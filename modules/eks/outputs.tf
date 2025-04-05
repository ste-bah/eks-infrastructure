# Outputs for the EKS module

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS control plane Kubernetes API server"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true # Certificate data is sensitive
}

output "cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL for the EKS cluster"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if created"
  value       = one(aws_iam_openid_connect_provider.oidc_provider[*].arn)
}

output "blue_node_group_arn" {
  description = "ARN of the blue node group"
  value       = aws_eks_node_group.blue.arn
}

output "blue_node_group_name" {
  description = "Name of the blue node group"
  value       = aws_eks_node_group.blue.node_group_name
}

output "green_node_group_arn" {
  description = "ARN of the green node group"
  value       = aws_eks_node_group.green.arn
}

output "green_node_group_name" {
  description = "Name of the green node group"
  value       = aws_eks_node_group.green.node_group_name
}

output "ingress_node_group_arn" {
  description = "ARN of the ingress node group"
  value       = one(aws_eks_node_group.ingress[*].arn)
}

output "ingress_node_group_name" {
  description = "Name of the ingress node group"
  value       = one(aws_eks_node_group.ingress[*].node_group_name)
}

output "infra_node_group_arn" {
  description = "ARN of the infra node group"
  value       = one(aws_eks_node_group.infra[*].arn)
}

output "infra_node_group_name" {
  description = "Name of the infra node group"
  value       = one(aws_eks_node_group.infra[*].node_group_name)
}
