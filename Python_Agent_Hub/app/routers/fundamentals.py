"""
Fundamentals API Router
=======================
FastAPI endpoints for gold fundamentals analysis.

Endpoints:
- GET  /fundamentals        - Complete fundamental analysis
- GET  /macro               - Macro data (real yields, DXY, VIX)
- GET  /oil                 - Gold-Oil analysis
- GET  /etf                 - GLD ETF flows
- GET  /sentiment           - News sentiment (FinBERT)
- GET  /signal              - Aggregated trading signal for EA

All endpoints return JSON compatible with MQL5 integration.
"""

from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel
from typing import Optional, Dict, Any
from datetime import datetime
import logging

from app.services.gold_fundamentals import get_fundamentals_service
from app.services.news_sentiment import get_sentiment_service

logger = logging.getLogger(__name__)

router = APIRouter()


class SignalResponse(BaseModel):
    """Response model for trading signals."""
    signal: str
    score: float
    score_adjustment: int
    size_multiplier: float
    bias: str
    confidence: float
    timestamp: str


class FundamentalsResponse(BaseModel):
    """Response model for complete fundamentals."""
    macro: Dict[str, Any]
    oil: Dict[str, Any]
    etf: Dict[str, Any]
    total_score: float
    bias: str
    confidence: float
    timestamp: str


@router.get("/fundamentals")
async def get_fundamentals():
    """
    Get complete fundamental analysis for XAUUSD.
    
    Combines:
    - Macro factors (real yields, DXY, VIX)
    - Oil analysis (gold-oil ratio)
    - ETF flows (GLD)
    
    Returns weighted score and bias for trading decisions.
    """
    try:
        service = get_fundamentals_service()
        analysis = service.get_complete_analysis()
        return analysis
    except Exception as e:
        logger.error(f"Error in fundamentals: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/macro")
async def get_macro():
    """
    Get macro economic analysis.
    
    Data from FRED API:
    - Real Yields (10Y Treasury - Breakeven Inflation)
    - DXY (Dollar Index)
    - VIX (Fear Index)
    
    Each factor includes score and interpretation.
    """
    try:
        service = get_fundamentals_service()
        return service.macro.get_complete_analysis()
    except Exception as e:
        logger.error(f"Error in macro: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/oil")
async def get_oil():
    """
    Get Gold-Oil relationship analysis.
    
    CRITICAL: Research shows oil has 42% feature importance for gold prediction.
    
    Returns:
    - WTI price
    - Gold-Oil ratio
    - Score based on ratio deviation
    """
    try:
        service = get_fundamentals_service()
        return service.oil.get_oil_analysis()
    except Exception as e:
        logger.error(f"Error in oil analysis: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/etf")
async def get_etf(period: str = Query("20d", description="Period for analysis")):
    """
    Get GLD ETF flow analysis.
    
    Analyzes volume patterns to detect institutional flows.
    
    Parameters:
    - period: Time period (default: 20d)
    
    Returns flow direction and score.
    """
    try:
        service = get_fundamentals_service()
        return service.etf.get_etf_analysis(period)
    except Exception as e:
        logger.error(f"Error in ETF analysis: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/sentiment")
async def get_sentiment(days: int = Query(2, ge=1, le=7, description="Days of news to analyze")):
    """
    Get news sentiment analysis using FinBERT.
    
    Analyzes gold-related news from NewsAPI:
    - "gold price"
    - "gold xauusd"
    - "gold federal reserve"
    
    Parameters:
    - days: Number of days to look back (1-7)
    
    Returns sentiment score and trading signal.
    """
    try:
        service = get_sentiment_service()
        return service.analyze_gold_sentiment(days)
    except Exception as e:
        logger.error(f"Error in sentiment: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/sentiment/signal")
async def get_sentiment_signal():
    """
    Get trading signal based on news sentiment.
    
    Returns simplified signal for EA integration.
    """
    try:
        service = get_sentiment_service()
        return service.get_trading_signal()
    except Exception as e:
        logger.error(f"Error in sentiment signal: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/signal")
async def get_trading_signal():
    """
    Get aggregated trading signal for EA.
    
    This is the MAIN ENDPOINT for MQL5 integration.
    
    Combines:
    - Fundamentals (45%): Macro, Oil, ETF
    - Sentiment (15%): FinBERT news analysis
    
    Returns:
    - signal: STRONG_BUY, BUY, NEUTRAL, SELL, STRONG_SELL
    - score_adjustment: Points to add/subtract from technical score
    - size_multiplier: Position size multiplier
    - confidence: 0.0 to 1.0
    """
    try:
        # Get fundamentals signal
        fund_service = get_fundamentals_service()
        fund_signal = fund_service.get_trading_signal()
        
        # Get sentiment signal (optional - may fail if FinBERT not loaded)
        try:
            sent_service = get_sentiment_service()
            sent_signal = sent_service.get_trading_signal()
            has_sentiment = True
        except Exception as e:
            logger.warning(f"Sentiment unavailable: {e}")
            sent_signal = {'score': 0, 'score_adjustment': 0, 'confidence': 0.5}
            has_sentiment = False
        
        # Weighted combination
        fund_weight = 0.85
        sent_weight = 0.15 if has_sentiment else 0.0
        
        combined_score = (
            fund_signal['score'] * fund_weight +
            sent_signal.get('score', 0) * sent_weight
        )
        
        combined_adjustment = int(
            fund_signal['score_adjustment'] * fund_weight +
            sent_signal.get('score_adjustment', 0) * sent_weight
        )
        
        # Final signal determination
        if combined_score > 4:
            final_signal = 'STRONG_BUY'
        elif combined_score > 2:
            final_signal = 'BUY'
        elif combined_score > -2:
            final_signal = 'NEUTRAL'
        elif combined_score > -4:
            final_signal = 'SELL'
        else:
            final_signal = 'STRONG_SELL'
        
        # Confidence
        confidence = (
            fund_signal['confidence'] * fund_weight +
            sent_signal.get('confidence', 0.5) * sent_weight
        )
        
        return {
            'signal': final_signal,
            'score': round(combined_score, 2),
            'score_adjustment': combined_adjustment,
            'size_multiplier': fund_signal['size_multiplier'],
            'confidence': round(confidence, 2),
            'fundamentals': {
                'signal': fund_signal['signal'],
                'score': fund_signal['score'],
                'bias': fund_signal['bias'],
                'components': fund_signal['components']
            },
            'sentiment': {
                'signal': sent_signal.get('signal', 'N/A'),
                'score': sent_signal.get('score', 0),
                'available': has_sentiment
            },
            'timestamp': datetime.now().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Error generating signal: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/health")
async def fundamentals_health():
    """Check fundamentals service health."""
    import os
    
    fred_ok = bool(os.getenv('FRED_API_KEY'))
    news_ok = bool(os.getenv('NEWSAPI_KEY'))
    
    return {
        'status': 'ok' if fred_ok else 'degraded',
        'fred_api': 'configured' if fred_ok else 'missing',
        'newsapi': 'configured' if news_ok else 'missing',
        'timestamp': datetime.now().isoformat()
    }
