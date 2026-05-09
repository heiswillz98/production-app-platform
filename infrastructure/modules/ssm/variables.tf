variable "document_name" {
  description = "Name of the SSM document"
  type        = string
}

variable "instance_id" {
  description = "ID of the EC2 instance to provision"
  type        = string
}

variable "provision_script" {
  description = "Provisioning script content"
  type        = string
}
