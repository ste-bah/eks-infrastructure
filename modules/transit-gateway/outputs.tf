# Outputs for the Transit Gateway module

output "transit_gateway_vpc_attachment_id" {
  description = "The ID of the Transit Gateway VPC attachment"
  # Return the ID only if the attachment was created (TGW ID was provided)
  value       = one(aws_ec2_transit_gateway_vpc_attachment.vpc_attachment[*].id)
}

# Output the provided TGW ID for reference, useful if the module didn't create it.
output "transit_gateway_id" {
  description = "The ID of the Transit Gateway used (either provided or created)"
  value       = var.transit_gateway_id 
}

# Add other outputs if needed, e.g., TGW route table association ID
output "transit_gateway_route_table_association_id" {
  description = "The ID of the TGW route table association"
  value       = one(aws_ec2_transit_gateway_route_table_association.vpc_association[*].id)
}
