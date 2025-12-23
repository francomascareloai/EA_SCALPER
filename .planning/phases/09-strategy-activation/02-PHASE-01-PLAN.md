# PLAN: Phase 01 - Cleanup & Consolidation

## Metadata
- **Phase:** 01
- **Priority:** P0 - BLOCKER
- **Status:** Not Started
- **Agents:** 1 FORGE (opus)
- **Blocking:** Must complete before Phase 02

---

## Objective

Limpar código morto e consolidar duplicações antes de auditar estratégias. Isso garante que a auditoria subsequente foque apenas em código ativo.

---

## Tasks

### Task 01-01: Archive Dead Code

**Status:** Not Started

**Files to Archive:**
```
FROM                                          → TO
scripts/backtest/strategies/ea_logic_full.py  → _archive/legacy/
scripts/backtest/strategies/ea_logic_python.py → _archive/legacy/
scripts/backtest/strategies/ea_logic_compat.py → _archive/legacy/
src/indicators/mtf_manager.py                 → _archive/legacy/ (signals/ version is active)
src/indicators/footprint_analyzer.py          → _archive/legacy/ (no futures data)
```

**Pre-Execution Checklist:**
- [ ] Verify each file exists
- [ ] Check for imports from other active code
- [ ] Create `_archive/legacy/` directory if not exists
- [ ] Move files (git mv for history preservation)

**Verification:**
```bash
# After archiving, run:
python -c "from nautilus_gold_scalper.src.strategies import gold_scalper_strategy"
pytest nautilus_gold_scalper/tests/ -x --tb=short
```

**Acceptance Criteria:**
- [ ] No import errors after archiving
- [ ] Tests still pass
- [ ] Git history preserved

---

### Task 01-02: Remove NEWS_TRADER from Flow

**Status:** Not Started

**Context:** User confirmed they don't trade news events. NEWS_TRADER strategy should be removed from the decision flow.

**Files to Modify:**

1. **`strategy_selector.py`**
   - Find: Gate that returns `STRATEGY_NEWS_TRADER`
   - Action: Make it return `STRATEGY_SMC_SCALPER` or skip the gate entirely
   - Alternative: Remove the enum value (may break existing code)

2. **`gold_scalper_strategy.py`**
   - Search for any news-related logic
   - Remove or comment out

**Safe Approach:**
```python
# In strategy_selector.py, change:
# if news_event_detected:
#     return STRATEGY_NEWS_TRADER
# To:
# if news_event_detected:
#     return STRATEGY_NONE  # Don't trade during news (safer than removing)
```

**Verification:**
```bash
# Run tests
pytest nautilus_gold_scalper/tests/test_strategy_selector.py -v

# Grep to ensure no active paths return NEWS_TRADER
rg "STRATEGY_NEWS_TRADER" nautilus_gold_scalper/src/
```

**Acceptance Criteria:**
- [ ] StrategySelector never returns NEWS_TRADER
- [ ] No runtime errors
- [ ] Tests pass

---

### Task 01-03: Consolidate MTF Manager

**Status:** Not Started

**Context:** MTF Manager exists in two locations:
- `src/indicators/mtf_manager.py` (legacy)
- `src/signals/mtf_manager.py` (active)

**Actions:**
1. Verify `signals/mtf_manager.py` is the canonical version
2. Search for any imports from `indicators/mtf_manager`
3. Update imports to use `signals/mtf_manager`
4. Archive `indicators/mtf_manager.py`

**Verification:**
```bash
# Check for old imports
rg "from.*indicators.*mtf_manager" nautilus_gold_scalper/
rg "from.*indicators.mtf_manager" nautilus_gold_scalper/

# After update
python -c "from nautilus_gold_scalper.src.signals.mtf_manager import MTFManager"
```

**Acceptance Criteria:**
- [ ] All imports point to signals/mtf_manager
- [ ] indicators/mtf_manager.py archived
- [ ] Tests pass

---

### Task 01-04: Document Current Architecture

**Status:** Not Started

**Deliverable:** `ARCHITECTURE.md` in `.planning/phases/09-strategy-activation/`

**Content Required:**

```markdown
# Architecture Overview

## Strategy Hierarchy
BaseGoldStrategy
    └── GoldScalperStrategy
            ├── StrategySelector (6 gates)
            └── AdaptiveEVRouter (Thompson sampling)

## StrategySelector Decision Tree
Gate 1: Safety Check → STRATEGY_NONE if unsafe
Gate 2: FTMO Compliance → size adjustment
Gate 3: News Events → STRATEGY_NONE (was NEWS_TRADER)
Gate 4: Session Filter → time-based filtering
Gate 5: Holiday Check → STRATEGY_NONE if holiday
Gate 6: Regime Detection → TREND_FOLLOW / MEAN_REVERT / SMC_SCALPER

## AdaptiveEVRouter Arms
- SMC: Smart Money Concept signals
- TREND_PULLBACK: EMA bounce entries
- TREND_BREAKOUT: Donchian breakout entries

## Signal Generation Flow
1. Tick received → on_data()
2. StrategySelector.select() → StrategyType
3. Based on type:
   - SMC_SCALPER → SMC indicators → ConfluenceScorer
   - TREND_FOLLOW → TrendFollowGenerator → Candidates
4. AdaptiveEVRouter.select_arm() → best candidate
5. Generate signal → submit order

## Active Modules
- src/strategies/gold_scalper_strategy.py (main)
- src/strategies/strategy_selector.py (selection)
- src/strategies/adaptive_router.py (routing)
- src/signals/trend_follow.py (trend signals)
- src/signals/confluence_scorer.py (SMC scoring)
- src/indicators/*.py (SMC indicators)
```

**Acceptance Criteria:**
- [ ] ARCHITECTURE.md created
- [ ] Accurately reflects current code
- [ ] Decision flows documented
- [ ] Module relationships clear

---

## Execution Order

```
01-01 (Archive) → 01-02 (NEWS_TRADER) → 01-03 (MTF) → 01-04 (Document)
     ↓                    ↓                   ↓              ↓
  Verify           Verify tests          Verify        Review doc
```

---

## Phase Completion Checklist

- [ ] All dead code archived to `_archive/legacy/`
- [ ] NEWS_TRADER removed from decision flow
- [ ] MTF Manager consolidated (single source)
- [ ] ARCHITECTURE.md created
- [ ] All tests pass
- [ ] No import errors
- [ ] Git commit with descriptive message

---

## Exit Criteria

Phase 01 is COMPLETE when:
1. Codebase has no duplicate/dead code in active paths
2. Only valid strategies remain in StrategySelector
3. Architecture is documented
4. All tests pass

**Next Phase:** Phase 02 - SMC_SCALPER Deep Audit
