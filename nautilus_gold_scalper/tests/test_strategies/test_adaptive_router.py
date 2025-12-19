import os
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..")))

from nautilus_gold_scalper.src.strategies.adaptive_router import (
    AdaptiveEVRouter,
    Candidate,
    RouterArm,
    RouterContext,
)


def test_router_bootstrap_tie_break_prefers_pullback() -> None:
    router = AdaptiveEVRouter(seed=1, min_trades_to_trust=100)
    ctx = RouterContext(session="NY", regime="TREND", vol_bucket=2)

    cands = [
        Candidate(arm=RouterArm.TREND_BREAKOUT, score=80.0, meta={}),
        Candidate(arm=RouterArm.TREND_PULLBACK, score=80.0, meta={}),
    ]
    sel = router.select(ctx=ctx, candidates=cands, execution_threshold=70.0, daily_dd_pct=0.0, total_dd_pct=0.0)
    assert sel is not None
    assert sel.arm == RouterArm.TREND_PULLBACK


def test_router_learned_ev_selects_best_arm() -> None:
    router = AdaptiveEVRouter(seed=1, min_trades_to_trust=1)
    ctx = RouterContext(session="NY", regime="TREND", vol_bucket=2)

    # Make variance ~0 for deterministic sampling (repeated identical rewards).
    for _ in range(50):
        router.update(ctx=ctx, arm=RouterArm.TREND_PULLBACK, reward_r=0.0)
        router.update(ctx=ctx, arm=RouterArm.TREND_BREAKOUT, reward_r=1.0)

    cands = [
        Candidate(arm=RouterArm.TREND_BREAKOUT, score=75.0, meta={}),
        Candidate(arm=RouterArm.TREND_PULLBACK, score=75.0, meta={}),
    ]
    sel = router.select(ctx=ctx, candidates=cands, execution_threshold=70.0, daily_dd_pct=0.0, total_dd_pct=0.0)
    assert sel is not None
    assert sel.arm == RouterArm.TREND_BREAKOUT

