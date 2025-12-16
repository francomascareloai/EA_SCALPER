# EA_SCALPER_XAUUSD - Infrastructure Architecture Diagrams

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          TRADER (Franco)                                    │
│                               ↓                                             │
│                     AWS Management Console                                  │
│                     (MFA Required, IP Whitelist)                            │
└─────────────────────────────────────────────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                      AWS REGION: us-east-2 (Ohio)                           │
│                    Closest to Chicago Trading Servers                       │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐ │
│  │  VPC: ea-scalper-vpc (10.0.0.0/16)                                    │ │
│  │                                                                        │ │
│  │  ┌──────────────────────────┐   ┌──────────────────────────┐         │ │
│  │  │  Availability Zone 2a    │   │  Availability Zone 2b    │         │ │
│  │  │  (PRIMARY)               │   │  (STANDBY - Cold)        │         │ │
│  │  │                          │   │                          │         │ │
│  │  │  Public Subnet           │   │  Public Subnet           │         │ │
│  │  │  ┌──────────────┐        │   │  ┌──────────────┐       │         │ │
│  │  │  │ NAT Gateway  │        │   │  │ NAT Gateway  │       │         │ │
│  │  │  │ (Outbound)   │        │   │  │ (HA Backup)  │       │         │ │
│  │  │  └──────────────┘        │   │  └──────────────┘       │         │ │
│  │  │         ↕                │   │                          │         │ │
│  │  │  Private Subnet          │   │  Private Subnet          │         │ │
│  │  │  10.0.1.0/24             │   │  10.0.2.0/24             │         │ │
│  │  │                          │   │                          │         │ │
│  │  │  ┌────────────────────┐  │   │  ┌────────────────────┐ │         │ │
│  │  │  │ PLACEMENT GROUP    │  │   │  │ (Launch on fail)   │ │         │ │
│  │  │  │ trading-cluster    │  │   │  │                    │ │         │ │
│  │  │  │ (Cluster strategy) │  │   │  │                    │ │         │ │
│  │  │  │                    │  │   │  │                    │ │         │ │
│  │  │  │  ┌──────────────┐  │  │   │  │                    │ │         │ │
│  │  │  │  │  WINDOWS     │  │  │   │  │                    │ │         │ │
│  │  │  │  │  c5.xlarge   │  │  │   │  │                    │ │         │ │
│  │  │  │  │  4vCPU 8GB   │  │  │   │  │                    │ │         │ │
│  │  │  │  │              │  │  │   │  │                    │ │         │ │
│  │  │  │  │  MT5 + EA    │  │  │   │  │                    │ │         │ │
│  │  │  │  └──────────────┘  │  │   │  │                    │ │         │ │
│  │  │  │         ↕ <5ms     │  │   │  │                    │ │         │ │
│  │  │  │  ┌──────────────┐  │  │   │  │                    │ │         │ │
│  │  │  │  │  LINUX       │  │  │   │  │                    │ │         │ │
│  │  │  │  │  c7i.xlarge  │  │  │   │  │                    │ │         │ │
│  │  │  │  │  4vCPU 8GB   │  │  │   │  │                    │ │         │ │
│  │  │  │  │              │  │  │   │  │                    │ │         │ │
│  │  │  │  │  Python API  │  │  │   │  │                    │ │         │ │
│  │  │  │  │  ONNX Engine │  │  │   │  │                    │ │         │ │
│  │  │  │  └──────────────┘  │  │   │  │                    │ │         │ │
│  │  │  └────────────────────┘  │   │  └────────────────────┘ │         │ │
│  │  └──────────────────────────┘   └──────────────────────────┘         │ │
│  │                                                                        │ │
│  │  VPC Endpoints (Private connectivity to AWS services):                │ │
│  │  • S3 Gateway         • EC2 Messages                                  │ │
│  │  • DynamoDB Gateway   • SSM Messages                                  │ │
│  │  • SSM Interface                                                      │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│  MANAGED SERVICES (Regional, Serverless):                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │ S3 Buckets  │  │ DynamoDB    │  │ Secrets Mgr  │  │ CloudWatch   │    │
│  │ • Data      │  │ • State     │  │ • API Keys   │  │ • Metrics    │    │
│  │ • Backups   │  │ • Session   │  │ • MT5 Creds  │  │ • Logs       │    │
│  │ • Models    │  │             │  │              │  │ • Dashboards │    │
│  └─────────────┘  └─────────────┘  └──────────────┘  └──────────────┘    │
│                                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐                       │
│  │ SNS Topic   │  │ AWS Backup  │  │ KMS Keys     │                       │
│  │ • Alerts    │  │ • Hourly    │  │ • Encryption │                       │
│  │ • Email/SMS │  │ • Daily AMI │  │              │                       │
│  └─────────────┘  └─────────────┘  └──────────────┘                       │
└─────────────────────────────────────────────────────────────────────────────┘
                                  ↓ HTTPS
┌─────────────────────────────────────────────────────────────────────────────┐
│                  NinjaTrader / Apex Prop Firm Broker                        │
│                  Chicago, IL Data Center                                    │
│                  Latency: 5-15ms from us-east-2                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  MARKET DATA FLOW (Real-time tick ingestion)                               │
└─────────────────────────────────────────────────────────────────────────────┘
        ↓
┌──────────────────┐
│  Broker API      │  (XAUUSD tick stream)
│  NinjaTrader     │
└──────────────────┘
        ↓ HTTPS (5-15ms latency)
┌──────────────────┐
│  MT5 Terminal    │  OnTick() event triggered
│  Windows Server  │
└──────────────────┘
        ↓
┌──────────────────────────────────────────────────────────────────────────┐
│  EA DECISION PIPELINE (Total budget: 50ms)                               │
│                                                                           │
│  1. Basic Checks (2ms):                                                  │
│     • Spread validation (< 30 points)                                    │
│     • Session filter (NY hours, avoid news)                              │
│     • Circuit breaker status (DD limits)                                 │
│                                                                           │
│  2. REST API Call to Python (10ms):                          ┌─────────┐ │
│     • Tick data serialization                                │ NETWORK │ │
│     • HTTPS POST to Python server  ────────────────────────> │  5ms RT │ │
│                                                               └─────────┘ │
│  3. Python Processing (25ms):                                            │
│     ┌────────────────────────────────────────────────────────────┐      │
│     │  FastAPI Handler receives tick                            │      │
│     │    ↓                                                       │      │
│     │  Feature Engineering (10ms):                              │      │
│     │    • SMC structure analysis (BOS/CHoCH)                   │      │
│     │    • Order flow delta calculation                         │      │
│     │    • Regime detection (Hurst, Entropy)                    │      │
│     │    • 50+ technical features                               │      │
│     │    ↓                                                       │      │
│     │  ONNX Inference (<5ms):                                   │      │
│     │    • Load features into tensor                            │      │
│     │    • Run direction_model.onnx                             │      │
│     │    • P(BUY), P(SELL), P(HOLD)                             │      │
│     │    ↓                                                       │      │
│     │  Signal Generation (5ms):                                 │      │
│     │    • Confluence scoring (70+ threshold)                   │      │
│     │    • Entry optimization (FVG, OB, market)                 │      │
│     │    • Position sizing (Kelly/ATR)                          │      │
│     │    ↓                                                       │      │
│     │  Response: { action: BUY/SELL/HOLD, lots, sl, tp }       │      │
│     └────────────────────────────────────────────────────────────┘      │
│                                                                           │
│  4. Network Return (5ms)                                                 │
│                                                                           │
│  5. Trade Execution on MT5 (8ms):                                        │
│     • Validate signal against Apex limits                                │
│     • Submit order to broker                                             │
│     • Log trade to DynamoDB + S3                                         │
│                                                                           │
│  TOTAL: ~35-45ms (10-15ms buffer remaining)                              │
└───────────────────────────────────────────────────────────────────────────┘
        ↓
┌──────────────────┐
│  Order Execution │  Trade sent to broker
│  Broker API      │
└──────────────────┘
        ↓
┌──────────────────┐
│  Market          │  Position opened/closed
└──────────────────┘
```

---

## Security Architecture (Defense in Depth)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  LAYER 1: PERIMETER SECURITY                                                │
├─────────────────────────────────────────────────────────────────────────────┤
│  • AWS Shield Standard (DDoS protection)                                    │
│  • VPC isolation (no direct internet access to compute)                     │
│  • NAT Gateway (outbound-only for updates/API calls)                        │
│  • Security Groups (stateful firewall, least privilege)                     │
│  • Network ACLs (stateless firewall, subnet-level)                          │
└─────────────────────────────────────────────────────────────────────────────┘
        ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│  LAYER 2: IDENTITY & ACCESS MANAGEMENT                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│  • IAM Roles (no long-lived credentials)                                    │
│  • Instance Profiles (EC2 assumes role)                                     │
│  • Least Privilege Policies (explicit Allow, implicit Deny)                 │
│  • MFA Required for Console Access                                          │
│  • No SSH/RDP keys (SSM Session Manager only)                               │
│  • CloudTrail Audit Logging (all API calls)                                 │
└─────────────────────────────────────────────────────────────────────────────┘
        ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│  LAYER 3: DATA ENCRYPTION                                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│  AT REST:                           IN TRANSIT:                             │
│  • S3: AES-256 (SSE-S3)             • All API calls: TLS 1.3               │
│  • EBS: AES-256 (KMS)               • MT5 ↔ Python: HTTPS                  │
│  • DynamoDB: AES-256                • Python ↔ Broker: HTTPS               │
│  • Secrets Manager: AES-256 (KMS)   • Certificate Pinning                  │
│  • KMS Key Rotation: Annual                                                 │
└─────────────────────────────────────────────────────────────────────────────┘
        ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│  LAYER 4: APPLICATION SECURITY                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│  • Input Validation (all API requests)                                      │
│  • Output Sanitization (prevent injection)                                  │
│  • Rate Limiting (DDoS prevention)                                          │
│  • ONNX Model Signature Verification                                        │
│  • Secrets Never Hardcoded (Secrets Manager)                                │
│  • Code Signing (EA.ex5 signature validation)                               │
└─────────────────────────────────────────────────────────────────────────────┘
        ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│  LAYER 5: MONITORING & INCIDENT RESPONSE                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│  • CloudWatch Alarms (real-time anomaly detection)                          │
│  • VPC Flow Logs (network traffic analysis)                                 │
│  • GuardDuty (optional, $4-6/month for threat intelligence)                 │
│  • Automated Alerts (SNS → Email/SMS)                                       │
│  • Incident Runbooks (documented response procedures)                       │
│  • Regular Security Patching (automated via SSM)                            │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Disaster Recovery Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  PRIMARY SITE: us-east-2a (Ohio)                                            │
│  RTO: 5 minutes | RPO: 15 minutes                                           │
└─────────────────────────────────────────────────────────────────────────────┘
        ↓ Automated Backups
┌─────────────────────────────────────────────────────────────────────────────┐
│  BACKUP TIER 1: Hourly EBS Snapshots (trading hours only)                  │
│  ┌───────────────────────────────────────────────────────────────────────┐ │
│  │  Schedule: Every hour 9 AM - 5 PM ET                                  │ │
│  │  Retention: 7 days                                                     │ │
│  │  Recovery: 5 minutes (create volume → attach → mount)                 │ │
│  └───────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
        ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│  BACKUP TIER 2: Daily AMIs (Golden Images)                                 │
│  ┌───────────────────────────────────────────────────────────────────────┐ │
│  │  Schedule: Daily at 6 PM ET (after market close)                      │ │
│  │  Retention: 30 days                                                    │ │
│  │  Recovery: 10 minutes (launch instance from AMI)                      │ │
│  └───────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
        ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│  STANDBY SITE: us-east-2b (Ohio - Different AZ)                             │
│  RTO: 15 minutes | RPO: 15 minutes                                          │
│  ┌───────────────────────────────────────────────────────────────────────┐ │
│  │  Status: COLD STANDBY (no running instances)                          │ │
│  │  Cost: $0/month (pay only when activated)                             │ │
│  │  Activation: Manual trigger OR Lambda auto-failover on alarms         │ │
│  │  Process:                                                              │ │
│  │    1. CloudWatch alarm detects primary failure                        │ │
│  │    2. Lambda launches instances in AZ-2b from latest AMI              │ │
│  │    3. Elastic IP reassigned (if broker whitelisting required)         │ │
│  │    4. Trading resumes within 15 minutes                               │ │
│  └───────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
        ↓ Cross-Region Replication
┌─────────────────────────────────────────────────────────────────────────────┐
│  DR SITE: us-west-2 (Oregon - Different Region)                             │
│  RTO: 30-60 minutes | RPO: 1 hour                                           │
│  ┌───────────────────────────────────────────────────────────────────────┐ │
│  │  S3 Replication: Critical data only (real-time)                       │ │
│  │  AMI Copies: Weekly (automated)                                        │ │
│  │  Activation: MANUAL ONLY (extreme disaster scenarios)                 │ │
│  │  Use Case: Regional AWS outage, catastrophic failure                  │ │
│  └───────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘

CONTINUOUS BACKUP: DynamoDB Point-in-Time Recovery (35-day retention)
```

---

## Cost Breakdown Comparison

```
┌──────────────────────────────────────────────────────────────────┐
│  COST SCENARIO COMPARISON                                        │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  BASELINE: 24/5 Operation                                  │ │
│  │  Monthly: $299.47 | Annual: $3,588                         │ │
│  │  ┌──────────────────────────────────────────────────────┐  │ │
│  │  │  EC2 Windows: $156.00  (52%)                         │  │ │
│  │  │  EC2 Linux:   $ 92.82  (31%)                         │  │ │
│  │  │  Storage:     $ 13.65  ( 5%)                         │  │ │
│  │  │  Services:    $ 36.50  (12%)                         │  │ │
│  │  └──────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  OPTIMIZED: Scheduled Instances (NY Session 8.5 hrs/day)  │ │
│  │  Monthly: $140.56 | Annual: $1,687 | SAVE 53%            │ │
│  │  ┌──────────────────────────────────────────────────────┐  │ │
│  │  │  EC2 Windows: $ 53.55  (38%)                         │  │ │
│  │  │  EC2 Linux:   $ 31.86  (23%)                         │  │ │
│  │  │  Storage:     $ 13.65  (10%)                         │  │ │
│  │  │  Services:    $ 41.50  (29%)                         │  │ │
│  │  └──────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  RESERVED: 1-Year Commitment                              │ │
│  │  Monthly: $214.19 | Annual: $2,570 | SAVE 28%            │ │
│  │  ┌──────────────────────────────────────────────────────┐  │ │
│  │  │  EC2 Windows: $ 88.40  (41%)                         │  │ │
│  │  │  EC2 Linux:   $ 55.64  (26%)                         │  │ │
│  │  │  Storage:     $ 13.65  ( 6%)                         │  │ │
│  │  │  Services:    $ 56.50  (27%)                         │  │ │
│  │  └──────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  LOCAL PC: For Comparison                                 │ │
│  │  Monthly: $50 | Annual: $600                              │ │
│  │  ┌──────────────────────────────────────────────────────┐  │ │
│  │  │  BUT:                                                │  │ │
│  │  │  • No HA/DR                                          │  │ │
│  │  │  • Higher latency (home ISP)                         │  │ │
│  │  │  • No enterprise security                            │  │ │
│  │  │  • Manual backups                                    │  │ │
│  │  │  • Not scalable                                      │  │ │
│  │  │  EFFECTIVE VALUE: ~$100-150/month cloud equivalent   │  │ │
│  │  └──────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘

RECOMMENDATION: Start with Baseline, switch to Reserved after validation
```

---

**Document**: Architecture Diagrams
**Created**: 2025-12-15
**Owner**: Agent 10 (Cloud Architecture Specialist)
