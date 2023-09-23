# [DEMO] Installing OpenVPN Server on AWS using terraform

- [Infrastructure Diagram](docs/infrastructure-digagram.pdf)

## Introduction

This github project is created to demostrate how to install a openvpn server on ec2 using terraform as provisioning tool.

AWS has a lot of services to do that, but in my case, I've choose do it with a simple ec2 instance, because is a first approach to show how simple is that.

**NOTE:** In a business environment it should be necessary analyze in deep to build it with the best architecture. It depends if the company has a lot time, money, or human resources to get successfull to do it.

With my knowledge about AWS:

- **If you don't have enough time:** I would choose using AWS VPN Service (SAS).
- **If you have enough time and not money:** It better using AWS ECS with custom docker containers
- **If you don't have enough money but time:** Using three EC2 with auto-scalling groups and ELB in front

## Project scaffolding

//TODO

- config folder
- 

## Requirements

To run this project without problems, you need to have installed in your personal computer (linux or macOs) the following tools, or if you're using windows, you must to install on WSL.

- git (to clone this project)
- awscli (tool to interact with AWS API's)
- make (to use automation tool)
- terraform (to deploy infrastructure to AWS)
- python3 (to use automation tool)

**Also**, you must to configure your *AWS credentials* and the environment vars.

## How to launch my OpenVPN server using this repository

**MAKE SURE you have everything correctly install before continue or you could to have errors deploying to AWS**

### First Step

Clone this repo on your home folder

```bash
# go to home folder
cd $HOME
# clone the repository
git clone https://github.com/jlopezcrd/openvpn-terraform-demo.git
# enter to cloned folder
cd openvpn-terraform-demo
```

You should choose what tool to automate the deploy you want, or in the other hand, running the commands step by step manually.

- I want to use `make` because is standard linux tool
  - Follow the instructions with the [make] prefix
- I want to use `python` because I have developer background
  - Follow the instructions with the [python] prefix
- I want to use `bash` because I'm a system administrator
  - Follow the instructions with the [bash] prefix
- I want to run the commands by my hands
  - Follow the instructions with the [manual] prefix

### Second Step

Once you've cloned the repository, and you're located in the folder, you have to initialize the terraform providers.

[make]
```bash
cd src
make init service=account-services
make init service=openvpn-service
```

[python]
```bash
cd src
python3 scripts/init.py account-services
python3 scripts/init.py openvpn-service
```

[bash]
```bash
cd src
service=account-services bash scripts/init.sh
service=openvpn-service bash scripts/init.sh
```

[manual]
```bash
cd src
cd account-services
terraform init
cd ..
cd openvpn-service
terraform init
```

### Third Step

Showing what infrastructure will be deployed with `terraform plan`

**REMINDER:** The plan for openvpn-service doesn't work until you have created the basic account resources. If you want to review the reason, go back to [#project-scaffolding](#project-scaffolding)

[make]
```bash
cd src
make plan service=account-services
make plan service=openvpn-service
```

[python]
```bash
cd src
python3 scripts/plan.py account-services
python3 scripts/plan.py openvpn-service
```

[bash]
```bash
cd src
service=account-services bash scripts/plan.sh
service=openvpn-service bash scripts/plan.sh
```

[manual]
```bash
cd src
cd account-services
terraform plan
cd ..
cd openvpn-service
terraform plan
```

## Four Step

In this step, you can choose to apply the changes for each infrastructure or using automatic tool.

[make]
```bash
cd src
# If you want to do it automatically
make applyAll
# If you want to have the control
make apply service=account-services
make apply service=openvpn-service
```

[python]
```bash
cd src
# If you want to do it automatically
python3 scripts/applyAll.py
# If you want to have the control
python3 scripts/apply.py account-services
python3 scripts/apply.py openvpn-service
```

[bash]
```bash
cd src
# If you want to do it automatically
bash scripts/applyAll.sh
# If you want to have the control
service=account-services bash scripts/apply.sh
service=openvpn-service bash scripts/apply.sh
```

[manual]
```bash
cd src
# With terraform commands you need to do step by step
cd account-services
terraform apply
cd ..
cd openvpn-service
terraform apply
```


aws ecr get-login-password --region eu-south-2 | docker login --username AWS --password-stdin XXXXXXXXXXXX.dkr.ecr.eu-south-2.amazonaws.com

docker build -t kaira-ecr .

docker tag kaira-ecr:latest XXXXXXXXXXXX.dkr.ecr.eu-south-2.amazonaws.com/kaira-ecr:latest

docker push XXXXXXXXXXXX.dkr.ecr.eu-south-2.amazonaws.com/kaira-ecr:latest