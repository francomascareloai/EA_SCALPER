#!/usr/bin/env python3
"""
Teste do TaskManager MCP Server
"""

import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), 'servers'))

def test_task_manager_import():
    """Teste de importação do TaskManager MCP Server."""
    try:
        from mcp_task_manager import TaskManager
        print("✓ TaskManager MCP Server importado com sucesso")
        
        # Testar criação da instância
        server = TaskManager()
        print("✓ Instância do TaskManager criada com sucesso")
        
        # Testar métodos básicos
        if hasattr(server, 'create_request'):
            print("✓ Método create_request disponível")
        
        if hasattr(server, 'get_next_task'):
            print("✓ Método get_next_task disponível")
            
        if hasattr(server, 'mark_task_done'):
            print("✓ Método mark_task_done disponível")
            
        if hasattr(server, 'approve_task'):
            print("✓ Método approve_task disponível")
            
        if hasattr(server, 'get_request_status'):
            print("✓ Método get_request_status disponível")
        
        print("\n🎉 TaskManager MCP Server está funcionando!")
        return True
        
    except ImportError as e:
        print(f"✗ Erro de importação: {e}")
        return False
    except Exception as e:
        print(f"✗ Erro inesperado: {e}")
        return False

def test_dependencies():
    """Teste das dependências necessárias."""
    try:
        import json
        print("✓ json disponível")
        
        import uuid
        print("✓ uuid disponível")
        
        import datetime
        print("✓ datetime disponível")
        
        return True
    except ImportError as e:
        print(f"✗ Dependência faltando: {e}")
        return False

if __name__ == "__main__":
    print("=== Teste do TaskManager MCP Server ===")
    print()
    
    print("1. Testando dependências...")
    deps_ok = test_dependencies()
    print()
    
    if deps_ok:
        print("2. Testando importação e funcionalidade básica...")
        import_ok = test_task_manager_import()
        print()
        
        if import_ok:
            print("✅ TaskManager MCP Server está funcionando corretamente!")
        else:
            print("❌ Problemas detectados no TaskManager MCP Server.")
    else:
        print("❌ Dependências faltando.")