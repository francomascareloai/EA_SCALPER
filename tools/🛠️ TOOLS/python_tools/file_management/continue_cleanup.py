#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Continue Comprehensive Cleanup
==============================

Continues the comprehensive cleanup process from where it was interrupted,
processing remaining duplicates from the ultimate scan results.
"""

import os
import json
import shutil
from pathlib import Path
from datetime import datetime
import time

class CleanupContinuation:
    """Continues the comprehensive cleanup process"""
    
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.removed_files = []
        self.space_saved = 0
        self.processed_groups = 0
        
    def load_ultimate_scan(self) -> dict:
        """Load the ultimate scan results"""
        scan_file = self.base_path / "ultimate_complete_scan.json"
        if not scan_file.exists():
            print("❌ Ultimate scan file not found!")
            return {}
            
        with open(scan_file, 'r', encoding='utf-8') as f:
            return json.load(f)
    
    def get_file_priority(self, file_path: str) -> int:
        """Calculate file priority for keeping vs removing"""
        path_lower = file_path.lower()
        filename = Path(file_path).name.lower()
        
        # HIGHEST PRIORITY: New organized structure
        if 'main_eas\\production' in path_lower and 'ftmo' in filename:
            return 10000
        elif 'library\\mql5_components' in path_lower:
            return 8000
        elif 'library\\mql4_components' in path_lower:
            return 7000
        elif 'main_eas\\' in path_lower:
            return 6000
        elif 'metadata\\' in path_lower:
            return 5000
        elif 'workspace\\' in path_lower:
            return 4000
        elif '03_source_code\\' in path_lower and 'backup' not in path_lower:
            return 3000
        
        # MASSIVE PENALTIES: Things to remove aggressively
        penalties = 0
        
        # Backup directories
        if any(backup in path_lower for backup in [
            'backup_migration\\', 'backup_seguranca\\', 'advanced_cleanup\\',
            'final_cleanup\\', 'removed_duplicates', 'limpeza_final_completa\\'
        ]):
            penalties -= 5000
        
        # Python cache
        if '.venv\\' in path_lower or '__pycache__' in path_lower:
            penalties -= 7000
            
        # Duplicate indicators
        if any(dup in filename for dup in ['(1)', '(2)', '(3)', '_copy', '_backup']):
            penalties -= 1000
            
        return 1000 + penalties
    
    def choose_best_file(self, file_list: list) -> tuple:
        """Choose the best file to keep from duplicates"""
        existing_files = [f for f in file_list if Path(f).exists()]
        if len(existing_files) <= 1:
            return existing_files[0] if existing_files else "", []
            
        # Score all files
        scored_files = [(f, self.get_file_priority(f)) for f in existing_files]
        scored_files.sort(key=lambda x: x[1], reverse=True)
        
        best_file = scored_files[0][0]
        files_to_remove = [f[0] for f in scored_files[1:]]
        
        return best_file, files_to_remove
    
    def create_backup_dir(self) -> Path:
        """Create backup directory for removed files"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_dir = self.base_path / "LIMPEZA_FINAL_COMPLETA" / f"continuacao_limpeza_{timestamp}"
        backup_dir.mkdir(parents=True, exist_ok=True)
        return backup_dir
    
    def safe_remove_file(self, file_path: str, backup_dir: Path, kept_file: str) -> bool:
        """Safely remove a file with backup"""
        try:
            source_file = Path(file_path)
            if not source_file.exists():
                return False
                
            # Determine category for backup organization
            path_str = str(source_file).lower()
            if 'backup' in path_str:
                category = "backup_files"
            elif '.venv' in path_str or '__pycache__' in path_str:
                category = "python_cache"
            elif source_file.suffix.lower() in ['.mq4', '.mq5']:
                category = "mql_files"
            elif source_file.suffix.lower() == '.json':
                category = "json_metadata"
            else:
                category = "other_files"
                
            # Create backup path
            backup_subdir = backup_dir / category
            backup_subdir.mkdir(exist_ok=True)
            
            backup_file = backup_subdir / source_file.name
            if backup_file.exists():
                counter = 1
                stem = backup_file.stem
                suffix = backup_file.suffix
                while backup_file.exists():
                    backup_file = backup_subdir / f"{stem}_dup{counter}{suffix}"
                    counter += 1
            
            # Move file and record
            file_size = source_file.stat().st_size
            shutil.move(str(source_file), str(backup_file))
            
            self.removed_files.append({
                "original_path": file_path,
                "backup_path": str(backup_file),
                "size_bytes": file_size,
                "kept_file": kept_file,
                "category": category
            })
            
            self.space_saved += file_size
            return True
            
        except Exception as e:
            print(f"⚠️ Error removing {file_path}: {e}")
            return False
    
    def continue_cleanup(self):
        """Continue the comprehensive cleanup process"""
        print("🚀 CONTINUING COMPREHENSIVE CLEANUP")
        print("="*50)
        
        # Load scan data
        scan_data = self.load_ultimate_scan()
        if not scan_data:
            return
            
        duplicates = scan_data.get('top_duplicates', [])
        if not duplicates:
            print("❌ No duplicate data found!")
            return
            
        print(f"📊 Found {len(duplicates)} duplicate groups to process")
        print(f"💾 Estimated space to save: {scan_data.get('wasted_space_formatted', 'Unknown')}")
        
        # Create backup directory
        backup_dir = self.create_backup_dir()
        print(f"📁 Backup directory: {backup_dir}")
        
        # Process duplicates
        start_time = time.time()
        
        for i, group in enumerate(duplicates):
            files = group['files']
            waste_kb = group.get('wasted_space', 0) / 1024
            
            # Skip very small duplicates
            if waste_kb < 100:  # Less than 100KB wasted
                continue
                
            best_file, files_to_remove = self.choose_best_file(files)
            if not best_file or not files_to_remove:
                continue
                
            # Remove duplicates
            removed_count = 0
            for file_to_remove in files_to_remove:
                if self.safe_remove_file(file_to_remove, backup_dir, best_file):
                    removed_count += 1
                    
            if removed_count > 0:
                self.processed_groups += 1
                
            # Progress update every 500 groups
            if (i + 1) % 500 == 0:
                elapsed = time.time() - start_time
                space_saved_mb = self.space_saved / (1024 * 1024)
                print(f"📊 Progress: {i+1}/{len(duplicates)} groups - "
                      f"{space_saved_mb:.1f}MB saved - {elapsed:.1f}s")
        
        # Final report
        self.generate_final_report(backup_dir, time.time() - start_time)
    
    def generate_final_report(self, backup_dir: Path, processing_time: float):
        """Generate final cleanup report"""
        space_saved_gb = self.space_saved / (1024**3)
        space_saved_mb = self.space_saved / (1024**2)
        
        print("\n" + "="*60)
        print("📊 CONTINUATION CLEANUP COMPLETE!")
        print("="*60)
        print(f"⏱️ Processing time: {processing_time:.1f} seconds")
        print(f"📦 Groups processed: {self.processed_groups:,}")
        print(f"🗑️ Files removed: {len(self.removed_files):,}")
        print(f"💾 Space saved: {space_saved_gb:.3f} GB ({space_saved_mb:.1f} MB)")
        print(f"📁 Backup location: {backup_dir}")
        
        # Count by category
        category_counts = {}
        for file_info in self.removed_files:
            category = file_info['category']
            if category not in category_counts:
                category_counts[category] = {'count': 0, 'size': 0}
            category_counts[category]['count'] += 1
            category_counts[category]['size'] += file_info['size_bytes']
        
        print("\n📊 REMOVED FILES BY CATEGORY:")
        for category, stats in sorted(category_counts.items(), key=lambda x: x[1]['size'], reverse=True):
            size_mb = stats['size'] / (1024**2)
            print(f"   📂 {category:<20}: {stats['count']:>6,} files - {size_mb:>8.1f} MB")
        
        # Save report
        report = {
            "cleanup_date": datetime.now().isoformat(),
            "processing_time_seconds": processing_time,
            "backup_directory": str(backup_dir),
            "groups_processed": self.processed_groups,
            "files_removed": len(self.removed_files),
            "space_saved_bytes": self.space_saved,
            "space_saved_gb": space_saved_gb,
            "category_statistics": category_counts,
            "removed_files_sample": self.removed_files[:1000]
        }
        
        report_file = self.base_path / "continuation_cleanup_report.json"
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
            
        print(f"📋 Detailed report saved: {report_file}")
        print("="*60)

if __name__ == "__main__":
    cleaner = CleanupContinuation("c:/Users/Admin/Documents/EA_SCALPER_XAUUSD")
    cleaner.continue_cleanup()