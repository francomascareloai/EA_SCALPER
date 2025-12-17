# PLAN: Phase 02 - SMC Indicators Audit

> **Changelog:**
> - 2025-12-17: **CRITICAL** - Added mandatory delegation enforcement (Protocol 0). Orchestrator MUST NOT read source files directly.
> - 2025-12-16: Applied CRITIC review fixes (C-001 through C-010). Added Round 0 for mtf_manager, temporal verification protocol, orchestration output protocol, dependency graph, performance thresholds. Made look-ahead bias BLOCKING.

---

## ⚠️ MANDATORY DELEGATION (Protocol 0)

> **CRITICAL: The orchestrator MUST NOT read source files directly.**
>
> This phase analyzes ~4,391 lines of code across 9 files. Reading these files directly into the orchestrator's context will cause context overflow.

### Orchestrator Behavior

```
❌ WRONG (causes context overflow):
   Orchestrator reads 9 indicator files directly
   Orchestrator performs temporal verification in main context
   → CONTEXT OVERFLOW → Summarization → LOST DETAILS

✅ CORRECT (sustainable):
   Orchestrator spawns FORGE sub-agents with delegation prompt
   Each agent reads assigned files, analyzes, writes findings to disk
   Each agent returns 300-word summary to orchestrator
   Orchestrator updates MANIFEST.md
```

### Required Sub-Agent Prompts

**Round 0 - MTF Manager (BLOCKING):**
```
Execute Phase 02 Round 0 of the Nautilus Deep Audit.

DELEGATION PROTOCOL (MANDATORY):
1. YOU read the source file - orchestrator has NOT read it
2. File to analyze: nautilus_gold_scalper/src/indicators/mtf_manager.py (~670 lines)
3. Focus: Bar completion detection, HTF timestamp alignment, temporal integrity
4. Write COMPLETE analysis to: .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_02_R0_MTF_FINDINGS.md
5. Return ONLY summary (max 300 words) with issue counts and status
6. If look-ahead bias found: report BLOCKED immediately

Plan file: .planning/phases/08-nautilus-deep-audit/03-PHASE-02-PLAN.md
```

**Round 1 - Parallel Agents (A, B, C):**
```
Execute Phase 02 Round 1 Agent [A/B/C] of the Nautilus Deep Audit.

DELEGATION PROTOCOL (MANDATORY):
1. YOU read the source files - orchestrator has NOT read them
2. Files to analyze: [list from plan]
3. Follow temporal verification protocol in plan
4. Write COMPLETE analysis to: .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_02_R1_[A/B/C]_FINDINGS.md
5. Return ONLY summary (max 300 words) with issue counts and status

Plan file: .planning/phases/08-nautilus-deep-audit/03-PHASE-02-PLAN.md
```

---

## Objective
Critical analysis of all Smart Money Concepts (SMC) indicators to verify correctness, temporal integrity, and performance.

## Files Under Review

| File | Lines | Responsibility |
|------|-------|----------------|
| `amd_cycle_tracker.py` | ~250 | AMD cycle detection |
| `footprint_analyzer.py` | ~450 | Order flow analysis |
| `fvg_detector.py` | ~562 | Fair Value Gap detection |
| `liquidity_sweep.py` | ~611 | Liquidity hunt detection |
| `mtf_manager.py` | ~670 | Multi-timeframe management |
| `order_block_detector.py` | ~617 | Order Block detection |
| `regime_detector.py` | ~377 | Market regime classification |
| `session_filter.py` | ~233 | Trading session filtering |
| `structure_analyzer.py` | ~621 | Market structure analysis |

**Total:** ~4,391 lines

## Indicator Dependency Graph

**Core Dependencies (must be reviewed first):**
```
mtf_manager.py
  └── Used by: ALL indicators (provides multi-timeframe bar access)

structure_analyzer.py
  └── Used by: order_block_detector.py, fvg_detector.py, liquidity_sweep.py
  └── Provides: BOS/CHoCH, swing points, structure context

regime_detector.py
  └── Used by: Signal filtering in strategy layer
  └── Provides: Market regime classification
```

**Import Analysis Required:**
Each agent must trace `from ... import` statements to identify cross-dependencies.

## Execution Plan

### Round 0: MTF Manager Review (BLOCKING)

**Why First:** `mtf_manager.py` is the core dependency for ALL indicators. If MTF has look-ahead bias, every indicator inherits it. This MUST be verified clean before parallel review.

**Agent MTF:** `mtf_manager.py` only (~670 lines)
- Verify bar completion detection
- Trace HTF bar timestamp alignment
- Check `on_bar` vs `on_quote_tick` handling
- Verify NO forming bar access

**Gate:** Round 1 only proceeds if MTF is verified CLEAN for temporal integrity.

### Round 1: Parallel Indicator Review (3 Agents)

After MTF is verified, spawn 3 parallel agents:

**Agent A:** `amd_cycle_tracker.py` + `regime_detector.py` + `session_filter.py` + `footprint_analyzer.py`
- Market context + order flow indicators
- ~1,310 lines total

**Agent B:** `order_block_detector.py` + `fvg_detector.py`
- SMC zone detection
- ~1,179 lines total

**Agent C:** `liquidity_sweep.py` + `structure_analyzer.py`
- Liquidity and structure analysis
- ~1,232 lines total

**Workload Balance:** A=1,310 | B=1,179 | C=1,232 (variance ~10%, acceptable)

## Temporal Verification Protocol (MANDATORY)

**Every agent MUST follow this protocol for EACH indicator:**

### Step 1: Identify All Data Access Points
- Search for: `bars[`, `.iloc[`, `DataFrame`, `on_bar`, `on_quote_tick`
- Document every line that accesses bar/price data

### Step 2: Verify Each Access
| Access Pattern | Valid? | Explanation |
|----------------|--------|-------------|
| `bars[-1]` | ONLY IF | Bar is COMPLETED (not forming) |
| `bars[-2]` | YES | Always completed (previous bar) |
| `DataFrame.iloc[-1]` | ONLY IF | DataFrame excludes current forming bar |
| MTF access | ONLY IF | `HTF_bar.timestamp < current_LTF_bar.timestamp` |

### Step 3: Trace 3 Random Timestamps
1. Pick 3 random historical timestamps
2. For each, trace what data would be available at that moment
3. Verify indicator only uses data that EXISTED at that moment
4. Document findings with `file:line` references

### Step 4: Document Findings
```
## Temporal Integrity: [indicator_name]
- Data access points: [count] identified
- Violations found: [count]
- Details:
  - Line X: [description] - VIOLATION / CLEAN
```

## NautilusTrader-Specific Checks

All agents must verify:
- `Bar.is_complete` property usage (if available)
- `on_bar()` handler receives completed bars only
- `on_quote_tick()` does not access bar data directly
- Actor lifecycle: `on_start()`, `on_stop()`, `on_reset()` properly implemented
- Historical data warmup: `self.request_bars()` or similar

## CRITIC Focus Areas (All Agents)

### 1. SMC Logic Correctness
- Order Block definition matches ICT concepts?
- FVG detection rules accurate?
- Liquidity sweep identification correct?
- AMD cycle (Accumulation -> Manipulation -> Distribution) logic?
- **Advanced SMC:** Breaker blocks, IFVG, internal vs external structure, premium/discount zones

### 2. Temporal Integrity (CRITICAL - BLOCKING)
- **NO LOOK-AHEAD**: Does indicator use only completed bars?
- Bar indexing: `bars[-1]` is current COMPLETED, `bars[-2]` is previous?
- MTF alignment: HTF bar completed before LTF uses it?
- **Follow Temporal Verification Protocol above**

### 3. Edge Cases
- Thin market handling (low tick count)
- News spike behavior
- Gap handling (overnight, weekend)
- Session boundaries
- First bar after warmup

### 4. Performance
- Vectorized operations vs loops?
- Caching of expensive calculations?
- Memory usage for bar storage?
- **Threshold:** Indicator method call < 0.5ms

### 5. State Management
- Indicator state reset between sessions?
- Historical data requirements clear?
- Warmup period defined and sufficient?

## CRITIC Checklist per Indicator

| Check | Notes |
|-------|-------|
| Uses only completed bars | [ ] |
| Temporal Verification Protocol applied | [ ] |
| Bar indexing documented | [ ] |
| Edge cases handled | [ ] |
| Performance < 0.5ms per call | [ ] |
| State reset mechanism | [ ] |
| Dependencies clear | [ ] |
| Unit tests exist AND pass | [ ] |

## Specific Questions to Answer

### Order Block Detector
1. How is "imbalance" measured?
2. What defines OB validity?
3. How long does OB stay valid?
4. Mitigation detection correct?
5. Breaker block transformation logic?

### FVG Detector
1. Gap threshold configuration?
2. Partial fill handling?
3. Expiration mechanism?
4. IFVG (Inverted FVG) detection?

### Liquidity Sweep
1. Equal highs/lows tolerance?
2. Sweep confirmation logic?
3. False sweep filtering?
4. Internal vs external liquidity?

### Regime Detector
1. Regime classification accuracy?
2. Transition smoothing?
3. Volatile regime handling?

### Structure Analyzer
1. BOS/CHoCH detection rules?
2. Swing point identification?
3. Structure break confirmation?
4. Internal vs external structure?
5. Premium/discount zone calculation?

### AMD Cycle Tracker
1. Cycle phase detection accuracy?
2. Transition timing?
3. Integration with trading signals?

### Footprint Analyzer
1. Delta calculation correctness?
2. Imbalance thresholds?
3. Data requirements?

### MTF Manager
1. Timeframe synchronization?
2. Bar completion detection?
3. Data consistency across TFs?
4. HTF bar timestamp vs LTF alignment?

### Session Filter
1. Timezone handling (ET vs UTC)?
2. DST transitions?
3. Holiday detection?

## Success Criteria

- [ ] All 9 indicators reviewed with Temporal Verification Protocol
- [ ] **No look-ahead bias found (BLOCKING)** - any violation must be fixed before phase completes
- [ ] Edge cases catalogued
- [ ] Performance < 0.5ms verified or bottlenecks identified with fix plan
- [ ] Unit tests exist AND pass
- [ ] `PHASE_02_FINDINGS.md` completed

## Orchestration Output Protocol

**Session Folder:** `.planning/phases/08-nautilus-deep-audit/orchestration/phase-02/`

### Agent Output Requirements

Each agent writes COMPLETE analysis to:
- `Agent_MTF_output.md` (Round 0)
- `Agent_A_output.md` (Round 1)
- `Agent_B_output.md` (Round 1)
- `Agent_C_output.md` (Round 1)

**Agent Response to Chat:** Max 300 words containing:
1. Top 3-5 key findings
2. Severity counts: CRITICAL/HIGH/MEDIUM/LOW
3. Output file path
4. Status: COMPLETE/PARTIAL/FAILED

### Consolidation Step

After all agents complete, orchestrator:
1. Reads all `Agent_*_output.md` files
2. Creates `MANIFEST.md` with summary table
3. Synthesizes into `PHASE_02_FINDINGS.md`
4. Cross-validates findings for consistency

### Re-Review Trigger

If Agent MTF (Round 0) finds temporal integrity issues:
- HALT Round 1
- Fix MTF issues first
- Then proceed with Round 1

If any Round 1 agent finds cross-dependency issues:
- Document in their output
- Flag for consolidation review
- May trigger targeted re-review of affected indicators

## Agents

**Round 0:** 1 FORGE agent (model: opus)
- MTF Manager review
- Must apply CRITIC self-review internally
- Gate for Round 1

**Round 1:** 3 parallel FORGE agents (model: opus)
- Each handles 2-4 indicators (balanced workload)
- Must apply CRITIC self-review internally
- Must document all assumptions challenged

## Output

1. Individual outputs in `orchestration/phase-02/Agent_*.md`
2. Consolidated `MANIFEST.md`
3. Final `PHASE_02_FINDINGS.md` in this directory

---

## CRITIC RE-REVIEW (2025-12-16)

### Previous Issues Status

| ID | Issue | Status |
|----|-------|--------|
| C-001 | Missing Round 0 for MTF Manager (core dependency) | FIXED |
| C-002 | No Temporal Verification Protocol | FIXED |
| C-003 | Missing Orchestration Output Protocol | FIXED |
| C-004 | Missing Dependency Graph | FIXED |
| C-005 | No Performance Thresholds | FIXED |
| C-006 | Look-ahead not marked BLOCKING | FIXED |
| C-007 | Missing workload balance justification | FIXED |
| C-008 | Missing model specification for agents | FIXED |
| C-009 | Missing CRITIC self-review requirement | FIXED |
| C-010 | Missing re-review triggers | FIXED |

### New Issues Found

None.

### Minor Observations (Non-Blocking)

1. Dependency graph covers core indicators but not all (leaf nodes like `session_filter` omitted - agents will discover during audit)
2. Agent A has 4 files vs 2 for B/C (lines balanced at ~10% variance, acceptable)

### Verdict

**APPROVED** - Plan is ready for execution.

---

## ARGUS Integration: Look-Ahead Detection (2025-12-16)

### Source
`.planning/phases/08-nautilus-deep-audit/research/ARGUS_LOOKAHEAD_DETECTION.md`

### Dangerous Pattern Grep Commands (MANDATORY)

Run these grep commands against ALL indicator files during review. Any match requires investigation.

```bash
# Navigate to project root
cd /home/franco/projetos/EA_SCALPER_XAUUSD

# Pattern 1: Forward-looking shift (CRITICAL - any match is likely a bug)
rg "\.shift\s*\(\s*-\d" --type py nautilus_gold_scalper/

# Pattern 2: Forward-looking rolling
rg "rolling.*\.shift\s*\(\s*-" --type py nautilus_gold_scalper/

# Pattern 3: Full-sample statistics (requires manual review for context)
rg "\.mean\(\)|\.std\(\)|\.min\(\)|\.max\(\)" --type py nautilus_gold_scalper/indicators/

# Pattern 4: Close price used for same-bar decision (manual review)
rg "if.*close.*:|close.*>|close.*<" --type py nautilus_gold_scalper/

# Pattern 5: Nautilus timestamp configuration
rg "timestamp_on_close|ts_init_delta|bar_execution" --type py nautilus_gold_scalper/

# Pattern 6: Bar adaptive ordering
rg "bar_adaptive_high_low_ordering|bar_build_delay" --type py nautilus_gold_scalper/
```

### Grep Pattern Checklist (per Indicator)

| Pattern | Command | Status | Notes |
|---------|---------|--------|-------|
| Forward shift(-N) | `rg "\.shift\s*\(\s*-\d"` | [ ] | Any match = CRITICAL |
| Forward rolling | `rg "rolling.*\.shift\s*\(\s*-"` | [ ] | Any match = CRITICAL |
| Full-sample stats | `rg "\.mean\(\)|\.std\(\)"` | [ ] | Review context |
| Close-based decision | `rg "if.*close"` | [ ] | Check execution timing |
| Timestamp config | `rg "timestamp_on_close"` | [ ] | Must be True or default |

### NautilusTrader Configuration Checklist

Verify these configurations in data wranglers, backtest engine, and adapters:

| Config | Required Value | Location Pattern | Status |
|--------|---------------|------------------|--------|
| `ts_init_delta` | = bar_interval_ns | BarDataWrangler init | [ ] |
| `bars_timestamp_on_close` | True (or default) | Adapter/data config | [ ] |
| `bar_execution` | True | BacktestEngineConfig | [ ] |
| `bar_adaptive_high_low_ordering` | Document choice | BacktestEngineConfig | [ ] |
| `bar_build_delay` | > 0 (if applicable) | TimeBarAggregator | [ ] |

### Signal Lagging Requirements

All signals MUST use `.shift(1)` or equivalent to act on COMPLETED bars only:

| Data Type | Required Lag | Rationale |
|-----------|--------------|-----------|
| Technical signals | 1 bar | Signal from bar T, trade at bar T+1 |
| SMC zones (OB/FVG) | 0 bars* | Zone from completed bar, entry on next bar touch |
| Structure breaks | 1 bar | BOS/CHoCH confirmation on completed bar |

*Note: SMC zones are identified from completed bars but entry is triggered on subsequent price action.

### Indicator-Specific Verification

For each indicator, verify:

1. **on_bar() receives completed bars only** - Check Nautilus bar semantics
2. **No forming bar access** - bars[-1] must be completed, not forming
3. **HTF bar alignment** - HTF bar must be completed before LTF uses it
4. **Rolling calculations** - center=False confirmed
5. **DataFrame operations** - No negative shift values

### Integration with Temporal Verification Protocol

Extend the existing protocol with ARGUS patterns:

**Step 0 (NEW - before Step 1):** Run all grep commands and document any matches
**Step 5 (NEW - after Step 4):** Verify NautilusTrader configuration checklist
