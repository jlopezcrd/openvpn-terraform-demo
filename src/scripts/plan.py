#!/bin/python

import os
import sys

basePath = os.getcwd()

def plan():
    if len(sys.argv) == 1:
        print("Error, you have to set the service")
        exit(1)
    else:
        if sys.argv[1].startswith("openvpn-service") and os.path.exists("../account.output.txt") == False:
            print("You must to run account-services first to prepare the basic account")
            exit(1)

        directory = basePath + "/" + sys.argv[1]
        os.system(f"terraform -chdir={directory} plan")

if __name__ == "__main__":
   plan()