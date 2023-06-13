output "ec2_instance_id" {
  value = aws_instance.template_ec2.id
}

output "load_balancer_dns_name" {
  value = aws_lb.terramino.dns_name
}