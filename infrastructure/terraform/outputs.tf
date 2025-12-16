# Outputs for infrastructure reference

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "mt5_server_id" {
  description = "MT5 server instance ID"
  value       = aws_instance.mt5_server.id
}

output "mt5_server_private_ip" {
  description = "MT5 server private IP"
  value       = aws_instance.mt5_server.private_ip
}

output "python_server_id" {
  description = "Python ML server instance ID"
  value       = aws_instance.python_server.id
}

output "python_server_private_ip" {
  description = "Python ML server private IP"
  value       = aws_instance.python_server.private_ip
}

output "s3_bucket_name" {
  description = "Trading data S3 bucket name"
  value       = aws_s3_bucket.trading_data.id
}

output "dynamodb_table_name" {
  description = "Trading state DynamoDB table name"
  value       = aws_dynamodb_table.trading_state.name
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = aws_sns_topic.trading_alerts.arn
}

output "cloudwatch_dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.trading_dashboard.dashboard_name}"
}

output "broker_api_secret_arn" {
  description = "Secrets Manager ARN for broker API key"
  value       = aws_secretsmanager_secret.broker_api_key.arn
  sensitive   = true
}

output "mt5_credentials_secret_arn" {
  description = "Secrets Manager ARN for MT5 credentials"
  value       = aws_secretsmanager_secret.mt5_credentials.arn
  sensitive   = true
}

output "backup_vault_name" {
  description = "AWS Backup vault name"
  value       = aws_backup_vault.trading_backup.name
}

output "kms_key_id" {
  description = "KMS key ID for data encryption"
  value       = aws_kms_key.trading_data.key_id
  sensitive   = true
}
