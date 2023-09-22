#!/bin/python

import os
import sys

basePath = os.getcwd()

def format():
    if len(sys.argv) == 1:
        print("Error, you have to set the service")
        exit(1)
    else:
        directory = basePath + "/" + sys.argv[1]
        os.system(f"terraform -chdir={directory} fmt")

if __name__ == "__main__":
   format()