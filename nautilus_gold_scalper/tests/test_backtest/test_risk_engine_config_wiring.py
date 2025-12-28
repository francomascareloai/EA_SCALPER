from __future__ import annotations


def test_risk_engine_config_from_cfg_supports_rate_and_notional_map() -> None:
    from nautilus_gold_scalper.scripts.backtest.run_backtest import _risk_engine_config_from_cfg

    cfg = {
        "risk_engine": {
            "max_order_submit_rate": "10/00:00:01",
            "max_order_modify_rate": "5/00:00:01",
            "max_notional_per_order": {"XAU/USD.SIM": 50_000},
        }
    }

    rec = _risk_engine_config_from_cfg(cfg, instrument_id="XAU/USD.SIM")
    assert rec.bypass is False
    assert rec.max_order_submit_rate == "10/00:00:01"
    assert rec.max_order_modify_rate == "5/00:00:01"
    assert rec.max_notional_per_order == {"XAU/USD.SIM": 50_000}


def test_risk_engine_config_from_cfg_supports_notional_shorthand() -> None:
    from nautilus_gold_scalper.scripts.backtest.run_backtest import _risk_engine_config_from_cfg

    cfg = {"risk_engine": {"max_notional_per_order": 25_000}}

    rec = _risk_engine_config_from_cfg(cfg, instrument_id="XAU/USD.SIM")
    assert rec.bypass is False
    assert rec.max_notional_per_order == {"XAU/USD.SIM": 25_000}


def test_risk_engine_config_from_cfg_leaves_modify_rate_default_when_omitted() -> None:
    from nautilus_gold_scalper.scripts.backtest.run_backtest import _risk_engine_config_from_cfg

    cfg = {"risk_engine": {"max_order_submit_rate": "10/00:00:01"}}

    rec = _risk_engine_config_from_cfg(cfg, instrument_id="XAU/USD.SIM")
    assert rec.max_order_submit_rate == "10/00:00:01"
    # Should remain Nautilus default unless explicitly set.
    assert rec.max_order_modify_rate == "100/00:00:01"


def test_risk_engine_config_from_cfg_rejects_negative_notional() -> None:
    from nautilus_gold_scalper.scripts.backtest.run_backtest import _risk_engine_config_from_cfg

    cfg = {"risk_engine": {"max_notional_per_order": -1}}

    try:
        _risk_engine_config_from_cfg(cfg, instrument_id="XAU/USD.SIM")
    except ValueError as exc:
        assert ">= 0" in str(exc)
    else:  # pragma: no cover
        raise AssertionError("Expected ValueError")


def test_risk_engine_config_from_cfg_rejects_invalid_modify_rate_type() -> None:
    from nautilus_gold_scalper.scripts.backtest.run_backtest import _risk_engine_config_from_cfg

    cfg = {"risk_engine": {"max_order_modify_rate": 123}}

    try:
        _risk_engine_config_from_cfg(cfg, instrument_id="XAU/USD.SIM")
    except ValueError as exc:
        assert "max_order_modify_rate" in str(exc)
    else:  # pragma: no cover
        raise AssertionError("Expected ValueError")
