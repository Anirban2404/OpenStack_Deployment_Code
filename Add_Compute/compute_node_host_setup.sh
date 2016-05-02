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

cp /etc/hosts /etc/hosts.orig
echo;
echo "Editing /etc/hosts file"

echo "########################################################################################"
echo;
echo " Please provide name of controller node "
echo;
echo "########################################################################################"
read controller_node_name

echo "########################################################################################"
echo;
echo " Please provide Private IP of controller node "
echo;
echo "########################################################################################"
read controller_node_ip

# Name of new compute node
new_compute_node_name=$(cat /etc/hostname)

# Get the nic card of the private network
pvt_nic=$(cat ~/.nic_interfaces |awk '/private_interface/ {print $3}')

# Get the Controller node private ip
new_compute_node_ip=$(ip addr show $pvt_nic | awk '/inet / {print $2}'|sed 's/\/.*//')

# Get all required files for current compute node from controller node
ssh -n $new_compute_node_ip 'sed -i '/# computes/a $new_compute_node_ip $'\t' $new_compute_node_name' /etc/hosts'
mkdir -p ~/.ssh
scp ~/.ssh/authorized_keys $new_compute_node_name:~/.ssh/authorized_keys
ssh -n $new_compute_node_name 'chmod 644 ~/.ssh/authorized_keys'
scp ~/.ssh/id_rsa $new_compute_node_name:~/.ssh/id_rsa
ssh -n $new_compute_node_name 'chmod 400 ~/.ssh/id_rsa'
scp ~/.ssh/id_rsa.pub $new_compute_node_name:~/.ssh/id_rsa.pub
ssh -n $new_compute_node_name 'chmod 644 ~/.ssh/id_rsa.pub'
scp /etc/hosts $new_compute_node_name:/etc/hosts

chmod 755 /root/Add_Compute/change_hosts.sh
./root/Add_Compute/change_hosts.sh

apt-get update
echo "########################################################################################"
echo;
echo "New compute node /etc/hosts setup and ssh setup is done"
echo;
echo "########################################################################################"