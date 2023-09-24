resource "aws_security_group" "kaira_openvpn_nlb_sg" {
  tags = {
    Name = "kaira-nlb-sg-openvpn"
  }

  name        = "kaira-nlb-sg-openvpn"
  description = "Rules for openvpn service"

  vpc_id = data.aws_vpc.kaira_aws_vpc.id

  ingress {
    from_port   = var.kaira_container_port
    to_port     = var.kaira_container_port
    protocol    = var.kaira_container_protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "kaira_openvpn_ecs_sg" {
  tags = {
    Name = "kaira-ecs-sg-openvpn"
  }

  name        = "kaira-ecs-sg-openvpn"
  description = "Rules for openvpn service"

  vpc_id = data.aws_vpc.kaira_aws_vpc.id

  ingress {
    from_port       = var.kaira_container_port
    to_port         = var.kaira_container_port
    protocol        = var.kaira_container_protocol
    security_groups = [aws_security_group.kaira_openvpn_nlb_sg.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.kaira_openvpn_nlb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "kaira_iam_role" {
  name               = "ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.kaira_iam_policy_document.json
}

resource "aws_iam_role_policy_attachment" "kaira_iam_role_policy_attachment" {
  role       = aws_iam_role.kaira_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "kaira_iam_instance_profile" {
  name = "ecs-agent"
  role = aws_iam_role.kaira_iam_role.name
}

resource "aws_launch_configuration" "kaira_launch_configuration" {
  image_id             = data.aws_ami.kaira_aws_ecs_ami.id
  iam_instance_profile = aws_iam_instance_profile.kaira_iam_instance_profile.name
  security_groups      = [aws_security_group.kaira_openvpn_ecs_sg.id]
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=kaira-ecs-ec2-cluster >> /etc/ecs/ecs.config"
  instance_type        = "t3.small"
}

resource "aws_autoscaling_group" "kaira_autoscaling_group" {
  name = "asg"
  vpc_zone_identifier = [
    data.aws_subnet.kaira_aws_subnet_a.id,
    data.aws_subnet.kaira_aws_subnet_b.id,
    data.aws_subnet.kaira_aws_subnet_c.id,
  ]
  launch_configuration = aws_launch_configuration.kaira_launch_configuration.name

  desired_capacity          = 3
  min_size                  = 3
  max_size                  = 3
  health_check_grace_period = 10
  health_check_type         = "EC2"
}

resource "aws_lb" "kaira_external_nlb" {
  tags = {
    Name = "kaira-external-nlb",
  }

  name                             = "kaira-external-nlb"
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

resource "aws_lb_target_group" "kaira_external_nlb_tg" {
  tags = {
    Name = "kaira-external-nlb-tg",
  }

  name                 = "kaira-external-nlb-tg"
  port                 = var.kaira_container_port
  protocol             = "TCP_UDP" #upper(var.kaira_container_protocol)
  vpc_id               = data.aws_vpc.kaira_aws_vpc.id
  target_type          = "ip"
  deregistration_delay = 10

  health_check {
    port                = 80
    protocol            = "TCP" #upper(var.kaira_container_protocol)
    interval            = 5
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "kaira_nlb_listener" {
  load_balancer_arn = aws_lb.kaira_external_nlb.id
  port              = var.kaira_container_port
  protocol          = "TCP_UDP" #upper(var.kaira_container_protocol)

  default_action {
    target_group_arn = aws_lb_target_group.kaira_external_nlb_tg.id
    type             = "forward"
  }  
}

resource "aws_ecs_cluster" "kaira_ecs_cluster" {
  name = "kaira-ecs-ec2-cluster"
}

resource "aws_ecs_task_definition" "kaira_openvpn_task" {
  family = var.kaira_container_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = 512
  memory                   = 512
  execution_role_arn       = data.aws_iam_role.kaira_ecs_task_execution_role.arn
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
      name : var.kaira_container_name,
      image : "366007218587.dkr.ecr.eu-south-2.amazonaws.com/kaira-ecr:latest",
      cpu : 256,
      memory : 256,
      essential : true,
      portMappings : [
        {
          containerPort : var.kaira_container_port,
          hostPort : var.kaira_container_port,
          protocol : var.kaira_container_protocol
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
  #depends_on = [ aws_lb.kaira_external_nlb ] //TODO

  tags = {
    Name = "kaira-openvpn-service",
  }

  name            = "openvpn-service"
  cluster         = aws_ecs_cluster.kaira_ecs_cluster.id
  task_definition = aws_ecs_task_definition.kaira_openvpn_task.arn
  desired_count   = 3
  launch_type     = "EC2"
  #platform_version = "LATEST"

  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = [
      aws_security_group.kaira_openvpn_nlb_sg.id, //TODO
      aws_security_group.kaira_openvpn_ecs_sg.id
    ]
    subnets          = [
      data.aws_subnet.kaira_aws_subnet_a.id,
      data.aws_subnet.kaira_aws_subnet_b.id,
      data.aws_subnet.kaira_aws_subnet_c.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.kaira_external_nlb_tg.arn
    container_name = var.kaira_container_name
    container_port = var.kaira_container_port
  }

  force_new_deployment = true

  triggers = {
    redeployment = timestamp()
  }

  # lifecycle {
  #   ignore_changes = [task_definition]
  # }
}