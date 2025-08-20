#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🔍 TESTE PRÉ-EXECUÇÃO - Verificação Final do Sistema
Verifica se todos os componentes estão prontos para o teste completo
"""

import sys
import os
import json
from pathlib import Path
import importlib.util
from typing import Dict, List, Tuple

# Adicionar diretório raiz ao path
project_root = Path(__file__).parent.parent.parent
sys.path.insert(0, str(project_root))

class TestPreExecucao:
    """Classe para verificação pré-execução do sistema"""
    
    def __init__(self):
        self.project_root = project_root
        self.issues = []
        self.warnings = []
        self.success_count = 0
        self.total_checks = 0
        
    def log_success(self, message: str):
        """Log de sucesso"""
        print(f"✅ {message}")
        self.success_count += 1
        
    def log_warning(self, message: str):
        """Log de warning"""
        print(f"⚠️  {message}")
        self.warnings.append(message)
        
    def log_error(self, message: str):
        """Log de erro"""
        print(f"❌ {message}")
        self.issues.append(message)
        
    def check_file_exists(self, file_path: str, description: str) -> bool:
        """Verifica se arquivo existe"""
        self.total_checks += 1
        full_path = self.project_root / file_path
        
        if full_path.exists():
            self.log_success(f"{description}: {file_path}")
            return True
        else:
            self.log_error(f"{description} não encontrado: {file_path}")
            return False
            
    def check_module_import(self, module_path: str, description: str) -> bool:
        """Verifica se módulo pode ser importado"""
        self.total_checks += 1
        try:
            spec = importlib.util.spec_from_file_location("test_module", self.project_root / module_path)
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)
            self.log_success(f"{description} importado com sucesso")
            return True
        except Exception as e:
            self.log_error(f"Erro ao importar {description}: {str(e)}")
            return False
            
    def check_config_file(self, config_path: str, required_keys: List[str]) -> bool:
        """Verifica arquivo de configuração"""
        self.total_checks += 1
        full_path = self.project_root / config_path
        
        if not full_path.exists():
            self.log_error(f"Arquivo de configuração não encontrado: {config_path}")
            return False
            
        try:
            with open(full_path, 'r', encoding='utf-8') as f:
                config = json.load(f)
                
            missing_keys = [key for key in required_keys if key not in config]
            if missing_keys:
                self.log_warning(f"Chaves faltando em {config_path}: {missing_keys}")
                return False
            else:
                self.log_success(f"Configuração válida: {config_path}")
                return True
                
        except Exception as e:
            self.log_error(f"Erro ao ler configuração {config_path}: {str(e)}")
            return False
            
    def check_directory_structure(self) -> bool:
        """Verifica estrutura de diretórios"""
        required_dirs = [
            "Development/Core",
            "Development/Testing",
            "Development/Reports",
            "Development/Utils",
            "Development/Scripts",
            "Development/config",
            "Development/logs"
        ]
        
        all_exist = True
        for dir_path in required_dirs:
            self.total_checks += 1
            full_path = self.project_root / dir_path
            if full_path.exists():
                self.log_success(f"Diretório existe: {dir_path}")
            else:
                self.log_error(f"Diretório não encontrado: {dir_path}")
                all_exist = False
                
        return all_exist
        
    def run_all_checks(self) -> Dict:
        """Executa todas as verificações"""
        print("🔍 INICIANDO VERIFICAÇÃO PRÉ-EXECUÇÃO\n")
        
        # 1. Estrutura de diretórios
        print("📁 Verificando estrutura de diretórios...")
        self.check_directory_structure()
        print()
        
        # 2. Arquivos principais
        print("📄 Verificando arquivos principais...")
        core_files = [
            ("Development/Core/orquestrador_central.py", "Orquestrador Central"),
            ("Development/Core/classificador_lote_avancado.py", "Classificador Lote"),
            ("Development/Core/monitor_tempo_real.py", "Monitor Tempo Real"),
            ("Development/Core/gerador_relatorios_avancados.py", "Gerador Relatórios")
        ]
        
        for file_path, description in core_files:
            self.check_file_exists(file_path, description)
        print()
        
        # 3. Arquivos de configuração
        print("⚙️ Verificando configurações...")
        self.check_config_file("Development/config/orquestrador.json", 
                              ["debug", "auto_backup", "max_workers", "components"])
        self.check_file_exists("Development/Testing/pytest.ini", "Configuração pytest")
        print()
        
        # 4. Importação de módulos
        print("🔌 Verificando importações...")
        modules = [
            ("Development/Core/orquestrador_central.py", "Orquestrador"),
            ("Development/Core/classificador_lote_avancado.py", "Classificador"),
            ("Development/Core/monitor_tempo_real.py", "Monitor")
        ]
        
        for module_path, description in modules:
            self.check_module_import(module_path, description)
        print()
        
        # 5. Arquivos de teste
        print("🧪 Verificando ambiente de teste...")
        test_files = [
            ("Development/Testing/setup_test_environment.py", "Setup Teste"),
            ("Development/Testing/test_exemplo_ambiente.py", "Teste Exemplo"),
            ("Development/Testing/teste_sistema_completo_passo2.py", "Teste Sistema")
        ]
        
        for file_path, description in test_files:
            self.check_file_exists(file_path, description)
        print()
        
        # Resultado final
        return self._generate_final_report()
        
    def _generate_final_report(self) -> Dict:
        """Gera relatório final"""
        success_rate = (self.success_count / self.total_checks) * 100 if self.total_checks > 0 else 0
        
        print("="*60)
        print("📊 RELATÓRIO FINAL DA VERIFICAÇÃO")
        print("="*60)
        print(f"✅ Sucessos: {self.success_count}/{self.total_checks} ({success_rate:.1f}%)")
        print(f"⚠️  Warnings: {len(self.warnings)}")
        print(f"❌ Erros: {len(self.issues)}")
        print()
        
        if self.issues:
            print("🚨 PROBLEMAS CRÍTICOS:")
            for issue in self.issues:
                print(f"   • {issue}")
            print()
            
        if self.warnings:
            print("⚠️  AVISOS:")
            for warning in self.warnings:
                print(f"   • {warning}")
            print()
            
        # Status final
        if not self.issues:
            if not self.warnings:
                print("🎉 SISTEMA PRONTO PARA TESTE COMPLETO!")
                status = "READY"
            else:
                print("✅ Sistema pronto com avisos menores")
                status = "READY_WITH_WARNINGS"
        else:
            print("🚫 SISTEMA NÃO ESTÁ PRONTO - Corrija os problemas primeiro")
            status = "NOT_READY"
            
        print("="*60)
        
        return {
            "status": status,
            "success_rate": success_rate,
            "total_checks": self.total_checks,
            "successes": self.success_count,
            "warnings": len(self.warnings),
            "errors": len(self.issues),
            "issues": self.issues,
            "warning_messages": self.warnings
        }

def main():
    """Função principal"""
    tester = TestPreExecucao()
    result = tester.run_all_checks()
    
    # Salvar resultado
    report_path = tester.project_root / "Development" / "Testing" / "pre_execution_check.json"
    with open(report_path, 'w', encoding='utf-8') as f:
        json.dump(result, f, indent=2, ensure_ascii=False)
        
    print(f"\n📄 Relatório salvo em: {report_path}")
    
    # Código de saída
    if result["status"] == "READY":
        sys.exit(0)
    elif result["status"] == "READY_WITH_WARNINGS":
        sys.exit(1)
    else:
        sys.exit(2)

if __name__ == "__main__":
    main()