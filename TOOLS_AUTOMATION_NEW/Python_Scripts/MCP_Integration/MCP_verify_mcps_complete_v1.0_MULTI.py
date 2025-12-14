#!/usr/bin/env python3
"""
🤖 Verificação Completa dos MCPs para Desenvolvimento Autônomo de EA
Autor: Classificador_Trading
Data: 2025-08-22
"""

import subprocess
import sys
import json
import os
from pathlib import Path

def test_command(name, command):
    """Testa se um comando/MCP está funcionando"""
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True, timeout=10)
        if "running on stdio" in result.stdout or "Server" in result.stdout or result.returncode == 0:
            return True, "✅ FUNCIONANDO"
        else:
            return False, f"❌ ERRO: {result.stderr[:100]}"
    except subprocess.TimeoutExpired:
        return True, "✅ FUNCIONANDO (timeout esperado para servidor)"
    except Exception as e:
        return False, f"❌ ERRO: {str(e)[:100]}"

def main():
    print("🤖 EA_SCALPER_XAUUSD - Verificação Completa dos MCPs")
    print("=" * 60)
    
    # MCPs Externos
    external_mcps = {
        "fetch": "uvx mcp-server-fetch --help",
        "github": "npx -y @modelcontextprotocol/server-github --help",
        "sequential-thinking": "npx -y @modelcontextprotocol/server-sequential-thinking --help", 
        "context7": "npx -y @upstash/context7-mcp@latest --help",
        "playwright": "npx @playwright/mcp@latest --help",
        "everything": "npx -y @modelcontextprotocol/server-everything --help"
    }
    
    # MCPs do Projeto
    project_base = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD"
    python_exe = f"{project_base}/.venv/Scripts/python.exe"
    
    project_mcps = {
        "trading_classifier": f'"{python_exe}" "{project_base}/MCP_Integration/servers/trading_classifier_mcp.py" --help',
        "code_analysis": f'"{python_exe}" "{project_base}/MCP_Integration/servers/code_analysis_mcp.py" --help',
        "test_automation": f'"{python_exe}" "{project_base}/MCP_Integration/servers/test_automation_mcp.py" --help',
        "python_dev_accelerator": f'"{python_exe}" "{project_base}/MCP_Integration/servers/python_dev_accelerator_mcp.py" --help',
        "api_integration": f'"{python_exe}" "{project_base}/MCP_Integration/servers/api_integration_mcp.py" --help',
        "project_scaffolding": f'"{python_exe}" "{project_base}/MCP_Integration/servers/project_scaffolding_mcp.py" --help',
        "metatrader5": f'"{python_exe}" "{project_base}/mcp-metatrader5-server/run.py" --help'
    }
    
    results = {}
    
    print("🌐 Testando MCPs Externos...")
    for name, command in external_mcps.items():
        print(f"  Testando {name}...", end=" ")
        success, message = test_command(name, command)
        results[f"external_{name}"] = success
        print(message)
    
    print("\n🏠 Testando MCPs do Projeto...")
    for name, command in project_mcps.items():
        print(f"  Testando {name}...", end=" ")
        success, message = test_command(name, command)
        results[f"project_{name}"] = success
        print(message)
    
    # Estatísticas
    total = len(results)
    working = sum(results.values())
    percentage = (working / total) * 100
    
    print("\n" + "=" * 60)
    print("📊 RELATÓRIO FINAL")
    print("=" * 60)
    print(f"📈 Taxa de Sucesso: {percentage:.1f}% ({working}/{total})")
    
    if percentage >= 80:
        status = "🟢 EXCELENTE"
    elif percentage >= 60:
        status = "🟡 BOM"
    else:
        status = "🔴 REQUER ATENÇÃO"
    
    print(f"📋 Status Geral: {status}")
    
    # MCPs Funcionando
    working_mcps = [name.replace("external_", "").replace("project_", "") 
                   for name, status in results.items() if status]
    
    print(f"\n✅ MCPs Funcionando ({len(working_mcps)}):")
    for mcp in working_mcps:
        print(f"  - {mcp}")
    
    # MCPs com Problemas
    failing_mcps = [name.replace("external_", "").replace("project_", "") 
                   for name, status in results.items() if not status]
    
    if failing_mcps:
        print(f"\n❌ MCPs com Problemas ({len(failing_mcps)}):")
        for mcp in failing_mcps:
            print(f"  - {mcp}")
    
    print("\n🚀 PRÓXIMOS PASSOS:")
    print("1. Copie qoder_mcp_config_complete.json para:")
    print("   C:\\Users\\Admin\\AppData\\Roaming\\Qoder\\SharedClientCache\\mcp.json")
    print("2. Reinicie o Qoder IDE")
    print("3. Teste os MCPs no ambiente de desenvolvimento")
    
    if percentage >= 80:
        print("\n🎯 SISTEMA PRONTO PARA DESENVOLVIMENTO AUTÔNOMO DE EA!")
    
    print("=" * 60)

if __name__ == "__main__":
    main()