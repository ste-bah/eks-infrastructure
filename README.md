# Modular Terraform EKS Infrastructure

## Objective

This project provides a modular, scalable, and secure Terraform-based infrastructure for deploying Amazon EKS (Elastic Kubernetes Service) clusters. It is designed to align with best practices, including multi-VPC architecture, multi-environment support, and integration with AWS Organizations and Control Tower for governance.

## Architecture Overview

The core architecture consists of:

*   **Multiple VPCs:** Separate VPCs for different environments (e.g., dev, pre-prod, prod), potentially with a dedicated VPC for the EKS control plane or shared services depending on the final implementation.
*   **AWS Transit Gateway:** Used for centralized routing between VPCs, on-premises networks (via Direct Connect), and potentially shared service VPCs.
*   **Private EKS Clusters:** EKS control plane endpoints are kept private, enhancing security.
*   **Bottlerocket OS:** Worker nodes utilize the security-focused Bottlerocket OS.
*   **Modular Design:** Infrastructure components (VPC, TGW, EKS, Security, Logging) are encapsulated in reusable Terraform modules.
*   **Multi-Environment Support:** Configurations for different environments (dev, pre-prod, prod) are managed using `.tfvars` files.
*   **Centralized Logging:** Configuration for CloudWatch Logs (Container Insights) and integration points (Kinesis) for external systems like Splunk.
*   **Security:** Leverages IAM roles, security groups, and aims for integration with AWS Control Tower guardrails and Service Control Policies (SCPs).

## Prerequisites

Before using this Terraform code, ensure you have the following installed and configured:

*   **Terraform:** Version 1.0 or later (see `provider.tf` for specific constraints).
*   **AWS CLI:** Configured with appropriate credentials for accessing the target AWS account(s). For multi-account deployments (Phase 4), ensure profiles or roles are set up for cross-account access.
*   **Git:** For version control.
*   **(Optional) Visual Studio Code:** With the HashiCorp Terraform extension for linting, formatting, and syntax highlighting.

## Directory Structure

```
eks-infrastructure/
├── modules/              # Reusable Terraform modules
│   ├── vpc/             # VPC, Subnets, Route Tables
│   ├── transit-gateway/ # TGW Attachments, Routing
│   ├── eks/             # EKS Cluster, Node Groups (Bottlerocket)
│   ├── logging/         # CloudWatch Log Groups, Kinesis (for Splunk)
│   └── security/        # IAM Roles, Security Groups
├── environments/         # Environment-specific configurations
│   ├── dev/
│   │   └── terraform.tfvars
│   ├── pre-prod/
│   │   └── terraform.tfvars
│   └── prod/
│       └── terraform.tfvars
├── .gitignore            # Specifies intentionally untracked files
├── .terraform.lock.hcl   # Terraform provider lock file
├── main.tf               # Root module definition, orchestrates module calls
├── variables.tf          # Global input variables for the root module
├── outputs.tf            # Outputs exposed by the root module
├── provider.tf           # AWS provider configuration (including multi-account placeholders)
└── README.md             # This file
```

## Modules

*   **vpc:** Creates the VPC, private/intra subnets, and associated route tables.
*   **transit-gateway:** Manages the VPC attachment to the Transit Gateway and related routing within the VPC. Assumes TGW exists (likely in a network account).
*   **security:** Defines necessary IAM roles (EKS Cluster, EKS Node) and Security Groups for the cluster and nodes.
*   **eks:** Provisions the private EKS cluster control plane and managed node groups using Bottlerocket OS. Configures different node groups (worker, ingress, infra).
*   **logging:** Sets up CloudWatch Log Groups according to Container Insights naming conventions and optionally creates a Kinesis Data Stream for Splunk/Cribl integration.

*(Note: Detailed inputs, outputs, and resources for each module should ideally be documented within a `README.md` inside each module's directory).*

## Environments

Each subdirectory under `environments/` represents a deployment environment (e.g., `dev`, `pre-prod`, `prod`). The `terraform.tfvars` file within each directory contains environment-specific values that override the defaults defined in `variables.tf` or module variables.

## Usage / Deployment

1.  **Initialization:** Navigate to the `eks-infrastructure` directory and run:
    ```bash
    terraform init
    ```
    This downloads provider plugins and initializes modules.

2.  **Planning:** To preview the changes for a specific environment (e.g., dev):
    ```bash
    terraform plan -var-file="environments/dev/terraform.tfvars"
    ```

3.  **Applying:** To deploy the infrastructure for a specific environment (e.g., dev):
    ```bash
    terraform apply -var-file="environments/dev/terraform.tfvars"
    ```
    Review the plan and type `yes` to confirm.

4.  **Destroying:** To tear down the infrastructure for a specific environment:
    ```bash
    terraform destroy -var-file="environments/dev/terraform.tfvars"
    ```

## Inputs and Outputs

*   **Global Inputs:** Defined in `variables.tf`. These are expected to be provided via `.tfvars` files.
*   **Global Outputs:** Defined in `outputs.tf`. These expose key information about the deployed infrastructure (e.g., EKS cluster endpoint, VPC ID).
*   **Module Inputs/Outputs:** Each module defines its own inputs (`variables.tf`) and outputs (`outputs.tf`). Refer to the module's internal documentation (once created) for details.

## AWS Control Tower Integration (Phase 4)

The `provider.tf` file includes commented-out placeholders for configuring provider aliases. In a multi-account Control Tower setup, these aliases will be used to assume roles in different accounts (e.g., network, logging, workload accounts) to manage resources across the organization according to the landing zone design.

## Testing (Phase 5)

The project plan includes using Terratest for automated infrastructure testing. Test files would typically reside in a separate `test/` directory (not yet created).
