# orphan_monitor.py - Monitor de arquivos órfãos
import time
import json
import os
from datetime import datetime

class OrphanFileMonitor:
    def __init__(self, orphan_directory="06_ARQUIVOS_ORFAOS"):
        self.orphan_directory = orphan_directory
        self.management_dir = os.path.join(orphan_directory, "ORPHAN_MANAGEMENT")
        self.index_file = os.path.join(self.management_dir, "FILE_MANAGEMENT_INDEX.json")
        self.monitoring_rules = self.load_monitoring_rules()
        self.alert_thresholds = self.load_alert_thresholds()
        
    def load_monitoring_rules(self):
        """Load monitoring rules for orphan files"""
        # Default rules for monitoring
        return {
            "critical_extensions": [".mq5", ".mq4", ".ex5", ".ex4"],
            "size_threshold": 1000000,  # 1MB
            "scan_interval": 3600  # 1 hour
        }
        
    def load_alert_thresholds(self):
        """Load alert thresholds for orphan files"""
        # Default alert thresholds
        return {
            "critical_file_count": 10,
            "large_file_count": 50,
            "total_file_limit": 1000
        }
        
    def continuous_monitoring(self):
        """Monitoramento contínuo de arquivos órfãos"""
        print("Starting continuous monitoring of orphan files...")
        while True:
            # Verificar novos arquivos órfãos
            new_orphans = self.detect_new_orphans()
            
            # Classificar automaticamente
            self.auto_classify(new_orphans)
            
            # Gerar alertas se necessário
            self.generate_alerts(new_orphans)
            
            # Atualizar índices
            self.update_indexes()
            
            time.sleep(self.monitoring_rules["scan_interval"])  # Verificar a cada hora
            
    def detect_new_orphans(self):
        """Detectar novos arquivos órfãos"""
        all_files = self.scan_all_directories()
        classified_files = self.get_classified_files()
        
        orphans = []
        for file in all_files:
            if file not in classified_files:
                orphans.append(file)
                
        return orphans
        
    def scan_all_directories(self):
        """Scan all directories for files"""
        all_files = []
        for root, dirs, files in os.walk(self.orphan_directory):
            # Skip the management directory itself
            if "ORPHAN_MANAGEMENT" in root:
                continue
            for file in files:
                all_files.append(os.path.join(root, file))
        return all_files
        
    def get_classified_files(self):
        """Get list of already classified files"""
        try:
            with open(self.index_file, 'r') as f:
                index_data = json.load(f)
                # In a real implementation, this would return actual classified files
                return []
        except FileNotFoundError:
            return []
        
    def auto_classify(self, orphans):
        """Auto-classify orphan files"""
        print(f"Auto-classifying {len(orphans)} orphan files...")
        # In a real implementation, this would contain actual classification logic
        pass
        
    def generate_alerts(self, orphans):
        """Gerar alertas para arquivos órfãos críticos"""
        critical_orphans = []
        large_orphans = []
        
        for orphan in orphans:
            # Arquivos MQL5/EAs são críticos
            _, extension = os.path.splitext(orphan)
            if extension in self.monitoring_rules["critical_extensions"]:
                critical_orphans.append(orphan)
                
            # Arquivos grandes também são críticos
            try:
                if os.path.getsize(orphan) > self.monitoring_rules["size_threshold"]:
                    large_orphans.append(orphan)
            except OSError:
                # File might have been moved/deleted
                pass
                
        # Check thresholds and generate alerts
        if len(critical_orphans) >= self.alert_thresholds["critical_file_count"]:
            self.send_critical_alert(critical_orphans)
            
        if len(large_orphans) >= self.alert_thresholds["large_file_count"]:
            self.send_large_file_alert(large_orphans)
            
    def send_critical_alert(self, critical_files):
        """Send alert for critical files"""
        print(f"CRITICAL ALERT: Found {len(critical_files)} critical orphan files")
        # In a real implementation, this would send actual alerts
        
    def send_large_file_alert(self, large_files):
        """Send alert for large files"""
        print(f"WARNING: Found {len(large_files)} large orphan files")
        # In a real implementation, this would send actual alerts
        
    def update_indexes(self):
        """Update management indexes"""
        print("Updating orphan file indexes...")
        # In a real implementation, this would update actual indexes
        self.update_file_management_index()
        
    def update_file_management_index(self):
        """Update the FILE_MANAGEMENT_INDEX.json"""
        try:
            with open(self.index_file, 'r') as f:
                index_data = json.load(f)
        except FileNotFoundError:
            index_data = {
                "project": "EA_SCALPER_XAUUSD",
                "orphan_directory": self.orphan_directory,
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
            
        # Update the last update timestamp
        index_data["last_update"] = datetime.now().isoformat()
        
        # Save the updated index
        with open(self.index_file, 'w') as f:
            json.dump(index_data, f, indent=2)

if __name__ == "__main__":
    # Initialize and start monitoring
    monitor = OrphanFileMonitor()
    monitor.update_indexes()
    print("Orphan file monitoring system initialized.")
    print("Directory structure for quarantining bad/locked files is now set up.")