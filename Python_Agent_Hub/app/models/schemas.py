"""
Pydantic Schemas for EA_SCALPER_XAUUSD Agent Hub
"""

from pydantic import BaseModel, Field
from typing import Optional, Dict, Any, List
from datetime import datetime


class HealthResponse(BaseModel):
    """Health check response."""
    status: str
    timestamp: float
    version: str
    uptime_seconds: float
    fred_configured: Optional[bool] = None
    newsapi_configured: Optional[bool] = None


class MacroData(BaseModel):
    """Macro economic data."""
    real_yield: Optional[float] = None
    nominal_yield: Optional[float] = None
    breakeven_inflation: Optional[float] = None
    dxy: Optional[float] = None
    dxy_ma20: Optional[float] = None
    vix: Optional[float] = None
    total_score: float = 0.0
    interpretation: str = "NEUTRAL"


class OilData(BaseModel):
    """Gold-Oil analysis data."""
    wti_price: Optional[float] = None
    gold_price: Optional[float] = None
    gold_oil_ratio: Optional[float] = None
    oil_change_5d: Optional[float] = None
    score: float = 0.0
    interpretation: str = "NEUTRAL"


class ETFData(BaseModel):
    """ETF flow analysis data."""
    etf: str = "GLD"
    price_change_pct: Optional[float] = None
    volume_ratio: Optional[float] = None
    flow: str = "NEUTRAL"
    score: float = 0.0
    interpretation: str = "NEUTRAL"


class SentimentData(BaseModel):
    """News sentiment data."""
    sentiment: str = "neutral"
    score: float = 0.0
    confidence: float = 0.0
    article_count: int = 0
    recent_headlines: Optional[List[str]] = None


class ComponentScores(BaseModel):
    """Component scores breakdown."""
    macro_score: float = 0.0
    oil_score: float = 0.0
    etf_score: float = 0.0


class FundamentalsDetails(BaseModel):
    """Detailed fundamentals response."""
    signal: str
    score: float
    bias: str
    components: ComponentScores


class SentimentDetails(BaseModel):
    """Detailed sentiment response."""
    signal: str
    score: float
    available: bool


class SignalResponse(BaseModel):
    """Trading signal response for MQL5 integration."""
    signal: str = Field(..., description="STRONG_BUY, BUY, NEUTRAL, SELL, STRONG_SELL")
    score: float = Field(..., description="Combined score (-10 to +10)")
    score_adjustment: int = Field(..., description="Points to add to technical score")
    size_multiplier: float = Field(..., description="Position size multiplier (0.5-1.0)")
    confidence: float = Field(..., description="Overall confidence (0.0-1.0)")
    fundamentals: Optional[FundamentalsDetails] = None
    sentiment: Optional[SentimentDetails] = None
    timestamp: str


class FundamentalsResponse(BaseModel):
    """Complete fundamentals analysis response."""
    macro: Dict[str, Any]
    oil: Dict[str, Any]
    etf: Dict[str, Any]
    total_score: float
    bias: str
    confidence: float
    timestamp: str


class TechnicalRequest(BaseModel):
    """Request for technical analysis."""
    symbol: str = "XAUUSD"
    timeframe: str = "M15"
    prices: Optional[List[float]] = None


class RegimeResponse(BaseModel):
    """Regime detection response."""
    regime: str
    hurst_exponent: float
    shannon_entropy: float
    size_multiplier: float
    score_adjustment: int
    action: str
    confidence: float
