#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Demo Completa - Classificação em Tempo Real
Integração com TaskManager e Interface Gráfica
"""

import os
import sys
import json
import time
import sqlite3
from pathlib import Path
from datetime import datetime
import shutil
import hashlib

# Adicionar o diretório atual ao path para imports
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

class DemoClassificadorCompleto:
    """Demonstração completa do sistema de classificação"""
    
    def __init__(self):
        self.demo_path = Path("Demo_Tests")
        self.input_path = self.demo_path / "Input"
        self.output_path = self.demo_path / "Output"
        self.metadata_path = self.demo_path / "Metadata"
        self.reports_path = self.demo_path / "Reports"
        self.logs_path = self.demo_path / "Logs"
        
        # Conectar ao banco de dados do TaskManager
        self.db_path = "tasks.db"
        self.init_database()
        
        # Estatísticas da demo
        self.stats = {
            "arquivos_processados": 0,
            "eas_encontrados": 0,
            "indicadores_encontrados": 0,
            "scripts_encontrados": 0,
            "ftmo_ready": 0,
            "metadados_gerados": 0,
            "tempo_inicio": None,
            "tempo_fim": None
        }
    
    def init_database(self):
        """Inicializa o banco de dados do TaskManager"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Criar tabelas se não existirem
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS requests (
                id TEXT PRIMARY KEY,
                original_request TEXT NOT NULL,
                split_details TEXT,
                status TEXT DEFAULT 'pending',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                completed_at TIMESTAMP
            )
        ''')
        
        cursor.execute('''
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
        ''')
        
        conn.commit()
        conn.close()
    
    def criar_request_demo(self):
        """Cria uma nova requisição no TaskManager para a demo"""
        import uuid
        
        request_id = str(uuid.uuid4())
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Criar requisição
        cursor.execute('''
            INSERT INTO requests (id, original_request, split_details, status)
            VALUES (?, ?, ?, ?)
        ''', (
            request_id,
            "Demonstração completa do sistema de classificação de códigos MQ4",
            "Demo executada com 5 arquivos MQ4 representativos para mostrar todas as funcionalidades",
            "active"
        ))
        
        # Criar tarefas
        tasks = [
            {
                "title": "Preparar Ambiente de Classificação",
                "description": "Verificar estrutura de pastas e arquivos de entrada para a demo"
            },
            {
                "title": "Analisar Arquivos MQ4",
                "description": "Processar e analisar cada arquivo MQ4 para detectar tipo e estratégia"
            },
            {
                "title": "Classificar por Tipo",
                "description": "Separar arquivos em EAs, Indicadores e Scripts conforme análise"
            },
            {
                "title": "Detectar Estratégias",
                "description": "Identificar estratégias (Scalping, Grid/Martingale, Trend, SMC, Volume)"
            },
            {
                "title": "Verificar Compliance FTMO",
                "description": "Analisar conformidade com regras FTMO (risk management, SL, drawdown)"
            },
            {
                "title": "Gerar Metadados",
                "description": "Criar arquivos .meta.json com informações detalhadas de cada código"
            },
            {
                "title": "Organizar Arquivos",
                "description": "Mover arquivos para pastas apropriadas conforme classificação"
            },
            {
                "title": "Gerar Relatório Final",
                "description": "Criar relatório completo com estatísticas e resultados da classificação"
            }
        ]
        
        for i, task in enumerate(tasks):
            task_id = str(uuid.uuid4())
            cursor.execute('''
                INSERT INTO tasks (id, request_id, title, description, status)
                VALUES (?, ?, ?, ?, ?)
            ''', (
                task_id,
                request_id,
                task["title"],
                task["description"],
                "pending"
            ))
        
        conn.commit()
        conn.close()
        
        return request_id
    
    def marcar_task_concluida(self, request_id, task_title, detalhes=""):
        """Marca uma tarefa como concluída"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            UPDATE tasks 
            SET status = 'done', completed_details = ?, completed_at = CURRENT_TIMESTAMP
            WHERE request_id = ? AND title = ? AND status = 'pending'
        ''', (detalhes, request_id, task_title))
        
        conn.commit()
        conn.close()
    
    def log_acao(self, acao, detalhes=""):
        """Registra ação no log da demo"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        log_entry = f"[{timestamp}] {acao}"
        if detalhes:
            log_entry += f" - {detalhes}"
        
        print(log_entry)
        
        # Salvar no arquivo de log
        log_file = self.logs_path / "demo_execution.log"
        with open(log_file, 'a', encoding='utf-8') as f:
            f.write(log_entry + "\n")
    
    def analisar_arquivo_mq4(self, file_path):
        """Analisa um arquivo MQ4 e retorna informações de classificação"""
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
            ftmo_score = 0
            ftmo_checks = {
                "stop_loss": any(word in content for word in ["stoploss", "sl", "stop"]),
                "take_profit": any(word in content for word in ["takeprofit", "tp"]),
                "risk_management": any(word in content for word in ["risk", "lot", "balance"]),
                "drawdown_check": any(word in content for word in ["drawdown", "equity"]),
                "no_martingale": "martingale" not in content
            }
            
            ftmo_score = sum(ftmo_checks.values()) * 20  # 0-100 score
            ftmo_ready = ftmo_score >= 60
            
            # Calcular hash do arquivo
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
            self.log_acao(f"❌ Erro ao analisar {file_path.name}", str(e))
            return None
    
    def gerar_metadata(self, file_info, output_path):
        """Gera arquivo de metadados .meta.json"""
        metadata = {
            "id": file_info["hash"][:12],
            "arquivo": {
                "nome_original": file_info["nome_original"],
                "nome_renomeado": file_info["nome_original"],  # Simplificado para demo
                "hash": file_info["hash"],
                "tamanho_bytes": file_info["tamanho"],
                "data_modificacao": file_info["data_modificacao"]
            },
            "classificacao": {
                "tipo": file_info["tipo"],
                "linguagem": "MQL4",
                "estrategia": file_info["estrategia"],
                "mercados": ["MULTI"],
                "timeframes": ["M15", "H1"]
            },
            "ftmo_analysis": {
                "ftmo_ready": file_info["ftmo_ready"],
                "score": file_info["ftmo_score"],
                "checks": file_info["ftmo_checks"]
            },
            "qualidade": {
                "score": 85,
                "nivel": "Alto",
                "status_compilacao": "Não testado"
            },
            "tags": [
                f"#{file_info['tipo']}",
                f"#{file_info['estrategia']}",
                "#MQL4",
                "#Demo"
            ],
            "data_analise": datetime.now().isoformat()
        }
        
        # Salvar metadata
        metadata_file = self.metadata_path / f"{file_info['nome_original']}.meta.json"
        with open(metadata_file, 'w', encoding='utf-8') as f:
            json.dump(metadata, f, indent=2, ensure_ascii=False)
        
        return metadata_file
    
    def executar_demo_completa(self):
        """Executa a demonstração completa"""
        self.log_acao("🚀 INICIANDO DEMO COMPLETA DO CLASSIFICADOR")
        self.stats["tempo_inicio"] = datetime.now()
        
        # Criar requisição no TaskManager
        request_id = self.criar_request_demo()
        self.log_acao(f"📋 Request criada no TaskManager: {request_id[:8]}...")
        
        # TAREFA 1: Preparar Ambiente
        self.log_acao("📁 [1/8] Preparando ambiente de classificação...")
        time.sleep(1)
        
        if not self.input_path.exists():
            self.log_acao("❌ Pasta de entrada não encontrada!")
            return
        
        arquivos_mq4 = list(self.input_path.glob("*.mq4"))
        self.log_acao(f"✅ Encontrados {len(arquivos_mq4)} arquivos MQ4 para processar")
        self.marcar_task_concluida(request_id, "Preparar Ambiente de Classificação", 
                                 f"{len(arquivos_mq4)} arquivos encontrados")
        
        # TAREFA 2: Analisar Arquivos
        self.log_acao("🔍 [2/8] Analisando arquivos MQ4...")
        time.sleep(1)
        
        arquivos_analisados = []
        for i, arquivo in enumerate(arquivos_mq4, 1):
            self.log_acao(f"  📄 Analisando [{i}/{len(arquivos_mq4)}]: {arquivo.name}")
            info = self.analisar_arquivo_mq4(arquivo)
            if info:
                arquivos_analisados.append(info)
                self.stats["arquivos_processados"] += 1
            time.sleep(0.5)  # Simular processamento
        
        self.marcar_task_concluida(request_id, "Analisar Arquivos MQ4", 
                                 f"{len(arquivos_analisados)} arquivos analisados com sucesso")
        
        # TAREFA 3: Classificar por Tipo
        self.log_acao("📊 [3/8] Classificando por tipo...")
        time.sleep(1)
        
        tipos_encontrados = {}
        for info in arquivos_analisados:
            tipo = info["tipo"]
            if tipo not in tipos_encontrados:
                tipos_encontrados[tipo] = 0
            tipos_encontrados[tipo] += 1
            
            if tipo == "EA":
                self.stats["eas_encontrados"] += 1
            elif tipo == "Indicator":
                self.stats["indicadores_encontrados"] += 1
            elif tipo == "Script":
                self.stats["scripts_encontrados"] += 1
        
        for tipo, count in tipos_encontrados.items():
            self.log_acao(f"  📈 {tipo}: {count} arquivo(s)")
        
        self.marcar_task_concluida(request_id, "Classificar por Tipo", 
                                 f"Tipos encontrados: {tipos_encontrados}")
        
        # TAREFA 4: Detectar Estratégias
        self.log_acao("🎯 [4/8] Detectando estratégias...")
        time.sleep(1)
        
        estrategias_encontradas = {}
        for info in arquivos_analisados:
            estrategia = info["estrategia"]
            if estrategia not in estrategias_encontradas:
                estrategias_encontradas[estrategia] = 0
            estrategias_encontradas[estrategia] += 1
        
        for estrategia, count in estrategias_encontradas.items():
            self.log_acao(f"  🎲 {estrategia}: {count} arquivo(s)")
        
        self.marcar_task_concluida(request_id, "Detectar Estratégias", 
                                 f"Estratégias: {estrategias_encontradas}")
        
        # TAREFA 5: Verificar FTMO
        self.log_acao("🛡️ [5/8] Verificando compliance FTMO...")
        time.sleep(1)
        
        for info in arquivos_analisados:
            if info["ftmo_ready"]:
                self.stats["ftmo_ready"] += 1
                self.log_acao(f"  ✅ {info['nome_original']}: FTMO Ready (Score: {info['ftmo_score']})")
            else:
                self.log_acao(f"  ⚠️ {info['nome_original']}: Não FTMO (Score: {info['ftmo_score']})")
        
        self.marcar_task_concluida(request_id, "Verificar Compliance FTMO", 
                                 f"{self.stats['ftmo_ready']} arquivos FTMO-Ready de {len(arquivos_analisados)}")
        
        # TAREFA 6: Gerar Metadados
        self.log_acao("📝 [6/8] Gerando metadados...")
        time.sleep(1)
        
        for info in arquivos_analisados:
            metadata_file = self.gerar_metadata(info, self.output_path)
            self.stats["metadados_gerados"] += 1
            self.log_acao(f"  📄 Metadata criado: {metadata_file.name}")
            time.sleep(0.3)
        
        self.marcar_task_concluida(request_id, "Gerar Metadados", 
                                 f"{self.stats['metadados_gerados']} arquivos de metadata criados")
        
        # TAREFA 7: Organizar Arquivos
        self.log_acao("📁 [7/8] Organizando arquivos...")
        time.sleep(1)
        
        for i, (arquivo, info) in enumerate(zip(arquivos_mq4, arquivos_analisados), 1):
            # Determinar pasta destino
            if info["tipo"] == "EA":
                if info["estrategia"] == "Scalping":
                    dest_folder = self.output_path / "EAs" / "Scalping"
                elif info["estrategia"] == "Grid_Martingale":
                    dest_folder = self.output_path / "EAs" / "Grid_Martingale"
                else:
                    dest_folder = self.output_path / "EAs" / "Trend"
            elif info["tipo"] == "Indicator":
                if info["estrategia"] == "SMC":
                    dest_folder = self.output_path / "Indicators" / "SMC"
                elif info["estrategia"] == "Volume":
                    dest_folder = self.output_path / "Indicators" / "Volume"
                else:
                    dest_folder = self.output_path / "Indicators" / "Custom"
            else:
                dest_folder = self.output_path / "Scripts" / "Utilities"
            
            # Criar pasta se não existir
            dest_folder.mkdir(parents=True, exist_ok=True)
            
            # Copiar arquivo
            dest_file = dest_folder / arquivo.name
            shutil.copy2(arquivo, dest_file)
            self.log_acao(f"  📂 [{i}/{len(arquivos_mq4)}] {arquivo.name} → {dest_folder.name}")
            time.sleep(0.2)
        
        self.marcar_task_concluida(request_id, "Organizar Arquivos", 
                                 f"{len(arquivos_mq4)} arquivos organizados por categoria")
        
        # TAREFA 8: Gerar Relatório
        self.log_acao("📊 [8/8] Gerando relatório final...")
        time.sleep(1)
        
        self.stats["tempo_fim"] = datetime.now()
        tempo_execucao = (self.stats["tempo_fim"] - self.stats["tempo_inicio"]).total_seconds()
        
        relatorio = {
            "demo_info": {
                "data_execucao": self.stats["tempo_inicio"].isoformat(),
                "tempo_execucao_segundos": tempo_execucao,
                "request_id": request_id
            },
            "estatisticas": {
                "arquivos_processados": self.stats["arquivos_processados"],
                "eas_encontrados": self.stats["eas_encontrados"],
                "indicadores_encontrados": self.stats["indicadores_encontrados"],
                "scripts_encontrados": self.stats["scripts_encontrados"],
                "ftmo_ready": self.stats["ftmo_ready"],
                "metadados_gerados": self.stats["metadados_gerados"]
            },
            "distribuicao_tipos": tipos_encontrados,
            "distribuicao_estrategias": estrategias_encontradas,
            "arquivos_detalhados": arquivos_analisados
        }
        
        # Salvar relatório
        relatorio_file = self.reports_path / f"demo_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(relatorio_file, 'w', encoding='utf-8') as f:
            json.dump(relatorio, f, indent=2, ensure_ascii=False)
        
        self.log_acao(f"📋 Relatório salvo: {relatorio_file.name}")
        self.marcar_task_concluida(request_id, "Gerar Relatório Final", 
                                 f"Relatório completo gerado: {relatorio_file.name}")
        
        # Finalizar
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute('''
            UPDATE requests 
            SET status = 'completed', completed_at = CURRENT_TIMESTAMP
            WHERE id = ?
        ''', (request_id,))
        conn.commit()
        conn.close()
        
        self.log_acao("🎉 DEMO COMPLETA FINALIZADA COM SUCESSO!")
        self.log_acao(f"⏱️ Tempo total: {tempo_execucao:.1f} segundos")
        self.log_acao(f"📊 Arquivos processados: {self.stats['arquivos_processados']}")
        self.log_acao(f"🛡️ FTMO Ready: {self.stats['ftmo_ready']}")
        self.log_acao(f"📝 Metadados gerados: {self.stats['metadados_gerados']}")
        
        return relatorio

def main():
    """Função principal"""
    print("🎯 EXECUTANDO DEMO COMPLETA DO CLASSIFICADOR")
    print("=" * 50)
    
    demo = DemoClassificadorCompleto()
    
    try:
        relatorio = demo.executar_demo_completa()
        print("\n✅ Demo executada com sucesso!")
        print(f"📊 Relatório disponível em: Demo_Tests/Reports/")
        return True
    except Exception as e:
        print(f"❌ Erro na execução da demo: {e}")
        return False

if __name__ == "__main__":
    main()