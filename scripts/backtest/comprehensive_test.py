#!/usr/bin/env python3
"""
Comprehensive Strategy Backtest
===============================
Tests multiple strategies on XAUUSD M5 data (2020-2025).
Generates detailed comparison report.

Author: ORACLE + FORGE
Date: 2025-12-01
"""

import numpy as np
import pandas as pd
from pathlib import Path
from dataclasses import dataclass
from typing import List, Dict, Optional
from datetime import datetime
import warnings
warnings.filterwarnings('ignore')

from strategies import (
    BaseStrategy, Signal, get_all_strategies,
    MACrossStrategy, MeanReversionStrategy, BreakoutStrategy,
    TrendFollowingStrategy, EALogicStrategy, MomentumScalperStrategy,
    EALogicConfig, MomentumScalperConfig
)


# =============================================================================
# CONFIGURATION
# =============================================================================

@dataclass
class BacktestConfig:
    """Backtest configuration"""
    initial_balance: float = 100_000.0
    risk_per_trade: float = 0.005
    max_daily_dd: float = 0.05
    max_total_dd: float = 0.10
    spread_points: float = 0.30  # $0.30 average spread
    slippage_mult: float = 1.5   # Pessimistic slippage


@dataclass
class TradeResult:
    """Single trade result"""
    entry_time: datetime
    exit_time: datetime
    direction: str
    entry_price: float
    exit_price: float
    sl: float
    tp: float
    lots: float
    pnl: float
    exit_reason: str


# =============================================================================
# DATA LOADING
# =============================================================================

def load_m5_data(filepath: str) -> pd.DataFrame:
    """Load M5 OHLC data"""
    print(f"[Data] Loading {filepath}...")
    df = pd.read_csv(filepath)
    
    # Parse datetime
    df['datetime'] = pd.to_datetime(df['Date'].astype(str) + ' ' + df['Time'])
    df.set_index('datetime', inplace=True)
    df = df[['Open', 'High', 'Low', 'Close', 'Volume']].copy()
    df.columns = ['open', 'high', 'low', 'close', 'volume']
    
    print(f"[Data] Loaded {len(df):,} bars")
    print(f"[Data] Period: {df.index[0]} to {df.index[-1]}")
    
    return df


# =============================================================================
# BACKTESTER
# =============================================================================

class StrategyBacktester:
    """Backtester for any strategy"""
    
    def __init__(self, config: BacktestConfig = None):
        self.config = config or BacktestConfig()
    
    def run(self, df: pd.DataFrame, strategy: BaseStrategy) -> Dict:
        """Run backtest for a single strategy"""
        
        # Calculate indicators
        df = strategy.calculate_indicators(df)
        
        # Initialize state
        balance = self.config.initial_balance
        peak_balance = balance
        position = None
        trades = []
        daily_pnl = {}
        equity_curve = []
        
        # Count signals
        buy_signals = 0
        sell_signals = 0
        
        for idx, row in df.iterrows():
            date_key = idx.date()
            
            # Daily P&L tracking
            if date_key not in daily_pnl:
                daily_pnl[date_key] = 0
            
            # Check FTMO limits
            current_daily_dd = -daily_pnl.get(date_key, 0) / self.config.initial_balance
            current_total_dd = (peak_balance - balance) / peak_balance if peak_balance > 0 else 0
            
            if current_daily_dd >= self.config.max_daily_dd or current_total_dd >= self.config.max_total_dd:
                if position:
                    pnl = self._close_position(position, row, 'DD_LIMIT')
                    trades.append(pnl)
                    balance += pnl.pnl
                    position = None
                continue
            
            # Manage position
            if position:
                exit_result = self._check_exit(position, row)
                if exit_result:
                    trades.append(exit_result)
                    balance += exit_result.pnl
                    daily_pnl[date_key] += exit_result.pnl
                    if balance > peak_balance:
                        peak_balance = balance
                    position = None
            
            # Generate signal
            signal = strategy.generate_signal(row)
            
            if signal == Signal.BUY:
                buy_signals += 1
            elif signal == Signal.SELL:
                sell_signals += 1
            
            # Open new position
            if position is None and signal != Signal.NONE:
                position = self._open_position(idx, row, signal, strategy, balance)
            
            # Record equity
            equity_curve.append({'datetime': idx, 'balance': balance})
        
        # Close remaining position
        if position:
            pnl = self._close_position(position, df.iloc[-1], 'END')
            trades.append(pnl)
            balance += pnl.pnl
        
        # Calculate metrics
        metrics = self._calculate_metrics(trades, self.config.initial_balance, balance, peak_balance)
        metrics['buy_signals'] = buy_signals
        metrics['sell_signals'] = sell_signals
        
        return {
            'strategy': strategy.name,
            'trades': trades,
            'metrics': metrics,
            'equity_curve': equity_curve
        }
    
    def _open_position(self, timestamp, row, signal: Signal, 
                       strategy: BaseStrategy, balance: float) -> Dict:
        """Open a new position"""
        spread = self.config.spread_points * self.config.slippage_mult
        atr = row['atr']
        
        if signal == Signal.BUY:
            entry = row['close'] + spread / 2
            sl, tp = strategy.calculate_sl_tp(entry, atr, signal)
        else:
            entry = row['close'] - spread / 2
            sl, tp = strategy.calculate_sl_tp(entry, atr, signal)
        
        # Position sizing
        risk_amount = balance * self.config.risk_per_trade
        sl_distance = abs(entry - sl)
        lots = risk_amount / (sl_distance * 100) if sl_distance > 0 else 0.01
        lots = max(0.01, min(lots, 10.0))
        
        return {
            'direction': 'BUY' if signal == Signal.BUY else 'SELL',
            'entry_time': timestamp,
            'entry': entry,
            'sl': sl,
            'tp': tp,
            'lots': lots
        }
    
    def _check_exit(self, position: Dict, row: pd.Series) -> Optional[TradeResult]:
        """Check if position should be closed"""
        if position['direction'] == 'BUY':
            if row['low'] <= position['sl']:
                return self._create_trade(position, row.name, position['sl'], 'SL')
            if row['high'] >= position['tp']:
                return self._create_trade(position, row.name, position['tp'], 'TP')
        else:
            if row['high'] >= position['sl']:
                return self._create_trade(position, row.name, position['sl'], 'SL')
            if row['low'] <= position['tp']:
                return self._create_trade(position, row.name, position['tp'], 'TP')
        return None
    
    def _close_position(self, position: Dict, row: pd.Series, reason: str) -> TradeResult:
        """Force close position"""
        spread = self.config.spread_points * self.config.slippage_mult
        if position['direction'] == 'BUY':
            exit_price = row['close'] - spread / 2
        else:
            exit_price = row['close'] + spread / 2
        return self._create_trade(position, row.name, exit_price, reason)
    
    def _create_trade(self, position: Dict, exit_time, exit_price: float, 
                      reason: str) -> TradeResult:
        """Create trade result"""
        if position['direction'] == 'BUY':
            pnl = (exit_price - position['entry']) * position['lots'] * 100
        else:
            pnl = (position['entry'] - exit_price) * position['lots'] * 100
        
        return TradeResult(
            entry_time=position['entry_time'],
            exit_time=exit_time,
            direction=position['direction'],
            entry_price=position['entry'],
            exit_price=exit_price,
            sl=position['sl'],
            tp=position['tp'],
            lots=position['lots'],
            pnl=pnl,
            exit_reason=reason
        )
    
    def _calculate_metrics(self, trades: List[TradeResult], initial: float, 
                          final: float, peak: float) -> Dict:
        """Calculate performance metrics"""
        if not trades:
            return {'error': 'No trades', 'total_trades': 0}
        
        pnls = [t.pnl for t in trades]
        wins = [p for p in pnls if p > 0]
        losses = [p for p in pnls if p < 0]
        
        total_trades = len(trades)
        win_rate = len(wins) / total_trades if total_trades > 0 else 0
        
        gross_profit = sum(wins) if wins else 0
        gross_loss = abs(sum(losses)) if losses else 1  # Avoid div by zero
        profit_factor = gross_profit / gross_loss if gross_loss > 0 else float('inf')
        
        # Drawdown
        equity = [initial]
        for pnl in pnls:
            equity.append(equity[-1] + pnl)
        equity = np.array(equity)
        peak_eq = np.maximum.accumulate(equity)
        drawdowns = (peak_eq - equity) / peak_eq
        max_dd = drawdowns.max()
        
        # Returns
        total_return = (final - initial) / initial
        
        # Sharpe (annualized, M5 = 288 bars/day)
        if len(pnls) > 1 and np.std(pnls) > 0:
            returns = np.array(pnls) / initial
            sharpe = np.mean(returns) / np.std(returns) * np.sqrt(252 * 288)
        else:
            sharpe = 0
        
        # SQN
        sqn = np.sqrt(total_trades) * np.mean(pnls) / np.std(pnls) if len(pnls) > 1 and np.std(pnls) > 0 else 0
        
        # Expectancy
        avg_win = np.mean(wins) if wins else 0
        avg_loss = abs(np.mean(losses)) if losses else 0
        expectancy = (win_rate * avg_win) - ((1 - win_rate) * avg_loss)
        
        # Exit reasons
        exit_reasons = {}
        for t in trades:
            exit_reasons[t.exit_reason] = exit_reasons.get(t.exit_reason, 0) + 1
        
        return {
            'total_trades': total_trades,
            'win_rate': win_rate,
            'profit_factor': profit_factor,
            'total_return': total_return,
            'max_drawdown': max_dd,
            'sharpe_ratio': sharpe,
            'sqn': sqn,
            'expectancy': expectancy,
            'gross_profit': gross_profit,
            'gross_loss': gross_loss,
            'avg_win': avg_win,
            'avg_loss': -abs(np.mean(losses)) if losses else 0,
            'final_balance': final,
            'net_profit': final - initial,
            'exit_reasons': exit_reasons,
            'max_consecutive_losses': self._max_consecutive(pnls, lambda x: x < 0),
            'max_consecutive_wins': self._max_consecutive(pnls, lambda x: x > 0),
        }
    
    def _max_consecutive(self, pnls: List[float], condition) -> int:
        """Calculate max consecutive trades matching condition"""
        max_streak = 0
        current = 0
        for pnl in pnls:
            if condition(pnl):
                current += 1
                max_streak = max(max_streak, current)
            else:
                current = 0
        return max_streak


# =============================================================================
# REPORT GENERATION
# =============================================================================

def generate_report(results: List[Dict], output_path: str = None):
    """Generate detailed comparison report"""
    
    report = []
    report.append("=" * 100)
    report.append("                    COMPREHENSIVE STRATEGY BACKTEST REPORT")
    report.append("                         XAUUSD M5 (2020-2025)")
    report.append("=" * 100)
    report.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    report.append(f"Data Period: 2020-01-02 to 2025-11-28 (~5 years)")
    report.append(f"Execution Mode: PESSIMISTIC (spread x1.5, conservative fills)")
    report.append("")
    
    # Summary table
    report.append("-" * 100)
    report.append("                              SUMMARY COMPARISON")
    report.append("-" * 100)
    report.append(f"{'Strategy':<30} {'Trades':>8} {'WR':>8} {'PF':>8} {'MaxDD':>8} {'Return':>10} {'Sharpe':>8} {'Status':<8}")
    report.append("-" * 100)
    
    for r in results:
        m = r['metrics']
        if 'error' in m:
            report.append(f"{r['strategy']:<30} {'ERROR':>8} {'-':>8} {'-':>8} {'-':>8} {'-':>10} {'-':>8} {'FAIL':<8}")
            continue
        
        # Determine status
        if m['profit_factor'] >= 1.5 and m['max_drawdown'] < 0.05:
            status = "GREAT"
        elif m['profit_factor'] >= 1.3 and m['max_drawdown'] < 0.08:
            status = "GOOD"
        elif m['profit_factor'] >= 1.0 and m['max_drawdown'] < 0.10:
            status = "OK"
        else:
            status = "FAIL"
        
        report.append(
            f"{r['strategy']:<30} {m['total_trades']:>8} {m['win_rate']:>7.1%} "
            f"{m['profit_factor']:>8.2f} {m['max_drawdown']:>7.2%} "
            f"{m['total_return']:>9.2%} {m['sharpe_ratio']:>8.2f} {status:<8}"
        )
    
    report.append("-" * 100)
    
    # Detailed results for each strategy
    report.append("")
    report.append("=" * 100)
    report.append("                              DETAILED RESULTS")
    report.append("=" * 100)
    
    for r in results:
        m = r['metrics']
        report.append("")
        report.append(f"### {r['strategy']}")
        report.append("-" * 50)
        
        if 'error' in m:
            report.append(f"ERROR: {m['error']}")
            continue
        
        report.append(f"Signals Generated:    {m.get('buy_signals', 0)} buy, {m.get('sell_signals', 0)} sell")
        report.append(f"Total Trades:         {m['total_trades']}")
        report.append(f"Win Rate:             {m['win_rate']:.2%}")
        report.append(f"Profit Factor:        {m['profit_factor']:.2f}")
        report.append(f"")
        report.append(f"Max Drawdown:         {m['max_drawdown']:.2%}")
        report.append(f"Total Return:         {m['total_return']:.2%}")
        report.append(f"Net Profit:           ${m['net_profit']:,.2f}")
        report.append(f"Final Balance:        ${m['final_balance']:,.2f}")
        report.append(f"")
        report.append(f"Sharpe Ratio:         {m['sharpe_ratio']:.2f}")
        report.append(f"SQN:                  {m['sqn']:.2f}")
        report.append(f"Expectancy:           ${m['expectancy']:.2f}")
        report.append(f"")
        report.append(f"Gross Profit:         ${m['gross_profit']:,.2f}")
        report.append(f"Gross Loss:           ${m['gross_loss']:,.2f}")
        report.append(f"Avg Win:              ${m['avg_win']:,.2f}")
        report.append(f"Avg Loss:             ${m['avg_loss']:,.2f}")
        report.append(f"")
        report.append(f"Max Consecutive Wins:  {m['max_consecutive_wins']}")
        report.append(f"Max Consecutive Losses:{m['max_consecutive_losses']}")
        report.append(f"")
        report.append(f"Exit Reasons:")
        for reason, count in sorted(m['exit_reasons'].items(), key=lambda x: -x[1]):
            pct = count / m['total_trades'] * 100
            report.append(f"  {reason}: {count} ({pct:.1f}%)")
        
        # FTMO Assessment
        report.append(f"")
        report.append(f"FTMO Assessment:")
        if m['max_drawdown'] < 0.05:
            report.append(f"  [OK] Max DD < 5% daily limit")
        elif m['max_drawdown'] < 0.10:
            report.append(f"  [WARN] Max DD {m['max_drawdown']:.2%} - between 5-10%")
        else:
            report.append(f"  [FAIL] Max DD {m['max_drawdown']:.2%} >= 10%")
        
        if m['profit_factor'] >= 1.5:
            report.append(f"  [OK] PF {m['profit_factor']:.2f} >= 1.5")
        elif m['profit_factor'] >= 1.0:
            report.append(f"  [WARN] PF {m['profit_factor']:.2f} - marginal")
        else:
            report.append(f"  [FAIL] PF {m['profit_factor']:.2f} < 1.0 (losing)")
        
        if m['total_trades'] >= 100:
            report.append(f"  [OK] {m['total_trades']} trades - statistically significant")
        elif m['total_trades'] >= 30:
            report.append(f"  [WARN] {m['total_trades']} trades - marginally significant")
        else:
            report.append(f"  [WARN] {m['total_trades']} trades - low significance")
    
    # Recommendations
    report.append("")
    report.append("=" * 100)
    report.append("                              RECOMMENDATIONS")
    report.append("=" * 100)
    
    # Find best strategies
    valid_results = [r for r in results if 'error' not in r['metrics']]
    if valid_results:
        # Sort by profit factor
        sorted_by_pf = sorted(valid_results, key=lambda x: x['metrics']['profit_factor'], reverse=True)
        
        # Sort by risk-adjusted (Sharpe)
        sorted_by_sharpe = sorted(valid_results, key=lambda x: x['metrics']['sharpe_ratio'], reverse=True)
        
        # Best overall (PF > 1, lowest DD)
        profitable = [r for r in valid_results if r['metrics']['profit_factor'] >= 1.0]
        if profitable:
            best = min(profitable, key=lambda x: x['metrics']['max_drawdown'])
            report.append(f"")
            report.append(f"BEST OVERALL (profitable + lowest DD):")
            report.append(f"  {best['strategy']}")
            report.append(f"  PF: {best['metrics']['profit_factor']:.2f}, DD: {best['metrics']['max_drawdown']:.2%}")
        else:
            report.append(f"")
            report.append(f"WARNING: No profitable strategies found!")
            report.append(f"Best by PF: {sorted_by_pf[0]['strategy']} (PF: {sorted_by_pf[0]['metrics']['profit_factor']:.2f})")
        
        report.append(f"")
        report.append(f"TOP 3 BY PROFIT FACTOR:")
        for i, r in enumerate(sorted_by_pf[:3]):
            report.append(f"  {i+1}. {r['strategy']} - PF: {r['metrics']['profit_factor']:.2f}")
        
        report.append(f"")
        report.append(f"TOP 3 BY SHARPE RATIO:")
        for i, r in enumerate(sorted_by_sharpe[:3]):
            report.append(f"  {i+1}. {r['strategy']} - Sharpe: {r['metrics']['sharpe_ratio']:.2f}")
    
    # GO/NO-GO recommendation
    report.append("")
    report.append("=" * 100)
    report.append("                              GO/NO-GO DECISION")
    report.append("=" * 100)
    
    go_candidates = [r for r in valid_results if 
                    r['metrics']['profit_factor'] >= 1.3 and 
                    r['metrics']['max_drawdown'] < 0.08 and
                    r['metrics']['total_trades'] >= 30]
    
    if go_candidates:
        report.append("")
        report.append("DECISION: CONDITIONAL GO")
        report.append("")
        report.append("Candidates for further validation:")
        for r in go_candidates:
            m = r['metrics']
            report.append(f"  - {r['strategy']}: PF={m['profit_factor']:.2f}, DD={m['max_drawdown']:.2%}")
        report.append("")
        report.append("NEXT STEPS:")
        report.append("  1. Run Walk-Forward Analysis on best candidate")
        report.append("  2. Run Monte Carlo (5000+ simulations)")
        report.append("  3. Calculate Deflated Sharpe Ratio")
        report.append("  4. If all pass: Demo test for 2 weeks")
    else:
        report.append("")
        report.append("DECISION: NO-GO")
        report.append("")
        report.append("No strategy meets minimum criteria:")
        report.append("  - PF >= 1.3")
        report.append("  - Max DD < 8%")
        report.append("  - Trades >= 30")
        report.append("")
        report.append("RECOMMENDATIONS:")
        report.append("  1. Review and improve signal generation")
        report.append("  2. Add more confluence factors")
        report.append("  3. Consider different market conditions")
        report.append("  4. Test on out-of-sample data")
    
    report.append("")
    report.append("=" * 100)
    
    # Join and output
    report_text = "\n".join(report)
    print(report_text)
    
    # Save to file
    if output_path:
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(report_text)
        print(f"\n[Report] Saved to: {output_path}")
    
    return report_text


# =============================================================================
# MAIN
# =============================================================================

def main():
    """Run comprehensive strategy comparison"""
    
    # Load data
    data_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/Python_Agent_Hub/ml_pipeline/data/Bars_2020-2025XAUUSD_ftmo-M5-No Session.csv"
    df = load_m5_data(data_path)
    
    # Initialize backtester
    config = BacktestConfig(
        initial_balance=100_000,
        risk_per_trade=0.005,
        spread_points=0.30,
        slippage_mult=1.5  # Pessimistic
    )
    backtester = StrategyBacktester(config)
    
    # Get all strategies
    strategies = get_all_strategies()
    
    print(f"\n[Test] Running {len(strategies)} strategies...")
    print("=" * 60)
    
    results = []
    for i, strategy in enumerate(strategies):
        print(f"\n[{i+1}/{len(strategies)}] Testing: {strategy.name}")
        result = backtester.run(df.copy(), strategy)
        results.append(result)
        
        m = result['metrics']
        if 'error' not in m:
            print(f"    Trades: {m['total_trades']}, PF: {m['profit_factor']:.2f}, "
                  f"DD: {m['max_drawdown']:.2%}, Return: {m['total_return']:.2%}")
    
    # Generate report
    output_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/DOCS/04_REPORTS/VALIDATION/STRATEGY_COMPARISON_REPORT.md"
    generate_report(results, output_path)
    
    # Export trades for best strategy
    valid = [r for r in results if 'error' not in r['metrics']]
    if valid:
        best = max(valid, key=lambda x: x['metrics']['profit_factor'])
        trades_df = pd.DataFrame([{
            'entry_time': t.entry_time,
            'exit_time': t.exit_time,
            'direction': t.direction,
            'entry_price': t.entry_price,
            'exit_price': t.exit_price,
            'sl': t.sl,
            'tp': t.tp,
            'lots': t.lots,
            'pnl': t.pnl,
            'exit_reason': t.exit_reason
        } for t in best['trades']])
        
        export_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/data/best_strategy_trades.csv"
        trades_df.to_csv(export_path, index=False)
        print(f"\n[Export] Best strategy trades saved to: {export_path}")
    
    return results


if __name__ == "__main__":
    main()
