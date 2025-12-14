# PROMPT 001: Nautilus Plan Deep Audit & Refine

## Objective

**Deep audit and reorganization** of NAUTILUS_MIGRATION_MASTER_PLAN.md (10,183 lines):
- Verify what's ACTUALLY implemented vs what's documented
- Consolidate redundant sections and fix inconsistencies
- Update status of all 40 modules with validation evidence
- Reorganize structure for clarity and maintainability
- Identify gaps, missing implementations, and next priorities

**Why it matters**: The plan is critical for tracking migration progress but has grown unwieldy. Need a clean, trustworthy source of truth before validating backtest functionality.

---

## Context

**Target file**: @DOCS/02_IMPLEMENTATION/NAUTILUS_MIGRATION_MASTER_PLAN.md

**Dynamic context**:
- !`wc -l DOCS/02_IMPLEMENTATION/NAUTILUS_MIGRATION_MASTER_PLAN.md` (current size)
- !`find nautilus_gold_scalper/src -name "*.py" -type f | wc -l` (actual Python files)
- !`git log --oneline DOCS/02_IMPLEMENTATION/NAUTILUS_MIGRATION_MASTER_PLAN.md | head -5` (recent changes)

**Known issues**:
1. Plan says "✅ COMPLETE" but may have gaps
2. 4 validation bugs documented (ORACLE/FORGE findings) but may be more
3. Risk management was FTMO, now Apex - unclear if fully updated
4. Backtest setup concerns not fully addressed

---

## Requirements

### 1. Evidence-Based Status Verification

For EACH of the 40 modules listed:

**Check actual implementation**:
```bash
# Example checks you should run:
ls -la nautilus_gold_scalper/src/indicators/session_filter.py
grep -n "class SessionFilter" nautilus_gold_scalper/src/indicators/session_filter.py
grep -n "def " nautilus_gold_scalper/src/indicators/session_filter.py | wc -l  # count methods
```

**Validation criteria**:
- ✅ IMPLEMENTED: File exists + has main class + has key methods + compiles without errors
- ⚠️ PARTIAL: File exists but missing features or has errors
- ❌ MISSING: File doesn't exist or is stub

**Evidence to collect**:
- File size (lines of code)
- Main classes/functions present
- Import validation (does it import cleanly?)
- Known bugs/issues from ORACLE/FORGE reports

### 2. Consolidation & Cleanup

**Remove redundancy**:
- Multiple progress trackers → ONE authoritative tracker
- Duplicate module listings → Consolidate
- Repeated feature descriptions → Link to single source

**Fix inconsistencies**:
- Status markers (✅ vs ⏳ vs ❌) must match reality
- Dates should be consistent and accurate
- Version numbers (v2.2, v4.0, etc.) should be clear

**Reorganize sections**:
- Executive summary at top (200 lines max)
- Detailed inventories in appendix
- Active work items clearly separated from completed

### 3. Gap Analysis

**Identify what's missing**:
- Features documented in MQL5 but not migrated
- Python modules that exist but aren't documented
- Tests that should exist but don't
- Integration points not addressed

**Priority assessment**:
- P0: Blockers for backtest validation
- P1: Core functionality gaps
- P2: Nice-to-haves

### 4. Next Steps Clarity

**Define concrete actions**:
- What needs to be built?
- What needs to be tested?
- What needs to be fixed?
- What's ready for validation?

---

## Droid Assignment

**Use NAUTILUS droid** for this task:
- Expert in NautilusTrader architecture
- Knows migration patterns MQL5 → Python
- Can validate implementations against plan
- Understands project structure and conventions

Invoke with:
```
Task(
  subagent_type="nautilus-trader-architect",
  description="Nautilus plan audit",
  prompt="[This entire prompt]"
)
```

---

## Output Specification

### Primary Output

**File**: `.prompts/001-nautilus-plan-refine/nautilus-plan-audit.md`

**Structure**:
```markdown
# Nautilus Migration Plan Audit Report

<metadata>
<confidence>HIGH|MEDIUM|LOW</confidence>
<verification_method>Evidence-based file checks + import validation</verification_method>
<modules_verified>40/40</modules_verified>
<issues_found>N</issues_found>
</metadata>

## Executive Summary

[200 words max - what's the current state, what needs attention]

## Module Status Matrix

| Module | Status | Evidence | Issues | Priority |
|--------|--------|----------|--------|----------|
| session_filter.py | ✅ VERIFIED | 312 lines, 8 methods, imports OK | None | - |
| regime_detector.py | ⚠️ PARTIAL | 420 lines, missing Hurst validation | Bug in VR calc | P1 |
...

## Gap Analysis

### P0 Gaps (Blockers)
- [List with evidence]

### P1 Gaps (Core functionality)
- [List with evidence]

### P2 Gaps (Nice-to-have)
- [List with evidence]

## Inconsistencies Found

1. [Description + location in plan + proposed fix]
2. ...

## Recommended Plan Structure

[Propose reorganization - show before/after outline]

## Next Actions

1. [Concrete action + owner + blocker status]
2. ...

<open_questions>
- [What remains uncertain after audit]
</open_questions>

<assumptions>
- [What was assumed during audit]
</assumptions>

<dependencies>
- [What's needed to proceed with fixes]
</dependencies>
```

### Secondary Output

**File**: `.prompts/001-nautilus-plan-refine/SUMMARY.md`

**Required sections**:
```markdown
# Nautilus Plan Audit - Summary

## One-Liner
[Substantive description of findings - NOT generic like "Audit completed"]

## Version
v1 - Initial audit (2025-12-07)

## Key Findings
• [Actionable finding 1]
• [Actionable finding 2]
• [Actionable finding 3]
• [Critical issues found: N]

## Decisions Needed
- [What requires user input]

## Blockers
- [External impediments, if any]

## Next Step
[Concrete forward action - e.g., "Fix 3 P0 gaps in regime_detector.py"]
```

---

## Tools to Use

**Essential**:
- `Glob` - Find Python files: `nautilus_gold_scalper/src/**/*.py`
- `Read` - Examine module implementations
- `Grep` - Search for classes, methods, known issues
- `Execute` - Run validation checks (line counts, imports, etc.)

**For validation**:
```bash
# Check file exists and size
ls -la nautilus_gold_scalper/src/indicators/session_filter.py

# Count classes/methods
grep -c "^class " file.py
grep -c "^    def " file.py

# Validate imports (quick smoke test)
python -c "from nautilus_gold_scalper.src.indicators import session_filter; print('OK')"
```

**Do NOT**:
- Make assumptions about implementation status
- Trust the plan's status markers without verification
- Skip evidence collection

---

## Success Criteria

**Audit Quality**:
- [ ] All 40 modules verified with evidence (file checks + import tests)
- [ ] Every status claim (✅/⚠️/❌) backed by evidence
- [ ] Gaps identified with priority levels (P0/P1/P2)
- [ ] Inconsistencies documented with proposed fixes
- [ ] Next actions are concrete and actionable

**Output Quality**:
- [ ] Module Status Matrix is complete and accurate
- [ ] Gap Analysis separates blockers from nice-to-haves
- [ ] Recommended structure is clear and practical
- [ ] SUMMARY.md has substantive one-liner (not generic)
- [ ] All XML metadata present and complete

**Validation**:
- [ ] At least 5 sample modules fully validated (compile + import test)
- [ ] Known bugs (ORACLE/FORGE findings) cross-referenced
- [ ] Report findings match actual codebase state

---

## Intelligence Rules

**Depth**: This is a deep audit - take time to verify claims.

**Parallelism**: When checking multiple modules, use parallel tool calls:
```
Read(file1), Read(file2), Read(file3), ... in ONE message
```

**Evidence standard**: "Trust but verify" - don't assume the plan is correct.

**Streaming write**: For the main audit report, write findings incrementally as you discover them (don't wait to collect everything before writing).

---

## Notes

- The plan currently claims "✅ MIGRAÇÃO COMPLETA" but user suspects gaps
- Risk management shift FTMO → Apex may not be fully reflected
- 4 bugs already documented - may be tip of iceberg
- This audit is PREREQUISITE for backtest validation (prompt 005)
