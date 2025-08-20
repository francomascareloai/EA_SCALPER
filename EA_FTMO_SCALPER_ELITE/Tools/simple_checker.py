#!/usr/bin/env python3
"""
EA FTMO Scalper Elite - Simple Checker
Verificação simples de estrutura e dependências
"""

import os
import re
from pathlib import Path

def check_file_structure():
    """Verifica estrutura básica dos arquivos"""
    print("🔍 EA FTMO SCALPER ELITE - VERIFICAÇÃO DE ESTRUTURA")
    print("=" * 60)
    
    # Arquivos principais
    files_to_check = [
        "MQL5_Source/EA_FTMO_Scalper_Elite.mq5",
        "MQL5_Source/Source/Core/DataStructures.mqh",
        "MQL5_Source/Source/Core/Interfaces.mqh",
        "MQL5_Source/Source/Core/Logger.mqh",
        "MQL5_Source/Source/Core/ConfigManager.mqh",
        "MQL5_Source/Source/Core/CacheManager.mqh",
        "MQL5_Source/Source/Core/PerformanceAnalyzer.mqh",
        "MQL5_Source/Source/Strategies/ICT/OrderBlockDetector.mqh",
        "MQL5_Source/Source/Strategies/ICT/FVGDetector.mqh",
        "MQL5_Source/Source/Strategies/ICT/LiquidityDetector.mqh",
        "MQL5_Source/Source/Strategies/ICT/MarketStructureAnalyzer.mqh"
    ]
    
    total_lines = 0
    total_size = 0
    missing_files = []
    
    print("📁 Verificando arquivos:")
    for file_path in files_to_check:
        path = Path(file_path)
        if path.exists():
            size = path.stat().st_size
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                lines = len(f.readlines())
            
            total_lines += lines
            total_size += size
            
            print(f"  ✅ {path.name:<30} ({lines:>4} linhas, {size:>6} bytes)")
        else:
            missing_files.append(file_path)
            print(f"  ❌ {path.name:<30} (NÃO ENCONTRADO)")
    
    print(f"\n📊 ESTATÍSTICAS:")
    print(f"  • Total de arquivos: {len(files_to_check)}")
    print(f"  • Arquivos encontrados: {len(files_to_check) - len(missing_files)}")
    print(f"  • Total de linhas: {total_lines:,}")
    print(f"  • Tamanho total: {total_size:,} bytes")
    
    if missing_files:
        print(f"\n❌ ARQUIVOS AUSENTES:")
        for file in missing_files:
            print(f"  • {file}")
        return False
    
    return True

def check_includes():
    """Verifica includes do arquivo principal"""
    print("\n🔗 VERIFICAÇÃO DE INCLUDES:")
    print("-" * 40)
    
    ea_file = Path("MQL5_Source/EA_FTMO_Scalper_Elite.mq5")
    if not ea_file.exists():
        print("❌ Arquivo principal não encontrado!")
        return False
    
    with open(ea_file, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    # Extrair includes
    includes = re.findall(r'#include\s+"([^"]+)"', content)
    
    print(f"📋 Includes encontrados: {len(includes)}")
    
    missing_includes = []
    for include in includes:
        include_path = Path("MQL5_Source") / include
        if include_path.exists():
            print(f"  ✅ {include}")
        else:
            print(f"  ❌ {include} (NÃO ENCONTRADO)")
            missing_includes.append(include)
    
    return len(missing_includes) == 0

def check_ftmo_features():
    """Verifica características FTMO no código"""
    print("\n🛡️  VERIFICAÇÃO FTMO COMPLIANCE:")
    print("-" * 40)
    
    ea_file = Path("MQL5_Source/EA_FTMO_Scalper_Elite.mq5")
    if not ea_file.exists():
        print("❌ Arquivo principal não encontrado!")
        return False
    
    with open(ea_file, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    ftmo_features = [
        ("Max_Risk_Per_Trade", "Risco por trade"),
        ("Daily_Loss_Limit", "Limite de perda diária"),
        ("Max_Drawdown_Limit", "Limite de drawdown"),
        ("News_Filter", "Filtro de notícias"),
        ("StopLoss", "Stop Loss"),
        ("TakeProfit", "Take Profit")
    ]
    
    found_features = []
    missing_features = []
    
    for feature, description in ftmo_features:
        if feature in content:
            found_features.append((feature, description))
            print(f"  ✅ {description}")
        else:
            missing_features.append((feature, description))
            print(f"  ⚠️  {description} (não encontrado diretamente)")
    
    # Verificar martingale/grid (não permitido)
    dangerous_patterns = ["martingale", "grid", "recovery"]
    dangerous_found = []
    
    for pattern in dangerous_patterns:
        if pattern.lower() in content.lower():
            dangerous_found.append(pattern)
    
    if dangerous_found:
        print(f"\n⚠️  ATENÇÃO - Padrões perigosos encontrados:")
        for pattern in dangerous_found:
            print(f"  • {pattern}")
    
    return len(missing_features) <= 2  # Tolerância para algumas features

def check_basic_syntax():
    """Verificação básica de sintaxe"""
    print("\n🔧 VERIFICAÇÃO BÁSICA DE SINTAXE:")
    print("-" * 40)
    
    ea_file = Path("MQL5_Source/EA_FTMO_Scalper_Elite.mq5")
    if not ea_file.exists():
        print("❌ Arquivo principal não encontrado!")
        return False
    
    with open(ea_file, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    # Verificações básicas
    checks = [
        ("OnInit()", "Função OnInit encontrada"),
        ("OnTick()", "Função OnTick encontrada"),
        ("OnDeinit()", "Função OnDeinit encontrada"),
        ("class", "Classes definidas"),
        ("input", "Parâmetros de entrada"),
        ("#include", "Includes definidos")
    ]
    
    all_good = True
    for pattern, description in checks:
        if pattern in content:
            print(f"  ✅ {description}")
        else:
            print(f"  ❌ {description}")
            all_good = False
    
    # Contar chaves balanceadas
    open_braces = content.count('{')
    close_braces = content.count('}')
    
    if open_braces == close_braces:
        print(f"  ✅ Chaves balanceadas ({open_braces} pares)")
    else:
        print(f"  ❌ Chaves desbalanceadas ({open_braces} abertas, {close_braces} fechadas)")
        all_good = False
    
    return all_good

def main():
    """Função principal"""
    print()
    
    # Executar verificações
    structure_ok = check_file_structure()
    includes_ok = check_includes()
    ftmo_ok = check_ftmo_features()
    syntax_ok = check_basic_syntax()
    
    # Resultado final
    print("\n" + "=" * 60)
    print("🎯 RESULTADO FINAL:")
    print("=" * 60)
    
    if structure_ok and includes_ok and syntax_ok:
        print("✅ ESTRUTURA: OK")
        print("✅ INCLUDES: OK") 
        print("✅ SINTAXE BÁSICA: OK")
        
        if ftmo_ok:
            print("✅ FTMO COMPLIANCE: OK")
        else:
            print("⚠️  FTMO COMPLIANCE: VERIFICAR")
        
        print("\n🚀 STATUS: PRONTO PARA COMPILAÇÃO!")
        print("\n📋 PRÓXIMOS PASSOS:")
        print("1. Abra o MetaEditor (MetaTrader 5)")
        print("2. Abra: MQL5_Source/EA_FTMO_Scalper_Elite.mq5")
        print("3. Pressione F7 para compilar")
        print("4. Verifique se não há erros")
        print("5. Execute testes no Strategy Tester")
        
        return True
    else:
        print("❌ ESTRUTURA: PROBLEMAS ENCONTRADOS")
        print("\n🔧 CORRIJA OS PROBLEMAS ANTES DE COMPILAR!")
        return False

if __name__ == "__main__":
    success = main()
    print("\n" + "=" * 60)
    exit(0 if success else 1)