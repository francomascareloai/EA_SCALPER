#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Processador Final Definitivo - Limpeza Completa dos 147k Arquivos
================================================================

Este script realiza a limpeza DEFINITIVA de todas as duplicatas encontradas
nos 147,982 arquivos do projeto, priorizando arquivos importantes e
removendo redundâncias massivas do ambiente Python e backups.
"""

import os
import hashlib
from pathlib import Path
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor
import time
import json
import shutil
from datetime import datetime

class FinalComprehensiveProcessor:
    """Processador final para limpeza completa de todos os 147k arquivos"""
    
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.file_hashes = defaultdict(list)
        self.removed_files = []
        self.space_saved = 0
        self.processed_groups = 0
        self.total_processed = 0
        
        # Estatísticas por categoria
        self.category_stats = {
            'python_cache': {'removed': 0, 'space': 0},
            'mql_files': {'removed': 0, 'space': 0}, 
            'json_metadata': {'removed': 0, 'space': 0},
            'backup_files': {'removed': 0, 'space': 0},
            'system_files': {'removed': 0, 'space': 0},
            'other_files': {'removed': 0, 'space': 0}
        }
        
    def calculate_fast_hash(self, file_path: Path) -> str:
        """Calcula hash rápido para identificação de duplicatas"""
        try:
            if not file_path.exists():
                return ""
                
            file_size = file_path.stat().st_size
            
            # Para arquivos pequenos, ler completamente
            if file_size <= 8192:
                with open(file_path, "rb") as f:
                    return hashlib.md5(f.read()).hexdigest()
            
            # Para arquivos grandes, hash otimizado
            hash_md5 = hashlib.md5()
            with open(file_path, "rb") as f:
                # Início (4KB)
                hash_md5.update(f.read(4096))
                
                # Meio (4KB)
                f.seek(file_size // 2)
                hash_md5.update(f.read(4096))
                
                # Fim (4KB)
                f.seek(-4096, 2)
                hash_md5.update(f.read(4096))
                
                # Incluir tamanho
                hash_md5.update(str(file_size).encode())
                
            return hash_md5.hexdigest()
            
        except Exception as e:
            print(f"⚠️ Erro ao calcular hash: {file_path}: {e}")
            return ""
    
    def collect_all_files_smart(self) -> list[Path]:
        """Coleta TODOS os arquivos com identificação de categorias"""
        print("📂 Coletando TODOS os 147,982 arquivos...")
        start_time = time.time()
        
        all_files = []
        category_counts = defaultdict(int)
        
        for root, dirs, files in os.walk(self.base_path):
            current_dir = Path(root)
            
            for filename in files:
                file_path = current_dir / filename
                
                if file_path.is_file():
                    all_files.append(file_path)
                    
                    # Categorizar arquivo
                    category = self.categorize_file(file_path)
                    category_counts[category] += 1
                    
            if len(all_files) % 10000 == 0:
                elapsed = time.time() - start_time
                print(f"📊 Coletados: {len(all_files):,} arquivos ({elapsed:.1f}s)")
        
        total_time = time.time() - start_time
        print(f"\n✅ Coleta concluída: {len(all_files):,} arquivos em {total_time:.1f}s")
        
        # Mostrar estatísticas por categoria
        print("\n📊 ARQUIVOS POR CATEGORIA:")
        for category, count in sorted(category_counts.items(), key=lambda x: x[1], reverse=True):
            print(f"   📂 {category:<20}: {count:>8,} arquivos")
        
        return all_files
    
    def categorize_file(self, file_path: Path) -> str:
        """Categoriza arquivo para priorização inteligente"""
        path_str = str(file_path).lower()
        ext = file_path.suffix.lower()
        
        if '.venv' in path_str or '__pycache__' in path_str:
            return 'python_cache'
        elif ext in ['.mq4', '.mq5', '.ex4', '.ex5']:
            return 'mql_files'
        elif ext == '.json':
            return 'json_metadata'
        elif any(backup in path_str for backup in ['backup_', '_backup', 'removed_duplicates']):
            return 'backup_files'
        elif ext in ['.pyc', '.pyd', '.pyi', '.git']:
            return 'system_files'
        else:
            return 'other_files'
    
    def get_comprehensive_priority(self, file_path: str) -> int:
        """Sistema de priorização ultra-inteligente"""
        path_lower = file_path.lower()
        filename = Path(file_path).name.lower()
        category = self.categorize_file(Path(file_path))
        
        # PRIORIDADE BASE POR CATEGORIA
        if 'main_eas\\production' in path_lower and 'ftmo' in filename:
            base_score = 10000  # FTMO production - MÁXIMA PRIORIDADE
        elif 'library\\mql5_components' in path_lower:
            base_score = 8000   # Nova estrutura MQL5
        elif 'library\\mql4_components' in path_lower:
            base_score = 7000   # Nova estrutura MQL4
        elif 'main_eas\\' in path_lower:
            base_score = 6000   # EAs principais
        elif 'metadata\\' in path_lower:
            base_score = 5000   # Metadados organizados
        elif 'workspace\\' in path_lower:
            base_score = 4000   # Área de trabalho
        elif '03_source_code\\' in path_lower and 'backup' not in path_lower:
            base_score = 3000   # Código fonte original
        else:
            base_score = 1000   # Outros arquivos
        
        # PENALIZAÇÕES MASSIVAS PARA LIMPEZA
        penalties = 0
        
        # Python cache e ambiente virtual - REMOÇÃO AGRESSIVA
        if category == 'python_cache':
            penalties -= 8000
        elif '.venv\\' in path_lower:
            penalties -= 7000
        elif '__pycache__' in path_lower:
            penalties -= 6000
        
        # Backups antigos - REMOÇÃO AGRESSIVA
        backup_dirs = [
            'backup_migration\\', 'backup_seguranca\\', 'backup_lote\\',
            'removed_duplicates', 'advanced_cleanup\\', 'final_cleanup\\',
            'all_mq4_backup', 'backups\\'
        ]
        for backup_dir in backup_dirs:
            if backup_dir in path_lower:
                penalties -= 5000
                break
        
        # BÔNUS POR CONTEÚDO CRÍTICO
        bonuses = 0
        if 'ftmo' in filename:
            bonuses += 2000
        elif 'elite' in filename or 'scalper' in filename:
            bonuses += 1500
        elif 'autonomous' in filename:
            bonuses += 1000
        elif ext := Path(file_path).suffix.lower():
            if ext in ['.mq5', '.mq4']:
                bonuses += 800
            elif ext == '.json' and 'meta' in filename:
                bonuses += 600
        
        # PENALIZAÇÃO POR INDICADORES DE DUPLICATA
        if any(dup in filename for dup in ['(1)', '(2)', '(3)', '_copy', '_backup', '_dup']):
            penalties -= 1000
        
        final_score = base_score + penalties + bonuses
        return final_score
    
    def scan_and_hash_all_files(self, all_files: list[Path]):
        """Escaneia e calcula hash de TODOS os arquivos"""
        print(f"\n🔍 Calculando hashes de {len(all_files):,} arquivos...")
        start_time = time.time()
        
        # Processar em chunks para eficiência
        chunk_size = 5000
        chunks = [all_files[i:i + chunk_size] for i in range(0, len(all_files), chunk_size)]
        
        with ThreadPoolExecutor(max_workers=16) as executor:
            futures = []
            
            for i, chunk in enumerate(chunks):
                future = executor.submit(self.process_hash_chunk, chunk)
                futures.append((i, future))
            
            # Processar resultados
            for i, future in futures:
                try:
                    chunk_hashes = future.result()
                    
                    # Mesclar hashes
                    for file_hash, file_paths in chunk_hashes.items():
                        self.file_hashes[file_hash].extend(file_paths)
                    
                    # Progresso
                    if (i + 1) % 10 == 0:
                        progress = ((i + 1) / len(chunks)) * 100
                        elapsed = time.time() - start_time
                        print(f"📊 Chunk {i+1:,}/{len(chunks):,} ({progress:.1f}%) - {elapsed:.1f}s")
                        
                except Exception as e:
                    print(f"❌ Erro no chunk {i}: {e}")
        
        total_time = time.time() - start_time
        unique_files = len(self.file_hashes)
        
        print(f"\n✅ Hash concluído: {unique_files:,} arquivos únicos em {total_time:.1f}s")
        
    def process_hash_chunk(self, chunk: list[Path]) -> dict:
        """Processa chunk de arquivos para hash"""
        chunk_hashes = defaultdict(list)
        
        for file_path in chunk:
            try:
                file_hash = self.calculate_fast_hash(file_path)
                if file_hash:
                    chunk_hashes[file_hash].append(str(file_path))
            except Exception:
                continue
                
        return dict(chunk_hashes)
    
    def analyze_and_remove_duplicates(self):
        """Analisa e remove duplicatas de forma inteligente"""
        print("\n🧹 Iniciando limpeza inteligente de duplicatas...")
        
        # Criar diretório de backup
        backup_dir = self.create_comprehensive_backup()
        
        duplicates_found = 0
        for file_hash, file_list in self.file_hashes.items():
            if len(file_list) > 1:
                duplicates_found += 1
                
                # Escolher melhor arquivo
                best_file = self.choose_best_file_comprehensive(file_list)
                files_to_remove = [f for f in file_list if f != best_file]
                
                # Remover duplicatas
                for file_to_remove in files_to_remove:
                    self.safe_remove_comprehensive(file_to_remove, backup_dir, best_file)
                
                self.processed_groups += 1
                
                # Progresso a cada 1000 grupos
                if self.processed_groups % 1000 == 0:
                    space_gb = self.space_saved / (1024**3)
                    print(f"📊 Grupos processados: {self.processed_groups:,} - Espaço: {space_gb:.2f}GB")
        
        print(f"\n✅ Limpeza concluída: {duplicates_found:,} grupos de duplicatas processados")
    
    def choose_best_file_comprehensive(self, file_list: list[str]) -> str:
        """Escolhe o melhor arquivo usando critério abrangente"""
        if len(file_list) <= 1:
            return file_list[0] if file_list else ""
        
        # Calcular prioridades
        file_priorities = []
        for file_path in file_list:
            if Path(file_path).exists():
                priority = self.get_comprehensive_priority(file_path)
                file_priorities.append((file_path, priority))
        
        if not file_priorities:
            return file_list[0]
        
        # Ordenar por prioridade (maior = melhor)
        file_priorities.sort(key=lambda x: x[1], reverse=True)
        return file_priorities[0][0]
    
    def safe_remove_comprehensive(self, file_path: str, backup_dir: Path, kept_file: str) -> bool:
        """Remove arquivo com backup e estatísticas"""
        try:
            source_file = Path(file_path)
            if not source_file.exists():
                return False
            
            # Categorizar para estatísticas
            category = self.categorize_file(source_file)
            file_size = source_file.stat().st_size
            
            # Criar backup organizado por categoria
            category_backup = backup_dir / category
            category_backup.mkdir(exist_ok=True)
            
            backup_file = category_backup / source_file.name
            
            # Nome único se já existe
            counter = 1
            while backup_file.exists():
                stem = backup_file.stem
                suffix = backup_file.suffix
                backup_file = category_backup / f"{stem}_dup{counter}{suffix}"
                counter += 1
            
            # Mover para backup
            shutil.move(str(source_file), str(backup_file))
            
            # Atualizar estatísticas
            self.category_stats[category]['removed'] += 1
            self.category_stats[category]['space'] += file_size
            self.space_saved += file_size
            
            # Registrar
            self.removed_files.append({
                "original_path": file_path,
                "backup_path": str(backup_file),
                "size_bytes": file_size,
                "category": category,
                "kept_file": kept_file,
                "removal_time": datetime.now().isoformat()
            })
            
            return True
            
        except Exception as e:
            print(f"⚠️ Erro ao remover {file_path}: {e}")
            return False
    
    def create_comprehensive_backup(self) -> Path:
        """Cria estrutura de backup organizada"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_dir = self.base_path / "LIMPEZA_FINAL_COMPLETA" / f"duplicatas_removidas_{timestamp}"
        backup_dir.mkdir(parents=True, exist_ok=True)
        
        print(f"📁 Backup será salvo em: {backup_dir}")
        return backup_dir
    
    def generate_final_comprehensive_report(self, backup_dir: Path, total_time: float):
        """Gera relatório final abrangente"""
        space_gb = self.space_saved / (1024**3)
        space_mb = self.space_saved / (1024**2)
        
        print("\n" + "="*100)
        print("🎉 RELATÓRIO FINAL - LIMPEZA COMPLETA DOS 147,982 ARQUIVOS")
        print("="*100)
        print(f"⏱️ Tempo total de processamento: {total_time:.1f} segundos")
        print(f"📁 Arquivos únicos identificados: {len(self.file_hashes):,}")
        print(f"📦 Grupos de duplicatas processados: {self.processed_groups:,}")
        print(f"🗑️ Total de arquivos removidos: {len(self.removed_files):,}")
        print(f"💾 Espaço total economizado: {space_gb:.3f} GB ({space_mb:.1f} MB)")
        print(f"📂 Backup localizado em: {backup_dir}")
        print()
        print("📊 LIMPEZA POR CATEGORIA:")
        print("-" * 60)
        
        for category, stats in self.category_stats.items():
            if stats['removed'] > 0:
                cat_gb = stats['space'] / (1024**3)
                print(f"   📂 {category:<20}: {stats['removed']:>8,} arquivos - {cat_gb:>6.2f} GB")
        
        print("="*100)
        
        # Salvar relatório JSON
        report = {
            "cleanup_date": datetime.now().isoformat(),
            "total_processing_time": total_time,
            "backup_directory": str(backup_dir),
            "files_processed": len(self.file_hashes),
            "duplicate_groups": self.processed_groups,
            "files_removed": len(self.removed_files),
            "space_saved_bytes": self.space_saved,
            "space_saved_gb": space_gb,
            "category_statistics": self.category_stats,
            "summary": {
                "original_file_count": 147982,
                "final_file_count": 147982 - len(self.removed_files),
                "cleanup_efficiency": f"{(len(self.removed_files) / 147982 * 100):.1f}%",
                "space_efficiency": f"{(self.space_saved / (7.9 * 1024**3) * 100):.1f}%"
            }
        }
        
        report_file = self.base_path / "RELATORIO_FINAL_LIMPEZA_COMPLETA.json"
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        
        print(f"📋 Relatório completo salvo: {report_file}")
    
    def run_comprehensive_cleanup(self):
        """Executa limpeza completa e definitiva"""
        print("🚀 INICIANDO LIMPEZA FINAL COMPLETA DOS 147,982 ARQUIVOS")
        print("🎯 Objetivo: Remover TODAS as duplicatas e otimizar projeto")
        print("="*80)
        
        start_time = time.time()
        
        try:
            # 1. Coletar todos os arquivos
            all_files = self.collect_all_files_smart()
            
            # 2. Calcular hashes de todos os arquivos
            self.scan_and_hash_all_files(all_files)
            
            # 3. Analisar e remover duplicatas
            self.analyze_and_remove_duplicates()
            
            # 4. Gerar relatório final
            total_time = time.time() - start_time
            self.generate_final_comprehensive_report(
                self.create_comprehensive_backup(), 
                total_time
            )
            
            print(f"\n🎉 LIMPEZA FINAL CONCLUÍDA COM SUCESSO!")
            print(f"💾 {self.space_saved / (1024**3):.2f} GB de espaço economizado")
            print(f"🗑️ {len(self.removed_files):,} duplicatas removidas")
            
        except Exception as e:
            print(f"❌ Erro durante limpeza: {e}")
            raise

if __name__ == "__main__":
    print("🎯 PROCESSADOR FINAL DEFINITIVO")
    print("📂 Processando TODOS os 147,982 arquivos")
    print("🧹 Limpeza completa de duplicatas")
    print("="*60)
    
    processor = FinalComprehensiveProcessor("c:/Users/Admin/Documents/EA_SCALPER_XAUUSD")
    processor.run_comprehensive_cleanup()