# Deployment Quick Reference

## Rapid Deployment Commands

### 1. Initialize Infrastructure (5 minutes)

```bash
cd /home/franco/projetos/EA_SCALPER_XAUUSD/infrastructure/terraform

# Create variables file
cat > terraform.tfvars <<EOF
aws_region                 = "us-east-2"
environment                = "production"
alert_email                = "franco@example.com"
broker_api_endpoint        = "https://api.ninjatrader.com"
enable_scheduled_instances = false
enable_cross_region_backup = true
max_daily_drawdown_pct     = 2.5
max_total_drawdown_pct     = 4.5
EOF

# Initialize and deploy
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### 2. Upload Trading Assets (10 minutes)

```bash
# Get bucket name from Terraform output
S3_BUCKET=$(terraform output -raw s3_bucket_name)

# Upload MQL5 code
aws s3 sync ../../../MQL5/ s3://$S3_BUCKET/mql5/ --exclude "*.ex5"

# Upload Python code
aws s3 sync ../../../nautilus_gold_scalper/ s3://$S3_BUCKET/code/

# Upload ONNX models
aws s3 cp ../../../models/direction_model.onnx s3://$S3_BUCKET/models/

# Upload data
aws s3 cp ../../../data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet \
    s3://$S3_BUCKET/historical/
```

### 3. Configure Secrets (2 minutes)

```bash
# Update broker credentials
aws secretsmanager put-secret-value \
    --secret-id ea-scalper/broker-api-key-production \
    --secret-string '{
        "api_endpoint": "https://api.ninjatrader.com",
        "api_key": "YOUR_KEY",
        "api_secret": "YOUR_SECRET"
    }'

# Update MT5 credentials
aws secretsmanager put-secret-value \
    --secret-id ea-scalper/mt5-credentials-production \
    --secret-string '{
        "account_number": "YOUR_ACCOUNT",
        "password": "YOUR_PASSWORD",
        "server": "YOUR_SERVER"
    }'
```

### 4. Access Instances (SSM)

```bash
# Get instance IDs
MT5_ID=$(terraform output -raw mt5_server_id)
PYTHON_ID=$(terraform output -raw python_server_id)

# Connect to Windows MT5 server
aws ssm start-session --target $MT5_ID

# Connect to Linux Python server
aws ssm start-session --target $PYTHON_ID
```

### 5. Verify Services

```bash
# On Python server (via SSM)
sudo systemctl status ea-scalper-api
curl http://localhost:8000/health

# Check logs
tail -f /opt/ea_scalper/logs/application.log
```

---

## Cost Optimization Quick Switches

### Enable Scheduled Instances (NY Session Only - 53% savings)

```bash
# Edit terraform.tfvars
enable_scheduled_instances = true

# Reapply
terraform apply
```

### Switch to Reserved Instances (28% savings)

Purchase Reserved Instances via AWS Console:
1. EC2 → Reserved Instances → Purchase Reserved Instances
2. Instance type: c5.xlarge (Windows), c7i.xlarge (Linux)
3. Term: 1 year, Payment: All Upfront or Partial Upfront
4. No Terraform changes needed (automatic billing adjustment)

---

## Monitoring Quick Access

```bash
# CloudWatch Dashboard URL
echo "https://console.aws.amazon.com/cloudwatch/home?region=us-east-2#dashboards:name=ea-scalper-trading-production"

# View recent alarms
aws cloudwatch describe-alarms --state-value ALARM --region us-east-2

# Get latest trading metrics (last 5 minutes)
aws cloudwatch get-metric-statistics \
    --namespace EA_SCALPER/Trading \
    --metric-name DailyDrawdownPct \
    --start-time $(date -u -d '5 minutes ago' +%Y-%m-%dT%H:%M:%S) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
    --period 60 \
    --statistics Maximum \
    --region us-east-2
```

---

## Disaster Recovery Commands

### Restore from Snapshot (RTO: 5 minutes)

```bash
# List available snapshots
aws ec2 describe-snapshots \
    --owner-ids self \
    --filters "Name=tag:Name,Values=mt5-server-root" \
    --query 'Snapshots | sort_by(@, &StartTime) | [-1]' \
    --region us-east-2

# Create volume from snapshot
SNAPSHOT_ID="snap-xxxxx"
VOLUME_ID=$(aws ec2 create-volume \
    --snapshot-id $SNAPSHOT_ID \
    --availability-zone us-east-2a \
    --volume-type gp3 \
    --query 'VolumeId' \
    --output text)

# Attach to replacement instance
aws ec2 attach-volume \
    --volume-id $VOLUME_ID \
    --instance-id $NEW_INSTANCE_ID \
    --device /dev/sdf
```

### Launch from AMI (RTO: 10 minutes)

```bash
# Get latest golden AMI
AMI_ID=$(aws ec2 describe-images \
    --owners self \
    --filters "Name=tag:Name,Values=mt5-golden-ami" \
    --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
    --output text)

# Launch new instance (Terraform preferred, or manual via CLI)
terraform apply -var="force_new_instance=true"
```

---

## Cost Monitoring

```bash
# Get month-to-date costs
aws ce get-cost-and-usage \
    --time-period Start=$(date +%Y-%m-01),End=$(date +%Y-%m-%d) \
    --granularity MONTHLY \
    --metrics "UnblendedCost" \
    --group-by Type=DIMENSION,Key=SERVICE \
    --filter file://cost-filter.json

# cost-filter.json content:
{
  "Tags": {
    "Key": "Project",
    "Values": ["EA_SCALPER_XAUUSD"]
  }
}

# Set billing alarm (via Terraform or console)
# Already configured in monitoring.tf
```

---

## Terraform State Management

### Backup State

```bash
# Local state backup
cp terraform.tfstate terraform.tfstate.backup.$(date +%Y%m%d)

# S3 backend backup (recommended)
aws s3 cp s3://ea-scalper-terraform-state/production/terraform.tfstate \
    terraform.tfstate.backup.$(date +%Y%m%d)
```

### Import Existing Resources

```bash
# If recreating infrastructure from existing AWS resources
terraform import aws_instance.mt5_server i-xxxxx
terraform import aws_instance.python_server i-yyyyy
```

---

## Troubleshooting

### High Latency

```bash
# Check network metrics
aws cloudwatch get-metric-statistics \
    --namespace EA_SCALPER/Performance \
    --metric-name OnTickLatencyMs \
    --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
    --period 60 \
    --statistics Average,Maximum \
    --region us-east-2

# Verify placement group
aws ec2 describe-instances \
    --instance-ids $MT5_ID $PYTHON_ID \
    --query 'Reservations[].Instances[].Placement'
```

### Instance Health Issues

```bash
# Check system status
aws ec2 describe-instance-status --instance-ids $MT5_ID

# View system logs
aws ec2 get-console-output --instance-id $MT5_ID

# Reboot instance
aws ec2 reboot-instances --instance-ids $MT5_ID
```

### API Connection Failures

```bash
# Test connectivity from MT5 to Python server
# (via SSM on MT5 instance)
curl http://<PYTHON_PRIVATE_IP>:8000/health

# Check security group rules
aws ec2 describe-security-groups \
    --filters "Name=tag:Name,Values=mt5-server-sg" \
    --query 'SecurityGroups[].IpPermissionsEgress'
```

---

## Terraform Module Outputs Reference

```bash
# View all outputs
terraform output

# Specific outputs
terraform output mt5_server_private_ip
terraform output python_server_private_ip
terraform output s3_bucket_name
terraform output cloudwatch_dashboard_url
```

---

## Emergency Shutdown

```bash
# Stop all trading instances immediately
aws ec2 stop-instances --instance-ids $MT5_ID $PYTHON_ID

# Verify stopped
aws ec2 describe-instances \
    --instance-ids $MT5_ID $PYTHON_ID \
    --query 'Reservations[].Instances[].[InstanceId,State.Name]'
```

---

## Cleanup (Full Teardown)

```bash
# WARNING: This destroys all infrastructure
terraform destroy

# Verify S3 buckets are empty first (manual step if versioning enabled)
aws s3 rm s3://ea-scalper-trading-data-production --recursive
```
