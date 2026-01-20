# variable "aws_region" {
#   description = "AWS region for deployment"
#   type        = string
#   default     = "us-east-1"
# }

variable "instance_type" {
  description = "EC2 instance type with GPU"
  type        = string
  default     = "g6e.2xlarge"
}

variable "key_name" {
  description = "SSH key pair name for instance access (optional)"
  type        = string
  default     = null
}
