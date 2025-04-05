terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Specify a suitable version constraint
    }
  }
  required_version = ">= 1.0" # Specify a suitable Terraform version constraint
}

provider "aws" {
  region = "us-east-1" # Default region, can be overridden by environment variables or tfvars
}

# Placeholder for multi-account provider configurations (Phase 4)
# provider "aws" {
#   alias  = "network"
#   region = "us-east-1"
#   assume_role {
#     role_arn = "arn:aws:iam::<network-account-id>:role/OrganizationAccountAccessRole"
#   }
# }

# provider "aws" {
#   alias  = "logging"
#   region = "us-east-1"
#   assume_role {
#     role_arn = "arn:aws:iam::<logging-account-id>:role/OrganizationAccountAccessRole"
#   }
# }

# provider "aws" {
#   alias  = "dev"
#   region = "us-east-1"
#   assume_role {
#     role_arn = "arn:aws:iam::<dev-account-id>:role/OrganizationAccountAccessRole"
#   }
# }

# provider "aws" {
#   alias  = "pre-prod"
#   region = "us-east-1"
#   assume_role {
#     role_arn = "arn:aws:iam::<pre-prod-account-id>:role/OrganizationAccountAccessRole"
#   }
# }

# provider "aws" {
#   alias  = "prod"
#   region = "us-east-1"
#   assume_role {
#     role_arn = "arn:aws:iam::<prod-account-id>:role/OrganizationAccountAccessRole"
#   }
# }
