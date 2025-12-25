from nautilus_gold_scalper.src.risk.virtual_gate import VirtualGate, VirtualGateInput


def test_virtual_gate_temporal_contract_fail_closed_on_violation() -> None:
    gate = VirtualGate(lookback_bars=3, range_spike_multiplier=3.0)

    inp = VirtualGateInput(
        decision_ts_ns=100,
        bar_ts_ns=[90, 100, 99],
        bar_highs=[10.0, 10.0, 10.0],
        bar_lows=[9.0, 9.0, 9.0],
    )

    r = gate.evaluate(
        decision_ts_ns=inp.decision_ts_ns,
        bar_ts_ns=inp.bar_ts_ns,
        bar_highs=inp.bar_highs,
        bar_lows=inp.bar_lows,
    )

    assert r.gate_ok is False
    assert r.gate_reason == "temporal_violation"


def test_virtual_gate_is_deterministic_for_identical_inputs() -> None:
    gate = VirtualGate(lookback_bars=5, range_spike_multiplier=3.0)

    inp = VirtualGateInput(
        decision_ts_ns=100,
        bar_ts_ns=[90, 91, 92, 93, 94],
        bar_highs=[10.0, 10.0, 10.0, 10.0, 10.0],
        bar_lows=[9.0, 9.0, 9.0, 9.0, 9.0],
    )

    r1 = gate.evaluate(
        decision_ts_ns=inp.decision_ts_ns,
        bar_ts_ns=inp.bar_ts_ns,
        bar_highs=inp.bar_highs,
        bar_lows=inp.bar_lows,
    )
    r2 = gate.evaluate(
        decision_ts_ns=inp.decision_ts_ns,
        bar_ts_ns=inp.bar_ts_ns,
        bar_highs=inp.bar_highs,
        bar_lows=inp.bar_lows,
    )

    assert r1 == r2
