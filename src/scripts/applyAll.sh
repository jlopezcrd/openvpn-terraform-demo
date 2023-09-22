#!/bin/bash

terraform -chdir=account-services apply --auto-approve
terraform -chdir=openvpn-service apply --auto-approve