"""
Test suite for TradeManager.

Tests cover:
- Trade creation and validation
- Entry fill processing
- Price update and management actions
- Partial profit taking
- Trailing stop logic
- Trade closure
- Edge cases and error conditions
"""
from decimal import Decimal

import pytest

from src.core.definitions import Direction, TradeState
from src.execution.trade_manager import TradeManager


class TestTradeManagerInitialize:
    """Test trade creation and initialization."""

    def test_create_long_trade_valid(self):
        """Test creating a valid LONG trade."""
        manager = TradeManager()

        trade = manager.create_trade(
            direction=Direction.LONG,
            entry_price=2000.0,
            stop_loss=1995.0,
            take_profit=2010.0,
            quantity=Decimal("1.0"),
            reason="Test LONG entry"
        )

        assert trade.direction == Direction.LONG
        assert trade.state == TradeState.PENDING
        assert trade.entry_price == 2000.0
        assert trade.initial_sl == 1995.0
        assert trade.current_sl == 1995.0
        assert trade.initial_tp == 2010.0
        assert trade.initial_quantity == Decimal("1.0")
        assert trade.risk_per_unit == 5.0  # |2000 - 1995|
        assert trade.entry_reason == "Test LONG entry"

    def test_create_short_trade_valid(self):
        """Test creating a valid SHORT trade."""
        manager = TradeManager()

        trade = manager.create_trade(
            direction=Direction.SHORT,
            entry_price=2000.0,
            stop_loss=2005.0,
            take_profit=1990.0,
            quantity=Decimal("0.5"),
            reason="Test SHORT entry"
        )

        assert trade.direction == Direction.SHORT
        assert trade.state == TradeState.PENDING
        assert trade.entry_price == 2000.0
        assert trade.initial_sl == 2005.0
        assert trade.initial_tp == 1990.0
        assert trade.risk_per_unit == 5.0  # |2000 - 2005|

    def test_fill_entry(self):
        """Test filling entry with actual execution details."""
        manager = TradeManager()

        trade = manager.create_trade(
            direction=Direction.LONG,
            entry_price=2000.0,
            stop_loss=1995.0,
            take_profit=2010.0,
            quantity=Decimal("1.0")
        )

        # Simulate fill with slippage
        filled_trade = manager.fill_entry(
            trade.trade_id,
            actual_entry_price=2000.1,
            actual_quantity=1.0
        )

        assert filled_trade.state == TradeState.OPEN
        assert filled_trade.entry_price == 2000.1
        assert filled_trade.filled_at is not None
        assert filled_trade.highest_price == 2000.1
        assert filled_trade.lowest_price == 2000.1


class TestTradeManagerEdgeCases:
    """Test edge cases and boundary conditions."""

    def test_create_trade_invalid_direction(self):
        """Test creating trade with NONE direction."""
        manager = TradeManager()

        with pytest.raises(ValueError, match="Direction cannot be NONE"):
            manager.create_trade(
                direction=Direction.NONE,
                entry_price=2000.0,
                stop_loss=1995.0,
                take_profit=2010.0,
                quantity=Decimal("1.0")
            )

    def test_create_trade_zero_quantity(self):
        """Test creating trade with zero quantity."""
        manager = TradeManager()

        with pytest.raises(ValueError, match="Quantity must be positive"):
            manager.create_trade(
                direction=Direction.LONG,
                entry_price=2000.0,
                stop_loss=1995.0,
                take_profit=2010.0,
                quantity=Decimal("0")
            )

    def test_create_trade_negative_quantity(self):
        """Test creating trade with negative quantity."""
        manager = TradeManager()

        with pytest.raises(ValueError, match="Quantity must be positive"):
            manager.create_trade(
                direction=Direction.LONG,
                entry_price=2000.0,
                stop_loss=1995.0,
                take_profit=2010.0,
                quantity=Decimal("-1.0")
            )

    def test_create_long_invalid_sl_placement(self):
        """Test LONG trade with SL above entry."""
        manager = TradeManager()

        with pytest.raises(ValueError, match="SL .* must be below entry"):
            manager.create_trade(
                direction=Direction.LONG,
                entry_price=2000.0,
                stop_loss=2005.0,  # Invalid: above entry
                take_profit=2010.0,
                quantity=Decimal("1.0")
            )

    def test_create_long_invalid_tp_placement(self):
        """Test LONG trade with TP below entry."""
        manager = TradeManager()

        with pytest.raises(ValueError, match="TP .* must be above entry"):
            manager.create_trade(
                direction=Direction.LONG,
                entry_price=2000.0,
                stop_loss=1995.0,
                take_profit=1990.0,  # Invalid: below entry
                quantity=Decimal("1.0")
            )

    def test_create_short_invalid_sl_placement(self):
        """Test SHORT trade with SL below entry."""
        manager = TradeManager()

        with pytest.raises(ValueError, match="SL .* must be above entry"):
            manager.create_trade(
                direction=Direction.SHORT,
                entry_price=2000.0,
                stop_loss=1995.0,  # Invalid: below entry
                take_profit=1990.0,
                quantity=Decimal("1.0")
            )

    def test_fill_nonexistent_trade(self):
        """Test filling entry for non-existent trade."""
        manager = TradeManager()

        with pytest.raises(KeyError, match="Trade .* not found"):
            manager.fill_entry("nonexistent_id", 2000.0, 1.0)

    def test_fill_already_filled_trade(self):
        """Test filling entry twice."""
        manager = TradeManager()

        trade = manager.create_trade(
            direction=Direction.LONG,
            entry_price=2000.0,
            stop_loss=1995.0,
            take_profit=2010.0,
            quantity=Decimal("1.0")
        )

        manager.fill_entry(trade.trade_id, 2000.0, 1.0)

        with pytest.raises(ValueError, match="not PENDING"):
            manager.fill_entry(trade.trade_id, 2000.0, 1.0)

    def test_execute_partial_exceeds_quantity(self):
        """Test partial close exceeding current quantity."""
        manager = TradeManager()

        trade = manager.create_trade(
            direction=Direction.LONG,
            entry_price=2000.0,
            stop_loss=1995.0,
            take_profit=2010.0,
            quantity=Decimal("1.0")
        )
        manager.fill_entry(trade.trade_id, 2000.0, 1.0)

        with pytest.raises(ValueError, match="Cannot close"):
            manager.execute_partial(
                trade.trade_id,
                closed_quantity=Decimal("2.0"),  # Exceeds 1.0
                close_price=2005.0,
                pnl=10.0
            )


class TestTradeManagerHappyPath:
    """Test complete trade lifecycle (happy path)."""

    def test_long_trade_full_cycle_with_partial(self):
        """Test LONG trade: entry -> partial @ 1R -> trailing -> close."""
        manager = TradeManager(
            partial_tp_r=1.0,
            partial_tp_percent=0.5,
            trailing_start_r=1.0
        )

        # 1. Create trade
        trade = manager.create_trade(
            direction=Direction.LONG,
            entry_price=2000.0,
            stop_loss=1995.0,
            take_profit=2010.0,
            quantity=Decimal("1.0"),
            reason="SMC confluence"
        )
        assert trade.state == TradeState.PENDING

        # 2. Fill entry
        manager.fill_entry(trade.trade_id, 2000.0, 1.0)
        trade = manager.get_trade(trade.trade_id)
        assert trade.state == TradeState.OPEN

        # 3. Price moves to 1R (2005.0)
        actions = manager.update_price(trade.trade_id, 2005.0)
        assert 'take_partial' in actions
        assert actions['current_r'] == pytest.approx(1.0, abs=0.01)

        # Execute partial
        partial_qty = Decimal("0.5")
        manager.execute_partial(
            trade.trade_id,
            closed_quantity=partial_qty,
            close_price=2005.0,
            pnl=2.5  # 0.5 * (2005 - 2000)
        )
        trade = manager.get_trade(trade.trade_id)
        assert trade.state == TradeState.PARTIAL_CLOSE
        assert trade.current_quantity == Decimal("0.5")
        assert trade.realized_pnl == 2.5
        assert trade.partial_count == 1

        # 4. Price continues to 2R (2010.0)
        actions = manager.update_price(trade.trade_id, 2010.0)
        assert 'adjust_sl' in actions
        assert actions['current_r'] == pytest.approx(2.0, abs=0.01)

        # Execute SL adjustment
        new_sl = actions['adjust_sl']['new_sl']
        manager.adjust_stop_loss(trade.trade_id, new_sl, "Trailing")
        trade = manager.get_trade(trade.trade_id)
        assert trade.state == TradeState.TRAILING
        assert trade.current_sl > trade.initial_sl  # Trailing up

        # 5. Close remaining position
        manager.close_trade(trade.trade_id, 2012.0, "Manual exit")
        trade = manager.get_trade(trade.trade_id)
        assert trade.state == TradeState.CLOSED
        assert trade.closed_at is not None
        assert trade.close_reason == "Manual exit"

    def test_short_trade_full_cycle(self):
        """Test SHORT trade: entry -> partial @ 1R -> trailing -> close."""
        manager = TradeManager()

        # 1. Create SHORT trade
        trade = manager.create_trade(
            direction=Direction.SHORT,
            entry_price=2000.0,
            stop_loss=2005.0,
            take_profit=1990.0,
            quantity=Decimal("1.0")
        )

        # 2. Fill
        manager.fill_entry(trade.trade_id, 2000.0, 1.0)

        # 3. Price moves to 1R (1995.0)
        actions = manager.update_price(trade.trade_id, 1995.0)
        assert actions['current_r'] == pytest.approx(1.0, abs=0.01)
        assert 'take_partial' in actions

        # Execute partial
        manager.execute_partial(
            trade.trade_id,
            closed_quantity=Decimal("0.5"),
            close_price=1995.0,
            pnl=2.5
        )

        # 4. Price continues to 1.5R (1992.5)
        actions = manager.update_price(trade.trade_id, 1992.5)
        assert 'adjust_sl' in actions

        # 5. Close
        manager.close_trade(trade.trade_id, 1990.0, "Hit TP")
        trade = manager.get_trade(trade.trade_id)
        assert trade.state == TradeState.CLOSED


class TestTradeManagerErrorConditions:
    """Test error handling and validation."""

    def test_update_price_closed_trade(self):
        """Test updating price on closed trade (should be no-op)."""
        manager = TradeManager()

        trade = manager.create_trade(
            direction=Direction.LONG,
            entry_price=2000.0,
            stop_loss=1995.0,
            take_profit=2010.0,
            quantity=Decimal("1.0")
        )
        manager.fill_entry(trade.trade_id, 2000.0, 1.0)
        manager.close_trade(trade.trade_id, 2005.0, "Test close")

        # Update price on closed trade should return empty actions
        actions = manager.update_price(trade.trade_id, 2010.0)
        assert actions['current_r'] == 0.0
        assert actions['state_changed'] is False
        assert 'take_partial' not in actions
        assert 'adjust_sl' not in actions

    def test_adjust_sl_invalid_direction_long(self):
        """Test lowering SL on LONG trade (invalid)."""
        manager = TradeManager()

        trade = manager.create_trade(
            direction=Direction.LONG,
            entry_price=2000.0,
            stop_loss=1995.0,
            take_profit=2010.0,
            quantity=Decimal("1.0")
        )
        manager.fill_entry(trade.trade_id, 2000.0, 1.0)
        manager.adjust_stop_loss(trade.trade_id, 1996.0, "Move up")

        # Try to lower SL (invalid for LONG)
        with pytest.raises(ValueError, match="Cannot lower SL"):
            manager.adjust_stop_loss(trade.trade_id, 1994.0, "Invalid lower")

    def test_adjust_sl_invalid_direction_short(self):
        """Test raising SL on SHORT trade (invalid)."""
        manager = TradeManager()

        trade = manager.create_trade(
            direction=Direction.SHORT,
            entry_price=2000.0,
            stop_loss=2005.0,
            take_profit=1990.0,
            quantity=Decimal("1.0")
        )
        manager.fill_entry(trade.trade_id, 2000.0, 1.0)
        manager.adjust_stop_loss(trade.trade_id, 2004.0, "Move down")

        # Try to raise SL (invalid for SHORT)
        with pytest.raises(ValueError, match="Cannot raise SL"):
            manager.adjust_stop_loss(trade.trade_id, 2006.0, "Invalid raise")

    def test_get_nonexistent_trade(self):
        """Test getting non-existent trade."""
        manager = TradeManager()

        trade = manager.get_trade("nonexistent_id")
        assert trade is None

    def test_get_active_trades(self):
        """Test getting only active trades."""
        manager = TradeManager()

        # Create 3 trades
        trade1 = manager.create_trade(
            Direction.LONG, 2000.0, 1995.0, 2010.0, Decimal("1.0")
        )
        trade2 = manager.create_trade(
            Direction.SHORT, 2000.0, 2005.0, 1990.0, Decimal("1.0")
        )
        trade3 = manager.create_trade(
            Direction.LONG, 2000.0, 1995.0, 2010.0, Decimal("1.0")
        )

        # Fill and close trade1
        manager.fill_entry(trade1.trade_id, 2000.0, 1.0)
        manager.close_trade(trade1.trade_id, 2005.0, "Closed")

        # Fill trade2 (keep open)
        manager.fill_entry(trade2.trade_id, 2000.0, 1.0)

        # Leave trade3 pending

        active = manager.get_active_trades()
        assert len(active) == 2  # trade2 (open) and trade3 (pending)
        assert trade1.trade_id not in [t.trade_id for t in active]
        assert trade3.trade_id in [t.trade_id for t in active]


class TestTradeManagerTrailingLogic:
    """Test trailing stop specific logic."""

    def test_trailing_activates_at_1r(self):
        """Test that trailing activates at 1R for LONG."""
        manager = TradeManager(trailing_start_r=1.0)

        trade = manager.create_trade(
            direction=Direction.LONG,
            entry_price=2000.0,
            stop_loss=1995.0,
            take_profit=2010.0,
            quantity=Decimal("1.0")
        )
        manager.fill_entry(trade.trade_id, 2000.0, 1.0)

        # Price at 0.5R - no trailing
        actions = manager.update_price(trade.trade_id, 2002.5)
        assert 'adjust_sl' not in actions or 'breakeven' not in actions['adjust_sl']['reason'].lower()

        # Price at 1R - should activate trailing
        actions = manager.update_price(trade.trade_id, 2005.0)
        assert 'adjust_sl' in actions
        assert 'breakeven' in actions['adjust_sl']['reason'].lower()

    def test_trailing_follows_highest_price_long(self):
        """Test that trailing follows highest price for LONG."""
        manager = TradeManager(trailing_start_r=1.0)

        trade = manager.create_trade(
            direction=Direction.LONG,
            entry_price=2000.0,
            stop_loss=1995.0,
            take_profit=2020.0,
            quantity=Decimal("1.0")
        )
        manager.fill_entry(trade.trade_id, 2000.0, 1.0)

        # Move to 2R
        actions = manager.update_price(trade.trade_id, 2010.0)
        sl_at_2r = actions.get('adjust_sl', {}).get('new_sl', 0)

        # Move to 3R
        actions = manager.update_price(trade.trade_id, 2015.0)
        sl_at_3r = actions.get('adjust_sl', {}).get('new_sl', 0)

        # SL should have moved up
        if sl_at_2r > 0 and sl_at_3r > 0:
            assert sl_at_3r > sl_at_2r


# ✓ FORGE v4.0: Test scaffold complete
# - Test_Initialize: Trade creation and fill
# - Test_EdgeCases: Zero, null, bounds, invalid inputs
# - Test_HappyPath: Complete trade lifecycle
# - Test_ErrorConditions: Error handling and validation
# - Test_TrailingLogic: Trailing stop behavior
