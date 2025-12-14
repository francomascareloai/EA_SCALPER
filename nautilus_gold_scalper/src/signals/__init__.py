"""Signal generation modules."""

from .mtf_manager import MTFManager, MTFState, TimeframeAnalysis
from .confluence_scorer import ConfluenceScorer, ScoringComponents
from .news_calendar import (
    NewsCalendar,
    NewsEvent,
    NewsWindow,
    NewsImpact,
    NewsTradeAction,
    get_weekly_events_for_day,
)
from .entry_optimizer import (
    EntryOptimizer,
    OptimalEntry,
    EntryType,
    EntryQuality,
    SignalDirection,
)

__all__ = [
    'MTFManager',
    'MTFState',
    'TimeframeAnalysis',
    'ConfluenceScorer',
    'ScoringComponents',
    'NewsCalendar',
    'NewsEvent',
    'NewsWindow',
    'NewsImpact',
    'NewsTradeAction',
    'get_weekly_events_for_day',
    'EntryOptimizer',
    'OptimalEntry',
    'EntryType',
    'EntryQuality',
    'SignalDirection',
]
