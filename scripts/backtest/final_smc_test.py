#!/usr/bin/env python3
"""
Final SMC Test - Fixed Risk (FTMO Compliant)
============================================
Uses FIXED lot size based on initial balance (no compounding).
This is how FTMO Challenge works.
"""

import numpy as np
import pandas as pd
from datetime import datetime
from dataclasses import dataclass
from typing import List, Dict, Optional
import warnings
warnings.filterwarnings('ignore')


@dataclass
class OrderBlock:
    idx: int
    time: datetime
    ob_type: str
    top: float
    bottom: float
    strength: float


class SMCBacktester:
    """FTMO-compliant backtester with fixed lot sizing"""
    
    def __init__(self, initial_balance: float = 100000, risk_pct: float = 0.005,
                 spread: float = 0.45, max_dd_pct: float = 0.10):
        self.initial_balance = initial_balance
        self.risk_amount = initial_balance * risk_pct  # FIXED risk amount
        self.spread = spread
        self.max_dd = initial_balance * max_dd_pct
    
    def detect_obs(self, df: pd.DataFrame, min_disp: float = 2.0) -> List[OrderBlock]:
        """Detect Order Blocks"""
        df['tr'] = np.maximum(
            df['high'] - df['low'],
            np.maximum(abs(df['high'] - df['close'].shift(1)),
                      abs(df['low'] - df['close'].shift(1))))
        df['atr'] = df['tr'].rolling(14).mean().fillna(1.0)
        
        obs = []
        for i in range(5, len(df) - 3):
            atr = df['atr'].iloc[i]
            
            # Bullish OB
            if df['close'].iloc[i] < df['open'].iloc[i]:
                disp = df['high'].iloc[i+1:i+4].max() - df['close'].iloc[i]
                if disp >= atr * min_disp:
                    obs.append(OrderBlock(i, df.index[i], 'BULL',
                                         df['open'].iloc[i], df['low'].iloc[i], disp/atr))
            
            # Bearish OB
            if df['close'].iloc[i] > df['open'].iloc[i]:
                disp = df['close'].iloc[i] - df['low'].iloc[i+1:i+4].min()
                if disp >= atr * min_disp:
                    obs.append(OrderBlock(i, df.index[i], 'BEAR',
                                         df['high'].iloc[i], df['open'].iloc[i], disp/atr))
        return obs
    
    def run(self, df: pd.DataFrame, obs: List[OrderBlock],
            sl_mult: float = 2.0, tp_mult: float = 3.0) -> Dict:
        """Run backtest with FIXED lot sizing"""
        
        # Calculate ATR if not present
        if 'tr' not in df.columns:
            df['tr'] = np.maximum(
                df['high'] - df['low'],
                np.maximum(abs(df['high'] - df['close'].shift(1)),
                          abs(df['low'] - df['close'].shift(1))))
        df['atr'] = df['tr'].rolling(14).mean().fillna(1.0)
        df['ma200'] = df['close'].rolling(200).mean()
        
        balance = self.initial_balance
        peak = balance
        position = None
        trades = []
        used_obs = set()
        
        for i, (idx, row) in enumerate(df.iterrows()):
            if i < 200:
                continue
            
            # Check DD (based on initial balance)
            current_dd = self.initial_balance - balance
            if current_dd >= self.max_dd:
                if position:
                    pnl, reason = self._close(position, row)
                    trades.append({'pnl': pnl, 'reason': 'DD_LIMIT'})
                    balance += pnl
                break
            
            # Manage position
            if position:
                result = self._check_exit(position, row)
                if result:
                    trades.append(result)
                    balance += result['pnl']
                    if balance > peak:
                        peak = balance
                    position = None
            
            # Entry at unmitigated OBs
            if position is None:
                atr = row['atr'] if 'atr' in row else 1.0
                ma200 = row['ma200']
                
                if pd.isna(atr) or pd.isna(ma200):
                    continue
                
                for ob in obs:
                    if ob.idx in used_obs:
                        continue
                    
                    if ob.ob_type == 'BULL':
                        if row['close'] > ma200 and row['low'] <= ob.top and row['close'] >= ob.bottom:
                            used_obs.add(ob.idx)
                            
                            entry = row['close'] + self.spread/2
                            sl = entry - atr * sl_mult
                            tp = entry + atr * tp_mult
                            
                            # FIXED lot based on initial balance risk
                            sl_dist = entry - sl
                            lots = self.risk_amount / (sl_dist * 100) if sl_dist > 0 else 0.01
                            lots = max(0.01, min(lots, 10.0))
                            
                            position = {'dir': 'BUY', 'entry': entry, 'sl': sl, 'tp': tp, 'lots': lots}
                            break
                    
                    elif ob.ob_type == 'BEAR':
                        if row['close'] < ma200 and row['high'] >= ob.bottom and row['close'] <= ob.top:
                            used_obs.add(ob.idx)
                            
                            entry = row['close'] - self.spread/2
                            sl = entry + atr * sl_mult
                            tp = entry - atr * tp_mult
                            
                            sl_dist = sl - entry
                            lots = self.risk_amount / (sl_dist * 100) if sl_dist > 0 else 0.01
                            lots = max(0.01, min(lots, 10.0))
                            
                            position = {'dir': 'SELL', 'entry': entry, 'sl': sl, 'tp': tp, 'lots': lots}
                            break
        
        # Close remaining
        if position:
            pnl, _ = self._close(position, df.iloc[-1])
            trades.append({'pnl': pnl, 'reason': 'END'})
            balance += pnl
        
        return self._metrics(trades, balance, peak, len(obs), len(used_obs))
    
    def _check_exit(self, pos: Dict, row: pd.Series) -> Optional[Dict]:
        if pos['dir'] == 'BUY':
            if row['low'] <= pos['sl']:
                pnl = (pos['sl'] - pos['entry']) * pos['lots'] * 100
                return {'pnl': pnl, 'reason': 'SL'}
            if row['high'] >= pos['tp']:
                pnl = (pos['tp'] - pos['entry']) * pos['lots'] * 100
                return {'pnl': pnl, 'reason': 'TP'}
        else:
            if row['high'] >= pos['sl']:
                pnl = (pos['entry'] - pos['sl']) * pos['lots'] * 100
                return {'pnl': pnl, 'reason': 'SL'}
            if row['low'] <= pos['tp']:
                pnl = (pos['entry'] - pos['tp']) * pos['lots'] * 100
                return {'pnl': pnl, 'reason': 'TP'}
        return None
    
    def _close(self, pos: Dict, row: pd.Series) -> tuple:
        if pos['dir'] == 'BUY':
            exit_p = row['close'] - self.spread/2
            return (exit_p - pos['entry']) * pos['lots'] * 100, 'CLOSE'
        else:
            exit_p = row['close'] + self.spread/2
            return (pos['entry'] - exit_p) * pos['lots'] * 100, 'CLOSE'
    
    def _metrics(self, trades: List[Dict], final: float, peak: float,
                 total_obs: int, used_obs: int) -> Dict:
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
        
        # Proper DD calculation
        equity = [self.initial_balance]
        for p in pnls:
            equity.append(equity[-1] + p)
        eq = np.array(equity)
        running_max = np.maximum.accumulate(eq)
        drawdowns = running_max - eq
        max_dd = drawdowns.max()
        max_dd_pct = max_dd / self.initial_balance
        
        # Exit reasons
        reasons = {}
        for t in trades:
            r = t['reason']
            reasons[r] = reasons.get(r, 0) + 1
        
        return {
            'total_trades': n,
            'wins': len(wins),
            'losses': len(losses),
            'win_rate': wr,
            'profit_factor': pf,
            'max_drawdown': max_dd,
            'max_drawdown_pct': max_dd_pct,
            'total_return': (final - self.initial_balance) / self.initial_balance,
            'net_profit': final - self.initial_balance,
            'final_balance': final,
            'exit_reasons': reasons,
            'total_obs': total_obs,
            'used_obs': used_obs,
            'avg_win': np.mean(wins) if wins else 0,
            'avg_loss': np.mean(losses) if losses else 0
        }


def load_data(filepath: str) -> pd.DataFrame:
    df = pd.read_csv(filepath)
    df['datetime'] = pd.to_datetime(df['Date'].astype(str) + ' ' + df['Time'])
    df.set_index('datetime', inplace=True)
    df = df[['Open', 'High', 'Low', 'Close', 'Volume']].copy()
    df.columns = ['open', 'high', 'low', 'close', 'volume']
    return df


def main():
    print("=" * 80)
    print("         SMC ORDER BLOCK - FIXED RISK (FTMO COMPLIANT)")
    print("=" * 80)
    
    # Load
    path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/Python_Agent_Hub/ml_pipeline/data/Bars_2020-2025XAUUSD_ftmo-M5-No Session.csv"
    print(f"\nLoading data...")
    df = load_data(path)
    print(f"Loaded {len(df):,} bars")
    
    # Test multiple configurations
    configs = [
        {'disp': 2.0, 'sl': 2.0, 'tp': 3.0, 'name': 'Standard (2.0/2.0/3.0)'},
        {'disp': 2.0, 'sl': 1.5, 'tp': 2.25, 'name': 'Tight (2.0/1.5/2.25)'},
        {'disp': 2.5, 'sl': 2.0, 'tp': 3.0, 'name': 'High Disp (2.5/2.0/3.0)'},
        {'disp': 2.0, 'sl': 2.0, 'tp': 4.0, 'name': 'Wide TP (2.0/2.0/4.0)'},
        {'disp': 1.5, 'sl': 1.5, 'tp': 3.0, 'name': 'Aggressive (1.5/1.5/3.0)'},
    ]
    
    print("\n" + "-" * 80)
    print(f"{'Config':<30} {'Trades':>8} {'WR':>8} {'PF':>8} {'MaxDD':>10} {'Return':>10}")
    print("-" * 80)
    
    results = []
    bt = SMCBacktester(initial_balance=100000, risk_pct=0.005, spread=0.45)
    
    for cfg in configs:
        df_copy = df.copy()
        obs = bt.detect_obs(df_copy, min_disp=cfg['disp'])
        print(f"  [{cfg['name']}] OBs detected: {len(obs)}", end=" -> ")
        m = bt.run(df_copy, obs, sl_mult=cfg['sl'], tp_mult=cfg['tp'])
        m['config'] = cfg['name']
        results.append(m)
        
        if 'error' not in m and m['total_trades'] > 0:
            status = 'FAIL' if m['profit_factor'] < 1.0 else 'OK'
            if m['profit_factor'] >= 1.3 and m['max_drawdown_pct'] < 0.08:
                status = 'GOOD'
            if m['profit_factor'] >= 1.5 and m['max_drawdown_pct'] < 0.05:
                status = 'GREAT'
            
            print(f"Trades: {m['total_trades']}, WR: {m['win_rate']:.1%}, "
                  f"PF: {m['profit_factor']:.2f}, DD: {m['max_drawdown_pct']:.2%} [{status}]")
        else:
            print(f"No trades or error: {m.get('error', 'Unknown')}")
    
    # Best result
    valid = [r for r in results if 'error' not in r and r['profit_factor'] > 0]
    if valid:
        best = max(valid, key=lambda x: x['profit_factor'])
        
        print("\n" + "=" * 80)
        print("                         BEST RESULT")
        print("=" * 80)
        print(f"\nConfig:          {best['config']}")
        print(f"Total Trades:    {best['total_trades']}")
        print(f"Win Rate:        {best['win_rate']:.1%}")
        print(f"Profit Factor:   {best['profit_factor']:.2f}")
        print(f"Max Drawdown:    {best['max_drawdown_pct']:.2%} (${best['max_drawdown']:,.2f})")
        print(f"Total Return:    {best['total_return']:.2%}")
        print(f"Net Profit:      ${best['net_profit']:,.2f}")
        print(f"\nAvg Win:         ${best['avg_win']:,.2f}")
        print(f"Avg Loss:        ${best['avg_loss']:,.2f}")
        print(f"\nExit Reasons:")
        for r, c in sorted(best['exit_reasons'].items(), key=lambda x: -x[1]):
            print(f"  {r}: {c} ({c/best['total_trades']*100:.1f}%)")
        
        # Sanity check
        expected_pf = (best['win_rate'] * abs(best['avg_win'])) / ((1-best['win_rate']) * abs(best['avg_loss']))
        print(f"\nSanity Check:")
        print(f"  Calculated PF from WR/AvgWin/AvgLoss: {expected_pf:.2f}")
        print(f"  Reported PF: {best['profit_factor']:.2f}")
        
        # FTMO Assessment
        print("\n" + "-" * 40)
        print("FTMO ASSESSMENT:")
        
        checks = []
        if best['profit_factor'] >= 1.0:
            checks.append("[OK] PF >= 1.0 (profitable)")
        else:
            checks.append("[FAIL] PF < 1.0 (losing)")
        
        if best['max_drawdown_pct'] < 0.05:
            checks.append("[GREAT] DD < 5%")
        elif best['max_drawdown_pct'] < 0.08:
            checks.append("[GOOD] DD < 8%")
        elif best['max_drawdown_pct'] < 0.10:
            checks.append("[OK] DD < 10%")
        else:
            checks.append("[FAIL] DD >= 10%")
        
        if best['total_trades'] >= 100:
            checks.append("[OK] Trades >= 100 (significant)")
        elif best['total_trades'] >= 50:
            checks.append("[WARN] Trades 50-100 (marginal)")
        else:
            checks.append("[WARN] Trades < 50 (low)")
        
        for c in checks:
            print(f"  {c}")
        
        if best['profit_factor'] >= 1.3 and best['max_drawdown_pct'] < 0.08:
            print("\n>>> READY FOR ORACLE VALIDATION <<<")
        elif best['profit_factor'] >= 1.0:
            print("\n>>> MARGINAL - Consider adding more filters <<<")
        else:
            print("\n>>> NOT READY - Strategy needs work <<<")
    
    print("\n" + "=" * 80)
    return results


if __name__ == "__main__":
    main()
