#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
TradeDev_Master - Verificação Completa das Bibliotecas
Script para verificar se todas as bibliotecas foram criadas e estão funcionais
"""

import os
import json
from pathlib import Path
from datetime import datetime

def verify_all_libraries():
    """
    Verifica se todas as bibliotecas necessárias foram criadas
    """
    
    # Definir caminhos
    project_root = Path("C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/EA_FTMO_SCALPER_ELITE/MQL5_Source")
    source_dir = project_root / "Source"
    
    # Bibliotecas esperadas
    expected_libraries = {
        "Core": [
            "DataStructures.mqh",
            "Interfaces.mqh", 
            "Logger.mqh",
            "ConfigManager.mqh",
            "CacheManager.mqh",
            "PerformanceAnalyzer.mqh"
        ],
        "ICT": [
            "OrderBlockDetector.mqh",
            "FVGDetector.mqh",
            "LiquidityDetector.mqh",
            "MarketStructureAnalyzer.mqh"
        ],
        "Root": [
            "AdvancedClasses.mqh"
        ]
    }
    
    verification_report = {
        "timestamp": datetime.now().isoformat(),
        "project_path": str(project_root),
        "libraries_status": {},
        "summary": {
            "total_expected": 0,
            "total_found": 0,
            "missing_libraries": [],
            "verification_success": False
        }
    }
    
    print("=== TradeDev_Master - Verificação Completa das Bibliotecas ===\n")
    
    # Verificar cada categoria
    for category, libraries in expected_libraries.items():
        print(f"📁 Verificando categoria: {category}")
        
        if category == "Root":
            category_path = source_dir
        else:
            category_path = source_dir / category
            
        verification_report["libraries_status"][category] = {
            "path": str(category_path),
            "libraries": {},
            "found_count": 0,
            "expected_count": len(libraries)
        }
        
        for library in libraries:
            library_path = category_path / library
            exists = library_path.exists()
            
            if exists:
                # Verificar tamanho do arquivo
                file_size = library_path.stat().st_size
                status = "✓ Encontrada"
                verification_report["libraries_status"][category]["libraries"][library] = {
                    "exists": True,
                    "path": str(library_path),
                    "size_bytes": file_size,
                    "size_kb": round(file_size / 1024, 2)
                }
                verification_report["libraries_status"][category]["found_count"] += 1
                verification_report["summary"]["total_found"] += 1
            else:
                status = "✗ Não encontrada"
                verification_report["libraries_status"][category]["libraries"][library] = {
                    "exists": False,
                    "path": str(library_path)
                }
                verification_report["summary"]["missing_libraries"].append(f"{category}/{library}")
            
            verification_report["summary"]["total_expected"] += 1
            print(f"  {status}: {library}")
        
        print(f"  Resultado: {verification_report['libraries_status'][category]['found_count']}/{verification_report['libraries_status'][category]['expected_count']} encontradas\n")
    
    # Verificar EA principal
    ea_path = project_root / "EAs" / "FTMO_Ready" / "EA_FTMO_Scalper_Elite.mq5"
    ea_exists = ea_path.exists()
    
    verification_report["ea_status"] = {
        "path": str(ea_path),
        "exists": ea_exists
    }
    
    print(f"🤖 EA Principal: {'✓ Encontrado' if ea_exists else '✗ Não encontrado'} - {ea_path}\n")
    
    # Resumo final
    success_rate = (verification_report["summary"]["total_found"] / verification_report["summary"]["total_expected"]) * 100
    verification_report["summary"]["success_rate"] = round(success_rate, 2)
    verification_report["summary"]["verification_success"] = (success_rate == 100.0 and ea_exists)
    
    print("=== RESUMO DA VERIFICAÇÃO ===")
    print(f"📊 Bibliotecas encontradas: {verification_report['summary']['total_found']}/{verification_report['summary']['total_expected']} ({success_rate:.1f}%)")
    print(f"🤖 EA Principal: {'✓' if ea_exists else '✗'}")
    
    if verification_report["summary"]["missing_libraries"]:
        print(f"❌ Bibliotecas faltando: {', '.join(verification_report['summary']['missing_libraries'])}")
    
    if verification_report["summary"]["verification_success"]:
        print("\n🎉 VERIFICAÇÃO COMPLETA: Todas as bibliotecas e EA estão presentes!")
        print("✅ Sistema pronto para compilação e teste")
    else:
        print("\n⚠️  VERIFICAÇÃO INCOMPLETA: Algumas bibliotecas ou EA estão faltando")
        print("❌ Sistema não está pronto para uso")
    
    # Salvar relatório
    report_path = Path("C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/Tools/library_verification_report.json")
    try:
        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump(verification_report, f, indent=2, ensure_ascii=False)
        print(f"\n📄 Relatório salvo: {report_path}")
    except Exception as e:
        print(f"\n❌ Erro ao salvar relatório: {e}")
    
    return verification_report["summary"]["verification_success"]

def check_ea_includes():
    """
    Verifica se o EA principal tem todos os includes necessários
    """
    
    ea_path = Path("C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/EA_FTMO_SCALPER_ELITE/MQL5_Source/EAs/FTMO_Ready/EA_FTMO_Scalper_Elite.mq5")
    
    if not ea_path.exists():
        print("❌ EA principal não encontrado para verificação de includes")
        return False
    
    print("\n=== VERIFICAÇÃO DE INCLUDES DO EA ===")
    
    expected_includes = [
        "Source/Core/DataStructures.mqh",
        "Source/Core/Interfaces.mqh",
        "Source/Core/Logger.mqh",
        "Source/Core/ConfigManager.mqh",
        "Source/Core/CacheManager.mqh",
        "Source/Core/PerformanceAnalyzer.mqh",
        "Source/ICT/OrderBlockDetector.mqh",
        "Source/ICT/FVGDetector.mqh",
        "Source/ICT/LiquidityDetector.mqh",
        "Source/ICT/MarketStructureAnalyzer.mqh",
        "Source/AdvancedClasses.mqh"
    ]
    
    try:
        with open(ea_path, 'r', encoding='utf-8') as f:
            ea_content = f.read()
        
        includes_found = 0
        for include in expected_includes:
            if include in ea_content:
                print(f"✓ Include encontrado: {include}")
                includes_found += 1
            else:
                print(f"✗ Include faltando: {include}")
        
        success_rate = (includes_found / len(expected_includes)) * 100
        print(f"\n📊 Includes encontrados: {includes_found}/{len(expected_includes)} ({success_rate:.1f}%)")
        
        return success_rate == 100.0
        
    except Exception as e:
        print(f"❌ Erro ao verificar includes do EA: {e}")
        return False

def main():
    """
    Função principal
    """
    libraries_ok = verify_all_libraries()
    includes_ok = check_ea_includes()
    
    print("\n" + "="*60)
    if libraries_ok and includes_ok:
        print("🎯 SISTEMA COMPLETO E PRONTO PARA USO!")
        print("✅ Todas as bibliotecas foram restauradas com sucesso")
        print("✅ Todos os includes estão corretos no EA")
        print("🚀 Próximo passo: Compilar e testar o EA no MetaTrader 5")
    else:
        print("⚠️  SISTEMA INCOMPLETO")
        if not libraries_ok:
            print("❌ Algumas bibliotecas estão faltando")
        if not includes_ok:
            print("❌ Alguns includes estão incorretos no EA")
        print("🔧 Ação necessária: Verificar e corrigir os problemas identificados")

if __name__ == "__main__":
    main()