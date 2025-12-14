#!/usr/bin/env python3
"""
Incremental SMC Filter Testing
==============================
Tests each SMC/ICT component incrementally to measure impact.

Test Matrix:
1. Baseline (no filters)
2. + Structure (bias alignment)
3. + Order Blocks
4. + FVG
5. + Liquidity Sweeps
6. + Premium/Discount
7. + Full Confluence Score

Author: FORGE + ORACLE
Date: 2025-12-01
"""

import numpy as np
import pandas as pd
from pathlib import Path
from dataclasses import dataclass
from typing import List, Dict, Optional, Tuple
from datetime import datetime
from enum import Enum
import warnings
import time
warnings.filterwarnings('ignore')

# Import SMC components
from smc_components import (
    SMCAnalyzer, StructureAnalyzer, OrderBlockDetector, 
    FVGDetector, LiquiditySweepDetector, PremiumDiscountAnalyzer,
    ConfluenceCalculator, MarketBias
)


# =============================================================================
# CONFIGURATION
# =============================================================================

@dataclass
class TestConfig:
    initial_balance: float = 100_000.0
    risk_per_trade: float = 0.005
    max_daily_dd: float = 0.05
    max_total_dd: float = 0.10
    spread: float = 0.30
    slippage_mult: float = 1.5
    atr_period: int = 14
    atr_sl_mult: float = 2.0
    atr_tp_mult: float = 3.0


class Signal(Enum):
    NONE = 0
    BUY = 1
    SELL = -1


# =============================================================================
# DATA LOADING
# =============================================================================

def load_data(filepath: str) -> pd.DataFrame:
    """Load M5 OHLC data"""
    print(f"Loading {filepath}...")
    df = pd.read_csv(filepath)
    df['datetime'] = pd.to_datetime(df['Date'].astype(str) + ' ' + df['Time'])
    df.set_index('datetime', inplace=True)
    df = df[['Open', 'High', 'Low', 'Close', 'Volume']].copy()
    df.columns = ['open', 'high', 'low', 'close', 'volume']
    print(f"Loaded {len(df):,} bars ({df.index[0]} to {df.index[-1]})")
    return df


# =============================================================================
# STRATEGY CLASSES
# =============================================================================

class BaseStrategy:
    """Base class for all strategies"""
    
    def __init__(self, name: str):
        self.name = name
    
    def prepare(self, df: pd.DataFrame) -> pd.DataFrame:
        """Prepare indicators"""
        return df
    
    def generate_signal(self, row: pd.Series) -> Signal:
        """Generate trading signal"""
        return Signal.NONE


class Strategy1_Baseline(BaseStrategy):
    """Baseline - Simple EMA crossover, no SMC"""
    
    def __init__(self):
        super().__init__("1. Baseline (EMA Cross)")
    
    def prepare(self, df: pd.DataFrame) -> pd.DataFrame:
        df = df.copy()
        df['ema_fast'] = df['close'].ewm(span=12).mean()
        df['ema_slow'] = df['close'].ewm(span=26).mean()
        df['tr'] = np.maximum(df['high'] - df['low'], 
                             np.maximum(abs(df['high'] - df['close'].shift(1)),
                                       abs(df['low'] - df['close'].shift(1))))
        df['atr'] = df['tr'].rolling(14).mean()
        df['cross_up'] = (df['ema_fast'] > df['ema_slow']) & (df['ema_fast'].shift(1) <= df['ema_slow'].shift(1))
        df['cross_down'] = (df['ema_fast'] < df['ema_slow']) & (df['ema_fast'].shift(1) >= df['ema_slow'].shift(1))
        return df.dropna()
    
    def generate_signal(self, row: pd.Series) -> Signal:
        if row.get('cross_up', False):
            return Signal.BUY
        if row.get('cross_down', False):
            return Signal.SELL
        return Signal.NONE


class Strategy2_Structure(BaseStrategy):
    """Add Structure Analysis - Only trade with bias"""
    
    def __init__(self):
        super().__init__("2. + Structure (Bias)")
        self.structure = StructureAnalyzer(swing_strength=3)
    
    def prepare(self, df: pd.DataFrame) -> pd.DataFrame:
        df = df.copy()
        df['ema_fast'] = df['close'].ewm(span=12).mean()
        df['ema_slow'] = df['close'].ewm(span=26).mean()
        df['tr'] = np.maximum(df['high'] - df['low'], 
                             np.maximum(abs(df['high'] - df['close'].shift(1)),
                                       abs(df['low'] - df['close'].shift(1))))
        df['atr'] = df['tr'].rolling(14).mean()
        df['cross_up'] = (df['ema_fast'] > df['ema_slow']) & (df['ema_fast'].shift(1) <= df['ema_slow'].shift(1))
        df['cross_down'] = (df['ema_fast'] < df['ema_slow']) & (df['ema_fast'].shift(1) >= df['ema_slow'].shift(1))
        df = self.structure.analyze(df)
        return df.dropna()
    
    def generate_signal(self, row: pd.Series) -> Signal:
        bias = row.get('bias', MarketBias.RANGING.value)
        if row.get('cross_up', False) and bias == MarketBias.BULLISH.value:
            return Signal.BUY
        if row.get('cross_down', False) and bias == MarketBias.BEARISH.value:
            return Signal.SELL
        return Signal.NONE


class Strategy3_OrderBlocks(BaseStrategy):
    """Add Order Blocks - Entry at OB zones"""
    
    def __init__(self):
        super().__init__("3. + Order Blocks")
        self.structure = StructureAnalyzer(swing_strength=3)
        self.ob = OrderBlockDetector(displacement_mult=2.0)
    
    def prepare(self, df: pd.DataFrame) -> pd.DataFrame:
        df = df.copy()
        df['tr'] = np.maximum(df['high'] - df['low'], 
                             np.maximum(abs(df['high'] - df['close'].shift(1)),
                                       abs(df['low'] - df['close'].shift(1))))
        df['atr'] = df['tr'].rolling(14).mean()
        df = self.structure.analyze(df)
        df = self.ob.detect(df)
        return df.dropna()
    
    def generate_signal(self, row: pd.Series) -> Signal:
        bias = row.get('bias', MarketBias.RANGING.value)
        # Buy at bullish OB in bullish bias
        if row.get('in_bullish_ob', False) and bias == MarketBias.BULLISH.value:
            return Signal.BUY
        # Sell at bearish OB in bearish bias
        if row.get('in_bearish_ob', False) and bias == MarketBias.BEARISH.value:
            return Signal.SELL
        return Signal.NONE


class Strategy4_FVG(BaseStrategy):
    """Add FVG - Entry at Fair Value Gaps"""
    
    def __init__(self):
        super().__init__("4. + FVG")
        self.structure = StructureAnalyzer(swing_strength=3)
        self.ob = OrderBlockDetector(displacement_mult=2.0)
        self.fvg = FVGDetector(min_gap_points=0.3, max_gap_points=15.0)
    
    def prepare(self, df: pd.DataFrame) -> pd.DataFrame:
        df = df.copy()
        df['tr'] = np.maximum(df['high'] - df['low'], 
                             np.maximum(abs(df['high'] - df['close'].shift(1)),
                                       abs(df['low'] - df['close'].shift(1))))
        df['atr'] = df['tr'].rolling(14).mean()
        df = self.structure.analyze(df)
        df = self.ob.detect(df)
        df = self.fvg.detect(df)
        return df.dropna()
    
    def generate_signal(self, row: pd.Series) -> Signal:
        bias = row.get('bias', MarketBias.RANGING.value)
        # Buy at bullish OB or FVG
        if bias == MarketBias.BULLISH.value:
            if row.get('in_bullish_ob', False) or row.get('in_bullish_fvg', False):
                return Signal.BUY
        # Sell at bearish OB or FVG
        if bias == MarketBias.BEARISH.value:
            if row.get('in_bearish_ob', False) or row.get('in_bearish_fvg', False):
                return Signal.SELL
        return Signal.NONE


class Strategy5_Liquidity(BaseStrategy):
    """Add Liquidity Sweeps - Trade after sweep rejection"""
    
    def __init__(self):
        super().__init__("5. + Liquidity Sweeps")
        self.structure = StructureAnalyzer(swing_strength=3)
        self.ob = OrderBlockDetector(displacement_mult=2.0)
        self.fvg = FVGDetector(min_gap_points=0.3, max_gap_points=15.0)
        self.liq = LiquiditySweepDetector(equal_tolerance=0.5)
    
    def prepare(self, df: pd.DataFrame) -> pd.DataFrame:
        df = df.copy()
        df['tr'] = np.maximum(df['high'] - df['low'], 
                             np.maximum(abs(df['high'] - df['close'].shift(1)),
                                       abs(df['low'] - df['close'].shift(1))))
        df['atr'] = df['tr'].rolling(14).mean()
        df = self.structure.analyze(df)
        df = self.ob.detect(df)
        df = self.fvg.detect(df)
        df = self.liq.detect(df)
        return df.dropna()
    
    def generate_signal(self, row: pd.Series) -> Signal:
        # SSL sweep = Buy signal (liquidity grabbed below, reversal up)
        if row.get('ssl_sweep', False) and row.get('sweep_rejection', False):
            return Signal.BUY
        # BSL sweep = Sell signal (liquidity grabbed above, reversal down)
        if row.get('bsl_sweep', False) and row.get('sweep_rejection', False):
            return Signal.SELL
        
        # Fallback to OB/FVG
        bias = row.get('bias', MarketBias.RANGING.value)
        if bias == MarketBias.BULLISH.value:
            if row.get('in_bullish_ob', False) or row.get('in_bullish_fvg', False):
                return Signal.BUY
        if bias == MarketBias.BEARISH.value:
            if row.get('in_bearish_ob', False) or row.get('in_bearish_fvg', False):
                return Signal.SELL
        return Signal.NONE


class Strategy6_PremiumDiscount(BaseStrategy):
    """Add Premium/Discount - Only trade in correct zone"""
    
    def __init__(self):
        super().__init__("6. + Premium/Discount")
        self.structure = StructureAnalyzer(swing_strength=3)
        self.ob = OrderBlockDetector(displacement_mult=2.0)
        self.fvg = FVGDetector(min_gap_points=0.3, max_gap_points=15.0)
        self.liq = LiquiditySweepDetector(equal_tolerance=0.5)
        self.pd = PremiumDiscountAnalyzer(lookback=50)
    
    def prepare(self, df: pd.DataFrame) -> pd.DataFrame:
        df = df.copy()
        df['tr'] = np.maximum(df['high'] - df['low'], 
                             np.maximum(abs(df['high'] - df['close'].shift(1)),
                                       abs(df['low'] - df['close'].shift(1))))
        df['atr'] = df['tr'].rolling(14).mean()
        df = self.structure.analyze(df)
        df = self.ob.detect(df)
        df = self.fvg.detect(df)
        df = self.liq.detect(df)
        df = self.pd.analyze(df)
        return df.dropna()
    
    def generate_signal(self, row: pd.Series) -> Signal:
        bias = row.get('bias', MarketBias.RANGING.value)
        in_discount = row.get('in_discount', False)
        in_premium = row.get('in_premium', False)
        
        # Buy: Bullish bias + discount zone + (OB or FVG or SSL sweep)
        if bias == MarketBias.BULLISH.value and in_discount:
            if row.get('in_bullish_ob', False) or row.get('in_bullish_fvg', False) or row.get('ssl_sweep', False):
                return Signal.BUY
        
        # Sell: Bearish bias + premium zone + (OB or FVG or BSL sweep)
        if bias == MarketBias.BEARISH.value and in_premium:
            if row.get('in_bearish_ob', False) or row.get('in_bearish_fvg', False) or row.get('bsl_sweep', False):
                return Signal.SELL
        
        return Signal.NONE


class Strategy7_FullConfluence(BaseStrategy):
    """Full Confluence Scoring - All SMC components"""
    
    def __init__(self, min_score: int = 50):
        super().__init__(f"7. Full Confluence (>={min_score})")
        self.min_score = min_score
        self.smc = SMCAnalyzer()
    
    def prepare(self, df: pd.DataFrame) -> pd.DataFrame:
        df = self.smc.analyze(df)
        return df.dropna()
    
    def generate_signal(self, row: pd.Series) -> Signal:
        buy_score = row.get('score_buy', 0)
        sell_score = row.get('score_sell', 0)
        
        if buy_score >= self.min_score and buy_score > sell_score:
            return Signal.BUY
        if sell_score >= self.min_score and sell_score > buy_score:
            return Signal.SELL
        return Signal.NONE


# =============================================================================
# BACKTESTER
# =============================================================================

class Backtester:
    """Simple backtester for strategy comparison"""
    
    def __init__(self, config: TestConfig = None):
        self.config = config or TestConfig()
    
    def run(self, df: pd.DataFrame, strategy: BaseStrategy) -> Dict:
        """Run backtest for a strategy"""
        # Prepare data
        df = strategy.prepare(df)
        
        # Initialize
        balance = self.config.initial_balance
        peak = balance
        position = None
        trades = []
        signals_generated = {'BUY': 0, 'SELL': 0}
        
        for i, (idx, row) in enumerate(df.iterrows()):
            # Check DD limits
            dd = (peak - balance) / peak if peak > 0 else 0
            if dd >= self.config.max_total_dd:
                if position:
                    pnl = self._close(position, row)
                    trades.append(pnl)
                    balance += pnl['pnl']
                break
            
            # Manage position
            if position:
                exit_result = self._check_exit(position, row)
                if exit_result:
                    trades.append(exit_result)
                    balance += exit_result['pnl']
                    if balance > peak:
                        peak = balance
                    position = None
            
            # Generate signal
            signal = strategy.generate_signal(row)
            if signal != Signal.NONE:
                signals_generated[signal.name] += 1
            
            # Open position
            if position is None and signal != Signal.NONE:
                position = self._open(idx, row, signal)
        
        # Close remaining
        if position:
            pnl = self._close(position, df.iloc[-1])
            trades.append(pnl)
            balance += pnl['pnl']
        
        # Calculate metrics
        metrics = self._calculate_metrics(trades, self.config.initial_balance, balance, peak)
        metrics['signals_buy'] = signals_generated['BUY']
        metrics['signals_sell'] = signals_generated['SELL']
        
        return {
            'strategy': strategy.name,
            'trades': trades,
            'metrics': metrics
        }
    
    def _open(self, time, row: pd.Series, signal: Signal) -> Dict:
        spread = self.config.spread * self.config.slippage_mult
        atr = row.get('atr', 1.0)
        
        if signal == Signal.BUY:
            entry = row['close'] + spread/2
            sl = entry - atr * self.config.atr_sl_mult
            tp = entry + atr * self.config.atr_tp_mult
        else:
            entry = row['close'] - spread/2
            sl = entry + atr * self.config.atr_sl_mult
            tp = entry - atr * self.config.atr_tp_mult
        
        risk = self.config.initial_balance * self.config.risk_per_trade
        sl_dist = abs(entry - sl)
        lots = risk / (sl_dist * 100) if sl_dist > 0 else 0.01
        lots = max(0.01, min(lots, 10.0))
        
        return {
            'time': time,
            'direction': signal.name,
            'entry': entry,
            'sl': sl,
            'tp': tp,
            'lots': lots
        }
    
    def _check_exit(self, pos: Dict, row: pd.Series) -> Optional[Dict]:
        if pos['direction'] == 'BUY':
            if row['low'] <= pos['sl']:
                return self._create_trade(pos, pos['sl'], 'SL')
            if row['high'] >= pos['tp']:
                return self._create_trade(pos, pos['tp'], 'TP')
        else:
            if row['high'] >= pos['sl']:
                return self._create_trade(pos, pos['sl'], 'SL')
            if row['low'] <= pos['tp']:
                return self._create_trade(pos, pos['tp'], 'TP')
        return None
    
    def _close(self, pos: Dict, row: pd.Series) -> Dict:
        spread = self.config.spread * self.config.slippage_mult
        exit_price = row['close'] - spread/2 if pos['direction'] == 'BUY' else row['close'] + spread/2
        return self._create_trade(pos, exit_price, 'CLOSE')
    
    def _create_trade(self, pos: Dict, exit_price: float, reason: str) -> Dict:
        if pos['direction'] == 'BUY':
            pnl = (exit_price - pos['entry']) * pos['lots'] * 100
        else:
            pnl = (pos['entry'] - exit_price) * pos['lots'] * 100
        return {'entry': pos['entry'], 'exit': exit_price, 'pnl': pnl, 'reason': reason}
    
    def _calculate_metrics(self, trades: List, initial: float, final: float, peak: float) -> Dict:
        if not trades:
            return {'error': 'No trades', 'total_trades': 0}
        
        pnls = [t['pnl'] for t in trades]
        wins = [p for p in pnls if p > 0]
        losses = [p for p in pnls if p < 0]
        
        n = len(trades)
        wr = len(wins) / n if n > 0 else 0
        gp = sum(wins) if wins else 0
        gl = abs(sum(losses)) if losses else 1
        pf = gp / gl if gl > 0 else 0
        
        equity = [initial]
        for p in pnls:
            equity.append(equity[-1] + p)
        eq = np.array(equity)
        pk = np.maximum.accumulate(eq)
        dd = ((pk - eq) / pk).max()
        
        ret = (final - initial) / initial
        
        exit_reasons = {}
        for t in trades:
            r = t['reason']
            exit_reasons[r] = exit_reasons.get(r, 0) + 1
        
        return {
            'total_trades': n,
            'win_rate': wr,
            'profit_factor': pf,
            'max_drawdown': dd,
            'total_return': ret,
            'net_profit': final - initial,
            'final_balance': final,
            'exit_reasons': exit_reasons
        }


# =============================================================================
# MAIN TEST RUNNER
# =============================================================================

def run_incremental_tests(df: pd.DataFrame) -> List[Dict]:
    """Run all strategy tests incrementally"""
    
    strategies = [
        Strategy1_Baseline(),
        Strategy2_Structure(),
        Strategy3_OrderBlocks(),
        Strategy4_FVG(),
        Strategy5_Liquidity(),
        Strategy6_PremiumDiscount(),
        Strategy7_FullConfluence(min_score=40),
        Strategy7_FullConfluence(min_score=50),
        Strategy7_FullConfluence(min_score=60),
    ]
    
    backtester = Backtester()
    results = []
    
    print(f"\n{'='*80}")
    print("                    INCREMENTAL SMC FILTER TESTING")
    print(f"{'='*80}\n")
    
    for i, strat in enumerate(strategies):
        start_time = time.time()
        print(f"[{i+1}/{len(strategies)}] Testing: {strat.name}...", end=" ", flush=True)
        
        result = backtester.run(df.copy(), strat)
        elapsed = time.time() - start_time
        
        m = result['metrics']
        if 'error' not in m:
            status = "OK" if m['profit_factor'] >= 1.0 else "FAIL"
            if m['profit_factor'] >= 1.3:
                status = "GOOD"
            if m['profit_factor'] >= 1.5:
                status = "GREAT"
            print(f"Trades:{m['total_trades']:>4} PF:{m['profit_factor']:>5.2f} DD:{m['max_drawdown']:>6.2%} [{status}] ({elapsed:.1f}s)")
        else:
            print(f"ERROR: {m['error']}")
        
        results.append(result)
    
    return results


def print_detailed_report(results: List[Dict]):
    """Print detailed comparison report"""
    
    print(f"\n{'='*100}")
    print("                              DETAILED RESULTS")
    print(f"{'='*100}\n")
    
    # Summary table
    print(f"{'Strategy':<35} {'Trades':>7} {'WR':>7} {'PF':>7} {'MaxDD':>8} {'Return':>9} {'Status':<8}")
    print("-" * 100)
    
    for r in results:
        m = r['metrics']
        if 'error' in m:
            print(f"{r['strategy']:<35} {'ERROR':>7}")
            continue
        
        status = "FAIL"
        if m['profit_factor'] >= 1.0:
            status = "OK"
        if m['profit_factor'] >= 1.3 and m['max_drawdown'] < 0.08:
            status = "GOOD"
        if m['profit_factor'] >= 1.5 and m['max_drawdown'] < 0.05:
            status = "GREAT"
        
        print(f"{r['strategy']:<35} {m['total_trades']:>7} {m['win_rate']:>6.1%} "
              f"{m['profit_factor']:>7.2f} {m['max_drawdown']:>7.2%} "
              f"{m['total_return']:>8.2%} {status:<8}")
    
    # Analysis
    print(f"\n{'='*100}")
    print("                              ANALYSIS")
    print(f"{'='*100}\n")
    
    # Find best
    valid = [r for r in results if 'error' not in r['metrics']]
    if valid:
        best_pf = max(valid, key=lambda x: x['metrics']['profit_factor'])
        best_dd = min(valid, key=lambda x: x['metrics']['max_drawdown'])
        
        print(f"Best Profit Factor: {best_pf['strategy']}")
        print(f"  PF: {best_pf['metrics']['profit_factor']:.2f}, DD: {best_pf['metrics']['max_drawdown']:.2%}")
        print()
        print(f"Lowest Drawdown: {best_dd['strategy']}")
        print(f"  PF: {best_dd['metrics']['profit_factor']:.2f}, DD: {best_dd['metrics']['max_drawdown']:.2%}")
        
        # Incremental improvement analysis
        print(f"\n{'='*100}")
        print("                         INCREMENTAL IMPACT")
        print(f"{'='*100}\n")
        
        baseline_pf = results[0]['metrics'].get('profit_factor', 0)
        print(f"{'Filter Added':<35} {'PF Change':>12} {'Cumulative PF':>15}")
        print("-" * 65)
        
        for i, r in enumerate(results):
            m = r['metrics']
            if 'error' in m:
                continue
            
            pf = m['profit_factor']
            if i == 0:
                change = 0
            else:
                prev_pf = results[i-1]['metrics'].get('profit_factor', pf)
                change = pf - prev_pf
            
            change_str = f"+{change:.2f}" if change >= 0 else f"{change:.2f}"
            print(f"{r['strategy']:<35} {change_str:>12} {pf:>15.2f}")
    
    # Final recommendation
    print(f"\n{'='*100}")
    print("                         RECOMMENDATION")
    print(f"{'='*100}\n")
    
    profitable = [r for r in valid if r['metrics']['profit_factor'] >= 1.0]
    if profitable:
        best = max(profitable, key=lambda x: x['metrics']['profit_factor'])
        m = best['metrics']
        print(f"BEST STRATEGY: {best['strategy']}")
        print(f"  Profit Factor: {m['profit_factor']:.2f}")
        print(f"  Win Rate: {m['win_rate']:.1%}")
        print(f"  Max Drawdown: {m['max_drawdown']:.2%}")
        print(f"  Total Return: {m['total_return']:.2%}")
        
        if m['profit_factor'] >= 1.3 and m['max_drawdown'] < 0.08:
            print("\n  STATUS: READY FOR ORACLE VALIDATION")
            print("  Next: Run WFA, Monte Carlo, PSR/DSR")
        else:
            print("\n  STATUS: MARGINAL - Needs improvement")
    else:
        print("NO PROFITABLE STRATEGY FOUND")
        print("\nRecommendations:")
        print("  1. Review signal generation logic")
        print("  2. Test on different timeframes (H1, H4)")
        print("  3. Add more confluence factors")
        print("  4. Review execution assumptions")


def main():
    """Main entry point"""
    
    # Load data
    data_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/Python_Agent_Hub/ml_pipeline/data/Bars_2020-2025XAUUSD_ftmo-M5-No Session.csv"
    df = load_data(data_path)
    
    # Run tests
    results = run_incremental_tests(df)
    
    # Print report
    print_detailed_report(results)
    
    # Save results
    output_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/DOCS/04_REPORTS/VALIDATION/SMC_INCREMENTAL_RESULTS.md"
    
    with open(output_path, 'w') as f:
        f.write("# SMC Incremental Filter Testing Results\n\n")
        f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        
        f.write("## Summary\n\n")
        f.write("| Strategy | Trades | WR | PF | MaxDD | Return | Status |\n")
        f.write("|----------|--------|-----|------|-------|--------|--------|\n")
        
        for r in results:
            m = r['metrics']
            if 'error' not in m:
                status = "FAIL" if m['profit_factor'] < 1.0 else "OK"
                if m['profit_factor'] >= 1.3:
                    status = "GOOD"
                f.write(f"| {r['strategy']} | {m['total_trades']} | {m['win_rate']:.1%} | "
                       f"{m['profit_factor']:.2f} | {m['max_drawdown']:.2%} | "
                       f"{m['total_return']:.2%} | {status} |\n")
    
    print(f"\n[Report saved to {output_path}]")
    
    return results


if __name__ == "__main__":
    main()
