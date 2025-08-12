#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Sistema de Backup Automático GitHub
Parte do EA Scalper Trading Code Classification System

Este script automatiza o backup no GitHub após cada alteração significativa.
"""

import os
import sys
import subprocess
import json
from datetime import datetime
from pathlib import Path
import time

class GitAutoBackup:
    def __init__(self, repo_path=None):
        self.repo_path = Path(repo_path) if repo_path else Path.cwd()
        self.git_dir = self.repo_path / '.git'
        self.config_file = self.repo_path / 'Development' / 'Config' / 'git_config.json'
        self.log_file = self.repo_path / 'Development' / 'Logs' / 'git_backup.log'
        
        # Criar diretórios se não existirem
        self.config_file.parent.mkdir(parents=True, exist_ok=True)
        self.log_file.parent.mkdir(parents=True, exist_ok=True)
        
    def log_message(self, message, level="INFO"):
        """Registra mensagem no log"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_entry = f"[{timestamp}] [{level}] {message}\n"
        
        print(f"[{level}] {message}")
        
        with open(self.log_file, 'a', encoding='utf-8') as f:
            f.write(log_entry)
    
    def run_git_command(self, command):
        """Executa comando Git e retorna resultado"""
        try:
            result = subprocess.run(
                command,
                cwd=self.repo_path,
                capture_output=True,
                text=True,
                shell=True
            )
            
            if result.returncode == 0:
                self.log_message(f"Git command successful: {command}")
                return True, result.stdout.strip()
            else:
                self.log_message(f"Git command failed: {command} - {result.stderr}", "ERROR")
                return False, result.stderr.strip()
                
        except Exception as e:
            self.log_message(f"Error executing git command: {command} - {str(e)}", "ERROR")
            return False, str(e)
    
    def check_git_status(self):
        """Verifica se há alterações para commit"""
        success, output = self.run_git_command("git status --porcelain")
        if success:
            return len(output.strip()) > 0, output
        return False, output
    
    def add_all_changes(self):
        """Adiciona todas as alterações ao staging"""
        return self.run_git_command("git add .")
    
    def commit_changes(self, message=None):
        """Faz commit das alterações"""
        if not message:
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            message = f"Auto backup: {timestamp} - Sistema EA Scalper atualizado"
        
        return self.run_git_command(f'git commit -m "{message}"')
    
    def push_to_remote(self, remote="origin", branch="main"):
        """Envia alterações para o repositório remoto"""
        return self.run_git_command(f"git push {remote} {branch}")
    
    def setup_remote_repository(self, github_url):
        """Configura repositório remoto"""
        # Verificar se remote já existe
        success, output = self.run_git_command("git remote -v")
        
        if "origin" not in output:
            # Adicionar remote
            success, output = self.run_git_command(f"git remote add origin {github_url}")
            if not success:
                return False, output
        
        # Configurar branch principal
        self.run_git_command("git branch -M main")
        
        return True, "Remote configurado com sucesso"
    
    def create_backup(self, commit_message=None, push_to_github=True):
        """Executa backup completo"""
        self.log_message("=== INICIANDO BACKUP AUTOMÁTICO ===")
        
        # Verificar se há alterações
        has_changes, status_output = self.check_git_status()
        
        if not has_changes:
            self.log_message("Nenhuma alteração detectada. Backup não necessário.")
            return True, "Nenhuma alteração"
        
        self.log_message(f"Alterações detectadas:\n{status_output}")
        
        # Adicionar alterações
        success, output = self.add_all_changes()
        if not success:
            self.log_message(f"Erro ao adicionar alterações: {output}", "ERROR")
            return False, output
        
        # Fazer commit
        success, output = self.commit_changes(commit_message)
        if not success:
            self.log_message(f"Erro ao fazer commit: {output}", "ERROR")
            return False, output
        
        self.log_message("Commit realizado com sucesso")
        
        # Push para GitHub (se configurado)
        if push_to_github:
            success, output = self.push_to_remote()
            if success:
                self.log_message("Push para GitHub realizado com sucesso")
            else:
                self.log_message(f"Aviso: Push para GitHub falhou: {output}", "WARNING")
                self.log_message("Backup local realizado. Configure o repositório remoto para backup na nuvem.")
        
        self.log_message("=== BACKUP CONCLUÍDO ===")
        return True, "Backup realizado com sucesso"
    
    def save_config(self, config):
        """Salva configuração"""
        with open(self.config_file, 'w', encoding='utf-8') as f:
            json.dump(config, f, indent=2, ensure_ascii=False)
    
    def load_config(self):
        """Carrega configuração"""
        if self.config_file.exists():
            with open(self.config_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        return {}
    
    def setup_auto_backup(self, github_url=None, auto_push=True):
        """Configura backup automático"""
        config = {
            "github_url": github_url,
            "auto_push": auto_push,
            "last_backup": None,
            "backup_frequency": "on_change",  # on_change, hourly, daily
            "created_at": datetime.now().isoformat()
        }
        
        if github_url:
            success, message = self.setup_remote_repository(github_url)
            if not success:
                self.log_message(f"Erro ao configurar repositório remoto: {message}", "ERROR")
                return False, message
        
        self.save_config(config)
        self.log_message("Configuração de backup automático salva")
        
        return True, "Backup automático configurado"

def main():
    """Função principal"""
    backup_system = GitAutoBackup()
    
    if len(sys.argv) > 1:
        command = sys.argv[1].lower()
        
        if command == "setup":
            github_url = input("Digite a URL do repositório GitHub (ou Enter para pular): ").strip()
            if not github_url:
                github_url = None
            
            success, message = backup_system.setup_auto_backup(github_url)
            print(f"Setup: {message}")
            
        elif command == "backup":
            commit_msg = " ".join(sys.argv[2:]) if len(sys.argv) > 2 else None
            success, message = backup_system.create_backup(commit_msg)
            print(f"Backup: {message}")
            
        elif command == "status":
            has_changes, output = backup_system.check_git_status()
            if has_changes:
                print("Alterações pendentes:")
                print(output)
            else:
                print("Nenhuma alteração pendente")
                
        else:
            print("Comandos disponíveis:")
            print("  setup   - Configurar backup automático")
            print("  backup  - Executar backup manual")
            print("  status  - Verificar status do repositório")
    else:
        # Backup automático
        success, message = backup_system.create_backup()
        print(f"Backup automático: {message}")

if __name__ == "__main__":
    main()