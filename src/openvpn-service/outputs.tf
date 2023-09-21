output "output_kaira_openvpn_server" {
  value = {
    openvpn_server = aws_instance.kaira_openvpn_server.arn
    openvpn_eip = aws_instance.kaira_openvpn_server.public_ip
  }
}