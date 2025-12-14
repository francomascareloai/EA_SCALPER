#!/usr/bin/env python3
"""
Cleanup Script for Unused Directories
This script identifies and organizes unused/legacy directories in the EA_SCALPER_XAUUSD project.
"""

import os
import shutil
import json
from datetime import datetime
from pathlib import Path

class DirectoryCleanupManager:
    def __init__(self, project_root="."):
        self.project_root = Path(project_root)
        self.orphan_root = self.project_root / "06_ARQUIVOS_ORFAOS"
        self.management_dir = self.orphan_root / "ORPHAN_MANAGEMENT"
        self.index_file = self.management_dir / "FILE_MANAGEMENT_INDEX.json"
        
        # Create management directory if it doesn't exist
        self.management_dir.mkdir(exist_ok=True)
        
        # List of directories to preserve (new organized structure)
        self.preserve_dirs = {
            "🚀 MAIN_EAS",
            "📋 METADATA",
            "📊 TRADINGVIEW",
            "🤖 AI_AGENTS",
            "📚 LIBRARY",
            "06_ARQUIVOS_ORFAOS",
            ".git",
            ".qoder"
        }
        
        # List of known legacy directories to archive
        self.known_legacy_dirs = [
            "01_Core",
            "02_Strategies", 
            "03_Source_Code",
            "04_Development",
            "05_Testing",
            "06_Integration",
            "07_Data",
            "08_Documentation",
            "09_Reports",
            "10_Configuration",
            "BACKUP_REORGANIZATION_20250823_191715",
            "BACKUP_SEGURANCA",
            "Backups",
            "CODIGO_FONTE_LIBRARY",
            "Config",
            "Core",
            "DEVELOPMENT_WORKSPACE_NEW",
            "DOCUMENTATION_NEW",
            "Datasets",
            "Demo_Tests",
            "Demo_Visual",
            "Development",
            "Documentation",
            "EA_FTMO_XAUUSD_ELITE_NEW",
            "Include",
            "MCP_Integration",
            "MQL4_Source",
            "MQL5_Source",
            "Manifests",
            "Output",
            "REPORTS_ANALYTICS_NEW",
            "Reports",
            "RiskManagement",
            "Snippets",
            "Source",
            "Strategies",
            "Strategy",
            "TESTING_VALIDATION_NEW",
            "TOOLS_AUTOMATION_NEW",
            "Temp",
            "Teste_Critico",
            "Testing",
            "Tests",
            "Tools",
            "TradingView_Scripts",
            "Utils",
            "__pycache__",
            "bmad-trading",
            "data",
            "examples",
            "logs",
            "mcp-code-checker",
            "mcp-metatrader5-server",
            "prompts",
            "TradingView_Scripts"
        ]
        
    def scan_project_directories(self):
        """Scan all directories in the project"""
        directories = []
        for item in self.project_root.iterdir():
            if item.is_dir() and item.name not in self.preserve_dirs:
                directories.append(item)
        return directories
    
    def identify_unused_directories(self):
        """Identify unused/legacy directories"""
        all_dirs = self.scan_project_directories()
        unused_dirs = []
        
        for directory in all_dirs:
            # Check if it's in the known legacy list
            if directory.name in self.known_legacy_dirs:
                unused_dirs.append(directory)
                continue
                
            # Check if directory is empty
            try:
                if not any(directory.iterdir()):
                    unused_dirs.append(directory)
                    continue
            except PermissionError:
                # Skip directories we can't read
                continue
                
            # Check if directory hasn't been modified in a long time
            try:
                mod_time = datetime.fromtimestamp(directory.stat().st_mtime)
                days_since_mod = (datetime.now() - mod_time).days
                if days_since_mod > 365:  # Over a year old
                    unused_dirs.append(directory)
            except (OSError, PermissionError):
                # Skip directories with access issues
                pass
                
        return unused_dirs
    
    def move_to_orphan_storage(self, directory_path):
        """Move directory to orphan storage for review"""
        try:
            # Create target directory in orphan storage
            target_dir = self.orphan_root / "OUT_OF_SCOPE" / "legacy_systems" / directory_path.name
            target_dir.parent.mkdir(parents=True, exist_ok=True)
            
            # Move the directory
            shutil.move(str(directory_path), str(target_dir))
            return True
        except Exception as e:
            print(f"Error moving {directory_path}: {e}")
            return False
    
    def archive_directory(self, directory_path):
        """Archive directory to backup location"""
        try:
            # Create archive directory
            archive_dir = self.orphan_root / "OUT_OF_SCOPE" / "archive_pending" / directory_path.name
            archive_dir.parent.mkdir(parents=True, exist_ok=True)
            
            # Move to archive
            shutil.move(str(directory_path), str(archive_dir))
            return True
        except Exception as e:
            print(f"Error archiving {directory_path}: {e}")
            return False
    
    def update_index(self, moved_dirs, archived_dirs):
        """Update the file management index"""
        try:
            # Load existing index or create new
            if self.index_file.exists():
                with open(self.index_file, 'r') as f:
                    index_data = json.load(f)
            else:
                index_data = {
                    "project": "EA_SCALPER_XAUUSD",
                    "orphan_directory": "06_ARQUIVOS_ORFAOS",
                    "last_update": datetime.now().isoformat(),
                    "total_files": 0,
                    "quarantined_files": 0,
                    "processed_files": 0,
                    "categories": {
                        "ex4_files": 0,
                        "locked_mq4": 0,
                        "potentially_bad": 0,
                        "duplicate_candidates": 0
                    },
                    "analysis_status": {
                        "in_progress": 0,
                        "completed": 0
                    }
                }
            
            # Update with cleanup information
            index_data["last_cleanup"] = datetime.now().isoformat()
            index_data["moved_directories"] = [str(d) for d in moved_dirs]
            index_data["archived_directories"] = [str(d) for d in archived_dirs]
            
            # Save updated index
            with open(self.index_file, 'w') as f:
                json.dump(index_data, f, indent=2)
                
        except Exception as e:
            print(f"Error updating index: {e}")
    
    def generate_cleanup_report(self, unused_dirs, moved_dirs, archived_dirs):
        """Generate a report of the cleanup operation"""
        report = {
            "timestamp": datetime.now().isoformat(),
            "total_unused_directories_found": len(unused_dirs),
            "directories_moved_to_orphan_storage": len(moved_dirs),
            "directories_archived": len(archived_dirs),
            "directories_remaining": len(unused_dirs) - len(moved_dirs) - len(archived_dirs),
            "moved_directories": [str(d) for d in moved_dirs],
            "archived_directories": [str(d) for d in archived_dirs]
        }
        
        # Save report
        report_file = self.management_dir / f"cleanup_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2)
            
        return report
    
    def execute_cleanup(self, dry_run=True):
        """Execute the cleanup process"""
        print("Starting directory cleanup process...")
        print(f"Project root: {self.project_root}")
        print(f"Dry run mode: {dry_run}")
        
        # Identify unused directories
        print("\n1. Scanning for unused directories...")
        unused_dirs = self.identify_unused_directories()
        print(f"Found {len(unused_dirs)} unused directories")
        
        # Categorize directories
        print("\n2. Categorizing directories...")
        to_move = []
        to_archive = []
        
        for directory in unused_dirs:
            # Move known legacy directories to orphan storage
            if directory.name in self.known_legacy_dirs:
                to_move.append(directory)
            else:
                # Archive others
                to_archive.append(directory)
        
        print(f"Directories to move to orphan storage: {len(to_move)}")
        print(f"Directories to archive: {len(to_archive)}")
        
        # Process moves (dry run or actual)
        moved_dirs = []
        archived_dirs = []
        
        if not dry_run:
            print("\n3. Moving directories to orphan storage...")
            for directory in to_move:
                print(f"  Moving {directory.name}...")
                if self.move_to_orphan_storage(directory):
                    moved_dirs.append(directory)
                else:
                    print(f"    Failed to move {directory.name}")
            
            print("\n4. Archiving directories...")
            for directory in to_archive:
                print(f"  Archiving {directory.name}...")
                if self.archive_directory(directory):
                    archived_dirs.append(directory)
                else:
                    print(f"    Failed to archive {directory.name}")
            
            # Update index
            print("\n5. Updating file management index...")
            self.update_index(moved_dirs, archived_dirs)
        
        # Generate report
        print("\n6. Generating cleanup report...")
        report = self.generate_cleanup_report(unused_dirs, moved_dirs, archived_dirs)
        
        print("\nCleanup Report:")
        print(f"  Unused directories found: {report['total_unused_directories_found']}")
        print(f"  Directories moved: {report['directories_moved_to_orphan_storage']}")
        print(f"  Directories archived: {report['directories_archived']}")
        print(f"  Directories remaining: {report['directories_remaining']}")
        
        if dry_run:
            print("\nDRY RUN COMPLETE - No actual changes made")
            print("Run with dry_run=False to perform actual cleanup")
        else:
            print("\nCLEANUP COMPLETE")
            report_path = self.management_dir / f"cleanup_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
            print(f"Report saved to: {report_path}")
        
        return report

def main():
    """Main function to run the cleanup process"""
    print("EA_SCALPER_XAUUSD Directory Cleanup Tool")
    print("========================================")
    
    # Initialize cleanup manager
    cleaner = DirectoryCleanupManager()
    
    # Run in dry run mode first
    print("\nRunning in DRY RUN mode to preview changes...")
    cleaner.execute_cleanup(dry_run=True)
    
    # Ask user if they want to proceed with actual cleanup
    response = input("\nDo you want to proceed with actual cleanup? (yes/no): ")
    if response.lower() in ['yes', 'y']:
        print("\nRunning actual cleanup...")
        cleaner.execute_cleanup(dry_run=False)
    else:
        print("Cleanup cancelled by user.")

if __name__ == "__main__":
    main()