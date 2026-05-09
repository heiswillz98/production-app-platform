# SSM Document for EC2 provisioning
resource "aws_ssm_document" "provision" {
  name          = var.document_name
  document_type = "Command"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Provision EC2 instance for DevOps assessment"
    parameters = {
      commands = {
        type        = "StringList"
        description = "Commands to run"
        default     = []
      }
      workingDirectory = {
        type        = "String"
        description = "Working directory"
        default     = "/opt"
      }
      executionTimeout = {
        type        = "String"
        description = "Execution timeout in seconds"
        default     = "3600"
      }
    }
    mainSteps = [
      {
        action = "aws:runShellScript"
        name   = "provisionInstance"
        inputs = {
          runCommand = var.provision_script
          workingDirectory = "{{ workingDirectory }}"
          timeoutSeconds = "{{ executionTimeout }}"
        }
      }
    ]
  })
}

# Execute SSM document on instance
resource "aws_ssm_association" "provision" {
  name = aws_ssm_document.provision.name
  targets {
    key    = "InstanceIds"
    values = [var.instance_id]
  }

  parameters = {
    commands = var.provision_script
  }
}
