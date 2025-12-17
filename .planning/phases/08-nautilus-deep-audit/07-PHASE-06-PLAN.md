# PLAN: Phase 06 - Backtest Scripts Audit

> **Changelog:**
> - 2025-12-17: **CRITICAL** - Added mandatory delegation enforcement (Protocol 0). Orchestrator MUST NOT read source files directly.
> - 2025-12-16 (v2): Fixed R-001 through R-006 from CRITIC re-review (agent type, synthesis step, time gates, look-ahead protocol, orchestration protocol, blocking criteria)
> - 2025-12-16 (v1): Applied CRITIC v1.1 review fixes (C-001 through C-010)

---

## ⚠️ MANDATORY DELEGATION (Protocol 0)

> **CRITICAL: The orchestrator MUST NOT read source files directly.**
>
> This phase analyzes ~9,393 lines of backtest code across 11+ files. Reading these files directly will cause severe context overflow.

### Orchestrator Behavior

```
❌ WRONG (causes context overflow):
   Orchestrator reads 11 backtest scripts directly
   Orchestrator performs look-ahead detection in main context
   → CONTEXT OVERFLOW → Summarization → MISSED DATA LEAKAGE

✅ CORRECT (sustainable):
   Orchestrator spawns REVIEWER sub-agents with delegation prompt
   Each REVIEWER reads assigned files, checks for leakage, writes findings
   Each REVIEWER returns 300-word summary to orchestrator
   Orchestrator synthesizes and updates MANIFEST.md
```

### Required Sub-Agent Prompts

**Round 1 - Agent A (Core EA Logic):**
```
Execute Phase 06 Round 1 Agent A (Core EA Logic) of the Nautilus Deep Audit.

DELEGATION PROTOCOL (MANDATORY):
1. YOU read the source file - orchestrator has NOT read it
2. File to analyze: scripts/backtest/strategies/ea_logic_full.py (2696 lines)
3. Focus: MQL5 parity, look-ahead detection, Apex time gates
4. Write COMPLETE analysis to: .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_06_R1_A_EALOGIC_FINDINGS.md
5. Return ONLY summary (max 300 words) with issue counts and leakage status

Plan file: .planning/phases/08-nautilus-deep-audit/07-PHASE-06-PLAN.md
```

**Round 1 - Agent B (Alternative Strategies):**
```
Execute Phase 06 Round 1 Agent B (Alternative Strategies) of the Nautilus Deep Audit.

DELEGATION PROTOCOL (MANDATORY):
1. YOU read the source files - orchestrator has NOT read them
2. Files to analyze:
   - scripts/backtest/strategies/ea_logic_python.py (704 lines)
   - scripts/backtest/strategies/adaptive_kelly.py (541 lines)
   - scripts/backtest/strategies/ea_logic_compat.py (313 lines)
3. Focus: Consistency with main strategy, Kelly implementation
4. Write COMPLETE analysis to: .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_06_R1_B_ALTSTRAT_FINDINGS.md
5. Return ONLY summary (max 300 words) with issue counts

Plan file: .planning/phases/08-nautilus-deep-audit/07-PHASE-06-PLAN.md
```

**Round 1 - Agent C (Analysis Strategies):**
```
Execute Phase 06 Round 1 Agent C (Analysis Strategies) of the Nautilus Deep Audit.

DELEGATION PROTOCOL (MANDATORY):
1. YOU read the source files - orchestrator has NOT read them
2. Files to analyze:
   - scripts/backtest/strategies/fibonacci_analyzer.py (539 lines)
   - scripts/backtest/strategies/spread_analyzer.py (451 lines)
3. Focus: Fibonacci/spread analysis correctness, temporal integrity
4. Write COMPLETE analysis to: .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_06_R1_C_ANALYSIS_FINDINGS.md
5. Return ONLY summary (max 300 words) with issue counts

Plan file: .planning/phases/08-nautilus-deep-audit/07-PHASE-06-PLAN.md
```

**Round 2 - Validation Scripts (separate prompts for each agent as defined in plan)**

---

## Objective
Critical analysis of all backtest scripts and strategies to identify data leakage, unrealistic assumptions, and consistency issues with the main strategy.

## Prerequisites (MANDATORY - before spawning agents)

### File Verification
Run the following to verify all files exist:
```bash
ls -la scripts/backtest/strategies/ea_logic_full.py \
       scripts/backtest/strategies/ea_logic_python.py \
       scripts/backtest/strategies/adaptive_kelly.py \
       scripts/backtest/strategies/fibonacci_analyzer.py \
       scripts/backtest/strategies/spread_analyzer.py \
       scripts/backtest/strategies/ea_logic_compat.py \
       scripts/backtest/monte_carlo_degradation.py \
       scripts/backtest/wfa_filter_study.py \
       scripts/backtest/realistic_backtester.py \
       scripts/backtest/stress_test_degradation.py \
       scripts/backtest/multi_year_backtest.py
```

### Comparison Baseline
**Reference:** `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
**Git Hash:** (Record at execution time with `git log -1 --format=%H -- nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`)

## Files Under Review

### Primary Strategies (scripts/backtest/strategies/)
| File | Lines | Priority |
|------|-------|----------|
| `ea_logic_full.py` | 2696 | P0 - CRITICAL |
| `ea_logic_python.py` | 704 | P1 |
| `adaptive_kelly.py` | 541 | P1 |
| `fibonacci_analyzer.py` | 539 | P1 |
| `spread_analyzer.py` | 451 | P2 |
| `ea_logic_compat.py` | 313 | P2 |
| `__init__.py` | 78 | P3 |

**Subtotal:** ~5,322 lines

### Key Backtest Scripts (scripts/backtest/)
| File | Lines | Priority | Focus |
|------|-------|----------|-------|
| `monte_carlo_degradation.py` | 251 | P0 | MC implementation |
| `wfa_filter_study.py` | 600 | P0 | Walk-forward validation |
| `realistic_backtester.py` | 1280 | P0 | Realistic simulation |
| `stress_test_degradation.py` | 155 | P1 | Stress testing |
| `multi_year_backtest.py` | 143 | P1 | Long-term validation |
| `ablation_study.py` | 1057 | P2 | Component analysis |
| `comprehensive_validation.py` | 585 | P2 | Full validation |

**Subtotal:** ~4,071 lines

## Execution Plan

### Round 1: Core Strategies (3 agents max)

**Agent A:** Core EA Logic
- `ea_logic_full.py` (2696 lines - largest!)
- Focus: MQL5 parity, logic correctness
- **Scope:** 2,696 lines

**Agent B:** Alternative Strategies
- `ea_logic_python.py` (704 lines)
- `adaptive_kelly.py` (541 lines)
- `ea_logic_compat.py` (313 lines)
- Focus: Consistency with main, Kelly implementation
- **Scope:** 1,558 lines

**Agent C:** Analysis Strategies
- `fibonacci_analyzer.py` (539 lines)
- `spread_analyzer.py` (451 lines)
- Focus: Fibonacci/spread analysis correctness
- **Scope:** 990 lines

### Round 2: Validation Scripts (2 agents max)

**Agent D:** Statistical Validation
- `monte_carlo_degradation.py` (251 lines)
- `wfa_filter_study.py` (600 lines)
- Focus: Statistical validity
- **Scope:** 851 lines

**Agent E:** Backtester Scripts
- `realistic_backtester.py` (1280 lines)
- `stress_test_degradation.py` (155 lines)
- `multi_year_backtest.py` (143 lines)
- Focus: Realistic simulation
- **Scope:** 1,578 lines

## CRITICAL ANALYSIS AREAS

### Data Leakage Detection (MOST CRITICAL)

**BLOCKING CRITERIA:** Any confirmed look-ahead bias = PHASE FAIL (must fix before proceeding)

**Common Look-Ahead Patterns:**
1. Using `bars[i+1]` instead of `bars[i-1]`
2. Future data in indicator warmup
3. Perfect fill assumptions
4. Using close price for entry when should be open
5. News data known before release time

**Questions:**
- Is bar indexing consistent?
- Are indicators using only completed bars?
- Is spread known before trade?
- Are fills at bid/ask or mid?

**Look-Ahead TEST Protocol:**
For each signal generation function, trace the data flow:
1. Identify all data access points (bar indices, indicator calls)
2. For each access: document the bar offset (0 = current, -1 = previous, +1 = FUTURE)
3. Any +offset access = CRITICAL look-ahead violation
4. Check indicator warmup: does it use future bars during initialization?
5. Verify trade execution uses bar[0].open (not bar[0].close for entry)

### Consistency with Main Strategy

**Compare Against:**
- `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`

**Comparison Scope:**
1. Signal generation logic (SMC concepts, entry triggers)
2. Threshold values (pip distances, ATR multipliers)
3. Risk sizing (lot calculation, position limits)
4. Time gate logic (if present)

**Handling Intentional Differences:**
- Document any variants being tested
- Flag with "INTENTIONAL_DIFF" in findings

**Questions:**
- Do backtest strategies use same logic?
- Are thresholds identical?
- Same indicator implementations?
- Same risk management?

### Realistic Simulation

**Slippage Reference Values (XAUUSD):**
- Normal conditions: 0.5-2 pips
- News/high volatility: 5-10 pips
- Should be variable, not fixed

**Spread Reference Values (XAUUSD):**
- Normal conditions: 1-3 pips
- Asia session: wider (3-5 pips)
- News events: significantly wider (10+ pips)
- Should be session-based and variable

**Commission Reference:**
- Typical: $7-10 per standard lot round-trip
- Or equivalent built into spread

**Fills:**
- Partial fills modeled?
- Rejections modeled?
- Latency accounted for?

### Monte Carlo Correctness

**Minimum Requirements:**
- At least 1000 simulations
- Bootstrap with replacement (preserves sequence structure) OR trade shuffling (destroys serial correlation - document which)

**Questions:**
- Randomization method?
- Number of simulations?
- What is randomized (trades? returns? order?)?
- Bootstrap vs permutation?
- Confidence intervals correct?

### Walk-Forward Correctness

**Questions:**
- In-sample/out-of-sample split?
- No data leakage between periods?
- Optimization metric?
- WFE calculation correct?
- Anchored vs rolling?

**Additional Requirements:**
- Embargo period between train/test? (Required for overlapping features)
- Purging applied for lookback features? (Required to prevent leakage)
- Minimum OOS sample size: 50 trades recommended

## CRITIC Checklist

### EA Logic (ea_logic_full.py)
| Check | Status |
|-------|--------|
| No look-ahead bias | [ ] |
| Matches MQL5 logic | [ ] |
| Same thresholds as main | [ ] |
| **Apex: Block new trades after 4:30 PM ET** | [ ] |
| **Apex: Emergency force-close from 4:55 PM ET** | [ ] |
| **Apex: 4:59 PM ET close enforced** | [ ] |
| **Apex: Trailing DD from HIGH-WATER MARK** | [ ] |
| **Apex: Unrealized P/L included in DD** | [ ] |
| **Apex: 30% consistency rule checked** | [ ] |
| Slippage modeled | [ ] |
| Spread modeled | [ ] |

### Monte Carlo
| Check | Status |
|-------|--------|
| Randomization valid | [ ] |
| Sufficient simulations (>= 1000) | [ ] |
| CI calculation correct | [ ] |
| No data contamination | [ ] |
| Bootstrap/shuffling method documented | [ ] |

### Walk-Forward
| Check | Status |
|-------|--------|
| Clean IS/OOS split | [ ] |
| No future data in IS | [ ] |
| WFE formula correct | [ ] |
| Anchored/rolling documented | [ ] |
| **Embargo period applied** | [ ] |
| **Purging for lookback features** | [ ] |
| **Minimum OOS sample size (50 trades)** | [ ] |

### Realistic Backtester
| Check | Status |
|-------|--------|
| Slippage realistic (0.5-2 pips normal, 5-10 news) | [ ] |
| Spread realistic (session-based, variable) | [ ] |
| Fills realistic | [ ] |
| Latency modeled | [ ] |
| Commission correct ($7-10/lot) | [ ] |

## Specific Questions

1. **ea_logic_full.py (2696 lines)**: Why is this separate from main strategy? Duplication risk?

2. **adaptive_kelly.py**: Kelly criterion implementation - is it correct for trading?

3. **wfa_filter_study.py**: What filters are being studied? Is purging done correctly?

4. **monte_carlo_degradation.py**: What type of MC? (Shuffled trades? Bootstrap? Path-dependent?)

5. **realistic_backtester.py**: How realistic? What assumptions?

## Success Criteria
- [ ] All backtest strategies reviewed
- [ ] No data leakage found OR documented with fix
- [ ] Consistency with main strategy verified
- [ ] Monte Carlo implementation validated
- [ ] Walk-forward implementation validated
- [ ] Realistic simulation verified
- [ ] `PHASE_06_FINDINGS.md` completed

## Agents

**Round 1:** 3 parallel REVIEWER agents (model: opus) - Agents A, B, C
**Round 2:** 2 parallel REVIEWER agents (model: opus) - Agents D, E
**Synthesis:** Orchestrator consolidates all 5 agent outputs into PHASE_06_FINDINGS.md

**Agent Requirements:**
- Each handles specific files per assignment
- Must apply CRITIC self-review internally
- Focus on data leakage and consistency
- Use defined output format below
- Follow orchestration output protocol (see CLAUDE.md orchestration_output_protocol)

**Orchestration Output Protocol:**
Per CLAUDE.md, each agent MUST:
1. Write COMPLETE analysis to: `.planning/phases/08-nautilus-deep-audit/orchestration/AGENT_[A-E]_output.md`
2. Return ONLY a SUMMARY (max 300 words) to chat containing:
   - Top 3-5 key findings
   - Severity counts: CRITICAL/HIGH/MEDIUM/LOW
   - Output file path
   - Status: COMPLETE/PARTIAL/FAILED

## Agent Output Format

Each agent MUST structure findings as:

```markdown
## [AGENT_ID] Findings

### Summary
- Files reviewed: [list]
- Total lines: [count]
- Issues found: [CRITICAL: N, HIGH: N, MEDIUM: N, LOW: N]

### Issues

| ID | Severity | File:Line | Description | Recommended Fix |
|----|----------|-----------|-------------|-----------------|
| A-001 | CRITICAL | ea_logic_full.py:123 | Look-ahead: uses bars[i+1] | Change to bars[i-1] |
| ... | ... | ... | ... | ... |

### Checklist Status
[Paste relevant checklist with checkboxes filled]

### Notes
[Any additional observations]
```

## Output
`PHASE_06_FINDINGS.md` in this directory

---

## CRITIC FINAL REVIEW (2025-12-16)

### Issues Verification
| ID | Issue | Status |
|----|-------|--------|
| R-001 | Agent type REVIEWER | FIXED - Lines 263-264 specify "REVIEWER agents (model: opus)" |
| R-002 | Synthesis step | FIXED - Line 265 explicitly states orchestrator consolidation |
| R-003 | All 3 time gates | FIXED - Lines 202-204 include 4:30 PM, 4:55 PM, 4:59 PM ET |
| R-004 | Look-ahead test protocol | FIXED - Lines 116-122 provide 5-step concrete protocol |
| R-005 | Output protocol reference | FIXED - Lines 272-281 reference CLAUDE.md and spell out requirements |
| R-006 | Blocking criteria | FIXED - Line 101 defines clear PHASE FAIL criterion |

### New Issues Found
| ID | Severity | Description |
|----|----------|-------------|
| R-007 | MEDIUM | Two P2 files listed in overview (ablation_study.py:1057, comprehensive_validation.py:585) are not assigned to any agent. Likely intentional scope reduction for Phase 06. Orchestrator may add Round 3 or defer to follow-up phase. |

### Verification Notes
- All 6 original issues from re-review properly addressed
- Agent workload distribution is reasonable (max 2696 lines per agent)
- Prerequisite checks included (file verification, git hash baseline)
- APEX compliance checks are thorough (trailing DD, HWM, unrealized P/L, 30% rule, all 3 time gates)
- Orchestration output protocol properly referenced with file paths and summary requirements

### Final Verdict
**APPROVED**

Plan is ready for execution. The MEDIUM observation (R-007) is noted but not blocking - P2 files can be addressed in a follow-up phase or by orchestrator discretion during execution.
