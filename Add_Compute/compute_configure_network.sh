#!/bin/bash
##################################################
#                                                #
# Purpose: Setup the network and configure it    #
#          on the Compute node.                  #
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

# Execute to enable root login 
chmod 755 enable_root_login.sh
./enable_root_login.sh

# Setup controller name
chmod 755 compute_name_setup.sh
./compute_name_setup.sh

# Execute to setup network on controller node
chmod 755 openstack_network_setup.sh
./openstack_network_setup.sh
