# TF_VAR_KAIRA_PUBLIC_RSA_PATH=/home/developez/.ssh/id_rsa.pub terraform fmt
# TF_VAR_KAIRA_PUBLIC_RSA_PATH=/home/developez/.ssh/id_rsa.pub terraform plan
# TF_VAR_KAIRA_PUBLIC_RSA_PATH=/home/developez/.ssh/id_rsa.pub terraform apply --auto-approve
# TF_VAR_KAIRA_PRIVATE_RSA_PATH=/home/developez/.ssh/id_rsa TF_VAR_KAIRA_PUBLIC_RSA_PATH=/home/developez/.ssh/id_rsa.pub terraform apply --auto-approve

#ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/id_rsa ubuntu@18.100.216.248

SHELL := /bin/bash

help:
	@echo "Usage: make <subcommand>"
	@echo ""
	@echo "The available commands for execution are listed below."
	@echo ""
	@echo "Commands:"
	@echo "    help                                  Show the command usage"
	@echo "    configure                             Set the environment vars for terraform in your bashrc profile"
	@echo "    init service=<your-service>           Prepare your working directory for other commands"
	@echo "    format service=<your-service>         Reformat your configuration in the standard style"
	@echo "    validate service=<your-service>       Check whether the configuration is valid"
	@echo "    plan service=<your-service>           Show changes required by the current configuration"
	@echo "    apply service=<your-service>          Create or update infrastructure"
	@echo "    destroy service=<your-service>        Destroy previously-created infrastructure"
	@echo "    clean                                 Unset the environment vars for terraform in your bashrc profile"
	@echo ""
	@exit 0

configure:
	@echo 'export TF_VAR_KAIRA_PRIVATE_RSA_PATH="~/.ssh/id_rsa"' >> ~/.bashrc
	@echo 'export TF_VAR_KAIRA_PUBLIC_RSA_PATH="~/.ssh/id_rsa.pub"' >> ~/.bashrc
	@export TF_VAR_KAIRA_PRIVATE_RSA_PATH="~/.ssh/id_rsa"
	@export TF_VAR_KAIRA_PUBLIC_RSA_PATH="~/.ssh/id_rsa.pub"

init:
	@if [ "${service}" = "" ]; then echo "Error, you have to set the service"; exit 1; else terraform -chdir=${service} init; fi

format:
	@if [ "${service}" = "" ]; then echo "Error, you have to set the service"; exit 1; else terraform -chdir=${service} fmt; fi

validate:
	@if [ "${service}" = "" ]; then echo "Error, you have to set the service"; exit 1; else terraform -chdir=${service} validate; fi

plan:
	@if [ "${service}" = "" ]; then echo "Error, you have to set the service"; exit 1; else terraform -chdir=${service} plan; fi

apply:
	@if [ "${service}" = "" ]; then echo "Error, you have to set the service"; exit 1; else terraform -chdir=${service} apply --auto-approve; fi

destroy:
	@if [ "${service}" = "" ]; then echo "Error, you have to set the service"; exit 1; else terraform -chdir=${service} destroy --auto-approve; fi

clean:
	@sed -i '/TF_VAR_KAIRA_PRIVATE_RSA_PATH/d' ~/.bashrc
	@sed -i '/TF_VAR_KAIRA_PUBLIC_RSA_PATH/d' ~/.bashrc
	@export TF_VAR_KAIRA_PRIVATE_RSA_PATH=
	@lexport TF_VAR_KAIRA_PUBLIC_RSA_PATH=