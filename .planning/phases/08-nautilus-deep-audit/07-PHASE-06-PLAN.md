# PLAN: Phase 06 - Backtest Scripts Audit

## Objective
Critical analysis of all backtest scripts and strategies to identify data leakage, unrealistic assumptions, and consistency issues with the main strategy.

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
| File | Priority | Focus |
|------|----------|-------|
| `monte_carlo_degradation.py` | P0 | MC implementation |
| `wfa_filter_study.py` | P0 | Walk-forward validation |
| `realistic_backtester.py` | P0 | Realistic simulation |
| `stress_test_degradation.py` | P1 | Stress testing |
| `multi_year_backtest.py` | P1 | Long-term validation |
| `ablation_study.py` | P2 | Component analysis |
| `comprehensive_validation.py` | P2 | Full validation |

**Estimated:** ~3,000+ lines additional

## Execution Plan

### Parallel Agent Assignment

**Agent A:** Core EA Logic
- `ea_logic_full.py` (2696 lines - largest!)
- Focus: MQL5 parity, logic correctness
- ~2,696 lines

**Agent B:** Alternative Strategies
- `ea_logic_python.py`
- `adaptive_kelly.py`
- `ea_logic_compat.py`
- Focus: Consistency with main, Kelly implementation
- ~1,558 lines

**Agent C:** Analysis Strategies
- `fibonacci_analyzer.py`
- `spread_analyzer.py`
- Focus: Fibonacci/spread analysis correctness
- ~990 lines

**Agent D:** Validation Scripts
- `monte_carlo_degradation.py`
- `wfa_filter_study.py`
- Focus: Statistical validity
- Lines TBD

**Agent E:** Backtester Scripts
- `realistic_backtester.py`
- `stress_test_degradation.py`
- `multi_year_backtest.py`
- Focus: Realistic simulation
- Lines TBD

## CRITICAL ANALYSIS AREAS

### Data Leakage Detection (MOST CRITICAL)

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

### Consistency with Main Strategy

**Compare Against:**
- `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`

**Questions:**
- Do backtest strategies use same logic?
- Are thresholds identical?
- Same indicator implementations?
- Same risk management?

### Realistic Simulation

**Slippage:**
- Is slippage modeled?
- Variable or fixed?
- Worse during news?

**Spread:**
- Historical or fixed?
- Widening during volatility?

**Fills:**
- Partial fills modeled?
- Rejections modeled?
- Latency accounted for?

### Monte Carlo Correctness

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

## CRITIC Checklist

### EA Logic (ea_logic_full.py)
| Check | Status |
|-------|--------|
| No look-ahead bias | ⬜ |
| Matches MQL5 logic | ⬜ |
| Same thresholds as main | ⬜ |
| Apex rules enforced | ⬜ |
| Slippage modeled | ⬜ |
| Spread modeled | ⬜ |

### Monte Carlo
| Check | Status |
|-------|--------|
| Randomization valid | ⬜ |
| Sufficient simulations | ⬜ |
| CI calculation correct | ⬜ |
| No data contamination | ⬜ |

### Walk-Forward
| Check | Status |
|-------|--------|
| Clean IS/OOS split | ⬜ |
| No future data in IS | ⬜ |
| WFE formula correct | ⬜ |
| Anchored/rolling documented | ⬜ |

### Realistic Backtester
| Check | Status |
|-------|--------|
| Slippage realistic | ⬜ |
| Spread realistic | ⬜ |
| Fills realistic | ⬜ |
| Latency modeled | ⬜ |
| Commission correct | ⬜ |

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

**5 parallel general-purpose agents (model: opus)**
- Each handles specific files
- Must apply CRITIC self-review internally
- Focus on data leakage and consistency

## Output
`PHASE_06_FINDINGS.md` in this directory
