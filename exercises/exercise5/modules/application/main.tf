terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.60.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Canonical
  owners = ["099720109477"]
}

#====================================

# data "template_cloudinit_config" "config" {
#   gzip          = false
#   base64_encode = false

#   #userdata
#   part {
#     content_type = "text/x-shellscript"
#     content      = <<-EOF
#     #! /bin/bash

#     #ansible now performs install
#     echo fin v1.00!

#     EOF
#   }
# }

#====================================

#tfsec:ignore:aws-ec2-enforce-launch-config-http-token-imds
resource "aws_launch_template" "apptemplate" {
  name = "application"

  image_id               = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.webserver_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name  = "FrontendApp"
      Owner = "CloudAcademy"
    }
  }

  #user_data = base64encode(data.template_cloudinit_config.config.rendered)
}

#====================================

#tfsec:ignore:aws-elb-alb-not-public
resource "aws_lb" "alb1" {
  name                       = "alb1"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.alb_sg_id]
  subnets                    = var.public_subnets
  drop_invalid_header_fields = true
  enable_deletion_protection = false

  /*
  access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = "test-lb"
    enabled = true
  }
  */

  tags = {
    Environment = "Prod"
  }
}

resource "aws_alb_target_group" "webserver" {
  vpc_id   = var.vpc_id
  port     = 80
  protocol = "HTTP"

  health_check {
    path                = "/"
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 6
    timeout             = 5
  }
}

resource "aws_alb_target_group" "api" {
  vpc_id   = var.vpc_id
  port     = 8080
  protocol = "HTTP"

  health_check {
    path                = "/ok"
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 6
    timeout             = 5
  }
}

#tfsec:ignore:aws-elb-http-not-used
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb1.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.webserver.arn
  }
}

resource "aws_alb_listener_rule" "frontend_rule1" {
  listener_arn = aws_alb_listener.front_end.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["/"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.webserver.arn
  }
}

resource "aws_alb_listener_rule" "api_rule1" {
  listener_arn = aws_alb_listener.front_end.arn
  priority     = 10

  condition {
    path_pattern {
      values = [
        "/languages",
        "/languages/*",
        "/languages/*/*",
        "/ok"
      ]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.api.arn
  }
}

#====================================

resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = var.private_subnets

  desired_capacity = var.asg_desired
  max_size         = var.asg_max_size
  min_size         = var.asg_min_size

  target_group_arns = [aws_alb_target_group.webserver.arn, aws_alb_target_group.api.arn]

  launch_template {
    id      = aws_launch_template.apptemplate.id
    version = "$Latest"
  }
}

data "aws_instances" "application" {
  instance_tags = {
    Name  = "FrontendApp"
    Owner = "CloudAcademy"
  }

  instance_state_names = ["pending", "running"]

  depends_on = [
    aws_autoscaling_group.asg
  ]
}
