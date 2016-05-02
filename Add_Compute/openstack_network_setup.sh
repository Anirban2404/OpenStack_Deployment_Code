#!/bin/bash
##################################################
#                                                #
# Purpose: Setup /etc/network/interfaces         #
#          in the node.                          #
# Author: Anirban Bhattacharjee                  #
# Date: 25-APR-2016                              #
#                                                #
##################################################
## get UID
uid=$(id -u)

# Make sure only root can run our script
if [ $uid -ne 0 ]; then
   echo "$USER, you need to have root access."
   exit 1
fi

cp /etc/network/interfaces /etc/network/interfaces.orig

echo;
echo "Editing /etc/network/interfaces file"
echo "Please provide the public ip address of the node:"
read pub_ip_address
if [ ${#pub_ip_address} -eq 0 ]
  then echo "Please enter public IP address"
  exit 1
fi

echo "Please provide public netmask address"
read pub_netmask
if [ ${#pub_netmask} -eq 0 ]
  then pub_netmask="255.255.255.128"
fi

echo "Please provide network address"
read network
if [ ${#network} -eq 0 ]
  then network="129.59.234.128"
fi

echo "Please provide broadcast address"
read broadcast
if [ ${#broadcast} -eq 0 ]
  then broadcast="129.59.234.255"
fi

echo "Please provide gateway address"
read gateway
if [ ${#gateway} -eq 0 ]
  then gateway="129.59.234.129"
fi

echo "Please provide dns nameservers address"
read dns_nameservers
if [ ${#dns_nameservers} -eq 0 ]
  then dns_nameservers="8.8.8.8"
fi

echo "Please provide the private ip address of the node:"
read pvt_ip_address
if [ ${#pvt_ip_address} -eq 0 ]
  then echo "Please enter private IP address"
  exit 1
fi

echo "Please provide private netmask address"
read pvt_netmask
if [ ${#pvt_netmask} -eq 0 ]
  then pvt_netmask="255.255.255.0"
fi

# Get the nic card of the private network
pvt_nic=$(cat ~/.nic_interfaces |awk '/private_interface/ {print $3}')

# Get the nic card of the public network
pub_nic=$(cat ~/.nic_interfaces |awk '/public_interface/ {print $3}')

# Change /etc/network/interfaces file
cat >  /etc/network/interfaces <<EOL
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto $pub_nic
iface $pub_nic inet static
        address $pub_ip_address
        netmask $pub_netmask
        network $network
        broadcast $broadcast
        gateway $gateway
        # dns-* options are implemented by the resolvconf package, if installed
        dns-nameservers $dns_nameservers

# Configuring the private network
auto $pvt_nic
iface $pvt_nic inet static
        address $pvt_ip_address
        netmask $pvt_netmask
        dns-nameservers $dns_nameservers

EOL

# Reboot the machine
reboot