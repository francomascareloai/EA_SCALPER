"""Monte Carlo drawdown stress test utilities.

Computes distribution of max drawdown (%) via block bootstrap resampling of returns.

Units:
- Drawdown values are returned as percentages in [0, 100].

IMPORTANT:
- This is an offline stress test to rank/flag candidates.
- It does NOT replace Apex-grade trailing DD computation from tick-level MTM equity.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any

import numpy as np
import pandas as pd
from numpy.typing import NDArray


def _max_drawdown_pct(equity: NDArray[np.floating[Any]]) -> float:
    """Compute max drawdown percentage from an equity curve.

    Formula:
        dd_pct(t) = (HWM(t) - equity(t)) / HWM(t) * 100
        max_dd_pct = max_t dd_pct(t)

    Example:
        equity = [100000, 102000, 99000]
        HWM    = [100000, 102000, 102000]
        DD%    = [0.00, 0.00, 2.94]
    """
    if equity.size < 2:
        return 0.0

    equity = equity.astype(np.float64, copy=False)
    running_max = np.maximum.accumulate(equity)

    # Guard running_max <= 0 (invalid equity) by setting dd to NaN.
    with np.errstate(divide="ignore", invalid="ignore"):
        dd = (running_max - equity) / running_max * 100.0
        dd = np.where(running_max > 0.0, dd, np.nan)

    max_dd = float(np.nanmax(dd))
    if not np.isfinite(max_dd):
        return 100.0

    # Sanity bounds.
    return float(max(0.0, min(100.0, max_dd)))


def _block_bootstrap_indices(
    n: int,
    *,
    rng: np.random.Generator,
    block_size: int,
) -> NDArray[np.int64]:
    if n <= 0:
        return np.empty(0, dtype=np.int64)

    if block_size <= 1:
        return rng.integers(0, n, size=n, dtype=np.int64)

    n_blocks = int(np.ceil(n / block_size))
    starts = rng.integers(0, n, size=n_blocks, dtype=np.int64)

    idx = np.empty(n, dtype=np.int64)
    pos = 0
    for s in starts:
        take = min(block_size, n - pos)
        block = np.arange(int(s), int(s) + take, dtype=np.int64)
        block = np.mod(block, n)
        idx[pos : pos + take] = block
        pos += take
        if pos >= n:
            break

    return idx.copy()


def _parse_block_size(block_size: str, n: int) -> int:
    if n <= 0:
        return 1

    if block_size == "auto":
        # Heuristic: n^(1/3), minimum 2.
        return max(2, int(round(n ** (1.0 / 3.0))))

    try:
        v = int(block_size)
    except Exception as exc:
        raise ValueError(f"Invalid block_size: {block_size!r}") from exc

    return max(1, v)


@dataclass(frozen=True, slots=True)
class MonteCarloDDResult:
    mc_95_dd: float
    mc_99_dd: float


def compute_mc_drawdown_percentiles_from_trades(
    trades_df: pd.DataFrame,
    *,
    start_equity: float,
    simulations: int,
    seed: int,
    block_bootstrap: bool,
    block_size: str,
    pnl_col: str = "pnl",
) -> MonteCarloDDResult:
    """Compute Monte Carlo drawdown percentiles from realized trade PnL.

    We bootstrap *trade PnL deltas* to construct synthetic equity paths, then compute
    max drawdown (%) for each path.

    If inputs are invalid/too short, returns fail-closed 100% DD.

    Notes:
    - This is intended to be fast: it operates on trade-level series, not tick-level equity.
    """
    if simulations <= 0:
        raise ValueError("simulations must be > 0")

    if trades_df is None or trades_df.empty or pnl_col not in trades_df.columns:
        return MonteCarloDDResult(mc_95_dd=100.0, mc_99_dd=100.0)

    start = float(start_equity)
    if not np.isfinite(start) or start <= 0.0:
        return MonteCarloDDResult(mc_95_dd=100.0, mc_99_dd=100.0)

    pnl = trades_df[pnl_col].astype(float).replace([np.inf, -np.inf], np.nan).dropna()
    deltas = pnl.to_numpy(dtype=np.float64, copy=False)

    if deltas.size < 1:
        return MonteCarloDDResult(mc_95_dd=100.0, mc_99_dd=100.0)

    if deltas.size < 2:
        equity = np.array([start, start + float(deltas[0])], dtype=np.float64)
        dd = _max_drawdown_pct(equity)
        return MonteCarloDDResult(mc_95_dd=dd, mc_99_dd=dd)

    rng = np.random.default_rng(int(seed))
    block_n = _parse_block_size(block_size, int(deltas.size))

    dd_samples = np.empty(int(simulations), dtype=np.float64)

    for i in range(int(simulations)):
        if block_bootstrap:
            idx = _block_bootstrap_indices(int(deltas.size), rng=rng, block_size=block_n)
        else:
            idx = rng.integers(0, int(deltas.size), size=int(deltas.size), dtype=np.int64)

        sim_deltas = deltas[idx]
        sim_equity = np.empty(sim_deltas.size + 1, dtype=np.float64)
        sim_equity[0] = start
        np.cumsum(sim_deltas, out=sim_equity[1:])
        sim_equity[1:] += start

        dd_samples[i] = _max_drawdown_pct(sim_equity)

    # Fail-closed if any simulation produced invalid values.
    dd_samples = np.where(np.isfinite(dd_samples), dd_samples, 100.0)

    mc_95 = float(np.percentile(dd_samples, 95))
    mc_99 = float(np.percentile(dd_samples, 99))

    assert 0.0 <= mc_95 <= 100.0, f"Invalid mc_95_dd: {mc_95}"
    assert 0.0 <= mc_99 <= 100.0, f"Invalid mc_99_dd: {mc_99}"

    return MonteCarloDDResult(mc_95_dd=mc_95, mc_99_dd=mc_99)


def compute_mc_drawdown_percentiles(
    equity_series: pd.Series | None,
    *,
    simulations: int,
    seed: int,
    block_bootstrap: bool,
    block_size: str,
) -> MonteCarloDDResult:
    """Compute Monte Carlo drawdown percentiles.

    We bootstrap *returns* (equity deltas) to construct synthetic equity paths,
    then compute max drawdown (%) for each path.

    If equity_series is invalid/too short, returns fail-closed 100% DD.
    """
    if simulations <= 0:
        raise ValueError("simulations must be > 0")

    if equity_series is None or len(equity_series) < 2:
        return MonteCarloDDResult(mc_95_dd=100.0, mc_99_dd=100.0)

    equity = equity_series.astype(float).replace([np.inf, -np.inf], np.nan).dropna()
    if len(equity) < 2:
        return MonteCarloDDResult(mc_95_dd=100.0, mc_99_dd=100.0)

    # Use equity deltas (not % returns) to avoid division artifacts at small equity.
    deltas = np.diff(equity.to_numpy(dtype=np.float64, copy=False))
    if deltas.size < 2:
        # With 1 delta we can still compute a single simulated path but percentile is trivial.
        dd = _max_drawdown_pct(equity.to_numpy(dtype=np.float64, copy=False))
        return MonteCarloDDResult(mc_95_dd=dd, mc_99_dd=dd)

    rng = np.random.default_rng(int(seed))
    block_n = _parse_block_size(block_size, int(deltas.size))

    dd_samples = np.empty(int(simulations), dtype=np.float64)

    start_equity = float(equity.iloc[0])
    if not np.isfinite(start_equity) or start_equity <= 0:
        return MonteCarloDDResult(mc_95_dd=100.0, mc_99_dd=100.0)

    for i in range(int(simulations)):
        if block_bootstrap:
            idx = _block_bootstrap_indices(int(deltas.size), rng=rng, block_size=block_n)
        else:
            idx = rng.integers(0, int(deltas.size), size=int(deltas.size), dtype=np.int64)

        sim_deltas = deltas[idx]
        sim_equity = np.empty(sim_deltas.size + 1, dtype=np.float64)
        sim_equity[0] = start_equity
        np.cumsum(sim_deltas, out=sim_equity[1:])
        sim_equity[1:] += start_equity

        dd_samples[i] = _max_drawdown_pct(sim_equity)

    # Fail-closed if any simulation produced invalid values.
    dd_samples = np.where(np.isfinite(dd_samples), dd_samples, 100.0)

    # Percentiles in percent units.
    mc_95 = float(np.percentile(dd_samples, 95))
    mc_99 = float(np.percentile(dd_samples, 99))

    # Sanity bounds.
    assert 0.0 <= mc_95 <= 100.0, f"Invalid mc_95_dd: {mc_95}"
    assert 0.0 <= mc_99 <= 100.0, f"Invalid mc_99_dd: {mc_99}"

    return MonteCarloDDResult(mc_95_dd=mc_95, mc_99_dd=mc_99)
