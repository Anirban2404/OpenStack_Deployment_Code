#!/bin/bash
##################################################
#                                                #
# Purpose: verify chrony in node(s).             #
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

# verify
chronyc sources
