#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para preparar amostra expandida de arquivos MQ4 para análise crítica
"""

import os
import shutil
import glob
from pathlib import Path

def preparar_amostra_expandida():
    print("🔄 Preparando amostra expandida para análise crítica...")
    
    # Criar diretório de destino
    input_expandido = Path("Input_Expandido")
    input_expandido.mkdir(exist_ok=True)
    
    # Limpar diretório existente
    for arquivo in input_expandido.glob("*"):
        if arquivo.is_file():
            arquivo.unlink()
    
    # Buscar arquivos MQ4 da pasta All_MQ4 (se existir)
    all_mq4_path = Path("../All_MQ4")
    mq4_files = []
    if all_mq4_path.exists():
        mq4_files = list(all_mq4_path.glob("*.mq4"))[:30]
        print(f"📁 Encontrados {len(mq4_files)} arquivos em All_MQ4")
    else:
        print("⚠️ Pasta All_MQ4 não encontrada, usando apenas arquivos existentes")
    
    # Buscar arquivos existentes na pasta Input
    input_path = Path("Input")
    existing_files = []
    if input_path.exists():
        existing_files = list(input_path.glob("*.mq4"))
        print(f"📁 Encontrados {len(existing_files)} arquivos em Input")
    
    # Buscar arquivos em outras pastas do projeto
    outras_pastas = [
        "../Demo_Tests/Input",
        "../Demo_Visual/Input",
        "../CODIGO_FONTE_LIBRARY/MQL4_Source/EAs",
        "../CODIGO_FONTE_LIBRARY/MQL4_Source/Misc"
    ]
    
    outros_files = []
    for pasta in outras_pastas:
        pasta_path = Path(pasta)
        if pasta_path.exists():
            files_pasta = list(pasta_path.rglob("*.mq4"))[:10]  # Máximo 10 por pasta
            outros_files.extend(files_pasta)
            print(f"📁 Encontrados {len(files_pasta)} arquivos em {pasta}")
    
    # Combinar todos os arquivos
    all_files = mq4_files + existing_files + outros_files
    
    # Remover duplicatas baseado no nome do arquivo
    arquivos_unicos = {}
    for arquivo in all_files:
        nome = arquivo.name
        if nome not in arquivos_unicos:
            arquivos_unicos[nome] = arquivo
    
    arquivos_finais = list(arquivos_unicos.values())[:50]  # Máximo 50 arquivos
    
    print(f"📊 Total de arquivos únicos selecionados: {len(arquivos_finais)}")
    
    # Copiar arquivos para o diretório expandido
    copiados = 0
    for arquivo in arquivos_finais:
        try:
            destino = input_expandido / arquivo.name
            shutil.copy2(arquivo, destino)
            copiados += 1
            print(f"✅ Copiado: {arquivo.name}")
        except Exception as e:
            print(f"❌ Erro ao copiar {arquivo.name}: {e}")
    
    print(f"\n🎯 Amostra expandida preparada com sucesso!")
    print(f"📈 Total de arquivos copiados: {copiados}")
    print(f"📂 Localização: {input_expandido.absolute()}")
    
    # Listar arquivos copiados
    arquivos_copiados = list(input_expandido.glob("*.mq4"))
    print(f"\n📋 Arquivos na amostra expandida:")
    for i, arquivo in enumerate(arquivos_copiados, 1):
        print(f"  {i:2d}. {arquivo.name}")
    
    return len(arquivos_copiados)

if __name__ == "__main__":
    try:
        total = preparar_amostra_expandida()
        print(f"\n✨ Processo concluído! {total} arquivos prontos para análise.")
    except Exception as e:
        print(f"💥 Erro durante a preparação: {e}")
        import traceback
        traceback.print_exc()