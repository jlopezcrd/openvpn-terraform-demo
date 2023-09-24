# [DEMO] Installing OpenVPN Server on AWS using terraform

- [Infrastructure Diagram](docs/openvpn-infrastructure-diagram.pdf)

## Introduction

This github project is created to demostrate how to install a openvpn server on ec2 using terraform as provisioning tool.

AWS has a lot of services to do that, but in my case, I've choose do it with ECS cluster with three instances as workers. It is IMPORTANT remark that if you're thinking to use FARGATE, it's not possible, because AWS doesn't support NET_ADMIN capabiliy for use OPEN VPN in a container.

Then only you can choose beteween ECS-EC2 CLUSTER, EC2 INSTANCES managing the ec2 instances yourself or using VPN SERVICE (SAS)

**NOTE:** In a business environment it should be necessary analyze in deep to build it with the best architecture. It depends if the company has a lot time, money, or human resources to get successfull to do it.

Another point to explain, is the HEALTH-CHECKS from NLB or ECS CLUSTER doesn't support UDP protocol, for this reason, I've created a SIDECAR CONTAINER to provision a NGINX service as essential running in the same ECS TASK to have a reachable TCP PORT.

Launching two containers as ESSENTIAL, tell to ECS service that one of them is killed or down, it must destroy the TASK.

There is a TERRAFORM BUG when you're trying to destroy INFRASTRUCTURE. Terraform attempts to destroy the ECS SERVICE before the AUTOSCALING GROUP. **REMEMBER:** When you're running the destroy command with the script kaira-destroy.sh, YOU MUST TO DESTROY the autoscaling group manually to help to terraform continue and left waiting.

You can see here:
- [STACK OVERFLOW](https://stackoverflow.com/questions/68117174/during-terraform-destroy-terraform-is-trying-to-destroy-the-ecs-cluster-before)
- [GITHUB](https://github.com/hashicorp/terraform-provider-aws/issues/4852)

## Project scaffolding

This repository has a singular structure to add the possibility to extend services to the same account

- ROOT
  - docs (documentation or references)
  - src (code)
    - account-services (terraform basic account resources)
    - openvpn-ecs-service (terraform openvpn resources)
    - scripts (bash automations scripts)
  - .editorconfig (file to configure code editors with rules defined)
  - .gitignore (file to tell to GIT what files it must ignored)
  - LICENSE (license of this project)
  - README.md (principal documentation)

If you would want add another services, it's simple, create another folder into src, because you don't need to recreate basic resources.

## Requirements

To run this project without problems, you need to have installed in your personal computer (linux or macOs) the following tools, or if you're using windows, you must to install on WSL.

- AWS ACCOUNT WITH SPAIN REGION (eu-south-2)
- AWS ADMIN CREDENTIALS (aws access key and aws secret key)
- git (to clone this project)
- awscli (tool to interact with AWS API's)
- terraform (to deploy infrastructure to AWS)
- python3 (to use automation tool)
- docker (to build openvpn image)

**Also**, you must to configure your *AWS credentials* with *ADMIN permissions*.

I understand that using `aws key and aws secret key` with *admin permissions* is causing a security risk, but, REMEMBER... this is a demo!!

> If you're going to use in business production mode, you should use a `session crentials` or `aws organizations` or `sso login`

## How to launch my OpenVPN server using this repository

**MAKE SURE you have everything correctly install before continue or you could to have errors deploying to AWS**

```bash
# Create new profile to connect with AWS API
developez@vm-linux:~/test-openvpn/src$ aws configure --profile kaira-dev-sso
AWS Access Key ID [None]: AKIXXXXXXXXXX
AWS Secret Access Key [None]: XXXXXXXXXXXXXXXXXXXXXXXXXXX
Default region name [None]: eu-south-2
Default output format [None]: json

developez@vm-linux:~$ tree .aws/
.aws/
├── config
└── credentials

0 directories, 2 files

# TEST AWS config
developez@vm-linux:~$ cat .aws/config 
[default]
region = eu-south-2
output = json

# TEST AWS credentials
developez@vm-linux:~$ cat .aws/credentials 
[default]
aws_access_key_id = AKIXXXXXXXXXX
aws_secret_access_key = XXXXXXXXXXXXXXXXXXXXXXXXXXX

# TEST git
> git --version
git version x.xx.x

# TEST awscli
> aws --version
aws-cli/x.xx.xx Python/x.xx.x Linux/x.xx.x-xx-generic exe/x86_64

# TEST make
> make --version
GNU Make x.x
Built for x86_64-pc-linux-gnu
Copyright (C) 1988-2020 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

# TEST terraform
> terraform --version
terraform --version

# TEST python3
> python3 --version
python3 --version
```

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

### Second Step

Once you've cloned the repository, and you're located in the cloned folder, you have to run the automated bash script tool.

```bash
cd src
bash scripts/kaira.sh
```

### Third Step

If all was well, you should see an output like this:

```bash
Apply complete! Resources: 15 added, 0 changed, 0 destroyed.

Outputs:

output_kaira_openvpn_external_nlb = {
  "dns_name" = "kaira-openvpn-external-nlb-xxxxxxxxxxxx.elb.eu-south-2.amazonaws.com"
}
```

### Fourth Step

Check the openvpn credentials generated before. You should see the same DNS NAME

```bash
developez@vm-linux:~/kairadigital.com/src$ head openvpn-ecs-service/.generated/clients/developez.ovpn 

client
nobind
dev tun
remote-cert-tls server

remote kaira-openvpn-external-nlb-xxxxxxxxxxxx.elb.eu-south-2.amazonaws.com 1194 udp

<key>
-----BEGIN PRIVATE KEY-----

developez@vm-linux:~/kairadigital.com/src$ head openvpn-ecs-service/.generated/clients/julio.ovpn 

client
nobind
dev tun
remote-cert-tls server

remote kaira-openvpn-external-nlb-xxxxxxxxxxxx.elb.eu-south-2.amazonaws.com 1194 udp

<key>
-----BEGIN PRIVATE KEY-----

developez@vm-linux:~/kairadigital.com/src$ head openvpn-ecs-service/.generated/clients/mario.ovpn 

client
nobind
dev tun
remote-cert-tls server

remote kaira-openvpn-external-nlb-xxxxxxxxxxxx.elb.eu-south-2.amazonaws.com 1194 udp

<key>
-----BEGIN PRIVATE KEY-----
```

### Fifth Step Step

Connect to the OPEN VPN using the NETWORK LOAD BALANCER. You must to be located in src folder.

If you can see: `Initialization Sequence Completed` in other terminal you have to do a ping to the targets ips to check the connection.

Alternatively you can add to a OPEN VPN GUI CLIENT as the image bellow:

![OpenVPN GUI CLIENTE 1](docs/gui-openvpn-1.png "openvpn gui client 1")
![OpenVPN GUI CLIENTE 2](docs/gui-openvpn-2.png "openvpn gui client 2")
![OpenVPN GUI CLIENTE 3](docs/gui-openvpn-3.png "openvpn gui client 3")

```bash
developez@vm-linux:~/test-openvpn/src$ sudo openvpn --config openvpn-ecs-service/.generated/clients/{developez,julio or mario}.ovpn

2023-09-24 21:26:09 --cipher is not set. Previous OpenVPN version defaulted to BF-CBC as fallback when cipher negotiation failed in this case. If you need this fallback please add '--data-ciphers-fallback BF-CBC' to your configuration and/or add BF-CBC to --data-ciphers.
2023-09-24 21:26:09 OpenVPN 2.5.5 x86_64-pc-linux-gnu [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [PKCS11] [MH/PKTINFO] [AEAD] built on Jul 14 2022
2023-09-24 21:26:09 library versions: OpenSSL 3.0.2 15 Mar 2022, LZO 2.10
2023-09-24 21:26:09 TCP/UDP: Preserving recently used remote address: [AF_INET]18.100.197.223:1194
2023-09-24 21:26:09 UDP link local: (not bound)
2023-09-24 21:26:09 UDP link remote: [AF_INET]18.100.197.223:1194
2023-09-24 21:26:09 WARNING: 'link-mtu' is used inconsistently, local='link-mtu 1541', remote='link-mtu 1542'
2023-09-24 21:26:09 WARNING: 'comp-lzo' is present in remote config but missing in local config, remote='comp-lzo'
2023-09-24 21:26:09 [vpn-test-ecs.kairadigital.com] Peer Connection Initiated with [AF_INET]18.100.197.223:1194
2023-09-24 21:26:10 Options error: Unrecognized option or missing or extra parameter(s) in [PUSH-OPTIONS]:1: block-outside-dns (2.5.5)
2023-09-24 21:26:10 TUN/TAP device tun0 opened
2023-09-24 21:26:10 net_iface_mtu_set: mtu 1500 for tun0
2023-09-24 21:26:10 net_iface_up: set tun0 up
2023-09-24 21:26:10 net_addr_ptp_v4_add: 192.168.255.6 peer 192.168.255.5 dev tun0
2023-09-24 21:26:10 WARNING: this configuration may cache passwords in memory -- use the auth-nocache option to prevent this
2023-09-24 21:26:10 Initialization Sequence Completed
```

**If you're reading this line, everything went well, and you have an OpenVPN server configured by terraform.**

## Final thoughts

This project was a bit complex, because I don't usually use container for VPNS. In fact, the incompatibility with FARGATE slowed me down a bit, because it was very difficult to find the issue. [REF to AWS DOCS](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_KernelCapabilities.html)

Also comment, the first deployment was a simple EC2 node with OPENVPN service installed on it, but I thought, it's very simple, I'm going to use containers.

As summary, I learned that all SERVERLESS services in the cloud doesn't support all features that you can deploy in managed services / nodes.