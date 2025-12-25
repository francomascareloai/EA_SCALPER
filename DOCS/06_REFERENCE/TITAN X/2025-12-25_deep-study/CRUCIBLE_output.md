## CRUCIBLE Output

AGENT: CRUCIBLE
VERSION: 4.2
CLAUDE_MD_VERSION: 3.10.9
STATUS: PARTIAL

### Summary
Titan X (per `Titan_X.md`) is a configurable cost-averaging ladder/grid system with multiple “managers” that adapt spacing/size/targets as exposure rises. The core edge is **mean reversion / retracement to breakeven**; the primary failure mode is **sustained trend + volatility expansion**, especially around macro/news (XAUUSD).

### Core Trading Mechanism (What It Actually Does)
- **Ladder/grid (cost averaging):** Opens level-1 then adds levels as price moves by a “Pip Step”, with optional multipliers for both spacing and size (`Titan_X.md:49-82`).
- **Pip Step variants:** Fixed, volatility-adaptive (ATR(3) averaged across H1/H4/D1/W1), time-based, and “stacked” (adds in profit or drawdown) (`Titan_X.md:49-78`).
- **Sizing:** Starting lot can be fixed or “risk level” formula; follow-on lots via multiplier with caps/intervals (`Titan_X.md:21-48`).

### Ghost Trades (Virtual Ladders → Real Trigger)
- **Ghost Trades = virtual ladder used as a gate:** Titan runs “virtual” ladder levels to avoid starting ladders at the beginning of a trend; once a max GT level is hit it triggers a real trade (`Titan_X.md:96-110`).
- **GT TP anchored to GT breakeven midpoint:** TP is computed from midpoint between first/last GT level, then offset by GT TP (`Titan_X.md:104-107`).

### Entry Filters (Start/CA Gating)
- **Candlestick bias filter (multi-timeframe):** Uses most recent candle close on configured timeframe; can apply to start-only, CA-only, or all trades (`Titan_X.md:111-126`).
- **MA filter with “entry delay” anti-overexposure:** Prevents repeated ladders in same direction until opposite condition occurs (`Titan_X.md:133-153`).
- **RSI filter (trend or counter-trend):** Upper/lower thresholds drive direction (`Titan_X.md:155-166`).
- **Exposure cap:** “Max Charts” limits concurrent traded symbols (`Titan_X.md:167-170`).
- **Spread filter:** Skips trades if spread ≥ max (`Titan_X.md:171-175`).

### Exit Logic / Managers
- **TP relative to breakeven:** “TP pips beyond BE” becomes more valuable as total lots increase (`Titan_X.md:181-184`).
- **Aggregate PnL exits:** Profit basket / floating basket (trailing on floating profits), weekly/daily goals (`Titan_X.md:191-237`).
- **Risk stops:** Per-trade SL optional; account SL; “Equity Protector” variants incl. max-daily-loss logic tied to VPS time (`Titan_X.md:239-315`).
- **DD management modes:**
  - **Yoga:** When floating loss exceeds threshold, pause new ladders on pairs that hit TP while keeping management on existing ladders (`Titan_X.md:319-339`).
  - **Lipo:** “Trim” smallest early levels after N levels to reduce exposure and bring TP closer (`Titan_X.md:343-346`).
  - **Amp:** Force-close a direction after level threshold + DD threshold (`Titan_X.md:349-356`).
- **Adaptive managers:** Lot Multiplier Manager, Pip Step Manager (expand spacing as DD grows), TP Manager (move TP closer; can even accept loss at deep levels), FB Manager (lower profit target as DD increases), CSF Manager (change timeframe/min-time) (`Titan_X.md:359-427`).
- **Trend Trade (hedge / last resort):** Optional hedge that can be single-trade or its own CA ladder; can ignore SL if CA mode (`Titan_X.md:429-451`).

### Regime Bet (Implicit) + Likely Failure Modes (XAUUSD)
- **Bets on:** Frequent mean-reverting swings where price revisits a breakeven zone often enough to harvest small TP offsets.
- **Fails on:** Persistent directional trends with shallow pullbacks (volatility expansion), especially during US session news; grid/CA + spread widening makes BE/TP harder to reach.
- **Ghost Trades helps only if:** Trend exhaustion occurs before the real ladder is started; on XAUUSD fast breakouts can overshoot before “exhaustion” is detected.

### Design Patterns We Can Learn (Non-Proprietary)
1. **Virtual gating before risk-on (Ghost ladder):** +Avoids early-trend entries; −Can lag and still trigger late into momentum.
2. **Volatility-aware spacing:** +Controls trade density across regimes; −ATR smoothing can be slow during spikes.
3. **Exposure caps (max concurrent symbols/contexts):** +Limits correlated blowups; −Can reduce opportunities.
4. **Stateful “power-down” (Yoga / pause-start):** +Reduces adding risk during DD; −May prolong recovery.
5. **DD-triggered policy switching (managers):** +Adaptive risk response; −Many thresholds → overfit risk.
6. **Accept smaller profits (TP/FB managers):** +Improves survival by taking “less” on retrace; −May lock in negative expectancy.
7. **Forced loss acceptance (Amp):** +Prevents infinite averaging; −Timing can realize worst loss.
8. **Hedge-as-last-resort (trend trade):** +Mitigates runaway trend; −Can double complexity and cost.

### Gates Assessment (26 Realism Gates)
| Category | Passed | Failed | Score |
|----------|--------|--------|-------|
| Execution (1-9) | 1/9 | [1-3,4-9]
| 11% |
| Data Quality (10-13) | 0/4 | [10-13] | 0% |
| Statistical (14-19) | 0/6 | [14-19] | 0% |
| Prop Firm/Apex (20-25) | 0/6 | [20-25] | 0% |
| XAUUSD Specific (26) | 0/1 | [26] | 0% |
| **TOTAL** | **1/26** | - | **4%** |

Notes (why so low): `Titan_X.md` describes features but does not provide our required backtest execution realism, OOS/WFA/MC, or Apex time gates.

### Recommendations
1. CRITICAL: Treat Titan-style ladders as **trend-risky** on XAUUSD; only evaluate under **variable spread + slippage + latency** and strict time gates.
2. HIGH: If we borrow any pattern, start with **one** (e.g., volatility-aware spacing OR virtual gating), not the whole “manager stack”.
3. HIGH: Add falsification-first tests: if edge remains with random entry but same managers, then “managers” (not signals) are the edge.

### Recommended Experiments (Our System)
- **Ghost-gate ablation:** Compare (A) immediate ladder start vs (B) virtual gate start, identical exits/risk.
- **Volatility-spacing stress:** Hold strategy constant; vary pip-step as ATR-adaptive vs fixed; evaluate MC95DD.
- **Trend shock test:** Replay only high-vol regimes (news windows) with 2× spread + stop slippage; measure blow-up rate.
- **Manager soup audit:** Incrementally add ONE manager at a time; require ΔMC95DD improvement without killing WFE.

### Preliminary Verdict
**NEEDS_DATA**

Rationale: Mechanisms are clear, but without execution realism + OOS/WFA/MC and Apex-time-gate compliance we cannot rate viability.

### Required Handoffs
| Agent | Purpose | Priority |
|-------|---------|----------|
| ORACLE | Run WFA/OOS + Monte Carlo under realistic fills; report WFE/PSR/DSR/MC95DD | HIGH |
| SENTINEL | Map Apex-specific time gates + DD/HWM semantics and define safe sizing / kill-switches | HIGH |

### IMPORTANT
This is a PRELIMINARY assessment. Final GO/NO-GO requires:
- ORACLE: Statistical validation (WFA, Monte Carlo, PSR, DSR)
- SENTINEL: Apex compliance verification
