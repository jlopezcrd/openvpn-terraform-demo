#!/bin/python

import os
import sys

basePath = os.getcwd()

def destroy():
    if len(sys.argv) == 1:
        print("Error, you have to set the service")
        exit(1)
    else:
        directory = basePath + "/" + sys.argv[1]
        os.system(f"terraform -chdir={directory} destroy --auto-approve")

        if os.path.isdir(".clients"):
            #os.rmdir(".clients")
            # can be with shutil.rmtree("path_to_dir") but for avoid to another import
            os.system("rm -rf .clients")
        
        if os.path.isfile("openvpn.config.txt"):
            os.remove("openvpn.config.txt")

if __name__ == "__main__":
   destroy()