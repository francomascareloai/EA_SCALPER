# Security Groups - Least Privilege Access

# Security group for Windows MT5 server
resource "aws_security_group" "mt5_server" {
  name_prefix = "mt5-server-"
  description = "Security group for Windows MT5 trading server"
  vpc_id      = module.vpc.vpc_id

  # RDP access via SSM only (no direct RDP)
  # Outbound HTTPS for MT5 broker connection
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS for MT5 broker connectivity"
  }

  # Outbound HTTP for updates
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP for Windows updates"
  }

  # Communication with Python server (REST API)
  egress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.python_server.id]
    description     = "REST API to Python ML server"
  }

  # DNS
  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "DNS resolution"
  }

  tags = merge(local.common_tags, {
    Name = "mt5-server-sg"
  })
}

# Security group for Linux Python server
resource "aws_security_group" "python_server" {
  name_prefix = "python-server-"
  description = "Security group for Linux Python ML server"
  vpc_id      = module.vpc.vpc_id

  # REST API from MT5 server
  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.mt5_server.id]
    description     = "REST API from MT5 server"
  }

  # Outbound HTTPS for AWS services
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS for AWS services"
  }

  # Outbound to DynamoDB (via VPC endpoint)
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    prefix_list_ids = [aws_vpc_endpoint.dynamodb.prefix_list_id]
    description = "DynamoDB access"
  }

  # DNS
  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "DNS resolution"
  }

  tags = merge(local.common_tags, {
    Name = "python-server-sg"
  })
}

# Security group for Application Load Balancer (if needed for monitoring)
resource "aws_security_group" "alb" {
  count       = var.environment == "production" ? 1 : 0
  name_prefix = "trading-alb-"
  description = "Security group for monitoring ALB"
  vpc_id      = module.vpc.vpc_id

  # HTTPS from specific IPs only (monitoring dashboard)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
    description = "HTTPS for monitoring dashboard"
  }

  egress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    security_groups = [aws_security_group.python_server.id]
    description = "Forward to Python server"
  }

  tags = merge(local.common_tags, {
    Name = "trading-alb-sg"
  })
}
