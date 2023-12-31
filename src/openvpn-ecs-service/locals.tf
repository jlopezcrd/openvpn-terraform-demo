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
  subnet_public_b   = "kaira-subnet-public-b"
  subnet_public_c   = "kaira-subnet-public-c"
  public_key_name   = "kaira-rsa-public-key"
}