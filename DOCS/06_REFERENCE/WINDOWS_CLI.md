# Windows CLI Reference

## Critical Rule
**PowerShell ONLY!** CMD operators do NOT work.

## Anti-Patterns (NEVER USE)
```
&, &&, ||, 2>nul     # CMD operators - FAIL
cmd /c "mkdir x & move y"  # Chained commands - FAIL
```

## Tools Available
| Tool | Path | Purpose |
|------|------|---------|
| rg | C:\tools\rg.exe | Text search (ripgrep) |
| fd | C:\tools\fd.exe | File search |

## PowerShell Commands

| Operation | Command |
|-----------|---------|
| mkdir | `New-Item -ItemType Directory -Path "path" -Force` |
| move | `Move-Item -Path "src" -Destination "dst" -Force` |
| copy | `Copy-Item -Path "src" -Destination "dst" -Force` |
| delete | `Remove-Item -Path "target" -Recurse -Force -ErrorAction SilentlyContinue` |

## Best Practices

1. **One command per Execute** - No chaining
2. **Use Factory tools when possible:**
   - Create file → Create tool
   - Read file → Read tool
   - Edit file → Edit tool
   - List dir → LS tool
   - Find files → Glob tool
   - Find text → Grep tool

## MQL5 Compilation

### Paths
```
Compiler: C:\Program Files\FTMO MetaTrader 5\metaeditor64.exe
Project:  C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MQL5
StdLib:   C:\Program Files\FTMO MetaTrader 5\MQL5
```

### Compile Command
```powershell
Start-Process -FilePath "C:\Program Files\FTMO MetaTrader 5\metaeditor64.exe" -ArgumentList '/compile:"[FILE]"','/inc:"[PROJECT]"','/inc:"[STDLIB]"','/log' -Wait -NoNewWindow
```

### Read Compilation Log
```powershell
Get-Content "[FILE].log" -Encoding Unicode | Select-String "error|warning|Result"
```

### Common Errors
| Symptom | Solution |
|---------|----------|
| file not found | Check include path |
| undeclared identifier | Import missing |
| unexpected token | Syntax error |
