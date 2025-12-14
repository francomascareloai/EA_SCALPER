# AGENTS.md v3.8.0 Optimization Report

## Summary

| Metric | Before (v3.7.1) | After (v3.8.0) | Change |
|--------|-----------------|----------------|--------|
| **Total Lines** | 1,172 | 937 | **-235 lines (-20%)** |
| **Token Estimate** | ~18,000 | ~14,400 | **-3,600 tokens** |

## Optimization Strategy: Content Delegation

Instead of duplicating detailed protocols in AGENTS.md, we delegate to specialized subagents and reference files.

### Sections Compressed

| Section | Before | After | Savings | Delegated To |
|---------|--------|-------|---------|--------------|
| `<drawdown_protection>` | 122 lines | 10 lines | **-112 lines** | `.claude/agents/sentinel-apex-guardian.md` |
| `<critical_bug_protocol>` | 94 lines | 9 lines | **-85 lines** | `.claude/agents/forge-mql5-architect.md` P0.11 |
| `<mql5_compilation>` | 17 lines | 4 lines | **-13 lines** | `DOCS/06_REFERENCE/WINDOWS_CLI.md` |
| `<windows_cli>` | 27 lines | 4 lines | **-23 lines** | `DOCS/06_REFERENCE/WINDOWS_CLI.md` |
| **TOTAL** | 260 lines | 27 lines | **-233 lines** |

### Files Created/Modified

1. **DOCS/06_REFERENCE/WINDOWS_CLI.md** (NEW - 63 lines)
   - Complete Windows CLI reference
   - MQL5 compilation paths and commands
   - PowerShell commands and anti-patterns

2. **`.claude/agents/forge-mql5-architect.md`** (MODIFIED)
   - Added P0.11 CRITICAL BUG PROTOCOL (~60 lines)
   - Added P0.12 MQL5 COMPILATION (~20 lines)
   - Total: 937 lines (was already comprehensive)

3. **`.claude/agents/sentinel-apex-guardian.md`** (VERIFIED)
   - Already contained complete DD protection system
   - Multi-tier DD tables, circuit breakers, recovery protocol
   - No additional content needed

4. **`.factory/droids/` (SYNCED)**
   - Both forge-mql5-architect.md and sentinel-apex-guardian.md synced

## Compression Pattern Used

Each compressed section follows this template:

```xml
<section_name>
  <!-- DELEGATED TO [AGENT]: Full [protocol] in [file_path] -->
  <reference>[Agent/File] has complete [content description]</reference>
  <summary>
    [Critical quick-reference content only]
  </summary>
</section_name>
```

## Benefits

1. **Reduced Token Consumption**: -20% reduction means faster processing
2. **Single Source of Truth**: Specialized content lives in specialized agents
3. **Easier Maintenance**: Update one place, not multiple
4. **Clear Delegation**: Comments indicate where full content resides
5. **Essential Info Preserved**: Summaries provide quick reference without full details

## Verification

- All specialized agents contain the full delegated content
- References point to correct file paths
- Critical information preserved in summaries
- No functionality lost - only verbosity reduced

## Version History

- **v3.7.1**: Added SQN/PSR/DSR/PBO thresholds, fixed MC DD 4%
- **v3.8.0**: Content delegation optimization (-235 lines, -20%)

---

*Generated: 2025-12-13*
*Prompt: 011-agents-md-optimization*
