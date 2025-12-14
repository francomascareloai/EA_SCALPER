"""
Metadata Classifier for EA_SCALPER_XAUUSD
Classifies metadata files to identify top performers and organize them
"""
import os
import json
import shutil
from pathlib import Path
from datetime import datetime

class MetadataClassifier:
    def __init__(self, organized_root="📋 METADATA"):
        self.organized_root = organized_root
        self.premium_robots_dir = Path(organized_root) / "PREMIUM_ROBOTS"
        
    def calculate_composite_score(self, metadata):
        """Calculate composite score for classification"""
        ftmo_score = metadata.get("ftmo_score", 0)
        quality_score = metadata.get("quality_score", 0) or metadata.get("qualidade_codigo", 0)
        strategy = metadata.get("strategy", "") or metadata.get("estrategia", "")
        market = metadata.get("market", "") or metadata.get("mercado", "")
        
        # Weights for each criterion
        ftmo_weight = 0.4
        quality_weight = 0.3
        strategy_weight = 0.2
        market_weight = 0.1
        
        # Calculate strategy score
        strategy_score = 10 if "SMC" in strategy or "ICT" in strategy else \
                         9 if "Scalping" in strategy else \
                         8 if "Trend" in strategy else \
                         7 if "Price Action" in strategy else 5
        
        # Calculate market score
        market_score = 10 if "XAUUSD" in market else \
                       9 if "MULTI" in market else \
                       8 if "FOREX" in market else 7
        
        # Calculate composite score
        composite_score = (ftmo_score * ftmo_weight + 
                          quality_score * quality_weight + 
                          strategy_score * strategy_weight + 
                          market_score * market_weight)
        
        return composite_score
        
    def identify_top_performers(self, min_score=8.0):
        """Identify top performing robots based on composite score"""
        print(f"Identifying top performers with score >= {min_score}...")
        
        # Create premium robots directory
        self.premium_robots_dir.mkdir(parents=True, exist_ok=True)
        
        # Collect all metadata files
        premium_robots = []
        processed_count = 0
        
        for category in ["by_performance", "by_strategy", "by_timeframe", "by_status"]:
            category_path = Path(self.organized_root) / "EA_METADATA" / category
            if not category_path.exists():
                continue
                
            for subdir in category_path.iterdir():
                if not subdir.is_dir():
                    continue
                    
                for file_path in subdir.glob("*.json"):
                    try:
                        with open(file_path, 'r', encoding='utf-8') as f:
                            metadata = json.load(f)
                            
                        score = self.calculate_composite_score(metadata)
                        
                        if score >= min_score:
                            premium_robots.append({
                                "metadata": metadata,
                                "score": score,
                                "category": category,
                                "subcategory": subdir.name,
                                "file_path": str(file_path)
                            })
                            
                        processed_count += 1
                        
                    except Exception as e:
                        print(f"Error processing {file_path}: {e}")
                        
        # Sort by score (descending)
        premium_robots.sort(key=lambda x: x["score"], reverse=True)
        
        # Copy top 25 to premium robots directory
        top_robots = premium_robots[:25]
        
        for i, robot in enumerate(top_robots):
            try:
                # Copy metadata file
                filename = f"top_{i+1:02d}_{Path(robot['file_path']).name}"
                target_path = self.premium_robots_dir / filename
                shutil.copy2(robot['file_path'], target_path)
                
                # Add ranking info to metadata
                robot['metadata']['ranking'] = {
                    "position": i + 1,
                    "composite_score": robot['score'],
                    "classification_date": datetime.now().isoformat()
                }
                
                # Update metadata file with ranking info
                with open(target_path, 'w', encoding='utf-8') as f:
                    json.dump(robot['metadata'], f, indent=2, ensure_ascii=False)
                    
            except Exception as e:
                print(f"Error copying {robot['file_path']}: {e}")
                
        print(f"Identified {len(top_robots)} top performers")
        return top_robots
        
    def generate_premium_robots_index(self, premium_robots):
        """Generate index file for premium robots"""
        print("Generating premium robots index...")
        
        index_data = {
            "project": "EA_SCALPER_XAUUSD",
            "index_type": "Premium Robots",
            "last_update": datetime.now().isoformat(),
            "total_robots": len(premium_robots),
            "top_performers": []
        }
        
        for i, robot in enumerate(premium_robots):
            robot_info = {
                "rank": i + 1,
                "score": robot['score'],
                "name": robot['metadata'].get('name', 'Unknown'),
                "strategy": robot['metadata'].get('strategy', 'Unknown'),
                "market": robot['metadata'].get('market', 'Unknown'),
                "ftmo_score": robot['metadata'].get('ftmo_score', 0),
                "quality_score": robot['metadata'].get('quality_score', 0),
                "file": f"top_{i+1:02d}_{Path(robot['file_path']).name}"
            }
            index_data["top_performers"].append(robot_info)
            
        # Save index file
        index_path = self.premium_robots_dir / "PREMIUM_ROBOTS_INDEX.json"
        with open(index_path, 'w', encoding='utf-8') as f:
            json.dump(index_data, f, indent=2, ensure_ascii=False)
            
        print(f"Premium robots index created at {index_path}")
        
    def create_premium_robots_structure(self, premium_robots):
        """Create directory structure for premium robots"""
        print("Creating premium robots structure...")
        
        # Create subdirectories for different categories
        categories = {
            "SMC_ICT": "Smart Money Concepts robots",
            "SCALPING": "Scalping strategy robots",
            "TREND_FOLLOWING": "Trend following robots",
            "AI_DRIVEN": "AI-driven robots",
            "MULTI_STRATEGY": "Multi-strategy robots"
        }
        
        for category, description in categories.items():
            category_path = self.premium_robots_dir / category
            category_path.mkdir(exist_ok=True)
            
            # Add a description file
            desc_path = category_path / "DESCRIPTION.md"
            with open(desc_path, 'w', encoding='utf-8') as f:
                f.write(f"# {category}\n\n{description}\n")
                
        # Categorize and copy robots to appropriate directories
        categorized_count = 0
        for i, robot in enumerate(premium_robots):
            try:
                strategy = robot['metadata'].get('strategy', '')
                name = f"top_{i+1:02d}_{Path(robot['file_path']).name}"
                source_path = self.premium_robots_dir / name
                
                # Determine category
                target_category = "MULTI_STRATEGY"  # Default
                if "SMC" in strategy or "ICT" in strategy:
                    target_category = "SMC_ICT"
                elif "Scalping" in strategy:
                    target_category = "SCALPING"
                elif "Trend" in strategy:
                    target_category = "TREND_FOLLOWING"
                elif "AI" in strategy:
                    target_category = "AI_DRIVEN"
                    
                # Copy to category directory
                target_path = self.premium_robots_dir / target_category / name
                if source_path.exists():
                    shutil.copy2(source_path, target_path)
                    categorized_count += 1
                    
            except Exception as e:
                print(f"Error categorizing robot: {e}")
                
        print(f"Categorized {categorized_count} premium robots")
        
    def run_classification(self):
        """Run complete metadata classification process"""
        print("Starting metadata classification...")
        
        # Identify top performers
        premium_robots = self.identify_top_performers()
        
        # Generate index
        self.generate_premium_robots_index(premium_robots)
        
        # Create structure
        self.create_premium_robots_structure(premium_robots)
        
        print("Metadata classification completed!")
        
        # Print summary
        print("\n=== CLASSIFICATION SUMMARY ===")
        print(f"Total premium robots identified: {len(premium_robots)}")
        print("Top 5 performers:")
        for i, robot in enumerate(premium_robots[:5]):
            print(f"  {i+1}. Score: {robot['score']:.2f} - {robot['metadata'].get('name', 'Unknown')}")

# Example usage
if __name__ == "__main__":
    classifier = MetadataClassifier()
    classifier.run_classification()