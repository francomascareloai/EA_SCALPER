#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Deduplicador Otimizado para Arquivos MQ5
Remove duplicatas baseado em hash MD5 do conteúdo
Mantém o arquivo com nome mais limpo/original
"""

import os
import hashlib
import shutil
from pathlib import Path
from collections import defaultdict
import re
from datetime import datetime

class MQ5Deduplicator:
    def __init__(self, source_dir):
        self.source_dir = Path(source_dir)
        self.duplicates_dir = self.source_dir.parent / "Duplicates_Removed"
        self.log_file = self.source_dir.parent / "deduplication_log.txt"
        self.file_hashes = defaultdict(list)
        
    def calculate_file_hash(self, file_path):
        """Calcula hash MD5 do conteúdo do arquivo"""
        hash_md5 = hashlib.md5()
        try:
            with open(file_path, "rb") as f:
                for chunk in iter(lambda: f.read(4096), b""):
                    hash_md5.update(chunk)
            return hash_md5.hexdigest()
        except Exception as e:
            print(f"Erro ao calcular hash de {file_path}: {e}")
            return None
    
    def get_file_priority(self, filename):
        """Determina prioridade do arquivo (menor = melhor)"""
        name = filename.lower()
        priority = 0
        
        # Penaliza nomes com sufixos de duplicação
        if re.search(r'\(\d+\)', name):  # (2), (3), etc.
            priority += 100
        if re.search(r'\s+\(\d+\)', name):  # espaço + (2)
            priority += 50
        if '@' in name:  # @canal, @grupo
            priority += 30
        if 'copy' in name or 'copia' in name:
            priority += 40
        if name.count(' ') > 3:  # muitos espaços
            priority += 20
        if len(name) > 50:  # nomes muito longos
            priority += 10
            
        # Favorece nomes mais limpos
        if re.match(r'^[a-zA-Z0-9_-]+\.mq5$', filename):  # nome limpo
            priority -= 20
            
        return priority
    
    def scan_files(self):
        """Escaneia todos os arquivos .mq5 e calcula hashes"""
        print(f"Escaneando arquivos em: {self.source_dir}")
        
        mq5_files = list(self.source_dir.glob("*.mq5"))
        total_files = len(mq5_files)
        
        print(f"Encontrados {total_files} arquivos .mq5")
        
        for i, file_path in enumerate(mq5_files, 1):
            print(f"\rProcessando: {i}/{total_files} - {file_path.name[:50]}...", end="")
            
            file_hash = self.calculate_file_hash(file_path)
            if file_hash:
                self.file_hashes[file_hash].append(file_path)
        
        print("\nEscaneamento concluído!")
    
    def find_duplicates(self):
        """Identifica grupos de arquivos duplicados"""
        duplicates = {}
        unique_files = 0
        duplicate_groups = 0
        total_duplicates = 0
        
        for file_hash, files in self.file_hashes.items():
            if len(files) > 1:
                duplicate_groups += 1
                total_duplicates += len(files) - 1
                duplicates[file_hash] = files
            else:
                unique_files += 1
        
        print(f"\n=== RELATÓRIO DE DUPLICATAS ===")
        print(f"Arquivos únicos: {unique_files}")
        print(f"Grupos de duplicatas: {duplicate_groups}")
        print(f"Total de duplicatas a remover: {total_duplicates}")
        
        return duplicates
    
    def select_best_file(self, files):
        """Seleciona o melhor arquivo de um grupo de duplicatas"""
        # Ordena por prioridade (menor = melhor)
        sorted_files = sorted(files, key=lambda f: self.get_file_priority(f.name))
        return sorted_files[0]
    
    def remove_duplicates(self, duplicates, dry_run=True):
        """Remove arquivos duplicados"""
        if not duplicates:
            print("Nenhuma duplicata encontrada!")
            return
        
        # Cria diretório para duplicatas removidas
        if not dry_run:
            self.duplicates_dir.mkdir(exist_ok=True)
        
        log_entries = []
        log_entries.append(f"=== LOG DE REMOÇÃO DE DUPLICATAS - {datetime.now()} ===")
        
        total_removed = 0
        space_saved = 0
        
        for file_hash, files in duplicates.items():
            best_file = self.select_best_file(files)
            files_to_remove = [f for f in files if f != best_file]
            
            log_entries.append(f"\nGrupo Hash: {file_hash[:8]}...")
            log_entries.append(f"Mantido: {best_file.name}")
            log_entries.append("Removidos:")
            
            for file_to_remove in files_to_remove:
                file_size = file_to_remove.stat().st_size
                space_saved += file_size
                
                log_entries.append(f"  - {file_to_remove.name} ({file_size} bytes)")
                
                if not dry_run:
                    # Move para pasta de duplicatas
                    dest_path = self.duplicates_dir / file_to_remove.name
                    # Se já existe, adiciona sufixo
                    counter = 1
                    while dest_path.exists():
                        stem = file_to_remove.stem
                        suffix = file_to_remove.suffix
                        dest_path = self.duplicates_dir / f"{stem}_dup{counter}{suffix}"
                        counter += 1
                    
                    shutil.move(str(file_to_remove), str(dest_path))
                    total_removed += 1
                else:
                    print(f"[DRY RUN] Removeria: {file_to_remove.name}")
        
        # Salva log
        log_entries.append(f"\n=== RESUMO ===")
        log_entries.append(f"Total de arquivos removidos: {total_removed}")
        log_entries.append(f"Espaço economizado: {space_saved / 1024 / 1024:.2f} MB")
        
        if not dry_run:
            with open(self.log_file, 'w', encoding='utf-8') as f:
                f.write('\n'.join(log_entries))
            print(f"\nLog salvo em: {self.log_file}")
        
        print(f"\n=== RESULTADO ===")
        if dry_run:
            print("[SIMULAÇÃO] Arquivos que seriam removidos:")
        else:
            print("Arquivos removidos com sucesso!")
        print(f"Total: {total_removed} arquivos")
        print(f"Espaço economizado: {space_saved / 1024 / 1024:.2f} MB")
    
    def run(self, dry_run=True):
        """Executa o processo completo de deduplicação"""
        print("=== DEDUPLICADOR MQ5 OTIMIZADO ===")
        print(f"Modo: {'SIMULAÇÃO' if dry_run else 'EXECUÇÃO REAL'}")
        
        self.scan_files()
        duplicates = self.find_duplicates()
        
        if duplicates:
            print("\n=== PREVIEW DOS GRUPOS DE DUPLICATAS ===")
            for i, (file_hash, files) in enumerate(list(duplicates.items())[:5], 1):
                best_file = self.select_best_file(files)
                print(f"\nGrupo {i}:")
                print(f"  Mantido: {best_file.name}")
                for f in files:
                    if f != best_file:
                        print(f"  Remove:  {f.name}")
            
            if len(duplicates) > 5:
                print(f"\n... e mais {len(duplicates) - 5} grupos")
            
            self.remove_duplicates(duplicates, dry_run)
        
        return len(duplicates)

def main():
    source_dir = r"c:\Users\Admin\Documents\EA_SCALPER_XAUUSD\CODIGO_FONTE_LIBRARY\MQL5_Source\All_MQ5"
    
    if not os.path.exists(source_dir):
        print(f"Erro: Diretório não encontrado: {source_dir}")
        return
    
    deduplicator = MQ5Deduplicator(source_dir)
    
    # Primeiro executa em modo simulação
    print("\n" + "="*60)
    print("EXECUTANDO EM MODO SIMULAÇÃO (DRY RUN)")
    print("="*60)
    
    duplicate_count = deduplicator.run(dry_run=True)
    
    if duplicate_count > 0:
        print("\n" + "="*60)
        response = input("\nDeseja executar a remoção real? (s/N): ").strip().lower()
        
        if response in ['s', 'sim', 'y', 'yes']:
            print("\nEXECUTANDO REMOÇÃO REAL...")
            print("="*60)
            deduplicator.run(dry_run=False)
        else:
            print("Operação cancelada pelo usuário.")
    else:
        print("\nNenhuma duplicata encontrada. Nada a fazer.")

if __name__ == "__main__":
    main()