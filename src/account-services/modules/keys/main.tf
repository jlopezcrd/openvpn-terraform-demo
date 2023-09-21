variable "kaira_public_key_name" {}
variable "kaira_public_rsa_key" {}

resource "aws_key_pair" "kaira_rsa_key" {
    tags = {
        Name = var.kaira_public_key_name
    }

    key_name   = var.kaira_public_key_name
    public_key = var.kaira_public_rsa_key
}