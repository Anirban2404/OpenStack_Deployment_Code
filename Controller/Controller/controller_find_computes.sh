#!/bin/bash
##################################################
#                                                #
# Purpose: Setup root ssh between controller and #
#          computes and edit /etc/hosts in       #
#          Compute nodes.                        #
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

# Function fot Setup root ssh between controller and computes edit /etc/hosts in Compute nodes
enable_ssh_compute(){
    ssh -n $compute 'mkdir -p ~/.ssh'
    ssh-copy-id  $compute
    scp ~/.ssh/id_rsa $compute:~/.ssh/id_rsa
    ssh -n $compute 'chmod 400 ~/.ssh/id_rsa'
    scp ~/.ssh/id_rsa.pub $compute:~/.ssh/id_rsa.pub
    ssh -n $compute 'chmod 644 ~/.ssh/id_rsa.pub'
    scp /etc/hosts $compute:/etc/hosts
}

# Generating ssh keypair
ssh-keygen -t rsa
cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys

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
    enable_ssh_compute
    fi
 done < /etc/hosts

echo;
echo "##############################################################################################"
echo;
echo "SSH to all compute nodes are done. Please check manually to be sure."
echo;
echo "##############################################################################################"
echo;


