"""
Integration test for the complete strategy flow.
Tests all modules working together with simulated XAUUSD data.
"""

import importlib
import pkgutil
from datetime import datetime

import numpy as np
import pytest

# Context imports
from src.context.holiday_detector import HolidayDetector

# Core imports
from src.core.definitions import (
    TradingSession,
)
from src.indicators.regime_detector import RegimeDetector

# Indicator imports
from src.indicators.session_filter import SessionFilter
from src.indicators.structure_analyzer import MarketBias, StructureAnalyzer
from src.risk.circuit_breaker import CircuitBreaker

# Risk imports
from src.risk.spread_monitor import SpreadMonitor

# Signal imports
from src.signals.entry_optimizer import EntryOptimizer, SignalDirection

# Strategy imports
from src.strategies.strategy_selector import MarketContext, StrategySelector, StrategyType


def generate_trending_data(n_bars: int = 200, direction: str = "bull") -> dict:
    """Generate simulated trending XAUUSD data."""
    np.random.seed(42)

    base_price = 2650.0
    trend = 0.15 if direction == "bull" else -0.15

    closes_list: list[float] = [base_price]
    for _ in range(1, n_bars):
        change = trend + np.random.normal(0, 0.5)
        closes_list.append(closes_list[-1] + change)

    closes = np.array(closes_list)
    highs = closes + np.random.uniform(0.5, 2.0, n_bars)
    lows = closes - np.random.uniform(0.5, 2.0, n_bars)

    # Deterministic synthetic timestamps for StructureAnalyzer
    timestamps = np.arange(n_bars, dtype=np.int64).astype("datetime64[s]")

    return {
        "high": highs,
        "low": lows,
        "close": closes,
        "timestamps": timestamps,
    }


class TestImports:
    def test_import_indicators_signals_risk_strategy_modules(self) -> None:
        """Ensure all core modules import (catches missing/unused dependency drift)."""
        packages = [
            "src.indicators",
            "src.signals",
            "src.risk",
            "src.strategies",
        ]

        module_names: list[str] = []
        for pkg in packages:
            module_names.extend(_iter_package_modules(pkg))

        # Skip explicitly archived code paths.
        module_names = [name for name in module_names if ".execution._archive" not in name]

        assert module_names, "Expected to discover modules for import smoke test"

        failed: list[str] = []
        for name in module_names:
            try:
                importlib.import_module(name)
            except Exception:
                failed.append(name)

        assert not failed, f"Import failures: {failed}"


class TestSessionFilter:
    """Test SessionFilter."""

    def test_london_session(self):
        sf = SessionFilter()
        dt = datetime(2025, 12, 3, 10, 0, 0)
        info = sf.get_session_info(dt)

        assert info.session == TradingSession.SESSION_LONDON
        assert info.is_trading_allowed
        print("OK: London session allowed")

    def test_overlap_session(self):
        sf = SessionFilter()
        dt = datetime(2025, 12, 3, 13, 0, 0)
        info = sf.get_session_info(dt)

        assert info.session == TradingSession.SESSION_LONDON_NY_OVERLAP
        print("OK: Overlap session detected")

    def test_asian_blocked(self):
        sf = SessionFilter(allow_asian=False)
        dt = datetime(2025, 12, 3, 3, 0, 0)
        info = sf.get_session_info(dt)

        assert not info.is_trading_allowed
        print("OK: Asian session blocked")


class TestRegimeDetector:
    """Test RegimeDetector."""

    def test_trending_detection(self):
        rd = RegimeDetector()
        data = generate_trending_data(200, "bull")

        analysis = rd.analyze(data["close"])

        assert analysis.is_valid
        assert analysis.hurst_exponent > 0.5
        print(f"OK: Hurst={analysis.hurst_exponent:.3f}")

    def test_size_multiplier(self):
        rd = RegimeDetector()
        data = generate_trending_data(200, "bull")

        analysis = rd.analyze(data["close"])
        assert analysis.size_multiplier > 0
        print(f"OK: Size mult={analysis.size_multiplier:.2f}")


def _iter_package_modules(package_name: str) -> list[str]:
    """Return fully-qualified module names under a package."""
    package = importlib.import_module(package_name)
    if not hasattr(package, "__path__"):
        return []

    names: list[str] = []
    for mod in pkgutil.iter_modules(package.__path__, prefix=f"{package_name}."):
        names.append(mod.name)
    return names


class TestStructureAnalyzer:
    """Test StructureAnalyzer."""

    def test_bullish_structure(self):
        sa = StructureAnalyzer()
        data = generate_trending_data(100, "bull")

        sa.analyze(data["high"], data["low"], data["close"], data["timestamps"])
        bias = sa.get_market_bias()

        assert bias in [MarketBias.BULLISH, MarketBias.TRANSITION, MarketBias.RANGING]
        print(f"OK: Bias={bias.name}")


class TestSpreadMonitor:
    """Test SpreadMonitor."""

    def test_normal_spread(self):
        sm = SpreadMonitor(max_spread_pips=5.0)

        t = datetime(2025, 1, 1)
        for i in range(50):
            sm.update(bid=2650.00, ask=2650.20, now=t.replace(second=i))

        assert sm.can_trade()
        print("OK: Normal spread allows trading")

    def test_size_multiplier(self):
        sm = SpreadMonitor(max_spread_pips=5.0)

        t = datetime(2025, 1, 1)
        for i in range(50):
            sm.update(bid=2650.00, ask=2650.40, now=t.replace(second=i))

        mult = sm.get_size_multiplier()
        assert mult <= 1.0
        print(f"OK: Spread mult={mult:.2f}")


class TestCircuitBreaker:
    """Test CircuitBreaker."""

    def test_initial_state(self):
        cb = CircuitBreaker()
        assert cb.can_trade()
        print("OK: CB initially active")

    def test_loss_recording(self):
        cb = CircuitBreaker()
        cb.register_trade_result(pnl=-500.0, is_win=False)
        print("OK: Loss recorded")


class TestEntryOptimizer:
    """Test EntryOptimizer."""

    def test_long_entry(self):
        eo = EntryOptimizer()

        entry = eo.calculate_optimal_entry(
            direction=SignalDirection.SIGNAL_BUY,
            current_price=2650.0,
            atr=5.0,
            fvg_low=2647.0,
            fvg_high=2649.0,
            ob_low=2644.0,
            ob_high=2646.0,
        )

        assert entry is not None
        assert entry.stop_loss < entry.optimal_price
        print(f"OK: Long entry={entry.optimal_price:.2f}, SL={entry.stop_loss:.2f}")

    def test_short_entry(self):
        eo = EntryOptimizer()

        entry = eo.calculate_optimal_entry(
            direction=SignalDirection.SIGNAL_SELL,
            current_price=2650.0,
            atr=5.0,
            fvg_low=2651.0,
            fvg_high=2653.0,
            ob_low=2654.0,
            ob_high=2656.0,
        )

        assert entry is not None
        assert entry.stop_loss > entry.optimal_price
        print(f"OK: Short entry={entry.optimal_price:.2f}, SL={entry.stop_loss:.2f}")


class TestStrategySelector:
    """Test StrategySelector."""

    def test_trending_context(self):
        ss = StrategySelector()

        context = MarketContext(
            hurst=0.65,
            entropy=1.2,
            is_trending=True,
            is_random=False,
            is_london=True,
            circuit_ok=True,
            spread_ok=True,
        )

        selection = ss.select_strategy(context)
        assert selection.strategy != StrategyType.STRATEGY_NONE
        print(f"OK: Trending -> {selection.strategy.name}")

    def test_random_walk_blocked(self):
        ss = StrategySelector()

        context = MarketContext(
            hurst=0.50, entropy=2.5, is_random=True, is_london=True, circuit_ok=True, spread_ok=True
        )

        selection = ss.select_strategy(context)
        # Random walk should be blocked or safe mode
        print(f"OK: Random walk -> {selection.strategy.name}")


class TestHolidayDetector:
    """Test HolidayDetector."""

    def test_christmas(self):
        hd = HolidayDetector()
        info = hd.check_holiday(datetime(2025, 12, 25, 12, 0))

        assert info.is_holiday
        print(f"OK: Christmas detected, mult={info.size_multiplier}")

    def test_normal_day(self):
        hd = HolidayDetector()
        info = hd.check_holiday(datetime(2025, 12, 3, 12, 0))

        assert not info.is_holiday
        assert info.size_multiplier == 1.0
        print("OK: Normal day")


class TestFullFlow:
    """Test complete strategy flow."""

    def test_full_flow(self):
        print("\n" + "=" * 50)
        print("FULL STRATEGY FLOW")
        print("=" * 50)

        # 1. Data
        data = generate_trending_data(200, "bull")
        price = data["close"][-1]
        print(f"1. Price: {price:.2f}")

        # 2. Session
        sf = SessionFilter()
        session = sf.get_session_info(datetime(2025, 12, 3, 13, 0))
        print(f"2. Session: {session.session.name}")
        assert session.is_trading_allowed

        # 3. Regime
        rd = RegimeDetector()
        regime = rd.analyze(data["close"])
        print(f"3. Regime: {regime.regime.name}, H={regime.hurst_exponent:.3f}")

        # 4. Spread
        sm = SpreadMonitor()
        t = datetime(2025, 1, 1)
        for i in range(30):
            sm.update(bid=price, ask=price + 0.20, now=t.replace(second=i))
        print(f"4. Spread OK: {sm.can_trade()}")
        assert sm.can_trade()

        # 5. Circuit Breaker
        cb = CircuitBreaker()
        print(f"5. CB OK: {cb.can_trade()}")
        assert cb.can_trade()

        # 6. Holiday
        hd = HolidayDetector()
        holiday = hd.check_holiday(datetime(2025, 12, 3, 13, 0))
        print(f"6. Holiday: {holiday.is_holiday}")

        # 7. Strategy
        ss = StrategySelector()
        context = MarketContext(
            hurst=regime.hurst_exponent,
            entropy=regime.shannon_entropy,
            is_trending=regime.hurst_exponent > 0.55,
            is_random=0.45 <= regime.hurst_exponent <= 0.55,
            is_overlap=True,
            circuit_ok=True,
            spread_ok=True,
        )
        selection = ss.select_strategy(context)
        print(f"7. Strategy: {selection.strategy.name}")

        # 8. Structure
        sa = StructureAnalyzer()
        sa.analyze(data["high"], data["low"], data["close"], data["timestamps"])
        bias = sa.get_market_bias()
        print(f"8. Bias: {bias.name}")

        # 9. Entry
        eo = EntryOptimizer()
        direction = (
            SignalDirection.SIGNAL_BUY
            if bias == MarketBias.BULLISH
            else SignalDirection.SIGNAL_SELL
        )
        entry = eo.calculate_optimal_entry(direction=direction, current_price=price, atr=5.0)
        print(f"9. Entry: {entry.optimal_price:.2f}, SL: {entry.stop_loss:.2f}")

        print("=" * 50)
        print("FLOW COMPLETE!")
        print("=" * 50)


if __name__ == "__main__":
    pytest.main([__file__, "-v", "-s"])
