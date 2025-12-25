from nautilus_gold_scalper.src.risk.unified_risk_policy import RiskDecision, UnifiedRiskPolicy


def test_must_flatten_wins_over_can_open_new() -> None:
    d = RiskDecision(can_open_new=True, must_flatten=True)
    assert d.must_flatten is True
    assert d.can_open_new is False


def test_size_factor_is_clamped_to_0_1() -> None:
    assert RiskDecision(size_factor=-1.0).size_factor == 0.0
    assert RiskDecision(size_factor=2.0).size_factor == 1.0


def test_policy_returns_cannot_open_if_any_reason_present() -> None:
    policy = UnifiedRiskPolicy()
    d = policy.evaluate_entry(time_gate_ok=False)
    assert d.can_open_new is False
    assert "time_gate_entry" in d.reasons
