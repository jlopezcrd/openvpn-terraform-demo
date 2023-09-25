terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.kaira_default_region
  profile = var.kaira_default_role
  default_tags {
    tags = var.kaira_default_tags
  }
}

resource "aws_security_group" "kaira_openvpn_nlb_sg" {
  tags = {
    Name = "kaira-openvpn-nlb-sg"
  }

  name        = "kaira-openvpn-nlb-sg"
  description = "Rules for openvpn service"

  vpc_id = data.aws_vpc.kaira_aws_vpc.id

  ingress {
    from_port   = var.kaira_openvpn_container_port
    to_port     = var.kaira_openvpn_container_port
    protocol    = var.kaira_openvpn_container_protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   from_port       = 80
  #   to_port         = 80
  #   protocol        = "tcp"
  #   cidr_blocks     = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "kaira_openvpn_ecs_sg" {
  tags = {
    Name = "kaira-openvpn-ecs-sg"
  }

  name        = "kaira-openvpn-ecs-sg"
  description = "Rules for openvpn service"

  vpc_id = data.aws_vpc.kaira_aws_vpc.id

  ingress {
    from_port       = 8
    to_port         = 0
    protocol        = "icmp"
    security_groups = [aws_security_group.kaira_openvpn_nlb_sg.id]
  }

  ingress {
    from_port       = var.kaira_openvpn_container_port
    to_port         = var.kaira_openvpn_container_port
    protocol        = var.kaira_openvpn_container_protocol
    security_groups = [aws_security_group.kaira_openvpn_nlb_sg.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    //cidr_blocks     = ["0.0.0.0/0"] //FOR HEALTH CHECKS
    security_groups = [aws_security_group.kaira_openvpn_nlb_sg.id] //FOR HEALTH CHECKS
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "kaira_openvpn_iam_role" {
  tags = {
    Name = "kaira-openvpn-iam-role"
  }

  name               = "kaira-openvpn-iam-role"
  assume_role_policy = data.aws_iam_policy_document.kaira_aws_sts_policy.json
}

resource "aws_iam_role_policy_attachment" "kaira_openvpn_iam_role_policy_attachment" {
  role       = aws_iam_role.kaira_openvpn_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "kaira_openvpn_iam_instance_profile" {
  tags = {
    Name = "kaira-openvpn-iam-instance-profile"
  }

  name = "kaira-openvpn-iam-instance-profile"
  role = aws_iam_role.kaira_openvpn_iam_role.name
}

resource "aws_launch_configuration" "kaira_openvpn_launch_configuration" {
  image_id             = data.aws_ami.kaira_aws_ecs_ami.id
  iam_instance_profile = aws_iam_instance_profile.kaira_openvpn_iam_instance_profile.name
  security_groups      = [aws_security_group.kaira_openvpn_ecs_sg.id]
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=kaira-openvpn-cluster >> /etc/ecs/ecs.config"
  instance_type        = "t3.small"
}

resource "aws_autoscaling_group" "kaira_openvpn_autoscaling_group" {
  depends_on = [ aws_launch_configuration.kaira_openvpn_launch_configuration ]

  name = "kaira-openvpn-autoscaling-group"
  vpc_zone_identifier = [
    data.aws_subnet.kaira_aws_subnet_a.id,
    data.aws_subnet.kaira_aws_subnet_b.id,
    data.aws_subnet.kaira_aws_subnet_c.id,
  ]
  launch_configuration = aws_launch_configuration.kaira_openvpn_launch_configuration.name

  desired_capacity          = var.kaira_openvpn_autoscaling_group_capacity
  min_size                  = var.kaira_openvpn_autoscaling_group_max_size
  max_size                  = var.kaira_openvpn_autoscaling_group_max_size
  health_check_grace_period = 10
  health_check_type         = "EC2"

  tag {
    key                 = "Name"
    value               = "openvpn-node"
    propagate_at_launch = true
  }
}

resource "aws_lb" "kaira_openvpn_external_nlb" {
  depends_on = [ aws_autoscaling_group.kaira_openvpn_autoscaling_group ]

  tags = {
    Name = "kaira-openvpn-external-nlb",
  }

  name                             = "kaira-openvpn-external-nlb"
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = "true"

  internal = false
  subnets  = [
    data.aws_subnet.kaira_aws_subnet_a.id,
    data.aws_subnet.kaira_aws_subnet_b.id,
    data.aws_subnet.kaira_aws_subnet_c.id
  ]

  security_groups = [ aws_security_group.kaira_openvpn_nlb_sg.id ]
}

resource "aws_lb_target_group" "kaira_openvpn_target_group" {
  depends_on = [ aws_lb.kaira_openvpn_external_nlb ]

  tags = {
    Name = "kaira-openvpn-external-nlb-tg",
  }

  name                 = "kaira-openvpn-external-nlb-tg"
  port                 = var.kaira_openvpn_container_port
  protocol             = "TCP_UDP"
  vpc_id               = data.aws_vpc.kaira_aws_vpc.id
  target_type          = "ip"
  deregistration_delay = 10

  health_check {
    port                = 80
    protocol            = "TCP"
    interval            = 5
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "kaira_openvpn_nlb_listener" {
  depends_on = [ aws_lb.kaira_openvpn_external_nlb ]

  tags = {
    Name = "kaira-openvpn-nlb-listener",
  }

  load_balancer_arn = aws_lb.kaira_openvpn_external_nlb.id
  port              = var.kaira_openvpn_container_port
  protocol          = "TCP_UDP"

  default_action {
    target_group_arn = aws_lb_target_group.kaira_openvpn_target_group.id
    type             = "forward"
  }  
}

resource "null_resource" "kaira_upload_openvpn_image" {
  depends_on = [data.aws_ecr_repository.kaira_aws_openvpn_repo]
     
  triggers = {
    redeployment = timestamp()
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash" ,"-c"]
    command = <<EOF
    aws ecr get-login-password --profile kaira-dev-sso --region ${var.kaira_default_region} | docker login --username AWS \
    --password-stdin ${data.aws_caller_identity.account.account_id}.dkr.ecr.${var.kaira_default_region}.amazonaws.com \
    && docker push ${data.aws_ecr_repository.kaira_aws_openvpn_repo.repository_url}:latest
    EOF
  }
}

resource "aws_ecs_cluster" "kaira_openvpn_ecs_ec2_cluster" {
  depends_on = [
    aws_iam_role_policy_attachment.kaira_openvpn_iam_role_policy_attachment,
    aws_launch_configuration.kaira_openvpn_launch_configuration,
    aws_autoscaling_group.kaira_openvpn_autoscaling_group,
    aws_lb.kaira_openvpn_external_nlb,
    null_resource.kaira_upload_openvpn_image
  ]

  tags = {
    Name = "kaira-openvpn-cluster",
  }

  name = "kaira-openvpn-cluster"
}

resource "aws_ecs_task_definition" "kaira_openvpn_task" {
  depends_on = [
    aws_iam_role_policy_attachment.kaira_openvpn_iam_role_policy_attachment,
    aws_launch_configuration.kaira_openvpn_launch_configuration,
    aws_autoscaling_group.kaira_openvpn_autoscaling_group,
    aws_lb.kaira_openvpn_external_nlb,
    null_resource.kaira_upload_openvpn_image
  ]

  tags = {
    Name = "kaira-openvpn-task",
  }

  family = var.kaira_openvpn_container_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = 512
  memory                   = 512
  execution_role_arn       = data.aws_iam_role.kaira_aws_ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name : "healthcheck",
      image : "nginx:latest",
      cpu : 256,
      memory : 256,
      essential : true,
      portMappings : [
        {
          containerPort : 80,
          hostPort : 80,
          protocol : "tcp"
        },
      ]
    },
    {
      name : var.kaira_openvpn_container_name,
      image : "${data.aws_ecr_repository.kaira_aws_openvpn_repo.repository_url}:latest",
      cpu : 256,
      memory : 256,
      essential : true,
      portMappings : [
        {
          containerPort : var.kaira_openvpn_container_port,
          hostPort : var.kaira_openvpn_container_port,
          protocol : var.kaira_openvpn_container_protocol
        },
      ],
      linuxParameters : {
        capabilities : {
          add : ["NET_ADMIN"]
        }
      },
      environment : [
        {
          name : "DEBUG",
          value : "1"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "kaira_openvpn_service" {
  depends_on = [
    aws_iam_role_policy_attachment.kaira_openvpn_iam_role_policy_attachment,
    aws_launch_configuration.kaira_openvpn_launch_configuration,
    aws_autoscaling_group.kaira_openvpn_autoscaling_group,
    aws_lb.kaira_openvpn_external_nlb,
    null_resource.kaira_upload_openvpn_image
  ]

  tags = {
    Name = "kaira-openvpn-service",
  }

  name            = "openvpn-service"
  cluster         = aws_ecs_cluster.kaira_openvpn_ecs_ec2_cluster.id
  task_definition = aws_ecs_task_definition.kaira_openvpn_task.arn
  desired_count   = var.kaira_openvpn_service_capacity
  launch_type     = "EC2"

  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = [
      aws_security_group.kaira_openvpn_ecs_sg.id
    ]
    subnets          = [
      data.aws_subnet.kaira_aws_subnet_a.id,
      data.aws_subnet.kaira_aws_subnet_b.id,
      data.aws_subnet.kaira_aws_subnet_c.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.kaira_openvpn_target_group.arn
    container_name = var.kaira_openvpn_container_name
    container_port = var.kaira_openvpn_container_port
  }

  force_new_deployment = true

  # triggers = {
  #   redeployment = timestamp()
  # }
}

resource "null_resource" "kaira_openvpn_users" {
  depends_on = [
    aws_iam_role_policy_attachment.kaira_openvpn_iam_role_policy_attachment,
    aws_launch_configuration.kaira_openvpn_launch_configuration,
    aws_lb.kaira_openvpn_external_nlb,
    aws_ecs_cluster.kaira_openvpn_ecs_ec2_cluster,
    aws_ecs_task_definition.kaira_openvpn_task,
    aws_ecs_service.kaira_openvpn_service
  ]

  triggers = {
    redeployment = timestamp()
  }

  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = <<EOF
    echo "--------------"
    echo "Applying dns endpoint to OpenVPN clients"
    echo "--------------"
    cd .generated/clients
    for client in $(find . -name "*.ovpn"); do
      echo "Editing: $client ..."
      config=$(cat $client)
      echo "$${config//vpn-test-ecs.kairadigital.com/${aws_lb.kaira_openvpn_external_nlb.dns_name}}" > $client
    done
    EOF
  }
}