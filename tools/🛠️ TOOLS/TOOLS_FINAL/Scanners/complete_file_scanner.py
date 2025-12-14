#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Scanner Completo de TODOS os Arquivos
====================================

Escaneia TODOS os 144k+ arquivos do projeto, incluindo os que foram ignorados anteriormente.
Versão otimizada para processar grandes volumes sem limitações.
"""

import os
import hashlib
from pathlib import Path
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor
import time
import json

def calculate_fast_hash(file_path: Path) -> str:
    """Calcula hash rápido lendo apenas início e fim do arquivo"""
    try:
        if not file_path.exists():
            return ""
            
        file_size = file_path.stat().st_size
        
        # Para arquivos muito pequenos (< 1KB), ler tudo
        if file_size <= 1024:
            with open(file_path, "rb") as f:
                return hashlib.md5(f.read()).hexdigest()
        
        # Para arquivos pequenos (< 8KB), ler tudo
        if file_size <= 8192:
            with open(file_path, "rb") as f:
                return hashlib.md5(f.read()).hexdigest()
        
        # Para arquivos grandes, ler início + meio + fim + tamanho
        hash_md5 = hashlib.md5()
        with open(file_path, "rb") as f:
            # Início do arquivo (4KB)
            hash_md5.update(f.read(4096))
            
            # Meio do arquivo (4KB)
            f.seek(file_size // 2)
            hash_md5.update(f.read(4096))
            
            # Fim do arquivo (4KB)
            if file_size > 8192:
                f.seek(-4096, 2)
                hash_md5.update(f.read(4096))
            
            # Incluir tamanho no hash para diferenciação
            hash_md5.update(str(file_size).encode())
            
        return hash_md5.hexdigest()
        
    except Exception as e:
        print(f"⚠️ Erro ao processar {file_path}: {e}")
        return ""

def process_chunk(chunk):
    """Processa um chunk de arquivos"""
    chunk_hashes = defaultdict(list)
    chunk_processed = 0
    
    for file_path in chunk:
        try:
            file_hash = calculate_fast_hash(file_path)
            if file_hash:
                chunk_hashes[file_hash].append(str(file_path))
                chunk_processed += 1
        except Exception as e:
            print(f"⚠️ Erro no chunk: {e}")
            
    return dict(chunk_hashes), chunk_processed

class CompleteDuplicateScanner:
    """Scanner que processa TODOS os arquivos"""
    
    def __init__(self, base_path: str, chunk_size: int = 1000):
        self.base_path = Path(base_path)
        self.chunk_size = chunk_size
        self.file_hashes = defaultdict(list)
        
    def should_skip_file(self, file_path: Path) -> bool:
        """Verifica se arquivo específico deve ser ignorado (muito restritivo)"""
        try:
            # Apenas ignorar arquivos que realmente não devem ser processados
            if file_path.name.startswith('.'):
                return True
            if file_path.suffix.lower() in ['.tmp', '.temp', '.lock']:
                return True
            if 'REMOVED_DUPLICATES' in str(file_path):
                return True
            return False
        except:
            return False
            
    def should_skip_directory(self, dir_path: Path) -> bool:
        """Versão menos restritiva - só ignora diretórios realmente problemáticos"""
        skip_dirs = {
            '.git', '.venv', '__pycache__', 
            'REMOVED_DUPLICATES_SMART'  # Apenas nossos próprios backups de remoção
        }
        
        return any(skip_dir in dir_path.parts for skip_dir in skip_dirs)
        
    def collect_all_files(self) -> list[Path]:
        """Coleta TODOS os arquivos do projeto"""
        print("📂 Coletando TODOS os arquivos do projeto...")
        start_time = time.time()
        
        all_files = []
        skipped_files = 0
        skipped_dirs = set()
        
        for root, dirs, files in os.walk(self.base_path):
            current_dir = Path(root)
            
            # Verificar se diretório deve ser ignorado
            if self.should_skip_directory(current_dir):
                skipped_dirs.add(str(current_dir))
                continue
                
            for filename in files:
                file_path = current_dir / filename
                
                if self.should_skip_file(file_path):
                    skipped_files += 1
                    continue
                    
                if file_path.is_file():
                    all_files.append(file_path)
                    
        collection_time = time.time() - start_time
        
        print(f"📊 Coleta concluída em {collection_time:.1f}s:")
        print(f"   📁 Total de arquivos encontrados: {len(all_files):,}")
        print(f"   ⏭️ Arquivos ignorados: {skipped_files:,}")
        print(f"   📁 Diretórios ignorados: {len(skipped_dirs)}")
        
        if skipped_dirs:
            print(f"   📂 Diretórios ignorados: {list(skipped_dirs)[:5]}{'...' if len(skipped_dirs) > 5 else ''}")
        
        return all_files
        
    def scan_all_files(self):
        """Escaneia TODOS os arquivos do projeto"""
        print("🚀 Iniciando escaneamento COMPLETO de TODOS os arquivos...")
        start_time = time.time()
        
        # Coletar todos os arquivos
        all_files = self.collect_all_files()
        total_files = len(all_files)
        
        if total_files == 0:
            print("❌ Nenhum arquivo encontrado!")
            return
            
        print(f"⚡ Processando {total_files:,} arquivos em chunks de {self.chunk_size:,}")
        
        # Dividir em chunks
        chunks = [all_files[i:i + self.chunk_size] for i in range(0, total_files, self.chunk_size)]
        total_chunks = len(chunks)
        
        print(f"📦 Total de chunks: {total_chunks}")
        
        # Processar chunks com ThreadPoolExecutor
        total_processed = 0
        
        with ThreadPoolExecutor(max_workers=8) as executor:
            futures = []
            
            # Submeter todos os chunks
            for i, chunk in enumerate(chunks):
                future = executor.submit(process_chunk, chunk)
                futures.append((i, future))
            
            # Processar resultados conforme ficam prontos
            for i, future in futures:
                try:
                    chunk_hashes, chunk_processed = future.result()
                    total_processed += chunk_processed
                    
                    # Mesclar com hashes globais
                    for file_hash, file_list in chunk_hashes.items():
                        self.file_hashes[file_hash].extend(file_list)
                    
                    # Mostrar progresso
                    progress = ((i + 1) / total_chunks) * 100
                    print(f"📊 Chunk {i+1:,}/{total_chunks:,} ({progress:.1f}%) - Processados: {total_processed:,}")
                    
                except Exception as e:
                    print(f"❌ Erro no chunk {i}: {e}")
        
        total_time = time.time() - start_time
        avg_speed = total_processed / total_time if total_time > 0 else 0
        
        print(f"\n✅ Escaneamento COMPLETO concluído!")
        print(f"📊 Arquivos processados: {total_processed:,}/{total_files:,}")
        print(f"⏱️ Tempo total: {total_time:.1f}s")
        print(f"⚡ Velocidade média: {avg_speed:.0f} arquivos/segundo")
        
        # Analisar duplicatas
        self.analyze_duplicates()
        
    def analyze_duplicates(self):
        """Analisa e reporta duplicatas encontradas"""
        print("\n🔍 Analisando duplicatas...")
        
        duplicates = []
        total_duplicates = 0
        total_duplicate_size = 0
        
        for file_hash, file_list in self.file_hashes.items():
            if len(file_list) > 1:
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
        
        # Relatório final
        print("\n" + "="*70)
        print("📊 RELATÓRIO COMPLETO DE DUPLICATAS")
        print("="*70)
        print(f"📁 Arquivos únicos processados: {len(self.file_hashes):,}")
        print(f"🔍 Grupos de duplicatas: {len(duplicates):,}")
        print(f"🗑️ Arquivos duplicados: {total_duplicates:,}")
        print(f"💾 Espaço desperdiçado: {self.format_size(total_duplicate_size)}")
        print("="*70)
        
        # Salvar relatório completo
        report = {
            "scan_date": time.strftime("%Y-%m-%d %H:%M:%S"),
            "total_unique_files": len(self.file_hashes),
            "duplicate_groups": len(duplicates),
            "duplicate_files": total_duplicates,
            "wasted_space_bytes": total_duplicate_size,
            "wasted_space_formatted": self.format_size(total_duplicate_size),
            "top_duplicates": sorted(duplicates, key=lambda x: x["wasted_space"], reverse=True)[:50]
        }
        
        with open(self.base_path / "complete_duplicate_scan.json", "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        
        print("📋 Relatório completo salvo em: complete_duplicate_scan.json")
        
        return duplicates
    
    def format_size(self, size_bytes: int) -> str:
        """Formata tamanho em bytes"""
        for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
            if size_bytes < 1024.0:
                return f"{size_bytes:.1f} {unit}"
            size_bytes /= 1024.0

if __name__ == "__main__":
    scanner = CompleteDuplicateScanner("c:/Users/Admin/Documents/EA_SCALPER_XAUUSD", chunk_size=2000)
    scanner.scan_all_files()