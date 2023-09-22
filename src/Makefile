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
	@chmod +x ./scripts/init.sh
	@bash ./scripts/init.sh

format:
	@chmod +x ./scripts/format.sh
	@bash ./scripts/format.sh

validate:
	@chmod +x ./scripts/validate.sh
	@bash ./scripts/validate.sh

plan:
	@chmod +x ./scripts/plan.sh
	@bash ./scripts/plan.sh

apply:
	@chmod +x ./scripts/apply.sh
	@bash ./scripts/apply.sh

applyAll:
	@chmod +x ./scripts/applyAll.sh
	@bash ./scripts/applyAll.sh

destroy:
	@chmod +x ./scripts/destroy.sh
	@bash ./scripts/destroy.sh

clean:
	@sed -i '/TF_VAR_KAIRA_PRIVATE_RSA_PATH/d' ~/.bashrc
	@sed -i '/TF_VAR_KAIRA_PUBLIC_RSA_PATH/d' ~/.bashrc
	@export TF_VAR_KAIRA_PRIVATE_RSA_PATH=
	@export TF_VAR_KAIRA_PUBLIC_RSA_PATH=