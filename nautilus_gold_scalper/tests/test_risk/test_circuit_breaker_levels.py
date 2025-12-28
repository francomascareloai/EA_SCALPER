from datetime import datetime, timedelta, timezone

from nautilus_gold_scalper.src.risk.circuit_breaker import CircuitBreaker


def test_circuit_breaker_consecutive_losses_reduces_size():
    cb = CircuitBreaker(daily_loss_limit=0.10, total_loss_limit=0.20)

    # 3 losses -> level 1 pause (can_trade False)
    now = datetime(2025, 1, 1, tzinfo=timezone.utc)
    cb.register_trade_result(pnl=-100, is_win=False, now=now)
    cb.register_trade_result(pnl=-100, is_win=False, now=now)
    cb.register_trade_result(pnl=-100, is_win=False, now=now)
    assert cb.can_trade(now=now) is False

    # After cooldown expiry, intelligent recovery may allow a limited probe.
    after = now + timedelta(minutes=int(cb.LEVEL_1_COOLDOWN) + 1)
    assert cb.can_trade(now=after) is True

    # 5th loss -> Level 2 with size multiplier reduction
    cb.register_trade_result(pnl=-100, is_win=False, now=after)
    cb.register_trade_result(pnl=-100, is_win=False, now=after)
    assert cb.get_size_multiplier() <= 0.75
    assert cb.can_trade(now=after) is False or cb.get_size_multiplier() < 1.0


def test_circuit_breaker_resets():
    cb = CircuitBreaker()
    cb.update_equity(100000.0)
    cb.register_trade_result(pnl=-100, is_win=False)
    cb.update_equity(99900.0)
    cb.reset_daily()
    assert cb.can_trade() is True
    assert cb.get_size_multiplier() == 1.0
    state = cb.get_state()
    assert state.probe_trades_remaining == 0
    assert state.probe_until is None
    assert state.cooldown_backoff == 0
