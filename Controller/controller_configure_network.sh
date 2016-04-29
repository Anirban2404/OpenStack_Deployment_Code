#!/bin/bash
##################################################
#                                                #
# Purpose: Setup the network and configure it    #
#          on the Controller node.               #
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

# Execute to enable root login 
chmod 755 enable_root_login.sh
./enable_root_login.sh

# Setup controller name
chmod 755 controller_name_setup.sh
./controller_name_setup.sh

# Execute to do linux portforward
chmod 755 linux_portforward.sh
./linux_portforward.sh

# Execute to setup network on controller node
chmod 755 openstack_network_setup.sh
./openstack_network_setup.sh
