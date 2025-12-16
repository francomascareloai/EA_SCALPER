# CloudWatch Monitoring and Alerting

# SNS topic for alerts
resource "aws_sns_topic" "trading_alerts" {
  name = "ea-scalper-trading-alerts-${var.environment}"

  tags = merge(local.common_tags, {
    Name = "trading-alerts-topic"
  })
}

resource "aws_sns_topic_subscription" "trading_alerts_email" {
  topic_arn = aws_sns_topic.trading_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "mt5_server" {
  name              = "/ea-scalper/mt5-server/${var.environment}"
  retention_in_days = 7

  tags = merge(local.common_tags, {
    Name = "mt5-server-logs"
  })
}

resource "aws_cloudwatch_log_group" "python_server" {
  name              = "/ea-scalper/python-server/${var.environment}"
  retention_in_days = 7

  tags = merge(local.common_tags, {
    Name = "python-server-logs"
  })
}

# Trading-specific metric alarms

# 1. Daily Drawdown Alert
resource "aws_cloudwatch_metric_alarm" "daily_drawdown_warning" {
  alarm_name          = "daily-drawdown-warning-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DailyDrawdownPct"
  namespace           = "EA_SCALPER/Trading"
  period              = 300  # 5 minutes
  statistic           = "Maximum"
  threshold           = 1.5
  alarm_description   = "Daily drawdown exceeded 1.5% (warning level)"
  alarm_actions       = [aws_sns_topic.trading_alerts.arn]

  dimensions = {
    Environment = var.environment
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "daily_drawdown_critical" {
  alarm_name          = "daily-drawdown-critical-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DailyDrawdownPct"
  namespace           = "EA_SCALPER/Trading"
  period              = 60  # 1 minute
  statistic           = "Maximum"
  threshold           = var.max_daily_drawdown_pct
  alarm_description   = "CRITICAL: Daily drawdown exceeded ${var.max_daily_drawdown_pct}%"
  alarm_actions       = [aws_sns_topic.trading_alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    Environment = var.environment
  }

  tags = local.common_tags
}

# 2. Total Drawdown Alert (Circuit Breaker)
resource "aws_cloudwatch_metric_alarm" "total_drawdown_critical" {
  alarm_name          = "total-drawdown-critical-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "TotalDrawdownPct"
  namespace           = "EA_SCALPER/Trading"
  period              = 60
  statistic           = "Maximum"
  threshold           = var.max_total_drawdown_pct
  alarm_description   = "CIRCUIT BREAKER: Total drawdown exceeded ${var.max_total_drawdown_pct}%"
  alarm_actions       = [aws_sns_topic.trading_alerts.arn]

  dimensions = {
    Environment = var.environment
  }

  tags = local.common_tags
}

# 3. ONNX Inference Latency
resource "aws_cloudwatch_metric_alarm" "onnx_latency_high" {
  alarm_name          = "onnx-inference-latency-high-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ONNXInferenceLatencyMs"
  namespace           = "EA_SCALPER/Performance"
  period              = 60
  statistic           = "Average"
  threshold           = 5.0
  alarm_description   = "ONNX inference latency exceeded 5ms (performance degradation)"
  alarm_actions       = [aws_sns_topic.trading_alerts.arn]

  dimensions = {
    Environment = var.environment
  }

  tags = local.common_tags
}

# 4. OnTick Execution Time
resource "aws_cloudwatch_metric_alarm" "ontick_latency_high" {
  alarm_name          = "ontick-latency-high-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "OnTickLatencyMs"
  namespace           = "EA_SCALPER/Performance"
  period              = 60
  statistic           = "Average"
  threshold           = 50.0
  alarm_description   = "OnTick execution time exceeded 50ms budget"
  alarm_actions       = [aws_sns_topic.trading_alerts.arn]

  dimensions = {
    Environment = var.environment
  }

  tags = local.common_tags
}

# 5. Python Hub API Latency
resource "aws_cloudwatch_metric_alarm" "python_api_latency_high" {
  alarm_name          = "python-api-latency-high-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "PythonAPILatencyMs"
  namespace           = "EA_SCALPER/Performance"
  period              = 60
  statistic           = "Average"
  threshold           = 400.0
  alarm_description   = "Python API latency exceeded 400ms budget"
  alarm_actions       = [aws_sns_topic.trading_alerts.arn]

  dimensions = {
    Environment = var.environment
  }

  tags = local.common_tags
}

# 6. Failed Trade Execution
resource "aws_cloudwatch_metric_alarm" "failed_trades" {
  alarm_name          = "failed-trades-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FailedTrades"
  namespace           = "EA_SCALPER/Trading"
  period              = 300
  statistic           = "Sum"
  threshold           = 3
  alarm_description   = "More than 3 failed trade executions in 5 minutes"
  alarm_actions       = [aws_sns_topic.trading_alerts.arn]

  dimensions = {
    Environment = var.environment
  }

  tags = local.common_tags
}

# 7. Spread Width Alert
resource "aws_cloudwatch_metric_alarm" "spread_too_wide" {
  alarm_name          = "spread-too-wide-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "SpreadPoints"
  namespace           = "EA_SCALPER/MarketConditions"
  period              = 60
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "Spread exceeded 30 points (trading halted)"
  alarm_actions       = [aws_sns_topic.trading_alerts.arn]

  dimensions = {
    Environment = var.environment
  }

  tags = local.common_tags
}

# 8. EC2 Instance Health
resource "aws_cloudwatch_metric_alarm" "mt5_instance_health" {
  alarm_name          = "mt5-instance-health-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1
  alarm_description   = "MT5 server instance failing status checks"
  alarm_actions       = [aws_sns_topic.trading_alerts.arn]

  dimensions = {
    InstanceId = aws_instance.mt5_server.id
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "python_instance_health" {
  alarm_name          = "python-instance-health-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1
  alarm_description   = "Python server instance failing status checks"
  alarm_actions       = [aws_sns_topic.trading_alerts.arn]

  dimensions = {
    InstanceId = aws_instance.python_server.id
  }

  tags = local.common_tags
}

# Dashboard
resource "aws_cloudwatch_dashboard" "trading_dashboard" {
  dashboard_name = "ea-scalper-trading-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["EA_SCALPER/Trading", "DailyDrawdownPct"],
            [".", "TotalDrawdownPct"]
          ]
          period = 60
          stat   = "Maximum"
          region = var.aws_region
          title  = "Drawdown Monitoring"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["EA_SCALPER/Performance", "OnTickLatencyMs"],
            [".", "ONNXInferenceLatencyMs"],
            [".", "PythonAPILatencyMs"]
          ]
          period = 60
          stat   = "Average"
          region = var.aws_region
          title  = "Latency Performance"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["EA_SCALPER/Trading", "SuccessfulTrades"],
            [".", "FailedTrades"]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "Trade Execution"
        }
      }
    ]
  })
}
