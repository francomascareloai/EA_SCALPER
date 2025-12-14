$procs = wmic process where "name='node.exe'" get CommandLine 2>$null | Out-String

$calc = ([regex]::Matches($procs, "calculator-mcp")).Count
$rag = ([regex]::Matches($procs, "mcp-local-rag")).Count
$reason = ([regex]::Matches($procs, "code-reasoning")).Count
$brave = ([regex]::Matches($procs, "brave-search")).Count
$e2b = ([regex]::Matches($procs, "e2b")).Count
$exa = ([regex]::Matches($procs, "exa-mcp")).Count
$fire = ([regex]::Matches($procs, "firecrawl")).Count
$mem = ([regex]::Matches($procs, "server-memory")).Count
$pg = ([regex]::Matches($procs, "postgres")).Count
$gh = ([regex]::Matches($procs, "server-github")).Count
$seq = ([regex]::Matches($procs, "sequential-thinking")).Count
$git = ([regex]::Matches($procs, "git-mcp")).Count

Write-Host ""
Write-Host "=== MCPs ATIVOS (por instancia droid) ==="
Write-Host ""
Write-Host "DESABILITADO (mas ainda carregando!):"
Write-Host "  calculator-mcp: $calc processos"
Write-Host ""
Write-Host "HABILITADOS:"
Write-Host "  mcp-local-rag: $rag processos"
Write-Host "  code-reasoning: $reason processos"
Write-Host "  brave-search: $brave processos"
Write-Host "  e2b: $e2b processos"
Write-Host "  exa: $exa processos"
Write-Host "  firecrawl: $fire processos"
Write-Host "  memory: $mem processos"
Write-Host "  postgres: $pg processos"
Write-Host "  github: $gh processos"
Write-Host "  sequential-thinking: $seq processos"
Write-Host "  git: $git processos"

$total = $calc + $rag + $reason + $brave + $e2b + $exa + $fire + $mem + $pg + $gh + $seq + $git
Write-Host ""
Write-Host "TOTAL: $total processos node.exe"
Write-Host ""

# Calculate expected for 6 droid instances
$mcps_per_droid = 12
$expected = $mcps_per_droid * 6
$overhead = $total - $expected

Write-Host "ANALISE:"
Write-Host "  Instancias droid ativas: 6"
Write-Host "  MCPs habilitados: $mcps_per_droid"
Write-Host "  Esperado (6 x $mcps_per_droid): $expected processos"
Write-Host "  Real: $total processos"
Write-Host "  Overhead (orphaned): $overhead processos"
