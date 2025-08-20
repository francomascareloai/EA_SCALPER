#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para executar classificação da pasta All_MQ4
"""

import os
import sys
from pathlib import Path

# Adicionar paths necessários
sys.path.append(str(Path(__file__).parent / "Development" / "Core"))

try:
    from classificador_lote_avancado import ClassificadorLoteAvancado
    
    print("🔧 CLASSIFICADOR TRADING - PROCESSANDO ALL_MQ4")
    print("="*60)
    
    # Configurar caminhos
    base_path = Path(__file__).parent
    source_dir = base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "All_MQ4"
    
    print(f"📁 Diretório fonte: {source_dir}")
    print(f"📁 Diretório base: {base_path}")
    
    # Verificar se o diretório existe
    if not source_dir.exists():
        print(f"❌ ERRO: Diretório {source_dir} não encontrado!")
        print("\n📋 Diretórios disponíveis:")
        codigo_fonte = base_path / "CODIGO_FONTE_LIBRARY"
        if codigo_fonte.exists():
            for item in codigo_fonte.iterdir():
                if item.is_dir():
                    print(f"   📂 {item.name}")
                    for subitem in item.iterdir():
                        if subitem.is_dir():
                            print(f"      📂 {subitem.name}")
        sys.exit(1)
    
    # Contar arquivos MQ4
    mq4_files = list(source_dir.glob("*.mq4"))
    print(f"📊 Encontrados {len(mq4_files)} arquivos .mq4")
    
    if len(mq4_files) == 0:
        print("⚠️ Nenhum arquivo .mq4 encontrado para processar")
        sys.exit(0)
    
    # Criar classificador
    print("\n🚀 Iniciando classificador...")
    classificador = ClassificadorLoteAvancado(max_workers=2, base_path=str(base_path))
    
    # Processar diretório
    print("\n⚡ Processando arquivos...")
    resultado = classificador.process_directory(
        source_dir=str(source_dir),
        extensions=['.mq4'],
        create_backup=True,
        show_progress=True
    )
    
    # Mostrar resultados
    print("\n" + "="*60)
    print("📊 RESULTADOS FINAIS")
    print("="*60)
    
    if 'execution_time' in resultado:
        print(f"⏱️  Tempo de execução: {resultado['execution_time']:.2f}s")
    
    if 'performance' in resultado:
        perf = resultado['performance']
        print(f"📈 Taxa de processamento: {perf.get('files_per_second', 0):.1f} arquivos/s")
        print(f"✅ Taxa de sucesso: {perf.get('success_rate', 0):.1f}%")
        print(f"❌ Taxa de erro: {perf.get('error_rate', 0):.1f}%")
    
    if 'stats' in resultado:
        stats = resultado['stats']
        print(f"\n📁 Arquivos processados: {stats.get('processed', 0)}")
        print(f"✅ Sucessos: {stats.get('successful', 0)}")
        print(f"❌ Erros: {stats.get('errors', 0)}")
        print(f"⏭️  Ignorados: {stats.get('skipped', 0)}")
    
    if 'top_categories' in resultado:
        print("\n🏆 TOP CATEGORIAS:")
        for categoria, count in resultado['top_categories']:
            print(f"   📂 {categoria}: {count} arquivos")
    
    if 'recommendations' in resultado and resultado['recommendations']:
        print("\n💡 RECOMENDAÇÕES:")
        for rec in resultado['recommendations']:
            print(f"   💡 {rec}")
    
    print("\n✅ PROCESSAMENTO CONCLUÍDO COM SUCESSO!")
    
except ImportError as e:
    print(f"❌ ERRO DE IMPORTAÇÃO: {e}")
    print("\n🔍 Verificando arquivos disponíveis...")
    core_path = Path(__file__).parent / "Development" / "Core"
    if core_path.exists():
        print(f"📁 Arquivos em {core_path}:")
        for file in core_path.glob("*.py"):
            print(f"   📄 {file.name}")
    else:
        print(f"❌ Diretório {core_path} não encontrado")
        
except Exception as e:
    print(f"❌ ERRO GERAL: {e}")
    import traceback
    traceback.print_exc()