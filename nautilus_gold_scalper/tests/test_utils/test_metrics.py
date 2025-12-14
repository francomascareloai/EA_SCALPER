"""Tests for performance metrics calculator."""
import pytest
from nautilus_gold_scalper.src.utils.metrics import MetricsCalculator, PerformanceMetrics


def test_metrics_calculator_basic():
    """Test basic metrics calculation."""
    calculator = MetricsCalculator(risk_free_rate=0.05)
    
    # Simple profit sequence: 10 trades, 6 wins, 4 losses
    pnl_series = [100, 150, -50, 200, -75, 125, -60, 180, -40, 110]
    
    metrics = calculator.calculate(
        pnl_series=pnl_series,
        initial_balance=100000.0
    )
    
    assert isinstance(metrics, PerformanceMetrics)
    assert metrics.num_trades == 10
    assert metrics.num_wins == 6
    assert metrics.num_losses == 4
    assert metrics.win_rate == 60.0
    assert metrics.total_pnl == sum(pnl_series)
    assert metrics.sharpe_ratio > 0
    assert metrics.sortino_ratio > 0
    assert metrics.calmar_ratio > 0
    assert metrics.sqn > 0


def test_metrics_calculator_all_wins():
    """Test metrics with all winning trades."""
    calculator = MetricsCalculator()
    pnl_series = [100, 150, 200, 125, 180]
    
    metrics = calculator.calculate(pnl_series, initial_balance=100000.0)
    
    assert metrics.win_rate == 100.0
    assert metrics.num_wins == 5
    assert metrics.num_losses == 0
    assert metrics.profit_factor == float('inf')  # No losses
    assert metrics.avg_loss == 0.0


def test_metrics_calculator_all_losses():
    """Test metrics with all losing trades."""
    calculator = MetricsCalculator()
    pnl_series = [-50, -75, -60, -40, -90]
    
    metrics = calculator.calculate(pnl_series, initial_balance=100000.0)
    
    assert metrics.win_rate == 0.0
    assert metrics.num_wins == 0
    assert metrics.num_losses == 5
    assert metrics.profit_factor == 0.0  # No wins
    assert metrics.avg_win == 0.0
    assert metrics.total_pnl < 0


def test_metrics_calculator_empty():
    """Test metrics with no trades."""
    calculator = MetricsCalculator()
    pnl_series = []
    
    metrics = calculator.calculate(pnl_series, initial_balance=100000.0)
    
    assert metrics.num_trades == 0
    assert metrics.win_rate == 0.0
    assert metrics.total_pnl == 0.0
    assert metrics.sharpe_ratio == 0.0
    assert metrics.sqn == 0.0


def test_metrics_calculator_high_sharpe():
    """Test metrics with consistent profitable trades (high Sharpe)."""
    calculator = MetricsCalculator()
    # Consistent wins with low volatility
    pnl_series = [100] * 20  # 20 trades, $100 each
    
    metrics = calculator.calculate(pnl_series, initial_balance=100000.0)
    
    assert metrics.win_rate == 100.0
    assert metrics.sharpe_ratio > 10  # Very high Sharpe
    assert metrics.std_dev < 0.001  # Very low volatility
    assert metrics.sqn > 4  # Excellent system quality


def test_metrics_max_drawdown():
    """Test max drawdown calculation."""
    calculator = MetricsCalculator()
    # Start with wins, then big loss
    pnl_series = [1000, 1000, 1000, -2500, 500]
    
    metrics = calculator.calculate(pnl_series, initial_balance=100000.0)
    
    # Max DD should capture the -2500 loss after 3k profit
    assert metrics.max_drawdown_pct > 2.0  # At least 2% DD
    assert metrics.calmar_ratio > 0


def test_metrics_profit_factor():
    """Test profit factor calculation."""
    calculator = MetricsCalculator()
    # Gross profit = 600, Gross loss = 200
    pnl_series = [100, 200, 300, -50, -100, -50]
    
    metrics = calculator.calculate(pnl_series, initial_balance=100000.0)
    
    assert metrics.profit_factor == 3.0  # 600 / 200 = 3.0
    assert metrics.num_wins == 3
    assert metrics.num_losses == 3


def test_metrics_to_dict():
    """Test metrics serialization to dict."""
    calculator = MetricsCalculator()
    pnl_series = [100, -50, 150, -75, 200]
    
    metrics = calculator.calculate(pnl_series, initial_balance=100000.0)
    metrics_dict = metrics.to_dict()
    
    assert isinstance(metrics_dict, dict)
    assert 'sharpe_ratio' in metrics_dict
    assert 'sortino_ratio' in metrics_dict
    assert 'calmar_ratio' in metrics_dict
    assert 'sqn' in metrics_dict
    assert 'win_rate' in metrics_dict
    assert 'total_pnl' in metrics_dict
    
    # Check rounding
    assert isinstance(metrics_dict['sharpe_ratio'], (int, float))
    assert isinstance(metrics_dict['num_trades'], int)


def test_metrics_sqn_interpretation():
    """Test SQN (System Quality Number) with known values."""
    calculator = MetricsCalculator()
    
    # Good system: consistent profits
    pnl_series = [50] * 100  # 100 trades, $50 each
    metrics = calculator.calculate(pnl_series, initial_balance=100000.0)
    assert metrics.sqn > 7  # Holy Grail (SQN > 7)
    
    # Poor system: inconsistent
    pnl_series = [200, -150, 180, -160, 220, -170]
    metrics = calculator.calculate(pnl_series, initial_balance=100000.0)
    assert metrics.sqn < 2  # Below average (SQN < 2)


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
