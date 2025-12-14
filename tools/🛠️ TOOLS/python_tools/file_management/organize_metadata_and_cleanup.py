#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de Organização de Metadados e Limpeza de Pastas Vazias
===========================================================

Este script:
1. Reorganiza os 3.685+ arquivos de metadados em categorias
2. Remove pastas vazias desnecessárias
3. Gera índices centralizados
4. Cria documentação automática
"""

import os
import json
import shutil
import logging
from datetime import datetime
from pathlib import Path
from typing import Dict, List
import re

class MetadataOrganizer:
    """Organizador de metadados e limpeza de estrutura"""
    
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.logger = self.setup_logging()
        self.metadata_registry = {}
        self.empty_dirs_removed = []
        
    def setup_logging(self):
        """Configura logging"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(self.base_path / 'metadata_organization.log', encoding='utf-8'),
                logging.StreamHandler()
            ]
        )
        return logging.getLogger(__name__)
        
    def count_files_in_directory(self, directory: Path) -> int:
        """Conta arquivos em um diretório"""
        try:
            return len([f for f in directory.iterdir() if f.is_file()])
        except:
            return 0
            
    def get_overflow_directory(self, base_dir: Path, max_files: int = 500) -> Path:
        """Cria diretório de overflow quando limite é atingido"""
        counter = 1
        while True:
            if self.count_files_in_directory(base_dir) < max_files:
                return base_dir
            
            overflow_dir = base_dir.parent / f"{base_dir.name}_batch_{counter:03d}"
            if not overflow_dir.exists() or self.count_files_in_directory(overflow_dir) < max_files:
                overflow_dir.mkdir(exist_ok=True)
                return overflow_dir
            counter += 1
            
    def classify_metadata_file(self, metadata_path: Path) -> str:
        """Classifica arquivo de metadados baseado no conteúdo"""
        try:
            with open(metadata_path, 'r', encoding='utf-8', errors='ignore') as f:
                data = json.load(f)
                
            # Extrair informações de classificação
            classification = data.get('classification', {})
            strategies = classification.get('strategy', [])
            ftmo_ready = classification.get('ftmo_ready', False)
            file_type = data.get('type', '').lower()
            
            # Priorizar FTMO (prioridade máxima)
            if ftmo_ready or any('ftmo' in str(s).lower() for s in strategies):
                return 'FTMO_Compatible'
                
            # Classificar por estratégia
            strategy_str = ' '.join(str(s) for s in strategies).lower()
            
            if any(keyword in strategy_str for keyword in ['scalping', 'scalp']):
                return 'Scalping_Systems'
            elif any(keyword in strategy_str for keyword in ['smc', 'ict', 'smart money']):
                return 'SMC_ICT_Systems'
            elif any(keyword in strategy_str for keyword in ['grid', 'martingale']):
                return 'Grid_Systems'
            elif any(keyword in strategy_str for keyword in ['trend', 'following']):
                return 'Trend_Following'
            elif any(keyword in strategy_str for keyword in ['news', 'fundamental']):
                return 'News_Trading'
            else:
                return 'Archive'
                
        except Exception as e:
            self.logger.warning(f"⚠️ Erro ao classificar {metadata_path}: {e}")
            return 'Archive'
            
    def organize_metadata_files(self):
        """Organiza arquivos de metadados em categorias"""
        self.logger.info("📊 Organizando arquivos de metadados...")
        
        # Diretórios fonte de metadados
        metadata_sources = [
            "Metadata", 
            "📋 METADATA",
            "BACKUP_METADATA",
            "03_Source_Code/Metadata"
        ]
        
        processed_files = 0
        
        for source_name in metadata_sources:
            source_dir = self.base_path / source_name
            if not source_dir.exists():
                continue
                
            self.logger.info(f"📁 Processando: {source_dir}")
            
            # Processar todos arquivos .json de metadados
            for json_file in source_dir.rglob("*.json"):
                if json_file.is_file() and json_file.name.endswith('.meta.json'):
                    # Classificar arquivo
                    category = self.classify_metadata_file(json_file)
                    
                    # Determinar diretório de destino
                    target_base_dir = self.base_path / "METADATA" / "EA_Metadata" / category
                    target_dir = self.get_overflow_directory(target_base_dir)
                    
                    # Mover arquivo
                    target_path = target_dir / json_file.name
                    if not target_path.exists():
                        target_dir.mkdir(parents=True, exist_ok=True)
                        shutil.move(str(json_file), str(target_path))
                        self.logger.info(f"✅ Metadados movidos: {json_file.name} → {category}")
                        
                        # Registrar no registry
                        self.metadata_registry[str(json_file)] = {
                            "original_path": str(json_file),
                            "new_path": str(target_path),
                            "category": category,
                            "timestamp": datetime.now().isoformat()
                        }
                        
                        processed_files += 1
                    else:
                        self.logger.info(f"⏭️ Metadados já existem: {json_file.name}")
                        
        self.logger.info(f"✅ {processed_files} arquivos de metadados organizados!")
        
    def remove_empty_directories(self):
        """Remove diretórios vazios recursivamente"""
        self.logger.info("🧹 Removendo pastas vazias...")
        
        def is_directory_empty(path: Path) -> bool:
            """Verifica se diretório está vazio (incluindo subdiretórios)"""
            try:
                for item in path.iterdir():
                    if item.is_file():
                        return False
                    elif item.is_dir() and not is_directory_empty(item):
                        return False
                return True
            except:
                return False
                
        # Varrer todo o projeto
        empty_dirs = []
        for root, dirs, files in os.walk(self.base_path):
            root_path = Path(root)
            
            # Pular diretórios específicos que devem ser mantidos
            skip_dirs = {
                'MAIN_EAS', 'LIBRARY', 'WORKSPACE', 'METADATA', 
                'TOOLS', 'CONFIG', 'DOCS', 'ORPHAN_FILES',
                '.git', '.venv', '__pycache__', 'BACKUP_MIGRATION'
            }
            
            if any(skip_dir in root_path.parts for skip_dir in skip_dirs):
                continue
                
            if is_directory_empty(root_path) and root_path != self.base_path:
                empty_dirs.append(root_path)
                
        # Remover diretórios vazios (do mais profundo para o mais raso)
        empty_dirs.sort(key=lambda x: len(x.parts), reverse=True)
        
        removed_count = 0
        for empty_dir in empty_dirs:
            try:
                if empty_dir.exists() and is_directory_empty(empty_dir):
                    empty_dir.rmdir()
                    self.logger.info(f"🗑️ Pasta vazia removida: {empty_dir}")
                    self.empty_dirs_removed.append(str(empty_dir))
                    removed_count += 1
            except Exception as e:
                self.logger.warning(f"⚠️ Erro ao remover {empty_dir}: {e}")
                
        self.logger.info(f"✅ {removed_count} pastas vazias removidas!")
        
    def generate_master_index(self):
        """Gera índice mestre do projeto"""
        self.logger.info("📋 Gerando índice mestre...")
        
        def count_files_by_extension(directory: Path) -> Dict:
            """Conta arquivos por extensão"""
            counts = {}
            try:
                for file_path in directory.rglob("*"):
                    if file_path.is_file():
                        ext = file_path.suffix.lower()
                        counts[ext] = counts.get(ext, 0) + 1
            except:
                pass
            return counts
            
        # Estatísticas por diretório principal
        stats = {}
        main_dirs = ['MAIN_EAS', 'LIBRARY', 'WORKSPACE', 'METADATA', 'TOOLS', 'CONFIG']
        
        for dir_name in main_dirs:
            dir_path = self.base_path / dir_name
            if dir_path.exists():
                stats[dir_name] = {
                    "total_files": len(list(dir_path.rglob("*.*"))),
                    "total_dirs": len(list(dir_path.rglob("*"))),
                    "file_types": count_files_by_extension(dir_path)
                }
                
        # Criar índice mestre
        master_index = {
            "project_name": "EA_SCALPER_XAUUSD",
            "organization_date": datetime.now().isoformat(),
            "structure_version": "2.0",
            "statistics": stats,
            "main_components": {
                "main_eas": {
                    "production": list((self.base_path / "MAIN_EAS" / "PRODUCTION").glob("*.mq*")) if (self.base_path / "MAIN_EAS" / "PRODUCTION").exists() else [],
                    "development": list((self.base_path / "MAIN_EAS" / "DEVELOPMENT").glob("*.mq*")) if (self.base_path / "MAIN_EAS" / "DEVELOPMENT").exists() else []
                },
                "metadata_organization": {
                    "total_metadata_files": len(self.metadata_registry),
                    "categories": list(set(item["category"] for item in self.metadata_registry.values()))
                }
            },
            "migration_summary": {
                "metadata_files_organized": len(self.metadata_registry),
                "empty_directories_removed": len(self.empty_dirs_removed)
            }
        }
        
        # Salvar índice mestre
        index_path = self.base_path / "MASTER_INDEX.json"
        with open(index_path, 'w', encoding='utf-8') as f:
            json.dump(master_index, f, indent=2, ensure_ascii=False, default=str)
            
        self.logger.info(f"✅ Índice mestre criado: {index_path}")
        
        # Criar documentação README
        self.create_readme_documentation(master_index)
        
    def create_readme_documentation(self, master_index: Dict):
        """Cria documentação README atualizada"""
        readme_content = f"""# 🚀 EA_SCALPER_XAUUSD - Projeto Organizado

## 📊 Visão Geral
Projeto de Expert Advisors para trading automatizado em XAUUSD, organizados com estrutura otimizada para performance e escalabilidade.

**Data de Organização:** {datetime.now().strftime('%d/%m/%Y')}
**Versão da Estrutura:** 2.0

## 📁 Estrutura Principal

### 🚀 MAIN_EAS/
EAs principais do projeto com acesso direto:
- **PRODUCTION/**: EAs prontos para produção
- **DEVELOPMENT/**: EAs em desenvolvimento ativo
- **RELEASES/**: Candidatos a release

### 📚 LIBRARY/
Biblioteca organizada por tecnologia e categoria:
- **MQL5_Components/**: Componentes MQL5 (EAs, Indicators, Scripts, Include)
- **MQL4_Components/**: Componentes MQL4 (legado)
- **TradingView/**: Scripts Pine Script

### 📊 METADATA/
Metadados organizados por performance (máx. 500 arquivos/pasta):
- **EA_Metadata/**: Metadados dos Expert Advisors
  - FTMO_Compatible/ (prioridade máxima)
  - Scalping_Systems/
  - SMC_ICT_Systems/
  - Grid_Systems/
  - Trend_Following/
  - Archive/

### 🔧 WORKSPACE/
Ambiente de desenvolvimento:
- **Active_Development/**: Desenvolvimento em andamento
- **Testing/**: Testes e validação
- **Sandbox/**: Experimentos rápidos

### 🛠️ TOOLS/
Ferramentas e automação:
- **Build/**: Scripts de compilação
- **Testing/**: Ferramentas de teste
- **Automation/**: Scripts de automação

## 📈 Estatísticas do Projeto

"""

        # Adicionar estatísticas
        for dir_name, stats in master_index["statistics"].items():
            readme_content += f"""### {dir_name}
- **Total de arquivos:** {stats['total_files']}
- **Total de diretórios:** {stats['total_dirs']}
- **Tipos de arquivo:** {', '.join(f"{ext}({count})" for ext, count in stats['file_types'].items())}

"""

        readme_content += f"""## 🎯 Melhorias Implementadas

### ✅ Performance Otimizada
- Metadados reorganizados: **{master_index['migration_summary']['metadata_files_organized']}** arquivos
- Pastas vazias removidas: **{master_index['migration_summary']['empty_directories_removed']}**
- Máximo 500 arquivos por diretório
- Acesso direto aos EAs principais

### ✅ Organização por Prioridade
1. **FTMO-compatible EAs** (HIGHEST)
2. **XAUUSD specialists + SMC/Order Blocks** (HIGH)
3. **General scalping + trend following** (MEDIUM)
4. **Grid/martingale + experimental** (LOW)

### ✅ Convenção de Nomenclatura
Padrão: `[TYPE]_[NAME]v[VERSION][SPECIFIC].[EXT]`

Exemplo: `EA_FTMO_Scalper_Elite_v2.12_XAUUSD.mq5`

## 🚀 Quick Start

### Compilar EAs Principais
```bash
# Windows
cd TOOLS/Build
compile_main_eas.bat

# Python
python TOOLS/Build/compile_main_eas.py
```

### Localizar Arquivos
- **EAs Principais:** `MAIN_EAS/PRODUCTION/`
- **Biblioteca:** `LIBRARY/MQL5_Components/EAs/`
- **Metadados:** `METADATA/EA_Metadata/`

## 📋 Índices de Referência
- **MASTER_INDEX.json**: Índice completo do projeto
- **LIBRARY/LIBRARY_INDEX.json**: Índice da biblioteca
- **METADATA/METADATA_INDEX.json**: Índice de metadados

---
**Última atualização:** {datetime.now().strftime('%d/%m/%Y %H:%M')}
"""

        readme_path = self.base_path / "README.md"
        with open(readme_path, 'w', encoding='utf-8') as f:
            f.write(readme_content)
            
        self.logger.info(f"✅ Documentação README criada: {readme_path}")
        
    def run_organization(self):
        """Executa organização completa"""
        self.logger.info("🚀 Iniciando organização de metadados e limpeza...")
        
        try:
            # 1. Organizar metadados
            self.organize_metadata_files()
            
            # 2. Remover pastas vazias
            self.remove_empty_directories()
            
            # 3. Gerar índices
            self.generate_master_index()
            
            self.logger.info("🎉 Organização concluída com sucesso!")
            
        except Exception as e:
            self.logger.error(f"❌ Erro durante organização: {e}")
            raise

if __name__ == "__main__":
    # Executar organização
    organizer = MetadataOrganizer("c:/Users/Admin/Documents/EA_SCALPER_XAUUSD")
    organizer.run_organization()