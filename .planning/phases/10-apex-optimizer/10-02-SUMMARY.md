## Goal
Reduce RAM usage in optimization runs (grid/random) by avoiding full materialization of samples and by supporting bounded in-memory results + optional streaming to disk.

## Current state
- `grid` search iterates lazily over the Cartesian product (no prebuilt grid), with hard `max_grid_size` fail-fast.
- `random` search uses a batch-streaming LHS-like generator (bounded batch RAM, reproducible via seed).
- Optional result streaming: each trial result can be appended via callback and persisted to a Parquet *partitioned dataset* (no read/concat/write).
- Optional RAM cap: keep only top-N results in memory (`max_results_in_ram`).

## Decisions made
- Add `SearchStrategy` support for `on_result` callback + `max_results_in_ram`, implemented via `_record_result()`.
- Implement streaming LHS as batch-based (practical compromise vs true global LHS) to keep memory bounded.
- Persist streaming results as partitioned Parquet parts to avoid O(N) rewrite costs.

## Files changed
- `nautilus_gold_scalper/src/optimization/config.py`
- `nautilus_gold_scalper/src/optimization/optimizer.py`
- `nautilus_gold_scalper/src/optimization/search/base.py`
- `nautilus_gold_scalper/src/optimization/search/grid.py`
- `nautilus_gold_scalper/src/optimization/search/random.py`
- `nautilus_gold_scalper/src/optimization/streaming/__init__.py`
- `nautilus_gold_scalper/src/optimization/streaming/generator.py`
- `nautilus_gold_scalper/src/optimization/streaming/persistence.py`

## Commands run
- `./.venv/bin/mypy --strict nautilus_gold_scalper/src/optimization/**/*.py`
- `./.venv/bin/pytest -q nautilus_gold_scalper/tests/test_optimization/test_grid_search.py nautilus_gold_scalper/tests/test_optimization/test_random_search.py`

## Validation
- mypy strict (optimization subtree): PASS
- optimization unit tests: PASS

## How to use (YAML)
Add to your config:

```yaml
output:
  streaming:
    results_parquet: "results"   # relative to session output dir
    flush_every: 50
    max_results_in_ram: 200
```

This writes partitions to:
- `<output.dir>/<timestamp>/results/results_dataset/part-00000.parquet`, etc.

## Next steps
- Add a small CLI override for `output.streaming.*` so you can enable streaming without editing YAML.
- If Optuna RAM becomes an issue, configure Optuna to use SQLite storage to avoid keeping all trials in memory.
