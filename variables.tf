variable "environment" {
  description = "The deployment environment (e.g., dev, pre-prod, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "cluster_name" {
  description = "The name for the EKS cluster"
  type        = string
}

variable "node_count" {
  description = "The desired number of worker nodes"
  type        = number
  default     = 2 # Default value, can be overridden in tfvars
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

# Add other global variables as needed
