resource "aws_subnet" "public_eu_west_1a" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.6.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet"
    Owner = "jduchnowski" 
    Project = "2023_internship_gda"
  }
}

resource "aws_subnet" "public_eu_west_1b" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.96.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet"
    Owner = "jduchnowski" 
    Project = "2023_internship_gda"
  }
}