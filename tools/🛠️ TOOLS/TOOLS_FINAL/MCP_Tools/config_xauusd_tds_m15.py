#!/usr/bin/env python3
"""
🔧 XAUUSD_TDS M15 Configuration for Autonomous EA
Configuração específica para Symbol=XAUUSD_TDS, Period=M15
"""

import asyncio
import MetaTrader5 as mt5
from datetime import datetime, timedelta
from typing import Dict, Any, List

class XAUUSD_TDS_M15_Config:
    """Configuration class for XAUUSD_TDS M15 timeframe trading"""
    
    def __init__(self):
        self.symbol = "XAUUSD_TDS"
        self.fallback_symbol = "XAUUSD"
        self.primary_timeframe = mt5.TIMEFRAME_M15
        self.timeframes = {
            "M1": mt5.TIMEFRAME_M1,
            "M5": mt5.TIMEFRAME_M5,
            "M15": mt5.TIMEFRAME_M15,  # Primary timeframe
            "H1": mt5.TIMEFRAME_H1,
            "H4": mt5.TIMEFRAME_H4
        }
        
    async def validate_symbol(self) -> str:
        """Validate and return the correct symbol to use"""
        # Try XAUUSD_TDS first
        symbol_info = mt5.symbol_info(self.symbol)
        if symbol_info is not None:
            print(f"✅ Using primary symbol: {self.symbol}")
            return self.symbol
        
        # Fallback to standard XAUUSD
        symbol_info = mt5.symbol_info(self.fallback_symbol)
        if symbol_info is not None:
            print(f"⚠️ Primary symbol not found, using fallback: {self.fallback_symbol}")
            return self.fallback_symbol
        
        raise ValueError("❌ Neither XAUUSD_TDS nor XAUUSD symbols are available")
    
    async def setup_symbol_for_trading(self) -> Dict[str, Any]:
        """Setup the symbol for trading and return its specifications"""
        symbol = await self.validate_symbol()
        
        # Add symbol to Market Watch
        if not mt5.symbol_select(symbol, True):
            raise ValueError(f"❌ Failed to add {symbol} to Market Watch")
        
        # Get symbol information
        symbol_info = mt5.symbol_info(symbol)
        if symbol_info is None:
            raise ValueError(f"❌ Failed to get symbol info for {symbol}")
        
        specs = {
            "symbol": symbol,
            "description": f"{symbol} - Gold vs US Dollar",
            "digits": symbol_info.digits,
            "point": symbol_info.point,
            "spread": symbol_info.spread,
            "min_lot": symbol_info.volume_min,
            "max_lot": symbol_info.volume_max,
            "lot_step": symbol_info.volume_step,
            "contract_size": getattr(symbol_info, 'contract_size', 100),
            "tick_size": getattr(symbol_info, 'tick_size', 0.01),
            "tick_value": getattr(symbol_info, 'tick_value', 1.0),
            "primary_timeframe": "M15",
            "timeframes_available": list(self.timeframes.keys())
        }
        
        print(f"📊 {symbol} configured for M15 trading:")
        print(f"   📈 Spread: {specs['spread']} points")
        print(f"   📏 Min/Max Lot: {specs['min_lot']}/{specs['max_lot']}")
        print(f"   🎯 Primary Timeframe: M15")
        print(f"   🔢 Digits: {specs['digits']}")
        
        return specs
    
    async def get_multi_timeframe_data(self, bars_count: int = 1000) -> Dict[str, Any]:
        """Get multi-timeframe data for XAUUSD_TDS with M15 as primary"""
        symbol = await self.validate_symbol()
        
        data = {}
        
        print(f"📊 Fetching multi-timeframe data for {symbol}...")
        
        for tf_name, tf_constant in self.timeframes.items():
            try:
                rates = mt5.copy_rates_from_pos(symbol, tf_constant, 0, bars_count)
                if rates is not None and len(rates) > 0:
                    data[tf_name] = {
                        "timeframe": tf_name,
                        "bars_count": len(rates),
                        "rates": rates,
                        "is_primary": tf_name == "M15",
                        "last_update": datetime.fromtimestamp(rates[-1]['time']).isoformat()
                    }
                    print(f"   ✅ {tf_name}: {len(rates)} bars loaded")
                else:
                    print(f"   ❌ {tf_name}: No data available")
                    data[tf_name] = None
            except Exception as e:
                print(f"   ❌ {tf_name}: Error - {e}")
                data[tf_name] = None
        
        return data
    
    async def analyze_m15_patterns(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Analyze M15 patterns with multi-timeframe confluence"""
        
        if not data.get('M15') or data['M15'] is None:
            return {"error": "M15 data not available"}
        
        m15_rates = data['M15']['rates']
        
        # Basic M15 analysis
        analysis = {
            "timeframe": "M15",
            "symbol": await self.validate_symbol(),
            "bars_analyzed": len(m15_rates),
            "price_analysis": {
                "current_price": m15_rates[-1]['close'],
                "high_20": max([bar['high'] for bar in m15_rates[-20:]]),
                "low_20": min([bar['low'] for bar in m15_rates[-20:]]),
                "sma_20": sum([bar['close'] for bar in m15_rates[-20:]]) / 20
            },
            "multi_timeframe_confluence": {}
        }\n        \n        # Multi-timeframe confluence analysis (following project specification)\n        for tf_name in [\"H4\", \"H1\", \"M15\", \"M5\", \"M1\"]:\n            if data.get(tf_name) and data[tf_name] is not None:\n                tf_rates = data[tf_name]['rates']\n                if len(tf_rates) >= 10:\n                    # Simple trend analysis\n                    recent_close = tf_rates[-1]['close']\n                    sma_10 = sum([bar['close'] for bar in tf_rates[-10:]]) / 10\n                    \n                    trend = \"BULLISH\" if recent_close > sma_10 else \"BEARISH\"\n                    \n                    analysis[\"multi_timeframe_confluence\"][tf_name] = {\n                        \"trend\": trend,\n                        \"current_price\": recent_close,\n                        \"sma_10\": sma_10,\n                        \"strength\": abs(recent_close - sma_10) / sma_10 * 100\n                    }\n        \n        # Confluence score\n        bullish_tfs = [tf for tf, data in analysis[\"multi_timeframe_confluence\"].items() \n                      if data[\"trend\"] == \"BULLISH\"]\n        bearish_tfs = [tf for tf, data in analysis[\"multi_timeframe_confluence\"].items() \n                      if data[\"trend\"] == \"BEARISH\"]\n        \n        analysis[\"confluence_analysis\"] = {\n            \"bullish_timeframes\": bullish_tfs,\n            \"bearish_timeframes\": bearish_tfs,\n            \"confluence_score\": len(bullish_tfs) - len(bearish_tfs),\n            \"signal_strength\": \"STRONG\" if abs(len(bullish_tfs) - len(bearish_tfs)) >= 3 else \"WEAK\"\n        }\n        \n        return analysis\n    \n    def get_m15_trading_parameters(self) -> Dict[str, Any]:\n        \"\"\"Get M15-specific trading parameters\"\"\"\n        return {\n            \"timeframe\": \"M15\",\n            \"bars_for_analysis\": 100,  # Look back 100 M15 bars (25 hours)\n            \"stop_loss_pips\": 20,      # 20 pips SL for M15\n            \"take_profit_pips\": 40,    # 40 pips TP for M15 (1:2 RR)\n            \"max_spread\": 30,          # Max 30 pips spread\n            \"risk_per_trade\": 0.5,     # 0.5% risk per trade\n            \"max_positions\": 3,        # Max 3 simultaneous M15 positions\n            \"trading_hours\": {\n                \"start\": \"01:05\",\n                \"end\": \"23:50\",\n                \"timezone\": \"Broker\"\n            },\n            \"confluence_requirements\": {\n                \"min_timeframes_aligned\": 3,\n                \"required_timeframes\": [\"H4\", \"H1\", \"M15\"],\n                \"primary_timeframe\": \"M15\"\n            }\n        }\n\nasync def test_xauusd_tds_m15_setup():\n    \"\"\"Test the XAUUSD_TDS M15 configuration\"\"\"\n    \n    print(\"🧪 Testing XAUUSD_TDS M15 Configuration\")\n    print(\"=\" * 50)\n    \n    config = XAUUSD_TDS_M15_Config()\n    \n    try:\n        # Initialize MT5\n        if not mt5.initialize():\n            print(\"❌ Failed to initialize MT5\")\n            return False\n        \n        # Setup symbol\n        print(\"\\n📊 Setting up symbol...\")\n        symbol_specs = await config.setup_symbol_for_trading()\n        \n        # Get multi-timeframe data\n        print(\"\\n📈 Fetching multi-timeframe data...\")\n        mtf_data = await config.get_multi_timeframe_data(bars_count=200)\n        \n        # Analyze M15 patterns\n        print(\"\\n🔍 Analyzing M15 patterns...\")\n        analysis = await config.analyze_m15_patterns(mtf_data)\n        \n        # Print results\n        print(\"\\n\" + \"=\" * 50)\n        print(\"📋 M15 Analysis Results:\")\n        print(f\"Symbol: {analysis.get('symbol', 'N/A')}\")\n        print(f\"Current Price: {analysis['price_analysis']['current_price']}\")\n        print(f\"20-bar High/Low: {analysis['price_analysis']['high_20']:.2f} / {analysis['price_analysis']['low_20']:.2f}\")\n        \n        print(\"\\n🎯 Multi-Timeframe Confluence:\")\n        confluence = analysis.get('confluence_analysis', {})\n        print(f\"Bullish TFs: {confluence.get('bullish_timeframes', [])}\")\n        print(f\"Bearish TFs: {confluence.get('bearish_timeframes', [])}\")\n        print(f\"Confluence Score: {confluence.get('confluence_score', 0)}\")\n        print(f\"Signal Strength: {confluence.get('signal_strength', 'UNKNOWN')}\")\n        \n        # Get trading parameters\n        params = config.get_m15_trading_parameters()\n        print(\"\\n⚙️ M15 Trading Parameters:\")\n        print(f\"Stop Loss: {params['stop_loss_pips']} pips\")\n        print(f\"Take Profit: {params['take_profit_pips']} pips\")\n        print(f\"Risk per Trade: {params['risk_per_trade']}%\")\n        print(f\"Max Positions: {params['max_positions']}\")\n        \n        mt5.shutdown()\n        \n        print(\"\\n✅ XAUUSD_TDS M15 configuration test completed successfully!\")\n        return True\n        \n    except Exception as e:\n        print(f\"\\n❌ Test failed: {e}\")\n        mt5.shutdown()\n        return False\n\nasync def main():\n    \"\"\"Main test function\"\"\"\n    \n    print(\"🤖 XAUUSD_TDS M15 Configuration Test\")\n    print(\"Symbol=XAUUSD_TDS\")\n    print(\"Period=M15\")\n    print(\"=\" * 60)\n    \n    success = await test_xauusd_tds_m15_setup()\n    \n    if success:\n        print(\"\\n🚀 Ready for M15 autonomous EA development!\")\n        print(\"✅ Symbol: XAUUSD_TDS (with XAUUSD fallback)\")\n        print(\"✅ Primary Timeframe: M15\")\n        print(\"✅ Multi-timeframe analysis configured\")\n        print(\"✅ Trading parameters optimized for M15\")\n    else:\n        print(\"\\n❌ Configuration test failed\")\n        print(\"🔧 Check MT5 connection and symbol availability\")\n\nif __name__ == \"__main__\":\n    asyncio.run(main())