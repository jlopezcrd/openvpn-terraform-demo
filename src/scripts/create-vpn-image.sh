#!/bin/bash


users=${1:-"developez julio mario"}
endpoint="vpn-test-ecs.kairadigital.com"
folder=openvpn-ecs-service
accountId=$(aws sts get-caller-identity --profile kaira-dev-sso --output text | cut -d$'\t' -f 1)
region=$(aws configure get region --profile kaira-dev-sso)
output=".generated"
clients="${output}/clients"

if [ "${accountId}" == "" ] || [ "${region}" == "" ]; then
    echo ""
    echo "================================"
    echo "     ERROR AWS CONFIGURATION    "
    echo "================================"
    echo ""
    exit 1
fi

if [ ! -d ${folder} ]; then
    echo ""
    echo "================================"
    echo "     ERROR FOLDER NOT FOUND     "
    echo "================================"
    echo ""
    exit 1
fi

cd ${folder}
mkdir -p ${clients}

if [ -f "${output}/openvpn.conf" ]; then
    echo ""
    echo "================================"
    echo "VPN config already exists."
    echo "================================"
    echo ""
else
    sudo docker run -v $(pwd)/${output}:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u udp://${endpoint}
    sudo docker run -v $(pwd)/${output}:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki
fi

for user in $users; do
    echo ""
    echo "================================"
    echo " Generating vpn user ${user}... "
    echo "================================"
    echo ""

    if [ -f "${output}/pki/reqs/${user}.req" ]; then
        echo ""
        echo "================================"
        echo "VPN user ${user} already exists."
        echo "================================"
        echo ""
        continue
    fi

    sudo docker run -v $(pwd)/${output}:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full ${user} nopass
    sudo docker run -v $(pwd)/${output}:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient ${user} > "${clients}/${user}.ovpn"
done

sudo docker build -t ${accountId}.dkr.ecr.${region}.amazonaws.com/kaira-openvpn:latest .

sudo chown -R $USER: ${output}