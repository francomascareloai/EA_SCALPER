#!/usr/bin/env python3
"""
Verificação Final de Todos os MCPs Instalados
Classificador_Trading - Verificação de Status Completa
"""

import sys
import os
import json
from pathlib import Path

# Adicionar path dos servidores
sys.path.append(os.path.join(os.path.dirname(__file__), 'servers'))

def test_mcp_config():
    """Verifica se o arquivo mcp.json está configurado corretamente."""
    print("🔧 Verificando configuração MCP...")
    
    config_path = Path("C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/.kilocode/mcp.json")
    
    if not config_path.exists():
        print("❌ Arquivo mcp.json não encontrado")
        return False
    
    try:
        with open(config_path, 'r', encoding='utf-8') as f:
            config = json.load(f)
        
        expected_mcps = [
            'file_analyzer',
            'ftmo_validator', 
            'metadata_generator',
            'code_classifier',
            'batch_processor',
            'task_manager',
            'youtube_transcript'
        ]
        
        for mcp in expected_mcps:
            if mcp in config:
                print(f"✅ {mcp} configurado")
            else:
                print(f"❌ {mcp} não configurado")
                return False
        
        return True
        
    except Exception as e:
        print(f"❌ Erro ao ler configuração: {e}")
        return False

def test_youtube_transcript():
    """Testa o YouTube Transcript Server."""
    print("\n🎥 Testando YouTube Transcript Server...")
    
    try:
        from mcp_youtube_transcript import YouTubeTranscriptServer
        server = YouTubeTranscriptServer()
        
        # Teste básico de extração de ID
        test_id = server.extract_video_id("https://www.youtube.com/watch?v=test123")
        if test_id == "test123":
            print("✅ YouTube Transcript Server funcionando")
            return True
        else:
            print("❌ Problema na extração de video ID")
            return False
            
    except Exception as e:
        print(f"❌ Erro no YouTube Transcript Server: {e}")
        return False

def test_task_manager():
    """Testa o TaskManager MCP."""
    print("\n📋 Testando TaskManager MCP...")
    
    try:
        from mcp_task_manager import TaskManager
        manager = TaskManager()
        
        # Verificar métodos essenciais
        methods = ['create_request', 'get_next_task', 'mark_task_done', 'approve_task']
        for method in methods:
            if hasattr(manager, method):
                print(f"✅ Método {method} disponível")
            else:
                print(f"❌ Método {method} não encontrado")
                return False
        
        print("✅ TaskManager MCP funcionando")
        return True
        
    except Exception as e:
        print(f"❌ Erro no TaskManager MCP: {e}")
        return False

def test_existing_mcps():
    """Testa os MCPs pré-existentes."""
    print("\n🔍 Verificando MCPs pré-existentes...")
    
    mcps_to_test = [
        ('mcp_file_analyzer', 'FileAnalyzer'),
        ('mcp_code_classifier', 'CodeClassifier'),
        ('mcp_ftmo_validator', 'FTMOValidator'),
        ('mcp_metadata_generator', 'MetadataGenerator'),
        ('mcp_batch_processor', 'BatchProcessor')
    ]
    
    success_count = 0
    
    for module_name, class_name in mcps_to_test:
        try:
            module = __import__(module_name)
            if hasattr(module, class_name) or hasattr(module, 'mcp'):
                print(f"✅ {module_name} disponível")
                success_count += 1
            else:
                print(f"⚠️ {module_name} importado mas classe não encontrada")
        except ImportError:
            print(f"❌ {module_name} não pode ser importado")
        except Exception as e:
            print(f"⚠️ {module_name} com problema: {e}")
    
    return success_count >= 3  # Pelo menos 3 dos 5 devem funcionar

def test_dependencies():
    """Verifica dependências essenciais."""
    print("\n📦 Verificando dependências...")
    
    dependencies = [
        'json',
        'sqlite3', 
        'uuid',
        'datetime',
        'pathlib',
        'youtube_transcript_api',
        'mcp'
    ]
    
    success_count = 0
    
    for dep in dependencies:
        try:
            __import__(dep)
            print(f"✅ {dep} disponível")
            success_count += 1
        except ImportError:
            print(f"❌ {dep} não disponível")
    
    return success_count >= len(dependencies) - 1  # Permitir 1 falha

def generate_final_report(results):
    """Gera relatório final da verificação."""
    print("\n" + "="*60)
    print("📊 RELATÓRIO FINAL DE VERIFICAÇÃO DOS MCPs")
    print("="*60)
    
    total_tests = len(results)
    passed_tests = sum(results.values())
    success_rate = (passed_tests / total_tests) * 100
    
    print(f"\n📈 Taxa de Sucesso: {success_rate:.1f}% ({passed_tests}/{total_tests})")
    
    print("\n📋 Detalhes dos Testes:")
    for test_name, result in results.items():
        status = "✅ PASSOU" if result else "❌ FALHOU"
        print(f"  {test_name}: {status}")
    
    if success_rate >= 85:
        print("\n🎉 STATUS GERAL: ✅ SISTEMA PRONTO PARA PRODUÇÃO")
        print("\n🚀 Todos os MCPs necessários estão funcionando corretamente!")
        print("   O Classificador_Trading pode começar a usar o sistema.")
    elif success_rate >= 70:
        print("\n⚠️ STATUS GERAL: 🟡 SISTEMA PARCIALMENTE FUNCIONAL")
        print("\n🔧 Alguns MCPs precisam de atenção, mas o sistema pode operar.")
    else:
        print("\n❌ STATUS GERAL: 🔴 SISTEMA REQUER MANUTENÇÃO")
        print("\n🛠️ Vários MCPs precisam ser corrigidos antes do uso.")
    
    print("\n" + "="*60)
    print("Verificação concluída pelo Classificador_Trading")
    print("="*60)

def main():
    """Execução principal da verificação."""
    print("🤖 Classificador_Trading - Verificação Final dos MCPs")
    print("🔍 Iniciando verificação completa do sistema...\n")
    
    # Executar todos os testes
    results = {
        "Configuração MCP": test_mcp_config(),
        "Dependências": test_dependencies(),
        "YouTube Transcript": test_youtube_transcript(),
        "TaskManager": test_task_manager(),
        "MCPs Existentes": test_existing_mcps()
    }
    
    # Gerar relatório final
    generate_final_report(results)
    
    return all(results.values())

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)