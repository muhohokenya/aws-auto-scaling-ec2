/***************** Create a Security group for the Public ELB *************************/
resource "aws_security_group" "tech_space_elb_public_security_group" {
  name        = "tech-space-elb-public-security-group"
  description = "Tech space Elb Public security group"

  ingress {
    description = "Allow traffic from anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] //Allow traffic from the Internet
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.tech_space_vpc.id

  tags = {
    Name = "tech-space-alb-sg"
  }
}


/***************** Create a Security group to open ports 80 and 22 *************************/
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
#     cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.tech_space_elb_public_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tech-space-sg-allow-ssh"
  }
}

/***************** Create a Security group to open ports 80 and 22 *************************/
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
    Name = "tech-space-sg-for-Ec2"
  }
}