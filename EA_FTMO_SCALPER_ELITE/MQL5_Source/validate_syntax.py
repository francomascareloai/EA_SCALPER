#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de Validação de Sintaxe MQL5
Verifica possíveis erros de sintaxe no código MQL5
"""

import os
import re
from pathlib import Path

def check_mql5_syntax(file_path):
    """Verifica sintaxe básica de arquivo MQL5"""
    errors = []
    warnings = []
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            lines = content.split('\n')
    except Exception as e:
        return [f"Erro ao ler arquivo: {e}"], []
    
    # Verificações básicas
    for i, line in enumerate(lines, 1):
        line_stripped = line.strip()
        
        # Verificar chaves não balanceadas
        open_braces = line.count('{')
        close_braces = line.count('}')
        
        # Verificar ponto e vírgula em declarações
        if (line_stripped.endswith('{') or 
            line_stripped.startswith('//') or 
            line_stripped.startswith('/*') or 
            line_stripped.startswith('*') or
            line_stripped.startswith('#') or
            line_stripped == '' or
            line_stripped.endswith('}') or
            'enum' in line_stripped or
            'struct' in line_stripped or
            'class' in line_stripped):
            continue
            
        # Verificar se linha de código não termina com ; ou {
        if (line_stripped and 
            not line_stripped.endswith(';') and 
            not line_stripped.endswith('{') and
            not line_stripped.endswith('}') and
            not line_stripped.endswith('*/') and
            not line_stripped.startswith('if') and
            not line_stripped.startswith('else') and
            not line_stripped.startswith('for') and
            not line_stripped.startswith('while') and
            not line_stripped.startswith('switch') and
            not line_stripped.startswith('case') and
            not line_stripped.startswith('default') and
            '::' not in line_stripped):
            warnings.append(f"Linha {i}: Possível ponto e vírgula ausente: {line_stripped}")
    
    # Verificar balanceamento de chaves
    open_count = content.count('{')
    close_count = content.count('}')
    if open_count != close_count:
        errors.append(f"Chaves não balanceadas: {open_count} aberturas, {close_count} fechamentos")
    
    # Verificar includes
    includes = re.findall(r'#include\s+["<]([^"<>]+)[">]', content)
    for include in includes:
        if not include.endswith('.mqh') and not include.startswith('<'):
            warnings.append(f"Include suspeito: {include}")
    
    # Verificar declarações de função
    function_pattern = r'\b(void|int|double|bool|string|datetime)\s+\w+\s*\([^)]*\)\s*{?'
    functions = re.findall(function_pattern, content)
    
    return errors, warnings

def validate_project():
    """Valida todo o projeto MQL5"""
    base_path = Path("C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/EA_FTMO_SCALPER_ELITE/MQL5_Source")
    
    print("=== VALIDAÇÃO DE SINTAXE MQL5 ===")
    print(f"Diretório base: {base_path}")
    print()
    
    total_errors = 0
    total_warnings = 0
    
    # Verificar arquivo principal
    main_file = base_path / "EA_FTMO_Scalper_Elite.mq5"
    if main_file.exists():
        print(f"📁 Verificando: {main_file.name}")
        errors, warnings = check_mql5_syntax(main_file)
        
        if errors:
            print("❌ ERROS:")
            for error in errors:
                print(f"   {error}")
            total_errors += len(errors)
        
        if warnings:
            print("⚠️  AVISOS:")
            for warning in warnings:
                print(f"   {warning}")
            total_warnings += len(warnings)
        
        if not errors and not warnings:
            print("✅ Arquivo principal OK")
        print()
    
    # Verificar arquivos Include
    include_path = base_path / "Include"
    if include_path.exists():
        for mqh_file in include_path.glob("*.mqh"):
            print(f"📁 Verificando: Include/{mqh_file.name}")
            errors, warnings = check_mql5_syntax(mqh_file)
            
            if errors:
                print("❌ ERROS:")
                for error in errors:
                    print(f"   {error}")
                total_errors += len(errors)
            
            if warnings:
                print("⚠️  AVISOS:")
                for warning in warnings:
                    print(f"   {warning}")
                total_warnings += len(warnings)
            
            if not errors and not warnings:
                print("✅ OK")
            print()
    
    # Verificar arquivos Source
    source_path = base_path / "Source"
    if source_path.exists():
        for mqh_file in source_path.rglob("*.mqh"):
            rel_path = mqh_file.relative_to(base_path)
            print(f"📁 Verificando: {rel_path}")
            errors, warnings = check_mql5_syntax(mqh_file)
            
            if errors:
                print("❌ ERROS:")
                for error in errors:
                    print(f"   {error}")
                total_errors += len(errors)
            
            if warnings:
                print("⚠️  AVISOS:")
                for warning in warnings:
                    print(f"   {warning}")
                total_warnings += len(warnings)
            
            if not errors and not warnings:
                print("✅ OK")
            print()
    
    print("=== RESUMO DA VALIDAÇÃO ===")
    print(f"Total de erros: {total_errors}")
    print(f"Total de avisos: {total_warnings}")
    
    if total_errors == 0:
        print("🎉 Nenhum erro crítico encontrado!")
        return True
    else:
        print("💥 Erros encontrados que precisam ser corrigidos.")
        return False

if __name__ == "__main__":
    validate_project()