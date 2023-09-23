#!/bin/bash

for ((index=0; index<$(cat /opt/openvpn/users | jq '.users | length'); index++)); do
    client=$(cat /opt/openvpn/users | jq .users[$index].name | sed -r 's/"//g')
    status=$(cat /opt/openvpn/users | jq .users[$index].status | sed -r 's/"//g')

    if [ "$status" == "active" ]; then
        echo "---------------------"
        echo "Creating $client vpn..."
        echo "---------------------"
        sudo MENU_OPTION=1 CLIENT=$client PASS=1 /opt/openvpn/openvpn-install.sh
        sudo mv /root/$client.ovpn /opt/openvpn/clients/$client.ovpn
        sudo chown ubuntu:ubuntu /opt/openvpn/clients/$client.ovpn
    elif [ "$status" == "revoked" ]; then
        clientnumber=$(cat /etc/openvpn/easy-rsa/pki/index.txt | grep "^V" | grep -v "server_" | nl | grep "test3" | awk '{print $1}')
        echo "---------------------"
        echo "Revoking $client vpn..."
        echo "---------------------"
        sudo MENU_OPTION=2 CLIENTNUMBER=$clientnumber /opt/openvpn/openvpn-install.sh
        
        if [ -f /opt/openvpn/clients/$client.ovpn ]; then
            rm -f /opt/openvpn/clients/$client.ovpn
        fi
    else
        # to more actions
    fi
done