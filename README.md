# [DEMO] Installing OpenVPN Server on AWS using terraform

- [Infrastructure Diagram](docs/infrastructure-digagram.drawio.pdf)

## Introduction

This github project is created to demostrate how to install a openvpn server on ec2 using terraform as provisioning tool.

AWS has a lot of services to do that, but in my case, I've choose do it with a simple ec2 instance, because is a first approach to show how simple is that.

**NOTE:** In a business environment it should be necessary analyze in deep to build it with the best architecture. It depends if the company has a lot time, money, or human resources to get successfull to do it.

With my knowledge about AWS:

- **If you don't have enough time:** I would choose using AWS VPN Service (SAS).
- **If you have enough time and not money:** It better using AWS ECS with custom docker containers
- **If you don't have enough money but time:** Using three EC2 with auto-scalling groups and ELB in front

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
cd $HOME
git clone https://github.com/jlopezcrd/openvpn-terraform-demo.git
cd openvpn-terraform-demo
```

### Second Step

### Third Step

//TODO


aws ecr get-login-password --region eu-south-2 | docker login --username AWS --password-stdin XXXXXXXXXXXX.dkr.ecr.eu-south-2.amazonaws.com

docker build -t kaira-ecr .

docker tag kaira-ecr:latest XXXXXXXXXXXX.dkr.ecr.eu-south-2.amazonaws.com/kaira-ecr:latest

docker push XXXXXXXXXXXX.dkr.ecr.eu-south-2.amazonaws.com/kaira-ecr:latest