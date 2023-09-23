data "aws_ami" "kaira_aws_ubuntu_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["amazon"]
}

data "aws_vpc" "kaira_aws_vpc" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_id]
  }
}

data "aws_subnet" "kaira_aws_subnet" {
  filter {
    name   = "tag:Name"
    values = [local.subnet_public_b]
  }
}

data "aws_key_pair" "kaira_key_name" {
  filter {
    name   = "tag:Name"
    values = [local.public_key_name]
  }
}

variable "kaira_instance_type" {
  type      = string
  default   = "t3.micro"
  sensitive = false
}

variable "kaira_root_volume_size" {
  type      = string
  default   = "20"
  sensitive = false
}

variable "KAIRA_PUBLIC_RSA_PATH" {
  description = "Absolute path to your rsa public key"
  type        = string
  sensitive   = false
}

variable "KAIRA_PRIVATE_RSA_PATH" {
  description = "Absolute path to your rsa private key"
  type        = string
  sensitive   = false
}

variable "kaira_openvpn_users_list" {
  type      = string
  default   = "../../config/users"
  sensitive = false
}

variable "kaira_openvpn_script" {
  type      = string
  default   = <<EOF
#!/bin/bash
mkdir -p /opt/openvpn/clients
chown -R ubuntu:ubuntu /opt/openvpn
sudo apt update -y && sudo apt upgrade -y
sudo apt install git jq -y
sudo hostnamectl set-hostname $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 | tr '.' '-')
cd /opt/openvpn
curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
chmod +x openvpn-install.sh
sudo AUTO_INSTALL=y \
APPROVE_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4) \
ENDPOINT=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname) \
./openvpn-install.sh
touch /tmp/provisioned.lock
EOF
  sensitive = false
}
