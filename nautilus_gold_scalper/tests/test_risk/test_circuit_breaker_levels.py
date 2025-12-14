from nautilus_gold_scalper.src.risk.circuit_breaker import CircuitBreaker, CircuitBreakerLevel


def test_circuit_breaker_consecutive_losses_reduces_size():
    cb = CircuitBreaker(daily_loss_limit=0.10, total_loss_limit=0.20)
    # 3 losses -> level 1 pause (can_trade False)
    cb.register_trade_result(pnl=-100, is_win=False)
    cb.register_trade_result(pnl=-100, is_win=False)
    cb.register_trade_result(pnl=-100, is_win=False)
    assert cb.can_trade() is False
    # 5th loss -> Level 2 with size multiplier reduction
    cb.register_trade_result(pnl=-100, is_win=False)
    cb.register_trade_result(pnl=-100, is_win=False)
    assert cb.get_size_multiplier() <= 0.75
    # Lockdown level should report cannot trade
    assert cb.can_trade() is False or cb.get_size_multiplier() < 1.0


def test_circuit_breaker_resets():
    cb = CircuitBreaker()
    cb.update_equity(100000.0)
    cb.register_trade_result(pnl=-100, is_win=False)
    cb.update_equity(99900.0)
    cb.reset_daily()
    assert cb.can_trade() is True
    assert cb.get_size_multiplier() == 1.0
