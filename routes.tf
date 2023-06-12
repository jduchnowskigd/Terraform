resource "aws_route" "internet_connection" {
  route_table_id = aws_vpc.app_vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "route_table"
    Owner = "jduchnowski" 
    Project = "2023_internship_gda"
  }
}

resource "aws_route_table_association" "public_rt_asso_a" {
  subnet_id      = aws_subnet.public_eu_west_1a.id
  route_table_id = aws_route_table.public_rt.id

}

resource "aws_route_table_association" "public_rt_asso_b" {
  subnet_id      = aws_subnet.public_eu_west_1b.id
  route_table_id = aws_route_table.public_rt.id

}

# resource "aws_route_table_association" "public_rt_asso_igw" {
#   gateway_id      = aws_internet_gateway.igw.id
#   route_table_id = aws_route_table.public_rt.id

# }

#Czemu nie odpala się to route table na wejściu