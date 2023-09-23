#!/bin/python

import os
import sys

basePath = os.getcwd()

def apply():
    if len(sys.argv) == 1:
        print("Error, you have to set the service")
        exit(1)
    else:
        if sys.argv[1].startswith("openvpn-service") and os.path.exists("../account.output.txt") == False:
            print("You must to run account-services first to prepare the basic account")
            exit(1)

        directory = basePath + "/" + sys.argv[1]
        os.system(f"terraform -chdir={directory} apply --auto-approve")

        if sys.argv[1].startswith("account-services"):
            os.system(f"terraform -chdir=account-services output -json > ../account.output.txt")

        if sys.argv[1].startswith("openvpn-service"):
            os.system(f"terraform -chdir=openvpn-service output -json > ../openvpn.config.txt")

if __name__ == "__main__":
   apply()