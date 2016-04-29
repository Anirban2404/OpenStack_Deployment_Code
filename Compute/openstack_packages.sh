#!/bin/bash
##################################################
#                                                #
# Purpose: Install OpenStack packages in         #
#          Compute node.                         #
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

# Enable the OpenStack repository
apt-get install software-properties-common -y
add-apt-repository cloud-archive:liberty -y
# Upgrade the packages
apt-get update && apt-get dist-upgrade -y
# Install the OpenStack client
apt-get install python-openstackclient -y

compute_name=$(cat /etc/hostname)

echo;
echo "##############################################################################################"
echo;
echo "Openstack Liberty package installation in "$compute_name" node is done."
echo;
echo "##############################################################################################"
echo;