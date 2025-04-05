# Main configuration for the Logging module

locals {
  # Combine default tags with environment-specific tags
  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = "EKS-Infrastructure"
    ManagedBy   = "Terraform"
  })

  # Define log group names based on the plan's structure
  application_log_group_name = "/aws/containerinsights/${var.cluster_name}/application"
  dataplane_log_group_name   = "/aws/containerinsights/${var.cluster_name}/dataplane"
  host_log_group_name        = "/aws/containerinsights/${var.cluster_name}/host"
}

# --- CloudWatch Log Groups for Container Insights ---

# Log group for application logs (from pods via Fluent Bit/Fluentd)
resource "aws_cloudwatch_log_group" "application" {
  name              = local.application_log_group_name
  retention_in_days = var.log_retention_in_days
  # kms_key_id = var.log_kms_key_arn # Optional: Add KMS key ARN if encryption is required

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-application-logs"
  })
}

# Log group for dataplane logs (EKS managed components)
resource "aws_cloudwatch_log_group" "dataplane" {
  name              = local.dataplane_log_group_name
  retention_in_days = var.log_retention_in_days
  # kms_key_id = var.log_kms_key_arn

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-dataplane-logs"
  })
}

# Log group for host logs (from nodes via Fluent Bit/Fluentd)
resource "aws_cloudwatch_log_group" "host" {
  name              = local.host_log_group_name
  retention_in_days = var.log_retention_in_days
  # kms_key_id = var.log_kms_key_arn

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-host-logs"
  })
}

# --- Kinesis Stream for Splunk/Cribl Integration ---

resource "aws_kinesis_stream" "splunk_stream" {
  count = var.enable_splunk_integration ? 1 : 0

  name             = "${var.cluster_name}-splunk-kinesis-stream"
  shard_count      = var.splunk_kinesis_stream_shard_count
  retention_period = var.splunk_kinesis_stream_retention_hours

  # stream_mode_details { # Optional: Use provisioned or on-demand mode
  #   stream_mode = "PROVISIONED" # or "ON_DEMAND"
  # }

  # encryption_type = "KMS" # Optional: Enable KMS encryption
  # kms_key_id      = var.kinesis_kms_key_arn 

  tags = merge(local.common_tags, {
    Name        = "${var.cluster_name}-splunk-kinesis-stream"
    Integration = "Splunk" # Or Cribl
  })
}

# Note: This module sets up the AWS-side resources (Log Groups, optional Kinesis Stream).
# The actual configuration of Fluent Bit/Fluentd DaemonSet within the EKS cluster to *send* logs 
# to these destinations is typically handled via Kubernetes manifests or Helm charts, 
# potentially applied after the cluster is up.
# Similarly, configuring Cribl or Splunk to consume from the Kinesis stream is outside this module's scope.
