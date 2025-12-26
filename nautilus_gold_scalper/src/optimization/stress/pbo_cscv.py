"""Candidate-set PBO (CSCV-like, rank-based) for optimization.

This module provides a *candidate-set* Probability of Backtest Overfitting estimate
computed from a family of candidates evaluated on the *same* set of IS/OOS windows.

Important:
- This is not full CPCV (combinatorial purged CV) across all fold combinations.
- It is a lightweight CSCV-style estimate derived from the existing inline WFA windows.

Definition implemented (rank-based CSCV proxy):

For each window w:
1) Identify the candidate c* with best in-sample (IS) score.
2) Compute the out-of-sample (OOS) rank percentile u_w of c* among all candidates.
3) A window is a "failure" if u_w > 0.5 (IS-winner falls in bottom half OOS).

PBO = mean_w 1(u_w > 0.5)

This yields PBO in [0, 1]. Higher is worse (more overfitting).
"""

from __future__ import annotations

from collections.abc import Iterable, Sequence
from dataclasses import dataclass
from typing import Any

import numpy as np


@dataclass(frozen=True, slots=True)
class CandidateWindowMetrics:
    """Per-window IS/OOS scores for a single candidate."""

    candidate_id: int
    is_scores: list[float]
    oos_scores: list[float]


def _finite(x: float) -> bool:
    return bool(np.isfinite(float(x)))


def compute_candidate_set_pbo_rank_based(
    candidates: Sequence[CandidateWindowMetrics],
    *,
    fail_closed: bool = True,
) -> float:
    """Compute candidate-set PBO (rank-based CSCV proxy) in [0, 1].

    Args:
        candidates: Per-candidate IS/OOS score vectors. All candidates must share
            the same number of windows.
        fail_closed: If True, return 1.0 when PBO cannot be computed (insufficient
            candidates/windows/finite values). If False, returns 0.0.

    Returns:
        PBO estimate in [0, 1].
    """

    if len(candidates) < 2:
        return 1.0 if fail_closed else 0.0

    n_windows = len(candidates[0].is_scores)
    if n_windows < 1:
        return 1.0 if fail_closed else 0.0

    for c in candidates:
        if len(c.is_scores) != n_windows or len(c.oos_scores) != n_windows:
            raise ValueError("All candidates must have the same number of windows")

    failures = 0
    used = 0

    for w in range(n_windows):
        # Build vectors for this window.
        is_vals: list[tuple[int, float]] = []
        oos_map: dict[int, float] = {}

        for c in candidates:
            is_v = float(c.is_scores[w])
            oos_v = float(c.oos_scores[w])
            if _finite(is_v) and _finite(oos_v):
                is_vals.append((int(c.candidate_id), is_v))
                oos_map[int(c.candidate_id)] = oos_v

        # Need at least 2 candidates to rank.
        if len(is_vals) < 2:
            continue

        # Pick IS winner (max IS score). Ties: choose smallest candidate_id for determinism.
        is_vals.sort(key=lambda t: (t[1], -t[0]), reverse=True)
        best_id = is_vals[0][0]

        # Rank winner by OOS score (higher is better).
        oos_vals = [float(oos_map[cid]) for cid, _ in is_vals]
        best_oos = float(oos_map[best_id])

        # Percentile rank u in [0,1]: 0=best, 1=worst. Use average rank for ties.
        # Formula:
        #   rank = 1 + count(oos > best) + 0.5*count(oos == best)
        #   u = (rank - 1) / (n - 1)
        n = len(oos_vals)
        if n < 2:
            continue

        gt = sum(1 for v in oos_vals if v > best_oos)
        eq = sum(1 for v in oos_vals if v == best_oos)
        rank = 1.0 + float(gt) + 0.5 * float(eq - 1)

        u = (rank - 1.0) / float(n - 1)
        u = float(max(0.0, min(1.0, u)))

        if u > 0.5:
            failures += 1
        used += 1

    if used <= 0:
        return 1.0 if fail_closed else 0.0

    pbo = float(failures) / float(used)
    pbo = float(max(0.0, min(1.0, pbo)))
    return pbo


def compute_candidate_set_pbo_from_window_dicts(
    window_dicts: Iterable[dict[str, Any]],
    *,
    candidate_id_key: str = "candidate_id",
    is_key: str = "is_scores",
    oos_key: str = "oos_scores",
) -> float:
    """Convenience wrapper to compute PBO from JSON-friendly dicts."""

    candidates: list[CandidateWindowMetrics] = []
    for d in window_dicts:
        candidates.append(
            CandidateWindowMetrics(
                candidate_id=int(d[candidate_id_key]),
                is_scores=[float(x) for x in d[is_key]],
                oos_scores=[float(x) for x in d[oos_key]],
            )
        )

    return compute_candidate_set_pbo_rank_based(candidates)
