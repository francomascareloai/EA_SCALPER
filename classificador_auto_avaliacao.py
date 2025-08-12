#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🎯 CLASSIFICADOR COM AUTO-AVALIAÇÃO CONTÍNUA
Sistema inteligente que se auto-monitora e melhora continuamente

Recursos:
- Auto-avaliação a cada N arquivos
- Métricas de qualidade em tempo real
- Ajustes automáticos de parâmetros
- Relatórios de melhoria contínua
- Detecção de padrões emergentes
"""

import os
import json
import re
import shutil
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple, Any
from dataclasses import dataclass, asdict
import statistics

@dataclass
class MetricasAutoAvaliacao:
    """Métricas para auto-avaliação do processo"""
    total_arquivos: int = 0
    deteccoes_corretas: int = 0
    deteccoes_incertas: int = 0
    casos_especiais_detectados: int = 0
    nomenclatura_consistente: int = 0
    ftmo_compliance_detectado: int = 0
    confidence_scores: List[float] = None
    tempo_processamento: List[float] = None
    
    def __post_init__(self):
        if self.confidence_scores is None:
            self.confidence_scores = []
        if self.tempo_processamento is None:
            self.tempo_processamento = []
    
    @property
    def taxa_precisao(self) -> float:
        """Taxa de precisão das detecções"""
        if self.total_arquivos == 0:
            return 0.0
        return (self.deteccoes_corretas / self.total_arquivos) * 100
    
    @property
    def confidence_media(self) -> float:
        """Confidence score médio"""
        return statistics.mean(self.confidence_scores) if self.confidence_scores else 0.0
    
    @property
    def tempo_medio(self) -> float:
        """Tempo médio de processamento por arquivo"""
        return statistics.mean(self.tempo_processamento) if self.tempo_processamento else 0.0

class AutoAvaliadorQualidade:
    """Sistema de auto-avaliação contínua"""
    
    def __init__(self, intervalo_avaliacao: int = 10):
        self.intervalo_avaliacao = intervalo_avaliacao
        self.metricas = MetricasAutoAvaliacao()
        self.historico_avaliacoes = []
        self.padroes_emergentes = {}
        self.ajustes_realizados = []
        
        # Thresholds para qualidade
        self.thresholds = {
            'confidence_minimo': 70.0,
            'taxa_precisao_minima': 85.0,
            'tempo_maximo_por_arquivo': 5.0,
            'casos_especiais_minimos': 5.0
        }
    
    def avaliar_deteccao_tipo(self, codigo: str, tipo_detectado: str) -> bool:
        """Avalia se a detecção de tipo está correta"""
        # Padrões mais rigorosos para validação
        padroes_ea = [
            r'OnTick\s*\(',
            r'OrderSend\s*\(',
            r'trade\.Buy\s*\(',
            r'trade\.Sell\s*\(',
            r'PositionOpen\s*\(',
            r'#property\s+strict'
        ]
        
        padroes_indicator = [
            r'OnCalculate\s*\(',
            r'SetIndexBuffer\s*\(',
            r'IndicatorBuffers\s*\(',
            r'#property\s+indicator',
            r'PlotIndexSetInteger\s*\('
        ]
        
        padroes_script = [
            r'OnStart\s*\(',
            r'#property\s+script',
            r'void\s+OnStart\s*\('
        ]
        
        # Contagem de matches
        ea_matches = sum(1 for p in padroes_ea if re.search(p, codigo, re.IGNORECASE))
        ind_matches = sum(1 for p in padroes_indicator if re.search(p, codigo, re.IGNORECASE))
        scr_matches = sum(1 for p in padroes_script if re.search(p, codigo, re.IGNORECASE))
        
        # Determina tipo esperado
        if ea_matches >= 2:
            tipo_esperado = 'EA'
        elif ind_matches >= 2:
            tipo_esperado = 'Indicator'
        elif scr_matches >= 1:
            tipo_esperado = 'Script'
        else:
            tipo_esperado = 'Unknown'
        
        return tipo_detectado == tipo_esperado
    
    def avaliar_nomenclatura(self, nome_original: str, nome_sugerido: str) -> bool:
        """Avalia se a nomenclatura segue o padrão"""
        # Padrão: [PREFIXO]_[NOME]_v[VER]_[MERCADO].[EXT]
        padrao = r'^(EA|IND|SCR|STR|LIB)_[A-Za-z0-9]+_v\d+\.\d+_[A-Z0-9]+\.(mq[45]|pine)$'
        return bool(re.match(padrao, nome_sugerido))
    
    def avaliar_ftmo_compliance(self, analise_ftmo: Dict) -> bool:
        """Avalia se a análise FTMO está correta"""
        score = analise_ftmo.get('score', 0)
        nivel = analise_ftmo.get('compliance_level', 'Non_Compliant')
        
        # Validação de consistência
        if score >= 6 and nivel != 'FTMO_Ready':
            return False
        if score >= 4 and nivel == 'Non_Compliant':
            return False
        if score < 2 and nivel == 'FTMO_Ready':
            return False
        
        return True
    
    def detectar_padroes_emergentes(self, metadata: Dict):
        """Detecta novos padrões que podem indicar novas categorias"""
        estrategia = metadata.get('classification', {}).get('strategy', 'Unknown')
        mercado = metadata.get('classification', {}).get('markets', ['Unknown'])[0]
        
        # Registra combinações
        combinacao = f"{estrategia}_{mercado}"
        if combinacao not in self.padroes_emergentes:
            self.padroes_emergentes[combinacao] = 0
        self.padroes_emergentes[combinacao] += 1
    
    def registrar_processamento(self, metadata: Dict, tempo_processamento: float):
        """Registra métricas de um arquivo processado"""
        import time
        start_time = time.time()
        
        self.metricas.total_arquivos += 1
        self.metricas.tempo_processamento.append(tempo_processamento)
        
        # Avalia detecção de tipo
        codigo = metadata.get('file_info', {}).get('content_preview', '')
        tipo_detectado = metadata.get('classification', {}).get('file_type', 'Unknown')
        
        if self.avaliar_deteccao_tipo(codigo, tipo_detectado):
            self.metricas.deteccoes_corretas += 1
        else:
            self.metricas.deteccoes_incertas += 1
        
        # Avalia nomenclatura
        nome_original = metadata.get('file_info', {}).get('original_name', '')
        nome_sugerido = metadata.get('organization', {}).get('suggested_name', '')
        
        if self.avaliar_nomenclatura(nome_original, nome_sugerido):
            self.metricas.nomenclatura_consistente += 1
        
        # Avalia FTMO compliance
        analise_ftmo = metadata.get('ftmo_analysis', {})
        if self.avaliar_ftmo_compliance(analise_ftmo):
            self.metricas.ftmo_compliance_detectado += 1
        
        # Registra confidence score
        confidence = metadata.get('analysis_metadata', {}).get('confidence_score', 0)
        self.metricas.confidence_scores.append(confidence)
        
        # Detecta casos especiais
        if metadata.get('special_analysis', {}).get('is_exceptional', False):
            self.metricas.casos_especiais_detectados += 1
        
        # Detecta padrões emergentes
        self.detectar_padroes_emergentes(metadata)
        
        # Auto-avaliação periódica
        if self.metricas.total_arquivos % self.intervalo_avaliacao == 0:
            self.executar_auto_avaliacao()
    
    def executar_auto_avaliacao(self) -> Dict:
        """Executa auto-avaliação completa"""
        print(f"\n🔍 AUTO-AVALIAÇÃO - Arquivo {self.metricas.total_arquivos}")
        print("=" * 50)
        
        avaliacao = {
            'timestamp': datetime.now().isoformat(),
            'arquivos_processados': self.metricas.total_arquivos,
            'metricas': {
                'taxa_precisao': self.metricas.taxa_precisao,
                'confidence_media': self.metricas.confidence_media,
                'tempo_medio': self.metricas.tempo_medio,
                'casos_especiais': self.metricas.casos_especiais_detectados
            },
            'status_qualidade': self.avaliar_qualidade_geral(),
            'ajustes_sugeridos': self.sugerir_ajustes(),
            'padroes_emergentes': self.identificar_padroes_emergentes()
        }
        
        self.historico_avaliacoes.append(avaliacao)
        self.imprimir_relatorio_avaliacao(avaliacao)
        
        return avaliacao
    
    def avaliar_qualidade_geral(self) -> str:
        """Avalia qualidade geral do processo"""
        score = 0
        
        # Taxa de precisão
        if self.metricas.taxa_precisao >= self.thresholds['taxa_precisao_minima']:
            score += 25
        elif self.metricas.taxa_precisao >= 70:
            score += 15
        
        # Confidence médio
        if self.metricas.confidence_media >= self.thresholds['confidence_minimo']:
            score += 25
        elif self.metricas.confidence_media >= 50:
            score += 15
        
        # Tempo de processamento
        if self.metricas.tempo_medio <= self.thresholds['tempo_maximo_por_arquivo']:
            score += 25
        elif self.metricas.tempo_medio <= 10:
            score += 15
        
        # Detecção de casos especiais
        taxa_especiais = (self.metricas.casos_especiais_detectados / self.metricas.total_arquivos) * 100
        if taxa_especiais >= self.thresholds['casos_especiais_minimos']:
            score += 25
        elif taxa_especiais >= 2:
            score += 15
        
        if score >= 90:
            return "EXCELENTE"
        elif score >= 70:
            return "BOM"
        elif score >= 50:
            return "REGULAR"
        else:
            return "PRECISA_MELHORAR"
    
    def sugerir_ajustes(self) -> List[str]:
        """Sugere ajustes baseados nas métricas"""
        ajustes = []
        
        if self.metricas.taxa_precisao < self.thresholds['taxa_precisao_minima']:
            ajustes.append("🔧 Melhorar padrões de detecção de tipo")
            ajustes.append("📚 Adicionar mais keywords específicas")
        
        if self.metricas.confidence_media < self.thresholds['confidence_minimo']:
            ajustes.append("⚡ Refinar algoritmo de confidence scoring")
            ajustes.append("🎯 Adicionar validação cruzada de padrões")
        
        if self.metricas.tempo_medio > self.thresholds['tempo_maximo_por_arquivo']:
            ajustes.append("🚀 Otimizar performance de análise")
            ajustes.append("💾 Implementar cache de padrões")
        
        taxa_especiais = (self.metricas.casos_especiais_detectados / self.metricas.total_arquivos) * 100
        if taxa_especiais < self.thresholds['casos_especiais_minimos']:
            ajustes.append("🔍 Melhorar detecção de casos especiais")
            ajustes.append("⭐ Adicionar mais padrões de qualidade")
        
        return ajustes
    
    def identificar_padroes_emergentes(self) -> List[str]:
        """Identifica padrões emergentes que podem virar novas categorias"""
        emergentes = []
        
        for padrao, count in self.padroes_emergentes.items():
            if count >= 5:  # Threshold para nova categoria
                emergentes.append(f"📈 Padrão '{padrao}': {count} ocorrências - Considerar nova categoria")
        
        return emergentes
    
    def imprimir_relatorio_avaliacao(self, avaliacao: Dict):
        """Imprime relatório de auto-avaliação"""
        print(f"📊 Taxa de Precisão: {avaliacao['metricas']['taxa_precisao']:.1f}%")
        print(f"🎯 Confidence Médio: {avaliacao['metricas']['confidence_media']:.1f}%")
        print(f"⏱️ Tempo Médio: {avaliacao['metricas']['tempo_medio']:.2f}s/arquivo")
        print(f"⭐ Casos Especiais: {avaliacao['metricas']['casos_especiais']}")
        print(f"🏆 Status Geral: {avaliacao['status_qualidade']}")
        
        if avaliacao['ajustes_sugeridos']:
            print("\n🔧 AJUSTES SUGERIDOS:")
            for ajuste in avaliacao['ajustes_sugeridos']:
                print(f"   {ajuste}")
        
        if avaliacao['padroes_emergentes']:
            print("\n📈 PADRÕES EMERGENTES:")
            for padrao in avaliacao['padroes_emergentes']:
                print(f"   {padrao}")
        
        print("=" * 50)
    
    def gerar_relatorio_final(self) -> Dict:
        """Gera relatório final de auto-avaliação"""
        return {
            'resumo_geral': {
                'total_arquivos': self.metricas.total_arquivos,
                'taxa_precisao_final': self.metricas.taxa_precisao,
                'confidence_media_final': self.metricas.confidence_media,
                'tempo_total': sum(self.metricas.tempo_processamento),
                'casos_especiais_total': self.metricas.casos_especiais_detectados
            },
            'evolucao_qualidade': self.historico_avaliacoes,
            'padroes_emergentes_finais': self.padroes_emergentes,
            'ajustes_realizados': self.ajustes_realizados,
            'recomendacoes_futuras': self.gerar_recomendacoes_futuras()
        }
    
    def gerar_recomendacoes_futuras(self) -> List[str]:
        """Gera recomendações para melhorias futuras"""
        recomendacoes = []
        
        # Análise de tendências
        if len(self.historico_avaliacoes) >= 3:
            ultimas_precisoes = [a['metricas']['taxa_precisao'] for a in self.historico_avaliacoes[-3:]]
            if ultimas_precisoes[-1] < ultimas_precisoes[0]:
                recomendacoes.append("📉 Precisão em declínio - Revisar padrões de detecção")
        
        # Padrões emergentes
        for padrao, count in self.padroes_emergentes.items():
            if count >= 10:
                recomendacoes.append(f"🆕 Criar categoria específica para '{padrao}' ({count} arquivos)")
        
        # Performance
        if self.metricas.tempo_medio > 3:
            recomendacoes.append("⚡ Implementar otimizações de performance")
        
        return recomendacoes

# Exemplo de uso integrado
if __name__ == "__main__":
    # Demonstração do sistema de auto-avaliação
    avaliador = AutoAvaliadorQualidade(intervalo_avaliacao=5)
    
    print("🎯 SISTEMA DE AUTO-AVALIAÇÃO ATIVADO")
    print("Monitoramento contínuo da qualidade do processo...\n")
    
    # Simulação de processamento com auto-avaliação
    arquivos_teste = [
        "EA_Test1.mq4", "IND_Test2.mq4", "SCR_Test3.mq4",
        "EA_Test4.mq5", "IND_Test5.mq5", "Unknown_Test6.mq4"
    ]
    
    for i, arquivo in enumerate(arquivos_teste):
        # Simula metadata de processamento
        metadata_simulado = {
            'file_info': {
                'original_name': arquivo,
                'content_preview': 'OnTick() { OrderSend(); }' if 'EA_' in arquivo else 'OnCalculate() { SetIndexBuffer(); }'
            },
            'classification': {
                'file_type': 'EA' if 'EA_' in arquivo else 'Indicator' if 'IND_' in arquivo else 'Script',
                'strategy': 'scalping',
                'markets': ['EURUSD']
            },
            'organization': {
                'suggested_name': arquivo.replace('.mq', '_v1.0_EURUSD.mq')
            },
            'ftmo_analysis': {
                'score': 5,
                'compliance_level': 'Partially_Compliant'
            },
            'analysis_metadata': {
                'confidence_score': 85.0
            },
            'special_analysis': {
                'is_exceptional': i % 3 == 0  # Simula casos especiais
            }
        }
        
        # Registra processamento
        avaliador.registrar_processamento(metadata_simulado, 2.5)
        
        print(f"✅ Processado: {arquivo}")
    
    # Relatório final
    print("\n📋 RELATÓRIO FINAL DE AUTO-AVALIAÇÃO")
    relatorio_final = avaliador.gerar_relatorio_final()
    print(json.dumps(relatorio_final, indent=2, ensure_ascii=False))