#!/bin/bash
##################################################
#                                                #
# Purpose: linux portforward in Controller node. #
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

# Get the nic card of the private network
pvt_nic=$(cat ~/.nic_interfaces |awk '/private_interface/ {print $3}')

# Get the nic card of the public network
pub_nic=$(cat ~/.nic_interfaces |awk '/public_interface/ {print $3}')

# Change the ip forward rules
iptables -t nat -A POSTROUTING -o $pvt_nic -j MASQUERADE
iptables -A FORWARD -i $pvt_nic -o $pub_nic -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $pub_nic -o $pvt_nic -j ACCEPT
iptables-save > /etc/iptables.sav

# Change /etc/rc.local file
cat >  /etc/rc.local <<EOF
#!/bin/sh
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
echo "1" > /proc/sys/net/ipv4/ip_forward
iptables-restore < /etc/iptables.sav
exit 0
EOF

# Change /etc/sysctl.conf file
cat >> /etc/sysctl.conf <<EOF
net.ipv4.conf.default.rp_filter=0
net.ipv4.conf.all.rp_filter=0

net.ipv4.ip_forward=1
EOF

echo "########################################################################################"
echo;
echo "Linux port forward is done."
echo;
echo "########################################################################################"