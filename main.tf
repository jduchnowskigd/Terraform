# Create a VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "app-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "vpc_igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = "eu-west-1a"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "public_rt_asso" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id

}

resource "aws_instance" "web" {
ami             = "ami-0f29c8402f8cce65c" 
instance_type   = var.instance_type
key_name        = var.instance_key
subnet_id       = aws_subnet.public_subnet.id
security_groups = [aws_security_group.sg.id]

user_data = <<-EOF
#!/bin/bash
echo "*** Installing apache2"
sudo apt update -y
sudo apt install apache2 -y
echo "*** Completed Installing apache2"
EOF

tags = {
  Name = "web_instance"
}

volume_tags = {
  Name = "web_instance"
 } 
}

  # Inny sposób na egzekucje komand na nowo stworzonej maszynce
  # provisioner "remote-exec" {
  #   inline = [
  #     "sed -i \"s/MAGE_COMPOSER_USERNAME/${var.mage_composer_username}/g\" /tmp/ec2_install/configs/auth.json",
  #     "sed -i \"s/MAGE_COMPOSER_PASSWORD/${var.mage_composer_password}/g\" /tmp/ec2_install/configs/auth.json",
  #     "chmod +x /tmp/ec2_install/scripts/*.sh",
  #     "/tmp/ec2_install/scripts/install_stack.sh",
  #   ]

  #   connection {
  #     type        = "ssh"
  #     host        = self.public_ip
  #     user        = var.ssh_username
  #     private_key = data.aws_secretsmanager_secret_version.ssh-key.secret_string
  #   }

  # }
