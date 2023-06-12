resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "internet_gateway"
    Owner = "jduchnowski" 
    Project = "2023_internship_gda"
  }
}
