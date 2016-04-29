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

. ~/./demo-openrc.sh

echo "########################################################################################"
echo;
echo "Please provide name of key"
echo;
echo "########################################################################################"
read mykey

nova keypair-add --pub-key ~/.ssh/id_rsa.pub $mykey

#Verify addition of the key pair
nova keypair-list

#Add security group rules
#Permit ICMP (ping)
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0

#Permit secure shell (SSH) access
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0

echo;
echo "##############################################################################################"
echo;
echo "Openstack security setup in Compute node(s) is done."
echo;
echo "##############################################################################################"
echo;
