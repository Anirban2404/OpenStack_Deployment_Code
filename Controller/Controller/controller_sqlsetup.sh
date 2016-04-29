#!/bin/bash
##################################################
#                                                #
# Purpose: Install and configure components SQL  #
#          database (MariaDB) in Controller Node #
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

# install SQL database
echo;
echo "##############################################################################################"
echo;
echo "Setting up MySQL now.  You will be prompted to set a MySQL root password by the setup process."
echo;
echo "##############################################################################################"
echo;
apt-get install mariadb-server python-pymysql --force-yes -y

# Get the nic card of the private network
pvt_nic=$(cat ~/.nic_interfaces |awk '/private_interface/ {print $3}')
# Get the ip of the private network
pvt_ip=$(/sbin/ifconfig $pvt_nic| sed -n 's/.*inet *addr:\([0-9\.]*\).*/\1/p')

# Configure 
# Edit /etc/mysql/conf.d/mysqld_openstack.cnf file
cat >   /etc/mysql/conf.d/mysqld_openstack.cnf  <<EOF
# setup mysql to support utf8 and innodb
[mysqld]
bind-address = $pvt_ip
default-storage-engine = innodb
innodb_file_per_table
collation-server = utf8_general_ci
init-connect = 'SET NAMES utf8'
character-set-server = utf8
EOF

# restart mysql service
service mysql restart

echo;
echo "##############################################################################################"
echo;
echo "Setting up MySQL is done"
echo;
echo "##############################################################################################"
echo;
