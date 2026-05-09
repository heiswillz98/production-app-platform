variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "instance_profile_name" {
  description = "Name of the IAM instance profile"
  type        = string
}

variable "role_policy_arns" {
  description = "List of additional policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}
