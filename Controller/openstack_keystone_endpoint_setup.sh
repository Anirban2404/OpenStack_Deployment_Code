#!/bin/bash
##################################################
#                                                #
# Purpose: Create the keystone service entity    #
#          and API endpoints and projects, users,#
#          and roles                             #
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

# Get controller name
controller_name=$(cat /etc/hostname)

#configuring environment
cat >  /root/.openstack_env.sh <<EOF
export OS_TOKEN=a9d340b637594eaa9fa7
export OS_URL=http://$controller_name:35357/v3
export OS_IDENTITY_API_VERSION=3
EOF

sleep 2
chmod 755  /root/.openstack_env.sh
. /root/.openstack_env.sh


#Create the service entity and API endpoints
#Create the service entity for the Identity service

openstack service create \
  --name keystone --description "OpenStack Identity" identity

#Create the Identity service API endpoints

openstack endpoint create --region RegionOne \
  identity public http://$controller_name:5000/v2.0

openstack endpoint create --region RegionOne \
  identity internal http://$controller_name:5000/v2.0

openstack endpoint create --region RegionOne \
  identity admin http://$controller_name:35357/v2.0

#Create the admin project

openstack project create --domain default \
  --description "Admin Project" admin

echo "########################################################################################"
echo;
echo "Please provide admin user password."
echo;
echo "########################################################################################"

#Create the admin user

openstack user create --domain default \
  --password-prompt admin

#Create the admin role

openstack role create admin

#Add the admin role to the admin project and user

openstack role add --project admin --user admin admin

#Create the service project

openstack project create --domain default \
  --description "Service Project" service

#Create the demo project
openstack project create --domain default \
  --description "Demo Project" demo

#Create the demo user
echo "########################################################################################"
echo;
echo "Please provide demo user password."
echo;
echo "########################################################################################"

openstack user create --domain default \
  --password-prompt demo

#Create the user role

openstack role create user

#Add the user role to the demo project and user

openstack role add --project demo --user demo user

echo;
echo "##############################################################################################"
echo;
echo " Creation of Keystone service entity and API endpoints is done."
echo;
echo "##############################################################################################"
echo;