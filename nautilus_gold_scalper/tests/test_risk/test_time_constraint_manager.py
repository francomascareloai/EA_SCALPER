import datetime

from nautilus_gold_scalper.src.risk.time_constraint_manager import TimeConstraintManager


class DummyStrategy:
    def __init__(self):
        self.closed = False
        self.canceled = False
        self.log = self
        self._is_trading_allowed = True
        self.config = type("Cfg", (), {"instrument_id": None})
        self._trading_blocked_today = False

    def close_position(self, *_args, **_kwargs):  # pragma: no cover - unused in this test
        return None

    # Logging proxies
    def critical(self, msg):  # pragma: no cover - trivial
        pass

    def error(self, msg):  # pragma: no cover - trivial
        pass

    def warning(self, msg):  # pragma: no cover - trivial
        pass

    # Position management stubs
    def cancel_all_orders(self, *_args, **_kwargs):
        self.canceled = True

    def close_all_positions(self, *_args, **_kwargs):
        self.closed = True

    @property
    def cache(self):  # pragma: no cover - unused in this test
        class Cache:
            @staticmethod
            def positions_open():
                return []
        return Cache()


def ts_at(hour: int, minute: int) -> int:
    """Create timestamp in ET timezone (not UTC)."""
    try:
        from zoneinfo import ZoneInfo
        et_tz = ZoneInfo("America/New_York")
    except Exception:
        # Fallback for testing: use UTC offset approximation
        et_tz = datetime.timezone(datetime.timedelta(hours=-5))

    dt = datetime.datetime(2025, 1, 1, hour, minute, tzinfo=et_tz)
    return int(dt.timestamp() * 1e9)


def test_time_manager_allows_before_urgent_block():
    s = DummyStrategy()
    mgr = TimeConstraintManager(strategy=s, allow_overnight=False)
    assert mgr.check(ts_at(15, 0)) is True
    assert s._is_trading_allowed is True
    assert s._trading_blocked_today is False


def test_time_manager_blocks_new_trades_after_urgent():
    s = DummyStrategy()
    mgr = TimeConstraintManager(strategy=s, allow_overnight=False)
    assert mgr.can_open_new(ts_at(16, 30)) is False
    assert s.closed is False
    assert s._is_trading_allowed is True
    assert s._trading_blocked_today is False


def test_time_manager_flattens_in_emergency_window():
    s = DummyStrategy()
    mgr = TimeConstraintManager(strategy=s, allow_overnight=False)
    assert mgr.check(ts_at(16, 55)) is False
    assert s.canceled is True
    assert s.closed is True
    assert s._is_trading_allowed is False
    assert s._trading_blocked_today is True


def test_time_manager_blocks_and_flattens_at_cutoff():
    s = DummyStrategy()
    mgr = TimeConstraintManager(strategy=s, allow_overnight=False)
    assert mgr.check(ts_at(16, 59)) is False
    assert s.canceled is True
    assert s.closed is True
    assert s._is_trading_allowed is False
    assert s._trading_blocked_today is True


def test_time_manager_resets_daily():
    s = DummyStrategy()
    mgr = TimeConstraintManager(strategy=s, allow_overnight=False)
    mgr._issued.update({"warning", "urgent", "emergency"})
    mgr.reset_daily()
    assert mgr._issued == set()


def test_time_manager_wall_clock_check_uses_clock_timestamp(monkeypatch):
    s = DummyStrategy()

    class DummyClock:
        def timestamp_ns(self) -> int:
            return ts_at(16, 55)

        def timer_names(self) -> list[str]:
            return []

        def cancel_timer(self, _name: str) -> None:
            return None

        def set_timer_ns(self, *args, **kwargs) -> None:
            return None

    clk = DummyClock()
    mgr = TimeConstraintManager(strategy=s, allow_overnight=False, clock=clk, use_clock_timer=True)

    assert mgr.check_wall_clock() is False
    assert s.canceled is True
    assert s.closed is True
    assert s._is_trading_allowed is False
    assert s._trading_blocked_today is True


def test_time_manager_fail_safe_when_et_unavailable(monkeypatch):
    s = DummyStrategy()
    mgr = TimeConstraintManager(strategy=s, allow_overnight=False)

    import nautilus_gold_scalper.src.risk.time_constraint_manager as tcm

    monkeypatch.setattr(tcm, "ET_TZ", None)
    assert mgr.can_open_new(ts_at(10, 0)) is False
    assert mgr.check(ts_at(10, 0)) is False
    assert s.canceled is True
    assert s.closed is True
    assert s._is_trading_allowed is False
    assert s._trading_blocked_today is True
