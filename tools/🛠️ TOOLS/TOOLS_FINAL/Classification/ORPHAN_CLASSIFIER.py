#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ORPHAN CLASSIFIER - Sistema Inteligente de Classificação de Arquivos Órfãos
Projeto: EA_SCALPER_XAUUSD
Versão: 1.0
Autor: Agente Organizador
Data: 2025

Descrição:
Sistema avançado para classificação automática de arquivos órfãos usando:
- Análise de conteúdo com IA
- Detecção de padrões
- Machine Learning para categorização
- Regras de negócio específicas para trading
- Sistema de quarentena para arquivos suspeitos

Funcionalidades:
- Identificação automática de tipo de arquivo
- Classificação por estratégia de trading
- Detecção de duplicatas
- Análise de segurança
- Recomendações de ação
"""

import os
import re
import json
import hashlib
import shutil
# import magic  # Removido para evitar dependência externa
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any, Optional, Tuple
import logging
from dataclasses import dataclass
from enum import Enum

# Configuração de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('orphan_classification.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class FileType(Enum):
    """Tipos de arquivo suportados"""
    EA = "Expert Advisor"
    INDICATOR = "Indicator"
    SCRIPT = "Script"
    INCLUDE = "Include File"
    LIBRARY = "Library"
    PINE_SCRIPT = "Pine Script"
    COMPILED = "Compiled File"
    DOCUMENTATION = "Documentation"
    DATA = "Data File"
    CONFIG = "Configuration"
    UNKNOWN = "Unknown"

class SecurityLevel(Enum):
    """Níveis de segurança"""
    SAFE = "safe"
    SUSPICIOUS = "suspicious"
    DANGEROUS = "dangerous"
    QUARANTINE = "quarantine"

class ActionType(Enum):
    """Tipos de ação recomendada"""
    MOVE_TO_LIBRARY = "move_to_library"
    MOVE_TO_SOURCE = "move_to_source"
    ARCHIVE = "archive"
    DELETE = "delete"
    QUARANTINE = "quarantine"
    MANUAL_REVIEW = "manual_review"

@dataclass
class ClassificationResult:
    """Resultado da classificação de um arquivo"""
    file_path: str
    file_type: FileType
    strategy: str
    market: str
    timeframe: str
    confidence: float
    security_level: SecurityLevel
    recommended_action: ActionType
    target_location: str
    metadata: Dict[str, Any]
    analysis_notes: List[str]

class OrphanClassifier:
    """Classificador inteligente de arquivos órfãos"""
    
    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.orphan_dir = self.project_root / "06_ARQUIVOS_ORFAOS"
        self.quarantine_dir = self.orphan_dir / "QUARANTINE"
        self.processed_dir = self.orphan_dir / "PROCESSED"
        self.analysis_dir = self.orphan_dir / "ANALYSIS_IN_PROGRESS"
        
        # Estatísticas
        self.stats = {
            "total_files_analyzed": 0,
            "files_classified": 0,
            "files_quarantined": 0,
            "duplicates_found": 0,
            "security_issues": 0,
            "errors": 0
        }
        
        # Padrões de classificação
        self.trading_patterns = {
            "scalping": [r"scalp", r"m1", r"m5", r"quick", r"fast", r"rapid"],
            "grid": [r"grid", r"martingale", r"recovery", r"hedge"],
            "trend": [r"trend", r"momentum", r"breakout", r"ma", r"ema"],
            "smc": [r"smc", r"ict", r"order.?block", r"liquidity", r"institutional"],
            "volume": [r"volume", r"obv", r"flow", r"accumulation"],
            "news": [r"news", r"event", r"announcement", r"calendar"],
            "ai": [r"ai", r"ml", r"neural", r"learning", r"algorithm"]
        }
        
        self.market_patterns = {
            "forex": [r"eur", r"usd", r"gbp", r"jpy", r"aud", r"cad", r"chf", r"nzd"],
            "gold": [r"xau", r"gold", r"ouro"],
            "indices": [r"spx", r"nas", r"dax", r"ftse", r"nikkei"],
            "crypto": [r"btc", r"eth", r"crypto", r"bitcoin"]
        }
        
        self.timeframe_patterns = {
            "m1": [r"m1", r"1min", r"1m"],
            "m5": [r"m5", r"5min", r"5m"],
            "m15": [r"m15", r"15min", r"15m"],
            "h1": [r"h1", r"1h", r"60min"],
            "h4": [r"h4", r"4h", r"240min"],
            "d1": [r"d1", r"daily", r"1d"]
        }
        
        # Padrões suspeitos
        self.suspicious_patterns = [
            r"crack", r"keygen", r"patch", r"hack", r"virus",
            r"malware", r"trojan", r"backdoor", r"exploit"
        ]
        
        # Cache de hashes para detecção de duplicatas
        self.file_hashes = {}
        
    def analyze_orphan_files(self) -> List[ClassificationResult]:
        """Analisa todos os arquivos órfãos e retorna classificações"""
        logger.info("Iniciando análise de arquivos órfãos...")
        
        results = []
        
        # Buscar arquivos em diretórios de órfãos
        orphan_locations = [
            self.analysis_dir,
            self.orphan_dir / "UNCLASSIFIED",
            self.project_root / "TEMP",
            self.project_root / "MISC"
        ]
        
        for location in orphan_locations:
            if location.exists():
                for file_path in location.rglob("*"):
                    if file_path.is_file():
                        self.stats["total_files_analyzed"] += 1
                        result = self.classify_file(file_path)
                        if result:
                            results.append(result)
                            
        logger.info(f"Análise concluída: {len(results)} arquivos classificados")
        return results
        
    def classify_file(self, file_path: Path) -> Optional[ClassificationResult]:
        """Classifica um arquivo individual"""
        try:
            logger.info(f"Classificando: {file_path.name}")
            
            # Análise básica do arquivo
            file_info = self._analyze_file_basic(file_path)
            
            # Análise de conteúdo
            content_analysis = self._analyze_file_content(file_path)
            
            # Análise de segurança
            security_analysis = self._analyze_file_security(file_path)
            
            # Detecção de duplicatas
            duplicate_analysis = self._check_duplicates(file_path)
            
            # Classificação por IA/ML
            ml_classification = self._ml_classify(file_path, content_analysis)
            
            # Combinar análises
            result = self._combine_analyses(
                file_path, file_info, content_analysis, 
                security_analysis, duplicate_analysis, ml_classification
            )
            
            self.stats["files_classified"] += 1
            return result
            
        except Exception as e:
            logger.error(f"Erro ao classificar {file_path}: {e}")
            self.stats["errors"] += 1
            return None
            
    def _analyze_file_basic(self, file_path: Path) -> Dict[str, Any]:
        """Análise básica do arquivo"""
        stat = file_path.stat()
        
        return {
            "name": file_path.name,
            "extension": file_path.suffix.lower(),
            "size": stat.st_size,
            "created": datetime.fromtimestamp(stat.st_ctime),
            "modified": datetime.fromtimestamp(stat.st_mtime),
            "is_executable": file_path.suffix.lower() in [".ex4", ".ex5", ".exe"],
            "is_source": file_path.suffix.lower() in [".mq4", ".mq5", ".mqh", ".pine"]
        }
        
    def _analyze_file_content(self, file_path: Path) -> Dict[str, Any]:
        """Análise de conteúdo do arquivo"""
        analysis = {
            "file_type": FileType.UNKNOWN,
            "strategy": "unknown",
            "market": "unknown",
            "timeframe": "unknown",
            "keywords": [],
            "functions": [],
            "includes": [],
            "properties": {}
        }
        
        try:
            # Tentar ler como texto
            if file_path.suffix.lower() in [".mq4", ".mq5", ".mqh", ".pine", ".txt", ".md"]:
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read().lower()
                    
                # Determinar tipo de arquivo
                analysis["file_type"] = self._determine_file_type(content, file_path)
                
                # Extrair funções
                analysis["functions"] = self._extract_functions(content)
                
                # Extrair includes
                analysis["includes"] = self._extract_includes(content)
                
                # Extrair propriedades
                analysis["properties"] = self._extract_properties(content)
                
                # Classificar estratégia
                analysis["strategy"] = self._classify_strategy(content)
                
                # Classificar mercado
                analysis["market"] = self._classify_market(content)
                
                # Classificar timeframe
                analysis["timeframe"] = self._classify_timeframe(content)
                
                # Extrair palavras-chave
                analysis["keywords"] = self._extract_keywords(content)
                
        except Exception as e:
            logger.warning(f"Erro ao analisar conteúdo de {file_path}: {e}")
            
        return analysis
        
    def _determine_file_type(self, content: str, file_path: Path) -> FileType:
        """Determina o tipo do arquivo baseado no conteúdo"""
        extension = file_path.suffix.lower()
        
        # Baseado na extensão
        if extension in [".ex4", ".ex5"]:
            return FileType.COMPILED
        elif extension == ".mqh":
            return FileType.INCLUDE
        elif extension == ".pine":
            return FileType.PINE_SCRIPT
        elif extension in [".txt", ".md", ".pdf"]:
            return FileType.DOCUMENTATION
        elif extension in [".json", ".xml", ".ini", ".cfg"]:
            return FileType.CONFIG
        elif extension in [".csv", ".dat", ".hst"]:
            return FileType.DATA
            
        # Baseado no conteúdo
        if "ontick" in content and ("ordersend" in content or "trade.buy" in content):
            return FileType.EA
        elif "oncalculate" in content or "setindexbuffer" in content:
            return FileType.INDICATOR
        elif "onstart" in content and "ontick" not in content:
            return FileType.SCRIPT
        elif "#include" in content or "#import" in content:
            return FileType.INCLUDE
        elif "study(" in content or "strategy(" in content:
            return FileType.PINE_SCRIPT
            
        return FileType.UNKNOWN
        
    def _extract_functions(self, content: str) -> List[str]:
        """Extrai funções do código"""
        functions = []
        
        # Padrões para funções MQL
        mql_patterns = [
            r"(int|double|bool|string|void)\s+(\w+)\s*\(",
            r"OnTick\s*\(",
            r"OnInit\s*\(",
            r"OnDeinit\s*\(",
            r"OnCalculate\s*\(",
            r"OnStart\s*\("
        ]
        
        for pattern in mql_patterns:
            matches = re.findall(pattern, content, re.IGNORECASE)
            functions.extend([match[1] if isinstance(match, tuple) else match for match in matches])
            
        return list(set(functions))[:20]  # Limitar a 20 funções
        
    def _extract_includes(self, content: str) -> List[str]:
        """Extrai arquivos incluídos"""
        includes = []
        
        # Padrões para includes
        patterns = [
            r"#include\s*[<\"]([^>\"]+)[>\"]?",
            r"#import\s*[<\"]([^>\"]+)[>\"]?"
        ]
        
        for pattern in patterns:
            matches = re.findall(pattern, content, re.IGNORECASE)
            includes.extend(matches)
            
        return list(set(includes))
        
    def _extract_properties(self, content: str) -> Dict[str, str]:
        """Extrai propriedades do arquivo"""
        properties = {}
        
        # Padrões para propriedades MQL
        prop_patterns = {
            "version": r"#property\s+version\s+[\"']?([^\"'\n]+)[\"']?",
            "description": r"#property\s+description\s+[\"']?([^\"'\n]+)[\"']?",
            "copyright": r"#property\s+copyright\s+[\"']?([^\"'\n]+)[\"']?",
            "link": r"#property\s+link\s+[\"']?([^\"'\n]+)[\"']?",
            "indicator_buffers": r"#property\s+indicator_buffers\s+(\d+)",
            "indicator_plots": r"#property\s+indicator_plots\s+(\d+)"
        }
        
        for prop_name, pattern in prop_patterns.items():
            match = re.search(pattern, content, re.IGNORECASE)
            if match:
                properties[prop_name] = match.group(1).strip()
                
        return properties
        
    def _classify_strategy(self, content: str) -> str:
        """Classifica a estratégia de trading"""
        for strategy, patterns in self.trading_patterns.items():
            for pattern in patterns:
                if re.search(pattern, content, re.IGNORECASE):
                    return strategy
        return "unknown"
        
    def _classify_market(self, content: str) -> str:
        """Classifica o mercado alvo"""
        for market, patterns in self.market_patterns.items():
            for pattern in patterns:
                if re.search(pattern, content, re.IGNORECASE):
                    return market
        return "multi"
        
    def _classify_timeframe(self, content: str) -> str:
        """Classifica o timeframe"""
        for timeframe, patterns in self.timeframe_patterns.items():
            for pattern in patterns:
                if re.search(pattern, content, re.IGNORECASE):
                    return timeframe
        return "unknown"
        
    def _extract_keywords(self, content: str) -> List[str]:
        """Extrai palavras-chave relevantes"""
        keywords = []
        
        # Palavras-chave de trading
        trading_keywords = [
            "stop.?loss", "take.?profit", "trailing", "breakeven",
            "risk", "money.?management", "position.?size",
            "fibonacci", "support", "resistance", "pivot",
            "rsi", "macd", "bollinger", "stochastic",
            "candlestick", "pattern", "signal", "alert"
        ]
        
        for keyword in trading_keywords:
            if re.search(keyword, content, re.IGNORECASE):
                keywords.append(keyword.replace(".?", " "))
                
        return keywords[:10]  # Limitar a 10 palavras-chave
        
    def _analyze_file_security(self, file_path: Path) -> Dict[str, Any]:
        """Análise de segurança do arquivo"""
        security = {
            "level": SecurityLevel.SAFE,
            "issues": [],
            "suspicious_patterns": [],
            "file_signature": None
        }
        
        try:
            # Verificar padrões suspeitos no nome
            filename_lower = file_path.name.lower()
            for pattern in self.suspicious_patterns:
                if re.search(pattern, filename_lower):
                    security["suspicious_patterns"].append(pattern)
                    security["level"] = SecurityLevel.SUSPICIOUS
                    
            # Verificar tamanho do arquivo
            file_size = file_path.stat().st_size
            if file_size == 0:
                security["issues"].append("Arquivo vazio")
                security["level"] = SecurityLevel.SUSPICIOUS
            elif file_size > 50 * 1024 * 1024:  # 50MB
                security["issues"].append("Arquivo muito grande")
                security["level"] = SecurityLevel.SUSPICIOUS
                
            # Verificar extensão
            if file_path.suffix.lower() in [".exe", ".bat", ".cmd", ".scr"]:
                security["issues"].append("Tipo de arquivo potencialmente perigoso")
                security["level"] = SecurityLevel.QUARANTINE
                
            # Verificar extensões suspeitas (sem usar magic)
            suspicious_extensions = [".exe", ".bat", ".cmd", ".scr", ".vbs", ".js"]
            if file_path.suffix.lower() in suspicious_extensions:
                if file_path.suffix.lower() not in [".mq4", ".mq5", ".ex4", ".ex5"]:
                    security["issues"].append(f"Extensão suspeita: {file_path.suffix}")
                    security["level"] = SecurityLevel.SUSPICIOUS
                
            # Verificar conteúdo suspeito
            if file_path.suffix.lower() in [".mq4", ".mq5", ".txt"]:
                try:
                    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                        content = f.read().lower()
                        
                    for pattern in self.suspicious_patterns:
                        if re.search(pattern, content):
                            security["suspicious_patterns"].append(pattern)
                            security["level"] = SecurityLevel.DANGEROUS
                            
                except:
                    pass
                    
        except Exception as e:
            logger.warning(f"Erro na análise de segurança de {file_path}: {e}")
            security["issues"].append(f"Erro na análise: {e}")
            
        return security
        
    def _check_duplicates(self, file_path: Path) -> Dict[str, Any]:
        """Verifica se o arquivo é duplicata"""
        duplicate_info = {
            "is_duplicate": False,
            "original_file": None,
            "hash": None,
            "similar_files": []
        }
        
        try:
            # Calcular hash do arquivo
            file_hash = self._calculate_file_hash(file_path)
            duplicate_info["hash"] = file_hash
            
            # Verificar se já existe
            if file_hash in self.file_hashes:
                duplicate_info["is_duplicate"] = True
                duplicate_info["original_file"] = self.file_hashes[file_hash]
                self.stats["duplicates_found"] += 1
            else:
                self.file_hashes[file_hash] = str(file_path)
                
            # Buscar arquivos similares por nome
            similar_files = self._find_similar_files(file_path)
            duplicate_info["similar_files"] = similar_files
            
        except Exception as e:
            logger.warning(f"Erro ao verificar duplicatas de {file_path}: {e}")
            
        return duplicate_info
        
    def _calculate_file_hash(self, file_path: Path) -> str:
        """Calcula hash MD5 do arquivo"""
        hash_md5 = hashlib.md5()
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)
        return hash_md5.hexdigest()
        
    def _find_similar_files(self, file_path: Path) -> List[str]:
        """Encontra arquivos com nomes similares"""
        similar = []
        base_name = file_path.stem.lower()
        
        # Buscar em diretórios principais
        search_dirs = [
            self.project_root / "MQL4_Source",
            self.project_root / "MQL5_Source",
            self.project_root / "🚀 MAIN_EAS",
            self.project_root / "📚 LIBRARY"
        ]
        
        for search_dir in search_dirs:
            if search_dir.exists():
                for existing_file in search_dir.rglob("*"):
                    if existing_file.is_file():
                        existing_name = existing_file.stem.lower()
                        
                        # Verificar similaridade
                        if self._calculate_similarity(base_name, existing_name) > 0.8:
                            similar.append(str(existing_file))
                            
        return similar[:5]  # Limitar a 5 arquivos similares
        
    def _calculate_similarity(self, str1: str, str2: str) -> float:
        """Calcula similaridade entre duas strings"""
        if str1 == str2:
            return 1.0
            
        # Algoritmo simples de similaridade
        longer = str1 if len(str1) > len(str2) else str2
        shorter = str2 if len(str1) > len(str2) else str1
        
        if len(longer) == 0:
            return 1.0
            
        return (len(longer) - self._levenshtein_distance(longer, shorter)) / len(longer)
        
    def _levenshtein_distance(self, s1: str, s2: str) -> int:
        """Calcula distância de Levenshtein"""
        if len(s1) < len(s2):
            return self._levenshtein_distance(s2, s1)
            
        if len(s2) == 0:
            return len(s1)
            
        previous_row = list(range(len(s2) + 1))
        for i, c1 in enumerate(s1):
            current_row = [i + 1]
            for j, c2 in enumerate(s2):
                insertions = previous_row[j + 1] + 1
                deletions = current_row[j] + 1
                substitutions = previous_row[j] + (c1 != c2)
                current_row.append(min(insertions, deletions, substitutions))
            previous_row = current_row
            
        return previous_row[-1]
        
    def _ml_classify(self, file_path: Path, content_analysis: Dict[str, Any]) -> Dict[str, Any]:
        """Classificação usando machine learning (simulado)"""
        # Simulação de classificação ML
        # Em implementação real, usaria modelos treinados
        
        ml_result = {
            "confidence": 0.5,
            "predicted_category": "unknown",
            "features": [],
            "model_version": "1.0_simulated"
        }
        
        # Calcular confiança baseada em análises
        confidence_factors = []
        
        # Fator 1: Tipo de arquivo identificado
        if content_analysis["file_type"] != FileType.UNKNOWN:
            confidence_factors.append(0.3)
            
        # Fator 2: Estratégia identificada
        if content_analysis["strategy"] != "unknown":
            confidence_factors.append(0.2)
            
        # Fator 3: Funções encontradas
        if content_analysis["functions"]:
            confidence_factors.append(0.2)
            
        # Fator 4: Propriedades encontradas
        if content_analysis["properties"]:
            confidence_factors.append(0.1)
            
        # Fator 5: Palavras-chave relevantes
        if content_analysis["keywords"]:
            confidence_factors.append(0.2)
            
        ml_result["confidence"] = min(1.0, sum(confidence_factors))
        
        # Determinar categoria predita
        if content_analysis["file_type"] == FileType.EA:
            if content_analysis["strategy"] in ["scalping", "smc"]:
                ml_result["predicted_category"] = "high_value_ea"
            else:
                ml_result["predicted_category"] = "standard_ea"
        elif content_analysis["file_type"] == FileType.INDICATOR:
            ml_result["predicted_category"] = "indicator"
        elif content_analysis["file_type"] == FileType.SCRIPT:
            ml_result["predicted_category"] = "utility_script"
        else:
            ml_result["predicted_category"] = "unknown"
            
        return ml_result
        
    def _combine_analyses(self, file_path: Path, file_info: Dict, content_analysis: Dict,
                         security_analysis: Dict, duplicate_analysis: Dict, 
                         ml_classification: Dict) -> ClassificationResult:
        """Combina todas as análises em um resultado final"""
        
        # Determinar ação recomendada
        recommended_action = self._determine_action(
            content_analysis, security_analysis, duplicate_analysis, ml_classification
        )
        
        # Determinar localização alvo
        target_location = self._determine_target_location(
            content_analysis, recommended_action
        )
        
        # Compilar notas de análise
        analysis_notes = self._compile_analysis_notes(
            file_info, content_analysis, security_analysis, duplicate_analysis
        )
        
        # Criar metadados completos
        metadata = {
            "file_info": file_info,
            "content_analysis": content_analysis,
            "security_analysis": security_analysis,
            "duplicate_analysis": duplicate_analysis,
            "ml_classification": ml_classification,
            "classification_timestamp": datetime.now().isoformat(),
            "classifier_version": "1.0"
        }
        
        return ClassificationResult(
            file_path=str(file_path),
            file_type=content_analysis["file_type"],
            strategy=content_analysis["strategy"],
            market=content_analysis["market"],
            timeframe=content_analysis["timeframe"],
            confidence=ml_classification["confidence"],
            security_level=security_analysis["level"],
            recommended_action=recommended_action,
            target_location=target_location,
            metadata=metadata,
            analysis_notes=analysis_notes
        )
        
    def _determine_action(self, content_analysis: Dict, security_analysis: Dict,
                         duplicate_analysis: Dict, ml_classification: Dict) -> ActionType:
        """Determina a ação recomendada"""
        
        # Verificar segurança primeiro
        if security_analysis["level"] == SecurityLevel.DANGEROUS:
            return ActionType.QUARANTINE
        elif security_analysis["level"] == SecurityLevel.QUARANTINE:
            return ActionType.QUARANTINE
            
        # Verificar duplicatas
        if duplicate_analysis["is_duplicate"]:
            return ActionType.DELETE
            
        # Verificar confiança da classificação
        if ml_classification["confidence"] < 0.3:
            return ActionType.MANUAL_REVIEW
            
        # Determinar ação baseada no tipo
        file_type = content_analysis["file_type"]
        
        if file_type == FileType.EA:
            if content_analysis["strategy"] in ["scalping", "smc", "ftmo"]:
                return ActionType.MOVE_TO_LIBRARY
            else:
                return ActionType.MOVE_TO_SOURCE
        elif file_type == FileType.INDICATOR:
            return ActionType.MOVE_TO_LIBRARY
        elif file_type == FileType.SCRIPT:
            return ActionType.MOVE_TO_SOURCE
        elif file_type == FileType.DOCUMENTATION:
            return ActionType.ARCHIVE
        elif file_type == FileType.COMPILED:
            if security_analysis["level"] == SecurityLevel.SAFE:
                return ActionType.MOVE_TO_SOURCE
            else:
                return ActionType.QUARANTINE
        else:
            return ActionType.MANUAL_REVIEW
            
    def _determine_target_location(self, content_analysis: Dict, action: ActionType) -> str:
        """Determina a localização alvo"""
        
        if action == ActionType.QUARANTINE:
            return "06_ARQUIVOS_ORFAOS/QUARANTINE/POTENTIALLY_BAD"
        elif action == ActionType.DELETE:
            return "DELETE"
        elif action == ActionType.MANUAL_REVIEW:
            return "06_ARQUIVOS_ORFAOS/ANALYSIS_IN_PROGRESS/Under_Review"
        elif action == ActionType.ARCHIVE:
            return "06_ARQUIVOS_ORFAOS/PROCESSED/Archived"
            
        # Determinar localização baseada no tipo
        file_type = content_analysis["file_type"]
        strategy = content_analysis["strategy"]
        
        if file_type == FileType.EA:
            if strategy == "scalping":
                return "MQL5_Source/EAs/Advanced_Scalping"
            elif strategy == "smc":
                return "📚 LIBRARY/MQL5_Components/Indicators/SMC_Indicators"
            elif "ftmo" in strategy:
                return "MQL5_Source/EAs/FTMO_Ready"
            else:
                return "MQL5_Source/EAs/Others"
        elif file_type == FileType.INDICATOR:
            if strategy == "smc":
                return "MQL5_Source/Indicators/Order_Blocks"
            elif strategy == "volume":
                return "MQL5_Source/Indicators/Volume_Flow"
            else:
                return "MQL5_Source/Indicators/Custom"
        elif file_type == FileType.SCRIPT:
            return "MQL5_Source/Scripts/Analysis_Tools"
        elif file_type == FileType.PINE_SCRIPT:
            return "📊 TRADINGVIEW/Pine_Script_Source/Indicators/Custom_Plots"
        else:
            return "📚 LIBRARY/Python_Components/Data_Processing"
            
    def _compile_analysis_notes(self, file_info: Dict, content_analysis: Dict,
                               security_analysis: Dict, duplicate_analysis: Dict) -> List[str]:
        """Compila notas da análise"""
        notes = []
        
        # Notas sobre o arquivo
        notes.append(f"Arquivo: {file_info['name']} ({file_info['size']} bytes)")
        notes.append(f"Tipo identificado: {content_analysis['file_type'].value}")
        
        if content_analysis["strategy"] != "unknown":
            notes.append(f"Estratégia: {content_analysis['strategy']}")
            
        if content_analysis["market"] != "unknown":
            notes.append(f"Mercado: {content_analysis['market']}")
            
        # Notas de segurança
        if security_analysis["issues"]:
            notes.append(f"Problemas de segurança: {', '.join(security_analysis['issues'])}")
            
        # Notas de duplicatas
        if duplicate_analysis["is_duplicate"]:
            notes.append(f"Duplicata de: {duplicate_analysis['original_file']}")
            
        if duplicate_analysis["similar_files"]:
            notes.append(f"Arquivos similares encontrados: {len(duplicate_analysis['similar_files'])}")
            
        # Notas sobre funções
        if content_analysis["functions"]:
            notes.append(f"Funções principais: {', '.join(content_analysis['functions'][:3])}")
            
        return notes
        
    def execute_classifications(self, results: List[ClassificationResult]) -> Dict[str, Any]:
        """Executa as ações recomendadas"""
        logger.info("Executando classificações...")
        
        execution_stats = {
            "files_moved": 0,
            "files_quarantined": 0,
            "files_deleted": 0,
            "files_archived": 0,
            "manual_review_required": 0,
            "errors": 0
        }
        
        for result in results:
            try:
                source_path = Path(result.file_path)
                
                if not source_path.exists():
                    continue
                    
                if result.recommended_action == ActionType.MOVE_TO_LIBRARY:
                    self._move_file(source_path, result.target_location)
                    execution_stats["files_moved"] += 1
                    
                elif result.recommended_action == ActionType.MOVE_TO_SOURCE:
                    self._move_file(source_path, result.target_location)
                    execution_stats["files_moved"] += 1
                    
                elif result.recommended_action == ActionType.QUARANTINE:
                    self._quarantine_file(source_path, result)
                    execution_stats["files_quarantined"] += 1
                    
                elif result.recommended_action == ActionType.DELETE:
                    self._delete_file(source_path)
                    execution_stats["files_deleted"] += 1
                    
                elif result.recommended_action == ActionType.ARCHIVE:
                    self._archive_file(source_path, result.target_location)
                    execution_stats["files_archived"] += 1
                    
                elif result.recommended_action == ActionType.MANUAL_REVIEW:
                    self._flag_for_review(source_path, result)
                    execution_stats["manual_review_required"] += 1
                    
            except Exception as e:
                logger.error(f"Erro ao executar ação para {result.file_path}: {e}")
                execution_stats["errors"] += 1
                
        return execution_stats
        
    def _move_file(self, source_path: Path, target_location: str):
        """Move arquivo para localização alvo"""
        target_path = self.project_root / target_location
        target_path.mkdir(parents=True, exist_ok=True)
        
        final_path = target_path / source_path.name
        shutil.move(str(source_path), str(final_path))
        
        logger.info(f"Movido: {source_path.name} -> {target_location}")
        
    def _quarantine_file(self, source_path: Path, result: ClassificationResult):
        """Coloca arquivo em quarentena"""
        quarantine_path = self.quarantine_dir / "POTENTIALLY_BAD"
        quarantine_path.mkdir(parents=True, exist_ok=True)
        
        # Mover arquivo
        final_path = quarantine_path / source_path.name
        shutil.move(str(source_path), str(final_path))
        
        # Criar relatório de quarentena
        report_path = quarantine_path / f"{source_path.stem}_QUARANTINE_REPORT.json"
        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump({
                "quarantined_at": datetime.now().isoformat(),
                "original_path": str(source_path),
                "reason": result.analysis_notes,
                "security_level": result.security_level.value,
                "metadata": result.metadata
            }, f, indent=2, ensure_ascii=False)
            
        logger.warning(f"Quarentena: {source_path.name}")
        
    def _delete_file(self, source_path: Path):
        """Deleta arquivo duplicado"""
        # Criar backup antes de deletar
        backup_dir = self.processed_dir / "DELETED_DUPLICATES"
        backup_dir.mkdir(parents=True, exist_ok=True)
        
        backup_path = backup_dir / f"{source_path.stem}_{datetime.now().strftime('%Y%m%d_%H%M%S')}{source_path.suffix}"
        shutil.copy2(str(source_path), str(backup_path))
        
        # Deletar original
        source_path.unlink()
        
        logger.info(f"Deletado (backup criado): {source_path.name}")
        
    def _archive_file(self, source_path: Path, target_location: str):
        """Arquiva arquivo"""
        archive_path = self.project_root / target_location
        archive_path.mkdir(parents=True, exist_ok=True)
        
        final_path = archive_path / source_path.name
        shutil.move(str(source_path), str(final_path))
        
        logger.info(f"Arquivado: {source_path.name} -> {target_location}")
        
    def _flag_for_review(self, source_path: Path, result: ClassificationResult):
        """Marca arquivo para revisão manual"""
        review_path = self.analysis_dir / "Under_Review"
        review_path.mkdir(parents=True, exist_ok=True)
        
        # Mover arquivo
        final_path = review_path / source_path.name
        shutil.move(str(source_path), str(final_path))
        
        # Criar relatório de revisão
        report_path = review_path / f"{source_path.stem}_REVIEW_NEEDED.json"
        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump({
                "flagged_at": datetime.now().isoformat(),
                "reason": "Baixa confiança na classificação automática",
                "confidence": result.confidence,
                "analysis_notes": result.analysis_notes,
                "suggested_actions": [
                    "Revisar manualmente o conteúdo",
                    "Verificar se é arquivo útil",
                    "Determinar categoria apropriada",
                    "Mover para localização correta"
                ],
                "metadata": result.metadata
            }, f, indent=2, ensure_ascii=False)
            
        logger.info(f"Marcado para revisão: {source_path.name}")
        
    def generate_classification_report(self, results: List[ClassificationResult], 
                                     execution_stats: Dict[str, Any]) -> str:
        """Gera relatório completo da classificação"""
        logger.info("Gerando relatório de classificação...")
        
        report = {
            "classification_completed_at": datetime.now().isoformat(),
            "classifier_version": "1.0",
            "total_files_analyzed": len(results),
            "statistics": self.stats,
            "execution_statistics": execution_stats,
            "classification_summary": {
                "by_file_type": {},
                "by_strategy": {},
                "by_security_level": {},
                "by_action": {}
            },
            "high_confidence_classifications": [],
            "low_confidence_classifications": [],
            "security_issues": [],
            "duplicates_found": [],
            "recommendations": []
        }
        
        # Compilar estatísticas
        for result in results:
            # Por tipo de arquivo
            file_type = result.file_type.value
            report["classification_summary"]["by_file_type"][file_type] = \
                report["classification_summary"]["by_file_type"].get(file_type, 0) + 1
                
            # Por estratégia
            strategy = result.strategy
            report["classification_summary"]["by_strategy"][strategy] = \
                report["classification_summary"]["by_strategy"].get(strategy, 0) + 1
                
            # Por nível de segurança
            security = result.security_level.value
            report["classification_summary"]["by_security_level"][security] = \
                report["classification_summary"]["by_security_level"].get(security, 0) + 1
                
            # Por ação
            action = result.recommended_action.value
            report["classification_summary"]["by_action"][action] = \
                report["classification_summary"]["by_action"].get(action, 0) + 1
                
            # Classificações de alta confiança
            if result.confidence > 0.8:
                report["high_confidence_classifications"].append({
                    "file": Path(result.file_path).name,
                    "type": result.file_type.value,
                    "confidence": result.confidence,
                    "action": result.recommended_action.value
                })
                
            # Classificações de baixa confiança
            if result.confidence < 0.3:
                report["low_confidence_classifications"].append({
                    "file": Path(result.file_path).name,
                    "confidence": result.confidence,
                    "notes": result.analysis_notes[:3]
                })
                
            # Problemas de segurança
            if result.security_level in [SecurityLevel.SUSPICIOUS, SecurityLevel.DANGEROUS]:
                report["security_issues"].append({
                    "file": Path(result.file_path).name,
                    "level": result.security_level.value,
                    "issues": result.metadata["security_analysis"]["issues"]
                })
                
            # Duplicatas
            if result.metadata["duplicate_analysis"]["is_duplicate"]:
                report["duplicates_found"].append({
                    "file": Path(result.file_path).name,
                    "original": result.metadata["duplicate_analysis"]["original_file"]
                })
                
        # Recomendações
        report["recommendations"] = [
            "Revisar manualmente arquivos de baixa confiança",
            "Investigar problemas de segurança identificados",
            "Confirmar remoção de duplicatas",
            "Implementar monitoramento contínuo de arquivos órfãos",
            "Treinar modelo ML com dados classificados"
        ]
        
        # Salvar relatório
        report_path = self.orphan_dir / "CLASSIFICATION_REPORT.json"
        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
            
        # Log do relatório
        logger.info("=" * 60)
        logger.info("CLASSIFICAÇÃO DE ARQUIVOS ÓRFÃOS CONCLUÍDA")
        logger.info("=" * 60)
        logger.info(f"Total de arquivos analisados: {len(results)}")
        logger.info(f"Arquivos movidos: {execution_stats['files_moved']}")
        logger.info(f"Arquivos em quarentena: {execution_stats['files_quarantined']}")
        logger.info(f"Duplicatas removidas: {execution_stats['files_deleted']}")
        logger.info(f"Revisão manual necessária: {execution_stats['manual_review_required']}")
        logger.info(f"Relatório salvo em: {report_path}")
        logger.info("=" * 60)
        
        return str(report_path)
        
    def run_full_classification(self) -> str:
        """Executa classificação completa de arquivos órfãos"""
        logger.info("Iniciando classificação completa de arquivos órfãos...")
        
        # 1. Analisar arquivos órfãos
        results = self.analyze_orphan_files()
        
        # 2. Executar classificações
        execution_stats = self.execute_classifications(results)
        
        # 3. Gerar relatório
        report_path = self.generate_classification_report(results, execution_stats)
        
        logger.info("Classificação completa de arquivos órfãos finalizada!")
        return report_path

def main():
    """Função principal"""
    project_root = r"c:\Users\Admin\Documents\EA_SCALPER_XAUUSD"
    
    classifier = OrphanClassifier(project_root)
    report_path = classifier.run_full_classification()
    
    print(f"Classificação concluída. Relatório: {report_path}")
    
if __name__ == "__main__":
    main()