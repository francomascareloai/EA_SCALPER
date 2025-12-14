"""
Memory API Router
EA_SCALPER_XAUUSD - Learning Edition

REST API endpoints for Trade Memory and Reflection system.
Called by MQL5 via HTTP for trade analysis and memory checks.
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from typing import Dict, List, Optional
from datetime import datetime
import logging

# Import memory modules
from ml_pipeline.memory import TradeMemory, TradeRecord, ReflectionEngine, RiskModeSelector

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/memory", tags=["memory"])

# Initialize global instances
_memory: Optional[TradeMemory] = None
_reflection: Optional[ReflectionEngine] = None
_risk_selector: Optional[RiskModeSelector] = None


def get_memory() -> TradeMemory:
    global _memory
    if _memory is None:
        _memory = TradeMemory()
    return _memory


def get_reflection() -> ReflectionEngine:
    global _reflection
    if _reflection is None:
        _reflection = ReflectionEngine(memory=get_memory())
    return _reflection


def get_risk_selector() -> RiskModeSelector:
    global _risk_selector
    if _risk_selector is None:
        _risk_selector = RiskModeSelector(memory=get_memory())
    return _risk_selector


# ============== Request/Response Models ==============

class MemoryCheckRequest(BaseModel):
    """Request to check if situation should be avoided."""
    features: Dict[str, float] = Field(..., description="Current market features")
    direction: str = Field(..., description="BUY or SELL")
    regime: str = Field(..., description="TRENDING, REVERTING, or RANDOM")
    session: str = Field(..., description="ASIAN, LONDON, or NY")


class MemoryCheckResponse(BaseModel):
    """Response from memory check."""
    should_trade: bool
    avoid_reason: Optional[str] = None
    similar_trades_found: int
    win_rate: float
    avg_r_multiple: float
    confidence: float


class TradeRecordRequest(BaseModel):
    """Request to record a completed trade."""
    ticket: int
    symbol: str = "XAUUSD"
    direction: str
    entry_time: str  # ISO format
    exit_time: str  # ISO format
    entry_price: float
    exit_price: float
    stop_loss: float
    take_profit: float
    profit_loss: float
    profit_pips: float
    r_multiple: float
    is_winner: bool
    features: Dict[str, float]
    regime: str
    session: str
    spread_state: str = "NORMAL"
    news_window: bool = False
    confluence_score: int = 0
    signal_tier: str = "C"


class TradeRecordResponse(BaseModel):
    """Response after recording trade."""
    success: bool
    trade_id: int
    reflection: Optional[str] = None
    lessons: List[str] = []
    recommendation: str = ""


class RiskModeRequest(BaseModel):
    """Request for risk mode determination."""
    daily_dd: float = Field(..., description="Daily drawdown %")
    total_dd: float = Field(..., description="Total drawdown %")
    last_trade_result: Optional[float] = None
    is_new_day: bool = False


class RiskModeResponse(BaseModel):
    """Response with risk mode recommendation."""
    mode: str  # AGGRESSIVE, NEUTRAL, CONSERVATIVE
    size_multiplier: float
    score_adjustment: int
    can_trade: bool
    reasoning: str


class StatisticsResponse(BaseModel):
    """Memory statistics response."""
    total_trades: int
    winners: int
    win_rate: float
    avg_r_multiple: float
    avg_pips: float
    unique_situations: int


# ============== API Endpoints ==============

@router.post("/check", response_model=MemoryCheckResponse)
async def check_memory(request: MemoryCheckRequest):
    """
    Check if current situation should be avoided based on memory.
    
    Called by MQL5 before opening a trade.
    Response time target: < 50ms
    """
    try:
        memory = get_memory()
        
        query = memory.check_situation(
            features=request.features,
            direction=request.direction,
            regime=request.regime,
            session=request.session
        )
        
        return MemoryCheckResponse(
            should_trade=not query.should_avoid,
            avoid_reason=query.avoid_reason,
            similar_trades_found=query.total_found,
            win_rate=query.win_rate,
            avg_r_multiple=query.avg_r_multiple,
            confidence=query.confidence
        )
    
    except Exception as e:
        logger.error(f"Memory check error: {e}")
        # Fail open - allow trade if memory fails
        return MemoryCheckResponse(
            should_trade=True,
            avoid_reason=None,
            similar_trades_found=0,
            win_rate=0.5,
            avg_r_multiple=0,
            confidence=0
        )


@router.post("/record", response_model=TradeRecordResponse)
async def record_trade(request: TradeRecordRequest):
    """
    Record a completed trade and get reflection.
    
    Called by MQL5 after trade closes.
    """
    try:
        memory = get_memory()
        reflection_engine = get_reflection()
        
        # Convert request to TradeRecord
        trade = TradeRecord(
            ticket=request.ticket,
            symbol=request.symbol,
            direction=request.direction,
            entry_time=datetime.fromisoformat(request.entry_time),
            exit_time=datetime.fromisoformat(request.exit_time),
            entry_price=request.entry_price,
            exit_price=request.exit_price,
            stop_loss=request.stop_loss,
            take_profit=request.take_profit,
            profit_loss=request.profit_loss,
            profit_pips=request.profit_pips,
            r_multiple=request.r_multiple,
            is_winner=request.is_winner,
            features=request.features,
            regime=request.regime,
            session=request.session,
            spread_state=request.spread_state,
            news_window=request.news_window,
            confluence_score=request.confluence_score,
            signal_tier=request.signal_tier
        )
        
        # Record to memory
        trade_id = memory.record_trade(trade)
        
        # Generate reflection
        reflection_result = reflection_engine.reflect_and_store(trade)
        
        # Update risk selector state
        risk_selector = get_risk_selector()
        risk_selector.update_state(request.profit_loss)
        
        return TradeRecordResponse(
            success=True,
            trade_id=trade_id,
            reflection=reflection_result.reflection,
            lessons=reflection_result.lessons,
            recommendation=reflection_result.recommendation
        )
    
    except Exception as e:
        logger.error(f"Record trade error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/risk-mode", response_model=RiskModeResponse)
async def get_risk_mode(request: RiskModeRequest):
    """
    Get current risk mode recommendation.
    
    Returns AGGRESSIVE, NEUTRAL, or CONSERVATIVE based on conditions.
    """
    try:
        risk_selector = get_risk_selector()
        
        # Update state if trade result provided
        if request.last_trade_result is not None:
            risk_selector.update_state(request.last_trade_result, request.is_new_day)
        
        # Get mode
        mode = risk_selector.get_mode(request.daily_dd, request.total_dd)
        
        return RiskModeResponse(
            mode=mode['mode'],
            size_multiplier=mode['size_multiplier'],
            score_adjustment=mode.get('score_adjustment', 0),
            can_trade=mode['can_trade'],
            reasoning=mode['reasoning']
        )
    
    except Exception as e:
        logger.error(f"Risk mode error: {e}")
        # Default to neutral on error
        return RiskModeResponse(
            mode='NEUTRAL',
            size_multiplier=1.0,
            score_adjustment=0,
            can_trade=True,
            reasoning='Default mode (error occurred)'
        )


@router.get("/statistics", response_model=StatisticsResponse)
async def get_statistics():
    """Get overall memory statistics."""
    try:
        memory = get_memory()
        stats = memory.get_statistics()
        
        return StatisticsResponse(**stats)
    
    except Exception as e:
        logger.error(f"Statistics error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/worst-situations")
async def get_worst_situations(limit: int = 10):
    """Get situations with worst historical performance."""
    try:
        memory = get_memory()
        return memory.get_worst_situations(limit)
    
    except Exception as e:
        logger.error(f"Worst situations error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/recent-trades")
async def get_recent_trades(limit: int = 20):
    """Get most recent trades from memory."""
    try:
        memory = get_memory()
        trades = memory.get_recent_trades(limit)
        
        # Convert to dicts for JSON response
        return [
            {
                'ticket': t.ticket,
                'direction': t.direction,
                'entry_time': t.entry_time.isoformat(),
                'r_multiple': t.r_multiple,
                'is_winner': t.is_winner,
                'regime': t.regime,
                'session': t.session,
                'reflection': t.reflection
            }
            for t in trades
        ]
    
    except Exception as e:
        logger.error(f"Recent trades error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/health")
async def health_check():
    """Health check for memory system."""
    try:
        memory = get_memory()
        stats = memory.get_statistics()
        
        return {
            'status': 'healthy',
            'total_trades_in_memory': stats['total_trades'],
            'memory_system': 'SQLite',
            'reflection_system': 'rule-based'
        }
    
    except Exception as e:
        return {
            'status': 'unhealthy',
            'error': str(e)
        }


@router.post("/reset")
async def reset_memory():
    """
    Reset memory (for testing/debugging).
    
    WARNING: Deletes all trade history!
    """
    global _memory, _reflection, _risk_selector
    
    try:
        # Reinitialize
        _memory = TradeMemory()
        _reflection = ReflectionEngine(memory=_memory)
        _risk_selector = RiskModeSelector(memory=_memory)
        
        return {'success': True, 'message': 'Memory reset successfully'}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
