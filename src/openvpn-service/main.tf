terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  alias   = "spain"
  region  = "eu-south-2"
  profile = "kaira-dev-sso"
  default_tags {
    tags = {
      Name        = "kaira-resource-untagged",
      Client      = "kaira",
      Backup      = false,
      Environment = "DEV",
      ManagedBy   = "terraform"
      OwnerBy     = "@developez"
    }
  }
}

resource "aws_instance" "kaira_openvpn_server" {
  tags = {
    Name = "kaira-openvpn-server"
  }

  ami                         = data.aws_ami.kaira_aws_ubuntu_ami.id
  associate_public_ip_address = true
  instance_type               = var.kaira_instance_type
  key_name                    = data.aws_key_pair.kaira_key_name.key_name
  subnet_id                   = data.aws_subnet.kaira_aws_subnet.id
  #var.kaira_subnet_id

  # vpc_security_group_ids = [
  #   aws_security_group.openvpn.id,
  #   aws_security_group.ssh_from_local.id,
  # ]

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.kaira_root_volume_size
    delete_on_termination = true
  }
}
