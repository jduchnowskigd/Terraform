resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "internet_gateway"
    Owner = "jduchnowski" 
    Project = "2023_internship_gda"
  }
}

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

resource "aws_security_group" "sg" {
  name        = "allow_ssh_http"
  description = "Allow ssh http inbound traffic"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
    ingress {
    description      = "SSH from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh_http"
  }
}


resource "aws_security_group" "instance_sg" {
  
}

resource "aws_security_group" "lb_sg" {
  
}

# Create a VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc"
    Owner = "jduchnowski" 
    Project = "2023_internship_gda"
  }
}