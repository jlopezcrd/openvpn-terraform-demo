#!/bin/python

import os
import sys

basePath = os.getcwd()

def plan():
    if len(sys.argv) == 1:
        print("Error, you have to set the service")
        exit(1)
    else:
        directory = basePath + "/" + sys.argv[1]
        os.system(f"terraform -chdir={directory} plan")

if __name__ == "__main__":
   plan()