#!/bin/bash
##################################################
#                                                #
# Purpose: Setup the name of the Controller node.#
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

# Get the old host name
host=$(cat /etc/hostname)

# Provide the new controller node
echo "########################################################################################"
echo;
echo "Please provide the name of the controller node:"
echo;
echo "########################################################################################"
read controller_name

while [ ${#controller_name} -eq 0 ]
  do
     echo "Please provide the name of the controller node:"
     read controller_name
  done

# Swap the old name with the new one
sed -i -e "s/$host/$controller_name/g" /etc/hostname

echo "########################################################################################"
echo;
echo "New controller name is $controller_name"
echo;
echo "########################################################################################"
