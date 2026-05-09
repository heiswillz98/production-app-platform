output "document_name" {
  description = "Name of the SSM document"
  value       = aws_ssm_document.provision.name
}

output "document_arn" {
  description = "ARN of the SSM document"
  value       = aws_ssm_document.provision.arn
}

output "association_id" {
  description = "ID of the SSM association"
  value       = aws_ssm_association.provision.id
}
