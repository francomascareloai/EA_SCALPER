"""
Adaptive strategy router (Apex-first).

Chooses between multiple candidate modes using an EV-centric policy with drawdown penalties.

Key properties:
- No look-ahead: updates only on realized trade close.
- Conservative bootstrap: uses priors + minimum-sample rules before trusting learned edges.
- Context-aware: learns per (session, regime, volatility_bucket) to avoid mixing regimes.
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import Any

import numpy as np


class RouterArm(str, Enum):
    SMC = "smc"
    TREND_PULLBACK = "trend_pullback"
    TREND_BREAKOUT = "trend_breakout"
    MEAN_REVERT = "mean_revert"


@dataclass(frozen=True, slots=True)
class RouterContext:
    session: str
    regime: str
    vol_bucket: int  # 0..4

    def key(self) -> tuple[str, str, int]:
        return (self.session, self.regime, self.vol_bucket)


@dataclass(slots=True)
class ArmStats:
    n: int = 0
    mean: float = 0.0
    m2: float = 0.0  # Welford accumulator

    def variance(self) -> float:
        if self.n < 2:
            return 1.0
        return max(1e-9, self.m2 / float(self.n - 1))

    def update(self, x: float) -> None:
        self.n += 1
        delta = x - self.mean
        self.mean += delta / float(self.n)
        delta2 = x - self.mean
        self.m2 += delta * delta2


@dataclass(frozen=True, slots=True)
class Candidate:
    arm: RouterArm
    score: float  # 0..100 “confidence/quality”
    meta: dict[str, Any]


@dataclass(frozen=True, slots=True)
class Selection:
    arm: RouterArm
    utility: float
    reason: str
    sampled_ev: float
    dd_penalty: float


class AdaptiveEVRouter:
    """
    Contextual bandit selecting by EV (R-multiples) with drawdown penalty.

    Reward is expressed in R-multiples:
        R = net_pnl_usd / risk_usd_at_entry
    """

    def __init__(
        self,
        *,
        seed: int = 1337,
        prior_mean: float = 0.0,
        prior_var: float = 1.0,
        min_trades_to_trust: int = 30,
        score_weight: float = 0.10,  # utility bonus from deterministic score (in R units)
        dd_penalty_total: float = 0.20,  # penalty in R units at 100% of total DD ref
        dd_penalty_daily: float = 0.10,  # penalty in R units at 100% of daily DD ref
        daily_dd_ref: float = 3.0,
        total_dd_ref: float = 5.0,
    ) -> None:
        self._rng = np.random.default_rng(int(seed))
        self._prior_mean = float(prior_mean)
        self._prior_var = float(max(1e-9, prior_var))
        self._min_trades_to_trust = int(max(0, min_trades_to_trust))
        self._score_weight = float(max(0.0, score_weight))
        self._dd_penalty_total = float(max(0.0, dd_penalty_total))
        self._dd_penalty_daily = float(max(0.0, dd_penalty_daily))
        self._daily_dd_ref = float(max(1e-9, daily_dd_ref))
        self._total_dd_ref = float(max(1e-9, total_dd_ref))

        self._stats: dict[tuple[str, str, int], dict[RouterArm, ArmStats]] = {}

    def _get_stats(self, ctx: RouterContext, arm: RouterArm) -> ArmStats:
        key = ctx.key()
        by_arm = self._stats.get(key)
        if by_arm is None:
            by_arm = {}
            self._stats[key] = by_arm
        st = by_arm.get(arm)
        if st is None:
            st = ArmStats()
            by_arm[arm] = st
        return st

    def update(self, *, ctx: RouterContext, arm: RouterArm, reward_r: float) -> None:
        """
        Update with a realized reward in R-multiples.
        Reward is clipped to keep the learner robust to outliers.
        """
        r = float(reward_r)
        r = float(max(-3.0, min(3.0, r)))
        self._get_stats(ctx, arm).update(r)

    def _dd_penalty(self, *, daily_dd_pct: float, total_dd_pct: float) -> float:
        d = max(0.0, float(daily_dd_pct)) / self._daily_dd_ref
        t = max(0.0, float(total_dd_pct)) / self._total_dd_ref
        d = max(0.0, min(2.0, d))
        t = max(0.0, min(2.0, t))
        return (d * self._dd_penalty_daily) + (t * self._dd_penalty_total)

    def _sample_ev(self, st: ArmStats) -> float:
        # Gaussian Thompson sampling over mean reward.
        if st.n <= 0:
            return float(self._rng.normal(self._prior_mean, np.sqrt(self._prior_var)))
        var = st.variance()
        std = float(np.sqrt(var / float(max(1, st.n))))
        return float(self._rng.normal(st.mean, max(1e-6, std)))

    def select(
        self,
        *,
        ctx: RouterContext,
        candidates: list[Candidate],
        execution_threshold: float,
        daily_dd_pct: float,
        total_dd_pct: float,
        prefer: RouterArm = RouterArm.TREND_PULLBACK,
    ) -> Selection | None:
        """
        Select the best candidate by utility.

        Eligibility:
        - candidate.score >= execution_threshold

        Utility:
        - sampled_ev (learned) + score_bonus - dd_penalty

        Bootstrap:
        - If an arm has fewer than min_trades_to_trust in this context, its sampled EV is treated as 0.
        """
        if not candidates:
            return None

        dd_pen = self._dd_penalty(daily_dd_pct=daily_dd_pct, total_dd_pct=total_dd_pct)
        thr = float(execution_threshold)

        best: Selection | None = None
        best_score: float = 0.0

        for c in candidates:
            if float(c.score) < thr:
                continue

            st = self._get_stats(ctx, c.arm)
            trusted = st.n >= self._min_trades_to_trust
            sampled = self._sample_ev(st) if trusted else 0.0

            s_norm = (float(c.score) - thr) / 30.0
            s_norm = max(0.0, min(1.0, s_norm))
            score_bonus = self._score_weight * s_norm

            util = float(sampled + score_bonus - dd_pen)
            sel = Selection(
                arm=c.arm,
                utility=util,
                reason="trusted_ev" if trusted else "bootstrap_score",
                sampled_ev=float(sampled),
                dd_penalty=float(dd_pen),
            )

            if best is None:
                best = sel
                best_score = float(c.score)
                continue

            if sel.utility > best.utility + 1e-9:
                best = sel
                best_score = float(c.score)
                continue

            if abs(sel.utility - best.utility) <= 1e-9:
                if float(c.score) > best_score + 1e-9:
                    best = sel
                    best_score = float(c.score)
                    continue
                if abs(float(c.score) - best_score) <= 1e-9:
                    if sel.arm == prefer and best.arm != prefer:
                        best = sel
                        best_score = float(c.score)

        return best

