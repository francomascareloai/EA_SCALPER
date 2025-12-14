"""
Multi-Timeframe (MTF) Manager.
Coordinates analysis across multiple timeframes for confluence.

Timeframe Hierarchy:
- HTF (H1): Direction and bias
- MTF (M15): Structure and key levels
- LTF (M5): Entry timing and execution
"""
import logging
import numpy as np
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, field
from datetime import datetime
from enum import IntEnum

logger = logging.getLogger(__name__)

from ..core.definitions import SignalType, MarketRegime, TradingSession
from ..indicators.structure_analyzer import StructureAnalyzer, MarketBias, StructureState
from ..indicators.regime_detector import RegimeDetector


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
    htf_analysis: Optional[TimeframeAnalysis] = None  # H1
    mtf_analysis: Optional[TimeframeAnalysis] = None  # M15
    ltf_analysis: Optional[TimeframeAnalysis] = None  # M5
    
    # Alignment
    is_aligned: bool = False
    alignment_direction: SignalType = SignalType.SIGNAL_NONE
    alignment_strength: float = 0.0
    
    # Scores
    mtf_score: float = 0.0
    confluence_bonus: int = 0
    
    # Trade recommendation
    recommended_direction: SignalType = SignalType.SIGNAL_NONE
    entry_timeframe: Timeframe = Timeframe.M5
    
    diagnosis: str = ""


class MTFManager:
    """
    Multi-Timeframe Analysis Manager.
    
    Coordinates analysis across HTF (H1), MTF (M15), and LTF (M5)
    to identify high-probability setups with timeframe confluence.
    """
    
    # Default timeframe configuration
    DEFAULT_HTF = Timeframe.H1
    DEFAULT_MTF = Timeframe.M15
    DEFAULT_LTF = Timeframe.M5
    
    def __init__(
        self,
        htf: Timeframe = DEFAULT_HTF,
        mtf: Timeframe = DEFAULT_MTF,
        ltf: Timeframe = DEFAULT_LTF,
    ):
        """
        Initialize MTF Manager.
        
        Args:
            htf: Higher timeframe for direction (default H1)
            mtf: Medium timeframe for structure (default M15)
            ltf: Lower timeframe for entry (default M5)
        """
        self.htf = htf
        self.mtf = mtf
        self.ltf = ltf
        
        # Analyzers for each timeframe
        self._structure_analyzers: Dict[Timeframe, StructureAnalyzer] = {
            htf: StructureAnalyzer(swing_strength=5, lookback_bars=100),
            mtf: StructureAnalyzer(swing_strength=3, lookback_bars=100),
            ltf: StructureAnalyzer(swing_strength=2, lookback_bars=50),
        }
        
        self._regime_detector = RegimeDetector()
        self._state = MTFState()
    
    def analyze(
        self,
        htf_data: Dict[str, np.ndarray],
        mtf_data: Dict[str, np.ndarray],
        ltf_data: Dict[str, np.ndarray],
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
            logger.error("Invalid HTF data provided")
            return self._state
        
        if not self._validate_data(mtf_data, "MTF"):
            logger.error("Invalid MTF data provided")
            return self._state
        
        if not self._validate_data(ltf_data, "LTF"):
            logger.error("Invalid LTF data provided")
            return self._state
        
        if current_price <= 0:
            logger.error(f"Invalid current price: {current_price}")
            return self._state
        
        try:
            if not session_ok:
                self._state.diagnosis = "Session filter blocked trading"
                return self._state

            # Analyze each timeframe
            self._state.htf_analysis = self._analyze_timeframe(
                self.htf, htf_data, current_price
            )
            self._state.mtf_analysis = self._analyze_timeframe(
                self.mtf, mtf_data, current_price
            )
            self._state.ltf_analysis = self._analyze_timeframe(
                self.ltf, ltf_data, current_price
            )
            
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
            logger.error(f"MTF analysis failed: {e}", exc_info=True)
            self._state = MTFState()  # Return empty state on error
        
        return self._state
    
    def _validate_data(self, data: Dict[str, np.ndarray], name: str) -> bool:
        """Validate input data dictionary."""
        if not data:
            return False
        
        required_keys = ['highs', 'lows', 'closes']
        for key in required_keys:
            if key not in data:
                logger.warning(f"{name} data missing key: {key}")
                return False
            
            if not isinstance(data[key], np.ndarray):
                logger.warning(f"{name} {key} is not a numpy array")
                return False
            
            if len(data[key]) == 0:
                logger.warning(f"{name} {key} is empty")
                return False
        
        return True
    
    def _analyze_timeframe(
        self,
        timeframe: Timeframe,
        data: Dict[str, np.ndarray],
        current_price: float,
    ) -> TimeframeAnalysis:
        """Analyze a single timeframe."""
        analysis = TimeframeAnalysis(timeframe=timeframe)
        
        try:
            highs = data.get('highs', np.array([]))
            lows = data.get('lows', np.array([]))
            closes = data.get('closes', np.array([]))
            
            if len(closes) < 20:
                return analysis
            
            # Structure analysis
            analyzer = self._structure_analyzers.get(timeframe)
            if analyzer:
                structure_state = analyzer.analyze(highs, lows, closes, current_price=current_price)
                
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
    
    def _check_alignment(self):
        """Check if all timeframes are aligned."""
        htf = self._state.htf_analysis
        mtf = self._state.mtf_analysis
        ltf = self._state.ltf_analysis
        
        if not all([htf, mtf, ltf]):
            return
        
        if not all([htf.is_valid, mtf.is_valid, ltf.is_valid]):
            return
        
        # Block if HTF and MTF are in direct opposition
        if (htf.bias == MarketBias.BULLISH and mtf.bias == MarketBias.BEARISH) or \
           (htf.bias == MarketBias.BEARISH and mtf.bias == MarketBias.BULLISH):
            self._state.is_aligned = False
            self._state.alignment_direction = SignalType.SIGNAL_NONE
            self._state.alignment_strength = 0.0
            self._state.diagnosis = "HTF/MTF opposite - block entries"
            return
        
        # Check bullish alignment
        bullish_aligned = (
            htf.bias == MarketBias.BULLISH and
            mtf.bias in [MarketBias.BULLISH, MarketBias.TRANSITION] and
            ltf.bias in [MarketBias.BULLISH, MarketBias.TRANSITION]
        )
        
        # Check bearish alignment
        bearish_aligned = (
            htf.bias == MarketBias.BEARISH and
            mtf.bias in [MarketBias.BEARISH, MarketBias.TRANSITION] and
            ltf.bias in [MarketBias.BEARISH, MarketBias.TRANSITION]
        )
        
        if bullish_aligned:
            self._state.is_aligned = True
            self._state.alignment_direction = SignalType.SIGNAL_BUY
            mtf_weight = 0.35 if mtf.bias == MarketBias.BULLISH else 0.25  # Penalize transitional M15
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
    
    def _calculate_mtf_score(self):
        """Calculate MTF confluence score."""
        score = 0.0
        
        htf = self._state.htf_analysis
        mtf = self._state.mtf_analysis
        ltf = self._state.ltf_analysis
        
        if not all([htf, mtf, ltf]):
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
    
    def _generate_recommendation(self):
        """Generate trade recommendation."""
        if not self._state.is_aligned:
            self._state.recommended_direction = SignalType.SIGNAL_NONE
            self._state.diagnosis = "No MTF alignment - no trade"
            return
        
        self._state.recommended_direction = self._state.alignment_direction
        self._state.entry_timeframe = self.ltf
        
        direction_str = "BUY" if self._state.alignment_direction == SignalType.SIGNAL_BUY else "SELL"
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
