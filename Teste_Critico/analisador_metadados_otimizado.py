#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Analisador de Metadados Otimizado - Classificador Trading v4.0
Sistema Multi-Agente para Análise Crítica e Otimização Contínua
"""

import os
import sys
import json
import time
import re
from pathlib import Path
import datetime
from dataclasses import dataclass, asdict
from typing import List, Dict, Any, Optional
from concurrent.futures import ThreadPoolExecutor, as_completed
import logging

# Configuração de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('analisador_metadados.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

@dataclass
class MetadataQuality:
    """Qualidade dos metadados"""
    completeness: float  # 0-10
    accuracy: float     # 0-10
    consistency: float  # 0-10
    richness: float     # 0-10
    overall_score: float # 0-10
    issues: List[str]
    recommendations: List[str]

@dataclass
class AgentScore:
    """Score de um agente específico"""
    agent_name: str
    score: float
    max_score: float
    details: Dict[str, Any]
    recommendations: List[str]
    issues: List[str]
    confidence: float
    processing_time: float
    timestamp: str

@dataclass
class FileAnalysis:
    """Análise completa de um arquivo"""
    filename: str
    file_path: str
    file_type: str
    strategy: str
    market: str
    timeframe: str
    ftmo_score: float
    ftmo_status: str
    tags: List[str]
    components: List[str]
    agent_scores: List[AgentScore]
    unified_score: float
    metadata_quality: MetadataQuality
    processing_time: float
    issues_found: List[str]
    recommendations: List[str]
    code_metrics: Dict[str, Any]
    risk_assessment: Dict[str, Any]

class AdvancedArchitectAgent:
    """Agente Arquiteto Avançado - Avalia estrutura e padrões de código"""
    
    def __init__(self):
        self.name = "Advanced_Architect"
        self.max_score = 10.0
        self.patterns = self._load_patterns()
        
    def _load_patterns(self) -> Dict[str, List[str]]:
        """Carrega padrões de análise"""
        return {
            "oop_patterns": [r'\bclass\s+\w+', r'\bstruct\s+\w+', r'\bpublic:', r'\bprivate:'],
            "function_patterns": [r'\b(void|int|double|bool|string|datetime)\s+\w+\s*\('],
            "error_handling": [r'\bGetLastError\b', r'\btry\b', r'\bcatch\b', r'\bif\s*\(.*Error'],
            "constants": [r'#define\s+\w+', r'\benum\s+\w+', r'\bconst\s+\w+'],
            "includes": [r'#include\s*[<"].*[>"]', r'#import\s*[<"].*[>"]'],
            "comments": [r'//.*', r'/\*.*?\*/', r'\*.*'],
            "best_practices": [r'\bOnInit\b', r'\bOnDeinit\b', r'\binput\s+\w+', r'\bextern\s+\w+']
        }
        
    def analyze(self, file_path: str, content: str) -> AgentScore:
        """Analisa a arquitetura do código"""
        start_time = time.time()
        score = 0.0
        details = {}
        recommendations = []
        issues = []
        confidence = 0.0
        
        try:
            # Análise de estrutura OOP
            oop_score, oop_details = self._analyze_oop(content)
            score += oop_score
            details.update(oop_details)
            confidence += 0.2
            
            # Análise de funções e modularidade
            func_score, func_details = self._analyze_functions(content)
            score += func_score
            details.update(func_details)
            confidence += 0.2
            
            # Análise de comentários e documentação
            doc_score, doc_details = self._analyze_documentation(content)
            score += doc_score
            details.update(doc_details)
            confidence += 0.15
            
            # Análise de tratamento de erros
            error_score, error_details = self._analyze_error_handling(content)
            score += error_score
            details.update(error_details)
            confidence += 0.15
            
            # Análise de boas práticas
            practices_score, practices_details = self._analyze_best_practices(content)
            score += practices_score
            details.update(practices_details)
            confidence += 0.15
            
            # Análise de complexidade
            complexity_score, complexity_details = self._analyze_complexity(content)
            score += complexity_score
            details.update(complexity_details)
            confidence += 0.15
            
            # Gerar recomendações baseadas na análise
            recommendations = self._generate_recommendations(details)
            issues = self._identify_issues(details)
            
            # Normalizar score
            score = min(score, self.max_score)
            
        except Exception as e:
            logger.error(f"Erro na análise do Architect: {e}")
            issues.append(f"Erro na análise: {str(e)}")
            confidence = 0.1
            
        processing_time = time.time() - start_time
        
        return AgentScore(
            agent_name=self.name,
            score=score,
            max_score=self.max_score,
            details=details,
            recommendations=recommendations,
            issues=issues,
            confidence=confidence,
            processing_time=processing_time,
            timestamp=datetime.datetime.now().isoformat()
        )
    
    def _analyze_oop(self, content: str) -> tuple:
        """Analisa uso de programação orientada a objetos"""
        score = 0.0
        details = {}
        
        class_count = len(re.findall(r'\bclass\s+\w+', content))
        struct_count = len(re.findall(r'\bstruct\s+\w+', content))
        access_modifiers = len(re.findall(r'\b(public|private|protected):', content))
        
        if class_count > 0:
            score += 2.0
            details['has_classes'] = True
            details['class_count'] = class_count
            
            if access_modifiers > 0:
                score += 0.5
                details['uses_access_modifiers'] = True
        else:
            details['has_classes'] = False
            
        if struct_count > 0:
            score += 0.5
            details['struct_count'] = struct_count
            
        details['oop_score'] = score
        return score, details
    
    def _analyze_functions(self, content: str) -> tuple:
        """Analisa funções e modularidade"""
        score = 0.0
        details = {}
        
        functions = re.findall(r'\b(void|int|double|bool|string|datetime)\s+(\w+)\s*\(', content)
        function_count = len(functions)
        
        details['function_count'] = function_count
        details['function_names'] = [func[1] for func in functions[:10]]  # Primeiras 10
        
        if function_count >= 10:
            score += 2.0
            details['modularity'] = 'Excellent'
        elif function_count >= 5:
            score += 1.5
            details['modularity'] = 'Good'
        elif function_count >= 3:
            score += 1.0
            details['modularity'] = 'Basic'
        else:
            details['modularity'] = 'Poor'
            
        # Análise de parâmetros de função
        complex_functions = len(re.findall(r'\w+\s*\([^)]{20,}\)', content))
        if complex_functions > 0:
            details['has_complex_functions'] = True
            if complex_functions <= function_count * 0.3:  # Máximo 30% de funções complexas
                score += 0.5
            else:
                score -= 0.5
                
        details['function_analysis_score'] = score
        return score, details
    
    def _analyze_documentation(self, content: str) -> tuple:
        """Analisa comentários e documentação"""
        score = 0.0
        details = {}
        
        lines = content.split('\n')
        total_lines = len([line for line in lines if line.strip()])
        
        # Contar diferentes tipos de comentários
        single_comments = len(re.findall(r'//.*', content))
        block_comments = len(re.findall(r'/\*.*?\*/', content, re.DOTALL))
        header_comments = len(re.findall(r'/\*\*.*?\*/', content, re.DOTALL))
        
        total_comments = single_comments + block_comments
        comment_ratio = total_comments / max(total_lines, 1)
        
        details['total_lines'] = total_lines
        details['single_comments'] = single_comments
        details['block_comments'] = block_comments
        details['header_comments'] = header_comments
        details['comment_ratio'] = comment_ratio
        
        if comment_ratio >= 0.20:
            score += 2.0
            details['documentation_quality'] = 'Excellent'
        elif comment_ratio >= 0.15:
            score += 1.5
            details['documentation_quality'] = 'Good'
        elif comment_ratio >= 0.10:
            score += 1.0
            details['documentation_quality'] = 'Basic'
        else:
            details['documentation_quality'] = 'Poor'
            
        if header_comments > 0:
            score += 0.5
            details['has_header_documentation'] = True
            
        details['documentation_score'] = score
        return score, details
    
    def _analyze_error_handling(self, content: str) -> tuple:
        """Analisa tratamento de erros"""
        score = 0.0
        details = {}
        
        error_patterns = [
            r'\bGetLastError\b',
            r'\btry\b.*\bcatch\b',
            r'\bif\s*\(.*Error',
            r'\bErrorDescription\b',
            r'\bIsTradeAllowed\b'
        ]
        
        error_handling_count = 0
        for pattern in error_patterns:
            matches = len(re.findall(pattern, content, re.IGNORECASE))
            if matches > 0:
                error_handling_count += 1
                
        details['error_handling_patterns'] = error_handling_count
        
        if error_handling_count >= 3:
            score += 2.0
            details['error_handling_quality'] = 'Excellent'
        elif error_handling_count >= 2:
            score += 1.5
            details['error_handling_quality'] = 'Good'
        elif error_handling_count >= 1:
            score += 1.0
            details['error_handling_quality'] = 'Basic'
        else:
            details['error_handling_quality'] = 'None'
            
        details['error_handling_score'] = score
        return score, details
    
    def _analyze_best_practices(self, content: str) -> tuple:
        """Analisa boas práticas de programação"""
        score = 0.0
        details = {}
        
        practices = {
            'has_oninit': bool(re.search(r'\bOnInit\b', content)),
            'has_ondeinit': bool(re.search(r'\bOnDeinit\b', content)),
            'uses_input_params': bool(re.search(r'\binput\s+\w+', content)),
            'uses_extern_params': bool(re.search(r'\bextern\s+\w+', content)),
            'uses_constants': bool(re.search(r'#define\s+\w+|\bconst\s+\w+', content)),
            'proper_includes': len(re.findall(r'#include\s*[<"].*[>"]', content)) > 0
        }
        
        details.update(practices)
        
        # Pontuar cada boa prática
        for practice, exists in practices.items():
            if exists:
                score += 0.3
                
        details['best_practices_score'] = score
        return score, details
    
    def _analyze_complexity(self, content: str) -> tuple:
        """Analisa complexidade do código"""
        score = 0.0
        details = {}
        
        lines = content.split('\n')
        code_lines = len([line for line in lines if line.strip() and not line.strip().startswith('//')])
        
        # Contar estruturas de controle
        if_count = len(re.findall(r'\bif\s*\(', content))
        for_count = len(re.findall(r'\bfor\s*\(', content))
        while_count = len(re.findall(r'\bwhile\s*\(', content))
        switch_count = len(re.findall(r'\bswitch\s*\(', content))
        
        total_control = if_count + for_count + while_count + switch_count
        complexity_ratio = total_control / max(code_lines, 1)
        
        details['code_lines'] = code_lines
        details['if_statements'] = if_count
        details['for_loops'] = for_count
        details['while_loops'] = while_count
        details['switch_statements'] = switch_count
        details['complexity_ratio'] = complexity_ratio
        
        # Pontuar baseado na complexidade
        if complexity_ratio <= 0.1:  # Baixa complexidade
            score += 2.0
            details['complexity_level'] = 'Low'
        elif complexity_ratio <= 0.2:  # Média complexidade
            score += 1.5
            details['complexity_level'] = 'Medium'
        elif complexity_ratio <= 0.3:  # Alta complexidade
            score += 1.0
            details['complexity_level'] = 'High'
        else:  # Muito alta complexidade
            score += 0.5
            details['complexity_level'] = 'Very High'
            
        details['complexity_score'] = score
        return score, details
    
    def _generate_recommendations(self, details: Dict[str, Any]) -> List[str]:
        """Gera recomendações baseadas na análise"""
        recommendations = []
        
        if not details.get('has_classes', False):
            recommendations.append("Considerar uso de programação orientada a objetos para melhor organização")
            
        if details.get('function_count', 0) < 5:
            recommendations.append("Aumentar modularidade criando mais funções específicas")
            
        if details.get('comment_ratio', 0) < 0.15:
            recommendations.append("Adicionar mais comentários explicativos no código")
            
        if details.get('error_handling_patterns', 0) < 2:
            recommendations.append("Implementar tratamento de erros mais robusto")
            
        if not details.get('uses_constants', False):
            recommendations.append("Usar constantes para valores fixos em vez de números mágicos")
            
        if details.get('complexity_level') == 'Very High':
            recommendations.append("Refatorar código para reduzir complexidade")
            
        return recommendations
    
    def _identify_issues(self, details: Dict[str, Any]) -> List[str]:
        """Identifica issues críticos"""
        issues = []
        
        if details.get('error_handling_quality') == 'None':
            issues.append("CRÍTICO: Nenhum tratamento de erro encontrado")
            
        if details.get('function_count', 0) < 3:
            issues.append("AVISO: Código muito monolítico - poucas funções")
            
        if details.get('complexity_level') == 'Very High':
            issues.append("CRÍTICO: Complexidade muito alta - difícil manutenção")
            
        if details.get('comment_ratio', 0) < 0.05:
            issues.append("AVISO: Documentação insuficiente")
            
        return issues

class EnhancedFTMOAgent:
    """Agente FTMO Aprimorado - Avalia conformidade FTMO e gestão de risco"""
    
    def __init__(self):
        self.name = "Enhanced_FTMO"
        self.max_score = 10.0
        self.ftmo_rules = self._load_ftmo_rules()
        
    def _load_ftmo_rules(self) -> Dict[str, Any]:
        """Carrega regras FTMO"""
        return {
            "prohibited_strategies": [
                r'\bgrid\b', r'\bmartingale\b', r'\brecovery\b',
                r'\bdouble\s*down\b', r'\bhedge\b', r'\barbitrage\b',
                r'\bscalping\b.*\bnews\b', r'\bhigh\s*frequency\b'
            ],
            "required_elements": {
                "stop_loss": [r'\bStopLoss\b', r'\bSL\b', r'\bstop.*loss\b'],
                "take_profit": [r'\bTakeProfit\b', r'\bTP\b', r'\btake.*profit\b'],
                "risk_management": [r'\brisk\b', r'\blot.*size\b', r'\bposition.*size\b'],
                "drawdown_control": [r'\bdrawdown\b', r'\bequity\b', r'\bbalance\b'],
                "time_filters": [r'\btime\b.*filter', r'\bsession\b', r'\bhour\b'],
                "news_filters": [r'\bnews\b', r'\bevent\b', r'\beconomic\b']
            },
            "risk_limits": {
                "max_risk_per_trade": 1.0,  # 1%
                "max_daily_loss": 5.0,      # 5%
                "max_total_loss": 10.0,     # 10%
                "min_risk_reward": 1.5      # 1:1.5
            }
        }
        
    def analyze(self, file_path: str, content: str) -> AgentScore:
        """Analisa conformidade FTMO"""
        start_time = time.time()
        score = 0.0
        details = {}
        recommendations = []
        issues = []
        confidence = 0.0
        
        try:
            # Verificar estratégias proibidas
            prohibited_score, prohibited_details = self._check_prohibited_strategies(content)
            score += prohibited_score
            details.update(prohibited_details)
            confidence += 0.3
            
            # Verificar elementos obrigatórios
            required_score, required_details = self._check_required_elements(content)
            score += required_score
            details.update(required_details)
            confidence += 0.3
            
            # Análise de gestão de risco
            risk_score, risk_details = self._analyze_risk_management(content)
            score += risk_score
            details.update(risk_details)
            confidence += 0.2
            
            # Análise de filtros
            filter_score, filter_details = self._analyze_filters(content)
            score += filter_score
            details.update(filter_details)
            confidence += 0.2
            
            # Gerar recomendações e issues
            recommendations = self._generate_ftmo_recommendations(details)
            issues = self._identify_ftmo_issues(details)
            
            # Aplicar penalidades por estratégias proibidas
            if details.get('has_prohibited_strategies', False):
                score = min(score, 2.0)  # Score máximo 2.0 se tem estratégias proibidas
                details['ftmo_compliant'] = False
            else:
                details['ftmo_compliant'] = True
                
            # Normalizar score
            score = min(score, self.max_score)
            
        except Exception as e:
            logger.error(f"Erro na análise do FTMO: {e}")
            issues.append(f"Erro na análise FTMO: {str(e)}")
            confidence = 0.1
            
        processing_time = time.time() - start_time
        
        return AgentScore(
            agent_name=self.name,
            score=score,
            max_score=self.max_score,
            details=details,
            recommendations=recommendations,
            issues=issues,
            confidence=confidence,
            processing_time=processing_time,
            timestamp=datetime.datetime.now().isoformat()
        )
    
    def _check_prohibited_strategies(self, content: str) -> tuple:
        """Verifica estratégias proibidas"""
        score = 0.0
        details = {}
        
        prohibited_found = []
        for pattern in self.ftmo_rules['prohibited_strategies']:
            if re.search(pattern, content, re.IGNORECASE):
                prohibited_found.append(pattern)
                
        details['prohibited_strategies_found'] = prohibited_found
        details['has_prohibited_strategies'] = len(prohibited_found) > 0
        
        if not prohibited_found:
            score = 3.0  # Pontuação alta por não ter estratégias proibidas
            details['strategy_compliance'] = 'Compliant'
        else:
            score = 0.0
            details['strategy_compliance'] = 'Non-Compliant'
            
        return score, details
    
    def _check_required_elements(self, content: str) -> tuple:
        """Verifica elementos obrigatórios"""
        score = 0.0
        details = {}
        
        required_elements = self.ftmo_rules['required_elements']
        
        for element, patterns in required_elements.items():
            found = any(re.search(pattern, content, re.IGNORECASE) for pattern in patterns)
            details[f'has_{element}'] = found
            
            if found:
                if element in ['stop_loss', 'risk_management']:
                    score += 1.5  # Elementos críticos
                else:
                    score += 1.0   # Elementos importantes
                    
        return score, details
    
    def _analyze_risk_management(self, content: str) -> tuple:
        """Analisa gestão de risco"""
        score = 0.0
        details = {}
        
        # Procurar por cálculos de risco
        risk_patterns = [
            r'\brisk\s*[=*]\s*[0-9.]+',
            r'\blot.*size\s*[=*]',
            r'\bAccountBalance\b',
            r'\bAccountEquity\b',
            r'\bAccountFreeMargin\b'
        ]
        
        risk_calculations = 0
        for pattern in risk_patterns:
            if re.search(pattern, content, re.IGNORECASE):
                risk_calculations += 1
                
        details['risk_calculation_patterns'] = risk_calculations
        
        if risk_calculations >= 3:
            score += 2.0
            details['risk_management_quality'] = 'Excellent'
        elif risk_calculations >= 2:
            score += 1.5
            details['risk_management_quality'] = 'Good'
        elif risk_calculations >= 1:
            score += 1.0
            details['risk_management_quality'] = 'Basic'
        else:
            details['risk_management_quality'] = 'Poor'
            
        # Verificar limites de risco específicos
        if re.search(r'\b[0-9.]*[01]\.[0-9]*\b.*risk', content, re.IGNORECASE):
            score += 0.5
            details['has_risk_percentage'] = True
            
        return score, details
    
    def _analyze_filters(self, content: str) -> tuple:
        """Analisa filtros de tempo e notícias"""
        score = 0.0
        details = {}
        
        # Filtros de tempo
        time_filter_patterns = [
            r'\bTimeHour\b', r'\bTimeCurrent\b', r'\bTimeLocal\b',
            r'\bsession\b', r'\btrade.*time\b', r'\bhour.*filter\b'
        ]
        
        has_time_filter = any(re.search(pattern, content, re.IGNORECASE) 
                             for pattern in time_filter_patterns)
        
        details['has_time_filter'] = has_time_filter
        if has_time_filter:
            score += 1.0
            
        # Filtros de notícias
        news_filter_patterns = [
            r'\bnews\b.*filter', r'\bevent\b.*filter', r'\beconomic\b',
            r'\bfundamental\b', r'\bvolatility\b.*filter', r'\bspread\b.*filter'
        ]
        
        has_news_filter = any(re.search(pattern, content, re.IGNORECASE) 
                             for pattern in news_filter_patterns)
        
        details['has_news_filter'] = has_news_filter
        if has_news_filter:
            score += 1.5  # Filtro de notícias é muito importante
            
        return score, details
    
    def _generate_ftmo_recommendations(self, details: Dict[str, Any]) -> List[str]:
        """Gera recomendações específicas para FTMO"""
        recommendations = []
        
        if not details.get('has_stop_loss', False):
            recommendations.append("CRÍTICO: Implementar Stop Loss obrigatório para conformidade FTMO")
            
        if not details.get('has_risk_management', False):
            recommendations.append("CRÍTICO: Implementar gestão de risco com limite de 1% por trade")
            
        if not details.get('has_time_filter', False):
            recommendations.append("Adicionar filtros de horário para evitar períodos de alta volatilidade")
            
        if not details.get('has_news_filter', False):
            recommendations.append("Implementar filtro de notícias para evitar eventos de alto impacto")
            
        if details.get('risk_management_quality') == 'Poor':
            recommendations.append("Melhorar cálculos de gestão de risco com base no saldo da conta")
            
        if not details.get('has_take_profit', False):
            recommendations.append("Adicionar Take Profit para melhorar relação risco/retorno")
            
        return recommendations
    
    def _identify_ftmo_issues(self, details: Dict[str, Any]) -> List[str]:
        """Identifica issues críticos para FTMO"""
        issues = []
        
        if details.get('has_prohibited_strategies', False):
            strategies = details.get('prohibited_strategies_found', [])
            issues.append(f"CRÍTICO: Estratégias proibidas detectadas: {', '.join(strategies)}")
            
        if not details.get('has_stop_loss', False):
            issues.append("CRÍTICO: Stop Loss obrigatório não encontrado")
            
        if not details.get('has_risk_management', False):
            issues.append("CRÍTICO: Gestão de risco inadequada")
            
        if details.get('strategy_compliance') == 'Non-Compliant':
            issues.append("CRÍTICO: Estratégia não compatível com regras FTMO")
            
        return issues

class PrecisionCodeAnalyst:
    """Agente Analista de Código de Precisão - Avalia qualidade técnica detalhada"""
    
    def __init__(self):
        self.name = "Precision_Code_Analyst"
        self.max_score = 10.0
        
    def analyze(self, file_path: str, content: str) -> AgentScore:
        """Analisa qualidade técnica do código com precisão"""
        start_time = time.time()
        score = 0.0
        details = {}
        recommendations = []
        issues = []
        confidence = 0.0
        
        try:
            # Análise de métricas de código
            metrics_score, metrics_details = self._analyze_code_metrics(content)
            score += metrics_score
            details.update(metrics_details)
            confidence += 0.25
            
            # Análise de performance
            perf_score, perf_details = self._analyze_performance(content)
            score += perf_score
            details.update(perf_details)
            confidence += 0.2
            
            # Análise de indicadores técnicos
            tech_score, tech_details = self._analyze_technical_indicators(content)
            score += tech_score
            details.update(tech_details)
            confidence += 0.2
            
            # Análise de logging e debug
            log_score, log_details = self._analyze_logging(content)
            score += log_score
            details.update(log_details)
            confidence += 0.15
            
            # Análise de segurança
            sec_score, sec_details = self._analyze_security(content)
            score += sec_score
            details.update(sec_details)
            confidence += 0.2
            
            # Gerar recomendações e issues
            recommendations = self._generate_code_recommendations(details)
            issues = self._identify_code_issues(details)
            
            # Normalizar score
            score = min(score, self.max_score)
            
        except Exception as e:
            logger.error(f"Erro na análise do Code Analyst: {e}")
            issues.append(f"Erro na análise de código: {str(e)}")
            confidence = 0.1
            
        processing_time = time.time() - start_time
        
        return AgentScore(
            agent_name=self.name,
            score=score,
            max_score=self.max_score,
            details=details,
            recommendations=recommendations,
            issues=issues,
            confidence=confidence,
            processing_time=processing_time,
            timestamp=datetime.datetime.now().isoformat()
        )
    
    def _analyze_code_metrics(self, content: str) -> tuple:
        """Analisa métricas detalhadas do código"""
        score = 0.0
        details = {}
        
        lines = content.split('\n')
        total_lines = len(lines)
        code_lines = len([line for line in lines if line.strip() and not line.strip().startswith('//')])
        blank_lines = len([line for line in lines if not line.strip()])
        comment_lines = total_lines - code_lines - blank_lines
        
        details.update({
            'total_lines': total_lines,
            'code_lines': code_lines,
            'comment_lines': comment_lines,
            'blank_lines': blank_lines,
            'comment_ratio': comment_lines / max(total_lines, 1)
        })
        
        # Análise de complexidade ciclomática (aproximada)
        decision_points = (
            len(re.findall(r'\bif\b', content)) +
            len(re.findall(r'\belse\b', content)) +
            len(re.findall(r'\bfor\b', content)) +
            len(re.findall(r'\bwhile\b', content)) +
            len(re.findall(r'\bswitch\b', content)) +
            len(re.findall(r'\bcase\b', content))
        )
        
        cyclomatic_complexity = decision_points + 1
        details['cyclomatic_complexity'] = cyclomatic_complexity
        
        # Pontuar baseado na complexidade
        if cyclomatic_complexity <= 10:
            score += 2.0
            details['complexity_rating'] = 'Low'
        elif cyclomatic_complexity <= 20:
            score += 1.5
            details['complexity_rating'] = 'Medium'
        elif cyclomatic_complexity <= 30:
            score += 1.0
            details['complexity_rating'] = 'High'
        else:
            score += 0.5
            details['complexity_rating'] = 'Very High'
            
        # Análise de variáveis globais
        global_vars = len(re.findall(r'^\s*(int|double|bool|string|datetime)\s+\w+', content, re.MULTILINE))
        details['global_variables'] = global_vars
        
        if global_vars <= 5:
            score += 1.0
        elif global_vars <= 10:
            score += 0.5
        else:
            score += 0.0
            
        return score, details
    
    def _analyze_performance(self, content: str) -> tuple:
        """Analisa aspectos de performance"""
        score = 0.0
        details = {}
        
        performance_issues = []
        
        # Verificar loops infinitos
        if re.search(r'while\s*\(\s*true\s*\)', content, re.IGNORECASE):
            performance_issues.append('Infinite loop detected')
            
        # Verificar uso excessivo de Sleep
        sleep_count = len(re.findall(r'\bSleep\s*\(', content))
        if sleep_count > 3:
            performance_issues.append(f'Excessive Sleep usage: {sleep_count} calls')
            
        # Verificar loops aninhados
        nested_loops = len(re.findall(r'for\s*\([^}]*for\s*\(', content, re.DOTALL))
        if nested_loops > 0:
            performance_issues.append(f'Nested loops detected: {nested_loops}')
            
        # Verificar uso de arrays dinâmicos
        dynamic_arrays = len(re.findall(r'\bArrayResize\b', content))
        details['dynamic_array_usage'] = dynamic_arrays
        
        details['performance_issues'] = performance_issues
        details['sleep_calls'] = sleep_count
        details['nested_loops'] = nested_loops
        
        # Pontuar performance
        if not performance_issues:
            score += 2.0
            details['performance_rating'] = 'Excellent'
        elif len(performance_issues) <= 2:
            score += 1.0
            details['performance_rating'] = 'Good'
        else:
            score += 0.5
            details['performance_rating'] = 'Poor'
            
        return score, details
    
    def _analyze_technical_indicators(self, content: str) -> tuple:
        """Analisa uso de indicadores técnicos"""
        score = 0.0
        details = {}
        
        indicators = {
            'MA': len(re.findall(r'\biMA\b', content)),
            'RSI': len(re.findall(r'\biRSI\b', content)),
            'MACD': len(re.findall(r'\biMACD\b', content)),
            'Stochastic': len(re.findall(r'\biStochastic\b', content)),
            'Bollinger': len(re.findall(r'\biBands\b', content)),
            'ATR': len(re.findall(r'\biATR\b', content)),
            'SAR': len(re.findall(r'\biSAR\b', content)),
            'ADX': len(re.findall(r'\biADX\b', content)),
            'CCI': len(re.findall(r'\biCCI\b', content)),
            'Williams': len(re.findall(r'\biWPR\b', content))
        }
        
        used_indicators = [name for name, count in indicators.items() if count > 0]
        details['technical_indicators'] = indicators
        details['used_indicators'] = used_indicators
        details['indicator_count'] = len(used_indicators)
        
        # Pontuar baseado no uso de indicadores
        if len(used_indicators) >= 3:
            score += 2.0
            details['indicator_usage'] = 'Rich'
        elif len(used_indicators) >= 2:
            score += 1.5
            details['indicator_usage'] = 'Good'
        elif len(used_indicators) >= 1:
            score += 1.0
            details['indicator_usage'] = 'Basic'
        else:
            details['indicator_usage'] = 'None'
            
        return score, details
    
    def _analyze_logging(self, content: str) -> tuple:
        """Analisa sistema de logging e debug"""
        score = 0.0
        details = {}
        
        logging_functions = {
            'Print': len(re.findall(r'\bPrint\s*\(', content)),
            'Comment': len(re.findall(r'\bComment\s*\(', content)),
            'Alert': len(re.findall(r'\bAlert\s*\(', content)),
            'SendMail': len(re.findall(r'\bSendMail\s*\(', content)),
            'SendNotification': len(re.findall(r'\bSendNotification\s*\(', content))
        }
        
        total_logging = sum(logging_functions.values())
        details['logging_functions'] = logging_functions
        details['total_logging_calls'] = total_logging
        
        if total_logging >= 5:
            score += 2.0
            details['logging_quality'] = 'Excellent'
        elif total_logging >= 3:
            score += 1.5
            details['logging_quality'] = 'Good'
        elif total_logging >= 1:
            score += 1.0
            details['logging_quality'] = 'Basic'
        else:
            details['logging_quality'] = 'None'
            
        return score, details
    
    def _analyze_security(self, content: str) -> tuple:
        """Analisa aspectos de segurança"""
        score = 0.0
        details = {}
        
        security_issues = []
        
        # Verificar hardcoded passwords/keys
        if re.search(r'(password|key|secret)\s*=\s*["\'][^"\']+["\']', content, re.IGNORECASE):
            security_issues.append('Hardcoded credentials detected')
            
        # Verificar validação de entrada
        input_validation = len(re.findall(r'\bIsTradeAllowed\b|\bIsConnected\b|\bIsTradeContextBusy\b', content))
        details['input_validation_checks'] = input_validation
        
        if input_validation >= 2:
            score += 1.5
        elif input_validation >= 1:
            score += 1.0
            
        # Verificar uso seguro de funções de trading
        safe_trading = len(re.findall(r'\bOrderSend\b.*GetLastError|\btrade\.(Buy|Sell).*ResultRetcode', content))
        details['safe_trading_practices'] = safe_trading
        
        if safe_trading > 0:
            score += 1.0
            
        details['security_issues'] = security_issues
        
        if not security_issues:
            score += 1.5
            details['security_rating'] = 'Good'
        else:
            details['security_rating'] = 'Issues Found'
            
        return score, details
    
    def _generate_code_recommendations(self, details: Dict[str, Any]) -> List[str]:
        """Gera recomendações de código"""
        recommendations = []
        
        if details.get('complexity_rating') in ['High', 'Very High']:
            recommendations.append("Refatorar código para reduzir complexidade ciclomática")
            
        if details.get('global_variables', 0) > 10:
            recommendations.append("Reduzir número de variáveis globais")
            
        if details.get('performance_rating') == 'Poor':
            recommendations.append("Otimizar performance removendo gargalos identificados")
            
        if details.get('indicator_usage') == 'None':
            recommendations.append("Considerar uso de indicadores técnicos para melhor análise")
            
        if details.get('logging_quality') in ['None', 'Basic']:
            recommendations.append("Implementar sistema de logging mais robusto")
            
        if details.get('security_issues'):
            recommendations.append("Corrigir issues de segurança identificados")
            
        return recommendations
    
    def _identify_code_issues(self, details: Dict[str, Any]) -> List[str]:
        """Identifica issues críticos de código"""
        issues = []
        
        if details.get('complexity_rating') == 'Very High':
            issues.append("CRÍTICO: Complexidade ciclomática muito alta")
            
        if details.get('performance_issues'):
            for issue in details['performance_issues']:
                issues.append(f"PERFORMANCE: {issue}")
                
        if details.get('security_issues'):
            for issue in details['security_issues']:
                issues.append(f"SEGURANÇA: {issue}")
                
        if details.get('global_variables', 0) > 15:
            issues.append("AVISO: Muitas variáveis globais podem causar conflitos")
            
        return issues

class MetadataQualityAnalyzer:
    """Analisador de Qualidade de Metadados"""
    
    def __init__(self):
        self.quality_thresholds = {
            'excellent': 9.0,
            'good': 7.0,
            'average': 5.0,
            'poor': 3.0
        }
        
    def analyze_metadata_quality(self, analysis: FileAnalysis) -> MetadataQuality:
        """Analisa qualidade dos metadados"""
        completeness = self._calculate_completeness(analysis)
        accuracy = self._calculate_accuracy(analysis)
        consistency = self._calculate_consistency(analysis)
        richness = self._calculate_richness(analysis)
        
        overall_score = (completeness + accuracy + consistency + richness) / 4.0
        
        issues = self._identify_metadata_issues(analysis, completeness, accuracy, consistency, richness)
        recommendations = self._generate_metadata_recommendations(analysis, completeness, accuracy, consistency, richness)
        
        return MetadataQuality(
            completeness=completeness,
            accuracy=accuracy,
            consistency=consistency,
            richness=richness,
            overall_score=overall_score,
            issues=issues,
            recommendations=recommendations
        )
    
    def _calculate_completeness(self, analysis: FileAnalysis) -> float:
        """Calcula completude dos metadados"""
        score = 0.0
        
        # Verificar campos obrigatórios
        if analysis.file_type and analysis.file_type != "Unknown":
            score += 2.0
        if analysis.strategy and analysis.strategy != "Unknown":
            score += 2.0
        if analysis.market and analysis.market != "Multi":
            score += 1.5
        if analysis.timeframe and analysis.timeframe != "Multi":
            score += 1.5
        if analysis.ftmo_status:
            score += 1.5
        if analysis.tags and len(analysis.tags) > 0:
            score += 1.5
        if analysis.components and len(analysis.components) > 0:
            score += 1.0
            
        return min(score, 10.0)
    
    def _calculate_accuracy(self, analysis: FileAnalysis) -> float:
        """Calcula precisão dos metadados"""
        score = 0.0
        
        # Baseado na confiança dos agentes
        total_confidence = sum(agent.confidence for agent in analysis.agent_scores)
        avg_confidence = total_confidence / len(analysis.agent_scores) if analysis.agent_scores else 0
        
        score += avg_confidence * 10.0
        
        return min(score, 10.0)
    
    def _calculate_consistency(self, analysis: FileAnalysis) -> float:
        """Calcula consistência dos metadados"""
        score = 10.0  # Começar com score máximo
        
        # Verificar inconsistências
        if analysis.file_type == "EA" and "EA" not in analysis.filename:
            score -= 1.0
        if analysis.strategy == "Grid_Martingale" and analysis.ftmo_status == "FTMO_READY":
            score -= 2.0  # Inconsistência crítica
        if "FTMO" in analysis.filename and analysis.ftmo_status == "NAO_FTMO":
            score -= 1.5
            
        # Verificar consistência entre agentes
        scores = [agent.score / agent.max_score for agent in analysis.agent_scores]
        if scores:
            score_variance = max(scores) - min(scores)
            if score_variance > 0.5:  # Grande variação entre agentes
                score -= 1.0
                
        return max(score, 0.0)
    
    def _calculate_richness(self, analysis: FileAnalysis) -> float:
        """Calcula riqueza dos metadados"""
        score = 0.0
        
        # Número de tags
        score += min(len(analysis.tags) * 0.5, 3.0)
        
        # Número de componentes
        score += min(len(analysis.components) * 0.3, 2.0)
        
        # Detalhes dos agentes
        total_details = sum(len(agent.details) for agent in analysis.agent_scores)
        score += min(total_details * 0.1, 3.0)
        
        # Recomendações e issues
        score += min(len(analysis.recommendations) * 0.1, 1.0)
        score += min(len(analysis.issues_found) * 0.1, 1.0)
        
        return min(score, 10.0)
    
    def _identify_metadata_issues(self, analysis: FileAnalysis, completeness: float, 
                                 accuracy: float, consistency: float, richness: float) -> List[str]:
        """Identifica issues nos metadados"""
        issues = []
        
        if completeness < 5.0:
            issues.append("Metadados incompletos - campos obrigatórios faltando")
        if accuracy < 5.0:
            issues.append("Baixa confiança na precisão dos metadados")
        if consistency < 5.0:
            issues.append("Inconsistências detectadas nos metadados")
        if richness < 3.0:
            issues.append("Metadados pobres - falta de detalhes")
            
        return issues
    
    def _generate_metadata_recommendations(self, analysis: FileAnalysis, completeness: float,
                                         accuracy: float, consistency: float, richness: float) -> List[str]:
        """Gera recomendações para melhorar metadados"""
        recommendations = []
        
        if completeness < 8.0:
            recommendations.append("Completar campos obrigatórios dos metadados")
        if accuracy < 8.0:
            recommendations.append("Revisar e validar precisão dos metadados")
        if consistency < 8.0:
            recommendations.append("Corrigir inconsistências nos metadados")
        if richness < 6.0:
            recommendations.append("Enriquecer metadados com mais tags e componentes")
            
        return recommendations

class OptimizedMultiAgentSystem:
    """Sistema Multi-Agente Otimizado"""
    
    def __init__(self):
        self.agents = [
            AdvancedArchitectAgent(),
            EnhancedFTMOAgent(),
            PrecisionCodeAnalyst()
        ]
        self.metadata_analyzer = MetadataQualityAnalyzer()
        self.results = []
        self.performance_metrics = {
            'total_files_processed': 0,
            'total_processing_time': 0.0,
            'average_processing_time': 0.0,
            'errors_encountered': 0,
            'quality_distribution': {'excellent': 0, 'good': 0, 'average': 0, 'poor': 0}
        }
        
    def analyze_file(self, file_path: str) -> Optional[FileAnalysis]:
        """Analisa um arquivo com todos os agentes otimizados"""
        start_time = time.time()
        
        try:
            # Ler arquivo
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                
            if not content.strip():
                logger.warning(f"Arquivo vazio: {file_path}")
                return None
                
        except Exception as e:
            logger.error(f"Erro ao ler arquivo {file_path}: {e}")
            self.performance_metrics['errors_encountered'] += 1
            return None
            
        filename = Path(file_path).name
        
        try:
            # Análise básica do arquivo
            file_type = self._detect_file_type(content)
            strategy = self._detect_strategy(content)
            market = self._detect_market(content)
            timeframe = self._detect_timeframe(content)
            ftmo_score, ftmo_status = self._calculate_ftmo_score(content)
            tags = self._extract_tags(content, file_type, strategy, market, timeframe)
            components = self._extract_components(content)
            code_metrics = self._calculate_code_metrics(content)
            risk_assessment = self._assess_risk(content)
            
            # Análise por agentes em paralelo
            agent_scores = []
            with ThreadPoolExecutor(max_workers=3) as executor:
                future_to_agent = {executor.submit(agent.analyze, file_path, content): agent 
                                 for agent in self.agents}
                
                for future in as_completed(future_to_agent):
                    agent = future_to_agent[future]
                    try:
                        score = future.result(timeout=30)  # Timeout de 30 segundos
                        agent_scores.append(score)
                    except Exception as e:
                        logger.error(f"Erro no agente {agent.name} para {filename}: {e}")
                        self.performance_metrics['errors_encountered'] += 1
                        
            # Calcular score unificado
            unified_score = self._calculate_unified_score(agent_scores)
            
            # Consolidar issues e recomendações
            all_issues = []
            all_recommendations = []
            for score in agent_scores:
                all_issues.extend(score.issues)
                all_recommendations.extend(score.recommendations)
                
            processing_time = time.time() - start_time
            
            # Criar análise inicial
            analysis = FileAnalysis(
                filename=filename,
                file_path=file_path,
                file_type=file_type,
                strategy=strategy,
                market=market,
                timeframe=timeframe,
                ftmo_score=ftmo_score,
                ftmo_status=ftmo_status,
                tags=tags,
                components=components,
                agent_scores=agent_scores,
                unified_score=unified_score,
                metadata_quality=None,  # Será calculado a seguir
                processing_time=processing_time,
                issues_found=all_issues,
                recommendations=all_recommendations,
                code_metrics=code_metrics,
                risk_assessment=risk_assessment
            )
            
            # Analisar qualidade dos metadados
            metadata_quality = self.metadata_analyzer.analyze_metadata_quality(analysis)
            analysis.metadata_quality = metadata_quality
            
            # Atualizar métricas de performance
            self._update_performance_metrics(analysis)
            
            return analysis
            
        except Exception as e:
            logger.error(f"Erro na análise de {filename}: {e}")
            self.performance_metrics['errors_encountered'] += 1
            return None
    
    def _detect_file_type(self, content: str) -> str:
        """Detecta o tipo do arquivo com maior precisão"""
        # Verificar Expert Advisor
        if re.search(r'\bOnTick\s*\(', content) and (re.search(r'\bOrderSend\s*\(', content) or re.search(r'\btrade\.(Buy|Sell)', content)):
            return "EA"
        
        # Verificar Indicator
        if re.search(r'\bOnCalculate\s*\(', content) or re.search(r'\bSetIndexBuffer\s*\(', content) or re.search(r'\bIndicatorBuffers\s*\(', content):
            return "Indicator"
        
        # Verificar Script
        if re.search(r'\bOnStart\s*\(', content) and not re.search(r'\bOnTick\s*\(', content):
            return "Script"
        
        # Verificar Pine Script
        if re.search(r'\b(study|strategy|indicator)\s*\(', content):
            return "Pine"
        
        # Verificar Library
        if re.search(r'#property\s+library', content):
            return "Library"
            
        return "Unknown"
    
    def _detect_strategy(self, content: str) -> str:
        """Detecta a estratégia com maior precisão"""
        content_lower = content.lower()
        
        # Estratégias proibidas (prioridade alta)
        if any(word in content_lower for word in ['grid', 'martingale', 'recovery', 'double down']):
            return "Grid_Martingale"
        
        # Scalping
        scalping_indicators = ['scalp', 'm1', 'm5', 'tick', 'second']
        if any(word in content_lower for word in scalping_indicators):
            return "Scalping"
        
        # SMC/ICT
        smc_indicators = ['order block', 'liquidity', 'institutional', 'smc', 'ict', 'fair value gap', 'imbalance']
        if any(word in content_lower for word in smc_indicators):
            return "SMC"
        
        # Trend Following
        trend_indicators = ['trend', 'momentum', 'moving average', 'ema', 'sma', 'macd']
        if any(word in content_lower for word in trend_indicators):
            return "Trend"
        
        # Volume Analysis
        volume_indicators = ['volume', 'obv', 'flow', 'accumulation', 'distribution']
        if any(word in content_lower for word in volume_indicators):
            return "Volume"
        
        # News Trading
        news_indicators = ['news', 'event', 'economic', 'fundamental', 'calendar']
        if any(word in content_lower for word in news_indicators):
            return "News_Trading"
            
        return "Unknown"
    
    def _detect_market(self, content: str) -> str:
        """Detecta o mercado com maior precisão"""
        content_upper = content.upper()
        
        # Ouro
        if any(symbol in content_upper for symbol in ['XAUUSD', 'GOLD', 'GLD']):
            return "XAUUSD"
        
        # Forex majors
        forex_pairs = ['EURUSD', 'GBPUSD', 'USDJPY', 'USDCHF', 'AUDUSD', 'USDCAD', 'NZDUSD']
        for pair in forex_pairs:
            if pair in content_upper:
                return pair
        
        # Índices
        indices = ['SPX500', 'NAS100', 'US30', 'GER30', 'UK100', 'JPN225']
        for index in indices:
            if index in content_upper:
                return index
        
        # Crypto
        crypto_pairs = ['BTCUSD', 'ETHUSD', 'BITCOIN', 'ETHEREUM']
        for crypto in crypto_pairs:
            if crypto in content_upper:
                return "Crypto"
                
        return "Multi"
    
    def _detect_timeframe(self, content: str) -> str:
        """Detecta o timeframe com maior precisão"""
        content_upper = content.upper()
        
        # Timeframes específicos
        timeframes = {
            'M1': ['M1', 'PERIOD_M1', '1MIN', '1 MIN'],
            'M5': ['M5', 'PERIOD_M5', '5MIN', '5 MIN'],
            'M15': ['M15', 'PERIOD_M15', '15MIN', '15 MIN'],
            'M30': ['M30', 'PERIOD_M30', '30MIN', '30 MIN'],
            'H1': ['H1', 'PERIOD_H1', '1H', '1 HOUR'],
            'H4': ['H4', 'PERIOD_H4', '4H', '4 HOUR'],
            'D1': ['D1', 'PERIOD_D1', 'DAILY', '1D'],
            'W1': ['W1', 'PERIOD_W1', 'WEEKLY', '1W'],
            'MN1': ['MN1', 'PERIOD_MN1', 'MONTHLY', '1M']
        }
        
        for tf, patterns in timeframes.items():
            if any(pattern in content_upper for pattern in patterns):
                return tf
                
        return "Multi"
    
    def _calculate_ftmo_score(self, content: str) -> tuple:
        """Calcula score FTMO com maior precisão"""
        score = 0.0
        
        # Verificar estratégias proibidas (penalidade severa)
        prohibited = ['grid', 'martingale', 'recovery', 'double down', 'hedge']
        if any(word in content.lower() for word in prohibited):
            return 0.0, "NAO_FTMO"
        
        # Elementos obrigatórios
        if re.search(r'\b(StopLoss|SL)\b', content, re.IGNORECASE):
            score += 2.5
        if re.search(r'\b(TakeProfit|TP)\b', content, re.IGNORECASE):
            score += 1.5
        if re.search(r'\b(risk|lot.*size)\b', content, re.IGNORECASE):
            score += 2.0
        if re.search(r'\b(drawdown|equity)\b', content, re.IGNORECASE):
            score += 1.5
        if re.search(r'\b(time.*filter|session)\b', content, re.IGNORECASE):
            score += 1.0
        if re.search(r'\b(news.*filter|economic)\b', content, re.IGNORECASE):
            score += 1.5
        
        # Determinar status
        if score >= 8.0:
            status = "FTMO_READY"
        elif score >= 5.0:
            status = "FTMO_POTENTIAL"
        else:
            status = "NAO_FTMO"
            
        return min(score, 10.0), status
    
    def _extract_tags(self, content: str, file_type: str, strategy: str, market: str, timeframe: str) -> List[str]:
        """Extrai tags com maior precisão"""
        tags = []
        
        # Tags básicas
        if file_type != "Unknown":
            tags.append(f"#{file_type}")
        if strategy != "Unknown":
            tags.append(f"#{strategy}")
        if market != "Multi":
            tags.append(f"#{market}")
        if timeframe != "Multi":
            tags.append(f"#{timeframe}")
        
        # Tags específicas baseadas no conteúdo
        content_lower = content.lower()
        
        # Indicadores técnicos
        indicators = {
            'RSI': r'\brsi\b',
            'MACD': r'\bmacd\b',
            'Bollinger': r'\bbollinger\b',
            'Stochastic': r'\bstochastic\b',
            'ATR': r'\batr\b',
            'SAR': r'\bsar\b'
        }
        
        for indicator, pattern in indicators.items():
            if re.search(pattern, content_lower):
                tags.append(f"#{indicator}")
        
        # Características especiais
        if re.search(r'\bnews\b', content_lower):
            tags.append("#News_Trading")
        if re.search(r'\bai\b|\bmachine.*learning\b', content_lower):
            tags.append("#AI")
        if re.search(r'\bbacktest\b', content_lower):
            tags.append("#Backtest")
        if re.search(r'\bmulti.*symbol\b', content_lower):
            tags.append("#Multi_Symbol")
        if re.search(r'\boptimiz\b', content_lower):
            tags.append("#Optimization")
            
        return list(set(tags))  # Remover duplicatas
    
    def _extract_components(self, content: str) -> List[str]:
        """Extrai componentes reutilizáveis"""
        components = []
        
        # Funções de gestão de risco
        if re.search(r'\b(CalculateLotSize|GetLotSize)\b', content):
            components.append("LotSizeCalculator")
        if re.search(r'\b(TrailStop|TrailingStop)\b', content):
            components.append("TrailingStop")
        if re.search(r'\b(BreakEven)\b', content):
            components.append("BreakEven")
        
        # Filtros
        if re.search(r'\b(TimeFilter|SessionFilter)\b', content):
            components.append("TimeFilter")
        if re.search(r'\b(NewsFilter|EconomicFilter)\b', content):
            components.append("NewsFilter")
        if re.search(r'\b(SpreadFilter)\b', content):
            components.append("SpreadFilter")
        
        # Análise técnica
        if re.search(r'\b(OrderBlock|OB)\b', content, re.IGNORECASE):
            components.append("OrderBlockDetector")
        if re.search(r'\b(Liquidity|LQ)\b', content, re.IGNORECASE):
            components.append("LiquidityAnalyzer")
        if re.search(r'\b(VolumeProfile|VP)\b', content, re.IGNORECASE):
            components.append("VolumeProfile")
        
        # Utilitários
        if re.search(r'\b(Logger|Log)\b', content):
            components.append("Logger")
        if re.search(r'\b(Dashboard|Panel)\b', content):
            components.append("Dashboard")
        if re.search(r'\b(Alert|Notification)\b', content):
            components.append("AlertSystem")
            
        return components
    
    def _calculate_code_metrics(self, content: str) -> Dict[str, Any]:
        """Calcula métricas detalhadas do código"""
        lines = content.split('\n')
        
        return {
            'total_lines': len(lines),
            'code_lines': len([line for line in lines if line.strip() and not line.strip().startswith('//')]),
            'comment_lines': len([line for line in lines if line.strip().startswith('//')]),
            'function_count': len(re.findall(r'\b(void|int|double|bool|string|datetime)\s+\w+\s*\(', content)),
            'class_count': len(re.findall(r'\bclass\s+\w+', content)),
            'variable_count': len(re.findall(r'\b(int|double|bool|string|datetime)\s+\w+', content)),
            'complexity_score': len(re.findall(r'\b(if|for|while|switch)\b', content))
        }
    
    def _assess_risk(self, content: str) -> Dict[str, Any]:
        """Avalia riscos do código"""
        risks = {
            'high_risk_patterns': [],
            'medium_risk_patterns': [],
            'low_risk_patterns': [],
            'overall_risk_level': 'Low'
        }
        
        content_lower = content.lower()
        
        # Riscos altos
        high_risk = ['grid', 'martingale', 'recovery', 'no stop loss', 'infinite loop']
        for risk in high_risk:
            if risk in content_lower:
                risks['high_risk_patterns'].append(risk)
        
        # Riscos médios
        medium_risk = ['high leverage', 'news trading', 'scalping', 'hedging']
        for risk in medium_risk:
            if risk in content_lower:
                risks['medium_risk_patterns'].append(risk)
        
        # Riscos baixos
        low_risk = ['manual trading', 'conservative', 'low risk']
        for risk in low_risk:
            if risk in content_lower:
                risks['low_risk_patterns'].append(risk)
        
        # Determinar nível geral de risco
        if risks['high_risk_patterns']:
            risks['overall_risk_level'] = 'High'
        elif risks['medium_risk_patterns']:
            risks['overall_risk_level'] = 'Medium'
        else:
            risks['overall_risk_level'] = 'Low'
            
        return risks
    
    def _calculate_unified_score(self, agent_scores: List[AgentScore]) -> float:
        """Calcula score unificado com pesos otimizados"""
        if not agent_scores:
            return 0.0
        
        # Pesos otimizados para cada agente
        weights = {
            'Advanced_Architect': 0.25,
            'Enhanced_FTMO': 0.45,      # Maior peso para FTMO
            'Precision_Code_Analyst': 0.30
        }
        
        weighted_sum = 0.0
        total_weight = 0.0
        
        for score in agent_scores:
            weight = weights.get(score.agent_name, 0.33)
            normalized_score = (score.score / score.max_score) * 10.0
            weighted_sum += normalized_score * weight * score.confidence
            total_weight += weight * score.confidence
        
        return weighted_sum / total_weight if total_weight > 0 else 0.0
    
    def _update_performance_metrics(self, analysis: FileAnalysis):
        """Atualiza métricas de performance"""
        self.performance_metrics['total_files_processed'] += 1
        self.performance_metrics['total_processing_time'] += analysis.processing_time
        self.performance_metrics['average_processing_time'] = (
            self.performance_metrics['total_processing_time'] / 
            self.performance_metrics['total_files_processed']
        )
        
        # Classificar qualidade
        overall_score = analysis.metadata_quality.overall_score if analysis.metadata_quality else 0
        if overall_score >= 9.0:
            self.performance_metrics['quality_distribution']['excellent'] += 1
        elif overall_score >= 7.0:
            self.performance_metrics['quality_distribution']['good'] += 1
        elif overall_score >= 5.0:
            self.performance_metrics['quality_distribution']['average'] += 1
        else:
            self.performance_metrics['quality_distribution']['poor'] += 1
    
    def analyze_directory(self, directory_path: str) -> List[FileAnalysis]:
        """Analisa todos os arquivos MQ4/MQ5 em um diretório"""
        results = []
        
        # Encontrar todos os arquivos MQ4/MQ5
        file_patterns = ['*.mq4', '*.mq5', '*.mqh']
        files_to_analyze = []
        
        for pattern in file_patterns:
            files_to_analyze.extend(Path(directory_path).glob(pattern))
        
        logger.info(f"Encontrados {len(files_to_analyze)} arquivos para análise")
        
        # Analisar arquivos
        for file_path in files_to_analyze:
            logger.info(f"Analisando: {file_path.name}")
            analysis = self.analyze_file(str(file_path))
            if analysis:
                results.append(analysis)
                self.results.append(analysis)
        
        return results
    
    def generate_report(self, results: List[FileAnalysis]) -> Dict[str, Any]:
        """Gera relatório detalhado da análise"""
        if not results:
            return {"error": "Nenhum resultado para gerar relatório"}
        
        # Estatísticas gerais
        total_files = len(results)
        avg_unified_score = sum(r.unified_score for r in results) / total_files
        avg_metadata_quality = sum(r.metadata_quality.overall_score for r in results if r.metadata_quality) / total_files
        
        # Distribuição por tipo
        type_distribution = {}
        for result in results:
            type_distribution[result.file_type] = type_distribution.get(result.file_type, 0) + 1
        
        # Distribuição por estratégia
        strategy_distribution = {}
        for result in results:
            strategy_distribution[result.strategy] = strategy_distribution.get(result.strategy, 0) + 1
        
        # Top arquivos por score
        top_files = sorted(results, key=lambda x: x.unified_score, reverse=True)[:10]
        
        # Arquivos FTMO Ready
        ftmo_ready = [r for r in results if r.ftmo_status == "FTMO_READY"]
        
        # Issues mais comuns
        all_issues = []
        for result in results:
            all_issues.extend(result.issues_found)
        
        issue_frequency = {}
        for issue in all_issues:
            issue_frequency[issue] = issue_frequency.get(issue, 0) + 1
        
        common_issues = sorted(issue_frequency.items(), key=lambda x: x[1], reverse=True)[:10]
        
        # Recomendações mais comuns
        all_recommendations = []
        for result in results:
            all_recommendations.extend(result.recommendations)
        
        rec_frequency = {}
        for rec in all_recommendations:
            rec_frequency[rec] = rec_frequency.get(rec, 0) + 1
        
        common_recommendations = sorted(rec_frequency.items(), key=lambda x: x[1], reverse=True)[:10]
        
        return {
            "summary": {
                "total_files": total_files,
                "average_unified_score": round(avg_unified_score, 2),
                "average_metadata_quality": round(avg_metadata_quality, 2),
                "ftmo_ready_count": len(ftmo_ready),
                "ftmo_ready_percentage": round(len(ftmo_ready) / total_files * 100, 1)
            },
            "distributions": {
                "by_type": type_distribution,
                "by_strategy": strategy_distribution,
                "quality_distribution": self.performance_metrics['quality_distribution']
            },
            "top_performers": [
                {
                    "filename": r.filename,
                    "unified_score": round(r.unified_score, 2),
                    "ftmo_status": r.ftmo_status,
                    "strategy": r.strategy
                } for r in top_files
            ],
            "ftmo_ready_files": [
                {
                    "filename": r.filename,
                    "unified_score": round(r.unified_score, 2),
                    "ftmo_score": round(r.ftmo_score, 2)
                } for r in ftmo_ready
            ],
            "common_issues": common_issues,
            "common_recommendations": common_recommendations,
            "performance_metrics": self.performance_metrics,
            "timestamp": datetime.datetime.now().isoformat()
        }
    
    def export_results(self, results: List[FileAnalysis], output_dir: str):
        """Exporta resultados em múltiplos formatos"""
        output_path = Path(output_dir)
        output_path.mkdir(exist_ok=True)
        
        # Exportar JSON detalhado
        json_data = {
            "metadata": {
                "generated_at": datetime.datetime.now().isoformat(),
                "total_files": len(results),
                "system_version": "4.0"
            },
            "results": [asdict(result) for result in results],
            "report": self.generate_report(results)
        }
        
        with open(output_path / "analise_completa.json", 'w', encoding='utf-8') as f:
            json.dump(json_data, f, indent=2, ensure_ascii=False)
        
        # Exportar relatório em Markdown
        report = self.generate_report(results)
        markdown_content = self._generate_markdown_report(report)
        
        with open(output_path / "RELATORIO_ANALISE.md", 'w', encoding='utf-8') as f:
            f.write(markdown_content)
        
        logger.info(f"Resultados exportados para: {output_path}")
    
    def _generate_markdown_report(self, report: Dict[str, Any]) -> str:
        """Gera relatório em formato Markdown"""
        md = f"""# Relatório de Análise de Metadados - Sistema Multi-Agente v4.0

**Gerado em:** {report['timestamp']}

## 📊 Resumo Executivo

- **Total de Arquivos:** {report['summary']['total_files']}
- **Score Unificado Médio:** {report['summary']['average_unified_score']}/10.0
- **Qualidade de Metadados Média:** {report['summary']['average_metadata_quality']}/10.0
- **Arquivos FTMO Ready:** {report['summary']['ftmo_ready_count']} ({report['summary']['ftmo_ready_percentage']}%)

## 📈 Distribuições

### Por Tipo de Arquivo
"""
        
        for file_type, count in report['distributions']['by_type'].items():
            md += f"- **{file_type}:** {count} arquivos\n"
        
        md += "\n### Por Estratégia\n"
        for strategy, count in report['distributions']['by_strategy'].items():
            md += f"- **{strategy}:** {count} arquivos\n"
        
        md += "\n## 🏆 Top 10 Arquivos por Performance\n\n"
        for i, file_info in enumerate(report['top_performers'], 1):
            md += f"{i}. **{file_info['filename']}** - Score: {file_info['unified_score']}/10.0 - {file_info['ftmo_status']} - {file_info['strategy']}\n"
        
        if report['ftmo_ready_files']:
            md += "\n## ✅ Arquivos FTMO Ready\n\n"
            for file_info in report['ftmo_ready_files']:
                md += f"- **{file_info['filename']}** - Score Unificado: {file_info['unified_score']}/10.0 - Score FTMO: {file_info['ftmo_score']}/10.0\n"
        
        md += "\n## ⚠️ Issues Mais Comuns\n\n"
        for issue, count in report['common_issues']:
            md += f"- **{issue}** ({count} ocorrências)\n"
        
        md += "\n## 💡 Recomendações Mais Comuns\n\n"
        for rec, count in report['common_recommendations']:
            md += f"- **{rec}** ({count} ocorrências)\n"
        
        md += f"\n## 📊 Métricas de Performance\n\n"
        md += f"- **Tempo Total de Processamento:** {report['performance_metrics']['total_processing_time']:.2f}s\n"
        md += f"- **Tempo Médio por Arquivo:** {report['performance_metrics']['average_processing_time']:.2f}s\n"
        md += f"- **Erros Encontrados:** {report['performance_metrics']['errors_encountered']}\n"
        
        return md

def main():
    """Função principal para execução em modo console"""
    print("🤖 Sistema Multi-Agente de Análise de Metadados v4.0")
    print("=" * 60)
    
    # Configurar diretório de entrada
    input_dir = "Input_Expandido"
    if not os.path.exists(input_dir):
        print(f"❌ Diretório {input_dir} não encontrado!")
        return
    
    # Inicializar sistema
    system = OptimizedMultiAgentSystem()
    
    print(f"📁 Analisando arquivos em: {input_dir}")
    print("⏳ Iniciando análise...\n")
    
    start_time = time.time()
    
    # Analisar diretório
    results = system.analyze_directory(input_dir)
    
    total_time = time.time() - start_time
    
    print(f"\n✅ Análise concluída em {total_time:.2f}s")
    print(f"📊 {len(results)} arquivos processados")
    
    if results:
        # Gerar e exibir relatório
        report = system.generate_report(results)
        
        print("\n" + "=" * 60)
        print("📋 RELATÓRIO RESUMIDO")
        print("=" * 60)
        print(f"Score Unificado Médio: {report['summary']['average_unified_score']}/10.0")
        print(f"Qualidade de Metadados: {report['summary']['average_metadata_quality']}/10.0")
        print(f"Arquivos FTMO Ready: {report['summary']['ftmo_ready_count']} ({report['summary']['ftmo_ready_percentage']}%)")
        
        # Exportar resultados
        system.export_results(results, "Output_Analise")
        print(f"\n💾 Resultados exportados para: Output_Analise/")
        
        # Mostrar top 5 arquivos
        print("\n🏆 TOP 5 ARQUIVOS:")
        for i, file_info in enumerate(report['top_performers'][:5], 1):
            print(f"{i}. {file_info['filename']} - {file_info['unified_score']}/10.0")
    
    print("\n🎯 Análise completa! Verifique os arquivos de saída para detalhes.")

if __name__ == "__main__":
    main()