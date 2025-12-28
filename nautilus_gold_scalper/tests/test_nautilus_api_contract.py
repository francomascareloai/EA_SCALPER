"""Phase 0: verify NautilusTrader API contracts we depend on.

Goal: fail fast if the installed NautilusTrader version changes its signatures/constraints.

We intentionally validate against BOTH:
- The installed package in `.venv` (what actually runs in this repo).
- The local `external/nautilus_trader` source tree (preferred doc/source of truth).
"""

from __future__ import annotations

from pathlib import Path


def _repo_root() -> Path:
    # tests/ -> nautilus_gold_scalper/ -> repo root
    return Path(__file__).resolve().parents[2]


def test_risk_engine_config_fields_match_expected() -> None:
    from nautilus_trader.risk.config import RiskEngineConfig

    cfg = RiskEngineConfig()
    assert hasattr(cfg, "bypass")
    assert hasattr(cfg, "max_order_submit_rate")
    assert hasattr(cfg, "max_order_modify_rate")
    assert hasattr(cfg, "max_notional_per_order")
    assert hasattr(cfg, "debug")


def test_actor_publish_signal_restricts_value_types() -> None:
    # Verified in external source: actor.pyx enforces int/float/str.
    actor_pyx = (
        _repo_root() / "external" / "nautilus_trader" / "nautilus_trader" / "common" / "actor.pyx"
    )
    assert actor_pyx.exists(), f"Missing expected file: {actor_pyx}"

    text = actor_pyx.read_text(encoding="utf-8")
    assert "publish_signal" in text
    assert "Condition.is_in(type(value), (int, float, str)" in text


def test_actor_persistence_contract_is_bytes_dict() -> None:
    # Verified in external source: actor.pxd defines on_save/on_load contract.
    actor_pxd = (
        _repo_root() / "external" / "nautilus_trader" / "nautilus_trader" / "common" / "actor.pxd"
    )
    assert actor_pxd.exists(), f"Missing expected file: {actor_pxd}"

    text = actor_pxd.read_text(encoding="utf-8")
    assert "cpdef dict[str, bytes] on_save" in text
    assert "cpdef void on_load(self, dict[str, bytes] state" in text


def test_trader_add_exec_algorithm_exists_and_has_guardrails() -> None:
    from nautilus_trader.trading.trader import Trader

    assert hasattr(Trader, "add_exec_algorithm")

    trader_py = (
        _repo_root() / "external" / "nautilus_trader" / "nautilus_trader" / "trading" / "trader.py"
    )
    assert trader_py.exists(), f"Missing expected file: {trader_py}"

    text = trader_py.read_text(encoding="utf-8")
    assert "def add_exec_algorithm" in text
    assert "Cannot add an execution algorithm to a running trader" in text


def test_twap_example_requires_exec_algorithm_params() -> None:
    # Guardrail: TWAP algorithm requires exec_algorithm_params with horizon/interval.
    twap_py = (
        _repo_root()
        / "external"
        / "nautilus_trader"
        / "nautilus_trader"
        / "examples"
        / "algorithms"
        / "twap.py"
    )
    assert twap_py.exists(), f"Missing expected file: {twap_py}"

    text = twap_py.read_text(encoding="utf-8")
    assert "horizon_secs" in text
    assert "interval_secs" in text


def test_repo_uses_risk_engine_config_import_path() -> None:
    # Sanity check that our repo imports the same RiskEngineConfig we validate.
    run_backtest = (
        _repo_root() / "nautilus_gold_scalper" / "scripts" / "backtest" / "run_backtest.py"
    )
    assert run_backtest.exists()

    text = run_backtest.read_text(encoding="utf-8")
    assert (
        "from nautilus_trader.config import BacktestEngineConfig, LoggingConfig, RiskEngineConfig"
        in text
    )
