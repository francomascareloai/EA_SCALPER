#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Deduplicador Otimizado para Arquivos MQ5
Versão: 2.0
Autor: Classificador Trading

Este script identifica e remove arquivos duplicados baseado no hash MD5 do conteúdo,
mantendo sempre o arquivo com nome mais limpo/original.
"""

import os
import sys
import hashlib
import shutil
from pathlib import Path
from collections import defaultdict
import re
from datetime import datetime

class MQ5Deduplicator:
    def __init__(self, source_dir, dry_run=True):
        self.source_dir = Path(source_dir)
        self.dry_run = dry_run
        self.duplicates_dir = self.source_dir.parent / "Duplicates_Removed"
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
        score = 0
        
        # Penaliza nomes com sufixos de duplicação
        if re.search(r'\(\d+\)', name):  # (2), (3), etc.
            score += 100
        if re.search(r'\s+\(\d+\)', name):  # espaço + (2)
            score += 50
        if '@' in name:  # @canal, @grupo
            score += 30
        if re.search(r'(copy|copia|backup|bak|old|temp|test)', name):
            score += 40
        if len(name.split(' ')) > 3:  # muitos espaços
            score += 20
        if len(name) > 50:  # nomes muito longos
            score += 10
        
        # Favorece nomes mais limpos
        if re.match(r'^[a-zA-Z0-9_\s-]+\.mq5$', name):
            score -= 20
        
        return score
    
    def scan_files(self):
        """Escaneia todos os arquivos .mq5 e agrupa por hash"""
        print(f"🔍 Escaneando arquivos em: {self.source_dir}")
        
        if not self.source_dir.exists():
            print(f"❌ Diretório não encontrado: {self.source_dir}")
            return {}
        
        mq5_files = list(self.source_dir.glob("*.mq5"))
        total_files = len(mq5_files)
        
        print(f"📁 Encontrados {total_files} arquivos .mq5")
        
        if total_files == 0:
            print("⚠️ Nenhum arquivo .mq5 encontrado!")
            return {}
        
        # Agrupa arquivos por hash
        hash_groups = defaultdict(list)
        
        for i, file_path in enumerate(mq5_files, 1):
            print(f"\r⏳ Calculando hashes... {i}/{total_files} ({i/total_files*100:.1f}%)", end="")
            
            file_hash = self.calculate_md5(file_path)
            if file_hash:
                hash_groups[file_hash].append(file_path)
        
        print("\n✅ Cálculo de hashes concluído!")
        return dict(hash_groups)
    
    def identify_duplicates(self, hash_groups):
        """Identifica grupos de duplicatas"""
        duplicate_groups = {h: files for h, files in hash_groups.items() if len(files) > 1}
        unique_files = len([h for h, files in hash_groups.items() if len(files) == 1])
        total_duplicates = sum(len(files) - 1 for files in duplicate_groups.values())
        
        print("\n" + "="*50)
        print("📊 RELATÓRIO DE DUPLICATAS")
        print("="*50)
        print(f"📄 Arquivos únicos: {unique_files}")
        print(f"🔄 Grupos de duplicatas: {len(duplicate_groups)}")
        print(f"🗑️ Total de duplicatas a remover: {total_duplicates}")
        
        return duplicate_groups, total_duplicates
    
    def preview_duplicates(self, duplicate_groups, max_preview=5):
        """Mostra preview dos grupos de duplicatas"""
        if not duplicate_groups:
            print("✅ Nenhuma duplicata encontrada!")
            return
        
        print(f"\n🔍 PREVIEW DOS PRIMEIROS {min(max_preview, len(duplicate_groups))} GRUPOS:")
        print("-" * 60)
        
        for i, (file_hash, files) in enumerate(list(duplicate_groups.items())[:max_preview], 1):
            # Ordena por prioridade
            sorted_files = sorted(files, key=self.get_file_priority)
            best_file = sorted_files[0]
            
            print(f"\n📁 Grupo {i} (Hash: {file_hash[:8]}...):")
            print(f"  ✅ MANTER: {best_file.name}")
            
            for file_path in files:
                if file_path != best_file:
                    size_kb = file_path.stat().st_size / 1024
                    print(f"  ❌ REMOVER: {file_path.name} ({size_kb:.1f} KB)")
        
        if len(duplicate_groups) > max_preview:
            print(f"\n... e mais {len(duplicate_groups) - max_preview} grupos")
    
    def execute_deduplication(self, duplicate_groups):
        """Executa a remoção de duplicatas"""
        if not duplicate_groups:
            return 0
        
        # Cria pasta para duplicatas se não existir
        if not self.dry_run:
            self.duplicates_dir.mkdir(exist_ok=True)
        
        # Inicia log
        self.log_entries = [
            "=== LOG DE REMOÇÃO DE DUPLICATAS ===",
            f"Data: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            f"Pasta origem: {self.source_dir}",
            f"Modo: {'SIMULAÇÃO' if self.dry_run else 'EXECUÇÃO REAL'}",
            ""
        ]
        
        total_removed = 0
        space_saved = 0
        
        for group_num, (file_hash, files) in enumerate(duplicate_groups.items(), 1):
            # Ordena por prioridade
            sorted_files = sorted(files, key=self.get_file_priority)
            best_file = sorted_files[0]
            files_to_remove = [f for f in files if f != best_file]
            
            print(f"\n🔄 Processando Grupo {group_num}/{len(duplicate_groups)}")
            print(f"  Hash: {file_hash[:8]}...")
            print(f"  ✅ MANTENDO: {best_file.name}")
            
            self.log_entries.extend([
                f"Grupo {group_num} (Hash: {file_hash[:8]}...):",
                f"  MANTIDO: {best_file.name}",
                "  REMOVIDOS:"
            ])
            
            for file_to_remove in files_to_remove:
                file_size = file_to_remove.stat().st_size
                space_saved += file_size
                
                print(f"  ❌ REMOVENDO: {file_to_remove.name} ({file_size/1024:.1f} KB)")
                self.log_entries.append(f"    - {file_to_remove.name} ({file_size} bytes)")
                
                if not self.dry_run:
                    # Move para pasta de duplicatas
                    dest_path = self.duplicates_dir / file_to_remove.name
                    counter = 1
                    
                    # Resolve conflitos de nome
                    while dest_path.exists():
                        stem = file_to_remove.stem
                        suffix = file_to_remove.suffix
                        dest_path = self.duplicates_dir / f"{stem}_dup{counter}{suffix}"
                        counter += 1
                    
                    try:
                        shutil.move(str(file_to_remove), str(dest_path))
                        total_removed += 1
                    except Exception as e:
                        print(f"  ⚠️ Erro ao mover {file_to_remove.name}: {e}")
                else:
                    total_removed += 1
            
            self.log_entries.append("")
        
        return total_removed, space_saved
    
    def save_log(self, total_removed, space_saved):
        """Salva log da operação"""
        self.log_entries.extend([
            "=== RESUMO ===",
            f"Total de arquivos removidos: {total_removed}",
            f"Espaço economizado: {space_saved/1024/1024:.2f} MB",
            f"Pasta de duplicatas: {self.duplicates_dir if not self.dry_run else 'N/A (simulação)'}"
        ])
        
        log_file = self.source_dir.parent / "deduplication_log.txt"
        
        try:
            with open(log_file, 'w', encoding='utf-8') as f:
                f.write('\n'.join(self.log_entries))
            print(f"\n📝 Log salvo em: {log_file}")
        except Exception as e:
            print(f"⚠️ Erro ao salvar log: {e}")
    
    def run(self):
        """Executa o processo completo de deduplicação"""
        print("🚀 DEDUPLICADOR MQ5 OTIMIZADO")
        print("=" * 40)
        print(f"📂 Pasta: {self.source_dir}")
        print(f"🔧 Modo: {'🟡 SIMULAÇÃO' if self.dry_run else '🔴 EXECUÇÃO REAL'}")
        print("=" * 40)
        
        # 1. Escaneia arquivos
        hash_groups = self.scan_files()
        if not hash_groups:
            return
        
        # 2. Identifica duplicatas
        duplicate_groups, total_duplicates = self.identify_duplicates(hash_groups)
        if not duplicate_groups:
            return
        
        # 3. Mostra preview
        self.preview_duplicates(duplicate_groups)
        
        # 4. Executa remoção
        print(f"\n{'🔄 SIMULANDO' if self.dry_run else '🗑️ EXECUTANDO'} REMOÇÃO...")
        print("-" * 50)
        
        total_removed, space_saved = self.execute_deduplication(duplicate_groups)
        
        # 5. Salva log
        self.save_log(total_removed, space_saved)
        
        # 6. Resultado final
        print("\n" + "="*50)
        print("🎯 RESULTADO FINAL")
        print("="*50)
        
        if self.dry_run:
            print(f"📊 Arquivos que seriam removidos: {total_duplicates}")
            print(f"💾 Espaço que seria economizado: {space_saved/1024/1024:.2f} MB")
            print("\n💡 Para executar a remoção real, execute:")
            print("   python deduplicator_optimized.py --execute")
        else:
            print(f"✅ Arquivos removidos com sucesso: {total_removed}")
            print(f"💾 Espaço economizado: {space_saved/1024/1024:.2f} MB")
            print(f"📁 Duplicatas movidas para: {self.duplicates_dir}")
        
        print("\n🎉 Processo concluído!")

def main():
    """Função principal"""
    # Configurações
    source_dir = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\CODIGO_FONTE_LIBRARY\MQL5_Source\All_MQ5"
    
    # Verifica argumentos
    execute_mode = '--execute' in sys.argv or '-e' in sys.argv
    dry_run = not execute_mode
    
    # Executa deduplicação
    deduplicator = MQ5Deduplicator(source_dir, dry_run=dry_run)
    deduplicator.run()
    
    # Pausa para visualização
    input("\n⏸️ Pressione Enter para sair...")

if __name__ == "__main__":
    main()