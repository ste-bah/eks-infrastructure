# Variables for the Transit Gateway module

variable "environment" {
  description = "The deployment environment name (e.g., dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to attach to the Transit Gateway"
  type        = string
}

variable "vpc_subnet_ids" {
  description = "List of subnet IDs (typically the 'intra' subnets) in the VPC for TGW attachments"
  type        = list(string)
}

variable "transit_gateway_id" {
  description = "Optional: ID of an existing Transit Gateway to use. If null, a new one might be created (depending on implementation)."
  type        = string
  default     = null 
}

variable "transit_gateway_route_table_id" {
  description = "Optional: ID of the TGW route table to associate the VPC attachment with."
  type        = string
  default     = null 
}

variable "vpc_route_table_ids" {
  description = "List of VPC route table IDs (e.g., private, intra) where routes to the TGW should be added."
  type        = list(string)
}

variable "destination_cidrs_via_tgw" {
  description = "List of destination CIDR blocks reachable via the Transit Gateway (e.g., other VPCs, on-prem)"
  type        = list(string)
  default     = [] # Example: ["10.0.0.0/8", "172.16.0.0/12"]
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}

# Add other variables as needed, e.g., for TGW sharing (Resource Access Manager - RAM), specific route propagation/static routes.
