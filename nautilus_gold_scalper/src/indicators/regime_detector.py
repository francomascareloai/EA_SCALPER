"""
Regime Detector com Hurst + Entropy + Variance Ratio.
Migrado de: MQL5/Include/EA_SCALPER/Analysis/CRegimeDetector.mqh

v4.0 Features:
- Hurst Exponent (R/S method)
- Shannon Entropy
- Variance Ratio (Lo-MacKinlay)
- Multi-scale Hurst (robustness)
- Regime Transition Detection (predictive)
- Kalman Filter trend
"""

from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Any

import numpy as np
from numpy.typing import NDArray
from scipy import stats

from ..core.data_types import RegimeAnalysis
from ..core.definitions import EntryMode, MarketRegime
from ..core.exceptions import InsufficientDataError


@dataclass
class KalmanState:
    """Estado interno do filtro de Kalman simples (posicao + velocidade)."""

    x: float = 0.0  # posicao estimada (preco suavizado)
    p: float = 1.0  # variancia da estimativa
    velocity: float = 0.0  # tendencia / primeira derivada


class RegimeDetector:
    """
    Detector de regime de mercado institucional.

    Classifica o mercado em regimes de tendencia ou mean-reversion usando
    Hurst, entropia e variance ratio, com confirmacoes multi-escala e
    um filtro de Kalman para tendencia instantanea.
    """

    HURST_TRENDING_MIN = 0.56
    HURST_REVERTING_MAX = 0.45
    ENTROPY_LOW_THRESHOLD = 1.5
    VR_TRENDING_THRESHOLD = 1.2
    VR_REVERTING_THRESHOLD = 0.8
    TRANSITION_PROBABILITY_HIGH = 0.6

    def __init__(
        self,
        hurst_period: int = 100,
        entropy_period: int = 50,
        vr_period: int = 20,
        kalman_q: float = 0.01,
        kalman_r: float = 0.1,
        multiscale_periods: list[int] | None = None,
    ) -> None:
        self.hurst_period = hurst_period
        self.entropy_period = entropy_period
        self.vr_period = vr_period
        self.kalman_q = kalman_q
        self.kalman_r = kalman_r
        self.multiscale_periods = multiscale_periods or [50, 100, 200]

        self._kalman = KalmanState()
        self._regime_history: list[MarketRegime] = []
        self._hurst_history: list[float] = []
        self._bars_in_current_regime = 0
        self._previous_regime: MarketRegime = MarketRegime.REGIME_UNKNOWN

    def reset(self) -> None:
        """Reset internal state to avoid cross-run leakage (e.g., WFA folds/backtest segments)."""
        self._kalman = KalmanState()
        self._regime_history = []
        self._hurst_history = []
        self._bars_in_current_regime = 0
        self._previous_regime = MarketRegime.REGIME_UNKNOWN

    def analyze(
        self,
        prices: NDArray[np.floating[Any]],
        volumes: NDArray[np.floating[Any]] | None = None,
    ) -> RegimeAnalysis:
        """Analisa o regime de mercado atual e retorna RegimeAnalysis."""
        # BUG-IND-001: VR requires >= (2*q + 1) prices because returns = diff(log(prices)).
        # Also guard against non-finite / non-positive prices which break log().
        min_bars = max(
            self.hurst_period,
            self.entropy_period,
            max(self.multiscale_periods),
            (self.vr_period * 2) + 1,
        )
        if len(prices) < min_bars:
            raise InsufficientDataError(f"Precisa de pelo menos {min_bars} barras")

        # Sanitize prices for log-based metrics.
        prices_f = np.asarray(prices, dtype=float)
        finite_pos = np.isfinite(prices_f) & (prices_f > 0.0)
        if not np.all(finite_pos):
            prices_f = prices_f[finite_pos]
            if len(prices_f) < min_bars:
                raise InsufficientDataError(
                    f"Precisa de pelo menos {min_bars} barras (apos filtrar NaN/<=0)"
                )

        hurst = self._calculate_hurst(prices_f[-self.hurst_period :])
        hurst = max(0.0, min(1.0, hurst))
        entropy = self._calculate_entropy(prices_f[-self.entropy_period :])
        vr = self._calculate_variance_ratio(prices_f[-((self.vr_period * 2) + 1) :])

        # BUG-IND-001: use the same sanitized price series for all log-based metrics.
        hurst_short = self._calculate_hurst(prices_f[-self.multiscale_periods[0] :])
        hurst_medium = self._calculate_hurst(prices_f[-self.multiscale_periods[1] :])
        hurst_long = self._calculate_hurst(prices_f[-self.multiscale_periods[2] :])
        multiscale_agreement = self._calculate_multiscale_agreement(
            hurst_short, hurst_medium, hurst_long
        )

        kalman_velocity = self._update_kalman(float(prices[-1]))

        regime = self._classify_regime(hurst, entropy, vr, multiscale_agreement)
        transition_prob = self._calculate_transition_probability(hurst)
        if transition_prob > self.TRANSITION_PROBABILITY_HIGH:
            regime = MarketRegime.REGIME_TRANSITIONING

        self._update_history(regime, hurst)

        size_multiplier = self._calculate_size_multiplier(regime, multiscale_agreement)
        score_adjustment = self._calculate_score_adjustment(regime, transition_prob)
        confidence = self._calculate_confidence(
            hurst, entropy, vr, multiscale_agreement, transition_prob
        )
        entry_mode = self.get_entry_mode(regime)

        return RegimeAnalysis(
            regime=regime,
            hurst_exponent=hurst,
            shannon_entropy=entropy,
            variance_ratio=vr,
            hurst_short=hurst_short,
            hurst_medium=hurst_medium,
            hurst_long=hurst_long,
            multiscale_agreement=multiscale_agreement,
            transition_probability=transition_prob,
            bars_in_regime=self._bars_in_current_regime,
            regime_velocity=self._calculate_regime_velocity(),
            previous_regime=self._previous_regime,
            kalman_trend_velocity=kalman_velocity,
            size_multiplier=size_multiplier,
            score_adjustment=score_adjustment,
            confidence=confidence,
            recommended_entry_mode=entry_mode,
            calculation_time=datetime.now(timezone.utc),
            is_valid=True,
            diagnosis=self._generate_diagnosis(regime, hurst, entropy, vr),
        )

    # --- metricas principais -------------------------------------------------
    def _calculate_hurst(self, prices: NDArray[np.floating[Any]]) -> float:
        """Calcula Hurst Exponent usando o metodo R/S (robusto para serie curta)."""
        n = len(prices)
        if n < 20:
            return 0.5

        returns = np.diff(np.log(prices))
        rs_values: list[float] = []
        sizes: list[int] = []

        for size in [int(n / 8), int(n / 4), int(n / 2)]:
            if size < 10:
                continue

            num_chunks = len(returns) // size
            if num_chunks < 1:
                continue

            rs_list: list[float] = []
            for i in range(num_chunks):
                chunk = returns[i * size : (i + 1) * size]
                mean_adj = chunk - np.mean(chunk)
                cumsum = np.cumsum(mean_adj)
                R = float(np.max(cumsum) - np.min(cumsum))
                S = float(np.std(chunk, ddof=1))
                if S > 0:
                    rs_list.append(R / S)

            if rs_list:
                rs_values.append(float(np.mean(rs_list)))
                sizes.append(size)

        if len(rs_values) < 2:
            return 0.5

        log_sizes = np.log(sizes)
        log_rs = np.log(rs_values)
        slope, _, _, _, _ = stats.linregress(log_sizes, log_rs)
        return float(np.clip(slope, 0.0, 1.0))

    def _calculate_entropy(self, prices: NDArray[np.floating[Any]]) -> float:
        """Calcula Shannon Entropy normalizada dos retornos log."""
        returns = np.diff(np.log(prices))
        n_bins = min(20, max(3, len(returns) // 5))
        if n_bins < 3:
            return 2.0

        # BUG FIX: density=True returns PDF, not probabilities.
        # Must use density=False and normalize to get P(x) that sums to 1.
        hist, _ = np.histogram(returns, bins=n_bins, density=False)
        hist = hist / hist.sum()  # Normalize to probabilities
        hist = hist[hist > 0]
        entropy = -np.sum(hist * np.log2(hist)) / np.log2(n_bins)
        return float(entropy)

    def _calculate_variance_ratio(self, prices: NDArray[np.floating[Any]]) -> float:
        """Calcula Variance Ratio (Lo-MacKinlay). VR>1 trending, VR<1 mean-revert."""
        returns = np.diff(np.log(prices))
        if len(returns) < self.vr_period * 2:
            return 1.0

        var_1 = float(np.var(returns, ddof=1))
        q = self.vr_period
        returns_q = np.diff(np.log(prices[::q]))
        var_q = float(np.var(returns_q, ddof=1)) if len(returns_q) > 1 else var_1
        if var_1 <= 0:
            return 1.0
        vr = var_q / (q * var_1)
        return float(vr)

    # --- classificacao e ajustes --------------------------------------------
    def _classify_regime(
        self, hurst: float, entropy: float, vr: float, agreement: float
    ) -> MarketRegime:
        if self.HURST_REVERTING_MAX <= hurst <= self.HURST_TRENDING_MIN:
            return MarketRegime.REGIME_RANDOM_WALK

        if hurst > self.HURST_TRENDING_MIN:
            if entropy < self.ENTROPY_LOW_THRESHOLD and vr > self.VR_TRENDING_THRESHOLD:
                return MarketRegime.REGIME_PRIME_TRENDING
            return MarketRegime.REGIME_NOISY_TRENDING

        if hurst < self.HURST_REVERTING_MAX:
            if entropy < self.ENTROPY_LOW_THRESHOLD and vr < self.VR_REVERTING_THRESHOLD:
                return MarketRegime.REGIME_PRIME_REVERTING
            return MarketRegime.REGIME_NOISY_REVERTING

        return MarketRegime.REGIME_UNKNOWN

    def _calculate_multiscale_agreement(
        self, h_short: float, h_medium: float, h_long: float
    ) -> float:
        values = [h_short, h_medium, h_long]
        all_trending = all(h > 0.5 for h in values)
        all_reverting = all(h < 0.5 for h in values)
        if not (all_trending or all_reverting):
            return 30.0
        std = float(np.std(values))
        agreement = 100 * (1 - min(std * 10, 1))
        return float(agreement)

    def _update_kalman(self, price: float) -> float:
        x_pred = self._kalman.x + self._kalman.velocity
        p_pred = self._kalman.p + self.kalman_q
        k = p_pred / (p_pred + self.kalman_r)

        self._kalman.x = x_pred + k * (price - x_pred)
        self._kalman.p = (1 - k) * p_pred
        self._kalman.velocity = self._kalman.x - x_pred + k * (price - x_pred)
        return float(self._kalman.velocity)

    def _calculate_transition_probability(self, current_hurst: float) -> float:
        if len(self._hurst_history) < 10:
            return 0.0
        recent = self._hurst_history[-10:]
        velocity = (recent[-1] - recent[0]) / 10
        distance_to_boundary = min(
            abs(current_hurst - self.HURST_TRENDING_MIN),
            abs(current_hurst - self.HURST_REVERTING_MAX),
        )
        if distance_to_boundary < 0.05 and abs(velocity) > 0.005:
            return float(min(0.9, 0.5 + abs(velocity) * 10))
        return float(max(0.0, 0.5 - distance_to_boundary * 5))

    def _update_history(self, regime: MarketRegime, hurst: float) -> None:
        self._hurst_history.append(hurst)
        if len(self._hurst_history) > 200:
            self._hurst_history.pop(0)

        if regime == self._previous_regime:
            self._bars_in_current_regime += 1
        else:
            self._previous_regime = regime
            self._bars_in_current_regime = 1

        self._regime_history.append(regime)
        if len(self._regime_history) > 200:
            self._regime_history.pop(0)

    def _calculate_regime_velocity(self) -> float:
        if len(self._hurst_history) < 2:
            return 0.0
        return float(self._hurst_history[-1] - self._hurst_history[-2])

    def _calculate_size_multiplier(self, regime: MarketRegime, agreement: float) -> float:
        base_mult = {
            MarketRegime.REGIME_PRIME_TRENDING: 1.0,
            MarketRegime.REGIME_NOISY_TRENDING: 0.7,
            MarketRegime.REGIME_PRIME_REVERTING: 0.8,
            MarketRegime.REGIME_NOISY_REVERTING: 0.5,
            MarketRegime.REGIME_RANDOM_WALK: 0.0,
            MarketRegime.REGIME_TRANSITIONING: 0.3,
            MarketRegime.REGIME_UNKNOWN: 0.0,
        }.get(regime, 0.0)
        agreement_factor = agreement / 100
        return float(base_mult * (0.7 + 0.3 * agreement_factor))

    def _calculate_score_adjustment(self, regime: MarketRegime, transition_prob: float) -> int:
        base_adj = {
            MarketRegime.REGIME_PRIME_TRENDING: 20,
            MarketRegime.REGIME_NOISY_TRENDING: 10,
            MarketRegime.REGIME_PRIME_REVERTING: 15,
            MarketRegime.REGIME_NOISY_REVERTING: 5,
            MarketRegime.REGIME_RANDOM_WALK: -50,
            MarketRegime.REGIME_TRANSITIONING: -20,
            MarketRegime.REGIME_UNKNOWN: -30,
        }.get(regime, 0)
        if transition_prob > 0.5:
            base_adj -= int(transition_prob * 20)
        return int(base_adj)

    def _calculate_confidence(
        self,
        hurst: float,
        entropy: float,
        vr: float,
        agreement: float,
        transition_prob: float,
    ) -> float:
        hurst_clarity = min(abs(hurst - 0.5) * 4, 1.0) * 25
        entropy_factor = max(0.0, (2.5 - entropy) / 2.5) * 20
        vr_confirms = 1.0
        if (hurst > 0.55 and vr < 1.0) or (hurst < 0.45 and vr > 1.0):
            vr_confirms = 0.5
        vr_factor = vr_confirms * 20
        agreement_factor = agreement * 0.25
        stability_factor = (1 - transition_prob) * 10
        total = hurst_clarity + entropy_factor + vr_factor + agreement_factor + stability_factor
        return float(min(100, max(0, total)))

    def _generate_diagnosis(
        self, regime: MarketRegime, hurst: float, entropy: float, vr: float
    ) -> str:
        names = {
            MarketRegime.REGIME_PRIME_TRENDING: "PRIME TRENDING",
            MarketRegime.REGIME_NOISY_TRENDING: "NOISY TRENDING",
            MarketRegime.REGIME_PRIME_REVERTING: "PRIME REVERTING",
            MarketRegime.REGIME_NOISY_REVERTING: "NOISY REVERTING",
            MarketRegime.REGIME_RANDOM_WALK: "RANDOM WALK",
            MarketRegime.REGIME_TRANSITIONING: "TRANSITIONING",
            MarketRegime.REGIME_UNKNOWN: "UNKNOWN",
        }
        return f"{names.get(regime, 'UNKNOWN')} | H={hurst:.3f} S={entropy:.2f} VR={vr:.2f}"

    def get_entry_mode(self, regime: MarketRegime) -> EntryMode:
        return {
            MarketRegime.REGIME_PRIME_TRENDING: EntryMode.ENTRY_MODE_BREAKOUT,
            MarketRegime.REGIME_NOISY_TRENDING: EntryMode.ENTRY_MODE_PULLBACK,
            MarketRegime.REGIME_PRIME_REVERTING: EntryMode.ENTRY_MODE_MEAN_REVERT,
            MarketRegime.REGIME_NOISY_REVERTING: EntryMode.ENTRY_MODE_MEAN_REVERT,
            MarketRegime.REGIME_RANDOM_WALK: EntryMode.ENTRY_MODE_DISABLED,
            MarketRegime.REGIME_TRANSITIONING: EntryMode.ENTRY_MODE_CONFIRMATION,
            MarketRegime.REGIME_UNKNOWN: EntryMode.ENTRY_MODE_DISABLED,
        }.get(regime, EntryMode.ENTRY_MODE_DISABLED)

    def detect_regime(self, prices: NDArray[np.floating[Any]]) -> str:
        """
        Simplified regime detection returning TRENDING, RANGING, or RANDOM_WALK.

        This is a simplified interface for quick regime classification.
        For detailed analysis, use analyze() method.

        Args:
            prices: Array of price data (minimum length = max(hurst_period, entropy_period))

        Returns:
            str: "TRENDING", "RANGING", or "RANDOM_WALK"

        Raises:
            InsufficientDataError: If not enough data provided
        """
        min_bars = max(self.hurst_period, self.entropy_period)
        if len(prices) < min_bars:
            raise InsufficientDataError(
                f"Precisa de pelo menos {min_bars} barras, fornecido {len(prices)}"
            )

        # Calculate core metrics
        hurst = self._calculate_hurst(prices[-self.hurst_period :])

        # Simplified classification
        if self.HURST_REVERTING_MAX <= hurst <= self.HURST_TRENDING_MIN:
            # Random walk zone: 0.45 <= H <= 0.55
            return "RANDOM_WALK"

        if hurst > self.HURST_TRENDING_MIN:
            # Trending: H > 0.55
            return "TRENDING"

        if hurst < self.HURST_REVERTING_MAX:
            # Mean reverting: H < 0.45
            return "RANGING"

        # Fallback (should not reach here with proper thresholds)
        return "RANDOM_WALK"

    def is_regime_stable(
        self, min_bars: int = 10, max_transition_prob: float = 0.4
    ) -> tuple[bool, str]:
        """
        CRUCIBLE FIX: Require regime stability before trading.

        Avoids entering trades during regime transitions which have
        higher failure rates due to changing market dynamics.

        Args:
            min_bars: Minimum bars in current regime required (default: 10)
            max_transition_prob: Maximum acceptable transition probability (default: 0.4)

        Returns:
            (stable, reason)
            - stable: True if regime is stable enough for trading
            - reason: Human-readable explanation
        """
        # Check minimum bars in current regime
        if self._bars_in_current_regime < min_bars:
            return False, f"Regime too new ({self._bars_in_current_regime}/{min_bars} bars)"

        # Calculate current transition probability from Hurst history
        if len(self._hurst_history) >= 10:
            current_hurst = self._hurst_history[-1]
            transition_prob = self._calculate_transition_probability(current_hurst)

            if transition_prob > max_transition_prob:
                return (
                    False,
                    f"High transition probability ({transition_prob:.1%} > {max_transition_prob:.0%})",
                )

        return True, "Regime stable"


# FORGE v4.0: 7/7 checks
