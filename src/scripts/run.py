#!/bin/python

import os
import sys
import subprocess

basePath = os.getcwd()

def doTerraform(service, subcommand):
    process = subprocess.Popen(
        f"terraform -chdir={service} {subcommand}",
        shell=True,
        stdout=subprocess.PIPE
    )
    
    for line in process.stdout:
        print(line.decode('UTF-8'))

    process.wait()

def run():
    if len(sys.argv) == 1:
        print("Error, you have to set the service")
        exit(1)
    else:
        if sys.argv[1].startswith("openvpn-service") and os.path.exists("./account.output.txt") == False:
            print("You must to run account-services first to prepare the basic account")
            exit(1)

        # doTerraform(
        #     basePath + sys.argv[1],
        #     "apply --auto-approve"
        # )

        if sys.argv[1].startswith("account-services"):
            print("Running account-services...")
            doTerraform(
                basePath + "/account-services",
                "apply --auto-approve"
            )
            doTerraform(
                basePath + "/account-services",
                "output -json > ./account.output.txt"
            )

        elif sys.argv[1].startswith("openvpn-ecs-service"):
            print("Running openvpn-ecs-service...")
            doTerraform(
                basePath + "/openvpn-ecs-service",
                "apply --auto-approve"
            )
            doTerraform(
                basePath + "/openvpn-ecs-service",
                "output -json > ./openvpn.ecs.config.txt"
            )

        elif sys.argv[1].startswith("openvpn-service"):
            print("Running openvpn-service...")
            doTerraform(
                basePath + "/openvpn-service",
                "apply --auto-approve"
            )
            doTerraform(
                basePath + "/openvpn-service",
                "output -json > ./openvpn.config.txt"
            )
        
        else:
            print("Service not found")
            exit(1)

if __name__ == "__main__":
   run()