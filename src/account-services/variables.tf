variable "kaira_vpc_ip_block" {
  description = "VPC IP BLOCK"
  type        = string
  default     = "10.100.0.0/16"
  sensitive   = false
}

variable "KAIRA_PUBLIC_RSA_PATH" {
  description = "Absolute path to your rsa public key"
  type        = string
  sensitive   = false
}