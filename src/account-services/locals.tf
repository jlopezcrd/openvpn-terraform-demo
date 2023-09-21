data "http" "office_ip_address" {
  url = "https://checkip.amazonaws.com"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  office_ip_address = "${chomp(data.http.office_ip_address.response_body)}/32"
  public_rsa_key    = file(var.kaira_public_rsa_path)
}