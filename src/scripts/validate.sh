#!/bin/bash

if [ "${service}" = "" ]; then
    echo "Error, you have to set the service"
    exit 1
else
    terraform -chdir=${service} validate
fi