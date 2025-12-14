#!/usr/bin/env python3
"""
Script para testar MCPs Python simulando exatamente como o Trae se conecta
"""

import subprocess
import json
import sys
import os
import time
from pathlib import Path

def setup_environment():
    """Configura as variáveis de ambiente como no mcp.json do Trae"""
    env = os.environ.copy()
    
    # Configurações do mcp.json
    env['PYTHONPATH'] = r'c:\Users\Admin\Documents\EA_SCALPER_XAUUSD'
    env['VIRTUAL_ENV'] = r'c:\Users\Admin\Documents\EA_SCALPER_XAUUSD\.venv'
    env['PATH'] = r'c:\Users\Admin\Documents\EA_SCALPER_XAUUSD\.venv\Scripts;C:\Python313;C:\Python313\Scripts'
    
    return env

def test_mcp_stdio(mcp_path, mcp_name):
    """Testa um MCP específico via stdio"""
    print(f"\n{'='*60}")
    print(f"TESTANDO: {mcp_name}")
    print(f"CAMINHO: {mcp_path}")
    print(f"{'='*60}")
    
    if not os.path.exists(mcp_path):
        print(f"❌ ERRO: Arquivo não encontrado: {mcp_path}")
        return False
    
    # Configurar ambiente
    env = setup_environment()
    cwd = r'c:\Users\Admin\Documents\EA_SCALPER_XAUUSD'
    
    # Usar o Python do ambiente virtual
    python_exe = r'c:\Users\Admin\Documents\EA_SCALPER_XAUUSD\.venv\Scripts\python.exe'
    
    try:
        # Iniciar processo MCP
        print("🚀 Iniciando processo MCP...")
        process = subprocess.Popen(
            [python_exe, mcp_path],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=env,
            cwd=cwd,
            text=True,
            bufsize=0
        )
        
        # Aguardar um pouco para inicialização
        time.sleep(2)
        
        # Verificar se o processo ainda está rodando
        if process.poll() is not None:
            stdout, stderr = process.communicate()
            print(f"❌ PROCESSO TERMINOU PREMATURAMENTE")
            print(f"STDOUT: {stdout}")
            print(f"STDERR: {stderr}")
            return False
        
        print("✅ Processo iniciado com sucesso")
        
        # Teste 1: Enviar comando initialize
        print("\n📤 Enviando comando 'initialize'...")
        initialize_request = {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "initialize",
            "params": {
                "protocolVersion": "2024-11-05",
                "capabilities": {
                    "roots": {
                        "listChanged": True
                    },
                    "sampling": {}
                },
                "clientInfo": {
                    "name": "Trae",
                    "version": "1.0.0"
                }
            }
        }
        
        request_json = json.dumps(initialize_request) + '\n'
        process.stdin.write(request_json)
        process.stdin.flush()
        
        # Aguardar resposta
        print("⏳ Aguardando resposta...")
        time.sleep(3)
        
        # Ler resposta
        try:
            # Verificar se há dados disponíveis
            import select
            if sys.platform == 'win32':
                # No Windows, usar timeout
                response_line = process.stdout.readline()
            else:
                # No Unix, usar select
                ready, _, _ = select.select([process.stdout], [], [], 5)
                if ready:
                    response_line = process.stdout.readline()
                else:
                    response_line = ""
            
            if response_line:
                print(f"📥 RESPOSTA RECEBIDA: {response_line.strip()}")
                try:
                    response_data = json.loads(response_line.strip())
                    print(f"✅ JSON VÁLIDO: {json.dumps(response_data, indent=2)}")
                except json.JSONDecodeError as e:
                    print(f"❌ ERRO JSON: {e}")
                    print(f"RESPOSTA RAW: {response_line}")
            else:
                print("❌ NENHUMA RESPOSTA RECEBIDA")
        
        except Exception as e:
            print(f"❌ ERRO AO LER RESPOSTA: {e}")
        
        # Teste 2: Listar tools disponíveis
        print("\n📤 Enviando comando 'tools/list'...")
        tools_request = {
            "jsonrpc": "2.0",
            "id": 2,
            "method": "tools/list"
        }
        
        request_json = json.dumps(tools_request) + '\n'
        process.stdin.write(request_json)
        process.stdin.flush()
        
        time.sleep(2)
        
        # Ler resposta tools
        try:
            if sys.platform == 'win32':
                response_line = process.stdout.readline()
            else:
                ready, _, _ = select.select([process.stdout], [], [], 5)
                if ready:
                    response_line = process.stdout.readline()
                else:
                    response_line = ""
            
            if response_line:
                print(f"📥 TOOLS RESPONSE: {response_line.strip()}")
                try:
                    response_data = json.loads(response_line.strip())
                    tools = response_data.get('result', {}).get('tools', [])
                    print(f"✅ TOOLS ENCONTRADAS: {len(tools)}")
                    for tool in tools[:3]:  # Mostrar apenas as primeiras 3
                        print(f"  - {tool.get('name', 'N/A')}: {tool.get('description', 'N/A')[:50]}...")
                except json.JSONDecodeError as e:
                    print(f"❌ ERRO JSON TOOLS: {e}")
            else:
                print("❌ NENHUMA RESPOSTA DE TOOLS")
        
        except Exception as e:
            print(f"❌ ERRO AO LER TOOLS: {e}")
        
        # Finalizar processo
        print("\n🛑 Finalizando processo...")
        process.terminate()
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()
        
        print(f"✅ TESTE CONCLUÍDO PARA: {mcp_name}")
        return True
        
    except Exception as e:
        print(f"❌ ERRO GERAL: {e}")
        if 'process' in locals():
            process.terminate()
        return False

def main():
    """Função principal para testar todos os MCPs"""
    print("🔍 INICIANDO TESTES DE STDIO DOS MCPs PYTHON")
    print("Simulando exatamente como o Trae se conecta aos servidores MCP")
    
    # Lista de MCPs para testar (apenas servidores MCP reais)
    mcps_to_test = [
        {
            'name': 'task_manager',
            'path': r'c:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MCP_Integration\servers\mcp_task_manager.py'
        },
        {
            'name': 'python_dev_accelerator', 
            'path': r'c:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MCP_Integration\servers\python_dev_accelerator_mcp.py'
        },
        {
            'name': 'api_integration',
            'path': r'c:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MCP_Integration\servers\api_integration_mcp.py'
        },
        {
            'name': 'trading_classifier',
            'path': r'c:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MCP_Integration\servers\trading_classifier_mcp.py'
        },
        {
            'name': 'project_scaffolding',
            'path': r'c:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MCP_Integration\servers\project_scaffolding_mcp.py'
        },
        {
            'name': 'code_analysis',
            'path': r'c:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MCP_Integration\servers\code_analysis_mcp.py'
        },
        {
            'name': 'test_automation',
            'path': r'c:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MCP_Integration\servers\test_automation_mcp.py'
        }
    ]
    
    results = {}
    
    for mcp in mcps_to_test:
        success = test_mcp_stdio(mcp['path'], mcp['name'])
        results[mcp['name']] = success
    
    # Resumo final
    print(f"\n{'='*60}")
    print("📊 RESUMO DOS TESTES")
    print(f"{'='*60}")
    
    for mcp_name, success in results.items():
        status = "✅ SUCESSO" if success else "❌ FALHOU"
        print(f"{mcp_name}: {status}")
    
    total_success = sum(results.values())
    total_tests = len(results)
    print(f"\nRESULTADO GERAL: {total_success}/{total_tests} MCPs funcionando")
    
    if total_success == total_tests:
        print("🎉 TODOS OS MCPs ESTÃO FUNCIONANDO!")
    else:
        print("⚠️  ALGUNS MCPs PRECISAM DE CORREÇÃO")

if __name__ == "__main__":
    main()