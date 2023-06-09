provider "aws" {
  region = "us-west-2"
}

# Create a temporary EC2 instance with an HTTP server installation script
resource "aws_instance" "temporary_vm" {
  ami           = "ami-0c94855ba95c71c99"  # Use a predefined AMI as the source image
  instance_type = "t2.micro"
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    echo "Hello from temporary VM!" > /var/www/html/index.html
    systemctl enable httpd
    systemctl start httpd
    EOF
}

# Create an AMI from the temporary EC2 instance
resource "aws_ami" "temporary_vm_image" {
  name               = "temporary-vm-image"
  instance_id        = aws_instance.temporary_vm.id
  root_device_name   = "/dev/xvda"
  ebs_block_device {
    device_name = "/dev/xvda"
    volume_size = 8
  }
}

# Create a launch configuration
resource "aws_launch_configuration" "example" {
  name          = "example-launch-config"
  image_id      = aws_ami.temporary_vm_image.id
  instance_type = "t2.micro"
  user_data     = <<-EOF
    #!/bin/bash
    echo "ServerNumber: 1" > /var/www/html/index.html
    systemctl enable httpd
    systemctl start httpd
    EOF
}

# Create an auto scaling group
resource "aws_autoscaling_group" "example" {
  name                      = "example-asg"
  min_size                  = 3
  max_size                  = 3
  desired_capacity          = 3
  launch_configuration      = aws_launch_configuration.example.name
  vpc_zone_identifier       = ["subnet-12345678"]
  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "example-instance"
    propagate_at_launch = true
  }
}

# Create a load balancer
resource "aws_lb" "example" {
  name               = "example-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-12345678"]
  subnets            = ["subnet-12345678"]
}

# Create a target group
resource "aws_lb_target_group" "example" {
  name        = "example-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "vpc-12345678"
  target_type = "instance"
  health_check {
    path = "/"
  }
}

# Attach target group to auto scaling group
resource "aws_lb_target_group_attachment" "example" {
  target_group_arn = aws_lb_target_group.example.arn
  target_id        = aws_autoscaling_group.example.id
  port             = 80
}

# Create a listener for the load balancer
resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}
