#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Limpeza de Casos Especiais - Arquivos com Múltiplos Parênteses
Versão: 1.0
Autor: Agente Organizador

Este script remove arquivos com padrões específicos como (1) (2), (2) (1), etc.
"""

import os
import shutil
from pathlib import Path
import re
from datetime import datetime

def find_special_duplicates(source_dir):
    """Encontra arquivos com padrões especiais de duplicação"""
    source_path = Path(source_dir)
    
    if not source_path.exists():
        print(f"❌ Diretório não encontrado: {source_dir}")
        return []
    
    # Padrões para detectar
    patterns = [
        r'.*\(\d+\)\s*\(\d+\)\.mq5$',  # (1) (2).mq5
        r'.*\(\d+\)\s+\(\d+\)\.mq5$',  # (1) (2).mq5 com espaço
        r'.*\s\(\d+\)\s*\(\d+\)\.mq5$', # nome (1) (2).mq5
    ]
    
    special_files = []
    
    for mq5_file in source_path.glob("*.mq5"):
        filename = mq5_file.name
        
        for pattern in patterns:
            if re.match(pattern, filename, re.IGNORECASE):
                special_files.append(mq5_file)
                break
    
    return special_files

def clean_special_cases(source_dir, dry_run=True):
    """Remove casos especiais de duplicação"""
    print("🧹 LIMPEZA DE CASOS ESPECIAIS")
    print("=" * 40)
    print(f"📂 Pasta: {source_dir}")
    print(f"🔧 Modo: {'🟡 SIMULAÇÃO' if dry_run else '🔴 EXECUÇÃO REAL'}")
    print("=" * 40)
    
    special_files = find_special_duplicates(source_dir)
    
    if not special_files:
        print("✅ Nenhum caso especial encontrado!")
        return
    
    print(f"\n🔍 Encontrados {len(special_files)} arquivos com padrões especiais:")
    print("-" * 50)
    
    duplicates_dir = Path(source_dir).parent / "Duplicates_Removed_Special"
    total_size = 0
    
    for i, file_path in enumerate(special_files, 1):
        file_size = file_path.stat().st_size
        total_size += file_size
        
        print(f"{i:2d}. {file_path.name} ({file_size/1024:.1f} KB)")
        
        if not dry_run:
            # Cria pasta se não existir
            duplicates_dir.mkdir(exist_ok=True)
            
            # Move arquivo
            dest_path = duplicates_dir / file_path.name
            counter = 1
            
            # Resolve conflitos de nome
            while dest_path.exists():
                stem = file_path.stem
                suffix = file_path.suffix
                dest_path = duplicates_dir / f"{stem}_special{counter}{suffix}"
                counter += 1
            
            try:
                shutil.move(str(file_path), str(dest_path))
                print(f"    ✅ Movido para: {dest_path.name}")
            except Exception as e:
                print(f"    ❌ Erro: {e}")
    
    print("\n" + "=" * 50)
    print("📊 RESUMO")
    print("=" * 50)
    
    if dry_run:
        print(f"📁 Arquivos que seriam removidos: {len(special_files)}")
        print(f"💾 Espaço que seria economizado: {total_size/1024/1024:.2f} MB")
        print("\n💡 Para executar a remoção real, execute:")
        print("   python cleanup_special_cases.py --execute")
    else:
        print(f"✅ Arquivos removidos: {len(special_files)}")
        print(f"💾 Espaço economizado: {total_size/1024/1024:.2f} MB")
        print(f"📁 Arquivos movidos para: {duplicates_dir}")
    
    print("\n🎉 Limpeza de casos especiais concluída!")

def main():
    """Função principal"""
    import sys
    
    source_dir = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\CODIGO_FONTE_LIBRARY\MQL5_Source\All_MQ5"
    
    # Verifica argumentos
    execute_mode = '--execute' in sys.argv or '-e' in sys.argv
    dry_run = not execute_mode
    
    clean_special_cases(source_dir, dry_run=dry_run)
    
    input("\n⏸️ Pressione Enter para sair...")

if __name__ == "__main__":
    main()