resource "aws_ecr_repository" "kaira_openvpn" {
  tags = {
    Name = "kaira-openvpn",
  }

  name = "kaira-openvpn"
  force_delete = true
}