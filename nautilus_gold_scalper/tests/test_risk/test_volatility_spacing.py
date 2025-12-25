from nautilus_gold_scalper.src.risk.volatility_spacing import VolatilitySpacing


def test_spacing_monotonic_and_bounded() -> None:
    sp = VolatilitySpacing(min_cooldown_seconds=10.0, max_cooldown_seconds=100.0, reference_volatility=2.0)
    c0 = sp.required_cooldown_seconds(volatility=0.0)
    c1 = sp.required_cooldown_seconds(volatility=1.0)
    c2 = sp.required_cooldown_seconds(volatility=2.0)
    c3 = sp.required_cooldown_seconds(volatility=4.0)

    assert 10.0 <= c0 <= 100.0
    assert 10.0 <= c1 <= 100.0
    assert 10.0 <= c2 <= 100.0
    assert 10.0 <= c3 <= 100.0

    assert c0 <= c1 <= c2 <= c3


def test_spacing_blocks_until_cooldown_elapsed() -> None:
    sp = VolatilitySpacing(min_cooldown_seconds=10.0, max_cooldown_seconds=10.0, reference_volatility=1.0)
    # 1s after last entry with required 10s => blocked
    r1 = sp.evaluate(now_ts_ns=11_000_000_000, last_entry_ts_ns=10_000_000_000, volatility=1.0)
    assert r1.allow_entry is False
    assert r1.reason == "volatility_spacing"

    # 10s after => allowed
    r2 = sp.evaluate(now_ts_ns=20_000_000_000, last_entry_ts_ns=10_000_000_000, volatility=1.0)
    assert r2.allow_entry is True
