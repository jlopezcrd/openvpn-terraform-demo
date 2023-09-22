#!/bin/bash

terraform -chdir=account-services destroy --auto-approve
terraform -chdir=openvpn-service destroy --auto-approve

if [ -d .clients ]; then
    rm -rf .clients
fi

if [ -f openvpn.config.txt]; then
    rm openvpn.config.txt
fi