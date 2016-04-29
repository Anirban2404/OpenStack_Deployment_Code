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

# Find the compute nodes and install and configure neutron compute packages
# in these compute nodes
i=0
while read -r line
 do
    echo $line
    i=`expr "$i" + 1`
    if [ $i -ge 7 ];then
        if [ ${#line} -eq 0 ]; then
             break
        fi
    compute=$(echo "$line" | awk '{print $2}')
    ssh -n $compute apt-get update
    ssh -n $compute 'chmod 755 /root/Compute/compute_neutron_setup.sh'
    ssh -n $compute ./Compute/compute_neutron_setup.sh
    fi
 done < /etc/hosts

echo;
echo "##############################################################################################"
echo;
echo "Openstack NEUTRON setup in Compute node(s) is done."
echo;
echo "##############################################################################################"
echo;
