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

. ~/./admin-openrc.sh

echo "########################################################################################"
echo;
echo "Please provide name of public network you want to create"
echo;
echo "########################################################################################"
read PUBLIC_NETWORK_NAME

#Create the network
neutron net-create $PUBLIC_NETWORK_NAME --shared --provider:physical_network public \
  --provider:network_type flat


echo "########################################################################################"
echo;
echo "Please provide PUBLIC_NETWORK_CIDR e.g.203.0.113.0/24"
echo;
echo "########################################################################################"
read PUBLIC_NETWORK_CIDR

echo "########################################################################################"
echo;
echo "Please provide START_IP_ADDRESS"
echo;
echo "########################################################################################"
read START_IP_ADDRESS

echo "########################################################################################"
echo;
echo "Please provide END_IP_ADDRESS"
echo;
echo "########################################################################################"
read END_IP_ADDRESS

echo "########################################################################################"
echo;
echo "Please provide DNS_RESOLVER"
echo;
echo "########################################################################################"
read DNS_RESOLVER

echo "########################################################################################"
echo;
echo "Please provide PUBLIC_NETWORK_GATEWAY"
echo;
echo "########################################################################################"
read PUBLIC_NETWORK_GATEWAY

#Create a subnet on the network
neutron subnet-create $PUBLIC_NETWORK_NAME $PUBLIC_NETWORK_CIDR --name $PUBLIC_NETWORK_NAME \
  --allocation-pool start=$START_IP_ADDRESS,end=$END_IP_ADDRESS\
  --dns-nameserver $DNS_RESOLVER --gateway $PUBLIC_NETWORK_GATEWAY


echo;
echo "##############################################################################################"
echo;
echo "Openstack Public network setup in Compute node(s) is done."
echo;
echo "##############################################################################################"
echo;