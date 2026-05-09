output "app_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "app_instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.main.public_ip
}

output "app_instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.main.private_ip
}
