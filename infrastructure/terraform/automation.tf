# Auto-scaling and Backup Automation

# EventBridge rule for scheduled instance start/stop (cost optimization)
resource "aws_cloudwatch_event_rule" "trading_hours_start" {
  count               = var.enable_scheduled_instances ? 1 : 0
  name                = "trading-hours-start-${var.environment}"
  description         = "Start trading instances at NY session open"
  schedule_expression = "cron(30 13 ? * MON-FRI *)"  # 8:30 AM ET (13:30 UTC)

  tags = local.common_tags
}

resource "aws_cloudwatch_event_rule" "trading_hours_end" {
  count               = var.enable_scheduled_instances ? 1 : 0
  name                = "trading-hours-end-${var.environment}"
  description         = "Stop trading instances after NY session close"
  schedule_expression = "cron(0 23 ? * MON-FRI *)"  # 6:00 PM ET (23:00 UTC)

  tags = local.common_tags
}

# Lambda function for instance management
resource "aws_iam_role" "instance_scheduler_lambda" {
  count = var.enable_scheduled_instances ? 1 : 0
  name  = "instance-scheduler-lambda-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "instance_scheduler_lambda" {
  count = var.enable_scheduled_instances ? 1 : 0
  role  = aws_iam_role.instance_scheduler_lambda[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# EBS Snapshot automation using AWS Backup
resource "aws_backup_vault" "trading_backup" {
  name = "ea-scalper-backup-vault-${var.environment}"

  tags = local.common_tags
}

resource "aws_backup_plan" "trading_backup" {
  name = "ea-scalper-backup-plan-${var.environment}"

  rule {
    rule_name         = "hourly_during_trading"
    target_vault_name = aws_backup_vault.trading_backup.name
    schedule          = "cron(0 14-22 ? * MON-FRI *)"  # Every hour during trading (9 AM - 5 PM ET)

    lifecycle {
      delete_after = 7
    }

    recovery_point_tags = local.common_tags
  }

  rule {
    rule_name         = "daily_snapshot"
    target_vault_name = aws_backup_vault.trading_backup.name
    schedule          = "cron(0 23 ? * * *)"  # Daily at 6 PM ET

    lifecycle {
      delete_after = 30
    }

    recovery_point_tags = local.common_tags
  }

  tags = local.common_tags
}

resource "aws_iam_role" "backup_role" {
  name = "backup-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "backup_policy" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_backup_selection" "trading_instances" {
  name         = "trading-instances-${var.environment}"
  plan_id      = aws_backup_plan.trading_backup.id
  iam_role_arn = aws_iam_role.backup_role.arn

  resources = [
    aws_instance.mt5_server.arn,
    aws_instance.python_server.arn
  ]
}

# AMI creation for disaster recovery
resource "aws_ami_from_instance" "mt5_golden_image" {
  count              = var.environment == "production" ? 1 : 0
  name               = "mt5-golden-image-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  source_instance_id = aws_instance.mt5_server.id
  snapshot_without_reboot = false

  tags = merge(local.common_tags, {
    Name = "mt5-golden-ami"
    Type = "disaster-recovery"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ami_from_instance" "python_golden_image" {
  count              = var.environment == "production" ? 1 : 0
  name               = "python-golden-image-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  source_instance_id = aws_instance.python_server.id
  snapshot_without_reboot = false

  tags = merge(local.common_tags, {
    Name = "python-golden-ami"
    Type = "disaster-recovery"
  })

  lifecycle {
    create_before_destroy = true
  }
}
