"""
Run Complete Backtesting Pipeline
EA_SCALPER_XAUUSD - Singularity Edition

Usage:
    python run_backtest.py                    # Full pipeline
    python run_backtest.py --quick            # Quick test (subset of data)
    python run_backtest.py --walk-forward     # Walk-forward only
    python run_backtest.py --monte-carlo      # Monte Carlo only
"""

import sys
from pathlib import Path

# Add parent to path
sys.path.insert(0, str(Path(__file__).parent))

from vectorbt_backtest import XAUUSDBacktester

DATA_DIR = Path(__file__).parent.parent / "data"


def main():
    args = sys.argv[1:] if len(sys.argv) > 1 else []
    
    # Find data file
    data_path = DATA_DIR / "XAUUSD_M15_2020-2025.csv"
    
    if not data_path.exists():
        print(f"ERROR: Data file not found: {data_path}")
        print("\nAvailable files:")
        for f in DATA_DIR.glob("*.csv"):
            print(f"  - {f.name}")
        return
    
    # Initialize backtester
    backtester = XAUUSDBacktester(data_path)
    
    # Run based on arguments
    if '--quick' in args:
        print("\n=== QUICK TEST (last 6 months) ===")
        # Use only last 6 months
        backtester.data = backtester.data.last('180D')
        backtester.generate_signals_from_model()
        pf_long, pf_short = backtester.run_vectorbt_backtest()
        print("\nQuick Stats:")
        print(f"Long Return: {pf_long.total_return()*100:.2f}%")
        print(f"Long Trades: {pf_long.trades.count()}")
        
    elif '--walk-forward' in args:
        print("\n=== WALK-FORWARD ANALYSIS ===")
        backtester.generate_signals_from_model()
        backtester.run_walk_forward(n_splits=5)
        
    elif '--monte-carlo' in args:
        print("\n=== MONTE CARLO SIMULATION ===")
        backtester.generate_signals_from_model()
        backtester.run_monte_carlo(n_simulations=5000)
        
    else:
        # Full pipeline
        results = backtester.full_backtest_pipeline()
        
        # Save results
        print("\nSaving results...")
        output_dir = DATA_DIR / "backtest_results"
        output_dir.mkdir(exist_ok=True)
        
        # Save stats
        if results['portfolio_long']:
            stats = results['portfolio_long'].stats()
            stats.to_csv(output_dir / "backtest_stats.csv")
            print(f"Stats saved to {output_dir / 'backtest_stats.csv'}")


if __name__ == "__main__":
    main()
