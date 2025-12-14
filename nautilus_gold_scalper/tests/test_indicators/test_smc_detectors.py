import numpy as np

from src.core.definitions import AMDPhase, SignalType
from src.indicators.amd_cycle_tracker import AMDCycleTracker
from src.indicators.fvg_detector import FVGDetector
from src.indicators.liquidity_sweep import LiquiditySweepDetector
from src.indicators.order_block_detector import OrderBlockDetector


class TestOrderBlockDetector:
    def test_bullish_ob_detected_and_scored(self):
        detector = OrderBlockDetector(lookback_bars=50)
        n = 80
        base = 1900.0

        opens = np.linspace(base, base + 0.4, n)
        closes = opens + 0.05
        highs = closes + 0.05
        lows = opens - 0.05
        volumes = np.ones(n) * 1_000
        timestamps = np.arange(n)

        # Barra candidata a OB (grande corpo + volume) em i=60
        opens[60] = base + 0.6
        closes[60] = base + 2.1
        highs[60] = closes[60] + 0.1
        lows[60] = opens[60] - 0.2
        volumes[60] = 2_000

        # Movimento impulsivo subsequente
        closes[61:66] = np.array([base + 3, base + 4, base + 5.5, base + 7.0, base + 8.5])
        highs[61:66] = closes[61:66] + 0.2
        lows[61:66] = closes[61:66] - 0.3

        obs = detector.detect(opens, highs, lows, closes, volumes, timestamps, current_price=base + 8.0)

        assert obs, "Deve detectar ao menos um OB"
        assert any(o.direction == SignalType.SIGNAL_BUY for o in obs)
        assert detector.get_ob_score(base + 8.0, SignalType.SIGNAL_BUY) > 0


class TestFVGDetector:
    def test_bullish_fvg_detected(self):
        fvgd = FVGDetector()
        highs = np.array([1900.0, 1905.0, 1920.0])
        lows = np.array([1895.0, 1900.0, 1915.0])
        closes = np.array([1898.0, 1903.0, 1918.0])
        timestamps = np.array([0, 1, 2])

        fvgs = fvgd.detect(highs, lows, closes, timestamps, current_price=1918.0)

        bullish_fvgs = [f for f in fvgs if f.direction == SignalType.SIGNAL_BUY]
        assert bullish_fvgs, "Gap bullish deve ser detectado"
        assert bullish_fvgs[0].size_atr_ratio > 0


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
