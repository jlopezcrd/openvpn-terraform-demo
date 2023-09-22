#!/bin/bash

if [ "${service}" = "" ]; then
    echo "Error, you have to set the service"
    exit 1
else
    terraform -chdir=${service} apply --auto-approve
    if [ $(echo "${service}" | grep -i "openvpn-service") ]; then
        terraform -chdir=${service} output -json > ../openvpn.config.txt
    fi
fi