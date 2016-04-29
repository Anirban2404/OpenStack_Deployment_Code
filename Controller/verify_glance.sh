#!/bin/bash
##################################################
#                                                #
# Purpose: Verification of glance image service  #
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

# In each client environment script, configure the Image service client to use API version 2.0
echo "export OS_IMAGE_API_VERSION=2" \
  | tee -a admin-openrc.sh demo-openrc.sh

# Source admin credentials 
 . ~/./admin-openrc.sh

# cirros image download
wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img

# Upload the image to the Image service using the QCOW2 disk format, bare container format,
# and public visibility so all projects can access it
glance image-create --name "cirros" \
  --file cirros-0.3.4-x86_64-disk.img \
  --disk-format qcow2 --container-format bare \
  --visibility public --progress

# ubuntu image download
wget http://uec-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-disk1.img

# Upload the image to the Image service using the QCOW2 disk format, bare container format,
# and public visibility so all projects can access it
glance image-create --name "ubuntu14.04" \
  --file trusty-server-cloudimg-amd64-disk1.img \
  --disk-format qcow2 --container-format bare \
  --visibility public --progress

# Confirm upload of the image and validate attributes
glance image-list

echo;
echo "##############################################################################################"
echo;
echo " Glance Image service verification is done."
echo;
echo "##############################################################################################"
echo;
