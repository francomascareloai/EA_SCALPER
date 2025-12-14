# Validates MCP servers defined for Codex by launching each under the MCP Inspector.
# Usage: Run in Windows PowerShell:  ./validate_mcp_servers.ps1

param(
    [string]$ProjectRoot = "C:\\Users\\Admin\\Documents\\EA_SCALPER_XAUUSD"
)

function Ensure-Command {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        Write-Error "Required command '$Name' not found in PATH. Please install or add to PATH."
        exit 1
    }
}

Ensure-Command -Name "npx"

# Define servers mirroring codex_mcp_config.toml
$servers = @(
    @{ name='context7'; cmd='npx'; args=@('-y','@upstash/context7-mcp'); env=@{}; cwd=$null },
    @{ name='sequential_thinking'; cmd='npx'; args=@('-y','@ahxxm/server-sequential-thinking'); env=@{}; cwd=$null },
    @{ name='puppeteer'; cmd='npx'; args=@('-y','@modelcontextprotocol/server-puppeteer'); env=@{}; cwd=$null },
    @{ name='github'; cmd='npx'; args=@('-y','@modelcontextprotocol/server-github'); env=@{ GITHUB_PERSONAL_ACCESS_TOKEN = '' }; cwd=$null },
    @{ name='everything'; cmd='npx'; args=@('-y','@modelcontextprotocol/server-everything'); env=@{}; cwd=$null },

    @{ name='mcp_code_checker'; cmd='python'; args=@("$ProjectRoot\\mcp-code-checker\\src\\main.py"); env=@{ PYTHONPATH = $ProjectRoot; VIRTUAL_ENV = "$ProjectRoot\\.venv"; PATH = "$ProjectRoot\\.venv\\Scripts;C:\\Python313;C:\\Python313\\Scripts;$env:PATH" }; cwd=$ProjectRoot },
    @{ name='file_analyzer'; cmd='python'; args=@("$ProjectRoot\\MCP_Integration\\servers\\mcp_file_analyzer.py"); env=@{ PYTHONPATH = $ProjectRoot; VIRTUAL_ENV = "$ProjectRoot\\.venv"; PATH = "$ProjectRoot\\.venv\\Scripts;C:\\Python313;C:\\Python313\\Scripts;$env:PATH" }; cwd=$ProjectRoot },
    @{ name='ftmo_validator'; cmd='python'; args=@("$ProjectRoot\\MCP_Integration\\servers\\mcp_ftmo_validator.py"); env=@{ PYTHONPATH = $ProjectRoot; VIRTUAL_ENV = "$ProjectRoot\\.venv"; PATH = "$ProjectRoot\\.venv\\Scripts;C:\\Python313;C:\\Python313\\Scripts;$env:PATH" }; cwd=$ProjectRoot },
    @{ name='metadata_generator'; cmd='python'; args=@("$ProjectRoot\\MCP_Integration\\servers\\mcp_metadata_generator.py"); env=@{ PYTHONPATH = $ProjectRoot; VIRTUAL_ENV = "$ProjectRoot\\.venv"; PATH = "$ProjectRoot\\.venv\\Scripts;C:\\Python313;C:\\Python313\\Scripts;$env:PATH" }; cwd=$ProjectRoot },
    @{ name='code_classifier'; cmd='python'; args=@("$ProjectRoot\\MCP_Integration\\servers\\mcp_code_classifier.py"); env=@{ PYTHONPATH = $ProjectRoot; VIRTUAL_ENV = "$ProjectRoot\\.venv"; PATH = "$ProjectRoot\\.venv\\Scripts;C:\\Python313;C:\\Python313\\Scripts;$env:PATH" }; cwd=$ProjectRoot },
    @{ name='batch_processor'; cmd='python'; args=@("$ProjectRoot\\MCP_Integration\\servers\\mcp_batch_processor.py"); env=@{ PYTHONPATH = $ProjectRoot; VIRTUAL_ENV = "$ProjectRoot\\.venv"; PATH = "$ProjectRoot\\.venv\\Scripts;C:\\Python313;C:\\Python313\\Scripts;$env:PATH" }; cwd=$ProjectRoot },
    @{ name='task_manager'; cmd='python'; args=@("$ProjectRoot\\MCP_Integration\\servers\\mcp_task_manager.py"); env=@{ PYTHONPATH = $ProjectRoot; VIRTUAL_ENV = "$ProjectRoot\\.venv"; PATH = "$ProjectRoot\\.venv\\Scripts;C:\\Python313;C:\\Python313\\Scripts;$env:PATH" }; cwd=$ProjectRoot },
    @{ name='trading_classifier'; cmd='python'; args=@("$ProjectRoot\\MCP_Integration\\servers\\trading_classifier_mcp.py"); env=@{ PYTHONPATH = $ProjectRoot; VIRTUAL_ENV = "$ProjectRoot\\.venv"; PATH = "$ProjectRoot\\.venv\\Scripts;C:\\Python313;C:\\Python313\\Scripts;$env:PATH" }; cwd=$ProjectRoot },
    @{ name='api_integration'; cmd='python'; args=@("$ProjectRoot\\MCP_Integration\\servers\\api_integration_mcp.py"); env=@{ PYTHONPATH = $ProjectRoot; VIRTUAL_ENV = "$ProjectRoot\\.venv"; PATH = "$ProjectRoot\\.venv\\Scripts;C:\\Python313;C:\\Python313\\Scripts;$env:PATH" }; cwd=$ProjectRoot },
    @{ name='code_analysis'; cmd='python'; args=@("$ProjectRoot\\MCP_Integration\\servers\\code_analysis_mcp.py"); env=@{ PYTHONPATH = $ProjectRoot; VIRTUAL_ENV = "$ProjectRoot\\.venv"; PATH = "$ProjectRoot\\.venv\\Scripts;C:\\Python313;C:\\Python313\\Scripts;$env:PATH" }; cwd=$ProjectRoot },
    @{ name='project_scaffolding'; cmd='python'; args=@("$ProjectRoot\\MCP_Integration\\servers\\project_scaffolding_mcp.py"); env=@{ PYTHONPATH = $ProjectRoot; VIRTUAL_ENV = "$ProjectRoot\\.venv"; PATH = "$ProjectRoot\\.venv\\Scripts;C:\\Python313;C:\\Python313\\Scripts;$env:PATH" }; cwd=$ProjectRoot },
    @{ name='youtube_transcript'; cmd='python'; args=@("$ProjectRoot\\MCP_Integration\\servers\\mcp_youtube_transcript.py"); env=@{ PYTHONPATH = $ProjectRoot; VIRTUAL_ENV = "$ProjectRoot\\.venv"; PATH = "$ProjectRoot\\.venv\\Scripts;C:\\Python313;C:\\Python313\\Scripts;$env:PATH" }; cwd=$ProjectRoot }
)

$failures = @()

foreach ($s in $servers) {
    Write-Host "\n=== Validating MCP server: $($s.name) ===" -ForegroundColor Cyan

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "npx"
    # Launch inspector, which launches the server and exposes a local web UI
    $psi.ArgumentList.Add("-y")
    $psi.ArgumentList.Add("@modelcontextprotocol/inspector")
    $psi.ArgumentList.Add($s.cmd)
    foreach ($a in $s.args) { $psi.ArgumentList.Add($a) }

    if ($s.cwd) { $psi.WorkingDirectory = $s.cwd }
    foreach ($k in $s.env.Keys) {
        $psi.Environment[$k] = $s.env[$k]
    }

    $psi.UseShellExecute = $false

    try {
        $proc = [System.Diagnostics.Process]::Start($psi)
        if (-not $proc) { throw "Failed to start process" }
        Write-Host "Opened MCP Inspector for '$($s.name)'." -ForegroundColor Green
        Write-Host "- A browser tab should open automatically."
        Write-Host "- Wait for 'Connected' and check Tools list loads."
        Write-Host "Press Enter to stop and continue to next server..."
        [void][System.Console]::ReadLine()
        if (-not $proc.HasExited) { $proc.Kill(true) }
        Start-Sleep -Milliseconds 500
    }
    catch {
        Write-Warning "Server '$($s.name)' failed: $($_.Exception.Message)"
        $failures += $s.name
    }
}

if ($failures.Count -gt 0) {
    Write-Warning "\nSome servers failed to launch under Inspector: $($failures -join ', ')"
    exit 1
}
else {
    Write-Host "\nAll servers launched successfully under Inspector." -ForegroundColor Green
}

