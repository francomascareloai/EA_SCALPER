#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🖥️ INTERFACE GRÁFICA - CLASSIFICADOR LOTE
Interface simples para o sistema de classificação em lote

Autor: Classificador_Trading
Versão: 2.0
Data: 12/08/2025

Recursos:
- Interface gráfica intuitiva
- Barra de progresso em tempo real
- Seleção de diretórios
- Configurações avançadas
- Visualização de resultados
- Controle de parada
"""

import tkinter as tk
from tkinter import ttk, filedialog, messagebox, scrolledtext
import threading
import os
import json
from datetime import datetime
from classificador_lote_avancado import ClassificadorLoteAvancado

class InterfaceClassificadorLote:
    """
    Interface gráfica para o classificador em lote
    """
    
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("🔧 Classificador Trading - Lote Avançado")
        self.root.geometry("800x600")
        self.root.resizable(True, True)
        
        # Variáveis
        self.directory_var = tk.StringVar()
        self.backup_var = tk.BooleanVar(value=True)
        self.workers_var = tk.IntVar(value=4)
        self.extensions_var = tk.StringVar(value=".mq4,.mq5,.pine")
        
        # Classificador
        self.classificador = None
        self.processing = False
        
        self._create_widgets()
        self._setup_layout()
        
    def _create_widgets(self):
        """Cria todos os widgets da interface"""
        
        # Frame principal
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Configurar grid
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_frame.columnconfigure(1, weight=1)
        
        # Título
        title_label = ttk.Label(main_frame, text="🔧 Classificador Trading - Processamento em Lote", 
                               font=('Arial', 14, 'bold'))
        title_label.grid(row=0, column=0, columnspan=3, pady=(0, 20))
        
        # Seleção de diretório
        ttk.Label(main_frame, text="📁 Diretório:").grid(row=1, column=0, sticky=tk.W, pady=5)
        
        dir_frame = ttk.Frame(main_frame)
        dir_frame.grid(row=1, column=1, columnspan=2, sticky=(tk.W, tk.E), pady=5)
        dir_frame.columnconfigure(0, weight=1)
        
        self.dir_entry = ttk.Entry(dir_frame, textvariable=self.directory_var, width=50)
        self.dir_entry.grid(row=0, column=0, sticky=(tk.W, tk.E), padx=(0, 5))
        
        ttk.Button(dir_frame, text="Procurar", command=self._select_directory).grid(row=0, column=1)
        
        # Configurações
        config_frame = ttk.LabelFrame(main_frame, text="⚙️ Configurações", padding="10")
        config_frame.grid(row=2, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=10)
        config_frame.columnconfigure(1, weight=1)
        
        # Extensões
        ttk.Label(config_frame, text="📄 Extensões:").grid(row=0, column=0, sticky=tk.W, pady=2)
        ttk.Entry(config_frame, textvariable=self.extensions_var, width=30).grid(row=0, column=1, sticky=tk.W, pady=2, padx=(5, 0))
        
        # Workers
        ttk.Label(config_frame, text="🔄 Threads:").grid(row=1, column=0, sticky=tk.W, pady=2)
        ttk.Spinbox(config_frame, from_=1, to=8, textvariable=self.workers_var, width=10).grid(row=1, column=1, sticky=tk.W, pady=2, padx=(5, 0))
        
        # Backup
        ttk.Checkbutton(config_frame, text="💾 Criar backup antes do processamento", 
                       variable=self.backup_var).grid(row=2, column=0, columnspan=2, sticky=tk.W, pady=5)
        
        # Controles
        control_frame = ttk.Frame(main_frame)
        control_frame.grid(row=3, column=0, columnspan=3, pady=10)
        
        self.start_button = ttk.Button(control_frame, text="🚀 Iniciar Processamento", 
                                      command=self._start_processing, style='Accent.TButton')
        self.start_button.pack(side=tk.LEFT, padx=(0, 10))
        
        self.stop_button = ttk.Button(control_frame, text="🛑 Parar", 
                                     command=self._stop_processing, state='disabled')
        self.stop_button.pack(side=tk.LEFT)
        
        # Progresso
        progress_frame = ttk.LabelFrame(main_frame, text="📊 Progresso", padding="10")
        progress_frame.grid(row=4, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=10)
        progress_frame.columnconfigure(0, weight=1)
        
        self.progress_var = tk.StringVar(value="Aguardando...")
        self.progress_label = ttk.Label(progress_frame, textvariable=self.progress_var)
        self.progress_label.grid(row=0, column=0, sticky=tk.W)
        
        self.progress_bar = ttk.Progressbar(progress_frame, mode='determinate')
        self.progress_bar.grid(row=1, column=0, sticky=(tk.W, tk.E), pady=(5, 0))
        
        # Log
        log_frame = ttk.LabelFrame(main_frame, text="📝 Log de Execução", padding="10")
        log_frame.grid(row=5, column=0, columnspan=3, sticky=(tk.W, tk.E, tk.N, tk.S), pady=10)
        log_frame.columnconfigure(0, weight=1)
        log_frame.rowconfigure(0, weight=1)
        
        self.log_text = scrolledtext.ScrolledText(log_frame, height=15, width=80)
        self.log_text.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Configurar redimensionamento
        main_frame.rowconfigure(5, weight=1)
        
    def _setup_layout(self):
        """Configura o layout da interface"""
        # Definir diretório padrão
        default_dir = os.path.join(os.getcwd(), "CODIGO_FONTE_LIBRARY")
        if os.path.exists(default_dir):
            self.directory_var.set(default_dir)
            
    def _select_directory(self):
        """Abre diálogo para seleção de diretório"""
        directory = filedialog.askdirectory(
            title="Selecionar diretório para processamento",
            initialdir=self.directory_var.get() or os.getcwd()
        )
        if directory:
            self.directory_var.set(directory)
            
    def _log_message(self, message: str):
        """Adiciona mensagem ao log"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        self.log_text.insert(tk.END, f"[{timestamp}] {message}\n")
        self.log_text.see(tk.END)
        self.root.update_idletasks()
        
    def _update_progress(self, message: str, percentage: float = None):
        """Callback para atualização de progresso"""
        self.progress_var.set(message)
        
        if percentage is not None:
            self.progress_bar['value'] = percentage
            
        self._log_message(message)
        
    def _validate_inputs(self) -> bool:
        """Valida as entradas do usuário"""
        if not self.directory_var.get():
            messagebox.showerror("Erro", "Selecione um diretório para processamento")
            return False
            
        if not os.path.exists(self.directory_var.get()):
            messagebox.showerror("Erro", "Diretório selecionado não existe")
            return False
            
        if not self.extensions_var.get().strip():
            messagebox.showerror("Erro", "Especifique pelo menos uma extensão")
            return False
            
        return True
        
    def _start_processing(self):
        """Inicia o processamento em thread separada"""
        if not self._validate_inputs():
            return
            
        if self.processing:
            messagebox.showwarning("Aviso", "Processamento já está em andamento")
            return
            
        # Configurar interface
        self.processing = True
        self.start_button.config(state='disabled')
        self.stop_button.config(state='normal')
        self.progress_bar['value'] = 0
        self.log_text.delete(1.0, tk.END)
        
        # Iniciar thread de processamento
        thread = threading.Thread(target=self._process_files, daemon=True)
        thread.start()
        
    def _process_files(self):
        """Processa arquivos em thread separada"""
        try:
            # Configurar classificador
            self.classificador = ClassificadorLoteAvancado(max_workers=self.workers_var.get())
            self.classificador.set_progress_callback(self._update_progress)
            
            # Preparar parâmetros
            extensions = [ext.strip() for ext in self.extensions_var.get().split(',')]
            
            self._log_message("🚀 Iniciando processamento...")
            
            # Processar
            report = self.classificador.process_directory(
                source_dir=self.directory_var.get(),
                extensions=extensions,
                create_backup=self.backup_var.get(),
                show_progress=False  # Usamos nosso próprio sistema de progresso
            )
            
            # Mostrar resultados
            self._show_results(report)
            
        except Exception as e:
            self._log_message(f"❌ Erro durante processamento: {str(e)}")
            messagebox.showerror("Erro", f"Erro durante processamento:\n{str(e)}")
            
        finally:
            # Restaurar interface
            self.processing = False
            self.start_button.config(state='normal')
            self.stop_button.config(state='disabled')
            self.progress_bar['value'] = 100
            self.progress_var.set("Processamento concluído")
            
    def _stop_processing(self):
        """Para o processamento"""
        if self.classificador:
            self.classificador.stop()
            self._log_message("🛑 Solicitação de parada enviada...")
            
    def _show_results(self, report: dict):
        """Mostra resultados em janela separada"""
        results_window = tk.Toplevel(self.root)
        results_window.title("📊 Resultados do Processamento")
        results_window.geometry("600x500")
        
        # Frame principal
        main_frame = ttk.Frame(results_window, padding="10")
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Título
        ttk.Label(main_frame, text="📊 Relatório de Processamento", 
                 font=('Arial', 12, 'bold')).pack(pady=(0, 10))
        
        # Estatísticas
        stats_frame = ttk.LabelFrame(main_frame, text="📈 Estatísticas", padding="10")
        stats_frame.pack(fill=tk.X, pady=(0, 10))
        
        stats = report['statistics']
        perf = report['performance']
        
        stats_text = f"""
⏱️  Tempo de execução: {report['execution_time']:.2f}s
📁 Arquivos processados: {stats['processed']}
✅ Sucessos: {stats['successful']}
❌ Erros: {stats['errors']}
📈 Taxa: {perf['files_per_second']:.1f} arquivos/s
🎯 Taxa de sucesso: {perf['success_rate']:.1f}%
"""
        
        ttk.Label(stats_frame, text=stats_text, justify=tk.LEFT).pack(anchor=tk.W)
        
        # Top categorias
        if report['top_categories']:
            cat_frame = ttk.LabelFrame(main_frame, text="🏆 Top Categorias", padding="10")
            cat_frame.pack(fill=tk.X, pady=(0, 10))
            
            for category, count in report['top_categories']:
                percentage = (count / stats['processed']) * 100 if stats['processed'] > 0 else 0
                ttk.Label(cat_frame, text=f"{category}: {count} ({percentage:.1f}%)").pack(anchor=tk.W)
        
        # Recomendações
        if report['recommendations']:
            rec_frame = ttk.LabelFrame(main_frame, text="💡 Recomendações", padding="10")
            rec_frame.pack(fill=tk.BOTH, expand=True)
            
            rec_text = scrolledtext.ScrolledText(rec_frame, height=8)
            rec_text.pack(fill=tk.BOTH, expand=True)
            
            for rec in report['recommendations']:
                rec_text.insert(tk.END, f"• {rec}\n")
                
        # Botões
        button_frame = ttk.Frame(main_frame)
        button_frame.pack(fill=tk.X, pady=(10, 0))
        
        ttk.Button(button_frame, text="📄 Salvar Relatório", 
                  command=lambda: self._save_report(report)).pack(side=tk.LEFT, padx=(0, 10))
        ttk.Button(button_frame, text="✅ Fechar", 
                  command=results_window.destroy).pack(side=tk.RIGHT)
                  
    def _save_report(self, report: dict):
        """Salva relatório em arquivo"""
        filename = filedialog.asksaveasfilename(
            title="Salvar Relatório",
            defaultextension=".json",
            filetypes=[("JSON files", "*.json"), ("All files", "*.*")],
            initialname=f"relatorio_lote_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        )
        
        if filename:
            try:
                with open(filename, 'w', encoding='utf-8') as f:
                    json.dump(report, f, indent=2, ensure_ascii=False)
                messagebox.showinfo("Sucesso", f"Relatório salvo em:\n{filename}")
            except Exception as e:
                messagebox.showerror("Erro", f"Erro ao salvar relatório:\n{str(e)}")
                
    def run(self):
        """Executa a interface"""
        self.root.mainloop()

def main():
    """Função principal"""
    try:
        app = InterfaceClassificadorLote()
        app.run()
    except Exception as e:
        print(f"Erro ao iniciar interface: {str(e)}")
        
if __name__ == "__main__":
    main()