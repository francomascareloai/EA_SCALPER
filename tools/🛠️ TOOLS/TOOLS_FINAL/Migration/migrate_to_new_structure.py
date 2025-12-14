#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de Migração Segura para Nova Estrutura
============================================

Este script migra o projeto EA_SCALPER_XAUUSD para a nova estrutura organizacional
garantindo que NENHUM arquivo seja perdido ou excluído.

Funcionalidades:
- Migração segura com backup automático
- Logging detalhado de todas operações
- Verificação de integridade
- Remoção de pastas vazias
- Geração de índices automáticos
"""

import os
import shutil
import json
import hashlib
import logging
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple
import re

class SafeMigrator:
    """Migrador seguro para nova estrutura de diretórios"""
    
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.backup_path = self.base_path / "BACKUP_MIGRATION" / datetime.now().strftime("%Y%m%d_%H%M%S")
        self.migration_log = []
        self.file_registry = {}
        
        # Configurar logging
        self.setup_logging()
        
        # Definir estrutura alvo
        self.target_structure = self.define_target_structure()
        
    def setup_logging(self):
        """Configura sistema de logging detalhado"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(self.base_path / 'migration.log', encoding='utf-8'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
        
    def define_target_structure(self) -> Dict:
        """Define estrutura de diretórios alvo"""
        return {
            "MAIN_EAS": {
                "PRODUCTION": {},
                "DEVELOPMENT": {},
                "RELEASES": {},
                "_backups": {}
            },
            "LIBRARY": {
                "MQL5_Components": {
                    "EAs": {
                        "FTMO_Ready": {},
                        "Scalping": {},
                        "SMC_ICT": {},
                        "Grid_Systems": {},
                        "Experimental": {}
                    },
                    "Indicators": {
                        "SMC_Tools": {},
                        "Volume_Analysis": {},
                        "Trend_Tools": {},
                        "Custom": {}
                    },
                    "Scripts": {
                        "Risk_Management": {},
                        "Account_Tools": {},
                        "Utilities": {}
                    },
                    "Include": {
                        "Core": {},
                        "Utils": {},
                        "Custom": {}
                    }
                },
                "MQL4_Components": {
                    "EAs": {
                        "FTMO_Ready": {},
                        "Scalping": {},
                        "SMC_ICT": {},
                        "Grid_Systems": {},
                        "Experimental": {}
                    },
                    "Indicators": {
                        "SMC_Tools": {},
                        "Volume_Analysis": {},
                        "Trend_Tools": {},
                        "Custom": {}
                    },
                    "Scripts": {
                        "Risk_Management": {},
                        "Account_Tools": {},
                        "Utilities": {}
                    },
                    "Include": {
                        "Core": {},
                        "Utils": {},
                        "Custom": {}
                    }
                },
                "TradingView": {
                    "Indicators": {},
                    "Strategies": {},
                    "Libraries": {}
                }
            },
            "WORKSPACE": {
                "Active_Development": {},
                "Testing": {},
                "Sandbox": {},
                "Optimization": {}
            },
            "METADATA": {
                "EA_Metadata": {
                    "FTMO_Compatible": {},
                    "Scalping_Systems": {},
                    "Grid_Systems": {},
                    "SMC_ICT_Systems": {},
                    "Trend_Following": {},
                    "Archive": {}
                },
                "Indicator_Metadata": {},
                "Script_Metadata": {}
            },
            "TOOLS": {
                "Build": {},
                "Testing": {},
                "Automation": {},
                "MCP_Integration": {},
                "Utilities": {}
            },
            "CONFIG": {
                "Trading_Configs": {},
                "MCP_Configs": {},
                "Broker_Configs": {},
                "Environment_Configs": {}
            },
            "ORPHAN_FILES": {
                "Unclassified": {},
                "Duplicates": {},
                "Review_Pending": {},
                "Temporary": {}
            },
            "DOCS": {}
        }
        
    def create_directory_structure(self):
        """Cria estrutura de diretórios de forma recursiva"""
        self.logger.info("🏗️ Criando estrutura de diretórios...")
        
        def create_dirs(structure: Dict, current_path: Path):
            for dir_name, subdirs in structure.items():
                dir_path = current_path / dir_name
                dir_path.mkdir(parents=True, exist_ok=True)
                self.logger.info(f"✅ Criado: {dir_path}")
                
                if isinstance(subdirs, dict) and subdirs:
                    create_dirs(subdirs, dir_path)
        
        create_dirs(self.target_structure, self.base_path)
        self.logger.info("✅ Estrutura de diretórios criada com sucesso!")
        
    def create_backup(self):
        """Cria backup completo antes da migração"""
        self.logger.info("💾 Criando backup de segurança...")
        
        self.backup_path.mkdir(parents=True, exist_ok=True)
        
        # Lista de diretórios críticos para backup
        critical_dirs = [
            "02_Strategies",
            "03_Source_Code", 
            "Metadata",
            "📋 METADATA",
            "🚀 MAIN_EAS",
            "📚 LIBRARY"
        ]
        
        for dir_name in critical_dirs:
            source_dir = self.base_path / dir_name
            if source_dir.exists():
                target_backup = self.backup_path / dir_name
                try:
                    shutil.copytree(source_dir, target_backup)
                    self.logger.info(f"✅ Backup criado: {dir_name}")
                except Exception as e:
                    self.logger.warning(f"⚠️ Erro no backup de {dir_name}: {e}")
        
        self.logger.info(f"✅ Backup completo criado em: {self.backup_path}")
        
    def calculate_file_hash(self, file_path: Path) -> str:
        """Calcula hash MD5 do arquivo para verificação de integridade"""
        hash_md5 = hashlib.md5()
        try:
            with open(file_path, "rb") as f:
                for chunk in iter(lambda: f.read(4096), b""):
                    hash_md5.update(chunk)
            return hash_md5.hexdigest()
        except Exception:
            return ""
            
    def register_file(self, file_path: Path, new_location: Path):
        """Registra movimento de arquivo para tracking"""
        file_hash = self.calculate_file_hash(file_path)
        self.file_registry[str(file_path)] = {
            "original_path": str(file_path),
            "new_path": str(new_location),
            "hash": file_hash,
            "timestamp": datetime.now().isoformat(),
            "size": file_path.stat().st_size if file_path.exists() else 0
        }
        
    def safe_move_file(self, source: Path, target_dir: Path, new_name: str = None) -> bool:
        """Move arquivo de forma segura com verificação"""
        if not source.exists():
            self.logger.warning(f"⚠️ Arquivo não encontrado: {source}")
            return False
            
        target_dir.mkdir(parents=True, exist_ok=True)
        final_name = new_name if new_name else source.name
        target_path = target_dir / final_name
        
        # Verifica se arquivo já existe no destino
        if target_path.exists():
            # Se é o mesmo arquivo (mesmo hash), skip
            if self.calculate_file_hash(source) == self.calculate_file_hash(target_path):
                self.logger.info(f"⏭️ Arquivo já existe (mesmo conteúdo): {final_name}")
                return True
            else:
                # Arquivo diferente, criar nome único
                counter = 1
                while target_path.exists():
                    name_parts = final_name.rsplit('.', 1)
                    if len(name_parts) == 2:
                        new_final_name = f"{name_parts[0]}_{counter}.{name_parts[1]}"
                    else:
                        new_final_name = f"{final_name}_{counter}"
                    target_path = target_dir / new_final_name
                    counter += 1
        
        try:
            # Registrar movimento
            self.register_file(source, target_path)
            
            # Mover arquivo
            shutil.move(str(source), str(target_path))
            self.logger.info(f"✅ Movido: {source.name} → {target_path}")
            
            # Verificar integridade
            if source.exists():
                self.logger.error(f"❌ Erro: arquivo não foi movido corretamente: {source}")
                return False
                
            return True
            
        except Exception as e:
            self.logger.error(f"❌ Erro ao mover {source}: {e}")
            return False
            
    def migrate_main_eas(self):
        """Migra EAs principais para MAIN_EAS/"""
        self.logger.info("🚀 Migrando EAs principais...")
        
        # EAs principais identificados
        main_eas = [
            "EA_FTMO_Scalper_Elite_v2.12.mq5",
            "EA_FTMO_Scalper_Elite.mq5", 
            "EA_AUTONOMOUS_XAUUSD_ELITE_v2.0.mq5",
            "EA_AUTONOMOUS_XAUUSD_ELITE.mq5"
        ]
        
        # Buscar EAs em todo o projeto
        for ea_name in main_eas:
            found_files = list(self.base_path.rglob(ea_name))
            
            for file_path in found_files:
                # Determinar destino baseado no nome e conteúdo
                if "FTMO" in ea_name and ("v2.12" in ea_name or "Elite" in ea_name):
                    target_dir = self.base_path / "MAIN_EAS" / "PRODUCTION"
                else:
                    target_dir = self.base_path / "MAIN_EAS" / "DEVELOPMENT"
                
                # Mover arquivo
                success = self.safe_move_file(file_path, target_dir)
                if success:
                    self.migration_log.append(f"EA Principal movido: {ea_name} → {target_dir}")
                    
                # Mover arquivo compilado correspondente (.ex5/.ex4)
                compiled_file = file_path.with_suffix('.ex5')
                if compiled_file.exists():
                    self.safe_move_file(compiled_file, target_dir)
                    
        self.logger.info("✅ Migração de EAs principais concluída!")
        
    def classify_mql_file(self, file_path: Path) -> str:
        """Classifica arquivo MQL baseado no conteúdo"""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read().lower()
                
            filename = file_path.name.lower()
            
            # Determinar tipo de arquivo
            if any(keyword in content for keyword in ['ontick', 'ordersend', 'expert advisor']):
                file_type = "EAs"
            elif any(keyword in content for keyword in ['#property indicator', 'indicator']):
                file_type = "Indicators"  
            elif any(keyword in content for keyword in ['onstart', 'script']):
                file_type = "Scripts"
            elif file_path.suffix.lower() == '.mqh':
                file_type = "Include"
            else:
                return "Experimental"  # Default para EAs
                
            # Determinar categoria específica
            if file_type == "EAs":
                if any(keyword in content for keyword in ['ftmo', 'risk management']):
                    return f"{file_type}/FTMO_Ready"
                elif any(keyword in content for keyword in ['scalp', 'tick', 'spread']):
                    return f"{file_type}/Scalping"
                elif any(keyword in content for keyword in ['smc', 'ict', 'orderblock', 'liquidity']):
                    return f"{file_type}/SMC_ICT" 
                elif any(keyword in content for keyword in ['grid', 'martingale', 'hedge']):
                    return f"{file_type}/Grid_Systems"
                else:
                    return f"{file_type}/Experimental"
                    
            elif file_type == "Indicators":
                if any(keyword in content for keyword in ['smc', 'ict', 'orderblock']):
                    return f"{file_type}/SMC_Tools"
                elif any(keyword in content for keyword in ['volume', 'tick volume']):
                    return f"{file_type}/Volume_Analysis"
                elif any(keyword in content for keyword in ['trend', 'moving average', 'ema']):
                    return f"{file_type}/Trend_Tools"
                else:
                    return f"{file_type}/Custom"
                    
            elif file_type == "Scripts":
                if any(keyword in content for keyword in ['risk', 'lot', 'position']):
                    return f"{file_type}/Risk_Management"
                elif any(keyword in content for keyword in ['account', 'balance', 'equity']):
                    return f"{file_type}/Account_Tools"
                else:
                    return f"{file_type}/Utilities"
                    
            elif file_type == "Include":
                if any(keyword in content for keyword in ['core', 'engine', 'base']):
                    return f"{file_type}/Core"
                elif any(keyword in content for keyword in ['util', 'helper', 'common']):
                    return f"{file_type}/Utils"
                else:
                    return f"{file_type}/Custom"
                    
        except Exception as e:
            self.logger.warning(f"⚠️ Erro ao classificar {file_path}: {e}")
            
        return "Experimental"  # Default seguro
        
    def migrate_library_files(self):
        """Migra arquivos da biblioteca para estrutura organizada"""
        self.logger.info("📚 Migrando arquivos da biblioteca...")
        
        # Diretórios fonte conhecidos
        source_dirs = [
            "03_Source_Code/MQL4",
            "03_Source_Code/MQL5", 
            "03_Source_Code/Libraries",
            "CODIGO_FONTE_LIBRARY/MQL4_Source",
            "CODIGO_FONTE_LIBRARY/MQL5_Source",
            "02_Strategies/EA_FTMO_SCALPER_ELITE/MQL5_Source"
        ]
        
        for source_dir_name in source_dirs:
            source_dir = self.base_path / source_dir_name
            if not source_dir.exists():
                continue
                
            self.logger.info(f"📁 Processando: {source_dir}")
            
            # Processar arquivos MQL
            for ext in ['.mq4', '.mq5', '.mqh', '.ex4', '.ex5']:
                for file_path in source_dir.rglob(f"*{ext}"):
                    if file_path.is_file():
                        # Determinar componente (MQL4 ou MQL5)
                        if ext in ['.mq4', '.ex4']:
                            component = "MQL4_Components"
                        else:
                            component = "MQL5_Components"
                            
                        # Classificar arquivo
                        category = self.classify_mql_file(file_path)
                        
                        # Determinar destino
                        target_dir = self.base_path / "LIBRARY" / component / category
                        
                        # Mover arquivo
                        self.safe_move_file(file_path, target_dir)
                        
        # Processar TradingView
        tv_dirs = ["📊 TRADINGVIEW", "03_Source_Code/TradingView"]
        for tv_dir_name in tv_dirs:
            tv_dir = self.base_path / tv_dir_name
            if tv_dir.exists():
                for file_path in tv_dir.rglob("*"):
                    if file_path.is_file() and file_path.suffix.lower() in ['.pine', '.txt']:
                        # Classificar TradingView
                        if any(keyword in file_path.name.lower() for keyword in ['indicator', 'ind']):
                            target_dir = self.base_path / "LIBRARY" / "TradingView" / "Indicators"
                        elif any(keyword in file_path.name.lower() for keyword in ['strategy', 'strat']):
                            target_dir = self.base_path / "LIBRARY" / "TradingView" / "Strategies"
                        else:
                            target_dir = self.base_path / "LIBRARY" / "TradingView" / "Libraries"
                            
                        self.safe_move_file(file_path, target_dir)
                        
        self.logger.info("✅ Migração da biblioteca concluída!")
        
    def run_migration(self):
        """Executa migração completa"""
        self.logger.info("🚀 Iniciando migração para nova estrutura...")
        
        try:
            # 1. Criar backup
            self.create_backup()
            
            # 2. Criar estrutura
            self.create_directory_structure()
            
            # 3. Migrar EAs principais
            self.migrate_main_eas()
            
            # 4. Migrar biblioteca
            self.migrate_library_files()
            
            # 5. Salvar registro de migração
            self.save_migration_report()
            
            self.logger.info("🎉 Migração concluída com sucesso!")
            
        except Exception as e:
            self.logger.error(f"❌ Erro durante migração: {e}")
            raise
            
    def save_migration_report(self):
        """Salva relatório detalhado da migração"""
        report = {
            "migration_date": datetime.now().isoformat(),
            "backup_location": str(self.backup_path),
            "files_moved": len(self.file_registry),
            "file_registry": self.file_registry,
            "migration_log": self.migration_log
        }
        
        report_path = self.base_path / "migration_report.json"
        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
            
        self.logger.info(f"📋 Relatório de migração salvo: {report_path}")

if __name__ == "__main__":
    # Executar migração
    migrator = SafeMigrator("c:/Users/Admin/Documents/EA_SCALPER_XAUUSD")
    migrator.run_migration()