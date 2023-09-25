#!/bin/bash

outputFolder="../"
awsConfigFolder="~/.aws"
scriptsFolder="./scripts"
accountServices="account-services"
accountServicesFolder="./account-services"
openVpnService="openvpn-ecs-cluster"
openVpnClusterFolder="./openvpn-ecs-service"

if [ ! -d ~/.aws ] || [ ! -f ~/.aws/credentials ]; then
    echo ""
    echo "================================="
    echo "ERROR AWS CONFIG FOLDER NOT FOUND"
    echo "================================="
    echo ""
    echo "You have to run aws configure to set your aws key and aws secret"
    echo ""
    exit 1
fi

grep -i "aws_access_key_id = AKI" ~/.aws/credentials >> /dev/null

if [ $? -ne 0 ]; then
    echo ""
    echo "================================="
    echo "ERROR AWS CONFIG FOLDER NOT FOUND"
    echo "================================="
    echo ""
    echo "You have to run aws configure to set your aws key and aws secret"
    echo ""
    exit 1
fi

grep -i "kaira-dev-sso" ~/.aws/credentials >> /dev/null

if [ $? -ne 0 ]; then
    echo ""
    echo "========================================="
    echo "ERROR AWS PROFILE kaira-dev-sso NOT FOUND"
    echo "========================================="
    echo ""
    echo "You have to run aws configure to set your aws key and aws secret"
    echo ""
    exit 1
fi

if [ ! -d ${scriptsFolder} ]; then
    echo ""
    echo "================================"
    echo "      ERROR RUNNING SCRIPT      "
    echo "================================"
    echo ""
    echo "You have to run this script from src folder as base path"
    echo ""
    exit 1
fi

if [ $(aws configure get region --profile kaira-dev-sso) != "eu-south-2" ]; then
    echo ""
    echo "================================"
    echo "     ERROR AWS CONFIGURATION    "
    echo "================================"
    echo ""
    echo "You have to configure aws credentials with ADMIN ACCESS"
    echo "and set default region to eu-south-2"
    echo ""
    exit 1
fi

echo ""
echo "================================"
echo " INITIALIZING TERRAFORM MODULES "
echo "================================"
echo ""

terraform -chdir=${accountServicesFolder} init
terraform -chdir=${openVpnClusterFolder} init


echo ""
echo "================================"
echo "     CREATING DOCKER IMAGE      "
echo "================================"
echo ""

chmod +x ${scriptsFolder}/create-vpn-image.sh
bash ${scriptsFolder}/create-vpn-image.sh

echo ""
echo "================================"
echo "  DEPLOYING ACCOUNT SERVICES    "
echo "================================"
echo ""

terraform -chdir=${accountServicesFolder} apply --auto-approve
terraform -chdir=${accountServicesFolder} output -json > ${outputFolder}/${accountServices}.output.txt

echo ""
echo "================================"
echo "   DEPLOYING OPENVPN CLUSTER    "
echo "================================"
echo ""

if [ ! -f "${outputFolder}/${accountServices}.output.txt" ]; then
    echo ""
    echo "==================================="
    echo "ERROR ACCOUNT SERVICES IS NOT READY"
    echo "==================================="
    echo ""
    exit 1
fi

terraform -chdir=${openVpnClusterFolder} apply --auto-approve
terraform -chdir=${openVpnClusterFolder} output -json > ${outputFolder}/${openVpnService}.output.txt