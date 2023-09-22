#!/bin/python

import os
import sys

basePath = os.getcwd()

def applyAll():
    for service in ["/account-services", "/openvpn-service"]:
        directory = basePath + service
        os.system(f"terraform -chdir={directory} apply --auto-approve")        

if __name__ == "__main__":
   applyAll()