variable "kaira_vpc_ip_block" {}

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