"""
Sample Trade Data Generator
============================

Generates realistic synthetic trade data for testing Oracle validation scripts.

For: EA_SCALPER_XAUUSD - ORACLE Validation v2.2

Usage:
    python -m scripts.oracle.sample_data --output sample_trades.csv --trades 500
    
    # Or as module:
    from scripts.oracle.sample_data import generate_realistic_xauusd_trades
    df = generate_realistic_xauusd_trades(n_trades=500)
"""

import numpy as np
import pandas as pd
from datetime import datetime, timedelta
from typing import Optional, Tuple
import argparse


def generate_sample_trades(
    n_trades: int = 500,
    win_rate: float = 0.55,
    avg_win: float = 150.0,
    avg_loss: float = -100.0,
    start_date: str = "2022-01-03",
    initial_capital: float = 100000,
    seed: int = 42
) -> pd.DataFrame:
    """
    Generate basic synthetic trade data.
    
    Args:
        n_trades: Number of trades to generate
        win_rate: Win rate (0-1)
        avg_win: Average profit on winning trades
        avg_loss: Average loss on losing trades (negative)
        start_date: Starting date for trades
        initial_capital: Starting capital
        seed: Random seed for reproducibility
    
    Returns:
        DataFrame with trade data
    """
    np.random.seed(seed)
    
    # Generate wins/losses
    wins = np.random.random(n_trades) < win_rate
    
    profits = []
    for is_win in wins:
        if is_win:
            profit = np.random.normal(avg_win, avg_win * 0.3)
        else:
            profit = np.random.normal(avg_loss, abs(avg_loss) * 0.3)
        profits.append(profit)
    
    # Generate timestamps (skip weekends)
    start = datetime.strptime(start_date, "%Y-%m-%d")
    timestamps = []
    current = start
    
    for _ in range(n_trades):
        # Skip weekends
        while current.weekday() >= 5:
            current += timedelta(days=1)
        
        timestamps.append(current)
        
        # Random gap between trades (1-8 hours)
        hours_gap = np.random.exponential(4)
        current += timedelta(hours=hours_gap)
    
    # Generate directions
    directions = np.random.choice(['LONG', 'SHORT'], n_trades)
    
    # Generate entry prices (XAUUSD around 1900-2100)
    base_price = 2000
    prices = np.random.normal(base_price, 50, n_trades)
    
    df = pd.DataFrame({
        'datetime': timestamps,
        'direction': directions,
        'entry_price': prices,
        'profit': profits,
        'is_win': wins
    })
    
    return df


def generate_realistic_xauusd_trades(
    n_trades: int = 500,
    sharpe_target: float = 2.0,
    max_dd_target: float = 8.0,
    risk_per_trade: float = 0.005,
    initial_capital: float = 100000,
    start_date: str = "2022-01-03",
    include_regimes: bool = True,
    seed: int = 42
) -> pd.DataFrame:
    """
    Generate realistic XAUUSD scalping trade data.
    
    Features:
    - Autocorrelation in streaks (win/loss clustering)
    - Session-based volatility (Asian, London, NY)
    - Occasional high-volatility events
    - Regime changes (trending/ranging)
    
    Args:
        n_trades: Number of trades to generate
        sharpe_target: Target Sharpe ratio (affects win rate and RR)
        max_dd_target: Target max drawdown (%)
        risk_per_trade: Risk per trade as fraction of capital
        initial_capital: Starting capital
        start_date: Starting date
        include_regimes: Include regime changes
        seed: Random seed
    
    Returns:
        DataFrame with realistic trade data
    """
    np.random.seed(seed)
    
    # Calculate target metrics based on Sharpe
    # Sharpe = sqrt(252) * mean_return / std_return
    # For scalping: ~10 trades/day, so annualization factor ~2520
    base_win_rate = 0.50 + (sharpe_target * 0.02)  # Higher Sharpe = higher WR
    base_win_rate = min(0.65, max(0.45, base_win_rate))
    
    target_rr = 1.2 + (sharpe_target * 0.15)  # Higher Sharpe = better RR
    target_rr = min(2.0, max(1.0, target_rr))
    
    # Trade parameters
    risk_usd = initial_capital * risk_per_trade
    avg_loss = -risk_usd
    avg_win = risk_usd * target_rr
    
    profits = []
    timestamps = []
    directions = []
    entry_prices = []
    sessions = []
    regimes = []
    
    # State tracking
    current_streak = 0
    last_win = None
    current_regime = 'normal'  # normal, trending, choppy
    regime_trades = 0
    
    # Price tracking
    current_price = 2000.0
    
    # Time tracking
    current_time = datetime.strptime(start_date, "%Y-%m-%d") + timedelta(hours=8)
    
    for i in range(n_trades):
        # Skip weekends
        while current_time.weekday() >= 5:
            current_time += timedelta(days=1)
            current_time = current_time.replace(hour=8, minute=0)
        
        # Determine session
        hour = current_time.hour
        if 0 <= hour < 8:
            session = 'asian'
            session_mult = 0.7  # Lower volatility
        elif 8 <= hour < 16:
            session = 'london'
            session_mult = 1.2  # Higher volatility
        else:
            session = 'newyork'
            session_mult = 1.0
        
        # Regime changes (every ~100 trades on average)
        if include_regimes:
            regime_trades += 1
            if regime_trades > np.random.exponential(100):
                current_regime = np.random.choice(['normal', 'trending', 'choppy'], p=[0.5, 0.3, 0.2])
                regime_trades = 0
        
        # Adjust win rate based on regime
        regime_wr_adj = {
            'normal': 0,
            'trending': 0.05,   # Better in trends
            'choppy': -0.08    # Worse in chop
        }
        adjusted_wr = base_win_rate + regime_wr_adj.get(current_regime, 0)
        
        # Autocorrelation: streaks tend to continue
        if last_win is not None:
            if current_streak > 0:
                # Tendency to continue streak (mean reversion after long streaks)
                streak_factor = min(current_streak / 10, 0.15)
                if current_streak > 5:
                    # Mean reversion kicks in
                    streak_factor = -0.1
                
                if last_win:
                    adjusted_wr += streak_factor
                else:
                    adjusted_wr -= streak_factor
        
        adjusted_wr = max(0.35, min(0.70, adjusted_wr))
        
        # Determine win/loss
        is_win = np.random.random() < adjusted_wr
        
        # Update streak
        if last_win is None or is_win == last_win:
            current_streak += 1
        else:
            current_streak = 1
        last_win = is_win
        
        # Calculate profit with variation
        if is_win:
            # Wins have positive skew
            base_profit = avg_win * session_mult
            profit = np.random.gamma(2, base_profit / 2)
            profit = min(profit, avg_win * 3)  # Cap at 3x average
        else:
            # Losses are more consistent (disciplined SL)
            base_loss = avg_loss * session_mult
            profit = np.random.normal(base_loss, abs(base_loss) * 0.15)
            profit = max(profit, avg_loss * 1.5)  # Max loss is 1.5x average
        
        # Occasional big moves (5% of trades)
        if np.random.random() < 0.05:
            multiplier = np.random.uniform(1.5, 2.5)
            profit *= multiplier
        
        # Direction based on regime
        if current_regime == 'trending':
            # Trend followers do well
            direction = np.random.choice(['LONG', 'SHORT'], p=[0.6, 0.4])
        else:
            direction = np.random.choice(['LONG', 'SHORT'])
        
        # Update price (random walk with session volatility)
        price_change = np.random.normal(0, 5 * session_mult)
        current_price += price_change
        current_price = max(1800, min(2200, current_price))  # Keep in range
        
        # Store trade
        profits.append(profit)
        timestamps.append(current_time)
        directions.append(direction)
        entry_prices.append(current_price)
        sessions.append(session)
        regimes.append(current_regime)
        
        # Advance time (1-4 hours between trades for scalping)
        hours_gap = np.random.exponential(2) + 0.5
        current_time += timedelta(hours=hours_gap)
    
    df = pd.DataFrame({
        'datetime': timestamps,
        'direction': directions,
        'entry_price': entry_prices,
        'profit': profits,
        'is_win': [p > 0 for p in profits],
        'session': sessions,
        'regime': regimes
    })
    
    return df


def generate_edge_case_trades(
    scenario: str = 'high_drawdown',
    n_trades: int = 200,
    seed: int = 42
) -> pd.DataFrame:
    """
    Generate edge case scenarios for testing.
    
    Scenarios:
    - 'high_drawdown': Many consecutive losses
    - 'high_sharpe': Suspiciously good performance
    - 'low_trades': Insufficient sample size
    - 'choppy': Many small wins/losses (low RR)
    - 'boom_bust': Alternating good and bad periods
    
    Args:
        scenario: Which edge case to generate
        n_trades: Number of trades
        seed: Random seed
    
    Returns:
        DataFrame with edge case trades
    """
    np.random.seed(seed)
    
    if scenario == 'high_drawdown':
        # Start with losses, then recover
        first_half = generate_sample_trades(
            n_trades=n_trades // 2,
            win_rate=0.30,
            avg_win=100,
            avg_loss=-150,
            seed=seed
        )
        second_half = generate_sample_trades(
            n_trades=n_trades // 2,
            win_rate=0.60,
            avg_win=120,
            avg_loss=-80,
            start_date="2023-01-03",
            seed=seed + 1
        )
        return pd.concat([first_half, second_half], ignore_index=True)
    
    elif scenario == 'high_sharpe':
        # Suspiciously good (likely overfit)
        return generate_sample_trades(
            n_trades=n_trades,
            win_rate=0.75,
            avg_win=200,
            avg_loss=-50,
            seed=seed
        )
    
    elif scenario == 'low_trades':
        # Insufficient sample
        return generate_sample_trades(
            n_trades=50,
            win_rate=0.55,
            avg_win=150,
            avg_loss=-100,
            seed=seed
        )
    
    elif scenario == 'choppy':
        # Many small trades, low RR
        return generate_sample_trades(
            n_trades=n_trades,
            win_rate=0.52,
            avg_win=60,
            avg_loss=-55,
            seed=seed
        )
    
    elif scenario == 'boom_bust':
        # Alternating periods
        dfs = []
        for i in range(4):
            is_good = i % 2 == 0
            df = generate_sample_trades(
                n_trades=n_trades // 4,
                win_rate=0.65 if is_good else 0.40,
                avg_win=150 if is_good else 80,
                avg_loss=-80 if is_good else -150,
                start_date=f"202{2 + i // 2}-0{1 + (i % 2) * 6}-03",
                seed=seed + i
            )
            dfs.append(df)
        return pd.concat(dfs, ignore_index=True)
    
    else:
        return generate_sample_trades(n_trades=n_trades, seed=seed)


def calculate_metrics_summary(df: pd.DataFrame) -> dict:
    """Calculate quick summary metrics for generated data."""
    profits = df['profit'].values
    n = len(profits)
    
    win_rate = (profits > 0).mean()
    avg_win = profits[profits > 0].mean() if any(profits > 0) else 0
    avg_loss = abs(profits[profits < 0].mean()) if any(profits < 0) else 0
    
    # Equity curve
    equity = 100000 + np.cumsum(profits)
    peak = np.maximum.accumulate(equity)
    dd = (peak - equity) / peak
    max_dd = dd.max() * 100
    
    # Simple Sharpe (daily)
    returns = profits / 100000
    sharpe = np.sqrt(252) * returns.mean() / returns.std() if returns.std() > 0 else 0
    
    # Profit factor
    gross_win = profits[profits > 0].sum()
    gross_loss = abs(profits[profits < 0].sum())
    pf = gross_win / gross_loss if gross_loss > 0 else 0
    
    return {
        'n_trades': n,
        'win_rate': win_rate * 100,
        'avg_win': avg_win,
        'avg_loss': avg_loss,
        'rr_ratio': avg_win / avg_loss if avg_loss > 0 else 0,
        'total_pnl': profits.sum(),
        'max_dd': max_dd,
        'sharpe': sharpe,
        'profit_factor': pf
    }


def main():
    """CLI interface"""
    parser = argparse.ArgumentParser(description='Generate Sample Trade Data')
    parser.add_argument('--output', '-o', default='sample_trades.csv', help='Output CSV file')
    parser.add_argument('--trades', '-n', type=int, default=500, help='Number of trades')
    parser.add_argument('--type', '-t', choices=['basic', 'realistic', 'edge'], default='realistic')
    parser.add_argument('--scenario', '-s', default='normal', 
                        help='For edge type: high_drawdown, high_sharpe, low_trades, choppy, boom_bust')
    parser.add_argument('--sharpe', type=float, default=2.0, help='Target Sharpe for realistic')
    parser.add_argument('--seed', type=int, default=42, help='Random seed')
    
    args = parser.parse_args()
    
    # Generate data
    print(f"Generating {args.trades} {args.type} trades...")
    
    if args.type == 'basic':
        df = generate_sample_trades(n_trades=args.trades, seed=args.seed)
    elif args.type == 'realistic':
        df = generate_realistic_xauusd_trades(
            n_trades=args.trades,
            sharpe_target=args.sharpe,
            seed=args.seed
        )
    else:
        df = generate_edge_case_trades(scenario=args.scenario, n_trades=args.trades, seed=args.seed)
    
    # Save
    df.to_csv(args.output, index=False)
    print(f"Saved to {args.output}")
    
    # Print summary
    summary = calculate_metrics_summary(df)
    print("\nSUMMARY:")
    print(f"  Trades:        {summary['n_trades']}")
    print(f"  Win Rate:      {summary['win_rate']:.1f}%")
    print(f"  Avg Win:       ${summary['avg_win']:.2f}")
    print(f"  Avg Loss:      ${summary['avg_loss']:.2f}")
    print(f"  R:R Ratio:     {summary['rr_ratio']:.2f}")
    print(f"  Total P&L:     ${summary['total_pnl']:,.2f}")
    print(f"  Max Drawdown:  {summary['max_dd']:.1f}%")
    print(f"  Sharpe Ratio:  {summary['sharpe']:.2f}")
    print(f"  Profit Factor: {summary['profit_factor']:.2f}")


if __name__ == '__main__':
    main()
