# Variables for the EKS module

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster and nodes will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS control plane and worker nodes"
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  type        = string
}

variable "node_role_arn" {
  description = "ARN of the IAM role for the EKS worker nodes"
  type        = string
}

variable "cluster_sg_id" {
  description = "ID of the security group for the EKS cluster control plane"
  type        = string
}

variable "node_sg_id" {
  description = "ID of the security group for the EKS worker nodes"
  type        = string
}

variable "kubernetes_version" {
  description = "Desired Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.28" # Specify a recent, supported version
}

variable "node_count" {
  description = "Desired number of nodes in the default worker node group"
  type        = number
  default     = 2
}

variable "node_instance_type" {
  description = "EC2 instance type for the worker nodes"
  type        = string
  default     = "t3.medium" # Choose an appropriate default
}

variable "node_disk_size" {
  description = "Disk size in GiB for worker nodes"
  type        = number
  default     = 20
}

variable "bottlerocket_ami_id" {
  description = "Optional: Specific Bottlerocket AMI ID. If null, uses the EKS-optimized Bottlerocket AMI."
  type        = string
  default     = null # Let EKS manage the default Bottlerocket AMI
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}

# Variables for specific node groups (blue/green, ingress, infra)
variable "blue_node_group_config" {
  description = "Configuration for the Blue node group"
  type = object({
    name          = optional(string, "blue-nodes")
    instance_type = optional(string, "t3.medium")
    desired_size  = optional(number, 2)
    min_size      = optional(number, 1)
    max_size      = optional(number, 3)
    disk_size     = optional(number, 20)
    labels        = optional(map(string), { "color" = "blue" }) # Default blue label
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  })
  default = {} # Allow full override
}

variable "green_node_group_config" {
  description = "Configuration for the Green node group"
  type = object({
    name          = optional(string, "green-nodes")
    instance_type = optional(string, "t3.medium")
    desired_size  = optional(number, 2)
    min_size      = optional(number, 1)
    max_size      = optional(number, 3)
    disk_size     = optional(number, 20)
    labels        = optional(map(string), { "color" = "green" }) # Default green label
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  })
  default = {} # Allow full override
}

variable "ingress_node_group_config" {
  description = "Configuration for the ingress node group"
  type = object({
    create        = optional(bool, true) # Control creation of this group
    name          = optional(string, "ingress-nodes")
    instance_type = optional(string, "t3.medium") # Potentially different type
    desired_size  = optional(number, 2)
    min_size      = optional(number, 1)
    max_size      = optional(number, 3)
    disk_size     = optional(number, 20)
    labels        = optional(map(string), { "node-role.kubernetes.io/ingress" = "true" }) # Default label
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
      # Example: key = "ingress-only", value = "true", effect = "NO_SCHEDULE"
    })), [])
  })
  default = {}
}

variable "infra_node_group_config" {
  description = "Configuration for the infrastructure node group (e.g., for cluster autoscaler, metrics)"
  type = object({
    create        = optional(bool, true) # Control creation of this group
    name          = optional(string, "infra-nodes")
    instance_type = optional(string, "t3.small") # Potentially smaller type
    desired_size  = optional(number, 1)
    min_size      = optional(number, 1)
    max_size      = optional(number, 2)
    disk_size     = optional(number, 20)
    labels        = optional(map(string), { "node-role.kubernetes.io/infra" = "true" }) # Default label
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
      # Example: key = "infra-only", value = "true", effect = "NO_SCHEDULE"
    })), [])
  })
  default = {}
}

# Add other variables as needed: cluster endpoint access, logging types, encryption config, etc.
