#!/bin/bash
##################################################
#                                                #
# Purpose: Setup chrony in all nodes             #
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

# Setup Network Time Protocol (NTP)--Chrony in controller node
chmod 755 controller_chrony.sh
./controller_chrony.sh

# Setup Network Time Protocol (NTP)--Chrony in compute node(s) by ssh from Controller node
# It'll execute the below script in Compute node(s)
# ./Compute/compute_chrony.sh
chmod 755 controller_chrony_computes.sh
./controller_chrony_computes.sh

echo;
echo "##############################################################################################"
echo;
echo "Chrony setup is done."
echo;
echo "##############################################################################################"
echo;