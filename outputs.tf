# Outputs for VPC S3 Endpoint Setup

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.myvpc1.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private_subnet.id
}

output "public_server_id" {
  description = "ID of the public EC2 instance"
  value       = aws_instance.public_server.id
}

output "public_server_public_ip" {
  description = "Public IP of the public EC2 instance"
  value       = aws_instance.public_server.public_ip
}

output "private_server_id" {
  description = "ID of the private EC2 instance"
  value       = aws_instance.private_server.id
}

output "private_server_private_ip" {
  description = "Private IP of the private EC2 instance"
  value       = aws_instance.private_server.private_ip
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.demo_bucket.id
}

output "vpc_endpoint_id" {
  description = "ID of the VPC Endpoint for S3"
  value       = aws_vpc_endpoint.s3_endpoint.id
}

output "ssh_to_public_server" {
  description = "SSH command to connect to public server"
  value       = "ssh -i ${var.key_name}.pem ec2-user@${aws_instance.public_server.public_ip}"
}

output "ssh_to_private_server_via_public" {
  description = "SSH command to connect to private server from public server"
  value       = "ssh -i ${var.key_name}.pem ec2-user@${aws_instance.private_server.private_ip}"
}
