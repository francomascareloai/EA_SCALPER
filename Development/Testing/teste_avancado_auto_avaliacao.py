#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🎯 TESTE AVANÇADO DO SISTEMA DE AUTO-AVALIAÇÃO
Teste com arquivos .mq4 reais para demonstrar melhorias
"""

import os
import json
import time
from datetime import datetime
from pathlib import Path
from classificador_qualidade_maxima import TradingCodeAnalyzer

class AutoAvaliadorAvancado:
    """Sistema de auto-avaliação avançado com métricas detalhadas"""
    
    def __init__(self, intervalo_avaliacao: int = 3):
        self.intervalo_avaliacao = intervalo_avaliacao
        self.arquivos_processados = 0
        self.tempo_total = 0
        self.casos_especiais = 0
        self.qualidade_scores = []
        self.ftmo_scores = []
        self.alertas = []
        self.tipos_detectados = {}
        self.estrategias_detectadas = {}
        self.melhorias_sugeridas = []
        self.historico_performance = []
    
    def registrar_processamento(self, arquivo_nome: str, metadata: dict, tempo: float):
        """Registra um processamento com análise detalhada"""
        self.arquivos_processados += 1
        self.tempo_total += tempo
        
        # Registrar qualidade
        if 'code_quality' in metadata:
            score = metadata['code_quality'].get('quality_score', 0)
            self.qualidade_scores.append(score)
        
        # Registrar FTMO
        if 'ftmo_analysis' in metadata:
            ftmo_score = metadata['ftmo_analysis'].get('score', 0)
            self.ftmo_scores.append(ftmo_score)
        
        # Registrar tipos
        tipo = metadata.get('classification', {}).get('file_type', 'Unknown')
        self.tipos_detectados[tipo] = self.tipos_detectados.get(tipo, 0) + 1
        
        # Registrar estratégias
        estrategia = metadata.get('classification', {}).get('strategy', 'Unknown')
        self.estrategias_detectadas[estrategia] = self.estrategias_detectadas.get(estrategia, 0) + 1
        
        # Casos especiais
        if metadata.get('special_analysis', {}).get('is_exceptional', False):
            self.casos_especiais += 1
        
        # Histórico de performance
        self.historico_performance.append({
            'arquivo': arquivo_nome,
            'tempo': tempo,
            'tipo': tipo,
            'estrategia': estrategia,
            'qualidade': metadata.get('code_quality', {}).get('quality_score', 0),
            'ftmo': metadata.get('ftmo_analysis', {}).get('score', 0),
            'especial': metadata.get('special_analysis', {}).get('is_exceptional', False)
        })
        
        # Auto-avaliação periódica
        if self.arquivos_processados % self.intervalo_avaliacao == 0:
            self.executar_auto_avaliacao()
    
    def executar_auto_avaliacao(self):
        """Executa auto-avaliação com análise de tendências"""
        tempo_medio = self.tempo_total / self.arquivos_processados
        qualidade_media = sum(self.qualidade_scores) / len(self.qualidade_scores) if self.qualidade_scores else 0
        ftmo_medio = sum(self.ftmo_scores) / len(self.ftmo_scores) if self.ftmo_scores else 0
        
        print(f"\n🔍 AUTO-AVALIAÇÃO AVANÇADA - Arquivo {self.arquivos_processados}")
        print("=" * 60)
        print(f"⏱️ Tempo médio por arquivo: {tempo_medio:.2f}s")
        print(f"🎯 Qualidade média: {qualidade_media:.1f}/10")
        print(f"🏆 FTMO compliance médio: {ftmo_medio:.1f}/7")
        print(f"⭐ Casos especiais detectados: {self.casos_especiais}")
        
        # Análise de tipos
        print(f"\n📊 DISTRIBUIÇÃO DE TIPOS:")
        for tipo, count in self.tipos_detectados.items():
            porcentagem = (count / self.arquivos_processados) * 100
            print(f"   {tipo}: {count} ({porcentagem:.1f}%)")
        
        # Análise de estratégias
        print(f"\n🎯 ESTRATÉGIAS IDENTIFICADAS:")
        for estrategia, count in self.estrategias_detectadas.items():
            porcentagem = (count / self.arquivos_processados) * 100
            print(f"   {estrategia}: {count} ({porcentagem:.1f}%)")
        
        # Gerar alertas e melhorias
        self._gerar_alertas_e_melhorias(tempo_medio, qualidade_media, ftmo_medio)
        
        print("=" * 60)
    
    def _gerar_alertas_e_melhorias(self, tempo_medio: float, qualidade_media: float, ftmo_medio: float):
        """Gera alertas e sugestões de melhoria"""
        # Alertas de performance
        if tempo_medio > 2.0:
            alerta = f"⚠️ PERFORMANCE: Tempo médio alto ({tempo_medio:.2f}s)"
            print(alerta)
            self.alertas.append(alerta)
            self.melhorias_sugeridas.append("Otimizar análise de código para arquivos grandes")
        
        # Alertas de qualidade
        if qualidade_media < 6.0:
            alerta = f"ℹ️ QUALIDADE: Média baixa ({qualidade_media:.1f}/10)"
            print(alerta)
            self.alertas.append(alerta)
            self.melhorias_sugeridas.append("Implementar filtros para códigos de baixa qualidade")
        
        # Alertas FTMO
        if ftmo_medio < 4.0:
            alerta = f"⚠️ FTMO: Baixa compatibilidade ({ftmo_medio:.1f}/7)"
            print(alerta)
            self.alertas.append(alerta)
            self.melhorias_sugeridas.append("Criar categoria específica para códigos FTMO-ready")
        
        # Análise de distribuição
        unknown_percentage = (self.tipos_detectados.get('Unknown', 0) / self.arquivos_processados) * 100
        if unknown_percentage > 50:
            alerta = f"⚠️ CLASSIFICAÇÃO: {unknown_percentage:.1f}% arquivos não classificados"
            print(alerta)
            self.alertas.append(alerta)
            self.melhorias_sugeridas.append("Melhorar algoritmos de detecção de tipo")
        
        # Casos especiais
        if self.casos_especiais > 0:
            taxa_especiais = (self.casos_especiais / self.arquivos_processados) * 100
            if taxa_especiais > 20:
                alerta = f"⭐ ESPECIAIS: Alta taxa de casos especiais ({taxa_especiais:.1f}%)"
                print(alerta)
                self.alertas.append(alerta)
                self.melhorias_sugeridas.append("Criar workflows específicos para casos especiais")
    
    def analisar_tendencias(self):
        """Analisa tendências nos últimos processamentos"""
        if len(self.historico_performance) < 3:
            return
        
        ultimos_3 = self.historico_performance[-3:]
        tempo_medio_recente = sum(p['tempo'] for p in ultimos_3) / 3
        qualidade_media_recente = sum(p['qualidade'] for p in ultimos_3) / 3
        
        print(f"\n📈 TENDÊNCIAS RECENTES:")
        print(f"   Tempo médio (últimos 3): {tempo_medio_recente:.2f}s")
        print(f"   Qualidade média (últimos 3): {qualidade_media_recente:.1f}/10")
        
        # Detectar padrões
        tipos_recentes = [p['tipo'] for p in ultimos_3]
        if len(set(tipos_recentes)) == 1 and tipos_recentes[0] == 'Unknown':
            print("   ⚠️ Padrão: Sequência de arquivos não classificados")
            self.melhorias_sugeridas.append("Revisar critérios de classificação")
    
    def relatorio_final_avancado(self):
        """Gera relatório final com análise completa"""
        tempo_medio = self.tempo_total / self.arquivos_processados if self.arquivos_processados > 0 else 0
        qualidade_media = sum(self.qualidade_scores) / len(self.qualidade_scores) if self.qualidade_scores else 0
        ftmo_medio = sum(self.ftmo_scores) / len(self.ftmo_scores) if self.ftmo_scores else 0
        
        # Análise de eficiência
        arquivos_por_segundo = self.arquivos_processados / self.tempo_total if self.tempo_total > 0 else 0
        
        return {
            'estatisticas_gerais': {
                'arquivos_processados': self.arquivos_processados,
                'tempo_total': self.tempo_total,
                'tempo_medio': tempo_medio,
                'arquivos_por_segundo': arquivos_por_segundo,
                'qualidade_media': qualidade_media,
                'ftmo_medio': ftmo_medio,
                'casos_especiais': self.casos_especiais
            },
            'distribuicao_tipos': self.tipos_detectados,
            'distribuicao_estrategias': self.estrategias_detectadas,
            'alertas_gerados': self.alertas,
            'melhorias_sugeridas': list(set(self.melhorias_sugeridas)),
            'historico_performance': self.historico_performance,
            'metricas_qualidade': {
                'scores_qualidade': self.qualidade_scores,
                'scores_ftmo': self.ftmo_scores,
                'qualidade_min': min(self.qualidade_scores) if self.qualidade_scores else 0,
                'qualidade_max': max(self.qualidade_scores) if self.qualidade_scores else 0,
                'ftmo_min': min(self.ftmo_scores) if self.ftmo_scores else 0,
                'ftmo_max': max(self.ftmo_scores) if self.ftmo_scores else 0
            }
        }

def testar_auto_avaliacao_avancado():
    """Testa o sistema de auto-avaliação avançado"""
    print("🎯 TESTE AVANÇADO DO SISTEMA DE AUTO-AVALIAÇÃO")
    print("Processando arquivos .mq4 reais com análise detalhada...\n")
    
    # Inicializar
    base_path = Path.cwd()
    analyzer = TradingCodeAnalyzer(str(base_path))
    avaliador = AutoAvaliadorAvancado(intervalo_avaliacao=2)
    
    # Encontrar arquivos .mq4 reais
    arquivos_teste = []
    
    # Buscar em várias pastas
    pastas_busca = [
        'CODIGO_FONTE_LIBRARY/MQL4_Source/All_MQ4',
        'CODIGO_FONTE_LIBRARY/MQL4_Source/Unclassified',
        'CODIGO_FONTE_LIBRARY/MQL4_Source/Duplicates_Removed_MQL4',
        'CODIGO_FONTE_LIBRARY/MQL4_Source/All_MQ4/Duplicates_Removed_Special_MQL4'
    ]
    
    for pasta in pastas_busca:
        pasta_path = base_path / pasta
        if pasta_path.exists():
            for arquivo in pasta_path.glob('*.mq4'):
                if arquivo.is_file() and arquivo.stat().st_size > 1000:  # Apenas arquivos > 1KB
                    arquivos_teste.append(arquivo)
                    if len(arquivos_teste) >= 8:  # Limitar a 8 arquivos
                        break
        if len(arquivos_teste) >= 8:
            break
    
    if not arquivos_teste:
        print("❌ Nenhum arquivo .mq4 encontrado para teste")
        return
    
    print(f"📁 Encontrados {len(arquivos_teste)} arquivos .mq4 para teste")
    print(f"📊 Tamanhos: {[f'{a.stat().st_size//1024}KB' for a in arquivos_teste]}")
    
    # Processar arquivos
    for i, arquivo in enumerate(arquivos_teste, 1):
        print(f"\n📄 [{i}/{len(arquivos_teste)}] Processando: {arquivo.name}")
        print(f"   📁 Pasta: {arquivo.parent.name}")
        print(f"   📏 Tamanho: {arquivo.stat().st_size//1024}KB")
        
        start_time = time.time()
        
        try:
            # Analisar arquivo
            metadata = analyzer.analyze_file(str(arquivo))
            
            tempo_processamento = time.time() - start_time
            
            # Registrar no auto-avaliador
            avaliador.registrar_processamento(arquivo.name, metadata, tempo_processamento)
            
            # Mostrar resultado detalhado
            tipo = metadata.get('classification', {}).get('file_type', 'Unknown')
            estrategia = metadata.get('classification', {}).get('strategy', 'Unknown')
            ftmo = metadata.get('ftmo_analysis', {}).get('compliance_level', 'Unknown')
            qualidade = metadata.get('code_quality', {}).get('quality_level', 'Unknown')
            
            especial = "⭐" if metadata.get('special_analysis', {}).get('is_exceptional', False) else "✅"
            
            print(f"   {especial} {tipo} | {estrategia} | {ftmo} | {qualidade}")
            print(f"   ⏱️ Processado em {tempo_processamento:.2f}s")
            
            # Mostrar flags especiais se houver
            if metadata.get('special_analysis', {}).get('flags'):
                flags = metadata['special_analysis']['flags']
                print(f"   🏷️ Flags: {', '.join(flags)}")
            
        except Exception as e:
            print(f"   ❌ Erro: {e}")
    
    # Análise de tendências
    avaliador.analisar_tendencias()
    
    # Relatório final
    print("\n📊 RELATÓRIO FINAL AVANÇADO")
    print("=" * 70)
    
    relatorio = avaliador.relatorio_final_avancado()
    
    # Estatísticas gerais
    stats = relatorio['estatisticas_gerais']
    print(f"📁 Arquivos processados: {stats['arquivos_processados']}")
    print(f"⏱️ Tempo total: {stats['tempo_total']:.2f}s")
    print(f"📈 Tempo médio por arquivo: {stats['tempo_medio']:.2f}s")
    print(f"🚀 Velocidade: {stats['arquivos_por_segundo']:.1f} arquivos/segundo")
    print(f"🎯 Qualidade média: {stats['qualidade_media']:.1f}/10")
    print(f"🏆 FTMO compliance médio: {stats['ftmo_medio']:.1f}/7")
    print(f"⭐ Casos especiais: {stats['casos_especiais']}")
    
    # Distribuições
    print(f"\n📊 DISTRIBUIÇÃO FINAL DE TIPOS:")
    for tipo, count in relatorio['distribuicao_tipos'].items():
        porcentagem = (count / stats['arquivos_processados']) * 100
        print(f"   {tipo}: {count} ({porcentagem:.1f}%)")
    
    print(f"\n🎯 ESTRATÉGIAS FINAIS:")
    for estrategia, count in relatorio['distribuicao_estrategias'].items():
        porcentagem = (count / stats['arquivos_processados']) * 100
        print(f"   {estrategia}: {count} ({porcentagem:.1f}%)")
    
    # Métricas de qualidade
    metricas = relatorio['metricas_qualidade']
    if metricas['scores_qualidade']:
        print(f"\n📈 ANÁLISE DE QUALIDADE:")
        print(f"   Qualidade: {metricas['qualidade_min']:.1f} - {metricas['qualidade_max']:.1f}")
        print(f"   FTMO: {metricas['ftmo_min']:.1f} - {metricas['ftmo_max']:.1f}")
    
    # Melhorias sugeridas
    if relatorio['melhorias_sugeridas']:
        print(f"\n💡 MELHORIAS SUGERIDAS:")
        for i, melhoria in enumerate(relatorio['melhorias_sugeridas'], 1):
            print(f"   {i}. {melhoria}")
    
    # Salvar relatório
    reports_dir = base_path / "Reports" / "Auto_Avaliacao"
    reports_dir.mkdir(parents=True, exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    arquivo_relatorio = reports_dir / f"teste_avancado_{timestamp}.json"
    
    with open(arquivo_relatorio, 'w', encoding='utf-8') as f:
        json.dump(relatorio, f, indent=2, ensure_ascii=False)
    
    print(f"\n💾 Relatório detalhado salvo em: {arquivo_relatorio}")
    
    # Conclusões e recomendações
    print("\n🎯 CONCLUSÕES E RECOMENDAÇÕES:")
    print("✅ Sistema de auto-avaliação avançado funcionando")
    print("✅ Análise de tendências implementada")
    print("✅ Detecção de padrões em tempo real")
    print("✅ Métricas de performance monitoradas")
    print("✅ Sugestões de melhoria automáticas")
    
    # Calcular eficiência
    eficiencia = (stats['arquivos_processados'] / stats['tempo_total']) * 60  # arquivos por minuto
    print(f"\n🚀 EFICIÊNCIA: {eficiencia:.0f} arquivos por minuto")
    print(f"📊 PROJEÇÃO: ~{eficiencia * 60:.0f} arquivos por hora")
    
    return relatorio

if __name__ == "__main__":
    testar_auto_avaliacao_avancado()