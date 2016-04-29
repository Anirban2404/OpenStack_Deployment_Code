#!/bin/bash
##################################################
#                                                #
# Purpose: Enable root login in the node.        #
# Author: Anirban Bhattacharjee                  #
# Date: 25-APR-2016                              #
#                                                #
##################################################
## get UID
uid=$(id -u)

# Make sure only root can run our script
if [ $uid -ne 0 ]; then
   echo "$USER, you need to have root access."
   exit 1
fi

# Change the PermitRootLogin without-password to PermitRootLogin yes
sed -i -e 's/without-password/yes/g' /etc/ssh/sshd_config

# Set New Password
echo "########################################################################################"
echo;
echo "Please provide new root password."
echo;
echo "########################################################################################"
sudo passwd root
service ssh restart

echo "########################################################################################"
echo;
echo "Root login is enabled."
echo;
echo "########################################################################################"
exit
