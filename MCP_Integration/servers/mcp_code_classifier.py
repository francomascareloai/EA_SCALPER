#!/usr/bin/env python3
"""
MCP Code Classifier Server
Classifica códigos de trading baseado nas regras do projeto
"""

import json
import sys
import os
import re

def classify_code(file_path):
    """
    Classifica código de trading baseado no conteúdo
    """
    try:
        if not os.path.exists(file_path):
            return {"success": False, "error": "File not found"}
        
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read().lower()
        
        # Detectar tipo de arquivo
        file_type = detect_file_type(content, file_path)
        
        # Detectar estratégia
        strategy = detect_strategy(content)
        
        # Detectar mercado e timeframe
        market = detect_market(content)
        timeframe = detect_timeframe(content)
        
        # Gerar nome sugerido
        suggested_name = generate_suggested_name(file_type, strategy, market, timeframe, file_path)
        
        # Determinar pasta destino
        target_folder = determine_target_folder(file_type, strategy)
        
        # Gerar tags
        tags = generate_tags(file_type, strategy, market, timeframe, content)
        
        return {
            "success": True,
            "classification": {
                "file_type": file_type,
                "strategy": strategy,
                "market": market,
                "timeframe": timeframe,
                "suggested_name": suggested_name,
                "target_folder": target_folder,
                "tags": tags
            }
        }
        
    except Exception as e:
        return {"success": False, "error": str(e)}

def detect_file_type(content, file_path):
    """Detecta o tipo do arquivo"""
    ext = os.path.splitext(file_path)[1].lower()
    
    if ext == '.mq4':
        if 'ontick' in content and ('ordersend' in content or 'buy' in content or 'sell' in content):
            return 'EA'
        elif 'oncalculate' in content or 'setindexbuffer' in content:
            return 'Indicator'
        elif 'onstart' in content:
            return 'Script'
        else:
            return 'MQL4_Unknown'
    
    elif ext == '.mq5':
        if 'ontick' in content and ('trade.buy' in content or 'trade.sell' in content or 'ordersend' in content):
            return 'EA'
        elif 'oncalculate' in content or 'plotindexsetinteger' in content:
            return 'Indicator'
        elif 'onstart' in content:
            return 'Script'
        else:
            return 'MQL5_Unknown'
    
    elif ext == '.pine':
        if 'strategy(' in content:
            return 'Pine_Strategy'
        elif 'study(' in content or 'indicator(' in content:
            return 'Pine_Indicator'
        else:
            return 'Pine_Unknown'
    
    return 'Unknown'

def detect_strategy(content):
    """Detecta a estratégia baseada em keywords"""
    strategies = {
        'Scalping': ['scalp', 'm1', 'm5', 'quick', 'fast', 'pips'],
        'Grid_Martingale': ['grid', 'martingale', 'recovery', 'multiply', 'lot_multiplier'],
        'SMC_ICT': ['order_block', 'orderblock', 'liquidity', 'institutional', 'smc', 'ict', 'fair_value_gap'],
        'Trend_Following': ['trend', 'momentum', 'moving_average', 'ma_', 'ema', 'sma'],
        'Volume_Analysis': ['volume', 'obv', 'flow', 'tick_volume', 'real_volume'],
        'Breakout': ['breakout', 'break_out', 'support', 'resistance', 'channel'],
        'News_Trading': ['news', 'fundamental', 'economic', 'calendar'],
        'Hedge': ['hedge', 'hedging', 'correlation', 'basket']
    }
    
    for strategy, keywords in strategies.items():
        if any(keyword in content for keyword in keywords):
            return strategy
    
    return 'Unknown'

def detect_market(content):
    """Detecta o mercado baseado em símbolos"""
    markets = {
        'XAUUSD': ['xauusd', 'gold', 'ouro'],
        'EURUSD': ['eurusd', 'eur_usd'],
        'GBPUSD': ['gbpusd', 'gbp_usd'],
        'USDJPY': ['usdjpy', 'usd_jpy'],
        'BTCUSD': ['btcusd', 'bitcoin', 'btc'],
        'US30': ['us30', 'dow', 'dji'],
        'NAS100': ['nas100', 'nasdaq', 'nq']
    }
    
    for market, symbols in markets.items():
        if any(symbol in content for symbol in symbols):
            return market
    
    return 'MULTI'

def detect_timeframe(content):
    """Detecta o timeframe baseado em indicadores"""
    timeframes = {
        'M1': ['period_m1', 'per_m1', '1 minute', 'm1'],
        'M5': ['period_m5', 'per_m5', '5 minute', 'm5'],
        'M15': ['period_m15', 'per_m15', '15 minute', 'm15'],
        'H1': ['period_h1', 'per_h1', '1 hour', 'h1'],
        'H4': ['period_h4', 'per_h4', '4 hour', 'h4'],
        'D1': ['period_d1', 'per_d1', 'daily', 'd1']
    }
    
    for tf, indicators in timeframes.items():
        if any(indicator in content for indicator in indicators):
            return tf
    
    return 'Unknown'

def generate_suggested_name(file_type, strategy, market, timeframe, original_path):
    """Gera nome sugerido baseado na classificação"""
    base_name = os.path.splitext(os.path.basename(original_path))[0]
    ext = os.path.splitext(original_path)[1]
    
    # Prefixos baseados no tipo
    prefixes = {
        'EA': 'EA_',
        'Indicator': 'IND_',
        'Script': 'SCR_',
        'Pine_Strategy': 'STR_',
        'Pine_Indicator': 'IND_'
    }
    
    prefix = prefixes.get(file_type, 'UNK_')
    
    # Limpar nome base
    clean_name = re.sub(r'[^a-zA-Z0-9_]', '', base_name)
    if not clean_name:
        clean_name = 'Unnamed'
    
    # Construir nome
    parts = [prefix + clean_name, 'v1.0']
    
    if market != 'MULTI' and market != 'Unknown':
        parts.append(market)
    
    if timeframe != 'Unknown':
        parts.append(timeframe)
    
    return '_'.join(parts) + ext

def determine_target_folder(file_type, strategy):
    """Determina a pasta destino baseada no tipo e estratégia"""
    base_paths = {
        'EA': 'CODIGO_FONTE_LIBRARY/MQL4_Source/EAs',
        'Indicator': 'CODIGO_FONTE_LIBRARY/MQL4_Source/Indicators',
        'Script': 'CODIGO_FONTE_LIBRARY/MQL4_Source/Scripts'
    }
    
    if file_type.startswith('MQL5'):
        base_paths = {
            'EA': 'CODIGO_FONTE_LIBRARY/MQL5_Source/EAs',
            'Indicator': 'CODIGO_FONTE_LIBRARY/MQL5_Source/Indicators',
            'Script': 'CODIGO_FONTE_LIBRARY/MQL5_Source/Scripts'
        }
    elif file_type.startswith('Pine'):
        base_paths = {
            'Pine_Strategy': 'CODIGO_FONTE_LIBRARY/TradingView_Scripts/Strategies',
            'Pine_Indicator': 'CODIGO_FONTE_LIBRARY/TradingView_Scripts/Indicators'
        }
    
    base_path = base_paths.get(file_type, 'CODIGO_FONTE_LIBRARY/Misc')
    
    # Subpastas por estratégia
    strategy_folders = {
        'Scalping': 'Scalping',
        'Grid_Martingale': 'Grid_Martingale',
        'SMC_ICT': 'SMC_ICT',
        'Trend_Following': 'Trend',
        'Volume_Analysis': 'Volume',
        'Breakout': 'Breakout'
    }
    
    if strategy in strategy_folders:
        return f"{base_path}/{strategy_folders[strategy]}"
    else:
        return f"{base_path}/Misc"

def generate_tags(file_type, strategy, market, timeframe, content):
    """Gera tags baseadas na classificação"""
    tags = []
    
    # Tag de tipo
    if file_type in ['EA', 'Indicator', 'Script']:
        tags.append(f"#{file_type}")
    elif file_type.startswith('Pine'):
        tags.append("#Pine")
    
    # Tag de estratégia
    if strategy != 'Unknown':
        tags.append(f"#{strategy}")
    
    # Tag de mercado
    if market != 'MULTI' and market != 'Unknown':
        tags.append(f"#{market}")
    
    # Tag de timeframe
    if timeframe != 'Unknown':
        tags.append(f"#{timeframe}")
    
    # Tags especiais baseadas no conteúdo
    if any(word in content for word in ['ai', 'neural', 'machine_learning', 'ml']):
        tags.append("#AI")
    
    if any(word in content for word in ['backtest', 'optimization', 'genetic']):
        tags.append("#Backtest")
    
    return tags

def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "Usage: python mcp_code_classifier.py <file_path>"}), flush=True)
        return
    
    file_path = sys.argv[1]
    result = classify_code(file_path)
    print(json.dumps(result, indent=2), flush=True)

if __name__ == "__main__":
    main()