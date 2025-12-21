"""
YAML-driven grid search (fast) using NautilusTrader bars feed + evaluation for a 20-day target.

Goal: converge quickly on candidate configs for Apex eval:
- Account size: $50k
- Target: +$3000 within <=20 operated days

Design:
- Bars feed (M5) for fast screening.
- Grid spec in YAML using dotpaths to overwrite `configs/strategy_config.yaml`.
- Special prefixes:
  - `runner.*` => BacktestRunner(...) kwargs
  - `run.*`    => BacktestRunner.run(...) kwargs (excluding start/end which come from CLI)
  - otherwise  => config_overrides dotpath (deep-merged into strategy_config.yaml)
"""

from __future__ import annotations

import argparse
import json
import random
from dataclasses import dataclass
from datetime import datetime, timezone
from itertools import product
from pathlib import Path
from typing import Any, cast

import pandas as pd
import yaml
from nautilus_trader.model.data import Bar, BarSpecification, BarType
from nautilus_trader.model.enums import AggregationSource, BarAggregation, PriceType
from nautilus_trader.model.identifiers import Venue
from nautilus_trader.persistence.wranglers import BarDataWrangler

from ..backtest.run_backtest import (
    BacktestRunner,
    Gateway,
    Product,
    _quantize_to_tick,
    create_mgc_instrument,
    create_xauusd_instrument,
    load_m5_bars_csv,
)

_MISSING = object()


@dataclass(frozen=True, slots=True)
class EvalResult:
    params: dict[str, object]
    final_balance: float
    total_pnl: float
    trades: int
    terminated: bool
    days_to_target: int | None
    operated_days: int | None
    positive_days_ratio: float | None
    max_daily_share: float | None
    output_dir: str


def _set_deep(dst: dict[str, Any], dotpath: str, value: Any) -> None:
    cur: dict[str, Any] = dst
    parts = [p for p in dotpath.split(".") if p]
    if not parts:
        raise ValueError("Empty dotpath")
    for p in parts[:-1]:
        nxt = cur.get(p)
        if not isinstance(nxt, dict):
            nxt = {}
            cur[p] = nxt
        cur = cast(dict[str, Any], nxt)
    cur[parts[-1]] = value


def _normalize_map(obj: object) -> dict[str, list[object]]:
    if not isinstance(obj, dict):
        return {}
    out: dict[str, list[object]] = {}
    for k, v in obj.items():
        if v is None:
            continue
        if isinstance(v, list):
            out[str(k)] = [cast(object, x) for x in v]
        else:
            out[str(k)] = [cast(object, v)]
    return out


def _load_grid_spec(path: Path, groups: list[str] | None) -> dict[str, list[object]]:
    if not path.exists():
        raise FileNotFoundError(f"Grid config not found: {path}")
    with open(path, encoding="utf-8") as f:
        spec = yaml.safe_load(f) or {}
    if not isinstance(spec, dict):
        raise ValueError("Grid config must be a mapping")

    grid = _normalize_map(spec.get("grid"))
    groups_obj = spec.get("groups")
    if not isinstance(groups_obj, dict):
        return grid

    selected = groups or []
    if not selected:
        default_groups = spec.get("default_groups")
        if isinstance(default_groups, list) and default_groups:
            selected = [str(x) for x in default_groups if str(x).strip()]
        else:
            selected = [str(k) for k in groups_obj.keys()]
    merged = dict(grid)
    for g in selected:
        grp = groups_obj.get(g)
        if not isinstance(grp, dict):
            raise ValueError(f"Invalid group mapping for {g!r} in {path}")
        merged.update(_normalize_map(grp))
    return merged


def _parse_realized_pnl(value: object) -> float:
    if value is None:
        return 0.0
    s = str(value).replace(" USD", "").strip()
    try:
        return float(s)
    except Exception:
        return 0.0


def _extract_trade_series(output_dir: Path) -> pd.DataFrame | None:
    """Read positions.csv and extract per-position realized pnl + timestamp (best effort)."""
    path = output_dir / "positions.csv"
    if not path.exists():
        return None
    df = pd.read_csv(path)
    if df.empty or "realized_pnl" not in df.columns:
        return None

    ts_col = None
    for col in ("ts_closed", "ts_event", "ts_init", "timestamp", "time", "datetime"):
        if col in df.columns:
            ts_col = col
            break
    if ts_col is None:
        return None

    ts = df[ts_col]
    if pd.api.types.is_numeric_dtype(ts):
        ts_dt = pd.to_datetime(ts, unit="ns", utc=True, errors="coerce")
    else:
        ts_dt = pd.to_datetime(ts, utc=True, errors="coerce")
    pnl = df["realized_pnl"].apply(_parse_realized_pnl)

    out = pd.DataFrame({"ts": ts_dt, "pnl": pnl}).dropna(subset=["ts"])
    out = out[out["pnl"] != 0.0]
    return None if out.empty else out


def _daily_pnl_series(trades_df: pd.DataFrame) -> pd.Series:
    daily = trades_df.copy()
    daily["date"] = daily["ts"].dt.date
    return daily.groupby("date")["pnl"].sum().sort_index()


def days_to_target(trades_df: pd.DataFrame, target_profit: float, max_days: int) -> int | None:
    """Return operated days needed to reach target profit, or None."""
    if trades_df.empty:
        return None
    daily_pnl = _daily_pnl_series(trades_df)
    operated = daily_pnl[daily_pnl != 0.0]
    if operated.empty:
        return None
    cum = operated.cumsum()
    hit = cum[cum >= float(target_profit)]
    if hit.empty:
        return None
    first_date = hit.index[0]
    n_days = int((operated.index <= first_date).sum())
    return n_days if n_days <= int(max_days) else None


def _eval_window_daily_pnl(trades_df: pd.DataFrame, target_profit: float) -> pd.Series:
    """Daily PnL for operated days up to target hit (inclusive); else full window."""
    daily_pnl = _daily_pnl_series(trades_df)
    operated = daily_pnl[daily_pnl != 0.0]
    if operated.empty:
        return operated
    cum = operated.cumsum()
    hit = cum[cum >= float(target_profit)]
    if hit.empty:
        return operated
    hit_date = hit.index[0]
    return operated[operated.index <= hit_date]


def _consistency_metrics(
    trades_df: pd.DataFrame,
    target_profit: float,
) -> tuple[int | None, float | None, float | None]:
    """Return (operated_days, positive_days_ratio, max_daily_share) for the eval window."""
    if trades_df.empty:
        return None, None, None
    window = _eval_window_daily_pnl(trades_df, target_profit=target_profit)
    if window.empty:
        return None, None, None
    operated_days = int(len(window))
    pos_days = int((window > 0).sum())
    positive_days_ratio = float(pos_days / operated_days) if operated_days > 0 else None
    total_profit = float(window.sum())
    if total_profit <= 0:
        return operated_days, positive_days_ratio, None
    max_daily_profit = float(window.max())
    max_daily_share = float(max_daily_profit / total_profit) if max_daily_profit > 0 else None
    return operated_days, positive_days_ratio, max_daily_share


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="YAML grid search + 20-day target evaluation (bars feed).")
    p.add_argument("--start", default="2020-01-01")
    p.add_argument("--end", default="2020-06-30")
    p.add_argument("--product", choices=["xauusd", "mgc"], default="xauusd")
    p.add_argument("--gateway", choices=["rithmic", "tradovate"], default="tradovate")
    p.add_argument(
        "--bars-file",
        default="data/derived/xauusd_m5_2020_2025.parquet",
        help="M5 bars file path (CSV or Parquet).",
    )
    p.add_argument(
        "--grid-config",
        default="nautilus_gold_scalper/configs/grids/eval20d_default.yaml",
        help="YAML grid spec path.",
    )
    p.add_argument(
        "--groups",
        default="",
        help="Comma-separated YAML groups to include (empty=all groups).",
    )
    p.add_argument("--samples", type=int, default=0, help="If >0, random sample N configs.")
    p.add_argument("--seed", type=int, default=42)
    p.add_argument("--max-runs", type=int, default=2000, help="Safety cap when --samples=0.")
    p.add_argument("--account", type=float, default=50_000.0)
    p.add_argument("--target-profit", type=float, default=3000.0)
    p.add_argument("--target-days", type=int, default=20)
    p.add_argument("--max-daily-share", type=float, default=0.30)
    p.add_argument("--min-positive-days-ratio", type=float, default=0.60)
    p.add_argument("--min-operated-days", type=int, default=5)
    p.add_argument("--out", default="logs/grid_search_eval20d")
    p.add_argument("--top", type=int, default=20)
    p.add_argument("--dry-run", action="store_true", help="Only compute grid size; do not run.")
    return p.parse_args()


def main() -> int:
    args = parse_args()
    out_root = Path(args.out) / datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
    out_root.mkdir(parents=True, exist_ok=True)

    groups = [s.strip() for s in str(args.groups).split(",") if s.strip()]
    param_space = _load_grid_spec(Path(args.grid_config), groups if groups else None)
    if not param_space:
        raise ValueError(f"Empty grid in {args.grid_config}")

    # Compute full cartesian size (for safety)
    size = 1
    for k, vs in param_space.items():
        if not vs:
            raise ValueError(f"Empty value list for key {k!r} in {args.grid_config}")
        size *= len(vs)

    if args.dry_run:
        print(json.dumps({"grid_config": str(args.grid_config), "groups": groups, "runs": size}, indent=2))
        return 0

    if int(args.samples) <= 0 and size > int(args.max_runs):
        raise SystemExit(
            f"Refusing to run full cartesian grid of {size:,} runs (cap={args.max_runs}). "
            f"Use --samples N or increase --max-runs."
        )

    bars_path = Path(args.bars_file)
    if not bars_path.exists():
        raise FileNotFoundError(f"Bars file not found: {bars_path}")

    bars_df = load_m5_bars_csv(bars_path, start_date=args.start, end_date=args.end)

    venue = Venue("SIM")
    if args.product == "mgc":
        instrument = create_mgc_instrument(venue)
        tick = float(instrument.price_increment.as_double())
        bars_df = bars_df.copy()
        bars_df["open"] = _quantize_to_tick(bars_df["open"].astype(float).values, tick=tick, mode="nearest")
        bars_df["close"] = _quantize_to_tick(bars_df["close"].astype(float).values, tick=tick, mode="nearest")
        bars_df["high"] = _quantize_to_tick(bars_df["high"].astype(float).values, tick=tick, mode="ceil")
        bars_df["low"] = _quantize_to_tick(bars_df["low"].astype(float).values, tick=tick, mode="floor")
    else:
        instrument = create_xauusd_instrument(venue)

    bar_type = BarType(
        instrument_id=instrument.id,
        bar_spec=BarSpecification(step=5, aggregation=BarAggregation.MINUTE, price_type=PriceType.MID),
        aggregation_source=AggregationSource.EXTERNAL,
    )
    bars = cast(list[Bar], BarDataWrangler(bar_type, instrument).process(bars_df))

    commission_per_side = 0.0
    if args.product == "mgc":
        from nautilus_gold_scalper.src.execution.commission_schedule import commission_per_side_usd

        commission_per_side = commission_per_side_usd(
            profile="apex",
            product="mgc",
            gateway=cast(Gateway, args.gateway),
        )

    # Build combos (cartesian or sampled)
    keys = list(param_space.keys())
    combos: list[dict[str, object]] = []
    if int(args.samples) > 0:
        rng = random.Random(int(args.seed))
        for _ in range(int(args.samples)):
            combos.append({k: rng.choice(param_space[k]) for k in keys})
    else:
        for values in product(*[param_space[k] for k in keys]):
            combos.append(dict(zip(keys, values, strict=True)))

    results: list[EvalResult] = []

    def _consistency_ok(r: EvalResult) -> bool:
        if r.terminated:
            return False
        if r.days_to_target is None:
            return False
        if r.operated_days is None or r.positive_days_ratio is None or r.max_daily_share is None:
            return False
        if r.operated_days < int(args.min_operated_days):
            return False
        if r.positive_days_ratio < float(args.min_positive_days_ratio):
            return False
        if r.max_daily_share > float(args.max_daily_share):
            return False
        return True

    for i, combo in enumerate(combos, 1):
        run_dir = out_root / f"run_{i:04d}"
        run_dir.mkdir(parents=True, exist_ok=True)

        runner_kwargs: dict[str, Any] = {
            "initial_balance": float(args.account),
            "log_level": "ERROR",
            "commission_per_contract": float(commission_per_side),
            "product": cast(Product, args.product),
            "gateway": cast(Gateway, args.gateway),
        }
        run_kwargs: dict[str, Any] = {
            "start_date": args.start,
            "end_date": args.end,
            "feed": "bars",
            "data_source": "parquet",
            "reports": "positions",
            "bars_override": bars,
            "output_dir": str(run_dir),
            "return_summary": True,
            "product": cast(Product, args.product),
            "gateway": cast(Gateway, args.gateway),
            "quiet": True,
        }
        config_overrides: dict[str, Any] = {}
        if args.product == "mgc":
            config_overrides.setdefault("execution", {})
            cast(dict[str, Any], config_overrides["execution"]).update(
                {
                    "commission_source": "schedule",
                    "commission_profile": "apex",
                    "commission_gateway": cast(Gateway, args.gateway),
                }
            )

        for k, v in combo.items():
            ks = str(k)
            if ks.startswith("runner."):
                runner_kwargs[ks.removeprefix("runner.")] = v
            elif ks.startswith("run."):
                run_kwargs[ks.removeprefix("run.")] = v
            else:
                _set_deep(config_overrides, ks, v)

        # Avoid serializing the full bars list (huge); keep reproducibility via bars_file + date range.
        run_kwargs_serializable = dict(run_kwargs)
        bars_override_len = None
        if "bars_override" in run_kwargs_serializable:
            bars_override_len = len(cast(list[object], run_kwargs_serializable["bars_override"]))
            run_kwargs_serializable.pop("bars_override", None)

        with open(run_dir / "params.json", "w", encoding="utf-8") as f:
            json.dump(
                {
                    "grid_config": str(args.grid_config),
                    "groups": groups,
                    "combo": combo,
                    "runner": runner_kwargs,
                    "run": run_kwargs_serializable,
                    "bars_override_len": bars_override_len,
                    "config_overrides": config_overrides,
                },
                f,
                indent=2,
                default=str,
            )

        runner = BacktestRunner(**runner_kwargs)
        summary = runner.run(**run_kwargs, config_overrides=config_overrides)
        assert summary is not None

        trade_series = _extract_trade_series(run_dir)
        dto = None
        operated_days = None
        positive_days_ratio = None
        max_daily_share = None
        if trade_series is not None:
            dto = days_to_target(trade_series, target_profit=args.target_profit, max_days=args.target_days)
            operated_days, positive_days_ratio, max_daily_share = _consistency_metrics(
                trade_series,
                target_profit=args.target_profit,
            )

        results.append(
            EvalResult(
                params=dict(combo),
                final_balance=float(summary.final_balance),
                total_pnl=float(summary.total_pnl),
                trades=int(summary.trades),
                terminated=bool(summary.terminated),
                days_to_target=dto,
                operated_days=operated_days,
                positive_days_ratio=positive_days_ratio,
                max_daily_share=max_daily_share,
                output_dir=str(run_dir),
            )
        )

    ranked = sorted(
        results,
        key=lambda r: (
            r.terminated,
            r.days_to_target is None,
            not _consistency_ok(r),
            r.days_to_target if r.days_to_target is not None else 10_000,
            -r.total_pnl,
        ),
    )
    topn = ranked[: int(args.top)]

    # Write summary files
    json_path = out_root / "summary.json"
    json_path.write_text(
        json.dumps(
            [
                {
                    **r.params,
                    "final_balance": r.final_balance,
                    "total_pnl": r.total_pnl,
                    "trades": r.trades,
                    "terminated": r.terminated,
                    "days_to_target": r.days_to_target,
                    "operated_days": r.operated_days,
                    "positive_days_ratio": r.positive_days_ratio,
                    "max_daily_share": r.max_daily_share,
                    "output_dir": r.output_dir,
                }
                for r in ranked
            ],
            indent=2,
        ),
        encoding="utf-8",
    )

    csv_path = out_root / "summary.csv"
    pd.DataFrame(
        [
            {
                **r.params,
                "final_balance": r.final_balance,
                "total_pnl": r.total_pnl,
                "trades": r.trades,
                "terminated": r.terminated,
                "days_to_target": r.days_to_target,
                "operated_days": r.operated_days,
                "positive_days_ratio": r.positive_days_ratio,
                "max_daily_share": r.max_daily_share,
                "output_dir": r.output_dir,
            }
            for r in ranked
        ]
    ).to_csv(csv_path, index=False)

    top_path = out_root / "top.json"
    top_path.write_text(
        json.dumps(
            [
                {
                    "rank": i,
                    **r.params,
                    "final_balance": r.final_balance,
                    "total_pnl": r.total_pnl,
                    "trades": r.trades,
                    "terminated": r.terminated,
                    "days_to_target": r.days_to_target,
                    "operated_days": r.operated_days,
                    "positive_days_ratio": r.positive_days_ratio,
                    "max_daily_share": r.max_daily_share,
                    "output_dir": r.output_dir,
                }
                for i, r in enumerate(topn, 1)
            ],
            indent=2,
        ),
        encoding="utf-8",
    )

    print(f"Wrote: {json_path}")
    print(f"Wrote: {csv_path}")
    print(f"Wrote: {top_path}")
    print("\nTop candidates:")
    for r in topn:
        print(
            f"- days_to_target={r.days_to_target} pnl={r.total_pnl:.2f} "
            f"op_days={r.operated_days} pos_days_ratio={r.positive_days_ratio} max_day_share={r.max_daily_share} "
            f"params={r.params} dir={r.output_dir}"
        )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
