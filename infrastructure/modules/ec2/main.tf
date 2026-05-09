# EC2 Instance
resource "aws_instance" "main" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile

  tags = {
    Name = var.instance_name
  }

  # Root volume
  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  # User data for basic setup
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    project_name = var.instance_name
  }))
}
