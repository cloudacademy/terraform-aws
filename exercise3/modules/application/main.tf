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

  owners = ["099720109477"] # Canonical
}

data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = false
  #first part of local config file
  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
    #! /bin/bash
    apt-get -y update
    apt-get -y install nginx
    systemctl start nginx

    echo ===========================
    echo install yarn...
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    apt-get update
    apt-get -y install yarn

    echo install golang...
    wget -c https://golang.org/dl/go1.16.7.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local
    export PATH=$PATH:/usr/local/go/bin

    mkdir -p /tmp/cloudacademy-app
    cd /tmp/cloudacademy-app

    echo ===========================
    echo cloning...
    git clone https://github.com/cloudacademy/voteapp-api-go
    git clone https://github.com/cloudacademy/voteapp-frontend-react-2020.git

    echo ===========================
    echo building api v1.01...
    mkdir -p /tmp/cloudacademy-app/go
    mkdir -p /tmp/cloudacademy-app/go-cache
    export GOPATH=/tmp/cloudacademy-app/go
    export GOCACHE=/tmp/cloudacademy-app/go-cache
    pushd ./voteapp-api-go
    which go
    go env
    go get -v
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o api
    MONGO_CONN_STR=mongodb://${var.mongodb_ip}:27017/langdb ./api &
    popd

    echo ===========================
    echo building frontend v2020...
    pushd ./voteapp-frontend-react-2020
    yarn install
    yarn build
    rm -rf /var/www/html
    cp -R build /var/www/html
    cat > /var/www/html/env-config.js << EOFF
    window._env_ = {REACT_APP_APIHOSTPORT: "${aws_lb.alb1.dns_name}:8080"}
    EOFF
    popd

    echo fin v1.00!

    EOF
  }
}

resource "aws_launch_template" "launchtemplate1" {
  name = "web"
  
  image_id        = data.aws_ami.ubuntu.id
	instance_type   = var.instance_type
	key_name        = var.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [var.webserver_sg_id]
  }

  //vpc_security_group_ids = [aws_security_group.webserver.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "App"
    }
  }

  user_data = "${base64encode(data.template_cloudinit_config.config.rendered)}"
}

resource "aws_lb" "alb1" {
  name               = "alb1"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = [var.subnet1_id, var.subnet2_id]

  enable_deletion_protection = false
  
  /*
  access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = "test-lb"
    enabled = true
  }
  */

  tags = {
    Environment = "production"
  }
}

resource "aws_alb_target_group" "webserver" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_alb_target_group" "api" {
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb1.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.webserver.arn
  }
}

resource "aws_alb_listener" "api" {
  load_balancer_arn = aws_lb.alb1.arn
  port              = "8080"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.api.arn
  }
}

resource "aws_alb_listener_rule" "frontend_rule1" {
  listener_arn = aws_alb_listener.front_end.arn
  priority     = 99

  action {
    type = "forward"
    target_group_arn = aws_alb_target_group.webserver.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

resource "aws_alb_listener_rule" "api_rule1" {
  listener_arn = aws_alb_listener.api.arn
  priority     = 99

  action {
    type = "forward"
    target_group_arn = aws_alb_target_group.api.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier       = [var.subnet3_id, var.subnet4_id]

  desired_capacity   = var.asg_desired
  max_size           = var.asg_max_size
  min_size           = var.asg_min_size
  
  target_group_arns = [aws_alb_target_group.webserver.arn, aws_alb_target_group.api.arn]

  launch_template {
    id      = aws_launch_template.launchtemplate1.id
    version = "$Latest"
  }
}