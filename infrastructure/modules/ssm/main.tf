# SSM Document for EC2 provisioning
resource "aws_ssm_document" "provision" {
  name          = var.document_name
  document_type = "Command"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Provision Script"
    mainSteps = [{
      action = "aws:runShellScript"
      name   = "runShellScript"
      inputs = {
        runCommand = split("\n", var.provision_script)
      }
    }]
  })
}

# Execute SSM document on instance
resource "aws_ssm_association" "provision" {
  name = aws_ssm_document.provision.name

  targets {
    key    = "InstanceIds"
    values = [var.instance_id]
  }

  # Wait for instance to be ready
  depends_on = [var.instance_id]
}
