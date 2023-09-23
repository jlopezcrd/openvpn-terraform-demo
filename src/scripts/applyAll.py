#!/bin/python

import os
import sys
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


        if sys.argv[1].startswith("account-services"):
            subprocess.Popen(
                f"terraform -chdir={directory} output -json > ../account.output.txt",
                shell=True,
                stdout=subprocess.PIPE
            ).wait()

        if sys.argv[1].startswith("openvpn-service"):
            subprocess.Popen(
                f"terraform -chdir={directory} output -json > ../openvpn.config.txt",
                shell=True,
                stdout=subprocess.PIPE
            ).wait()

if __name__ == "__main__":
   applyAll()