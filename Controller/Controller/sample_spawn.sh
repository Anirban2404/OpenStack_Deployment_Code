#!/bin/bash
##################################################
#                                                #
# Purpose: Setup the network and configure it    #
#          on the Controller node.               #
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

export NET_ID=$(neutron net-list | awk '/private/ { print $2 }')

a=0
while [ $a -le $1 ]
do
   echo $a
   heat stack-create -f demo-template.yml -P "ImageID=cirros;NetID=$NET_ID" stack$a
   a=`expr $a + 1`
done

