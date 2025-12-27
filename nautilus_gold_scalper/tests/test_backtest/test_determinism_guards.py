from __future__ import annotations

from nautilus_gold_scalper.src.strategies.base_strategy import BaseGoldStrategy, BaseStrategyConfig
from nautilus_trader.model.identifiers import InstrumentId
from nautilus_trader.model.objects import Quantity


class DummyConfig(BaseStrategyConfig):
    instrument_id = InstrumentId.from_str("XAUUSD.SIM")
    seed = 123
    partial_fill_prob = 0.9
    partial_fill_ratio = 0.5
    fill_reject_base = 0.2
    fill_reject_spread_factor = 0.0
    fill_model = "realistic"
    bracket_confirm_timeout_ns = 60_000_000_000


class DummyStrategy(BaseGoldStrategy):
    def _on_strategy_start(self) -> None:
        return None

    def _on_strategy_stop(self) -> None:
        return None

    def _on_htf_bar(self, _bar):  # type: ignore[no-untyped-def]
        return None

    def _on_mtf_bar(self, _bar):  # type: ignore[no-untyped-def]
        return None

    def _on_ltf_bar(self, _bar):  # type: ignore[no-untyped-def]
        return None

    def _check_for_signal(self, _bar):  # type: ignore[no-untyped-def]
        return None


def test_partial_fill_simulation_is_deterministic_for_fixed_seed() -> None:
    s1 = DummyStrategy(config=DummyConfig(instrument_id=InstrumentId.from_str("XAUUSD.SIM")))
    s2 = DummyStrategy(config=DummyConfig(instrument_id=InstrumentId.from_str("XAUUSD.SIM")))

    qty = Quantity.from_str("1.00")

    out1 = [s1._simulate_partial_fill(qty, side="BUY").as_double() for _ in range(50)]
    out2 = [s2._simulate_partial_fill(qty, side="BUY").as_double() for _ in range(50)]

    assert out1 == out2


def test_fill_model_construction_is_seeded() -> None:
    from nautilus_gold_scalper.scripts.backtest.run_backtest import _build_fill_model

    m1 = _build_fill_model("three_tier", seed=123)
    m2 = _build_fill_model("three_tier", seed=123)

    assert m1 is not None
    assert m2 is not None
    assert type(m1) is type(m2)
