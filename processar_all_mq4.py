#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para processar todos os arquivos da pasta All_MQ4
Utiliza o sistema de classificação de qualidade máxima
"""

import os
import sys
import glob
from pathlib import Path

# Adiciona o caminho do Development/Core ao sys.path
sys.path.append(str(Path(__file__).parent / "Development" / "Core"))

try:
    from classificador_qualidade_maxima import TradingCodeAnalyzer
except ImportError:
    print("❌ Erro: Não foi possível importar TradingCodeAnalyzer")
    sys.exit(1)

def processar_pasta_all_mq4():
    """
    Processa todos os arquivos .mq4 da pasta All_MQ4
    """
    base_path = Path(__file__).parent
    input_dir = base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "All_MQ4"
    output_dir = base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source"
    
    print(f"🔍 Processando arquivos em: {input_dir}")
    print(f"📂 Diretório de saída: {output_dir}")
    
    if not input_dir.exists():
        print(f"❌ Diretório não encontrado: {input_dir}")
        return
    
    # Inicializa o analisador
    analyzer = TradingCodeAnalyzer(str(base_path))
    
    # Busca todos os arquivos .mq4 recursivamente
    arquivos_mq4 = list(input_dir.rglob("*.mq4"))
    
    print(f"📊 Encontrados {len(arquivos_mq4)} arquivos .mq4")
    
    if not arquivos_mq4:
        print("⚠️ Nenhum arquivo .mq4 encontrado na pasta All_MQ4")
        return
    
    # Processa cada arquivo
    processados = 0
    erros = 0
    
    for i, arquivo in enumerate(arquivos_mq4, 1):
        try:
            print(f"\n[{i}/{len(arquivos_mq4)}] Processando: {arquivo.name}")
            
            # Analisa o arquivo
            analysis = analyzer.analyze_file(str(arquivo))
            
            if analysis:
                # Gera metadados
                metadata = analyzer.generate_metadata(analysis)
                
                # Salva metadados
                metadata_file = output_dir / "Metadata" / f"{arquivo.stem}.meta.json"
                metadata_file.parent.mkdir(parents=True, exist_ok=True)
                
                import json
                with open(metadata_file, 'w', encoding='utf-8') as f:
                    json.dump(metadata, f, indent=2, ensure_ascii=False)
                
                print(f"✅ Processado: {arquivo.name}")
                print(f"   Tipo: {analysis.get('type', 'Unknown')}")
                print(f"   Estratégia: {analysis.get('strategy', 'Unknown')}")
                print(f"   FTMO Score: {analysis.get('ftmo_compliance', {}).get('score', 0)}/7")
                print(f"   Metadados salvos em: {metadata_file}")
                
                processados += 1
            else:
                print(f"⚠️ Não foi possível analisar: {arquivo.name}")
                erros += 1
                
        except Exception as e:
            print(f"❌ Erro ao processar {arquivo.name}: {e}")
            erros += 1
    
    print(f"\n📊 RESUMO DO PROCESSAMENTO:")
    print(f"   Total de arquivos: {len(arquivos_mq4)}")
    print(f"   Processados com sucesso: {processados}")
    print(f"   Erros: {erros}")
    print(f"   Taxa de sucesso: {(processados/len(arquivos_mq4)*100):.1f}%")

if __name__ == "__main__":
    print("🚀 INICIANDO PROCESSAMENTO DA PASTA ALL_MQ4")
    print("=" * 50)
    processar_pasta_all_mq4()
    print("\n✅ PROCESSAMENTO CONCLUÍDO!")