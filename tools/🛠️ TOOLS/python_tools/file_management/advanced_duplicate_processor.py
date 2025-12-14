#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Processador Avançado de Duplicatas - Scanner Completo
====================================================

Processa as 3.8GB de duplicatas encontradas no escaneamento completo de 82k+ arquivos.
Inteligência aprimorada para preservar arquivos importantes e remover redundâncias.
"""

import json
import os
import shutil
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Tuple
import time

class AdvancedDuplicateProcessor:
    """Processador avançado para duplicatas do escaneamento completo"""
    
    def __init__(self, base_path: str, report_path: str):
        self.base_path = Path(base_path)
        self.report_path = Path(report_path)
        self.removed_files = []
        self.space_saved = 0
        self.processed_groups = 0
        self.skipped_groups = 0
        
    def load_complete_report(self) -> Dict:
        """Carrega relatório completo de duplicatas"""
        try:
            with open(self.report_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            print(f"❌ Erro ao carregar relatório: {e}")
            return {}
    
    def get_advanced_priority(self, file_path: str) -> int:
        """Sistema de priorização avançado (maior = melhor para manter)"""
        path_lower = file_path.lower()
        filename = Path(file_path).name.lower()
        
        # PRIORIDADE MÁXIMA: Nova estrutura organizada
        if any(dir in path_lower for dir in ['library\\', 'main_eas\\', 'metadata\\', 'workspace\\', 'tools\\', 'config\\']):
            base_score = 2000
        else:
            base_score = 500
            
        # PENALIZAÇÃO SEVERA: Múltiplos backups
        backup_penalties = 0
        if 'backup_migration\\' in path_lower:
            backup_penalties -= 1500
        if 'backup_seguranca\\' in path_lower:
            backup_penalties -= 1000  
        if 'backup_lote\\' in path_lower:
            backup_penalties -= 800
        if 'removed_duplicates' in path_lower:
            backup_penalties -= 2000
            
        # BÔNUS: Tipo de arquivo
        file_bonus = 0
        if filename.endswith(('.mq5', '.mq4')):
            file_bonus += 300  # Código fonte é prioritário
        elif filename.endswith(('.ex5', '.ex4')):
            file_bonus += 100  # Compilados são menos importantes
        elif filename.endswith('.json') and 'meta' in filename:
            file_bonus += 200  # Metadados importantes
        elif filename.endswith(('.pdf', '.txt', '.md')):
            file_bonus += 50   # Documentação
            
        # BÔNUS: Conteúdo do nome
        name_bonus = 0
        if 'ftmo' in filename:
            name_bonus += 400  # FTMO tem prioridade máxima
        elif 'elite' in filename or 'scalper' in filename:
            name_bonus += 300
        elif 'smc' in filename or 'ict' in filename:
            name_bonus += 200
        elif 'autonomous' in filename:
            name_bonus += 250
            
        # PENALIZAÇÃO: Indicadores de duplicata no nome
        duplicate_penalty = 0
        if any(dup in filename for dup in ['(1)', '(2)', '(3)', '(4)', '(5)', '(6)', '(7)', '_1', '_2', '_3', '_copy', '_backup']):
            duplicate_penalty -= 200
            
        # BÔNUS: Localização específica
        location_bonus = 0
        if 'production' in path_lower:
            location_bonus += 400
        elif 'development' in path_lower:
            location_bonus += 200
        elif '03_source_code\\' in path_lower and 'backup' not in path_lower:
            location_bonus += 150
            
        final_score = base_score + backup_penalties + file_bonus + name_bonus + duplicate_penalty + location_bonus
        return max(final_score, -2000)  # Mínimo para evitar scores muito negativos
    
    def analyze_duplicate_group(self, group: Dict) -> Tuple[str, List[str], int]:
        """Analisa grupo de duplicatas e escolhe melhor arquivo"""
        files = group['files']
        
        if len(files) <= 1:
            return files[0] if files else "", [], 0
            
        # Calcular prioridades
        file_priorities = []
        for file_path in files:
            if Path(file_path).exists():
                priority = self.get_advanced_priority(file_path)
                file_priorities.append((file_path, priority))
                
        if not file_priorities:
            return "", [], 0
            
        # Ordenar por prioridade (maior primeiro)
        file_priorities.sort(key=lambda x: x[1], reverse=True)
        
        best_file = file_priorities[0][0]
        best_priority = file_priorities[0][1]
        files_to_remove = [fp[0] for fp in file_priorities[1:]]
        
        return best_file, files_to_remove, best_priority
    
    def create_smart_backup(self) -> Path:
        """Cria diretório de backup inteligente"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_dir = self.base_path / "ADVANCED_CLEANUP" / f"removed_duplicates_{timestamp}"
        backup_dir.mkdir(parents=True, exist_ok=True)
        return backup_dir
    
    def safe_remove_file(self, file_path: str, backup_dir: Path, kept_file: str) -> bool:
        """Remove arquivo com backup seguro"""
        try:
            source_file = Path(file_path)
            if not source_file.exists():
                return False
                
            # Criar estrutura de backup preservando hierarquia
            try:
                relative_path = source_file.relative_to(self.base_path)
            except ValueError:
                # Se não conseguir criar caminho relativo, usar nome do arquivo
                relative_path = source_file.name
                
            backup_file = backup_dir / relative_path
            backup_file.parent.mkdir(parents=True, exist_ok=True)
            
            # Se arquivo já existe no backup, criar nome único
            if backup_file.exists():
                counter = 1
                while backup_file.exists():
                    stem = backup_file.stem
                    suffix = backup_file.suffix
                    backup_file = backup_file.parent / f"{stem}_dup{counter}{suffix}"
                    counter += 1
            
            # Obter tamanho antes de mover
            file_size = source_file.stat().st_size
            
            # Mover para backup
            shutil.move(str(source_file), str(backup_file))
            
            # Registrar remoção
            self.removed_files.append({
                "original_path": file_path,
                "backup_path": str(backup_file),
                "size_bytes": file_size,
                "kept_file": kept_file,
                "removal_time": datetime.now().isoformat()
            })
            
            self.space_saved += file_size
            return True
            
        except Exception as e:
            print(f"⚠️ Erro ao remover {file_path}: {e}")
            return False
    
    def process_all_duplicates(self, min_group_waste_mb: float = 5.0, max_groups: int = None):
        """Processa todas as duplicatas do relatório completo"""
        print("🚀 Iniciando processamento avançado de duplicatas...")
        print(f"💾 Meta: Processar 3.8GB de duplicatas encontradas")
        
        # Carregar relatório
        report = self.load_complete_report()
        if not report:
            print("❌ Falha ao carregar relatório!")
            return
            
        duplicates = report.get('top_duplicates', [])
        total_groups = len(duplicates)
        
        if not duplicates:
            print("❌ Nenhuma duplicata encontrada no relatório!")
            return
            
        print(f"📊 Total de grupos de duplicatas: {total_groups:,}")
        print(f"🎯 Processando grupos que desperdiçam ≥ {min_group_waste_mb} MB")
        
        # Criar backup
        backup_dir = self.create_smart_backup()
        print(f"📁 Backup será salvo em: {backup_dir}")
        
        # Processar grupos
        start_time = time.time()
        
        for i, group in enumerate(duplicates):
            if max_groups and i >= max_groups:
                break
                
            waste_mb = group['wasted_space'] / (1024 * 1024)
            
            # Filtrar por tamanho mínimo
            if waste_mb < min_group_waste_mb:
                self.skipped_groups += 1
                continue
                
            # Analisar grupo
            best_file, files_to_remove, priority = self.analyze_duplicate_group(group)
            
            if not best_file or not files_to_remove:
                self.skipped_groups += 1
                continue
                
            # Mostrar informações do grupo
            if i % 100 == 0 or waste_mb > 50:
                print(f"📦 Grupo {i+1:,}/{total_groups:,} - {waste_mb:.1f}MB - {len(files_to_remove)} arquivos")
                print(f"   🏆 Mantendo: {Path(best_file).name} (prioridade: {priority})")
                
            # Remover arquivos duplicados
            removed_in_group = 0
            for file_to_remove in files_to_remove:
                if self.safe_remove_file(file_to_remove, backup_dir, best_file):
                    removed_in_group += 1
                    
            self.processed_groups += 1
            
            # Progresso a cada 500 grupos ou grupos grandes
            if i % 500 == 0 or waste_mb > 100:
                elapsed = time.time() - start_time
                progress = ((i + 1) / total_groups) * 100
                space_saved_mb = self.space_saved / (1024 * 1024)
                print(f"⚡ Progresso: {progress:.1f}% - {space_saved_mb:.1f}MB economizados - {elapsed:.1f}s")
        
        # Relatório final
        total_time = time.time() - start_time
        self.generate_final_report(backup_dir, total_time)
    
    def generate_final_report(self, backup_dir: Path, processing_time: float):
        """Gera relatório final detalhado"""
        space_saved_mb = self.space_saved / (1024 * 1024)
        space_saved_gb = space_saved_mb / 1024
        
        print("\n" + "="*80)
        print("📊 RELATÓRIO FINAL DO PROCESSAMENTO AVANÇADO")
        print("="*80)
        print(f"⏱️ Tempo de processamento: {processing_time:.1f} segundos")
        print(f"📦 Grupos processados: {self.processed_groups:,}")
        print(f"⏭️ Grupos ignorados: {self.skipped_groups:,}")
        print(f"🗑️ Arquivos removidos: {len(self.removed_files):,}")
        print(f"💾 Espaço economizado: {space_saved_gb:.2f} GB ({space_saved_mb:.1f} MB)")
        print(f"📁 Backup localizado em: {backup_dir}")
        print("="*80)
        
        # Salvar relatório JSON
        report = {
            "processing_date": datetime.now().isoformat(),
            "processing_time_seconds": processing_time,
            "backup_directory": str(backup_dir),
            "groups_processed": self.processed_groups,
            "groups_skipped": self.skipped_groups,
            "files_removed": len(self.removed_files),
            "space_saved_bytes": self.space_saved,
            "space_saved_mb": space_saved_mb,
            "space_saved_gb": space_saved_gb,
            "removed_files_details": self.removed_files[:1000],  # Primeiros 1000 para não ficar muito grande
            "summary": {
                "efficiency": f"{(self.processed_groups / (self.processed_groups + self.skipped_groups) * 100):.1f}%",
                "avg_space_per_file": self.space_saved / len(self.removed_files) if self.removed_files else 0
            }
        }
        
        report_file = self.base_path / "advanced_cleanup_report.json"
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
            
        print(f"📋 Relatório detalhado salvo: {report_file}")
        
        # Top 10 maiores economias
        if self.removed_files:
            print("\n🏆 TOP 10 MAIORES ECONOMIAS:")
            sorted_files = sorted(self.removed_files, key=lambda x: x['size_bytes'], reverse=True)[:10]
            for i, file_info in enumerate(sorted_files, 1):
                size_mb = file_info['size_bytes'] / (1024 * 1024)
                filename = Path(file_info['original_path']).name
                print(f"   {i:2d}. {filename:<50} - {size_mb:7.1f} MB")
    
    def format_size(self, size_bytes: int) -> str:
        """Formata tamanho em bytes"""
        for unit in ['B', 'KB', 'MB', 'GB']:
            if size_bytes < 1024.0:
                return f"{size_bytes:.1f} {unit}"
            size_bytes /= 1024.0
        return f"{size_bytes:.1f} TB"

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description='Processador avançado de duplicatas')
    parser.add_argument('--min-waste', type=float, default=2.0, 
                        help='Mínimo de MB desperdiçados por grupo (default: 2.0)')
    parser.add_argument('--max-groups', type=int, 
                        help='Máximo de grupos para processar (para testes)')
    parser.add_argument('--aggressive', action='store_true',
                        help='Modo agressivo: processa grupos menores (min 0.5MB)')
    
    args = parser.parse_args()
    
    base_path = "c:/Users/Admin/Documents/EA_SCALPER_XAUUSD"
    report_path = f"{base_path}/complete_duplicate_scan.json"
    
    if not Path(report_path).exists():
        print("❌ Relatório completo não encontrado!")
        print("Execute primeiro: python complete_file_scanner.py")
        exit(1)
    
    # Ajustar limite baseado no modo
    min_waste = 0.5 if args.aggressive else args.min_waste
    
    processor = AdvancedDuplicateProcessor(base_path, report_path)
    
    print(f"🎯 Processando grupos com ≥ {min_waste} MB desperdiçados")
    if args.max_groups:
        print(f"🔢 Limitado a {args.max_groups} grupos (modo teste)")
    
    processor.process_all_duplicates(
        min_group_waste_mb=min_waste,
        max_groups=args.max_groups
    )