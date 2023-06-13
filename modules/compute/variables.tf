variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name for the EC2 instance"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EC2 instance and Load Balancer"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security Group ID for the EC2 instance and Load Balancer"
  type        = string
}

variable "user_data" {
  description = "User data script for the EC2 instance"
  type        = string
}
