# VPC Endpoint for S3 - Complete Setup
# This creates a VPC with public and private subnets, EC2 instances, S3 bucket, and VPC endpoint

provider "aws" {
  region = var.aws_region
}

# 1. Create VPC
resource "aws_vpc" "myvpc1" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "myvpc1"
  }
}

# 2. Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.myvpc1.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "public-subnet"
  }
}

# 3. Create Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.myvpc1.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "private-subnet"
  }
}

# 4. Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc1.id

  tags = {
    Name = "myvpc1-igw"
  }
}

# 5. Create Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.myvpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# 6. Create Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.myvpc1.id

  tags = {
    Name = "private-route-table"
  }
}

# 7. Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 8. Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# 9. Create Security Group for Public EC2
resource "aws_security_group" "public_sg" {
  name        = "public-server-sg"
  description = "Security group for public EC2 instance"
  vpc_id      = aws_vpc.myvpc1.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-server-sg"
  }
}

# 10. Create Security Group for Private EC2
resource "aws_security_group" "private_sg" {
  name        = "private-server-sg"
  description = "Security group for private EC2 instance"
  vpc_id      = aws_vpc.myvpc1.id

  ingress {
    description     = "SSH from public subnet"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-server-sg"
  }
}

# 11. Create IAM Role for EC2 to access S3
resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "ec2-s3-access-role"
  }
}

# 12. Attach S3 Full Access Policy to Role
resource "aws_iam_role_policy_attachment" "s3_policy" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# 13. Create Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-s3-instance-profile"
  role = aws_iam_role.ec2_s3_role.name
}

# 14. Create Public EC2 Instance
resource "aws_instance" "public_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y aws-cli
              EOF

  tags = {
    Name = "public-server"
  }
}

# 15. Create Private EC2 Instance
resource "aws_instance" "private_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y aws-cli
              EOF

  tags = {
    Name = "private-server"
  }
}

# 16. Create S3 Bucket
resource "aws_s3_bucket" "demo_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name = "vpc-endpoint-demo-bucket"
  }
}

# 17. Upload sample file to S3
resource "aws_s3_object" "sample_file" {
  bucket  = aws_s3_bucket.demo_bucket.id
  key     = "sample-file.txt"
  content = "This is a sample file accessed via VPC Endpoint!"

  tags = {
    Name = "sample-file"
  }
}

# 18. Create VPC Endpoint for S3 (Gateway Endpoint)
resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id       = aws_vpc.myvpc1.id
  service_name = "com.amazonaws.${var.aws_region}.s3"

  route_table_ids = [
    aws_route_table.public_rt.id,
    aws_route_table.private_rt.id
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource  = "*"
      }
    ]
  })

  tags = {
    Name = "s3-vpc-endpoint"
  }
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}
