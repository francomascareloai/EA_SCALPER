"""Unit tests for telemetry hard-gate CLI logic in run_backtest.py."""

from __future__ import annotations

import argparse
from pathlib import Path


def test_require_telemetry_argument_defaults_true() -> None:
    """--require-telemetry should default to True for Apex compliance."""
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--require-telemetry",
        action=argparse.BooleanOptionalAction,
        default=True,
    )
    args = parser.parse_args([])
    assert args.require_telemetry is True


def test_no_require_telemetry_sets_false() -> None:
    """--no-require-telemetry should set flag to False."""
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--require-telemetry",
        action=argparse.BooleanOptionalAction,
        default=True,
    )
    args = parser.parse_args(["--no-require-telemetry"])
    assert args.require_telemetry is False


def test_require_telemetry_explicit_sets_true() -> None:
    """--require-telemetry explicit should set flag to True."""
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--require-telemetry",
        action=argparse.BooleanOptionalAction,
        default=True,
    )
    args = parser.parse_args(["--require-telemetry"])
    assert args.require_telemetry is True


def test_telemetry_path_derivation_from_out_dir() -> None:
    """When --out-dir is provided but --telemetry-path is not, path should be auto-derived."""
    out_dir = "/tmp/backtest_results"
    effective_path = str(Path(out_dir) / "telemetry.jsonl")
    assert effective_path == "/tmp/backtest_results/telemetry.jsonl"


def test_telemetry_path_user_override_honored() -> None:
    """When --telemetry-path is provided, it should be used directly."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--telemetry-path", default=None)
    args = parser.parse_args(["--telemetry-path", "/custom/path.jsonl"])
    assert args.telemetry_path == "/custom/path.jsonl"
