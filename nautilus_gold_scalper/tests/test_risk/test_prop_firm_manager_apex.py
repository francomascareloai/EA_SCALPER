import pytest
from nautilus_gold_scalper.src.risk.prop_firm_manager import (
    AccountTerminatedException,
    PropFirmLimits,
    PropFirmManager,
)


class DummyStrategy:
    def __init__(self):
        self.stopped = False
        self.flattened = False
        self.config = type("Cfg", (), {"instrument_id": None})
        self.log = self

    def stop(self):
        self.stopped = True

    def close_all_positions(self, *_args, **_kwargs):
        self.flattened = True

    # Log stubs
    def critical(self, msg):  # pragma: no cover - trivial
        pass


def test_prop_firm_manager_hard_stop_on_breach():
    """Test that PropFirmManager triggers hard stop when DD limits are breached.

    H4 FIX: This test now uses percentage-based DD system (DDProtectionCalculator).
    The legacy dollar-based limits are DEPRECATED.
    DDProtectionCalculator halts trading at:
    - trailing DD >= 4% (from HWM)
    - daily DD >= 3% (from day start)
    """
    limits = PropFirmLimits(
        account_size=100_000.0,
        # Legacy limits are deprecated - DDProtectionCalculator is authoritative
        daily_loss_limit=50_000.0,  # High value to avoid legacy interference
        trailing_drawdown=50_000.0,  # High value to avoid legacy interference
    )
    mgr = PropFirmManager(limits=limits)
    s = DummyStrategy()
    mgr.set_strategy(s)
    mgr.initialize(100_000.0)

    # Simulate equity drop to trigger DDProtectionCalculator halt threshold (>= 4% trailing DD)
    # 4.5% DD = $4,500 loss from HWM of $100k
    mgr.update_equity(95_500.0)  # 4.5% trailing DD - exceeds 4% halt threshold

    # Should raise exception on breach
    with pytest.raises(AccountTerminatedException):
        mgr.can_trade()

    assert s.stopped is True
    assert s.flattened is True


def test_prop_firm_ensure_compliance_hard_stops_on_dd_protection_halt():
    limits = PropFirmLimits(
        account_size=100_000.0,
        daily_loss_limit=50_000.0,
        trailing_drawdown=50_000.0,
    )
    mgr = PropFirmManager(limits=limits)
    s = DummyStrategy()
    mgr.set_strategy(s)
    mgr.initialize(100_000.0)

    mgr.update_equity(96_000.0)

    with pytest.raises(AccountTerminatedException):
        mgr.ensure_compliance()

    assert s.stopped is True
    assert s.flattened is True
