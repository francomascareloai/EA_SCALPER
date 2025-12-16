# Secrets Manager for API keys and credentials

# Broker API key
resource "aws_secretsmanager_secret" "broker_api_key" {
  name                    = "ea-scalper/broker-api-key-${var.environment}"
  description             = "NinjaTrader/Apex API credentials"
  recovery_window_in_days = 7

  tags = merge(local.common_tags, {
    Name = "broker-api-key"
  })
}

resource "aws_secretsmanager_secret_version" "broker_api_key" {
  secret_id = aws_secretsmanager_secret.broker_api_key.id
  secret_string = jsonencode({
    api_endpoint = var.broker_api_endpoint
    api_key      = "REPLACE_WITH_ACTUAL_KEY"
    api_secret   = "REPLACE_WITH_ACTUAL_SECRET"
  })

  lifecycle {
    ignore_changes = [secret_string]  # Prevent Terraform from overwriting manual updates
  }
}

# MT5 credentials
resource "aws_secretsmanager_secret" "mt5_credentials" {
  name                    = "ea-scalper/mt5-credentials-${var.environment}"
  description             = "MetaTrader 5 account credentials"
  recovery_window_in_days = 7

  tags = merge(local.common_tags, {
    Name = "mt5-credentials"
  })
}

resource "aws_secretsmanager_secret_version" "mt5_credentials" {
  secret_id = aws_secretsmanager_secret.mt5_credentials.id
  secret_string = jsonencode({
    account_number = "REPLACE_WITH_ACCOUNT"
    password       = "REPLACE_WITH_PASSWORD"
    server         = "REPLACE_WITH_SERVER"
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# KMS key for additional encryption
resource "aws_kms_key" "trading_data" {
  description             = "KMS key for EA_SCALPER trading data encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(local.common_tags, {
    Name = "trading-data-kms-key"
  })
}

resource "aws_kms_alias" "trading_data" {
  name          = "alias/ea-scalper-trading-${var.environment}"
  target_key_id = aws_kms_key.trading_data.key_id
}
