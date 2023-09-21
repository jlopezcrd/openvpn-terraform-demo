variable "kaira_vpc_id" {}

resource "aws_internet_gateway" "kaira_igw_main" {
  tags = {
    Name = "kaira-igw-main",
  }

  vpc_id = var.kaira_vpc_id
}