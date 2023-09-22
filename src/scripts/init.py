#!/bin/python

import os
import sys

basePath = os.getcwd()

def init():
    if len(sys.argv) == 1:
        print("Error, you have to set the service")
        exit(1)
    else:
        directory = basePath + "/" + sys.argv[1]
        os.system(f"terraform -chdir={directory} init")

if __name__ == "__main__":
   init()