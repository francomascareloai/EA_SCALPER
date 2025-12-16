<powershell>
# Windows MT5 Server Bootstrap Script
# EA_SCALPER_XAUUSD - Production Environment

$ErrorActionPreference = "Stop"

# Variables
$Environment = "${environment}"
$S3Bucket = "${s3_bucket}"
$AppDir = "C:\EA_SCALPER"
$LogFile = "C:\EA_SCALPER\setup.log"

# Create log directory
New-Item -ItemType Directory -Force -Path $AppDir | Out-Null

# Start logging
Start-Transcript -Path $LogFile -Append

Write-Host "=== EA_SCALPER MT5 Server Setup Started: $(Get-Date) ==="

# Install Chocolatey (package manager)
Write-Host "Installing Chocolatey..."
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Refresh environment
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Install AWS CLI
Write-Host "Installing AWS CLI..."
choco install awscli -y

# Install 7-Zip (for extracting MT5)
choco install 7zip -y

# Refresh path again
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")

# Download MT5 installer from S3
Write-Host "Downloading MetaTrader 5..."
New-Item -ItemType Directory -Force -Path "$AppDir\installers" | Out-Null
aws s3 cp s3://$S3Bucket/installers/mt5setup.exe $AppDir\installers\mt5setup.exe

# Install MT5 silently
Write-Host "Installing MetaTrader 5..."
Start-Process -FilePath "$AppDir\installers\mt5setup.exe" -ArgumentList "/auto" -Wait

# Download EA files from S3
Write-Host "Downloading EA files..."
$MT5DataPath = "$env:APPDATA\MetaQuotes\Terminal"
aws s3 sync s3://$S3Bucket/mql5/ $AppDir\MQL5\

# Copy EA to MT5 directory (will need to be done after MT5 creates data folder)
# This will be handled by a scheduled task that runs after first MT5 launch

# Install CloudWatch agent
Write-Host "Installing CloudWatch agent..."
$CloudWatchInstaller = "$AppDir\installers\amazon-cloudwatch-agent.msi"
Invoke-WebRequest -Uri "https://s3.amazonaws.com/amazoncloudwatch-agent/windows/amd64/latest/amazon-cloudwatch-agent.msi" -OutFile $CloudWatchInstaller
Start-Process msiexec.exe -ArgumentList "/i $CloudWatchInstaller /qn" -Wait

# Configure CloudWatch agent
$CloudWatchConfig = @"
{
  "metrics": {
    "namespace": "EA_SCALPER/Performance",
    "metrics_collected": {
      "Processor": {
        "measurement": [{"name": "% Processor Time", "rename": "CPUUtilization", "unit": "Percent"}],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      },
      "Memory": {
        "measurement": [{"name": "% Committed Bytes In Use", "rename": "MemoryUtilization", "unit": "Percent"}],
        "metrics_collection_interval": 60
      },
      "LogicalDisk": {
        "measurement": [{"name": "% Free Space", "rename": "DiskFreeSpace", "unit": "Percent"}],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "C:\\EA_SCALPER\\logs\\*.log",
            "log_group_name": "/ea-scalper/mt5-server/$Environment",
            "log_stream_name": "{instance_id}/application"
          }
        ]
      },
      "windows_events": {
        "collect_list": [
          {
            "event_name": "System",
            "event_levels": ["ERROR", "WARNING"],
            "log_group_name": "/ea-scalper/mt5-server/$Environment",
            "log_stream_name": "{instance_id}/system"
          }
        ]
      }
    }
  }
}
"@

$CloudWatchConfig | Out-File -FilePath "C:\ProgramData\Amazon\AmazonCloudWatchAgent\config.json" -Encoding ASCII

# Start CloudWatch agent
& "C:\Program Files\Amazon\AmazonCloudWatchAgent\amazon-cloudwatch-agent-ctl.ps1" `
    -a fetch-config `
    -m ec2 `
    -s `
    -c file:"C:\ProgramData\Amazon\AmazonCloudWatchAgent\config.json"

# Configure Windows time service for accurate timestamps
Write-Host "Configuring time synchronization..."
w32tm /config /manualpeerlist:"time.windows.com,0x8 time.nist.gov,0x8" /syncfromflags:manual /reliable:YES /update
Stop-Service w32time
Start-Service w32time
w32tm /resync

# Disable Windows Defender real-time scanning on MT5 directories (performance)
Add-MpPreference -ExclusionPath "C:\Program Files\MetaTrader 5"
Add-MpPreference -ExclusionPath "$env:APPDATA\MetaQuotes"
Add-MpPreference -ExclusionPath $AppDir

# Configure Windows for better network performance
Write-Host "Optimizing network settings..."
Set-NetTCPSetting -SettingName Internet -AutoTuningLevelLocal Normal
Set-NetTCPSetting -SettingName Internet -ScalingHeuristics Disabled
netsh int tcp set global autotuninglevel=normal
netsh int tcp set global chimney=enabled

# Disable unnecessary Windows services for performance
$ServicesToDisable = @(
    "DiagTrack",  # Diagnostics Tracking
    "SysMain",    # Superfetch
    "WSearch"     # Windows Search
)

foreach ($service in $ServicesToDisable) {
    Write-Host "Disabling service: $service"
    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
    Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
}

# Create logs directory
New-Item -ItemType Directory -Force -Path "$AppDir\logs" | Out-Null

# Create scheduled task to start MT5 on boot
$Action = New-ScheduledTaskAction -Execute "C:\Program Files\MetaTrader 5\terminal64.exe"
$Trigger = New-ScheduledTaskTrigger -AtStartup
$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

Register-ScheduledTask -TaskName "Start MT5" -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings -Force

# Signal completion
Write-Host "=== Setup completed successfully: $(Get-Date) ==="

Stop-Transcript

# Send CloudWatch metric
aws cloudwatch put-metric-data `
    --namespace EA_SCALPER/Setup `
    --metric-name SetupCompleted `
    --value 1 `
    --dimensions Environment=$Environment,Server=MT5

# Restart to apply all settings
Write-Host "Restarting system to apply settings..."
Restart-Computer -Force
</powershell>
