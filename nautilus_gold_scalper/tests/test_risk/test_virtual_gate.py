from nautilus_gold_scalper.src.risk.virtual_gate import VirtualGate, VirtualGateInput


def test_virtual_gate_temporal_contract_fail_closed_on_violation() -> None:
    gate = VirtualGate(
        lookback_bars=3,
        range_spike_multiplier=3.0,
        fail_open_on_insufficient_history=False,
    )

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
    gate = VirtualGate(
        lookback_bars=5,
        range_spike_multiplier=3.0,
        fail_open_on_insufficient_history=False,
    )

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


def test_virtual_gate_blocks_on_turbulence_cluster() -> None:
    gate = VirtualGate(
        lookback_bars=10,
        range_spike_multiplier=10.0,  # disable single-bar spike for this test
        cluster_spike_multiplier=2.0,
        cluster_max_fraction=0.30,
        fail_open_on_insufficient_history=False,
    )

    # 10 bars: median range=1.0; 4 bars have range=3.0 => 40% > 30% => block.
    ranges = [1.0, 1.0, 1.0, 1.0, 1.0, 3.0, 3.0, 3.0, 3.0, 1.0]
    highs = [10.0 + r for r in ranges]
    lows = [10.0 for _ in ranges]

    r = gate.evaluate(
        decision_ts_ns=200,
        bar_ts_ns=list(range(100, 110)),
        bar_highs=highs,
        bar_lows=lows,
    )

    assert r.gate_ok is False
    assert r.gate_reason == "turbulence_cluster"


def test_virtual_gate_rejects_non_monotonic_timestamps() -> None:
    gate = VirtualGate(lookback_bars=5, fail_open_on_insufficient_history=False)

    r = gate.evaluate(
        decision_ts_ns=200,
        bar_ts_ns=[100, 101, 101, 103, 104],
        bar_highs=[11.0, 11.0, 11.0, 11.0, 11.0],
        bar_lows=[10.0, 10.0, 10.0, 10.0, 10.0],
    )

    assert r.gate_ok is False
    assert r.gate_reason == "non_monotonic_ts"


def test_virtual_gate_rejects_invalid_bar_range() -> None:
    gate = VirtualGate(lookback_bars=3, fail_open_on_insufficient_history=False)

    r = gate.evaluate(
        decision_ts_ns=200,
        bar_ts_ns=[100, 101, 102],
        bar_highs=[10.0, 9.0, 10.0],
        bar_lows=[9.0, 10.0, 9.0],
    )

    assert r.gate_ok is False
    assert r.gate_reason == "invalid_bar_range"


def test_virtual_gate_fail_open_on_insufficient_history() -> None:
    gate = VirtualGate(lookback_bars=5, fail_open_on_insufficient_history=True)

    r = gate.evaluate(
        decision_ts_ns=200,
        bar_ts_ns=[100, 101, 102, 103],
        bar_highs=[11.0, 11.0, 11.0, 11.0],
        bar_lows=[10.0, 10.0, 10.0, 10.0],
    )

    assert r.gate_ok is True
