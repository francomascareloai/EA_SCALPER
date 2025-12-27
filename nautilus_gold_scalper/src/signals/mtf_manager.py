"""
Multi-Timeframe (MTF) Manager.
Coordinates analysis across multiple timeframes for confluence.

Timeframe Hierarchy:
- HTF (H1): Direction and bias
- MTF (M30): Structure and key levels
- LTF (M15): Entry timing and execution
"""

import logging
from dataclasses import dataclass
from enum import IntEnum
from typing import Any, TypeAlias, TypedDict

import numpy as np
from numpy.typing import NDArray

from ..core.definitions import MarketRegime, SignalType
from ..indicators.regime_detector import RegimeDetector
from ..indicators.structure_analyzer import MarketBias, StructureAnalyzer

PriceArray: TypeAlias = NDArray[np.floating[Any]]
TimestampArray: TypeAlias = NDArray[np.datetime64]


class OHLCData(TypedDict):
    highs: PriceArray
    lows: PriceArray
    closes: PriceArray
    timestamps: TimestampArray


logger = logging.getLogger(__name__)


class Timeframe(IntEnum):
    """Timeframe enum for MTF analysis."""

    M1 = 1
    M5 = 5
    M15 = 15
    M30 = 30
    H1 = 60
    H4 = 240
    D1 = 1440


@dataclass
class TimeframeAnalysis:
    """Analysis result for a single timeframe."""

    timeframe: Timeframe
    bias: MarketBias = MarketBias.RANGING
    regime: MarketRegime = MarketRegime.REGIME_UNKNOWN
    direction: SignalType = SignalType.SIGNAL_NONE
    strength: float = 0.0
    structure_score: float = 0.0
    has_bos: bool = False
    has_choch: bool = False
    in_premium: bool = False
    in_discount: bool = False
    is_valid: bool = False


@dataclass
class MTFState:
    """Complete multi-timeframe state."""

    # Individual timeframe analyses
    htf_analysis: TimeframeAnalysis | None = None  # H1
    mtf_analysis: TimeframeAnalysis | None = None  # M30
    ltf_analysis: TimeframeAnalysis | None = None  # M15

    # Alignment
    is_aligned: bool = False
    alignment_direction: SignalType = SignalType.SIGNAL_NONE
    alignment_strength: float = 0.0

    # Scores
    mtf_score: float = 0.0
    confluence_bonus: int = 0

    # Trade recommendation
    recommended_direction: SignalType = SignalType.SIGNAL_NONE
    entry_timeframe: Timeframe = Timeframe.M15

    diagnosis: str = ""


class MTFManager:
    """
    Multi-Timeframe Analysis Manager.

    Coordinates analysis across HTF (H1), MTF (M30), and LTF (M15)
    to identify high-probability setups with timeframe confluence.
    """

    # Default timeframe configuration
    # Defaults align with baseline: Entry=M15, Structure=M30, Direction=H1.
    DEFAULT_HTF = Timeframe.H1
    DEFAULT_MTF = Timeframe.M30
    DEFAULT_LTF = Timeframe.M15

    def __init__(
        self,
        htf: Timeframe = DEFAULT_HTF,
        mtf: Timeframe = DEFAULT_MTF,
        ltf: Timeframe = DEFAULT_LTF,
        htf_swing_strength: int = 5,
        mtf_swing_strength: int = 3,
        ltf_swing_strength: int = 2,
        htf_lookback_bars: int = 100,
        mtf_lookback_bars: int = 100,
        ltf_lookback_bars: int = 50,
        structure_point: float = 0.01,
        regime_hurst_period: int = 100,
        regime_entropy_period: int = 50,
        regime_vr_period: int = 20,
        regime_kalman_q: float = 0.01,
        regime_kalman_r: float = 0.1,
        regime_multiscale_periods: tuple[int, int, int] = (50, 100, 200),
    ):
        """
        Initialize MTF Manager.

        Args:
            htf: Higher timeframe for direction (default H1)
            mtf: Medium timeframe for structure (default M30)
            ltf: Lower timeframe for entry (default M15)
        """
        self.htf = htf
        self.mtf = mtf
        self.ltf = ltf

        # Analyzers for each timeframe
        self._structure_analyzers: dict[Timeframe, StructureAnalyzer] = {
            htf: StructureAnalyzer(
                swing_strength=htf_swing_strength,
                lookback_bars=htf_lookback_bars,
                point=structure_point,
            ),
            mtf: StructureAnalyzer(
                swing_strength=mtf_swing_strength,
                lookback_bars=mtf_lookback_bars,
                point=structure_point,
            ),
            ltf: StructureAnalyzer(
                swing_strength=ltf_swing_strength,
                lookback_bars=ltf_lookback_bars,
                point=structure_point,
            ),
        }

        self._regime_detector = RegimeDetector(
            hurst_period=regime_hurst_period,
            entropy_period=regime_entropy_period,
            vr_period=regime_vr_period,
            kalman_q=regime_kalman_q,
            kalman_r=regime_kalman_r,
            multiscale_periods=list(regime_multiscale_periods),
        )
        self._state = MTFState()

    def analyze(
        self,
        htf_data: OHLCData,
        mtf_data: OHLCData,
        ltf_data: OHLCData,
        current_price: float,
        session_ok: bool = True,
    ) -> MTFState:
        """
        Perform multi-timeframe analysis.

        Args:
            htf_data: Dict with 'highs', 'lows', 'closes' arrays for HTF
            mtf_data: Dict with 'highs', 'lows', 'closes' arrays for MTF
            ltf_data: Dict with 'highs', 'lows', 'closes' arrays for LTF
            current_price: Current market price

        Returns:
            MTFState with complete analysis
        """
        self._state = MTFState()

        # Validate inputs
        if not self._validate_data(htf_data, "HTF"):
            self._state.diagnosis = "Invalid HTF data provided"
            logger.error(self._state.diagnosis)
            return self._state

        if not self._validate_data(mtf_data, "MTF"):
            self._state.diagnosis = "Invalid MTF data provided"
            logger.error(self._state.diagnosis)
            return self._state

        if not self._validate_data(ltf_data, "LTF"):
            self._state.diagnosis = "Invalid LTF data provided"
            logger.error(self._state.diagnosis)
            return self._state

        if current_price <= 0:
            self._state.diagnosis = f"Invalid current price: {current_price}"
            logger.error(self._state.diagnosis)
            return self._state

        try:
            if not session_ok:
                self._state.diagnosis = "Session filter blocked trading"
                return self._state

            # Analyze each timeframe
            self._state.htf_analysis = self._analyze_timeframe(self.htf, htf_data, current_price)
            self._state.mtf_analysis = self._analyze_timeframe(self.mtf, mtf_data, current_price)
            self._state.ltf_analysis = self._analyze_timeframe(self.ltf, ltf_data, current_price)

            # Check alignment
            self._check_alignment()

            # Calculate scores
            self._calculate_mtf_score()

            # Generate recommendation
            self._generate_recommendation()

            logger.debug(
                f"MTF Analysis: aligned={self._state.is_aligned}, "
                f"score={self._state.mtf_score:.1f}, "
                f"direction={self._state.alignment_direction}"
            )

        except Exception as e:
            # Fail-closed: return an empty state with explicit diagnosis.
            # Callers are expected to treat any non-empty diagnosis as a hard block.
            self._state = MTFState()
            self._state.diagnosis = f"ERROR: MTF analysis failed: {type(e).__name__}: {e}"
            logger.error(self._state.diagnosis, exc_info=True)

        return self._state

    def _validate_data(self, data: OHLCData, name: str) -> bool:
        """Validate input data dictionary.

        FIX LOOKAHEAD-1: Added timestamp monotonicity checks to prevent look-ahead bias.
        """
        # BUG-IND-002: Ensure OHLC arrays are present, aligned, and deterministic.
        if not data:
            return False

        highs = data.get("highs")
        lows = data.get("lows")
        closes = data.get("closes")
        timestamps = data.get("timestamps")

        if not isinstance(highs, np.ndarray) or highs.ndim != 1 or len(highs) == 0:
            logger.warning(f"{name} highs must be a non-empty 1D numpy array")
            return False
        if not isinstance(lows, np.ndarray) or lows.ndim != 1 or len(lows) == 0:
            logger.warning(f"{name} lows must be a non-empty 1D numpy array")
            return False
        if not isinstance(closes, np.ndarray) or closes.ndim != 1 or len(closes) == 0:
            logger.warning(f"{name} closes must be a non-empty 1D numpy array")
            return False

        if not isinstance(timestamps, np.ndarray) or timestamps.ndim != 1 or len(timestamps) == 0:
            logger.warning(f"{name} timestamps must be a non-empty 1D numpy array")
            return False

        if not np.issubdtype(np.asarray(timestamps).dtype, np.datetime64):
            logger.warning(f"{name} timestamps must be np.datetime64 for deterministic semantics")
            return False

        n = len(closes)
        if len(highs) != n or len(lows) != n:
            logger.warning(
                f"{name} OHLC arrays length mismatch: highs={len(highs)} lows={len(lows)} closes={n}"
            )
            return False

        if len(timestamps) != n:
            logger.warning(
                f"{name} OHLC/timestamps length mismatch: timestamps={len(timestamps)} closes={n}"
            )
            return False

        # FIX LOOKAHEAD-1: Verify timestamps are monotonically non-decreasing
        # This prevents look-ahead bias from out-of-order bars
        if len(timestamps) > 1:
            ts_int = timestamps.view("i8")  # Convert datetime64 to int64 for comparison
            if not np.all(ts_int[1:] >= ts_int[:-1]):
                logger.warning(
                    f"{name} timestamps are not monotonically increasing - potential look-ahead bias"
                )
                return False

        return True

    def _analyze_timeframe(
        self,
        timeframe: Timeframe,
        data: OHLCData,
        current_price: float,
    ) -> TimeframeAnalysis:
        """Analyze a single timeframe."""
        analysis = TimeframeAnalysis(timeframe=timeframe)

        try:
            highs = data.get("highs", np.array([], dtype=float))
            lows = data.get("lows", np.array([], dtype=float))
            closes = data.get("closes", np.array([], dtype=float))
            timestamps = data.get("timestamps")

            if len(closes) < 20:
                return analysis

            if timestamps is None:
                raise ValueError(
                    "MTFManager requires timestamps for deterministic StructureAnalyzer"
                )

            # Structure analysis
            analyzer = self._structure_analyzers.get(timeframe)
            if analyzer:
                structure_state = analyzer.analyze(
                    highs,
                    lows,
                    closes,
                    timestamps,
                    current_price=current_price,
                )

                analysis.bias = structure_state.bias
                analysis.direction = structure_state.direction
                analysis.structure_score = structure_state.score
                analysis.has_bos = analyzer.has_recent_bos()
                analysis.has_choch = analyzer.has_recent_choch()
                analysis.in_premium = structure_state.in_premium
                analysis.in_discount = structure_state.in_discount

            # Regime analysis (only for MTF)
            if timeframe == self.mtf:
                regime_result = self._regime_detector.analyze(closes)
                analysis.regime = regime_result.regime

            # Calculate strength
            analysis.strength = self._calculate_tf_strength(analysis)
            analysis.is_valid = True

        except Exception as e:
            logger.error(f"Timeframe analysis failed for {timeframe}: {e}", exc_info=True)
            analysis.is_valid = False

        return analysis

    def _calculate_tf_strength(self, analysis: TimeframeAnalysis) -> float:
        """Calculate strength score for a timeframe."""
        strength = 0.0

        # Bias contribution
        if analysis.bias in [MarketBias.BULLISH, MarketBias.BEARISH]:
            strength += 40
        elif analysis.bias == MarketBias.TRANSITION:
            strength += 20

        # Structure score
        strength += analysis.structure_score * 0.3

        # BOS/CHoCH bonus
        if analysis.has_bos:
            strength += 15
        if analysis.has_choch:
            strength += 20

        return min(100, strength)

    def _check_alignment(self) -> None:
        """Check if all timeframes are aligned."""
        htf = self._state.htf_analysis
        mtf = self._state.mtf_analysis
        ltf = self._state.ltf_analysis

        if htf is None or mtf is None or ltf is None:
            return

        if not all([htf.is_valid, mtf.is_valid, ltf.is_valid]):
            return

        # Block if HTF and MTF are in direct opposition
        if (htf.bias == MarketBias.BULLISH and mtf.bias == MarketBias.BEARISH) or (
            htf.bias == MarketBias.BEARISH and mtf.bias == MarketBias.BULLISH
        ):
            self._state.is_aligned = False
            self._state.alignment_direction = SignalType.SIGNAL_NONE
            self._state.alignment_strength = 0.0
            self._state.diagnosis = "HTF/MTF opposite - block entries"
            return

        # Check bullish alignment
        bullish_aligned = (
            htf.bias == MarketBias.BULLISH
            and mtf.bias in [MarketBias.BULLISH, MarketBias.TRANSITION]
            and ltf.bias in [MarketBias.BULLISH, MarketBias.TRANSITION]
        )

        # Check bearish alignment
        bearish_aligned = (
            htf.bias == MarketBias.BEARISH
            and mtf.bias in [MarketBias.BEARISH, MarketBias.TRANSITION]
            and ltf.bias in [MarketBias.BEARISH, MarketBias.TRANSITION]
        )

        if bullish_aligned:
            self._state.is_aligned = True
            self._state.alignment_direction = SignalType.SIGNAL_BUY
            mtf_weight = (
                0.35 if mtf.bias == MarketBias.BULLISH else 0.25
            )  # Penalize transitional M15
            self._state.alignment_strength = (
                htf.strength * 0.35 + mtf.strength * mtf_weight + ltf.strength * 0.30
            )
        elif bearish_aligned:
            self._state.is_aligned = True
            self._state.alignment_direction = SignalType.SIGNAL_SELL
            mtf_weight = 0.35 if mtf.bias == MarketBias.BEARISH else 0.25
            self._state.alignment_strength = (
                htf.strength * 0.35 + mtf.strength * mtf_weight + ltf.strength * 0.30
            )
        else:
            self._state.is_aligned = False
            self._state.alignment_direction = SignalType.SIGNAL_NONE
            self._state.alignment_strength = 0

    def _calculate_mtf_score(self) -> None:
        """Calculate MTF confluence score."""
        score = 0.0

        htf = self._state.htf_analysis
        mtf = self._state.mtf_analysis
        ltf = self._state.ltf_analysis

        if htf is None or mtf is None or ltf is None:
            self._state.mtf_score = 0
            return

        # Base score from alignment
        if self._state.is_aligned:
            score += 50
            self._state.confluence_bonus = 15

        # HTF contribution (most important)
        if htf.is_valid:
            score += htf.strength * 0.25

        # MTF contribution
        if mtf.is_valid:
            score += mtf.strength * 0.15

        # LTF contribution
        if ltf.is_valid:
            score += ltf.strength * 0.10

        # Premium/Discount bonus
        if self._state.alignment_direction == SignalType.SIGNAL_BUY:
            if ltf.in_discount:
                score += 10
        elif self._state.alignment_direction == SignalType.SIGNAL_SELL:
            if ltf.in_premium:
                score += 10

        self._state.mtf_score = min(100, score)

    def _generate_recommendation(self) -> None:
        """Generate trade recommendation."""
        if not self._state.is_aligned:
            self._state.recommended_direction = SignalType.SIGNAL_NONE
            self._state.diagnosis = "No MTF alignment - no trade"
            return

        self._state.recommended_direction = self._state.alignment_direction
        self._state.entry_timeframe = self.ltf

        direction_str = (
            "BUY" if self._state.alignment_direction == SignalType.SIGNAL_BUY else "SELL"
        )
        self._state.diagnosis = f"MTF aligned {direction_str} | Score: {self._state.mtf_score:.0f}"

    def is_aligned(self) -> bool:
        """Check if MTF is aligned."""
        return self._state.is_aligned

    def get_direction(self) -> SignalType:
        """Get recommended direction."""
        return self._state.recommended_direction

    def get_score(self) -> float:
        """Get MTF score."""
        return self._state.mtf_score

    def reset(self) -> None:
        """Reset all internal state to avoid cross-run leakage (e.g., WFA folds)."""
        self._state = MTFState()

        for analyzer in self._structure_analyzers.values():
            analyzer.reset()

        self._regime_detector.reset()
