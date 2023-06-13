//Tutaj wrzucamy wszystkie resources związane z compute

resource "aws_instance" "template_ec2" {
  ami                          = var.ami_id
  instance_type                = var.instance_type
  key_name                     = var.key_name
  security_groups              = [var.security_group_id]
  associate_public_ip_address  = true
  subnet_id                    = var.subnet_ids[0]
  user_data                    = var.user_data

  tags = {
    Name    = "ec2"
    Owner   = "jduchnowski"
    Project = "2023_internship_gda"
  }
}

resource "aws_ami_from_instance" "template_ami" {
  depends_on          = [aws_instance.template_ec2]
  name                = "template_ami2"
  source_instance_id  = aws_instance.template_ec2.id

  tags = {
    Name    = "template_ami"
    Owner   = "jduchnowski"
    Project = "2023_internship_gda"
  }
}

resource "aws_launch_configuration" "terramino" {
  name_prefix                = "learn-terraform-aws-asg-"
  image_id                   = aws_ami_from_instance.template_ami.id
  instance_type              = aws_instance.template_ec2.instance_type
  user_data                  = aws_instance.template_ec2.user_data
  security_groups            = [var.security_group_id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "terramino" {
  name                    = "terramino"
  min_size                = 1
  max_size                = 3
  desired_capacity        = 3
  launch_configuration    = aws_launch_configuration.terramino.name
  vpc_zone_identifier     = var.subnet_ids

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
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids
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