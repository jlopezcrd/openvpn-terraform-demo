#!/bin/python

import os
import subprocess

basePath = os.getcwd()

def applyAll():
    for service in ["/account-services", "/openvpn-service"]:
        directory = basePath + service
        #os.system(f"terraform -chdir={directory} apply --auto-approve")
        process = subprocess.Popen(
            f"terraform -chdir={directory} apply --auto-approve",
            shell=True,
            stdout=subprocess.PIPE
        )
        
        for line in process.stdout:
            print(line.decode('UTF-8'))

        process.wait()
    
    os.system(f"terraform -chdir=openvpn-service output -json > ../openvpn.config.txt")

if __name__ == "__main__":
   applyAll()