variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "ami_id" {
  description = "AMI ID for EC2 (Amazon Linux 2023 in ap-south-1)"
  type        = string
  default     = "ami-0c2af51e265bd5e0e"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "AWS key pair name (must exist in your AWS account)"
  type        = string
}

variable "instance_name" {
  description = "Name tag for EC2 instance"
  type        = string
  default     = "Production-Web-Server"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}
