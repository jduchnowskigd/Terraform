resource "aws_s3_bucket" "terraform_state" {
  bucket = "jdgd-terraform-state"  # Replace with your desired bucket name
  acl    = "private"
  #force_destroy = true
  versioning {
    enabled = true
  }

  tags = {
    Name = "Terraform Remote State"
  }
}