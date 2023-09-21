output "output_kaira_subnet_public_ids" {
  value = {
    a = aws_subnet.kaira_subnet_public_a.id
    b = aws_subnet.kaira_subnet_public_b.id
    c = aws_subnet.kaira_subnet_public_c.id
  }
}

output "output_kaira_subnet_public_a" {
  value = aws_subnet.kaira_subnet_public_a
}

output "output_kaira_subnet_public_b" {
  value = aws_subnet.kaira_subnet_public_b
}

output "output_kaira_subnet_public_c" {
  value = aws_subnet.kaira_subnet_public_c
}