# Outputs for the Logging module

output "application_log_group_name" {
  description = "Name of the CloudWatch Log Group for application logs"
  value       = aws_cloudwatch_log_group.application.name
}

output "application_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for application logs"
  value       = aws_cloudwatch_log_group.application.arn
}

output "dataplane_log_group_name" {
  description = "Name of the CloudWatch Log Group for dataplane logs"
  value       = aws_cloudwatch_log_group.dataplane.name
}

output "dataplane_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for dataplane logs"
  value       = aws_cloudwatch_log_group.dataplane.arn
}

output "host_log_group_name" {
  description = "Name of the CloudWatch Log Group for host logs"
  value       = aws_cloudwatch_log_group.host.name
}

output "host_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for host logs"
  value       = aws_cloudwatch_log_group.host.arn
}

output "splunk_kinesis_stream_name" {
  description = "Name of the Kinesis stream for Splunk integration (if enabled)"
  value       = var.enable_splunk_integration ? one(aws_kinesis_stream.splunk_stream[*].name) : null
}

output "splunk_kinesis_stream_arn" {
  description = "ARN of the Kinesis stream for Splunk integration (if enabled)"
  value       = var.enable_splunk_integration ? one(aws_kinesis_stream.splunk_stream[*].arn) : null
}
