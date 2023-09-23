#!/bin/bash

terraform -chdir=openvpn-service destroy --auto-approve
terraform -chdir=account-services destroy --auto-approve

if [ -d .clients ]; then
    rm -rf .clients
fi

if [ -f "../../openvpn.config.txt" ]; then
    rm -f ../../openvpn.config.txt
fi

if [ -f "../../account.output.txt" ]; then
    rm -f ../../account.output.txt
fi