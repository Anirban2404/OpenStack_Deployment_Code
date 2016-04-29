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
echo "Please provide name of private network you want to create"
echo;
echo "########################################################################################"
read PRIVATE_NETWORK_NAME

#Create the network
neutron net-create $PRIVATE_NETWORK_NAME

echo "########################################################################################"
echo;
echo "Please provide PRIVATE_NETWORK_CIDR e.g. 172.16.1.0/24"
echo;
echo "########################################################################################"
read PRIVATE_NETWORK_CIDR

echo "########################################################################################"
echo;
echo "Please provide DNS_RESOLVER"
echo;
echo "########################################################################################"
read DNS_RESOLVER

echo "########################################################################################"
echo;
echo "Please provide PRIVATE_NETWORK_GATEWAY"
echo;
echo "########################################################################################"
read PRIVATE_NETWORK_GATEWAY



neutron subnet-create $PRIVATE_NETWORK_NAME $PRIVATE_NETWORK_CIDR --name $PRIVATE_NETWORK_NAME \
  --dns-nameserver $DNS_RESOLVER --gateway $PRIVATE_NETWORK_GATEWAY


. ~/./admin-openrc.sh

echo "########################################################################################"
echo;
echo "Please add the router: external option to your public provider network"
echo;
echo "########################################################################################"
read PUBLIC_NETWORK_NAME

neutron net-update $PUBLIC_NETWORK_NAME --router:external

. ~/./demo-openrc.sh

#Create a router
echo "########################################################################################"
echo;
echo "Please provide the router name"
echo;
echo "########################################################################################"
read ROUTER_NAME

neutron router-create $ROUTER_NAME

#Add the private network subnet as an interface on the router
neutron router-interface-add $ROUTER_NAME $PRIVATE_NETWORK_NAME

#Set a gateway on the public network on the router
neutron router-gateway-set $ROUTER_NAME $PUBLIC_NETWORK_NAME

echo;
echo "##############################################################################################"
echo;
echo "Openstack Private network setup in Compute node(s) is done."
echo;
echo "##############################################################################################"
echo;