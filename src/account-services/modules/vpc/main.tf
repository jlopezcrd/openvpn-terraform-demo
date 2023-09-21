variable "kaira_vpc_ip_block" {}
variable "kaira_office_ip" {}
variable "kaira_public_rsa_key" {}

resource "aws_vpc_dhcp_options" "kaira_vpc_dhcp_options" {
    tags = {
        Name = "kaira-vpc-dhcp-options"
    }

    domain_name         = "kaira"
    domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc" "kaira_vpc" {    
    tags = {
        Name = "kaira-vpc"
    }

    cidr_block           = var.kaira_vpc_ip_block
    enable_dns_hostnames = true
    enable_dns_support   = true
}

resource "aws_vpc_dhcp_options_association" "kaira_vpc_dhcp_options" {
    vpc_id          = aws_vpc.kaira_vpc.id
    dhcp_options_id = aws_vpc_dhcp_options.kaira_vpc_dhcp_options.id
}

resource "aws_internet_gateway" "kaira_igw_main" {
  vpc_id   = aws_vpc.kaira_vpc.id

  tags = {
    Name = "kaira-igw-main",
  }
}

resource "aws_subnet" "kaira_subnet_public_a" {
    vpc_id                                      = aws_vpc.kaira_vpc.id
    cidr_block                                  = cidrsubnet(var.kaira_vpc_ip_block, 4, 2)
    availability_zone                           = "eu-south-2a"
    map_public_ip_on_launch                     = true
    enable_resource_name_dns_a_record_on_launch = true

    tags = {
        Name = "kaira-subnet-public-a"
    }
}

resource "aws_subnet" "kaira_subnet_public_b" {
    vpc_id                                      = aws_vpc.kaira_vpc.id
    cidr_block                                  = cidrsubnet(var.kaira_vpc_ip_block, 4, 4)
    availability_zone                           = "eu-south-2b"
    map_public_ip_on_launch                     = true
    enable_resource_name_dns_a_record_on_launch = true

    tags = {
        Name = "kaira-subnet-public-b"
    }
}

resource "aws_subnet" "kaira_subnet_public_c" {
    vpc_id                                      = aws_vpc.kaira_vpc.id
    cidr_block                                  = cidrsubnet(var.kaira_vpc_ip_block, 4, 8)
    availability_zone                           = "eu-south-2c"
    map_public_ip_on_launch                     = true
    enable_resource_name_dns_a_record_on_launch = true

    tags = {
        Name = "kaira-subnet-public-c"
    }
}

# TODO PRIVATE SUBNETS
