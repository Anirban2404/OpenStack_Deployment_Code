#!/bin/bash
##################################################
#                                                #
# Purpose: Install and configure Self-service    #
#          networks                              #
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

# Get the nic card name of public network
pub_nic=$(cat ~/.nic_interfaces |awk '/public_interface/ {print $3}')
# Get the ip of public network
pub_ip=$(/sbin/ifconfig $pub_nic| sed -n 's/.*inet *addr:\([0-9\.]*\).*/\1/p')

# Configure the Linux bridge agent
# Edit the /etc/neutron/plugins/ml2/linuxbridge_agent.ini file
cat >  /etc/neutron/plugins/ml2/linuxbridge_agent.ini <<EOF
[linux_bridge]
# (ListOpt) Comma-separated list of
# <physical_network>:<physical_interface> tuples mapping physical
# network names to the agent's node-specific physical network
# interfaces to be used for flat and VLAN networks. All physical
# networks listed in network_vlan_ranges on the server should have
# mappings to appropriate interfaces on each agent.
#
# physical_interface_mappings =
# Example: physical_interface_mappings = physnet1:eth1
physical_interface_mappings = public:$pub_nic
[vxlan]
# (BoolOpt) enable VXLAN on the agent
# VXLAN support can be enabled when agent is managed by ml2 plugin using
# linuxbridge mechanism driver.
enable_vxlan = True
#
# (IntOpt) use specific TTL for vxlan interface protocol packets
# ttl =
#
# (IntOpt) use specific TOS for vxlan interface protocol packets
# tos =
#
# (StrOpt) multicast group or group range to use for broadcast emulation.
# Specifying a range allows different VNIs to use different group addresses,
# reducing or eliminating spurious broadcast traffic to the tunnel endpoints.
# Ranges are specified by using CIDR notation. To reserve a unique group for
# each possible (24-bit) VNI, use a /8 such as 239.0.0.0/8.
# This setting must be the same on all the agents.
# vxlan_group = 224.0.0.1
#
# (StrOpt) Local IP address to use for VXLAN endpoints (required)
local_ip = $pub_ip
#
# (BoolOpt) Flag to enable l2population extension. This option should be used
# in conjunction with ml2 plugin l2population mechanism driver (in that case,
# both linuxbridge and l2population mechanism drivers should be loaded).
# It enables plugin to populate VXLAN forwarding table, in order to limit
# the use of broadcast emulation (multicast will be turned off if kernel and
# iproute2 supports unicast flooding - requires 3.11 kernel and iproute2 3.10)
# l2_population = False
l2_population = True

[agent]
# Agent's polling interval in seconds
# polling_interval = 2

# (IntOpt) Set new timeout in seconds for new rpc calls after agent receives
# SIGTERM. If value is set to 0, rpc timeout won't be changed.
#
# quitting_rpc_timeout = 10
prevent_arp_spoofing = True

[securitygroup]
# Firewall driver for realizing neutron security group function
# firewall_driver = neutron.agent.firewall.NoopFirewallDriver
# Example: firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver

# Controls if neutron security group is enabled or not.
# It should be false when you use nova security group.
enable_security_group = True
firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver
EOF

compute_name=$(cat /etc/hostname)

echo;
echo "##############################################################################################"
echo;
echo "Installation and configuration of Self-service networks in "$compute_name" node is done."
echo;
echo "##############################################################################################"
echo;