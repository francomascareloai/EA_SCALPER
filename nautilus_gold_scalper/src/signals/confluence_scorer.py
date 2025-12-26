"""
Confluence Scorer - Central signal scoring system.
Combines all analysis components into a unified confluence score.

Score Tiers:
- S (90-100): Elite setup, full position
- A (80-89): High quality, standard position
- B (70-79): Tradeable, reduced position
- C (60-69): Marginal, minimal position
- Invalid (<60): No trade

GENIUS v4.0+ Features:
- Session-specific factor weights (v4.2)
- Phase 1 multipliers: alignment, freshness, divergence (v4.1)
- ICT 7-step sequential confirmation (v4.0)
"""

import logging
from dataclasses import dataclass

from ..core.data_types import (
    AMDCycle,
    ConfluenceResult,
    FairValueGap,
    LiquiditySweep,
    OrderBlock,
    RegimeAnalysis,
    SessionInfo,
)
from ..core.definitions import (
    BONUS_HIGH_CONFLUENCE,
    MIN_VALID_SCORE,
    PENALTY_RANDOM_WALK,
    TIER_A_MIN,
    TIER_B_MIN,
    TIER_C_MIN,
    TIER_S_MIN,
    WEIGHT_AMD_CYCLE,
    WEIGHT_FIB,
    WEIGHT_FOOTPRINT,
    WEIGHT_FVG,
    WEIGHT_LIQUIDITY_SWEEP,
    WEIGHT_MTF,
    WEIGHT_ORDER_BLOCK,
    WEIGHT_REGIME,
    WEIGHT_STRUCTURE,
    MarketRegime,
    SessionQuality,
    SignalQuality,
    SignalType,
    TradingSession,
)
from ..indicators.structure_analyzer import MarketBias, StructureState

logger = logging.getLogger(__name__)


@dataclass
class ScoringComponents:
    """Individual scoring components for transparency."""

    structure_score: float = 0.0
    regime_score: float = 0.0
    session_score: float = 0.0
    sweep_score: float = 0.0
    amd_score: float = 0.0
    ob_score: float = 0.0
    fvg_score: float = 0.0
    fib_score: float = 0.0
    premium_discount_score: float = 0.0
    mtf_score: float = 0.0
    footprint_score: float = 0.0

    regime_adjustment: int = 0
    session_adjustment: int = 0
    confluence_bonus: int = 0

    bullish_factors: int = 0
    bearish_factors: int = 0


@dataclass
class FactorActivationCounters:
    """Counts how often each factor contributes during a run."""

    bars_analyzed: int = 0

    structure_fired: int = 0
    order_blocks_fired: int = 0
    fvgs_fired: int = 0
    session_allowed: int = 0
    mtf_aligned: int = 0
    amd_fired: int = 0
    fibonacci_fired: int = 0
    footprint_fired: int = 0
    liquidity_sweep_fired: int = 0

    def as_dict(self) -> dict[str, int]:
        return {
            "bars_analyzed": self.bars_analyzed,
            "structure_fired": self.structure_fired,
            "order_blocks_fired": self.order_blocks_fired,
            "fvgs_fired": self.fvgs_fired,
            "session_allowed": self.session_allowed,
            "mtf_aligned": self.mtf_aligned,
            "amd_fired": self.amd_fired,
            "fibonacci_fired": self.fibonacci_fired,
            "footprint_fired": self.footprint_fired,
            "liquidity_sweep_fired": self.liquidity_sweep_fired,
        }


class SessionWeightProfile:
    """
    Session-specific factor weights (GENIUS v4.2).
    Different sessions favor different confluence factors.
    """

    # Asian session: Range-bound, OB/FVG are key
    ASIAN = {
        "structure": 0.11,
        "regime": 0.16,
        "sweep": 0.08,
        "ob": 0.17,
        "fvg": 0.14,
        "zone": 0.04,
        "amd": 0.03,
        "mtf": 0.10,
        "footprint": 0.08,
        "fib": 0.09,
    }

    # London session: Breakouts, structure/sweep dominant
    LONDON = {
        "structure": 0.19,  # Reduced from 0.20 to accommodate AMD
        "regime": 0.11,
        "sweep": 0.16,  # Reduced from 0.17 to accommodate AMD
        "ob": 0.12,
        "fvg": 0.10,
        "zone": 0.07,
        "mtf": 0.10,
        "footprint": 0.08,
        "fib": 0.01,  # Reduced from 0.05 (less important in breakout session)
        "amd": 0.06,  # FIX: AMD now contributes to London score
    }

    # NY Overlap: BEST - all factors balanced
    NY_OVERLAP = {
        "structure": 0.11,  # Reduced to accommodate AMD
        "regime": 0.12,  # Reduced to accommodate AMD
        "sweep": 0.12,  # Reduced to accommodate AMD
        "ob": 0.11,  # Reduced to accommodate AMD
        "fvg": 0.11,  # Reduced to accommodate AMD
        "zone": 0.06,  # Reduced to accommodate AMD
        "mtf": 0.11,  # Reduced to accommodate AMD
        "footprint": 0.11,
        "fib": 0.05,
        "amd": 0.10,  # FIX: AMD highly important during NY Overlap
    }

    # NY session: Momentum, footprint is king
    NY = {
        "structure": 0.10,  # Reduced to accommodate AMD
        "regime": 0.10,  # Reduced to accommodate AMD
        "sweep": 0.10,  # Reduced to accommodate AMD
        "ob": 0.09,  # Reduced to accommodate AMD
        "fvg": 0.09,  # Reduced to accommodate AMD
        "zone": 0.06,  # Reduced to accommodate AMD
        "mtf": 0.11,  # Reduced to accommodate AMD
        "footprint": 0.21,  # Reduced slightly, still dominant
        "fib": 0.06,
        "amd": 0.08,  # FIX: AMD important in NY session
    }

    # Default (unknown/late sessions): Balanced
    DEFAULT = {
        "structure": 0.14,
        "regime": 0.14,
        "sweep": 0.11,
        "ob": 0.12,
        "fvg": 0.12,
        "zone": 0.07,
        "mtf": 0.12,
        "footprint": 0.12,
        "fib": 0.06,
        "amd": 0.0,
    }

    @classmethod
    def get_weights(cls, session: TradingSession) -> dict[str, float]:
        """Get weight profile for given session."""
        if session == TradingSession.SESSION_ASIAN:
            return cls.ASIAN
        elif session == TradingSession.SESSION_LONDON:
            return cls.LONDON
        elif session == TradingSession.SESSION_LONDON_NY_OVERLAP:
            return cls.NY_OVERLAP
        elif session == TradingSession.SESSION_NY:
            return cls.NY
        else:
            return cls.DEFAULT


class SequenceValidator:
    """
    ICT 7-step sequential confirmation (GENIUS v4.0).

    ICT Sequence (must occur in order):
    1. Regime OK (not random walk)
    2. HTF direction set (H1 bias clear)
    3. Sweep occurred (liquidity taken)
    4. Structure broken (BOS/CHoCH)
    5. At POI (OB/FVG zone)
    6. LTF confirmed (M5 entry)
    7. Flow confirmed (order flow aligned)
    """

    @staticmethod
    def validate_sequence(
        result: ConfluenceResult,
        structure_state: StructureState | None,
        regime_analysis: RegimeAnalysis | None,
        has_sweep: bool,
        at_poi: bool,
        mtf_aligned: bool,
        footprint_aligned: bool,
    ) -> tuple[int, int]:
        """
        Validate ICT 7-step sequence.

        Args:
            result: Current confluence result
            structure_state: Market structure state
            regime_analysis: Regime analysis
            has_sweep: Whether liquidity sweep occurred
            at_poi: Whether price is at Point of Interest (OB/FVG)
            mtf_aligned: Whether multi-timeframe is aligned
            footprint_aligned: Whether order flow is aligned

        Returns:
            (steps_completed, bonus_points)
        """
        steps = 0

        # Step 1: Regime OK (not random walk)
        if regime_analysis:
            if regime_analysis.regime == MarketRegime.REGIME_RANDOM_WALK:
                # Random walk is explicitly bad - apply penalty
                return (steps, -10)
            else:
                steps += 1
        # If regime_analysis is None, just skip this step (no penalty for missing data)

        # Step 2: HTF direction set (bias clear)
        if structure_state and structure_state.bias != MarketBias.RANGING:
            steps += 1
        else:
            return (steps, 0)  # No penalty yet, but stop counting

        # Step 3: Sweep occurred
        if has_sweep:
            steps += 1
        else:
            return (steps, 0)

        # Step 4: Structure broken (BOS/CHoCH)
        if structure_state and structure_state.last_break is not None:
            steps += 1
        else:
            return (steps, 0)

        # Step 5: At POI (OB/FVG zone)
        if at_poi:
            steps += 1
        else:
            return (steps, 0)

        # Step 6: LTF confirmed (MTF aligned)
        if mtf_aligned:
            steps += 1
        else:
            return (steps, 0)

        # Step 7: Flow confirmed (footprint aligned)
        if footprint_aligned:
            steps += 1

        # Calculate bonus/penalty based on steps completed
        if steps >= 6:
            bonus = 20  # Elite sequence
        elif steps == 5:
            bonus = 10  # Strong sequence
        elif steps == 4:
            bonus = 5  # Good sequence
        elif steps == 3:
            bonus = 0  # Minimal sequence
        else:
            bonus = 0  # Removed -10 penalty: too punitive for common market conditions

        return (steps, bonus)


class ConfluenceScorer:
    """
    Central confluence scoring system.

    Combines signals from:
    - Market Structure (BOS, CHoCH, bias)
    - Regime Detection (trending, reverting, random walk)
    - Session Filter (quality, volatility)
    - Order Blocks
    - Fair Value Gaps
    - Liquidity Sweeps
    - AMD Cycles
    - MTF Alignment
    - Footprint/Order Flow
    """

    # Score constants (extracted magic numbers)
    BIAS_SCORE = 15
    BOS_SCORE = 10
    CHOCH_SCORE = 15
    PREMIUM_DISCOUNT_SCORE = 10
    OB_BASE_SCORE = 10
    OB_QUALITY_BONUS = 5
    OB_FRESH_BONUS = 3
    FVG_BASE_SCORE = 8
    FVG_QUALITY_BONUS = 4
    FVG_FRESH_BONUS = 2
    SWEEP_BASE_SCORE = 12
    SWEEP_INSTITUTIONAL_BONUS = 5
    AMD_BASE_SCORE = 10
    AMD_MAX_CONFIDENCE_BONUS = 5
    MIN_FACTORS_FOR_BONUS = 3
    HIGH_FACTORS_FOR_BONUS = 5
    MEDIUM_CONFLUENCE_BONUS = 5

    def __init__(
        self,
        min_score_to_trade: float = MIN_VALID_SCORE,
        use_session_filter: bool = True,
        use_regime_filter: bool = True,
        weight_structure: float = WEIGHT_STRUCTURE,
        weight_regime: float = WEIGHT_REGIME,
        weight_order_block: float = WEIGHT_ORDER_BLOCK,
        weight_fvg: float = WEIGHT_FVG,
        weight_liquidity_sweep: float = WEIGHT_LIQUIDITY_SWEEP,
        weight_amd_cycle: float = WEIGHT_AMD_CYCLE,
        weight_fib: float = WEIGHT_FIB,
        weight_mtf: float = WEIGHT_MTF,
        weight_footprint: float = WEIGHT_FOOTPRINT,
    ):
        """
        Initialize the confluence scorer.

        Args:
            min_score_to_trade: Minimum score to generate trade signal
            use_session_filter: Whether to apply session filtering
            use_regime_filter: Whether to apply regime filtering
        """
        self.min_score_to_trade = min_score_to_trade
        self.use_session_filter = use_session_filter
        self.use_regime_filter = use_regime_filter

        # Weight caps per component (0-100). Defaults match `core.definitions.WEIGHT_*` constants.
        self.weight_structure = float(weight_structure)
        self.weight_regime = float(weight_regime)
        self.weight_order_block = float(weight_order_block)
        self.weight_fvg = float(weight_fvg)
        self.weight_liquidity_sweep = float(weight_liquidity_sweep)
        self.weight_amd_cycle = float(weight_amd_cycle)
        self.weight_fib = float(weight_fib)
        self.weight_mtf = float(weight_mtf)
        self.weight_footprint = float(weight_footprint)

        self._components = ScoringComponents()
        self._factor_counters = FactorActivationCounters()

    def _calculate_alignment_multiplier(self, result: ConfluenceResult) -> float:
        """
        Calculate alignment multiplier (GENIUS v4.1).

        ELITE alignment: 6+ factors strongly aligned (>70), no opposition → 1.35x
        CONFLICT: 2+ bullish AND 2+ bearish strong → 0.60x
        Otherwise: 1.0x
        """
        # Get individual component scores (normalized 0-100)
        components = {
            "structure": self._components.structure_score,
            "regime": self._components.regime_score,
            "sweep": self._components.sweep_score,
            "ob": self._components.ob_score,
            "fvg": self._components.fvg_score,
            "fib": self._components.fib_score,
            "amd": self._components.amd_score,
            "mtf": self._components.mtf_score,
            "footprint": self._components.footprint_score,
        }

        # CRUCIBLE FIX: Raised threshold from 10 to 12 for "strong" factor.
        # 10 was too low - many mediocre signals were getting "strong" classification.
        strong_aligned = sum(1 for score in components.values() if score > 12.0)

        # Check for conflict (opposing directions)
        bullish = self._components.bullish_factors
        bearish = self._components.bearish_factors

        if strong_aligned >= 6 and (bullish == 0 or bearish == 0):
            # Elite alignment: all factors point same direction
            logger.debug(
                f"ELITE alignment detected: {strong_aligned} strong factors, multiplier=1.35"
            )
            return 1.35
        elif bullish >= 2 and bearish >= 2:
            # Conflict: factors disagree
            logger.debug(
                f"CONFLICT detected: {bullish} bullish, {bearish} bearish, multiplier=0.60"
            )
            return 0.60
        else:
            return 1.0

    def _calculate_freshness_multiplier(
        self,
        order_blocks: list[OrderBlock] | None,
        fvgs: list[FairValueGap] | None,
        optimal_bars: int = 5,
    ) -> float:
        """
        Calculate freshness multiplier (GENIUS v4.1).

        Recent signals are better. Peak freshness at optimal_bars (not 0, need time to develop).
        Decay after optimal.
        """
        if not order_blocks and not fvgs:
            return 1.0

        # Find youngest active OB/FVG
        min_age = 999999

        if order_blocks:
            for ob in order_blocks:
                if ob.is_valid and ob.is_fresh:
                    # Use actual age_in_bars if available, else neutral (skip this OB for age calc)
                    if hasattr(ob, "age_in_bars") and ob.age_in_bars is not None:
                        age = ob.age_in_bars
                        min_age = min(min_age, age)

        if fvgs:
            for fvg in fvgs:
                if fvg.is_valid and fvg.is_fresh:
                    age = fvg.age_in_bars
                    min_age = min(min_age, age)

        if min_age == 999999:
            return 1.0

        # Calculate multiplier: peak at optimal_bars, decay before and after
        if min_age <= optimal_bars:
            # Building up to peak
            multiplier = 0.9 + (0.15 * min_age / optimal_bars)
        else:
            # Decay after peak
            bars_past_optimal = min_age - optimal_bars
            decay = 0.02 * bars_past_optimal
            multiplier = max(0.85, 1.05 - decay)

        logger.debug(
            f"Freshness multiplier: {multiplier:.2f} (age={min_age}, optimal={optimal_bars})"
        )
        return multiplier

    def _calculate_divergence_multiplier(self) -> float:
        """
        Calculate divergence penalty (GENIUS v4.1).

        If factors disagree on direction:
        - 85%+ agree → 1.0 (no penalty)
        - <55% agree → 0.50 (50% penalty)
        """
        total_factors = self._components.bullish_factors + self._components.bearish_factors

        if total_factors == 0:
            return 1.0

        # Calculate agreement percentage
        dominant_factors = max(self._components.bullish_factors, self._components.bearish_factors)
        agreement_pct = (dominant_factors / total_factors) * 100

        if agreement_pct >= 85:
            # Strong agreement, no penalty
            return 1.0
        elif agreement_pct < 55:
            # High divergence, heavy penalty
            logger.debug(f"High divergence: {agreement_pct:.0f}% agreement, multiplier=0.50")
            return 0.50
        else:
            # Moderate divergence, scaled penalty
            # Linear interpolation: 85% → 1.0, 55% → 0.50
            multiplier = 0.50 + (agreement_pct - 55) * (0.50 / 30)
            logger.debug(
                f"Moderate divergence: {agreement_pct:.0f}% agreement, multiplier={multiplier:.2f}"
            )
            return multiplier

    def calculate_score(
        self,
        structure_state: StructureState | None = None,
        regime_analysis: RegimeAnalysis | None = None,
        session_info: SessionInfo | None = None,
        order_blocks: list[OrderBlock] | None = None,
        fvgs: list[FairValueGap] | None = None,
        sweeps: list[LiquiditySweep] | None = None,
        amd_cycle: AMDCycle | None = None,
        mtf_score: float = 0.0,
        mtf_aligned: bool = False,
        footprint_score: float = 0.0,
        footprint_direction: SignalType = SignalType.SIGNAL_NONE,
        current_price: float = 0.0,
        current_session: TradingSession = TradingSession.SESSION_UNKNOWN,
    ) -> ConfluenceResult:
        """
        Calculate confluence score from all components.

        Returns:
            ConfluenceResult with total score and breakdown
        """
        result = ConfluenceResult()
        self._components = ScoringComponents()
        self._factor_counters.bars_analyzed += 1

        # Determine primary direction from structure
        primary_direction = SignalType.SIGNAL_NONE
        if structure_state:
            primary_direction = structure_state.direction

        # 1. Structure Score
        if structure_state:
            self._score_structure(structure_state, result)

        # 2. Regime Score
        if regime_analysis:
            self._score_regime(regime_analysis, result)

        # 3. Session Score
        if session_info:
            self._score_session(session_info, result)

        # 4. Order Blocks
        if order_blocks:
            self._score_order_blocks(order_blocks, primary_direction, current_price, result)

        # 5. Fair Value Gaps
        if fvgs:
            self._score_fvgs(fvgs, primary_direction, current_price, result)

        # 5. Fibonacci (golden pocket + extensions)
        self._score_fibonacci(structure_state, current_price, order_blocks, fvgs, result)

        # 6. Liquidity Sweeps
        if sweeps:
            self._score_sweeps(sweeps, primary_direction, result)

        # 7. AMD Cycle
        if amd_cycle:
            self._score_amd(amd_cycle, primary_direction, result)

        # 8. MTF Score
        # CRUCIBLE FIX: Remove weight/100 scaling - mtf_score is already 0-100 normalized.
        # The double-scaling was causing MTF contribution to be too low.
        # Session weights in _calculate_total will apply the proper weighting.
        self._components.mtf_score = mtf_score
        if mtf_aligned:
            self._factor_counters.mtf_aligned += 1
            self._components.confluence_bonus += 10

        # 9. Footprint Score
        # CRUCIBLE FIX: Same issue as MTF - footprint_score is already 0-100 normalized.
        self._components.footprint_score = footprint_score
        if self._components.footprint_score > 0:
            self._factor_counters.footprint_fired += 1
        if (
            footprint_direction == primary_direction
            and footprint_direction != SignalType.SIGNAL_NONE
        ):
            self._components.confluence_bonus += 5
        result.footprint_score = self._components.footprint_score
        result.footprint_direction = footprint_direction

        # BUG-11 DIAGNOSTIC: Verbose logging of all 9 factor scores for debugging confluence issues.
        # This helps diagnose why trades are/aren't being triggered.
        logger.debug(
            "[CONFLUENCE_SCORER] All 9 Factors: "
            f"Struct={self._components.structure_score:.1f} "
            f"Regime={self._components.regime_score:.1f} "
            f"Session={self._components.session_score:.1f} "
            f"OB={self._components.ob_score:.1f} (count={len(order_blocks) if order_blocks else 0}) "
            f"FVG={self._components.fvg_score:.1f} (count={len(fvgs) if fvgs else 0}) "
            f"Fib={self._components.fib_score:.1f} "
            f"Sweep={self._components.sweep_score:.1f} (count={len(sweeps) if sweeps else 0}) "
            f"AMD={self._components.amd_score:.1f} "
            f"MTF={self._components.mtf_score:.1f} (aligned={mtf_aligned}) "
            f"Footprint={self._components.footprint_score:.1f} "
            f"Bonus={self._components.confluence_bonus:.1f} "
            f"| Dir={primary_direction.name} Price={current_price:.2f}"
        )

        # Calculate total score with GENIUS v4.0+ enhancements
        self._calculate_total(
            result=result,
            current_session=current_session,
            order_blocks=order_blocks,
            fvgs=fvgs,
            structure_state=structure_state,
            regime_analysis=regime_analysis,
            sweeps=sweeps,
            mtf_aligned=mtf_aligned,
            footprint_direction=footprint_direction,
            current_price=current_price,
        )

        # Determine quality tier
        self._determine_quality(result)

        # Final validation
        self._validate_result(result, session_info, regime_analysis)

        return result

    def _score_structure(self, state: StructureState, result: ConfluenceResult) -> None:
        """Score market structure component."""
        if not state:
            logger.debug("Structure state is None, skipping structure scoring")
            return

        score = 0.0

        # Bias contribution
        if state.bias == MarketBias.BULLISH:
            score += self.BIAS_SCORE
            self._components.bullish_factors += 1
            result.direction = SignalType.SIGNAL_BUY
        elif state.bias == MarketBias.BEARISH:
            score += self.BIAS_SCORE
            self._components.bearish_factors += 1
            result.direction = SignalType.SIGNAL_SELL

        # BOS/CHoCH contribution
        if state.last_break:
            from ..indicators.structure_analyzer import BreakType

            if state.last_break.break_type == BreakType.BOS:
                score += self.BOS_SCORE
            elif state.last_break.break_type == BreakType.CHOCH:
                score += self.CHOCH_SCORE  # Higher weight for reversal signal

        # Premium/Discount alignment
        if result.direction == SignalType.SIGNAL_BUY and state.in_discount:
            score += self.PREMIUM_DISCOUNT_SCORE
            self._components.premium_discount_score = self.PREMIUM_DISCOUNT_SCORE
        elif result.direction == SignalType.SIGNAL_SELL and state.in_premium:
            score += self.PREMIUM_DISCOUNT_SCORE
            self._components.premium_discount_score = self.PREMIUM_DISCOUNT_SCORE

        self._components.structure_score = min(self.weight_structure, score)
        result.structure_score = self._components.structure_score
        if self._components.structure_score > 0:
            self._factor_counters.structure_fired += 1

        logger.debug(f"Structure score: {self._components.structure_score:.1f}, bias={state.bias}")

    def _score_regime(self, regime: RegimeAnalysis, result: ConfluenceResult) -> None:
        """Score regime component."""
        score = 0.0
        adjustment = 0

        if regime.regime == MarketRegime.REGIME_PRIME_TRENDING:
            score = self.weight_regime
            adjustment = 10
        elif regime.regime == MarketRegime.REGIME_NOISY_TRENDING:
            score = self.weight_regime * 0.7
            adjustment = 5
        elif regime.regime == MarketRegime.REGIME_PRIME_REVERTING:
            score = self.weight_regime * 0.8
            adjustment = 8
        elif regime.regime == MarketRegime.REGIME_NOISY_REVERTING:
            score = self.weight_regime * 0.5
            adjustment = 0
        elif regime.regime == MarketRegime.REGIME_RANDOM_WALK:
            score = 0
            adjustment = PENALTY_RANDOM_WALK
        elif regime.regime == MarketRegime.REGIME_TRANSITIONING:
            score = self.weight_regime * 0.3
            adjustment = -10

        self._components.regime_score = score
        self._components.regime_adjustment = adjustment
        result.regime_score = score
        result.regime_adjustment = adjustment

    def _score_session(self, session: SessionInfo, result: ConfluenceResult) -> None:
        """Score session component.

        FORGE-NAUTILUS Wave 3 FIX: When a session is explicitly allowed via config
        (allow_asian=True or allow_late_ny=True), we don't penalize the score.
        The session adjustment is only applied when trading is NOT allowed.
        """
        score = 0.0
        adjustment = 0

        if session.quality == SessionQuality.SESSION_QUALITY_PRIME:
            score = 10
            adjustment = 5
        elif session.quality == SessionQuality.SESSION_QUALITY_HIGH:
            score = 8
        elif session.quality == SessionQuality.SESSION_QUALITY_MEDIUM:
            score = 5
        elif session.quality == SessionQuality.SESSION_QUALITY_LOW:
            score = 2
            # WAVE 3 FIX: Only apply penalty if trading is NOT allowed
            # When allow_asian=True, is_trading_allowed=True, so no penalty
            adjustment = 0 if session.is_trading_allowed else -5
        elif session.quality == SessionQuality.SESSION_QUALITY_BLOCKED:
            score = 0
            adjustment = -15

        self._components.session_score = score
        self._components.session_adjustment = adjustment
        result.session_score = score
        result.session_filter_ok = session.is_trading_allowed
        if session.is_trading_allowed:
            self._factor_counters.session_allowed += 1

    def _score_order_blocks(
        self,
        obs: list[OrderBlock],
        direction: SignalType,
        current_price: float,
        result: ConfluenceResult,
    ) -> None:
        """Score order blocks."""
        if not obs:
            logger.debug("No order blocks provided")
            return

        if current_price <= 0:
            logger.warning(f"Invalid current price for OB scoring: {current_price}")
            return

        score = 0.0

        for ob in obs:
            if not ob.is_valid or ob.state.value >= 2:  # Mitigated or disabled
                continue

            # Check if price is near OB
            if ob.low_price <= current_price <= ob.high_price:
                # Direction alignment
                if ob.direction == direction:
                    score += self.OB_BASE_SCORE
                    if ob.quality.value >= 2:  # HIGH or ELITE
                        score += self.OB_QUALITY_BONUS
                    if ob.is_fresh:
                        score += self.OB_FRESH_BONUS

                    if direction == SignalType.SIGNAL_BUY:
                        self._components.bullish_factors += 1
                    else:
                        self._components.bearish_factors += 1

                    logger.debug(f"Order block scored: {score:.1f}")
                    break  # Use best OB only

        self._components.ob_score = min(self.weight_order_block, score)
        result.ob_score = self._components.ob_score
        if self._components.ob_score > 0:
            self._factor_counters.order_blocks_fired += 1

    def _score_fvgs(
        self,
        fvgs: list[FairValueGap],
        direction: SignalType,
        current_price: float,
        result: ConfluenceResult,
    ) -> None:
        """Score fair value gaps."""
        if not fvgs:
            logger.debug("No FVGs provided")
            return

        if current_price <= 0:
            # Caller bug / warm-up edge case; don't spam logs during sweeps.
            logger.debug("Invalid current price for FVG scoring: %s", current_price)
            return

        score = 0.0

        for fvg in fvgs:
            if not fvg.is_valid or fvg.state.value >= 2:  # Filled or expired
                continue

            # Check if price is in FVG
            if fvg.lower_level <= current_price <= fvg.upper_level:
                if fvg.direction == direction:
                    score += self.FVG_BASE_SCORE
                    if fvg.quality.value >= 2:
                        score += self.FVG_QUALITY_BONUS
                    if fvg.is_fresh:
                        score += self.FVG_FRESH_BONUS

                    if direction == SignalType.SIGNAL_BUY:
                        self._components.bullish_factors += 1
                    else:
                        self._components.bearish_factors += 1

                    logger.debug(f"FVG scored: {score:.1f}")
                    break

        self._components.fvg_score = min(self.weight_fvg, score)
        result.fvg_score = self._components.fvg_score
        if self._components.fvg_score > 0:
            self._factor_counters.fvgs_fired += 1

    def _score_sweeps(
        self, sweeps: list[LiquiditySweep], direction: SignalType, result: ConfluenceResult
    ) -> None:
        """Score liquidity sweeps."""
        if not sweeps:
            logger.debug("No liquidity sweeps provided")
            return

        score = 0.0

        for sweep in sweeps:
            if not sweep.is_confirmed:
                continue

            # Sweep in opposite direction = reversal signal
            if sweep.direction != direction and sweep.direction != SignalType.SIGNAL_NONE:
                score += self.SWEEP_BASE_SCORE
                if sweep.is_institutional:
                    score += self.SWEEP_INSTITUTIONAL_BONUS

                # Count as confluence factor
                if direction == SignalType.SIGNAL_BUY:
                    self._components.bullish_factors += 1
                else:
                    self._components.bearish_factors += 1

                logger.debug(
                    f"Liquidity sweep scored: {score:.1f}, institutional={sweep.is_institutional}"
                )
                break

        self._components.sweep_score = min(self.weight_liquidity_sweep, score)
        result.sweep_score = self._components.sweep_score
        if self._components.sweep_score > 0:
            self._factor_counters.liquidity_sweep_fired += 1

    def _score_amd(self, amd: AMDCycle, direction: SignalType, result: ConfluenceResult) -> None:
        """Score AMD cycle."""
        if not amd:
            logger.debug("No AMD cycle provided")
            return

        score = 0.0

        if not amd.is_valid:
            return

        from ..core.definitions import AMDPhase

        # Distribution phase with direction alignment
        if amd.current_phase == AMDPhase.AMD_DISTRIBUTION:
            if amd.expected_direction == direction:
                score += self.AMD_BASE_SCORE
                # Up to AMD_MAX_CONFIDENCE_BONUS extra based on confidence
                score += amd.confidence * self.AMD_MAX_CONFIDENCE_BONUS / 100

                if direction == SignalType.SIGNAL_BUY:
                    self._components.bullish_factors += 1
                else:
                    self._components.bearish_factors += 1

                logger.debug(f"AMD cycle scored: {score:.1f}, confidence={amd.confidence:.1f}")

        self._components.amd_score = min(self.weight_amd_cycle, score)
        result.amd_score = self._components.amd_score
        if self._components.amd_score > 0:
            self._factor_counters.amd_fired += 1

    def _score_fibonacci(
        self,
        structure_state: StructureState | None,
        current_price: float,
        order_blocks: list[OrderBlock] | None,
        fvgs: list[FairValueGap] | None,
        result: ConfluenceResult,
    ) -> None:
        """Score Fibonacci confluence (golden pocket + POI overlap)."""
        if not structure_state or not structure_state.fibonacci:
            return

        fib = structure_state.fibonacci
        score = 0.0

        if fib.in_golden_pocket:
            score += 15

            # Bonus: overlap with OB or FVG
            if order_blocks:
                if any(
                    ob.is_valid and ob.low_price <= current_price <= ob.high_price
                    for ob in order_blocks
                ):
                    score += 10

            if fvgs:
                if any(
                    fvg.is_valid and fvg.lower_level <= current_price <= fvg.upper_level
                    for fvg in fvgs
                ):
                    score += 10

        score = min(self.weight_fib, score)
        self._components.fib_score = score
        result.fib_score = score
        if score > 0:
            self._factor_counters.fibonacci_fired += 1

        if fib.direction == SignalType.SIGNAL_BUY:
            self._components.bullish_factors += 1
            if result.direction == SignalType.SIGNAL_NONE:
                result.direction = SignalType.SIGNAL_BUY
        elif fib.direction == SignalType.SIGNAL_SELL:
            self._components.bearish_factors += 1
            if result.direction == SignalType.SIGNAL_NONE:
                result.direction = SignalType.SIGNAL_SELL

    def _calculate_total(
        self,
        result: ConfluenceResult,
        current_session: TradingSession,
        order_blocks: list[OrderBlock] | None,
        fvgs: list[FairValueGap] | None,
        structure_state: StructureState | None,
        regime_analysis: RegimeAnalysis | None,
        sweeps: list[LiquiditySweep] | None,
        mtf_aligned: bool,
        footprint_direction: SignalType,
        current_price: float = 0.0,
    ) -> None:
        """Calculate total score with GENIUS v4.0+ enhancements."""
        # Get session-specific weights (GENIUS v4.2)
        session_weights = SessionWeightProfile.get_weights(current_session)

        # Apply session-specific weights to base scores
        # NOTE: Removed * 100 multiplier - was causing score inflation (BUG FIX)
        weighted_scores = {
            "structure": self._components.structure_score * session_weights["structure"],
            "regime": self._components.regime_score * session_weights["regime"],
            "sweep": self._components.sweep_score * session_weights["sweep"],
            "ob": self._components.ob_score * session_weights["ob"],
            "fvg": self._components.fvg_score * session_weights["fvg"],
            "fib": self._components.fib_score * session_weights.get("fib", 0.0),
            "zone": self._components.premium_discount_score * session_weights["zone"],
            # AMD is a confluence factor and must contribute to the base score.
            "amd": self._components.amd_score * session_weights.get("amd", 0.0),
            # CRUCIBLE FIX: Cap MTF contribution at 15 to prevent score ceiling hits
            "mtf": min(self._components.mtf_score * session_weights["mtf"], 15),
            "footprint": self._components.footprint_score * session_weights["footprint"],
        }

        # Sum weighted base scores (session score now weighted properly)
        session_weighted = self._components.session_score * session_weights.get("session", 0.10)
        base_score = sum(weighted_scores.values()) + session_weighted

        # Apply adjustments
        adjustments = self._components.regime_adjustment + self._components.session_adjustment

        # Confluence bonus for multiple factors
        total_factors = self._components.bullish_factors + self._components.bearish_factors
        if total_factors >= self.HIGH_FACTORS_FOR_BONUS:
            self._components.confluence_bonus += BONUS_HIGH_CONFLUENCE
        elif total_factors >= self.MIN_FACTORS_FOR_BONUS:
            self._components.confluence_bonus += self.MEDIUM_CONFLUENCE_BONUS

        # Calculate additive score (before multipliers)
        additive_score = base_score + adjustments + self._components.confluence_bonus

        # Apply Phase 1 Multipliers (GENIUS v4.1)
        alignment_mult = self._calculate_alignment_multiplier(result)
        freshness_mult = self._calculate_freshness_multiplier(order_blocks, fvgs)
        divergence_mult = self._calculate_divergence_multiplier()

        total_multiplier = alignment_mult * freshness_mult * divergence_mult
        multiplied_score = additive_score * total_multiplier

        # ICT Sequential Confirmation (GENIUS v4.0)
        has_sweep = any(s.is_confirmed for s in (sweeps or []))
        # CRUCIBLE FIX: at_poi must check if price is ACTUALLY AT the OB/FVG zone,
        # not just whether any valid OB/FVG exists. Without price proximity check,
        # this was always True when any OB/FVG existed, defeating the purpose.
        at_poi = any(
            ob.is_valid and ob.state.value < 2 and ob.low_price <= current_price <= ob.high_price
            for ob in (order_blocks or [])
        ) or any(
            fvg.is_valid
            and fvg.state.value < 2
            and fvg.lower_level <= current_price <= fvg.upper_level
            for fvg in (fvgs or [])
        )
        footprint_aligned = (
            footprint_direction == result.direction
            and footprint_direction != SignalType.SIGNAL_NONE
        )

        sequence_steps, sequence_bonus = SequenceValidator.validate_sequence(
            result=result,
            structure_state=structure_state,
            regime_analysis=regime_analysis,
            has_sweep=has_sweep,
            at_poi=at_poi,
            mtf_aligned=mtf_aligned,
            footprint_aligned=footprint_aligned,
        )

        # Apply sequence bonus
        final_score = multiplied_score + sequence_bonus

        # Scale to 0-100 range
        # Session weights sum to ~1.0, so base_score max is ~15-20 instead of 100
        # FORGE-NAUTILUS CALIBRATION: Compromise between 6.0 (original) and 4.0 (Wave 1).
        # 4.0 was too restrictive - only 1 trade in 3 months. 5.0 balances signal
        # distribution across tiers while still preventing ceiling hits.
        SCORE_SCALE_FACTOR = 5.0
        scaled_score = final_score * SCORE_SCALE_FACTOR

        # Clamp to 0-100
        result.total_score = max(0, min(100, scaled_score))
        result.confluence_bonus = self._components.confluence_bonus
        result.bullish_factors = self._components.bullish_factors
        result.bearish_factors = self._components.bearish_factors
        result.total_confluences = total_factors

        # Store GENIUS enhancements in result
        result.sequence_steps = sequence_steps
        result.multiplier_adjustments = {
            "alignment": alignment_mult,
            "freshness": freshness_mult,
            "divergence": divergence_mult,
            "total": total_multiplier,
            "sequence_bonus": sequence_bonus,
        }

        logger.debug(
            f"GENIUS score calculation: base={base_score:.1f}, additive={additive_score:.1f}, "
            f"mult={total_multiplier:.2f}, sequence_bonus={sequence_bonus}, raw={final_score:.1f}, "
            f"scaled={scaled_score:.1f}, final={result.total_score:.1f}"
        )
        logger.debug(
            f"Session={current_session.name}, ICT_steps={sequence_steps}/7, "
            f"factors={total_factors} (B:{self._components.bullish_factors}, S:{self._components.bearish_factors})"
        )

    def _determine_quality(self, result: ConfluenceResult) -> None:
        """Determine signal quality tier."""
        score = result.total_score

        if score >= TIER_S_MIN:
            result.quality = SignalQuality.QUALITY_ELITE
        elif score >= TIER_A_MIN:
            result.quality = SignalQuality.QUALITY_HIGH
        elif score >= TIER_B_MIN:
            result.quality = SignalQuality.QUALITY_MEDIUM
        elif score >= TIER_C_MIN:
            result.quality = SignalQuality.QUALITY_LOW
        else:
            result.quality = SignalQuality.QUALITY_INVALID

    def _validate_result(
        self, result: ConfluenceResult, session: SessionInfo | None, regime: RegimeAnalysis | None
    ) -> None:
        """Final validation of the result."""
        # Session filter
        if self.use_session_filter and session:
            result.session_filter_ok = session.is_trading_allowed
            if not session.is_trading_allowed:
                result.quality = SignalQuality.QUALITY_INVALID

        # Regime filter
        if self.use_regime_filter and regime:
            result.regime_filter_ok = regime.regime != MarketRegime.REGIME_RANDOM_WALK
            if regime.regime == MarketRegime.REGIME_RANDOM_WALK:
                result.quality = SignalQuality.QUALITY_INVALID

        # Score threshold
        if result.total_score < self.min_score_to_trade:
            result.quality = SignalQuality.QUALITY_INVALID

        # Generate diagnosis
        result.diagnosis = self._generate_diagnosis(result)

    def _generate_diagnosis(self, result: ConfluenceResult) -> str:
        """Generate human-readable diagnosis with GENIUS v4.0+ info."""
        direction = (
            "BUY"
            if result.direction == SignalType.SIGNAL_BUY
            else ("SELL" if result.direction == SignalType.SIGNAL_SELL else "NONE")
        )

        quality_names = {
            SignalQuality.QUALITY_ELITE: "TIER-S",
            SignalQuality.QUALITY_HIGH: "TIER-A",
            SignalQuality.QUALITY_MEDIUM: "TIER-B",
            SignalQuality.QUALITY_LOW: "TIER-C",
            SignalQuality.QUALITY_INVALID: "INVALID",
        }

        # Build base diagnosis
        diagnosis = (
            f"{direction} | {quality_names.get(result.quality, 'UNKNOWN')} | "
            f"Score: {result.total_score:.0f} | "
            f"Confluences: {result.total_confluences}"
        )

        # Add GENIUS enhancements if available
        if result.sequence_steps > 0:
            diagnosis += f" | ICT: {result.sequence_steps}/7"

        if result.multiplier_adjustments:
            total_mult = result.multiplier_adjustments.get("total", 1.0)
            if total_mult != 1.0:
                diagnosis += f" | Mult: {total_mult:.2f}x"

        return diagnosis

    def get_components(self) -> ScoringComponents:
        """Get detailed scoring components."""
        return self._components

    def get_factor_counters(self) -> FactorActivationCounters:
        """Get activation counters for the current run."""
        return self._factor_counters
