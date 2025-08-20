#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Demo Interface Visual - Classificação em Tempo Real
Interface gráfica aprimorada para mostrar o processo completo
"""

import tkinter as tk
from tkinter import ttk, scrolledtext
import threading
import time
import os
import json
import shutil
import hashlib
from pathlib import Path
from datetime import datetime
import sqlite3
import uuid

class DemoInterfaceVisual:
    """Interface gráfica visual para demonstração do classificador"""
    
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("🚀 DEMO CLASSIFICADOR TRADING - TEMPO REAL")
        self.root.geometry("1200x800")
        self.root.configure(bg='#1e1e1e')
        
        # Variáveis de controle
        self.demo_running = False
        self.current_step = 0
        self.total_steps = 8
        self.arquivos_processados = 0
        self.total_arquivos = 3
        
        # Configurar interface
        self.setup_interface()
        
        # Preparar ambiente com 3 arquivos
        self.preparar_ambiente_3_arquivos()
    
    def setup_interface(self):
        """Configura a interface gráfica"""
        
        # Título principal
        title_frame = tk.Frame(self.root, bg='#1e1e1e')
        title_frame.pack(fill='x', padx=10, pady=10)
        
        title_label = tk.Label(
            title_frame,
            text="🚀 CLASSIFICADOR TRADING - DEMONSTRAÇÃO VISUAL",
            font=('Arial', 16, 'bold'),
            fg='#00ff00',
            bg='#1e1e1e'
        )
        title_label.pack()
        
        # Frame principal com duas colunas
        main_frame = tk.Frame(self.root, bg='#1e1e1e')
        main_frame.pack(fill='both', expand=True, padx=10, pady=5)
        
        # Coluna esquerda - Controles e Status
        left_frame = tk.Frame(main_frame, bg='#2d2d2d', relief='raised', bd=2)
        left_frame.pack(side='left', fill='both', expand=True, padx=(0, 5))
        
        # Coluna direita - Logs e Detalhes
        right_frame = tk.Frame(main_frame, bg='#2d2d2d', relief='raised', bd=2)
        right_frame.pack(side='right', fill='both', expand=True, padx=(5, 0))
        
        # === COLUNA ESQUERDA ===
        
        # Botão de início
        control_frame = tk.Frame(left_frame, bg='#2d2d2d')
        control_frame.pack(fill='x', padx=10, pady=10)
        
        self.start_button = tk.Button(
            control_frame,
            text="🚀 INICIAR DEMO (3 ARQUIVOS)",
            font=('Arial', 12, 'bold'),
            bg='#00aa00',
            fg='white',
            command=self.iniciar_demo,
            height=2
        )
        self.start_button.pack(fill='x')
        
        # Progress geral
        progress_frame = tk.Frame(left_frame, bg='#2d2d2d')
        progress_frame.pack(fill='x', padx=10, pady=10)
        
        tk.Label(
            progress_frame,
            text="📊 PROGRESSO GERAL",
            font=('Arial', 10, 'bold'),
            fg='#ffffff',
            bg='#2d2d2d'
        ).pack()
        
        self.progress_var = tk.DoubleVar()
        self.progress_bar = ttk.Progressbar(
            progress_frame,
            variable=self.progress_var,
            maximum=100,
            length=300
        )
        self.progress_bar.pack(pady=5)
        
        self.progress_label = tk.Label(
            progress_frame,
            text="Aguardando início...",
            font=('Arial', 9),
            fg='#cccccc',
            bg='#2d2d2d'
        )
        self.progress_label.pack()
        
        # Status das etapas
        steps_frame = tk.Frame(left_frame, bg='#2d2d2d')
        steps_frame.pack(fill='both', expand=True, padx=10, pady=10)
        
        tk.Label(
            steps_frame,
            text="📋 ETAPAS DO PROCESSO",
            font=('Arial', 10, 'bold'),
            fg='#ffffff',
            bg='#2d2d2d'
        ).pack()
        
        # Lista de etapas
        self.steps_frame = tk.Frame(steps_frame, bg='#2d2d2d')
        self.steps_frame.pack(fill='both', expand=True, pady=5)
        
        self.step_labels = []
        steps = [
            "1. Preparar Ambiente",
            "2. Analisar Arquivos MQ4",
            "3. Classificar por Tipo",
            "4. Detectar Estratégias",
            "5. Verificar FTMO",
            "6. Gerar Metadados",
            "7. Organizar Arquivos",
            "8. Gerar Relatório"
        ]
        
        for i, step in enumerate(steps):
            label = tk.Label(
                self.steps_frame,
                text=f"⏳ {step}",
                font=('Arial', 9),
                fg='#888888',
                bg='#2d2d2d',
                anchor='w'
            )
            label.pack(fill='x', pady=2)
            self.step_labels.append(label)
        
        # Estatísticas em tempo real
        stats_frame = tk.Frame(left_frame, bg='#2d2d2d')
        stats_frame.pack(fill='x', padx=10, pady=10)
        
        tk.Label(
            stats_frame,
            text="📊 ESTATÍSTICAS",
            font=('Arial', 10, 'bold'),
            fg='#ffffff',
            bg='#2d2d2d'
        ).pack()
        
        self.stats_text = tk.Text(
            stats_frame,
            height=8,
            width=40,
            bg='#1a1a1a',
            fg='#00ff00',
            font=('Courier', 9),
            state='disabled'
        )
        self.stats_text.pack(fill='x', pady=5)
        
        # === COLUNA DIREITA ===
        
        # Logs em tempo real
        logs_frame = tk.Frame(right_frame, bg='#2d2d2d')
        logs_frame.pack(fill='both', expand=True, padx=10, pady=10)
        
        tk.Label(
            logs_frame,
            text="📝 LOGS EM TEMPO REAL",
            font=('Arial', 10, 'bold'),
            fg='#ffffff',
            bg='#2d2d2d'
        ).pack()
        
        self.logs_text = scrolledtext.ScrolledText(
            logs_frame,
            height=25,
            width=60,
            bg='#0a0a0a',
            fg='#00ff00',
            font=('Courier', 9),
            state='disabled'
        )
        self.logs_text.pack(fill='both', expand=True, pady=5)
        
        # Detalhes dos arquivos
        details_frame = tk.Frame(right_frame, bg='#2d2d2d')
        details_frame.pack(fill='x', padx=10, pady=10)
        
        tk.Label(
            details_frame,
            text="📄 DETALHES DOS ARQUIVOS",
            font=('Arial', 10, 'bold'),
            fg='#ffffff',
            bg='#2d2d2d'
        ).pack()
        
        self.details_text = tk.Text(
            details_frame,
            height=8,
            width=60,
            bg='#1a1a1a',
            fg='#ffff00',
            font=('Courier', 8),
            state='disabled'
        )
        self.details_text.pack(fill='x', pady=5)
    
    def preparar_ambiente_3_arquivos(self):
        """Prepara ambiente com apenas 3 arquivos para demo rápida"""
        
        # Criar estrutura
        demo_dirs = [
            "Demo_Visual/Input",
            "Demo_Visual/Output/EAs/Scalping",
            "Demo_Visual/Output/EAs/Trend",
            "Demo_Visual/Output/Indicators/Custom",
            "Demo_Visual/Metadata",
            "Demo_Visual/Reports",
            "Demo_Visual/Logs"
        ]
        
        for dir_path in demo_dirs:
            os.makedirs(dir_path, exist_ok=True)
        
        # Copiar apenas 3 arquivos específicos
        source_dir = Path("CODIGO_FONTE_LIBRARY/MQL4_Source/All_MQ4")
        target_dir = Path("Demo_Visual/Input")
        
        if source_dir.exists():
            all_files = list(source_dir.glob("*.mq4"))
            
            # Selecionar 3 arquivos específicos
            selected_files = all_files[:3] if len(all_files) >= 3 else all_files
            
            for file_path in selected_files:
                target_path = target_dir / file_path.name
                if not target_path.exists():
                    shutil.copy2(file_path, target_path)
        
        self.log_message("✅ Ambiente preparado com 3 arquivos MQ4")
    
    def log_message(self, message, color='#00ff00'):
        """Adiciona mensagem aos logs"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        formatted_message = f"[{timestamp}] {message}\n"
        
        self.logs_text.config(state='normal')
        self.logs_text.insert(tk.END, formatted_message)
        self.logs_text.config(state='disabled')
        self.logs_text.see(tk.END)
        
        # Atualizar interface
        self.root.update()
    
    def update_stats(self, stats_dict):
        """Atualiza estatísticas em tempo real"""
        self.stats_text.config(state='normal')
        self.stats_text.delete(1.0, tk.END)
        
        stats_text = ""
        for key, value in stats_dict.items():
            stats_text += f"{key}: {value}\n"
        
        self.stats_text.insert(1.0, stats_text)
        self.stats_text.config(state='disabled')
        self.root.update()
    
    def update_details(self, details):
        """Atualiza detalhes dos arquivos"""
        self.details_text.config(state='normal')
        self.details_text.delete(1.0, tk.END)
        self.details_text.insert(1.0, details)
        self.details_text.config(state='disabled')
        self.root.update()
    
    def update_step(self, step_index, status='running'):
        """Atualiza status de uma etapa"""
        if 0 <= step_index < len(self.step_labels):
            label = self.step_labels[step_index]
            
            if status == 'running':
                icon = "🔄"
                color = '#ffff00'
            elif status == 'done':
                icon = "✅"
                color = '#00ff00'
            else:
                icon = "⏳"
                color = '#888888'
            
            text = label.cget('text')
            new_text = f"{icon} {text[2:]}"
            label.config(text=new_text, fg=color)
            
            self.root.update()
    
    def analisar_arquivo_mq4(self, file_path):
        """Analisa um arquivo MQ4 e retorna informações"""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read().lower()
            
            # Detectar tipo
            tipo = "Unknown"
            if "ontick()" in content and ("ordersend" in content or "buy" in content or "sell" in content):
                tipo = "EA"
            elif "oncalculate()" in content or "setindexbuffer" in content:
                tipo = "Indicator"
            elif "onstart()" in content:
                tipo = "Script"
            
            # Detectar estratégia
            estrategia = "Custom"
            if any(word in content for word in ["scalp", "m1", "m5"]):
                estrategia = "Scalping"
            elif any(word in content for word in ["grid", "martingale", "recovery"]):
                estrategia = "Grid_Martingale"
            elif any(word in content for word in ["trend", "momentum", "ma", "moving average"]):
                estrategia = "Trend"
            elif any(word in content for word in ["order_block", "liquidity", "institutional"]):
                estrategia = "SMC"
            elif any(word in content for word in ["volume", "obv", "flow"]):
                estrategia = "Volume"
            
            # Verificar FTMO compliance
            ftmo_checks = {
                "stop_loss": any(word in content for word in ["stoploss", "sl", "stop"]),
                "take_profit": any(word in content for word in ["takeprofit", "tp"]),
                "risk_management": any(word in content for word in ["risk", "lot", "balance"]),
                "drawdown_check": any(word in content for word in ["drawdown", "equity"]),
                "no_martingale": "martingale" not in content
            }
            
            ftmo_score = sum(ftmo_checks.values()) * 20
            ftmo_ready = ftmo_score >= 60
            
            # Hash do arquivo
            with open(file_path, 'rb') as f:
                file_hash = hashlib.md5(f.read()).hexdigest()
            
            return {
                "nome_original": file_path.name,
                "tipo": tipo,
                "estrategia": estrategia,
                "ftmo_ready": ftmo_ready,
                "ftmo_score": ftmo_score,
                "ftmo_checks": ftmo_checks,
                "hash": file_hash,
                "tamanho": file_path.stat().st_size,
                "data_modificacao": datetime.fromtimestamp(file_path.stat().st_mtime).isoformat()
            }
            
        except Exception as e:
            self.log_message(f"❌ Erro ao analisar {file_path.name}: {str(e)}")
            return None
    
    def executar_classificacao(self):
        """Executa a classificação completa com interface visual"""
        
        self.log_message("🚀 INICIANDO CLASSIFICAÇÃO VISUAL")
        
        # Estatísticas iniciais
        stats = {
            "📄 Arquivos": "0/3",
            "🤖 EAs": "0",
            "📈 Indicadores": "0",
            "📜 Scripts": "0",
            "🛡️ FTMO Ready": "0",
            "📝 Metadados": "0"
        }
        
        input_path = Path("Demo_Visual/Input")
        arquivos_mq4 = list(input_path.glob("*.mq4"))
        self.total_arquivos = len(arquivos_mq4)
        
        # ETAPA 1: Preparar Ambiente
        self.update_step(0, 'running')
        self.log_message("📁 [1/8] Preparando ambiente...")
        time.sleep(1)
        self.log_message(f"✅ Encontrados {len(arquivos_mq4)} arquivos para processar")
        self.update_step(0, 'done')
        self.progress_var.set(12.5)
        self.progress_label.config(text="Ambiente preparado")
        
        # ETAPA 2: Analisar Arquivos
        self.update_step(1, 'running')
        self.log_message("🔍 [2/8] Analisando arquivos MQ4...")
        
        arquivos_analisados = []
        for i, arquivo in enumerate(arquivos_mq4, 1):
            self.log_message(f"  📄 Analisando [{i}/{len(arquivos_mq4)}]: {arquivo.name}")
            
            info = self.analisar_arquivo_mq4(arquivo)
            if info:
                arquivos_analisados.append(info)
                
                # Atualizar detalhes em tempo real
                details = f"Arquivo: {info['nome_original']}\n"
                details += f"Tipo: {info['tipo']}\n"
                details += f"Estratégia: {info['estrategia']}\n"
                details += f"FTMO Score: {info['ftmo_score']}\n"
                details += f"FTMO Ready: {'✅' if info['ftmo_ready'] else '❌'}\n"
                details += f"Hash: {info['hash'][:12]}...\n"
                details += f"Tamanho: {info['tamanho']} bytes"
                
                self.update_details(details)
            
            time.sleep(1.5)  # Pausa para visualização
        
        self.update_step(1, 'done')
        self.progress_var.set(25)
        self.progress_label.config(text="Arquivos analisados")
        
        # ETAPA 3: Classificar por Tipo
        self.update_step(2, 'running')
        self.log_message("📊 [3/8] Classificando por tipo...")
        
        tipos_encontrados = {}
        for info in arquivos_analisados:
            tipo = info["tipo"]
            if tipo not in tipos_encontrados:
                tipos_encontrados[tipo] = 0
            tipos_encontrados[tipo] += 1
        
        for tipo, count in tipos_encontrados.items():
            self.log_message(f"  📈 {tipo}: {count} arquivo(s)")
        
        # Atualizar stats
        stats["🤖 EAs"] = str(tipos_encontrados.get("EA", 0))
        stats["📈 Indicadores"] = str(tipos_encontrados.get("Indicator", 0))
        stats["📜 Scripts"] = str(tipos_encontrados.get("Script", 0))
        self.update_stats(stats)
        
        self.update_step(2, 'done')
        self.progress_var.set(37.5)
        self.progress_label.config(text="Tipos classificados")
        time.sleep(1)
        
        # ETAPA 4: Detectar Estratégias
        self.update_step(3, 'running')
        self.log_message("🎯 [4/8] Detectando estratégias...")
        
        estrategias_encontradas = {}
        for info in arquivos_analisados:
            estrategia = info["estrategia"]
            if estrategia not in estrategias_encontradas:
                estrategias_encontradas[estrategia] = 0
            estrategias_encontradas[estrategia] += 1
        
        for estrategia, count in estrategias_encontradas.items():
            self.log_message(f"  🎲 {estrategia}: {count} arquivo(s)")
        
        self.update_step(3, 'done')
        self.progress_var.set(50)
        self.progress_label.config(text="Estratégias detectadas")
        time.sleep(1)
        
        # ETAPA 5: Verificar FTMO
        self.update_step(4, 'running')
        self.log_message("🛡️ [5/8] Verificando compliance FTMO...")
        
        ftmo_ready_count = 0
        for info in arquivos_analisados:
            if info["ftmo_ready"]:
                ftmo_ready_count += 1
                self.log_message(f"  ✅ {info['nome_original']}: FTMO Ready (Score: {info['ftmo_score']})")
            else:
                self.log_message(f"  ⚠️ {info['nome_original']}: Não FTMO (Score: {info['ftmo_score']})")
            time.sleep(0.8)
        
        stats["🛡️ FTMO Ready"] = str(ftmo_ready_count)
        self.update_stats(stats)
        
        self.update_step(4, 'done')
        self.progress_var.set(62.5)
        self.progress_label.config(text="FTMO verificado")
        
        # ETAPA 6: Gerar Metadados
        self.update_step(5, 'running')
        self.log_message("📝 [6/8] Gerando metadados...")
        
        metadados_gerados = 0
        for info in arquivos_analisados:
            # Criar metadata
            metadata = {
                "id": info["hash"][:12],
                "arquivo": {
                    "nome_original": info["nome_original"],
                    "hash": info["hash"],
                    "tamanho_bytes": info["tamanho"]
                },
                "classificacao": {
                    "tipo": info["tipo"],
                    "estrategia": info["estrategia"]
                },
                "ftmo_analysis": {
                    "ftmo_ready": info["ftmo_ready"],
                    "score": info["ftmo_score"]
                },
                "data_analise": datetime.now().isoformat()
            }
            
            # Salvar metadata
            metadata_file = Path("Demo_Visual/Metadata") / f"{info['nome_original']}.meta.json"
            with open(metadata_file, 'w', encoding='utf-8') as f:
                json.dump(metadata, f, indent=2, ensure_ascii=False)
            
            metadados_gerados += 1
            self.log_message(f"  📄 Metadata criado: {metadata_file.name}")
            time.sleep(0.5)
        
        stats["📝 Metadados"] = str(metadados_gerados)
        stats["📄 Arquivos"] = f"{len(arquivos_analisados)}/{self.total_arquivos}"
        self.update_stats(stats)
        
        self.update_step(5, 'done')
        self.progress_var.set(75)
        self.progress_label.config(text="Metadados gerados")
        
        # ETAPA 7: Organizar Arquivos
        self.update_step(6, 'running')
        self.log_message("📁 [7/8] Organizando arquivos...")
        
        for i, (arquivo, info) in enumerate(zip(arquivos_mq4, arquivos_analisados), 1):
            # Determinar pasta destino
            if info["tipo"] == "EA":
                if info["estrategia"] == "Scalping":
                    dest_folder = Path("Demo_Visual/Output/EAs/Scalping")
                else:
                    dest_folder = Path("Demo_Visual/Output/EAs/Trend")
            else:
                dest_folder = Path("Demo_Visual/Output/Indicators/Custom")
            
            # Copiar arquivo
            dest_file = dest_folder / arquivo.name
            shutil.copy2(arquivo, dest_file)
            self.log_message(f"  📂 [{i}/{len(arquivos_mq4)}] {arquivo.name} → {dest_folder.name}")
            time.sleep(0.8)
        
        self.update_step(6, 'done')
        self.progress_var.set(87.5)
        self.progress_label.config(text="Arquivos organizados")
        
        # ETAPA 8: Gerar Relatório
        self.update_step(7, 'running')
        self.log_message("📊 [8/8] Gerando relatório final...")
        
        relatorio = {
            "demo_info": {
                "data_execucao": datetime.now().isoformat(),
                "arquivos_processados": len(arquivos_analisados)
            },
            "estatisticas": {
                "tipos": tipos_encontrados,
                "estrategias": estrategias_encontradas,
                "ftmo_ready": ftmo_ready_count
            },
            "arquivos": arquivos_analisados
        }
        
        # Salvar relatório
        relatorio_file = Path("Demo_Visual/Reports") / f"demo_visual_{datetime.now().strftime('%H%M%S')}.json"
        with open(relatorio_file, 'w', encoding='utf-8') as f:
            json.dump(relatorio, f, indent=2, ensure_ascii=False)
        
        self.log_message(f"📋 Relatório salvo: {relatorio_file.name}")
        
        self.update_step(7, 'done')
        self.progress_var.set(100)
        self.progress_label.config(text="✅ DEMO COMPLETA!")
        
        # Finalizar
        self.log_message("🎉 DEMO VISUAL FINALIZADA COM SUCESSO!")
        self.log_message(f"📊 Total processado: {len(arquivos_analisados)} arquivos")
        self.log_message(f"🛡️ FTMO Ready: {ftmo_ready_count}")
        self.log_message(f"📝 Metadados: {metadados_gerados}")
        
        # Reativar botão
        self.start_button.config(state='normal', text="🔄 EXECUTAR NOVAMENTE")
        self.demo_running = False
    
    def iniciar_demo(self):
        """Inicia a demonstração em thread separada"""
        if not self.demo_running:
            self.demo_running = True
            self.start_button.config(state='disabled', text="🔄 EXECUTANDO...")
            
            # Resetar interface
            self.progress_var.set(0)
            self.progress_label.config(text="Iniciando...")
            
            for i in range(len(self.step_labels)):
                self.update_step(i, 'pending')
            
            # Limpar logs
            self.logs_text.config(state='normal')
            self.logs_text.delete(1.0, tk.END)
            self.logs_text.config(state='disabled')
            
            # Executar em thread separada
            thread = threading.Thread(target=self.executar_classificacao)
            thread.daemon = True
            thread.start()
    
    def run(self):
        """Executa a interface"""
        self.log_message("🚀 Interface Visual Iniciada - Pronta para demonstração")
        self.log_message("💡 Clique em 'INICIAR DEMO' para começar")
        self.root.mainloop()

def main():
    """Função principal"""
    print("🚀 Iniciando Demo Interface Visual...")
    
    demo = DemoInterfaceVisual()
    demo.run()

if __name__ == "__main__":
    main()