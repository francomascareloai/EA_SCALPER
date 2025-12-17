from datetime import datetime, timezone

from src.core.definitions import SessionQuality, TradingSession
from src.indicators.session_filter import SessionFilter


class TestSessionFilter:
    def test_london_session_detected(self):
        sf = SessionFilter()
        dt = datetime(2024, 1, 9, 10, 0, 0, tzinfo=timezone.utc)
        info = sf.get_session_info(dt)
        assert info.session == TradingSession.SESSION_LONDON
        assert info.is_trading_allowed is True

    def test_asian_blocked_by_default(self):
        sf = SessionFilter()
        dt = datetime(2024, 1, 9, 3, 0, 0, tzinfo=timezone.utc)
        info = sf.get_session_info(dt)
        assert info.session == TradingSession.SESSION_ASIAN
        assert info.is_trading_allowed is False

    def test_overlap_is_prime(self):
        sf = SessionFilter()
        dt = datetime(2024, 1, 9, 13, 0, 0, tzinfo=timezone.utc)
        info = sf.get_session_info(dt)
        assert info.session == TradingSession.SESSION_LONDON_NY_OVERLAP
        assert info.quality == SessionQuality.SESSION_QUALITY_PRIME

    def test_weekend_blocked(self):
        sf = SessionFilter()
        dt = datetime(2024, 1, 13, 10, 0, 0, tzinfo=timezone.utc)  # Saturday
        info = sf.get_session_info(dt)
        assert info.session == TradingSession.SESSION_WEEKEND
        assert info.is_trading_allowed is False
