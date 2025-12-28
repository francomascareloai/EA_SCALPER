"""
Test Apex Trading Compliance - Verify all P0 blockers are implemented.

Tests:
1. Time constraints (4:59 PM ET)
2. Consistency rule (30% max daily profit)
3. Circuit breaker integration
4. Trailing DD calculation
5. Account termination on breach
6. Telemetry-based DD validation (validate_apex_compliance script)
"""

import inspect
import json
import sys
import tempfile
from datetime import datetime, time
from decimal import Decimal
from pathlib import Path
from zoneinfo import ZoneInfo

import pytest

sys.path.insert(0, str(Path(__file__).parent.parent))

from src.risk import (
    AccountTerminatedException,
    CircuitBreaker,
    PropFirmLimits,
    PropFirmManager,
)
from src.risk.consistency_tracker import ConsistencyTracker
from src.risk.time_constraint_manager import TimeConstraintManager


class TestApexCompliance:
    """Test suite for Apex Trading compliance."""

    def test_time_constraint_4_59_pm_et(self):
        """Test that TimeConstraintManager blocks trading at 4:59 PM ET."""

        # Create mock strategy
        class MockConfig:
            instrument_id = "XAUUSD"

        class MockCache:
            def positions_open(self):
                return []

        class MockStrategy:
            def __init__(self):
                self._is_trading_allowed = True
                self.log = MockLogger()
                self.config = MockConfig()
                self.cache = MockCache()

            def close_all_positions(self, instrument_id):
                pass

        class MockLogger:
            def error(self, msg):
                print(f"ERROR: {msg}")

            def warning(self, msg):
                print(f"WARNING: {msg}")

        strategy = MockStrategy()

        # Initialize TimeConstraintManager with 4:59 PM ET cutoff
        time_mgr = TimeConstraintManager(
            strategy=strategy,
            cutoff=time(16, 59),  # 4:59 PM
            warning=time(16, 0),
            urgent=time(16, 30),
            emergency=time(16, 55),
            allow_overnight=False,
        )

        # Test: Before cutoff (4:30 PM ET) - trading may continue, but new entries are blocked.
        et_tz = ZoneInfo("America/New_York")
        dt_before = datetime(2025, 12, 7, 16, 30, 0, tzinfo=et_tz)
        ts_before_ns = int(dt_before.timestamp() * 1e9)

        assert time_mgr.check(ts_before_ns), "Trading should be allowed before 4:59 PM ET"
        assert time_mgr.can_open_new(ts_before_ns) is False, (
            "New trades must be blocked after 4:30 PM ET"
        )

        # Test: At cutoff (4:59 PM ET)
        dt_cutoff = datetime(2025, 12, 7, 16, 59, 0, tzinfo=et_tz)
        ts_cutoff_ns = int(dt_cutoff.timestamp() * 1e9)

        result = time_mgr.check(ts_cutoff_ns)
        assert not result, "Trading should be BLOCKED at 4:59 PM ET"
        assert not strategy._is_trading_allowed, "Strategy should be blocked after cutoff"

    def test_consistency_rule_30_percent(self):
        """Test that ConsistencyTracker blocks trading at 30% daily profit limit."""
        et_tz = ZoneInfo("America/New_York")
        tracker = ConsistencyTracker(initial_balance=100_000.0)

        # Simulate: $5k total profit over 20 days
        for i in range(20):
            now = datetime(2025, 12, i + 1, 12, 0, 0, tzinfo=et_tz)
            tracker.update_profit(250.0, now)
            tracker.reset_daily()  # Reset for next day

        # Total profit: $5k
        assert tracker.total_profit == Decimal("5000.0"), (
            f"Total profit should be $5k, got {tracker.total_profit}"
        )

        # Day 21: Add $1.5k profit
        # After: Daily=$1.5k, Total=$6.5k, Pct=23.08% (below 25% - should allow)
        now = datetime(2025, 12, 21, 12, 0, 0, tzinfo=et_tz)
        tracker.update_profit(1500.0, now)
        daily_pct = tracker.get_daily_profit_pct()
        print(
            f"After $1500 profit: Daily={tracker.daily_profit}, Total={tracker.total_profit}, Pct={daily_pct:.2f}%"
        )
        assert tracker.can_trade(now), (
            f"Trading allowed at {daily_pct:.2f}% daily profit (below 25%)"
        )

        # Add another $200 (total daily $1.7k, total account $6.7k = 25.37% - above 25% buffer)
        tracker.update_profit(200.0, now)
        daily_pct = tracker.get_daily_profit_pct()
        print(
            f"After $1700 profit: Daily={tracker.daily_profit}, Total={tracker.total_profit}, Pct={daily_pct:.2f}%"
        )
        # Note: can_trade() checks the _limit_hit flag which was set by update_profit
        result = tracker.can_trade(now)
        assert not result, f"Trading should be BLOCKED at {daily_pct:.2f}% daily profit (above 25%)"

    def test_circuit_breaker_integration(self):
        """Test that CircuitBreaker escalates correctly on consecutive losses."""
        cb = CircuitBreaker(daily_loss_limit=0.05, total_loss_limit=0.10)
        cb.update_equity(100_000.0)

        # Test: 3 consecutive losses → Level 1
        for _ in range(3):
            cb.register_trade_result(pnl=-100.0, is_win=False)
            cb.update_equity(cb._state.current_equity - 100.0)

        assert cb.get_level().value >= 1, "Should escalate to Level 1 after 3 losses"
        assert not cb.can_trade(), "Should block trading in Level 1 cooldown"

    def test_trailing_dd_calculation(self):
        """Test that PropFirmManager calculates trailing DD correctly."""
        limits = PropFirmLimits(
            account_size=100_000.0,
            daily_loss_limit=5_000.0,  # 5%
            trailing_drawdown=5_000.0,  # 5% Apex trailing DD
        )
        prop_mgr = PropFirmManager(limits=limits)
        prop_mgr.initialize(100_000.0)

        # Test: Equity increases → HWM updates
        prop_mgr.update_equity(105_000.0)
        assert prop_mgr._high_water == 105_000.0, "HWM should update when equity increases"

        # Test: Equity drops to $100.2k (4.8k loss from HWM = 4.57% DD)
        # Project hard-blocks at trailing DD >= 4.0% as safety buffer before Apex 5%.
        prop_mgr.update_equity(100_200.0)
        state = prop_mgr.get_state()
        assert state.trailing_dd_current == 4_800.0, "Trailing DD should be $4.8k"
        assert not state.is_trading_allowed, (
            "Trading must be blocked at 4.57% trailing DD (>= 4.0% safety buffer)"
        )

        # Test: Equity drops to $99.75k (5.25k loss from HWM = 5% DD - BREACHED)
        prop_mgr.update_equity(99_750.0)
        state = prop_mgr.get_state()
        assert state.trailing_dd_current == 5_250.0, "Trailing DD should be $5.25k"
        assert state.is_hard_breached, "Should breach at 5.00% DD"

    def test_account_termination_on_breach(self):
        """Test that PropFirmManager raises AccountTerminatedException on breach."""
        limits = PropFirmLimits(
            account_size=100_000.0,
            trailing_drawdown=5_000.0,  # 5% Apex trailing DD
        )
        prop_mgr = PropFirmManager(limits=limits)
        prop_mgr.initialize(100_000.0)

        # Update equity to $95k (5k loss = 5% DD)
        prop_mgr.update_equity(95_000.0)

        # Test: can_trade() should trigger _hard_stop() which raises exception
        with pytest.raises(AccountTerminatedException):
            prop_mgr.can_trade()

    def test_config_values_loaded(self):
        """Test that config values are loaded correctly from YAML."""
        # This test verifies that GoldScalperConfig has correct default values
        from nautilus_trader.model.identifiers import InstrumentId

        from src.strategies.adaptive_router import RouterArm
        from src.strategies.gold_scalper_strategy import GoldScalperConfig

        config = GoldScalperConfig(instrument_id=InstrumentId.from_str("XAU/USD.SIM"))

        # Verify Apex-specific values (5% DD is critical!)
        assert config.total_loss_limit_pct == 5.0, "Apex trailing DD limit should be 5%"
        assert config.flatten_time_et == "16:59", "Cutoff time should be 4:59 PM ET"
        assert not config.allow_overnight, "Overnight should be disabled for Apex"
        assert config.consistency_cap_pct == 30.0, "Consistency limit should be 30%"
        assert config.cb_level_1_losses == 3, "Circuit breaker L1 should trigger at 3 losses"
        assert config.cb_level_5_dd == 4.5, "Circuit breaker L5 should trigger at 4.5% DD"

        # New config behavior: per-arm TP RR resolution
        cfg2 = GoldScalperConfig(
            instrument_id=InstrumentId.from_str("XAU/USD.SIM"),
            target_rr_ratio=2.5,
            trend_target_rr_ratio=4.0,
            mean_revert_target_rr_ratio=1.8,
        )

        assert cfg2.resolve_tp_rr(arm=RouterArm.SMC) == 2.5
        assert cfg2.resolve_tp_rr(arm=RouterArm.TREND_PULLBACK) == 4.0
        assert cfg2.resolve_tp_rr(arm=RouterArm.TREND_BREAKOUT) == 4.0
        assert cfg2.resolve_tp_rr(arm=RouterArm.MEAN_REVERT) == 1.8


class TestTelemetryDDValidation:
    """Test suite for telemetry-based DD validation in validate_apex_compliance script."""

    def test_telemetry_dd_extraction_success(self) -> None:
        """Test that telemetry JSONL with circuit_state events extracts DD correctly."""
        from scripts.validate_apex_compliance import (
            TelemetryDDResult,
            _parse_telemetry_dd,
        )

        # Create test telemetry JSONL
        telemetry_lines = [
            '{"event": "signal_reject", "reason": "spread", "bar": 1}',
            '{"event": "circuit_state", "level": "NORMAL", "daily_dd": 1.5, "total_dd": 2.0}',
            '{"event": "circuit_state", "level": "WARN", "daily_dd": 2.5, "total_dd": 3.5}',
            '{"event": "spread_state", "state": "OK", "points": 25}',
            '{"event": "circuit_state", "level": "CAUTION", "daily_dd": 1.8, "total_dd": 4.2}',
        ]

        with tempfile.NamedTemporaryFile(mode="w", suffix=".jsonl", delete=False) as f:
            for line in telemetry_lines:
                f.write(line + "\n")
            temp_path = Path(f.name)

        try:
            result = _parse_telemetry_dd(temp_path)
            assert isinstance(result, TelemetryDDResult)
            assert result.parse_error is False
            # max total_dd should be 4.2, max daily_dd should be 2.5
            assert result.max_total_dd_pct == 4.2
            assert result.max_daily_dd_pct == 2.5
        finally:
            temp_path.unlink()

    def test_telemetry_dd_snapshot_with_higher_dd_than_circuit_state(self) -> None:
        """Test that dd_snapshot events with higher DD values are correctly used.

        Verifies that when dd_snapshot events contain higher DD values than
        circuit_state events, the parser returns the max from dd_snapshot.
        This ensures Apex DD validation is robust against sparse circuit_state
        telemetry (which only fires on level change).
        """
        from scripts.validate_apex_compliance import (
            TelemetryDDResult,
            _parse_telemetry_dd,
        )

        # Create telemetry with circuit_state at lower DD, dd_snapshot at higher DD
        telemetry_lines = [
            # circuit_state fires on level change with moderate DD
            '{"event": "circuit_state", "level": "NORMAL", "daily_dd": 1.5, "total_dd": 2.0}',
            '{"event": "circuit_state", "level": "WARN", "daily_dd": 2.0, "total_dd": 3.0}',
            # dd_snapshot fires on every new max - captures the peak DD
            '{"event": "dd_snapshot", "daily_dd": 2.8, "total_dd": 4.5, "equity": 95500.0, '
            '"source": "circuit_breaker", "ts": "2024-01-01T12:30:00+00:00"}',
            # Another dd_snapshot with even higher total_dd
            '{"event": "dd_snapshot", "daily_dd": 2.5, "total_dd": 4.9, "equity": 95100.0, '
            '"source": "circuit_breaker", "ts": "2024-01-01T12:35:00+00:00"}',
            # Other events should be ignored
            '{"event": "signal_reject", "reason": "spread", "bar": 1}',
        ]

        with tempfile.NamedTemporaryFile(mode="w", suffix=".jsonl", delete=False) as f:
            for line in telemetry_lines:
                f.write(line + "\n")
            temp_path = Path(f.name)

        try:
            result = _parse_telemetry_dd(temp_path)
            assert isinstance(result, TelemetryDDResult)
            assert result.parse_error is False
            # max total_dd should be 4.9 (from dd_snapshot), not 3.0 (from circuit_state)
            assert result.max_total_dd_pct == 4.9, (
                f"Expected max total_dd=4.9 from dd_snapshot, got {result.max_total_dd_pct}"
            )
            # max daily_dd should be 2.8 (from first dd_snapshot), not 2.0 (from circuit_state)
            assert result.max_daily_dd_pct == 2.8, (
                f"Expected max daily_dd=2.8 from dd_snapshot, got {result.max_daily_dd_pct}"
            )
        finally:
            temp_path.unlink()

    def test_telemetry_dd_extraction_no_circuit_state(self) -> None:
        """Test that telemetry without circuit_state events returns None."""
        from scripts.validate_apex_compliance import _parse_telemetry_dd

        telemetry_lines = [
            '{"event": "signal_reject", "reason": "spread", "bar": 1}',
            '{"event": "spread_state", "state": "OK", "points": 25}',
        ]

        with tempfile.NamedTemporaryFile(mode="w", suffix=".jsonl", delete=False) as f:
            for line in telemetry_lines:
                f.write(line + "\n")
            temp_path = Path(f.name)

        try:
            result = _parse_telemetry_dd(temp_path)
            # No circuit_state events, should return (None, None)
            assert result.parse_error is False
            assert result.max_total_dd_pct is None
            assert result.max_daily_dd_pct is None
        finally:
            temp_path.unlink()

    def test_telemetry_dd_extraction_invalid_json_fails_closed(self) -> None:
        """Test that malformed JSON in telemetry causes fail-closed (returns None)."""
        from scripts.validate_apex_compliance import _parse_telemetry_dd

        telemetry_lines = [
            '{"event": "circuit_state", "daily_dd": 1.5, "total_dd": 2.0}',
            "this is not valid json",  # Malformed line
            '{"event": "circuit_state", "daily_dd": 3.0, "total_dd": 4.0}',
        ]

        with tempfile.NamedTemporaryFile(mode="w", suffix=".jsonl", delete=False) as f:
            for line in telemetry_lines:
                f.write(line + "\n")
            temp_path = Path(f.name)

        try:
            result = _parse_telemetry_dd(temp_path)
            # Fail closed: malformed JSON should return (None, None)
            assert result.parse_error is True
            assert result.max_total_dd_pct is None
            assert result.max_daily_dd_pct is None
        finally:
            temp_path.unlink()

    def test_telemetry_dd_extraction_missing_file(self) -> None:
        """Test that missing telemetry file returns None (fail closed)."""
        from scripts.validate_apex_compliance import _parse_telemetry_dd

        result = _parse_telemetry_dd(Path("/nonexistent/path/telemetry.jsonl"))
        assert result.parse_error is False
        assert result.max_total_dd_pct is None
        assert result.max_daily_dd_pct is None

    def test_validator_uses_telemetry_dd_source(self) -> None:
        """Test that validator reports dd_source='telemetry' when telemetry is provided."""
        import subprocess

        # Create minimal fills CSV (required)
        # Use a timestamp during NY trading hours (avoid cutoff false positives).
        fills_content = "ts_event,side,quantity,pnl\n1704110400000000000,BUY,1,100.0\n"

        # Create telemetry JSONL with circuit_state
        telemetry_content = (
            '{"event": "circuit_state", "level": "NORMAL", '
            '"daily_dd": 1.5, "total_dd": 2.5, "ts": "2024-01-01T12:00:00+00:00"}\n'
        )

        with tempfile.TemporaryDirectory() as tmpdir:
            fills_path = Path(tmpdir) / "fills.csv"
            telemetry_path = Path(tmpdir) / "telemetry.jsonl"
            output_path = Path(tmpdir) / "output.json"

            fills_path.write_text(fills_content)
            telemetry_path.write_text(telemetry_content)

            # Run validator
            result = subprocess.run(
                [
                    sys.executable,
                    "-m",
                    "nautilus_gold_scalper.scripts.validate_apex_compliance",
                    "--trades",
                    str(fills_path),
                    "--telemetry",
                    str(telemetry_path),
                    "--output",
                    str(output_path),
                ],
                capture_output=True,
                text=True,
                cwd=str(Path(__file__).parent.parent.parent),
            )

            assert result.returncode == 0, f"Validator failed: {result.stderr}"

            # Check output JSON
            output = json.loads(output_path.read_text())
            assert output["require_telemetry"] is True  # Default
            assert output["dd_source"] == "telemetry"
            assert output["dd_is_mtm_unrealized"] is True  # Valid telemetry DD
            assert output["max_trailing_dd_pct"] == 2.5  # From telemetry total_dd
            assert output["max_daily_dd_pct"] == 1.5  # From telemetry daily_dd

    def test_validator_fallback_to_positions_when_telemetry_invalid(self) -> None:
        """Test that validator fails closed when telemetry is invalid (default require_telemetry=True)."""
        import subprocess

        # Create minimal fills CSV with pnl
        fills_content = "ts_event,side,quantity,pnl\n1704067200000000000,BUY,1,100.0\n"

        # Create INVALID telemetry (malformed JSON)
        telemetry_content = "this is not valid json\n"

        with tempfile.TemporaryDirectory() as tmpdir:
            fills_path = Path(tmpdir) / "fills.csv"
            telemetry_path = Path(tmpdir) / "telemetry.jsonl"
            output_path = Path(tmpdir) / "output.json"

            fills_path.write_text(fills_content)
            telemetry_path.write_text(telemetry_content)

            # Run validator with default require_telemetry=True
            result = subprocess.run(
                [
                    sys.executable,
                    "-m",
                    "nautilus_gold_scalper.scripts.validate_apex_compliance",
                    "--trades",
                    str(fills_path),
                    "--telemetry",
                    str(telemetry_path),
                    "--output",
                    str(output_path),
                ],
                capture_output=True,
                text=True,
                cwd=str(Path(__file__).parent.parent.parent),
            )

            assert result.returncode == 0, f"Validator failed: {result.stderr}"

            # Check output JSON - should FAIL CLOSED (default is require_telemetry=True)
            output = json.loads(output_path.read_text())
            assert output["require_telemetry"] is True
            assert output["dd_source"] == "telemetry"  # Attempted source
            assert output["dd_is_mtm_unrealized"] is False  # Failed to extract
            assert output["passed"] is False, (
                "Should fail when telemetry is invalid (require_telemetry=True)"
            )
            assert any("malformed" in v.lower() for v in output["violations"]), (
                f"Expected violation about malformed telemetry: {output['violations']}"
            )

    def test_telemetry_strict_failure_no_dd_events(self) -> None:
        """Test that require_telemetry=True fails when telemetry has no DD events."""
        import subprocess

        # Create minimal fills CSV (required)
        # Use a timestamp during NY trading hours (avoid cutoff false positives).
        fills_content = "ts_event,side,quantity,pnl\n1704110400000000000,BUY,1,100.0\n"

        # Create telemetry JSONL with NO circuit_state or dd_snapshot events
        telemetry_content = (
            '{"event": "signal_reject", "reason": "spread", "bar": 1}\n'
            '{"event": "spread_state", "state": "OK", "points": 25}\n'
        )

        with tempfile.TemporaryDirectory() as tmpdir:
            fills_path = Path(tmpdir) / "fills.csv"
            telemetry_path = Path(tmpdir) / "telemetry.jsonl"
            output_path = Path(tmpdir) / "output.json"

            fills_path.write_text(fills_content)
            telemetry_path.write_text(telemetry_content)

            # Run validator with default require_telemetry=True
            result = subprocess.run(
                [
                    sys.executable,
                    "-m",
                    "nautilus_gold_scalper.scripts.validate_apex_compliance",
                    "--trades",
                    str(fills_path),
                    "--telemetry",
                    str(telemetry_path),
                    "--output",
                    str(output_path),
                ],
                capture_output=True,
                text=True,
                cwd=str(Path(__file__).parent.parent.parent),
            )

            assert result.returncode == 0, f"Validator failed: {result.stderr}"

            # Check output JSON
            output = json.loads(output_path.read_text())
            assert output["require_telemetry"] is True
            assert output["telemetry_strict"] is True
            assert output["dd_source"] == "telemetry"  # Attempted source
            assert output["dd_is_mtm_unrealized"] is False  # Failed to extract
            assert output["passed"] is False, (
                "Should fail when no DD events (require_telemetry=True)"
            )
            assert any("no dd events" in v.lower() for v in output["violations"]), (
                f"Expected violation about missing DD events: {output['violations']}"
            )

    def test_telemetry_no_strict_fallback(self) -> None:
        """Test that --no-require-telemetry with --no-telemetry-strict falls back to fills when no DD events."""
        import subprocess

        # Create minimal fills CSV with pnl
        # Each day: open and close on same day to avoid overnight violation
        # Spread profits across 5+ days equally to stay below 25% consistency limit
        fills_content = (
            "ts_event,side,quantity,pnl\n"
            # Day 1: open and close (12:00-13:00 ET)
            "1704214800000000000,BUY,1,0.0\n"  # 2024-01-02 17:00:00 UTC
            "1704218400000000000,SELL,1,10.0\n"  # 2024-01-02 18:00:00 UTC
            # Day 2
            "1704301200000000000,BUY,1,0.0\n"  # 2024-01-03 17:00:00 UTC
            "1704304800000000000,SELL,1,10.0\n"  # 2024-01-03 18:00:00 UTC
            # Day 3
            "1704387600000000000,BUY,1,0.0\n"  # 2024-01-04 17:00:00 UTC
            "1704391200000000000,SELL,1,10.0\n"  # 2024-01-04 18:00:00 UTC
            # Day 4
            "1704474000000000000,BUY,1,0.0\n"  # 2024-01-05 17:00:00 UTC
            "1704477600000000000,SELL,1,10.0\n"  # 2024-01-05 18:00:00 UTC
            # Day 5
            "1704560400000000000,BUY,1,0.0\n"  # 2024-01-06 17:00:00 UTC
            "1704564000000000000,SELL,1,10.0\n"  # 2024-01-06 18:00:00 UTC
        )
        # Each day = 20% of total profit = well below 25% limit

        # Create telemetry JSONL with NO circuit_state or dd_snapshot events
        telemetry_content = '{"event": "signal_reject", "reason": "spread", "bar": 1}\n'

        with tempfile.TemporaryDirectory() as tmpdir:
            fills_path = Path(tmpdir) / "fills.csv"
            telemetry_path = Path(tmpdir) / "telemetry.jsonl"
            output_path = Path(tmpdir) / "output.json"

            fills_path.write_text(fills_content)
            telemetry_path.write_text(telemetry_content)

            # Run validator with --no-require-telemetry AND --no-telemetry-strict
            result = subprocess.run(
                [
                    sys.executable,
                    "-m",
                    "nautilus_gold_scalper.scripts.validate_apex_compliance",
                    "--trades",
                    str(fills_path),
                    "--telemetry",
                    str(telemetry_path),
                    "--no-require-telemetry",
                    "--no-telemetry-strict",
                    "--output",
                    str(output_path),
                ],
                capture_output=True,
                text=True,
                cwd=str(Path(__file__).parent.parent.parent),
            )

            assert result.returncode == 0, f"Validator failed: {result.stderr}"

            # Check output JSON - should fallback to fills
            output = json.loads(output_path.read_text())
            assert output["require_telemetry"] is False
            assert output["telemetry_strict"] is False
            assert output["dd_source"] == "fills"  # Fallback
            assert output["dd_is_mtm_unrealized"] is False  # Realized-only
            assert output["passed"] is True, (
                f"Should pass when fallback to fills; violations: {output['violations']}"
            )

    def test_daily_dd_limit_violation_via_telemetry(self) -> None:
        """Test that daily DD limit violation is detected from telemetry."""
        import subprocess

        # Create minimal fills CSV (required)
        # Use a timestamp during NY trading hours (avoid cutoff false positives).
        fills_content = "ts_event,side,quantity,pnl\n1704110400000000000,BUY,1,100.0\n"

        # Create telemetry JSONL with daily_dd > 3% limit
        # daily_dd=3.5 (3.5% > 3% limit)
        telemetry_content = (
            '{"event": "circuit_state", "level": "WARN", '
            '"daily_dd": 3.5, "total_dd": 2.0, "ts": "2024-01-01T12:00:00+00:00"}\n'
        )

        with tempfile.TemporaryDirectory() as tmpdir:
            fills_path = Path(tmpdir) / "fills.csv"
            telemetry_path = Path(tmpdir) / "telemetry.jsonl"
            output_path = Path(tmpdir) / "output.json"

            fills_path.write_text(fills_content)
            telemetry_path.write_text(telemetry_content)

            # Run validator with default daily-dd-limit (0.03 = 3%)
            result = subprocess.run(
                [
                    sys.executable,
                    "-m",
                    "nautilus_gold_scalper.scripts.validate_apex_compliance",
                    "--trades",
                    str(fills_path),
                    "--telemetry",
                    str(telemetry_path),
                    "--output",
                    str(output_path),
                ],
                capture_output=True,
                text=True,
                cwd=str(Path(__file__).parent.parent.parent),
            )

            assert result.returncode == 0, f"Validator failed: {result.stderr}"

            # Check output JSON
            output = json.loads(output_path.read_text())
            assert output["dd_source"] == "telemetry"
            assert output["max_daily_dd_pct"] == 3.5
            assert output["daily_dd_limit_pct"] == 3.0
            assert output["passed"] is False, "Should fail when daily DD exceeds limit"
            assert any("Daily DD" in v and "exceeds limit" in v for v in output["violations"]), (
                f"Expected violation about daily DD: {output['violations']}"
            )

    def test_daily_dd_limit_pass_via_telemetry(self) -> None:
        """Test that daily DD within limit passes."""
        import subprocess

        # Create minimal fills CSV (required)
        # Each day: open and close on same day to avoid overnight violation
        # Spread profits across 5+ days equally to stay below 25% consistency limit
        fills_content = (
            "ts_event,side,quantity,pnl\n"
            # Day 1: open and close (12:00-13:00 ET)
            "1704214800000000000,BUY,1,0.0\n"  # 2024-01-02 17:00:00 UTC
            "1704218400000000000,SELL,1,10.0\n"  # 2024-01-02 18:00:00 UTC
            # Day 2
            "1704301200000000000,BUY,1,0.0\n"  # 2024-01-03 17:00:00 UTC
            "1704304800000000000,SELL,1,10.0\n"  # 2024-01-03 18:00:00 UTC
            # Day 3
            "1704387600000000000,BUY,1,0.0\n"  # 2024-01-04 17:00:00 UTC
            "1704391200000000000,SELL,1,10.0\n"  # 2024-01-04 18:00:00 UTC
            # Day 4
            "1704474000000000000,BUY,1,0.0\n"  # 2024-01-05 17:00:00 UTC
            "1704477600000000000,SELL,1,10.0\n"  # 2024-01-05 18:00:00 UTC
            # Day 5
            "1704560400000000000,BUY,1,0.0\n"  # 2024-01-06 17:00:00 UTC
            "1704564000000000000,SELL,1,10.0\n"  # 2024-01-06 18:00:00 UTC
        )
        # Each day = 20% of total profit = well below 25% limit

        # Create telemetry JSONL with daily_dd < 3% limit
        telemetry_content = (
            '{"event": "circuit_state", "level": "NORMAL", '
            '"daily_dd": 2.5, "total_dd": 2.0, "ts": "2024-01-02T17:00:00+00:00"}\n'
        )

        with tempfile.TemporaryDirectory() as tmpdir:
            fills_path = Path(tmpdir) / "fills.csv"
            telemetry_path = Path(tmpdir) / "telemetry.jsonl"
            output_path = Path(tmpdir) / "output.json"

            fills_path.write_text(fills_content)
            telemetry_path.write_text(telemetry_content)

            # Run validator
            result = subprocess.run(
                [
                    sys.executable,
                    "-m",
                    "nautilus_gold_scalper.scripts.validate_apex_compliance",
                    "--trades",
                    str(fills_path),
                    "--telemetry",
                    str(telemetry_path),
                    "--output",
                    str(output_path),
                ],
                capture_output=True,
                text=True,
                cwd=str(Path(__file__).parent.parent.parent),
            )

            assert result.returncode == 0, f"Validator failed: {result.stderr}"

            # Check output JSON
            output = json.loads(output_path.read_text())
            assert output["max_daily_dd_pct"] == 2.5
            assert output["passed"] is True, (
                f"Should pass when daily DD within limit; violations: {output['violations']}"
            )

    def test_require_telemetry_default_fails_without_telemetry(self) -> None:
        """Test that default require_telemetry=True fails when no telemetry is provided."""
        import subprocess

        # Create minimal fills CSV with pnl (no violations on its own)
        # Spread profits across 5+ days to avoid consistency violation
        fills_content = (
            "ts_event,side,quantity,pnl\n"
            "1704214800000000000,BUY,1,0.0\n"
            "1704218400000000000,SELL,1,10.0\n"
            "1704301200000000000,BUY,1,0.0\n"
            "1704304800000000000,SELL,1,10.0\n"
            "1704387600000000000,BUY,1,0.0\n"
            "1704391200000000000,SELL,1,10.0\n"
            "1704474000000000000,BUY,1,0.0\n"
            "1704477600000000000,SELL,1,10.0\n"
            "1704560400000000000,BUY,1,0.0\n"
            "1704564000000000000,SELL,1,10.0\n"
        )

        with tempfile.TemporaryDirectory() as tmpdir:
            fills_path = Path(tmpdir) / "fills.csv"
            output_path = Path(tmpdir) / "output.json"

            fills_path.write_text(fills_content)

            # Run validator WITHOUT --telemetry (default require_telemetry=True)
            result = subprocess.run(
                [
                    sys.executable,
                    "-m",
                    "nautilus_gold_scalper.scripts.validate_apex_compliance",
                    "--trades",
                    str(fills_path),
                    "--output",
                    str(output_path),
                ],
                capture_output=True,
                text=True,
                cwd=str(Path(__file__).parent.parent.parent),
            )

            assert result.returncode == 0, f"Validator failed: {result.stderr}"

            # Check output JSON - should FAIL because telemetry is required
            output = json.loads(output_path.read_text())
            assert output["require_telemetry"] is True
            assert output["dd_source"] is None  # No telemetry attempted
            assert output["dd_is_mtm_unrealized"] is False
            assert output["passed"] is False, (
                "Should fail when telemetry is required but not provided"
            )
            assert any("Telemetry is required" in v for v in output["violations"]), (
                f"Expected violation about required telemetry: {output['violations']}"
            )

    def test_no_require_telemetry_fallback_with_invalid_telemetry(self) -> None:
        """Test that --no-require-telemetry allows fallback when telemetry is invalid."""
        import subprocess

        # Create minimal fills CSV with pnl
        # Spread profits across 5+ days to avoid consistency violation
        fills_content = (
            "ts_event,side,quantity,pnl\n"
            "1704214800000000000,BUY,1,0.0\n"
            "1704218400000000000,SELL,1,10.0\n"
            "1704301200000000000,BUY,1,0.0\n"
            "1704304800000000000,SELL,1,10.0\n"
            "1704387600000000000,BUY,1,0.0\n"
            "1704391200000000000,SELL,1,10.0\n"
            "1704474000000000000,BUY,1,0.0\n"
            "1704477600000000000,SELL,1,10.0\n"
            "1704560400000000000,BUY,1,0.0\n"
            "1704564000000000000,SELL,1,10.0\n"
        )

        # Create INVALID telemetry (malformed JSON)
        telemetry_content = "this is not valid json\n"

        with tempfile.TemporaryDirectory() as tmpdir:
            fills_path = Path(tmpdir) / "fills.csv"
            telemetry_path = Path(tmpdir) / "telemetry.jsonl"
            output_path = Path(tmpdir) / "output.json"

            fills_path.write_text(fills_content)
            telemetry_path.write_text(telemetry_content)

            # Run validator with --no-require-telemetry
            result = subprocess.run(
                [
                    sys.executable,
                    "-m",
                    "nautilus_gold_scalper.scripts.validate_apex_compliance",
                    "--trades",
                    str(fills_path),
                    "--telemetry",
                    str(telemetry_path),
                    "--no-require-telemetry",
                    "--output",
                    str(output_path),
                ],
                capture_output=True,
                text=True,
                cwd=str(Path(__file__).parent.parent.parent),
            )

            assert result.returncode == 0, f"Validator failed: {result.stderr}"

            # Check output JSON - should fallback to fills
            output = json.loads(output_path.read_text())
            assert output["require_telemetry"] is False
            assert output["dd_source"] == "fills"  # Fallback from invalid telemetry
            assert output["dd_is_mtm_unrealized"] is False  # Realized-only
            assert output["passed"] is True, (
                f"Should pass when fallback to fills; violations: {output['violations']}"
            )


class TestDailyResetDDTelemetry:
    """Test that daily reset properly resets DD telemetry max trackers."""

    def test_daily_reset_resets_daily_dd_max_only(self) -> None:
        """Guard: daily max resets, session max does not.

        This stays as a source-level check because spinning up a full Nautilus
        engine just to hit `on_new_day` is disproportionate for Phase 0.
        """
        from src.strategies.base_strategy import BaseGoldStrategy

        source = inspect.getsource(BaseGoldStrategy.on_new_day)

        assert "_telemetry_max_daily_dd_pct = 0.0" in source
        assert "Do NOT reset" in source and "_telemetry_max_total_dd_pct" in source

        update_idx = source.find("update_equity")
        reset_idx = source.find("reset_daily(now=tick_dt)")
        assert update_idx < reset_idx


if __name__ == "__main__":
    # Run basic tests without pytest
    test = TestApexCompliance()

    print("Testing Time Constraint (4:59 PM ET)...")
    test.test_time_constraint_4_59_pm_et()
    print("PASS\n")

    print("Testing Consistency Rule (30%)...")
    test.test_consistency_rule_30_percent()
    print("PASS\n")

    print("Testing Circuit Breaker Integration...")
    test.test_circuit_breaker_integration()
    print("PASS\n")

    print("Testing Trailing DD Calculation...")
    test.test_trailing_dd_calculation()
    print("PASS\n")

    print("Testing Account Termination...")
    test.test_account_termination_on_breach()
    print("PASS\n")

    print("Testing Config Values...")
    test.test_config_values_loaded()
    print("PASS\n")

    print("=" * 60)
    print("ALL APEX COMPLIANCE TESTS PASSED")
    print("=" * 60)
