#!/usr/bin/env python3
"""
Teste do MCP Task Manager
"""

import json
import sys
import os

# Adicionar o caminho dos servidores
sys.path.append(os.path.join(os.path.dirname(__file__), 'MCP_Integration', 'servers'))

from mcp_task_manager import task_manager

def test_task_manager():
    """Testa as funcionalidades básicas do Task Manager"""
    print("🧪 Testando MCP Task Manager...")
    
    try:
        # Teste 1: Listar requisições (deve estar vazio)
        print("\n1. Testando list_requests...")
        requests = task_manager.list_requests()
        print(f"   Requisições encontradas: {len(requests)}")
        
        # Teste 2: Criar uma nova requisição
        print("\n2. Testando create_request...")
        tasks = [
            {"title": "Tarefa 1", "description": "Primeira tarefa de teste"},
            {"title": "Tarefa 2", "description": "Segunda tarefa de teste"}
        ]
        request_id = task_manager.create_request(
            "Requisição de teste", 
            tasks, 
            "Teste de funcionalidade"
        )
        print(f"   Request ID criado: {request_id}")
        
        # Teste 3: Obter próxima tarefa
        print("\n3. Testando get_next_task...")
        next_task = task_manager.get_next_task(request_id)
        if next_task:
            print(f"   Próxima tarefa: {next_task['title']}")
            task_id = next_task['id']
            
            # Teste 4: Marcar tarefa como concluída
            print("\n4. Testando mark_task_done...")
            success = task_manager.mark_task_done(request_id, task_id, "Tarefa concluída com sucesso")
            print(f"   Tarefa marcada como concluída: {success}")
            
            # Teste 5: Aprovar tarefa
            print("\n5. Testando approve_task...")
            success = task_manager.approve_task(request_id, task_id)
            print(f"   Tarefa aprovada: {success}")
        
        # Teste 6: Verificar status da requisição
        print("\n6. Testando get_request_status...")
        status = task_manager.get_request_status(request_id)
        if status:
            print(f"   Status da requisição: {status['status']}")
            print(f"   Total de tarefas: {len(status['tasks'])}")
            for i, task in enumerate(status['tasks'], 1):
                print(f"     Tarefa {i}: {task['title']} - {task['status']}")
        
        print("\n✅ Todos os testes passaram com sucesso!")
        return True
        
    except Exception as e:
        print(f"\n❌ Erro durante o teste: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = test_task_manager()
    sys.exit(0 if success else 1)