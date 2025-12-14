"""
Metadata Organizer for EA_SCALPER_XAUUSD
Organizes metadata files according to the optimized structure
"""
import os
import json
import shutil
from pathlib import Path
from datetime import datetime

class MetadataOrganizer:
    def __init__(self, metadata_root="Metadata", organized_root="📋 METADATA"):
        self.metadata_root = metadata_root
        self.organized_root = organized_root
        self.max_files_per_dir = 500
        
    def organize_by_performance(self):
        """Organize metadata by performance scores"""
        print("Organizing metadata by performance...")
        
        # Create performance directories
        performance_dirs = {
            "elite_performers": (8.0, 10.0),
            "good_performers": (6.0, 8.0),
            "average_performers": (4.0, 6.0),
            "poor_performers": (2.0, 4.0),
            "experimental": (0.0, 2.0)
        }
        
        for dir_name, (min_score, max_score) in performance_dirs.items():
            dir_path = Path(self.organized_root) / "EA_METADATA" / "by_performance" / dir_name
            dir_path.mkdir(parents=True, exist_ok=True)
            
        # Process metadata files
        organized_count = 0
        for file_path in Path(self.metadata_root).glob("*.json"):
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    metadata = json.load(f)
                    
                # Get performance score
                ftmo_score = metadata.get("ftmo_score", 0)
                quality_score = metadata.get("quality_score", 0) or metadata.get("qualidade_codigo", 0)
                
                # Calculate composite score
                composite_score = (ftmo_score + quality_score) / 2 if ftmo_score and quality_score else 0
                
                # Determine directory based on score
                target_dir = None
                for dir_name, (min_score, max_score) in performance_dirs.items():
                    if min_score <= composite_score < max_score:
                        target_dir = dir_name
                        break
                        
                if target_dir:
                    # Copy file to appropriate directory
                    target_path = Path(self.organized_root) / "EA_METADATA" / "by_performance" / target_dir / file_path.name
                    shutil.copy2(file_path, target_path)
                    organized_count += 1
                    
            except Exception as e:
                print(f"Error processing {file_path}: {e}")
                
        print(f"Organized {organized_count} metadata files by performance")
        
    def organize_by_strategy(self):
        """Organize metadata by strategy type"""
        print("Organizing metadata by strategy...")
        
        # Create strategy directories
        strategy_dirs = [
            "ftmo_compliant",
            "scalping",
            "grid_systems",
            "trend_following",
            "smc_ict",
            "news_trading",
            "ai_driven"
        ]
        
        for dir_name in strategy_dirs:
            dir_path = Path(self.organized_root) / "EA_METADATA" / "by_strategy" / dir_name
            dir_path.mkdir(parents=True, exist_ok=True)
            
        # Process metadata files
        organized_count = 0
        for file_path in Path(self.organized_root) / "EA_METADATA" / "by_performance" / "**" / "*.json":
            if not file_path.exists():
                continue
                
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    metadata = json.load(f)
                    
                # Get strategy information
                strategies = metadata.get("classification", {}).get("strategy", [])
                ftmo_ready = metadata.get("classification", {}).get("ftmo_ready", False)
                
                # Determine target directory
                target_dir = None
                if ftmo_ready:
                    target_dir = "ftmo_compliant"
                elif strategies:
                    # Map strategy to directory
                    strategy_map = {
                        "Scalping": "scalping",
                        "Grid": "grid_systems",
                        "Martingale": "grid_systems",
                        "Trend Following": "trend_following",
                        "SMC": "smc_ict",
                        "ICT": "smc_ict",
                        "News Trading": "news_trading",
                        "AI": "ai_driven"
                    }
                    
                    for strategy in strategies:
                        if strategy in strategy_map:
                            target_dir = strategy_map[strategy]
                            break
                            
                if target_dir:
                    # Copy file to appropriate directory
                    target_path = Path(self.organized_root) / "EA_METADATA" / "by_strategy" / target_dir / file_path.name
                    if not target_path.exists():  # Avoid duplicates
                        shutil.copy2(file_path, target_path)
                        organized_count += 1
                        
            except Exception as e:
                print(f"Error processing {file_path}: {e}")
                
        print(f"Organized {organized_count} metadata files by strategy")
        
    def organize_by_timeframe(self):
        """Organize metadata by timeframe"""
        print("Organizing metadata by timeframe...")
        
        # Create timeframe directories
        timeframe_dirs = [
            "m1_scalping",
            "m5_entries",
            "h1_swing",
            "multi_timeframe"
        ]
        
        for dir_name in timeframe_dirs:
            dir_path = Path(self.organized_root) / "EA_METADATA" / "by_timeframe" / dir_name
            dir_path.mkdir(parents=True, exist_ok=True)
            
        # Process metadata files
        organized_count = 0
        for file_path in Path(self.organized_root) / "EA_METADATA" / "by_strategy" / "**" / "*.json":
            if not file_path.exists():
                continue
                
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    metadata = json.load(f)
                    
                # Get timeframe information
                timeframes = metadata.get("timeframe", [])
                
                # Determine target directory
                target_dir = None
                if "M1" in timeframes:
                    target_dir = "m1_scalping"
                elif "M5" in timeframes:
                    target_dir = "m5_entries"
                elif "H1" in timeframes:
                    target_dir = "h1_swing"
                elif len(timeframes) > 1:
                    target_dir = "multi_timeframe"
                    
                if target_dir:
                    # Copy file to appropriate directory
                    target_path = Path(self.organized_root) / "EA_METADATA" / "by_timeframe" / target_dir / file_path.name
                    if not target_path.exists():  # Avoid duplicates
                        shutil.copy2(file_path, target_path)
                        organized_count += 1
                        
            except Exception as e:
                print(f"Error processing {file_path}: {e}")
                
        print(f"Organized {organized_count} metadata files by timeframe")
        
    def organize_by_status(self):
        """Organize metadata by development status"""
        print("Organizing metadata by status...")
        
        # Create status directories
        status_dirs = [
            "production_ready",
            "beta_testing",
            "alpha_development",
            "archived",
            "deprecated"
        ]
        
        for dir_name in status_dirs:
            dir_path = Path(self.organized_root) / "EA_METADATA" / "by_status" / dir_name
            dir_path.mkdir(parents=True, exist_ok=True)
            
        # Process metadata files
        organized_count = 0
        for file_path in Path(self.organized_root) / "EA_METADATA" / "by_timeframe" / "**" / "*.json":
            if not file_path.exists():
                continue
                
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    metadata = json.load(f)
                    
                # Get status information
                status = metadata.get("status", "alpha_development").lower()
                
                # Map status to directory
                status_map = {
                    "production": "production_ready",
                    "prod": "production_ready",
                    "beta": "beta_testing",
                    "testing": "beta_testing",
                    "alpha": "alpha_development",
                    "development": "alpha_development",
                    "archived": "archived",
                    "deprecated": "deprecated"
                }
                
                target_dir = status_map.get(status, "alpha_development")
                
                # Copy file to appropriate directory
                target_path = Path(self.organized_root) / "EA_METADATA" / "by_status" / target_dir / file_path.name
                if not target_path.exists():  # Avoid duplicates
                    shutil.copy2(file_path, target_path)
                    organized_count += 1
                    
            except Exception as e:
                print(f"Error processing {file_path}: {e}")
                
        print(f"Organized {organized_count} metadata files by status")
        
    def create_index_files(self):
        """Create index files for organized directories"""
        print("Creating index files...")
        
        # Create main metadata index
        index_data = {
            "project": "EA_SCALPER_XAUUSD",
            "last_update": datetime.now().isoformat(),
            "organization": {
                "by_performance": {},
                "by_strategy": {},
                "by_timeframe": {},
                "by_status": {}
            }
        }
        
        # Count files in each category
        for category in ["by_performance", "by_strategy", "by_timeframe", "by_status"]:
            category_path = Path(self.organized_root) / "EA_METADATA" / category
            if category_path.exists():
                for subdir in category_path.iterdir():
                    if subdir.is_dir():
                        file_count = len(list(subdir.glob("*.json")))
                        index_data["organization"][category][subdir.name] = {
                            "path": str(subdir.relative_to(self.organized_root)),
                            "file_count": file_count
                        }
        
        # Save index file
        index_path = Path(self.organized_root) / "METADATA_MASTER_INDEX.json"
        with open(index_path, 'w', encoding='utf-8') as f:
            json.dump(index_data, f, indent=2, ensure_ascii=False)
            
        print(f"Metadata index created at {index_path}")
        
    def run_organization(self):
        """Run complete metadata organization process"""
        print("Starting metadata organization...")
        
        # Create organized root directory
        Path(self.organized_root).mkdir(exist_ok=True)
        
        # Run organization steps
        self.organize_by_performance()
        self.organize_by_strategy()
        self.organize_by_timeframe()
        self.organize_by_status()
        self.create_index_files()
        
        print("Metadata organization completed!")

# Example usage
if __name__ == "__main__":
    organizer = MetadataOrganizer()
    organizer.run_organization()