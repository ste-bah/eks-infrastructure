# Variables for the Logging module

variable "cluster_name" {
  description = "Name of the EKS cluster (used for log group naming)"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region where CloudWatch logs reside"
  type        = string
}

variable "log_retention_in_days" {
  description = "Number of days to retain logs in CloudWatch Log Groups"
  type        = number
  default     = 30 # Example retention period
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}

# Variables related to Splunk integration (Kinesis, potentially Cribl config)
variable "enable_splunk_integration" {
  description = "Flag to enable Kinesis stream creation for Splunk integration"
  type        = bool
  default     = false # Keep it optional/disabled by default
}

variable "splunk_kinesis_stream_shard_count" {
  description = "Number of shards for the Kinesis stream sending data to Splunk/Cribl"
  type        = number
  default     = 1
}

variable "splunk_kinesis_stream_retention_hours" {
  description = "Retention period in hours for the Kinesis stream"
  type        = number
  default     = 24
}

# Add other variables if needed, e.g., KMS key for log group encryption
