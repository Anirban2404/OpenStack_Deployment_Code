#!/bin/bash
##################################################
#                                                #
# Purpose: Install OpenStack packages in         #
#          Controller node.                      #
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

# Enable the OpenStack repository
apt-get install software-properties-common -y
add-apt-repository cloud-archive:liberty -y
# Upgrade the packages
apt-get update && apt-get dist-upgrade -y
# Install the OpenStack client
apt-get install python-openstackclient -y

echo;
echo "##############################################################################################"
echo;
echo "Openstack Liberty package installation in Controller node is done."
echo;
echo "##############################################################################################"
echo;
