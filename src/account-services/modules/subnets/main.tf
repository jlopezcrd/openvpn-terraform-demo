variable "kaira_default_region" {}
variable "kaira_vpc_ip_block" {}
variable "kaira_vpc_id" {}

resource "aws_subnet" "kaira_subnet_public_a" {
  tags = {
    Name = "kaira-subnet-public-a"
  }

  vpc_id                                      = var.kaira_vpc_id
  cidr_block                                  = cidrsubnet(var.kaira_vpc_ip_block, 4, 2)
  availability_zone                           = "${var.kaira_default_region}a"
  map_public_ip_on_launch                     = true
  enable_resource_name_dns_a_record_on_launch = true
}

resource "aws_subnet" "kaira_subnet_public_b" {
  tags = {
    Name = "kaira-subnet-public-b"
  }

  vpc_id                                      = var.kaira_vpc_id
  cidr_block                                  = cidrsubnet(var.kaira_vpc_ip_block, 4, 4)
  availability_zone                           = "${var.kaira_default_region}b"
  map_public_ip_on_launch                     = true
  enable_resource_name_dns_a_record_on_launch = true
}

resource "aws_subnet" "kaira_subnet_public_c" {
  tags = {
    Name = "kaira-subnet-public-c"
  }

  vpc_id                                      = var.kaira_vpc_id
  cidr_block                                  = cidrsubnet(var.kaira_vpc_ip_block, 4, 8)
  availability_zone                           = "${var.kaira_default_region}c"
  map_public_ip_on_launch                     = true
  enable_resource_name_dns_a_record_on_launch = true
}

# TODO PRIVATE SUBNETS