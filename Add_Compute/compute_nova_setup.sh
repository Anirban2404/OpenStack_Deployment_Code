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
# Should run on COMPUTE NODE                     #
#                                                #
##################################################

## get UID
uid=$(id -u)

# Make sure only root can run our script
if [ $uid -ne 0 ]; then
   echo "$USER, you need to have root access."
   exit 1
fi

apt-get update
# Install nova components
apt-get install nova-compute sysfsutils -y

# Source compute_env file
. ~/./.compute_env.sh

i=0
while read  -r line
 do
    i=`expr "$i" + 1`
    if [ $i -eq 4 ];then
        if [ ${#line} -eq 0 ]; then
             break
        fi
    controller_name=$(echo "$line" | awk '{print $2}')
    # Store the controller name
    echo "export controller=$controller_name" > /root/.compute_env.sh
    fi
 done < /etc/hosts
chmod 775  /root/.compute_env.sh

# Get controller name
controller_name=$controller

# Get updated .password file
ssh $controller_name 'cat ~/.password' >  ~/.password

# Read passwords
NOVA_DBPASS=$(cat ~/.password | awk '/NOVA_DBPASS/ {print $3}')
RABBIT_PASS=$(cat ~/.password | awk '/RABBIT_PASS/ {print $3}')
NOVA_PASS=$(cat ~/.password | awk '/NOVA_PASS/ {print $3}')

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

#[database]
#connection = mysql+pymysql://nova:$NOVA_DBPASS@$controller_name/nova

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
enabled = True
vncserver_listen = 0.0.0.0
vncserver_proxyclient_address = \$my_ip
novncproxy_base_url = http://$controller_name:6080/vnc_auto.html
EOF

# Restart the Compute services
service nova-compute restart
rm -f /var/lib/nova/nova.sqlite

compute_name=$(cat /etc/hostname)

echo;
echo "##############################################################################################"
echo;
echo "Openstack NOVA Compute setup in "$compute_name" node is done."
echo;
echo "##############################################################################################"
echo;