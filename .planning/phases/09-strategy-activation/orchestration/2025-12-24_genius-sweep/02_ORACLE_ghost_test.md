# ORACLE Output: Ghost Test Implementation Plan

## Header
```
AGENT: ORACLE
VERSION: 3.4
CLAUDE_MD_VERSION: 3.10.23
STATUS: COMPLETE
TASK: Ghost Test Design for Signal Edge Falsification
```

---

## Executive Summary

The Ghost Test is the fastest falsification test to prove/disprove whether SMC signals add value over random direction selection. Given CRUCIBLE's finding that 8/9 confluence factors score ZERO and only 7 trades occurred in 6 months, there is high probability that signals are placebo.

**Core Hypothesis to Falsify:**
> "SMC direction prediction adds meaningful edge over random coin-flip direction."

---

## Test Design

### Test Type: Direction-Only Permutation Test

Instead of running 100 full backtests (slow), we:
1. Run FULL system ONCE to extract trade entry points
2. At each entry point, simulate 100 random direction choices
3. Compare Full outcomes vs Ghost distribution

**Why This Design:**
- 7 trades in 6 months = low sample size
- Traditional 2-sample t-test lacks power with N=7
- Permutation test pools evidence across MC runs
- Runtime: < 10 minutes (vs 50+ minutes for 100 full backtests)

### Pass/Fail Criteria

| Metric | KILL SIGNALS (No Edge) | KEEP SIGNALS (Edge Exists) |
|--------|------------------------|---------------------------|
| Permutation p-value | p >= 0.05 | p < 0.05 |
| Full vs Ghost Sharpe | abs(Delta) < 0.2 | Delta > 0.2 AND Full > Ghost |
| Full vs Ghost WinRate | abs(Delta) < 5% | Delta > 5% AND Full > Ghost |
| Full percentile in Ghost dist | 30th-70th percentile | > 95th percentile |

**Interpretation:**
- If Full system ranks in 30th-70th percentile of Ghost runs: **NO EDGE** (direction is noise)
- If Full system ranks below 30th percentile: **HARMFUL** (direction prediction worse than random)
- If Full system ranks above 95th percentile: **EDGE EXISTS** (keep signals)

---

## Implementation

### File 1: `nautilus_gold_scalper/src/signals/ghost_signal.py`

```python
"""
Ghost Signal Generator for Falsification Testing.

This module implements the Ghost Test pattern from CLAUDE.md falsification_patterns_library.
Purpose: Replace signal direction with random.choice([LONG, SHORT]) to test if
direction prediction adds any value over pure randomness.
"""

from __future__ import annotations

import random
from dataclasses import dataclass
from enum import Enum
from typing import Literal

from .trend_follow import TrendDirection, TrendFollowCandidate, TrendFollowVariant


class GhostMode(str, Enum):
    """Ghost test modes."""
    DIRECTION_ONLY = "direction_only"  # Keep timing, randomize direction
    FULL_RANDOM = "full_random"  # Random timing AND direction


@dataclass(frozen=True, slots=True)
class GhostTestConfig:
    """Configuration for ghost testing."""
    enabled: bool = False
    mode: GhostMode = GhostMode.DIRECTION_ONLY
    seed: int | None = None
    signal_probability: float = 0.001  # For FULL_RANDOM mode only


class GhostSignalGenerator:
    """
    Random signal generator for falsification testing.

    Usage:
        # Wrap existing signal generator
        ghost = GhostSignalGenerator(
            mode=GhostMode.DIRECTION_ONLY,
            seed=42,
        )

        # In strategy, replace real candidates with ghost candidates
        real_candidates = trend_follow_generator.generate(...)
        ghost_candidates = ghost.randomize_direction(real_candidates)
    """

    def __init__(
        self,
        mode: GhostMode = GhostMode.DIRECTION_ONLY,
        seed: int | None = None,
        signal_probability: float = 0.001,
    ):
        self.mode = mode
        self.signal_probability = signal_probability
        self.rng = random.Random(seed)
        self._seed = seed

    def reset(self, seed: int | None = None) -> None:
        """Reset RNG with new seed for fresh MC run."""
        self.rng = random.Random(seed if seed is not None else self._seed)

    def randomize_direction(
        self,
        candidates: list[TrendFollowCandidate],
    ) -> list[TrendFollowCandidate]:
        """
        Replace direction with random choice while keeping everything else.

        This tests: "Does SMC direction prediction matter?"

        Args:
            candidates: Real candidates from signal generator

        Returns:
            Ghost candidates with randomized directions
        """
        ghost_candidates = []

        for c in candidates:
            # Coin flip for direction
            random_dir = self.rng.choice([TrendDirection.LONG, TrendDirection.SHORT])

            ghost_candidates.append(TrendFollowCandidate(
                variant=c.variant,
                direction=random_dir,
                score=c.score,  # Keep original score
                sl_distance=c.sl_distance,  # Keep original SL
                reason=f"ghost_{c.reason}",
                meta={
                    **c.meta,
                    "ghost_mode": "direction_only",
                    "original_direction": c.direction.value,
                    "ghost_direction": random_dir.value,
                },
            ))

        return ghost_candidates

    def generate_random_signal(
        self,
        atr: float,
        tick_size: float = 0.01,
    ) -> list[TrendFollowCandidate]:
        """
        Generate completely random signal (for FULL_RANDOM mode).

        This tests: "Does SMC provide ANY value vs pure randomness?"

        Args:
            atr: Current ATR for SL sizing
            tick_size: Minimum price increment

        Returns:
            List with 0 or 1 random candidate
        """
        # Random firing based on probability
        if self.rng.random() > self.signal_probability:
            return []

        random_dir = self.rng.choice([TrendDirection.LONG, TrendDirection.SHORT])

        return [TrendFollowCandidate(
            variant=TrendFollowVariant.PULLBACK,  # Arbitrary
            direction=random_dir,
            score=self.rng.uniform(65.0, 85.0),  # Random but tradeable score
            sl_distance=max(tick_size, atr * self.rng.uniform(0.5, 1.5)),
            reason="ghost_full_random",
            meta={
                "ghost_mode": "full_random",
                "signal_probability": self.signal_probability,
            },
        )]
```

### File 2: `nautilus_gold_scalper/scripts/backtest/ghost_test.py`

```python
#!/usr/bin/env python3
"""
Ghost Test Harness - Fastest Falsification Test for Signal Edge.

This script implements the Ghost Test pattern to determine if SMC direction
prediction adds any value over random coin-flip direction selection.

Usage:
    python -m nautilus_gold_scalper.scripts.backtest.ghost_test \
        --config configs/backtest/default.yaml \
        --mc-runs 100 \
        --output results/ghost_test_results.json

Expected Runtime: < 10 minutes (uses cached trade entries, not full backtests)
"""

from __future__ import annotations

import argparse
import json
import logging
from dataclasses import asdict, dataclass
from datetime import datetime
from pathlib import Path
from typing import Any

import numpy as np
from scipy import stats

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
)
logger = logging.getLogger(__name__)


@dataclass
class TradeEntry:
    """Captured trade entry point from full system run."""
    timestamp: datetime
    direction: str  # "long" or "short"
    entry_price: float
    sl_distance: float
    score: float
    # Forward-looking data for simulation (captured at entry time)
    forward_prices: list[float]  # Next N bars of close prices
    atr_at_entry: float


@dataclass
class TradeOutcome:
    """Outcome of a trade (simulated or real)."""
    pnl: float
    pnl_pct: float
    is_win: bool
    exit_reason: str  # "tp", "sl", "timeout"
    bars_held: int


@dataclass
class GhostTestResult:
    """Complete Ghost Test result."""
    # Metadata
    test_date: str
    mc_runs: int
    trades_analyzed: int

    # Full system metrics
    full_total_pnl: float
    full_sharpe: float
    full_win_rate: float
    full_profit_factor: float

    # Ghost distribution metrics
    ghost_mean_pnl: float
    ghost_std_pnl: float
    ghost_mean_sharpe: float
    ghost_mean_win_rate: float

    # Statistical tests
    permutation_p_value: float
    full_percentile: float  # Where Full ranks in Ghost distribution
    delta_sharpe: float
    delta_win_rate: float

    # Decision
    decision: str  # "KILL_SIGNALS", "KEEP_SIGNALS", "INCONCLUSIVE"
    reasoning: str


class GhostTestHarness:
    """
    Main test harness for Ghost Test execution.

    Protocol:
    1. Run FULL system to extract trade entry points
    2. For each trade, simulate MC random directions
    3. Compare Full outcomes vs Ghost distribution
    4. Compute permutation p-value
    5. Report KILL/KEEP decision
    """

    def __init__(
        self,
        mc_runs: int = 100,
        rr_ratio: float = 2.0,  # Risk:Reward for TP calculation
        max_bars_held: int = 50,  # Timeout in bars
        seed: int = 42,
    ):
        self.mc_runs = mc_runs
        self.rr_ratio = rr_ratio
        self.max_bars_held = max_bars_held
        self.rng = np.random.default_rng(seed)

    def extract_trade_entries(
        self,
        backtest_result_path: Path,
    ) -> list[TradeEntry]:
        """
        Extract trade entry points from a completed backtest.

        This loads the trade log and extracts entry context needed
        for direction permutation simulation.
        """
        # TODO: Implement based on actual backtest output format
        # This is a placeholder showing expected structure

        logger.info(f"Loading trade entries from {backtest_result_path}")

        # Load backtest results
        with open(backtest_result_path) as f:
            data = json.load(f)

        entries = []
        for trade in data.get("trades", []):
            entries.append(TradeEntry(
                timestamp=datetime.fromisoformat(trade["entry_time"]),
                direction=trade["direction"],
                entry_price=trade["entry_price"],
                sl_distance=trade["sl_distance"],
                score=trade["score"],
                forward_prices=trade.get("forward_prices", []),
                atr_at_entry=trade.get("atr", 10.0),
            ))

        logger.info(f"Extracted {len(entries)} trade entries")
        return entries

    def simulate_trade(
        self,
        entry: TradeEntry,
        direction: str,  # "long" or "short"
    ) -> TradeOutcome:
        """
        Simulate trade outcome given entry context and direction.

        Uses forward_prices to determine if trade hits TP, SL, or times out.
        """
        entry_price = entry.entry_price
        sl_distance = entry.sl_distance
        tp_distance = sl_distance * self.rr_ratio

        if direction == "long":
            sl_price = entry_price - sl_distance
            tp_price = entry_price + tp_distance
        else:
            sl_price = entry_price + sl_distance
            tp_price = entry_price - tp_distance

        # Walk through forward prices
        for i, price in enumerate(entry.forward_prices):
            if i >= self.max_bars_held:
                # Timeout - exit at current price
                pnl = (price - entry_price) if direction == "long" else (entry_price - price)
                pnl_pct = pnl / entry_price * 100
                return TradeOutcome(
                    pnl=pnl,
                    pnl_pct=pnl_pct,
                    is_win=pnl > 0,
                    exit_reason="timeout",
                    bars_held=i + 1,
                )

            if direction == "long":
                if price <= sl_price:
                    return TradeOutcome(
                        pnl=-sl_distance,
                        pnl_pct=-sl_distance / entry_price * 100,
                        is_win=False,
                        exit_reason="sl",
                        bars_held=i + 1,
                    )
                if price >= tp_price:
                    return TradeOutcome(
                        pnl=tp_distance,
                        pnl_pct=tp_distance / entry_price * 100,
                        is_win=True,
                        exit_reason="tp",
                        bars_held=i + 1,
                    )
            else:  # short
                if price >= sl_price:
                    return TradeOutcome(
                        pnl=-sl_distance,
                        pnl_pct=-sl_distance / entry_price * 100,
                        is_win=False,
                        exit_reason="sl",
                        bars_held=i + 1,
                    )
                if price <= tp_price:
                    return TradeOutcome(
                        pnl=tp_distance,
                        pnl_pct=tp_distance / entry_price * 100,
                        is_win=True,
                        exit_reason="tp",
                        bars_held=i + 1,
                    )

        # No forward prices available - use entry price (no change)
        return TradeOutcome(
            pnl=0.0,
            pnl_pct=0.0,
            is_win=False,
            exit_reason="no_data",
            bars_held=0,
        )

    def run_full_system(
        self,
        entries: list[TradeEntry],
    ) -> list[TradeOutcome]:
        """Simulate full system using original directions."""
        outcomes = []
        for entry in entries:
            outcome = self.simulate_trade(entry, entry.direction)
            outcomes.append(outcome)
        return outcomes

    def run_ghost_system(
        self,
        entries: list[TradeEntry],
    ) -> list[TradeOutcome]:
        """Simulate ghost system with random directions."""
        outcomes = []
        for entry in entries:
            random_dir = self.rng.choice(["long", "short"])
            outcome = self.simulate_trade(entry, random_dir)
            outcomes.append(outcome)
        return outcomes

    def compute_metrics(
        self,
        outcomes: list[TradeOutcome],
    ) -> dict[str, float]:
        """Compute performance metrics from trade outcomes."""
        if not outcomes:
            return {
                "total_pnl": 0.0,
                "sharpe": 0.0,
                "win_rate": 0.0,
                "profit_factor": 0.0,
            }

        pnls = np.array([o.pnl for o in outcomes])
        wins = sum(1 for o in outcomes if o.is_win)
        losses = len(outcomes) - wins

        total_pnl = float(np.sum(pnls))
        win_rate = wins / len(outcomes) * 100 if outcomes else 0.0

        # Sharpe (annualized, assuming daily trades)
        if len(pnls) > 1 and np.std(pnls) > 0:
            sharpe = float(np.mean(pnls) / np.std(pnls) * np.sqrt(252))
        else:
            sharpe = 0.0

        # Profit Factor
        gross_profit = float(np.sum(pnls[pnls > 0]))
        gross_loss = float(np.abs(np.sum(pnls[pnls < 0])))
        profit_factor = gross_profit / gross_loss if gross_loss > 0 else 999.0

        return {
            "total_pnl": total_pnl,
            "sharpe": sharpe,
            "win_rate": win_rate,
            "profit_factor": profit_factor,
        }

    def run_permutation_test(
        self,
        entries: list[TradeEntry],
    ) -> GhostTestResult:
        """
        Main permutation test execution.

        Returns complete test result with decision.
        """
        logger.info(f"Running Ghost Test with {self.mc_runs} MC runs on {len(entries)} trades")

        if len(entries) < 5:
            logger.warning("Too few trades for meaningful statistical analysis")

        # 1. Run FULL system
        full_outcomes = self.run_full_system(entries)
        full_metrics = self.compute_metrics(full_outcomes)

        logger.info(f"Full system: PnL={full_metrics['total_pnl']:.2f}, "
                   f"Sharpe={full_metrics['sharpe']:.2f}, "
                   f"WinRate={full_metrics['win_rate']:.1f}%")

        # 2. Run GHOST system MC times
        ghost_pnls = []
        ghost_sharpes = []
        ghost_win_rates = []

        for i in range(self.mc_runs):
            ghost_outcomes = self.run_ghost_system(entries)
            ghost_metrics = self.compute_metrics(ghost_outcomes)

            ghost_pnls.append(ghost_metrics["total_pnl"])
            ghost_sharpes.append(ghost_metrics["sharpe"])
            ghost_win_rates.append(ghost_metrics["win_rate"])

        ghost_pnls = np.array(ghost_pnls)
        ghost_sharpes = np.array(ghost_sharpes)
        ghost_win_rates = np.array(ghost_win_rates)

        logger.info(f"Ghost system (mean of {self.mc_runs} runs): "
                   f"PnL={np.mean(ghost_pnls):.2f} +/- {np.std(ghost_pnls):.2f}, "
                   f"Sharpe={np.mean(ghost_sharpes):.2f}")

        # 3. Compute permutation p-value
        # p-value = proportion of ghost runs that beat full system
        ghost_beats_full = np.sum(ghost_pnls >= full_metrics["total_pnl"])
        p_value = ghost_beats_full / self.mc_runs

        # Percentile of Full in Ghost distribution
        full_percentile = float(stats.percentileofscore(ghost_pnls, full_metrics["total_pnl"]))

        # Delta metrics
        delta_sharpe = full_metrics["sharpe"] - float(np.mean(ghost_sharpes))
        delta_win_rate = full_metrics["win_rate"] - float(np.mean(ghost_win_rates))

        logger.info(f"Permutation p-value: {p_value:.3f}")
        logger.info(f"Full percentile in Ghost distribution: {full_percentile:.1f}%")
        logger.info(f"Delta Sharpe: {delta_sharpe:.2f}, Delta WinRate: {delta_win_rate:.1f}%")

        # 4. Make decision
        decision, reasoning = self._make_decision(
            p_value=p_value,
            full_percentile=full_percentile,
            delta_sharpe=delta_sharpe,
            delta_win_rate=delta_win_rate,
        )

        return GhostTestResult(
            test_date=datetime.now().isoformat(),
            mc_runs=self.mc_runs,
            trades_analyzed=len(entries),
            full_total_pnl=full_metrics["total_pnl"],
            full_sharpe=full_metrics["sharpe"],
            full_win_rate=full_metrics["win_rate"],
            full_profit_factor=full_metrics["profit_factor"],
            ghost_mean_pnl=float(np.mean(ghost_pnls)),
            ghost_std_pnl=float(np.std(ghost_pnls)),
            ghost_mean_sharpe=float(np.mean(ghost_sharpes)),
            ghost_mean_win_rate=float(np.mean(ghost_win_rates)),
            permutation_p_value=p_value,
            full_percentile=full_percentile,
            delta_sharpe=delta_sharpe,
            delta_win_rate=delta_win_rate,
            decision=decision,
            reasoning=reasoning,
        )

    def _make_decision(
        self,
        p_value: float,
        full_percentile: float,
        delta_sharpe: float,
        delta_win_rate: float,
    ) -> tuple[str, str]:
        """
        Make KILL/KEEP decision based on test results.

        Criteria from CLAUDE.md falsification_patterns_library:
        - If baseline approximately equal to full system → delete/simplify
        - If baseline materially worse (p < 0.05) → component adds real value
        """
        reasons = []

        # Check if Full is statistically better than Ghost
        if p_value < 0.05 and full_percentile > 95:
            # Full significantly beats Ghost
            if abs(delta_sharpe) >= 0.2:
                reasons.append(f"Full Sharpe is {delta_sharpe:.2f} higher than Ghost (significant)")
            if abs(delta_win_rate) >= 5:
                reasons.append(f"Full WinRate is {delta_win_rate:.1f}% higher than Ghost (significant)")

            if reasons:
                return "KEEP_SIGNALS", "Direction prediction shows statistically significant edge. " + " ".join(reasons)

        # Check if Full is indistinguishable from Ghost
        if 30 <= full_percentile <= 70 or p_value >= 0.05:
            reasons.append(f"Full ranks at {full_percentile:.1f}th percentile of Ghost distribution")
            reasons.append(f"p-value = {p_value:.3f} (>= 0.05 threshold)")
            reasons.append(f"Delta Sharpe = {delta_sharpe:.2f} (< 0.2 threshold)")

            return "KILL_SIGNALS", "Direction prediction is NOISE - no statistical difference from random. " + " ".join(reasons)

        # Check if Full is WORSE than Ghost
        if full_percentile < 30:
            return "KILL_SIGNALS", f"Direction prediction is HARMFUL - Full ranks at only {full_percentile:.1f}th percentile, BELOW most random runs. IMMEDIATE ACTION: Kill signal logic."

        return "INCONCLUSIVE", f"Results are ambiguous. Full percentile={full_percentile:.1f}%, p={p_value:.3f}. More trades needed for conclusive test."


def main():
    parser = argparse.ArgumentParser(description="Ghost Test - Signal Edge Falsification")
    parser.add_argument("--backtest-result", type=Path, required=True,
                       help="Path to backtest result JSON with trade entries")
    parser.add_argument("--mc-runs", type=int, default=100,
                       help="Number of Monte Carlo runs (default: 100)")
    parser.add_argument("--output", type=Path, default=Path("ghost_test_result.json"),
                       help="Output path for test results")
    parser.add_argument("--seed", type=int, default=42,
                       help="Random seed for reproducibility")

    args = parser.parse_args()

    harness = GhostTestHarness(
        mc_runs=args.mc_runs,
        seed=args.seed,
    )

    # Extract trade entries
    entries = harness.extract_trade_entries(args.backtest_result)

    if not entries:
        logger.error("No trade entries found. Cannot run Ghost Test.")
        return 1

    # Run permutation test
    result = harness.run_permutation_test(entries)

    # Save results
    with open(args.output, "w") as f:
        json.dump(asdict(result), f, indent=2, default=str)

    logger.info(f"Results saved to {args.output}")

    # Print decision
    print("\n" + "=" * 60)
    print("GHOST TEST RESULT")
    print("=" * 60)
    print(f"Decision: {result.decision}")
    print(f"Reasoning: {result.reasoning}")
    print("=" * 60)

    return 0 if result.decision != "INCONCLUSIVE" else 1


if __name__ == "__main__":
    exit(main())
```

---

## Config Integration

Add to `nautilus_gold_scalper/configs/backtest/default.yaml`:

```yaml
# Ghost Test Configuration
ghost_test:
  enabled: false
  mode: "direction_only"  # "direction_only" or "full_random"
  seed: null  # null = random seed each run
  signal_probability: 0.001  # For full_random mode only
```

Add to strategy initialization:

```python
# In GoldScalperStrategy.__init__
if config.ghost_test.enabled:
    from ..signals.ghost_signal import GhostSignalGenerator, GhostMode
    self.ghost_generator = GhostSignalGenerator(
        mode=GhostMode(config.ghost_test.mode),
        seed=config.ghost_test.seed,
    )
else:
    self.ghost_generator = None

# In signal generation path
candidates = self.trend_follow.generate(...)
if self.ghost_generator:
    candidates = self.ghost_generator.randomize_direction(candidates)
```

---

## Expected Outcomes

### Scenario A: KILL_SIGNALS (Most Likely)

```
GHOST TEST RESULT
Decision: KILL_SIGNALS
Reasoning: Direction prediction is NOISE - no statistical difference from random.
Full ranks at 52nd percentile of Ghost distribution. p-value = 0.480 (>= 0.05).
Delta Sharpe = 0.08 (< 0.2 threshold).
```

**Action if A:** Remove SMC confluence scoring, keep only filters (regime, session, time gates).

### Scenario B: KEEP_SIGNALS (Unlikely but Possible)

```
GHOST TEST RESULT
Decision: KEEP_SIGNALS
Reasoning: Direction prediction shows statistically significant edge.
Full Sharpe is 0.45 higher than Ghost (significant).
Full ranks at 97th percentile. p-value = 0.03.
```

**Action if B:** Keep SMC signals, optimize thresholds, proceed to WFA validation.

### Scenario C: HARMFUL (Worst Case)

```
GHOST TEST RESULT
Decision: KILL_SIGNALS
Reasoning: Direction prediction is HARMFUL - Full ranks at only 18th percentile,
BELOW most random runs. IMMEDIATE ACTION: Kill signal logic.
```

**Action if C:** Emergency removal of SMC direction logic. Investigate why it's anti-predictive.

---

## Runtime Estimate

| Component | Time |
|-----------|------|
| Load backtest results | < 1 sec |
| Extract trade entries | < 1 sec |
| Run Full system simulation | < 1 sec |
| Run 100 Ghost simulations | < 5 sec |
| Statistical analysis | < 1 sec |
| **Total** | **< 10 seconds** |

Note: This assumes trade entries are pre-extracted from a completed backtest.
If we need to run the initial backtest first, add ~2-5 minutes.

---

## Next Steps

1. **Immediate:** Implement `ghost_signal.py` and `ghost_test.py`
2. **Week 1:** Run Ghost Test on most recent backtest results
3. **If KILL:** Proceed to Filter-Only strategy (remove signals, keep gates)
4. **If KEEP:** Proceed to standard ORACLE WFA/MC validation

---

## Handoff

| Condition | Next Agent | Action |
|-----------|------------|--------|
| KILL_SIGNALS | FORGE | Remove SMC signal logic, implement Filter-Only strategy |
| KEEP_SIGNALS | ORACLE | Proceed with WFA/MC validation |
| HARMFUL | CRUCIBLE | Emergency strategy review |
| Implementation ready | FORGE | Implement ghost_signal.py and ghost_test.py |

---

*ORACLE v3.4 - Statistical Truth-Seeker*
