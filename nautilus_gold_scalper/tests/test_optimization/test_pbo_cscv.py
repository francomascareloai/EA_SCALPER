from __future__ import annotations

from src.optimization.stress.pbo_cscv import (
    CandidateWindowMetrics,
    compute_candidate_set_pbo_rank_based,
)


def test_pbo_zero_when_is_winner_also_oos_winner() -> None:
    # Two candidates, three windows.
    # Candidate 1 always wins IS and also wins OOS -> u=0 -> no failures.
    c1 = CandidateWindowMetrics(
        candidate_id=1, is_scores=[3.0, 3.0, 3.0], oos_scores=[2.0, 2.0, 2.0]
    )
    c2 = CandidateWindowMetrics(
        candidate_id=2, is_scores=[1.0, 1.0, 1.0], oos_scores=[1.0, 1.0, 1.0]
    )

    pbo = compute_candidate_set_pbo_rank_based([c1, c2])
    assert pbo == 0.0


def test_pbo_one_when_is_winner_is_bottom_half_oos() -> None:
    # Two candidates, three windows.
    # Candidate 1 always wins IS but always loses OOS -> u=1 -> failures in all windows.
    c1 = CandidateWindowMetrics(
        candidate_id=1, is_scores=[3.0, 3.0, 3.0], oos_scores=[0.0, 0.0, 0.0]
    )
    c2 = CandidateWindowMetrics(
        candidate_id=2, is_scores=[1.0, 1.0, 1.0], oos_scores=[1.0, 1.0, 1.0]
    )

    pbo = compute_candidate_set_pbo_rank_based([c1, c2])
    assert pbo == 1.0


def test_pbo_half_mixed_windows() -> None:
    # Candidate 1 wins IS always; OOS alternates good/bad.
    c1 = CandidateWindowMetrics(
        candidate_id=1, is_scores=[3.0, 3.0, 3.0, 3.0], oos_scores=[2.0, 0.0, 2.0, 0.0]
    )
    c2 = CandidateWindowMetrics(
        candidate_id=2, is_scores=[1.0, 1.0, 1.0, 1.0], oos_scores=[1.0, 1.0, 1.0, 1.0]
    )

    pbo = compute_candidate_set_pbo_rank_based([c1, c2])
    assert pbo == 0.5


def test_pbo_fail_closed_on_insufficient_candidates() -> None:
    c1 = CandidateWindowMetrics(candidate_id=1, is_scores=[1.0], oos_scores=[1.0])
    assert compute_candidate_set_pbo_rank_based([c1]) == 1.0


def test_pbo_raises_on_mismatched_window_lengths() -> None:
    c1 = CandidateWindowMetrics(candidate_id=1, is_scores=[1.0, 1.0], oos_scores=[1.0, 1.0])
    c2 = CandidateWindowMetrics(candidate_id=2, is_scores=[1.0], oos_scores=[1.0])

    try:
        compute_candidate_set_pbo_rank_based([c1, c2])
    except ValueError as e:
        assert "same number of windows" in str(e)
    else:
        raise AssertionError("Expected ValueError")
