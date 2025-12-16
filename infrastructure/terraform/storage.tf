# S3 Storage Configuration

# Main trading data bucket
resource "aws_s3_bucket" "trading_data" {
  bucket = "ea-scalper-trading-data-${var.environment}"

  tags = merge(local.common_tags, {
    Name = "trading-data-bucket"
  })
}

# Enable versioning for data protection
resource "aws_s3_bucket_versioning" "trading_data" {
  bucket = aws_s3_bucket.trading_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "trading_data" {
  bucket = aws_s3_bucket.trading_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "trading_data" {
  bucket = aws_s3_bucket.trading_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy for cost optimization
resource "aws_s3_bucket_lifecycle_configuration" "trading_data" {
  bucket = aws_s3_bucket.trading_data.id

  rule {
    id     = "historical-data-archival"
    status = "Enabled"

    filter {
      prefix = "historical/"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER_IR"
    }

    transition {
      days          = 180
      storage_class = "DEEP_ARCHIVE"
    }
  }

  rule {
    id     = "backtest-results-cleanup"
    status = "Enabled"

    filter {
      prefix = "backtests/"
    }

    expiration {
      days = 90
    }
  }

  rule {
    id     = "logs-retention"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    expiration {
      days = 30
    }
  }
}

# Cross-region replication for disaster recovery
resource "aws_s3_bucket" "trading_data_replica" {
  count    = var.enable_cross_region_backup ? 1 : 0
  provider = aws.us_west_2
  bucket   = "ea-scalper-trading-data-replica-${var.environment}"

  tags = merge(local.common_tags, {
    Name = "trading-data-bucket-replica"
  })
}

resource "aws_s3_bucket_versioning" "trading_data_replica" {
  count    = var.enable_cross_region_backup ? 1 : 0
  provider = aws.us_west_2
  bucket   = aws_s3_bucket.trading_data_replica[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# Replication configuration
resource "aws_s3_bucket_replication_configuration" "trading_data" {
  count = var.enable_cross_region_backup ? 1 : 0

  role   = aws_iam_role.s3_replication[0].arn
  bucket = aws_s3_bucket.trading_data.id

  rule {
    id     = "replicate-critical-data"
    status = "Enabled"

    filter {
      prefix = "critical/"
    }

    destination {
      bucket        = aws_s3_bucket.trading_data_replica[0].arn
      storage_class = "STANDARD_IA"
    }
  }
}

# IAM role for S3 replication
resource "aws_iam_role" "s3_replication" {
  count = var.enable_cross_region_backup ? 1 : 0
  name  = "s3-replication-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "s3_replication" {
  count = var.enable_cross_region_backup ? 1 : 0
  role  = aws_iam_role.s3_replication[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.trading_data.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl"
        ]
        Resource = "${aws_s3_bucket.trading_data.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete"
        ]
        Resource = "${aws_s3_bucket.trading_data_replica[0].arn}/*"
      }
    ]
  })
}

# DynamoDB table for trading state and session data
resource "aws_dynamodb_table" "trading_state" {
  name           = "ea-scalper-trading-state-${var.environment}"
  billing_mode   = "PAY_PER_REQUEST"  # On-demand for cost optimization
  hash_key       = "session_id"
  range_key      = "timestamp"

  attribute {
    name = "session_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  attribute {
    name = "symbol"
    type = "S"
  }

  global_secondary_index {
    name            = "symbol-timestamp-index"
    hash_key        = "symbol"
    range_key       = "timestamp"
    projection_type = "ALL"
  }

  # Enable point-in-time recovery
  point_in_time_recovery {
    enabled = true
  }

  # Enable encryption
  server_side_encryption {
    enabled = true
  }

  # TTL for automatic cleanup of old data
  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = merge(local.common_tags, {
    Name = "trading-state-table"
  })
}
