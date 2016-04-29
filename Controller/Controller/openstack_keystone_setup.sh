#!/bin/bash
##################################################
#                                                #
# Purpose: Setup Identity service -- Keystone    #
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

# In openstack_keystone_setup.sh below scripts will be executed.
# Install and configure Keystone Identity service
chmod 755 controller_keystone_setup.sh
./controller_keystone_setup.sh

# Configure the Apache HTTP server
chmod 755 controller_apache_config.sh
./controller_apache_config.sh

# Create the keystone service entity and API endpoints and projects, users, and roles
chmod 755 openstack_keystone_endpoint_setup.sh
./openstack_keystone_endpoint_setup.sh

# Verify operation of the keystone Identity service before installing other services
chmod 755 verify_keystone.sh
./verify_keystone.sh