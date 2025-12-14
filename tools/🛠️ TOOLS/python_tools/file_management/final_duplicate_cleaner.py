#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Limpeza Final Agressiva de Duplicatas
===================================

Processa TODAS as duplicatas restantes (3.6GB) com critérios mais agressivos
para finalizar a limpeza completa do projeto.
"""

import json
import os
import shutil
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Tuple
import time

class FinalDuplicateCleaner:
    """Limpador final agressivo para remover todas as duplicatas restantes"""
    
    def __init__(self, base_path: str, report_path: str):
        self.base_path = Path(base_path)
        self.report_path = Path(report_path)
        self.removed_files = []
        self.space_saved = 0
        self.processed_groups = 0
        self.skipped_groups = 0
        
    def load_scan_report(self) -> Dict:
        """Carrega relatório do scanner rápido"""
        try:
            with open(self.report_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            print(f"❌ Erro ao carregar relatório: {e}")
            return {}
    
    def get_ultra_priority(self, file_path: str) -> int:
        """Sistema de priorização ultra-agressivo"""
        path_lower = file_path.lower()
        filename = Path(file_path).name.lower()
        
        # PRIORIDADE MÁXIMA: Nova estrutura organizada
        if any(dir in path_lower for dir in ['main_eas\\production', 'library\\mql5_components\\eas\\ftmo_ready']):
            return 5000  # Arquivos FTMO na estrutura nova
        elif any(dir in path_lower for dir in ['library\\', 'main_eas\\', 'metadata\\', 'workspace\\', 'tools\\', 'config\\']):
            return 3000  # Nova estrutura organizada
        elif '03_source_code\\' in path_lower and 'backup' not in path_lower:
            return 1000  # Código fonte original
        else:
            return 500    # Outros arquivos
            
        # PENALIZAÇÃO SEVERA: Todos os tipos de backup
        backup_penalties = 0
        backup_dirs = [
            'backup_migration\\', 'backup_seguranca\\', 'backup_lote\\', 
            'removed_duplicates', 'advanced_cleanup\\', 'backups\\',
            'all_mq4_backup', 'backup_', '_backup'
        ]
        
        for backup_dir in backup_dirs:
            if backup_dir in path_lower:
                backup_penalties -= 2000
                break
                
        # BÔNUS: Tipo de arquivo e conteúdo
        file_bonus = 0
        if 'ftmo' in filename:
            file_bonus += 500
        elif 'elite' in filename or 'scalper' in filename:
            file_bonus += 300
        elif 'autonomous' in filename:
            file_bonus += 250
        elif filename.endswith(('.mq5', '.mq4')):
            file_bonus += 200
        elif filename.endswith('.json') and 'meta' in filename:
            file_bonus += 150
            
        # PENALIZAÇÃO: Indicadores de duplicata
        duplicate_penalty = 0
        duplicate_indicators = [
            '(1)', '(2)', '(3)', '(4)', '(5)', '(6)', '(7)', '(8)', '(9)',
            '_1', '_2', '_3', '_4', '_5', '_copy', '_backup', '_dup'
        ]
        for indicator in duplicate_indicators:
            if indicator in filename:
                duplicate_penalty -= 300
                break
                
        # BÔNUS: Localização específica
        location_bonus = 0
        if 'production' in path_lower:
            location_bonus += 400
        elif 'development' in path_lower:
            location_bonus += 200
        elif 'ftmo_ready' in path_lower:
            location_bonus += 300
            
        final_score = 3000 + backup_penalties + file_bonus + duplicate_penalty + location_bonus
        return max(final_score, -3000)  # Permitir scores muito negativos para backups
    
    def choose_best_file_aggressive(self, file_list: List[str]) -> Tuple[str, List[str]]:
        """Escolhe o melhor arquivo de forma agressiva"""
        if len(file_list) <= 1:
            return (file_list[0] if file_list else "", [])
            
        # Calcular prioridades para arquivos existentes
        file_priorities = []
        for file_path in file_list:
            if Path(file_path).exists():
                priority = self.get_ultra_priority(file_path)
                file_priorities.append((file_path, priority))
                
        if not file_priorities:
            return ("", [])
            
        # Ordenar por prioridade
        file_priorities.sort(key=lambda x: x[1], reverse=True)
        
        best_file = file_priorities[0][0]
        best_priority = file_priorities[0][1]
        files_to_remove = [fp[0] for fp in file_priorities[1:]]
        
        return best_file, files_to_remove
    
    def create_final_backup(self) -> Path:
        """Cria diretório de backup final"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_dir = self.base_path / "FINAL_CLEANUP" / f"final_duplicates_removed_{timestamp}"
        backup_dir.mkdir(parents=True, exist_ok=True)
        return backup_dir
    
    def safe_remove_duplicate(self, file_path: str, backup_dir: Path, kept_file: str) -> bool:
        """Remove duplicata com backup seguro"""
        try:
            source_file = Path(file_path)
            if not source_file.exists():
                return False
                
            # Criar backup com estrutura simplificada
            filename = source_file.name
            
            # Identificar origem para organizar backup
            path_parts = source_file.parts
            origin = "unknown"
            if "backup_migration" in path_parts:
                origin = "backup_migration"
            elif "backup_seguranca" in path_parts:
                origin = "backup_seguranca"
            elif "library" in path_parts:
                origin = "library_duplicates"
            elif "03_source_code" in path_parts:
                origin = "source_code_duplicates"
            else:
                origin = "other_duplicates"
                
            backup_subdir = backup_dir / origin
            backup_subdir.mkdir(exist_ok=True)
            
            backup_file = backup_subdir / filename
            
            # Se arquivo já existe no backup, criar nome único
            if backup_file.exists():
                counter = 1
                stem = backup_file.stem
                suffix = backup_file.suffix
                while backup_file.exists():
                    backup_file = backup_subdir / f"{stem}_dup{counter}{suffix}"
                    counter += 1
            
            # Obter tamanho e mover
            file_size = source_file.stat().st_size
            shutil.move(str(source_file), str(backup_file))
            
            # Registrar
            self.removed_files.append({
                "original_path": file_path,
                "backup_path": str(backup_file),
                "size_bytes": file_size,
                "kept_file": kept_file,
                "origin": origin,
                "removal_time": datetime.now().isoformat()
            })
            
            self.space_saved += file_size
            return True
            
        except Exception as e:
            print(f"⚠️ Erro ao remover {file_path}: {e}")
            return False
    
    def process_all_remaining_duplicates(self, min_group_waste_kb: float = 100):
        """Processa TODAS as duplicatas restantes"""
        print("🚀 Iniciando LIMPEZA FINAL AGRESSIVA de duplicatas...")
        print(f"💾 Meta: Limpar os 3.6GB restantes de duplicatas")
        
        # Carregar relatório do scanner
        report = self.load_scan_report()
        if not report:
            print("❌ Falha ao carregar relatório!")
            return
            
        duplicates = report.get('top_duplicates', [])
        total_groups = len(duplicates)
        
        if not duplicates:
            print("❌ Nenhuma duplicata encontrada no relatório!")
            return
            
        print(f"📊 Total de grupos de duplicatas: {total_groups:,}")
        print(f"🎯 Processando grupos que desperdiçam ≥ {min_group_waste_kb} KB")
        
        # Criar backup
        backup_dir = self.create_final_backup()
        print(f"📁 Backup final será salvo em: {backup_dir}")
        
        # Processar todos os grupos
        start_time = time.time()
        
        for i, group in enumerate(duplicates):
            waste_kb = group['wasted_space'] / 1024
            
            # Filtrar apenas por tamanho mínimo muito baixo
            if waste_kb < min_group_waste_kb:
                self.skipped_groups += 1
                continue
                
            # Processar grupo
            files = group['files']
            best_file, files_to_remove = self.choose_best_file_aggressive(files)
            
            if not best_file or not files_to_remove:
                self.skipped_groups += 1
                continue
                
            # Mostrar progresso a cada 1000 grupos ou grupos grandes
            if i % 1000 == 0 or waste_kb > 10000:  # >10MB
                waste_mb = waste_kb / 1024
                print(f"📦 Grupo {i+1:,}/{total_groups:,} - {waste_mb:.1f}MB - {len(files_to_remove)} duplicatas")
                best_name = Path(best_file).name
                print(f"   🏆 Mantendo: {best_name}")
                
            # Remover duplicatas
            removed_in_group = 0
            for file_to_remove in files_to_remove:
                if self.safe_remove_duplicate(file_to_remove, backup_dir, best_file):
                    removed_in_group += 1
                    
            self.processed_groups += 1
            
            # Progresso a cada 2000 grupos
            if i % 2000 == 0:
                elapsed = time.time() - start_time
                progress = ((i + 1) / total_groups) * 100
                space_saved_gb = self.space_saved / (1024**3)
                print(f"⚡ Progresso: {progress:.1f}% - {space_saved_gb:.2f}GB economizados - {elapsed:.1f}s")
        
        # Relatório final
        total_time = time.time() - start_time
        self.generate_final_cleanup_report(backup_dir, total_time)
    
    def generate_final_cleanup_report(self, backup_dir: Path, processing_time: float):
        """Gera relatório final da limpeza completa"""
        space_saved_gb = self.space_saved / (1024**3)
        space_saved_mb = self.space_saved / (1024**2)
        
        # Contar por origem
        origin_stats = {}
        for file_info in self.removed_files:
            origin = file_info['origin']
            if origin not in origin_stats:
                origin_stats[origin] = {'count': 0, 'size': 0}
            origin_stats[origin]['count'] += 1
            origin_stats[origin]['size'] += file_info['size_bytes']
        
        print("\n" + "="*90)
        print("📊 RELATÓRIO FINAL DA LIMPEZA COMPLETA DE DUPLICATAS")
        print("="*90)
        print(f"⏱️ Tempo de processamento: {processing_time:.1f} segundos")
        print(f"📦 Grupos processados: {self.processed_groups:,}")
        print(f"⏭️ Grupos ignorados: {self.skipped_groups:,}")
        print(f"🗑️ Arquivos removidos: {len(self.removed_files):,}")
        print(f"💾 Espaço economizado: {space_saved_gb:.3f} GB ({space_saved_mb:.1f} MB)")
        print(f"📁 Backup localizado em: {backup_dir}")
        print()
        print("📊 DISTRIBUIÇÃO POR ORIGEM:")
        for origin, stats in sorted(origin_stats.items(), key=lambda x: x[1]['size'], reverse=True):
            origin_gb = stats['size'] / (1024**3)
            print(f"   📂 {origin:<25}: {stats['count']:>6,} arquivos - {origin_gb:>6.2f} GB")
        print("="*90)
        
        # Salvar relatório JSON
        report = {
            "cleanup_date": datetime.now().isoformat(),
            "processing_time_seconds": processing_time,
            "backup_directory": str(backup_dir),
            "groups_processed": self.processed_groups,
            "groups_skipped": self.skipped_groups,
            "files_removed": len(self.removed_files),
            "space_saved_bytes": self.space_saved,
            "space_saved_gb": space_saved_gb,
            "origin_statistics": origin_stats,
            "removed_files_sample": self.removed_files[:500],  # Amostra para não ficar muito grande
            "summary": {
                "total_processing_efficiency": f"{(self.processed_groups / (self.processed_groups + self.skipped_groups) * 100):.1f}%",
                "average_file_size": self.space_saved / len(self.removed_files) if self.removed_files else 0,
                "processing_speed": len(self.removed_files) / processing_time if processing_time > 0 else 0
            }
        }
        
        report_file = self.base_path / "final_cleanup_report.json"
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
            
        print(f"📋 Relatório completo salvo: {report_file}")
    
    def format_size(self, size_bytes: int) -> str:
        """Formata tamanho em bytes"""
        for unit in ['B', 'KB', 'MB', 'GB']:
            if size_bytes < 1024.0:
                return f"{size_bytes:.1f} {unit}"
            size_bytes /= 1024.0
        return f"{size_bytes:.1f} TB"

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description='Limpeza final agressiva de duplicatas')
    parser.add_argument('--min-waste-kb', type=float, default=50, 
                        help='Mínimo de KB desperdiçados por grupo (default: 50)')
    parser.add_argument('--ultra-aggressive', action='store_true',
                        help='Modo ultra-agressivo: processa grupos de 10KB+')
    
    args = parser.parse_args()
    
    base_path = "c:/Users/Admin/Documents/EA_SCALPER_XAUUSD"
    report_path = f"{base_path}/fast_duplicate_scan.json"
    
    if not Path(report_path).exists():
        print("❌ Relatório de duplicatas não encontrado!")
        print("Execute primeiro: python fast_duplicate_scanner.py")
        exit(1)
    
    # Ajustar limite baseado no modo
    min_waste_kb = 10 if args.ultra_aggressive else args.min_waste_kb
    
    cleaner = FinalDuplicateCleaner(base_path, report_path)
    
    print(f"🎯 Limpeza final: processando grupos com ≥ {min_waste_kb} KB desperdiçados")
    if args.ultra_aggressive:
        print("⚡ MODO ULTRA-AGRESSIVO ATIVADO")
    
    cleaner.process_all_remaining_duplicates(min_group_waste_kb=min_waste_kb)