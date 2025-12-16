#!/bin/bash
# Linux Python Server Bootstrap Script
# EA_SCALPER_XAUUSD - Production Environment

set -e

# Variables
ENVIRONMENT="${environment}"
S3_BUCKET="${s3_bucket}"
APP_DIR="/opt/ea_scalper"
LOG_FILE="/var/log/ea_scalper_setup.log"

exec > >(tee -a $LOG_FILE)
exec 2>&1

echo "=== EA_SCALPER Python Server Setup Started: $(date) ==="

# Update system
echo "Updating system packages..."
dnf update -y

# Install required packages
echo "Installing dependencies..."
dnf install -y \
    python3.11 \
    python3.11-pip \
    python3.11-devel \
    git \
    gcc \
    g++ \
    cmake \
    awscli \
    amazon-cloudwatch-agent \
    chrony

# Configure time synchronization (critical for trading)
echo "Configuring NTP..."
systemctl enable chronyd
systemctl start chronyd

# Create application directory
echo "Creating application directory..."
mkdir -p $APP_DIR
cd $APP_DIR

# Download application code from S3
echo "Downloading application code from S3..."
aws s3 sync s3://$S3_BUCKET/code/ $APP_DIR/

# Create Python virtual environment
echo "Setting up Python environment..."
python3.11 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Install ONNX Runtime (optimized for CPU)
pip install onnxruntime>=1.16.0

# Configure CloudWatch agent
echo "Configuring CloudWatch agent..."
cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json <<EOF
{
  "metrics": {
    "namespace": "EA_SCALPER/Performance",
    "metrics_collected": {
      "cpu": {
        "measurement": [{"name": "cpu_usage_idle", "rename": "CPUUtilization", "unit": "Percent"}],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [{"name": "used_percent", "rename": "DiskUtilization", "unit": "Percent"}],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      },
      "mem": {
        "measurement": [{"name": "mem_used_percent", "rename": "MemoryUtilization", "unit": "Percent"}],
        "metrics_collection_interval": 60
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/ea_scalper_setup.log",
            "log_group_name": "/ea-scalper/python-server/$ENVIRONMENT",
            "log_stream_name": "{instance_id}/setup"
          },
          {
            "file_path": "$APP_DIR/logs/application.log",
            "log_group_name": "/ea-scalper/python-server/$ENVIRONMENT",
            "log_stream_name": "{instance_id}/application"
          }
        ]
      }
    }
  }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -s \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json

# Create systemd service for Python API
cat > /etc/systemd/system/ea-scalper-api.service <<EOF
[Unit]
Description=EA_SCALPER Python ML API
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$APP_DIR
Environment="PATH=$APP_DIR/venv/bin"
ExecStart=$APP_DIR/venv/bin/uvicorn Python_Agent_Hub.main:app --host 0.0.0.0 --port 8000 --workers 1
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl daemon-reload
systemctl enable ea-scalper-api
systemctl start ea-scalper-api

# Configure system limits for trading performance
cat >> /etc/security/limits.conf <<EOF
*               soft    nofile          65536
*               hard    nofile          65536
*               soft    nproc           4096
*               hard    nproc           4096
EOF

# Kernel tuning for low latency
cat >> /etc/sysctl.conf <<EOF
# Network performance tuning
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq

# Disable swap for consistent latency
vm.swappiness = 0
EOF

sysctl -p

# Create application logs directory
mkdir -p $APP_DIR/logs
chmod 755 $APP_DIR/logs

# Download ONNX models from S3
echo "Downloading ONNX models..."
mkdir -p $APP_DIR/models
aws s3 sync s3://$S3_BUCKET/models/ $APP_DIR/models/

# Set permissions
chown -R root:root $APP_DIR

# Signal completion
echo "=== Setup completed successfully: $(date) ==="

# Send notification via CloudWatch
aws cloudwatch put-metric-data \
    --namespace EA_SCALPER/Setup \
    --metric-name SetupCompleted \
    --value 1 \
    --dimensions Environment=$ENVIRONMENT,Server=Python
