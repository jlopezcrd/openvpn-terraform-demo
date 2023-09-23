#!/bin/bash

if [ "${service}" = "" ]; then
    echo "Error, you have to set the service"
    exit 1
else
    if [ $(echo "${service}" | grep -i "openvpn-service") &&  $(! -f "../../account.output.txt") ]; then
      echo "--------------"
      echo "You must to run account-services first to prepare the basic account"
      echo "--------------"
      exit 1
    fi

    terraform -chdir=${service} apply --auto-approve

    if [ $(echo "${service}" | grep -i "account-services") ]; then
        terraform -chdir=${service} output -json > ../../account.output.txt
    fi

    if [ $(echo "${service}" | grep -i "openvpn-service") ]; then
        terraform -chdir=${service} output -json > ../../openvpn.config.txt
    fi
fi