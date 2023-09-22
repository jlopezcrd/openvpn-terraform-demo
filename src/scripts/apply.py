#!/bin/python

import os
import sys

basePath = os.getcwd()

def apply():
    if len(sys.argv) == 1:
        print("Error, you have to set the service")
        exit(1)
    else:
        directory = basePath + "/" + sys.argv[1]
        os.system(f"terraform -chdir={directory} apply --auto-approve")

        if sys.argv[1].startswith("openvpn-service"):
            os.system(f"terraform -chdir=openvpn-service output -json > ../openvpn.config.txt")

if __name__ == "__main__":
   apply()