#!/bin/bash

if [ "${service}" = "" ]; then 
    echo "Error, you have to set the service"
    exit 1
else
    terraform -chdir=${service} destroy --auto-approve
	
    if [ -d .clients ]; then
        rm -rf .clients
    fi
	
    if [ -f openvpn.config.txt]; then
        rm openvpn.config.txt
    fi
fi