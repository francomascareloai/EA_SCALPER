"""
ConsistencyTracker - Enforces Apex 30% daily profit consistency rule.
"""
from __future__ import annotations

from decimal import Decimal
from datetime import datetime
from zoneinfo import ZoneInfo


class ConsistencyTracker:
    """
    Tracks total and daily profit, enforcing Apex rule:
    daily_profit > 30% of total profit => block new trades.
    """

    def __init__(self, initial_balance: float, tz: str = "America/New_York"):
        self.initial_balance = Decimal(str(initial_balance))
        self.total_profit = Decimal("0")
        self.daily_profit = Decimal("0")
        self.consistency_limit = Decimal("0.25")  # 25% safety buffer (5% margin vs Apex 30%)
        self._limit_hit = False
        self.et_tz = ZoneInfo(tz)
        self._last_day = None

    def _maybe_reset(self, now: datetime):
        if self._last_day is None:
            self._last_day = now.date()
        elif now.date() != self._last_day:
            self.reset_daily()
            self._last_day = now.date()

    def update_profit(self, trade_pnl: float, now: datetime):
        self._maybe_reset(now)
        pnl = Decimal(str(trade_pnl))
        self.total_profit += pnl
        self.daily_profit += pnl

        if self.total_profit > 0:
            daily_pct = self.daily_profit / self.total_profit
            if daily_pct >= self.consistency_limit:
                self._limit_hit = True

    def can_trade(self, now: datetime | None = None) -> bool:
        """
        Returns True if trading is allowed under the consistency rule.
        Accepts an optional datetime; defaults to now in ET.
        """
        if now is None:
            now = datetime.now(self.et_tz)
        self._maybe_reset(now)
        return not self._limit_hit

    def reset_daily(self):
        self.daily_profit = Decimal("0")
        self._limit_hit = False

    def get_daily_profit_pct(self) -> float:
        if self.total_profit <= 0:
            return 0.0
        return float((self.daily_profit / self.total_profit) * 100)
