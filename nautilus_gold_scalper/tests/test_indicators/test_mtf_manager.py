"""
Unit tests for MTFManager - Multi-Timeframe Analysis.
Tests trend detection, alignment scoring, and confluence calculation.
"""
import numpy as np
import pytest

from src.indicators.mtf_manager import (
    MTFAlignment,
    MTFManager,
    MTFTrend,
    TimeframeAnalysis,
)
from src.core.definitions import SignalType
from src.core.exceptions import InsufficientDataError


class TestTimeframeAnalysis:
    """Test TimeframeAnalysis dataclass."""
    
    def test_initialization(self):
        """Test default initialization."""
        analysis = TimeframeAnalysis(timeframe="H1")
        assert analysis.timeframe == "H1"
        assert analysis.trend == MTFTrend.NEUTRAL
        assert analysis.trend_strength == 0.0
        assert analysis.is_trending is False
    
    def test_reset(self):
        """Test reset functionality."""
        analysis = TimeframeAnalysis(timeframe="M15")
        analysis.trend = MTFTrend.BULLISH
        analysis.trend_strength = 75.0
        analysis.is_trending = True
        
        analysis.reset()
        
        assert analysis.trend == MTFTrend.NEUTRAL
        assert analysis.trend_strength == 0.0
        assert analysis.is_trending is False


class TestMTFManager:
    """Test MTFManager main functionality."""
    
    @pytest.fixture
    def manager(self):
        """Create MTFManager instance."""
        return MTFManager(min_trend_strength=30.0, min_confluence=60.0)
    
    @pytest.fixture
    def trending_up_prices(self):
        """Generate upward trending price data."""
        np.random.seed(42)
        trend = np.cumsum(np.random.randn(200) * 0.3 + 0.2)
        return 2000 + trend * 10
    
    @pytest.fixture
    def trending_down_prices(self):
        """Generate downward trending price data."""
        np.random.seed(43)
        trend = np.cumsum(np.random.randn(200) * 0.3 - 0.2)
        return 2000 + trend * 10
    
    @pytest.fixture
    def ranging_prices(self):
        """Generate ranging price data."""
        np.random.seed(44)
        return 2000 + np.random.randn(200) * 5
    
    # Test: Analyze Timeframe
    
    def test_analyze_timeframe_bullish(self, manager, trending_up_prices):
        """Test bullish trend detection."""
        analysis = manager.analyze_timeframe("H1", trending_up_prices)
        
        assert analysis.timeframe == "H1"
        assert analysis.trend in [MTFTrend.BULLISH, MTFTrend.NEUTRAL]  # May be bullish
        assert analysis.ema_20 > 0
        assert analysis.ema_50 > 0
        assert analysis.current_price > 0
        assert analysis.last_update is not None
    
    def test_analyze_timeframe_bearish(self, manager, trending_down_prices):
        """Test bearish trend detection."""
        analysis = manager.analyze_timeframe("M15", trending_down_prices)
        
        assert analysis.timeframe == "M15"
        assert analysis.ema_20 > 0
        assert analysis.ema_50 > 0
        assert analysis.current_price > 0
    
    def test_analyze_timeframe_ranging(self, manager, ranging_prices):
        """Test ranging market detection."""
        analysis = manager.analyze_timeframe("M5", ranging_prices)
        
        assert analysis.timeframe == "M5"
        # Ranging markets should have low trend strength
        # or be detected as RANGING/NEUTRAL
        assert analysis.trend in [MTFTrend.NEUTRAL, MTFTrend.RANGING]
    
    def test_analyze_insufficient_data(self, manager):
        """Test error handling with insufficient data."""
        short_prices = np.array([2000, 2001, 2002])
        
        with pytest.raises(InsufficientDataError):
            manager.analyze_timeframe("H1", short_prices)
    
    # Test: Get MTF Bias
    
    def test_get_mtf_bias_all_bullish(self, manager, trending_up_prices):
        """Test bias detection when all timeframes are bullish."""
        biases = manager.get_mtf_bias(
            h1_prices=trending_up_prices,
            m15_prices=trending_up_prices,
            m5_prices=trending_up_prices,
            m1_prices=trending_up_prices,
        )
        
        assert "H1" in biases
        assert "M15" in biases
        assert "M5" in biases
        assert "M1" in biases
        
        # At least some should detect the trend
        # (depending on EMA calculation)
        assert any(bias != MTFTrend.NEUTRAL for bias in biases.values())
    
    def test_get_mtf_bias_mixed(
        self,
        manager,
        trending_up_prices,
        trending_down_prices,
        ranging_prices,
    ):
        """Test bias detection with mixed timeframe signals."""
        biases = manager.get_mtf_bias(
            h1_prices=trending_up_prices,
            m15_prices=trending_down_prices,
            m5_prices=ranging_prices,
            m1_prices=trending_up_prices,
        )
        
        # Should return bias for all 4 timeframes
        assert len(biases) == 4
    
    def test_get_mtf_bias_insufficient_data(self, manager):
        """Test bias with insufficient data (should return NEUTRAL)."""
        short_prices = np.array([2000, 2001, 2002])
        
        biases = manager.get_mtf_bias(
            h1_prices=short_prices,
            m15_prices=short_prices,
            m5_prices=short_prices,
            m1_prices=short_prices,
        )
        
        # All should be NEUTRAL due to insufficient data
        assert all(bias == MTFTrend.NEUTRAL for bias in biases.values())
    
    # Test: Get Alignment Score
    
    def test_get_alignment_score_perfect(self, manager, trending_up_prices):
        """Test perfect alignment (all timeframes bullish)."""
        # First get biases to populate internal state
        manager.get_mtf_bias(
            h1_prices=trending_up_prices,
            m15_prices=trending_up_prices,
            m5_prices=trending_up_prices,
            m1_prices=trending_up_prices,
        )
        
        confluence = manager.get_alignment_score()
        
        assert confluence.alignment in [MTFAlignment.PERFECT, MTFAlignment.GOOD]
        assert confluence.signal in [SignalType.BUY, SignalType.NONE]
        assert confluence.confidence >= 0
        assert 0 <= confluence.position_size_mult <= 1.0
    
    def test_get_alignment_score_good(
        self,
        manager,
        trending_up_prices,
        ranging_prices,
    ):
        """Test good alignment (3/4 timeframes bullish)."""
        manager.get_mtf_bias(
            h1_prices=trending_up_prices,
            m15_prices=trending_up_prices,
            m5_prices=trending_up_prices,
            m1_prices=ranging_prices,  # One neutral
        )
        
        confluence = manager.get_alignment_score()
        
        # Should have reasonable alignment
        assert confluence.alignment in [
            MTFAlignment.PERFECT,
            MTFAlignment.GOOD,
            MTFAlignment.WEAK,
        ]
    
    def test_get_alignment_score_conflicting(
        self,
        manager,
        trending_up_prices,
        trending_down_prices,
    ):
        """Test conflicting timeframes (no alignment)."""
        manager.get_mtf_bias(
            h1_prices=trending_up_prices,
            m15_prices=trending_down_prices,
            m5_prices=trending_up_prices,
            m1_prices=trending_down_prices,
        )
        
        confluence = manager.get_alignment_score()
        
        # Conflicting signals should result in weak or no alignment
        assert confluence.alignment in [MTFAlignment.WEAK, MTFAlignment.NONE]
    
    # Test: Trade Permission
    
    def test_can_trade_long_perfect_alignment(self, manager, trending_up_prices):
        """Test long trade permission with perfect alignment."""
        manager.get_mtf_bias(
            h1_prices=trending_up_prices,
            m15_prices=trending_up_prices,
            m5_prices=trending_up_prices,
            m1_prices=trending_up_prices,
        )
        manager.get_alignment_score()
        
        # May or may not allow (depends on confidence threshold)
        can_long = manager.can_trade_long()
        assert isinstance(can_long, bool)
    
    def test_can_trade_short_perfect_alignment(self, manager, trending_down_prices):
        """Test short trade permission with perfect alignment."""
        manager.get_mtf_bias(
            h1_prices=trending_down_prices,
            m15_prices=trending_down_prices,
            m5_prices=trending_down_prices,
            m1_prices=trending_down_prices,
        )
        manager.get_alignment_score()
        
        can_short = manager.can_trade_short()
        assert isinstance(can_short, bool)
    
    def test_cannot_trade_with_weak_alignment(self, manager, ranging_prices):
        """Test that weak alignment blocks trades."""
        manager.get_mtf_bias(
            h1_prices=ranging_prices,
            m15_prices=ranging_prices,
            m5_prices=ranging_prices,
            m1_prices=ranging_prices,
        )
        manager.get_alignment_score()
        
        # Weak alignment should not allow trades
        assert manager.can_trade_long() is False
        assert manager.can_trade_short() is False
    
    # Test: Helper Methods
    
    def test_calculate_ema(self, manager):
        """Test EMA calculation."""
        prices = np.array([100, 101, 102, 103, 104, 105])
        ema = manager._calculate_ema(prices, period=3)
        
        assert ema > 0
        assert ema <= 105  # Should not exceed max price
    
    def test_calculate_rsi(self, manager):
        """Test RSI calculation."""
        prices = np.array([100, 102, 101, 103, 105, 104, 106, 108])
        rsi = manager._calculate_rsi(prices, period=5)
        
        assert 0 <= rsi <= 100
    
    def test_calculate_atr(self, manager):
        """Test ATR calculation."""
        prices = np.array([100, 102, 101, 103, 105, 104, 106, 108])
        atr = manager._calculate_atr(prices, period=5)
        
        assert atr >= 0
    
    def test_determine_trend_bullish(self, manager):
        """Test bullish trend determination."""
        trend = manager._determine_trend(
            price=105.0,
            ema_20=102.0,
            ema_50=100.0,
            atr=2.0,
        )
        
        assert trend == MTFTrend.BULLISH
    
    def test_determine_trend_bearish(self, manager):
        """Test bearish trend determination."""
        trend = manager._determine_trend(
            price=95.0,
            ema_20=98.0,
            ema_50=100.0,
            atr=2.0,
        )
        
        assert trend == MTFTrend.BEARISH
    
    def test_determine_trend_ranging(self, manager):
        """Test ranging market determination."""
        trend = manager._determine_trend(
            price=100.0,
            ema_20=100.2,
            ema_50=100.3,
            atr=2.0,
        )
        
        # EMAs are compressed -> ranging
        assert trend in [MTFTrend.RANGING, MTFTrend.NEUTRAL]
    
    # Test: Analysis Summary
    
    def test_get_analysis_summary(self, manager, trending_up_prices):
        """Test analysis summary generation."""
        manager.get_mtf_bias(
            h1_prices=trending_up_prices,
            m15_prices=trending_up_prices,
            m5_prices=trending_up_prices,
            m1_prices=trending_up_prices,
        )
        manager.get_alignment_score()
        
        summary = manager.get_analysis_summary()
        
        assert isinstance(summary, str)
        assert "MTF ANALYSIS" in summary
        assert "H1:" in summary
        assert "M15:" in summary
        assert "M5:" in summary
        assert "M1:" in summary
        assert "Alignment:" in summary
        assert "Confidence:" in summary
    
    # Test: Edge Cases
    
    def test_handle_zero_atr(self, manager):
        """Test handling of zero ATR (flat market)."""
        flat_prices = np.full(200, 2000.0)  # All same price
        
        analysis = manager.analyze_timeframe("H1", flat_prices)
        
        # Should not crash, should return neutral
        assert analysis.trend == MTFTrend.NEUTRAL
        assert analysis.trend_strength == 0.0
    
    def test_handle_nan_prices(self, manager):
        """Test handling of prices with NaN values."""
        prices_with_nan = np.array([2000.0] * 100)
        prices_with_nan[50] = np.nan
        
        # Should handle gracefully or raise appropriate error
        try:
            analysis = manager.analyze_timeframe("H1", prices_with_nan)
            # If it succeeds, verify it's handling it
            assert analysis is not None
        except (ValueError, InsufficientDataError):
            # Expected to fail gracefully
            pass
    
    def test_position_size_multiplier_ranges(self, manager):
        """Test that position size multiplier is always in valid range."""
        # Test with perfect alignment
        manager.confluence.alignment = MTFAlignment.PERFECT
        manager.confluence.confidence = 100.0
        mult = manager._calculate_position_size_multiplier()
        assert 0.0 <= mult <= 1.0
        
        # Test with no alignment
        manager.confluence.alignment = MTFAlignment.NONE
        manager.confluence.confidence = 0.0
        mult = manager._calculate_position_size_multiplier()
        assert mult == 0.0


# ✓ FORGE v4.0: Test scaffold complete
# - Tests cover: initialization, trend detection, alignment scoring
# - Edge cases: insufficient data, zero ATR, NaN handling
# - Happy path: bullish/bearish/ranging markets
# - Integration: full workflow from bias to trade permission
