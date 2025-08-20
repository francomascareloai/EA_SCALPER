#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Sistema Multi-Agente com Interface Gráfica em Tempo Real
Classificador Trading v4.0 - Análise Crítica e Otimização Contínua
"""

import os
import sys
import json
import time
import threading
import tkinter as tk
from tkinter import ttk, scrolledtext, messagebox
from pathlib import Path
import datetime
from dataclasses import dataclass, asdict
from typing import List, Dict, Any, Optional
import queue
import re
from concurrent.futures import ThreadPoolExecutor, as_completed

# Configuração de logging
import logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('sistema_multi_agente.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

@dataclass
class AgentScore:
    """Score de um agente específico"""
    agent_name: str
    score: float
    max_score: float
    details: Dict[str, Any]
    recommendations: List[str]
    issues: List[str]
    timestamp: str

@dataclass
class FileAnalysis:
    """Análise completa de um arquivo"""
    filename: str
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
    processing_time: float
    metadata_quality: float
    issues_found: List[str]
    recommendations: List[str]

class ArchitectAgent:
    """Agente Arquiteto - Avalia estrutura e padrões de código"""
    
    def __init__(self):
        self.name = "Architect"
        self.max_score = 10.0
        
    def analyze(self, file_path: str, content: str) -> AgentScore:
        """Analisa a arquitetura do código"""
        score = 0.0
        details = {}
        recommendations = []
        issues = []
        
        # Análise de estrutura
        if "class" in content:
            score += 2.0
            details["oop_usage"] = True
        else:
            recommendations.append("Considerar uso de programação orientada a objetos")
            
        # Análise de funções
        function_count = len(re.findall(r'\b(void|int|double|bool|string)\s+\w+\s*\(', content))
        if function_count >= 5:
            score += 1.5
            details["function_count"] = function_count
        elif function_count >= 3:
            score += 1.0
            details["function_count"] = function_count
        else:
            issues.append("Poucas funções definidas - código pode estar monolítico")
            
        # Análise de comentários
        comment_lines = len(re.findall(r'//.*|/\*.*?\*/', content, re.DOTALL))
        total_lines = len(content.split('\n'))
        comment_ratio = comment_lines / max(total_lines, 1)
        
        if comment_ratio >= 0.15:
            score += 1.5
            details["comment_ratio"] = comment_ratio
        elif comment_ratio >= 0.10:
            score += 1.0
            details["comment_ratio"] = comment_ratio
        else:
            recommendations.append("Adicionar mais comentários explicativos")
            
        # Análise de constantes e enums
        if "#define" in content or "enum" in content:
            score += 1.0
            details["uses_constants"] = True
        else:
            recommendations.append("Usar constantes e enums para valores fixos")
            
        # Análise de includes
        include_count = len(re.findall(r'#include', content))
        if include_count >= 3:
            score += 1.0
            details["include_count"] = include_count
        elif include_count >= 1:
            score += 0.5
            details["include_count"] = include_count
            
        # Análise de error handling
        if "GetLastError" in content or "try" in content:
            score += 1.5
            details["error_handling"] = True
        else:
            issues.append("Falta tratamento de erros")
            
        # Análise de modularidade
        if function_count >= 8 and "class" in content:
            score += 1.5
            details["modularity"] = "High"
        elif function_count >= 5:
            score += 1.0
            details["modularity"] = "Medium"
        else:
            details["modularity"] = "Low"
            recommendations.append("Melhorar modularidade do código")
            
        # Normalizar score
        score = min(score, self.max_score)
        
        return AgentScore(
            agent_name=self.name,
            score=score,
            max_score=self.max_score,
            details=details,
            recommendations=recommendations,
            issues=issues,
            timestamp=datetime.datetime.now().isoformat()
        )

class FTMOTraderAgent:
    """Agente FTMO Trader - Avalia conformidade FTMO e gestão de risco"""
    
    def __init__(self):
        self.name = "FTMO_Trader"
        self.max_score = 10.0
        
    def analyze(self, file_path: str, content: str) -> AgentScore:
        """Analisa conformidade FTMO"""
        score = 0.0
        details = {}
        recommendations = []
        issues = []
        
        # Verificar estratégias proibidas
        prohibited_patterns = [
            r'\bgrid\b', r'\bmartingale\b', r'\brecovery\b',
            r'\bdouble\s*down\b', r'\bhedge\b', r'\barbitrage\b'
        ]
        
        has_prohibited = False
        for pattern in prohibited_patterns:
            if re.search(pattern, content, re.IGNORECASE):
                has_prohibited = True
                issues.append(f"Estratégia proibida detectada: {pattern}")
                break
                
        if not has_prohibited:
            score += 2.5
            details["prohibited_strategies"] = False
        else:
            details["prohibited_strategies"] = True
            
        # Verificar Stop Loss obrigatório
        sl_patterns = [
            r'\bStopLoss\b', r'\bSL\b', r'\bstop.*loss\b',
            r'\bOrderModify\b.*stop', r'\bPositionModify\b.*sl'
        ]
        
        has_sl = any(re.search(pattern, content, re.IGNORECASE) for pattern in sl_patterns)
        if has_sl:
            score += 2.0
            details["stop_loss"] = True
        else:
            issues.append("Stop Loss obrigatório não encontrado")
            details["stop_loss"] = False
            
        # Verificar gestão de risco
        risk_patterns = [
            r'\brisk\b', r'\blot.*size\b', r'\bposition.*size\b',
            r'\bmoney.*management\b', r'\bdrawdown\b'
        ]
        
        risk_score = sum(1 for pattern in risk_patterns 
                        if re.search(pattern, content, re.IGNORECASE))
        
        if risk_score >= 3:
            score += 2.0
            details["risk_management"] = "Good"
        elif risk_score >= 2:
            score += 1.0
            details["risk_management"] = "Basic"
        else:
            issues.append("Gestão de risco inadequada")
            details["risk_management"] = "Poor"
            
        # Verificar Take Profit
        tp_patterns = [
            r'\bTakeProfit\b', r'\bTP\b', r'\btake.*profit\b'
        ]
        
        has_tp = any(re.search(pattern, content, re.IGNORECASE) for pattern in tp_patterns)
        if has_tp:
            score += 1.0
            details["take_profit"] = True
        else:
            recommendations.append("Adicionar Take Profit para melhor R/R")
            details["take_profit"] = False
            
        # Verificar filtros de tempo/sessão
        time_filters = [
            r'\btime\b.*filter', r'\bsession\b', r'\bhour\b.*trade',
            r'\bTimeHour\b', r'\bTimeCurrent\b'
        ]
        
        has_time_filter = any(re.search(pattern, content, re.IGNORECASE) 
                             for pattern in time_filters)
        if has_time_filter:
            score += 1.0
            details["time_filters"] = True
        else:
            recommendations.append("Adicionar filtros de horário de negociação")
            details["time_filters"] = False
            
        # Verificar filtros de notícias
        news_patterns = [
            r'\bnews\b', r'\bevent\b', r'\beconomic\b',
            r'\bfundamental\b', r'\bvolatility\b.*filter'
        ]
        
        has_news_filter = any(re.search(pattern, content, re.IGNORECASE) 
                             for pattern in news_patterns)
        if has_news_filter:
            score += 1.5
            details["news_filters"] = True
        else:
            recommendations.append("Adicionar filtro de notícias")
            details["news_filters"] = False
            
        # Normalizar score
        score = min(score, self.max_score)
        
        # Se tem estratégias proibidas, score máximo é 2.0
        if has_prohibited:
            score = min(score, 2.0)
            details["ftmo_compliant"] = False
        else:
            details["ftmo_compliant"] = True
            
        return AgentScore(
            agent_name=self.name,
            score=score,
            max_score=self.max_score,
            details=details,
            recommendations=recommendations,
            issues=issues,
            timestamp=datetime.datetime.now().isoformat()
        )

class CodeAnalystAgent:
    """Agente Analista de Código - Avalia qualidade técnica"""
    
    def __init__(self):
        self.name = "Code_Analyst"
        self.max_score = 10.0
        
    def analyze(self, file_path: str, content: str) -> AgentScore:
        """Analisa qualidade técnica do código"""
        score = 0.0
        details = {}
        recommendations = []
        issues = []
        
        # Análise de complexidade
        lines = content.split('\n')
        total_lines = len([line for line in lines if line.strip()])
        
        if total_lines < 50:
            details["complexity"] = "Low"
            score += 1.0
        elif total_lines < 200:
            details["complexity"] = "Medium"
            score += 1.5
        elif total_lines < 500:
            details["complexity"] = "High"
            score += 1.0
        else:
            details["complexity"] = "Very High"
            issues.append("Código muito complexo - considerar refatoração")
            
        # Análise de variáveis globais
        global_vars = len(re.findall(r'^\s*(int|double|bool|string)\s+\w+', content, re.MULTILINE))
        if global_vars <= 5:
            score += 1.5
            details["global_variables"] = global_vars
        elif global_vars <= 10:
            score += 1.0
            details["global_variables"] = global_vars
        else:
            issues.append("Muitas variáveis globais")
            details["global_variables"] = global_vars
            
        # Análise de magic numbers
        magic_numbers = len(re.findall(r'\b\d+\.\d+\b|\b[1-9]\d+\b', content))
        if magic_numbers <= 10:
            score += 1.0
            details["magic_numbers"] = magic_numbers
        else:
            recommendations.append("Substituir números mágicos por constantes")
            details["magic_numbers"] = magic_numbers
            
        # Análise de performance
        performance_issues = []
        if "while(true)" in content:
            performance_issues.append("Loop infinito detectado")
        if content.count("for(") > 5:
            performance_issues.append("Muitos loops - verificar performance")
        if "Sleep(" in content:
            performance_issues.append("Uso de Sleep pode afetar performance")
            
        if not performance_issues:
            score += 1.5
            details["performance_issues"] = []
        else:
            score += 0.5
            details["performance_issues"] = performance_issues
            issues.extend(performance_issues)
            
        # Análise de boas práticas
        good_practices = 0
        
        if "OnInit" in content:
            good_practices += 1
        if "OnDeinit" in content:
            good_practices += 1
        if "input" in content:
            good_practices += 1
        if "extern" in content or "input" in content:
            good_practices += 1
            
        score += min(good_practices * 0.5, 2.0)
        details["good_practices_count"] = good_practices
        
        # Análise de indicadores técnicos
        indicators = []
        indicator_patterns = [
            r'\biMA\b', r'\biRSI\b', r'\biMACD\b', r'\biStochastic\b',
            r'\biBands\b', r'\biATR\b', r'\biSAR\b', r'\biADX\b'
        ]
        
        for pattern in indicator_patterns:
            if re.search(pattern, content):
                indicators.append(pattern.strip('\\b'))
                
        if len(indicators) >= 2:
            score += 1.5
            details["technical_indicators"] = indicators
        elif len(indicators) >= 1:
            score += 1.0
            details["technical_indicators"] = indicators
        else:
            recommendations.append("Considerar uso de indicadores técnicos")
            details["technical_indicators"] = []
            
        # Análise de logging
        if "Print(" in content or "Comment(" in content:
            score += 1.0
            details["has_logging"] = True
        else:
            recommendations.append("Adicionar logging para debug")
            details["has_logging"] = False
            
        # Normalizar score
        score = min(score, self.max_score)
        
        return AgentScore(
            agent_name=self.name,
            score=score,
            max_score=self.max_score,
            details=details,
            recommendations=recommendations,
            issues=issues,
            timestamp=datetime.datetime.now().isoformat()
        )

class MultiAgentSystem:
    """Sistema Multi-Agente para análise de códigos"""
    
    def __init__(self):
        self.agents = [
            ArchitectAgent(),
            FTMOTraderAgent(),
            CodeAnalystAgent()
        ]
        self.results = []
        
    def analyze_file(self, file_path: str) -> FileAnalysis:
        """Analisa um arquivo com todos os agentes"""
        start_time = time.time()
        
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except Exception as e:
            logger.error(f"Erro ao ler arquivo {file_path}: {e}")
            return None
            
        filename = Path(file_path).name
        
        # Análise básica do arquivo
        file_type = self._detect_file_type(content)
        strategy = self._detect_strategy(content)
        market = self._detect_market(content)
        timeframe = self._detect_timeframe(content)
        ftmo_score, ftmo_status = self._calculate_ftmo_score(content)
        tags = self._extract_tags(content, file_type, strategy, market, timeframe)
        components = self._extract_components(content)
        
        # Análise por agentes
        agent_scores = []
        for agent in self.agents:
            try:
                score = agent.analyze(file_path, content)
                agent_scores.append(score)
            except Exception as e:
                logger.error(f"Erro no agente {agent.name} para {filename}: {e}")
                
        # Calcular score unificado
        unified_score = self._calculate_unified_score(agent_scores)
        
        # Calcular qualidade dos metadados
        metadata_quality = self._calculate_metadata_quality(agent_scores, tags, components)
        
        # Consolidar issues e recomendações
        all_issues = []
        all_recommendations = []
        for score in agent_scores:
            all_issues.extend(score.issues)
            all_recommendations.extend(score.recommendations)
            
        processing_time = time.time() - start_time
        
        analysis = FileAnalysis(
            filename=filename,
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
            processing_time=processing_time,
            metadata_quality=metadata_quality,
            issues_found=all_issues,
            recommendations=all_recommendations
        )
        
        return analysis
    
    def _detect_file_type(self, content: str) -> str:
        """Detecta o tipo do arquivo"""
        if "OnTick" in content and ("OrderSend" in content or "trade.Buy" in content):
            return "EA"
        elif "OnCalculate" in content or "SetIndexBuffer" in content:
            return "Indicator"
        elif "OnStart" in content:
            return "Script"
        elif "study(" in content or "strategy(" in content:
            return "Pine"
        else:
            return "Unknown"
    
    def _detect_strategy(self, content: str) -> str:
        """Detecta a estratégia do código"""
        content_lower = content.lower()
        
        if any(word in content_lower for word in ['grid', 'martingale', 'recovery']):
            return "Grid_Martingale"
        elif any(word in content_lower for word in ['scalp', 'm1', 'm5']):
            return "Scalping"
        elif any(word in content_lower for word in ['order_block', 'liquidity', 'institutional']):
            return "SMC"
        elif any(word in content_lower for word in ['trend', 'momentum', 'ma']):
            return "Trend"
        elif any(word in content_lower for word in ['volume', 'obv', 'flow']):
            return "Volume"
        else:
            return "Unknown"
    
    def _detect_market(self, content: str) -> str:
        """Detecta o mercado do código"""
        content_upper = content.upper()
        
        if "XAUUSD" in content_upper or "GOLD" in content_upper:
            return "XAUUSD"
        elif any(pair in content_upper for pair in ['EURUSD', 'GBPUSD', 'USDJPY', 'USDCHF']):
            return "Forex"
        elif any(index in content_upper for index in ['SPX', 'NAS', 'DOW', 'DAX']):
            return "Indices"
        elif any(crypto in content_upper for crypto in ['BTC', 'ETH', 'CRYPTO']):
            return "Crypto"
        else:
            return "Multi"
    
    def _detect_timeframe(self, content: str) -> str:
        """Detecta o timeframe do código"""
        timeframes = ['M1', 'M5', 'M15', 'M30', 'H1', 'H4', 'D1', 'W1', 'MN1']
        
        for tf in timeframes:
            if tf in content or f"PERIOD_{tf}" in content:
                return tf
                
        return "Multi"
    
    def _calculate_ftmo_score(self, content: str) -> tuple:
        """Calcula score FTMO e status"""
        score = 0.0
        
        # Verificar estratégias proibidas
        prohibited = ['grid', 'martingale', 'recovery', 'hedge']
        if any(word in content.lower() for word in prohibited):
            return 0.0, "PROIBIDO_FTMO"
            
        # Verificar elementos FTMO
        if "StopLoss" in content or "SL" in content:
            score += 3.0
        if "TakeProfit" in content or "TP" in content:
            score += 2.0
        if "risk" in content.lower():
            score += 2.0
        if "drawdown" in content.lower():
            score += 1.5
        if "news" in content.lower():
            score += 1.5
            
        if score >= 7.0:
            return score, "FTMO_READY"
        elif score >= 4.0:
            return score, "PARCIAL_FTMO"
        else:
            return score, "NAO_FTMO"
    
    def _extract_tags(self, content: str, file_type: str, strategy: str, market: str, timeframe: str) -> List[str]:
        """Extrai tags do código"""
        tags = [f"#{file_type}", f"#{strategy}", f"#{market}", f"#{timeframe}"]
        
        # Tags adicionais
        if "news" in content.lower():
            tags.append("#News_Trading")
        if "ai" in content.lower() or "neural" in content.lower():
            tags.append("#AI")
        if "backtest" in content.lower():
            tags.append("#Backtest")
        if "alert" in content.lower():
            tags.append("#Alert")
            
        return tags
    
    def _extract_components(self, content: str) -> List[str]:
        """Extrai componentes úteis do código"""
        components = []
        
        if "StopLoss" in content:
            components.append("Stop Loss Management")
        if "TakeProfit" in content:
            components.append("Take Profit Management")
        if "trail" in content.lower():
            components.append("Trailing Stop")
        if "news" in content.lower():
            components.append("News Filter")
        if "time" in content.lower() and "filter" in content.lower():
            components.append("Time Filter")
        if "volume" in content.lower():
            components.append("Volume Analysis")
        if "rsi" in content.lower():
            components.append("RSI Indicator")
        if "macd" in content.lower():
            components.append("MACD Indicator")
            
        return components
    
    def _calculate_unified_score(self, agent_scores: List[AgentScore]) -> float:
        """Calcula score unificado dos agentes"""
        if not agent_scores:
            return 0.0
            
        # Pesos dos agentes
        weights = {
            "Architect": 0.3,
            "FTMO_Trader": 0.4,
            "Code_Analyst": 0.3
        }
        
        total_score = 0.0
        total_weight = 0.0
        
        for score in agent_scores:
            weight = weights.get(score.agent_name, 0.33)
            normalized_score = (score.score / score.max_score) * 10.0
            total_score += normalized_score * weight
            total_weight += weight
            
        return total_score / total_weight if total_weight > 0 else 0.0
    
    def _calculate_metadata_quality(self, agent_scores: List[AgentScore], tags: List[str], components: List[str]) -> float:
        """Calcula qualidade dos metadados"""
        quality = 0.0
        
        # Qualidade baseada nos scores dos agentes
        avg_score = sum(score.score / score.max_score for score in agent_scores) / len(agent_scores) if agent_scores else 0
        quality += avg_score * 5.0
        
        # Qualidade baseada nas tags
        quality += min(len(tags) * 0.5, 2.5)
        
        # Qualidade baseada nos componentes
        quality += min(len(components) * 0.3, 2.5)
        
        return min(quality, 10.0)

class RealTimeInterface:
    """Interface gráfica em tempo real"""
    
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Sistema Multi-Agente - Análise em Tempo Real")
        self.root.geometry("1400x900")
        self.root.configure(bg='#2b2b2b')
        
        self.multi_agent = MultiAgentSystem()
        self.analysis_queue = queue.Queue()
        self.is_running = False
        self.current_analysis = []
        
        self.setup_ui()
        self.setup_styles()
        
    def setup_styles(self):
        """Configura estilos da interface"""
        style = ttk.Style()
        style.theme_use('clam')
        
        # Configurar cores escuras
        style.configure('Dark.TFrame', background='#2b2b2b')
        style.configure('Dark.TLabel', background='#2b2b2b', foreground='white')
        style.configure('Dark.TButton', background='#404040', foreground='white')
        style.configure('Dark.Treeview', background='#3b3b3b', foreground='white', fieldbackground='#3b3b3b')
        style.configure('Dark.Treeview.Heading', background='#404040', foreground='white')
        
    def setup_ui(self):
        """Configura a interface do usuário"""
        # Frame principal
        main_frame = ttk.Frame(self.root, style='Dark.TFrame')
        main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Título
        title_label = ttk.Label(main_frame, text="🤖 Sistema Multi-Agente - Classificador Trading v4.0", 
                               font=('Arial', 16, 'bold'), style='Dark.TLabel')
        title_label.pack(pady=(0, 10))
        
        # Frame de controles
        control_frame = ttk.Frame(main_frame, style='Dark.TFrame')
        control_frame.pack(fill=tk.X, pady=(0, 10))
        
        # Botões de controle
        self.start_button = ttk.Button(control_frame, text="🚀 Iniciar Análise", 
                                      command=self.start_analysis, style='Dark.TButton')
        self.start_button.pack(side=tk.LEFT, padx=(0, 10))
        
        self.stop_button = ttk.Button(control_frame, text="⏹️ Parar", 
                                     command=self.stop_analysis, style='Dark.TButton', state='disabled')
        self.stop_button.pack(side=tk.LEFT, padx=(0, 10))
        
        self.export_button = ttk.Button(control_frame, text="📊 Exportar Relatório", 
                                       command=self.export_report, style='Dark.TButton')
        self.export_button.pack(side=tk.LEFT, padx=(0, 10))
        
        # Status
        self.status_label = ttk.Label(control_frame, text="Status: Aguardando...", 
                                     style='Dark.TLabel')
        self.status_label.pack(side=tk.RIGHT)
        
        # Notebook para abas
        self.notebook = ttk.Notebook(main_frame)
        self.notebook.pack(fill=tk.BOTH, expand=True)
        
        # Aba de análise em tempo real
        self.setup_realtime_tab()
        
        # Aba de estatísticas
        self.setup_stats_tab()
        
        # Aba de logs
        self.setup_logs_tab()
        
        # Aba de configurações
        self.setup_config_tab()
        
    def setup_realtime_tab(self):
        """Configura aba de análise em tempo real"""
        realtime_frame = ttk.Frame(self.notebook, style='Dark.TFrame')
        self.notebook.add(realtime_frame, text="📈 Análise em Tempo Real")
        
        # Frame de métricas
        metrics_frame = ttk.LabelFrame(realtime_frame, text="Métricas Gerais", style='Dark.TFrame')
        metrics_frame.pack(fill=tk.X, padx=5, pady=5)
        
        # Métricas em linha
        metrics_row = ttk.Frame(metrics_frame, style='Dark.TFrame')
        metrics_row.pack(fill=tk.X, padx=10, pady=10)
        
        self.total_files_label = ttk.Label(metrics_row, text="Arquivos: 0", style='Dark.TLabel')
        self.total_files_label.pack(side=tk.LEFT, padx=(0, 20))
        
        self.avg_score_label = ttk.Label(metrics_row, text="Score Médio: 0.0", style='Dark.TLabel')
        self.avg_score_label.pack(side=tk.LEFT, padx=(0, 20))
        
        self.ftmo_ready_label = ttk.Label(metrics_row, text="FTMO Ready: 0", style='Dark.TLabel')
        self.ftmo_ready_label.pack(side=tk.LEFT, padx=(0, 20))
        
        self.processing_time_label = ttk.Label(metrics_row, text="Tempo: 0.0s", style='Dark.TLabel')
        self.processing_time_label.pack(side=tk.LEFT)
        
        # Tabela de resultados
        table_frame = ttk.LabelFrame(realtime_frame, text="Resultados da Análise", style='Dark.TFrame')
        table_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Treeview com scrollbar
        tree_frame = ttk.Frame(table_frame, style='Dark.TFrame')
        tree_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        columns = ('Arquivo', 'Tipo', 'Estratégia', 'Score Unificado', 'Architect', 'FTMO_Trader', 'Code_Analyst', 'FTMO Status', 'Qualidade Metadata')
        self.results_tree = ttk.Treeview(tree_frame, columns=columns, show='headings', style='Dark.Treeview')
        
        # Configurar colunas
        for col in columns:
            self.results_tree.heading(col, text=col)
            self.results_tree.column(col, width=120, anchor='center')
            
        # Scrollbars
        v_scrollbar = ttk.Scrollbar(tree_frame, orient=tk.VERTICAL, command=self.results_tree.yview)
        h_scrollbar = ttk.Scrollbar(tree_frame, orient=tk.HORIZONTAL, command=self.results_tree.xview)
        self.results_tree.configure(yscrollcommand=v_scrollbar.set, xscrollcommand=h_scrollbar.set)
        
        # Pack scrollbars e treeview
        self.results_tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        v_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        h_scrollbar.pack(side=tk.BOTTOM, fill=tk.X)
        
    def setup_stats_tab(self):
        """Configura aba de estatísticas"""
        stats_frame = ttk.Frame(self.notebook, style='Dark.TFrame')
        self.notebook.add(stats_frame, text="📊 Estatísticas")
        
        # Texto de estatísticas
        self.stats_text = scrolledtext.ScrolledText(stats_frame, bg='#3b3b3b', fg='white', 
                                                   font=('Consolas', 10))
        self.stats_text.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
    def setup_logs_tab(self):
        """Configura aba de logs"""
        logs_frame = ttk.Frame(self.notebook, style='Dark.TFrame')
        self.notebook.add(logs_frame, text="📝 Logs")
        
        # Texto de logs
        self.logs_text = scrolledtext.ScrolledText(logs_frame, bg='#3b3b3b', fg='white', 
                                                  font=('Consolas', 9))
        self.logs_text.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
    def setup_config_tab(self):
        """Configura aba de configurações"""
        config_frame = ttk.Frame(self.notebook, style='Dark.TFrame')
        self.notebook.add(config_frame, text="⚙️ Configurações")
        
        # Configurações de análise
        analysis_config = ttk.LabelFrame(config_frame, text="Configurações de Análise", style='Dark.TFrame')
        analysis_config.pack(fill=tk.X, padx=10, pady=10)
        
        # Intervalo de atualização
        ttk.Label(analysis_config, text="Intervalo de Atualização (s):", style='Dark.TLabel').pack(anchor='w', padx=10, pady=5)
        self.update_interval = tk.StringVar(value="2")
        ttk.Entry(analysis_config, textvariable=self.update_interval, width=10).pack(anchor='w', padx=10, pady=5)
        
        # Número de threads
        ttk.Label(analysis_config, text="Número de Threads:", style='Dark.TLabel').pack(anchor='w', padx=10, pady=5)
        self.num_threads = tk.StringVar(value="4")
        ttk.Entry(analysis_config, textvariable=self.num_threads, width=10).pack(anchor='w', padx=10, pady=5)
        
    def start_analysis(self):
        """Inicia a análise em tempo real"""
        if self.is_running:
            return
            
        self.is_running = True
        self.start_button.config(state='disabled')
        self.stop_button.config(state='normal')
        self.status_label.config(text="Status: Analisando...")
        
        # Limpar resultados anteriores
        for item in self.results_tree.get_children():
            self.results_tree.delete(item)
        self.current_analysis = []
        
        # Iniciar thread de análise
        self.analysis_thread = threading.Thread(target=self.run_analysis, daemon=True)
        self.analysis_thread.start()
        
        # Iniciar atualização da interface
        self.update_interface()
        
    def stop_analysis(self):
        """Para a análise"""
        self.is_running = False
        self.start_button.config(state='normal')
        self.stop_button.config(state='disabled')
        self.status_label.config(text="Status: Parado")
        
    def run_analysis(self):
        """Executa a análise em thread separada"""
        input_dir = Path("Input_Expandido")
        if not input_dir.exists():
            self.log_message("❌ Diretório Input_Expandido não encontrado")
            self.is_running = False
            return
            
        mq4_files = list(input_dir.glob("*.mq4"))
        if not mq4_files:
            self.log_message("❌ Nenhum arquivo .mq4 encontrado")
            self.is_running = False
            return
            
        self.log_message(f"🔍 Iniciando análise de {len(mq4_files)} arquivos...")
        
        # Análise com ThreadPoolExecutor
        max_workers = int(self.num_threads.get())
        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            future_to_file = {executor.submit(self.multi_agent.analyze_file, str(file_path)): file_path 
                             for file_path in mq4_files}
            
            for future in as_completed(future_to_file):
                if not self.is_running:
                    break
                    
                file_path = future_to_file[future]
                try:
                    analysis = future.result()
                    if analysis:
                        self.analysis_queue.put(analysis)
                        self.log_message(f"✅ Analisado: {analysis.filename} (Score: {analysis.unified_score:.1f})")
                except Exception as e:
                    self.log_message(f"❌ Erro ao analisar {file_path.name}: {e}")
                    
        self.log_message("🎯 Análise concluída!")
        self.is_running = False
        
    def update_interface(self):
        """Atualiza a interface em tempo real"""
        if not self.is_running:
            return
            
        # Processar novos resultados
        while not self.analysis_queue.empty():
            try:
                analysis = self.analysis_queue.get_nowait()
                self.current_analysis.append(analysis)
                self.add_result_to_tree(analysis)
            except queue.Empty:
                break
                
        # Atualizar métricas
        self.update_metrics()
        
        # Atualizar estatísticas
        self.update_statistics()
        
        # Agendar próxima atualização
        interval = int(float(self.update_interval.get()) * 1000)
        self.root.after(interval, self.update_interface)
        
    def add_result_to_tree(self, analysis: FileAnalysis):
        """Adiciona resultado à tabela"""
        # Obter scores dos agentes
        architect_score = next((s.score for s in analysis.agent_scores if s.agent_name == "Architect"), 0.0)
        ftmo_score = next((s.score for s in analysis.agent_scores if s.agent_name == "FTMO_Trader"), 0.0)
        analyst_score = next((s.score for s in analysis.agent_scores if s.agent_name == "Code_Analyst"), 0.0)
        
        # Determinar cor baseada no score
        if analysis.unified_score >= 8.0:
            tags = ('excellent',)
        elif analysis.unified_score >= 6.0:
            tags = ('good',)
        elif analysis.unified_score >= 4.0:
            tags = ('average',)
        else:
            tags = ('poor',)
            
        values = (
            analysis.filename,
            analysis.file_type,
            analysis.strategy,
            f"{analysis.unified_score:.1f}",
            f"{architect_score:.1f}",
            f"{ftmo_score:.1f}",
            f"{analyst_score:.1f}",
            analysis.ftmo_status,
            f"{analysis.metadata_quality:.1f}"
        )
        
        self.results_tree.insert('', 'end', values=values, tags=tags)
        
        # Configurar cores das tags
        self.results_tree.tag_configure('excellent', background='#2d5a2d', foreground='white')
        self.results_tree.tag_configure('good', background='#4a4a2d', foreground='white')
        self.results_tree.tag_configure('average', background='#4a3a2d', foreground='white')
        self.results_tree.tag_configure('poor', background='#4a2d2d', foreground='white')
        
    def update_metrics(self):
        """Atualiza métricas gerais"""
        if not self.current_analysis:
            return
            
        total_files = len(self.current_analysis)
        avg_score = sum(a.unified_score for a in self.current_analysis) / total_files
        ftmo_ready = sum(1 for a in self.current_analysis if a.ftmo_status == "FTMO_READY")
        total_time = sum(a.processing_time for a in self.current_analysis)
        
        self.total_files_label.config(text=f"Arquivos: {total_files}")
        self.avg_score_label.config(text=f"Score Médio: {avg_score:.1f}")
        self.ftmo_ready_label.config(text=f"FTMO Ready: {ftmo_ready}")
        self.processing_time_label.config(text=f"Tempo: {total_time:.1f}s")
        
    def update_statistics(self):
        """Atualiza estatísticas detalhadas"""
        if not self.current_analysis:
            return
            
        stats = self.generate_statistics()
        self.stats_text.delete(1.0, tk.END)
        self.stats_text.insert(tk.END, stats)
        
    def generate_statistics(self) -> str:
        """Gera estatísticas detalhadas"""
        if not self.current_analysis:
            return "Nenhuma análise disponível."
            
        total = len(self.current_analysis)
        
        # Estatísticas por tipo
        types = {}
        strategies = {}
        ftmo_status = {}
        
        for analysis in self.current_analysis:
            types[analysis.file_type] = types.get(analysis.file_type, 0) + 1
            strategies[analysis.strategy] = strategies.get(analysis.strategy, 0) + 1
            ftmo_status[analysis.ftmo_status] = ftmo_status.get(analysis.ftmo_status, 0) + 1
            
        # Scores dos agentes
        architect_scores = [next((s.score for s in a.agent_scores if s.agent_name == "Architect"), 0) for a in self.current_analysis]
        ftmo_scores = [next((s.score for s in a.agent_scores if s.agent_name == "FTMO_Trader"), 0) for a in self.current_analysis]
        analyst_scores = [next((s.score for s in a.agent_scores if s.agent_name == "Code_Analyst"), 0) for a in self.current_analysis]
        
        stats = f"""
🤖 ESTATÍSTICAS DO SISTEMA MULTI-AGENTE
{'='*50}

📊 RESUMO GERAL:
Total de Arquivos Analisados: {total}
Score Unificado Médio: {sum(a.unified_score for a in self.current_analysis) / total:.2f}
Tempo Total de Processamento: {sum(a.processing_time for a in self.current_analysis):.2f}s
Tempo Médio por Arquivo: {sum(a.processing_time for a in self.current_analysis) / total:.3f}s

🏗️ SCORES POR AGENTE:
Architect - Média: {sum(architect_scores) / len(architect_scores):.2f} | Min: {min(architect_scores):.1f} | Max: {max(architect_scores):.1f}
FTMO_Trader - Média: {sum(ftmo_scores) / len(ftmo_scores):.2f} | Min: {min(ftmo_scores):.1f} | Max: {max(ftmo_scores):.1f}
Code_Analyst - Média: {sum(analyst_scores) / len(analyst_scores):.2f} | Min: {min(analyst_scores):.1f} | Max: {max(analyst_scores):.1f}

📁 DISTRIBUIÇÃO POR TIPO:
"""
        
        for file_type, count in sorted(types.items()):
            percentage = (count / total) * 100
            stats += f"{file_type}: {count} ({percentage:.1f}%)\n"
            
        stats += "\n🎯 DISTRIBUIÇÃO POR ESTRATÉGIA:\n"
        for strategy, count in sorted(strategies.items()):
            percentage = (count / total) * 100
            stats += f"{strategy}: {count} ({percentage:.1f}%)\n"
            
        stats += "\n💰 STATUS FTMO:\n"
        for status, count in sorted(ftmo_status.items()):
            percentage = (count / total) * 100
            stats += f"{status}: {count} ({percentage:.1f}%)\n"
            
        # Top 5 melhores arquivos
        top_files = sorted(self.current_analysis, key=lambda x: x.unified_score, reverse=True)[:5]
        stats += "\n🏆 TOP 5 MELHORES ARQUIVOS:\n"
        for i, analysis in enumerate(top_files, 1):
            stats += f"{i}. {analysis.filename} - Score: {analysis.unified_score:.1f}\n"
            
        # Issues mais comuns
        all_issues = []
        for analysis in self.current_analysis:
            all_issues.extend(analysis.issues_found)
            
        issue_counts = {}
        for issue in all_issues:
            issue_counts[issue] = issue_counts.get(issue, 0) + 1
            
        if issue_counts:
            stats += "\n⚠️ ISSUES MAIS COMUNS:\n"
            for issue, count in sorted(issue_counts.items(), key=lambda x: x[1], reverse=True)[:5]:
                stats += f"{issue}: {count} ocorrências\n"
                
        return stats
        
    def log_message(self, message: str):
        """Adiciona mensagem ao log"""
        timestamp = datetime.datetime.now().strftime("%H:%M:%S")
        log_entry = f"[{timestamp}] {message}\n"
        
        self.logs_text.insert(tk.END, log_entry)
        self.logs_text.see(tk.END)
        
        # Manter apenas as últimas 1000 linhas
        lines = self.logs_text.get(1.0, tk.END).split('\n')
        if len(lines) > 1000:
            self.logs_text.delete(1.0, f"{len(lines) - 1000}.0")
            
    def export_report(self):
        """Exporta relatório completo"""
        if not self.current_analysis:
            messagebox.showwarning("Aviso", "Nenhuma análise disponível para exportar.")
            return
            
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # Exportar JSON
        json_file = f"relatorio_multi_agente_{timestamp}.json"
        json_data = {
            "timestamp": timestamp,
            "total_files": len(self.current_analysis),
            "analysis_results": [asdict(analysis) for analysis in self.current_analysis],
            "statistics": self.generate_statistics()
        }
        
        with open(json_file, 'w', encoding='utf-8') as f:
            json.dump(json_data, f, indent=2, ensure_ascii=False)
            
        # Exportar relatório executivo
        md_file = f"relatorio_executivo_{timestamp}.md"
        with open(md_file, 'w', encoding='utf-8') as f:
            f.write(self.generate_executive_report())
            
        messagebox.showinfo("Sucesso", f"Relatórios exportados:\n- {json_file}\n- {md_file}")
        
    def generate_executive_report(self) -> str:
        """Gera relatório executivo em Markdown"""
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        report = f"""
# 🤖 RELATÓRIO EXECUTIVO - SISTEMA MULTI-AGENTE

**Data/Hora:** {timestamp}  
**Versão:** Classificador Trading v4.0  
**Arquivos Analisados:** {len(self.current_analysis)}

## 📊 RESUMO EXECUTIVO

{self.generate_statistics()}

## 📋 DETALHES POR ARQUIVO

| Arquivo | Tipo | Estratégia | Score Unificado | Architect | FTMO_Trader | Code_Analyst | Status FTMO |
|---------|------|------------|----------------|-----------|-------------|--------------|-------------|
"""
        
        for analysis in sorted(self.current_analysis, key=lambda x: x.unified_score, reverse=True):
            architect_score = next((s.score for s in analysis.agent_scores if s.agent_name == "Architect"), 0.0)
            ftmo_score = next((s.score for s in analysis.agent_scores if s.agent_name == "FTMO_Trader"), 0.0)
            analyst_score = next((s.score for s in analysis.agent_scores if s.agent_name == "Code_Analyst"), 0.0)
            
            report += f"| {analysis.filename} | {analysis.file_type} | {analysis.strategy} | {analysis.unified_score:.1f} | {architect_score:.1f} | {ftmo_score:.1f} | {analyst_score:.1f} | {analysis.ftmo_status} |\n"
            
        report += "\n## 🎯 RECOMENDAÇÕES\n\n"
        
        # Consolidar recomendações
        all_recommendations = []
        for analysis in self.current_analysis:
            all_recommendations.extend(analysis.recommendations)
            
        rec_counts = {}
        for rec in all_recommendations:
            rec_counts[rec] = rec_counts.get(rec, 0) + 1
            
        for rec, count in sorted(rec_counts.items(), key=lambda x: x[1], reverse=True)[:10]:
            report += f"- {rec} ({count} arquivos)\n"
            
        return report
        
    def run(self):
        """Executa a interface"""
        self.root.mainloop()

def main():
    """Função principal"""
    try:
        interface = RealTimeInterface()
        interface.run()
    except Exception as e:
        logger.error(f"Erro na interface: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()