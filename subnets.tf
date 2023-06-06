resource "aws_subnet" "private_eu_west_1a" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.0.0/19"
  availability_zone = "eu-west-1a"

  tags = {
    "Name" = "private_eu_west_1a"
  }
}

resource "aws_subnet" "private_eu_west_1b" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.32.0/19"
  availability_zone = "eu-west-1b"

  tags = {
    "Name" = "private_eu_west_1b"
  }
}

resource "aws_subnet" "public_eu_west_1a" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.64.0/19"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "public_eu_west_1a"
  }
}

resource "aws_subnet" "public_eu_west_1b" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.96.0/19"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "public_eu_west_1a"
  }
}