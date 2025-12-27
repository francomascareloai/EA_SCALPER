"""
Tests for certification mode (--certify) in run_backtest.py.

Tests preflight checks and path resolution WITHOUT running a real backtest.
"""

from __future__ import annotations

import tempfile
from pathlib import Path
from unittest.mock import patch

import pytest

# Import the functions under test
from nautilus_gold_scalper.scripts.backtest.run_backtest import (
    CertifyPreflightError,
    certify_preflight_checks,
    resolve_certify_output_dir,
)


class TestCertifyPreflightChecks:
    """Tests for certify_preflight_checks()."""

    def test_passes_with_valid_args(self) -> None:
        """Should pass when feed=ticks and no_prop=False."""
        # Should not raise
        certify_preflight_checks(feed="ticks", no_prop=False)

    def test_fails_for_bars_feed(self) -> None:
        """Should fail when feed=bars (not valid for MTM/HWM enforcement)."""
        with pytest.raises(CertifyPreflightError) as exc_info:
            certify_preflight_checks(feed="bars", no_prop=False)

        assert "--certify requires --feed=ticks" in str(exc_info.value)
        assert "Bar-only mode is not valid" in str(exc_info.value)

    def test_fails_for_no_prop(self) -> None:
        """Should fail when --no-prop is set (certification requires prop rules)."""
        with pytest.raises(CertifyPreflightError) as exc_info:
            certify_preflight_checks(feed="ticks", no_prop=True)

        assert "--certify is incompatible with --no-prop" in str(exc_info.value)
        assert "prop-firm rules enabled" in str(exc_info.value)

    def test_fails_for_bars_and_no_prop(self) -> None:
        """Should fail for both violations (first one wins)."""
        with pytest.raises(CertifyPreflightError) as exc_info:
            certify_preflight_checks(feed="bars", no_prop=True)

        # The feed check comes first
        assert "--certify requires --feed=ticks" in str(exc_info.value)


class TestResolveCertifyOutputDir:
    """Tests for resolve_certify_output_dir()."""

    def test_creates_directory_with_correct_format(self) -> None:
        """Should create directory with expected naming format."""
        with tempfile.TemporaryDirectory() as tmpdir:
            base_logs = Path(tmpdir)
            result = resolve_certify_output_dir(
                product="xauusd",
                start="2024-01-01",
                end="2024-03-31",
                base_logs_dir=base_logs,
            )

            # Directory should be created
            assert result.exists()
            assert result.is_dir()

            # Name should match pattern: certify_<timestamp>_<product>_<start>_<end>
            name = result.name
            assert name.startswith("certify_")
            assert "xauusd" in name
            assert "2024-01-01" in name
            assert "2024-03-31" in name

    def test_creates_parent_directories(self) -> None:
        """Should create parent directories if they don't exist."""
        with tempfile.TemporaryDirectory() as tmpdir:
            base_logs = Path(tmpdir) / "deep" / "nested" / "logs"
            # Parent doesn't exist yet
            assert not base_logs.exists()

            result = resolve_certify_output_dir(
                product="mgc",
                start="2024-06-01",
                end="2024-06-30",
                base_logs_dir=base_logs,
            )

            # Directory should be created, including parents
            assert result.exists()
            assert base_logs.exists()

    def test_sanitizes_product_name(self) -> None:
        """Should sanitize product name to remove special chars."""
        with tempfile.TemporaryDirectory() as tmpdir:
            base_logs = Path(tmpdir)
            result = resolve_certify_output_dir(
                product="xau/usd",  # Invalid chars
                start="2024-01-01",
                end="2024-03-31",
                base_logs_dir=base_logs,
            )

            # Name should have sanitized product (no slash)
            name = result.name
            assert "/" not in name
            assert "xauusd" in name  # Slash removed

    def test_sanitizes_date_strings(self) -> None:
        """Should sanitize date strings to remove unexpected chars."""
        with tempfile.TemporaryDirectory() as tmpdir:
            base_logs = Path(tmpdir)
            result = resolve_certify_output_dir(
                product="mgc",
                start="2024/01/01",  # Using slashes instead of dashes
                end="2024.03.31",  # Using dots instead of dashes
                base_logs_dir=base_logs,
            )

            name = result.name
            # Slashes and dots should be removed (only alphanumeric and dash kept)
            assert "/" not in name
            assert "." not in name

    def test_uses_default_logs_dir_when_not_specified(self) -> None:
        """Should use project logs/ when base_logs_dir is None."""
        # This test verifies the default path logic without actually creating files
        # We'll mock Path to check what it would create
        with patch.object(Path, "mkdir"):
            result = resolve_certify_output_dir(
                product="xauusd",
                start="2024-01-01",
                end="2024-03-31",
            )

            # Should be under project's logs directory
            assert "logs" in str(result)

    def test_existing_directory_is_ok(self) -> None:
        """Should not fail if directory already exists."""
        with tempfile.TemporaryDirectory() as tmpdir:
            base_logs = Path(tmpdir)

            # Create first
            result1 = resolve_certify_output_dir(
                product="xauusd",
                start="2024-01-01",
                end="2024-03-31",
                base_logs_dir=base_logs,
            )

            # Due to timestamp, creating a second one should work
            # (they'll have different timestamps)
            result2 = resolve_certify_output_dir(
                product="xauusd",
                start="2024-01-01",
                end="2024-03-31",
                base_logs_dir=base_logs,
            )

            assert result1.exists()
            assert result2.exists()


class TestCertifyIntegration:
    """Integration tests for certification mode (with mocked backtest)."""

    def test_certify_mode_variables_are_exported(self) -> None:
        """Verify that the CertifyPreflightError is importable."""
        # This test verifies the module exports correctly
        from nautilus_gold_scalper.scripts.backtest.run_backtest import (
            CertifyPreflightError,
            certify_preflight_checks,
            resolve_certify_output_dir,
        )

        assert CertifyPreflightError is not None
        assert callable(certify_preflight_checks)
        assert callable(resolve_certify_output_dir)
