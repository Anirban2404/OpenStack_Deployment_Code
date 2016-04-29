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

# Enable the OpenStack repository and install openstack packages in Controller node
chmod 755 openstack_packages.sh
./openstack_packages.sh

# Enable the OpenStack repository and install openstack packages in Compute node by ssh from Controller node
# It'll execute the below script in Compute node(s)
# ./Compute/openstack_packages.sh
chmod 755 controller_openstackpkgs_computes.sh
./controller_openstackpkgs_computes.sh

# Install and configure components SQL database (MariaDB) in Controller Node
chmod 755 controller_sqlsetup.sh
./controller_sqlsetup.sh

# Install and configure components NoSQL database (MongoDB) in Controller Node
chmod 755 controller_nosqlsetup.sh
./controller_nosqlsetup.sh

# Message queue RABBITMQ setup
chmod 755 controller_messagequeuesetup.sh
./controller_messagequeuesetup.sh

echo;
echo "##############################################################################################"
echo;
echo "Openstack environment setup is done."
echo;
echo "##############################################################################################"
echo;