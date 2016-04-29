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

# Install and Configure nova-compute in controller node
chmod 755 controller_nova_setup.sh
./controller_nova_setup.sh

# Install and Configure nova-compute in compute node(s) by ssh from Controller node
chmod 755 controller_nova_computes.sh
./controller_nova_computes.sh
# It'll execute the below script in Compute node(s)
# ./Compute/compute_nova_setup.sh

# Verify nova setup from Controller node
chmod 755 verify_nova.sh
./verify_nova.sh