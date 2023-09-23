terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  alias   = "spain"
  region  = "eu-south-2"
  profile = "kaira-dev-sso"
  default_tags {
    tags = {
      Name        = "kaira-resource-untagged",
      Client      = "kaira",
      Backup      = false,
      Environment = "DEV",
      ManagedBy   = "terraform"
      OwnerBy     = "@developez"
    }
  }
}

resource "null_resource" "kaira_account_services" {
  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = <<EOF
    if [ test ! -e "../account.output.txt" ]; then
      echo "--------------"
      echo "You must to run account-services first to prepare the basic account"
      echo "--------------"
      exit 1
    fi    
    EOF
  }
}

resource "aws_security_group" "kaira_openvpn_sg" {
  tags = {
    Name = "kaira-sg-openvpn"
  }

  depends_on = [ null_resource.kaira_account_services ]

  name        = "kaira-sg-openvpn"
  description = "Rules for openvpn service"

  vpc_id = data.aws_vpc.kaira_aws_vpc.id

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.office_ip_address]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "kaira_openvpn_server" {
  tags = {
    Name = "kaira-openvpn-server"
  }

  depends_on = [ null_resource.kaira_account_services ]

  ami                         = data.aws_ami.kaira_aws_ubuntu_ami.id
  associate_public_ip_address = true
  instance_type               = var.kaira_instance_type
  key_name                    = data.aws_key_pair.kaira_key_name.key_name
  subnet_id                   = data.aws_subnet.kaira_aws_subnet.id
  user_data                   = var.kaira_openvpn_script

  vpc_security_group_ids = [
    aws_security_group.kaira_openvpn_sg.id
  ]

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.kaira_root_volume_size
    delete_on_termination = true
  }
}

resource "aws_eip" "kaira_openvpn_eip" {
  tags = {
    Name = "kaira-openvpn-eip"
  }

  depends_on = [ null_resource.kaira_account_services ]

  domain   = "vpc"
  instance = aws_instance.kaira_openvpn_server.id
}

resource "null_resource" "kaira_openvpn_bootstrap_complete" {
  depends_on = [ null_resource.kaira_account_services, aws_instance.kaira_openvpn_server ]

  triggers = {
    kaira_openvpn_users_list      = local.openvpn_users_list,
    kaira_openvpn_add_user_script = filemd5("./openvpn-add-user.sh")
  }

  connection {
    type        = "ssh"
    host        = aws_eip.kaira_openvpn_eip.public_ip
    user        = "ubuntu"
    port        = "22"
    private_key = file(var.KAIRA_PRIVATE_RSA_PATH)
    agent       = false
  }

  provisioner "local-exec" {
    command = <<EOF
    rm -rf ../.clients/*.ovpn
    echo "--------------"
    echo "Waiting until the machine is configured.."
    echo "--------------"
    EOF
  }

  provisioner "local-exec" {
    command = <<EOF
    isConfiguring=true
    while $isConfiguring; do
      scp -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -i ${var.KAIRA_PRIVATE_RSA_PATH} \
        ubuntu@${aws_eip.kaira_openvpn_eip.public_ip}:/tmp/provisioned.lock /tmp/provisioned.lock 2>/dev/null
      if [ $? -eq 0 ]; then
        isConfiguring=false
      fi
      echo 'Waiting until the machine is configured...'
      sleep 10
    done;
    EOF
  }
}

resource "null_resource" "kaira_openvpn_users" {
  depends_on = [
    null_resource.kaira_account_services,
    aws_instance.kaira_openvpn_server,
    null_resource.kaira_openvpn_bootstrap_complete
  ]

  triggers = {
    kaira_openvpn_users_list      = local.openvpn_users_list,
    kaira_openvpn_add_user_script = filemd5("./openvpn-add-user.sh")
  }

  connection {
    type        = "ssh"
    host        = aws_eip.kaira_openvpn_eip.public_ip
    user        = "ubuntu"
    port        = "22"
    private_key = file(var.KAIRA_PRIVATE_RSA_PATH)
    agent       = false
  }

  provisioner "file" {
    source      = var.kaira_openvpn_users_list
    destination = "/opt/openvpn/users"
  }

  provisioner "file" {
    source      = "./openvpn-add-user.sh"
    destination = "/opt/openvpn/openvpn-add-user.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /opt/openvpn/openvpn-add-user.sh",
      "sudo bash /opt/openvpn/openvpn-add-user.sh"
    ]
  }

  provisioner "local-exec" {
    command = <<EOF
    mkdir -p ../.clients;
    scp -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -i ${var.KAIRA_PRIVATE_RSA_PATH} ubuntu@${aws_eip.kaira_openvpn_eip.public_ip}:/opt/openvpn/clients/*.ovpn ../.clients/
    echo "--------------"
    echo "OpenVPN clients downloaded"
    echo "--------------"
    EOF
  }
}