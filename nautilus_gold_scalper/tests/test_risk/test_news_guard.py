from nautilus_gold_scalper.src.risk.news_guard import NewsGuard
from nautilus_gold_scalper.src.signals.news_calendar import NewsTradeAction, NewsWindow


def test_news_guard_blocks_on_block_action() -> None:
    guard = NewsGuard()
    window = NewsWindow(in_window=True, action=NewsTradeAction.BLOCK)
    r = guard.evaluate_from_window(window)
    assert r.allow_entry is False
    assert r.reason == "news_blackout"


def test_news_guard_allows_when_not_in_window() -> None:
    guard = NewsGuard()
    window = NewsWindow(in_window=False, action=NewsTradeAction.TRADE_NORMAL)
    r = guard.evaluate_from_window(window)
    assert r.allow_entry is True
    assert r.reason is None
