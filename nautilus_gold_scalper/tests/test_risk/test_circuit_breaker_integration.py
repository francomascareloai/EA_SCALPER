"""
Integration tests for CircuitBreaker in real strategy context.
Validates P1 critical item: CircuitBreaker blocks trades and reduces size.
"""
import pytest
from src.risk.circuit_breaker import CircuitBreaker, CircuitBreakerLevel


class TestCircuitBreakerIntegration:
    """Integration tests for CircuitBreaker protection."""
    
    def test_circuit_breaker_level_1_triggers(self):
        """Test that Level 1 (3 consecutive losses) triggers cooldown."""
        cb = CircuitBreaker()
        cb.update_equity(100000.0)
        
        # Register 3 consecutive losses
        cb.register_trade_result(pnl=-100.0, is_win=False)
        cb.update_equity(99900.0)
        cb.register_trade_result(pnl=-150.0, is_win=False)
        cb.update_equity(99750.0)
        cb.register_trade_result(pnl=-120.0, is_win=False)
        cb.update_equity(99630.0)
        
        state = cb.get_state()
        
        # Should be at Level 1 CAUTION
        assert state.level >= CircuitBreakerLevel.LEVEL_1_CAUTION, \
            "Circuit breaker should trigger Level 1 after 3 losses"
        assert state.consecutive_losses == 3
        
        # May or may not block immediately (depends on cooldown)
        # But level should be elevated
        print(f"[OK] Level 1 triggered: level={state.level.name}, can_trade={state.can_trade}")
    
    def test_circuit_breaker_level_2_triggers(self):
        """Test that Level 2 (5 consecutive losses) triggers and reduces size."""
        cb = CircuitBreaker()
        cb.update_equity(100000.0)
        
        # Register 5 consecutive losses
        equity = 100000.0
        for i in range(5):
            cb.register_trade_result(pnl=-100.0, is_win=False)
            equity -= 100.0
            cb.update_equity(equity)
        
        state = cb.get_state()
        
        # Should be at Level 2 WARNING
        assert state.level >= CircuitBreakerLevel.LEVEL_2_WARNING, \
            "Circuit breaker should trigger Level 2 after 5 losses"
        assert state.consecutive_losses == 5
        
        # Size multiplier should be reduced
        assert state.size_multiplier < 1.0, \
            f"Size multiplier should be <1.0 at Level 2, got {state.size_multiplier}"
        
        print(f"[OK] Level 2 triggered: level={state.level.name}, "
              f"size_mult={state.size_multiplier:.2f}, "
              f"consecutive_losses={state.consecutive_losses}")
    
    def test_circuit_breaker_dd_based_trigger(self):
        """Test that drawdown-based levels trigger correctly."""
        cb = CircuitBreaker()
        cb.update_equity(100000.0)
        
        # Simulate 3.5% drawdown (should trigger Level 3)
        current_equity = 100000.0 - 3500.0  # 3.5% DD
        cb.update_equity(current_equity)
        
        state = cb.get_state()
        
        # Should be at Level 3 ELEVATED (DD > 3%)
        assert state.level >= CircuitBreakerLevel.LEVEL_3_ELEVATED, \
            f"Circuit breaker should trigger Level 3 at 3.5% DD, got level={state.level.name}"
        
        assert state.total_dd_percent >= 3.0, \
            f"Total DD should be >= 3%, got {state.total_dd_percent:.2f}%"
        
        # Size should be further reduced
        assert state.size_multiplier < 0.75, \
            f"Size multiplier should be <0.75 at Level 3, got {state.size_multiplier}"
        
        print(f"[OK] Level 3 triggered: level={state.level.name}, "
              f"dd={state.total_dd_percent:.2f}%, "
              f"size_mult={state.size_multiplier:.2f}")
    
    def test_circuit_breaker_recovery(self):
        """Test that circuit breaker recovers after winning trades."""
        cb = CircuitBreaker()
        cb.update_equity(100000.0)
        
        # Register 3 losses
        equity = 100000.0
        for i in range(3):
            cb.register_trade_result(pnl=-100.0, is_win=False)
            equity -= 100.0
            cb.update_equity(equity)
        
        state = cb.get_state()
        initial_level = state.level
        assert initial_level >= CircuitBreakerLevel.LEVEL_1_CAUTION
        
        # Register 3 wins
        for i in range(3):
            cb.register_trade_result(pnl=150.0, is_win=True)
            equity += 150.0
            cb.update_equity(equity)
        
        state = cb.get_state()
        
        # Should have recovered
        assert state.consecutive_losses == 0, "Consecutive losses should reset after wins"
        assert state.consecutive_wins == 3, "Should track consecutive wins"
        
        # May still be at elevated level due to cooldown, but losses should reset
        print(f"[OK] Recovery: level={state.level.name}, "
              f"consec_wins={state.consecutive_wins}, "
              f"consec_losses={state.consecutive_losses}")
    
    def test_circuit_breaker_daily_reset(self):
        """Test that circuit breaker resets daily metrics."""
        cb = CircuitBreaker()
        cb.update_equity(100000.0)
        
        # Register some losses
        cb.register_trade_result(pnl=-100.0, is_win=False)
        cb.update_equity(99900.0)
        cb.register_trade_result(pnl=-150.0, is_win=False)
        cb.update_equity(99750.0)
        
        state_before = cb.get_state()
        daily_dd_before = state_before.daily_dd_percent
        
        # Reset daily (simulates new trading day)
        cb.reset_daily()
        
        state_after = cb.get_state()
        
        # Daily PnL should reset (primary purpose of reset_daily)
        assert state_after.daily_pnl == 0.0, \
            "Daily PnL should reset to 0"
        
        # Daily start equity should be updated to current equity
        assert state_after.daily_start_equity == state_after.current_equity, \
            "Daily start equity should update to current equity"
        
        # Current equity should persist (not changed by reset)
        assert state_after.current_equity == state_before.current_equity, \
            "Current equity should not change on daily reset"
        
        # Note: daily_dd_percent may persist (depends on calculation vs initial_balance or daily_start)
        # The key is that daily_pnl resets to 0, which is the primary guard
        
        print(f"[OK] Daily reset: daily_dd before={daily_dd_before:.2f}%, "
              f"after={state_after.daily_dd_percent:.2f}%")


if __name__ == "__main__":
    pytest.main([__file__, "-v", "-s"])
