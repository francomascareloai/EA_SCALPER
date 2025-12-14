"""
Tests for PropFirmManager.
"""
import pytest
from datetime import datetime
from src.risk.prop_firm_manager import (
    PropFirmManager,
    PropFirmLimits,
    RiskLevel,
    AccountTerminatedException,
)


class TestPropFirmManager:
    """Test suite for PropFirmManager."""
    
    def test_initial_state_allows_trading(self):
        """Trading should be allowed after initialization."""
        pfm = PropFirmManager()
        pfm.initialize(100_000)
        
        assert pfm.can_trade() is True
        state = pfm.get_state()
        assert state.is_trading_allowed is True
        assert state.risk_level == RiskLevel.NORMAL
    
    def test_daily_limit_blocks_trading(self):
        """Trading should be blocked when daily loss exceeds limit."""
        limits = PropFirmLimits(
            account_size=100_000,
            daily_loss_limit=3_000,  # 3%
        )
        pfm = PropFirmManager(limits=limits)
        pfm.initialize(100_000)
        
        # Simulate loss exceeding daily limit
        pfm.update_equity(96_500)  # -$3,500 (> $3,000 limit)
        
        # Should raise exception on breach
        with pytest.raises(AccountTerminatedException):
            pfm.can_trade()
        
        state = pfm.get_state()
        assert state.risk_level == RiskLevel.BREACHED
        assert state.is_hard_breached is True
    
    def test_trailing_dd_blocks_trading(self):
        """Trading should be blocked when trailing DD exceeds limit."""
        limits = PropFirmLimits(
            account_size=100_000,
            trailing_drawdown=3_000,
        )
        pfm = PropFirmManager(limits=limits)
        pfm.initialize(100_000)
        
        # Simulate profit then loss
        pfm.update_equity(105_000)  # New high
        pfm.update_equity(101_500)  # -$3,500 from high
        
        # Should raise exception on breach
        with pytest.raises(AccountTerminatedException):
            pfm.can_trade()
        
        state = pfm.get_state()
        assert state.trailing_dd_current == 3_500
    
    def test_validate_trade_respects_contract_limit(self):
        """Should reject trade exceeding max contracts."""
        limits = PropFirmLimits(max_contracts=20)
        pfm = PropFirmManager(limits=limits)
        pfm.initialize(100_000)
        
        # Try to add 25 contracts
        allowed, reason = pfm.validate_trade(500, 25)
        
        assert allowed is False
        assert "contracts" in reason.lower()
    
    def test_validate_trade_respects_risk_limit(self):
        """Should reject trade exceeding daily risk limit."""
        limits = PropFirmLimits(daily_loss_limit=3_000, buffer_pct=0.1)
        pfm = PropFirmManager(limits=limits)
        pfm.initialize(100_000)
        
        # Already lost some
        pfm.update_equity(98_000)  # -$2,000
        
        # Try to add $2,000 more risk (would exceed $2,700 effective limit)
        allowed, reason = pfm.validate_trade(2_000, 5)
        
        assert allowed is False
        assert "daily limit" in reason.lower()
    
    def test_consecutive_streaks_updated(self):
        """Win/loss streaks should be updated on trade close."""
        pfm = PropFirmManager()
        pfm.initialize(100_000)
        
        # Simulate 3 wins
        pfm.register_trade_close(1, 100)
        pfm.register_trade_close(1, 150)
        pfm.register_trade_close(1, 200)
        
        state = pfm.get_state()
        assert state.consecutive_wins == 3
        assert state.consecutive_losses == 0
        
        # One loss resets
        pfm.register_trade_close(1, -50)
        state = pfm.get_state()
        assert state.consecutive_wins == 0
        assert state.consecutive_losses == 1
    
    def test_max_risk_available(self):
        """Should correctly calculate available risk."""
        limits = PropFirmLimits(
            daily_loss_limit=3_000,
            trailing_drawdown=3_000,
            buffer_pct=0.1,  # 10% buffer
        )
        pfm = PropFirmManager(limits=limits)
        pfm.initialize(100_000)
        
        # No losses yet - should have $2,700 available (90% of $3,000)
        available = pfm.get_max_risk_available()
        assert abs(available - 2_700) < 1
        
        # After $1,000 loss
        pfm.update_equity(99_000)
        available = pfm.get_max_risk_available()
        assert abs(available - 1_700) < 1
    
    def test_risk_levels(self):
        """Risk levels should escalate with drawdown."""
        limits = PropFirmLimits(daily_loss_limit=3_000, buffer_pct=0.1)
        pfm = PropFirmManager(limits=limits)
        pfm.initialize(100_000)
        
        # 40% of limit = NORMAL
        pfm.update_equity(98_800)  # -$1,200
        assert pfm.get_state().risk_level == RiskLevel.NORMAL
        
        # 55% of limit = ELEVATED
        pfm.update_equity(98_350)  # -$1,650
        assert pfm.get_state().risk_level == RiskLevel.ELEVATED
        
        # 75% of limit = HIGH
        pfm.update_equity(97_750)  # -$2,250
        assert pfm.get_state().risk_level == RiskLevel.HIGH
        
        # 95% of limit = CRITICAL (blocks trading)
        pfm.update_equity(97_150)  # -$2,850
        assert pfm.get_state().risk_level == RiskLevel.CRITICAL
        
        # Should raise exception when breached
        with pytest.raises(AccountTerminatedException):
            pfm.can_trade()
    
    def test_momentum_adjustment_factor(self):
        """Momentum factor should adjust based on streaks."""
        pfm = PropFirmManager()
        pfm.initialize(100_000)
        
        # No streak
        assert pfm.get_momentum_adjustment_factor() == 1.0
        
        # 2 wins
        pfm.register_trade_close(1, 100)
        pfm.register_trade_close(1, 100)
        assert pfm.get_momentum_adjustment_factor() == 1.08
        
        # Reset and create losing streak
        pfm.register_trade_close(1, -100)
        pfm.register_trade_close(1, -100)
        assert pfm.get_momentum_adjustment_factor() == 0.70  # -30% after 2 losses


class TestPropFirmLimits:
    """Test PropFirmLimits defaults."""
    
    def test_default_apex_limits(self):
        """Default limits should match Apex $100k account."""
        limits = PropFirmLimits()
        
        assert limits.account_size == 100_000
        assert limits.daily_loss_limit == 3_000  # 3%
        assert limits.trailing_drawdown == 3_000
        assert limits.max_contracts == 20
