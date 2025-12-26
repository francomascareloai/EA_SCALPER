import numpy as np

from src.core.definitions import AMDPhase, SignalType
from src.indicators.amd_cycle_tracker import AMDCycleTracker
from src.indicators.fvg_detector import FVGDetector
from src.indicators.liquidity_sweep import LiquiditySweepDetector
from src.indicators.order_block_detector import OrderBlockDetector


class TestOrderBlockDetector:
    def test_bullish_ob_detected_and_scored(self):
        detector = OrderBlockDetector(
            lookback_bars=50, displacement_threshold=5.0, volume_threshold=1.0
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

    def test_ob_is_not_detected_without_displacement_confirmation(self):
        detector = OrderBlockDetector(
            lookback_bars=50, displacement_threshold=5.0, volume_threshold=1.0
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


class TestFVGDetector:
    def test_bullish_fvg_detected(self):
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

    def test_fvg_age_in_bars_increments_over_time(self):
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

    def test_fvg_requires_three_bars(self):
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
    def test_bearish_sweep_on_swing_high(self):
        detector = LiquiditySweepDetector()
        highs = np.array([100.0, 101.0, 102.0, 103.0, 104.0, 107.0])
        lows = np.array([99.5, 100.5, 101.5, 102.0, 103.0, 101.0])
        closes = np.array([99.8, 100.8, 101.7, 102.5, 102.8, 102.2])
        timestamps = np.arange(len(highs))

        swing_highs = [103.0, 104.0]
        swing_lows = [99.0]

        # detect() returns Tuple[List[LiquidityPool], List[LiquiditySweep]]
        pools, sweeps = detector.detect(highs, lows, closes, timestamps, swing_highs, swing_lows)

        assert pools or sweeps, "Should detect pools or sweeps"
        recent = detector.get_recent_sweep(SignalType.SIGNAL_SELL)
        assert recent is not None
        assert recent.direction == SignalType.SIGNAL_SELL
        assert detector.get_sweep_score(SignalType.SIGNAL_SELL) > 0


class TestAMDTracker:
    def test_accumulation_detected(self):
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
