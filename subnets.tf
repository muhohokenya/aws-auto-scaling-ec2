/***************** Create a Public Subnet 1 *************************/
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.tech_space_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags                    = {
    Name = "public-subnet(us-east-1a)"
  }
}
/***************** Create a Private Subnet 2 *************************/
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.tech_space_vpc.id
  cidr_block        = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1b"
  tags              = {
    Name = "private-subnet(us-east-1b)"
  }
}
# Create a EIP
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

/***************** Create a NAT Gateway *************************/
resource "aws_nat_gateway" "tech_space_nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "tech-space-nat-gateway"
  }
}