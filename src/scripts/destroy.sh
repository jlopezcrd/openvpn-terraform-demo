#!/bin/bash

if [ "${service}" = "" ]; then 
    echo "Error, you have to set the service"
    exit 1
else
    if [ $(echo "${service}" | grep -i "openvpn-service") && $(! -f "../../openvpn.config.txt") ]; then
      echo "--------------"
      echo "You must to destroy openvpn-server first"
      echo "--------------"
      exit 1
    fi

    terraform -chdir=${service} destroy --auto-approve
	
    if [ -d .clients ]; then
        rm -rf .clients
    fi
	
    if [ -f "../../openvpn.config.txt" ]; then
        rm -f ../../openvpn.config.txt
    fi

    if [ -f "../../account.output.txt" ]; then
        rm -f ../../account.output.txt
    fi
fi