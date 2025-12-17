# Orchestration Protocols

> **Changelog**
> - 2025-12-17 (v3): **CRITICAL FIX** - Added Protocol 0 (Mandatory Delegation Rule) to prevent context overflow. Orchestrator MUST delegate code reading to sub-agents. This is the highest priority protocol.
> - 2025-12-16 (v2): CRITIC review of ARGUS integrations - Fixed Protocol 13 (added SQN>7.0 red flag, MC95 DD<4%), Protocol 14 (clarified bar vs tick-level HWM), enforcement mechanism for Protocols 11-14.
> - 2025-12-16: Applied CRITIC review fixes (C-001, C-002, C-003, H-001 through H-005, M-001 through M-004, L-001, L-002). Added Protocols 7 and 8. Expanded temporal verification to 10 samples. Standardized naming. Added error handling, timeout protocol, checkpoint triggers, conflict expansion, parallel coordination, and MANIFEST enforcement.

---

## 0. MANDATORY DELEGATION RULE (HIGHEST PRIORITY)

### Purpose
Prevent context overflow by FORCING the orchestrator to delegate ALL code reading and analysis to sub-agents. This protocol takes precedence over all others.

### The Problem This Solves
Without delegation, the orchestrator:
1. Reads large files (1000+ lines) directly into context
2. Performs CRITIC analysis (15+ sequential thoughts) in same context
3. Accumulates code + analysis + findings
4. **CONTEXT OVERFLOW → Summarization → LOSES critical details**

### MANDATORY Rules

#### The Orchestrator MUST NOT:
1. **Read source files** (>100 lines) directly into main context
2. **Perform CRITIC analysis** in main context
3. **Accumulate** code + analysis + findings in same thread
4. **Use Read tool** on any file in `src/`, `scripts/`, or `tests/` directories without delegation

#### The Orchestrator MUST:
1. **ALWAYS spawn sub-agent** (FORGE/REVIEWER/NAUTILUS) for code analysis
2. **Sub-agent reads files**, analyzes, writes to disk, returns ONLY summary
3. **Orchestrator receives**: 300 words max + file path + issue counts
4. **Never touch source code directly** - only read summaries and findings files

### Pre-Read Check (MANDATORY)

Before ANY file read, orchestrator MUST:

```
1. Check if file is in: src/, scripts/, tests/, or is a .py file
   - YES → MUST delegate to sub-agent
   - NO → May read directly (configs, plans, findings)

2. If delegation required:
   - Spawn appropriate sub-agent (FORGE for code, REVIEWER for review)
   - Include OUTPUT PROTOCOL in prompt
   - Wait for summary (max 300 words)
   - Read findings file if needed (findings are summaries, safe to read)
```

### Sub-Agent Prompt Template (REQUIRED)

Every sub-agent prompt MUST include:

```
DELEGATION PROTOCOL (MANDATORY):

1. YOU read the source files - orchestrator has NOT read them
2. Write COMPLETE analysis to: [output_file_path]
3. Return ONLY a summary (max 300 words) containing:
   - Top 3-5 findings
   - Issue counts: X CRITICAL, Y HIGH, Z MEDIUM, W LOW
   - Output file path
   - Status: COMPLETE/PARTIAL/FAILED
4. DO NOT return full code snippets or detailed analysis in chat
5. If you need to show code, include file:line references only
```

### File Size Thresholds

| File Size | Action |
|-----------|--------|
| <100 lines | MAY read directly (configs, small utilities) |
| 100-500 lines | SHOULD delegate |
| >500 lines | MUST delegate |
| Any src/ file | MUST delegate (regardless of size) |

### Enforcement

If orchestrator attempts to read source files directly:
1. **STOP** - do not proceed
2. **Spawn sub-agent** with proper delegation prompt
3. **Wait for summary** before continuing

### Why This Matters

| Without Delegation | With Delegation |
|-------------------|-----------------|
| Orchestrator reads 1600 lines | Sub-agent reads 1600 lines |
| + 15 thoughts in same context | Sub-agent returns 300 words |
| + Full analysis in context | Orchestrator stays clean |
| = Context overflow | = Sustainable execution |
| = Lost details | = Full details in files |

### Exception: Findings Files

The orchestrator MAY read:
- `orchestration/*.md` (findings are summaries)
- `MANIFEST.md` (index)
- Plan files (`.planning/**/*.md`)
- Config files (`*.yaml`, `*.json`, `*.toml`)

These are already summaries/structured data, not raw code.

---

## 1. Output Protocol

### Purpose
Persist sub-agent outputs to files to survive context summarization. Prevent critical findings from being lost.

### Directory Structure
```
.planning/phases/08-nautilus-deep-audit/orchestration/
├── MANIFEST.md                           # Master index of all outputs
├── baseline_git_status.txt               # Phase 00 baseline
├── baseline_git_log.txt                  # Phase 00 baseline
├── baseline_pytest.txt                   # Phase 00 baseline
├── PHASE_00_FINDINGS.md
├── PHASE_01_FINDINGS.md
├── PHASE_02_R1_A_FINDINGS.md
├── PHASE_02_R1_B_FINDINGS.md
├── PHASE_02_R2_C_FINDINGS.md
├── PHASE_02_R2_D_FINDINGS.md
├── ... (all phases)
└── PHASE_09_SYNTHESIS.md
```

### File Naming Convention
**Standard:** `PHASE_XX_RY_GROUP_FINDINGS.md`
- `XX`: Two-digit phase number (00-09)
- `RY`: Round number (R1, R2, etc.) - omit if phase has single round
- `GROUP`: Group identifier (A, B, C, D) or agent name for single-agent phases

**Examples:**
- `PHASE_00_FINDINGS.md` (single round, single output)
- `PHASE_02_R1_A_FINDINGS.md` (round 1, group A)
- `PHASE_06_SENTINEL_FINDINGS.md` (single agent)

### File Collision Handling
If a findings file already exists:
- **Overwrite** with new content (previous version is lost)
- If preservation is needed, use version suffix: `PHASE_XX_FINDINGS_v2.md`

### Sub-Agent Output Contract

Each sub-agent MUST:

1. **Write COMPLETE analysis** to: `orchestration/PHASE_XX_[GROUP]_FINDINGS.md`
2. **Verify file was written** before returning (check file exists and is non-empty)
3. **Return ONLY summary** (max 300 words) to chat containing:
   - Top 3-5 key findings
   - Severity counts: CRITICAL/HIGH/MEDIUM/LOW
   - Output file path
   - Confirmation: "File verified: [path] ([word count] words)"
   - Status: COMPLETE/PARTIAL/FAILED

### Sub-Agent Prompt Template

Include this in every sub-agent prompt:

```
OUTPUT PROTOCOL (MANDATORY):
1. Write your COMPLETE analysis to:
   .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_XX_GROUP_FINDINGS.md

2. VERIFY the file was written:
   - Check file exists
   - Confirm file is >500 words (minimum for thorough analysis)

3. Return ONLY a summary (max 300 words) to chat with:
   - Top findings (3-5 bullets)
   - Issue counts: X CRITICAL, Y HIGH, Z MEDIUM, W LOW
   - File verification: "[path] verified ([N] words)"
   - Status: COMPLETE/PARTIAL/FAILED

If file write fails: report Status: FAILED with error details.
```

### Version Control
Orchestration files should be git-committed after each phase completion for recovery:
```bash
git add .planning/phases/08-nautilus-deep-audit/orchestration/
git commit -m "audit: Phase XX complete"
```

---

## 2. CRITIC Verification Protocol

### Purpose
Ensure CRITIC self-review actually happens and isn't superficial.

### Required CRITIC Notes Section

Every findings document MUST include:

```markdown
## CRITIC Self-Review Notes

### Verification
- Sequential thinking thoughts used: [NUMBER, must be >=12]
- Adversarial techniques applied: [LIST with SPECIFIC EXAMPLES]

### Techniques Applied (with examples)
1. **INVERSION**: [Specific example of what was inverted]
2. **PRE-MORTEM**: [Specific failure scenario considered]
3. **EDGE CASES**: [Specific edge cases tested, e.g., "empty bars list, single bar, 1000+ bars"]
4. ... (at least 3 techniques with concrete examples)

### Issues Found During Self-Review
1. [Issue found and how it was addressed]
2. ...

### Assumptions Challenged
1. [Assumption] -> [Challenge] -> [Conclusion]
2. ...

### Confidence Level
[LOW | MEDIUM | HIGH] - [Brief justification]
```

### Minimum Requirements
- >=12 sequential thinking thoughts for standard files
- >=20 sequential thinking thoughts for files >1000 lines
- >=3 adversarial techniques applied **with specific examples** (not just technique names)
- At least 2 assumptions challenged

### Validation Proxies
Since self-reported thought counts cannot be verified, use these proxies:
- **Minimum output length**: 500 words for 12-thought analysis, 800 words for 20-thought
- **Technique documentation**: Must include concrete examples, not just names
- **Assumptions section**: Must have substance, not placeholder text

---

## 3. Temporal Verification Method

### Purpose
Concrete method to detect look-ahead bias, not just "check for look-ahead."

### Method: Data Access Trace

For each indicator/signal module:

1. **Pick 10 timestamps** with required distribution:
   - 3 normal trading hours (e.g., 10:30 AM, 2:15 PM, 3:45 PM ET)
   - 2 session boundaries (9:30 AM open, 4:00 PM close ET)
   - 2 high-volatility moments (around FOMC, NFP, or large price moves)
   - 2 news event windows (within 30 min of scheduled release)
   - 1 low liquidity period (pre-market or late session)

2. **For each timestamp**, trace ALL data accessed during:
   - Indicator calculation
   - Signal generation
   - Score computation
   - Position sizing (if applicable)

3. **Verify** all accessed data has timestamp < current timestamp

4. **Document** the trace in findings with pass/fail for each sample

### Trace Template

```markdown
## Temporal Verification Trace

### Sample Distribution
- Normal trading: 3/10
- Session boundaries: 2/10
- High-volatility: 2/10
- News events: 2/10
- Low liquidity: 1/10

### Sample 1 [NORMAL]: 2024-03-15 10:30:00 ET
**Data accessed:**
- bars[-1] (current): 2024-03-15 10:30:00 [PASS]
- bars[-2] (previous): 2024-03-15 10:25:00 [PASS]
- htf_bars[-1]: 2024-03-15 10:00:00 [PASS]
- news_events[...]: 2024-03-15 08:30:00 [PASS] (released before)

**Verdict:** PASS - No future data accessed

### Sample 2 [SESSION BOUNDARY]: 2024-03-15 09:30:00 ET
...

### Sample 3 [HIGH-VOLATILITY]: 2024-01-31 14:00:00 ET (FOMC)
...

### Summary
| Sample Type | Count | Pass | Fail |
|-------------|-------|------|------|
| Normal | 3 | 3 | 0 |
| Session Boundary | 2 | 2 | 0 |
| High-Volatility | 2 | 2 | 0 |
| News Event | 2 | 2 | 0 |
| Low Liquidity | 1 | 1 | 0 |
| **TOTAL** | **10** | **10** | **0** |

**Overall Verdict:** PASS / FAIL
```

### Red Flags to Check
- `bars[i+1]` or positive index into future
- News data with release time > current bar time
- Features computed with future returns
- Close price used for entry when only open available
- HTF bar close used before bar is complete
- Lookahead in rolling window calculations

---

## 4. Conflict Resolution Protocol

### Purpose
Handle contradictory findings between phases.

### Conflict Types

1. **Binary disagreement**: Phase X says "correct", Phase Y says "bug"
2. **Severity disagreement**: Phase X says "HIGH", Phase Y says "LOW"
3. **Assessment disagreement**: Phase X says "risky but acceptable", Phase Y says "unacceptable risk"
4. **Scope disagreement**: Phase X says "isolated issue", Phase Y says "systemic problem"

### Process

1. **Detection**: If any disagreement type occurs:
   - Document conflict in ISSUES_TRACKER.md with tag `[CONFLICT]`
   - Include conflict type
   - Note both phase findings with context

2. **Resolution in Phase 09**:
   - DAEMON must explicitly address each `[CONFLICT]`
   - Investigate root cause of disagreement
   - Make definitive ruling with justification
   - For severity disagreements: default to higher severity until resolved

3. **Default Behavior**:
   - If conflict cannot be resolved: default to FAIL for GO/NO-GO
   - Conservative approach: assume bug exists until proven otherwise
   - For severity conflicts: use the MORE severe assessment

### Conflict Log Template

```markdown
## Conflict: [CONFLICT-001]

**Type:** [BINARY | SEVERITY | ASSESSMENT | SCOPE]

**Phase X Finding:** Module A time gate is correctly implemented
**Phase Y Finding:** Module A misses 4:55 PM emergency close

**Root Cause Analysis:**
[Analysis by DAEMON]

**Resolution:** [CONFIRMED BUG | FALSE POSITIVE | PARTIAL ISSUE | HIGHER SEVERITY CONFIRMED]

**Action Required:** [Description]
```

---

## 5. Checkpoint Summary Protocol

### Purpose
Preserve context between phases/rounds to enable fresh conversations.

### Checkpoint Triggers

Create a checkpoint summary:
- After every 2 phases complete
- After any phase finding a CRITICAL issue
- After any phase with PARTIAL or FAILED status
- Before starting a new orchestration session
- When context appears to be approaching limits

### Template

```markdown
# Checkpoint Summary: Phase XX Complete

## Goal
[What this phase was supposed to achieve]

## Current State
[What was analyzed, what was found]

## Decisions Made
- [Decision 1]
- [Decision 2]

## Files Changed/Created
- `orchestration/PHASE_XX_FINDINGS.md`

## Key Metrics
| Metric | Value |
|--------|-------|
| CRITICAL issues | X |
| HIGH issues | Y |
| MEDIUM issues | Z |
| LOW issues | W |

## Blocking Issues
- [Any issue that must be fixed before proceeding]

## Conflicts Detected
- [Any conflicts requiring resolution]

## Next Steps
1. [Next phase/action]
2. [Next phase/action]
3. [Next phase/action]
```

---

## 6. MANIFEST.md Template

### Purpose
Master index of all audit outputs for easy navigation.

### Update Enforcement
MANIFEST.md MUST be updated after each phase (enforced by Protocol 7).

### Template

```markdown
# Audit Manifest

## Audit ID: 08-nautilus-deep-audit
## Started: YYYY-MM-DD HH:MM
## Status: [IN_PROGRESS | COMPLETE]

## Phase Status

| Phase | Status | Output File | Issues | Verified |
|-------|--------|-------------|--------|----------|
| 00 | COMPLETE | PHASE_00_FINDINGS.md | 0C/0H/0M/0L | Yes |
| 01 | COMPLETE | PHASE_01_FINDINGS.md | 1C/2H/3M/1L | Yes |
| 02-R1 | IN PROGRESS | ... | ... | Pending |
| ... | | | | |

## Issue Summary

| Severity | Count | Status |
|----------|-------|--------|
| CRITICAL | X | Y open / Z resolved |
| HIGH | X | Y open / Z resolved |
| MEDIUM | X | Y open / Z resolved |
| LOW | X | Y open / Z resolved |

## Conflicts

| ID | Phases | Type | Status |
|----|--------|------|--------|
| CONFLICT-001 | 02 vs 08 | BINARY | OPEN |

## Compliance Check Log

| Phase | Output Exists | >500 Words | CRITIC Notes | Techniques | MANIFEST Updated |
|-------|---------------|------------|--------------|------------|------------------|
| 00 | Yes | Yes | Yes | 3 | Yes |
| 01 | Yes | Yes | Yes | 4 | Yes |

## Notes
[Any important observations]
```

---

## 7. Protocol Compliance Check

### Purpose
Enforce protocol adherence after each phase. Without enforcement, protocols are just suggestions.

### When to Run
Orchestrator runs this check immediately after each phase completes.

### Checklist

After each phase, orchestrator verifies:

- [ ] **Output file exists** at expected path
- [ ] **Output file is non-empty** (>500 words minimum for standard, >800 for 20+ thought)
- [ ] **CRITIC Self-Review Notes section** is present
- [ ] **At least 3 adversarial techniques** documented **with specific examples**
- [ ] **Assumptions section** has >=2 substantive entries
- [ ] **MANIFEST.md** is updated with phase status and issue counts
- [ ] **Verified column** in MANIFEST set to Yes/No

### Compliance Outcomes

| All Checks Pass | Action |
|-----------------|--------|
| YES | Mark phase COMPLETE, proceed |
| NO (minor gaps) | Mark phase PARTIAL, document gaps, proceed but flag for re-review |
| NO (critical gaps) | Mark phase FAILED, halt, require remediation before proceeding |

### Critical Gaps (require halt)
- Output file missing or empty
- No CRITIC notes at all
- Zero adversarial techniques documented

### Minor Gaps (flag but proceed)
- <3 adversarial techniques (but some present)
- <2 assumptions challenged
- MANIFEST not updated (orchestrator updates immediately)

---

## 8. Apex Verification Method

### Purpose
Dedicated protocol for verifying Apex-specific compliance. Trailing DD, time gates, and overnight prohibition are non-negotiables that require explicit verification.

### Applicability
Required for any phase auditing:
- Risk management modules
- Position management
- Time-related logic
- Drawdown calculations
- Order execution

### Verification Checklist

For modules handling risk/positions/time:

#### 1. Trailing Drawdown Verification
- [ ] DD calculation uses HIGH-WATER MARK (not starting balance, not current balance)
- [ ] HWM update logic includes unrealized P/L (not just realized)
- [ ] DD percentage = (HWM - CurrentEquity) / AccountSize * 100
- [ ] 5% threshold triggers account termination

**Document:** Code line references for HWM update and DD calculation

#### 2. Time Gate Verification
Trace time gate logic with specific code references:

| Gate | Time (ET) | Expected Behavior | Code Location | Verified |
|------|-----------|-------------------|---------------|----------|
| Trade Block | 4:30 PM | No new trades allowed | `file.py:line` | [ ] |
| Emergency Close Start | 4:55 PM | Begin closing all positions | `file.py:line` | [ ] |
| Hard Close | 4:59 PM | All positions must be closed | `file.py:line` | [ ] |

**Test:** Trace what happens if a position is open at each gate time.

#### 3. Overnight Prohibition
- [ ] No positions can be held past 4:59 PM ET
- [ ] Weekend/holiday handling exists
- [ ] Rollover handling (if applicable)

#### 4. Consistency Rule (30% max daily profit)
- [ ] Daily profit tracking exists
- [ ] 30% threshold check implemented
- [ ] Behavior when 30% reached is defined (reduce size? halt trading?)

#### 5. Buffer Thresholds
| Threshold | Limit | Action | Code Location | Verified |
|-----------|-------|--------|---------------|----------|
| Trailing DD | >= 4.0% | HALT | `file.py:line` | [ ] |
| Total DD | >= 4.5% | HALT | `file.py:line` | [ ] |

### Apex Verification Template

```markdown
## Apex Verification Report

### 1. Trailing Drawdown
**HWM Update Code:** `risk_manager.py:145-152`
**DD Calculation Code:** `risk_manager.py:160-168`
**Includes Unrealized:** YES/NO
**Verdict:** PASS/FAIL

### 2. Time Gates
| Gate | Expected | Found | Location | Verdict |
|------|----------|-------|----------|---------|
| 4:30 PM Block | Yes | Yes | `time_gates.py:45` | PASS |
| 4:55 PM Emergency | Yes | Yes | `time_gates.py:78` | PASS |
| 4:59 PM Hard Close | Yes | Yes | `time_gates.py:92` | PASS |

### 3. Overnight Prohibition
**Verified:** YES/NO
**Code Location:** `position_manager.py:200-215`
**Verdict:** PASS/FAIL

### 4. Consistency Rule (30%)
**Implemented:** YES/NO
**Code Location:** N/A or `daily_limits.py:XX`
**Verdict:** PASS/FAIL/NOT_FOUND

### 5. Buffer Thresholds
**4.0% Trailing HALT:** YES/NO
**4.5% Total HALT:** YES/NO
**Verdict:** PASS/FAIL

### Overall Apex Compliance: PASS / FAIL / PARTIAL
```

---

## 9. Error Handling and Timeout Protocol

### Purpose
Define behavior when sub-agents fail, timeout, or produce incomplete output.

### Sub-Agent Timeout Handling

If a sub-agent times out or fails to respond:

1. **Mark phase as FAILED** in MANIFEST
2. **Create stub findings file** with content:
   ```markdown
   # Phase XX Findings - FAILED

   ## Status: FAILED
   ## Reason: Sub-agent timeout / Sub-agent error
   ## Timestamp: YYYY-MM-DD HH:MM

   ## Impact
   [What was this phase supposed to analyze]

   ## Recommended Action
   - Retry phase in next session
   - Consider reducing scope if timeout recurs
   ```
3. **Log failure** in MANIFEST with timestamp
4. **Continue with next phase** (don't block entire audit)
5. **Flag for re-run** at end of audit

### File Write Failure Handling

If sub-agent reports file write failure:

1. Sub-agent returns full output to chat (exception to 300-word limit)
2. Orchestrator manually creates findings file from output
3. Mark as PARTIAL with note "manual file creation required"

### Partial Output Handling

If sub-agent returns PARTIAL status:

1. Document what was completed vs. incomplete
2. Assess if incomplete portion is blocking
3. If blocking: halt and remediate
4. If non-blocking: proceed with documented gaps

---

## 10. Parallel Coordination Protocol

### Purpose
Prevent conflicts when multiple sub-agents run in parallel.

### Rules for Parallel Execution

1. **Single Orchestrator Control**: Only the orchestrator spawns sub-agents
2. **Non-Overlapping Files**: Parallel phases must write to different files
3. **No Shared State Modification**: Parallel sub-agents must not modify MANIFEST.md or ISSUES_TRACKER.md
4. **Orchestrator Updates Shared Files**: Only orchestrator updates MANIFEST after all parallel phases complete

### Parallel Phase File Assignment

Before spawning parallel sub-agents, orchestrator:
1. Assigns unique output file path to each
2. Confirms no path collisions
3. Communicates paths in sub-agent prompts

### Post-Parallel Merge

After parallel phases complete:
1. Orchestrator collects all outputs
2. Orchestrator updates MANIFEST with all results
3. Orchestrator checks for conflicts across parallel outputs
4. Orchestrator creates checkpoint if needed

### Example: Phase 02 Round 1 (Groups A and B in Parallel)

```
Group A writes to: PHASE_02_R1_A_FINDINGS.md
Group B writes to: PHASE_02_R1_B_FINDINGS.md

After both complete:
- Orchestrator reads both files
- Updates MANIFEST with A and B status
- Checks for conflicts between A and B findings
- Creates checkpoint summary
```

---

## CRITIC RE-REVIEW (2025-12-16)

### Previous Issues Status

Based on the changelog claiming fixes for C-001, C-002, C-003, H-001 through H-005, M-001 through M-004, and L-001, L-002:

| ID | Issue (Inferred from Fixes) | Status |
|----|---------------------------|--------|
| C-001 | Missing enforcement mechanism | FIXED - Protocol 7 added |
| C-002 | Missing Apex verification method | FIXED - Protocol 8 added |
| C-003 | Missing error/timeout handling | FIXED - Protocol 9 added |
| H-001 | Insufficient temporal samples | FIXED - Expanded to 10 with distribution |
| H-002 | Missing parallel coordination | FIXED - Protocol 10 added |
| H-003 | Missing checkpoint triggers | FIXED - 5 triggers defined in Protocol 5 |
| H-004 | Incomplete conflict types | FIXED - 4 types defined in Protocol 4 |
| H-005 | Missing MANIFEST enforcement | FIXED - Added to Protocol 7 checklist |
| M-001 | Unstandardized naming | FIXED - Naming convention in Protocol 1 |
| M-002 | Missing file collision handling | FIXED - Protocol 1 lines 42-44 |
| M-003 | Missing validation proxies | FIXED - Protocol 2 lines 131-134 |
| M-004 | Missing techniques examples | FIXED - Protocol 2 requires specific examples |
| L-001 | Missing version control guidance | FIXED - Protocol 1 lines 82-86 |
| L-002 | Incomplete conflict log template | FIXED - Protocol 4 expanded template |

### New Issues Found

None significant.

Minor observation: Protocol 8 covers critical DD thresholds (4.0% trailing HALT, 4.5% total HALT) but does not verify intermediate warn/caution/reduce thresholds. This is acceptable scope for an audit protocol focused on safety gates.

### Verdict

**APPROVED**

The document is comprehensive, well-structured, and addresses all core audit requirements. All 10 protocols are complete with clear purposes, templates, checklists, and examples. Apex compliance verification is thorough. Error handling, parallel coordination, and enforcement mechanisms are properly defined.

---

## ARGUS Integration: Enhanced Temporal Verification (2025-12-16)

### Source
`.planning/phases/08-nautilus-deep-audit/research/ARGUS_LOOKAHEAD_DETECTION.md`

### 11. Dangerous Pattern Detection Protocol

#### Purpose
Automated detection of the 17 dangerous code patterns cataloged by ARGUS research before manual review begins.

#### When to Apply
MANDATORY before any indicator, strategy, or ML code review (Phases 02, 03, 04, 04.5, 05).

#### Complete Grep Command Suite

```bash
# Run from project root
cd /home/franco/projetos/EA_SCALPER_XAUUSD

# === CRITICAL PATTERNS (any match = likely bug) ===

# 1. Forward-looking shift (CRITICAL)
rg "\.shift\s*\(\s*-\d" --type py

# 2. Forward-looking rolling
rg "rolling.*\.shift\s*\(\s*-" --type py

# 3. bfill fills from future (CRITICAL)
rg "\.bfill\(\)" --type py

# === ML-SPECIFIC PATTERNS ===

# 4. SMOTE/resampling patterns
rg "SMOTE|fit_resample" --type py

# 5. Feature selection patterns
rg "SelectKBest|RFE|feature_selection.*fit" --type py

# 6. Target encoding patterns
rg "TargetEncoder|target_encode" --type py

# 7. Imputation patterns
rg "SimpleImputer|KNNImputer|fillna.*method" --type py

# === MANUAL REVIEW PATTERNS ===

# 8. Full-sample statistics (context needed)
rg "\.mean\(\)|\.std\(\)|\.min\(\)|\.max\(\)" --type py

# 9. Close price decision (context needed)
rg "if.*close.*:|close.*>|close.*<" --type py

# 10. Fundamental data without lag
rg "earnings|fundamental|announcement" --type py

# === NAUTILUS-SPECIFIC PATTERNS ===

# 11. Timestamp configuration
rg "timestamp_on_close|ts_init_delta|bar_execution" --type py

# 12. Bar adaptive ordering
rg "bar_adaptive_high_low_ordering|bar_build_delay" --type py
```

#### Pattern Severity Classification

| Pattern # | Description | Severity | Action on Match |
|-----------|-------------|----------|-----------------|
| 1 | Forward shift | CRITICAL | Must fix before proceeding |
| 2 | Forward rolling | CRITICAL | Must fix before proceeding |
| 3 | bfill | CRITICAL | Must fix before proceeding |
| 4-7 | ML leakage | HIGH | Investigate order vs split |
| 8-10 | Context needed | MEDIUM | Manual review required |
| 11-12 | Config | INFO | Document setting |

#### Output Template

```markdown
## Pattern Detection Results

### Scan Date: YYYY-MM-DD
### Scope: [files/directories scanned]

### CRITICAL Patterns
| Pattern | Matches | Files | Status |
|---------|---------|-------|--------|
| Forward shift | 0 | - | PASS |
| Forward rolling | 0 | - | PASS |
| bfill | 0 | - | PASS |

### HIGH Patterns (ML)
| Pattern | Matches | Files | Investigation |
|---------|---------|-------|---------------|
| SMOTE | 2 | file.py | [result] |
| fit_transform | 5 | [list] | [result] |

### MEDIUM Patterns (Manual Review)
| Pattern | Matches | Review Status |
|---------|---------|---------------|
| Full-sample stats | 15 | REVIEWED - all use rolling windows |

### Nautilus Config
| Config | Value Found | Location | Correct? |
|--------|-------------|----------|----------|
| ts_init_delta | 60_000_000_000 | wrangler.py:45 | YES |
| bars_timestamp_on_close | True | config.py:89 | YES |
| bar_execution | True | backtest.py:23 | YES |

### Summary
- CRITICAL violations: X
- HIGH concerns: Y
- MEDIUM (reviewed OK): Z
- Verdict: PROCEED / HALT
```

---

### 12. NautilusTrader Configuration Verification Protocol

#### Purpose
Dedicated verification of NautilusTrader-specific settings that affect temporal integrity.

#### Critical Configuration Checklist

| Config | Required | Rationale | Verification |
|--------|----------|-----------|--------------|
| `ts_init_delta` | = bar_interval_ns | Ensures ts_init is at bar close | Grep + manual trace |
| `bars_timestamp_on_close` | True (default) | Bars timestamped when complete | Check adapter config |
| `bar_execution` | True | Simulates intrabar OHLC path | Check engine config |
| `bar_adaptive_high_low_ordering` | Document choice | Affects fill simulation | Check engine config |
| `bar_build_delay` | > 0 (if applicable) | Processing delay simulation | Check aggregator config |

#### Timestamp Semantics (ts_event vs ts_init)

```
ts_event = Bar CLOSING time (when bar is complete and emitted)
ts_init  = Initialization time of data object

Key Principle: Bars are only "finalized" at ts_event (close).
              Strategies cannot act on bars before ts_event.
```

#### Runtime Verification Code

Add to strategy for validation:

```python
def on_bar(self, bar: Bar) -> None:
    current_time = self.clock.utc_now()
    # ASSERTION: Should never process bar before it closes
    assert current_time >= bar.ts_event, f"Processing bar before close! current={current_time}, bar.ts_event={bar.ts_event}"
```

#### Verification Template

```markdown
## NautilusTrader Configuration Verification

### Data Wrangler
- File: [path]
- ts_init_delta: [value] (expected: bar_interval_ns = [X])
- Verified: YES/NO

### Backtest Engine
- File: [path]
- bar_execution: [value] (expected: True)
- bar_adaptive_high_low_ordering: [value] (document)
- Verified: YES/NO

### Data Adapter
- File: [path]
- bars_timestamp_on_close: [value] (expected: True or default)
- Verified: YES/NO

### Runtime Check Added
- Location: [strategy file:line]
- Added: YES/NO

### Overall: PASS / FAIL
```

---

### 13. Statistical Validation Metrics Protocol

#### Purpose
Define statistical thresholds from ARGUS research to validate strategy results are not overfit.

#### Required Metrics

| Metric | Full Name | Threshold | Red Flag | Source |
|--------|-----------|-----------|----------|--------|
| PBO | Probability of Backtest Overfitting | < 20% | > 50% | Bailey & Lopez de Prado |
| DSR | Deflated Sharpe Ratio | > 0 | < -0.5 | Bailey & Lopez de Prado 2014 |
| WFE | Walk-Forward Efficiency | >= 0.6 | < 0.4 | Existing project standard |
| SQN | System Quality Number | >= 2.0 | **> 7.0 = SUSPICIOUS (possible overfit)** | Existing project standard |
| PSR | Probabilistic Sharpe Ratio | >= 0.85 | < 0.5 | Existing project standard |
| MC95 DD | Monte Carlo 95th Percentile Drawdown | < 4% | > 4.5% | Project safety buffer |

**WARNING:** SQN > 7.0 is a RED FLAG indicating potential overfitting. Investigate thoroughly if observed.

#### PBO Calculation (Conceptual)

```
PBO = Probability that the optimal backtest parameter set
      will underperform the median OOS performance

Method: CPCV (Combinatorial Purged Cross-Validation)
- Generate all combinations of train/test splits
- For each: find best IS params, measure OOS
- PBO = fraction where best IS underperforms median OOS
```

#### DSR Calculation

```
DSR = SR * (1 - gamma * (SR_bias_correction))

where:
- SR = observed Sharpe Ratio
- gamma = adjustment for number of trials
- SR_bias_correction = correction for non-normality
```

#### Validation Template

```markdown
## Statistical Validation Results

### Strategy: [name]
### Validation Date: YYYY-MM-DD

| Metric | Value | Threshold | Red Flag | Status |
|--------|-------|-----------|----------|--------|
| PBO | X% | < 20% | > 50% | PASS/FAIL |
| DSR | X.XX | > 0 | < -0.5 | PASS/FAIL |
| WFE | X.XX | >= 0.6 | < 0.4 | PASS/FAIL |
| SQN | X.XX | >= 2.0 | > 7.0 SUSPICIOUS | PASS/FAIL/INVESTIGATE |
| PSR | X.XX | >= 0.85 | < 0.5 | PASS/FAIL |
| MC95 DD | X% | < 4% | > 4.5% | PASS/FAIL |

### OOS Period Consistency
| Period | Sharpe | Max DD | Profitable |
|--------|--------|--------|------------|
| 2020 Q1 | X.XX | X% | YES/NO |
| 2020 Q2 | X.XX | X% | YES/NO |
| ... | ... | ... | ... |

### Overall Statistical Validation: PASS / FAIL
```

---

### Integration with Existing Protocols

**Protocol 3 (Temporal Verification):** Add Pattern Detection (Protocol 11) as Step 0 before timestamp tracing.

**Protocol 7 (Checkpoint Trigger):** Now enforces Protocols 1-14 (updated from 1-10).

**Protocol 8 (Apex Verification):** Superseded by Protocol 14 for Apex-specific checks.

**Phase Plans:** Reference these protocols by number (e.g., "Apply Protocol 11 before review").

**Enforcement:** Protocols 11-14 are MANDATORY for all trading/risk/ML work. Non-compliance blocks phase completion.

---

## 14. Apex Prop Firm Compliance Protocol (ARGUS Integration 2025-12-16)

### Purpose
Comprehensive verification protocol derived from ARGUS research on prop firm failure modes. Ensures all Apex-specific rules are verified with TRADOVATE-specific considerations.

### Applicability
MANDATORY for all phases. This protocol supersedes generic compliance checks.

### User Context
- **Platform**: TRADOVATE (NOT RITHMIC)
- **Position Sizing**: SMALL (conservative approach)
- **Execution Bridge**: NinjaTrader (file-based OTP)
- **Compliance Target**: 100% - zero tolerance for errors

---

### A. Trailing Drawdown (CRITICAL)

**TRADOVATE-specific behavior: Trailing NEVER stops during evaluation**

| Rule | Value | Verification |
|------|-------|--------------|
| Trailing DD limit | 5% from HWM | [ ] Code uses 0.05 threshold |
| HWM includes unrealized | Every bar updates HWM | [ ] Bar-level HWM update confirmed (Note: Backtest uses bars; live uses ticks) |
| HWM never decreases | Once raised, permanent | [ ] No HWM reset logic except account reset |
| Safety buffer | HALT at 4.0% trailing | [ ] 0.04 threshold triggers HALT |
| Termination buffer | HALT at 4.5% total | [ ] 0.045 threshold triggers TERMINATE |

**Clarification: Bar vs Tick-level HWM**
- **Backtest**: Uses bar-level updates (NautilusTrader bar-driven)
- **Live**: Should use tick-level updates (real-time equity)
- **Implication**: Backtest may underestimate HWM spikes within bars

**Trailing DD Trap Example (must understand):**
```
$50k account, trade spikes to $52k unrealized:
- HWM = $52k (raised!)
- New floor = $49.4k ($52k x 0.95)
- Trade retraces to $50.1k realized
- Result: Only $700 buffer left (lost $1,400 from spike!)
```

**Verification Method:**
1. Trace HWM update code path
2. Confirm unrealized P/L included
3. Trace DD calculation: (HWM - CurrentEquity) / AccountSize
4. Verify buffer thresholds (4.0%, 4.5%)
5. Test scenario: spike then retrace

---

### B. Time Gates (CRITICAL)

| Gate | Time (ET) | Action | Verification |
|------|-----------|--------|--------------|
| Trade Block | 4:30 PM | No new entries | [ ] Block logic confirmed |
| Emergency Close Start | 4:55 PM | Begin closing all | [ ] Force close logic confirmed |
| Hard Close | 4:59 PM | All positions closed | [ ] Market order close confirmed |
| Auto-close disclaimer | N/A | Do NOT rely on Apex | [ ] EA closes independently |

**DST Handling:**
- [ ] Timezone = America/New_York (pytz or zoneinfo)
- [ ] DST transitions tested (spring forward, fall back)
- [ ] Server time used, not local time

**Edge Cases:**
- [ ] Position opened at 4:29:59 PM - flagged for monitoring
- [ ] Close order fails at 4:55 PM - retry every second
- [ ] Partial fill at 4:58 PM - market close remaining

---

### C. 30% Per-Trade Loss Rule (HIGH)

**Rule**: Open negative P/L cannot exceed 30% of profit balance

| Account State | Max Open Loss | Calculation |
|---------------|---------------|-------------|
| New ($0 profit) | $750 | 30% x $2,500 threshold |
| $1,000 profit | $300 | 30% x $1,000 |
| $5,000 profit | $1,500 | 30% x $5,000 |

**Verification:**
- [ ] Dynamic position sizing based on profit balance
- [ ] Per-trade loss limit enforced (not just daily)
- [ ] Aggregate open P/L tracking for multiple positions
- [ ] Buffer to 25% (slippage protection)

---

### D. 30% Consistency Rule (HIGH)

**Rule**: No single trading day can exceed 30% of total profit at payout

**Formula**: Highest Profit Day / 0.3 = Minimum Total Before Payout

| Best Day | Min Total Needed | Calculation |
|----------|------------------|-------------|
| $500 | $1,667 | $500 / 0.3 |
| $1,000 | $3,333 | $1,000 / 0.3 |
| $1,500 | $5,000 | $1,500 / 0.3 |

**Verification:**
- [ ] Daily profit tracking exists
- [ ] Consistency ratio computed: best_day / total_profit
- [ ] Warning at 25% of trailing threshold per day
- [ ] Hard cap implementation (reduce size or halt)

**Note**: Resets after each payout. No longer applies after 6th payout or Live transition.

---

### E. 5:1 Risk-Reward Enforcement (HIGH)

**Rule**: SL cannot exceed 5x TP

| TP (ticks) | Max SL (ticks) | Example |
|------------|----------------|---------|
| 5 | 25 | 5 tick target = max 25 tick stop |
| 10 | 50 | 10 tick target = max 50 tick stop |
| 20 | 100 | 20 tick target = max 100 tick stop |

**Verification:**
- [ ] R:R validation at trade entry
- [ ] Parameter validation prevents >5:1
- [ ] Conservative recommendation: cap at 4:1
- [ ] Logging of actual R:R per trade

---

### F. Contract Scaling Rule (PA Only)

**Rule**: Trade 50% of max contracts until safety net reached

| Account | Max Contracts | Until Safety Net |
|---------|---------------|------------------|
| $50k | 10 | 5 contracts max |
| $100k | 20 | 10 contracts max |

**Note**: User plans small position sizes, so this is lower priority but must be verified if max size is used.

**Verification:**
- [ ] Contract limiter based on account state
- [ ] Safety net reached = EOD balance at $52,600 ($50k + $2,500 + $100)
- [ ] Always round DOWN on contract count

---

### G. News Blackout Windows (HIGH)

**Gold-specific risk during high-impact news:**
- Normal spread: 12-20 pips
- During news: 100-200+ pips
- Peak observed: 800+ pips slippage

| Event | Blackout Window | Verification |
|-------|-----------------|--------------|
| NFP | 10 min before/after | [ ] |
| CPI | 10 min before/after | [ ] |
| FOMC | 10 min before/after | [ ] |
| Fed Speeches | 5 min before/after | [ ] |

**Verification:**
- [ ] Economic calendar integration
- [ ] Real-time spread monitoring
- [ ] Spread threshold for trade blocking (e.g., >50 pips = block)
- [ ] News direction rule: only ONE direction during event

---

### H. Platform Error Handling (TRADOVATE-specific)

| Error Message | Meaning | Required Action |
|---------------|---------|-----------------|
| "Order can be placed by administrators only" | **ACCOUNT BLOWN** | HALT, alert, no retry |
| "Send cancels only after 30 secs" | Rate limited | 30s cooldown |
| "The OCO ID cannot be reused" | OCO issue | Disable OCO mode |
| "Atomic order operation in progress" | Order in flight | Queue changes |
| "Session count to exceed maximum" | Multiple logins | Single session only |

**Verification:**
- [ ] Error message parsing exists
- [ ] Account-blown detection and HALT
- [ ] Rate limiting on order modifications
- [ ] Reconnection with exponential backoff

---

### I. Automation Prohibition Awareness

**CRITICAL FINDING**: Automation is BANNED on PA/Live accounts

| Phase | Automation Status |
|-------|-------------------|
| Evaluation | Grey area (not explicitly banned) |
| PA (Performance Account) | **BANNED** |
| Live Account | **BANNED** |

**Mitigation Options:**
1. Use EA for evaluation only, manual for PA/Live
2. Convert to semi-auto: EA signals, human executes
3. Different prop firm (find one allowing automation)

**Detection Methods (suspected):**
- Trade execution timing patterns
- Order placement consistency (too perfect)
- No mouse movement during active trading
- Trade journal analysis (no notes = suspicious)

**Verification:**
- [ ] Awareness documented in strategy docs
- [ ] Semi-auto mode planned for PA/Live (if proceeding)
- [ ] Trade journal automation for compliance

---

### J. Slippage Buffer Requirements

**Gold gap statistics:**
- Average daily gap: 0.64% (more than double SPY)
- Weekend gaps: 1-3% possible
- Session open gaps: 0.3-0.5% common

| Scenario | Buffer Recommendation |
|----------|----------------------|
| Normal sizing | Size for 150% of planned SL |
| News events | No positions OR 200% buffer |
| Pre-weekend | Close all positions |
| Session open | Wait 5-10 min after open |

**Verification:**
- [ ] Slippage buffer in position sizing
- [ ] Commission tracking in DD calculation
- [ ] Gap scenario awareness in risk modules

---

### Apex Compliance Summary Template

```markdown
## Apex Prop Firm Compliance Report

### Platform: TRADOVATE

### A. Trailing Drawdown
- HWM includes unrealized: [YES/NO]
- Tick-level update: [YES/NO]
- 4.0% HALT threshold: [YES/NO]
- TRADOVATE eternal trailing: [HANDLED/NOT HANDLED]
- Verdict: [PASS/FAIL]

### B. Time Gates
- 4:30 PM block: [YES/NO]
- 4:55 PM emergency: [YES/NO]
- 4:59 PM hard close: [YES/NO]
- DST handling: [YES/NO]
- Verdict: [PASS/FAIL]

### C. 30% Per-Trade Loss
- Dynamic limit: [YES/NO]
- Buffer to 25%: [YES/NO]
- Verdict: [PASS/FAIL]

### D. 30% Consistency
- Daily tracking: [YES/NO]
- Ratio monitoring: [YES/NO]
- Verdict: [PASS/FAIL]

### E. 5:1 R:R
- Validation at entry: [YES/NO]
- Conservative cap (4:1): [YES/NO]
- Verdict: [PASS/FAIL]

### F. Contract Scaling
- 50% limit until safety net: [YES/NO/N/A]
- Verdict: [PASS/FAIL/N/A]

### G. News Blackout
- Calendar integration: [YES/NO]
- Spread monitoring: [YES/NO]
- Verdict: [PASS/FAIL]

### H. Error Handling
- Account-blown detection: [YES/NO]
- Rate limiting: [YES/NO]
- Verdict: [PASS/FAIL]

### Overall Apex Compliance: [PASS / FAIL / PARTIAL]
```
