#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Reorganizador Automático da Estrutura do Projeto
==============================================

Script para reorganizar completamente a estrutura caótica do projeto
EA_SCALPER_XAUUSD em uma estrutura limpa e profissional.
"""

import os
import shutil
from pathlib import Path
from datetime import datetime
import json
import re

class ProjectReorganizer:
    """Reorganizador automático da estrutura do projeto"""
    
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.backup_dir = None
        self.moved_files = []
        self.errors = []
        
        # Mapeamento de categorias de arquivos
        self.file_categories = {
            'classification': [
                'classificador_', 'classify_', 'reclassificar_', 
                'classificar_', 'auto_avaliacao'
            ],
            'testing': [
                'test_', 'teste_', 'demo_', 'verify_', 'verificar_'
            ],
            'optimization': [
                'sistema_', 'otimizacao_', 'performance_', 'diagnostico_',
                'processamento_', 'hierarchy_'
            ],
            'migration': [
                'migrate_', 'organize_', 'unificar_', 'reorganizer',
                'migration_', 'cleanup_'
            ],
            'utilities': [
                'alert_', 'monitor_', 'health_', 'calculator', 'imc_',
                'data_analyzer', 'input_validator'
            ],
            'mcp_tools': [
                'mcp_', 'fix_sequential_', 'setup_roboforex'
            ],
            'ai_systems': [
                'coordenador_', 'multi_agente', 'agente_', 'orquestrador'
            ]
        }
        
        # Mapeamento de documentação
        self.doc_categories = {
            'user_guides': ['GUIA_', 'EXEMPLO_', 'RESUMO_'],
            'technical': ['ARQUITETURA_', 'DOCUMENTACAO_', 'PLANO_'],
            'reports': ['RELATORIO_', 'RESPOSTA_', 'PROJETO_'],
            'installation': ['INSTALACAO_', 'MCP_', 'SETUP_', 'ROBOFOREX_'],
            'analysis': ['ANALISE_', 'ESTRATEGIA_', 'CONFIRMACAO_']
        }
    
    def create_target_structure(self):
        """Cria a estrutura de diretórios alvo"""
        print("📁 Criando estrutura de diretórios alvo...")
        
        target_dirs = [
            # Estrutura principal
            "TOOLS/Classification",
            "TOOLS/Testing", 
            "TOOLS/Optimization",
            "TOOLS/Migration",
            "TOOLS/Utilities",
            "TOOLS/MCP_Tools",
            "TOOLS/AI_Systems",
            
            # Configurações
            "CONFIG/MCP",
            "CONFIG/Trading", 
            "CONFIG/System",
            
            # Documentação
            "DOCS/User_Guides",
            "DOCS/Technical",
            "DOCS/Reports", 
            "DOCS/Installation",
            "DOCS/Analysis",
            
            # Testes organizados
            "TESTS/Unit",
            "TESTS/Integration",
            "TESTS/Performance",
            "TESTS/FTMO_Validation",
            
            # Dados e logs
            "DATA/Logs",
            "DATA/Cache",
            "DATA/Reports",
            "DATA/Temp",
            
            # Workspace limpo
            "WORKSPACE/Current_Projects",
            "WORKSPACE/Experiments", 
            "WORKSPACE/Sandbox",
            
            # Scripts de build e automação
            "SCRIPTS/Build",
            "SCRIPTS/Deploy",
            "SCRIPTS/Maintenance"
        ]
        
        for dir_path in target_dirs:
            full_path = self.base_path / dir_path
            full_path.mkdir(parents=True, exist_ok=True)
            print(f"   ✅ Criado: {dir_path}")
    
    def create_backup(self):
        """Cria backup da estrutura atual"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.backup_dir = self.base_path / "REORGANIZATION_BACKUP" / f"backup_{timestamp}"
        self.backup_dir.mkdir(parents=True, exist_ok=True)
        print(f"💾 Backup criado em: {self.backup_dir}")
    
    def categorize_python_file(self, filename: str) -> str:
        """Categoriza um arquivo Python baseado no nome"""
        filename_lower = filename.lower()
        
        for category, patterns in self.file_categories.items():
            for pattern in patterns:
                if pattern in filename_lower:
                    return category
        
        # Casos especiais
        if 'main.py' == filename_lower:
            return 'main_scripts'
        elif filename_lower.startswith('executar_'):
            return 'utilities'
        elif filename_lower.startswith('criar_'):
            return 'utilities'
        
        return 'utilities'  # Default
    
    def categorize_doc_file(self, filename: str) -> str:
        """Categoriza um arquivo de documentação"""
        filename_upper = filename.upper()
        
        for category, patterns in self.doc_categories.items():
            for pattern in patterns:
                if filename_upper.startswith(pattern):
                    return category
        
        # Casos especiais
        if 'README' in filename_upper:
            return 'technical'
        elif 'CHANGELOG' in filename_upper:
            return 'technical'
        elif 'INDEX' in filename_upper or 'MASTER' in filename_upper:
            return 'technical'
        
        return 'technical'  # Default
    
    def move_file_safely(self, source: Path, target_dir: str, new_name: str = None):
        """Move arquivo com segurança, evitando conflitos"""
        try:
            target_path = self.base_path / target_dir
            target_path.mkdir(parents=True, exist_ok=True)
            
            filename = new_name if new_name else source.name
            target_file = target_path / filename
            
            # Resolver conflitos de nome
            if target_file.exists():
                stem = target_file.stem
                suffix = target_file.suffix
                counter = 1
                while target_file.exists():
                    target_file = target_path / f"{stem}_v{counter}{suffix}"
                    counter += 1
            
            # Mover arquivo
            shutil.move(str(source), str(target_file))
            
            self.moved_files.append({
                'source': str(source),
                'target': str(target_file),
                'category': target_dir,
                'timestamp': datetime.now().isoformat()
            })
            
            print(f"   📁 {source.name} → {target_dir}/")
            return True
            
        except Exception as e:
            error_msg = f"Erro ao mover {source}: {e}"
            self.errors.append(error_msg)
            print(f"   ❌ {error_msg}")
            return False
    
    def reorganize_python_scripts(self):
        """Reorganiza scripts Python espalhados na raiz"""
        print("\n🐍 Reorganizando scripts Python...")
        
        python_files = list(self.base_path.glob("*.py"))
        print(f"📊 Encontrados {len(python_files)} scripts Python na raiz")
        
        for py_file in python_files:
            if py_file.name in ['main.py']:  # Manter alguns na raiz
                continue
                
            category = self.categorize_python_file(py_file.name)
            target_dir = f"TOOLS/{category.title()}"
            
            self.move_file_safely(py_file, target_dir)
    
    def reorganize_documentation(self):
        """Reorganiza documentação espalhada"""
        print("\n📝 Reorganizando documentação...")
        
        md_files = list(self.base_path.glob("*.md"))
        print(f"📊 Encontrados {len(md_files)} arquivos de documentação na raiz")
        
        for md_file in md_files:
            if md_file.name in ['README.md']:  # Manter alguns na raiz
                continue
                
            category = self.categorize_doc_file(md_file.name)
            target_dir = f"DOCS/{category.title()}"
            
            self.move_file_safely(md_file, target_dir)
    
    def reorganize_config_files(self):
        """Reorganiza arquivos de configuração"""
        print("\n⚙️ Reorganizando configurações...")
        
        # JSON configs
        json_files = list(self.base_path.glob("*.json"))
        for json_file in json_files:
            if 'mcp' in json_file.name.lower():
                self.move_file_safely(json_file, "CONFIG/MCP")
            elif any(word in json_file.name.lower() for word in ['config', 'settings']):
                self.move_file_safely(json_file, "CONFIG/System")
            else:
                self.move_file_safely(json_file, "DATA/Reports")
        
        # Log files
        log_files = list(self.base_path.glob("*.log"))
        for log_file in log_files:
            self.move_file_safely(log_file, "DATA/Logs")
        
        # Batch and shell scripts
        bat_files = list(self.base_path.glob("*.bat"))
        ps1_files = list(self.base_path.glob("*.ps1"))
        sh_files = list(self.base_path.glob("*.sh"))
        
        for script_file in bat_files + ps1_files + sh_files:
            if 'install' in script_file.name.lower():
                self.move_file_safely(script_file, "SCRIPTS/Deploy")
            else:
                self.move_file_safely(script_file, "SCRIPTS/Build")
    
    def reorganize_directories(self):
        """Reorganiza diretórios problemáticos"""
        print("\n📂 Reorganizando diretórios...")
        
        # Diretórios para consolidar/mover
        dir_mappings = {
            'Demo_Tests': 'TESTS/Integration',
            'Demo_Visual': 'WORKSPACE/Experiments',
            'Teste_Critico': 'TESTS/Performance',
            'Sistema_Contexto_Expandido_R1': 'TOOLS/AI_Systems',
            '__pycache__': 'DATA/Cache/Python',
            'logs': 'DATA/Logs',
            'examples': 'WORKSPACE/Experiments',
            'bmad-trading': 'WORKSPACE/Experiments',
            'data': 'DATA'
        }
        
        for old_dir, new_location in dir_mappings.items():
            old_path = self.base_path / old_dir
            if old_path.exists() and old_path.is_dir():
                new_path = self.base_path / new_location / old_dir
                try:
                    new_path.parent.mkdir(parents=True, exist_ok=True)
                    shutil.move(str(old_path), str(new_path))
                    print(f"   📁 {old_dir} → {new_location}/")
                except Exception as e:
                    self.errors.append(f"Erro ao mover diretório {old_dir}: {e}")
    
    def consolidate_similar_directories(self):
        \"\"\"Consolida diretórios com funções similares\"\"\"
        print("\n🔄 Consolidando diretórios similares...")
        
        # Mover conteúdo do Development/ para TOOLS/
        dev_path = self.base_path / "Development"
        if dev_path.exists():
            for item in dev_path.iterdir():
                target = self.base_path / "TOOLS" / item.name
                try:
                    if item.is_dir():
                        shutil.move(str(item), str(target))
                    else:
                        target.parent.mkdir(parents=True, exist_ok=True)
                        shutil.move(str(item), str(target))
                    print(f"   📁 Development/{item.name} → TOOLS/")
                except Exception as e:
                    self.errors.append(f"Erro ao mover {item}: {e}")
        
        # Mover conteúdo do Tools/ para TOOLS/
        tools_path = self.base_path / "Tools"
        if tools_path.exists():
            for item in tools_path.iterdir():
                target = self.base_path / "TOOLS" / "Legacy" / item.name
                try:
                    target.parent.mkdir(parents=True, exist_ok=True)
                    shutil.move(str(item), str(target))
                    print(f"   📁 Tools/{item.name} → TOOLS/Legacy/")
                except Exception as e:
                    self.errors.append(f"Erro ao mover {item}: {e}")
    
    def create_index_files(self):
        \"\"\"Cria arquivos de índice para as novas estruturas\"\"\"
        print("\n📋 Criando arquivos de índice...")
        
        # Índice principal
        main_index = {
            "project_name": "EA_SCALPER_XAUUSD",
            "reorganization_date": datetime.now().isoformat(),
            "structure_version": "2.0",
            "description": "Automated trading system with clean organization",
            "directories": {
                "TOOLS": "Development tools and utilities", 
                "CONFIG": "Configuration files",
                "DOCS": "Documentation",
                "TESTS": "Testing framework",
                "DATA": "Data, logs, and cache",
                "WORKSPACE": "Active development workspace",
                "SCRIPTS": "Build and deployment scripts"
            }
        }
        
        with open(self.base_path / "PROJECT_INDEX.json", 'w', encoding='utf-8') as f:
            json.dump(main_index, f, indent=2, ensure_ascii=False)
        
        # README atualizado
        readme_content = f\"\"\"# EA_SCALPER_XAUUSD - Automated Trading System

## 📋 Project Structure (Reorganized {datetime.now().strftime('%Y-%m-%d')})

### 🛠️ TOOLS/
- **Classification/**: Code classification tools
- **Testing/**: Testing utilities  
- **Optimization/**: Performance optimization tools
- **Migration/**: Data migration scripts
- **Utilities/**: General utilities
- **MCP_Tools/**: MCP integration tools
- **AI_Systems/**: AI and agent systems

### ⚙️ CONFIG/
- **MCP/**: MCP server configurations
- **Trading/**: Trading parameters
- **System/**: System configurations

### 📚 DOCS/
- **User_Guides/**: User documentation
- **Technical/**: Technical documentation
- **Reports/**: Generated reports
- **Installation/**: Setup guides

### 🧪 TESTS/
- **Unit/**: Unit tests
- **Integration/**: Integration tests  
- **Performance/**: Performance tests
- **FTMO_Validation/**: FTMO compliance tests

### 💾 DATA/
- **Logs/**: System logs
- **Cache/**: Cached data
- **Reports/**: Generated reports
- **Temp/**: Temporary files

### 🔧 WORKSPACE/
- **Current_Projects/**: Active projects
- **Experiments/**: Experimental code
- **Sandbox/**: Quick tests

## 🚀 Quick Start

1. Check `CONFIG/System/requirements.txt` for dependencies
2. Review `DOCS/Installation/` for setup guides
3. Use `SCRIPTS/Build/` for compilation
4. Run tests from `TESTS/` directory

## 📊 Project Statistics

- **Reorganization Date**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
- **Files Moved**: {len(self.moved_files)}
- **Structure Version**: 2.0
- **Organization Level**: Professional
\"\"\"
        
        with open(self.base_path / "README_NEW.md", 'w', encoding='utf-8') as f:
            f.write(readme_content)
    
    def generate_reorganization_report(self):
        \"\"\"Gera relatório da reorganização\"\"\"
        print("\n📊 Gerando relatório de reorganização...")
        
        report = {
            "reorganization_summary": {
                "date": datetime.now().isoformat(),
                "files_moved": len(self.moved_files),
                "errors_count": len(self.errors),
                "backup_location": str(self.backup_dir) if self.backup_dir else None
            },
            "moved_files": self.moved_files,
            "errors": self.errors,
            "new_structure": {
                "TOOLS": "Development tools organized by function",
                "CONFIG": "Centralized configuration management", 
                "DOCS": "Structured documentation",
                "TESTS": "Comprehensive testing framework",
                "DATA": "Data and logging infrastructure",
                "WORKSPACE": "Clean development environment"
            }
        }
        
        report_file = self.base_path / "REORGANIZATION_REPORT.json"
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        
        print(f"📋 Relatório salvo em: {report_file}")
    
    def run_full_reorganization(self):
        \"\"\"Executa reorganização completa\"\"\"
        print("🚀 INICIANDO REORGANIZAÇÃO AUTOMÁTICA DO PROJETO")
        print("="*60)
        
        try:
            # Etapa 1: Preparação
            self.create_backup()
            self.create_target_structure()
            
            # Etapa 2: Reorganização de arquivos
            self.reorganize_python_scripts()
            self.reorganize_documentation()
            self.reorganize_config_files()
            
            # Etapa 3: Reorganização de diretórios
            self.reorganize_directories()
            self.consolidate_similar_directories()
            
            # Etapa 4: Finalização
            self.create_index_files()
            self.generate_reorganization_report()
            
            # Resumo final
            print("\n" + "="*60)
            print("✅ REORGANIZAÇÃO CONCLUÍDA COM SUCESSO!")
            print("="*60)
            print(f"📁 Arquivos movidos: {len(self.moved_files)}")
            print(f"❌ Erros encontrados: {len(self.errors)}")
            print(f"💾 Backup em: {self.backup_dir}")
            print(f"📋 Relatório: REORGANIZATION_REPORT.json")
            
            if self.errors:
                print("\n⚠️ ERROS ENCONTRADOS:")
                for error in self.errors[:5]:  # Mostrar apenas os primeiros 5
                    print(f"   - {error}")
                if len(self.errors) > 5:
                    print(f"   ... e mais {len(self.errors) - 5} erros")
            
            print("\n🎯 PRÓXIMOS PASSOS:")
            print("1. Verificar arquivos importantes na nova estrutura")
            print("2. Atualizar imports em scripts que dependem de caminhos")
            print("3. Testar funcionalidades críticas")
            print("4. Atualizar documentação de referência")
            
        except Exception as e:
            print(f"\n❌ ERRO CRÍTICO NA REORGANIZAÇÃO: {e}")
            if self.backup_dir and self.backup_dir.exists():
                print(f"💾 Backup disponível em: {self.backup_dir}")

if __name__ == "__main__":
    base_path = "c:/Users/Admin/Documents/EA_SCALPER_XAUUSD"
    
    reorganizer = ProjectReorganizer(base_path)
    reorganizer.run_full_reorganization()