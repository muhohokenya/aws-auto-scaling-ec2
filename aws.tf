
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "tech_space_vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = {
    Name = "tech-space-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.tech_space_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags                    = {
    Name = "public-subnet(us-east-1a)"
  }
}


resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.tech_space_vpc.id
  cidr_block        = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
  tags              = {
    Name = "public-subnet(us-east-1b)"
  }
}

//Create an IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.tech_space_vpc.id

  tags = {
    Name = "Tech space IGW"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.tech_space_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_route_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_route_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "allow_ssh" {
  vpc_id = aws_vpc.tech_space_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-ssh"
  }
}


resource "aws_security_group" "security_group_for_ec2" {
  vpc_id = aws_vpc.tech_space_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Security group for Ec2"
  }
}


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
    associate_public_ip_address = true
    subnet_id = aws_subnet.public_subnet.id
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

/*Public elb security group*/
resource "aws_security_group" "tech_space_elb_public_security_group" {
  name        = "tech-space-elb-public-security-group"
  description = "Tech space Elb Public security group"

  ingress {
    description = "Allow traffic on port 80 from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] //Allow traffic from the Internet
  }

  egress {
    description = "Allow outbound traffic only to the private elb-sg"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.tech_space_private_elb_security_group.id]
  }

  vpc_id = aws_vpc.tech_space_vpc.id
}

//Private Elb Security group
resource "aws_security_group" "tech_space_private_elb_security_group" {
  name        = "tech-space-elb-private-security-group"
  description = "Tech space Elb Private Security group"

  ingress {
    description = "Allow traffic on port 80 from the Tech space Elb Public security group"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.tech_space_elb_public_security_group.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.tech_space_vpc.id
}

//Public ELB
resource "aws_lb" "tech_space_elb" {
  name               = "TechSpaceElb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet.id,aws_subnet.public_subnet_2.id]
  security_groups    = [aws_security_group.tech_space_elb_public_security_group.id]
}

//Private ELB
resource "aws_lb" "tech_space_private_elb" {
  name               = "TechSpacePrivateElb"
  internal           = true
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet.id,aws_subnet.public_subnet_2.id]
  security_groups    = [aws_security_group.tech_space_private_elb_security_group.id]
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
  load_balancer_arn = aws_lb.tech_space_private_elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tech_space_target_group.arn
  }
}


resource "aws_autoscaling_group" "tech_space_autoscaling_group" {
  desired_capacity   = 3
  max_size           = 4
  min_size           = 3
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete       = true
  launch_template {
  id = aws_launch_template.tech_space_launch_template.id
  version = "$Latest"
}
  vpc_zone_identifier = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id]

  target_group_arns = [aws_lb_target_group.tech_space_target_group.arn]

  tag {
    key                 = "Name"
    value               = "example-asg"
    propagate_at_launch = true
  }
}


#resource "aws_instance" "public_instance" {
#  ami           = "ami-0c2a30db6ef1582e4"
#  instance_type = "t2.micro"
#  subnet_id     = aws_subnet.public_subnet.id
#  key_name      = "main-key"
#  security_groups = [aws_security_group.allow_ssh.id]
#
#  tags = {
#    Name = "public-ec2"
#  }
#}



# resource "aws_nat_gateway" "nat_gateway" {
#   allocation_id = aws_eip.nat_eip.id
#   subnet_id     = aws_subnet.public_subnet_2.id
# }

# resource "aws_eip" "nat_eip" {
#   domain = "vpc"
# }

# resource "aws_route_table" "private_route_table" {
#   vpc_id = aws_vpc.tech_space_vpc.id
#
#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat_gateway.id
#   }
#
#   tags = {
#     Name = "private-route-table"
#   }
# }

# resource "aws_route_table_association" "private_route_association" {
#   subnet_id      = aws_subnet.public_subnet_2.id
#   route_table_id = aws_route_table.private_route_table.id
# }
#
# resource "aws_instance" "private_instance" {
#   ami           = "ami-0c2a30db6ef1582e4"
#   instance_type = "t2.micro"
#   subnet_id     = aws_subnet.public_subnet_2.id
#   key_name      = "main-key"
#
#   tags = {
#     Name = "private-ec2"
#   }
# }


#output "public_instance_public_ip" {
#  value = aws_instance.public_instance.public_ip
#}

# output "private_instance_private_ip" {
#   value = aws_instance.private_instance.private_ip
# }

# output "nat_gateway_public_ip" {
#   value = aws_eip.nat_eip.public_ip
# }
