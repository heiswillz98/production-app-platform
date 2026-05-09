terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Get the latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"
  
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  availability_zone  = var.availability_zone
  vpc_name           = "${var.project_name}-prod-vpc"
  subnet_name        = "${var.project_name}-prod-subnet"
  igw_name           = "${var.project_name}-prod-igw"
  route_table_name   = "${var.project_name}-prod-rt"
}

# IAM Module
module "iam" {
  source = "../../modules/iam"
  
  role_name               = "${var.project_name}-prod-ec2-role"
  instance_profile_name   = "${var.project_name}-prod-instance-profile"
  role_policy_arns        = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
}

# EC2 Module
module "ec2" {
  source = "../../modules/ec2"
  
  ami_id                  = data.aws_ami.ubuntu.id
  instance_type           = var.instance_type
  subnet_id               = module.vpc.public_subnet_id
  security_group_id       = module.vpc.security_group_id
  key_name                = var.key_name
  instance_name           = "${var.project_name}-prod-instance"
  iam_instance_profile    = module.iam.instance_profile_name
}

# EIP for EC2 instance
resource "aws_eip" "main" {
  domain = "vpc"
  tags = {
    Name = "${var.project_name}-prod-eip"
  }
}

resource "aws_eip_association" "main" {
  instance_id   = module.ec2.app_instance_id
  allocation_id = aws_eip.main.id
}

# ECR Module
module "ecr" {
  source = "../../modules/ecr"
  
  repository_name = "${var.project_name}-prod-repository"
}

# SSM Module
module "ssm" {
  source = "../../modules/ssm"
  
  document_name     = "${var.project_name}-prod-provision"
  instance_id       = module.ec2.app_instance_id
  provision_script  = file("${path.module}/scripts/provision_script.sh")
}

# SSM Parameter Store for application configuration
resource "aws_ssm_parameter" "app_port" {
  name  = "/${var.project_name}/prod/app/port"
  type  = "String"
  value = "3000"
  description = "Application port"
}

resource "aws_ssm_parameter" "app_environment" {
  name  = "/${var.project_name}/prod/app/environment"
  type  = "String"
  value = "production"
  description = "Application environment"
}

resource "aws_ssm_parameter" "log_level" {
  name  = "/${var.project_name}/prod/app/log_level"
  type  = "String"
  value = "warn"
  description = "Application log level"
}
