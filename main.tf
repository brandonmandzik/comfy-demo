# # TODO
# terraform {
#   required_version = ">= 1.0"
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
# }

# # TODO
# provider "aws" {
#   region = var.aws_region
# }

# Use default VPC for simplicity
data "aws_vpc" "default" {
  default = true
}

# Look up the latest Deep Learning Base AMI for eu-central-1
# Using Ubuntu 22.04 with Single CUDA for GPU workloads (ComfyUI)
data "aws_ami" "dlami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Deep Learning Base AMI with Single CUDA (Ubuntu 22.04)*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Security group for ComfyUI and SSH access
resource "aws_security_group" "comfyui" {
  name        = "comfyui-sg"
  description = "Allow ComfyUI and SSH access"
  vpc_id      = data.aws_vpc.default.id

  # ComfyUI web interface
  ingress {
    from_port   = 8188
    to_port     = 8188
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ComfyUI web interface"
  }

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name = local._name_tag
  }
}

# EC2 instance for ComfyUI
resource "aws_instance" "comfyui" {
  ami           = data.aws_ami.dlami.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.comfyui.id]
  # key_name               = var.key_name

  # Root volume - ephemeral storage only
  root_block_device {
    volume_size           = 100
    volume_type           = "gp3"
    delete_on_termination = true
  }

  # Bootstrap script to install ComfyUI
  user_data = file("${path.module}/bootstrap.sh")

  tags = {
    Name = local._name_tag
  }
}
