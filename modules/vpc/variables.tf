# Variables for the VPC module

variable "environment" {
  description = "The deployment environment name (e.g., dev, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "The main CIDR block for the VPC"
  type        = string
}

variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
  default     = "us-east-1" # Default, but should ideally be passed from root
}

variable "availability_zones" {
  description = "A list of Availability Zones to use for subnets"
  type        = list(string)
  # Example default, consider making this required or dynamically fetched
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"] 
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets (for EKS nodes, etc.)"
  type        = list(string)
  # Example defaults, adjust based on vpc_cidr and AZ count
  default     = ["10.x.1.0/24", "10.x.2.0/24", "10.x.3.0/24"] 
}

variable "intra_subnet_cidrs" {
  description = "List of CIDR blocks for intra subnets (for internal traffic, TGW attachments)"
  type        = list(string)
  # Example defaults, adjust based on vpc_cidr and AZ count
  default     = ["10.x.101.0/24", "10.x.102.0/24", "10.x.103.0/24"]
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}

# Add other variables as needed, e.g., for NAT Gateway configuration, VPC endpoints, etc.
