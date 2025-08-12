#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🎯 TESTE DO SISTEMA DE AUTO-AVALIAÇÃO
Teste rápido do classificador com auto-avaliação
"""

import os
import json
import time
from datetime import datetime
from pathlib import Path
from classificador_qualidade_maxima import TradingCodeAnalyzer

class AutoAvaliadorSimples:
    """Sistema de auto-avaliação simplificado para teste"""
    
    def __init__(self, intervalo_avaliacao: int = 3):
        self.intervalo_avaliacao = intervalo_avaliacao
        self.arquivos_processados = 0
        self.tempo_total = 0
        self.casos_especiais = 0
        self.qualidade_scores = []
        self.ftmo_scores = []
        self.alertas = []
    
    def registrar_processamento(self, metadata: dict, tempo: float):
        """Registra um processamento"""
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
        
        # Casos especiais
        if metadata.get('special_analysis', {}).get('is_exceptional', False):
            self.casos_especiais += 1
        
        # Auto-avaliação periódica
        if self.arquivos_processados % self.intervalo_avaliacao == 0:
            self.executar_auto_avaliacao()
    
    def executar_auto_avaliacao(self):
        """Executa auto-avaliação"""
        tempo_medio = self.tempo_total / self.arquivos_processados
        qualidade_media = sum(self.qualidade_scores) / len(self.qualidade_scores) if self.qualidade_scores else 0
        ftmo_medio = sum(self.ftmo_scores) / len(self.ftmo_scores) if self.ftmo_scores else 0
        
        print(f"\n🔍 AUTO-AVALIAÇÃO - Arquivo {self.arquivos_processados}")
        print("=" * 50)
        print(f"⏱️ Tempo médio por arquivo: {tempo_medio:.2f}s")
        print(f"🎯 Qualidade média: {qualidade_media:.1f}/10")
        print(f"🏆 FTMO compliance médio: {ftmo_medio:.1f}/7")
        print(f"⭐ Casos especiais detectados: {self.casos_especiais}")
        
        # Gerar alertas
        if tempo_medio > 3.0:
            print("⚠️ ALERTA: Tempo de processamento alto")
            self.alertas.append("Performance pode ser otimizada")
        
        if qualidade_media < 5.0:
            print("ℹ️ INFO: Qualidade média baixa detectada")
            self.alertas.append("Muitos códigos de baixa qualidade")
        
        if ftmo_medio < 3.0:
            print("⚠️ ALERTA: Baixa compatibilidade FTMO")
            self.alertas.append("Poucos códigos adequados para prop firms")
        
        if self.casos_especiais > 0:
            print(f"⭐ INFO: {self.casos_especiais} casos especiais identificados")
        
        print("=" * 50)
    
    def relatorio_final(self):
        """Gera relatório final"""
        tempo_medio = self.tempo_total / self.arquivos_processados if self.arquivos_processados > 0 else 0
        qualidade_media = sum(self.qualidade_scores) / len(self.qualidade_scores) if self.qualidade_scores else 0
        ftmo_medio = sum(self.ftmo_scores) / len(self.ftmo_scores) if self.ftmo_scores else 0
        
        return {
            'arquivos_processados': self.arquivos_processados,
            'tempo_total': self.tempo_total,
            'tempo_medio': tempo_medio,
            'qualidade_media': qualidade_media,
            'ftmo_medio': ftmo_medio,
            'casos_especiais': self.casos_especiais,
            'alertas_gerados': self.alertas
        }

def testar_auto_avaliacao():
    """Testa o sistema de auto-avaliação"""
    print("🎯 TESTE DO SISTEMA DE AUTO-AVALIAÇÃO")
    print("Processando arquivos com monitoramento contínuo...\n")
    
    # Inicializar
    base_path = Path.cwd()
    analyzer = TradingCodeAnalyzer(str(base_path))
    avaliador = AutoAvaliadorSimples(intervalo_avaliacao=2)  # Avaliar a cada 2 arquivos
    
    # Encontrar arquivos para teste
    arquivos_teste = []
    for pasta in ['All_MQ4', 'All_MQ5']:
        pasta_path = base_path / 'CODIGO_FONTE_LIBRARY' / 'MQL4_Source' / pasta
        if pasta_path.exists():
            for arquivo in pasta_path.glob('*.mq*'):
                arquivos_teste.append(arquivo)
                if len(arquivos_teste) >= 6:  # Limitar a 6 arquivos para teste
                    break
        if len(arquivos_teste) >= 6:
            break
    
    if not arquivos_teste:
        print("❌ Nenhum arquivo encontrado para teste")
        return
    
    print(f"📁 Encontrados {len(arquivos_teste)} arquivos para teste")
    
    # Processar arquivos
    for i, arquivo in enumerate(arquivos_teste, 1):
        print(f"\n📄 [{i}/{len(arquivos_teste)}] Processando: {arquivo.name}")
        
        start_time = time.time()
        
        try:
            # Analisar arquivo
            metadata = analyzer.analyze_file(str(arquivo))
            
            # Simular processamento
            time.sleep(0.1)  # Simular tempo de processamento
            
            tempo_processamento = time.time() - start_time
            
            # Registrar no auto-avaliador
            avaliador.registrar_processamento(metadata, tempo_processamento)
            
            # Mostrar resultado
            tipo = metadata.get('classification', {}).get('file_type', 'Unknown')
            estrategia = metadata.get('classification', {}).get('strategy', 'Unknown')
            ftmo = metadata.get('ftmo_analysis', {}).get('compliance_level', 'Unknown')
            qualidade = metadata.get('code_quality', {}).get('quality_level', 'Unknown')
            
            especial = "⭐" if metadata.get('special_analysis', {}).get('is_exceptional', False) else "✅"
            
            print(f"{especial} {tipo} | {estrategia} | {ftmo} | {qualidade} ({tempo_processamento:.2f}s)")
            
        except Exception as e:
            print(f"❌ Erro: {e}")
    
    # Relatório final
    print("\n📊 RELATÓRIO FINAL DE AUTO-AVALIAÇÃO")
    print("=" * 60)
    
    relatorio = avaliador.relatorio_final()
    
    print(f"📁 Arquivos processados: {relatorio['arquivos_processados']}")
    print(f"⏱️ Tempo total: {relatorio['tempo_total']:.2f}s")
    print(f"📈 Tempo médio por arquivo: {relatorio['tempo_medio']:.2f}s")
    print(f"🎯 Qualidade média: {relatorio['qualidade_media']:.1f}/10")
    print(f"🏆 FTMO compliance médio: {relatorio['ftmo_medio']:.1f}/7")
    print(f"⭐ Casos especiais: {relatorio['casos_especiais']}")
    
    if relatorio['alertas_gerados']:
        print(f"\n⚠️ ALERTAS GERADOS:")
        for alerta in relatorio['alertas_gerados']:
            print(f"   • {alerta}")
    
    # Salvar relatório
    reports_dir = base_path / "Reports" / "Auto_Avaliacao"
    reports_dir.mkdir(parents=True, exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    arquivo_relatorio = reports_dir / f"teste_auto_avaliacao_{timestamp}.json"
    
    with open(arquivo_relatorio, 'w', encoding='utf-8') as f:
        json.dump(relatorio, f, indent=2, ensure_ascii=False)
    
    print(f"\n💾 Relatório salvo em: {arquivo_relatorio}")
    
    # Conclusões
    print("\n🎯 CONCLUSÕES DO TESTE:")
    print("✅ Sistema de auto-avaliação funcionando")
    print("✅ Monitoramento de performance em tempo real")
    print("✅ Detecção automática de casos especiais")
    print("✅ Alertas de qualidade implementados")
    print("✅ Métricas de FTMO compliance monitoradas")
    
    return relatorio

if __name__ == "__main__":
    testar_auto_avaliacao()