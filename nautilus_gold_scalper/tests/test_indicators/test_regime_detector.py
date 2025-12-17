import numpy as np
import pytest

from src.core.exceptions import InsufficientDataError
from src.indicators.regime_detector import RegimeDetector


class TestRegimeDetector:
    def test_trending_market_detection(self):
        rd = RegimeDetector()
        np.random.seed(42)
        trend = np.cumsum(np.random.randn(300) * 0.5 + 0.1)
        prices = 1900 + trend

        result = rd.analyze(prices)
        assert result.is_valid
        assert result.hurst_exponent > 0.5

    def test_mean_reverting_detection(self):
        rd = RegimeDetector()
        np.random.seed(42)
        prices = [1900.0]
        theta = 0.3
        mu = 1900.0
        sigma = 5.0
        for _ in range(299):
            dp = theta * (mu - prices[-1]) + sigma * np.random.randn()
            prices.append(prices[-1] + dp)

        result = rd.analyze(np.array(prices))
        assert result.is_valid
        assert result.hurst_exponent < 0.55

    def test_insufficient_data_raises(self):
        rd = RegimeDetector()
        prices = np.array([1900, 1901, 1902])
        with pytest.raises(InsufficientDataError):
            rd.analyze(prices)
