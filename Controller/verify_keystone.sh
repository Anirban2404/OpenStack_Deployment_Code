#!/bin/bash
##################################################
#                                                #
# Purpose: Verify operation of the keystone      #          
#          Identity service                      #
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

# Unset the temporary OS_TOKEN and OS_URL environment variables
unset OS_TOKEN OS_URL

# Get controller name
controller_name=$(cat /etc/hostname)

# update .password file
echo "########################################################################################"
echo;
echo "Please provide admin user password twice."
echo;
echo "########################################################################################"
read ADMIN_PASS

cat >>  /root/.password  <<EOF
ADMIN_PASS = $ADMIN_PASS 
EOF

# As the admin user, request an authentication token
openstack --os-auth-url http://$controller_name:35357/v3 \
  --os-project-domain-id default --os-user-domain-id default \
  --os-project-name admin --os-username admin --os-auth-type password \
  token issue

# update .password file
echo "########################################################################################"
echo;
echo "Please provide demo user password twice."
echo;
echo "########################################################################################"
read DEMO_PASS

cat >>  /root/.password  <<EOF
DEMO_PASS = $DEMO_PASS 
EOF

# As the demo user, request an authentication token
openstack --os-auth-url http://$controller_name:5000/v3 \
  --os-project-domain-id default --os-user-domain-id default \
  --os-project-name demo --os-username demo --os-auth-type password \
  token issue

#configuring admin environment
cat >  ~/admin-openrc.sh  <<EOF
export OS_PROJECT_DOMAIN_ID=default
export OS_USER_DOMAIN_ID=default
export OS_PROJECT_NAME=admin
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_AUTH_URL=http://$controller_name:35357/v3
export OS_IDENTITY_API_VERSION=3
EOF
chmod 700 ~/admin-openrc.sh

#configuring demo environment
cat >  ~/demo-openrc.sh  <<EOF
export OS_PROJECT_DOMAIN_ID=default
export OS_USER_DOMAIN_ID=default
export OS_PROJECT_NAME=demo
export OS_TENANT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=$DEMO_PASS
export OS_AUTH_URL=http://$controller_name:5000/v3
export OS_IDENTITY_API_VERSION=3
EOF
chmod 770 ~/demo-openrc.sh

# Load the admin-openrc.sh file to populate environment variables with the location 
# of the Identity service and the admin project and user credentials
. ~/./admin-openrc.sh

# Request an authentication token
openstack token issue

echo;
echo "##############################################################################################"
echo;
echo " Verification of Keystone service is done."
echo;
echo "##############################################################################################"
echo;