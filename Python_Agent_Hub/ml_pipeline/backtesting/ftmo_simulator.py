"""
FTMO Rules Simulator
EA_SCALPER_XAUUSD - Singularity Edition

Simulates FTMO challenge rules during backtesting.
Ensures strategy compliance before real challenge.
"""

import pandas as pd
import numpy as np
from dataclasses import dataclass
from typing import List, Tuple, Optional
from datetime import datetime, timedelta


@dataclass
class FTMOConfig:
    """FTMO Challenge configuration."""
    account_size: float = 100_000
    max_daily_loss_pct: float = 5.0      # 5% = $5,000
    max_total_loss_pct: float = 10.0     # 10% = $10,000
    profit_target_pct: float = 10.0      # Phase 1: 10%
    min_trading_days: int = 4
    # Our safety buffers
    daily_loss_buffer_pct: float = 4.0   # Stop at 4%
    total_loss_buffer_pct: float = 8.0   # Stop at 8%


@dataclass
class TradeResult:
    """Single trade result."""
    entry_time: datetime
    exit_time: datetime
    direction: str  # 'long' or 'short'
    entry_price: float
    exit_price: float
    size: float
    pnl: float
    pnl_pct: float


class FTMOSimulator:
    """
    Simulates FTMO challenge rules during backtest.
    Tracks drawdown, daily limits, and compliance.
    """
    
    def __init__(self, config: FTMOConfig = None):
        self.config = config or FTMOConfig()
        self.reset()
    
    def reset(self):
        """Reset simulator state."""
        self.initial_balance = self.config.account_size
        self.balance = self.config.account_size
        self.equity = self.config.account_size
        self.peak_equity = self.config.account_size
        
        self.daily_start_equity = self.config.account_size
        self.current_day = None
        
        self.trades: List[TradeResult] = []
        self.daily_pnl: dict = {}
        self.trading_days: set = set()
        
        self.is_blown = False
        self.blown_reason = None
        self.is_passed = False
        
        # Tracking
        self.max_drawdown = 0
        self.max_daily_drawdown = 0
        self.total_pnl = 0
    
    def _check_new_day(self, timestamp: datetime):
        """Check if it's a new trading day."""
        day = timestamp.date()
        if self.current_day != day:
            self.current_day = day
            self.daily_start_equity = self.equity
            if day not in self.daily_pnl:
                self.daily_pnl[day] = 0
    
    def _update_drawdowns(self):
        """Update drawdown metrics."""
        # Peak equity
        if self.equity > self.peak_equity:
            self.peak_equity = self.equity
        
        # Total drawdown
        total_dd = (self.peak_equity - self.equity) / self.peak_equity * 100
        self.max_drawdown = max(self.max_drawdown, total_dd)
        
        # Daily drawdown
        daily_dd = (self.daily_start_equity - self.equity) / self.daily_start_equity * 100
        self.max_daily_drawdown = max(self.max_daily_drawdown, daily_dd)
        
        return total_dd, daily_dd
    
    def _check_ftmo_rules(self, total_dd: float, daily_dd: float) -> Tuple[bool, Optional[str]]:
        """Check if FTMO rules are violated."""
        # Hard limits (account blown)
        if daily_dd >= self.config.max_daily_loss_pct:
            return False, f"DAILY LOSS LIMIT: {daily_dd:.2f}% >= {self.config.max_daily_loss_pct}%"
        
        if total_dd >= self.config.max_total_loss_pct:
            return False, f"TOTAL LOSS LIMIT: {total_dd:.2f}% >= {self.config.max_total_loss_pct}%"
        
        return True, None
    
    def can_trade(self, timestamp: datetime) -> Tuple[bool, str]:
        """Check if trading is allowed (safety buffers)."""
        if self.is_blown:
            return False, f"Account blown: {self.blown_reason}"
        
        self._check_new_day(timestamp)
        total_dd, daily_dd = self._update_drawdowns()
        
        # Safety buffers (more conservative than FTMO limits)
        if daily_dd >= self.config.daily_loss_buffer_pct:
            return False, f"Daily DD at {daily_dd:.2f}% - STOP (buffer: {self.config.daily_loss_buffer_pct}%)"
        
        if total_dd >= self.config.total_loss_buffer_pct:
            return False, f"Total DD at {total_dd:.2f}% - STOP (buffer: {self.config.total_loss_buffer_pct}%)"
        
        return True, "OK"
    
    def record_trade(self, trade: TradeResult) -> Tuple[bool, str]:
        """Record a completed trade and check rules."""
        self._check_new_day(trade.exit_time)
        
        # Update balances
        self.balance += trade.pnl
        self.equity = self.balance  # Simplified, no open positions
        self.total_pnl += trade.pnl
        
        # Record daily PnL
        day = trade.exit_time.date()
        self.daily_pnl[day] = self.daily_pnl.get(day, 0) + trade.pnl
        self.trading_days.add(day)
        
        # Store trade
        self.trades.append(trade)
        
        # Update drawdowns and check rules
        total_dd, daily_dd = self._update_drawdowns()
        ok, reason = self._check_ftmo_rules(total_dd, daily_dd)
        
        if not ok:
            self.is_blown = True
            self.blown_reason = reason
            return False, reason
        
        # Check if passed
        profit_pct = (self.equity - self.initial_balance) / self.initial_balance * 100
        if profit_pct >= self.config.profit_target_pct and len(self.trading_days) >= self.config.min_trading_days:
            self.is_passed = True
        
        return True, "OK"
    
    def get_stats(self) -> dict:
        """Get comprehensive statistics."""
        if not self.trades:
            return {"error": "No trades recorded"}
        
        # Basic stats
        total_trades = len(self.trades)
        winning_trades = [t for t in self.trades if t.pnl > 0]
        losing_trades = [t for t in self.trades if t.pnl < 0]
        
        win_rate = len(winning_trades) / total_trades * 100 if total_trades > 0 else 0
        
        avg_win = np.mean([t.pnl for t in winning_trades]) if winning_trades else 0
        avg_loss = np.mean([t.pnl for t in losing_trades]) if losing_trades else 0
        
        profit_factor = abs(sum(t.pnl for t in winning_trades) / sum(t.pnl for t in losing_trades)) if losing_trades and sum(t.pnl for t in losing_trades) != 0 else float('inf')
        
        # Risk-adjusted returns
        returns = [t.pnl_pct for t in self.trades]
        sharpe = np.mean(returns) / np.std(returns) * np.sqrt(252) if np.std(returns) > 0 else 0
        
        return {
            "ftmo_status": "PASSED" if self.is_passed else ("BLOWN" if self.is_blown else "IN_PROGRESS"),
            "blown_reason": self.blown_reason,
            "initial_balance": self.initial_balance,
            "final_balance": self.balance,
            "total_pnl": self.total_pnl,
            "total_return_pct": (self.balance - self.initial_balance) / self.initial_balance * 100,
            "max_drawdown_pct": self.max_drawdown,
            "max_daily_drawdown_pct": self.max_daily_drawdown,
            "total_trades": total_trades,
            "winning_trades": len(winning_trades),
            "losing_trades": len(losing_trades),
            "win_rate_pct": win_rate,
            "avg_win": avg_win,
            "avg_loss": avg_loss,
            "profit_factor": profit_factor,
            "sharpe_ratio": sharpe,
            "trading_days": len(self.trading_days),
            "min_trading_days_met": len(self.trading_days) >= self.config.min_trading_days,
        }
    
    def print_report(self):
        """Print formatted report."""
        stats = self.get_stats()
        
        print("\n" + "="*60)
        print("FTMO CHALLENGE SIMULATION REPORT")
        print("="*60)
        
        status_color = {
            "PASSED": "GREEN",
            "BLOWN": "RED", 
            "IN_PROGRESS": "YELLOW"
        }
        
        print(f"\nStatus: {stats['ftmo_status']}")
        if stats['blown_reason']:
            print(f"Reason: {stats['blown_reason']}")
        
        print(f"\n--- Performance ---")
        print(f"Initial Balance: ${stats['initial_balance']:,.2f}")
        print(f"Final Balance:   ${stats['final_balance']:,.2f}")
        print(f"Total PnL:       ${stats['total_pnl']:,.2f} ({stats['total_return_pct']:.2f}%)")
        
        print(f"\n--- Risk Metrics ---")
        print(f"Max Drawdown:       {stats['max_drawdown_pct']:.2f}% (limit: {self.config.max_total_loss_pct}%)")
        print(f"Max Daily Drawdown: {stats['max_daily_drawdown_pct']:.2f}% (limit: {self.config.max_daily_loss_pct}%)")
        
        print(f"\n--- Trade Statistics ---")
        print(f"Total Trades:  {stats['total_trades']}")
        print(f"Win Rate:      {stats['win_rate_pct']:.1f}%")
        print(f"Profit Factor: {stats['profit_factor']:.2f}")
        print(f"Sharpe Ratio:  {stats['sharpe_ratio']:.2f}")
        print(f"Avg Win:       ${stats['avg_win']:.2f}")
        print(f"Avg Loss:      ${stats['avg_loss']:.2f}")
        
        print(f"\n--- FTMO Requirements ---")
        print(f"Trading Days: {stats['trading_days']} (min: {self.config.min_trading_days}) {'OK' if stats['min_trading_days_met'] else 'NOT MET'}")
        print(f"Profit Target: {stats['total_return_pct']:.2f}% (target: {self.config.profit_target_pct}%) {'OK' if stats['total_return_pct'] >= self.config.profit_target_pct else 'NOT MET'}")
        print(f"Max DD Limit:  {stats['max_drawdown_pct']:.2f}% (limit: {self.config.max_total_loss_pct}%) {'OK' if stats['max_drawdown_pct'] < self.config.max_total_loss_pct else 'VIOLATED'}")
        
        print("="*60)


if __name__ == "__main__":
    # Example usage
    sim = FTMOSimulator()
    
    # Simulate some trades
    base_time = datetime(2024, 1, 1, 10, 0)
    
    trades_data = [
        (1, 'long', 2000, 2010, 0.5, 500),   # Win
        (2, 'short', 2010, 2005, 0.5, 250),  # Win
        (3, 'long', 2005, 1995, 0.5, -500),  # Loss
        (4, 'long', 1995, 2015, 0.5, 1000),  # Win
        (5, 'short', 2015, 2020, 0.3, -150), # Loss
    ]
    
    for i, (day_offset, direction, entry, exit_p, size, pnl) in enumerate(trades_data):
        trade = TradeResult(
            entry_time=base_time + timedelta(days=day_offset, hours=i),
            exit_time=base_time + timedelta(days=day_offset, hours=i+2),
            direction=direction,
            entry_price=entry,
            exit_price=exit_p,
            size=size,
            pnl=pnl,
            pnl_pct=pnl/100000*100
        )
        
        can_trade, msg = sim.can_trade(trade.entry_time)
        if can_trade:
            ok, reason = sim.record_trade(trade)
            print(f"Trade {i+1}: PnL=${pnl:+.0f} | Balance=${sim.balance:,.0f} | {reason}")
        else:
            print(f"Trade {i+1}: BLOCKED - {msg}")
            break
    
    sim.print_report()
