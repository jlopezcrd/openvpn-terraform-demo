#!/bin/bash

for ((index=0; index<$(cat /opt/openvpn/users | jq 'users | length'); index++)); do
    client=$(cat /opt/openvpn/users | jq users[$index].name | sed -r 's/"//g')
    echo "---------------------"
    echo "Creating $client vpn..."
    echo "---------------------"
    sudo MENU_OPTION=1 CLIENT=$client PASS=1 /opt/openvpn/openvpn-install.sh
    sudo mv /root/$client.ovpn /opt/openvpn/clients/$client.ovpn
    sudo chown ubuntu:ubuntu /opt/openvpn/clients/$client.ovpn
done