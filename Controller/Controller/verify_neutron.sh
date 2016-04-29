#!/bin/bash
##################################################
#                                                #
# Purpose: Verify operations of the neutron      #
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

# List loaded extensions to verify successful launch of the neutron-server process
neutron ext-list

# List agents to verify successful launch of the neutron agents
neutron agent-list

echo;
echo "##############################################################################################"
echo;
echo " Verification of Neutron service is done."
echo;
echo "##############################################################################################"
echo;