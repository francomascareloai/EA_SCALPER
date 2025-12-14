#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Removedor Inteligente de Duplicatas
===================================

Remove duplicatas baseado no relatório do scanner rápido,
priorizando manter arquivos na LIBRARY e removendo backups desnecessários.
"""

import json
import os
import shutil
from pathlib import Path
from datetime import datetime

class SmartDuplicateRemover:
    """Removedor inteligente que usa relatório existente"""
    
    def __init__(self, base_path: str, report_path: str):
        self.base_path = Path(base_path)
        self.report_path = Path(report_path)
        self.removed_files = []
        self.space_saved = 0
        
    def load_duplicate_report(self):
        """Carrega relatório de duplicatas"""
        with open(self.report_path, 'r', encoding='utf-8') as f:
            return json.load(f)
            
    def get_file_priority(self, file_path: str) -> int:
        """Calcula prioridade do arquivo (maior = melhor para manter)"""
        path_lower = file_path.lower()
        
        # Prioridade máxima: nova estrutura organizada
        if 'library\\' in path_lower or 'main_eas\\' in path_lower:
            return 1000
        elif 'metadata\\' in path_lower:
            return 900
            
        # Média prioridade: arquivos de trabalho
        elif '03_source_code\\' in path_lower and 'backup' not in path_lower:
            return 500
            
        # Baixa prioridade: backups antigos
        elif 'backup_seguranca\\' in path_lower:
            return 100
        elif 'backup_lote\\' in path_lower:
            return 150
        elif 'backups\\' in path_lower:
            return 200
        elif 'backup_migration\\' in path_lower:
            return 50
            
        # Prioridade padrão
        return 300
        
    def choose_best_file(self, file_list):
        """Escolhe melhor arquivo para manter"""
        if len(file_list) <= 1:
            return file_list[0] if file_list else None
            
        # Calcular prioridades
        file_priorities = [(f, self.get_file_priority(f)) for f in file_list]
        file_priorities.sort(key=lambda x: x[1], reverse=True)
        
        best_file = file_priorities[0][0]
        print(f"🏆 Mantendo: {Path(best_file).name} (prioridade: {file_priorities[0][1]})")
        
        return best_file
        
    def remove_duplicates_safely(self, min_wasted_space_mb: float = 10):
        """Remove duplicatas de forma segura"""
        print("🚀 Iniciando remoção inteligente de duplicatas...")
        
        # Carregar relatório
        report = self.load_duplicate_report()
        duplicates = report.get('top_duplicates', [])
        
        if not duplicates:
            print("❌ Nenhuma duplicata encontrada no relatório!")
            return
            
        # Criar diretório de backup
        backup_dir = self.base_path / "REMOVED_DUPLICATES_SMART" / datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_dir.mkdir(parents=True, exist_ok=True)
        
        print(f"📁 Backup será salvo em: {backup_dir}")
        
        removed_count = 0
        
        for dup_group in duplicates:
            wasted_space_mb = dup_group['wasted_space'] / (1024 * 1024)
            
            # Só processar se desperdiça mais que o mínimo
            if wasted_space_mb < min_wasted_space_mb:
                continue
                
            files = dup_group['files']
            best_file = self.choose_best_file(files)
            
            if not best_file:
                continue
                
            # Remover outros arquivos
            for file_path in files:
                if file_path != best_file:
                    try:
                        file_obj = Path(file_path)
                        if not file_obj.exists():
                            continue
                            
                        # Criar estrutura de backup
                        relative_path = file_obj.relative_to(self.base_path)
                        backup_file = backup_dir / relative_path
                        backup_file.parent.mkdir(parents=True, exist_ok=True)
                        
                        # Mover para backup
                        shutil.move(str(file_obj), str(backup_file))
                        
                        file_size = backup_file.stat().st_size
                        self.space_saved += file_size
                        removed_count += 1
                        
                        self.removed_files.append({
                            "original": file_path,
                            "backup": str(backup_file),
                            "size": file_size,
                            "kept_file": best_file
                        })
                        
                        print(f"🗑️ Removido: {file_obj.name}")
                        
                    except Exception as e:
                        print(f"❌ Erro ao remover {file_path}: {e}")
                        
        print(f"\n✅ Remoção concluída!")
        print(f"🗑️ Arquivos removidos: {removed_count:,}")
        print(f"💾 Espaço economizado: {self.format_size(self.space_saved)}")
        
        # Salvar relatório de remoção
        self.save_removal_report(backup_dir)
        
    def format_size(self, size_bytes: int) -> str:
        """Formata tamanho em bytes"""
        for unit in ['B', 'KB', 'MB', 'GB']:
            if size_bytes < 1024.0:
                return f"{size_bytes:.1f} {unit}"
            size_bytes /= 1024.0
        return f"{size_bytes:.1f} TB"
        
    def save_removal_report(self, backup_dir):
        """Salva relatório de remoção"""
        report = {
            "removal_date": datetime.now().isoformat(),
            "backup_directory": str(backup_dir),
            "files_removed": len(self.removed_files),
            "space_saved_bytes": self.space_saved,
            "space_saved_formatted": self.format_size(self.space_saved),
            "removed_files": self.removed_files
        }
        
        report_file = self.base_path / "smart_removal_report.json"
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
            
        print(f"📋 Relatório salvo: {report_file}")

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description='Remove duplicatas inteligentemente')
    parser.add_argument('--min-waste', type=float, default=5.0, 
                        help='Mínimo de MB desperdiçados para processar grupo (default: 5.0)')
    parser.add_argument('--dry-run', action='store_true', 
                        help='Apenas simular, não remover arquivos')
    
    args = parser.parse_args()
    
    base_path = "c:/Users/Admin/Documents/EA_SCALPER_XAUUSD"
    report_path = f"{base_path}/fast_duplicate_scan.json"
    
    if not Path(report_path).exists():
        print("❌ Relatório de duplicatas não encontrado!")
        print("Execute primeiro: python fast_duplicate_scanner.py")
        exit(1)
    
    remover = SmartDuplicateRemover(base_path, report_path)
    
    if args.dry_run:
        print("🔍 MODO SIMULAÇÃO - Nenhum arquivo será removido")
        # Aqui você poderia adicionar lógica de simulação
    else:
        print(f"🗑️ Removendo grupos que desperdiçam ≥ {args.min_waste} MB")
        remover.remove_duplicates_safely(args.min_waste)