#!/usr/bin/env python3
"""
Teste de Integração MCP com Trae
Classificador_Trading - Verificação Completa de Funcionamento

Este script testa todos os servidores MCP configurados no Trae
para garantir que estão funcionando corretamente.

Autor: Classificador_Trading
Versão: 1.0
Data: 12/01/2025
"""

import os
import sys
import json
import subprocess
import time
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any

class MCPTraeIntegrationTester:
    """
    Testador de Integração MCP com Trae
    
    Verifica se todos os servidores MCP estão configurados
    e funcionando corretamente no ambiente Trae.
    """
    
    def __init__(self):
        self.project_root = Path("C:/Users/Admin/Documents/EA_SCALPER_XAUUSD")
        self.mcp_config_path = self.project_root / ".kilocode" / "mcp.json"
        self.servers_path = self.project_root / "MCP_Integration" / "servers"
        self.test_results = {}
        self.start_time = datetime.now()
        
    def log_test(self, test_name: str, success: bool, details: str = ""):
        """Registra resultado de um teste."""
        status = "✅ PASSOU" if success else "❌ FALHOU"
        timestamp = datetime.now().strftime("%H:%M:%S")
        
        print(f"[{timestamp}] {status} - {test_name}")
        if details:
            print(f"    📝 {details}")
            
        self.test_results[test_name] = {
            "success": success,
            "details": details,
            "timestamp": timestamp
        }
        
    def test_mcp_config_exists(self) -> bool:
        """Testa se o arquivo de configuração MCP existe."""
        try:
            if self.mcp_config_path.exists():
                self.log_test("Arquivo mcp.json existe", True, str(self.mcp_config_path))
                return True
            else:
                self.log_test("Arquivo mcp.json existe", False, "Arquivo não encontrado")
                return False
        except Exception as e:
            self.log_test("Arquivo mcp.json existe", False, f"Erro: {e}")
            return False
            
    def test_mcp_config_valid(self) -> bool:
        """Testa se a configuração MCP é válida."""
        try:
            with open(self.mcp_config_path, 'r', encoding='utf-8') as f:
                config = json.load(f)
                
            if "mcpServers" in config:
                servers_count = len(config["mcpServers"])
                self.log_test(
                    "Configuração MCP válida", 
                    True, 
                    f"{servers_count} servidores configurados"
                )
                return True
            else:
                self.log_test("Configuração MCP válida", False, "Chave 'mcpServers' não encontrada")
                return False
                
        except json.JSONDecodeError as e:
            self.log_test("Configuração MCP válida", False, f"JSON inválido: {e}")
            return False
        except Exception as e:
            self.log_test("Configuração MCP válida", False, f"Erro: {e}")
            return False
            
    def test_server_files_exist(self) -> bool:
        """Testa se todos os arquivos de servidor existem."""
        try:
            with open(self.mcp_config_path, 'r', encoding='utf-8') as f:
                config = json.load(f)
                
            servers = config.get("mcpServers", {})
            all_exist = True
            
            for server_name, server_config in servers.items():
                args = server_config.get("args", [])
                if args:
                    server_file = Path(args[0])
                    if server_file.exists():
                        self.log_test(
                            f"Servidor {server_name} existe", 
                            True, 
                            str(server_file)
                        )
                    else:
                        self.log_test(
                            f"Servidor {server_name} existe", 
                            False, 
                            f"Arquivo não encontrado: {server_file}"
                        )
                        all_exist = False
                        
            return all_exist
            
        except Exception as e:
            self.log_test("Arquivos de servidor existem", False, f"Erro: {e}")
            return False
            
    def test_python_environment(self) -> bool:
        """Testa se o ambiente Python está configurado corretamente."""
        try:
            # Testar Python
            result = subprocess.run(
                ["python", "--version"], 
                capture_output=True, 
                text=True, 
                timeout=10
            )
            
            if result.returncode == 0:
                python_version = result.stdout.strip()
                self.log_test("Python disponível", True, python_version)
            else:
                self.log_test("Python disponível", False, "Python não encontrado")
                return False
                
            # Testar PYTHONPATH
            pythonpath = os.environ.get("PYTHONPATH", "")
            if str(self.project_root) in pythonpath or not pythonpath:
                self.log_test("PYTHONPATH configurado", True, pythonpath or "Padrão")
            else:
                self.log_test(
                    "PYTHONPATH configurado", 
                    False, 
                    f"Projeto não está no PYTHONPATH: {pythonpath}"
                )
                
            return True
            
        except Exception as e:
            self.log_test("Ambiente Python", False, f"Erro: {e}")
            return False
            
    def test_dependencies_installed(self) -> bool:
        """Testa se as dependências estão instaladas."""
        dependencies = [
            "pylint",
            "pytest", 
            "flake8",
            "black"
        ]
        
        all_installed = True
        
        for dep in dependencies:
            try:
                result = subprocess.run(
                    [dep, "--version"], 
                    capture_output=True, 
                    text=True, 
                    timeout=10
                )
                
                if result.returncode == 0:
                    version = result.stdout.strip().split('\n')[0]
                    self.log_test(f"Dependência {dep}", True, version)
                else:
                    self.log_test(f"Dependência {dep}", False, "Não instalado")
                    all_installed = False
                    
            except Exception as e:
                self.log_test(f"Dependência {dep}", False, f"Erro: {e}")
                all_installed = False
                
        return all_installed
        
    def test_server_syntax(self) -> bool:
        """Testa se os servidores têm sintaxe Python válida."""
        try:
            with open(self.mcp_config_path, 'r', encoding='utf-8') as f:
                config = json.load(f)
                
            servers = config.get("mcpServers", {})
            all_valid = True
            
            for server_name, server_config in servers.items():
                args = server_config.get("args", [])
                if args:
                    server_file = Path(args[0])
                    if server_file.exists():
                        try:
                            result = subprocess.run(
                                ["python", "-m", "py_compile", str(server_file)],
                                capture_output=True,
                                text=True,
                                timeout=30
                            )
                            
                            if result.returncode == 0:
                                self.log_test(
                                    f"Sintaxe {server_name}", 
                                    True, 
                                    "Sintaxe válida"
                                )
                            else:
                                self.log_test(
                                    f"Sintaxe {server_name}", 
                                    False, 
                                    f"Erro de sintaxe: {result.stderr}"
                                )
                                all_valid = False
                                
                        except Exception as e:
                            self.log_test(
                                f"Sintaxe {server_name}", 
                                False, 
                                f"Erro ao verificar: {e}"
                            )
                            all_valid = False
                            
            return all_valid
            
        except Exception as e:
            self.log_test("Verificação de sintaxe", False, f"Erro: {e}")
            return False
            
    def test_quality_check_script(self) -> bool:
        """Testa se o script de verificação de qualidade funciona."""
        try:
            quality_script = self.project_root / "MCP_Integration" / "scripts" / "quality_check.py"
            
            if not quality_script.exists():
                self.log_test(
                    "Script quality_check", 
                    False, 
                    "Arquivo não encontrado"
                )
                return False
                
            result = subprocess.run(
                ["python", str(quality_script), "--help"],
                capture_output=True,
                text=True,
                timeout=30
            )
            
            if result.returncode == 0:
                self.log_test(
                    "Script quality_check", 
                    True, 
                    "Funcionando corretamente"
                )
                return True
            else:
                self.log_test(
                    "Script quality_check", 
                    False, 
                    f"Erro: {result.stderr}"
                )
                return False
                
        except Exception as e:
            self.log_test("Script quality_check", False, f"Erro: {e}")
            return False
            
    def generate_report(self) -> Dict[str, Any]:
        """Gera relatório final dos testes."""
        end_time = datetime.now()
        duration = (end_time - self.start_time).total_seconds()
        
        total_tests = len(self.test_results)
        passed_tests = sum(1 for result in self.test_results.values() if result["success"])
        failed_tests = total_tests - passed_tests
        
        success_rate = (passed_tests / total_tests * 100) if total_tests > 0 else 0
        
        report = {
            "timestamp": end_time.isoformat(),
            "duration_seconds": duration,
            "total_tests": total_tests,
            "passed_tests": passed_tests,
            "failed_tests": failed_tests,
            "success_rate": success_rate,
            "status": "PASSOU" if failed_tests == 0 else "FALHOU",
            "test_results": self.test_results
        }
        
        return report
        
    def run_all_tests(self) -> bool:
        """Executa todos os testes."""
        print("🚀 Iniciando Teste de Integração MCP com Trae")
        print("=" * 50)
        
        tests = [
            self.test_mcp_config_exists,
            self.test_mcp_config_valid,
            self.test_server_files_exist,
            self.test_python_environment,
            self.test_dependencies_installed,
            self.test_server_syntax,
            self.test_quality_check_script
        ]
        
        all_passed = True
        
        for test in tests:
            try:
                result = test()
                if not result:
                    all_passed = False
            except Exception as e:
                print(f"❌ ERRO no teste {test.__name__}: {e}")
                all_passed = False
                
            time.sleep(0.5)  # Pequena pausa entre testes
            
        print("\n" + "=" * 50)
        
        # Gerar relatório
        report = self.generate_report()
        
        # Salvar relatório
        report_file = self.project_root / "MCP_Integration" / "test_integration_report.json"
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
            
        # Exibir resumo
        print(f"📊 RESUMO DOS TESTES")
        print(f"   Total: {report['total_tests']}")
        print(f"   Passou: {report['passed_tests']} ✅")
        print(f"   Falhou: {report['failed_tests']} ❌")
        print(f"   Taxa de Sucesso: {report['success_rate']:.1f}%")
        print(f"   Duração: {report['duration_seconds']:.2f}s")
        print(f"   Status: {report['status']}")
        
        if all_passed:
            print("\n🎉 TODOS OS TESTES PASSARAM!")
            print("✅ MCP Code Checker está pronto para uso no Trae")
        else:
            print("\n⚠️  ALGUNS TESTES FALHARAM")
            print("❌ Verifique os erros acima antes de usar")
            
        print(f"\n📄 Relatório salvo em: {report_file}")
        
        return all_passed

def main():
    """Função principal."""
    tester = MCPTraeIntegrationTester()
    success = tester.run_all_tests()
    
    return 0 if success else 1

if __name__ == "__main__":
    sys.exit(main())