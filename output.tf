output "load_balancer_ip" {
  value = aws_lb.my_app_eg1.dns_name
  }