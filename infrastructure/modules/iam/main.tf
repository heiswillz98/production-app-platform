# IAM Role for EC2 Instance
resource "aws_iam_role" "ec2_role" {
  name = var.role_name
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = var.role_name
  }
}

# Attach managed policies to the role
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Attach additional policies if provided
resource "aws_iam_role_policy_attachment" "additional_policies" {
  for_each = toset(var.role_policy_arns)
  role       = aws_iam_role.ec2_role.name
  policy_arn = each.value
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "main" {
  name = var.instance_profile_name
  role = aws_iam_role.ec2_role.name
}
