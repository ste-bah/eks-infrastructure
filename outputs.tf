# Root module outputs

output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster's Kubernetes API server"
  value       = module.eks.cluster_endpoint
  # Sensitive might be true if the endpoint should not be displayed in logs,
  # but typically it's needed for kubectl configuration.
  # sensitive = true 
}

output "eks_cluster_name" {
  description = "The name of the deployed EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL for the EKS cluster"
  value       = module.eks.cluster_oidc_issuer_url
}

output "vpc_id" {
  description = "The ID of the VPC created for the environment"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs within the VPC"
  value       = module.vpc.private_subnet_ids
}

output "intra_subnet_ids" {
  description = "List of intra subnet IDs within the VPC"
  value       = module.vpc.intra_subnet_ids # Assuming VPC module outputs this
}

output "transit_gateway_id" {
  description = "The ID of the Transit Gateway"
  value       = module.transit_gateway.transit_gateway_id # Assuming TGW module outputs this
}

# Add other relevant outputs as modules are developed
