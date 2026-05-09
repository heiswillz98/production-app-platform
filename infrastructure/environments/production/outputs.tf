output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.vpc.public_subnet_id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = module.vpc.security_group_id
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2.app_instance_id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.main.public_ip
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "iam_role_name" {
  description = "Name of the IAM role"
  value       = module.iam.role_name
}

output "ssm_document_name" {
  description = "Name of the SSM document"
  value       = module.ssm.document_name
}
