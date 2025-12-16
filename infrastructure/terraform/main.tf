# EA_SCALPER_XAUUSD Trading Infrastructure
# AWS Region: us-east-2 (Ohio) - closest to Chicago trading servers
# Architecture: Hybrid Windows (MQL5) + Linux (Python/ONNX)

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "ea-scalper-terraform-state"
    key            = "production/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "EA_SCALPER_XAUUSD"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "Franco"
      CostCenter  = "Trading-Operations"
    }
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "windows_2022" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Local variables
locals {
  common_tags = {
    Project     = "EA_SCALPER_XAUUSD"
    Environment = var.environment
    Terraform   = "true"
  }

  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}
