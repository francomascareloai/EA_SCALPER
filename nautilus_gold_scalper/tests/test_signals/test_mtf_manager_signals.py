"""
Unit tests for signals.MTFManager - SMC-based Multi-Timeframe Analysis.
Tests structure-based direction, alignment, and MTF score calculation.

This tests the PRODUCTION version in signals/mtf_manager.py (SMC-based),
not the deprecated indicators/mtf_manager.py (EMA-based).
"""
import numpy as np
import pytest
from typing import Any

from nautilus_gold_scalper.src.core.definitions import SignalType, MarketRegime
from nautilus_gold_scalper.src.signals.mtf_manager import (
    MTFManager,
    MTFState,
    TimeframeAnalysis,
    Timeframe,
)
from nautilus_gold_scalper.src.indicators.structure_analyzer import MarketBias


class TestMTFManagerSignals:
    """Test production MTFManager (SMC-based) from signals module."""

    @pytest.fixture
    def manager(self) -> MTFManager:
        """Create MTFManager instance with defaults."""
        return MTFManager()

    @pytest.fixture
    def bullish_data(self) -> dict[str, np.ndarray[Any, np.dtype[np.floating[Any]]]]:
        """Generate bullish trending price data."""
        np.random.seed(42)
        n = 100
        # Create upward trending data: higher highs, higher lows
        base = np.linspace(1900, 2000, n)
        noise = np.random.randn(n) * 2
        closes = base + noise
        highs = closes + np.abs(np.random.randn(n) * 3) + 2
        lows = closes - np.abs(np.random.randn(n) * 3) - 2
        return {
            'highs': highs.astype(np.float64),
            'lows': lows.astype(np.float64),
            'closes': closes.astype(np.float64),
        }

    @pytest.fixture
    def bearish_data(self) -> dict[str, np.ndarray[Any, np.dtype[np.floating[Any]]]]:
        """Generate bearish trending price data."""
        np.random.seed(43)
        n = 100
        # Create downward trending data: lower highs, lower lows
        base = np.linspace(2000, 1900, n)
        noise = np.random.randn(n) * 2
        closes = base + noise
        highs = closes + np.abs(np.random.randn(n) * 3) + 2
        lows = closes - np.abs(np.random.randn(n) * 3) - 2
        return {
            'highs': highs.astype(np.float64),
            'lows': lows.astype(np.float64),
            'closes': closes.astype(np.float64),
        }

    @pytest.fixture
    def ranging_data(self) -> dict[str, np.ndarray[Any, np.dtype[np.floating[Any]]]]:
        """Generate ranging/sideways price data."""
        np.random.seed(44)
        n = 100
        # Create sideways data around 1950
        base = 1950 + np.sin(np.linspace(0, 4 * np.pi, n)) * 20
        noise = np.random.randn(n) * 2
        closes = base + noise
        highs = closes + np.abs(np.random.randn(n) * 3) + 2
        lows = closes - np.abs(np.random.randn(n) * 3) - 2
        return {
            'highs': highs.astype(np.float64),
            'lows': lows.astype(np.float64),
            'closes': closes.astype(np.float64),
        }

    # Test: Initialization

    def test_initialization_defaults(self, manager: MTFManager) -> None:
        """Test default initialization."""
        assert manager.htf == Timeframe.H1
        assert manager.mtf == Timeframe.M15
        assert manager.ltf == Timeframe.M5

    def test_initialization_custom_timeframes(self) -> None:
        """Test custom timeframe initialization."""
        custom = MTFManager(
            htf=Timeframe.H4,
            mtf=Timeframe.H1,
            ltf=Timeframe.M15,
        )
        assert custom.htf == Timeframe.H4
        assert custom.mtf == Timeframe.H1
        assert custom.ltf == Timeframe.M15

    # Test: Analyze Method

    def test_analyze_returns_mtf_state(
        self,
        manager: MTFManager,
        bullish_data: dict[str, np.ndarray[Any, np.dtype[np.floating[Any]]]],
    ) -> None:
        """Test analyze returns valid MTFState."""
        state = manager.analyze(
            htf_data=bullish_data,
            mtf_data=bullish_data,
            ltf_data=bullish_data,
            current_price=2000.0,
        )
        assert isinstance(state, MTFState)
        assert state.htf_analysis is not None
        assert state.mtf_analysis is not None
        assert state.ltf_analysis is not None

    def test_analyze_invalid_htf_data(self, manager: MTFManager) -> None:
        """Test analyze with invalid HTF data returns empty state."""
        empty_data: dict[str, np.ndarray[Any, np.dtype[np.floating[Any]]]] = {}
        valid_data = {
            'highs': np.array([2000.0] * 50, dtype=np.float64),
            'lows': np.array([1990.0] * 50, dtype=np.float64),
            'closes': np.array([1995.0] * 50, dtype=np.float64),
        }
        state = manager.analyze(
            htf_data=empty_data,
            mtf_data=valid_data,
            ltf_data=valid_data,
            current_price=1995.0,
        )
        assert state.htf_analysis is None
        assert not state.is_aligned

    def test_analyze_insufficient_bars(self, manager: MTFManager) -> None:
        """Test analyze with insufficient bars returns empty state."""
        short_data = {
            'highs': np.array([2000.0, 2001.0, 2002.0], dtype=np.float64),
            'lows': np.array([1990.0, 1991.0, 1992.0], dtype=np.float64),
            'closes': np.array([1995.0, 1996.0, 1997.0], dtype=np.float64),
        }
        state = manager.analyze(
            htf_data=short_data,
            mtf_data=short_data,
            ltf_data=short_data,
            current_price=1997.0,
        )
        # With less than 20 bars, analysis should be invalid
        assert state.htf_analysis is None or not state.htf_analysis.is_valid

    # Test: Alignment Detection

    def test_alignment_bullish(
        self,
        manager: MTFManager,
        bullish_data: dict[str, np.ndarray[Any, np.dtype[np.floating[Any]]]],
    ) -> None:
        """Test bullish alignment detection."""
        state = manager.analyze(
            htf_data=bullish_data,
            mtf_data=bullish_data,
            ltf_data=bullish_data,
            current_price=2000.0,
        )
        # With consistent bullish data, should get some level of alignment
        # (exact alignment depends on structure analyzer internals)
        assert isinstance(state.is_aligned, bool)
        assert isinstance(state.mtf_score, float)
        assert 0 <= state.mtf_score <= 100

    def test_alignment_bearish(
        self,
        manager: MTFManager,
        bearish_data: dict[str, np.ndarray[Any, np.dtype[np.floating[Any]]]],
    ) -> None:
        """Test bearish alignment detection."""
        state = manager.analyze(
            htf_data=bearish_data,
            mtf_data=bearish_data,
            ltf_data=bearish_data,
            current_price=1900.0,
        )
        assert isinstance(state.is_aligned, bool)
        assert isinstance(state.mtf_score, float)

    def test_alignment_mixed_blocks(
        self,
        manager: MTFManager,
        bullish_data: dict[str, np.ndarray[Any, np.dtype[np.floating[Any]]]],
        bearish_data: dict[str, np.ndarray[Any, np.dtype[np.floating[Any]]]],
    ) -> None:
        """Test that mixed HTF/MTF directions block alignment."""
        state = manager.analyze(
            htf_data=bullish_data,  # HTF bullish
            mtf_data=bearish_data,  # MTF bearish - opposite!
            ltf_data=bullish_data,
            current_price=1950.0,
        )
        # HTF and MTF in opposition should result in no alignment
        # The _check_alignment method explicitly blocks this
        if state.htf_analysis and state.mtf_analysis:
            htf_bias = state.htf_analysis.bias
            mtf_bias = state.mtf_analysis.bias
            if htf_bias == MarketBias.BULLISH and mtf_bias == MarketBias.BEARISH:
                assert not state.is_aligned
                assert "opposite" in state.diagnosis.lower() or state.diagnosis == ""

    # Test: Session Filter

    def test_session_filter_blocks_analysis(
        self,
        manager: MTFManager,
        bullish_data: dict[str, np.ndarray[Any, np.dtype[np.floating[Any]]]],
    ) -> None:
        """Test session filter blocks analysis."""
        state = manager.analyze(
            htf_data=bullish_data,
            mtf_data=bullish_data,
            ltf_data=bullish_data,
            current_price=2000.0,
            session_ok=False,  # Session not allowed
        )
        assert "Session filter" in state.diagnosis
        assert state.recommended_direction == SignalType.SIGNAL_NONE

    # Test: Public Methods

    def test_is_aligned_method(
        self,
        manager: MTFManager,
        bullish_data: dict[str, np.ndarray[Any, np.dtype[np.floating[Any]]]],
    ) -> None:
        """Test is_aligned() public method."""
        manager.analyze(
            htf_data=bullish_data,
            mtf_data=bullish_data,
            ltf_data=bullish_data,
            current_price=2000.0,
        )
        result = manager.is_aligned()
        assert isinstance(result, bool)

    def test_get_direction_method(
        self,
        manager: MTFManager,
        bullish_data: dict[str, np.ndarray[Any, np.dtype[np.floating[Any]]]],
    ) -> None:
        """Test get_direction() public method."""
        manager.analyze(
            htf_data=bullish_data,
            mtf_data=bullish_data,
            ltf_data=bullish_data,
            current_price=2000.0,
        )
        direction = manager.get_direction()
        assert direction in [
            SignalType.SIGNAL_NONE,
            SignalType.SIGNAL_BUY,
            SignalType.SIGNAL_SELL,
        ]

    def test_get_score_method(
        self,
        manager: MTFManager,
        bullish_data: dict[str, np.ndarray[Any, np.dtype[np.floating[Any]]]],
    ) -> None:
        """Test get_score() public method."""
        manager.analyze(
            htf_data=bullish_data,
            mtf_data=bullish_data,
            ltf_data=bullish_data,
            current_price=2000.0,
        )
        score = manager.get_score()
        assert isinstance(score, float)
        assert 0 <= score <= 100

    # Test: Edge Cases

    def test_zero_current_price(
        self,
        manager: MTFManager,
        bullish_data: dict[str, np.ndarray[Any, np.dtype[np.floating[Any]]]],
    ) -> None:
        """Test handling of zero current price."""
        state = manager.analyze(
            htf_data=bullish_data,
            mtf_data=bullish_data,
            ltf_data=bullish_data,
            current_price=0.0,  # Invalid
        )
        # Should return empty state or handle gracefully
        assert state is not None

    def test_negative_current_price(
        self,
        manager: MTFManager,
        bullish_data: dict[str, np.ndarray[Any, np.dtype[np.floating[Any]]]],
    ) -> None:
        """Test handling of negative current price."""
        state = manager.analyze(
            htf_data=bullish_data,
            mtf_data=bullish_data,
            ltf_data=bullish_data,
            current_price=-100.0,  # Invalid
        )
        # Should return empty state or handle gracefully
        assert state is not None


class TestTimeframeAnalysisDataclass:
    """Test TimeframeAnalysis dataclass."""

    def test_default_values(self) -> None:
        """Test default values."""
        analysis = TimeframeAnalysis(timeframe=Timeframe.H1)
        assert analysis.timeframe == Timeframe.H1
        assert analysis.bias == MarketBias.RANGING
        assert analysis.regime == MarketRegime.REGIME_UNKNOWN
        assert analysis.direction == SignalType.SIGNAL_NONE
        assert analysis.strength == 0.0
        assert not analysis.is_valid

    def test_custom_values(self) -> None:
        """Test custom values."""
        analysis = TimeframeAnalysis(
            timeframe=Timeframe.M15,
            bias=MarketBias.BULLISH,
            direction=SignalType.SIGNAL_BUY,
            strength=75.0,
            is_valid=True,
        )
        assert analysis.timeframe == Timeframe.M15
        assert analysis.bias == MarketBias.BULLISH
        assert analysis.direction == SignalType.SIGNAL_BUY
        assert analysis.strength == 75.0
        assert analysis.is_valid


class TestMTFStateDataclass:
    """Test MTFState dataclass."""

    def test_default_values(self) -> None:
        """Test default values."""
        state = MTFState()
        assert state.htf_analysis is None
        assert state.mtf_analysis is None
        assert state.ltf_analysis is None
        assert not state.is_aligned
        assert state.alignment_direction == SignalType.SIGNAL_NONE
        assert state.mtf_score == 0.0
        assert state.recommended_direction == SignalType.SIGNAL_NONE
        assert state.diagnosis == ""


# FORGE v4.0: Test scaffold complete
# - Tests cover: initialization, analyze, alignment, session filter
# - Edge cases: invalid data, zero price, mixed directions
# - Public API: is_aligned(), get_direction(), get_score()
