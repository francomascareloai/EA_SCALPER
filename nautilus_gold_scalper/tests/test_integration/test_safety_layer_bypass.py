from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone

from nautilus_gold_scalper.src.risk.exposure_caps import ExposureCaps
from nautilus_gold_scalper.src.risk.news_guard import NewsGuard
from nautilus_gold_scalper.src.risk.time_constraint_manager import TimeConstraintManager
from nautilus_gold_scalper.src.risk.unified_risk_policy import UnifiedRiskPolicy
from nautilus_gold_scalper.src.risk.virtual_gate import VirtualGate, VirtualGateInput
from nautilus_gold_scalper.src.risk.volatility_spacing import VolatilitySpacing
from nautilus_gold_scalper.src.signals.news_calendar import NewsTradeAction, NewsWindow


@dataclass
class _FakeConfig:
    instrument_id: object = "XAU/USD.SIM"


class _FakeCache:
    def __init__(self, *, open_positions: int = 1) -> None:
        self._open_positions = int(open_positions)

    def positions_open(self) -> list[object]:
        return [object() for _ in range(self._open_positions)]


class _FakeLog:
    def __init__(self) -> None:
        self.warnings: list[str] = []

    def warning(self, msg: str) -> None:
        self.warnings.append(str(msg))

    def error(self, msg: str) -> None:
        self.warnings.append(str(msg))


class _FakeStrategy:
    def __init__(self, *, open_positions: int = 1) -> None:
        self.config = _FakeConfig()
        self.cache = _FakeCache(open_positions=open_positions)
        self.log = _FakeLog()
        self._is_trading_allowed = True
        self._trading_blocked_today = False
        self.cancel_calls: int = 0
        self.close_all_calls: int = 0

    def cancel_all_orders(self, instrument_id: object) -> None:
        _ = instrument_id
        self.cancel_calls += 1

    def close_all_positions(self, instrument_id: object, reduce_only: bool = False) -> None:
        _ = instrument_id
        _ = reduce_only
        self.close_all_calls += 1

    def close_position(self, position_id: object, reduce_only: bool = False) -> None:
        _ = position_id
        _ = reduce_only
        self.close_all_calls += 1


def _ns(dt: datetime) -> int:
    return int(dt.replace(tzinfo=timezone.utc).timestamp() * 1_000_000_000)


def test_c1_force_close_bypasses_entry_gates_cutoff() -> None:
    """C1: Force-close must be possible even if news/time gates would block entries."""
    strat = _FakeStrategy(open_positions=1)
    mgr = TimeConstraintManager(strategy=strat)

    # 21:59 UTC is 16:59 ET (cutoff). check() must force-close.
    ts_ns = _ns(datetime(2024, 11, 1, 21, 59, 0, tzinfo=timezone.utc))
    allowed = mgr.check(ts_ns)

    assert allowed is False
    assert strat.close_all_calls == 1
    assert strat._is_trading_allowed is False
    assert strat._trading_blocked_today is True


def test_c2_dd_breach_bypasses_entry_gates_flatten_still_possible() -> None:
    """C2: DD breach -> no new entries, but flatten logic must remain possible (via prop firm/time manager)."""
    exposure = ExposureCaps(max_concurrent_positions=1, max_concurrent_instruments=1)
    spacing = VolatilitySpacing(min_cooldown_seconds=10.0, max_cooldown_seconds=300.0, reference_volatility=1.0)
    vg = VirtualGate(lookback_bars=20, range_spike_multiplier=3.0)
    policy = UnifiedRiskPolicy(
        exposure_caps=exposure,
        news_guard=NewsGuard(),
        volatility_spacing=spacing,
        virtual_gate=vg,
    )

    decision = policy.evaluate_entry(
        time_gate_ok=True,
        blocked_today=True,  # simulates DD halt day
        prop_firm_ok=False,  # simulates DD hard breach
        circuit_ok=False,
        must_flatten=True,
        open_positions_count=0,
        open_instruments_count=0,
        news_window=NewsWindow(in_window=True, action=NewsTradeAction.BLOCK, reason="dd_test"),
        now_utc=datetime(2024, 11, 1, 12, 0, 0, tzinfo=timezone.utc),
        last_entry_ts_ns=1,
        now_ts_ns=2,
        volatility=2.0,
        virtual_gate_input=VirtualGateInput(
            decision_ts_ns=2,
            bar_ts_ns=list(range(1, 21)),
            bar_highs=[10.0] * 20,
            bar_lows=[9.5] * 20,
        ),
        base_size_factor=1.0,
    )

    assert decision.must_flatten is True
    assert decision.can_open_new is False
    # NOTE: size_factor is for *entries* only; when must_flatten=True it is not used by flatten logic.
    assert 0.0 <= decision.size_factor <= 1.0


def test_c3_precedence_most_restrictive_wins_entries() -> None:
    """C3: Entry gates compose with 'most restrictive wins' and must_flatten dominates."""
    exposure = ExposureCaps(max_concurrent_positions=1, max_concurrent_instruments=1)
    spacing = VolatilitySpacing(min_cooldown_seconds=60.0, max_cooldown_seconds=300.0, reference_volatility=1.0)
    vg = VirtualGate(lookback_bars=20, range_spike_multiplier=3.0)

    policy = UnifiedRiskPolicy(
        exposure_caps=exposure,
        news_guard=NewsGuard(),
        volatility_spacing=spacing,
        virtual_gate=vg,
    )

    decision = policy.evaluate_entry(
        time_gate_ok=False,  # blocks entry
        blocked_today=False,
        prop_firm_ok=True,
        circuit_ok=True,
        must_flatten=False,
        open_positions_count=1,  # hits max_concurrent_positions
        open_instruments_count=0,
        news_window=None,
        now_utc=datetime(2024, 11, 1, 12, 0, 0, tzinfo=timezone.utc),
        last_entry_ts_ns=1,
        now_ts_ns=2,
        volatility=1.0,
        virtual_gate_input=VirtualGateInput(
            decision_ts_ns=2,
            bar_ts_ns=list(range(1, 21)),
            bar_highs=[10.0] * 20,
            bar_lows=[9.5] * 20,
        ),
        base_size_factor=1.0,
    )

    assert decision.can_open_new is False
    assert "time_gate_entry" in decision.reasons
    assert "max_concurrent_positions" in decision.reasons

    must_flatten_decision = policy.evaluate_entry(
        time_gate_ok=True,
        blocked_today=False,
        prop_firm_ok=True,
        circuit_ok=True,
        must_flatten=True,
        open_positions_count=0,
        open_instruments_count=0,
        news_window=None,
        now_utc=datetime(2024, 11, 1, 12, 0, 0, tzinfo=timezone.utc),
        last_entry_ts_ns=None,
        now_ts_ns=None,
        volatility=None,
        virtual_gate_input=None,
        base_size_factor=1.0,
    )

    assert must_flatten_decision.must_flatten is True
    assert must_flatten_decision.can_open_new is False
