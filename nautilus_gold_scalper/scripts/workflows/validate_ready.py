from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[3]


def _project_root() -> Path:
    return _repo_root() / "nautilus_gold_scalper"


def _run(cmd: list[str], *, title: str, env: dict[str, str] | None = None) -> None:
    print(f"\n==> {title}")
    print("$ " + " ".join(cmd))
    subprocess.run(cmd, check=True, env=env)


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Run a one-command readiness gate: pytest + mypy --strict + backtest smoke matrix. "
            "Optionally run slow catalog data validation."
        )
    )
    parser.add_argument("--start", default="2024-01-01", help="Start date for smoke matrix")
    parser.add_argument("--end", default="2024-02-01", help="End date for smoke matrix")
    parser.add_argument(
        "--with-data-validation",
        action="store_true",
        help=(
            "Also run the (slow) DuckDB catalog validation pipeline on the stride1 native catalog. "
            "Use this for final verification only."
        ),
    )
    parser.add_argument(
        "--catalog",
        default="data/catalog_native/xauusd_2003_2025_stride1_COMPLETE",
        help="Catalog path for data validation (repo-relative or absolute)",
    )

    args = parser.parse_args()

    repo_root = _repo_root()
    project_root = _project_root()

    python = sys.executable

    env = os.environ.copy()
    env["PYTHONPATH"] = os.pathsep.join(
        [str(repo_root), str(project_root), env.get("PYTHONPATH", "")]
    )

    try:
        _run([python, "-m", "pytest", "-q"], title="pytest", env=env)
        _run(
            [
                python,
                "-m",
                "mypy",
                "--strict",
                "nautilus_gold_scalper/src",
                "nautilus_gold_scalper/scripts/optimize.py",
                "nautilus_gold_scalper/scripts/run_backtest.py",
                "nautilus_gold_scalper/scripts/backtest/run_backtest.py",
            ],
            title="mypy --strict",
            env=env,
        )
        _run(
            [
                python,
                "-m",
                "nautilus_gold_scalper.scripts.run_backtest",
                "--smoke-matrix",
                "--start",
                str(args.start),
                "--end",
                str(args.end),
            ],
            title="backtest smoke matrix (stride20 parquet)",
            env=env,
        )

        if args.with_data_validation:
            catalog_path = Path(str(args.catalog))
            if not catalog_path.is_absolute():
                catalog_path = (repo_root / catalog_path).resolve()

            _run(
                [
                    python,
                    "-m",
                    "src.validation.run_validation",
                    "--catalog",
                    str(catalog_path),
                    "--phases",
                    "2,3,4",
                ],
                title="data validation pipeline (catalog stride1)",
                env=env,
            )

        print("\nREADY: all selected gates passed")
        return 0
    except subprocess.CalledProcessError as exc:
        print(f"\nNOT READY: gate failed (exit={exc.returncode})")
        return int(exc.returncode)


if __name__ == "__main__":
    raise SystemExit(main())
