#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Limpeza Imediata - Primeira Fase
===============================

Script simples para fazer a limpeza inicial mais urgente do projeto.
"""

import os
import shutil
from pathlib import Path
from datetime import datetime

def create_basic_structure():
    """Cria estrutura básica necessária"""
    base_path = Path("c:/Users/Admin/Documents/EA_SCALPER_XAUUSD")
    
    # Diretórios básicos necessários
    dirs_to_create = [
        "TOOLS_ORGANIZED/Python_Scripts",
        "DOCS_ORGANIZED/Reports", 
        "DOCS_ORGANIZED/Guides",
        "DOCS_ORGANIZED/Technical",
        "CONFIG_ORGANIZED/JSON_Files",
        "CONFIG_ORGANIZED/Logs",
        "TEMP_REORGANIZATION"
    ]
    
    print("📁 Criando estrutura básica...")
    for dir_name in dirs_to_create:
        dir_path = base_path / dir_name
        dir_path.mkdir(parents=True, exist_ok=True)
        print(f"   ✅ {dir_name}")

def move_python_scripts():
    """Move os scripts Python mais importantes"""
    base_path = Path("c:/Users/Admin/Documents/EA_SCALPER_XAUUSD")
    target_dir = base_path / "TOOLS_ORGANIZED" / "Python_Scripts"
    
    print("\n🐍 Organizando scripts Python críticos...")
    
    # Scripts críticos para mover
    critical_scripts = [
        'classificador_auto_avaliacao.py',
        'classificador_otimizado.py', 
        'sistema_diagnostico_avancado.py',
        'sistema_processamento_otimizado.py',
        'coordenador_multi_agente.py',
        'automated_project_reorganizer.py'
    ]
    
    moved_count = 0
    for script in critical_scripts:
        source = base_path / script
        if source.exists():
            target = target_dir / script
            try:
                shutil.move(str(source), str(target))
                print(f"   ✅ {script}")
                moved_count += 1
            except Exception as e:
                print(f"   ❌ Erro ao mover {script}: {e}")
    
    print(f"📊 Scripts movidos: {moved_count}")

def organize_documentation():
    """Organiza documentação básica"""
    base_path = Path("c:/Users/Admin/Documents/EA_SCALPER_XAUUSD")
    
    print("\n📚 Organizando documentação...")
    
    # Relatórios
    reports_dir = base_path / "DOCS_ORGANIZED" / "Reports"
    relatorio_files = list(base_path.glob("RELATORIO_*.md"))
    
    moved_reports = 0
    for report in relatorio_files[:10]:  # Primeiros 10 para teste
        try:
            target = reports_dir / report.name
            shutil.move(str(report), str(target))
            print(f"   📋 {report.name}")
            moved_reports += 1
        except Exception as e:
            print(f"   ❌ Erro: {e}")
    
    # Guias
    guides_dir = base_path / "DOCS_ORGANIZED" / "Guides"
    guia_files = list(base_path.glob("GUIA_*.md"))
    
    moved_guides = 0
    for guide in guia_files[:5]:  # Primeiros 5 para teste
        try:
            target = guides_dir / guide.name
            shutil.move(str(guide), str(target))
            print(f"   📖 {guide.name}")
            moved_guides += 1
        except Exception as e:
            print(f"   ❌ Erro: {e}")
    
    print(f"📊 Documentos organizados: {moved_reports + moved_guides}")

def organize_config_files():
    """Organiza arquivos de configuração"""
    base_path = Path("c:/Users/Admin/Documents/EA_SCALPER_XAUUSD")
    
    print("\n⚙️ Organizando configurações...")
    
    # JSON configs
    json_dir = base_path / "CONFIG_ORGANIZED" / "JSON_Files"
    json_files = list(base_path.glob("*.json"))
    
    moved_configs = 0
    for json_file in json_files[:10]:  # Primeiros 10 para teste
        if json_file.stat().st_size < 10 * 1024 * 1024:  # Apenas arquivos < 10MB
            try:
                target = json_dir / json_file.name
                shutil.copy2(str(json_file), str(target))  # Copy ao invés de move para segurança
                print(f"   ⚙️ {json_file.name}")
                moved_configs += 1
            except Exception as e:
                print(f"   ❌ Erro: {e}")
    
    # Logs
    logs_dir = base_path / "CONFIG_ORGANIZED" / "Logs"
    log_files = list(base_path.glob("*.log"))
    
    moved_logs = 0
    for log_file in log_files[:5]:  # Primeiros 5 para teste
        try:
            target = logs_dir / log_file.name
            shutil.copy2(str(log_file), str(target))
            print(f"   📋 {log_file.name}")
            moved_logs += 1
        except Exception as e:
            print(f"   ❌ Erro: {e}")
    
    print(f"📊 Configurações organizadas: {moved_configs + moved_logs}")

def generate_simple_report():
    """Gera relatório simples da reorganização"""
    base_path = Path("c:/Users/Admin/Documents/EA_SCALPER_XAUUSD")
    
    # Contar arquivos restantes na raiz
    py_files = len(list(base_path.glob("*.py")))
    md_files = len(list(base_path.glob("*.md")))
    json_files = len(list(base_path.glob("*.json")))
    
    report = f"""# 📊 RELATÓRIO DA PRIMEIRA FASE DE REORGANIZAÇÃO

## ✅ Estrutura Criada
- ✅ TOOLS_ORGANIZED/ - Scripts Python organizados
- ✅ DOCS_ORGANIZED/ - Documentação categorizada  
- ✅ CONFIG_ORGANIZED/ - Configurações centralizadas

## 📈 Status Atual (Pós Primeira Fase)
- 🐍 Scripts Python restantes na raiz: {py_files}
- 📚 Documentos MD restantes na raiz: {md_files}  
- ⚙️ Arquivos JSON restantes na raiz: {json_files}

## 🎯 Próximos Passos
1. Revisar arquivos organizados
2. Continuar movendo arquivos restantes
3. Implementar estrutura completa
4. Atualizar referências e imports

---
*Reorganização parcial realizada em: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*
"""
    
    report_file = base_path / "RELATORIO_REORGANIZACAO_FASE1.md"
    with open(report_file, 'w', encoding='utf-8') as f:
        f.write(report)
    
    print(f"\n📋 Relatório salvo: {report_file}")
    
    return py_files, md_files, json_files

def main():
    """Executa limpeza inicial"""
    print("🚀 INICIANDO LIMPEZA IMEDIATA - FASE 1")
    print("="*50)
    
    try:
        create_basic_structure()
        move_python_scripts()
        organize_documentation()
        organize_config_files()
        
        py_count, md_count, json_count = generate_simple_report()
        
        print("\n" + "="*50)
        print("✅ PRIMEIRA FASE CONCLUÍDA!")
        print("="*50)
        print(f"📊 Status atual:")
        print(f"   🐍 Python files na raiz: {py_count}")
        print(f"   📚 MD files na raiz: {md_count}")
        print(f"   ⚙️ JSON files na raiz: {json_count}")
        print(f"\n📁 Verifique as pastas criadas:")
        print(f"   - TOOLS_ORGANIZED/")
        print(f"   - DOCS_ORGANIZED/")
        print(f"   - CONFIG_ORGANIZED/")
        
    except Exception as e:
        print(f"\n❌ ERRO: {e}")

if __name__ == "__main__":
    main()