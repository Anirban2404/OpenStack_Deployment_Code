#!/bin/bash
##################################################
#                                                #
# Purpose: Configure /etc/hosts in Controller    #
#          node.                                 #
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

# Change /etc/hosts file
echo "########################################################################################"
echo;
echo "Editing /etc/hosts file"
echo;
echo "########################################################################################"
cp /etc/hosts /etc/hosts.orig

# Compute node(s) setup
echo "How many compute node do you need?"
read num_of_compute_nodes

echo "Name of controller node?"
controller_node_name=$(cat /etc/hostname)

# Get the nic card of the private network
pvt_nic=$(cat ~/.nic_interfaces |awk '/private_interface/ {print $3}')

# Get the Controller node private ip
controller_node_ip=$(ip addr show $pvt_nic | awk '/inet / {print $2}'|sed 's/\/.*//')

num=1

# Change /etc/hosts file
cat >  /etc/hosts <<EOF
127.0.0.1       localhost

# controllers
$controller_node_ip     $controller_node_name

# computes
EOF


while [ $num -le $num_of_compute_nodes ]
do
        echo "Name of compute node?"
        read compute_node_name

        echo "Private IP of compute node?"
        read compute_node_ip

        num=`expr $num + 1`
        echo $compute_node_ip$'\t' $compute_node_name>> /etc/hosts
done


cat >>  /etc/hosts <<EOL

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters"
EOL

apt-get update
echo "########################################################################################"
echo;
echo "New controller /etc/hosts setup is done"
echo;
echo "########################################################################################"
