#!/usr/bin/env python3
"""
EA FTMO Scalper Elite - Unit Tests Framework
Framework de testes unitários para validação dos módulos
"""

import os
import re
import json
from pathlib import Path
from datetime import datetime

class EAUnitTester:
    def __init__(self):
        self.test_results = {
            "timestamp": datetime.now().isoformat(),
            "total_tests": 0,
            "passed": 0,
            "failed": 0,
            "warnings": 0,
            "modules": {}
        }
        
    def log_test(self, module, test_name, status, message=""):
        """Registra resultado de um teste"""
        if module not in self.test_results["modules"]:
            self.test_results["modules"][module] = {
                "tests": [],
                "passed": 0,
                "failed": 0,
                "warnings": 0
            }
        
        self.test_results["modules"][module]["tests"].append({
            "name": test_name,
            "status": status,
            "message": message
        })
        
        self.test_results["modules"][module][status] += 1
        self.test_results[status] += 1
        self.test_results["total_tests"] += 1
        
        # Print resultado
        status_icon = {"passed": "✅", "failed": "❌", "warnings": "⚠️"}
        print(f"  {status_icon[status]} {test_name}: {message}")

    def test_file_structure(self):
        """Testa estrutura de arquivos"""
        print("\n🔍 TESTE 1: ESTRUTURA DE ARQUIVOS")
        print("-" * 50)
        
        required_files = [
            "MQL5_Source/EA_FTMO_Scalper_Elite.mq5",
            "MQL5_Source/Source/Core/DataStructures.mqh",
            "MQL5_Source/Source/Core/Interfaces.mqh",
            "MQL5_Source/Source/Core/Logger.mqh",
            "MQL5_Source/Source/Core/ConfigManager.mqh",
            "MQL5_Source/Source/Core/CacheManager.mqh",
            "MQL5_Source/Source/Core/PerformanceAnalyzer.mqh",
            "MQL5_Source/Source/Strategies/ICT/OrderBlockDetector.mqh",
            "MQL5_Source/Source/Strategies/ICT/FVGDetector.mqh",
            "MQL5_Source/Source/Strategies/ICT/LiquidityDetector.mqh",
            "MQL5_Source/Source/Strategies/ICT/MarketStructureAnalyzer.mqh"
        ]
        
        for file_path in required_files:
            path = Path(file_path)
            if path.exists():
                size = path.stat().st_size
                if size > 1000:  # Arquivo deve ter pelo menos 1KB
                    self.log_test("structure", f"File {path.name}", "passed", f"{size} bytes")
                else:
                    self.log_test("structure", f"File {path.name}", "warnings", f"Muito pequeno: {size} bytes")
            else:
                self.log_test("structure", f"File {path.name}", "failed", "Arquivo não encontrado")

    def test_includes_dependencies(self):
        """Testa dependências de includes"""
        print("\n🔗 TESTE 2: DEPENDÊNCIAS DE INCLUDES")
        print("-" * 50)
        
        ea_file = Path("MQL5_Source/EA_FTMO_Scalper_Elite.mq5")
        if not ea_file.exists():
            self.log_test("includes", "EA Principal", "failed", "Arquivo não encontrado")
            return
        
        with open(ea_file, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        # Extrair includes
        includes = re.findall(r'#include\s+"([^"]+)"', content)
        
        for include in includes:
            include_path = Path("MQL5_Source") / include
            if include_path.exists():
                self.log_test("includes", f"Include {include}", "passed", "Encontrado")
            else:
                self.log_test("includes", f"Include {include}", "failed", "Não encontrado")

    def test_ftmo_compliance(self):
        """Testa compliance FTMO"""
        print("\n🛡️  TESTE 3: FTMO COMPLIANCE")
        print("-" * 50)
        
        ea_file = Path("MQL5_Source/EA_FTMO_Scalper_Elite.mq5")
        if not ea_file.exists():
            self.log_test("ftmo", "EA Principal", "failed", "Arquivo não encontrado")
            return
        
        with open(ea_file, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        # Testes FTMO obrigatórios
        ftmo_tests = [
            ("Max_Risk_Per_Trade", "Risco por trade definido"),
            ("Daily_Loss_Limit", "Limite de perda diária"),
            ("Max_Drawdown_Limit", "Limite de drawdown"),
            ("StopLoss", "Stop Loss obrigatório"),
            ("TakeProfit", "Take Profit configurado"),
            ("News_Filter", "Filtro de notícias")
        ]
        
        for pattern, description in ftmo_tests:
            if pattern in content:
                self.log_test("ftmo", description, "passed", f"Padrão '{pattern}' encontrado")
            else:
                self.log_test("ftmo", description, "warnings", f"Padrão '{pattern}' não encontrado")
        
        # Verificar padrões proibidos
        forbidden_patterns = ["martingale", "grid", "recovery"]
        for pattern in forbidden_patterns:
            if pattern.lower() in content.lower():
                self.log_test("ftmo", f"Padrão proibido: {pattern}", "failed", "Encontrado no código")
            else:
                self.log_test("ftmo", f"Ausência de {pattern}", "passed", "Padrão proibido não encontrado")

    def test_class_definitions(self):
        """Testa definições de classes"""
        print("\n🏗️  TESTE 4: DEFINIÇÕES DE CLASSES")
        print("-" * 50)
        
        expected_classes = [
            ("COrderBlockDetector", "OrderBlockDetector.mqh"),
            ("CFVGDetector", "FVGDetector.mqh"),
            ("CLiquidityDetector", "LiquidityDetector.mqh"),
            ("CMarketStructureAnalyzer", "MarketStructureAnalyzer.mqh"),
            ("CLogger", "Logger.mqh"),
            ("CConfigManager", "ConfigManager.mqh"),
            ("CCacheManager", "CacheManager.mqh"),
            ("CPerformanceAnalyzer", "PerformanceAnalyzer.mqh")
        ]
        
        for class_name, file_name in expected_classes:
            # Procurar arquivo
            file_found = False
            for root, dirs, files in os.walk("MQL5_Source/Source"):
                if file_name in files:
                    file_path = Path(root) / file_name
                    file_found = True
                    
                    # Verificar se classe está definida
                    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                        content = f.read()
                    
                    if f"class {class_name}" in content:
                        self.log_test("classes", f"Classe {class_name}", "passed", f"Definida em {file_name}")
                    else:
                        self.log_test("classes", f"Classe {class_name}", "failed", f"Não encontrada em {file_name}")
                    break
            
            if not file_found:
                self.log_test("classes", f"Arquivo {file_name}", "failed", "Arquivo não encontrado")

    def test_function_signatures(self):
        """Testa assinaturas de funções principais"""
        print("\n⚙️  TESTE 5: FUNÇÕES PRINCIPAIS")
        print("-" * 50)
        
        ea_file = Path("MQL5_Source/EA_FTMO_Scalper_Elite.mq5")
        if not ea_file.exists():
            self.log_test("functions", "EA Principal", "failed", "Arquivo não encontrado")
            return
        
        with open(ea_file, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        required_functions = [
            ("OnInit()", "Função de inicialização"),
            ("OnTick()", "Função principal de trading"),
            ("OnDeinit(", "Função de finalização"),
            ("OnTimer()", "Função de timer")
        ]
        
        for func_pattern, description in required_functions:
            if func_pattern in content:
                self.log_test("functions", description, "passed", f"Função {func_pattern} encontrada")
            else:
                self.log_test("functions", description, "failed", f"Função {func_pattern} não encontrada")

    def test_input_parameters(self):
        """Testa parâmetros de entrada"""
        print("\n📊 TESTE 6: PARÂMETROS DE ENTRADA")
        print("-" * 50)
        
        ea_file = Path("MQL5_Source/EA_FTMO_Scalper_Elite.mq5")
        if not ea_file.exists():
            self.log_test("parameters", "EA Principal", "failed", "Arquivo não encontrado")
            return
        
        with open(ea_file, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        # Contar parâmetros input
        input_count = len(re.findall(r'input\s+\w+', content))
        
        if input_count >= 10:
            self.log_test("parameters", "Quantidade de inputs", "passed", f"{input_count} parâmetros encontrados")
        elif input_count >= 5:
            self.log_test("parameters", "Quantidade de inputs", "warnings", f"Apenas {input_count} parâmetros")
        else:
            self.log_test("parameters", "Quantidade de inputs", "failed", f"Muito poucos: {input_count}")
        
        # Verificar grupos de parâmetros
        expected_groups = [
            "CONFIGURAÇÕES GERAIS",
            "GESTÃO DE RISCO FTMO",
            "CONFIGURAÇÕES ICT/SMC"
        ]
        
        for group in expected_groups:
            if group in content:
                self.log_test("parameters", f"Grupo {group}", "passed", "Grupo encontrado")
            else:
                self.log_test("parameters", f"Grupo {group}", "warnings", "Grupo não encontrado")

    def generate_report(self):
        """Gera relatório final"""
        print("\n" + "=" * 60)
        print("📋 RELATÓRIO FINAL DE TESTES UNITÁRIOS")
        print("=" * 60)
        
        total = self.test_results["total_tests"]
        passed = self.test_results["passed"]
        failed = self.test_results["failed"]
        warnings = self.test_results["warnings"]
        
        print(f"📊 ESTATÍSTICAS GERAIS:")
        print(f"  • Total de testes: {total}")
        print(f"  • ✅ Aprovados: {passed} ({passed/total*100:.1f}%)")
        print(f"  • ❌ Falharam: {failed} ({failed/total*100:.1f}%)")
        print(f"  • ⚠️  Avisos: {warnings} ({warnings/total*100:.1f}%)")
        
        print(f"\n📋 RESUMO POR MÓDULO:")
        for module, data in self.test_results["modules"].items():
            total_mod = len(data["tests"])
            passed_mod = data["passed"]
            print(f"  • {module.upper()}: {passed_mod}/{total_mod} aprovados")
        
        # Determinar status geral
        if failed == 0 and warnings <= total * 0.2:  # Máximo 20% de warnings
            status = "✅ APROVADO"
            next_step = "Pronto para Strategy Tester"
        elif failed <= total * 0.1:  # Máximo 10% de falhas
            status = "⚠️  APROVADO COM RESSALVAS"
            next_step = "Corrigir avisos antes do Strategy Tester"
        else:
            status = "❌ REPROVADO"
            next_step = "Corrigir erros antes de prosseguir"
        
        print(f"\n🎯 STATUS FINAL: {status}")
        print(f"📋 PRÓXIMO PASSO: {next_step}")
        
        # Salvar relatório JSON
        with open("unit_test_report.json", "w", encoding="utf-8") as f:
            json.dump(self.test_results, f, indent=2, ensure_ascii=False)
        
        print(f"\n💾 Relatório salvo em: unit_test_report.json")
        
        return failed == 0

    def run_all_tests(self):
        """Executa todos os testes"""
        print("🧪 EA FTMO SCALPER ELITE - TESTES UNITÁRIOS")
        print("=" * 60)
        print(f"📅 Data/Hora: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        
        # Executar todos os testes
        self.test_file_structure()
        self.test_includes_dependencies()
        self.test_ftmo_compliance()
        self.test_class_definitions()
        self.test_function_signatures()
        self.test_input_parameters()
        
        # Gerar relatório
        return self.generate_report()

def main():
    """Função principal"""
    tester = EAUnitTester()
    success = tester.run_all_tests()
    
    print("\n" + "=" * 60)
    exit(0 if success else 1)

if __name__ == "__main__":
    main()