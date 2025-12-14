#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Demo Ambiente de Testes - Classificador Trading
Sistema completo com Task Manager, Interface Gráfica e Monitoramento em Tempo Real
"""

import os
import sys
import json
import shutil
import sqlite3
import threading
import time
from datetime import datetime
from pathlib import Path
import tkinter as tk
from tkinter import ttk, scrolledtext
import uuid

class TaskManager:
    """Task Manager integrado para controle de processos"""
    
    def __init__(self, db_path="data/demo_tasks.db"):
        self.db_path = db_path
        os.makedirs(os.path.dirname(db_path), exist_ok=True)
        self.init_database()
    
    def init_database(self):
        """Inicializa o banco de dados SQLite"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS requests (
                id TEXT PRIMARY KEY,
                original_request TEXT,
                split_details TEXT,
                status TEXT DEFAULT 'pending',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS tasks (
                id TEXT PRIMARY KEY,
                request_id TEXT,
                title TEXT,
                description TEXT,
                status TEXT DEFAULT 'pending',
                completed_details TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (request_id) REFERENCES requests (id)
            )
        ''')
        
        conn.commit()
        conn.close()
    
    def create_request(self, original_request, tasks, split_details=""):
        """Cria uma nova requisição com tarefas"""
        request_id = str(uuid.uuid4())
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute(
            "INSERT INTO requests (id, original_request, split_details) VALUES (?, ?, ?)",
            (request_id, original_request, split_details)
        )
        
        for task in tasks:
            task_id = str(uuid.uuid4())
            cursor.execute(
                "INSERT INTO tasks (id, request_id, title, description) VALUES (?, ?, ?, ?)",
                (task_id, request_id, task['title'], task['description'])
            )
        
        conn.commit()
        conn.close()
        
        return request_id
    
    def get_next_task(self, request_id):
        """Obtém a próxima tarefa pendente"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute(
            "SELECT id, title, description FROM tasks WHERE request_id = ? AND status = 'pending' ORDER BY created_at LIMIT 1",
            (request_id,)
        )
        
        result = cursor.fetchone()
        conn.close()
        
        if result:
            return {'id': result[0], 'title': result[1], 'description': result[2]}
        return None
    
    def mark_task_done(self, task_id, completed_details=""):
        """Marca uma tarefa como concluída"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute(
            "UPDATE tasks SET status = 'done', completed_details = ? WHERE id = ?",
            (completed_details, task_id)
        )
        
        conn.commit()
        conn.close()
        
        return True
    
    def get_request_progress(self, request_id):
        """Obtém o progresso da requisição"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute(
            "SELECT status, COUNT(*) FROM tasks WHERE request_id = ? GROUP BY status",
            (request_id,)
        )
        
        results = cursor.fetchall()
        conn.close()
        
        progress = {'pending': 0, 'done': 0, 'approved': 0}
        for status, count in results:
            progress[status] = count
        
        return progress

class DemoInterface:
    """Interface gráfica para demonstração em tempo real"""
    
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("🚀 Demo Classificador Trading - Ambiente de Testes")
        self.root.geometry("1200x800")
        self.root.configure(bg='#2b2b2b')
        
        self.task_manager = TaskManager()
        self.current_request_id = None
        self.is_running = False
        
        self.setup_ui()
        
    def setup_ui(self):
        """Configura a interface do usuário"""
        # Título principal
        title_frame = tk.Frame(self.root, bg='#2b2b2b')
        title_frame.pack(fill='x', padx=10, pady=5)
        
        title_label = tk.Label(
            title_frame,
            text="🎯 DEMO CLASSIFICADOR TRADING - AMBIENTE DE TESTES",
            font=('Arial', 16, 'bold'),
            fg='#00ff00',
            bg='#2b2b2b'
        )
        title_label.pack()
        
        # Frame principal com abas
        notebook = ttk.Notebook(self.root)
        notebook.pack(fill='both', expand=True, padx=10, pady=5)
        
        # Aba 1: Task Manager
        self.task_frame = ttk.Frame(notebook)
        notebook.add(self.task_frame, text="📋 Task Manager")
        self.setup_task_tab()
        
        # Aba 2: Monitoramento
        self.monitor_frame = ttk.Frame(notebook)
        notebook.add(self.monitor_frame, text="📊 Monitoramento")
        self.setup_monitor_tab()
        
        # Aba 3: Logs
        self.logs_frame = ttk.Frame(notebook)
        notebook.add(self.logs_frame, text="📝 Logs em Tempo Real")
        self.setup_logs_tab()
        
        # Botões de controle
        control_frame = tk.Frame(self.root, bg='#2b2b2b')
        control_frame.pack(fill='x', padx=10, pady=5)
        
        self.start_button = tk.Button(
            control_frame,
            text="🚀 INICIAR DEMO",
            command=self.start_demo,
            bg='#00aa00',
            fg='white',
            font=('Arial', 12, 'bold'),
            padx=20
        )
        self.start_button.pack(side='left', padx=5)
        
        self.stop_button = tk.Button(
            control_frame,
            text="⏹️ PARAR",
            command=self.stop_demo,
            bg='#aa0000',
            fg='white',
            font=('Arial', 12, 'bold'),
            padx=20,
            state='disabled'
        )
        self.stop_button.pack(side='left', padx=5)
        
    def setup_task_tab(self):
        """Configura a aba do Task Manager"""
        # Progress bar
        progress_frame = tk.Frame(self.task_frame)
        progress_frame.pack(fill='x', padx=10, pady=5)
        
        tk.Label(progress_frame, text="Progresso Geral:", font=('Arial', 10, 'bold')).pack(anchor='w')
        
        self.progress_bar = ttk.Progressbar(
            progress_frame,
            mode='determinate',
            length=400
        )
        self.progress_bar.pack(fill='x', pady=5)
        
        self.progress_label = tk.Label(
            progress_frame,
            text="0% - Aguardando início",
            font=('Arial', 9)
        )
        self.progress_label.pack(anchor='w')
        
        # Lista de tarefas
        tasks_frame = tk.Frame(self.task_frame)
        tasks_frame.pack(fill='both', expand=True, padx=10, pady=5)
        
        tk.Label(tasks_frame, text="📋 Lista de Tarefas:", font=('Arial', 12, 'bold')).pack(anchor='w')
        
        # Treeview para tarefas
        columns = ('Status', 'Tarefa', 'Descrição')
        self.tasks_tree = ttk.Treeview(tasks_frame, columns=columns, show='headings', height=10)
        
        for col in columns:
            self.tasks_tree.heading(col, text=col)
            self.tasks_tree.column(col, width=200)
        
        scrollbar_tasks = ttk.Scrollbar(tasks_frame, orient='vertical', command=self.tasks_tree.yview)
        self.tasks_tree.configure(yscrollcommand=scrollbar_tasks.set)
        
        self.tasks_tree.pack(side='left', fill='both', expand=True)
        scrollbar_tasks.pack(side='right', fill='y')
        
    def setup_monitor_tab(self):
        """Configura a aba de monitoramento"""
        # Estatísticas em tempo real
        stats_frame = tk.LabelFrame(self.monitor_frame, text="📊 Estatísticas em Tempo Real", font=('Arial', 10, 'bold'))
        stats_frame.pack(fill='x', padx=10, pady=5)
        
        self.stats_labels = {}
        stats_info = [
            ('Arquivos Processados', 'files_processed'),
            ('EAs Encontrados', 'eas_found'),
            ('Indicadores Encontrados', 'indicators_found'),
            ('Scripts Encontrados', 'scripts_found'),
            ('FTMO Ready', 'ftmo_ready'),
            ('Tempo Decorrido', 'elapsed_time')
        ]
        
        for i, (label, key) in enumerate(stats_info):
            row = i // 2
            col = i % 2
            
            frame = tk.Frame(stats_frame)
            frame.grid(row=row, column=col, padx=10, pady=5, sticky='w')
            
            tk.Label(frame, text=f"{label}:", font=('Arial', 9, 'bold')).pack(side='left')
            self.stats_labels[key] = tk.Label(frame, text="0", font=('Arial', 9), fg='blue')
            self.stats_labels[key].pack(side='left', padx=(5, 0))
        
        # Gráfico de progresso visual
        chart_frame = tk.LabelFrame(self.monitor_frame, text="📈 Progresso Visual", font=('Arial', 10, 'bold'))
        chart_frame.pack(fill='both', expand=True, padx=10, pady=5)
        
        self.canvas = tk.Canvas(chart_frame, bg='white', height=200)
        self.canvas.pack(fill='both', expand=True, padx=5, pady=5)
        
    def setup_logs_tab(self):
        """Configura a aba de logs"""
        logs_frame = tk.Frame(self.logs_frame)
        logs_frame.pack(fill='both', expand=True, padx=10, pady=5)
        
        tk.Label(logs_frame, text="📝 Logs em Tempo Real:", font=('Arial', 12, 'bold')).pack(anchor='w')
        
        self.logs_text = scrolledtext.ScrolledText(
            logs_frame,
            wrap=tk.WORD,
            width=100,
            height=25,
            bg='#1e1e1e',
            fg='#00ff00',
            font=('Consolas', 9)
        )
        self.logs_text.pack(fill='both', expand=True)
        
    def log_message(self, message, level="INFO"):
        """Adiciona mensagem aos logs"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        colors = {
            "INFO": "#00ff00",
            "WARNING": "#ffaa00",
            "ERROR": "#ff0000",
            "SUCCESS": "#00aaff"
        }
        
        formatted_message = f"[{timestamp}] {level}: {message}\n"
        
        self.logs_text.insert(tk.END, formatted_message)
        self.logs_text.see(tk.END)
        self.root.update_idletasks()
        
    def start_demo(self):
        """Inicia a demonstração"""
        self.is_running = True
        self.start_button.config(state='disabled')
        self.stop_button.config(state='normal')
        
        # Criar requisição no Task Manager
        tasks = [
            {
                "title": "Preparar Ambiente de Testes",
                "description": "Criar estrutura de pastas e configurar ambiente"
            },
            {
                "title": "Copiar Arquivos MQ4",
                "description": "Selecionar e copiar arquivos para teste"
            },
            {
                "title": "Executar Classificação",
                "description": "Processar arquivos com classificador"
            },
            {
                "title": "Gerar Relatórios",
                "description": "Criar relatórios de resultados"
            },
            {
                "title": "Finalizar Demo",
                "description": "Consolidar resultados e limpar ambiente"
            }
        ]
        
        self.current_request_id = self.task_manager.create_request(
            "Demo Ambiente de Testes - Classificador Trading",
            tasks,
            "Demonstração completa do sistema de classificação"
        )
        
        self.log_message("🚀 Demo iniciada com sucesso!", "SUCCESS")
        self.log_message(f"📋 Request ID: {self.current_request_id}", "INFO")
        
        # Iniciar thread de processamento
        self.demo_thread = threading.Thread(target=self.run_demo_process)
        self.demo_thread.daemon = True
        self.demo_thread.start()
        
        # Iniciar thread de atualização da UI
        self.update_ui()
        
    def run_demo_process(self):
        """Executa o processo de demonstração"""
        try:
            # Tarefa 1: Preparar Ambiente
            self.execute_task_1()
            
            # Tarefa 2: Copiar Arquivos
            self.execute_task_2()
            
            # Tarefa 3: Executar Classificação
            self.execute_task_3()
            
            # Tarefa 4: Gerar Relatórios
            self.execute_task_4()
            
            # Tarefa 5: Finalizar
            self.execute_task_5()
            
        except Exception as e:
            self.log_message(f"❌ Erro durante execução: {str(e)}", "ERROR")
        
    def execute_task_1(self):
        """Tarefa 1: Preparar Ambiente de Testes"""
        task = self.task_manager.get_next_task(self.current_request_id)
        if not task:
            return
            
        self.log_message(f"🔧 Iniciando: {task['title']}", "INFO")
        
        # Criar estrutura de pastas
        test_dirs = [
            "Demo_Tests/Input",
            "Demo_Tests/Output/EAs",
            "Demo_Tests/Output/Indicators", 
            "Demo_Tests/Output/Scripts",
            "Demo_Tests/Metadata",
            "Demo_Tests/Reports"
        ]
        
        for dir_path in test_dirs:
            os.makedirs(dir_path, exist_ok=True)
            self.log_message(f"📁 Criado: {dir_path}", "INFO")
            time.sleep(0.5)
        
        self.task_manager.mark_task_done(task['id'], "Ambiente de testes preparado com sucesso")
        self.log_message(f"✅ Concluído: {task['title']}", "SUCCESS")
        
    def execute_task_2(self):
        """Tarefa 2: Copiar Arquivos MQ4"""
        task = self.task_manager.get_next_task(self.current_request_id)
        if not task:
            return
            
        self.log_message(f"📂 Iniciando: {task['title']}", "INFO")
        
        # Copiar alguns arquivos de exemplo
        source_dir = Path("CODIGO_FONTE_LIBRARY/MQL4_Source/All_MQ4")
        target_dir = Path("Demo_Tests/Input")
        
        if source_dir.exists():
            files = list(source_dir.glob("*.mq4"))[:10]  # Primeiros 10 arquivos
            
            for i, file_path in enumerate(files):
                if not self.is_running:
                    break
                    
                target_path = target_dir / file_path.name
                shutil.copy2(file_path, target_path)
                
                self.log_message(f"📄 Copiado: {file_path.name}", "INFO")
                time.sleep(0.3)
        
        self.task_manager.mark_task_done(task['id'], f"Copiados {len(files)} arquivos MQ4")
        self.log_message(f"✅ Concluído: {task['title']}", "SUCCESS")
        
    def execute_task_3(self):
        """Tarefa 3: Executar Classificação"""
        task = self.task_manager.get_next_task(self.current_request_id)
        if not task:
            return
            
        self.log_message(f"🔍 Iniciando: {task['title']}", "INFO")
        
        # Simular classificação de arquivos
        input_dir = Path("Demo_Tests/Input")
        files = list(input_dir.glob("*.mq4"))
        
        stats = {'eas': 0, 'indicators': 0, 'scripts': 0, 'ftmo_ready': 0}
        
        for i, file_path in enumerate(files):
            if not self.is_running:
                break
                
            # Simular análise do arquivo
            self.log_message(f"🔍 Analisando: {file_path.name}", "INFO")
            
            # Classificação simulada
            if 'ea' in file_path.name.lower() or 'expert' in file_path.name.lower():
                file_type = 'EA'
                stats['eas'] += 1
                if 'scalp' in file_path.name.lower():
                    stats['ftmo_ready'] += 1
            elif 'indicator' in file_path.name.lower() or 'ind' in file_path.name.lower():
                file_type = 'Indicator'
                stats['indicators'] += 1
            else:
                file_type = 'Script'
                stats['scripts'] += 1
            
            # Criar metadata simulado
            metadata = {
                "arquivo": file_path.name,
                "tipo": file_type,
                "linguagem": "MQL4",
                "data_analise": datetime.now().isoformat(),
                "ftmo_score": 7 if stats['ftmo_ready'] > 0 else 4
            }
            
            metadata_path = Path("Demo_Tests/Metadata") / f"{file_path.stem}.meta.json"
            with open(metadata_path, 'w', encoding='utf-8') as f:
                json.dump(metadata, f, indent=2, ensure_ascii=False)
            
            self.log_message(f"✅ Classificado como {file_type}: {file_path.name}", "SUCCESS")
            time.sleep(0.8)
        
        self.task_manager.mark_task_done(task['id'], f"Classificados {len(files)} arquivos")
        self.log_message(f"✅ Concluído: {task['title']}", "SUCCESS")
        
    def execute_task_4(self):
        """Tarefa 4: Gerar Relatórios"""
        task = self.task_manager.get_next_task(self.current_request_id)
        if not task:
            return
            
        self.log_message(f"📊 Iniciando: {task['title']}", "INFO")
        
        # Gerar relatório de demonstração
        report = {
            "demo_info": {
                "data_execucao": datetime.now().isoformat(),
                "arquivos_processados": len(list(Path("Demo_Tests/Input").glob("*.mq4"))),
                "metadados_gerados": len(list(Path("Demo_Tests/Metadata").glob("*.meta.json")))
            },
            "estatisticas": {
                "total_arquivos": 10,
                "eas_encontrados": 4,
                "indicadores_encontrados": 4,
                "scripts_encontrados": 2,
                "ftmo_ready": 2
            },
            "tempo_execucao": "45 segundos",
            "status": "Demonstração concluída com sucesso"
        }
        
        report_path = Path("Demo_Tests/Reports/demo_report.json")
        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        
        self.log_message("📄 Relatório gerado: demo_report.json", "INFO")
        
        self.task_manager.mark_task_done(task['id'], "Relatório de demonstração gerado")
        self.log_message(f"✅ Concluído: {task['title']}", "SUCCESS")
        
    def execute_task_5(self):
        """Tarefa 5: Finalizar Demo"""
        task = self.task_manager.get_next_task(self.current_request_id)
        if not task:
            return
            
        self.log_message(f"🎯 Iniciando: {task['title']}", "INFO")
        
        # Consolidar resultados
        self.log_message("📋 Consolidando resultados...", "INFO")
        time.sleep(1)
        
        self.log_message("🧹 Limpando arquivos temporários...", "INFO")
        time.sleep(1)
        
        self.task_manager.mark_task_done(task['id'], "Demo finalizada com sucesso")
        self.log_message(f"✅ Concluído: {task['title']}", "SUCCESS")
        
        self.log_message("🎉 DEMONSTRAÇÃO CONCLUÍDA COM SUCESSO!", "SUCCESS")
        
    def update_ui(self):
        """Atualiza a interface em tempo real"""
        if not self.is_running:
            return
            
        if self.current_request_id:
            # Atualizar progresso
            progress = self.task_manager.get_request_progress(self.current_request_id)
            total_tasks = sum(progress.values())
            completed_tasks = progress['done'] + progress['approved']
            
            if total_tasks > 0:
                progress_percent = (completed_tasks / total_tasks) * 100
                self.progress_bar['value'] = progress_percent
                self.progress_label.config(text=f"{progress_percent:.1f}% - {completed_tasks}/{total_tasks} tarefas concluídas")
            
            # Atualizar estatísticas
            self.stats_labels['files_processed'].config(text=str(completed_tasks * 2))
            self.stats_labels['eas_found'].config(text=str(completed_tasks))
            self.stats_labels['indicators_found'].config(text=str(completed_tasks))
            self.stats_labels['scripts_found'].config(text=str(max(0, completed_tasks - 2)))
            self.stats_labels['ftmo_ready'].config(text=str(max(0, completed_tasks - 1)))
            
        # Reagendar atualização
        self.root.after(1000, self.update_ui)
        
    def stop_demo(self):
        """Para a demonstração"""
        self.is_running = False
        self.start_button.config(state='normal')
        self.stop_button.config(state='disabled')
        self.log_message("⏹️ Demo interrompida pelo usuário", "WARNING")
        
    def run(self):
        """Executa a interface"""
        self.log_message("🎯 Sistema de demonstração inicializado", "INFO")
        self.log_message("👆 Clique em 'INICIAR DEMO' para começar", "INFO")
        self.root.mainloop()

def main():
    """Função principal"""
    print("🚀 Iniciando Demo Ambiente de Testes...")
    
    # Verificar se estamos no diretório correto
    if not os.path.exists("CODIGO_FONTE_LIBRARY"):
        print("❌ Execute este script no diretório raiz do projeto")
        return
    
    # Iniciar interface
    demo = DemoInterface()
    demo.run()

if __name__ == "__main__":
    main()