#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para unificar as três pastas de Metadata em uma única estrutura organizada.
Classificador_Trading - Agente de Organização de Bibliotecas de Trading
"""

import os
import json
import shutil
from datetime import datetime
from pathlib import Path

class UnificadorMetadata:
    def __init__(self, base_path):
        self.base_path = Path(base_path)
        self.pasta_principal = self.base_path / "Metadata"
        self.pasta_codigo_fonte = self.base_path / "CODIGO_FONTE_LIBRARY" / "Metadata"
        self.pasta_mql5 = self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL5_Source" / "Metadata"
        
        # Backup das pastas originais
        self.backup_dir = self.base_path / "Backup_Metadata_" + datetime.now().strftime("%Y%m%d_%H%M%S")
        
    def criar_backup(self):
        """Cria backup das pastas de metadata antes da unificação"""
        print("Criando backup das pastas de metadata...")
        self.backup_dir.mkdir(exist_ok=True)
        
        # Backup pasta principal
        if self.pasta_principal.exists():
            shutil.copytree(self.pasta_principal, self.backup_dir / "Metadata_Principal")
            
        # Backup pasta codigo fonte
        if self.pasta_codigo_fonte.exists():
            shutil.copytree(self.pasta_codigo_fonte, self.backup_dir / "Metadata_CodigoFonte")
            
        # Backup pasta MQL5
        if self.pasta_mql5.exists():
            shutil.copytree(self.pasta_mql5, self.backup_dir / "Metadata_MQL5")
            
        print(f"Backup criado em: {self.backup_dir}")
        
    def carregar_catalogo_master(self, caminho):
        """Carrega um arquivo CATALOGO_MASTER.json"""
        try:
            with open(caminho, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            print(f"Erro ao carregar {caminho}: {e}")
            return None
            
    def unificar_catalogos(self):
        """Unifica os dados dos CATALOGO_MASTER.json das três pastas"""
        print("Unificando catálogos master...")
        
        # Carregar catálogos
        catalogo_principal = self.carregar_catalogo_master(self.pasta_principal / "CATALOGO_MASTER.json")
        catalogo_codigo_fonte = self.carregar_catalogo_master(self.pasta_codigo_fonte / "CATALOGO_MASTER.json")
        
        # Criar catálogo unificado baseado no mais recente (pasta principal)
        catalogo_unificado = {
            "projeto": "EA_SCALPER_XAUUSD",
            "versao_catalogo": "2.0",
            "ultima_atualizacao": datetime.now().isoformat() + "Z",
            "estatisticas": {
                "total_arquivos": 0,
                "ea": 0,
                "indicator": 0,
                "script": 0,
                "metadados_criados": 0,
                "ftmo_ready": 0,
                "nao_ftmo": 0,
                "mql4_arquivos": 0,
                "mql5_arquivos": 0,
                "pine_script_arquivos": 0
            },
            "arquivos": [],
            "arquivos_processados": [],
            "log_unificacao": [
                f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}: Unificação automática das três pastas de Metadata"
            ]
        }
        
        # Unificar arquivos do catálogo principal
        if catalogo_principal and "arquivos" in catalogo_principal:
            catalogo_unificado["arquivos"].extend(catalogo_principal["arquivos"])
            
        # Unificar arquivos do catálogo código fonte
        if catalogo_codigo_fonte and "arquivos_processados" in catalogo_codigo_fonte:
            for arquivo in catalogo_codigo_fonte["arquivos_processados"]:
                # Verificar se já existe
                if not any(a.get("id") == arquivo.get("id") for a in catalogo_unificado["arquivos"]):
                    catalogo_unificado["arquivos"].append(arquivo)
                    
        # Recalcular estatísticas
        self.recalcular_estatisticas(catalogo_unificado)
        
        return catalogo_unificado
        
    def recalcular_estatisticas(self, catalogo):
        """Recalcula as estatísticas do catálogo unificado"""
        stats = catalogo["estatisticas"]
        arquivos = catalogo["arquivos"]
        
        stats["total_arquivos"] = len(arquivos)
        
        for arquivo in arquivos:
            tipo = arquivo.get("tipo", "").lower()
            linguagem = arquivo.get("linguagem", "").lower()
            ftmo_score = arquivo.get("ftmo_score", 0)
            
            # Contar por tipo
            if tipo == "ea":
                stats["ea"] += 1
            elif tipo == "indicator":
                stats["indicator"] += 1
            elif tipo == "script":
                stats["script"] += 1
                
            # Contar por linguagem
            if "mql4" in linguagem:
                stats["mql4_arquivos"] += 1
            elif "mql5" in linguagem:
                stats["mql5_arquivos"] += 1
            elif "pine" in linguagem:
                stats["pine_script_arquivos"] += 1
                
            # Contar FTMO ready
            if ftmo_score >= 7:
                stats["ftmo_ready"] += 1
            else:
                stats["nao_ftmo"] += 1
                
        # Contar metadados criados
        stats["metadados_criados"] = len([f for f in self.pasta_principal.glob("*.meta.json")])
        
    def mover_arquivos_meta(self):
        """Move todos os arquivos .meta.json para a pasta principal"""
        print("Movendo arquivos .meta.json para pasta principal...")
        
        arquivos_movidos = 0
        
        # Mover da pasta código fonte
        if self.pasta_codigo_fonte.exists():
            for arquivo in self.pasta_codigo_fonte.glob("*.meta.json"):
                destino = self.pasta_principal / arquivo.name
                if not destino.exists():
                    shutil.move(str(arquivo), str(destino))
                    arquivos_movidos += 1
                    print(f"Movido: {arquivo.name}")
                else:
                    # Se já existe, criar com sufixo
                    contador = 1
                    while True:
                        nome_novo = f"{arquivo.stem}_{contador}.meta.json"
                        destino_novo = self.pasta_principal / nome_novo
                        if not destino_novo.exists():
                            shutil.move(str(arquivo), str(destino_novo))
                            arquivos_movidos += 1
                            print(f"Movido com sufixo: {nome_novo}")
                            break
                        contador += 1
                        
        # Mover da pasta MQL5
        if self.pasta_mql5.exists():
            for arquivo in self.pasta_mql5.glob("*.meta.json"):
                destino = self.pasta_principal / arquivo.name
                if not destino.exists():
                    shutil.move(str(arquivo), str(destino))
                    arquivos_movidos += 1
                    print(f"Movido: {arquivo.name}")
                else:
                    # Se já existe, criar com sufixo
                    contador = 1
                    while True:
                        nome_novo = f"{arquivo.stem}_{contador}.meta.json"
                        destino_novo = self.pasta_principal / nome_novo
                        if not destino_novo.exists():
                            shutil.move(str(arquivo), str(destino_novo))
                            arquivos_movidos += 1
                            print(f"Movido com sufixo: {nome_novo}")
                            break
                        contador += 1
                        
        print(f"Total de arquivos .meta.json movidos: {arquivos_movidos}")
        
    def remover_pastas_vazias(self):
        """Remove as pastas de metadata secundárias se estiverem vazias"""
        print("Verificando pastas vazias...")
        
        # Verificar pasta código fonte
        if self.pasta_codigo_fonte.exists():
            arquivos_restantes = list(self.pasta_codigo_fonte.glob("*"))
            if len(arquivos_restantes) <= 1:  # Apenas CATALOGO_MASTER.json ou vazia
                try:
                    shutil.rmtree(self.pasta_codigo_fonte)
                    print(f"Removida pasta vazia: {self.pasta_codigo_fonte}")
                except Exception as e:
                    print(f"Erro ao remover {self.pasta_codigo_fonte}: {e}")
                    
        # Verificar pasta MQL5
        if self.pasta_mql5.exists():
            arquivos_restantes = list(self.pasta_mql5.glob("*"))
            if len(arquivos_restantes) == 0:
                try:
                    shutil.rmtree(self.pasta_mql5)
                    print(f"Removida pasta vazia: {self.pasta_mql5}")
                except Exception as e:
                    print(f"Erro ao remover {self.pasta_mql5}: {e}")
                    
    def executar_unificacao(self):
        """Executa todo o processo de unificação"""
        print("=== INICIANDO UNIFICAÇÃO DE METADATA ===")
        print(f"Pasta base: {self.base_path}")
        
        # 1. Criar backup
        self.criar_backup()
        
        # 2. Mover arquivos .meta.json
        self.mover_arquivos_meta()
        
        # 3. Unificar catálogos
        catalogo_unificado = self.unificar_catalogos()
        
        # 4. Salvar catálogo unificado
        catalogo_path = self.pasta_principal / "CATALOGO_MASTER.json"
        with open(catalogo_path, 'w', encoding='utf-8') as f:
            json.dump(catalogo_unificado, f, indent=2, ensure_ascii=False)
        print(f"Catálogo unificado salvo em: {catalogo_path}")
        
        # 5. Remover pastas vazias
        self.remover_pastas_vazias()
        
        # 6. Relatório final
        self.gerar_relatorio_final(catalogo_unificado)
        
    def gerar_relatorio_final(self, catalogo):
        """Gera relatório final da unificação"""
        print("\n=== RELATÓRIO DE UNIFICAÇÃO ===")
        stats = catalogo["estatisticas"]
        
        print(f"Total de arquivos catalogados: {stats['total_arquivos']}")
        print(f"EAs: {stats['ea']}")
        print(f"Indicators: {stats['indicator']}")
        print(f"Scripts: {stats['script']}")
        print(f"Arquivos MQL4: {stats['mql4_arquivos']}")
        print(f"Arquivos MQL5: {stats['mql5_arquivos']}")
        print(f"FTMO Ready: {stats['ftmo_ready']}")
        print(f"Não FTMO: {stats['nao_ftmo']}")
        print(f"Metadados criados: {stats['metadados_criados']}")
        
        # Contar arquivos .meta.json na pasta principal
        meta_files = len(list(self.pasta_principal.glob("*.meta.json")))
        print(f"Arquivos .meta.json na pasta principal: {meta_files}")
        
        print(f"\nBackup criado em: {self.backup_dir}")
        print("\n=== UNIFICAÇÃO CONCLUÍDA COM SUCESSO ===")

if __name__ == "__main__":
    # Caminho base do projeto
    base_path = r"c:\Users\Admin\Documents\EA_SCALPER_XAUUSD"
    
    # Executar unificação
    unificador = UnificadorMetadata(base_path)
    unificador.executar_unificacao()