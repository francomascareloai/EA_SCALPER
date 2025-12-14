#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para executar o sistema multi-agente na pasta All_MQ4
Classificador Trading - Execução Inteligente
"""

import sys
import os
from pathlib import Path

# Adicionar caminhos necessários
sys.path.append(str(Path(__file__).parent / "Teste_Critico"))
sys.path.append(str(Path(__file__).parent / "Development" / "Core"))

from Teste_Critico.classificador_com_multiplos_agentes import ClassificadorMultiAgente

def main():
    """
    Executa o sistema multi-agente para processar todos os arquivos MQ4
    """
    print("🤖 SISTEMA MULTI-AGENTE - CLASSIFICADOR TRADING")
    print("=" * 60)
    
    # Configurar diretórios
    base_path = Path(__file__).parent
    input_dir = base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "All_MQ4"
    output_dir = base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source"
    
    print(f"📁 Diretório de entrada: {input_dir}")
    print(f"📁 Diretório de saída: {output_dir}")
    
    # Verificar se o diretório existe
    if not input_dir.exists():
        print(f"❌ Erro: Diretório {input_dir} não encontrado!")
        return
    
    # Contar arquivos
    arquivos_mq4 = list(input_dir.glob("*.mq4"))
    print(f"📊 Encontrados {len(arquivos_mq4)} arquivos .mq4 para processar")
    
    if len(arquivos_mq4) == 0:
        print("⚠️ Nenhum arquivo .mq4 encontrado para processar")
        return
    
    try:
        # Inicializar classificador
        print("\n🚀 Inicializando sistema multi-agente...")
        classificador = ClassificadorMultiAgente(
            input_dir=str(input_dir),
            output_dir=str(output_dir)
        )
        
        # Processar biblioteca
        print("\n⚡ Iniciando processamento inteligente...")
        resultado = classificador.processar_biblioteca()
        
        # Mostrar resultados
        print("\n" + "=" * 60)
        print("📊 RESULTADOS DO PROCESSAMENTO")
        print("=" * 60)
        print(f"⏱️  Tempo de processamento: {resultado['processing_time']:.2f}s")
        print(f"📁 Arquivos processados: {resultado['files_processed']}")
        
        # Score unificado
        score_unificado = resultado['multi_agent_evaluation']['unified_score']
        classificacao = resultado['multi_agent_evaluation']['classification']
        print(f"🎯 Score Unificado: {score_unificado:.1f}/10.0")
        print(f"🏆 Classificação: {classificacao}")
        
        # Estatísticas FTMO
        ftmo_analysis = resultado['ftmo_analysis']
        print(f"✅ FTMO Ready: {ftmo_analysis.get('ftmo_ready_percentage', 0):.1f}%")
        
        # Issues críticos
        critical_issues = resultado['multi_agent_evaluation']['critical_issues']
        if critical_issues:
            print(f"\n❌ ISSUES CRÍTICOS ({len(critical_issues)}):")
            for issue in critical_issues[:5]:
                print(f"  • {issue}")
        
        # Recomendações
        recommendations = resultado['recommendations']
        if recommendations:
            print(f"\n💡 RECOMENDAÇÕES PRIORITÁRIAS ({len(recommendations)}):")
            for i, rec in enumerate(recommendations[:5], 1):
                print(f"  {i}. {rec}")
        
        print("\n🎉 Processamento concluído com sucesso!")
        print(f"📄 Relatórios salvos em: {output_dir / 'Reports'}")
        print(f"📋 Metadados salvos em: {output_dir / 'Metadata'}")
        
    except Exception as e:
        print(f"\n❌ Erro durante o processamento: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()