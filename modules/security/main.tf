# Main configuration for the Security module (IAM Roles and Security Groups)

locals {
  # Combine default tags with environment-specific tags
  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = "EKS-Infrastructure"
    ManagedBy   = "Terraform"
  })

  # Extract OIDC provider endpoint host for assume role policy condition
  oidc_provider_host = var.oidc_provider_url != null ? replace(var.oidc_provider_url, "https://", "") : ""
}

# --- IAM Roles ---

# EKS Cluster IAM Role
resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-cluster-role"
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# EKS Node IAM Role
resource "aws_iam_role" "node" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-node-role"
  })
}

resource "aws_iam_instance_profile" "node" {
  name = "${var.cluster_name}-node-profile"
  role = aws_iam_role.node.name

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-node-profile"
  })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

# Add other policy attachments if needed (e.g., SSM, CloudWatch Agent)

# --- Security Groups ---

# EKS Cluster Security Group
# Controls traffic between the control plane and worker nodes.
resource "aws_security_group" "cluster" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "EKS cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-cluster-sg"
    # Add EKS specific tag if required by cluster creation process
    # "kubernetes.io/cluster/${var.cluster_name}" = "owned" 
  })
}

# EKS Node Security Group
# Controls traffic for worker nodes.
resource "aws_security_group" "node" {
  name        = "${var.cluster_name}-node-sg"
  description = "EKS worker node security group"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-node-sg"
  })
}

# --- Security Group Rules ---

# Cluster SG Rules:
# Allow inbound traffic from Node SG on specific ports (HTTPS for API, kubelet API)
resource "aws_security_group_rule" "cluster_ingress_node_https" {
  type                     = "ingress"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.node.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  description              = "Allow worker nodes to communicate with the API server"
}

resource "aws_security_group_rule" "cluster_ingress_node_kubelet" {
  type                     = "ingress"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.node.id
  from_port                = 10250 # Kubelet API
  to_port                  = 10250
  protocol                 = "tcp"
  description              = "Allow control plane to communicate with kubelet"
}

# Allow all outbound traffic from Cluster SG (Control Plane)
resource "aws_security_group_rule" "cluster_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.cluster.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # All protocols
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic from control plane"
}


# Node SG Rules:
# Allow inbound traffic from Cluster SG (for API server responses, kubelet communication)
resource "aws_security_group_rule" "node_ingress_cluster_ephemeral" {
  type                     = "ingress"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.cluster.id
  from_port                = 1025 # Ephemeral ports start range
  to_port                  = 65535 # Ephemeral ports end range
  protocol                 = "tcp"
  description              = "Allow control plane to communicate back to nodes"
}

# Allow inbound traffic from Node SG itself (for pod-to-pod communication)
resource "aws_security_group_rule" "node_ingress_self" {
  type              = "ingress"
  security_group_id = aws_security_group.node.id
  self              = true
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # All protocols
  description       = "Allow nodes to communicate with each other"
}

# Allow all outbound traffic from Node SG
resource "aws_security_group_rule" "node_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.node.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # All protocols
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic from nodes"
}

# Optional: Allow SSH from specific bastion/management network if needed (Not recommended for Bottlerocket)
# resource "aws_security_group_rule" "node_ingress_ssh" {
#   type              = "ingress"
#   security_group_id = aws_security_group.node.id
#   from_port         = 22
#   to_port           = 22
#   protocol          = "tcp"
#   cidr_blocks       = ["YOUR_MGMT_CIDR"] 
#   description       = "Allow SSH access from management network"
# }

# Note: The plan mentions specific ingress/infra nodes. This might require additional SGs or rules
# later, potentially managed by Kubernetes NetworkPolicies or specific SG attachments to those node groups.
# This setup provides the basic Cluster/Node SG interaction.
