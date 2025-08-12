#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Deduplicador Final para Arquivos MQ5
Versão: 3.0
Autor: Agente Organizador

Este script identifica e remove duplicatas restantes que escaparam da primeira limpeza,
incluindo padrões específicos como (2), (3), versões diferentes, etc.
"""

import os
import sys
import hashlib
import shutil
from pathlib import Path
from collections import defaultdict
import re
from datetime import datetime

class FinalDeduplicator:
    def __init__(self, source_dir, dry_run=True):
        self.source_dir = Path(source_dir)
        self.dry_run = dry_run
        self.duplicates_dir = self.source_dir.parent / "Duplicates_Removed_Final"
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
        
        # Penaliza padrões de duplicação
        if re.search(r'\(\d+\)', name):  # (2), (3), etc.
            score += 100
        if re.search(r'\s+\(\d+\)', name):  # espaço + (2)
            score += 50
        if re.search(r'\(\d+\)\s*\(\d+\)', name):  # (1) (2)
            score += 150
        if '@' in name:  # @canal, @grupo
            score += 30
        if re.search(r'(copy|copia|backup|bak|old|temp|test)', name):
            score += 40
        if re.search(r'(lifein|dreams|world|forex|expert|advisors)', name):
            score += 25
        if len(name.split(' ')) > 4:  # muitos espaços
            score += 20
        if len(name) > 60:  # nomes muito longos
            score += 15
        
        # Favorece nomes mais limpos
        if re.match(r'^[a-zA-Z0-9_\s-]+\.mq5$', name):
            score -= 20
        if not re.search(r'[()@]', name):  # sem parênteses ou @
            score -= 30
        
        return score
    
    def normalize_name(self, filename):
        """Normaliza nome do arquivo para comparação"""
        # Remove extensão
        name = filename.lower().replace('.mq5', '')
        
        # Remove padrões comuns de duplicação
        name = re.sub(r'\s*\(\d+\)\s*', ' ', name)
        name = re.sub(r'@[a-zA-Z0-9_]+', '', name)
        name = re.sub(r'\s+', ' ', name)
        name = name.strip()
        
        return name
    
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
        name_groups = defaultdict(list)
        
        for i, file_path in enumerate(mq5_files, 1):
            print(f"\r⏳ Analisando... {i}/{total_files} ({i/total_files*100:.1f}%)", end="")
            
            # Agrupa por hash MD5
            file_hash = self.calculate_md5(file_path)
            if file_hash:
                hash_groups[file_hash].append(file_path)
            
            # Agrupa por nome normalizado
            normalized_name = self.normalize_name(file_path.name)
            name_groups[normalized_name].append(file_path)
        
        print("\n✅ Análise concluída!")
        return dict(hash_groups), dict(name_groups)
    
    def identify_duplicates(self, hash_groups, name_groups):
        """Identifica grupos de duplicatas"""
        # Duplicatas por hash (conteúdo idêntico)
        hash_duplicates = {h: files for h, files in hash_groups.items() if len(files) > 1}
        
        # Duplicatas por nome (mesmo arquivo, nomes diferentes)
        name_duplicates = {n: files for n, files in name_groups.items() if len(files) > 1}
        
        # Combina ambos os tipos
        all_duplicates = {}
        
        # Adiciona duplicatas por hash
        for hash_key, files in hash_duplicates.items():
            all_duplicates[f"hash_{hash_key[:8]}"] = files
        
        # Adiciona duplicatas por nome que não estão em hash_duplicates
        for name_key, files in name_duplicates.items():
            # Verifica se esses arquivos já estão em hash_duplicates
            already_in_hash = False
            for hash_key, hash_files in hash_duplicates.items():
                if any(f in hash_files for f in files):
                    already_in_hash = True
                    break
            
            if not already_in_hash:
                all_duplicates[f"name_{name_key}"] = files
        
        total_duplicates = sum(len(files) - 1 for files in all_duplicates.values())
        
        print("\n" + "="*50)
        print("📊 RELATÓRIO DE DUPLICATAS FINAIS")
        print("="*50)
        print(f"🔄 Grupos de duplicatas por hash: {len(hash_duplicates)}")
        print(f"📝 Grupos de duplicatas por nome: {len(name_duplicates)}")
        print(f"🗑️ Total de duplicatas a remover: {total_duplicates}")
        
        return all_duplicates, total_duplicates
    
    def preview_duplicates(self, duplicate_groups, max_preview=10):
        """Mostra preview dos grupos de duplicatas"""
        if not duplicate_groups:
            print("✅ Nenhuma duplicata encontrada!")
            return
        
        print(f"\n🔍 PREVIEW DOS PRIMEIROS {min(max_preview, len(duplicate_groups))} GRUPOS:")
        print("-" * 60)
        
        for i, (group_key, files) in enumerate(list(duplicate_groups.items())[:max_preview], 1):
            # Ordena por prioridade
            sorted_files = sorted(files, key=self.get_file_priority)
            best_file = sorted_files[0]
            
            print(f"\n📁 Grupo {i} ({group_key}):")
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
            return 0, 0
        
        # Cria pasta para duplicatas se não existir
        if not self.dry_run:
            self.duplicates_dir.mkdir(exist_ok=True)
        
        # Inicia log
        self.log_entries = [
            "=== LOG DE REMOÇÃO FINAL DE DUPLICATAS ===",
            f"Data: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            f"Pasta origem: {self.source_dir}",
            f"Modo: {'SIMULAÇÃO' if self.dry_run else 'EXECUÇÃO REAL'}",
            ""
        ]
        
        total_removed = 0
        space_saved = 0
        
        for group_num, (group_key, files) in enumerate(duplicate_groups.items(), 1):
            # Ordena por prioridade
            sorted_files = sorted(files, key=self.get_file_priority)
            best_file = sorted_files[0]
            files_to_remove = [f for f in files if f != best_file]
            
            print(f"\n🔄 Processando Grupo {group_num}/{len(duplicate_groups)}")
            print(f"  Tipo: {group_key}")
            print(f"  ✅ MANTENDO: {best_file.name}")
            
            self.log_entries.extend([
                f"Grupo {group_num} ({group_key}):",
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
                        dest_path = self.duplicates_dir / f"{stem}_final{counter}{suffix}"
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
            "=== RESUMO FINAL ===",
            f"Total de arquivos removidos: {total_removed}",
            f"Espaço economizado: {space_saved/1024/1024:.2f} MB",
            f"Pasta de duplicatas: {self.duplicates_dir if not self.dry_run else 'N/A (simulação)'}"
        ])
        
        log_file = self.source_dir.parent / "deduplication_final_log.txt"
        
        try:
            with open(log_file, 'w', encoding='utf-8') as f:
                f.write('\n'.join(self.log_entries))
            print(f"\n📝 Log salvo em: {log_file}")
        except Exception as e:
            print(f"⚠️ Erro ao salvar log: {e}")
    
    def run(self):
        """Executa o processo completo de deduplicação final"""
        print("🚀 DEDUPLICADOR FINAL MQ5")
        print("=" * 40)
        print(f"📂 Pasta: {self.source_dir}")
        print(f"🔧 Modo: {'🟡 SIMULAÇÃO' if self.dry_run else '🔴 EXECUÇÃO REAL'}")
        print("=" * 40)
        
        # 1. Escaneia arquivos
        hash_groups, name_groups = self.scan_files()
        if not hash_groups and not name_groups:
            return
        
        # 2. Identifica duplicatas
        duplicate_groups, total_duplicates = self.identify_duplicates(hash_groups, name_groups)
        if not duplicate_groups:
            print("\n✅ Nenhuma duplicata encontrada! Pasta já está limpa.")
            return
        
        # 3. Mostra preview
        self.preview_duplicates(duplicate_groups)
        
        # 4. Executa remoção
        print(f"\n{'🔄 SIMULANDO' if self.dry_run else '🗑️ EXECUTANDO'} REMOÇÃO FINAL...")
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
            print("   python deduplicator_final.py --execute")
        else:
            print(f"✅ Arquivos removidos com sucesso: {total_removed}")
            print(f"💾 Espaço economizado: {space_saved/1024/1024:.2f} MB")
            print(f"📁 Duplicatas movidas para: {self.duplicates_dir}")
        
        print("\n🎉 Limpeza final concluída!")

def main():
    """Função principal"""
    # Configurações
    source_dir = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\CODIGO_FONTE_LIBRARY\MQL5_Source\All_MQ5"
    
    # Verifica argumentos
    execute_mode = '--execute' in sys.argv or '-e' in sys.argv
    dry_run = not execute_mode
    
    # Executa deduplicação final
    deduplicator = FinalDeduplicator(source_dir, dry_run=dry_run)
    deduplicator.run()
    
    # Pausa para visualização
    input("\n⏸️ Pressione Enter para sair...")

if __name__ == "__main__":
    main()