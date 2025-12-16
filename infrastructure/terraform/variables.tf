# Variables for EA_SCALPER_XAUUSD Infrastructure

variable "aws_region" {
  description = "AWS region for deployment (us-east-2 closest to Chicago)"
  type        = string
  default     = "us-east-2"
}

variable "environment" {
  description = "Environment name (production, staging, development)"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_scheduled_instances" {
  description = "Enable scheduled start/stop for cost optimization (NY session only)"
  type        = bool
  default     = false
}

variable "trading_hours_start" {
  description = "Trading hours start time (UTC, 8:30 AM ET = 13:30 UTC)"
  type        = string
  default     = "13:30"
}

variable "trading_hours_end" {
  description = "Trading hours end time (UTC, 5:00 PM ET = 22:00 UTC)"
  type        = string
  default     = "22:00"
}

variable "windows_instance_type" {
  description = "EC2 instance type for Windows MT5 server"
  type        = string
  default     = "c5.xlarge"
}

variable "linux_instance_type" {
  description = "EC2 instance type for Linux Python server"
  type        = string
  default     = "c7i.xlarge"
}

variable "enable_multi_az" {
  description = "Enable multi-AZ deployment for high availability"
  type        = bool
  default     = false
}

variable "snapshot_retention_days" {
  description = "Number of days to retain EBS snapshots"
  type        = number
  default     = 7
}

variable "enable_cross_region_backup" {
  description = "Enable cross-region backup to us-west-2"
  type        = bool
  default     = true
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to access instances via SSM (empty for SSM-only)"
  type        = list(string)
  default     = []
}

variable "alert_email" {
  description = "Email address for CloudWatch alerts"
  type        = string
}

variable "broker_api_endpoint" {
  description = "NinjaTrader/Apex API endpoint"
  type        = string
  sensitive   = true
}

variable "max_daily_drawdown_pct" {
  description = "Maximum daily drawdown percentage for alerts"
  type        = number
  default     = 2.5
}

variable "max_total_drawdown_pct" {
  description = "Maximum total drawdown percentage for circuit breaker"
  type        = number
  default     = 4.5
}
