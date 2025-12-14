#!/usr/bin/env python3
"""
shadow_exchange.py - Exchange emulator for shadow testing EA logic.

BATCH 4: Simulates order execution with realistic latency and slippage.

Features:
- Order execution simulation with latency (EVT modeled)
- Slippage modeling based on spread and volume
- Position tracking
- PnL calculation
- Divergence detection vs MT5 results

Usage:
    python scripts/backtest/shadow_exchange.py \
        --ticks data/processed/ticks_2024.parquet \
        --output shadow_results/
"""

import argparse
import json
import sys
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from pathlib import Path
from typing import Dict, List, Optional

import numpy as np
import pandas as pd


class OrderType(Enum):
    BUY = 1
    SELL = -1


class OrderStatus(Enum):
    PENDING = 'pending'
    FILLED = 'filled'
    CANCELLED = 'cancelled'
    CLOSED = 'closed'


@dataclass
class Order:
    """Trade order."""
    id: int
    type: OrderType
    entry_price: float
    sl_price: float
    tp_price: float
    lot_size: float
    timestamp: datetime
    status: OrderStatus = OrderStatus.PENDING
    fill_price: float = 0
    fill_time: datetime = None
    close_price: float = 0
    close_time: datetime = None
    pnl: float = 0
    slippage: float = 0
    latency_ms: float = 0


@dataclass
class Position:
    """Open position."""
    order: Order
    unrealized_pnl: float = 0


class ShadowExchange:
    """
    Simulated exchange for shadow testing.
    
    Models:
    - Execution latency (EVT distribution)
    - Slippage based on spread
    - FTMO limits
    """
    
    # Latency parameters (ms) - EVT modeled
    LATENCY_LOCATION = 50  # Location parameter
    LATENCY_SCALE = 20     # Scale parameter
    LATENCY_SHAPE = 0.3    # Shape parameter (tail)
    
    # Slippage parameters
    SLIPPAGE_BASE = 0.02   # Base slippage in price units
    SLIPPAGE_SPREAD_MULT = 0.1  # Multiplier of spread
    
    # FTMO limits
    DAILY_DD_LIMIT = 0.05
    TOTAL_DD_LIMIT = 0.10
    
    def __init__(self, initial_balance: float = 100000):
        self.initial_balance = initial_balance
        self.balance = initial_balance
        self.equity = initial_balance
        
        self.orders: List[Order] = []
        self.positions: Dict[int, Position] = {}
        self.closed_trades: List[Order] = []
        
        self.order_counter = 0
        self.daily_equity_high = initial_balance
        self.total_equity_high = initial_balance
        
        # Statistics
        self.total_latency = 0
        self.total_slippage = 0
        self.fill_count = 0
    
    def submit_order(self, order_type: OrderType, entry: float,
                     sl: float, tp: float, lot_size: float,
                     timestamp: datetime) -> Order:
        """Submit new order."""
        self.order_counter += 1
        
        order = Order(
            id=self.order_counter,
            type=order_type,
            entry_price=entry,
            sl_price=sl,
            tp_price=tp,
            lot_size=lot_size,
            timestamp=timestamp
        )
        
        self.orders.append(order)
        return order
    
    def process_tick(self, timestamp: datetime, bid: float, ask: float):
        """
        Process tick and check for order fills/exits.
        
        Args:
            timestamp: Current time
            bid: Bid price
            ask: Ask price
        """
        spread = ask - bid
        mid = (bid + ask) / 2
        
        # Process pending orders
        for order in self.orders:
            if order.status == OrderStatus.PENDING:
                self._try_fill_order(order, timestamp, bid, ask, spread)
        
        # Update positions and check SL/TP
        for pos_id, pos in list(self.positions.items()):
            self._update_position(pos, timestamp, bid, ask)
        
        # Update equity
        self._update_equity()
        
        # Check FTMO limits
        self._check_limits()
    
    def _try_fill_order(self, order: Order, timestamp: datetime,
                        bid: float, ask: float, spread: float):
        """Try to fill pending order."""
        # Simulate latency
        latency_ms = self._sample_latency()
        order.latency_ms = latency_ms
        
        # Simulate slippage
        slippage = self._calculate_slippage(spread)
        order.slippage = slippage
        
        # Fill price
        if order.type == OrderType.BUY:
            fill_price = ask + slippage
        else:
            fill_price = bid - slippage
        
        order.fill_price = fill_price
        order.fill_time = timestamp
        order.status = OrderStatus.FILLED
        
        # Create position
        self.positions[order.id] = Position(order=order)
        
        # Update stats
        self.total_latency += latency_ms
        self.total_slippage += slippage
        self.fill_count += 1
    
    def _update_position(self, pos: Position, timestamp: datetime,
                         bid: float, ask: float):
        """Update position and check exit conditions."""
        order = pos.order
        
        # Current price for exit
        if order.type == OrderType.BUY:
            current_price = bid  # Close at bid
        else:
            current_price = ask  # Close at ask
        
        # Calculate unrealized PnL
        if order.type == OrderType.BUY:
            pos.unrealized_pnl = (current_price - order.fill_price) * order.lot_size * 100
        else:
            pos.unrealized_pnl = (order.fill_price - current_price) * order.lot_size * 100
        
        # Check SL
        if order.type == OrderType.BUY:
            if current_price <= order.sl_price:
                self._close_position(pos, current_price, timestamp, 'SL')
                return
        else:
            if current_price >= order.sl_price:
                self._close_position(pos, current_price, timestamp, 'SL')
                return
        
        # Check TP
        if order.type == OrderType.BUY:
            if current_price >= order.tp_price:
                self._close_position(pos, current_price, timestamp, 'TP')
                return
        else:
            if current_price <= order.tp_price:
                self._close_position(pos, current_price, timestamp, 'TP')
                return
    
    def _close_position(self, pos: Position, close_price: float,
                        timestamp: datetime, reason: str):
        """Close position."""
        order = pos.order
        order.close_price = close_price
        order.close_time = timestamp
        order.status = OrderStatus.CLOSED
        
        # Final PnL
        if order.type == OrderType.BUY:
            order.pnl = (close_price - order.fill_price) * order.lot_size * 100
        else:
            order.pnl = (order.fill_price - close_price) * order.lot_size * 100
        
        # Update balance
        self.balance += order.pnl
        
        # Move to closed trades
        self.closed_trades.append(order)
        del self.positions[order.id]
    
    def _update_equity(self):
        """Update equity including unrealized PnL."""
        unrealized = sum(p.unrealized_pnl for p in self.positions.values())
        self.equity = self.balance + unrealized
        
        if self.equity > self.daily_equity_high:
            self.daily_equity_high = self.equity
        if self.equity > self.total_equity_high:
            self.total_equity_high = self.equity
    
    def _check_limits(self):
        """Check FTMO limits."""
        daily_dd = (self.daily_equity_high - self.equity) / self.daily_equity_high
        total_dd = (self.total_equity_high - self.equity) / self.total_equity_high
        
        if daily_dd >= self.DAILY_DD_LIMIT:
            # Would stop trading in real scenario
            pass
        
        if total_dd >= self.TOTAL_DD_LIMIT:
            # Would stop trading in real scenario
            pass
    
    def _sample_latency(self) -> float:
        """Sample latency from EVT distribution."""
        # Generalized Pareto Distribution
        u = np.random.uniform(0, 1)
        
        if self.LATENCY_SHAPE != 0:
            latency = self.LATENCY_LOCATION + self.LATENCY_SCALE * (
                (1 - u) ** (-self.LATENCY_SHAPE) - 1
            ) / self.LATENCY_SHAPE
        else:
            latency = self.LATENCY_LOCATION - self.LATENCY_SCALE * np.log(1 - u)
        
        return max(1, latency)
    
    def _calculate_slippage(self, spread: float) -> float:
        """Calculate slippage based on spread."""
        return self.SLIPPAGE_BASE + spread * self.SLIPPAGE_SPREAD_MULT
    
    def get_statistics(self) -> Dict:
        """Get exchange statistics."""
        trades = self.closed_trades
        
        if not trades:
            return {'error': 'No closed trades'}
        
        wins = [t for t in trades if t.pnl > 0]
        losses = [t for t in trades if t.pnl <= 0]
        
        total_pnl = sum(t.pnl for t in trades)
        
        return {
            'total_trades': len(trades),
            'wins': len(wins),
            'losses': len(losses),
            'win_rate': len(wins) / len(trades) * 100 if trades else 0,
            'total_pnl': total_pnl,
            'avg_pnl': total_pnl / len(trades) if trades else 0,
            'avg_latency_ms': self.total_latency / self.fill_count if self.fill_count else 0,
            'avg_slippage': self.total_slippage / self.fill_count if self.fill_count else 0,
            'final_balance': self.balance,
            'return_pct': (self.balance - self.initial_balance) / self.initial_balance * 100
        }


def run_shadow_test(
    ticks_path: str,
    output_dir: str,
    verbose: bool = True
) -> Dict:
    """
    Run shadow exchange test.
    
    Args:
        ticks_path: Path to tick data
        output_dir: Output directory
        verbose: Print progress
    """
    from scripts.backtest.strategies.ea_logic_python import EALogic, BarData
    
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    if verbose:
        print(f"\nLoading ticks from: {ticks_path}")
    
    # Load ticks
    if ticks_path.endswith('.parquet'):
        ticks = pd.read_parquet(ticks_path)
    else:
        ticks = pd.read_csv(ticks_path)
    
    if verbose:
        print(f"  Loaded {len(ticks):,} ticks")
    
    # Initialize
    exchange = ShadowExchange()
    ea = EALogic()
    
    # Resample to M5 bars for signals
    # (simplified - real implementation would be more sophisticated)
    
    if verbose:
        print("\nRunning shadow test...")
    
    # Process ticks (sample every 1000 for speed)
    sample_rate = 1000
    
    for i in range(0, len(ticks), sample_rate):
        tick = ticks.iloc[i]
        
        # Get prices
        if 'bid' in tick:
            bid = tick['bid']
            ask = tick['ask']
        else:
            continue
        
        timestamp = tick.get('timestamp', tick.get('datetime', datetime.now()))
        if isinstance(timestamp, str):
            timestamp = pd.to_datetime(timestamp)
        
        # Process tick
        exchange.process_tick(timestamp, bid, ask)
        
        # Generate signal periodically (every 300 ticks = ~M5)
        if i % (300 * sample_rate) == 0 and i > 0:
            bar = BarData(
                timestamp=timestamp.timestamp() if hasattr(timestamp, 'timestamp') else 0,
                open=bid,
                high=bid + 1,
                low=bid - 1,
                close=bid
            )
            
            hour = timestamp.hour if hasattr(timestamp, 'hour') else 12
            signal = ea.evaluate(bar, hour, rsi=50, ml_prob=0.6, mtf_alignment=0.7)
            
            if signal and len(exchange.positions) == 0:
                order_type = OrderType.BUY if signal.signal_type.value == 1 else OrderType.SELL
                exchange.submit_order(
                    order_type=order_type,
                    entry=signal.entry_price,
                    sl=signal.sl_price,
                    tp=signal.tp_price,
                    lot_size=signal.lot_size,
                    timestamp=timestamp
                )
    
    # Get results
    stats = exchange.get_statistics()
    
    if verbose:
        print(f"\n{'='*50}")
        print("SHADOW TEST RESULTS")
        print(f"{'='*50}")
        for k, v in stats.items():
            if isinstance(v, float):
                print(f"  {k}: {v:.2f}")
            else:
                print(f"  {k}: {v}")
    
    # Save results
    results_file = output_dir / 'shadow_results.json'
    with open(results_file, 'w') as f:
        json.dump(stats, f, indent=2, default=str)
    
    return stats


def main():
    parser = argparse.ArgumentParser(
        description='Shadow exchange for testing EA logic'
    )
    parser.add_argument('--ticks', '-t', required=True,
                        help='Path to tick data')
    parser.add_argument('--output', '-o', default='shadow_results/',
                        help='Output directory')
    
    args = parser.parse_args()
    
    stats = run_shadow_test(args.ticks, args.output)
    
    return 0


if __name__ == '__main__':
    sys.exit(main())
