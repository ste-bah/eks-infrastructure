# Main configuration for the VPC module

locals {
  # Combine default tags with environment-specific tags
  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = "EKS-Infrastructure"
    ManagedBy   = "Terraform"
  })
}

# Create the Virtual Private Cloud (VPC)
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${var.environment}-vpc"
  })
}

# Create Private Subnets (for EKS worker nodes, internal services)
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index % length(var.availability_zones)) # Distribute across AZs

  tags = merge(local.common_tags, {
    Name                                      = "${var.environment}-private-subnet-${element(var.availability_zones, count.index % length(var.availability_zones))}"
    "kubernetes.io/cluster/${var.environment}-eks" = "shared" # Tag for EKS auto-discovery (adjust cluster name if needed)
    "kubernetes.io/role/internal-elb"         = "1"      # Tag for internal load balancers
  })
}

# Create Intra Subnets (potentially for TGW attachments, internal routing)
resource "aws_subnet" "intra" {
  count             = length(var.intra_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.intra_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index % length(var.availability_zones)) # Distribute across AZs

  tags = merge(local.common_tags, {
    Name = "${var.environment}-intra-subnet-${element(var.availability_zones, count.index % length(var.availability_zones))}"
    # Add specific tags if needed for TGW or other services
  })
}

# --- Routing ---
# Private Route Table (No direct internet access, routes via TGW/Endpoints/NAT GW)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.environment}-private-rt"
  })
  # Routes for TGW/Endpoints/NAT GW will be added here or by other modules
}

# Associate Private Subnets with the Private Route Table
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Intra Route Table (Routing depends on use case, e.g., TGW)
resource "aws_route_table" "intra" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.environment}-intra-rt"
  })
  # Routes for TGW will likely be added here or by the TGW module
}

# Associate Intra Subnets with the Intra Route Table
resource "aws_route_table_association" "intra" {
  count          = length(aws_subnet.intra)
  subnet_id      = aws_subnet.intra[count.index].id
  route_table_id = aws_route_table.intra.id
}

# --- NAT Gateway (Optional - Plan implies TGW/Endpoints for egress) ---
# If needed, add resources for Elastic IP and NAT Gateway, 
# and add a default route (0.0.0.0/0) to the private route table pointing to the NAT GW.

# --- VPC Endpoints (Recommended for private EKS) ---
# Consider adding VPC endpoints for services like ECR, S3, STS, CloudWatch Logs, etc.
# Example for ECR API endpoint:
# resource "aws_vpc_endpoint" "ecr_api" {
#   vpc_id            = aws_vpc.main.id
#   service_name      = "com.amazonaws.${var.aws_region}.ecr.api"
#   vpc_endpoint_type = "Interface"
#   subnet_ids        = aws_subnet.private[*].id # Place in private subnets
#   private_dns_enabled = true
#   security_group_ids = [aws_security_group.vpc_endpoint_sg.id] # Requires a security group
# 
#   tags = merge(local.common_tags, {
#     Name = "${var.environment}-ecr-api-vpce"
#   })
# }
# (Repeat for ecr.dkr, s3 (Gateway), sts, logs, etc.)
# Need to define aws_security_group.vpc_endpoint_sg as well.
