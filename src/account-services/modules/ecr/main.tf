resource "aws_ecr_repository" "kaira_ecr" {
  tags = {
    Name = "kaira-ecr",
  }

  name = "kaira-ecr"
}