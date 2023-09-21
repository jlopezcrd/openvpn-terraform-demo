variable "kaira_vpc_ip_block" {
  description = "VPC IP BLOCK"
  type        = string
  default     = "10.100.0.0/16"
  sensitive   = false
}

variable "kaira_public_rsa_path" {
  description = "Absolute path to your rsa public key"
  type        = string
  sensitive   = false
}