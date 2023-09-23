#!/bin/python

import os
import subprocess

basePath = os.getcwd()

def destroyAll():
    for service in ["/openvpn-service", "/account-services"]:
        directory = basePath + service
        #os.system(f"terraform -chdir={directory} destroy --auto-approve")
        process = subprocess.Popen(
            f"terraform -chdir={directory} destroy --auto-approve",
            shell=True,
            stdout=subprocess.PIPE
        )
        
        for line in process.stdout:
            print(line.decode('UTF-8'))

        process.wait()

    if os.path.isdir(".clients"):
        #os.rmdir(".clients")
        # can be with shutil.rmtree("path_to_dir") but for avoid to another import
        os.system("rm -rf .clients")
    

    if os.path.isfile("../openvpn.config.txt"):
        os.remove("../openvpn.config.txt")

    if os.path.isfile("../account.output.txt"):
        os.remove("../account.output.txt")

if __name__ == "__main__":
   destroyAll()