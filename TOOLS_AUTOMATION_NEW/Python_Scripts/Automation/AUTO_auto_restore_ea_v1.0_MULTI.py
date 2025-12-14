#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
TradeDev_Master - Auto Restore EA Script
Script automatizado para localizar e restaurar o EA principal perdido

Autor: TradeDev_Master
Versão: 1.0.0
Data: 2025-01-20
"""

import os
import shutil
import glob
import json
import subprocess
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Optional, Tuple

class EARestoreManager:
    """Gerenciador automatizado para restauração de EAs perdidos"""
    
    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.ea_name = "EA_FTMO_Scalper_Elite"
        self.target_folder = self.project_root / "EA_FTMO_SCALPER_ELITE" / "MQL5_Source" / "EAs" / "FTMO_Ready"
        self.backup_folders = [
            self.project_root / "Backups",
            self.project_root / "BACKUP_SEGURANCA",
            self.project_root / "EA_FTMO_SCALPER_ELITE",
            self.project_root / "MQL5_Source"
        ]
        self.log_file = self.project_root / "Tools" / "restore_log.json"
        self.results = {
            "timestamp": datetime.now().isoformat(),
            "found_files": [],
            "restored_files": [],
            "errors": [],
            "git_history": []
        }
    
    def log_action(self, action: str, details: str, status: str = "info"):
        """Log de ações com timestamp"""
        log_entry = {
            "timestamp": datetime.now().isoformat(),
            "action": action,
            "details": details,
            "status": status
        }
        print(f"[{status.upper()}] {action}: {details}")
        
        if status == "error":
            self.results["errors"].append(log_entry)
    
    def search_ea_files(self) -> List[Dict]:
        """Busca arquivos do EA em todo o projeto"""
        self.log_action("SEARCH", "Iniciando busca por arquivos do EA")
        
        found_files = []
        search_patterns = [
            f"**/{self.ea_name}.mq5",
            f"**/{self.ea_name}.mq5.bak",
            f"**/*FTMO*Scalper*.mq5",
            f"**/*FTMO*Scalper*.mq5.bak",
            "**/*EA_FTMO*.mq5",
            "**/*EA_FTMO*.mq5.bak"
        ]
        
        for pattern in search_patterns:
            matches = list(self.project_root.glob(pattern))
            for match in matches:
                if match.is_file():
                    file_info = {
                        "path": str(match),
                        "name": match.name,
                        "size": match.stat().st_size,
                        "modified": datetime.fromtimestamp(match.stat().st_mtime).isoformat(),
                        "type": "backup" if ".bak" in match.name else "source",
                        "pattern": pattern
                    }
                    found_files.append(file_info)
                    self.log_action("FOUND", f"Arquivo encontrado: {match.name} ({file_info['size']} bytes)")
        
        self.results["found_files"] = found_files
        return found_files
    
    def check_git_history(self) -> List[Dict]:
        """Verifica histórico Git para deleções/renomeações"""
        self.log_action("GIT_CHECK", "Verificando histórico Git")
        
        git_results = []
        try:
            # Buscar por deleções do arquivo
            cmd_deleted = ["git", "log", "--diff-filter=D", "--summary", "--oneline", "--", f"*{self.ea_name}*"]
            result_deleted = subprocess.run(cmd_deleted, cwd=self.project_root, capture_output=True, text=True)
            
            if result_deleted.stdout:
                git_results.append({
                    "type": "deletions",
                    "output": result_deleted.stdout,
                    "command": " ".join(cmd_deleted)
                })
                self.log_action("GIT_FOUND", "Deleções encontradas no histórico Git")
            
            # Buscar por renomeações
            cmd_renamed = ["git", "log", "--diff-filter=R", "--summary", "--oneline", "--", f"*{self.ea_name}*"]
            result_renamed = subprocess.run(cmd_renamed, cwd=self.project_root, capture_output=True, text=True)
            
            if result_renamed.stdout:
                git_results.append({
                    "type": "renames",
                    "output": result_renamed.stdout,
                    "command": " ".join(cmd_renamed)
                })
                self.log_action("GIT_FOUND", "Renomeações encontradas no histórico Git")
            
            # Buscar últimos commits que afetaram arquivos .mq5
            cmd_recent = ["git", "log", "--oneline", "-10", "--name-status", "--", "*.mq5"]
            result_recent = subprocess.run(cmd_recent, cwd=self.project_root, capture_output=True, text=True)
            
            if result_recent.stdout:
                git_results.append({
                    "type": "recent_mq5_changes",
                    "output": result_recent.stdout,
                    "command": " ".join(cmd_recent)
                })
                self.log_action("GIT_FOUND", "Mudanças recentes em arquivos .mq5 encontradas")
        
        except Exception as e:
            self.log_action("GIT_ERROR", f"Erro ao verificar Git: {str(e)}", "error")
        
        self.results["git_history"] = git_results
        return git_results
    
    def analyze_file_content(self, file_path: Path) -> Dict:
        """Analisa conteúdo do arquivo para validar se é o EA correto"""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            # Verificações de validação
            validations = {
                "has_ontick": "OnTick()" in content,
                "has_oninit": "OnInit()" in content,
                "has_ondeinit": "OnDeinit()" in content,
                "has_ftmo_comment": "FTMO" in content.upper(),
                "has_scalper_comment": "SCALPER" in content.upper(),
                "has_risk_management": any(term in content.lower() for term in ["stoploss", "takeprofit", "risk", "drawdown"]),
                "has_order_functions": any(term in content for term in ["OrderSend", "trade.Buy", "trade.Sell"]),
                "file_size_ok": len(content) > 1000  # Arquivo deve ter conteúdo substancial
            }
            
            score = sum(validations.values())
            is_valid = score >= 6  # Pelo menos 6 de 8 validações devem passar
            
            return {
                "validations": validations,
                "score": score,
                "is_valid": is_valid,
                "content_length": len(content)
            }
        
        except Exception as e:
            self.log_action("ANALYSIS_ERROR", f"Erro ao analisar {file_path}: {str(e)}", "error")
            return {"validations": {}, "score": 0, "is_valid": False, "content_length": 0}
    
    def restore_best_candidate(self, found_files: List[Dict]) -> Optional[str]:
        """Restaura o melhor candidato encontrado"""
        if not found_files:
            self.log_action("RESTORE_ERROR", "Nenhum arquivo encontrado para restaurar", "error")
            return None
        
        # Analisar cada arquivo encontrado
        candidates = []
        for file_info in found_files:
            file_path = Path(file_info["path"])
            analysis = self.analyze_file_content(file_path)
            
            candidate = {
                **file_info,
                **analysis,
                "priority": self._calculate_priority(file_info, analysis)
            }
            candidates.append(candidate)
        
        # Ordenar por prioridade (maior primeiro)
        candidates.sort(key=lambda x: x["priority"], reverse=True)
        
        best_candidate = candidates[0]
        self.log_action("BEST_CANDIDATE", f"Melhor candidato: {best_candidate['name']} (score: {best_candidate['score']}, priority: {best_candidate['priority']})")
        
        if not best_candidate["is_valid"]:
            self.log_action("RESTORE_WARNING", "Melhor candidato não passou em todas as validações", "warning")
        
        # Criar pasta de destino se não existir
        self.target_folder.mkdir(parents=True, exist_ok=True)
        
        # Definir nome do arquivo restaurado
        restored_name = f"{self.ea_name}.mq5"
        restored_path = self.target_folder / restored_name
        
        try:
            # Copiar arquivo
            shutil.copy2(best_candidate["path"], restored_path)
            
            # Criar backup do arquivo original se não for .bak
            if not best_candidate["path"].endswith(".bak"):
                backup_path = Path(best_candidate["path"]).with_suffix(".mq5.bak")
                if not backup_path.exists():
                    shutil.copy2(best_candidate["path"], backup_path)
                    self.log_action("BACKUP_CREATED", f"Backup criado: {backup_path}")
            
            restore_info = {
                "source": best_candidate["path"],
                "destination": str(restored_path),
                "timestamp": datetime.now().isoformat(),
                "analysis": best_candidate
            }
            
            self.results["restored_files"].append(restore_info)
            self.log_action("RESTORE_SUCCESS", f"EA restaurado com sucesso: {restored_path}")
            
            return str(restored_path)
        
        except Exception as e:
            self.log_action("RESTORE_ERROR", f"Erro ao restaurar arquivo: {str(e)}", "error")
            return None
    
    def _calculate_priority(self, file_info: Dict, analysis: Dict) -> int:
        """Calcula prioridade do arquivo baseado em vários fatores"""
        priority = 0
        
        # Pontuação base pela análise de conteúdo
        priority += analysis["score"] * 10
        
        # Bonus por não ser backup
        if file_info["type"] == "source":
            priority += 20
        
        # Bonus por tamanho adequado (nem muito pequeno, nem muito grande)
        size = file_info["size"]
        if 10000 < size < 500000:  # Entre 10KB e 500KB
            priority += 15
        elif size > 5000:  # Pelo menos 5KB
            priority += 5
        
        # Bonus por estar em pasta apropriada
        path_lower = file_info["path"].lower()
        if "ftmo" in path_lower:
            priority += 10
        if "mql5_source" in path_lower:
            priority += 8
        if "eas" in path_lower:
            priority += 5
        
        # Penalty por estar em backup
        if "backup" in path_lower:
            priority -= 5
        
        return priority
    
    def create_git_commit(self, restored_path: str) -> bool:
        """Cria commit Git para a restauração"""
        try:
            # Adicionar arquivo ao Git
            subprocess.run(["git", "add", restored_path], cwd=self.project_root, check=True)
            
            # Commit
            commit_message = f"feat: Restore {self.ea_name} - Auto recovery by TradeDev_Master\n\nRestored from backup analysis\nTimestamp: {datetime.now().isoformat()}"
            subprocess.run(["git", "commit", "-m", commit_message], cwd=self.project_root, check=True)
            
            self.log_action("GIT_COMMIT", "Commit criado com sucesso")
            return True
        
        except subprocess.CalledProcessError as e:
            self.log_action("GIT_COMMIT_ERROR", f"Erro ao criar commit: {str(e)}", "error")
            return False
    
    def save_report(self):
        """Salva relatório detalhado da operação"""
        try:
            self.log_file.parent.mkdir(parents=True, exist_ok=True)
            with open(self.log_file, 'w', encoding='utf-8') as f:
                json.dump(self.results, f, indent=2, ensure_ascii=False)
            
            self.log_action("REPORT_SAVED", f"Relatório salvo: {self.log_file}")
        
        except Exception as e:
            self.log_action("REPORT_ERROR", f"Erro ao salvar relatório: {str(e)}", "error")
    
    def run_full_restore(self) -> Dict:
        """Executa processo completo de restauração"""
        self.log_action("START", "=== INICIANDO RESTAURAÇÃO AUTOMATIZADA DO EA ===")
        
        # 1. Buscar arquivos
        found_files = self.search_ea_files()
        
        # 2. Verificar Git
        git_history = self.check_git_history()
        
        # 3. Restaurar melhor candidato
        restored_path = None
        if found_files:
            restored_path = self.restore_best_candidate(found_files)
        
        # 4. Criar commit se restauração foi bem-sucedida
        if restored_path:
            self.create_git_commit(restored_path)
        
        # 5. Salvar relatório
        self.save_report()
        
        # 6. Resumo final
        summary = {
            "success": restored_path is not None,
            "files_found": len(found_files),
            "restored_path": restored_path,
            "errors_count": len(self.results["errors"]),
            "report_path": str(self.log_file)
        }
        
        if summary["success"]:
            self.log_action("COMPLETE", f"=== RESTAURAÇÃO CONCLUÍDA COM SUCESSO ===\nArquivo restaurado: {restored_path}")
        else:
            self.log_action("FAILED", "=== RESTAURAÇÃO FALHOU ===\nNenhum arquivo válido encontrado", "error")
        
        return summary

def main():
    """Função principal"""
    project_root = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD"
    
    print("\n" + "="*60)
    print("TradeDev_Master - Auto Restore EA Script")
    print("Restauração Automatizada de EA Perdido")
    print("="*60 + "\n")
    
    manager = EARestoreManager(project_root)
    result = manager.run_full_restore()
    
    print("\n" + "="*60)
    print("RESUMO DA OPERAÇÃO:")
    print(f"✅ Sucesso: {'SIM' if result['success'] else 'NÃO'}")
    print(f"📁 Arquivos encontrados: {result['files_found']}")
    print(f"🔧 Arquivo restaurado: {result['restored_path'] or 'Nenhum'}")
    print(f"❌ Erros: {result['errors_count']}")
    print(f"📋 Relatório: {result['report_path']}")
    print("="*60)
    
    return result

if __name__ == "__main__":
    main()