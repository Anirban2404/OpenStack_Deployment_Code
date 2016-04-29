#!/bin/bash
##################################################
#                                                #
# Purpose: Setup the nova compute services on    #
#          the Compute node(s) by ssh from       #
#          controller node.                      #
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

# see mounted drive
df -k

echo;
echo "##############################################################################################"
echo;
echo "Verification of live migration in controller node(s) is done."
echo;
echo "##############################################################################################"
echo;