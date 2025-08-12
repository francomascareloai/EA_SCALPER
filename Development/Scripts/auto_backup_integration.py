#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Integração de Backup Automático
Parte do EA Scalper Trading Code Classification System

Este script integra o backup automático com todas as operações do sistema.
"""

import os
import sys
from pathlib import Path
import subprocess
from datetime import datetime
import json

# Adicionar o diretório raiz ao path
root_dir = Path(__file__).parent.parent.parent
sys.path.append(str(root_dir))

from Development.Scripts.git_auto_backup import GitAutoBackup

class AutoBackupIntegration:
    def __init__(self):
        self.backup_system = GitAutoBackup()
        self.integration_log = root_dir / 'Development' / 'Logs' / 'backup_integration.log'
        self.integration_log.parent.mkdir(parents=True, exist_ok=True)
        
    def log_integration(self, message, level="INFO"):
        """Log específico para integração"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_entry = f"[{timestamp}] [INTEGRATION-{level}] {message}\n"
        
        print(f"[BACKUP-{level}] {message}")
        
        with open(self.integration_log, 'a', encoding='utf-8') as f:
            f.write(log_entry)
    
    def backup_after_classification(self, operation_type="classification"):
        """Backup após operação de classificação"""
        commit_message = f"Auto backup após {operation_type}: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
        
        self.log_integration(f"Iniciando backup após {operation_type}")
        
        success, message = self.backup_system.create_backup(
            commit_message=commit_message,
            push_to_github=True
        )
        
        if success:
            self.log_integration(f"Backup após {operation_type} concluído com sucesso")
        else:
            self.log_integration(f"Erro no backup após {operation_type}: {message}", "ERROR")
        
        return success, message
    
    def backup_after_report_generation(self):
        """Backup após geração de relatórios"""
        return self.backup_after_classification("geração de relatórios")
    
    def backup_after_system_update(self):
        """Backup após atualização do sistema"""
        return self.backup_after_classification("atualização do sistema")
    
    def backup_after_config_change(self):
        """Backup após mudança de configuração"""
        return self.backup_after_classification("mudança de configuração")
    
    def setup_github_repository(self):
        """Configuração interativa do repositório GitHub"""
        print("\n=== CONFIGURAÇÃO DO REPOSITÓRIO GITHUB ===")
        print("\nPara configurar o backup automático no GitHub, você precisa:")
        print("1. Criar um repositório no GitHub")
        print("2. Obter a URL do repositório")
        print("3. Configurar autenticação (token ou SSH)")
        
        print("\nExemplos de URL:")
        print("  HTTPS: https://github.com/seu-usuario/ea-scalper-system.git")
        print("  SSH:   git@github.com:seu-usuario/ea-scalper-system.git")
        
        github_url = input("\nDigite a URL do repositório GitHub (ou Enter para configurar depois): ").strip()
        
        if github_url:
            print("\nConfigurando repositório...")
            success, message = self.backup_system.setup_auto_backup(github_url)
            
            if success:
                print(f"✅ {message}")
                
                # Fazer push inicial
                print("\nFazendo push inicial...")
                success, message = self.backup_system.push_to_remote()
                
                if success:
                    print("✅ Push inicial realizado com sucesso!")
                    print("\n🎉 Backup automático configurado e funcionando!")
                else:
                    print(f"⚠️  Push inicial falhou: {message}")
                    print("\nVerifique:")
                    print("- Se a URL está correta")
                    print("- Se você tem permissões no repositório")
                    print("- Se a autenticação está configurada (token/SSH)")
            else:
                print(f"❌ Erro na configuração: {message}")
        else:
            print("\n⏭️  Configuração do GitHub adiada.")
            print("Execute novamente quando estiver pronto.")
        
        return github_url is not None
    
    def create_backup_hooks(self):
        """Cria hooks para backup automático"""
        hooks_dir = root_dir / 'Development' / 'Hooks'
        hooks_dir.mkdir(parents=True, exist_ok=True)
        
        # Hook para classificação
        classification_hook = hooks_dir / 'post_classification.py'
        with open(classification_hook, 'w', encoding='utf-8') as f:
            f.write('''
#!/usr/bin/env python3
# Hook executado após classificação
import sys
from pathlib import Path
sys.path.append(str(Path(__file__).parent.parent))
from Scripts.auto_backup_integration import AutoBackupIntegration

integration = AutoBackupIntegration()
integration.backup_after_classification()
''')
        
        # Hook para relatórios
        report_hook = hooks_dir / 'post_report.py'
        with open(report_hook, 'w', encoding='utf-8') as f:
            f.write('''
#!/usr/bin/env python3
# Hook executado após geração de relatórios
import sys
from pathlib import Path
sys.path.append(str(Path(__file__).parent.parent))
from Scripts.auto_backup_integration import AutoBackupIntegration

integration = AutoBackupIntegration()
integration.backup_after_report_generation()
''')
        
        self.log_integration("Hooks de backup criados")
        return True
    
    def test_backup_system(self):
        """Testa o sistema de backup"""
        print("\n=== TESTE DO SISTEMA DE BACKUP ===")
        
        # Verificar status
        has_changes, status = self.backup_system.check_git_status()
        print(f"Status do repositório: {'Alterações pendentes' if has_changes else 'Limpo'}")
        
        if has_changes:
            print("\nAlterações detectadas:")
            print(status)
            
            response = input("\nDeseja fazer backup das alterações? (s/n): ").lower()
            if response == 's':
                success, message = self.backup_after_system_update()
                print(f"Resultado: {message}")
        else:
            print("\n✅ Repositório está limpo - sistema funcionando corretamente")
        
        return True

def main():
    """Função principal"""
    integration = AutoBackupIntegration()
    
    if len(sys.argv) > 1:
        command = sys.argv[1].lower()
        
        if command == "setup":
            integration.setup_github_repository()
            integration.create_backup_hooks()
            
        elif command == "test":
            integration.test_backup_system()
            
        elif command == "backup":
            operation = sys.argv[2] if len(sys.argv) > 2 else "manual"
            success, message = integration.backup_after_classification(operation)
            print(f"Backup {operation}: {message}")
            
        else:
            print("Comandos disponíveis:")
            print("  setup  - Configurar integração com GitHub")
            print("  test   - Testar sistema de backup")
            print("  backup [operacao] - Executar backup manual")
    else:
        print("\n🔧 Sistema de Backup Automático - EA Scalper")
        print("\nUse 'python auto_backup_integration.py setup' para configurar")

if __name__ == "__main__":
    main()