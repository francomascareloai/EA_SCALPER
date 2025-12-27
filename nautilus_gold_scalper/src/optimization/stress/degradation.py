"""Degradation (edge decay) stress test utilities.

This module applies a simple, conservative degradation transform to realized trade PnL
and checks whether the degraded equity path still "survives" basic health checks.

Definitions:
- We treat degradation rate r as reducing ONLY positive PnL by (1 - r).
  Losses are left unchanged (conservative).
- We reconstruct an equity path from `start_equity` + cumulative sum of degraded PnL.
- We compute max drawdown (%) from the reconstructed equity path:
    dd_pct(t) = (HWM(t) - equity(t)) / HWM(t) * 100

This is an offline stress test for ranking/flagging candidates.
"""

from __future__ import annotations

from typing import Any

import numpy as np
import pandas as pd
from numpy.typing import NDArray


def _max_drawdown_pct(equity: NDArray[np.floating[Any]]) -> float:
    """Compute max drawdown percentage from an equity curve.

    Units: returns percentage in [0, 100].
    """
    if equity.size < 2:
        return 0.0

    equity = equity.astype(np.float64, copy=False)
    running_max = np.maximum.accumulate(equity)

    with np.errstate(divide="ignore", invalid="ignore"):
        dd = (running_max - equity) / running_max * 100.0
        dd = np.where(running_max > 0.0, dd, np.nan)

    max_dd = float(np.nanmax(dd))
    if not np.isfinite(max_dd):
        return 100.0

    return float(max(0.0, min(100.0, max_dd)))


def _apply_degradation(pnl: NDArray[np.floating[Any]], rate: float) -> NDArray[np.float64]:
    """Apply degradation to realized PnL.

    Conservative transform:
    - Positive pnl is scaled by (1 - rate)
    - Negative pnl is unchanged
    """
    pnl = pnl.astype(np.float64, copy=False)
    out = pnl.copy()

    pos_mask = out > 0.0
    out[pos_mask] *= 1.0 - float(rate)
    return out


def compute_degradation_survived(
    trades_df: pd.DataFrame,
    *,
    start_equity: float,
    rates: list[float],
    dd_limit_pct: float,
    pnl_col: str = "pnl",
) -> list[float]:
    """Return degradation rates which the candidate "survives".

    Survival criteria (minimal, conservative):
    - Total degraded PnL > 0
    - Max drawdown (%) on degraded equity path <= dd_limit_pct

    Notes:
    - If inputs are invalid, returns an empty list (fail-closed).
    """
    if trades_df is None or trades_df.empty:
        return []
    if pnl_col not in trades_df.columns:
        return []

    start = float(start_equity)
    if not np.isfinite(start) or start <= 0.0:
        return []

    dd_limit = float(dd_limit_pct)
    if not np.isfinite(dd_limit) or dd_limit <= 0.0 or dd_limit > 100.0:
        raise ValueError(f"dd_limit_pct must be in (0, 100], got {dd_limit_pct}")

    pnl = (
        trades_df[pnl_col]
        .astype(float)
        .replace([np.inf, -np.inf], np.nan)
        .dropna()
        .to_numpy(dtype=np.float64, copy=False)
    )
    if pnl.size == 0:
        return []

    survived: list[float] = []

    for r in rates:
        rate = float(r)
        if not np.isfinite(rate) or rate < 0.0 or rate >= 1.0:
            raise ValueError(f"degradation rate must be in [0, 1), got {r}")

        degraded = _apply_degradation(pnl, rate)

        equity = np.empty(degraded.size + 1, dtype=np.float64)
        equity[0] = start
        np.cumsum(degraded, out=equity[1:])
        equity[1:] += start

        total_pnl = float(np.sum(degraded))
        dd_pct = _max_drawdown_pct(equity)

        if total_pnl > 0.0 and dd_pct <= dd_limit:
            survived.append(rate)

    return survived
