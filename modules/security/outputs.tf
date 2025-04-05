# Outputs for the Security module

output "cluster_role_arn" {
  description = "ARN of the EKS Cluster IAM Role"
  value       = aws_iam_role.cluster.arn
}

output "node_role_arn" {
  description = "ARN of the EKS Node IAM Role"
  value       = aws_iam_role.node.arn
}

output "node_instance_profile_arn" {
  description = "ARN of the EKS Node Instance Profile"
  value       = aws_iam_instance_profile.node.arn
}

output "cluster_sg_id" {
  description = "ID of the EKS Cluster Security Group"
  value       = aws_security_group.cluster.id
}

output "node_sg_id" {
  description = "ID of the EKS Node Security Group"
  value       = aws_security_group.node.id
}
