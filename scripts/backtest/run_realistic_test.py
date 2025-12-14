#!/usr/bin/env python3
"""
Quick test script for Realistic Backtester v2.0

Usage:
    python scripts/backtest/run_realistic_test.py --ticks 1000000
    
Or with specific dates:
    python scripts/backtest/run_realistic_test.py --start 2025-01-01 --end 2025-06-01
"""

import argparse
import sys
from pathlib import Path

# Add project root
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

def main():
    parser = argparse.ArgumentParser(description='Run Realistic Backtester v2.0')
    parser.add_argument('--ticks', type=int, default=2_000_000, help='Max ticks to load')
    parser.add_argument('--start', type=str, default=None, help='Start date YYYY-MM-DD')
    parser.add_argument('--end', type=str, default=None, help='End date YYYY-MM-DD')
    parser.add_argument('--mode', choices=['optimistic', 'normal', 'pessimistic', 'stress'],
                        default='pessimistic', help='Execution mode')
    parser.add_argument('--no-latency', action='store_true', help='Disable latency simulation')
    parser.add_argument('--confluence', type=float, default=65.0, help='Min confluence score')
    parser.add_argument('--debug', action='store_true', help='Enable debug output')
    
    args = parser.parse_args()
    
    # Import after args (to show help faster)
    from scripts.backtest.realistic_backtester import (
        RealisticBacktester, RealisticBacktestConfig, ExecutionMode
    )
    
    # Map mode string to enum
    mode_map = {
        'optimistic': ExecutionMode.OPTIMISTIC,
        'normal': ExecutionMode.NORMAL,
        'pessimistic': ExecutionMode.PESSIMISTIC,
        'stress': ExecutionMode.STRESS
    }
    
    config = RealisticBacktestConfig(
        execution_mode=mode_map[args.mode],
        enable_latency_sim=not args.no_latency,
        enable_onnx_mock=True,
        min_confluence=args.confluence,
        debug=args.debug,
        debug_interval=500
    )
    
    # Default tick data path
    tick_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/Python_Agent_Hub/ml_pipeline/data/XAUUSD_ftmo_all_desde_2003.csv"
    
    print(f"\nConfiguration:")
    print(f"  Mode: {args.mode}")
    print(f"  Latency Sim: {not args.no_latency}")
    print(f"  Min Confluence: {args.confluence}")
    print(f"  Max Ticks: {args.ticks:,}")
    
    bt = RealisticBacktester(config)
    results = bt.run(tick_path, max_ticks=args.ticks, start_date=args.start, end_date=args.end)
    
    # Export trades
    export_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/data/realistic_trades.csv"
    bt.export_trades(export_path)
    
    # Summary for Oracle
    print("\n" + "=" * 70)
    print("READY FOR ORACLE VALIDATION")
    print("=" * 70)
    print(f"Trades exported to: {export_path}")
    print(f"Run: python -m scripts.oracle.go_nogo_validator --input {export_path}")
    
    return results


if __name__ == "__main__":
    main()
