# PLAN: Phase 01 - Core Strategy Audit

## Objective
Deep critical analysis of the main trading strategy (`GoldScalperStrategy`) and its base class to identify bugs, design flaws, and Apex compliance gaps.

## Files Under Review

| File | Lines | Priority |
|------|-------|----------|
| `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py` | ~800 | P0 |
| `nautilus_gold_scalper/src/strategies/base_strategy.py` | ~600 | P0 |
| `nautilus_gold_scalper/src/strategies/strategy_selector.py` | ~200 | P1 |

## Execution Steps

### Step 1: Read and Understand Architecture
- Read all 3 files completely
- Map the inheritance hierarchy
- Document component dependencies
- Identify entry/exit paths

### Step 2: CRITIC Analysis - base_strategy.py
**Focus areas:**
1. **Lifecycle management**
   - `on_start()` initialization correctness
   - `on_stop()` cleanup (positions closed? orders cancelled?)
   - Timer handling for daily reset

2. **Position tracking**
   - `_position` state consistency
   - `_daily_trades` counter accuracy
   - `_daily_pnl` calculation

3. **Edge cases**
   - Multiple positions (allowed?)
   - Partial fills handling
   - Order rejection recovery

**CRITIC Protocol:** 12-15 sequential thoughts, adversarial lens

### Step 3: CRITIC Analysis - gold_scalper_strategy.py
**Focus areas:**
1. **Apex compliance**
   - Trailing DD tracking (HIGH-WATER MARK!)
   - Time gate enforcement (4:30 PM, 4:55 PM)
   - Overnight position prevention
   - 30% consistency cap

2. **Signal generation**
   - Look-ahead bias check in `on_bar()`
   - MTF confluence logic
   - Score threshold application

3. **Trade execution**
   - SL/TP calculation correctness
   - Position sizing integration
   - Order submission flow

4. **Performance**
   - `on_bar` execution time (must be <1ms)
   - `on_quote_tick` execution time (must be <100µs)
   - Any blocking operations?

**CRITIC Protocol:** 15+ sequential thoughts, exhaustive analysis

### Step 4: CRITIC Analysis - strategy_selector.py
**Focus areas:**
1. **Selection logic correctness**
   - Regime-to-strategy mapping
   - Fallback behavior
   - State transitions

2. **Edge cases**
   - Unknown regime handling
   - Selector disabled scenarios

**CRITIC Protocol:** 8-10 sequential thoughts

### Step 5: Cross-Module Integration Check
- Verify data flow between modules
- Check for temporal inconsistencies
- Validate state synchronization

### Step 6: Document Findings
- Create `PHASE_01_FINDINGS.md`
- Classify issues by severity
- Document assumptions challenged
- List recommended fixes

## Success Criteria
- [ ] All 3 files reviewed with CRITIC protocol
- [ ] Apex compliance verified (5 rules)
- [ ] No look-ahead bias found OR documented
- [ ] Performance concerns identified
- [ ] `PHASE_01_FINDINGS.md` completed

## Agents

**Primary:** FORGE (model: opus)
- Responsible for deep code analysis
- Must apply CRITIC self-review internally

**Fallback:** Orchestrator spawns dedicated CRITIC if confidence < 0.9

## CRITIC Checklist for This Phase

| Check | Pass/Fail |
|-------|-----------|
| Trailing DD from HIGH-WATER MARK | ⬜ |
| No trades after 4:30 PM ET | ⬜ |
| Force close by 4:59 PM ET | ⬜ |
| Emergency close from 4:55 PM | ⬜ |
| 30% consistency cap enforced | ⬜ |
| on_stop() closes all positions | ⬜ |
| No look-ahead in on_bar() | ⬜ |
| Performance budget respected | ⬜ |
| Partial fill handling | ⬜ |
| Order rejection recovery | ⬜ |

## Output
`PHASE_01_FINDINGS.md` in this directory
