variable "kaira_public_rsa_key" {}

resource "aws_key_pair" "kaira_rsa_key" {
    tags = {
        Name = "kaira-rsa-public-key"
    }

    key_name   = "kaira-rsa-public-key"
    public_key = var.kaira_public_rsa_key
}