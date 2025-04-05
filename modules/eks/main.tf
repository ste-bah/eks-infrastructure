# Main configuration for the EKS module

locals {
  # Combine default tags with environment-specific tags
  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = "EKS-Infrastructure"
    ManagedBy   = "Terraform"
  })

  # Merge provided node group configs with defaults
  worker_ng_config = merge({
    name          = "worker-nodes"
    instance_type = var.node_instance_type # Default to global var if not set in object
    desired_size  = var.node_count         # Default to global var if not set in object
    min_size      = 1
    max_size      = max(2, var.node_count + 1) # Simple default max
    disk_size     = var.node_disk_size       # Default to global var if not set in object
    labels        = {}
    taints        = []
    }, var.worker_node_group_config # Provided config overrides defaults
  )

  ingress_ng_config = merge({
    create        = true
    name          = "ingress-nodes"
    instance_type = "t3.medium"
    desired_size  = 2
    min_size      = 1
    max_size      = 3
    disk_size     = 20
    labels        = { "node-role.kubernetes.io/ingress" = "true" }
    taints        = []
    }, var.ingress_node_group_config # Provided config overrides defaults
  )

  infra_ng_config = merge({
    create        = true
    name          = "infra-nodes"
    instance_type = "t3.small"
    desired_size  = 1
    min_size      = 1
    max_size      = 2
    disk_size     = 20
    labels        = { "node-role.kubernetes.io/infra" = "true" }
    taints        = []
    }, var.infra_node_group_config # Provided config overrides defaults
  )
}

# --- EKS Cluster ---
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [var.cluster_sg_id] # Control plane security group
    endpoint_private_access = true                # Private cluster as per plan
    endpoint_public_access  = false               # No public access
    public_access_cidrs     = []
  }

  # Enable control plane logs as specified in the plan (via logging module details)
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = merge(local.common_tags, {
    Name = var.cluster_name
  })

  depends_on = [
    # Ensure roles and SGs exist before creating cluster
    # Note: Terraform should detect this via ARN/ID references, but explicit dependency can be clearer
    # aws_iam_role.cluster (dependency via role_arn)
    # aws_security_group.cluster (dependency via security_group_ids)
  ]
}

# --- IAM OIDC Provider for IRSA ---
# Required for IAM Roles for Service Accounts
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  # Create only if the cluster's OIDC issuer URL is available
  count = aws_eks_cluster.main.identity[0].oidc[0].issuer != null ? 1 : 0

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [] # AWS Provider >= 4.0 automatically discovers thumbprint
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-oidc-provider"
  })
}


# --- EKS Node Groups ---

# Worker Node Group (Default/General Purpose)
resource "aws_eks_node_group" "worker" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = local.worker_ng_config.name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  ami_type       = "BOTTLEROCKET_x86_64" # As per plan
  capacity_type  = "ON_DEMAND"           # Or SPOT
  disk_size      = local.worker_ng_config.disk_size
  instance_types = [local.worker_ng_config.instance_type]
  release_version = null # Let EKS manage the Bottlerocket version based on K8s version

  scaling_config {
    desired_size = local.worker_ng_config.desired_size
    min_size     = local.worker_ng_config.min_size
    max_size     = local.worker_ng_config.max_size
  }

  update_config {
    max_unavailable_percentage = 33 # Example update strategy
  }

  labels = merge(local.common_tags, local.worker_ng_config.labels)

  dynamic "taint" {
    for_each = local.worker_ng_config.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  vpc_security_group_ids = [var.node_sg_id] # Attach the node security group

  tags = merge(local.common_tags, {
    Name                                = "${var.cluster_name}-${local.worker_ng_config.name}"
    "eks:nodegroup-name"                = local.worker_ng_config.name # EKS specific tag
    "k8s.io/cluster-autoscaler/enabled" = "true"                    # Example tag for cluster autoscaler
    # Add other relevant tags
  })

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_eks_cluster.main]
}

# Ingress Node Group
resource "aws_eks_node_group" "ingress" {
  count = local.ingress_ng_config.create ? 1 : 0

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = local.ingress_ng_config.name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  ami_type       = "BOTTLEROCKET_x86_64"
  capacity_type  = "ON_DEMAND"
  disk_size      = local.ingress_ng_config.disk_size
  instance_types = [local.ingress_ng_config.instance_type]
  release_version = null

  scaling_config {
    desired_size = local.ingress_ng_config.desired_size
    min_size     = local.ingress_ng_config.min_size
    max_size     = local.ingress_ng_config.max_size
  }

  update_config {
    max_unavailable_percentage = 33
  }

  labels = merge(local.common_tags, local.ingress_ng_config.labels)

  dynamic "taint" {
    for_each = local.ingress_ng_config.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  vpc_security_group_ids = [var.node_sg_id]

  tags = merge(local.common_tags, {
    Name                                = "${var.cluster_name}-${local.ingress_ng_config.name}"
    "eks:nodegroup-name"                = local.ingress_ng_config.name
    "k8s.io/cluster-autoscaler/enabled" = "true"
  })

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_eks_cluster.main]
}

# Infrastructure Node Group
resource "aws_eks_node_group" "infra" {
  count = local.infra_ng_config.create ? 1 : 0

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = local.infra_ng_config.name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  ami_type       = "BOTTLEROCKET_x86_64"
  capacity_type  = "ON_DEMAND"
  disk_size      = local.infra_ng_config.disk_size
  instance_types = [local.infra_ng_config.instance_type]
  release_version = null

  scaling_config {
    desired_size = local.infra_ng_config.desired_size
    min_size     = local.infra_ng_config.min_size
    max_size     = local.infra_ng_config.max_size
  }

  update_config {
    max_unavailable_percentage = 33
  }

  labels = merge(local.common_tags, local.infra_ng_config.labels)

  dynamic "taint" {
    for_each = local.infra_ng_config.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  vpc_security_group_ids = [var.node_sg_id]

  tags = merge(local.common_tags, {
    Name                                = "${var.cluster_name}-${local.infra_ng_config.name}"
    "eks:nodegroup-name"                = local.infra_ng_config.name
    "k8s.io/cluster-autoscaler/enabled" = "true"
  })

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_eks_cluster.main]
}
