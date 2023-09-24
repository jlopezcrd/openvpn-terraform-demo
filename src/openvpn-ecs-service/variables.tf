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

data "aws_ami" "kaira_aws_ecs_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*-amazon-ecs-optimized"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["amazon"] //878116103691
}

data "aws_vpc" "kaira_aws_vpc" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_id]
  }
}

data "aws_subnet" "kaira_aws_subnet_a" {
  filter {
    name   = "tag:Name"
    values = [local.subnet_public_a]
  }
}

data "aws_subnet" "kaira_aws_subnet_b" {
  filter {
    name   = "tag:Name"
    values = [local.subnet_public_b]
  }
}

data "aws_subnet" "kaira_aws_subnet_c" {
  filter {
    name   = "tag:Name"
    values = [local.subnet_public_c]
  }
}

data "aws_iam_role" "kaira_aws_ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

data "aws_iam_policy_document" "kaira_aws_sts_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_ecr_image" "kaira_aws_openvpn_image" {
  repository_name = "kaira-openvpn"
  image_tag       = "latest"
}

data "aws_ecr_repository" "kaira_aws_openvpn_repo" {
  name = "kaira-openvpn"
}

variable "kaira_default_tags" {
  default = {
    Name        = "kaira-resource-untagged",
    Client      = "kaira",
    Backup      = false,
    Environment = "DEV",
    ManagedBy   = "terraform"
    OwnerBy     = "@developez"
  }
  sensitive = false
}

variable "kaira_openvpn_container_name" {
  type      = string
  default   = "openvpn"
  sensitive = false
}

variable "kaira_openvpn_container_port" {
  type      = number
  default   = 1194
  sensitive = false
}

variable "kaira_openvpn_container_protocol" {
  type      = string
  default   = "udp"
  sensitive = false
}

variable "kaira_openvpn_autoscaling_group_capacity" {
  type      = number
  default   = 3
  sensitive = false
}

variable "kaira_openvpn_autoscaling_group_min_size" {
  type      = number
  default   = 3
  sensitive = false
}

variable "kaira_openvpn_autoscaling_group_max_size" {
  type      = number
  default   = 3
  sensitive = false
}

variable "kaira_openvpn_service_capacity" {
  type      = number
  default   = 3
  sensitive = false
}