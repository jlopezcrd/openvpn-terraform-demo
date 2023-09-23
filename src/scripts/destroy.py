#!/bin/python

import os
import sys

basePath = os.getcwd()

def destroy():
    if len(sys.argv) == 1:
        print("Error, you have to set the service")
        exit(1)
    else:
        if sys.argv[1].startswith("account-services") and os.path.exists("../openvpn.config.txt") == True:
            print("You must to destroy openvpn-server first")
            exit(1)

        directory = basePath + "/" + sys.argv[1]
        os.system(f"terraform -chdir={directory} destroy --auto-approve")

        if os.path.isdir(".clients"):
            #os.rmdir(".clients")
            # can be with shutil.rmtree("path_to_dir") but for avoid to another import
            os.system("rm -rf .clients")
        
        if os.path.isfile("../openvpn.config.txt"):
            os.remove("../openvpn.config.txt")

        if os.path.isfile("../account.output.txt"):
            os.remove("../account.output.txt")

if __name__ == "__main__":
   destroy()