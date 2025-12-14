#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Scanner Rápido de Duplicatas - Versão Ultra-Otimizada
====================================================

Versão ultra-rápida que apenas escaneia e reporta duplicatas sem remover,
otimizada para projetos com 100k+ arquivos.
"""

import os
import hashlib
from pathlib import Path
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor, ProcessPoolExecutor
import time
import json

def calculate_fast_hash(file_path: Path) -> str:
    """Calcula hash rápido lendo apenas início e fim do arquivo"""
    try:
        file_size = file_path.stat().st_size
        
        # Para arquivos pequenos, ler tudo
        if file_size <= 8192:
            with open(file_path, "rb") as f:
                return hashlib.md5(f.read()).hexdigest()
        
        # Para arquivos grandes, ler início + meio + fim
        hash_md5 = hashlib.md5()
        with open(file_path, "rb") as f:
            # Início do arquivo
            hash_md5.update(f.read(4096))
            
            # Meio do arquivo
            f.seek(file_size // 2)
            hash_md5.update(f.read(4096))
            
            # Fim do arquivo
            f.seek(-4096, 2)
            hash_md5.update(f.read(4096))
            
            # Incluir tamanho no hash para diferenciação
            hash_md5.update(str(file_size).encode())
            
        return hash_md5.hexdigest()
        
    except Exception:
        return ""

def process_chunk(chunk):
    """Processa um chunk de arquivos"""
    chunk_hashes = defaultdict(list)
    for file_path in chunk:
        file_hash = calculate_fast_hash(file_path)
        if file_hash:
            chunk_hashes[file_hash].append(str(file_path))
    return dict(chunk_hashes)

class FastDuplicateScanner:
    """Scanner ultra-rápido de duplicatas"""
    
    def __init__(self, base_path: str, chunk_size: int = 1000):
        self.base_path = Path(base_path)
        self.chunk_size = chunk_size
        self.file_hashes = defaultdict(list)
        

    
    def should_skip(self, file_path: Path) -> bool:
        """Verifica se arquivo deve ser ignorado"""
        skip_dirs = {'.git', '.venv', '__pycache__', 'BACKUP_MIGRATION', 'REMOVED_DUPLICATES'}
        return any(skip_dir in file_path.parts for skip_dir in skip_dirs)
        
    def scan_fast(self):
        """Escaneamento ultra-rápido"""
        print("🚀 Iniciando escaneamento ultra-rápido...")
        start_time = time.time()
        
        # Coletar arquivos
        all_files = []
        for root, dirs, files in os.walk(self.base_path):
            for filename in files:
                file_path = Path(root) / filename
                if not self.should_skip(file_path) and file_path.is_file():
                    all_files.append(file_path)
        
        total_files = len(all_files)
        print(f"📁 Encontrados {total_files:,} arquivos")
        
        if total_files == 0:
            return
            
        # Dividir em chunks
        chunks = [all_files[i:i + self.chunk_size] for i in range(0, total_files, self.chunk_size)]
        print(f"⚡ Processando {len(chunks)} chunks de {self.chunk_size} arquivos")
        
        # Processar chunks com ThreadPoolExecutor (mais compatível)
        with ThreadPoolExecutor(max_workers=4) as executor:
            results = list(executor.map(process_chunk, chunks))
        
        # Mesclar resultados
        for chunk_result in results:
            for file_hash, file_list in chunk_result.items():
                self.file_hashes[file_hash].extend(file_list)
        
        # Analisar duplicatas
        duplicates = []
        total_duplicates = 0
        total_duplicate_size = 0
        
        for file_hash, file_list in self.file_hashes.items():
            if len(file_list) > 1:
                # Calcular tamanho das duplicatas
                try:
                    first_file_size = Path(file_list[0]).stat().st_size
                    duplicate_size = first_file_size * (len(file_list) - 1)
                    total_duplicate_size += duplicate_size
                    
                    duplicates.append({
                        "hash": file_hash,
                        "files": file_list,
                        "count": len(file_list),
                        "size_per_file": first_file_size,
                        "wasted_space": duplicate_size
                    })
                    total_duplicates += len(file_list) - 1
                except:
                    pass
        
        scan_time = time.time() - start_time
        
        # Relatório rápido
        print("\n" + "="*60)
        print("📊 RELATÓRIO DE DUPLICATAS")
        print("="*60)
        print(f"📁 Arquivos escaneados: {total_files:,}")
        print(f"🔍 Grupos de duplicatas: {len(duplicates):,}")
        print(f"🗑️ Arquivos duplicados: {total_duplicates:,}")
        print(f"💾 Espaço desperdiçado: {self.format_size(total_duplicate_size)}")
        print(f"⏱️ Tempo de escaneamento: {scan_time:.1f}s")
        print(f"⚡ Velocidade: {total_files/scan_time:.0f} arquivos/segundo")
        print("="*60)
        
        # Salvar relatório detalhado
        report = {
            "scan_date": time.strftime("%Y-%m-%d %H:%M:%S"),
            "total_files": total_files,
            "duplicate_groups": len(duplicates),
            "duplicate_files": total_duplicates,
            "wasted_space_bytes": total_duplicate_size,
            "wasted_space_formatted": self.format_size(total_duplicate_size),
            "scan_time_seconds": scan_time,
            "scan_speed_files_per_second": total_files/scan_time,
            "top_duplicates": sorted(duplicates, key=lambda x: x["wasted_space"], reverse=True)[:20]
        }
        
        with open(self.base_path / "fast_duplicate_scan.json", "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        
        print("📋 Relatório salvo em: fast_duplicate_scan.json")
        
        return duplicates
    
    def format_size(self, size_bytes: int) -> str:
        """Formata tamanho em bytes"""
        for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
            if size_bytes < 1024.0:
                return f"{size_bytes:.1f} {unit}"
            size_bytes /= 1024.0

if __name__ == "__main__":
    scanner = FastDuplicateScanner("c:/Users/Admin/Documents/EA_SCALPER_XAUUSD", chunk_size=2000)
    scanner.scan_fast()