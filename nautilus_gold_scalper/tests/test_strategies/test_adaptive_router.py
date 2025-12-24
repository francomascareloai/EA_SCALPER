"""
Comprehensive tests for AdaptiveEVRouter.

Tests Thompson sampling, context learning, DD penalty, and bootstrap logic.
"""
import numpy as np
import pytest

from nautilus_gold_scalper.src.strategies.adaptive_router import (
    AdaptiveEVRouter,
    ArmStats,
    Candidate,
    RouterArm,
    RouterContext,
    Selection,
)


class TestRouterArm:
    """Test RouterArm enum."""

    def test_arm_values(self) -> None:
        """RouterArm has expected values."""
        assert RouterArm.SMC.value == "smc"
        assert RouterArm.TREND_PULLBACK.value == "trend_pullback"
        assert RouterArm.TREND_BREAKOUT.value == "trend_breakout"
        assert RouterArm.MEAN_REVERT.value == "mean_revert"

    def test_arm_count(self) -> None:
        """RouterArm has 4 arms."""
        assert len(RouterArm) == 4


class TestRouterContext:
    """Test RouterContext dataclass."""

    def test_context_key(self) -> None:
        """Context key is (session, regime, vol_bucket) tuple."""
        ctx = RouterContext(session="LONDON", regime="TRENDING", vol_bucket=3)
        assert ctx.key() == ("LONDON", "TRENDING", 3)

    def test_different_contexts_different_keys(self) -> None:
        """Different contexts produce different keys."""
        ctx1 = RouterContext(session="LONDON", regime="TRENDING", vol_bucket=3)
        ctx2 = RouterContext(session="NY", regime="TRENDING", vol_bucket=3)
        ctx3 = RouterContext(session="LONDON", regime="REVERTING", vol_bucket=3)
        ctx4 = RouterContext(session="LONDON", regime="TRENDING", vol_bucket=2)

        assert ctx1.key() != ctx2.key()
        assert ctx1.key() != ctx3.key()
        assert ctx1.key() != ctx4.key()


class TestArmStats:
    """Test ArmStats for Welford algorithm."""

    def test_initial_state(self) -> None:
        """Initial stats are zero."""
        stats = ArmStats()
        assert stats.n == 0
        assert stats.mean == 0.0
        assert stats.m2 == 0.0

    def test_single_update(self) -> None:
        """Single update sets mean correctly."""
        stats = ArmStats()
        stats.update(5.0)
        assert stats.n == 1
        assert stats.mean == 5.0

    def test_multiple_updates(self) -> None:
        """Multiple updates compute mean correctly."""
        stats = ArmStats()
        values = [1.0, 2.0, 3.0, 4.0, 5.0]
        for v in values:
            stats.update(v)

        assert stats.n == 5
        assert stats.mean == pytest.approx(3.0)

    def test_variance_with_small_sample(self) -> None:
        """Variance returns 1.0 for small samples."""
        stats = ArmStats()
        assert stats.variance() == 1.0  # n=0
        stats.update(5.0)
        assert stats.variance() == 1.0  # n=1

    def test_variance_calculation(self) -> None:
        """Variance is calculated correctly for larger samples."""
        stats = ArmStats()
        values = [2.0, 4.0, 6.0, 8.0, 10.0]  # mean=6, var=10
        for v in values:
            stats.update(v)

        # Sample variance = sum((x-mean)^2) / (n-1) = 40/4 = 10
        assert stats.variance() == pytest.approx(10.0)


class TestBootstrap:
    """Test bootstrap behavior before min_trades_to_trust."""

    def test_bootstrap_uses_prior(self) -> None:
        """Before min_trades, router samples from prior."""
        router = AdaptiveEVRouter(
            seed=42,
            min_trades_to_trust=100,
            prior_mean=0.0,
            prior_var=1.0,
        )
        ctx = RouterContext(session="NY", regime="TREND", vol_bucket=2)

        cands = [
            Candidate(arm=RouterArm.TREND_PULLBACK, score=80.0, meta={}),
            Candidate(arm=RouterArm.SMC, score=80.0, meta={}),
        ]

        # With only 10 trades, still in bootstrap (need 100)
        for _ in range(10):
            router.update(ctx=ctx, arm=RouterArm.TREND_PULLBACK, reward_r=1.0)

        sel = router.select(
            ctx=ctx,
            candidates=cands,
            execution_threshold=70.0,
            daily_dd_pct=0.0,
            total_dd_pct=0.0,
        )
        # In bootstrap, sampled_ev should be 0 (not using learned values)
        assert sel is not None
        assert sel.reason == "bootstrap_score"
        assert sel.sampled_ev == 0.0

    def test_trusted_after_min_trades(self) -> None:
        """After min_trades, router uses learned EV."""
        router = AdaptiveEVRouter(
            seed=42,
            min_trades_to_trust=30,
        )
        ctx = RouterContext(session="NY", regime="TREND", vol_bucket=2)

        # Train past threshold
        for _ in range(35):
            router.update(ctx=ctx, arm=RouterArm.TREND_PULLBACK, reward_r=1.0)

        cands = [
            Candidate(arm=RouterArm.TREND_PULLBACK, score=80.0, meta={}),
        ]

        sel = router.select(
            ctx=ctx,
            candidates=cands,
            execution_threshold=70.0,
            daily_dd_pct=0.0,
            total_dd_pct=0.0,
        )
        assert sel is not None
        assert sel.reason == "trusted_ev"
        assert sel.sampled_ev != 0.0


class TestThompsonSampling:
    """Test Thompson sampling selection logic."""

    def test_higher_ev_arm_selected(self) -> None:
        """Arm with higher learned EV is selected more often."""
        router = AdaptiveEVRouter(seed=42, min_trades_to_trust=5)
        ctx = RouterContext(session="NY", regime="TREND", vol_bucket=2)

        # Train: BREAKOUT gets 1.0R, PULLBACK gets 0.0R
        for _ in range(50):
            router.update(ctx=ctx, arm=RouterArm.TREND_BREAKOUT, reward_r=1.0)
            router.update(ctx=ctx, arm=RouterArm.TREND_PULLBACK, reward_r=0.0)

        cands = [
            Candidate(arm=RouterArm.TREND_BREAKOUT, score=75.0, meta={}),
            Candidate(arm=RouterArm.TREND_PULLBACK, score=75.0, meta={}),
        ]

        # Run selection many times, BREAKOUT should win most
        wins = {"BREAKOUT": 0, "PULLBACK": 0}
        for seed in range(100):
            router._rng = np.random.default_rng(seed)
            sel = router.select(
                ctx=ctx,
                candidates=cands,
                execution_threshold=70.0,
                daily_dd_pct=0.0,
                total_dd_pct=0.0,
            )
            if sel is not None:
                if sel.arm == RouterArm.TREND_BREAKOUT:
                    wins["BREAKOUT"] += 1
                else:
                    wins["PULLBACK"] += 1

        # BREAKOUT should win majority (>80%)
        assert wins["BREAKOUT"] > 80

    def test_prefer_pullback_tiebreak(self) -> None:
        """When tied, prefer TREND_PULLBACK."""
        router = AdaptiveEVRouter(seed=1, min_trades_to_trust=100)
        ctx = RouterContext(session="NY", regime="TREND", vol_bucket=2)

        cands = [
            Candidate(arm=RouterArm.TREND_BREAKOUT, score=80.0, meta={}),
            Candidate(arm=RouterArm.TREND_PULLBACK, score=80.0, meta={}),
        ]
        sel = router.select(
            ctx=ctx,
            candidates=cands,
            execution_threshold=70.0,
            daily_dd_pct=0.0,
            total_dd_pct=0.0,
            prefer=RouterArm.TREND_PULLBACK,
        )
        assert sel is not None
        assert sel.arm == RouterArm.TREND_PULLBACK


class TestContextLearning:
    """Test per-context learning."""

    def test_different_contexts_independent(self) -> None:
        """Learning in one context doesn't affect another."""
        router = AdaptiveEVRouter(seed=42, min_trades_to_trust=5)

        ctx_london = RouterContext(session="LONDON", regime="TREND", vol_bucket=2)
        ctx_ny = RouterContext(session="NY", regime="TREND", vol_bucket=2)

        # Train only in London context
        for _ in range(50):
            router.update(ctx=ctx_london, arm=RouterArm.SMC, reward_r=2.0)

        # NY context should still be in bootstrap
        cands = [Candidate(arm=RouterArm.SMC, score=80.0, meta={})]
        sel = router.select(
            ctx=ctx_ny,
            candidates=cands,
            execution_threshold=70.0,
            daily_dd_pct=0.0,
            total_dd_pct=0.0,
        )
        assert sel is not None
        assert sel.reason == "bootstrap_score"

        # London context should be trusted
        sel = router.select(
            ctx=ctx_london,
            candidates=cands,
            execution_threshold=70.0,
            daily_dd_pct=0.0,
            total_dd_pct=0.0,
        )
        assert sel is not None
        assert sel.reason == "trusted_ev"

    def test_regime_creates_different_context(self) -> None:
        """Different regimes are separate contexts."""
        router = AdaptiveEVRouter(seed=42, min_trades_to_trust=5)

        ctx_trend = RouterContext(session="LONDON", regime="TREND", vol_bucket=2)
        ctx_revert = RouterContext(session="LONDON", regime="REVERT", vol_bucket=2)

        # Train only in TREND
        for _ in range(50):
            router.update(ctx=ctx_trend, arm=RouterArm.SMC, reward_r=2.0)

        # REVERT should be bootstrap
        cands = [Candidate(arm=RouterArm.SMC, score=80.0, meta={})]
        sel = router.select(
            ctx=ctx_revert,
            candidates=cands,
            execution_threshold=70.0,
            daily_dd_pct=0.0,
            total_dd_pct=0.0,
        )
        assert sel is not None
        assert sel.reason == "bootstrap_score"


class TestDDPenalty:
    """Test drawdown penalty application."""

    def test_no_dd_no_penalty(self) -> None:
        """Zero DD means zero penalty."""
        router = AdaptiveEVRouter(seed=42, min_trades_to_trust=100)
        ctx = RouterContext(session="NY", regime="TREND", vol_bucket=2)

        cands = [Candidate(arm=RouterArm.TREND_PULLBACK, score=80.0, meta={})]
        sel = router.select(
            ctx=ctx,
            candidates=cands,
            execution_threshold=70.0,
            daily_dd_pct=0.0,
            total_dd_pct=0.0,
        )
        assert sel is not None
        assert sel.dd_penalty == 0.0

    def test_daily_dd_applies_penalty(self) -> None:
        """Daily DD applies penalty proportional to reference."""
        router = AdaptiveEVRouter(
            seed=42,
            min_trades_to_trust=100,
            dd_penalty_daily=0.10,
            daily_dd_ref=3.0,
        )
        ctx = RouterContext(session="NY", regime="TREND", vol_bucket=2)

        cands = [Candidate(arm=RouterArm.TREND_PULLBACK, score=80.0, meta={})]

        # 3% daily DD = 100% of reference = 0.10 penalty
        sel = router.select(
            ctx=ctx,
            candidates=cands,
            execution_threshold=70.0,
            daily_dd_pct=3.0,
            total_dd_pct=0.0,
        )
        assert sel is not None
        assert sel.dd_penalty == pytest.approx(0.10, rel=0.01)

    def test_total_dd_applies_penalty(self) -> None:
        """Total DD applies penalty proportional to reference."""
        router = AdaptiveEVRouter(
            seed=42,
            min_trades_to_trust=100,
            dd_penalty_total=0.20,
            total_dd_ref=5.0,
        )
        ctx = RouterContext(session="NY", regime="TREND", vol_bucket=2)

        cands = [Candidate(arm=RouterArm.TREND_PULLBACK, score=80.0, meta={})]

        # 5% total DD = 100% of reference = 0.20 penalty
        sel = router.select(
            ctx=ctx,
            candidates=cands,
            execution_threshold=70.0,
            daily_dd_pct=0.0,
            total_dd_pct=5.0,
        )
        assert sel is not None
        assert sel.dd_penalty == pytest.approx(0.20, rel=0.01)

    def test_combined_dd_penalty(self) -> None:
        """Both DD sources combine."""
        router = AdaptiveEVRouter(
            seed=42,
            min_trades_to_trust=100,
            dd_penalty_daily=0.10,
            dd_penalty_total=0.20,
            daily_dd_ref=3.0,
            total_dd_ref=5.0,
        )
        ctx = RouterContext(session="NY", regime="TREND", vol_bucket=2)

        cands = [Candidate(arm=RouterArm.TREND_PULLBACK, score=80.0, meta={})]

        # 3% daily + 5% total = 0.10 + 0.20 = 0.30
        sel = router.select(
            ctx=ctx,
            candidates=cands,
            execution_threshold=70.0,
            daily_dd_pct=3.0,
            total_dd_pct=5.0,
        )
        assert sel is not None
        assert sel.dd_penalty == pytest.approx(0.30, rel=0.01)

    def test_dd_penalty_reduces_utility(self) -> None:
        """DD penalty reduces arm utility."""
        router = AdaptiveEVRouter(
            seed=42,
            min_trades_to_trust=100,
            dd_penalty_daily=0.50,  # Heavy penalty
            daily_dd_ref=3.0,
        )
        ctx = RouterContext(session="NY", regime="TREND", vol_bucket=2)

        cands = [Candidate(arm=RouterArm.TREND_PULLBACK, score=80.0, meta={})]

        # No DD
        sel1 = router.select(
            ctx=ctx,
            candidates=cands,
            execution_threshold=70.0,
            daily_dd_pct=0.0,
            total_dd_pct=0.0,
        )

        # High DD
        sel2 = router.select(
            ctx=ctx,
            candidates=cands,
            execution_threshold=70.0,
            daily_dd_pct=3.0,
            total_dd_pct=0.0,
        )

        assert sel1 is not None and sel2 is not None
        assert sel2.utility < sel1.utility


class TestCandidateFiltering:
    """Test candidate filtering by threshold."""

    def test_below_threshold_filtered(self) -> None:
        """Candidates below threshold are not selected."""
        router = AdaptiveEVRouter(seed=42, min_trades_to_trust=100)
        ctx = RouterContext(session="NY", regime="TREND", vol_bucket=2)

        cands = [
            Candidate(arm=RouterArm.TREND_PULLBACK, score=60.0, meta={}),
            Candidate(arm=RouterArm.TREND_BREAKOUT, score=50.0, meta={}),
        ]

        sel = router.select(
            ctx=ctx,
            candidates=cands,
            execution_threshold=70.0,  # Both below
            daily_dd_pct=0.0,
            total_dd_pct=0.0,
        )
        assert sel is None

    def test_above_threshold_selected(self) -> None:
        """Candidates above threshold are eligible."""
        router = AdaptiveEVRouter(seed=42, min_trades_to_trust=100)
        ctx = RouterContext(session="NY", regime="TREND", vol_bucket=2)

        cands = [
            Candidate(arm=RouterArm.TREND_PULLBACK, score=80.0, meta={}),
            Candidate(arm=RouterArm.TREND_BREAKOUT, score=50.0, meta={}),
        ]

        sel = router.select(
            ctx=ctx,
            candidates=cands,
            execution_threshold=70.0,
            daily_dd_pct=0.0,
            total_dd_pct=0.0,
        )
        assert sel is not None
        assert sel.arm == RouterArm.TREND_PULLBACK  # Only one above threshold

    def test_empty_candidates_returns_none(self) -> None:
        """Empty candidate list returns None."""
        router = AdaptiveEVRouter(seed=42, min_trades_to_trust=100)
        ctx = RouterContext(session="NY", regime="TREND", vol_bucket=2)

        sel = router.select(
            ctx=ctx,
            candidates=[],
            execution_threshold=70.0,
            daily_dd_pct=0.0,
            total_dd_pct=0.0,
        )
        assert sel is None


class TestScoreBonus:
    """Test score bonus application."""

    def test_higher_score_gets_bonus(self) -> None:
        """Higher score translates to higher utility bonus."""
        router = AdaptiveEVRouter(
            seed=42,
            min_trades_to_trust=100,
            score_weight=0.10,
        )
        ctx = RouterContext(session="NY", regime="TREND", vol_bucket=2)

        # Both above threshold, but one has higher score
        cand_high = Candidate(arm=RouterArm.TREND_PULLBACK, score=100.0, meta={})
        cand_low = Candidate(arm=RouterArm.TREND_BREAKOUT, score=70.0, meta={})

        sel_high = router.select(
            ctx=ctx,
            candidates=[cand_high],
            execution_threshold=70.0,
            daily_dd_pct=0.0,
            total_dd_pct=0.0,
        )
        sel_low = router.select(
            ctx=ctx,
            candidates=[cand_low],
            execution_threshold=70.0,
            daily_dd_pct=0.0,
            total_dd_pct=0.0,
        )

        assert sel_high is not None and sel_low is not None
        assert sel_high.utility > sel_low.utility


class TestRewardClipping:
    """Test reward clipping for robustness."""

    def test_extreme_positive_reward_clipped(self) -> None:
        """Extreme positive rewards are clipped to +3."""
        router = AdaptiveEVRouter(seed=42, min_trades_to_trust=5)
        ctx = RouterContext(session="NY", regime="TREND", vol_bucket=2)

        # Feed extreme reward
        for _ in range(10):
            router.update(ctx=ctx, arm=RouterArm.SMC, reward_r=10.0)

        stats = router._get_stats(ctx, RouterArm.SMC)
        # Mean should be ~3.0 (clipped value)
        assert stats.mean == pytest.approx(3.0)

    def test_extreme_negative_reward_clipped(self) -> None:
        """Extreme negative rewards are clipped to -3."""
        router = AdaptiveEVRouter(seed=42, min_trades_to_trust=5)
        ctx = RouterContext(session="NY", regime="TREND", vol_bucket=2)

        # Feed extreme negative reward
        for _ in range(10):
            router.update(ctx=ctx, arm=RouterArm.SMC, reward_r=-10.0)

        stats = router._get_stats(ctx, RouterArm.SMC)
        # Mean should be ~-3.0 (clipped value)
        assert stats.mean == pytest.approx(-3.0)


class TestSelection:
    """Test Selection dataclass."""

    def test_selection_fields(self) -> None:
        """Selection has all expected fields."""
        sel = Selection(
            arm=RouterArm.SMC,
            utility=0.5,
            reason="test",
            sampled_ev=0.3,
            dd_penalty=0.1,
        )
        assert sel.arm == RouterArm.SMC
        assert sel.utility == 0.5
        assert sel.reason == "test"
        assert sel.sampled_ev == 0.3
        assert sel.dd_penalty == 0.1
