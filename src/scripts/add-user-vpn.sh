#!/bin/bash

CLIENT=$1
OVPN_DATA="./openvpn-ecs-service/.generated"

if [ ! -d $OVPN_DATA/clients ]; then
    sudo mkdir $OVPN_DATA/clients
fi

echo "---------------------"
echo "Creating $CLIENT vpn..."
echo "---------------------"

sudo docker run -v $OVPN_DATA:/etc/openvpn \
    --rm -it kylemanna/openvpn easyrsa build-client-full $CLIENT nopass

sudo docker run -v $OVPN_DATA:/etc/openvpn \
    --rm kylemanna/openvpn ovpn_getclient $CLIENT > /tmp/$CLIENT.ovpn

sudo mv /tmp/$CLIENT.ovpn $OVPN_DATA/clients/$CLIENT.ovpn
sudo chown -R $USER:$USER $OVPN_DATA