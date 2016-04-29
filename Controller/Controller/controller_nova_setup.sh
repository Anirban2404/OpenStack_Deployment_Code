#!/bin/bash
##################################################
#                                                #
# Purpose: Install and configure components of   #
#          nova compute service                  #
# Author: Anirban Bhattacharjee                  #
# Date: 25-APR-2016                              #
#                                                #
##################################################
#                                                #
# Should run on CONTROLLER NODE                  #
#                                                #
##################################################

## get UID
uid=$(id -u)

# Make sure only root can run our script
if [ $uid -ne 0 ]; then
   echo "$USER, you need to have root access."
   exit 1
fi

# update .password file
echo "########################################################################################"
echo;
echo "Please provide NOVADB password in ~/.password file."
echo;
echo "########################################################################################"
read NOVA_DBPASS

cat >>  /root/.password  <<EOF
NOVA_DBPASS = $NOVA_DBPASS
EOF

# update .password file
echo "########################################################################################"
echo;
echo "Please provide NOVA user password in ~/.password file."
echo;
echo "########################################################################################"
read NOVA_PASS

cat >>  /root/.password  <<EOF
NOVA_PASS = $NOVA_PASS
EOF

# Read passwords
MARIADB_PASS=$(cat ~/.password | awk '/MARIADB_PASS/ {print $3}')
NOVA_DBPASS=$(cat ~/.password | awk '/NOVA_DBPASS/ {print $3}')
RABBIT_PASS=$(cat ~/.password | awk '/RABBIT_PASS/ {print $3}')
NOVA_PASS=$(cat ~/.password | awk '/NOVA_PASS/ {print $3}')

# Get controller name
controller_name=$(cat /etc/hostname)

# To create the database, complete the following actions:
# Use the database access client to connect to the database server as the root user
# Create the nova database
# Grant proper access to the nova database
mysql -u root --password=$MARIADB_PASS <<EOF
CREATE DATABASE nova;
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' \
  IDENTIFIED BY '$NOVA_DBPASS';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' \
  IDENTIFIED BY '$NOVA_DBPASS';
EOF

#Source the admin credentials to gain access to admin-only CLI commands
. ~/./admin-openrc.sh

echo "########################################################################################"
echo;
echo "Please provide nova user password, also update ~/.password file."
echo;
echo "########################################################################################"
openstack user create --domain default --password-prompt nova

#Add the admin role to the nova user
openstack role add --project service --user nova admin

#Create the nova service entity
openstack service create --name nova \
  --description "OpenStack Compute" compute

#Create the Compute service API endpoints
openstack endpoint create --region RegionOne \
  compute public http://$controller_name:8774/v2/%\(tenant_id\)s

openstack endpoint create --region RegionOne \
  compute internal http://$controller_name:8774/v2/%\(tenant_id\)s

 openstack endpoint create --region RegionOne \
  compute admin http://$controller_name:8774/v2/%\(tenant_id\)s

#Install nova components
apt-get install nova-api nova-cert nova-conductor \
  nova-consoleauth nova-novncproxy nova-scheduler \
  python-novaclient -y

# Get the nic card name of private network
pvt_nic=$(cat ~/.nic_interfaces |awk '/private_interface/ {print $3}')
# Get the ip of private network
pvt_ip=$(/sbin/ifconfig $pvt_nic| sed -n 's/.*inet *addr:\([0-9\.]*\).*/\1/p')

# Edit the /etc/nova/nova.conf file
cat >  /etc/nova/nova.conf   <<EOF
[DEFAULT]
dhcpbridge_flagfile=/etc/nova/nova.conf
dhcpbridge=/usr/bin/nova-dhcpbridge
logdir=/var/log/nova
state_path=/var/lib/nova
lock_path=/var/lock/nova
force_dhcp_release=True
libvirt_use_virtio_for_bridges=True
verbose=True
ec2_private_dns_show_ip=True
api_paste_config=/etc/nova/api-paste.ini
#enabled_apis=ec2,osapi_compute,metadata

rpc_backend = rabbit
my_ip = $pvt_ip
network_api_class = nova.network.neutronv2.api.API
security_group_api = neutron
linuxnet_interface_driver = nova.network.linux_net.NeutronLinuxBridgeInterfaceDriver
firewall_driver = nova.virt.firewall.NoopFirewallDriver
auth_strategy = keystone
enabled_apis=osapi_compute,metadata

#Fail instance boot if vif plugging fails
vif_plugging_is_fatal = False

#Number of seconds to wait for neutron vif
#plugging events to arrive before continuing or failing
#(see vif_plugging_is_fatal). If this is set to zero and
#vif_plugging_is_fatal is False, events should not be expected to arrive at all.
vif_plugging_timeout = 10

[database]
connection = mysql+pymysql://nova:$NOVA_DBPASS@$controller_name/nova

[glance]
host = $controller_name

[keystone_authtoken]
auth_uri = http://$controller_name:5000
auth_url = http://$controller_name:35357
auth_plugin = password
project_domain_id = default
user_domain_id = default
project_name = service
username = nova
password = $NOVA_PASS

[oslo_concurrency]
lock_path = /var/lib/nova/tmp

[oslo_messaging_rabbit]
rabbit_host = $controller_name
rabbit_userid = openstack
rabbit_password = $RABBIT_PASS

[vnc]
vncserver_listen = \$my_ip
vncserver_proxyclient_address = \$my_ip
EOF

# Populate the Compute database
su -s /bin/sh -c "nova-manage db sync" nova

# Restart the Compute services
service nova-api restart
service nova-cert restart
service nova-consoleauth restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart

rm -f /var/lib/nova/nova.sqlite

echo;
echo "##############################################################################################"
echo;
echo "Openstack NOVA Controller setup is done."
echo;
echo "##############################################################################################"
echo;


