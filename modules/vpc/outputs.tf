# Outputs for the VPC module

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the created VPC"
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_ids" {
  description = "List of IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  description = "List of CIDR blocks of the private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "intra_subnet_ids" {
  description = "List of IDs of the intra subnets"
  value       = aws_subnet.intra[*].id
}

output "intra_subnet_cidrs" {
  description = "List of CIDR blocks of the intra subnets"
  value       = aws_subnet.intra[*].cidr_block
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = aws_route_table.private.id
}

output "intra_route_table_id" {
  description = "The ID of the intra route table"
  value       = aws_route_table.intra.id
}

# Add outputs for NAT Gateway IDs or VPC Endpoint IDs if they are implemented
