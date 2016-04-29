#!/bin/bash
##################################################
#                                                #
# Purpose: Install and configure components NoSQL#
#          database (MongoDB) in Controller Node #
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

# install NoSQL database
echo;
echo "##############################################################################################"
echo;
echo "Setting up NoSQL MongoDB now."
echo;
echo "##############################################################################################"
echo;
apt-get install mongodb-server mongodb-clients python-pymongo --force-yes -y

# Get the nic card of the private network
pvt_nic=$(cat ~/.nic_interfaces |awk '/private_interface/ {print $3}')
# Get the ip of the private network
pvt_ip=$(/sbin/ifconfig $pvt_nic| sed -n 's/.*inet *addr:\([0-9\.]*\).*/\1/p')
cp /etc/mongodb.conf /etc/mongodb.conf.orig

# Edit /etc/mongodb.conf file
cat > /etc/mongodb.conf  <<EOF
# mongodb.conf

# Where to store the data.
dbpath=/var/lib/mongodb

#where to log
logpath=/var/log/mongodb/mongodb.log

logappend=true

#bind_ip = 127.0.0.1
#port = 27017
bind_ip = $pvt_ip

# Enable journaling, http://www.mongodb.org/display/DOCS/Journaling
journal=true

# Enables periodic logging of CPU utilization and I/O wait
#cpu = true

# Turn on/off security.  Off is currently the default
#noauth = true
#auth = true

# Verbose logging output.
#verbose = true

# Inspect all client data for validity on receipt (useful for
# developing drivers)
#objcheck = true

# Enable db quota management
#quota = true

# Set oplogging level where n is
#   0=off (default)
#   1=W
#   2=R
#   3=both
#   7=W+some reads
#oplog = 0

# Diagnostic/debugging option
#nocursors = true

# Ignore query hints
#nohints = true

# Disable the HTTP interface (Defaults to localhost:27018).
#nohttpinterface = true

# Turns off server-side scripting.  This will result in greatly limited
# functionality
#noscripting = true

# Turns off table scans.  Any query that would do a table scan fails.
#notablescan = true

# Disable data file preallocation.
#noprealloc = true

# Specify .ns file size for new databases.
# nssize = <size>

# Accout token for Mongo monitoring server.
#mms-token = <token>

# Server name for Mongo monitoring server.
#mms-name = <server-name>

# Ping interval for Mongo monitoring server.
#mms-interval = <seconds>

# Replication Options

# in replicated mongo databases, specify here whether this is a slave or master
#slave = true
#source = master.example.com
# Slave only: specify a single database to replicate
#only = master.example.com
# or
#master = true
#source = slave.example.com

# Address of a server to pair with.
#pairwith = <server:port>
# Address of arbiter server.
#arbiter = <server:port>
# Automatically resync if slave data is stale
#autoresync
# Custom size for replication operation log.
#oplogSize = <MB>
# Size limit for in-memory storage of op ids.
#opIdMem = <bytes>

# SSL options
# Enable SSL on normal ports
#sslOnNormalPorts = true
# SSL Key file and password
#sslPEMKeyFile = /etc/ssl/mongodb.pem
#sslPEMKeyPassword = pass
EOF

# restart mongodb service
service mongodb stop
rm /var/lib/mongodb/journal/prealloc.*
service mongodb start

echo;
echo "##############################################################################################"
echo;
echo "Setting up NoSQL MongoDB is done."
echo;
echo "##############################################################################################"
echo;
