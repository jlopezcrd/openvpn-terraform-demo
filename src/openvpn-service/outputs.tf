output "output_kaira_openvpn_server" {
  value = {
    openvpn_server     = aws_instance.kaira_openvpn_server.arn
    openvpn_public_ip  = aws_eip.kaira_openvpn_eip.public_ip
    openvpn_private_ip = aws_eip.kaira_openvpn_eip.private_ip
    openvpn_dns_name   = aws_eip.kaira_openvpn_eip.public_dns
  }
}