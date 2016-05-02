#!/bin/bash
##################################################
#                                                #
# Purpose: Enable root login in the node.        #
# Author: Anirban Bhattacharjee                  #
# Date: 28-APR-2016                              #
#                                                #
##################################################
#                                                #
# Should run on COMPUTE NODE                     #
#                                                #
##################################################

## get UID
uid=$(id -u)

# Make sure only root can run our script
if [ $uid -ne 0 ]; then
   echo "$USER, you need to have root access."
   exit 1
fi

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
    scp /etc/hosts $compute:/etc/hosts
    fi
 done < /etc/hosts

echo "########################################################################################"
echo;
echo "Add the node to all other compute nodes' /etc/hosts is done"
echo;
echo "########################################################################################"