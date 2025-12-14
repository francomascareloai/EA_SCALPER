#!/usr/bin/env python3
"""Quick test of ea_logic_full integration in realistic_backtester."""

import sys
from pathlib import Path

# Setup paths
sys.path.insert(0, str(Path(__file__).parent / "strategies"))
sys.path.insert(0, str(Path(__file__).parent))

from realistic_backtester import RealisticBacktester, RealisticBacktestConfig, USE_FULL_LOGIC

print(f"\n=== INTEGRATION TEST ===")
print(f"USE_FULL_LOGIC: {USE_FULL_LOGIC}")

# Configure
config = RealisticBacktestConfig()
config.min_confluence = 25  # VERY low for testing
config.debug = True  # Enable debug output
config.debug_interval = 500  # Print every 500 bars

# Create backtester
bt = RealisticBacktester(config)

# Run with MORE data (2M ticks for ~8 days = ~200 H1 bars)
tick_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/Python_Agent_Hub/ml_pipeline/data/XAUUSD_ftmo_all_desde_2003.csv"

print("\nRunning backtest with 5M ticks (~18 days)...")
results = bt.run(tick_path, max_ticks=5_000_000)

# Summary
metrics = results.get('metrics', {})
print(f"\n=== RESULTS ===")
print(f"Total Trades: {metrics.get('total_trades', 0)}")
print(f"Win Rate: {metrics.get('win_rate', 0):.1%}")
print(f"Profit Factor: {metrics.get('profit_factor', 0):.2f}")
print(f"Max DD: {metrics.get('max_dd', 0):.2%}")
print(f"Final Balance: ${metrics.get('final_balance', 0):,.0f}")
print(f"Bars Analyzed: {results.get('bars', 0)}")
print(f"Signals Generated: {bt.signals_generated}")
print(f"Signals Rejected: {bt.signals_rejected}")

# Latency stats
latency = results.get('latency_stats', {})
print(f"\n=== LATENCY ===")
print(f"Mean: {latency.get('mean_ms', 0):.1f}ms")
print(f"P95: {latency.get('p95_ms', 0):.1f}ms")
print(f"Packet Loss Events: {latency.get('packet_loss_events', 0)}")

# Gate stats (only if using full logic)
if hasattr(bt, 'ea_logic_full') and bt.ea_logic_full is not None:
    gates = bt.ea_logic_full.get_gate_stats()
    print(f"\n=== GATE BLOCKS ===")
    for gate, count in sorted(gates.items()):
        if count > 0:
            print(f"{gate}: {count}")
