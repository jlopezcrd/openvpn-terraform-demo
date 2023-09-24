output "output_kaira_ecr_arn" {
  value = aws_ecr_repository.kaira_openvpn.arn
}

output "output_kaira_ecr_repository_url" {
  value = aws_ecr_repository.kaira_openvpn.repository_url
}