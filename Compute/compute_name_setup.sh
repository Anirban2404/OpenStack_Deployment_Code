#!/bin/bash
##################################################
#                                                #
# Purpose: Setup the name of the Compute node.   #
# Author: Anirban Bhattacharjee                  #
# Date: 25-APR-2016                              #
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

# Get the old host name
host=$(cat /etc/hostname)

# Provide the new compute node
echo "########################################################################################"
echo;
echo "Please provide the name of the compute node:"
echo;
echo "########################################################################################"
read compute_name

while [ ${#compute_name} -eq 0 ]
  do
     echo "Please provide the name of the compute node:"
     read compute_name
  done

# Swap the old name with the new one
sed -i -e "s/$host/$compute_name/g" /etc/hostname

echo "########################################################################################"
echo;
echo "New compute name is $compute_name"
echo;
echo "########################################################################################"