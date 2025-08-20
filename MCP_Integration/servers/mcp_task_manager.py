#!/usr/bin/env python3
"""
MCP Task Manager Server
Gerencia tarefas e requisições usando FastMCP
"""

import sqlite3
import json
import uuid
from datetime import datetime
from typing import List, Dict, Any, Optional
from pathlib import Path
from mcp.server.fastmcp import FastMCP

# Inicializar servidor MCP
mcp = FastMCP("TaskManager")

# Caminho do banco de dados
DB_PATH = Path("c:/Users/Admin/Documents/EA_SCALPER_XAUUSD/data/tasks.db")

class TaskManager:
    def __init__(self, db_path: str = str(DB_PATH)):
        self.db_path = db_path
        self.init_database()
    
    def init_database(self):
        """Inicializa o banco de dados SQLite"""
        # Criar diretório se não existir
        Path(self.db_path).parent.mkdir(parents=True, exist_ok=True)
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Tabela de requisições
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS requests (
                id TEXT PRIMARY KEY,
                original_request TEXT NOT NULL,
                split_details TEXT,
                status TEXT DEFAULT 'pending',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                completed_at TIMESTAMP
            )
        """)
        
        # Tabela de tarefas
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS tasks (
                id TEXT PRIMARY KEY,
                request_id TEXT NOT NULL,
                title TEXT NOT NULL,
                description TEXT NOT NULL,
                status TEXT DEFAULT 'pending',
                completed_details TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                completed_at TIMESTAMP,
                approved_at TIMESTAMP,
                FOREIGN KEY (request_id) REFERENCES requests (id)
            )
        """)
        
        conn.commit()
        conn.close()
    
    def create_request(self, original_request: str, tasks: List[Dict], split_details: str = None) -> str:
        """Cria uma nova requisição com tarefas"""
        request_id = str(uuid.uuid4())
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Inserir requisição
        cursor.execute(
            "INSERT INTO requests (id, original_request, split_details) VALUES (?, ?, ?)",
            (request_id, original_request, split_details)
        )
        
        # Inserir tarefas
        for task in tasks:
            task_id = str(uuid.uuid4())
            cursor.execute(
                "INSERT INTO tasks (id, request_id, title, description) VALUES (?, ?, ?, ?)",
                (task_id, request_id, task["title"], task["description"])
            )
        
        conn.commit()
        conn.close()
        
        return request_id
    
    def get_next_task(self, request_id: str) -> Optional[Dict]:
        """Obtém a próxima tarefa pendente"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute(
            "SELECT id, title, description, status FROM tasks WHERE request_id = ? AND status = 'pending' ORDER BY created_at LIMIT 1",
            (request_id,)
        )
        
        result = cursor.fetchone()
        conn.close()
        
        if result:
            return {
                "id": result[0],
                "title": result[1],
                "description": result[2],
                "status": result[3]
            }
        return None
    
    def mark_task_done(self, request_id: str, task_id: str, completed_details: str = None) -> bool:
        """Marca uma tarefa como concluída"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute(
            "UPDATE tasks SET status = 'done', completed_details = ?, completed_at = CURRENT_TIMESTAMP WHERE id = ? AND request_id = ?",
            (completed_details, task_id, request_id)
        )
        
        success = cursor.rowcount > 0
        conn.commit()
        conn.close()
        
        return success
    
    def approve_task(self, request_id: str, task_id: str) -> bool:
        """Aprova uma tarefa concluída"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute(
            "UPDATE tasks SET status = 'approved', approved_at = CURRENT_TIMESTAMP WHERE id = ? AND request_id = ? AND status = 'done'",
            (task_id, request_id)
        )
        
        success = cursor.rowcount > 0
        conn.commit()
        conn.close()
        
        return success
    
    def get_request_status(self, request_id: str) -> Dict:
        """Obtém o status de uma requisição e suas tarefas"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Buscar requisição
        cursor.execute(
            "SELECT original_request, status FROM requests WHERE id = ?",
            (request_id,)
        )
        request_data = cursor.fetchone()
        
        if not request_data:
            conn.close()
            return None
        
        # Buscar tarefas
        cursor.execute(
            "SELECT id, title, description, status, completed_details FROM tasks WHERE request_id = ? ORDER BY created_at",
            (request_id,)
        )
        tasks = cursor.fetchall()
        
        conn.close()
        
        return {
            "request_id": request_id,
            "original_request": request_data[0],
            "status": request_data[1],
            "tasks": [
                {
                    "id": task[0],
                    "title": task[1],
                    "description": task[2],
                    "status": task[3],
                    "completed_details": task[4]
                }
                for task in tasks
            ]
        }
    
    def list_requests(self) -> List[Dict]:
        """Lista todas as requisições"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute(
            "SELECT id, original_request, status, created_at FROM requests ORDER BY created_at DESC"
        )
        requests = cursor.fetchall()
        
        conn.close()
        
        return [
            {
                "id": req[0],
                "original_request": req[1],
                "status": req[2],
                "created_at": req[3]
            }
            for req in requests
        ]

# Instância global do gerenciador
task_manager = TaskManager()

@mcp.tool()
def request_planning(originalRequest: str, tasks: list, splitDetails: str = None) -> str:
    """Registra uma nova requisição e planeja suas tarefas associadas.
    
    Args:
        originalRequest: A requisição original do usuário
        tasks: Lista de tarefas com title e description
        splitDetails: Detalhes opcionais sobre como a requisição foi dividida
    """
    try:
        request_id = task_manager.create_request(originalRequest, tasks, splitDetails)
        
        # Gerar tabela de progresso
        status = task_manager.get_request_status(request_id)
        progress_table = generate_progress_table(status)
        
        return f"✅ Requisição criada com sucesso!\n\nRequest ID: {request_id}\n\n{progress_table}\n\n🔄 Use 'get_next_task' para obter a primeira tarefa."
    except Exception as e:
        return f"❌ Erro ao criar requisição: {str(e)}"

@mcp.tool()
def get_next_task(requestId: str) -> str:
    """Obtém a próxima tarefa pendente para uma requisição.
    
    Args:
        requestId: ID da requisição
    """
    try:
        # Gerar tabela de progresso
        status = task_manager.get_request_status(requestId)
        if not status:
            return f"❌ Requisição {requestId} não encontrada."
        
        progress_table = generate_progress_table(status)
        
        next_task = task_manager.get_next_task(requestId)
        
        if next_task:
            return f"📋 Próxima tarefa:\n\n**ID:** {next_task['id']}\n**Título:** {next_task['title']}\n**Descrição:** {next_task['description']}\n\n{progress_table}"
        else:
            # Verificar se todas as tarefas estão aprovadas
            all_approved = all(task['status'] == 'approved' for task in status['tasks'])
            if all_approved:
                return f"🎉 Todas as tarefas foram concluídas e aprovadas!\n\n{progress_table}\n\n✅ Use 'approve_request_completion' para finalizar a requisição."
            else:
                return f"⏳ Todas as tarefas foram atribuídas. Aguardando aprovações pendentes.\n\n{progress_table}"
    except Exception as e:
        return f"❌ Erro ao obter próxima tarefa: {str(e)}"

@mcp.tool()
def mark_task_done(requestId: str, taskId: str, completedDetails: str = None) -> str:
    """Marca uma tarefa como concluída.
    
    Args:
        requestId: ID da requisição
        taskId: ID da tarefa
        completedDetails: Detalhes opcionais sobre a conclusão
    """
    try:
        success = task_manager.mark_task_done(requestId, taskId, completedDetails)
        
        if success:
            # Gerar tabela de progresso atualizada
            status = task_manager.get_request_status(requestId)
            progress_table = generate_progress_table(status)
            
            return f"✅ Tarefa {taskId} marcada como concluída!\n\n{progress_table}\n\n⚠️ Aguardando aprovação do usuário via 'approve_task_completion'."
        else:
            return f"❌ Falha ao marcar tarefa {taskId} como concluída."
    except Exception as e:
        return f"❌ Erro ao marcar tarefa como concluída: {str(e)}"

@mcp.tool()
def approve_task_completion(requestId: str, taskId: str) -> str:
    """Aprova a conclusão de uma tarefa.
    
    Args:
        requestId: ID da requisição
        taskId: ID da tarefa
    """
    try:
        success = task_manager.approve_task(requestId, taskId)
        
        if success:
            # Gerar tabela de progresso atualizada
            status = task_manager.get_request_status(requestId)
            progress_table = generate_progress_table(status)
            
            return f"✅ Tarefa {taskId} aprovada!\n\n{progress_table}\n\n🔄 Agora você pode usar 'get_next_task' para continuar."
        else:
            return f"❌ Falha ao aprovar tarefa {taskId}."
    except Exception as e:
        return f"❌ Erro ao aprovar tarefa: {str(e)}"

@mcp.tool()
def approve_request_completion(requestId: str) -> str:
    """Finaliza uma requisição após todas as tarefas serem aprovadas.
    
    Args:
        requestId: ID da requisição
    """
    try:
        # Verificar se todas as tarefas estão aprovadas
        status = task_manager.get_request_status(requestId)
        if not status:
            return f"❌ Requisição {requestId} não encontrada."
        
        all_approved = all(task['status'] == 'approved' for task in status['tasks'])
        
        if not all_approved:
            progress_table = generate_progress_table(status)
            return f"⚠️ Nem todas as tarefas foram aprovadas ainda.\n\n{progress_table}"
        
        # Marcar requisição como completa
        conn = sqlite3.connect(task_manager.db_path)
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE requests SET status = 'completed', completed_at = CURRENT_TIMESTAMP WHERE id = ?",
            (requestId,)
        )
        conn.commit()
        conn.close()
        
        progress_table = generate_progress_table(status)
        return f"🎉 Requisição {requestId} finalizada com sucesso!\n\n{progress_table}\n\n✅ Todas as tarefas foram concluídas e aprovadas."
    except Exception as e:
        return f"❌ Erro ao finalizar requisição: {str(e)}"

@mcp.tool()
def open_task_details(taskId: str) -> str:
    """Obtém detalhes de uma tarefa específica.
    
    Args:
        taskId: ID da tarefa
    """
    try:
        conn = sqlite3.connect(task_manager.db_path)
        cursor = conn.cursor()
        
        cursor.execute(
            "SELECT t.id, t.title, t.description, t.status, t.completed_details, t.created_at, t.completed_at, t.approved_at, r.original_request FROM tasks t JOIN requests r ON t.request_id = r.id WHERE t.id = ?",
            (taskId,)
        )
        
        result = cursor.fetchone()
        conn.close()
        
        if result:
            return f"""📋 **Detalhes da Tarefa**

**ID:** {result[0]}
**Título:** {result[1]}
**Descrição:** {result[2]}
**Status:** {result[3]}
**Detalhes de Conclusão:** {result[4] or 'N/A'}
**Criada em:** {result[5]}
**Concluída em:** {result[6] or 'N/A'}
**Aprovada em:** {result[7] or 'N/A'}
**Requisição Original:** {result[8]}"""
        else:
            return f"❌ Tarefa {taskId} não encontrada."
    except Exception as e:
        return f"❌ Erro ao obter detalhes da tarefa: {str(e)}"

@mcp.tool()
def list_requests() -> str:
    """Lista todas as requisições com informações básicas."""
    try:
        requests = task_manager.list_requests()
        
        if not requests:
            return "📝 Nenhuma requisição encontrada."
        
        result = "📋 **Lista de Requisições**\n\n"
        for req in requests:
            result += f"**ID:** {req['id']}\n"
            result += f"**Requisição:** {req['original_request'][:100]}{'...' if len(req['original_request']) > 100 else ''}\n"
            result += f"**Status:** {req['status']}\n"
            result += f"**Criada em:** {req['created_at']}\n\n"
        
        return result
    except Exception as e:
        return f"❌ Erro ao listar requisições: {str(e)}"

def generate_progress_table(status: Dict) -> str:
    """Gera uma tabela de progresso das tarefas"""
    if not status or not status['tasks']:
        return "📋 Nenhuma tarefa encontrada."
    
    table = "📊 **Progresso das Tarefas**\n\n"
    table += "| # | Título | Status | Detalhes |\n"
    table += "|---|--------|--------|----------|\n"
    
    for i, task in enumerate(status['tasks'], 1):
        status_emoji = {
            'pending': '⏳',
            'done': '✅',
            'approved': '🎉'
        }.get(task['status'], '❓')
        
        title = task['title'][:30] + '...' if len(task['title']) > 30 else task['title']
        details = task['completed_details'][:20] + '...' if task['completed_details'] and len(task['completed_details']) > 20 else (task['completed_details'] or '-')
        
        table += f"| {i} | {title} | {status_emoji} {task['status']} | {details} |\n"
    
    return table

if __name__ == "__main__":
    mcp.run(transport="stdio")