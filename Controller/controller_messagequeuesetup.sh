#!/bin/bash
##################################################
#                                                #
# Purpose: Message queue RABBITMQ setup in the   #
#          Controller node.                      #
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


echo "########################################################################################"
echo;
echo "Please provide rabbit user password in ~/.password file."
echo;
echo "########################################################################################"
read RABBIT_PASS

# Create .password file at /root/
cat >  /root/.password  <<EOF
RABBIT_PASS = $RABBIT_PASS 
EOF


# install Message queue
echo;
echo "##############################################################################################"
echo;
echo "Setting up Message queue RabbitMQ now."
echo;
echo "##############################################################################################"
echo;
apt-get install rabbitmq-server -y



RABBIT_PASS=$(cat ~/.password | awk '/RABBIT_PASS/ {print $3}')
# Add the openstack user
rabbitmqctl add_user openstack $RABBIT_PASS
# Permit configuration, write, and read access for the openstack user
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

echo;
echo "##############################################################################################"
echo;
echo "Message queue RabbitMQ setup is done."
echo;
echo "##############################################################################################"
echo;