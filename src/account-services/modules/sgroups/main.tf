variable "kaira_office_ip" {}

resource "aws_default_security_group" "default" {
  tags = {
    Name = "DON'T USE!!!!"
  }

  vpc_id   = aws_vpc.kaira_vpc.id
}

resource "aws_security_group" "kaira_security_group_default" {
  tags = {
    Name = "kaira-sg-default"
  }

  name        = "kaira-sg-default"
  description = "Default security group from office"
  vpc_id      = aws_vpc.kaira_vpc.id

  ingress {
    description = "PINGv4 from Office IP"
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = [
        "${var.kaira_office_ip}",
    ]
  }

  egress {
    description      = "Access to internet"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}