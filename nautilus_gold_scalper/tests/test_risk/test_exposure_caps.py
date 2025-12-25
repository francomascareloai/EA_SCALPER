from nautilus_gold_scalper.src.risk.exposure_caps import ExposureCaps


def test_exposure_caps_blocks_when_max_positions_reached() -> None:
    caps = ExposureCaps(max_concurrent_positions=1, max_concurrent_instruments=1)
    r = caps.evaluate(open_positions_count=1, open_instruments_count=1)
    assert r.allow_entry is False
    assert r.reason == "max_concurrent_positions"


def test_exposure_caps_allows_when_below_caps() -> None:
    caps = ExposureCaps(max_concurrent_positions=2, max_concurrent_instruments=1)
    r = caps.evaluate(open_positions_count=0, open_instruments_count=0)
    assert r.allow_entry is True
    assert r.reason is None
