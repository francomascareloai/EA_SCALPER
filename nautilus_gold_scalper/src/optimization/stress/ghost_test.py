"""Ghost test utilities (signal vs baseline falsification).

This module implements a cheap null baseline based on the same realized trade PnL
series produced by a strategy.

Important:
- This is NOT a full "random signal" baseline backtest.
- It's a fast disproof tool: if baseline ≈ original, the edge is likely not in the
  signal generation (or is too weak to matter vs noise).

We model a baseline by permuting trade ordering (block bootstrap) to preserve
the distribution and some autocorrelation structure.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any

import numpy as np
import pandas as pd
from numpy.typing import NDArray


@dataclass(frozen=True, slots=True)
class GhostTestResult:
    sharpe_full: float
    sharpe_baseline_mean: float
    sharpe_baseline_std: float
    sharpe_delta: float
    p_value: float
    sims: int


def _sharpe(pnl: NDArray[np.float64], periods_per_year: int = 252) -> float:
    if pnl.size < 2:
        return 0.0

    mean = float(np.mean(pnl))
    std = float(np.std(pnl, ddof=1))
    if (not np.isfinite(mean)) or (not np.isfinite(std)) or std <= 0.0:
        return 0.0

    sharpe = float(mean / std * np.sqrt(periods_per_year))
    if not np.isfinite(sharpe):
        return 0.0

    return sharpe


def _block_bootstrap_permutation(
    pnl: NDArray[np.float64],
    *,
    rng: np.random.Generator,
    block_size: int,
) -> NDArray[np.float64]:
    if pnl.size == 0:
        return pnl
    if block_size <= 1:
        return rng.permutation(pnl)

    n = pnl.size
    starts = rng.integers(0, n, size=int(np.ceil(n / block_size)))
    out = np.empty(n, dtype=np.float64)
    pos = 0
    for s in starts:
        end = min(n, pos + block_size)
        take = end - pos
        block = pnl[int(s) : int(min(n, s + take))]
        if block.size < take:
            # wrap
            remaining = take - block.size
            block = np.concatenate([block, pnl[:remaining]])
        out[pos:end] = block
        pos = end
        if pos >= n:
            break
    return out


def run_ghost_test(
    trades_df: pd.DataFrame,
    *,
    sims: int,
    seed: int,
    block_size: int = 10,
    pnl_col: str = "pnl",
) -> GhostTestResult:
    if sims <= 0:
        raise ValueError("sims must be > 0")
    if pnl_col not in trades_df.columns:
        raise ValueError(f"trades_df missing required column: {pnl_col}")

    pnl_series = trades_df[pnl_col].astype(float).replace([np.inf, -np.inf], np.nan).dropna()
    pnl = pnl_series.to_numpy(dtype=np.float64, copy=False)

    sharpe_full = _sharpe(pnl)

    rng = np.random.default_rng(seed)
    baseline: NDArray[np.float64] = np.empty(sims, dtype=np.float64)
    for i in range(sims):
        perm = _block_bootstrap_permutation(pnl, rng=rng, block_size=block_size)
        baseline[i] = _sharpe(perm)

    mean_b = float(np.mean(baseline))
    std_b = float(np.std(baseline, ddof=1)) if sims > 1 else 0.0
    delta = sharpe_full - mean_b

    # One-sided p-value: P(baseline >= observed)
    p_value = float((np.sum(baseline >= sharpe_full) + 1.0) / (sims + 1.0))

    return GhostTestResult(
        sharpe_full=sharpe_full,
        sharpe_baseline_mean=mean_b,
        sharpe_baseline_std=std_b,
        sharpe_delta=delta,
        p_value=p_value,
        sims=sims,
    )


def ghost_test_summary_dict(res: GhostTestResult) -> dict[str, Any]:
    return {
        "sharpe_full": res.sharpe_full,
        "sharpe_baseline_mean": res.sharpe_baseline_mean,
        "sharpe_baseline_std": res.sharpe_baseline_std,
        "sharpe_delta": res.sharpe_delta,
        "p_value": res.p_value,
        "sims": res.sims,
    }
