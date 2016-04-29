#!/bin/bash
##################################################
#                                                #
# Purpose: Verify Live migration                 #
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

ls -ld /var/lib/nova/instances
df -k

compute_name=$(cat /etc/hostname)

echo;
echo "##############################################################################################"
echo;
echo "Verify Live migration setup in "$compute_name" node is done."
echo;
echo "##############################################################################################"
echo;
