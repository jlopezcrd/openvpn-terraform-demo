#!/bin/python

import os

basePath = os.getcwd()

def destroyAll():
    for service in ["/account-services", "/openvpn-service"]:
        directory = basePath + service
        os.system(f"terraform -chdir={directory} destroy --auto-approve")        

    if os.path.isdir(".clients"):
        #os.rmdir(".clients")
        # can be with shutil.rmtree("path_to_dir") but for avoid to another import
        os.system("rm -rf .clients")
    
    if os.path.isfile("openvpn.config.txt"):
        os.remove("openvpn.config.txt")

if __name__ == "__main__":
   destroyAll()