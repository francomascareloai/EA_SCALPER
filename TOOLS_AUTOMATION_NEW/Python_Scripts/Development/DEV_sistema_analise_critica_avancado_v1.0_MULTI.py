#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Sistema Multi-Agente de Análise Crítica Avançado
Classificador_Trading - Elite AI para Trading Code Organization

Este sistema implementa múltiplos agentes especializados que trabalham em conjunto
para garantir máxima qualidade e precisão nos metadados de códigos de trading.
"""

import os
import re
import json
import time
import shutil
import logging
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple, Optional, Any
from dataclasses import dataclass, asdict
from concurrent.futures import ThreadPoolExecutor, as_completed
import threading

# Configuração de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('sistema_analise_critica.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

@dataclass
class MetadataQuality:
    """Estrutura para avaliar qualidade dos metadados"""
    completeness: float  # 0-10
    accuracy: float     # 0-10
    consistency: float  # 0-10
    ftmo_compliance: float  # 0-10
    overall_score: float    # 0-10
    issues: List[str]
    recommendations: List[str]

@dataclass
class AgentScore:
    """Score individual de cada agente"""
    agent_name: str
    score: float
    confidence: float
    details: Dict[str, Any]
    issues_found: List[str]
    recommendations: List[str]

@dataclass
class FileAnalysis:
    """Análise completa de um arquivo"""
    filename: str
    file_type: str
    strategy: str
    market: str
    timeframe: str
    ftmo_score: float
    ftmo_ready: bool
    tags: List[str]
    components: List[str]
    agent_scores: List[AgentScore]
    unified_score: float
    metadata_quality: MetadataQuality
    risk_level: str
    code_metrics: Dict[str, Any]
    timestamp: str

class CriticalArchitectAgent:
    """Agente Arquiteto Crítico - Avalia estrutura e padrões de código"""
    
    def __init__(self):
        self.name = "Critical_Architect"
        self.version = "2.0"
        self.expertise = ["code_structure", "design_patterns", "modularity", "maintainability"]
        
    def analyze(self, content: str, filename: str) -> AgentScore:
        """Análise crítica da arquitetura do código"""
        try:
            details = {
                "functions_count": len(re.findall(r'\b(?:void|int|double|bool|string)\s+\w+\s*\(', content)),
                "classes_count": len(re.findall(r'\bclass\s+\w+', content)),
                "lines_count": len(content.split('\n')),
                "complexity_score": self._calculate_complexity(content),
                "modularity_score": self._evaluate_modularity(content),
                "maintainability_score": self._evaluate_maintainability(content),
                "code_quality_score": self._evaluate_code_quality(content)
            }
            
            issues = []
            recommendations = []
            
            # Análise crítica de complexidade
            if details["complexity_score"] > 15:
                issues.append("Complexidade ciclomática muito alta")
                recommendations.append("Refatorar código para reduzir complexidade")
            
            # Análise de modularidade
            if details["modularity_score"] < 5:
                issues.append("Baixa modularidade do código")
                recommendations.append("Implementar programação orientada a objetos")
            
            # Análise de manutenibilidade
            if details["maintainability_score"] < 6:
                issues.append("Código difícil de manter")
                recommendations.append("Adicionar comentários e documentação")
            
            # Score final baseado em múltiplos fatores
            score = (
                details["modularity_score"] * 0.3 +
                details["maintainability_score"] * 0.3 +
                details["code_quality_score"] * 0.4
            )
            
            confidence = 0.95 if len(issues) == 0 else 0.85
            
            return AgentScore(
                agent_name=self.name,
                score=score,
                confidence=confidence,
                details=details,
                issues_found=issues,
                recommendations=recommendations
            )
            
        except Exception as e:
            logger.error(f"Erro no {self.name}: {e}")
            return AgentScore(self.name, 0.0, 0.0, {}, [f"Erro na análise: {e}"], [])
    
    def _calculate_complexity(self, content: str) -> float:
        """Calcula complexidade ciclomática"""
        complexity_keywords = ['if', 'else', 'while', 'for', 'switch', 'case', '&&', '||']
        complexity = 1  # Base complexity
        for keyword in complexity_keywords:
            complexity += len(re.findall(rf'\b{keyword}\b', content, re.IGNORECASE))
        return min(complexity, 30)  # Cap at 30
    
    def _evaluate_modularity(self, content: str) -> float:
        """Avalia modularidade do código"""
        functions = len(re.findall(r'\b(?:void|int|double|bool|string)\s+\w+\s*\(', content))
        classes = len(re.findall(r'\bclass\s+\w+', content))
        lines = len(content.split('\n'))
        
        if lines == 0:
            return 0
        
        # Mais funções e classes = melhor modularidade
        modularity = (functions * 2 + classes * 3) / (lines / 100)
        return min(modularity, 10)
    
    def _evaluate_maintainability(self, content: str) -> float:
        """Avalia manutenibilidade do código"""
        comments = len(re.findall(r'//.*|/\*.*?\*/', content, re.DOTALL))
        lines = len(content.split('\n'))
        
        if lines == 0:
            return 0
        
        # Proporção de comentários
        comment_ratio = comments / lines * 100
        
        # Nomes de variáveis descritivos
        descriptive_vars = len(re.findall(r'\b[a-zA-Z_][a-zA-Z0-9_]{3,}\b', content))
        
        maintainability = (comment_ratio * 0.4 + min(descriptive_vars / lines * 100, 10) * 0.6)
        return min(maintainability, 10)
    
    def _evaluate_code_quality(self, content: str) -> float:
        """Avalia qualidade geral do código"""
        quality_score = 10
        
        # Penalidades por más práticas
        if len(re.findall(r'\bgoto\b', content, re.IGNORECASE)) > 0:
            quality_score -= 2
        
        # Muitas variáveis globais
        global_vars = len(re.findall(r'^\s*(?:extern\s+)?(?:static\s+)?(?:int|double|bool|string)\s+\w+', content, re.MULTILINE))
        if global_vars > 10:
            quality_score -= 1
        
        # Funções muito longas
        long_functions = len(re.findall(r'\{[^}]{500,}\}', content, re.DOTALL))
        if long_functions > 0:
            quality_score -= 1
        
        return max(quality_score, 0)

class EliteFTMOAgent:
    """Agente FTMO Elite - Especialista em conformidade FTMO"""
    
    def __init__(self):
        self.name = "Elite_FTMO"
        self.version = "2.0"
        self.expertise = ["risk_management", "ftmo_rules", "drawdown_control", "position_sizing"]
        
    def analyze(self, content: str, filename: str) -> AgentScore:
        """Análise crítica de conformidade FTMO"""
        try:
            details = {
                "stop_loss_mandatory": self._check_stop_loss(content),
                "risk_management": self._evaluate_risk_management(content),
                "drawdown_protection": self._check_drawdown_protection(content),
                "position_sizing": self._evaluate_position_sizing(content),
                "forbidden_strategies": self._check_forbidden_strategies(content),
                "news_filter": self._check_news_filter(content),
                "session_filter": self._check_session_filter(content),
                "max_risk_per_trade": self._calculate_max_risk(content)
            }
            
            issues = []
            recommendations = []
            
            # Verificações críticas FTMO
            if not details["stop_loss_mandatory"]:
                issues.append("Stop Loss obrigatório ausente")
                recommendations.append("Implementar Stop Loss obrigatório para conformidade FTMO")
            
            if details["risk_management"] < 7:
                issues.append("Gestão de risco inadequada")
                recommendations.append("Melhorar sistema de gestão de risco")
            
            if details["forbidden_strategies"]:
                issues.append("Estratégias proibidas detectadas (Martingale/Grid)")
                recommendations.append("Remover estratégias Martingale/Grid para conformidade FTMO")
            
            if not details["news_filter"]:
                issues.append("Filtro de notícias ausente")
                recommendations.append("Implementar filtro de notícias")
            
            # Cálculo do score FTMO
            ftmo_score = self._calculate_ftmo_score(details)
            
            confidence = 0.98 if ftmo_score > 8 else 0.85
            
            return AgentScore(
                agent_name=self.name,
                score=ftmo_score,
                confidence=confidence,
                details=details,
                issues_found=issues,
                recommendations=recommendations
            )
            
        except Exception as e:
            logger.error(f"Erro no {self.name}: {e}")
            return AgentScore(self.name, 0.0, 0.0, {}, [f"Erro na análise: {e}"], [])
    
    def _check_stop_loss(self, content: str) -> bool:
        """Verifica presença de Stop Loss obrigatório"""
        sl_patterns = [
            r'StopLoss',
            r'SL\s*=',
            r'OrderModify.*StopLoss',
            r'trade\.SetDeviationInPoints.*sl',
            r'\bsl\b.*=.*\d+'
        ]
        return any(re.search(pattern, content, re.IGNORECASE) for pattern in sl_patterns)
    
    def _evaluate_risk_management(self, content: str) -> float:
        """Avalia sistema de gestão de risco"""
        risk_score = 0
        
        # Verificações de risco
        if re.search(r'AccountBalance|AccountEquity', content, re.IGNORECASE):
            risk_score += 2
        
        if re.search(r'risk.*percent|percent.*risk', content, re.IGNORECASE):
            risk_score += 2
        
        if re.search(r'MaxDrawdown|DrawdownLimit', content, re.IGNORECASE):
            risk_score += 2
        
        if re.search(r'LotSize.*calculation|CalculateLotSize', content, re.IGNORECASE):
            risk_score += 2
        
        if re.search(r'MaxLoss|MaxProfit', content, re.IGNORECASE):
            risk_score += 2
        
        return min(risk_score, 10)
    
    def _check_drawdown_protection(self, content: str) -> bool:
        """Verifica proteção contra drawdown"""
        drawdown_patterns = [
            r'MaxDrawdown',
            r'DrawdownLimit',
            r'DailyLoss',
            r'AccountEquity.*<.*AccountBalance'
        ]
        return any(re.search(pattern, content, re.IGNORECASE) for pattern in drawdown_patterns)
    
    def _evaluate_position_sizing(self, content: str) -> float:
        """Avalia sistema de dimensionamento de posições"""
        sizing_score = 0
        
        if re.search(r'LotSize.*=.*AccountBalance', content, re.IGNORECASE):
            sizing_score += 3
        
        if re.search(r'risk.*percent', content, re.IGNORECASE):
            sizing_score += 3
        
        if re.search(r'CalculateLotSize|LotCalculation', content, re.IGNORECASE):
            sizing_score += 4
        
        return min(sizing_score, 10)
    
    def _check_forbidden_strategies(self, content: str) -> bool:
        """Verifica estratégias proibidas"""
        forbidden_patterns = [
            r'martingale',
            r'grid.*trading',
            r'recovery.*factor',
            r'multiply.*lot',
            r'double.*position'
        ]
        return any(re.search(pattern, content, re.IGNORECASE) for pattern in forbidden_patterns)
    
    def _check_news_filter(self, content: str) -> bool:
        """Verifica filtro de notícias"""
        news_patterns = [
            r'news.*filter',
            r'economic.*calendar',
            r'high.*impact',
            r'avoid.*news'
        ]
        return any(re.search(pattern, content, re.IGNORECASE) for pattern in news_patterns)
    
    def _check_session_filter(self, content: str) -> bool:
        """Verifica filtro de sessão"""
        session_patterns = [
            r'trading.*hours',
            r'session.*filter',
            r'TimeHour|TimeMinute',
            r'market.*open'
        ]
        return any(re.search(pattern, content, re.IGNORECASE) for pattern in session_patterns)
    
    def _calculate_max_risk(self, content: str) -> float:
        """Calcula risco máximo por trade"""
        risk_matches = re.findall(r'risk.*=.*([0-9.]+)', content, re.IGNORECASE)
        if risk_matches:
            try:
                return float(risk_matches[0])
            except:
                pass
        return 2.0  # Default conservative
    
    def _calculate_ftmo_score(self, details: Dict) -> float:
        """Calcula score FTMO baseado em todos os fatores"""
        score = 10
        
        # Penalidades críticas
        if not details["stop_loss_mandatory"]:
            score -= 4
        
        if details["forbidden_strategies"]:
            score -= 3
        
        if details["risk_management"] < 5:
            score -= 2
        
        if not details["drawdown_protection"]:
            score -= 1
        
        # Bônus por boas práticas
        if details["news_filter"]:
            score += 0.5
        
        if details["session_filter"]:
            score += 0.5
        
        return max(score, 0)

class PrecisionCodeAnalyst:
    """Analista de Código de Precisão - Avalia qualidade técnica detalhada"""
    
    def __init__(self):
        self.name = "Precision_Code_Analyst"
        self.version = "2.0"
        self.expertise = ["code_quality", "performance", "security", "best_practices"]
        
    def analyze(self, content: str, filename: str) -> AgentScore:
        """Análise de precisão da qualidade do código"""
        try:
            details = {
                "syntax_quality": self._evaluate_syntax_quality(content),
                "performance_score": self._evaluate_performance(content),
                "security_score": self._evaluate_security(content),
                "error_handling": self._evaluate_error_handling(content),
                "documentation_score": self._evaluate_documentation(content),
                "best_practices_score": self._evaluate_best_practices(content),
                "code_smells": self._detect_code_smells(content)
            }
            
            issues = []
            recommendations = []
            
            # Análise crítica de qualidade
            if details["syntax_quality"] < 7:
                issues.append("Qualidade de sintaxe baixa")
                recommendations.append("Melhorar estrutura e formatação do código")
            
            if details["error_handling"] < 5:
                issues.append("Tratamento de erros inadequado")
                recommendations.append("Implementar tratamento de erros robusto")
            
            if details["security_score"] < 6:
                issues.append("Problemas de segurança detectados")
                recommendations.append("Revisar e corrigir vulnerabilidades de segurança")
            
            if len(details["code_smells"]) > 3:
                issues.append("Múltiplos code smells detectados")
                recommendations.append("Refatorar código para eliminar code smells")
            
            # Score final
            score = (
                details["syntax_quality"] * 0.2 +
                details["performance_score"] * 0.2 +
                details["security_score"] * 0.2 +
                details["error_handling"] * 0.2 +
                details["best_practices_score"] * 0.2
            )
            
            confidence = 0.92 if len(issues) <= 1 else 0.80
            
            return AgentScore(
                agent_name=self.name,
                score=score,
                confidence=confidence,
                details=details,
                issues_found=issues,
                recommendations=recommendations
            )
            
        except Exception as e:
            logger.error(f"Erro no {self.name}: {e}")
            return AgentScore(self.name, 0.0, 0.0, {}, [f"Erro na análise: {e}"], [])
    
    def _evaluate_syntax_quality(self, content: str) -> float:
        """Avalia qualidade da sintaxe"""
        quality = 10
        
        # Verificar indentação consistente
        lines = content.split('\n')
        inconsistent_indent = 0
        for line in lines:
            if line.strip() and not line.startswith(' ') and not line.startswith('\t'):
                if '{' in line or '}' in line:
                    continue
                inconsistent_indent += 1
        
        if inconsistent_indent > len(lines) * 0.1:
            quality -= 2
        
        # Verificar nomenclatura
        bad_names = len(re.findall(r'\b[a-z]\b|\b[A-Z]{2,}\b', content))
        if bad_names > 10:
            quality -= 1
        
        return max(quality, 0)
    
    def _evaluate_performance(self, content: str) -> float:
        """Avalia performance do código"""
        performance = 10
        
        # Loops aninhados
        nested_loops = len(re.findall(r'for.*{[^}]*for.*{', content, re.DOTALL))
        performance -= nested_loops * 0.5
        
        # Operações custosas em loops
        expensive_in_loops = len(re.findall(r'for.*{[^}]*(?:OrderSend|OrderModify|Print)', content, re.DOTALL))
        performance -= expensive_in_loops * 1
        
        return max(performance, 0)
    
    def _evaluate_security(self, content: str) -> float:
        """Avalia segurança do código"""
        security = 10
        
        # Credenciais hardcoded
        if re.search(r'password\s*=\s*["\'][^"\']+["\']', content, re.IGNORECASE):
            security -= 3
        
        # Validação de entrada
        if not re.search(r'if.*\(.*\)', content):
            security -= 1
        
        return max(security, 0)
    
    def _evaluate_error_handling(self, content: str) -> float:
        """Avalia tratamento de erros"""
        error_handling = 0
        
        # Verificar try-catch ou verificações de erro
        if re.search(r'GetLastError|ErrorDescription', content, re.IGNORECASE):
            error_handling += 3
        
        if re.search(r'if.*OrderSend.*>\s*0', content, re.IGNORECASE):
            error_handling += 2
        
        if re.search(r'Alert\(|Print\(.*error', content, re.IGNORECASE):
            error_handling += 2
        
        return min(error_handling, 10)
    
    def _evaluate_documentation(self, content: str) -> float:
        """Avalia documentação do código"""
        lines = content.split('\n')
        comment_lines = len([line for line in lines if line.strip().startswith('//') or '/*' in line])
        
        if len(lines) == 0:
            return 0
        
        doc_ratio = comment_lines / len(lines) * 100
        return min(doc_ratio * 2, 10)
    
    def _evaluate_best_practices(self, content: str) -> float:
        """Avalia aderência às melhores práticas"""
        practices = 10
        
        # Funções muito longas
        long_functions = len(re.findall(r'\{[^}]{1000,}\}', content, re.DOTALL))
        practices -= long_functions * 1
        
        # Muitas variáveis globais
        global_vars = len(re.findall(r'^\s*(?:int|double|bool|string)\s+\w+\s*;', content, re.MULTILINE))
        if global_vars > 15:
            practices -= 2
        
        return max(practices, 0)
    
    def _detect_code_smells(self, content: str) -> List[str]:
        """Detecta code smells"""
        smells = []
        
        # Função muito longa
        if len(re.findall(r'\{[^}]{800,}\}', content, re.DOTALL)) > 0:
            smells.append("Função muito longa")
        
        # Muitos parâmetros
        if len(re.findall(r'\([^)]{100,}\)', content)) > 0:
            smells.append("Muitos parâmetros")
        
        # Código duplicado
        lines = content.split('\n')
        unique_lines = set(line.strip() for line in lines if line.strip())
        if len(lines) - len(unique_lines) > len(lines) * 0.3:
            smells.append("Código duplicado")
        
        return smells

class MetadataQualityAnalyzer:
    """Analisador de Qualidade de Metadados"""
    
    def __init__(self):
        self.name = "Metadata_Quality_Analyzer"
        
    def analyze_metadata_quality(self, file_analysis: FileAnalysis) -> MetadataQuality:
        """Analisa qualidade dos metadados gerados"""
        try:
            # Completeness - quão completos estão os metadados
            completeness = self._evaluate_completeness(file_analysis)
            
            # Accuracy - quão precisos estão os metadados
            accuracy = self._evaluate_accuracy(file_analysis)
            
            # Consistency - quão consistentes estão os metadados
            consistency = self._evaluate_consistency(file_analysis)
            
            # FTMO Compliance - conformidade FTMO
            ftmo_compliance = file_analysis.ftmo_score
            
            # Overall score
            overall_score = (completeness + accuracy + consistency + ftmo_compliance) / 4
            
            # Issues e recomendações
            issues = []
            recommendations = []
            
            if completeness < 7:
                issues.append("Metadados incompletos")
                recommendations.append("Completar campos obrigatórios")
            
            if accuracy < 7:
                issues.append("Precisão dos metadados baixa")
                recommendations.append("Revisar classificação automática")
            
            if consistency < 7:
                issues.append("Inconsistências nos metadados")
                recommendations.append("Padronizar nomenclatura e tags")
            
            return MetadataQuality(
                completeness=completeness,
                accuracy=accuracy,
                consistency=consistency,
                ftmo_compliance=ftmo_compliance,
                overall_score=overall_score,
                issues=issues,
                recommendations=recommendations
            )
            
        except Exception as e:
            logger.error(f"Erro na análise de qualidade: {e}")
            return MetadataQuality(0, 0, 0, 0, 0, [f"Erro: {e}"], [])
    
    def _evaluate_completeness(self, analysis: FileAnalysis) -> float:
        """Avalia completeness dos metadados"""
        score = 0
        
        # Campos obrigatórios
        if analysis.file_type and analysis.file_type != "Unknown":
            score += 2
        if analysis.strategy and analysis.strategy != "Unknown":
            score += 2
        if analysis.market and analysis.market != "Unknown":
            score += 2
        if analysis.timeframe and analysis.timeframe != "Unknown":
            score += 2
        if analysis.tags:
            score += 1
        if analysis.components:
            score += 1
        
        return min(score, 10)
    
    def _evaluate_accuracy(self, analysis: FileAnalysis) -> float:
        """Avalia accuracy dos metadados"""
        # Baseado na confiança dos agentes
        total_confidence = sum(agent.confidence for agent in analysis.agent_scores)
        avg_confidence = total_confidence / len(analysis.agent_scores) if analysis.agent_scores else 0
        
        return avg_confidence * 10
    
    def _evaluate_consistency(self, analysis: FileAnalysis) -> float:
        """Avalia consistency dos metadados"""
        score = 10
        
        # Verificar consistência entre agentes
        scores = [agent.score for agent in analysis.agent_scores]
        if scores:
            variance = max(scores) - min(scores)
            if variance > 3:
                score -= 2
        
        # Verificar consistência de tags
        if analysis.file_type == "EA" and "#EA" not in analysis.tags:
            score -= 1
        
        return max(score, 0)

class AdvancedMultiAgentSystem:
    """Sistema Multi-Agente Avançado para Análise Crítica"""
    
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.agents = [
            CriticalArchitectAgent(),
            EliteFTMOAgent(),
            PrecisionCodeAnalyst()
        ]
        self.metadata_analyzer = MetadataQualityAnalyzer()
        self.results = []
        self.stats = {
            "total_files": 0,
            "processed_files": 0,
            "errors": 0,
            "ftmo_ready": 0,
            "avg_score": 0.0,
            "avg_metadata_quality": 0.0,
            "processing_time": 0.0
        }
        
    def prepare_expanded_sample(self, target_count: int = 50) -> List[str]:
        """Prepara amostra expandida de arquivos para análise"""
        logger.info(f"🔍 Preparando amostra expandida de {target_count} arquivos...")
        
        # Diretórios para buscar arquivos
        search_dirs = [
            self.base_path / "All_MQ4",
            self.base_path / "All_MQ5", 
            self.base_path / "Input_Expandido",
            self.base_path / "Demo_Tests" / "Input",
            self.base_path / "Demo_Visual" / "Input",
            self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "EAs",
            self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "Indicators",
            self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "Misc",
            self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL5_Source" / "EAs",
            self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL5_Source" / "Indicators"
        ]
        
        all_files = set()
        
        for search_dir in search_dirs:
            if search_dir.exists():
                # Buscar arquivos .mq4, .mq5, .mqh
                for pattern in ['*.mq4', '*.mq5', '*.mqh']:
                    files = list(search_dir.rglob(pattern))
                    all_files.update(files)
                    logger.info(f"📁 {search_dir.name}: {len(files)} arquivos {pattern}")
        
        # Converter para lista e limitar
        file_list = list(all_files)[:target_count]
        
        # Criar diretório de amostra expandida
        expanded_dir = self.base_path / "Amostra_Expandida_Critica"
        expanded_dir.mkdir(exist_ok=True)
        
        # Copiar arquivos únicos
        copied_files = []
        for i, file_path in enumerate(file_list):
            if i >= target_count:
                break
                
            try:
                # Gerar nome único se necessário
                dest_name = file_path.name
                dest_path = expanded_dir / dest_name
                counter = 1
                
                while dest_path.exists():
                    name_parts = file_path.stem, counter, file_path.suffix
                    dest_name = f"{name_parts[0]}_{name_parts[1]}{name_parts[2]}"
                    dest_path = expanded_dir / dest_name
                    counter += 1
                
                shutil.copy2(file_path, dest_path)
                copied_files.append(str(dest_path))
                
            except Exception as e:
                logger.error(f"Erro ao copiar {file_path}: {e}")
        
        logger.info(f"✅ Amostra expandida preparada: {len(copied_files)} arquivos únicos")
        return copied_files
    
    def analyze_file(self, file_path: str) -> FileAnalysis:
        """Analisa um arquivo com todos os agentes"""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            filename = Path(file_path).name
            
            # Análise por todos os agentes
            agent_scores = []
            for agent in self.agents:
                score = agent.analyze(content, filename)
                agent_scores.append(score)
            
            # Detectar tipo, estratégia, etc.
            file_type = self._detect_file_type(content)
            strategy = self._detect_strategy(content)
            market = self._detect_market(content, filename)
            timeframe = self._detect_timeframe(content)
            
            # Calcular score FTMO
            ftmo_agent = next(agent for agent in self.agents if agent.name == "Elite_FTMO")
            ftmo_score_obj = ftmo_agent.analyze(content, filename)
            ftmo_score = ftmo_score_obj.score
            ftmo_ready = ftmo_score >= 8.0
            
            # Extrair tags e componentes
            tags = self._extract_tags(content, file_type, strategy, market, timeframe)
            components = self._extract_components(content)
            
            # Calcular score unificado
            unified_score = self._calculate_unified_score(agent_scores)
            
            # Avaliar risco
            risk_level = self._evaluate_risk_level(content, ftmo_score)
            
            # Métricas de código
            code_metrics = self._calculate_code_metrics(content)
            
            # Criar análise
            analysis = FileAnalysis(
                filename=filename,
                file_type=file_type,
                strategy=strategy,
                market=market,
                timeframe=timeframe,
                ftmo_score=ftmo_score,
                ftmo_ready=ftmo_ready,
                tags=tags,
                components=components,
                agent_scores=agent_scores,
                unified_score=unified_score,
                metadata_quality=MetadataQuality(0, 0, 0, 0, 0, [], []),  # Será calculado depois
                risk_level=risk_level,
                code_metrics=code_metrics,
                timestamp=datetime.now().isoformat()
            )
            
            # Analisar qualidade dos metadados
            analysis.metadata_quality = self.metadata_analyzer.analyze_metadata_quality(analysis)
            
            return analysis
            
        except Exception as e:
            logger.error(f"Erro ao analisar {file_path}: {e}")
            return None
    
    def _detect_file_type(self, content: str) -> str:
        """Detecta tipo do arquivo"""
        if re.search(r'OnTick\s*\(', content, re.IGNORECASE):
            return "EA"
        elif re.search(r'OnCalculate\s*\(|SetIndexBuffer', content, re.IGNORECASE):
            return "Indicator"
        elif re.search(r'OnStart\s*\(', content, re.IGNORECASE):
            return "Script"
        elif re.search(r'study\s*\(|strategy\s*\(|indicator\s*\(', content, re.IGNORECASE):
            return "Pine"
        else:
            return "Unknown"
    
    def _detect_strategy(self, content: str) -> str:
        """Detecta estratégia de trading"""
        strategies = {
            "Scalping": [r'scalp', r'M1', r'M5', r'quick.*profit'],
            "Grid_Martingale": [r'grid', r'martingale', r'recovery', r'multiply.*lot'],
            "SMC": [r'order.*block', r'liquidity', r'institutional', r'smart.*money'],
            "Trend": [r'trend', r'momentum', r'moving.*average', r'MA\('],
            "Volume": [r'volume', r'OBV', r'volume.*profile', r'tick.*volume']
        }
        
        for strategy, patterns in strategies.items():
            if any(re.search(pattern, content, re.IGNORECASE) for pattern in patterns):
                return strategy
        
        return "Unknown"
    
    def _detect_market(self, content: str, filename: str) -> str:
        """Detecta mercado/instrumento"""
        # Verificar no nome do arquivo primeiro
        filename_upper = filename.upper()
        
        # Pares Forex
        forex_pairs = ['EURUSD', 'GBPUSD', 'USDJPY', 'USDCHF', 'AUDUSD', 'USDCAD', 'NZDUSD']
        for pair in forex_pairs:
            if pair in filename_upper or pair in content.upper():
                return pair
        
        # Metais
        if any(metal in filename_upper or metal in content.upper() for metal in ['XAUUSD', 'GOLD', 'XAGUSD', 'SILVER']):
            return "XAUUSD"
        
        # Índices
        indices = ['SPX500', 'NAS100', 'US30', 'GER30', 'UK100']
        for index in indices:
            if index in filename_upper or index in content.upper():
                return index
        
        # Crypto
        cryptos = ['BTCUSD', 'ETHUSD', 'BITCOIN', 'ETHEREUM']
        for crypto in cryptos:
            if crypto in filename_upper or crypto in content.upper():
                return crypto
        
        return "Unknown"
    
    def _detect_timeframe(self, content: str) -> str:
        """Detecta timeframe"""
        timeframes = {
            "M1": [r'PERIOD_M1', r'1.*minute', r'M1'],
            "M5": [r'PERIOD_M5', r'5.*minute', r'M5'],
            "M15": [r'PERIOD_M15', r'15.*minute', r'M15'],
            "H1": [r'PERIOD_H1', r'1.*hour', r'H1'],
            "H4": [r'PERIOD_H4', r'4.*hour', r'H4'],
            "D1": [r'PERIOD_D1', r'daily', r'D1']
        }
        
        for tf, patterns in timeframes.items():
            if any(re.search(pattern, content, re.IGNORECASE) for pattern in patterns):
                return tf
        
        return "Unknown"
    
    def _extract_tags(self, content: str, file_type: str, strategy: str, market: str, timeframe: str) -> List[str]:
        """Extrai tags do código"""
        tags = []
        
        # Tags básicas
        if file_type != "Unknown":
            tags.append(f"#{file_type}")
        if strategy != "Unknown":
            tags.append(f"#{strategy}")
        if market != "Unknown":
            tags.append(f"#{market}")
        if timeframe != "Unknown":
            tags.append(f"#{timeframe}")
        
        # Tags de indicadores técnicos
        indicators = {
            "#RSI": [r'RSI', r'Relative.*Strength'],
            "#MACD": [r'MACD', r'Moving.*Average.*Convergence'],
            "#Bollinger": [r'Bollinger', r'BB\('],
            "#Stochastic": [r'Stochastic', r'%K', r'%D'],
            "#ATR": [r'ATR', r'Average.*True.*Range']
        }
        
        for tag, patterns in indicators.items():
            if any(re.search(pattern, content, re.IGNORECASE) for pattern in patterns):
                tags.append(tag)
        
        # Tags especiais
        if re.search(r'news.*filter|economic.*calendar', content, re.IGNORECASE):
            tags.append("#News_Filter")
        
        if re.search(r'AI|artificial.*intelligence|neural.*network', content, re.IGNORECASE):
            tags.append("#AI")
        
        return tags
    
    def _extract_components(self, content: str) -> List[str]:
        """Extrai componentes reutilizáveis"""
        components = []
        
        # Gestão de risco
        if re.search(r'CalculateLotSize|LotCalculation', content, re.IGNORECASE):
            components.append("LotSizeCalculator")
        
        if re.search(r'StopLoss.*calculation|SL.*calculation', content, re.IGNORECASE):
            components.append("StopLossCalculator")
        
        # Filtros
        if re.search(r'news.*filter', content, re.IGNORECASE):
            components.append("NewsFilter")
        
        if re.search(r'session.*filter|trading.*hours', content, re.IGNORECASE):
            components.append("SessionFilter")
        
        # Análise técnica
        if re.search(r'order.*block.*detection', content, re.IGNORECASE):
            components.append("OrderBlockDetector")
        
        if re.search(r'support.*resistance', content, re.IGNORECASE):
            components.append("SupportResistanceDetector")
        
        return components
    
    def _calculate_unified_score(self, agent_scores: List[AgentScore]) -> float:
        """Calcula score unificado com pesos otimizados"""
        if not agent_scores:
            return 0.0
        
        # Pesos otimizados para cada agente
        weights = {
            "Critical_Architect": 0.25,
            "Elite_FTMO": 0.50,  # Maior peso para FTMO
            "Precision_Code_Analyst": 0.25
        }
        
        weighted_sum = 0.0
        total_weight = 0.0
        
        for score in agent_scores:
            weight = weights.get(score.agent_name, 0.33)
            weighted_sum += score.score * weight * score.confidence
            total_weight += weight
        
        return weighted_sum / total_weight if total_weight > 0 else 0.0
    
    def _evaluate_risk_level(self, content: str, ftmo_score: float) -> str:
        """Avalia nível de risco"""
        if ftmo_score >= 8.0:
            return "Low"
        elif ftmo_score >= 6.0:
            return "Medium"
        else:
            return "High"
    
    def _calculate_code_metrics(self, content: str) -> Dict[str, Any]:
        """Calcula métricas do código"""
        lines = content.split('\n')
        
        return {
            "total_lines": len(lines),
            "code_lines": len([line for line in lines if line.strip() and not line.strip().startswith('//')]),
            "comment_lines": len([line for line in lines if line.strip().startswith('//')]),
            "functions": len(re.findall(r'\b(?:void|int|double|bool|string)\s+\w+\s*\(', content)),
            "classes": len(re.findall(r'\bclass\s+\w+', content)),
            "variables": len(re.findall(r'\b(?:int|double|bool|string)\s+\w+\s*[;=]', content)),
            "complexity": self._calculate_complexity(content)
        }
    
    def _calculate_complexity(self, content: str) -> int:
        """Calcula complexidade ciclomática"""
        complexity_keywords = ['if', 'else', 'while', 'for', 'switch', 'case', '&&', '||']
        complexity = 1
        for keyword in complexity_keywords:
            complexity += len(re.findall(rf'\b{keyword}\b', content, re.IGNORECASE))
        return complexity
    
    def run_critical_analysis(self, sample_size: int = 50) -> Dict[str, Any]:
        """Executa análise crítica completa"""
        start_time = time.time()
        
        logger.info("🚀 Iniciando Sistema Multi-Agente de Análise Crítica Avançado")
        logger.info(f"📊 Tamanho da amostra: {sample_size} arquivos")
        
        # Preparar amostra expandida
        file_paths = self.prepare_expanded_sample(sample_size)
        
        self.stats["total_files"] = len(file_paths)
        
        # Análise paralela com ThreadPoolExecutor
        with ThreadPoolExecutor(max_workers=4) as executor:
            future_to_file = {executor.submit(self.analyze_file, file_path): file_path for file_path in file_paths}
            
            for future in as_completed(future_to_file):
                file_path = future_to_file[future]
                try:
                    result = future.result()
                    if result:
                        self.results.append(result)
                        self.stats["processed_files"] += 1
                        
                        if result.ftmo_ready:
                            self.stats["ftmo_ready"] += 1
                        
                        logger.info(f"✅ Processado: {result.filename} (Score: {result.unified_score:.2f})")
                    else:
                        self.stats["errors"] += 1
                        
                except Exception as e:
                    logger.error(f"❌ Erro ao processar {file_path}: {e}")
                    self.stats["errors"] += 1
        
        # Calcular estatísticas finais
        if self.results:
            self.stats["avg_score"] = sum(r.unified_score for r in self.results) / len(self.results)
            self.stats["avg_metadata_quality"] = sum(r.metadata_quality.overall_score for r in self.results) / len(self.results)
        
        self.stats["processing_time"] = time.time() - start_time
        
        logger.info(f"🎯 Análise concluída em {self.stats['processing_time']:.2f}s")
        logger.info(f"📈 Score Unificado Médio: {self.stats['avg_score']:.2f}/10.0")
        logger.info(f"🏆 Arquivos FTMO Ready: {self.stats['ftmo_ready']}/{self.stats['processed_files']}")
        
        return self._generate_comprehensive_report()
    
    def _generate_comprehensive_report(self) -> Dict[str, Any]:
        """Gera relatório abrangente da análise"""
        # Ordenar resultados por score
        sorted_results = sorted(self.results, key=lambda x: x.unified_score, reverse=True)
        
        # Top 10 arquivos
        top_files = sorted_results[:10]
        
        # Distribuições
        type_distribution = {}
        strategy_distribution = {}
        risk_distribution = {}
        
        for result in self.results:
            type_distribution[result.file_type] = type_distribution.get(result.file_type, 0) + 1
            strategy_distribution[result.strategy] = strategy_distribution.get(result.strategy, 0) + 1
            risk_distribution[result.risk_level] = risk_distribution.get(result.risk_level, 0) + 1
        
        # Issues mais comuns
        all_issues = []
        all_recommendations = []
        
        for result in self.results:
            for agent_score in result.agent_scores:
                all_issues.extend(agent_score.issues_found)
                all_recommendations.extend(agent_score.recommendations)
        
        from collections import Counter
        common_issues = Counter(all_issues).most_common(10)
        common_recommendations = Counter(all_recommendations).most_common(10)
        
        report = {
            "summary": {
                "total_files_analyzed": self.stats["processed_files"],
                "processing_time_seconds": round(self.stats["processing_time"], 2),
                "average_unified_score": round(self.stats["avg_score"], 2),
                "average_metadata_quality": round(self.stats["avg_metadata_quality"], 2),
                "ftmo_ready_count": self.stats["ftmo_ready"],
                "errors_count": self.stats["errors"]
            },
            "distributions": {
                "file_types": type_distribution,
                "strategies": strategy_distribution,
                "risk_levels": risk_distribution
            },
            "top_performers": [
                {
                    "filename": result.filename,
                    "unified_score": round(result.unified_score, 2),
                    "ftmo_score": round(result.ftmo_score, 2),
                    "metadata_quality": round(result.metadata_quality.overall_score, 2),
                    "file_type": result.file_type,
                    "strategy": result.strategy,
                    "risk_level": result.risk_level
                }
                for result in top_files
            ],
            "quality_analysis": {
                "common_issues": [f"{issue}: {count}" for issue, count in common_issues],
                "common_recommendations": [f"{rec}: {count}" for rec, count in common_recommendations]
            },
            "agent_performance": self._analyze_agent_performance(),
            "metadata_quality_breakdown": self._analyze_metadata_quality_breakdown()
        }
        
        return report
    
    def _analyze_agent_performance(self) -> Dict[str, Any]:
        """Analisa performance dos agentes"""
        agent_stats = {}
        
        for result in self.results:
            for agent_score in result.agent_scores:
                agent_name = agent_score.agent_name
                if agent_name not in agent_stats:
                    agent_stats[agent_name] = {
                        "scores": [],
                        "confidences": [],
                        "issues_count": 0,
                        "recommendations_count": 0
                    }
                
                agent_stats[agent_name]["scores"].append(agent_score.score)
                agent_stats[agent_name]["confidences"].append(agent_score.confidence)
                agent_stats[agent_name]["issues_count"] += len(agent_score.issues_found)
                agent_stats[agent_name]["recommendations_count"] += len(agent_score.recommendations)
        
        # Calcular médias
        for agent_name, stats in agent_stats.items():
            stats["avg_score"] = round(sum(stats["scores"]) / len(stats["scores"]), 2)
            stats["avg_confidence"] = round(sum(stats["confidences"]) / len(stats["confidences"]), 2)
            del stats["scores"]
            del stats["confidences"]
        
        return agent_stats
    
    def _analyze_metadata_quality_breakdown(self) -> Dict[str, float]:
        """Analisa breakdown da qualidade dos metadados"""
        if not self.results:
            return {}
        
        total_completeness = sum(r.metadata_quality.completeness for r in self.results)
        total_accuracy = sum(r.metadata_quality.accuracy for r in self.results)
        total_consistency = sum(r.metadata_quality.consistency for r in self.results)
        total_ftmo_compliance = sum(r.metadata_quality.ftmo_compliance for r in self.results)
        
        count = len(self.results)
        
        return {
            "avg_completeness": round(total_completeness / count, 2),
            "avg_accuracy": round(total_accuracy / count, 2),
            "avg_consistency": round(total_consistency / count, 2),
            "avg_ftmo_compliance": round(total_ftmo_compliance / count, 2)
        }
    
    def export_results(self, output_dir: str = "Output_Analise_Critica"):
        """Exporta resultados da análise"""
        output_path = Path(output_dir)
        output_path.mkdir(exist_ok=True)
        
        # Gerar relatório
        report = self._generate_comprehensive_report()
        
        # Exportar JSON completo
        with open(output_path / "analise_critica_completa.json", 'w', encoding='utf-8') as f:
            json.dump({
                "metadata": {
                    "generated_at": datetime.now().isoformat(),
                    "system_version": "2.0",
                    "total_files": len(self.results)
                },
                "statistics": self.stats,
                "report": report,
                "detailed_results": [asdict(result) for result in self.results]
            }, f, indent=2, ensure_ascii=False)
        
        # Exportar relatório Markdown
        self._export_markdown_report(output_path, report)
        
        logger.info(f"📁 Resultados exportados para: {output_path}")
    
    def _export_markdown_report(self, output_path: Path, report: Dict[str, Any]):
        """Exporta relatório em Markdown"""
        md_content = f"""# Relatório de Análise Crítica Multi-Agente

**Gerado em:** {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}
**Sistema:** Classificador_Trading v2.0

## 📊 Resumo Executivo

- **Arquivos Analisados:** {report['summary']['total_files_analyzed']}
- **Tempo de Processamento:** {report['summary']['processing_time_seconds']}s
- **Score Unificado Médio:** {report['summary']['average_unified_score']}/10.0
- **Qualidade de Metadados Média:** {report['summary']['average_metadata_quality']}/10.0
- **Arquivos FTMO Ready:** {report['summary']['ftmo_ready_count']}
- **Erros:** {report['summary']['errors_count']}

## 🏆 Top 10 Arquivos com Melhor Performance

| Posição | Arquivo | Score Unificado | Score FTMO | Qualidade Metadados | Tipo | Estratégia | Risco |
|---------|---------|-----------------|------------|---------------------|------|------------|-------|
"""
        
        for i, file_info in enumerate(report['top_performers'], 1):
            md_content += f"| {i} | {file_info['filename']} | {file_info['unified_score']}/10.0 | {file_info['ftmo_score']}/10.0 | {file_info['metadata_quality']}/10.0 | {file_info['file_type']} | {file_info['strategy']} | {file_info['risk_level']} |\n"
        
        md_content += f"""

## 📈 Distribuições

### Por Tipo de Arquivo
"""
        for file_type, count in report['distributions']['file_types'].items():
            md_content += f"- **{file_type}:** {count} arquivos\n"
        
        md_content += "\n### Por Estratégia\n"
        for strategy, count in report['distributions']['strategies'].items():
            md_content += f"- **{strategy}:** {count} arquivos\n"
        
        md_content += "\n### Por Nível de Risco\n"
        for risk, count in report['distributions']['risk_levels'].items():
            md_content += f"- **{risk}:** {count} arquivos\n"
        
        md_content += f"""

## ⚠️ Issues Mais Comuns

"""
        for issue in report['quality_analysis']['common_issues'][:10]:
            md_content += f"- {issue}\n"
        
        md_content += f"""

## 💡 Recomendações Mais Comuns

"""
        for rec in report['quality_analysis']['common_recommendations'][:10]:
            md_content += f"- {rec}\n"
        
        md_content += f"""

## 🤖 Performance dos Agentes

"""
        for agent_name, stats in report['agent_performance'].items():
            md_content += f"### {agent_name}\n"
            md_content += f"- **Score Médio:** {stats['avg_score']}/10.0\n"
            md_content += f"- **Confiança Média:** {stats['avg_confidence']}/1.0\n"
            md_content += f"- **Issues Encontrados:** {stats['issues_count']}\n"
            md_content += f"- **Recomendações:** {stats['recommendations_count']}\n\n"
        
        md_content += f"""
## 📋 Breakdown da Qualidade dos Metadados

"""
        quality_breakdown = report.get('metadata_quality_breakdown', {})
        if quality_breakdown:
            md_content += f"- **Completeness Médio:** {quality_breakdown.get('avg_completeness', 0)}/10.0\n"
            md_content += f"- **Accuracy Médio:** {quality_breakdown.get('avg_accuracy', 0)}/10.0\n"
            md_content += f"- **Consistency Médio:** {quality_breakdown.get('avg_consistency', 0)}/10.0\n"
            md_content += f"- **FTMO Compliance Médio:** {quality_breakdown.get('avg_ftmo_compliance', 0)}/10.0\n"
        
        md_content += f"""

## 🎯 Conclusões e Próximos Passos

### Pontos Fortes Identificados
- Sistema multi-agente funcionando com alta precisão
- Análise FTMO robusta implementada
- Detecção automática de tipos e estratégias eficaz

### Áreas de Melhoria
- Implementar mais filtros de conformidade FTMO
- Expandir detecção de padrões de código
- Melhorar sistema de tags automáticas

### Recomendações Prioritárias
1. **Implementar Stop Loss obrigatório** em todos os EAs
2. **Remover estratégias Martingale/Grid** não conformes
3. **Adicionar filtros de notícias** para proteção
4. **Melhorar gestão de risco** com cálculos dinâmicos
5. **Refatorar códigos complexos** para manutenibilidade

---
*Relatório gerado pelo Sistema Multi-Agente Classificador_Trading v2.0*
"""
        
        with open(output_path / "RELATORIO_ANALISE_CRITICA.md", 'w', encoding='utf-8') as f:
            f.write(md_content)

def main():
    """Função principal para execução em modo console"""
    print("🚀 Sistema Multi-Agente de Análise Crítica Avançado")
    print("📋 Classificador_Trading v2.0 - Elite AI")
    print("=" * 60)
    
    # Configurar sistema
    base_path = Path.cwd()
    system = AdvancedMultiAgentSystem(str(base_path))
    
    try:
        # Executar análise crítica com amostra expandida
        print("\n🔍 Iniciando análise crítica com amostra expandida...")
        report = system.run_critical_analysis(sample_size=50)
        
        # Exportar resultados
        print("\n📁 Exportando resultados...")
        system.export_results()
        
        # Mostrar resumo
        print("\n" + "=" * 60)
        print("📊 RESUMO DA ANÁLISE CRÍTICA")
        print("=" * 60)
        print(f"✅ Arquivos Processados: {report['summary']['total_files_analyzed']}")
        print(f"⏱️  Tempo Total: {report['summary']['processing_time_seconds']}s")
        print(f"🎯 Score Unificado Médio: {report['summary']['average_unified_score']}/10.0")
        print(f"📈 Qualidade Metadados: {report['summary']['average_metadata_quality']}/10.0")
        print(f"🏆 FTMO Ready: {report['summary']['ftmo_ready_count']} arquivos")
        print(f"❌ Erros: {report['summary']['errors_count']}")
        
        print("\n🏆 TOP 5 ARQUIVOS:")
        for i, file_info in enumerate(report['top_performers'][:5], 1):
            print(f"{i}. {file_info['filename']} - Score: {file_info['unified_score']}/10.0")
        
        print("\n📁 Resultados salvos em: Output_Analise_Critica/")
        print("✅ Análise crítica concluída com sucesso!")
        
    except Exception as e:
        logger.error(f"Erro durante execução: {e}")
        print(f"❌ Erro: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())