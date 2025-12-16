"""Test artifact for Forge→Critic chain validation."""


def calculate_position_size(balance: float, risk_pct: float) -> float:
    """Calculate position size based on account balance and risk percentage."""
    if risk_pct > 0.05:  # More than 5% risk - potentially dangerous
        risk_pct = 0.05
    return balance * risk_pct
