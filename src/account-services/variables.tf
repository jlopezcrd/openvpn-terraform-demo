variable "kaira_vpc_ip_block" {
  description = "VPC IP BLOCK"
  type        = string
  default     = "10.100.0.0/16"
  sensitive   = false
}

variable "kaira_default_role" {
  type = string
  default = "kaira-dev-sso"
}

variable "kaira_default_region" {
  type = string
  default = "eu-south-2"
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