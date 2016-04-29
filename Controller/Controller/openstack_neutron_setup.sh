#!/bin/bash
##################################################
#                                                #
# Purpose: Setup networking service -- Neutron   #
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
# Install and configure neutron service
# Add OpenStack Networking – neutron in controller node
chmod 755 controller_neutron_setup.sh 
./controller_neutron_setup.sh 

# It includes controller_neutron_selfservice_setup.sh

# Install and Configure OpenStack Networking – neutron in compute node(s) by ssh from Controller node
# It'll execute the below script in Compute node(s)
# ./Compute/compute_neutron_setup.sh
# It includes compute_neutron_selfservice_setup.sh
chmod 755 controller_neutron_computes.sh
./controller_neutron_computes.sh

# Verify neutron networking service
chmod 755 verify_neutron.sh 
./verify_neutron.sh