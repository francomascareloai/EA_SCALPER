#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de Remoção de Duplicatas Inteligente
==========================================

Este script detecta e remove arquivos duplicados baseado no conteúdo (hash MD5),
mantendo apenas uma cópia de cada arquivo único para economizar espaço e melhorar performance.

Funcionalidades:
- Detecta duplicatas por hash MD5 (conteúdo idêntico)
- Remove duplicatas mantendo a melhor versão (critérios inteligentes)
- Backup automático antes da remoção
- Logging detalhado de todas operações
- Relatório de espaço economizado
"""

import os
import hashlib
import shutil
import json
import logging
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor, as_completed
import time
from functools import partial

class DuplicateRemover:
    """Removedor inteligente de duplicatas"""
    
    def __init__(self, base_path: str, batch_size: int = 5000, max_workers: int = 4):
        self.base_path = Path(base_path)
        self.batch_size = batch_size
        self.max_workers = max_workers
        self.logger = self.setup_logging()
        self.file_hashes = defaultdict(list)
        self.duplicates_found = []
        self.files_removed = []
        self.space_saved = 0
        self.processed_count = 0
        
    def setup_logging(self):
        """Configura sistema de logging"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(self.base_path / 'duplicate_removal.log', encoding='utf-8'),
                logging.StreamHandler()
            ]
        )
        return logging.getLogger(__name__)
        
    def calculate_file_hash(self, file_path: Path) -> str:
        """Calcula hash MD5 do arquivo"""
        hash_md5 = hashlib.md5()
        try:
            with open(file_path, "rb") as f:
                for chunk in iter(lambda: f.read(8192), b""):
                    hash_md5.update(chunk)
            return hash_md5.hexdigest()
        except Exception as e:
            self.logger.warning(f"⚠️ Erro ao calcular hash de {file_path}: {e}")
            return ""
            
    def should_skip_directory(self, dir_path: Path) -> bool:
        """Verifica se diretório deve ser ignorado"""
        skip_dirs = {
            '.git', '.venv', '__pycache__', 'node_modules',
            'BACKUP_MIGRATION', 'BACKUP_SEGURANCA', '.qoder',
            '.trae', '.roo', '.pytest_cache'
        }
        
        return any(skip_dir in dir_path.parts for skip_dir in skip_dirs)
        
    def get_file_priority_score(self, file_path: Path) -> int:
        """Calcula pontuação de prioridade para manter arquivo (maior = melhor)"""
        score = 0
        filename = file_path.name.lower()
        path_str = str(file_path).lower()
        
        # Prioridade por localização
        if 'main_eas' in path_str:
            score += 1000  # Máxima prioridade
        elif 'production' in path_str:
            score += 800
        elif 'library' in path_str:
            score += 600
        elif 'development' in path_str:
            score += 400
        elif 'workspace' in path_str:
            score += 300
        elif 'backup' in path_str or 'archive' in path_str:
            score -= 500  # Baixa prioridade para backups
            
        # Prioridade por tipo de arquivo
        if file_path.suffix.lower() in ['.mq5', '.mq4']:
            score += 200  # EAs e indicadores são importantes
        elif file_path.suffix.lower() in ['.ex5', '.ex4']:
            score += 100  # Compilados são menos prioritários
        elif file_path.suffix.lower() == '.json':
            if 'meta' in filename:
                score += 150  # Metadados são importantes
            else:
                score += 50
                
        # Prioridade por conteúdo do nome
        if 'ftmo' in filename:
            score += 300  # FTMO é prioridade máxima
        elif 'elite' in filename or 'scalper' in filename:
            score += 200
        elif 'smc' in filename or 'ict' in filename:
            score += 100
            
        # Prioridade por versão (versões mais recentes)
        if '_v' in filename:
            try:
                version_part = filename.split('_v')[1].split('_')[0].split('.')[0]
                if version_part.replace('.', '').isdigit():
                    score += int(float(version_part) * 10)
            except:
                pass
                
        # Penalizar arquivos com sufixos de duplicata
        if any(suffix in filename for suffix in ['_1', '_2', '_3', '(1)', '(2)', '(3)', '_copy', '_backup']):
            score -= 100
            
        return score
        
    def choose_best_file(self, duplicate_files: List[Path]) -> Path:
        """Escolhe o melhor arquivo entre duplicatas"""
        if len(duplicate_files) == 1:
            return duplicate_files[0]
            
        # Calcular pontuação para cada arquivo
        file_scores = []
        for file_path in duplicate_files:
            score = self.get_file_priority_score(file_path)
            file_scores.append((file_path, score))
            
        # Ordenar por pontuação (maior primeiro)
        file_scores.sort(key=lambda x: x[1], reverse=True)
        
        best_file = file_scores[0][0]
        self.logger.info(f"🏆 Melhor arquivo escolhido: {best_file} (score: {file_scores[0][1]})")
        
        return best_file
        
    def get_all_files(self) -> List[Path]:
        """Coleta todos os arquivos do projeto em lotes"""
        self.logger.info("📂 Coletando lista de arquivos...")
        all_files = []
        
        for root, dirs, files in os.walk(self.base_path):
            current_dir = Path(root)
            
            # Pular diretórios que devem ser ignorados
            if self.should_skip_directory(current_dir):
                continue
                
            for filename in files:
                file_path = current_dir / filename
                if file_path.is_file():
                    all_files.append(file_path)
                    
        self.logger.info(f"📊 Total de arquivos encontrados: {len(all_files):,}")
        return all_files
        
    def process_file_batch(self, file_batch: List[Path]) -> Dict[str, List[Path]]:
        """Processa um lote de arquivos e retorna hashes"""
        batch_hashes = defaultdict(list)
        
        def process_single_file(file_path: Path) -> Tuple[str, Path]:
            """Processa um único arquivo"""
            try:
                file_hash = self.calculate_file_hash(file_path)
                return file_hash, file_path
            except Exception as e:
                self.logger.warning(f"⚠️ Erro ao processar {file_path}: {e}")
                return "", file_path
                
        # Processar arquivos em paralelo
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            future_to_file = {executor.submit(process_single_file, fp): fp for fp in file_batch}
            
            for future in as_completed(future_to_file):
                file_hash, file_path = future.result()
                if file_hash:
                    batch_hashes[file_hash].append(file_path)
                    
        return batch_hashes
        
    def scan_for_duplicates(self):
        """Escaneia projeto em busca de duplicatas usando processamento em lotes"""
        self.logger.info("🔍 Iniciando escaneamento otimizado de duplicatas...")
        start_time = time.time()
        
        # Coletar todos os arquivos
        all_files = self.get_all_files()
        total_files = len(all_files)
        
        if total_files == 0:
            self.logger.info("📂 Nenhum arquivo encontrado para processar.")
            return
            
        self.logger.info(f"🚀 Processando {total_files:,} arquivos em lotes de {self.batch_size:,}")
        
        # Processar em lotes
        for i in range(0, total_files, self.batch_size):
            batch_end = min(i + self.batch_size, total_files)
            batch = all_files[i:batch_end]
            
            self.logger.info(f"📦 Processando lote {i//self.batch_size + 1}: arquivos {i+1:,} a {batch_end:,}")
            
            # Processar lote
            batch_start = time.time()
            batch_hashes = self.process_file_batch(batch)
            batch_time = time.time() - batch_start
            
            # Mesclar com hashes globais
            for file_hash, file_list in batch_hashes.items():
                self.file_hashes[file_hash].extend(file_list)
                
            self.processed_count = batch_end
            
            # Estatísticas de progresso
            progress = (batch_end / total_files) * 100
            files_per_second = len(batch) / batch_time if batch_time > 0 else 0
            eta_seconds = (total_files - batch_end) / files_per_second if files_per_second > 0 else 0
            
            self.logger.info(f"⚡ Lote processado em {batch_time:.1f}s ({files_per_second:.0f} arq/s) - Progresso: {progress:.1f}% - ETA: {eta_seconds/60:.1f}min")
            
        total_time = time.time() - start_time
        avg_speed = total_files / total_time if total_time > 0 else 0
        
        self.logger.info(f"✅ Escaneamento concluído! {total_files:,} arquivos em {total_time:.1f}s (média: {avg_speed:.0f} arq/s)")
        
        # Identificar duplicatas
        duplicates_count = 0
        for file_hash, file_list in self.file_hashes.items():
            if len(file_list) > 1:
                self.duplicates_found.append((file_hash, file_list))
                duplicates_count += len(file_list) - 1
                
        self.logger.info(f"🔍 Encontradas {len(self.duplicates_found)} grupos de duplicatas ({duplicates_count} arquivos duplicados)")
        
    def remove_duplicates(self):
        """Remove duplicatas mantendo apenas o melhor arquivo"""
        if not self.duplicates_found:
            self.logger.info("✅ Nenhuma duplicata encontrada!")
            return
            
        self.logger.info("🗑️ Iniciando remoção de duplicatas...")
        
        # Criar diretório de backup para duplicatas removidas
        backup_dir = self.base_path / "REMOVED_DUPLICATES" / datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_dir.mkdir(parents=True, exist_ok=True)
        
        for file_hash, duplicate_files in self.duplicates_found:
            if len(duplicate_files) <= 1:
                continue
                
            # Escolher melhor arquivo
            best_file = self.choose_best_file(duplicate_files)
            
            # Remover outros arquivos
            for file_path in duplicate_files:
                if file_path != best_file:
                    try:
                        # Calcular espaço a ser economizado
                        file_size = file_path.stat().st_size
                        self.space_saved += file_size
                        
                        # Fazer backup do arquivo antes de remover
                        backup_subdir = backup_dir / file_path.parent.name
                        backup_subdir.mkdir(exist_ok=True)
                        backup_file = backup_subdir / file_path.name
                        
                        # Se já existe arquivo com mesmo nome no backup, renomear
                        counter = 1
                        while backup_file.exists():
                            name_parts = file_path.name.rsplit('.', 1)
                            if len(name_parts) == 2:
                                backup_name = f"{name_parts[0]}_dup{counter}.{name_parts[1]}"
                            else:
                                backup_name = f"{file_path.name}_dup{counter}"
                            backup_file = backup_subdir / backup_name
                            counter += 1
                            
                        # Copiar para backup e remover original
                        shutil.copy2(file_path, backup_file)
                        file_path.unlink()
                        
                        self.files_removed.append({
                            "original_path": str(file_path),
                            "backup_path": str(backup_file),
                            "size_bytes": file_size,
                            "kept_file": str(best_file)
                        })
                        
                        self.logger.info(f"🗑️ Removido: {file_path} (backup: {backup_file})")
                        
                    except Exception as e:
                        self.logger.error(f"❌ Erro ao remover {file_path}: {e}")
                        
        self.logger.info(f"✅ Remoção concluída! {len(self.files_removed)} arquivos removidos.")
        self.logger.info(f"💾 Espaço economizado: {self.format_size(self.space_saved)}")
        
    def format_size(self, size_bytes: int) -> str:
        """Formata tamanho em bytes para formato legível"""
        for unit in ['B', 'KB', 'MB', 'GB']:
            if size_bytes < 1024.0:
                return f"{size_bytes:.1f} {unit}"
            size_bytes /= 1024.0
        return f"{size_bytes:.1f} TB"
        
    def generate_report(self):
        """Gera relatório detalhado da remoção"""
        report = {
            "removal_date": datetime.now().isoformat(),
            "total_files_scanned": sum(len(files) for files in self.file_hashes.values()),
            "duplicate_groups_found": len(self.duplicates_found),
            "files_removed": len(self.files_removed),
            "space_saved_bytes": self.space_saved,
            "space_saved_formatted": self.format_size(self.space_saved),
            "removed_files": self.files_removed,
            "summary": {
                "before_cleanup": {
                    "total_duplicate_files": sum(len(files) - 1 for _, files in self.duplicates_found),
                },
                "after_cleanup": {
                    "duplicates_removed": len(self.files_removed),
                    "unique_files_kept": len(self.duplicates_found)
                }
            }
        }
        
        # Salvar relatório
        report_path = self.base_path / "duplicate_removal_report.json"
        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
            
        self.logger.info(f"📋 Relatório salvo: {report_path}")
        
        # Exibir resumo
        self.logger.info("\n" + "="*60)
        self.logger.info("📊 RESUMO DA REMOÇÃO DE DUPLICATAS")
        self.logger.info("="*60)
        self.logger.info(f"📁 Arquivos escaneados: {report['total_files_scanned']:,}")
        self.logger.info(f"🔍 Grupos de duplicatas: {report['duplicate_groups_found']:,}")
        self.logger.info(f"🗑️ Arquivos removidos: {report['files_removed']:,}")
        self.logger.info(f"💾 Espaço economizado: {report['space_saved_formatted']}")
        self.logger.info("="*60)
        
    def run_cleanup(self):
        """Executa limpeza completa de duplicatas"""
        self.logger.info("🚀 Iniciando limpeza de duplicatas...")
        
        try:
            # 1. Escanear duplicatas
            self.scan_for_duplicates()
            
            # 2. Remover duplicatas
            self.remove_duplicates()
            
            # 3. Gerar relatório
            self.generate_report()
            
            self.logger.info("🎉 Limpeza de duplicatas concluída com sucesso!")
            
        except Exception as e:
            self.logger.error(f"❌ Erro durante limpeza: {e}")
            raise

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description='Remove duplicatas do projeto')
    parser.add_argument('--batch-size', type=int, default=2000, help='Tamanho do lote (default: 2000)')
    parser.add_argument('--workers', type=int, default=6, help='Número de workers paralelos (default: 6)')
    parser.add_argument('--scan-only', action='store_true', help='Apenas escanear, não remover')
    
    args = parser.parse_args()
    
    # Executar limpeza de duplicatas otimizada
    remover = DuplicateRemover(
        "c:/Users/Admin/Documents/EA_SCALPER_XAUUSD",
        batch_size=args.batch_size,
        max_workers=args.workers
    )
    
    if args.scan_only:
        print("🔍 Modo: Apenas escaneamento")
        remover.scan_for_duplicates()
        remover.generate_report()
    else:
        print(f"🚀 Modo: Limpeza completa (lotes: {args.batch_size}, workers: {args.workers})")
        remover.run_cleanup()