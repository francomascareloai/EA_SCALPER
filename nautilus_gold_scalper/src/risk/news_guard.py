from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime

from ..signals.news_calendar import NewsTradeAction, NewsWindow


@dataclass(frozen=True)
class NewsGuardResult:
    allow_entry: bool
    reason: str | None = None
    news_window: NewsWindow | None = None


class NewsGuard:
    """Entry-only news blackout guard.

    Uses the existing `NewsWindow` semantics produced by `NewsCalendar.check_news_window`.
    """

    def evaluate_from_window(self, window: NewsWindow | None) -> NewsGuardResult:
        if window is None:
            return NewsGuardResult(True, None, None)

        if bool(window.in_window) and window.action == NewsTradeAction.BLOCK:
            return NewsGuardResult(False, "news_blackout", window)

        return NewsGuardResult(True, None, window)

    def evaluate(self, *, now_utc: datetime, window: NewsWindow) -> NewsGuardResult:
        # `NewsWindow` is already computed at `now_utc` by NewsCalendar.check_news_window(now=...).
        _ = now_utc
        return self.evaluate_from_window(window)
