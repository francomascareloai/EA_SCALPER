"""
Gold Fundamentals Analyzer
==========================
Analyzes macro factors that drive XAUUSD price:
- Real Yields (Primary driver)
- Crude Oil (Discovery: 42% feature importance!)
- DXY (Dollar strength)
- VIX (Fear/volatility)

Based on deep research indexed in RAG.
"""

import os
import logging
from datetime import datetime, timedelta
from typing import Optional
import numpy as np

logger = logging.getLogger(__name__)

# Lazy imports to avoid startup delay
_fred = None
_yf = None

def get_fred():
    global _fred
    if _fred is None:
        from fredapi import Fred
        api_key = os.getenv('FRED_API_KEY')
        if not api_key:
            raise ValueError("FRED_API_KEY not set in environment")
        _fred = Fred(api_key=api_key)
        logger.info("FRED API initialized")
    return _fred

def get_yfinance():
    global _yf
    if _yf is None:
        import yfinance as yf
        _yf = yf
        logger.info("yfinance initialized")
    return _yf


class MacroAnalyzer:
    """
    Analyzes macroeconomic factors from FRED.
    
    Key insight from research:
    - Real Yields are the #1 driver of gold
    - 100bps change = 8-18% gold move (historically)
    - Correlation broke in 2022 due to central bank buying
    """
    
    def __init__(self):
        self._cache = {}
        self._cache_time = None
        self._cache_ttl = 300  # 5 minutes
    
    def _is_cache_valid(self) -> bool:
        if self._cache_time is None:
            return False
        return (datetime.now() - self._cache_time).total_seconds() < self._cache_ttl
    
    def get_real_yields(self) -> dict:
        """
        Calculate real yields = Nominal 10Y - Breakeven Inflation
        
        INTERPRETATION:
        - Negative real yields = VERY BULLISH for gold
        - Real yields > 2% = BEARISH for gold
        """
        try:
            fred = get_fred()
            
            # 10-Year Treasury Yield
            dgs10 = fred.get_series('DGS10').dropna().iloc[-1]
            
            # 10-Year Breakeven Inflation Rate  
            t10yie = fred.get_series('T10YIE').dropna().iloc[-1]
            
            # Real Yield
            real_yield = float(dgs10 - t10yie)
            
            # Score for gold (-10 bearish to +10 bullish)
            if real_yield < 0:
                score = 10
            elif real_yield < 0.5:
                score = 7
            elif real_yield < 1.0:
                score = 4
            elif real_yield < 1.5:
                score = 0
            elif real_yield < 2.0:
                score = -4
            elif real_yield < 2.5:
                score = -7
            else:
                score = -10
            
            return {
                'nominal_yield': float(dgs10),
                'breakeven_inflation': float(t10yie),
                'real_yield': real_yield,
                'score': score,
                'interpretation': 'BULLISH' if score > 2 else 'BEARISH' if score < -2 else 'NEUTRAL'
            }
        except Exception as e:
            logger.error(f"Error fetching real yields: {e}")
            return {'error': str(e), 'score': 0, 'real_yield': None}
    
    def get_dxy(self) -> dict:
        """
        Get Dollar Index analysis.
        
        CORRELATION: -0.70 with gold (inverse)
        When DXY rises, gold tends to fall.
        """
        try:
            fred = get_fred()
            
            # Trade Weighted Dollar Index
            dxy_series = fred.get_series('DTWEXBGS').dropna()
            current = float(dxy_series.iloc[-1])
            
            # 20-day moving average for context
            ma_20 = float(dxy_series.tail(20).mean())
            
            # Deviation from MA
            deviation = (current - ma_20) / ma_20 * 100
            
            # Score (strong DXY = bearish gold)
            if deviation > 2:
                score = -7
            elif deviation > 1:
                score = -4
            elif deviation > 0.5:
                score = -2
            elif deviation > -0.5:
                score = 0
            elif deviation > -1:
                score = 2
            elif deviation > -2:
                score = 4
            else:
                score = 7
            
            return {
                'dxy': current,
                'dxy_ma20': ma_20,
                'deviation_pct': round(deviation, 2),
                'score': score,
                'interpretation': 'BULLISH' if score > 2 else 'BEARISH' if score < -2 else 'NEUTRAL'
            }
        except Exception as e:
            logger.error(f"Error fetching DXY: {e}")
            return {'error': str(e), 'score': 0, 'dxy': None}
    
    def get_vix(self) -> dict:
        """
        Get VIX (Fear Index) analysis.
        
        CORRELATION: +0.30 with gold (positive)
        High VIX = safe haven demand = bullish gold
        """
        try:
            fred = get_fred()
            
            vix = float(fred.get_series('VIXCLS').dropna().iloc[-1])
            
            # Score based on fear level
            if vix > 35:
                score = 10
                level = 'EXTREME'
            elif vix > 30:
                score = 7
                level = 'HIGH'
            elif vix > 25:
                score = 4
                level = 'ELEVATED'
            elif vix > 20:
                score = 2
                level = 'MODERATE'
            elif vix > 15:
                score = 0
                level = 'NORMAL'
            else:
                score = -2
                level = 'LOW'
            
            return {
                'vix': vix,
                'fear_level': level,
                'score': score,
                'interpretation': 'BULLISH' if score > 2 else 'BEARISH' if score < -2 else 'NEUTRAL'
            }
        except Exception as e:
            logger.error(f"Error fetching VIX: {e}")
            return {'error': str(e), 'score': 0, 'vix': None}
    
    def get_complete_analysis(self) -> dict:
        """Get complete macro analysis with weighted score."""
        if self._is_cache_valid():
            return self._cache
        
        real_yields = self.get_real_yields()
        dxy = self.get_dxy()
        vix = self.get_vix()
        
        # Weighted score (based on research)
        weights = {
            'real_yields': 0.40,  # Primary driver
            'dxy': 0.35,          # Strong correlation
            'vix': 0.25           # Secondary factor
        }
        
        total_score = (
            real_yields.get('score', 0) * weights['real_yields'] +
            dxy.get('score', 0) * weights['dxy'] +
            vix.get('score', 0) * weights['vix']
        )
        
        result = {
            'real_yields': real_yields,
            'dxy': dxy,
            'vix': vix,
            'total_score': round(total_score, 2),
            'interpretation': 'BULLISH' if total_score > 2 else 'BEARISH' if total_score < -2 else 'NEUTRAL',
            'timestamp': datetime.now().isoformat()
        }
        
        self._cache = result
        self._cache_time = datetime.now()
        
        return result


class OilAnalyzer:
    """
    Analyzes Gold-Oil relationship.
    
    CRITICAL DISCOVERY from research:
    - USO (Crude Oil) has 42% feature importance for gold prediction!
    - This is 2x more important than any other factor
    - Gold influences Oil (Granger causality), not vice versa
    - Gold-to-Oil ratio typically ranges 6-40
    """
    
    def __init__(self):
        self._cache = {}
        self._cache_time = None
        self._cache_ttl = 300
    
    def get_oil_analysis(self) -> dict:
        """Get crude oil data and gold-oil ratio analysis."""
        try:
            yf = get_yfinance()
            
            # WTI Crude Oil
            wti = yf.Ticker('CL=F')
            wti_hist = wti.history(period='5d')
            if wti_hist.empty:
                raise ValueError("No WTI data available")
            wti_price = float(wti_hist['Close'].iloc[-1])
            
            # Gold
            gold = yf.Ticker('GC=F')
            gold_hist = gold.history(period='5d')
            if gold_hist.empty:
                raise ValueError("No Gold data available")
            gold_price = float(gold_hist['Close'].iloc[-1])
            
            # Gold-to-Oil Ratio
            ratio = gold_price / wti_price
            
            # Score based on ratio (historical range: 6-40)
            # High ratio (>30) = gold expensive vs oil
            # Low ratio (<15) = gold cheap vs oil
            if ratio > 40:
                score = -7  # Gold very expensive
            elif ratio > 35:
                score = -4
            elif ratio > 30:
                score = -2
            elif ratio > 25:
                score = 0
            elif ratio > 20:
                score = 2
            elif ratio > 15:
                score = 5
            else:
                score = 8  # Gold very cheap
            
            # Oil trend (5-day change)
            oil_change = (wti_hist['Close'].iloc[-1] - wti_hist['Close'].iloc[0]) / wti_hist['Close'].iloc[0] * 100
            gold_change = (gold_hist['Close'].iloc[-1] - gold_hist['Close'].iloc[0]) / gold_hist['Close'].iloc[0] * 100
            
            return {
                'wti_price': round(wti_price, 2),
                'gold_price': round(gold_price, 2),
                'gold_oil_ratio': round(ratio, 2),
                'oil_change_5d': round(float(oil_change), 2),
                'gold_change_5d': round(float(gold_change), 2),
                'score': score,
                'interpretation': 'BULLISH' if score > 2 else 'BEARISH' if score < -2 else 'NEUTRAL',
                'timestamp': datetime.now().isoformat()
            }
        except Exception as e:
            logger.error(f"Error fetching oil data: {e}")
            return {'error': str(e), 'score': 0}


class ETFFlowAnalyzer:
    """
    Analyzes Gold ETF flows (GLD, IAU).
    
    INSIGHT: ETF flows show institutional money movement.
    - Inflows + rising price = bullish
    - Outflows + falling price = bearish
    """
    
    def get_etf_analysis(self, period: str = '20d') -> dict:
        """Analyze GLD ETF volume patterns."""
        try:
            yf = get_yfinance()
            
            gld = yf.Ticker('GLD')
            hist = gld.history(period=period)
            
            if hist.empty:
                return {'error': 'No GLD data', 'score': 0}
            
            # Volume analysis
            avg_volume = float(hist['Volume'].mean())
            recent_volume = float(hist['Volume'].tail(5).mean())
            volume_ratio = recent_volume / avg_volume
            
            # Price change
            price_change = float((hist['Close'].iloc[-1] - hist['Close'].iloc[0]) / hist['Close'].iloc[0] * 100)
            
            # Determine flow direction
            if volume_ratio > 1.3 and price_change > 1:
                flow = 'STRONG_INFLOW'
                score = 7
            elif volume_ratio > 1.1 and price_change > 0:
                flow = 'INFLOW'
                score = 4
            elif volume_ratio > 1.1 and price_change < 0:
                flow = 'OUTFLOW'
                score = -4
            elif volume_ratio > 1.3 and price_change < -1:
                flow = 'STRONG_OUTFLOW'
                score = -7
            elif price_change > 1:
                flow = 'MILD_INFLOW'
                score = 2
            elif price_change < -1:
                flow = 'MILD_OUTFLOW'
                score = -2
            else:
                flow = 'NEUTRAL'
                score = 0
            
            return {
                'etf': 'GLD',
                'price_change_pct': round(price_change, 2),
                'volume_ratio': round(volume_ratio, 2),
                'flow': flow,
                'score': score,
                'interpretation': 'BULLISH' if score > 2 else 'BEARISH' if score < -2 else 'NEUTRAL',
                'timestamp': datetime.now().isoformat()
            }
        except Exception as e:
            logger.error(f"Error fetching ETF data: {e}")
            return {'error': str(e), 'score': 0}


class GoldFundamentalsService:
    """
    Main service that combines all fundamental analyzers.
    
    ARCHITECTURE:
    - MacroAnalyzer: FRED data (real yields, DXY, VIX)
    - OilAnalyzer: Gold-Oil relationship (42% importance!)
    - ETFFlowAnalyzer: Institutional flows
    
    WEIGHTS (based on research):
    - Macro: 45% (real yields most important)
    - Oil: 35% (discovered to be critical)
    - ETF: 20% (confirmation signal)
    """
    
    def __init__(self):
        self.macro = MacroAnalyzer()
        self.oil = OilAnalyzer()
        self.etf = ETFFlowAnalyzer()
        logger.info("GoldFundamentalsService initialized")
    
    def get_complete_analysis(self) -> dict:
        """Get complete fundamental analysis."""
        macro = self.macro.get_complete_analysis()
        oil = self.oil.get_oil_analysis()
        etf = self.etf.get_etf_analysis()
        
        # Weighted final score
        weights = {
            'macro': 0.45,
            'oil': 0.35,
            'etf': 0.20
        }
        
        total_score = (
            macro.get('total_score', 0) * weights['macro'] +
            oil.get('score', 0) * weights['oil'] +
            etf.get('score', 0) * weights['etf']
        )
        
        # Determine bias
        if total_score > 4:
            bias = 'STRONG_BULLISH'
        elif total_score > 2:
            bias = 'BULLISH'
        elif total_score > -2:
            bias = 'NEUTRAL'
        elif total_score > -4:
            bias = 'BEARISH'
        else:
            bias = 'STRONG_BEARISH'
        
        return {
            'macro': macro,
            'oil': oil,
            'etf': etf,
            'total_score': round(total_score, 2),
            'bias': bias,
            'confidence': min(abs(total_score) / 10 + 0.5, 1.0),
            'timestamp': datetime.now().isoformat()
        }
    
    def get_trading_signal(self) -> dict:
        """
        Get trading signal for MQL5 integration.
        
        Returns simplified signal for EA consumption.
        """
        analysis = self.get_complete_analysis()
        score = analysis['total_score']
        
        # Determine signal
        if score > 4:
            signal = 'STRONG_BUY'
            score_adjustment = 15
        elif score > 2:
            signal = 'BUY'
            score_adjustment = 10
        elif score > -2:
            signal = 'NEUTRAL'
            score_adjustment = 0
        elif score > -4:
            signal = 'SELL'
            score_adjustment = -10
        else:
            signal = 'STRONG_SELL'
            score_adjustment = -15
        
        # Size multiplier based on confidence
        if signal in ['STRONG_BUY', 'STRONG_SELL']:
            size_multiplier = 1.0
        elif signal in ['BUY', 'SELL']:
            size_multiplier = 0.75
        else:
            size_multiplier = 0.5
        
        return {
            'signal': signal,
            'score': round(score, 2),
            'score_adjustment': score_adjustment,
            'size_multiplier': size_multiplier,
            'bias': analysis['bias'],
            'confidence': round(analysis['confidence'], 2),
            'components': {
                'macro_score': analysis['macro'].get('total_score', 0),
                'oil_score': analysis['oil'].get('score', 0),
                'etf_score': analysis['etf'].get('score', 0)
            },
            'timestamp': datetime.now().isoformat()
        }


# Global service instance
_fundamentals_service: Optional[GoldFundamentalsService] = None

def get_fundamentals_service() -> GoldFundamentalsService:
    """Get or create the fundamentals service singleton."""
    global _fundamentals_service
    if _fundamentals_service is None:
        _fundamentals_service = GoldFundamentalsService()
    return _fundamentals_service
