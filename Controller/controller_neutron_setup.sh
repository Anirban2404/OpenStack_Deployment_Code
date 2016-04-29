#!/bin/bash
##################################################
#                                                #
# Purpose: Install and configure components of   #
#          neutron networking service            #
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
echo "Please provide NEUTRONDB password in ~/.password file."
echo;
echo "########################################################################################"
read NEUTRON_DBPASS

cat >>  /root/.password  <<EOF
NEUTRON_DBPASS = $NEUTRON_DBPASS
EOF

# update .password file
echo "########################################################################################"
echo;
echo "Please provide NEUTRON user password in ~/.password file."
echo;
echo "########################################################################################"
read NEUTRON_PASS

cat >>  /root/.password  <<EOF
NEUTRON_PASS = $NEUTRON_PASS
EOF

# update .password file
echo "########################################################################################"
echo;
echo "Please provide METADATA_SECRET in ~/.password file."
echo;
echo "########################################################################################"
read METADATA_SECRET

cat >>  /root/.password  <<EOF
METADATA_SECRET = $METADATA_SECRET
EOF

# Read passwords
MARIADB_PASS=$(cat ~/.password | awk '/MARIADB_PASS/ {print $3}')
NEUTRON_DBPASS=$(cat ~/.password | awk '/NEUTRON_DBPASS/ {print $3}')
NEUTRON_PASS=$(cat ~/.password | awk '/NEUTRON_PASS/ {print $3}')
METADATA_SECRET=$(cat ~/.password | awk '/METADATA_SECRET/ {print $3}')

# Get controller name
controller_name=$(cat /etc/hostname)

# To create the database, complete the following actions:
# Use the database access client to connect to the database server as the root user
# Create the neutron database
# Grant proper access to the neutron database
mysql -u root --password=$MARIADB_PASS <<EOF
CREATE DATABASE neutron;
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' \
  IDENTIFIED BY '$NEUTRON_DBPASS';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' \
  IDENTIFIED BY '$NEUTRON_DBPASS';
EOF

# Source the admin credentials to gain access to admin-only CLI commands
. ~/./admin-openrc.sh
echo "########################################################################################"
echo;
echo "Please provide neutron user password, also update ~/.password file."
echo;
echo "########################################################################################"

#Create the neutron user
openstack user create --domain default --password-prompt neutron

#Add the admin role to the neutron user
openstack role add --project service --user neutron admin

#Create the neutron service entity
openstack service create --name neutron \
  --description "OpenStack Networking" network

#Create the Networking service API endpoints
openstack endpoint create --region RegionOne \
  network public http://$controller_name:9696

openstack endpoint create --region RegionOne \
  network internal http://$controller_name:9696

openstack endpoint create --region RegionOne \
  network admin http://$controller_name:9696

# Configure networking options: Self-service networks
chmod 755 /root/Controller/controller_neutron_selfservice_setup.sh
./controller_neutron_selfservice_setup.sh

# Edit the /etc/neutron/metadata_agent.ini file 
cat >  /etc/neutron/metadata_agent.ini  <<EOF
[DEFAULT]
# Show debugging output in log (sets DEBUG log level output)
debug = True

# The Neutron user information for accessing the Neutron API.
#auth_url = http://localhost:5000/v2.0
#auth_region = RegionOne
# Turn off verification of the certificate for ssl
# auth_insecure = False
# Certificate Authority public key (CA cert) file for ssl
# auth_ca_cert =
#admin_tenant_name = %SERVICE_TENANT_NAME%
#admin_user = %SERVICE_USER%
#admin_password = %SERVICE_PASSWORD%

auth_uri = http://$controller_name:5000
auth_url = http://$controller_name:35357
auth_region = RegionOne
auth_plugin = password
project_domain_id = default
user_domain_id = default
project_name = service
username = neutron
password = $NEUTRON_PASS

# Network service endpoint type to pull from the keystone catalog
# endpoint_type = adminURL

# IP address used by Nova metadata server
nova_metadata_ip = $controller_name

# TCP Port used by Nova metadata server
# nova_metadata_port = 8775

# Which protocol to use for requests to Nova metadata server, http or https
# nova_metadata_protocol = http

# Whether insecure SSL connection should be accepted for Nova metadata server
# requests
# nova_metadata_insecure = False

# Client certificate for nova api, needed when nova api requires client
# certificates
# nova_client_cert =

# Private key for nova client certificate
# nova_client_priv_key =

# When proxying metadata requests, Neutron signs the Instance-ID header with a
# shared secret to prevent spoofing.  You may select any string for a secret,
# but it must match here and in the configuration used by the Nova Metadata
# Server. NOTE: Nova uses the same config key, but in [neutron] section.
metadata_proxy_shared_secret = $METADATA_SECRET

# Location of Metadata Proxy UNIX domain socket
# metadata_proxy_socket = $state_path/metadata_proxy

# Metadata Proxy UNIX domain socket mode, 4 values allowed:
# 'deduce': deduce mode from metadata_proxy_user/group values,
# 'user': set metadata proxy socket mode to 0o644, to use when
# metadata_proxy_user is agent effective user or root,
# 'group': set metadata proxy socket mode to 0o664, to use when
# metadata_proxy_group is agent effective group,
# 'all': set metadata proxy socket mode to 0o666, to use otherwise.
# metadata_proxy_socket_mode = deduce

# Number of separate worker processes for metadata server. Defaults to
# half the number of CPU cores
# metadata_workers =

# Number of backlog requests to configure the metadata server socket with
# metadata_backlog = 4096

# URL to connect to the cache backend.
# default_ttl=0 parameter will cause cache entries to never expire.
# Otherwise default_ttl specifies time in seconds a cache entry is valid for.
# No cache is used in case no value is passed.
# cache_url = memory://?default_ttl=5

[AGENT]
# Log agent heartbeats from this Metadata agent
# log_agent_heartbeats = False
EOF

# Edit the /etc/nova/nova.conf file 
cat >>  /etc/nova/nova.conf  <<EOF

[neutron]
url = http://$controller_name:9696
auth_url = http://$controller_name:35357
auth_plugin = password
project_domain_id = default
user_domain_id = default
region_name = RegionOne
project_name = service
username = neutron
password = $NEUTRON_PASS

service_metadata_proxy = True
metadata_proxy_shared_secret = $METADATA_SECRET
EOF

# Populate the database
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
  --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

# Restart the Compute API service
service nova-api restart

# Restart the Networking services
service neutron-server restart
service neutron-plugin-linuxbridge-agent restart
service neutron-dhcp-agent restart
service neutron-metadata-agent restart
service neutron-l3-agent restart

rm -f /var/lib/neutron/neutron.sqlite

echo;
echo "##############################################################################################"
echo;
echo "Openstack NEUTRON Controller setup is done."
echo;
echo "##############################################################################################"
echo;
