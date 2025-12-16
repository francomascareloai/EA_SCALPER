"""
Test artifact for CRITIC adversarial review.
Simple trading logic with intentional issues for CRITIC to find.
"""
from datetime import datetime, time
from typing import Optional


class SimpleScalper:
    """A simple gold scalper for testing CRITIC review."""

    def __init__(self, account_balance: float = 100_000.0):
        self.balance = account_balance
        self.high_water_mark = account_balance
        self.position_size = 0.0
        self.entry_price: Optional[float] = None
        self.is_long: bool = False

    def calculate_lot_size(self, stop_loss_pips: float, risk_percent: float = 2.0) -> float:
        """Calculate position size based on risk."""
        # Risk amount in dollars
        risk_amount = self.balance * risk_percent  # BUG: should be risk_percent / 100

        # Pip value for XAUUSD (assuming 1 lot = 100 oz, $1/pip per 0.01 lot)
        pip_value = 10.0  # per standard lot

        # Calculate lot size
        lot_size = risk_amount / (stop_loss_pips * pip_value)
        return lot_size

    def check_time_gate(self) -> bool:
        """Check if trading is allowed based on Apex time rules."""
        now = datetime.now()
        current_time = now.time()

        # Block new trades after 4:30 PM
        cutoff = time(16, 30)

        if current_time > cutoff:
            return False
        return True

    def calculate_drawdown(self) -> float:
        """Calculate current drawdown from high water mark."""
        if self.balance > self.high_water_mark:
            self.high_water_mark = self.balance

        # BUG: This only considers realized balance, not unrealized P/L
        drawdown = (self.high_water_mark - self.balance) / self.high_water_mark
        return drawdown

    def should_enter_long(self, prices: list[float]) -> bool:
        """Check if we should enter long based on simple MA crossover."""
        if len(prices) < 20:
            return False

        # Fast MA (5 period)
        fast_ma = sum(prices[-5:]) / 5

        # Slow MA (20 period) - BUG: look-ahead, using future price
        slow_ma = sum(prices[-20:]) / 20

        # BUG: Using current bar close which isn't complete yet
        current_price = prices[-1]

        return fast_ma > slow_ma and current_price > fast_ma

    def enter_trade(self, price: float, is_long: bool, lot_size: float):
        """Enter a new trade."""
        self.entry_price = price
        self.is_long = is_long
        self.position_size = lot_size
        # BUG: No check if already in a position
        # BUG: No check if lot_size is valid (> 0, <= max)

    def exit_trade(self, exit_price: float) -> float:
        """Exit current trade and return P/L."""
        if self.entry_price is None:
            return 0.0

        # Calculate P/L
        if self.is_long:
            pnl = (exit_price - self.entry_price) * self.position_size * 100
        else:
            pnl = (self.entry_price - exit_price) * self.position_size * 100

        self.balance += pnl
        self.entry_price = None
        self.position_size = 0.0

        return pnl

    def check_apex_compliance(self) -> dict:
        """Check if we're compliant with Apex rules."""
        dd = self.calculate_drawdown()

        return {
            "trailing_dd_ok": dd < 0.05,  # 5% trailing
            "daily_dd_ok": True,  # BUG: Not actually checking daily DD
            "time_ok": self.check_time_gate(),
            "overnight_ok": True,  # BUG: Not actually checking for overnight positions
        }


def run_backtest(prices: list[float]) -> dict:
    """Run a simple backtest."""
    scalper = SimpleScalper()
    trades = 0

    for i in range(20, len(prices)):
        # Get historical prices up to current bar
        historical = prices[:i+1]  # BUG: includes current bar (look-ahead)

        if scalper.entry_price is None:
            if scalper.should_enter_long(historical):
                lot_size = scalper.calculate_lot_size(10.0)  # 10 pip SL
                scalper.enter_trade(prices[i], True, lot_size)
                trades += 1
        else:
            # Simple exit: 20 pip TP or 10 pip SL
            current_pnl = (prices[i] - scalper.entry_price) * 100
            if current_pnl > 20 or current_pnl < -10:
                scalper.exit_trade(prices[i])

    return {
        "final_balance": scalper.balance,
        "trades": trades,
        "drawdown": scalper.calculate_drawdown(),
    }
