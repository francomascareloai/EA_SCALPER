#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Deduplicador Final para Arquivos MQ4
Versão: 1.0
Autor: Agente Organizador

Este script identifica e remove duplicatas de arquivos .mq4.
"""

import os
import sys
import hashlib
import shutil
from pathlib import Path
from collections import defaultdict
import re
from datetime import datetime

class MQL4Deduplicator:
    def __init__(self, source_dir, dry_run=True):
        self.source_dir = Path(source_dir)
        self.dry_run = dry_run
        self.duplicates_dir = self.source_dir.parent / "Duplicates_Removed_MQL4"
        self.log_entries = []

    def calculate_md5(self, file_path):
        """Calcula hash MD5 do arquivo"""
        try:
            hash_md5 = hashlib.md5()
            with open(file_path, "rb") as f:
                for chunk in iter(lambda: f.read(4096), b""):
                    hash_md5.update(chunk)
            return hash_md5.hexdigest()
        except Exception as e:
            print(f"Erro ao calcular hash de {file_path}: {e}")
            return None

    def get_file_priority(self, file_path):
        """Determina prioridade do arquivo (menor = melhor)"""
        name = file_path.name.lower()
        score = len(name) # Nomes mais curtos são melhores

        if re.search(r'\(\d+\)', name): score += 100
        if 'copy' in name: score += 50
        if '@' in name: score += 30

        return score

    def scan_files(self):
        """Escaneia todos os arquivos .mq4 e agrupa por hash"""
        print(f"🔍 Escaneando arquivos em: {self.source_dir}")
        mq4_files = list(self.source_dir.glob("*.mq4"))
        total_files = len(mq4_files)
        print(f"📁 Encontrados {total_files} arquivos .mq4")

        if total_files == 0:
            return {}

        hash_groups = defaultdict(list)
        for i, file_path in enumerate(mq4_files, 1):
            print(f"\r⏳ Analisando... {i}/{total_files} ({i/total_files*100:.1f}%)", end="")
            file_hash = self.calculate_md5(file_path)
            if file_hash:
                hash_groups[file_hash].append(file_path)
        
        print("\n✅ Análise concluída!")
        return dict(hash_groups)

    def identify_duplicates(self, hash_groups):
        """Identifica grupos de duplicatas"""
        duplicates = {h: files for h, files in hash_groups.items() if len(files) > 1}
        total_duplicates = sum(len(files) - 1 for files in duplicates.values())
        
        print("\n" + "="*50)
        print("📊 RELATÓRIO DE DUPLICATAS MQL4")
        print("="*50)
        print(f"🔄 Grupos de duplicatas encontrados: {len(duplicates)}")
        print(f"🗑️ Total de arquivos duplicados a remover: {total_duplicates}")
        
        return duplicates, total_duplicates

    def execute_deduplication(self, duplicate_groups):
        """Executa a remoção de duplicatas"""
        if not self.dry_run:
            self.duplicates_dir.mkdir(exist_ok=True)

        self.log_entries = [
            "=== LOG DE REMOÇÃO DE DUPLICATAS MQL4 ===",
            f"Data: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            f"Pasta origem: {self.source_dir}",
            f"Modo: {'SIMULAÇÃO' if self.dry_run else 'EXECUÇÃO REAL'}",
            ""
        ]

        total_removed = 0
        space_saved = 0

        for group_num, (group_key, files) in enumerate(duplicate_groups.items(), 1):
            sorted_files = sorted(files, key=self.get_file_priority)
            best_file = sorted_files[0]
            files_to_remove = [f for f in files if f != best_file]

            self.log_entries.extend([
                f"Grupo {group_num} (Hash: {group_key[:8]}...):",
                f"  MANTIDO: {best_file.name}",
                "  REMOVIDOS:"
            ])

            for file_to_remove in files_to_remove:
                file_size = file_to_remove.stat().st_size
                space_saved += file_size
                self.log_entries.append(f"    - {file_to_remove.name} ({file_size} bytes)")
                
                if not self.dry_run:
                    dest_path = self.duplicates_dir / file_to_remove.name
                    try:
                        shutil.move(str(file_to_remove), str(dest_path))
                    except Exception as e:
                        print(f"  ⚠️ Erro ao mover {file_to_remove.name}: {e}")
                total_removed += 1
        
        return total_removed, space_saved

    def save_log(self, total_removed, space_saved):
        """Salva log da operação"""
        self.log_entries.extend([
            "\n=== RESUMO FINAL ===",
            f"Total de arquivos removidos: {total_removed}",
            f"Espaço economizado: {space_saved/1024/1024:.2f} MB"
        ])
        log_file = self.source_dir.parent / "deduplication_mql4_log.txt"
        with open(log_file, 'w', encoding='utf-8') as f:
            f.write('\n'.join(self.log_entries))
        print(f"\n📝 Log salvo em: {log_file}")

    def run(self):
        """Executa o processo completo"""
        print("🚀 DEDUPLICADOR MQL4")
        print("="*40)
        print(f"📂 Pasta: {self.source_dir}")
        print(f"🔧 Modo: {'🟡 SIMULAÇÃO' if self.dry_run else '🔴 EXECUÇÃO REAL'}")
        print("="*40)

        hash_groups = self.scan_files()
        if not hash_groups: return

        duplicate_groups, total_duplicates = self.identify_duplicates(hash_groups)
        if not duplicate_groups: 
            print("\n✅ Nenhuma duplicata encontrada!")
            return

        total_removed, space_saved = self.execute_deduplication(duplicate_groups)
        self.save_log(total_removed, space_saved)

        print("\n" + "="*50)
        print("🎯 RESULTADO DA SIMULAÇÃO")
        print("="*50)
        print(f"📊 Arquivos que seriam removidos: {total_duplicates}")
        print(f"💾 Espaço que seria economizado: {space_saved/1024/1024:.2f} MB")
        
        if self.dry_run:
            print("\n💡 Para executar a remoção real, execute com o argumento --execute")
        else:
            print(f"✅ Arquivos removidos com sucesso: {total_removed}")
            print(f"📁 Duplicatas movidas para: {self.duplicates_dir}")

def main():
    source_dir = r"c:\Users\Admin\Documents\EA_SCALPER_XAUUSD\CODIGO_FONTE_LIBRARY\MQL4_Source\All_MQ4"
    execute_mode = '--execute' in sys.argv
    deduplicator = MQL4Deduplicator(source_dir, dry_run=not execute_mode)
    deduplicator.run()

if __name__ == "__main__":
    main()