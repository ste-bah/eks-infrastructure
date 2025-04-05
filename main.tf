# Root module to orchestrate the deployment of EKS infrastructure

# Call the VPC module
module "vpc" {
  source = "./modules/vpc"

  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  # Add other required variables for the VPC module here
}

# Call the Transit Gateway module (depends on VPC)
module "transit_gateway" {
  source = "./modules/transit-gateway"
  # Assuming TGW is deployed in the network account, adjust provider if needed
  # provider = aws.network 

  vpc_id = module.vpc.vpc_id
  # Add other required variables for the TGW module here
}

# Call the Security module (depends on VPC)
module "security" {
  source = "./modules/security"

  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  # Add other required variables for the Security module here
}

# Call the EKS module (depends on VPC and Security)
module "eks" {
  source = "./modules/eks"

  cluster_name      = var.cluster_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids # Assuming the VPC module outputs this
  cluster_sg_id     = module.security.cluster_sg_id # Assuming the Security module outputs this
  node_sg_id        = module.security.node_sg_id    # Assuming the Security module outputs this
  cluster_role_arn  = module.security.cluster_role_arn # Assuming the Security module outputs this
  node_role_arn     = module.security.node_role_arn    # Assuming the Security module outputs this
  node_count        = var.node_count
  # Add other required variables for the EKS module here
}

# Call the Logging module (depends on EKS)
module "logging" {
  source = "./modules/logging"
  # Assuming logging resources might be in a central logging account, adjust provider if needed
  # provider = aws.logging

  cluster_name = module.eks.cluster_name
  environment  = var.environment
  # Add other required variables for the Logging module here
}

# Note: Dependencies between modules are implicitly handled by Terraform based on the 
# references between module inputs and outputs (e.g., module.eks depends on module.vpc 
# because it uses module.vpc.vpc_id). Explicit 'depends_on' is generally not required.
