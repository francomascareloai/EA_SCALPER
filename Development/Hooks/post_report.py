
#!/usr/bin/env python3
# Hook executado após geração de relatórios
import sys
from pathlib import Path
sys.path.append(str(Path(__file__).parent.parent))
from Scripts.auto_backup_integration import AutoBackupIntegration

integration = AutoBackupIntegration()
integration.backup_after_report_generation()
