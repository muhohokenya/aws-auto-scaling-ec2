/***************** Create Public Route Table *************************/
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


/***************** Create Private Route Table *************************/
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.tech_space_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.tech_space_nat_gateway.id
  }

  tags = {
    Name = "private-route-table"
  }
}


/***************** Associate Public Subnet to Public Route table *************************/
resource "aws_route_table_association" "public_route_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}


/***************** Associate Public Subnet 2 to Public Route table *************************/
resource "aws_route_table_association" "private_subnet_route_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}