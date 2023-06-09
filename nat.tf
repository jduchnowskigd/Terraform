resource "aws_eip" "nat" {
  vpc = true

  tags = {
Name = "nat_gateway"
Owner = "jduchnowski" 
Project = "2023_internship_gda"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_eu_west_1a.id

  tags = {
Name = "nat_gateway"
Owner = "jduchnowski" 
Project = "2023_internship_gda"
  }

  depends_on = [aws_internet_gateway.igw]
}