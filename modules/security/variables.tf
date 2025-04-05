# Variables for the Security module

variable "environment" {
  description = "The deployment environment name (e.g., dev, prod)"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster (used for tagging and policy conditions)"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where security groups will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC (used for security group rules)"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for the EKS cluster (needed for IAM Roles for Service Accounts - IRSA)"
  type        = string
  # This will likely come from the EKS module output or a data source once the cluster is created.
  # For initial setup, it might be null or require manual input/lookup.
  default     = null 
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider for the EKS cluster (needed for IAM Roles for Service Accounts - IRSA)"
  type        = string
  # Similar to the ARN, this comes from the EKS cluster.
  default     = null 
}

# Add other variables if needed, e.g., specific CIDRs allowed for ingress, KMS key ARNs for encryption policies.
