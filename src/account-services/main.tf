terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.kaira_default_region
  profile = var.kaira_default_role
  default_tags {
    tags = var.kaira_default_tags
  }
}

module "kaira_vpc_module" {
  source             = "./modules/vpc"
  kaira_vpc_ip_block = var.kaira_vpc_ip_block
}

module "kaira_igw_module" {
  source       = "./modules/igw"
  kaira_vpc_id = module.kaira_vpc_module.output_kaira_vpc_id
}

module "kaira_subnets_module" {
  source               = "./modules/subnets"
  kaira_default_region = var.kaira_default_region
  kaira_vpc_ip_block   = var.kaira_vpc_ip_block
  kaira_vpc_id         = module.kaira_vpc_module.output_kaira_vpc_id
}

module "kaira_rtables_module" {
  source                  = "./modules/rtables"
  kaira_vpc_id            = module.kaira_vpc_module.output_kaira_vpc_id
  kaira_igw_main_id       = module.kaira_igw_module.output_kaira_igw_main_id
  kaira_subnet_public_ids = module.kaira_subnets_module.output_kaira_subnet_public_ids
}

module "kaira_sgroups_module" {
  source          = "./modules/sgroups"
  kaira_vpc_id    = module.kaira_vpc_module.output_kaira_vpc_id
  kaira_office_ip = local.office_ip_address
}

module "kaira_ecr_module" {
  source = "./modules/ecr"
}