data "http" "office_ip_address" {
  url = "https://checkip.amazonaws.com"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  office_ip_address = "${chomp(data.http.office_ip_address.response_body)}/32"
  vpc_id            = "kaira-vpc"
  subnet_public_a   = "kaira-subnet-public-a"
  public_key_name   = "kaira-rsa-public-key"
  public_rsa_key    = file(var.KAIRA_PUBLIC_RSA_PATH) //"/home/$USER/.ssh/id_rsa.pub"
}