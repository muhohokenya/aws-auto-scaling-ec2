provider "aws" {
  region = "us-east-1"
}

/***************** Create a VPC *************************/
resource "aws_vpc" "tech_space_vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = {
    Name = "tech-space-vpc"
  }
}

/***************** Create Internet Gateway *************************/
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.tech_space_vpc.id

  tags = {
    Name = "Tech space IGW"
  }
}

/***************** Create a Launching Template for Ec2 Instances *************************/
resource "aws_launch_template" "tech_space_launch_template" {
  name = "tech_space_launch_template"

  # (Optional) Specify volumes to attach to the instance
  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
    }
  }

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  credit_specification {
    cpu_credits = "standard"
  }

  image_id = "ami-0c2a30db6ef1582e4"

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t2.micro"

#   kernel_id = "test"

  key_name = "main-key"


  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = false
#     subnet_id = aws_subnet.private_subnet.id
    security_groups = [aws_security_group.allow_ssh.id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Tech Space Ec2"
    }
  }

  user_data = filebase64("${path.module}/example.sh")
}

resource "aws_lb_target_group" "tech_space_target_group" {
  name     = "tech-space-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.tech_space_vpc.id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    timeout             = 3
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.tech_space_elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tech_space_target_group.arn
  }
}

resource "aws_autoscaling_group" "tech_space_autoscaling_group" {
  desired_capacity   = 3 // 80%
  max_size           = 3
  min_size           = 3
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete       = true
  launch_template {
  id = aws_launch_template.tech_space_launch_template.id
  version = "$Latest"
}
  vpc_zone_identifier = [aws_subnet.private_subnet.id]

  target_group_arns = [aws_lb_target_group.tech_space_target_group.arn]

  tag {
    key                 = "Name"
    value               = "auto-scalable-ec2"
    propagate_at_launch = true
  }
}
