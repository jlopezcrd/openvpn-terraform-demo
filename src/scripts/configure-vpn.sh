#!/bin/bash

OVPN_DATA="././openvpn-ecs-service/.generated"
OVPN_DNS=${1:-vpn-test-ecs.kairadigital.com}

if [ ! -d $OVPN_DATA/pki ]; then
    sudo docker run -v $OVPN_DATA:/etc/openvpn \
        --rm kylemanna/openvpn ovpn_genconfig \
        -u udp://$OVPN_DNS

    sudo docker run -v $OVPN_DATA:/etc/openvpn \
        --rm -it kylemanna/openvpn ovpn_initpki

    sudo chown -R $USER:$USER $OVPN_DATA
else
    echo "VPN CONFIGURED";
fi

#aws ecr get-login-password --region eu-south-2 | docker login --username AWS --password-stdin XXXXXXXXXXXX.dkr.ecr.eu-south-2.amazonaws.com

#docker build -t kaira-ecr .

#docker tag kaira-ecr:latest XXXXXXXXXXXX.dkr.ecr.eu-south-2.amazonaws.com/kaira-ecr:latest

#docker push XXXXXXXXXXXX.dkr.ecr.eu-south-2.amazonaws.com/kaira-ecr:latest