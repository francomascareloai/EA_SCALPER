import numpy as np

from src.core.definitions import AMDPhase, SignalType
from src.indicators.amd_cycle_tracker import AMDCycleTracker
from src.indicators.fvg_detector import FVGDetector
from src.indicators.liquidity_sweep import LiquiditySweepDetector
from src.indicators.order_block_detector import OrderBlockDetector
from src.indicators.structure_analyzer import StructureAnalyzer


class TestOrderBlockDetector:
    def test_bullish_ob_detected_and_scored(self) -> None:
        detector = OrderBlockDetector(
            lookback_bars=50,
            displacement_threshold=5.0,
            volume_threshold=1.0,
            require_structure_break=False,
        )
        n = 80
        base = 1900.0

        opens = np.linspace(base, base + 0.4, n)
        closes = opens + 0.05
        highs = closes + 0.05
        lows = opens - 0.05
        volumes = np.ones(n) * 1_000
        timestamps = np.arange(n)

        # Candle 60 is the OB (bearish), candle 61 is the displacement confirmation
        opens[60] = base + 4.0
        closes[60] = base + 0.6
        highs[60] = opens[60] + 0.1
        lows[60] = closes[60] - 0.2
        volumes[60] = 2_000

        # Immediate displacement candle
        opens[61] = base + 0.6
        closes[61] = base + 8.0
        highs[61] = closes[61] + 0.2
        lows[61] = opens[61] - 0.3

        obs = detector.detect(
            opens, highs, lows, closes, volumes, timestamps, current_price=base + 8.0
        )

        assert obs, "Deve detectar ao menos um OB"
        assert any(o.direction == SignalType.SIGNAL_BUY for o in obs)
        assert detector.get_ob_score(base + 8.0, SignalType.SIGNAL_BUY) > 0

    def test_ob_is_not_detected_without_displacement_confirmation(self) -> None:
        detector = OrderBlockDetector(
            lookback_bars=50,
            displacement_threshold=5.0,
            volume_threshold=1.0,
            require_structure_break=False,
        )
        n = 80
        base = 1900.0

        opens = np.linspace(base, base + 0.4, n)
        closes = opens + 0.05
        highs = closes + 0.05
        lows = opens - 0.05
        volumes = np.ones(n) * 1_000
        timestamps = np.arange(n)

        # Candle 60 looks like an OB, but we do NOT include the displacement candle in the data.
        opens[60] = base + 2.1
        closes[60] = base + 0.6
        highs[60] = opens[60] + 0.1
        lows[60] = closes[60] - 0.2
        volumes[60] = 2_000

        cutoff = 61
        obs = detector.detect(
            opens[:cutoff],
            highs[:cutoff],
            lows[:cutoff],
            closes[:cutoff],
            volumes[:cutoff],
            timestamps[:cutoff],
            current_price=float(closes[cutoff - 1]),
        )

        assert not obs

    def test_ob_requires_structure_break_when_enabled(self) -> None:
        detector = OrderBlockDetector(
            lookback_bars=50,
            displacement_threshold=5.0,
            volume_threshold=1.0,
            require_structure_break=True,
        )
        n = 80
        base = 1900.0

        opens = np.linspace(base, base + 0.4, n)
        closes = opens + 0.05
        highs = closes + 0.05
        lows = opens - 0.05
        volumes = np.ones(n) * 1_000
        timestamps = np.arange(n)

        # Create an OB-like pattern at (60, 61) with displacement above OB high,
        # but NOT breaking above prior structure high.
        prior_struct_high = base + 20.0
        highs[:60] = prior_struct_high
        closes[:60] = highs[:60] - 0.05
        opens[:60] = closes[:60] - 0.05
        lows[:60] = opens[:60] - 0.05

        opens[60] = base + 4.0
        closes[60] = base + 0.6
        highs[60] = opens[60] + 0.1
        lows[60] = closes[60] - 0.2
        volumes[60] = 2_000

        # Displacement close above OB high, but still below prior_struct_high.
        opens[61] = base + 0.6
        closes[61] = prior_struct_high - 0.5
        highs[61] = closes[61] + 0.2
        lows[61] = opens[61] - 0.3

        obs = detector.detect(
            opens, highs, lows, closes, volumes, timestamps, current_price=float(closes[-1])
        )

        assert not obs


class TestFVGDetector:
    def test_bullish_fvg_detected(self) -> None:
        fvgd = FVGDetector(max_gap_size=200.0, min_displacement=1.0)
        opens = np.array([1899.0, 1902.0, 1912.0])
        highs = np.array([1900.0, 1905.0, 1920.0])
        lows = np.array([1895.0, 1900.0, 1910.0])
        closes = np.array([1898.0, 1903.0, 1918.0])
        timestamps = np.array([0, 1, 2]).astype("datetime64[s]")

        fvgs = fvgd.detect(opens, highs, lows, closes, None, timestamps, current_price=1918.0)

        bullish_fvgs = [f for f in fvgs if f.direction == SignalType.SIGNAL_BUY]
        assert bullish_fvgs, "Gap bullish deve ser detectado"
        assert bullish_fvgs[0].size_atr_ratio > 0
        assert bullish_fvgs[0].age_in_bars == 0

    def test_bullish_fvg_fill_percentage_uses_bar_low(self) -> None:
        import pytest

        fvgd = FVGDetector(max_gap_size=200.0, min_displacement=1.0)

        # Bullish FVG confirmed at index=2 from bars (0,1,2): high[0]=1900 < low[2]=1910.
        # Next bar trades down into the gap with low=1904.
        opens = np.array([1899.0, 1902.0, 1912.0, 1909.0])
        highs = np.array([1900.0, 1905.0, 1920.0, 1910.0])
        lows = np.array([1895.0, 1900.0, 1910.0, 1904.0])
        closes = np.array([1898.0, 1903.0, 1918.0, 1908.0])
        timestamps = np.arange(len(opens)).astype("datetime64[s]")

        fvgs = fvgd.detect(
            opens, highs, lows, closes, None, timestamps, current_price=float(closes[-1])
        )

        bullish_fvgs = [f for f in fvgs if f.direction == SignalType.SIGNAL_BUY]
        assert bullish_fvgs
        assert bullish_fvgs[0].fill_percentage == pytest.approx(60.0)
        assert bullish_fvgs[0].is_fresh is False

    def test_bearish_fvg_fill_percentage_uses_bar_high(self) -> None:
        import pytest

        fvgd = FVGDetector(max_gap_size=200.0, min_displacement=1.0)

        # Bearish FVG confirmed at index=2 from bars (0,1,2): high[2]=1900 < low[0]=1910.
        # Next bar trades up into the gap with high=1906.
        opens = np.array([1912.0, 1910.0, 1899.0, 1901.0])
        highs = np.array([1915.0, 1912.0, 1900.0, 1906.0])
        lows = np.array([1910.0, 1908.0, 1895.0, 1898.0])
        closes = np.array([1911.0, 1909.0, 1897.0, 1904.0])
        timestamps = np.arange(len(opens)).astype("datetime64[s]")

        fvgs = fvgd.detect(
            opens, highs, lows, closes, None, timestamps, current_price=float(closes[-1])
        )

        bearish_fvgs = [f for f in fvgs if f.direction == SignalType.SIGNAL_SELL]
        assert bearish_fvgs

        # Multiple bearish FVGs can be present; pick the one with the largest gap.
        target = max(bearish_fvgs, key=lambda f: f.upper_level - f.lower_level)
        assert target.fill_percentage == pytest.approx(60.0)
        assert target.is_fresh is False

    def test_fvg_age_in_bars_increments_over_time(self) -> None:
        fvgd = FVGDetector(max_gap_size=200.0, min_displacement=1.0)

        # Build a dataset where a bullish FVG is confirmed at index=2.
        # Then extend the series; the same FVG should have age_in_bars == (n-1) - 2.
        opens = np.array([1899.0, 1902.0, 1912.0, 1910.0, 1911.0])
        highs = np.array([1900.0, 1905.0, 1920.0, 1915.0, 1916.0])
        lows = np.array([1895.0, 1900.0, 1910.0, 1909.0, 1910.5])
        closes = np.array([1898.0, 1903.0, 1918.0, 1912.0, 1914.0])
        timestamps = np.arange(len(opens)).astype("datetime64[s]")

        fvgs = fvgd.detect(
            opens, highs, lows, closes, None, timestamps, current_price=float(closes[-1])
        )
        bullish_fvgs = [f for f in fvgs if f.direction == SignalType.SIGNAL_BUY]
        assert bullish_fvgs, "Gap bullish deve ser detectado"

        # Confirming index=2, current bar index=n-1 => expected_age=(n-1)-2
        expected_age = (len(opens) - 1) - 2
        assert bullish_fvgs[0].age_in_bars == expected_age

    def test_fvg_requires_three_bars(self) -> None:
        fvgd = FVGDetector()
        opens = np.array([1900.0, 1905.0])
        highs = np.array([1900.0, 1905.0])
        lows = np.array([1895.0, 1900.0])
        closes = np.array([1898.0, 1903.0])
        timestamps = np.array([0, 1]).astype("datetime64[s]")

        import pytest

        with pytest.raises(Exception):
            fvgd.detect(opens, highs, lows, closes, None, timestamps, current_price=1903.0)


class TestLiquiditySweepDetector:
    def test_bearish_sweep_on_swing_high(self) -> None:
        detector = LiquiditySweepDetector()
        highs = np.array([100.0, 101.0, 102.0, 103.0, 104.0, 107.0])
        lows = np.array([99.5, 100.5, 101.5, 102.0, 103.0, 101.0])
        closes = np.array([99.8, 100.8, 101.7, 102.5, 102.8, 102.2])
        timestamps = np.arange(len(highs)).astype("datetime64[s]")

        swing_highs = [103.0, 104.0]
        swing_lows = [99.0]

        # detect() returns Tuple[List[LiquidityPool], List[LiquiditySweep]]
        pools, sweeps = detector.detect(highs, lows, closes, timestamps, swing_highs, swing_lows)

        assert pools or sweeps, "Should detect pools or sweeps"
        recent = detector.get_recent_sweep(SignalType.SIGNAL_SELL)
        assert recent is not None
        assert recent.direction == SignalType.SIGNAL_SELL
        assert detector.get_sweep_score(SignalType.SIGNAL_SELL) > 0


class TestStructureAnalyzer:
    def test_min_swing_distance_replaces_nearby_more_extreme_swing(self) -> None:
        analyzer = StructureAnalyzer(swing_strength=1, min_swing_distance=5, lookback_bars=10)

        # Construct highs so we get two swing-high candidates close together.
        highs = np.array([100.0, 101.0, 100.0, 102.0, 101.0, 100.0])
        lows = np.array([99.0] * len(highs))
        closes = np.array([99.5] * len(highs))
        timestamps = np.arange(len(highs)).astype("datetime64[s]")

        state = analyzer.analyze(
            highs, lows, closes, timestamps=timestamps, current_price=float(closes[-1])
        )

        # With min_swing_distance=5 and swing_strength=1, the later, more extreme swing-high
        # should replace the earlier one rather than adding a second swing.
        assert state.last_high is not None
        assert state.last_high.price == 102.0

    def test_min_swing_distance_replaces_nearby_more_extreme_swing_low(self) -> None:
        """BUG-SMC-003: min_swing_distance must also apply to swing lows."""
        analyzer = StructureAnalyzer(swing_strength=1, min_swing_distance=5, lookback_bars=10)

        # Construct lows so we get two swing-low candidates close together.
        # swing_strength=1 means we need 1 bar on each side higher than the candidate.
        # With 6 bars total and candidates at indices 1 and 3, both confirmed at i=2 and i=4.
        highs = np.array([101.0] * 6)
        lows = np.array(
            [100.0, 99.0, 100.0, 98.0, 100.0, 100.0]
        )  # Two swing lows: 99 at idx 1, 98 at idx 3
        closes = np.array([100.5] * 6)
        timestamps = np.arange(len(highs)).astype("datetime64[s]")

        state = analyzer.analyze(
            highs, lows, closes, timestamps=timestamps, current_price=float(closes[-1])
        )

        # With min_swing_distance=5 and swing_strength=1, the later, more extreme swing-low (98.0)
        # should replace the earlier one (99.0) rather than adding a second swing.
        assert state.last_low is not None
        assert state.last_low.price == 98.0, f"Expected 98.0 but got {state.last_low.price}"
        # Should only have one swing low (replacement, not append)
        assert len(analyzer._swing_lows) == 1, (
            f"Expected 1 swing low, got {len(analyzer._swing_lows)}"
        )

    def test_has_recent_sweep_respects_within_bars(self) -> None:
        detector = LiquiditySweepDetector(min_sweep_depth=1.0, lookback_bars=100)

        # Build a series with a sweep at bar index 8, then extend to 20 bars.
        highs = np.array(
            [
                100.0,
                100.2,
                100.1,
                100.3,
                100.25,
                100.35,
                100.4,
                100.45,
                102.0,  # sweep bar (spike above level)
                100.2,
            ]
            + [100.0] * 10
        )
        lows = np.array([99.8] * len(highs))
        closes = np.array([99.9] * 8 + [99.7] + [99.9] * (len(highs) - 9))
        timestamps = np.arange(len(highs)).astype("datetime64[s]")

        # Force a BSL pool at 101.0 which is swept by highs[8].
        swing_highs = [101.0]
        swing_lows: list[float] = []

        _pools, _sweeps = detector.detect(highs, lows, closes, timestamps, swing_highs, swing_lows)
        assert detector.has_recent_sweep(within_bars=3) is False
        assert detector.has_recent_sweep(within_bars=20) is True

    def test_eqh_or_eql_bias_is_ranging(self) -> None:
        analyzer = StructureAnalyzer(swing_strength=1, min_swing_distance=1, lookback_bars=10)

        # Construct a series which produces an equal-high (EQH) on the last swing high
        # while the last swing low is a higher-low (HL). Bias should fail-closed to RANGING.
        highs = np.array([100.0, 101.0, 100.0, 101.0, 100.0, 101.0])
        lows = np.array([99.0, 100.0, 99.1, 100.1, 99.2, 100.2])
        closes = np.array([99.5, 100.5, 99.6, 100.6, 99.7, 100.7])
        timestamps = np.arange(len(highs)).astype("datetime64[s]")

        state = analyzer.analyze(
            highs, lows, closes, timestamps=timestamps, current_price=float(closes[-1])
        )

        assert state.bias == state.bias.RANGING


class TestAMDTracker:
    def test_accumulation_detected(self) -> None:
        amd = AMDCycleTracker()
        n = 40
        highs = np.ones(n) * 100.2
        lows = np.ones(n) * 100.0
        closes = np.ones(n) * 100.1
        volumes = np.ones(n) * 1_000
        timestamps = np.arange(n)

        state = amd.analyze(highs, lows, closes, volumes, timestamps)

        assert state.phase == AMDPhase.AMD_ACCUMULATION
        assert amd.get_amd_score() >= 0
