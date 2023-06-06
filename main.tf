locals {
  web_servers = {
    my-app-00 = {
      machine_type = "t2.micro"
      subnet_id    = aws_subnet.private_eu_west_1a.id
    }
    my-app-01 = {
      machine_type = "t2.micro"
      subnet_id    = aws_subnet.private_eu_west_1b.id
    }
  }
}

# Create a VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/16"

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
  subnet_id      = aws_subnet.public_eu_west_1a.id
  route_table_id = aws_route_table.public_rt.id

}

resource "aws_instance" "my_app_eg1" {
  for_each = local.web_servers

  ami           = "ami-08542e8d46d02e096"
  instance_type = each.value.machine_type
  key_name      = "my-key-pair"
  subnet_id     = each.value.subnet_id

  vpc_security_group_ids = [aws_security_group.sg.id]

  user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing apache2"
  sudo apt update -y
  sudo apt install apache2 -y
  echo "*** Completed Installing apache2"
  EOF


  tags = {
    Name = each.key
  }
}

# resource "aws_ami_from_instance" "example" {
#   name               = "web_server_instance"
#   source_instance_id = aws_instance.web.id
#   count = 3
# }
resource "aws_lb_target_group" "my_app_eg1" {
  name       = "my-app-eg1"
  port       = 8080
  protocol   = "HTTP"
  vpc_id     = aws_vpc.app_vpc.id
  slow_start = 0

  load_balancing_algorithm_type = "round_robin"

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  health_check {
    enabled             = true
    port                = 8081
    interval            = 30
    protocol            = "HTTP"
    path                = "/health"
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group_attachment" "my_app_eg1" {
  for_each = aws_instance.my_app_eg1

  target_group_arn = aws_lb_target_group.my_app_eg1.arn
  target_id        = each.value.id
  port             = 8080
}

resource "aws_lb" "my_app_eg1" {
  name               = "my-app-eg1"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]

  # access_logs {
  #   bucket  = "my-logs"
  #   prefix  = "my-app-lb"
  #   enabled = true
  # }

  subnets = [
    aws_subnet.public_eu_west_1a.id,
    aws_subnet.public_eu_west_1b.id
  ]
}

resource "aws_lb_listener" "http_eg1" {
  load_balancer_arn = aws_lb.my_app_eg1.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_app_eg1.arn
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
