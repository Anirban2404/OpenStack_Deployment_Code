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

# Source the admin credentials to gain access to admin-only CLI commands
. ~/./admin-openrc.sh

# List service components to verify successful launch and registration of each process
nova service-list

# List API endpoints in the Identity service to verify connectivity with the Identity service
nova endpoints

#List images in the Image service catalog to verify connectivity with the Image service
nova image-list

echo;
echo "##############################################################################################"
echo;
echo "Openstack NOVA setup verification is done."
echo;
echo "##############################################################################################"
echo;