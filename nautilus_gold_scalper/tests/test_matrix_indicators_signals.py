"""Matrix tests for core indicators/signals.

Goal: catch regressions across modules with deterministic synthetic inputs.

These are intentionally light-weight unit/contract tests:
- No Nautilus backtest engine required
- No data files required
- Must be fast and deterministic
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any

import numpy as np
import pytest
from numpy.typing import NDArray

from src.core.definitions import SignalType
from src.indicators.amd_cycle_tracker import AMDCycleTracker
from src.indicators.fvg_detector import FVGDetector
from src.indicators.liquidity_sweep import LiquiditySweepDetector
from src.indicators.order_block_detector import OrderBlockDetector
from src.indicators.regime_detector import RegimeDetector
from src.indicators.structure_analyzer import StructureAnalyzer


@dataclass(frozen=True)
class MatrixCase:
    name: str
    n: int
    kind: str  # trending | ranging | spike


def _make_ohlcv_case(case: MatrixCase) -> dict[str, NDArray[Any]]:
    rng = np.random.default_rng(1337)

    base = 1900.0
    n = case.n

    if case.kind == "trending":
        trend = 0.15
        noise = rng.normal(0.0, 0.5, n)
        closes = base + np.cumsum(trend + noise)
    elif case.kind == "ranging":
        noise = rng.normal(0.0, 0.35, n)
        closes = base + np.cumsum(noise)
    elif case.kind == "spike":
        noise = rng.normal(0.0, 0.4, n)
        closes = base + np.cumsum(noise)
        if n >= 10:
            closes[n // 2] += 10.0
            closes[n // 2 + 1] -= 8.0
    else:
        raise ValueError(f"Unknown case kind: {case.kind}")

    highs = closes + rng.uniform(0.2, 1.2, n)
    lows = closes - rng.uniform(0.2, 1.2, n)
    opens = np.roll(closes, 1)
    opens[0] = closes[0]
    volumes = rng.integers(900, 1100, n).astype(float)

    # deterministic synthetic timestamps
    timestamps = np.arange(n, dtype=np.int64).astype("datetime64[s]")

    return {
        "opens": opens.astype(float),
        "highs": highs.astype(float),
        "lows": lows.astype(float),
        "closes": closes.astype(float),
        "volumes": volumes.astype(float),
        "timestamps": timestamps,
    }


MATRIX_CASES: list[MatrixCase] = [
    # 80 bars is enough for OB/FVG/liquidity/structure but not for RegimeDetector (min_bars=200 by default).
    MatrixCase(name="small_trending", n=80, kind="trending"),
    MatrixCase(name="small_ranging", n=80, kind="ranging"),
    MatrixCase(name="medium_trending", n=200, kind="trending"),
    MatrixCase(name="medium_spike", n=200, kind="spike"),
]


@pytest.mark.parametrize("case", MATRIX_CASES, ids=lambda c: c.name)  # type: ignore[untyped-decorator]
def test_matrix_order_block_detector(case: MatrixCase) -> None:
    data = _make_ohlcv_case(case)

    detector = OrderBlockDetector(
        lookback_bars=50,
        displacement_threshold=5.0,
        volume_threshold=1.0,
        require_structure_break=False,
    )

    obs = detector.detect(
        data["opens"],
        data["highs"],
        data["lows"],
        data["closes"],
        data["volumes"],
        data["timestamps"],
        current_price=float(data["closes"][-1]),
    )

    assert isinstance(obs, list)
    # Contract: score accessor must be safe even when no OB exists.
    score_buy = detector.get_ob_score(float(data["closes"][-1]), SignalType.SIGNAL_BUY)
    score_sell = detector.get_ob_score(float(data["closes"][-1]), SignalType.SIGNAL_SELL)
    assert 0.0 <= float(score_buy) <= 100.0
    assert 0.0 <= float(score_sell) <= 100.0


@pytest.mark.parametrize("case", MATRIX_CASES, ids=lambda c: c.name)  # type: ignore[untyped-decorator]
def test_matrix_fvg_detector(case: MatrixCase) -> None:
    data = _make_ohlcv_case(case)

    fvgd = FVGDetector(max_gap_size=200.0, min_displacement=1.0)
    fvgs = fvgd.detect(
        data["opens"],
        data["highs"],
        data["lows"],
        data["closes"],
        data["volumes"],
        data["timestamps"],
        current_price=float(data["closes"][-1]),
    )

    assert isinstance(fvgs, list)
    # Contract: if present, fields must be sane.
    for f in fvgs:
        assert f.confluence_score >= 0
        assert f.age_in_bars >= 0
        assert 0.0 <= float(f.fill_percentage) <= 100.0


@pytest.mark.parametrize("case", MATRIX_CASES, ids=lambda c: c.name)  # type: ignore[untyped-decorator]
def test_matrix_liquidity_sweep_detector(case: MatrixCase) -> None:
    data = _make_ohlcv_case(case)

    detector = LiquiditySweepDetector(min_sweep_depth=1.0, lookback_bars=100)
    pools, sweeps = detector.detect(
        data["highs"],
        data["lows"],
        data["closes"],
        data["timestamps"],
        swing_highs=[float(np.max(data["highs"])) - 0.5],
        swing_lows=[float(np.min(data["lows"])) + 0.5],
        current_price=float(data["closes"][-1]),
        opens=data["opens"],
    )

    assert isinstance(pools, list)
    assert isinstance(sweeps, list)
    # Contract: score getters and recent sweep must be safe.
    assert detector.get_sweep_score(SignalType.SIGNAL_BUY) >= 0
    assert detector.get_sweep_score(SignalType.SIGNAL_SELL) >= 0
    _recent_buy = detector.get_recent_sweep(SignalType.SIGNAL_BUY)
    _recent_sell = detector.get_recent_sweep(SignalType.SIGNAL_SELL)
    assert (_recent_buy is None) or (_recent_buy.direction == SignalType.SIGNAL_BUY)
    assert (_recent_sell is None) or (_recent_sell.direction == SignalType.SIGNAL_SELL)


@pytest.mark.parametrize("case", MATRIX_CASES, ids=lambda c: c.name)  # type: ignore[untyped-decorator]
def test_matrix_structure_analyzer(case: MatrixCase) -> None:
    data = _make_ohlcv_case(case)

    sa = StructureAnalyzer(swing_strength=1, min_swing_distance=5, lookback_bars=50)
    state = sa.analyze(
        data["highs"],
        data["lows"],
        data["closes"],
        timestamps=data["timestamps"],
        current_price=float(data["closes"][-1]),
    )

    assert state is not None
    bias = sa.get_market_bias()
    assert bias in [bias.BULLISH, bias.BEARISH, bias.RANGING, bias.TRANSITION]


@pytest.mark.parametrize("case", MATRIX_CASES, ids=lambda c: c.name)  # type: ignore[untyped-decorator]
def test_matrix_regime_detector(case: MatrixCase) -> None:
    data = _make_ohlcv_case(case)

    rd = RegimeDetector()

    if case.n < 200:
        # Contract: regime detection is deliberately fail-closed when there is not enough data.
        with pytest.raises(Exception):
            rd.analyze(data["closes"])
        return

    analysis = rd.analyze(data["closes"])

    assert analysis.is_valid is True
    assert 0.0 <= float(analysis.hurst_exponent) <= 2.0
    assert float(analysis.size_multiplier) >= 0.0


@pytest.mark.parametrize("case", MATRIX_CASES, ids=lambda c: c.name)  # type: ignore[untyped-decorator]
def test_matrix_amd_cycle_tracker(case: MatrixCase) -> None:
    data = _make_ohlcv_case(case)

    amd = AMDCycleTracker()
    state = amd.analyze(
        data["opens"],
        data["highs"],
        data["lows"],
        data["closes"],
        timestamps=data["timestamps"],
    )

    assert state.is_valid in (True, False)
    score = amd.get_amd_score()
    assert 0.0 <= float(score) <= 100.0


def test_matrix_rejects_insufficient_data_consistently() -> None:
    # Contract: these detectors must fail closed on too-short series.
    closes = np.array([1.0, 2.0], dtype=float)
    highs = closes + 0.1
    lows = closes - 0.1
    opens = closes
    volumes = np.array([1.0, 1.0], dtype=float)
    ts = np.arange(len(closes), dtype=np.int64).astype("datetime64[s]")

    with pytest.raises(Exception):
        FVGDetector().detect(
            opens, highs, lows, closes, volumes, ts, current_price=float(closes[-1])
        )

    with pytest.raises(Exception):
        OrderBlockDetector(lookback_bars=50).detect(
            opens, highs, lows, closes, volumes, ts, current_price=float(closes[-1])
        )

    with pytest.raises(Exception):
        LiquiditySweepDetector().detect(highs, lows, closes, ts)

    with pytest.raises(Exception):
        StructureAnalyzer(lookback_bars=100).analyze(highs, lows, closes, ts)

    with pytest.raises(Exception):
        AMDCycleTracker().analyze(opens, highs, lows, closes, ts)
