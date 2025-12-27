"""Matrix tests for signals.MTFManager.

These are deterministic contract tests which ensure MTFManager behaves fail-closed
and returns bounded outputs across multiple synthetic regimes.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any

import numpy as np
import pytest
from numpy.typing import NDArray

from src.signals.mtf_manager import MTFManager


@dataclass(frozen=True)
class MtfCase:
    name: str
    n: int
    slope: float


def _make_ohlc(n: int, slope: float, seed: int) -> dict[str, NDArray[Any]]:
    rng = np.random.default_rng(seed)
    base = 1900.0
    closes = base + np.cumsum(rng.normal(0.0, 0.6, n) + float(slope))
    highs = closes + rng.uniform(0.2, 1.2, n)
    lows = closes - rng.uniform(0.2, 1.2, n)
    timestamps = np.arange(n, dtype=np.int64).astype("datetime64[s]")

    return {
        "highs": highs.astype(np.float64),
        "lows": lows.astype(np.float64),
        "closes": closes.astype(np.float64),
        "timestamps": timestamps,
    }


CASES: list[MtfCase] = [
    MtfCase(name="bullish", n=260, slope=0.20),
    MtfCase(name="bearish", n=260, slope=-0.20),
    MtfCase(name="flat", n=260, slope=0.00),
]


@pytest.mark.parametrize("case", CASES, ids=lambda c: c.name)  # type: ignore[untyped-decorator]
def test_matrix_mtf_manager_contract(case: MtfCase) -> None:
    manager = MTFManager(
        # Ensure StructureAnalyzer has enough bars.
        htf_lookback_bars=100,
        mtf_lookback_bars=100,
        ltf_lookback_bars=50,
        # Ensure RegimeDetector has enough bars.
        regime_multiscale_periods=(50, 100, 200),
    )

    htf_data = _make_ohlc(case.n, case.slope, seed=1001)
    mtf_data = _make_ohlc(case.n, case.slope * 0.7, seed=1002)
    ltf_data = _make_ohlc(case.n, case.slope * 0.4, seed=1003)

    current_price = float(ltf_data["closes"][-1])
    state = manager.analyze(
        htf_data=htf_data,
        mtf_data=mtf_data,
        ltf_data=ltf_data,
        current_price=current_price,
        session_ok=True,
    )

    assert 0.0 <= float(state.mtf_score) <= 100.0
    assert isinstance(state.is_aligned, bool)


def test_matrix_mtf_manager_fail_closed_on_bad_input() -> None:
    manager = MTFManager()

    bad: dict[str, NDArray[Any]] = {}
    good = _make_ohlc(260, 0.1, seed=2001)

    state = manager.analyze(
        htf_data=bad,  # invalid
        mtf_data=good,
        ltf_data=good,
        current_price=float(good["closes"][-1]),
        session_ok=True,
    )

    assert state.htf_analysis is None
    assert state.mtf_analysis is None
    assert state.ltf_analysis is None
    assert state.mtf_score == 0.0
    assert state.is_aligned is False


def test_matrix_mtf_manager_rejects_non_monotonic_timestamps() -> None:
    manager = MTFManager()

    good = _make_ohlc(260, 0.1, seed=2002)
    ts = good["timestamps"].copy()
    ts[10], ts[11] = ts[11], ts[10]  # break monotonicity
    bad_ts = {**good, "timestamps": ts}

    state = manager.analyze(
        htf_data=bad_ts,
        mtf_data=good,
        ltf_data=good,
        current_price=float(good["closes"][-1]),
        session_ok=True,
    )

    # Validation should fail early.
    assert state.htf_analysis is None
    assert state.mtf_score == 0.0


def test_matrix_mtf_manager_blocks_when_session_not_ok() -> None:
    manager = MTFManager()

    good = _make_ohlc(260, 0.1, seed=2003)
    state = manager.analyze(
        htf_data=good,
        mtf_data=good,
        ltf_data=good,
        current_price=float(good["closes"][-1]),
        session_ok=False,
    )

    assert "Session" in state.diagnosis
    assert state.mtf_score == 0.0
