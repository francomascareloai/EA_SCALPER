"""
Economic Calendar API Router
============================
FastAPI endpoints for economic calendar service.

Endpoints:
- GET /calendar/events       - Get upcoming events
- GET /calendar/next-high    - Get next high impact event
- GET /calendar/news-window  - Check if in news window
- GET /calendar/export       - Export to CSV
- GET /calendar/health       - Service health check
"""

from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
import logging

from app.services.economic_calendar import (
    get_calendar_service,
    EconomicEvent,
    NewsImpact
)

logger = logging.getLogger(__name__)

router = APIRouter()


class EventResponse(BaseModel):
    """Response model for a single event."""
    timestamp_utc: int
    datetime_str: str
    event: str
    currency: str
    impact: str
    forecast: Optional[float]
    previous: Optional[float]
    actual: Optional[float]
    minutes_from_now: Optional[int]


class NewsWindowResponse(BaseModel):
    """Response model for news window check."""
    in_window: bool
    event: Optional[EventResponse]
    minutes_to_event: Optional[int]
    is_before_event: Optional[bool]
    recommendation: str


class CalendarHealthResponse(BaseModel):
    """Response model for health check."""
    status: str
    finnhub_api: str
    cache_valid: bool
    cached_events: int
    last_update: Optional[str]


def event_to_response(event: EconomicEvent, now_ts: int = None) -> EventResponse:
    """Convert EconomicEvent to response model."""
    minutes_from_now = None
    if now_ts:
        minutes_from_now = int((event.timestamp_utc - now_ts) / 60)
    
    return EventResponse(
        timestamp_utc=event.timestamp_utc,
        datetime_str=event.datetime_utc.strftime("%Y-%m-%d %H:%M UTC"),
        event=event.event,
        currency=event.currency,
        impact=event.impact.value,
        forecast=event.forecast,
        previous=event.previous,
        actual=event.actual,
        minutes_from_now=minutes_from_now
    )


@router.get("/events", response_model=List[EventResponse])
async def get_upcoming_events(
    hours: int = Query(24, ge=1, le=168, description="Hours to look ahead (max 168 = 1 week)")
):
    """
    Get upcoming economic events.
    
    Returns events in the next N hours, sorted by time.
    Only includes US events relevant to Gold trading.
    """
    try:
        service = get_calendar_service()
        events = service.get_upcoming_events(hours)
        
        now_ts = int(datetime.utcnow().timestamp())
        
        return [event_to_response(e, now_ts) for e in events]
    except Exception as e:
        logger.error(f"Error getting events: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/next-high", response_model=Optional[EventResponse])
async def get_next_high_impact():
    """
    Get the next HIGH impact event.
    
    Returns the nearest upcoming event with HIGH impact level.
    These are events like Fed Decision, NFP, CPI.
    """
    try:
        service = get_calendar_service()
        event = service.get_next_high_impact_event()
        
        if not event:
            return None
        
        now_ts = int(datetime.utcnow().timestamp())
        return event_to_response(event, now_ts)
    except Exception as e:
        logger.error(f"Error getting next high impact: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/news-window", response_model=NewsWindowResponse)
async def check_news_window(
    minutes_before: int = Query(30, ge=5, le=120, description="Minutes before event to start window"),
    minutes_after: int = Query(15, ge=5, le=60, description="Minutes after event to end window")
):
    """
    Check if we're currently in a news trading window.
    
    This is the KEY ENDPOINT for the EA to call before trading.
    
    Returns:
    - in_window: True if within news window
    - event: The event causing the window (if any)
    - minutes_to_event: Minutes until event (negative if passed)
    - recommendation: Trading recommendation
    """
    try:
        service = get_calendar_service()
        result = service.is_in_news_window(minutes_before, minutes_after)
        
        event_response = None
        if result['event']:
            now_ts = int(datetime.utcnow().timestamp())
            event_response = event_to_response(result['event'], now_ts)
        
        # Determine recommendation
        if not result['in_window']:
            recommendation = "TRADE_NORMAL"
        elif result['is_before_event']:
            if result['minutes_to_event'] <= 5:
                recommendation = "NO_TRADE"
            elif result['minutes_to_event'] <= 15:
                recommendation = "NEWS_STRADDLE"
            else:
                recommendation = "NEWS_PREPOSITION"
        else:
            # After event
            if result['minutes_to_event'] >= -2:
                recommendation = "NO_TRADE"
            else:
                recommendation = "NEWS_PULLBACK"
        
        return NewsWindowResponse(
            in_window=result['in_window'],
            event=event_response,
            minutes_to_event=result['minutes_to_event'],
            is_before_event=result['is_before_event'],
            recommendation=recommendation
        )
    except Exception as e:
        logger.error(f"Error checking news window: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/today")
async def get_today_events():
    """Get all events for today."""
    try:
        service = get_calendar_service()
        events = service.get_events_for_date(datetime.utcnow())
        
        now_ts = int(datetime.utcnow().timestamp())
        
        return {
            'date': datetime.utcnow().strftime("%Y-%m-%d"),
            'count': len(events),
            'events': [event_to_response(e, now_ts) for e in events]
        }
    except Exception as e:
        logger.error(f"Error getting today's events: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/export")
async def export_calendar(
    filepath: str = Query(..., description="Path to export CSV file")
):
    """
    Export calendar to CSV file.
    
    The CSV can be loaded by MQL5 for offline/backtest use.
    """
    try:
        service = get_calendar_service()
        service.export_to_csv(filepath)
        
        return {
            'status': 'success',
            'filepath': filepath,
            'message': 'Calendar exported successfully'
        }
    except Exception as e:
        logger.error(f"Error exporting calendar: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/health", response_model=CalendarHealthResponse)
async def calendar_health():
    """
    Check economic calendar service health.
    
    Checks:
    - Finnhub API connectivity
    - Cache validity
    - Number of cached events
    """
    try:
        service = get_calendar_service()
        health = service.health_check()
        
        return CalendarHealthResponse(**health)
    except Exception as e:
        logger.error(f"Error in health check: {e}")
        return CalendarHealthResponse(
            status='error',
            finnhub_api='unknown',
            cache_valid=False,
            cached_events=0,
            last_update=None
        )


@router.get("/signal")
async def get_calendar_signal(
    minutes_before: int = Query(30, ge=5, le=120),
    minutes_after: int = Query(15, ge=5, le=60)
):
    """
    Get trading signal based on calendar.
    
    This is a simplified endpoint for MQL5 integration.
    Returns a single signal value that the EA can use directly.
    """
    try:
        service = get_calendar_service()
        result = service.is_in_news_window(minutes_before, minutes_after)
        
        # Calculate score adjustment
        if not result['in_window']:
            score_adjustment = 0
            action = "NORMAL"
            block_trade = False
        else:
            event = result['event']
            is_before = result['is_before_event']
            minutes = abs(result['minutes_to_event'])
            
            if event.impact == NewsImpact.HIGH:
                if minutes <= 5:
                    score_adjustment = -50  # Strong block
                    action = "BLOCK"
                    block_trade = True
                elif minutes <= 15:
                    score_adjustment = -30
                    action = "STRADDLE" if is_before else "PULLBACK"
                    block_trade = False
                else:
                    score_adjustment = -15
                    action = "CAUTION"
                    block_trade = False
            else:  # MEDIUM
                if minutes <= 5:
                    score_adjustment = -20
                    action = "BLOCK"
                    block_trade = True
                else:
                    score_adjustment = -10
                    action = "CAUTION"
                    block_trade = False
        
        return {
            'in_news_window': result['in_window'],
            'score_adjustment': score_adjustment,
            'action': action,
            'block_trade': block_trade,
            'event_name': result['event'].event if result['event'] else None,
            'event_impact': result['event'].impact.value if result['event'] else None,
            'minutes_to_event': result['minutes_to_event'],
            'timestamp': int(datetime.utcnow().timestamp())
        }
    except Exception as e:
        logger.error(f"Error getting calendar signal: {e}")
        # Fail safe - don't block trading if service fails
        return {
            'in_news_window': False,
            'score_adjustment': 0,
            'action': "NORMAL",
            'block_trade': False,
            'event_name': None,
            'event_impact': None,
            'minutes_to_event': None,
            'timestamp': int(datetime.utcnow().timestamp()),
            'error': str(e)
        }
