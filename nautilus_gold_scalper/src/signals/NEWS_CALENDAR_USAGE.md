# NewsCalendar Module - Usage Guide

## Overview

The `NewsCalendar` module provides economic news event detection and trading window management for the Gold Scalper strategy. Migrated from MQL5 `CNewsCalendarNative.mqh`.

## Features

- ✓ **Hardcoded Major Events** - Always works, no API dependency
- ✓ **Multiple Impact Levels** - CRITICAL, HIGH, MEDIUM, LOW
- ✓ **Time Window Detection** - Pre-news, blackout, post-news periods
- ✓ **Trading Actions** - BLOCK, STRADDLE, PREPOSITION, PULLBACK, CAUTION
- ✓ **Score Adjustments** - Confluence score integration
- ✓ **Size Multipliers** - Position size risk management
- ✓ **Weekly Schedule** - Typical events by day of week

## Quick Start

```python
from src.signals.news_calendar import NewsCalendar, NewsImpact

# Initialize
calendar = NewsCalendar(
    minutes_before_high=30,  # Window before HIGH events
    minutes_after_high=15,    # Window after HIGH events
    blackout_minutes=5,       # Hard blackout before/after
)

# Check current status
window = calendar.check_news_window()

if window.action == NewsTradeAction.BLOCK:
    # Don't trade!
    print(f"Trading blocked: {window.reason}")
elif window.action == NewsTradeAction.TRADE_CAUTION:
    # Reduce size
    lot_size *= window.size_multiplier  # 0.75x
else:
    # Trade normally
    pass
```

## Main Methods

### Check News Window

```python
window = calendar.check_news_window()

# Returns NewsWindow with:
# - in_window: bool (are we in a news window?)
# - action: NewsTradeAction (BLOCK, STRADDLE, etc.)
# - event: NewsEvent (the causing event)
# - minutes_to_event: int (time until event)
# - score_adjustment: int (for confluence scoring)
# - size_multiplier: float (position size multiplier)
# - reason: str (human-readable explanation)
```

### Get Events

```python
# Today's events
today = calendar.get_events_today()

# This week's events
week = calendar.get_events_this_week()

# Next HIGH/CRITICAL event
next_event = calendar.get_next_high_impact()
if next_event:
    print(f"{next_event.event_name} at {next_event.time_utc}")
```

### Quick Checks

```python
# Is it a blackout period? (±5 min)
if calendar.is_blackout_period():
    # Don't trade!
    pass

# Are we in a news window? (±30 min default)
if calendar.is_news_window(minutes_before=30, minutes_after=30):
    # Be cautious
    pass

# Should we reduce risk?
if calendar.should_reduce_risk():
    lot_size *= calendar.get_size_multiplier()
    
# Minutes to next event
minutes = calendar.minutes_to_next_event()
```

## Impact Levels

| Impact | Examples | Window |
|--------|----------|--------|
| **CRITICAL** | FOMC, NFP, Powell Speech | ±45 min, ALWAYS BLOCK |
| **HIGH** | CPI, GDP, Unemployment | ±30 min |
| **MEDIUM** | Retail Sales, PMI | ±15 min |
| **LOW** | Consumer Confidence | Ignored |

## Trading Actions

| Action | When | Size Multiplier | Score Adj |
|--------|------|-----------------|-----------|
| **BLOCK** | ±5 min from event | 0.0 | -50 to -100 |
| **STRADDLE** | 5-10 min before | 0.25 | -30 |
| **PREPOSITION** | 10-30 min before | 0.5 | -15 |
| **PULLBACK** | 5-15 min after | 0.5 | -20 |
| **TRADE_CAUTION** | 30-60 min before | 0.75 | -5 |
| **TRADE_NORMAL** | No news nearby | 1.0 | 0 |

## Integration with Strategy

### In Confluence Scoring

```python
# In ConfluenceScorer.calculate_score()
news_adjustment = self.news_calendar.get_score_adjustment()
score += news_adjustment

# Block trade if necessary
if self.news_calendar.check_news_window().action == NewsTradeAction.BLOCK:
    return 0  # Don't trade
```

### In Position Sizing

```python
# In calculate_position_size()
base_lot = calculate_base_lot()
news_multiplier = self.news_calendar.get_size_multiplier()
final_lot = base_lot * news_multiplier
```

### In Strategy on_bar()

```python
def on_bar(self, bar: Bar) -> None:
    # Check news before generating signals
    window = self.news_calendar.check_news_window()
    
    if window.action == NewsTradeAction.BLOCK:
        self.log.warning(f"Trading blocked: {window.reason}")
        return
    
    # Adjust confluence threshold if caution
    threshold = 65
    if window.action == NewsTradeAction.TRADE_CAUTION:
        threshold = 70  # Higher bar during news
    
    # Generate signal...
    score = self.confluence_scorer.calculate_score()
    
    if score >= threshold:
        # Trade with adjusted size
        size = self.calculate_size() * window.size_multiplier
        self.buy(size)
```

## Gold-Relevant Events

The module tracks these major events (auto-detected in event names):

- **Fed & Rates**: FOMC, Fed Rate Decision, Powell Speech
- **Employment**: NFP, Unemployment, Jobless Claims, ADP
- **Inflation**: CPI, Core CPI, PPI, PCE
- **Growth**: GDP
- **Retail & Manufacturing**: Retail Sales, ISM PMI, Durable Goods
- **Trade**: Trade Balance

## Weekly Schedule

| Day | Typical Events |
|-----|----------------|
| **Monday** | ISM Services |
| **Tuesday** | Consumer Confidence, Trade Balance |
| **Wednesday** | ADP Employment, FOMC (monthly) |
| **Thursday** | Jobless Claims, GDP (quarterly) |
| **Friday** | NFP, Unemployment, CPI |

```python
from src.signals.news_calendar import get_weekly_events_for_day

friday_events = get_weekly_events_for_day("Friday")
# ['Nonfarm Payrolls', 'NFP', 'Unemployment Rate', 'CPI']
```

## Data Sources

### Current (v1.0)
- **Hardcoded Events**: Major 2025 events (always works)

### Future (Optional)
- **Forex Factory Scraping**: Real-time data
- **Economic Calendar API**: Third-party services
- **MQL5 Calendar Bridge**: Via Python Hub

## Caching

Events are cached for 60 minutes by default:

```python
calendar = NewsCalendar()
calendar._cache_ttl_minutes = 30  # Refresh every 30 min

# Manual refresh
calendar._refresh_cache()
```

## Status & Debugging

```python
calendar.print_status()

# Output:
# === NewsCalendar Status ===
# Cached Events: 7
# Cache Age: 15 minutes
# In News Window: False
# Action: TRADE_NORMAL
# ...
```

## Example: Full Integration

```python
class GoldScalperStrategy(Strategy):
    def on_start(self):
        # Initialize calendar
        self.news_calendar = NewsCalendar(
            minutes_before_high=30,
            minutes_after_high=15,
            blackout_minutes=5,
        )
        
    def on_bar(self, bar: Bar):
        # Check news first
        window = self.news_calendar.check_news_window()
        
        if window.action == NewsTradeAction.BLOCK:
            self.log.warning(f"News block: {window.reason}")
            return
        
        # Calculate confluence with news adjustment
        score = self.confluence_scorer.calculate_score()
        score += window.score_adjustment
        
        # Adjust threshold if caution
        threshold = 70 if window.action == NewsTradeAction.TRADE_CAUTION else 65
        
        if score >= threshold:
            # Calculate size with news multiplier
            base_size = self.calculate_base_size()
            final_size = base_size * window.size_multiplier
            
            self.buy(final_size)
```

## Migration Notes

### From MQL5 to Python

| MQL5 | Python |
|------|--------|
| `CNewsCalendarNative` | `NewsCalendar` |
| `SNewsEventNative` | `NewsEvent` (dataclass) |
| `SNewsWindowNative` | `NewsWindow` (dataclass) |
| `ENUM_NATIVE_NEWS_IMPACT` | `NewsImpact` (IntEnum) |
| `ENUM_NEWS_TRADE_ACTION` | `NewsTradeAction` (IntEnum) |
| `CheckNewsWindow()` | `check_news_window()` |
| `IsInNewsWindow()` | `is_news_window()` |
| `ShouldBlockTrading()` | `is_blackout_period()` |

### Key Differences

1. **Timezone Handling**: Python uses `datetime.timezone.utc` explicitly
2. **Data Sources**: MQL5 uses native calendar API, Python uses hardcoded + optional external
3. **Caching**: Both cache events, Python uses timedelta for TTL
4. **Type Safety**: Python uses dataclasses and type hints

## Testing

```bash
cd nautilus_gold_scalper
python test_news_calendar.py
```

All 7 tests should pass:
- ✓ Initialization
- ✓ Event Retrieval
- ✓ News Window Detection
- ✓ Blackout & Risk Checks
- ✓ Weekly Schedule
- ✓ Custom Event (5 min test)
- ✓ Status Print

## Maintenance

### Adding New Events

Edit `get_hardcoded_events_2025()` in `news_calendar.py`:

```python
# Add January 2026 events
january_events = [
    NewsEvent(
        time_utc=datetime(2026, 1, 10, 13, 30, tzinfo=timezone.utc),
        event_name="Nonfarm Payrolls",
        impact=NewsImpact.CRITICAL,
    ),
]
events.extend(january_events)
```

### Updating Weekly Schedule

Edit `WEEKLY_SCHEDULE` dict in `news_calendar.py`:

```python
WEEKLY_SCHEDULE = {
    "Wednesday": [
        "ADP Employment",
        "FOMC Statement",
        "New Event Here",  # Add
    ],
}
```

---

**Version**: 1.0  
**Author**: FORGE v4.0  
**Date**: 2025-12-03  
**Status**: Production Ready ✓
