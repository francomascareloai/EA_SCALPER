#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🔥 SISTEMA DE AVALIAÇÃO FTMO ULTRA RIGOROSO

Baseado na análise crítica dos metadados existentes.
Escala 0-10 com critérios extremamente rigorosos.

Autor: Classificador_Trading
Versão: 3.0 - Ultra Crítico
Data: 2025-01-12
"""

import os
import sys
import json
import hashlib
import re
import chardet
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple, Optional, Any
import logging

class AvaliadorFTMORigoroso:
    """Sistema de avaliação FTMO ultra rigoroso baseado em prop firms reais"""
    
    def __init__(self):
        self.setup_logging()
        
        # CRITÉRIOS FTMO ULTRA RIGOROSOS (Escala 0-10)
        self.criterios_ftmo = {
            # CRITÉRIOS OBRIGATÓRIOS (Eliminatórios)
            'stop_loss_obrigatorio': {
                'peso': 3.0,
                'patterns': [r'stoploss', r'sl\s*=', r'stop\s*loss', r'orderstoploss'],
                'eliminatorio': True,
                'descricao': 'Stop Loss obrigatório em todas as operações'
            },
            'sem_grid_martingale': {
                'peso': 3.0,
                'patterns_proibidos': [r'grid', r'martingale', r'recovery', r'double\s*down', r'lot\s*multiply'],
                'eliminatorio': True,
                'descricao': 'Proibição absoluta de Grid/Martingale'
            },
            'daily_loss_protection': {
                'peso': 2.0,
                'patterns': [r'daily\s*loss', r'max\s*daily', r'equity\s*protection', r'account\s*balance'],
                'eliminatorio': True,
                'descricao': 'Proteção de perda diária máxima (5%)'
            },
            
            # CRITÉRIOS DE ALTA PRIORIDADE
            'risk_management': {
                'peso': 1.5,
                'patterns': [r'risk', r'lot\s*size', r'money\s*management', r'account\s*percent'],
                'descricao': 'Gestão de risco por percentual da conta'
            },
            'take_profit': {
                'peso': 1.0,
                'patterns': [r'takeprofit', r'tp\s*=', r'take\s*profit', r'ordertakeprofit'],
                'descricao': 'Take Profit definido'
            },
            'max_drawdown_protection': {
                'peso': 1.5,
                'patterns': [r'drawdown', r'max\s*dd', r'equity\s*curve', r'balance\s*protection'],
                'descricao': 'Proteção contra drawdown excessivo'
            },
            
            # CRITÉRIOS COMPLEMENTARES
            'session_filter': {
                'peso': 0.5,
                'patterns': [r'session', r'time\s*filter', r'trading\s*hours', r'market\s*hours'],
                'descricao': 'Filtro de sessão de trading'
            },
            'news_filter': {
                'peso': 0.5,
                'patterns': [r'news', r'economic', r'calendar', r'high\s*impact'],
                'descricao': 'Filtro de notícias econômicas'
            },
            'trailing_stop': {
                'peso': 0.5,
                'patterns': [r'trailing', r'trail', r'move\s*stop'],
                'descricao': 'Trailing Stop implementado'
            }
        }
        
        # PENALIDADES SEVERAS (Redução direta do score)
        self.penalidades_criticas = {
            'grid_trading': {
                'penalidade': -10.0,  # Eliminatório
                'patterns': [r'grid', r'averaging', r'add\s*position'],
                'descricao': 'Grid Trading - PROIBIDO em FTMO'
            },
            'martingale': {
                'penalidade': -10.0,  # Eliminatório
                'patterns': [r'martingale', r'double\s*down', r'lot\s*multiply', r'recovery'],
                'descricao': 'Martingale - PROIBIDO em FTMO'
            },
            'hedge_trading': {
                'penalidade': -8.0,
                'patterns': [r'hedge', r'opposite\s*position', r'buy\s*sell\s*same'],
                'descricao': 'Hedge Trading - Não permitido'
            },
            'no_stop_loss': {
                'penalidade': -5.0,
                'descricao': 'Ausência de Stop Loss'
            },
            'high_risk_lot': {
                'penalidade': -3.0,
                'patterns': [r'lot\s*=\s*[0-9]*\.[5-9]', r'lot\s*=\s*[1-9]'],
                'descricao': 'Lot size muito alto (>0.5)'
            },
            'no_risk_management': {
                'penalidade': -4.0,
                'descricao': 'Ausência de gestão de risco'
            },
            'scalping_excessivo': {
                'penalidade': -2.0,
                'patterns': [r'tp\s*=\s*[1-5]', r'takeprofit\s*=\s*[1-5]'],
                'descricao': 'Scalping com TP muito baixo (<5 pips)'
            }
        }
        
        # CLASSIFICAÇÃO FTMO RIGOROSA
        self.classificacao_ftmo = {
            (9.0, 10.0): 'FTMO_ELITE',
            (7.5, 8.9): 'FTMO_READY',
            (6.0, 7.4): 'FTMO_CONDICIONAL',
            (4.0, 5.9): 'ALTO_RISCO',
            (2.0, 3.9): 'INADEQUADO',
            (0.0, 1.9): 'PROIBIDO_FTMO'
        }
        
        # ESTRATÉGIAS AUTOMATICAMENTE PROIBIDAS
        self.estrategias_proibidas = {
            'Grid_Martingale': -10.0,
            'Martingale': -10.0,
            'Grid_Trading': -10.0,
            'Hedge_Trading': -8.0,
            'Recovery_Trading': -9.0
        }
    
    def setup_logging(self):
        """Configura logging rigoroso"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s'
        )
        self.logger = logging.getLogger(__name__)
    
    def analisar_ftmo_ultra_rigoroso(self, content: str, filename: str, estrategia: str) -> Dict[str, Any]:
        """Análise FTMO ultra rigorosa com critérios de prop firms reais"""
        content_lower = content.lower()
        filename_lower = filename.lower()
        
        # Inicializar análise
        analise = {
            'score_bruto': 0.0,
            'score_final': 0.0,
            'criterios_atendidos': {},
            'penalidades_aplicadas': {},
            'riscos_detectados': [],
            'ajustes_necessarios': [],
            'status_ftmo': 'PROIBIDO_FTMO',
            'eliminatorio': False,
            'observacoes': [],
            'componentes_uteis': [],
            'snippets_detectados': []
        }
        
        # 1. VERIFICAR ESTRATÉGIAS AUTOMATICAMENTE PROIBIDAS
        if estrategia in self.estrategias_proibidas:
            penalidade = self.estrategias_proibidas[estrategia]
            analise['score_final'] = max(0.0, penalidade)
            analise['eliminatorio'] = True
            analise['riscos_detectados'].append(f'ESTRATÉGIA PROIBIDA: {estrategia}')
            analise['ajustes_necessarios'].append(f'INCOMPATÍVEL COM FTMO - Estratégia {estrategia} é proibida')
            analise['observacoes'].append(f'EA automaticamente reprovado por usar {estrategia}')
            
            # MESMO SENDO PROIBIDO, EXTRAIR COMPONENTES ÚTEIS
            analise['componentes_uteis'] = self._extrair_componentes_uteis_martingale(content)
            analise['snippets_detectados'] = self._detectar_snippets_reutilizaveis(content, filename)
            
            return analise
        
        # 2. AVALIAR CRITÉRIOS OBRIGATÓRIOS
        score_positivo = 0.0
        
        for criterio, config in self.criterios_ftmo.items():
            atendido = False
            
            # Verificar padrões positivos
            if 'patterns' in config:
                for pattern in config['patterns']:
                    if re.search(pattern, content_lower) or re.search(pattern, filename_lower):
                        atendido = True
                        break
            
            # Verificar padrões proibidos (para critérios negativos)
            if 'patterns_proibidos' in config:
                for pattern in config['patterns_proibidos']:
                    if re.search(pattern, content_lower):
                        atendido = False  # Falha no critério
                        analise['riscos_detectados'].append(f'PADRÃO PROIBIDO DETECTADO: {pattern}')
                        break
                else:
                    atendido = True  # Passou no teste (não tem padrões proibidos)
            
            analise['criterios_atendidos'][criterio] = atendido
            
            if atendido:
                score_positivo += config['peso']
                self.logger.info(f"✅ Critério atendido: {criterio} (+{config['peso']})")
            else:
                self.logger.warning(f"❌ Critério NÃO atendido: {criterio}")
                if config.get('eliminatorio', False):
                    analise['eliminatorio'] = True
                    analise['ajustes_necessarios'].append(f"CRÍTICO: {config['descricao']}")
        
        analise['score_bruto'] = score_positivo
        
        # 3. APLICAR PENALIDADES SEVERAS
        score_com_penalidades = score_positivo
        
        for penalidade_nome, config in self.penalidades_criticas.items():
            penalidade_aplicada = False
            
            if 'patterns' in config:
                for pattern in config['patterns']:
                    if re.search(pattern, content_lower):
                        penalidade_aplicada = True
                        break
            elif penalidade_nome == 'no_stop_loss':
                # Verificar ausência de stop loss
                if not analise['criterios_atendidos'].get('stop_loss_obrigatorio', False):
                    penalidade_aplicada = True
            elif penalidade_nome == 'no_risk_management':
                # Verificar ausência de gestão de risco
                if not analise['criterios_atendidos'].get('risk_management', False):
                    penalidade_aplicada = True
            
            if penalidade_aplicada:
                score_com_penalidades += config['penalidade']
                analise['penalidades_aplicadas'][penalidade_nome] = config['penalidade']
                analise['riscos_detectados'].append(config['descricao'])
                self.logger.error(f"🚫 Penalidade aplicada: {penalidade_nome} ({config['penalidade']})")
        
        # 4. NORMALIZAR SCORE FINAL (0-10)
        analise['score_final'] = max(0.0, min(10.0, score_com_penalidades))
        
        # 5. DETERMINAR STATUS FTMO
        for (min_score, max_score), status in self.classificacao_ftmo.items():
            if min_score <= analise['score_final'] <= max_score:
                analise['status_ftmo'] = status
                break
        
        # 6. VERIFICAR CRITÉRIOS ELIMINATÓRIOS
        if analise['eliminatorio'] or analise['score_final'] < 4.0:
            analise['status_ftmo'] = 'PROIBIDO_FTMO'
        
        # 7. GERAR AJUSTES NECESSÁRIOS
        if analise['score_final'] < 7.5:
            if not analise['criterios_atendidos'].get('stop_loss_obrigatorio', False):
                analise['ajustes_necessarios'].append('OBRIGATÓRIO: Implementar Stop Loss em todas as operações')
            if not analise['criterios_atendidos'].get('daily_loss_protection', False):
                analise['ajustes_necessarios'].append('OBRIGATÓRIO: Implementar proteção de perda diária (5%)')
            if not analise['criterios_atendidos'].get('risk_management', False):
                analise['ajustes_necessarios'].append('OBRIGATÓRIO: Implementar gestão de risco por percentual')
            if not analise['criterios_atendidos'].get('max_drawdown_protection', False):
                analise['ajustes_necessarios'].append('RECOMENDADO: Implementar proteção de drawdown máximo')
        
        # 8. EXTRAIR COMPONENTES ÚTEIS E SNIPPETS
        analise['componentes_uteis'] = self._extrair_componentes_uteis_martingale(content)
        analise['snippets_detectados'] = self._detectar_snippets_reutilizaveis(content, filename)
        
        # 9. OBSERVAÇÕES FINAIS
        if analise['score_final'] >= 9.0:
            analise['observacoes'].append('EA de excelência - Pronto para FTMO Challenge')
        elif analise['score_final'] >= 7.5:
            analise['observacoes'].append('EA adequado para FTMO com pequenos ajustes')
        elif analise['score_final'] >= 6.0:
            analise['observacoes'].append('EA requer ajustes significativos para FTMO')
        elif analise['score_final'] >= 4.0:
            analise['observacoes'].append('EA de alto risco - Não recomendado para FTMO')
        else:
            analise['observacoes'].append('EA inadequado/proibido para FTMO')
        
        return analise
    
    def gerar_relatorio_critico(self, analises: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Gera relatório crítico das análises"""
        total_arquivos = len(analises)
        
        # Estatísticas por status
        status_count = {}
        scores = []
        
        for analise in analises:
            status = analise.get('status_ftmo', 'UNKNOWN')
            status_count[status] = status_count.get(status, 0) + 1
            scores.append(analise.get('score_final', 0.0))
        
        # Análise crítica
        ftmo_ready = status_count.get('FTMO_READY', 0) + status_count.get('FTMO_ELITE', 0)
        taxa_aprovacao = (ftmo_ready / total_arquivos * 100) if total_arquivos > 0 else 0
        
        relatorio = {
            'timestamp': datetime.now().isoformat(),
            'total_arquivos': total_arquivos,
            'estatisticas': {
                'score_medio': sum(scores) / len(scores) if scores else 0.0,
                'score_maximo': max(scores) if scores else 0.0,
                'score_minimo': min(scores) if scores else 0.0,
                'taxa_aprovacao_ftmo': taxa_aprovacao
            },
            'distribuicao_status': status_count,
            'analise_critica': {
                'perspectiva_trader': self._analise_perspectiva_trader(analises, taxa_aprovacao),
                'perspectiva_engenheiro': self._analise_perspectiva_engenheiro(analises),
                'recomendacoes': self._gerar_recomendacoes(analises, taxa_aprovacao)
            },
            'detalhes_arquivos': analises
        }
        
        return relatorio
    
    def _analise_perspectiva_trader(self, analises: List[Dict[str, Any]], taxa_aprovacao: float) -> List[str]:
        """Análise crítica do ponto de vista do trader"""
        observacoes = []
        
        if taxa_aprovacao < 20:
            observacoes.append("🚨 CRÍTICO: Taxa de aprovação FTMO extremamente baixa (<20%)")
            observacoes.append("📉 Biblioteca contém muitos EAs inadequados para prop firms")
        elif taxa_aprovacao < 50:
            observacoes.append("⚠️ ATENÇÃO: Taxa de aprovação FTMO baixa (<50%)")
            observacoes.append("🔧 Necessária revisão e otimização dos EAs")
        else:
            observacoes.append("✅ Taxa de aprovação FTMO aceitável")
        
        # Análise de riscos
        grid_martingale_count = sum(1 for a in analises if 'GRID' in str(a.get('riscos_detectados', [])).upper() or 'MARTINGALE' in str(a.get('riscos_detectados', [])).upper())
        if grid_martingale_count > 0:
            observacoes.append(f"🚫 {grid_martingale_count} EAs com estratégias proibidas (Grid/Martingale)")
        
        no_stop_loss_count = sum(1 for a in analises if not a.get('criterios_atendidos', {}).get('stop_loss_obrigatorio', False))
        if no_stop_loss_count > 0:
            observacoes.append(f"⚠️ {no_stop_loss_count} EAs sem Stop Loss obrigatório")
        
        return observacoes
    
    def _analise_perspectiva_engenheiro(self, analises: List[Dict[str, Any]]) -> List[str]:
        """Análise crítica do ponto de vista do engenheiro"""
        observacoes = []
        
        # Análise de qualidade de código
        eliminatorios = sum(1 for a in analises if a.get('eliminatorio', False))
        if eliminatorios > 0:
            observacoes.append(f"🔧 {eliminatorios} EAs com problemas eliminatórios")
        
        # Análise de padrões
        sem_risk_mgmt = sum(1 for a in analises if not a.get('criterios_atendidos', {}).get('risk_management', False))
        if sem_risk_mgmt > 0:
            observacoes.append(f"📊 {sem_risk_mgmt} EAs sem gestão de risco adequada")
        
        observacoes.append("✅ Sistema de avaliação ultra rigoroso aplicado")
        observacoes.append("📋 Critérios baseados em prop firms reais")
        
        return observacoes
    
    def _gerar_recomendacoes(self, analises: List[Dict[str, Any]], taxa_aprovacao: float) -> List[str]:
        """Gera recomendações baseadas na análise"""
        recomendacoes = []
        
        if taxa_aprovacao < 30:
            recomendacoes.append("🎯 PRIORIDADE MÁXIMA: Revisar e corrigir EAs com estratégias proibidas")
            recomendacoes.append("🛡️ Implementar Stop Loss obrigatório em todos os EAs")
            recomendacoes.append("📉 Adicionar proteção de perda diária em todos os EAs")
        
        recomendacoes.append("🔍 Focar em EAs com score ≥7.5 para FTMO")
        recomendacoes.append("⚡ Eliminar completamente estratégias Grid/Martingale")
        recomendacoes.append("📊 Implementar gestão de risco por percentual da conta")
        
        return recomendacoes
    
    def _extrair_componentes_uteis_martingale(self, content: str) -> List[str]:
        """Extrai componentes úteis mesmo de EAs Martingale proibidos"""
        componentes = []
        content_lower = content.lower()
        
        # Lógicas de entrada potencialmente úteis
        if re.search(r'rsi|stochastic|macd|bollinger|ema|sma', content_lower):
            componentes.append('Indicadores técnicos para entrada')
        
        if re.search(r'time\s*filter|session|trading\s*hours', content_lower):
            componentes.append('Filtro de horário/sessão')
        
        if re.search(r'spread\s*check|spread\s*filter', content_lower):
            componentes.append('Filtro de spread')
        
        if re.search(r'news\s*filter|economic\s*calendar', content_lower):
            componentes.append('Filtro de notícias')
        
        if re.search(r'volatility\s*filter|atr', content_lower):
            componentes.append('Filtro de volatilidade')
        
        if re.search(r'trend\s*detection|trend\s*filter', content_lower):
            componentes.append('Detecção de tendência')
        
        if re.search(r'support\s*resistance|s\&r', content_lower):
            componentes.append('Detecção de suporte/resistência')
        
        if re.search(r'breakout|break\s*out', content_lower):
            componentes.append('Lógica de breakout')
        
        return componentes
    
    def _detectar_snippets_reutilizaveis(self, content: str, filename: str) -> List[Dict[str, str]]:
        """Detecta snippets de código reutilizáveis"""
        snippets = []
        
        # Funções de gestão de risco
        if re.search(r'double\s+CalculateLotSize|double\s+GetLotSize', content, re.IGNORECASE):
            snippets.append({
                'tipo': 'Risk_Management',
                'nome': 'CalculateLotSize',
                'descricao': 'Função de cálculo de lot size',
                'categoria': 'FTMO_Tools'
            })
        
        # Funções de trailing stop
        if re.search(r'void\s+TrailingStop|bool\s+TrailStop', content, re.IGNORECASE):
            snippets.append({
                'tipo': 'Order_Management',
                'nome': 'TrailingStop',
                'descricao': 'Função de trailing stop',
                'categoria': 'Risk_Management'
            })
        
        # Funções de detecção de tendência
        if re.search(r'bool\s+IsTrend|int\s+GetTrend', content, re.IGNORECASE):
            snippets.append({
                'tipo': 'Market_Analysis',
                'nome': 'TrendDetection',
                'descricao': 'Função de detecção de tendência',
                'categoria': 'Market_Structure'
            })
        
        # Funções de filtro de tempo
        if re.search(r'bool\s+IsTimeToTrade|bool\s+TimeFilter', content, re.IGNORECASE):
            snippets.append({
                'tipo': 'Time_Filter',
                'nome': 'TimeFilter',
                'descricao': 'Função de filtro de horário',
                'categoria': 'FTMO_Tools'
            })
        
        # Funções de proteção de drawdown
        if re.search(r'bool\s+CheckDrawdown|double\s+GetDrawdown', content, re.IGNORECASE):
            snippets.append({
                'tipo': 'Risk_Management',
                'nome': 'DrawdownProtection',
                'descricao': 'Função de proteção de drawdown',
                'categoria': 'FTMO_Tools'
            })
        
        # Funções de order blocks (SMC)
        if re.search(r'bool\s+DetectOrderBlock|void\s+FindOrderBlock', content, re.IGNORECASE):
            snippets.append({
                'tipo': 'SMC_Analysis',
                'nome': 'OrderBlockDetection',
                'descricao': 'Função de detecção de order blocks',
                'categoria': 'Market_Structure'
            })
        
        # Funções de volume analysis
        if re.search(r'double\s+GetVolume|bool\s+VolumeFilter', content, re.IGNORECASE):
            snippets.append({
                'tipo': 'Volume_Analysis',
                'nome': 'VolumeAnalysis',
                'descricao': 'Função de análise de volume',
                'categoria': 'Volume_Analysis'
            })
        
        return snippets

if __name__ == '__main__':
    avaliador = AvaliadorFTMORigoroso()
    print("🔥 Sistema de Avaliação FTMO Ultra Rigoroso - Pronto!")
    print("📊 Escala: 0-10 (Critérios extremamente rigorosos)")
    print("🚫 Grid/Martingale = Score 0 (Eliminatório)")
    print("✅ FTMO_Ready ≥ 7.5 pontos")
    print("🔧 Extração de componentes úteis e snippets ativada")