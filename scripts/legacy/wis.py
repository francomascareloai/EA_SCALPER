from bisect import bisect_right
from dataclasses import dataclass
from typing import List, Tuple


@dataclass(frozen=True)
class Job:
    start: int
    end: int
    profit: int


def compute_p(sorted_jobs: List[Job]) -> List[int]:
    ends = [j.end for j in sorted_jobs]
    p = []
    for i, j in enumerate(sorted_jobs):
        # index of rightmost job with end <= j.start
        idx = bisect_right(ends, j.start) - 1
        if idx == i:  # exclude the job itself when start == previous end
            idx -= 1
        p.append(idx)
    return p


def weighted_interval_scheduling(jobs: List[Tuple[int, int, int]]):
    jobs_obj = [Job(*j) for j in jobs]
    jobs_sorted = sorted(jobs_obj, key=lambda x: x.end)

    p = compute_p(jobs_sorted)
    n = len(jobs_sorted)
    dp = [0] * (n + 1)

    for i in range(1, n + 1):
        incl = jobs_sorted[i - 1].profit + (dp[p[i - 1] + 1] if p[i - 1] >= 0 else 0)
        excl = dp[i - 1]
        dp[i] = max(incl, excl)

    # Reconstruct solution
    chosen = []
    i = n
    while i > 0:
        incl = jobs_sorted[i - 1].profit + (dp[p[i - 1] + 1] if p[i - 1] >= 0 else 0)
        if incl >= dp[i - 1]:
            chosen.append(jobs_sorted[i - 1])
            i = p[i - 1] + 1
        else:
            i -= 1
    chosen.reverse()

    return dp[n], chosen


def _demo():
    jobs = [
        (1, 3, 50),
        (2, 5, 20),
        (3, 10, 100),
        (6, 9, 70),
        (8, 11, 60),
        (9, 12, 80),
    ]
    total, chosen = weighted_interval_scheduling(jobs)
    print("Lucro máximo:", total)
    print("Escolhidos (start,end,profit):", [(c.start, c.end, c.profit) for c in chosen])


if __name__ == "__main__":
    _demo()

