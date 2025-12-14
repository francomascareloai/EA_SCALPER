#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Quick Status Check and Simple Cleanup
====================================

Checks current status and performs a simplified cleanup operation.
"""

import os
import json
import shutil
from pathlib import Path
from datetime import datetime

def check_current_status():
    """Check current project status"""
    base_path = Path("c:/Users/Admin/Documents/EA_SCALPER_XAUUSD")
    
    print("📊 QUICK STATUS CHECK")
    print("="*40)
    
    # Count total files
    total_files = 0
    for root, dirs, files in os.walk(base_path):
        total_files += len(files)
    
    print(f"📁 Current total files: {total_files:,}")
    
    # Check scan results
    scan_file = base_path / "ultimate_complete_scan.json"
    if scan_file.exists():
        with open(scan_file, 'r', encoding='utf-8') as f:
            scan_data = json.load(f)
        
        print(f"🔍 Last scan found:")
        print(f"   - Unique files: {scan_data.get('total_unique_files', 0):,}")
        print(f"   - Duplicate files: {scan_data.get('duplicate_files', 0):,}")
        print(f"   - Wasted space: {scan_data.get('wasted_space_formatted', 'Unknown')}")
        print(f"   - Duplicate groups: {scan_data.get('duplicate_groups', 0):,}")
        
        return scan_data
    else:
        print("❌ No scan data found")
        return None

def quick_cleanup():
    """Perform a quick cleanup of obvious duplicates"""
    base_path = Path("c:/Users/Admin/Documents/EA_SCALPER_XAUUSD")
    
    # Load scan data
    scan_file = base_path / "ultimate_complete_scan.json"
    if not scan_file.exists():
        print("❌ No scan data available for cleanup")
        return
    
    with open(scan_file, 'r', encoding='utf-8') as f:
        scan_data = json.load(f)
    
    duplicates = scan_data.get('top_duplicates', [])
    if not duplicates:
        print("❌ No duplicate data found")
        return
    
    print(f"\n🚀 QUICK CLEANUP - Processing top {min(50, len(duplicates))} duplicate groups")
    
    # Create backup directory
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_dir = base_path / "LIMPEZA_FINAL_COMPLETA" / f"quick_cleanup_{timestamp}"
    backup_dir.mkdir(parents=True, exist_ok=True)
    
    removed_count = 0
    space_saved = 0
    
    # Process top 50 duplicate groups (largest first)
    for i, group in enumerate(duplicates[:50]):
        files = group['files']
        waste_mb = group.get('wasted_space', 0) / (1024 * 1024)
        
        if waste_mb < 5:  # Skip small duplicates
            continue
            
        print(f"📦 Group {i+1}: {waste_mb:.1f}MB - {len(files)} duplicates")
        
        # Find existing files
        existing_files = [f for f in files if Path(f).exists()]
        if len(existing_files) <= 1:
            continue
        
        # Choose best file (prioritize new structure)
        best_file = None
        best_score = -99999
        
        for file_path in existing_files:
            score = 0
            path_lower = file_path.lower()
            
            # Prioritize new structure
            if 'main_eas\\' in path_lower:
                score += 1000
            elif 'library\\' in path_lower:
                score += 800
            elif '03_source_code\\' in path_lower and 'backup' not in path_lower:
                score += 600
            
            # Penalize backups heavily
            if any(backup in path_lower for backup in [
                'backup_migration\\', 'backup_seguranca\\', 
                'advanced_cleanup\\', 'final_cleanup\\', 'limpeza_final_completa\\'
            ]):
                score -= 2000
            
            # Penalize duplicates
            filename = Path(file_path).name.lower()
            if any(dup in filename for dup in ['(1)', '(2)', '(3)', '_copy']):
                score -= 500
            
            if score > best_score:
                best_score = score
                best_file = file_path
        
        # Remove other files
        for file_path in existing_files:
            if file_path != best_file:
                try:
                    source_file = Path(file_path)
                    file_size = source_file.stat().st_size
                    
                    # Create backup
                    backup_file = backup_dir / source_file.name
                    if backup_file.exists():
                        counter = 1
                        stem = backup_file.stem
                        suffix = backup_file.suffix
                        while backup_file.exists():
                            backup_file = backup_dir / f"{stem}_dup{counter}{suffix}"
                            counter += 1
                    
                    shutil.move(str(source_file), str(backup_file))
                    removed_count += 1
                    space_saved += file_size
                    
                except Exception as e:
                    print(f"   ⚠️ Error removing {file_path}: {e}")
        
        print(f"   ✅ Kept: {Path(best_file).name}")
    
    space_saved_mb = space_saved / (1024 * 1024)
    print(f"\n✅ QUICK CLEANUP COMPLETE!")
    print(f"🗑️ Files removed: {removed_count:,}")
    print(f"💾 Space saved: {space_saved_mb:.1f} MB")
    print(f"📁 Backup: {backup_dir}")

if __name__ == "__main__":
    scan_data = check_current_status()
    if scan_data:
        quick_cleanup()