output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web_server.id
}

output "public_ip" {
  description = "Public IP of the instance"
  value       = aws_instance.web_server.public_ip
}

output "instance_state" {
  description = "Current state of the instance"
  value       = aws_instance.web_server.instance_state
}
