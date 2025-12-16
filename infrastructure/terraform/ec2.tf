# EC2 Instances - Trading Servers

# IAM Role for EC2 instances
resource "aws_iam_role" "ec2_trading_role" {
  name = "ec2-trading-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# IAM Policy for trading instances
resource "aws_iam_role_policy" "ec2_trading_policy" {
  name = "ec2-trading-policy"
  role = aws_iam_role.ec2_trading_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.trading_data.arn,
          "${aws_s3_bucket.trading_data.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query"
        ]
        Resource = aws_dynamodb_table.trading_state.arn
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          aws_secretsmanager_secret.broker_api_key.arn,
          aws_secretsmanager_secret.mt5_credentials.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData"
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
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.trading_alerts.arn
      }
    ]
  })
}

# Attach SSM policy for Systems Manager access
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_trading_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance profile
resource "aws_iam_instance_profile" "ec2_trading_profile" {
  name = "ec2-trading-profile-${var.environment}"
  role = aws_iam_role.ec2_trading_role.name

  tags = local.common_tags
}

# Windows MT5 Server
resource "aws_instance" "mt5_server" {
  ami           = data.aws_ami.windows_2022.id
  instance_type = var.windows_instance_type

  subnet_id                   = module.vpc.private_subnets[0]
  vpc_security_group_ids      = [aws_security_group.mt5_server.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_trading_profile.name
  associate_public_ip_address = false

  # Placement group for low latency
  placement_group = aws_placement_group.trading_cluster.id

  # Enhanced networking
  ebs_optimized = true

  # Root volume
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 100
    iops                  = 3000
    throughput            = 125
    encrypted             = true
    delete_on_termination = false

    tags = merge(local.common_tags, {
      Name = "mt5-server-root"
    })
  }

  # User data for initial setup
  user_data = base64encode(templatefile("${path.module}/user_data/windows_setup.ps1", {
    environment = var.environment
    s3_bucket   = aws_s3_bucket.trading_data.id
  }))

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # IMDSv2 only
    http_put_response_hop_limit = 1
  }

  tags = merge(local.common_tags, {
    Name = "mt5-trading-server"
    Role = "MT5-Server"
  })

  lifecycle {
    ignore_changes = [ami]  # Prevent replacement on AMI updates
  }
}

# Linux Python Server
resource "aws_instance" "python_server" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.linux_instance_type

  subnet_id                   = module.vpc.private_subnets[0]
  vpc_security_group_ids      = [aws_security_group.python_server.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_trading_profile.name
  associate_public_ip_address = false

  # Placement group for low latency
  placement_group = aws_placement_group.trading_cluster.id

  # Enhanced networking
  ebs_optimized = true

  # Root volume
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 50
    iops                  = 3000
    throughput            = 125
    encrypted             = true
    delete_on_termination = false

    tags = merge(local.common_tags, {
      Name = "python-server-root"
    })
  }

  # User data for initial setup
  user_data = base64encode(templatefile("${path.module}/user_data/linux_setup.sh", {
    environment = var.environment
    s3_bucket   = aws_s3_bucket.trading_data.id
  }))

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # IMDSv2 only
    http_put_response_hop_limit = 1
  }

  tags = merge(local.common_tags, {
    Name = "python-ml-server"
    Role = "Python-ML-Server"
  })

  lifecycle {
    ignore_changes = [ami]
  }
}

# Elastic IPs for static addressing (if needed for broker whitelisting)
resource "aws_eip" "mt5_server" {
  count    = var.environment == "production" ? 1 : 0
  instance = aws_instance.mt5_server.id
  domain   = "vpc"

  tags = merge(local.common_tags, {
    Name = "mt5-server-eip"
  })
}
