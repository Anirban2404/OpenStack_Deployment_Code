#!/bin/bash
##################################################
#                                                #
# Purpose: Verify operations of the OpenStack    #
#          Orchestration heat service            #
#          networking service                    #
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
heat service-list

echo;
echo "##############################################################################################"
echo;
echo " Verification of Heat service is done."
echo;
echo "##############################################################################################"
echo;