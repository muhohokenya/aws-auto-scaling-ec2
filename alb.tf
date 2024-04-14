# //Public ELB
resource "aws_lb" "tech_space_elb" {
  name               = "tech-space-public-elb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet.id,aws_subnet.private_subnet.id]
  security_groups    = [aws_security_group.tech_space_elb_public_security_group.id]
}