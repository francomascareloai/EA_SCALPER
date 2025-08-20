#!/usr/bin/env python3
"""
Trading Classifier MCP Server
Servidor MCP customizado para acelerar classificação e análise de códigos de trading
Usando FastMCP 2.0 para máxima performance
"""

import os
import json
import re
from pathlib import Path
from typing import Dict, List, Optional, Any
from datetime import datetime

from fastmcp import FastMCP

# Inicializar servidor MCP
mcp = FastMCP("Trading Classifier MCP")

# Configurações
CODIGO_FONTE_PATH = Path("C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/CODIGO_FONTE_LIBRARY")
METADATA_PATH = Path("C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/Metadata")
REPORTS_PATH = Path("C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/Reports")

# Padrões de detecção rápida
PATTERNS = {
    "ea_indicators": [
        r"OnTick\s*\(",
        r"OrderSend\s*\(",
        r"trade\.Buy\s*\(",
        r"trade\.Sell\s*\("
    ],
    "indicator_patterns": [
        r"OnCalculate\s*\(",
        r"SetIndexBuffer\s*\(",
        r"IndicatorSetString\s*\("
    ],
    "strategy_patterns": {
        "scalping": [r"scalp", r"M1", r"M5", r"quick", r"fast"],
        "grid_martingale": [r"grid", r"martingale", r"recovery", r"double"],
        "smc_ict": [r"order.?block", r"liquidity", r"institutional", r"smc", r"ict"],
        "trend": [r"trend", r"momentum", r"MA", r"moving.?average"]
    },
    "ftmo_compliance": [
        r"risk.?management", r"stop.?loss", r"drawdown", r"lot.?size",
        r"AccountBalance", r"AccountEquity", r"risk.?percent"
    ]
}

@mcp.tool
def quick_classify_file(file_path: str) -> Dict[str, Any]:
    """
    Classificação rápida de um arquivo de trading
    
    Args:
        file_path: Caminho para o arquivo a ser classificado
        
    Returns:
        Dicionário com classificação completa
    """
    try:
        path = Path(file_path)
        if not path.exists():
            return {"error": f"Arquivo não encontrado: {file_path}"}
            
        content = path.read_text(encoding='utf-8', errors='ignore')
        
        # Classificação rápida
        classification = {
            "file_name": path.name,
            "file_path": str(path),
            "file_size": path.stat().st_size,
            "extension": path.suffix,
            "timestamp": datetime.now().isoformat(),
            "type": _detect_file_type(content),
            "strategy": _detect_strategy(content),
            "market": _detect_market(content),
            "timeframe": _detect_timeframe(content),
            "ftmo_ready": _check_ftmo_compliance(content),
            "risk_level": _assess_risk_level(content),
            "complexity_score": _calculate_complexity(content),
            "suggested_category": "",
            "tags": []
        }
        
        # Gerar categoria sugerida
        classification["suggested_category"] = _suggest_category(classification)
        
        # Gerar tags
        classification["tags"] = _generate_tags(classification)
        
        return classification
        
    except Exception as e:
        return {"error": f"Erro na classificação: {str(e)}"}

@mcp.tool
def batch_classify_directory(directory_path: str, extensions: List[str] = None) -> Dict[str, Any]:
    """
    Classificação em lote de diretório
    
    Args:
        directory_path: Caminho do diretório
        extensions: Lista de extensões a processar (ex: ['.mq4', '.mq5'])
        
    Returns:
        Resultados da classificação em lote
    """
    try:
        if extensions is None:
            extensions = ['.mq4', '.mq5', '.pine']
            
        directory = Path(directory_path)
        if not directory.exists():
            return {"error": f"Diretório não encontrado: {directory_path}"}
            
        results = {
            "directory": str(directory),
            "processed_files": [],
            "summary": {
                "total_files": 0,
                "by_type": {},
                "by_strategy": {},
                "ftmo_ready": 0,
                "high_risk": 0
            },
            "timestamp": datetime.now().isoformat()
        }
        
        # Processar arquivos
        for ext in extensions:
            for file_path in directory.rglob(f"*{ext}"):
                classification = quick_classify_file(str(file_path))
                if "error" not in classification:
                    results["processed_files"].append(classification)
                    
                    # Atualizar estatísticas
                    results["summary"]["total_files"] += 1
                    
                    file_type = classification.get("type", "unknown")
                    results["summary"]["by_type"][file_type] = results["summary"]["by_type"].get(file_type, 0) + 1
                    
                    strategy = classification.get("strategy", "unknown")
                    results["summary"]["by_strategy"][strategy] = results["summary"]["by_strategy"].get(strategy, 0) + 1
                    
                    if classification.get("ftmo_ready", False):
                        results["summary"]["ftmo_ready"] += 1
                        
                    if classification.get("risk_level") == "high":
                        results["summary"]["high_risk"] += 1
        
        return results
        
    except Exception as e:
        return {"error": f"Erro na classificação em lote: {str(e)}"}

@mcp.tool
def generate_metadata_file(classification: Dict[str, Any], output_path: str = None) -> Dict[str, str]:
    """
    Gerar arquivo de metadados baseado na classificação
    
    Args:
        classification: Resultado da classificação
        output_path: Caminho de saída (opcional)
        
    Returns:
        Status da geração
    """
    try:
        if output_path is None:
            file_name = classification.get("file_name", "unknown")
            base_name = Path(file_name).stem
            output_path = str(METADATA_PATH / f"{base_name}.meta.json")
            
        # Template de metadados
        metadata = {
            "file_info": {
                "original_name": classification.get("file_name"),
                "file_path": classification.get("file_path"),
                "file_size": classification.get("file_size"),
                "extension": classification.get("extension")
            },
            "classification": {
                "type": classification.get("type"),
                "strategy": classification.get("strategy"),
                "market": classification.get("market"),
                "timeframe": classification.get("timeframe"),
                "suggested_category": classification.get("suggested_category")
            },
            "quality_metrics": {
                "ftmo_ready": classification.get("ftmo_ready"),
                "risk_level": classification.get("risk_level"),
                "complexity_score": classification.get("complexity_score")
            },
            "tags": classification.get("tags", []),
            "metadata": {
                "created_at": datetime.now().isoformat(),
                "created_by": "Trading Classifier MCP",
                "version": "1.0"
            }
        }
        
        # Salvar arquivo
        Path(output_path).parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(metadata, f, indent=2, ensure_ascii=False)
            
        return {
            "status": "success",
            "output_path": output_path,
            "message": "Arquivo de metadados gerado com sucesso"
        }
        
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro ao gerar metadados: {str(e)}"
        }

@mcp.tool
def suggest_file_rename(classification: Dict[str, Any]) -> Dict[str, str]:
    """
    Sugerir novo nome para arquivo baseado na classificação
    
    Args:
        classification: Resultado da classificação
        
    Returns:
        Sugestão de renomeação
    """
    try:
        file_type = classification.get("type", "UNK")
        strategy = classification.get("strategy", "Generic")
        market = classification.get("market", "MULTI")
        extension = classification.get("extension", ".mq4")
        
        # Prefixos por tipo
        prefixes = {
            "ea": "EA",
            "indicator": "IND",
            "script": "SCR",
            "library": "LIB",
            "unknown": "UNK"
        }
        
        prefix = prefixes.get(file_type.lower(), "UNK")
        
        # Limpar nome da estratégia
        clean_strategy = re.sub(r'[^a-zA-Z0-9_]', '', strategy.title())
        
        # Gerar nome sugerido
        suggested_name = f"{prefix}_{clean_strategy}_v1.0_{market}{extension}"
        
        return {
            "original_name": classification.get("file_name"),
            "suggested_name": suggested_name,
            "prefix": prefix,
            "strategy": clean_strategy,
            "market": market,
            "version": "v1.0"
        }
        
    except Exception as e:
        return {
            "error": f"Erro ao sugerir renomeação: {str(e)}"
        }

@mcp.tool
def analyze_code_quality(file_path: str) -> Dict[str, Any]:
    """
    Análise rápida de qualidade do código
    
    Args:
        file_path: Caminho do arquivo
        
    Returns:
        Análise de qualidade
    """
    try:
        path = Path(file_path)
        if not path.exists():
            return {"error": f"Arquivo não encontrado: {file_path}"}
            
        content = path.read_text(encoding='utf-8', errors='ignore')
        lines = content.split('\n')
        
        analysis = {
            "file_name": path.name,
            "metrics": {
                "total_lines": len(lines),
                "code_lines": len([l for l in lines if l.strip() and not l.strip().startswith('//')]),
                "comment_lines": len([l for l in lines if l.strip().startswith('//')]),
                "empty_lines": len([l for l in lines if not l.strip()]),
                "functions_count": len(re.findall(r'\b\w+\s*\([^)]*\)\s*{', content)),
                "variables_count": len(re.findall(r'\b(int|double|string|bool|datetime)\s+\w+', content))
            },
            "quality_indicators": {
                "has_comments": '//' in content,
                "has_error_handling": 'GetLastError' in content or 'try' in content,
                "has_input_validation": 'if(' in content and ('>' in content or '<' in content),
                "has_stop_loss": any(pattern in content.lower() for pattern in ['stoploss', 'stop_loss', 'sl']),
                "has_take_profit": any(pattern in content.lower() for pattern in ['takeprofit', 'take_profit', 'tp'])
            },
            "complexity_score": _calculate_complexity(content),
            "maintainability": "high" if len(lines) < 500 and '//' in content else "medium" if len(lines) < 1000 else "low"
        }
        
        return analysis
        
    except Exception as e:
        return {"error": f"Erro na análise de qualidade: {str(e)}"}

# Funções auxiliares
def _detect_file_type(content: str) -> str:
    """Detectar tipo do arquivo"""
    content_lower = content.lower()
    
    if any(re.search(pattern, content, re.IGNORECASE) for pattern in PATTERNS["ea_indicators"]):
        return "ea"
    elif any(re.search(pattern, content, re.IGNORECASE) for pattern in PATTERNS["indicator_patterns"]):
        return "indicator"
    elif "onstart()" in content_lower:
        return "script"
    elif "#property library" in content_lower:
        return "library"
    else:
        return "unknown"

def _detect_strategy(content: str) -> str:
    """Detectar estratégia"""
    content_lower = content.lower()
    
    for strategy, patterns in PATTERNS["strategy_patterns"].items():
        if any(re.search(pattern, content_lower) for pattern in patterns):
            return strategy
    
    return "unknown"

def _detect_market(content: str) -> str:
    """Detectar mercado"""
    markets = {
        "XAUUSD": ["xauusd", "gold", "ouro"],
        "EURUSD": ["eurusd", "eur"],
        "GBPUSD": ["gbpusd", "gbp"],
        "USDJPY": ["usdjpy", "jpy"],
        "Forex": ["forex", "fx", "currency"],
        "Indices": ["index", "indices", "spx", "nas", "dax"],
        "Crypto": ["crypto", "bitcoin", "btc", "eth"]
    }
    
    content_lower = content.lower()
    for market, patterns in markets.items():
        if any(pattern in content_lower for pattern in patterns):
            return market
            
    return "MULTI"

def _detect_timeframe(content: str) -> str:
    """Detectar timeframe"""
    timeframes = {
        "M1": ["period_m1", "1min", "m1"],
        "M5": ["period_m5", "5min", "m5"],
        "M15": ["period_m15", "15min", "m15"],
        "H1": ["period_h1", "1hour", "h1"],
        "H4": ["period_h4", "4hour", "h4"],
        "D1": ["period_d1", "daily", "d1"]
    }
    
    content_lower = content.lower()
    for tf, patterns in timeframes.items():
        if any(pattern in content_lower for pattern in patterns):
            return tf
            
    return "MULTI"

def _check_ftmo_compliance(content: str) -> bool:
    """Verificar conformidade FTMO"""
    content_lower = content.lower()
    
    # Verificar presença de elementos FTMO
    ftmo_elements = 0
    for pattern in PATTERNS["ftmo_compliance"]:
        if re.search(pattern, content_lower):
            ftmo_elements += 1
            
    # Verificar ausência de elementos proibidos
    prohibited = ["martingale", "grid", "hedge"]
    has_prohibited = any(term in content_lower for term in prohibited)
    
    return ftmo_elements >= 2 and not has_prohibited

def _assess_risk_level(content: str) -> str:
    """Avaliar nível de risco"""
    content_lower = content.lower()
    
    high_risk_indicators = ["martingale", "grid", "no stop", "unlimited"]
    medium_risk_indicators = ["scalping", "high frequency", "news"]
    low_risk_indicators = ["stop loss", "risk management", "conservative"]
    
    if any(indicator in content_lower for indicator in high_risk_indicators):
        return "high"
    elif any(indicator in content_lower for indicator in low_risk_indicators):
        return "low"
    else:
        return "medium"

def _calculate_complexity(content: str) -> float:
    """Calcular score de complexidade"""
    lines = len(content.split('\n'))
    functions = len(re.findall(r'\b\w+\s*\([^)]*\)\s*{', content))
    conditions = len(re.findall(r'\bif\s*\(', content))
    loops = len(re.findall(r'\b(for|while)\s*\(', content))
    
    # Score baseado em métricas
    complexity = (lines / 100) + (functions / 10) + (conditions / 5) + (loops / 3)
    return min(complexity, 10.0)  # Máximo 10

def _suggest_category(classification: Dict[str, Any]) -> str:
    """Sugerir categoria baseada na classificação"""
    file_type = classification.get("type", "unknown")
    strategy = classification.get("strategy", "unknown")
    extension = classification.get("extension", ".mq4")
    
    # Mapear para estrutura de pastas
    if extension == ".mq4":
        base_path = "MQL4_Source"
    elif extension == ".mq5":
        base_path = "MQL5_Source"
    else:
        base_path = "Unknown"
        
    if file_type == "ea":
        if strategy == "scalping":
            return f"{base_path}/EAs/Scalping"
        elif strategy == "grid_martingale":
            return f"{base_path}/EAs/Grid_Martingale"
        elif strategy == "trend":
            return f"{base_path}/EAs/Trend_Following"
        else:
            return f"{base_path}/EAs/Misc"
    elif file_type == "indicator":
        if strategy == "smc_ict":
            return f"{base_path}/Indicators/SMC_ICT"
        elif "volume" in strategy:
            return f"{base_path}/Indicators/Volume"
        else:
            return f"{base_path}/Indicators/Custom"
    else:
        return f"{base_path}/Misc"

def _generate_tags(classification: Dict[str, Any]) -> List[str]:
    """Gerar tags baseadas na classificação"""
    tags = []
    
    # Tags de tipo
    file_type = classification.get("type", "")
    if file_type:
        tags.append(f"#{file_type.upper()}")
        
    # Tags de estratégia
    strategy = classification.get("strategy", "")
    if strategy and strategy != "unknown":
        tags.append(f"#{strategy.title()}")
        
    # Tags de mercado
    market = classification.get("market", "")
    if market and market != "MULTI":
        tags.append(f"#{market}")
        
    # Tags de timeframe
    timeframe = classification.get("timeframe", "")
    if timeframe and timeframe != "MULTI":
        tags.append(f"#{timeframe}")
        
    # Tags de qualidade
    if classification.get("ftmo_ready", False):
        tags.append("#FTMO_Ready")
        
    risk_level = classification.get("risk_level", "")
    if risk_level == "low":
        tags.append("#LowRisk")
    elif risk_level == "high":
        tags.append("#HighRisk")
        
    return tags

if __name__ == "__main__":
    # Executar servidor MCP
    mcp.run()