#!/bin/bash
##################################################
#                                                #
# Purpose: Setup Network Time Protocol (NTP)     #
#          --Chrony in compute node(s) by ssh    #
#          from Controller node                  #
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

# Find the compute nodes and execute chrony setup
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
    # Execute chrony setup in compute node
    ssh -n $compute 'chmod 755 /root/Compute/compute_chrony.sh'
    ssh -n $compute ./Compute/compute_chrony.sh
    fi
 done < /etc/hosts

echo;
echo "##############################################################################################"
echo;
echo "Chrony setup in Compute node(s) is done."
echo;
echo "##############################################################################################"
echo;