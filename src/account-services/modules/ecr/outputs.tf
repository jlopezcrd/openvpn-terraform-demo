output "output_kaira_ecr_arn" {
  value = aws_ecr_repository.kaira_ecr.arn
}

output "output_kaira_ecr_repository_url" {
  value = aws_ecr_repository.kaira_ecr.repository_url
}