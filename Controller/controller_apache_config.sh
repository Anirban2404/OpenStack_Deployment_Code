#!/bin/bash
##################################################
#                                                #
# Purpose: Configure the Apache HTTP server      #
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

cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.orig

# Get controller name
controller_name=$(cat /etc/hostname)

# Edit the /etc/apache2/apache2.conf file
sed -i "/#ServerRoot/a ServerName $controller_name\n" /etc/apache2/apache2.conf

# Edit /etc/apache2/sites-available/wsgi-keystone.conf file
cat >  /etc/apache2/sites-available/wsgi-keystone.conf <<EOF
Listen 5000
Listen 35357

<VirtualHost *:5000>
    WSGIDaemonProcess keystone-public processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-public
    WSGIScriptAlias / /usr/bin/keystone-wsgi-public
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    <IfVersion >= 2.4>
      ErrorLogFormat "%{cu}t %M"
    </IfVersion>
    ErrorLog /var/log/apache2/keystone.log
    CustomLog /var/log/apache2/keystone_access.log combined

    <Directory /usr/bin>
        <IfVersion >= 2.4>
            Require all granted
        </IfVersion>
        <IfVersion < 2.4>
            Order allow,deny
            Allow from all
        </IfVersion>
    </Directory>
</VirtualHost>

<VirtualHost *:35357>
    WSGIDaemonProcess keystone-admin processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-admin
    WSGIScriptAlias / /usr/bin/keystone-wsgi-admin
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    <IfVersion >= 2.4>
      ErrorLogFormat "%{cu}t %M"
    </IfVersion>
    ErrorLog /var/log/apache2/keystone.log
    CustomLog /var/log/apache2/keystone_access.log combined

    <Directory /usr/bin>
        <IfVersion >= 2.4>
            Require all granted
        </IfVersion>
        <IfVersion < 2.4>
            Order allow,deny
            Allow from all
        </IfVersion>
    </Directory>
</VirtualHost>
EOF

# Enable the Identity service virtual hosts
ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled

#restart the Apache HTTP server
service apache2 restart
rm -f /var/lib/keystone/keystone.db

echo;
echo "##############################################################################################"
echo;
echo " Apache HTTP server configuration is done."
echo;
echo "##############################################################################################"
echo;