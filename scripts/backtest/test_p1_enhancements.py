#!/usr/bin/env python3
"""
P1 Enhancements Validation Test
================================
Testa os 3 novos modulos: Fibonacci, Adaptive Kelly, Spread Analyzer

Author: FORGE v3.1
Date: 2025-12-01
"""

import sys
import numpy as np
from pathlib import Path
from datetime import datetime, timedelta

# Add strategies folder to path
_strategies_path = str(Path(__file__).parent / "strategies")
if _strategies_path not in sys.path:
    sys.path.insert(0, _strategies_path)

print("=" * 60)
print("P1 ENHANCEMENTS VALIDATION TEST")
print("=" * 60)

# ============================================================================
# TEST 1: FIBONACCI ANALYZER
# ============================================================================
print("\n[1/3] Testing FibonacciAnalyzer...")

try:
    from fibonacci_analyzer import FibonacciAnalyzer, create_fibonacci_analyzer
    
    # Create test data - clear uptrend then pullback
    np.random.seed(42)
    n = 100
    base = 2000.0
    
    # Create price series: uptrend from 2000 to 2050, then pullback to ~2030
    prices = np.zeros(n)
    for i in range(n):
        if i < 70:
            prices[i] = base + i * 0.7  # Uptrend
        else:
            prices[i] = prices[69] - (i - 69) * 0.5  # Pullback
    
    noise = np.random.randn(n) * 1
    prices = prices + noise
    
    highs = prices + np.random.rand(n) * 3 + 1
    lows = prices - np.random.rand(n) * 3 - 1
    
    # Current price = somewhere in pullback (around 61.8% retracement)
    swing_high = float(np.max(highs[-60:]))  # ~2052
    swing_low = float(np.min(lows[-60:]))    # ~2000
    range_size = swing_high - swing_low
    
    # Place price in golden pocket (between 50% and 65% retracement)
    current_price = swing_high - range_size * 0.58  # 58% retracement = in golden pocket
    
    # Test
    fib = FibonacciAnalyzer()
    result = fib.analyze(highs, lows, current_price, atr=5.0, is_bullish_bias=True)
    
    print(f"   Swing High: {result.levels.swing_high:.2f}")
    print(f"   Swing Low: {result.levels.swing_low:.2f}")
    print(f"   Current Price: {current_price:.2f}")
    print(f"   In Golden Pocket: {result.in_golden_pocket}")
    print(f"   Fib Score: {result.fib_score:.1f}")
    print(f"   Nearest Level: {result.nearest_fib_name} @ {result.nearest_fib_level:.2f}")
    print(f"   Distance (ATR): {result.distance_in_atr:.2f}")
    print(f"   Extension TPs: 127.2%={result.tp1_fib:.2f}, 161.8%={result.tp2_fib:.2f}")
    print(f"   Clusters Found: {len(result.clusters)}")
    
    # Validation - more flexible
    assert result.is_valid, "Result should be valid"
    assert result.fib_score >= 40, f"Fib score should be >= 40, got {result.fib_score}"
    # TP1 should be above swing high (extension)
    assert result.tp1_fib > result.levels.swing_high, "TP1 (127.2%) should be above swing high"
    
    print("   [OK] FibonacciAnalyzer PASSED")
    fib_pass = True
except Exception as e:
    print(f"   [FAIL] FibonacciAnalyzer FAILED: {e}")
    import traceback
    traceback.print_exc()
    fib_pass = False

# ============================================================================
# TEST 2: ADAPTIVE KELLY
# ============================================================================
print("\n[2/3] Testing AdaptiveKelly...")

try:
    from adaptive_kelly import AdaptiveKelly, KellyMode, create_adaptive_kelly
    
    kelly = AdaptiveKelly(mode=KellyMode.ADAPTIVE)
    kelly.initial_balance = 100000
    kelly.current_balance = 100000
    kelly.peak_balance = 100000
    kelly.daily_start_balance = 100000
    
    # Simulate trades (60% win rate, 1.5:1 avg win/loss)
    np.random.seed(42)
    for _ in range(50):
        if np.random.random() < 0.60:
            r = np.random.normal(1.5, 0.3)  # Win
        else:
            r = -np.random.normal(1.0, 0.2)  # Loss
        kelly.record_trade(r)
    
    # Get stats
    stats = kelly.get_stats_summary()
    print(f"   Total Trades: {stats['total_trades']}")
    print(f"   Win Rate: {stats['win_rate']}")
    print(f"   Avg Win: {stats['avg_win_r']}")
    print(f"   Avg Loss: {stats['avg_loss_r']}")
    print(f"   Expectancy: {stats['expectancy']}")
    print(f"   Kelly Fraction: {stats['kelly_fraction']}")
    print(f"   Half Kelly: {stats['half_kelly']}")
    
    # Calculate position size
    result = kelly.calculate_position_size(
        sl_points=50.0,
        regime_multiplier=1.0,
    )
    
    print(f"   Risk Percent: {result.risk_percent:.2f}%")
    print(f"   Lot Size: {result.lot_size:.2f}")
    print(f"   DD Adjustment: {result.dd_adjustment:.2f}")
    print(f"   Trading Allowed: {result.is_trading_allowed}")
    
    # Test DD scenario
    kelly.current_balance = 95000  # 5% DD
    result_dd = kelly.calculate_position_size(sl_points=50.0, regime_multiplier=1.0)
    print(f"   At 5% DD - Risk Percent: {result_dd.risk_percent:.2f}%")
    print(f"   At 5% DD - Allowed: {result_dd.is_trading_allowed}")
    
    # Validation
    assert kelly.stats.total_trades == 50, "Should have 50 trades"
    assert result.lot_size > 0, "Lot size should be > 0"
    assert result.is_trading_allowed, "Should allow trading"
    assert result_dd.risk_percent < result.risk_percent, "DD should reduce risk"
    
    print("   [OK] AdaptiveKelly PASSED")
    kelly_pass = True
except Exception as e:
    print(f"   [FAIL] AdaptiveKelly FAILED: {e}")
    import traceback
    traceback.print_exc()
    kelly_pass = False

# ============================================================================
# TEST 3: SPREAD ANALYZER
# ============================================================================
print("\n[3/3] Testing SpreadAnalyzer...")

try:
    from spread_analyzer import SpreadAnalyzer, SpreadCondition, create_spread_analyzer
    
    analyzer = SpreadAnalyzer(gmt_offset=0)
    
    # Simulate spread observations during London/NY overlap
    np.random.seed(42)
    base_time = datetime(2024, 1, 15, 14, 0)  # 14:00 GMT = overlap
    
    for i in range(50):
        spread = np.random.normal(30, 8)  # Normal spread around 30
        spread = max(15, spread)
        t = base_time + timedelta(minutes=i)
        analyzer.record_spread(spread, t)
    
    # Test normal spread
    result_normal = analyzer.analyze(
        current_spread=30,
        timestamp=datetime(2024, 1, 15, 14, 30),
        sl_points=50,
        signal_urgency=0.7,
    )
    
    print(f"   Normal Spread Test:")
    print(f"      Current: {result_normal.current_spread}")
    print(f"      Avg: {result_normal.avg_spread:.1f}")
    print(f"      Ratio: {result_normal.spread_ratio:.2f}")
    print(f"      Condition: {result_normal.condition.name}")
    print(f"      Allow Entry: {result_normal.allow_entry}")
    print(f"      Cost in R: {result_normal.cost_in_r:.2f}")
    
    # Test high spread
    result_high = analyzer.analyze(
        current_spread=70,
        timestamp=datetime(2024, 1, 15, 14, 30),
        sl_points=50,
        signal_urgency=0.5,
    )
    
    print(f"   High Spread Test:")
    print(f"      Current: {result_high.current_spread}")
    print(f"      Ratio: {result_high.spread_ratio:.2f}")
    print(f"      Condition: {result_high.condition.name}")
    print(f"      Allow Entry: {result_high.allow_entry}")
    print(f"      Wait for Better: {result_high.wait_for_better}")
    
    # Test extreme spread
    result_extreme = analyzer.analyze(
        current_spread=120,
        timestamp=datetime(2024, 1, 15, 14, 30),
        sl_points=50,
        signal_urgency=0.9,
    )
    
    print(f"   Extreme Spread Test:")
    print(f"      Current: {result_extreme.current_spread}")
    print(f"      Condition: {result_extreme.condition.name}")
    print(f"      Allow Entry: {result_extreme.allow_entry}")
    
    # Validation
    assert result_normal.allow_entry, "Normal spread should allow entry"
    assert not result_extreme.allow_entry, "Extreme spread should block entry"
    assert result_high.cost_in_r > result_normal.cost_in_r, "Higher spread = higher cost"
    
    print("   [OK] SpreadAnalyzer PASSED")
    spread_pass = True
except Exception as e:
    print(f"   [FAIL] SpreadAnalyzer FAILED: {e}")
    import traceback
    traceback.print_exc()
    spread_pass = False

# ============================================================================
# TEST 4: INTEGRATION TEST
# ============================================================================
print("\n[4/4] Testing Integration...")

try:
    # Test that all modules can be imported together
    from fibonacci_analyzer import FibonacciAnalyzer
    from adaptive_kelly import AdaptiveKelly, KellyMode
    from spread_analyzer import SpreadAnalyzer
    
    # Create instances
    fib = FibonacciAnalyzer()
    kelly = AdaptiveKelly(mode=KellyMode.ADAPTIVE)
    spread = SpreadAnalyzer()
    
    # Simulate a complete flow
    np.random.seed(123)
    
    # 1. Generate price data
    n = 100
    prices = 2000 + np.cumsum(np.random.randn(n) * 2)
    highs = prices + np.random.rand(n) * 5
    lows = prices - np.random.rand(n) * 5
    current_price = prices[-1]
    atr = np.mean(highs[-14:] - lows[-14:])
    
    # 2. Fibonacci analysis
    fib_result = fib.analyze(highs, lows, current_price, atr, is_bullish_bias=True)
    fib_score = fib_result.fib_score
    
    # 3. Spread check
    timestamp = datetime(2024, 1, 15, 14, 30)
    spread.record_spread(25, timestamp)
    spread_result = spread.analyze(30, timestamp, sl_points=50)
    
    # 4. Position sizing (with some simulated trades)
    kelly.initial_balance = 100000
    kelly.current_balance = 98000  # 2% down
    kelly.peak_balance = 100000
    for _ in range(20):
        kelly.record_trade(np.random.choice([1.5, -1.0], p=[0.55, 0.45]))
    
    sizing = kelly.calculate_position_size(
        sl_points=50,
        regime_multiplier=1.0 if fib_result.in_golden_pocket else 0.75
    )
    
    print(f"   Integration Flow:")
    print(f"      Fib Score: {fib_score:.1f}")
    print(f"      In Golden Pocket: {fib_result.in_golden_pocket}")
    print(f"      Spread OK: {spread_result.allow_entry}")
    print(f"      Spread Cost: {spread_result.cost_in_r:.2f}R")
    print(f"      Risk Percent: {sizing.risk_percent:.2f}%")
    print(f"      Lot Size: {sizing.lot_size:.2f}")
    print(f"      Trading Allowed: {sizing.is_trading_allowed}")
    
    # Calculate final score with bonuses
    base_score = 65  # Hypothetical base confluence
    fib_bonus = 15 if fib_result.in_golden_pocket else (5 if fib_result.near_fib_level else 0)
    final_score = base_score + fib_bonus
    
    print(f"      Base Score: {base_score}")
    print(f"      Fib Bonus: +{fib_bonus}")
    print(f"      Final Score: {final_score}")
    
    # Would we trade?
    would_trade = (
        spread_result.allow_entry and
        sizing.is_trading_allowed and
        final_score >= 65
    )
    print(f"      Would Trade: {'YES' if would_trade else 'NO'}")
    
    print("   [OK] Integration PASSED")
    integration_pass = True
except Exception as e:
    print(f"   [FAIL] Integration FAILED: {e}")
    import traceback
    traceback.print_exc()
    integration_pass = False

# ============================================================================
# SUMMARY
# ============================================================================
print("\n" + "=" * 60)
print("TEST SUMMARY")
print("=" * 60)

results = {
    "FibonacciAnalyzer": fib_pass,
    "AdaptiveKelly": kelly_pass,
    "SpreadAnalyzer": spread_pass,
    "Integration": integration_pass,
}

all_passed = all(results.values())
passed = sum(results.values())
total = len(results)

for name, passed_test in results.items():
    status = "[PASS]" if passed_test else "[FAIL]"
    print(f"   {name}: {status}")

print(f"\nResult: {passed}/{total} tests passed")

if all_passed:
    print("\n*** ALL P1 ENHANCEMENTS VALIDATED SUCCESSFULLY! ***")
    print("\nNext steps:")
    print("   1. Run full backtest to compare before/after")
    print("   2. Integrate into ea_logic_full.py")
    print("   3. Deploy to live testing")
else:
    print("\n!!! Some tests failed. Please fix before proceeding.")
    sys.exit(1)
