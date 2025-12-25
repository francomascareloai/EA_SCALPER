# DAEMON TRANSFORMATION ROADMAP v2.0

> "The goal is not to be right. The goal is to not be dead."

---

## EXECUTIVE SUMMARY

**Current State**: 15K lines of code producing 7 trades over 22 years = 0.32 trades/year
**Target State**: 200+ trades with 95% 1-year survival probability under Apex rules
**Core Paradigm**: SURVIVE FIRST, PROFIT SECOND

---

## THE FUNDAMENTAL PROBLEM

Before optimizing signals, before running Ghost Tests, before survival hardening - we must answer:

**WHY ONLY 7 TRADES IN 22 YEARS OF XAUUSD DATA?**

This is not a "low frequency strategy". This is a strategy that functionally does not trade. The confluence system is so tight that it filters out 99.97% of potential opportunities.

### Statistical Reality Check

| Metric | Current | Minimum Required | Target |
|--------|---------|------------------|--------|
| Total Trades | 7 | 200 | 500+ |
| Trades/Year | 0.32 | 9 | 25 |
| Trades/Week | 0.006 | 0.17 | 0.5 |

For ANY statistical validation to be meaningful:
- Sharpe ratio: n >= 30 trades
- T-test on edge: n >= 50 trades
- Monte Carlo: n >= 100 trades
- Walk-forward (5 folds): n >= 200 trades

**With 7 trades, we cannot distinguish skill from luck.**

---

## TRANSFORMATION ROADMAP

### WEEK 1: DIAGNOSTIC & FREQUENCY FIX

**Objective**: Achieve 50+ trades minimum before any other optimization

#### Day 1-2: Instrumentation
```
- Add logging to EVERY filter/gate that can reject a trade
- Track: signal generated → filter A → filter B → ... → trade executed OR rejected
- Create rejection funnel visualization
```

#### Day 3: Bottleneck Analysis
```
Questions to answer:
1. How many raw signals are generated?
2. At which filter do we lose >90% of signals?
3. Is there a single gate that blocks almost everything?
4. Are multiple gates correlated (same rejection)?
```

#### Day 4-5: Bottleneck Removal
```
Priority order for relaxation:
1. Remove the most restrictive gate entirely
2. If still < 50 trades: remove second most restrictive
3. Continue until 50+ trades achieved
4. Document what was removed
```

#### Day 6-7: Validation
```
- Re-run full backtest
- Confirm trade count >= 50
- Check that removal didn't break Apex compliance
- Document baseline metrics for comparison
```

**GO/NO-GO GATE**:
| Outcome | Action |
|---------|--------|
| Trades >= 50 | Proceed to Week 2 |
| Trades < 50 | Continue relaxation until achieved |
| No clear bottleneck | Investigate signal generation itself |

---

### WEEK 2: GHOST TEST & SIMPLIFICATION

**Objective**: Determine if signals have edge, then simplify accordingly

#### The Ghost Test Protocol

**Purpose**: Isolate signal edge from filter edge

**Implementation**:
```python
class GhostSignalGenerator:
    """Replace real signals with random but same-frequency signals"""

    def generate_signal(self, bar):
        # Match real signal frequency distribution
        if random.random() < self.signal_probability:
            return random.choice([Signal.BUY, Signal.SELL])
        return Signal.NONE
```

**Comparison**:
| Metric | Real Signals | Ghost Signals | Interpretation |
|--------|--------------|---------------|----------------|
| Sharpe | X | Y | Edge = X - Y |
| Win Rate | A | B | Skill = A - B |
| Max DD | P | Q | Risk = P vs Q |
| Profit Factor | M | N | Robustness = M vs N |

**GO/PIVOT Decision Matrix**:

| Ghost Test Result | Decision | Action |
|-------------------|----------|--------|
| Real Sharpe - Ghost Sharpe > 0.3 | **GO** | Signals have edge, refine them |
| Real Sharpe - Ghost Sharpe in [0, 0.3] | **INVESTIGATE** | Edge exists but small, dig deeper |
| Ghost Sharpe > Real Sharpe | **PIVOT IMMEDIATELY** | Signals are TOXIC, delete them |
| Results inconclusive | **INCREASE SAMPLE** | Need more trades for clarity |

#### If GO: Signal Refinement

Apply Three-Factor Rule:
1. Identify the 3 most predictive signal components
2. Require ANY 2 of 3 (not ALL 3)
3. This creates 3 entry combinations instead of 1

Candidates:
- Order Block (OB) touch/rejection
- Fair Value Gap (FVG) entry
- Trend alignment (higher timeframe structure)

#### If PIVOT: Filter-Only Strategy

The hypothesis shifts to: "Our edge is in WHEN, not WHAT"

New approach:
- Use simple trend-following entry (MA cross, momentum breakout)
- Apply all existing filters
- The filters ARE the strategy

**GO/NO-GO GATE**:
| Outcome | Action |
|---------|--------|
| Clear direction (GO or PIVOT) | Proceed to Week 3 |
| Inconclusive Ghost Test | Increase trade count, re-run |
| Both paths look unpromising | Step back, fundamental redesign |

---

### WEEK 3: SURVIVAL HARDENING

**Objective**: Achieve MC95DD < 4% and 95% 1-year survival probability

#### HWM-Proximity Scale-Out Protocol

```python
def calculate_position_scale(self, hwm: float, equity: float) -> float:
    """Scale position based on proximity to HWM danger zone"""

    # Safety buffer = distance from 5% DD line
    buffer_pct = ((equity - 0.95 * hwm) / equity) * 100

    if buffer_pct >= 3.0:
        return 1.0      # Full size
    elif buffer_pct >= 2.0:
        return 0.50     # Half size
    elif buffer_pct >= 1.5:
        return 0.25     # Quarter size
    elif buffer_pct >= 1.0:
        return 0.0      # HALT new trades
    else:
        self.emergency_close_all()
        return 0.0
```

#### Conservative Price Enforcement

```python
def calculate_unrealized_pnl(self, position: Position) -> float:
    """Use conservative prices for HWM calculation"""

    if position.side == Side.LONG:
        # Use BID - what we'd actually get if closing
        exit_price = self.current_bid
    else:
        # Use ASK - what we'd actually pay if closing
        exit_price = self.current_ask

    return (exit_price - position.entry_price) * position.quantity
```

#### Trailing Stop Rules

```python
class TrailingStop:
    """Trailing stop that NEVER widens"""

    def update(self, current_price: float):
        if self.side == Side.LONG:
            new_stop = current_price - self.trail_distance
            if new_stop > self.stop_price:
                self.stop_price = new_stop  # Tighten only
        else:
            new_stop = current_price + self.trail_distance
            if new_stop < self.stop_price:
                self.stop_price = new_stop  # Tighten only
```

#### Scale-Out at 1R

```python
def check_scale_out(self, position: Position, current_pnl: float):
    """Scale out 50% at 1R, move SL to breakeven"""

    if current_pnl >= position.initial_risk:
        self.close_partial(position, fraction=0.5)
        self.move_stop_to_breakeven(position)
```

#### Monte Carlo Survival Simulation

Run 1000 paths:
1. Shuffle trade sequence randomly
2. Simulate equity curve under Apex HWM rules
3. Count "deaths" (5% DD hit)
4. Calculate survival rate and MC95DD

**GO/NO-GO GATE**:
| Metric | Threshold | Action if Fail |
|--------|-----------|----------------|
| MC95DD | < 4% | Reduce position size further |
| 1-Year Survival | >= 95% | Tighten filters or reduce size |
| Both fail | - | Redesign from scratch |

---

### WEEK 4: FINAL VALIDATION

**Objective**: Confirm all metrics pass before paper trading

#### Validation Battery

| Metric | Threshold | Notes |
|--------|-----------|-------|
| Walk-Forward Efficiency (WFE) | >= 0.6 | OOS/IS Sharpe ratio |
| System Quality Number (SQN) | >= 2.0 | (avg_R / std_R) * sqrt(n) |
| Probabilistic Sharpe Ratio (PSR) | >= 0.85 | Prob(Sharpe > 0) |
| Deflated Sharpe Ratio (DSR) | > 0 | Adjusted for multiple testing |
| Monte Carlo 95th DD (MC95DD) | < 4% | From 1000 paths |
| Probability of Backtest Overfitting (PBO) | < 25% | CSCV method |
| Trade Count | >= 200 | Statistical validity |
| 1-Year Survival Rate | >= 95% | Under Apex rules |

#### Paper Trading Preparation

If all metrics pass:
1. Set up live data feed connection
2. Configure paper trading account
3. Implement real-time HWM tracking
4. Verify time gates work in real-time
5. Test emergency close mechanism

**GO/NO-GO GATE**:
| Outcome | Action |
|---------|--------|
| All metrics pass | Begin 2-week paper trading |
| Any metric fails | Loop back to appropriate week |
| Multiple failures | Fundamental redesign required |

---

## KEEP / CHANGE / DELETE MANIFEST

### KEEP (Infrastructure That Works)

| Component | Reason |
|-----------|--------|
| Data loader (parquet) | Proven, efficient |
| NautilusTrader integration | Core framework |
| Time gates (4:30 PM block, 4:55 PM close) | Apex requirement |
| Session filters (London/NY) | Empirically valid |
| Risk monitoring infrastructure | Core safety |
| Logging and metrics collection | Essential for debugging |
| Drawdown tracking | Core safety |

### CHANGE (Needs Modification)

| Component | Current | Target |
|-----------|---------|--------|
| Signal generation | Complex SMC | Simplified 3-factor OR filter-only |
| Confluence logic | ALL requirements | 2-of-3 OR simpler |
| Position sizing | Fixed | HWM-proximity scaled |
| Stop loss | Fixed | Trailing, never-widen |
| Profit taking | Hold to target | Scale out 50% at 1R |
| Timeframe handling | M15/M5 conflict | Single primary TF |
| Entry frequency | 7 trades/22yr | 200+ trades/22yr |

### DELETE (Complexity Without Proven Value)

| Component | Reason for Deletion |
|-----------|---------------------|
| Redundant confluence checks | Reduce without losing edge |
| M15/M5 semantic collision | Source of bugs and confusion |
| Complex scoring algorithms | Simplify to 3-factor |
| Nested state machines | Over-engineered |
| Any signal failing Ghost Test | Proven valueless |
| Parameters with negligible impact | Reduce overfit risk |

---

## THE FUNDAMENTAL QUESTION

Before proceeding, the team must answer:

> **"If we achieve 95% survival probability but only 0.5 Sharpe, do we still GO?"**

My recommendation: **YES**.

**Rationale**:
- A strategy that survives Apex is infinitely more valuable than a high-Sharpe strategy that blows up
- Dead accounts don't compound
- 0.5 Sharpe with 95% survival beats 2.0 Sharpe with 50% survival over any meaningful horizon
- The goal is wealth accumulation, not backtest beauty

The Apex evaluation is a SURVIVAL test, not a return-maximization test. Design accordingly.

---

## ESCALATION NOTES

### For SENTINEL

After Week 3 completion, SENTINEL must validate:
1. MC95DD calculation methodology is correct
2. HWM-proximity scaling rules are Apex-compliant
3. Emergency close triggers are conservative enough
4. Position sizing formulas have correct math

### For ORACLE

After Week 4, ORACLE must run full validation battery and confirm:
1. All metrics pass thresholds
2. Statistical tests have sufficient power
3. Walk-forward is properly configured
4. No look-ahead bias in any component

### For FORGE

Week 1-3 implementation requires FORGE to:
1. Add logging instrumentation
2. Implement Ghost Signal generator
3. Build HWM-proximity scaling
4. Add trailing stop logic
5. Create scale-out mechanism

---

## SUCCESS METRICS

| Milestone | Metric | Success Criteria |
|-----------|--------|------------------|
| End of Week 1 | Trade Count | >= 50 |
| End of Week 2 | Ghost Test Delta | Sharpe_real - Sharpe_ghost > 0.3 |
| End of Week 3 | MC95DD | < 4% |
| End of Week 3 | 1-Year Survival | >= 95% |
| End of Week 4 | All Validation | Pass |

---

## TIMELINE

| Week | Focus | Key Deliverable |
|------|-------|-----------------|
| Week 1 | Frequency Fix | 50+ trades achieved |
| Week 2 | Ghost Test + Simplify | GO/PIVOT decision made |
| Week 3 | Survival Hardening | MC95DD < 4%, 95% survival |
| Week 4 | Final Validation | All metrics pass |
| Post-Week 4 | Paper Trading | 2-week live data validation |

**Total transformation time**: 4-5 weeks

---

## APPENDIX: THE PARADIGM SHIFT

From ONDA 1 insight:

```
OLD PARADIGM: "Optimize for returns"
NEW PARADIGM: "Survive first, profit second"

OLD QUESTION: "What's the Sharpe?"
NEW QUESTION: "What's the survival probability?"

OLD METRIC: Profit
NEW METRIC: Probability of NOT hitting 5% DD

OLD SUCCESS: High backtest returns
NEW SUCCESS: Passing Apex evaluation without account blow-up
```

---

**DAEMON v1.1 - Strategic Transformation Architect**

*The strategy that survives is the strategy that wins.*
