output "output_kaira_general" {
  value = {
    ecr = {
        repository = module.kaira_ecr_module.output_kaira_ecr_repository_url
        arn = module.kaira_ecr_module.output_kaira_ecr_arn
    }
  }
}