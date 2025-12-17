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
    limits = PropFirmLimits(
        account_size=100_000.0,
        daily_loss_limit=1_000.0,
        trailing_drawdown=1_000.0,
    )
    mgr = PropFirmManager(limits=limits)
    s = DummyStrategy()
    mgr.set_strategy(s)
    mgr.initialize(100_000.0)

    # Simulate equity drop beyond trailing DD
    mgr.update_equity(98_900.0)  # DD = 1,100 > 1,000

    # Should raise exception on breach
    with pytest.raises(AccountTerminatedException):
        mgr.can_trade()

    assert s.stopped is True
    assert s.flattened is True
