# Main configuration for the Transit Gateway attachment module

locals {
  # Combine default tags with environment-specific tags
  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = "EKS-Infrastructure"
    ManagedBy   = "Terraform"
  })
}

# --- Transit Gateway VPC Attachment ---
# Attaches the VPC provided via var.vpc_id to the specified Transit Gateway.
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attachment" {
  # Check if a TGW ID is provided. If not, this resource shouldn't be created by this module.
  # A data source or another mechanism should provide the TGW ID from the network account.
  count = var.transit_gateway_id != null ? 1 : 0

  transit_gateway_id = var.transit_gateway_id
  vpc_id             = var.vpc_id
  subnet_ids         = var.vpc_subnet_ids # Use the 'intra' subnets designated for TGW

  # Options for DNS and IPv6 support can be added if needed
  # transit_gateway_default_route_table_association = false # Often set to false for explicit control
  # transit_gateway_default_route_table_propagation = false # Often set to false for explicit control

  tags = merge(local.common_tags, {
    Name = "${var.environment}-vpc-tgw-attachment"
  })
}

# --- TGW Route Table Association ---
# Associate the VPC attachment with a specific TGW route table (e.g., a per-environment or shared table).
resource "aws_ec2_transit_gateway_route_table_association" "vpc_association" {
  # Only associate if a specific TGW route table ID is provided
  count = var.transit_gateway_id != null && var.transit_gateway_route_table_id != null ? 1 : 0

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_attachment[0].id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}

# --- VPC Route Table Updates ---
# Add routes in the VPC's route tables (e.g., private, intra) to direct traffic 
# destined for other networks (var.destination_cidrs_via_tgw) towards the TGW.
resource "aws_route" "to_tgw" {
  # Create a route for each destination CIDR in each specified VPC route table
  count = var.transit_gateway_id != null ? length(var.vpc_route_table_ids) * length(var.destination_cidrs_via_tgw) : 0

  route_table_id         = element(var.vpc_route_table_ids, floor(count.index / length(var.destination_cidrs_via_tgw)))
  destination_cidr_block = element(var.destination_cidrs_via_tgw, count.index % length(var.destination_cidrs_via_tgw))
  transit_gateway_id     = var.transit_gateway_id

  # Ensure the TGW attachment is created before adding routes that depend on it
  depends_on = [aws_ec2_transit_gateway_vpc_attachment.vpc_attachment]
}

# Note: This module assumes the Transit Gateway itself exists and its ID is provided.
# In a multi-account setup (Phase 4), the TGW would likely be managed in a central network account,
# and its ID shared via SSM Parameter Store, data sources, or remote state.
# Route propagation from the VPC attachment to the TGW route table might also be needed, 
# configured either here or centrally on the TGW route table resource.
