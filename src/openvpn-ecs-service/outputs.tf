output "output_kaira_openvpn_external_nlb" {
  value = {
    dns_name = aws_lb.kaira_openvpn_external_nlb.dns_name
  }
}