provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      hashicorp-learn = "aws-asg"
    }
  }
}

terraform {

  backend "s3" {
      depends_on = [aws_s3_bucket.terraform_state]
    # bucket = aws_s3_bucket.terraform_state.name
    # key    = "terraform.tfstate"
    # region = "eu-west-1"  
  }
}

resource "aws_instance" "template_ec2" {
    ami = "ami-0f29c8402f8cce65c"
    instance_type = "t2.micro"
    key_name = "linuxbasics"
    security_groups = [ aws_security_group.sg.id ]
    associate_public_ip_address = true
    subnet_id = aws_subnet.public_eu_west_1a.id
    user_data = <<-EOF
    #!/bin/bash
    echo "*** Installing apache2"
    sudo apt update -y
    sudo apt install apache2 -y
    echo "*** Completed Installing apache2"
    echo "<html><body><h1>Instance Hostname: $(hostname)</h1></body></html>" > /var/www/html/index.html
    EOF
      tags = {
    Name = "ec2"
    Owner = "jduchnowski" 
    Project = "2023_internship_gda"
  }
}

resource "aws_ami_from_instance" "template_ami" {
    depends_on = [ aws_instance.template_ec2 ]
    name = "template_ami2"
    source_instance_id = aws_instance.template_ec2.id

  tags = {
    Name = "template_ami"
    Owner = "jduchnowski" 
    Project = "2023_internship_gda"
  }
}


resource "aws_launch_configuration" "terramino" {
  name_prefix     = "learn-terraform-aws-asg-"
  image_id        = aws_ami_from_instance.template_ami.id
  instance_type   = aws_instance.template_ec2.instance_type
  user_data = aws_instance.template_ec2.user_data
  security_groups = [ aws_security_group.sg.id ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "terramino" {
  name                 = "terramino"
  min_size             = 1
  max_size             = 3
  desired_capacity     = 3
  launch_configuration = aws_launch_configuration.terramino.name
  vpc_zone_identifier = [aws_subnet.public_eu_west_1a.id, aws_subnet.public_eu_west_1b.id]

  tag {
    key                 = "Name"
    value               = "HashiCorp Learn ASG - Terramino"
    propagate_at_launch = true
  }
}

resource "aws_lb" "terramino" {
  name               = "learn-asg-terramino-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.sg.id]
  subnets            = [aws_subnet.public_eu_west_1a.id, aws_subnet.public_eu_west_1b.id]
}

resource "aws_lb_listener" "terramino" {
  load_balancer_arn = aws_lb.terramino.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terramino.arn
  }
}

resource "aws_lb_target_group" "terramino" {
  name     = "learn-asg-terramino"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.app_vpc.id

}


resource "aws_autoscaling_attachment" "terramino" {
  autoscaling_group_name = aws_autoscaling_group.terramino.id
  lb_target_group_arn   = aws_lb_target_group.terramino.arn
}
