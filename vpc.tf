# Create a VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc"
    Owner = "jduchnowski" 
    Project = "2023_internship_gda"
  }
}