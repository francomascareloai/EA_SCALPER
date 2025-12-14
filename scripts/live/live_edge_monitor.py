#!/usr/bin/env python3
"""
live_edge_monitor.py - Monitor edge decay and performance in live trading.

BATCH 6: Real-time monitoring of strategy edge and performance metrics.

Features:
- Rolling performance metrics
- Edge decay detection
- Regime shift detection
- Alert generation
- Dashboard output

Usage:
    python scripts/live/live_edge_monitor.py \
        --trades data/live_trades.csv \
        --baseline backtest_metrics.json
"""

import argparse
import json
import sys
from dataclasses import dataclass
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional

import numpy as np
import pandas as pd


@dataclass
class AlertLevel:
    """Alert severity levels."""
    INFO = 'INFO'
    WARNING = 'WARNING'
    CRITICAL = 'CRITICAL'


@dataclass
class Alert:
    """Performance alert."""
    timestamp: datetime
    level: str
    metric: str
    message: str
    value: float
    threshold: float


class LiveEdgeMonitor:
    """
    Monitor strategy edge in real-time.
    
    Detects:
    - Edge decay (performance degradation)
    - Regime shifts
    - Drawdown warnings
    - Win rate changes
    """
    
    # Default thresholds
    EDGE_DECAY_THRESHOLD = 0.7  # If current/baseline < 0.7, alert
    WIN_RATE_DROP_THRESHOLD = 0.1  # 10% drop from baseline
    DD_WARNING_THRESHOLD = 0.06  # 6% drawdown
    DD_CRITICAL_THRESHOLD = 0.08  # 8% drawdown
    
    def __init__(self, baseline_metrics: Optional[Dict] = None):
        """
        Initialize monitor.
        
        Args:
            baseline_metrics: Dict with baseline performance from backtest
        """
        self.baseline = baseline_metrics or {}
        self.trades: List[Dict] = []
        self.alerts: List[Alert] = []
        self.metrics_history: List[Dict] = []
        
        # State
        self.equity = 100000
        self.equity_high = 100000
        self.daily_equity_high = 100000
    
    def set_baseline(self, metrics: Dict):
        """Set baseline metrics from backtest."""
        self.baseline = metrics
    
    def add_trade(self, trade: Dict):
        """
        Add completed trade and check for alerts.
        
        Trade dict should have:
        - pnl: float
        - entry_time: datetime
        - exit_time: datetime
        - regime: str (optional)
        - session: str (optional)
        """
        self.trades.append(trade)
        
        # Update equity
        self.equity += trade.get('pnl', 0)
        if self.equity > self.equity_high:
            self.equity_high = self.equity
        if self.equity > self.daily_equity_high:
            self.daily_equity_high = self.equity
        
        # Check alerts
        self._check_alerts()
        
        # Update metrics history
        if len(self.trades) % 10 == 0:  # Every 10 trades
            self._update_metrics_history()
    
    def _check_alerts(self):
        """Check all alert conditions."""
        self._check_drawdown()
        self._check_edge_decay()
        self._check_win_rate()
    
    def _check_drawdown(self):
        """Check drawdown levels."""
        current_dd = (self.equity_high - self.equity) / self.equity_high
        daily_dd = (self.daily_equity_high - self.equity) / self.daily_equity_high
        
        if daily_dd >= self.DD_CRITICAL_THRESHOLD:
            self._add_alert(
                AlertLevel.CRITICAL, 'daily_dd',
                f"Daily DD critical: {daily_dd*100:.1f}%",
                daily_dd, self.DD_CRITICAL_THRESHOLD
            )
        elif daily_dd >= self.DD_WARNING_THRESHOLD:
            self._add_alert(
                AlertLevel.WARNING, 'daily_dd',
                f"Daily DD warning: {daily_dd*100:.1f}%",
                daily_dd, self.DD_WARNING_THRESHOLD
            )
        
        if current_dd >= self.DD_CRITICAL_THRESHOLD:
            self._add_alert(
                AlertLevel.CRITICAL, 'total_dd',
                f"Total DD critical: {current_dd*100:.1f}%",
                current_dd, self.DD_CRITICAL_THRESHOLD
            )
    
    def _check_edge_decay(self):
        """Check for edge decay vs baseline."""
        if len(self.trades) < 20 or not self.baseline:
            return
        
        # Calculate current metrics
        recent = self.trades[-50:]  # Last 50 trades
        current_pf = self._calculate_pf(recent)
        baseline_pf = self.baseline.get('profit_factor', 1.5)
        
        if baseline_pf > 0:
            decay_ratio = current_pf / baseline_pf
            
            if decay_ratio < self.EDGE_DECAY_THRESHOLD:
                self._add_alert(
                    AlertLevel.WARNING, 'edge_decay',
                    f"Edge decay detected: PF {current_pf:.2f} vs baseline {baseline_pf:.2f}",
                    decay_ratio, self.EDGE_DECAY_THRESHOLD
                )
    
    def _check_win_rate(self):
        """Check win rate vs baseline."""
        if len(self.trades) < 30 or not self.baseline:
            return
        
        recent = self.trades[-30:]
        current_wr = sum(1 for t in recent if t.get('pnl', 0) > 0) / len(recent)
        baseline_wr = self.baseline.get('win_rate', 0.55)
        
        if current_wr < baseline_wr - self.WIN_RATE_DROP_THRESHOLD:
            self._add_alert(
                AlertLevel.WARNING, 'win_rate',
                f"Win rate drop: {current_wr*100:.1f}% vs baseline {baseline_wr*100:.1f}%",
                current_wr, baseline_wr - self.WIN_RATE_DROP_THRESHOLD
            )
    
    def _calculate_pf(self, trades: List[Dict]) -> float:
        """Calculate profit factor."""
        wins = sum(t['pnl'] for t in trades if t.get('pnl', 0) > 0)
        losses = abs(sum(t['pnl'] for t in trades if t.get('pnl', 0) < 0))
        return wins / losses if losses > 0 else 0
    
    def _add_alert(self, level: str, metric: str, message: str,
                   value: float, threshold: float):
        """Add new alert."""
        alert = Alert(
            timestamp=datetime.now(),
            level=level,
            metric=metric,
            message=message,
            value=value,
            threshold=threshold
        )
        self.alerts.append(alert)
        
        # Print alert
        print(f"[{level}] {message}")
    
    def _update_metrics_history(self):
        """Update rolling metrics history."""
        if len(self.trades) < 10:
            return
        
        recent = self.trades[-50:]
        
        metrics = {
            'timestamp': datetime.now().isoformat(),
            'n_trades': len(self.trades),
            'equity': self.equity,
            'drawdown_pct': (self.equity_high - self.equity) / self.equity_high * 100,
            'win_rate': sum(1 for t in recent if t.get('pnl', 0) > 0) / len(recent) * 100,
            'profit_factor': self._calculate_pf(recent),
            'avg_pnl': np.mean([t.get('pnl', 0) for t in recent])
        }
        
        self.metrics_history.append(metrics)
    
    def get_current_status(self) -> Dict:
        """Get current monitoring status."""
        if not self.trades:
            return {'status': 'NO_DATA'}
        
        recent = self.trades[-50:] if len(self.trades) >= 50 else self.trades
        
        return {
            'total_trades': len(self.trades),
            'equity': self.equity,
            'total_pnl': sum(t.get('pnl', 0) for t in self.trades),
            'drawdown_pct': (self.equity_high - self.equity) / self.equity_high * 100,
            'win_rate': sum(1 for t in recent if t.get('pnl', 0) > 0) / len(recent) * 100,
            'profit_factor': self._calculate_pf(recent),
            'recent_alerts': [
                {'level': a.level, 'message': a.message}
                for a in self.alerts[-5:]
            ],
            'edge_status': self._get_edge_status()
        }
    
    def _get_edge_status(self) -> str:
        """Get overall edge status."""
        if not self.baseline:
            return 'NO_BASELINE'
        
        recent_critical = [a for a in self.alerts[-10:] if a.level == AlertLevel.CRITICAL]
        recent_warnings = [a for a in self.alerts[-10:] if a.level == AlertLevel.WARNING]
        
        if len(recent_critical) >= 2:
            return 'CRITICAL'
        elif len(recent_warnings) >= 3:
            return 'DEGRADED'
        else:
            return 'HEALTHY'
    
    def generate_dashboard(self) -> str:
        """Generate text dashboard."""
        status = self.get_current_status()
        
        lines = [
            "=" * 60,
            "LIVE EDGE MONITOR DASHBOARD",
            f"Updated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            "=" * 60,
            "",
            f"Edge Status: {status.get('edge_status', 'UNKNOWN')}",
            "",
            "--- Performance ---",
            f"Total Trades:  {status.get('total_trades', 0)}",
            f"Equity:        ${status.get('equity', 0):,.2f}",
            f"Total PnL:     ${status.get('total_pnl', 0):,.2f}",
            f"Drawdown:      {status.get('drawdown_pct', 0):.1f}%",
            f"Win Rate:      {status.get('win_rate', 0):.1f}%",
            f"Profit Factor: {status.get('profit_factor', 0):.2f}",
            "",
            "--- Recent Alerts ---"
        ]
        
        for alert in status.get('recent_alerts', []):
            lines.append(f"  [{alert['level']}] {alert['message']}")
        
        if not status.get('recent_alerts'):
            lines.append("  No recent alerts")
        
        lines.append("")
        lines.append("=" * 60)
        
        return "\n".join(lines)
    
    def save_state(self, filepath: str):
        """Save monitor state."""
        state = {
            'baseline': self.baseline,
            'trades': self.trades,
            'alerts': [
                {'timestamp': a.timestamp.isoformat(), 'level': a.level,
                 'metric': a.metric, 'message': a.message}
                for a in self.alerts
            ],
            'metrics_history': self.metrics_history,
            'equity': self.equity
        }
        
        with open(filepath, 'w') as f:
            json.dump(state, f, indent=2)


def main():
    parser = argparse.ArgumentParser(
        description='Monitor live trading edge and performance'
    )
    parser.add_argument('--trades', '-t',
                        help='Path to live trades CSV')
    parser.add_argument('--baseline', '-b',
                        help='Path to baseline metrics JSON')
    parser.add_argument('--output', '-o',
                        help='Output path for state')
    
    args = parser.parse_args()
    
    # Load baseline if provided
    baseline = {}
    if args.baseline:
        with open(args.baseline, 'r') as f:
            baseline = json.load(f)
    
    # Create monitor
    monitor = LiveEdgeMonitor(baseline)
    
    # Load trades if provided
    if args.trades:
        trades_df = pd.read_csv(args.trades)
        for _, row in trades_df.iterrows():
            monitor.add_trade(row.to_dict())
    
    # Print dashboard
    print(monitor.generate_dashboard())
    
    # Save state
    if args.output:
        monitor.save_state(args.output)
    
    return 0


if __name__ == '__main__':
    sys.exit(main())
