variable "aws_region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH key pair"
  default     = "my-key-pair1"
}

