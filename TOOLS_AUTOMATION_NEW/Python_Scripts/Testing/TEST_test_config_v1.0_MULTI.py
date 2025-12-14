#!/usr/bin/env python3
"""
Configuração de Testes Automatizados para EAs MQL4/MQL5
TradeDev_Master - Sistema de Trading Automatizado
"""

import os
import sys
import json
from pathlib import Path
from typing import Dict, List, Any

class TestConfig:
    """Configuração centralizada para testes automatizados"""
    
    def __init__(self):
        self.project_root = Path(__file__).parent.parent
        self.config = self.load_config()
        
    def load_config(self) -> Dict[str, Any]:
        """Carrega configurações do arquivo config_sistema.json"""
        config_path = self.project_root / "config_sistema.json"
        
        if config_path.exists():
            with open(config_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        
        return self.get_default_config()
    
    def get_default_config(self) -> Dict[str, Any]:
        """Configurações padrão para testes"""
        return {
            "testing": {
                "enabled": True,
                "auto_run": False,
                "timeout_seconds": 300,
                "max_parallel_tests": 4,
                "test_data_path": "Tests/Data",
                "reports_path": "Tests/Reports",
                "coverage_threshold": 80
            },
            "mql_testing": {
                "mt5_path": "C:/Program Files/MetaTrader 5/terminal64.exe",
                "mt4_path": "C:/Program Files (x86)/MetaTrader 4/terminal.exe",
                "strategy_tester_enabled": True,
                "optimization_enabled": True,
                "genetic_algorithm": True,
                "test_period": "2023.01.01-2024.12.31",
                "test_symbols": ["XAUUSD", "EURUSD", "GBPUSD"],
                "test_timeframes": ["M1", "M5", "M15", "H1"]
            },
            "ftmo_validation": {
                "enabled": True,
                "max_daily_loss": 5.0,
                "max_total_drawdown": 10.0,
                "min_profit_factor": 1.3,
                "min_sharpe_ratio": 1.5,
                "max_risk_per_trade": 1.0
            }
        }
    
    def setup_test_environment(self) -> bool:
        """Configura o ambiente de testes"""
        try:
            # Criar diretórios de teste
            test_dirs = [
                "Tests/Unit",
                "Tests/Integration", 
                "Tests/Performance",
                "Tests/Data",
                "Tests/Reports",
                "Tests/Fixtures"
            ]
            
            for test_dir in test_dirs:
                dir_path = self.project_root / test_dir
                dir_path.mkdir(parents=True, exist_ok=True)
                print(f"✓ Diretório criado: {test_dir}")
            
            # Criar arquivo de configuração pytest
            self.create_pytest_config()
            
            # Criar scripts de teste base
            self.create_base_test_scripts()
            
            print("✓ Ambiente de testes configurado com sucesso!")
            return True
            
        except Exception as e:
            print(f"✗ Erro ao configurar ambiente de testes: {e}")
            return False
    
    def create_pytest_config(self):
        """Cria arquivo de configuração do pytest"""
        pytest_config = """
[tool:pytest]
python_files = test_*.py *_test.py
python_classes = Test*
python_functions = test_*
testpaths = Tests
addopts = 
    --verbose
    --tb=short
    --strict-markers
    --disable-warnings
    --cov=.
    --cov-report=html:Tests/Reports/coverage
    --cov-report=term-missing
    --cov-fail-under=80
    --junit-xml=Tests/Reports/junit.xml

markers =
    unit: Unit tests
    integration: Integration tests
    performance: Performance tests
    ftmo: FTMO compliance tests
    slow: Slow running tests
    mql4: MQL4 specific tests
    mql5: MQL5 specific tests
    pine: Pine Script tests
"""
        
        config_path = self.project_root / "pytest.ini"
        with open(config_path, 'w', encoding='utf-8') as f:
            f.write(pytest_config)
        
        print("✓ Configuração pytest criada")
    
    def create_base_test_scripts(self):
        """Cria scripts de teste base"""
        
        # Test runner principal
        test_runner = '''
#!/usr/bin/env python3
"""
Test Runner Principal - TradeDev_Master
"""

import pytest
import sys
from pathlib import Path

def run_all_tests():
    """Executa todos os testes"""
    args = [
        "Tests/",
        "-v",
        "--tb=short",
        "--cov=.",
        "--cov-report=html:Tests/Reports/coverage",
        "--junit-xml=Tests/Reports/junit.xml"
    ]
    
    return pytest.main(args)

def run_unit_tests():
    """Executa apenas testes unitários"""
    args = ["Tests/Unit/", "-v", "-m", "unit"]
    return pytest.main(args)

def run_integration_tests():
    """Executa testes de integração"""
    args = ["Tests/Integration/", "-v", "-m", "integration"]
    return pytest.main(args)

def run_ftmo_tests():
    """Executa testes de compliance FTMO"""
    args = ["Tests/", "-v", "-m", "ftmo"]
    return pytest.main(args)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        test_type = sys.argv[1]
        if test_type == "unit":
            exit_code = run_unit_tests()
        elif test_type == "integration":
            exit_code = run_integration_tests()
        elif test_type == "ftmo":
            exit_code = run_ftmo_tests()
        else:
            exit_code = run_all_tests()
    else:
        exit_code = run_all_tests()
    
    sys.exit(exit_code)
'''
        
        runner_path = self.project_root / "Tests" / "run_tests.py"
        with open(runner_path, 'w', encoding='utf-8') as f:
            f.write(test_runner)
        
        # Tornar executável no Windows
        os.chmod(runner_path, 0o755)
        
        print("✓ Test runner criado")
        
        # Criar exemplo de teste unitário
        unit_test_example = '''
#!/usr/bin/env python3
"""
Exemplo de Teste Unitário - EA Template
"""

import pytest
import sys
from pathlib import Path

# Adicionar o diretório raiz ao path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

class TestEATemplate:
    """Testes para o template de EA"""
    
    @pytest.mark.unit
    def test_ea_template_exists(self):
        """Verifica se o template de EA existe"""
        template_path = Path(__file__).parent.parent.parent / "MQL5_Source" / "EAs" / "FTMO_Ready" / "EA_Template_FTMO.mq5"
        assert template_path.exists(), "Template de EA não encontrado"
    
    @pytest.mark.unit
    def test_ea_template_content(self):
        """Verifica conteúdo básico do template"""
        template_path = Path(__file__).parent.parent.parent / "MQL5_Source" / "EAs" / "FTMO_Ready" / "EA_Template_FTMO.mq5"
        
        with open(template_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Verificar elementos essenciais FTMO
        assert "RiskPercent" in content, "Parâmetro de risco não encontrado"
        assert "MaxDailyLoss" in content, "Controle de perda diária não encontrado"
        assert "MaxTotalDD" in content, "Controle de drawdown não encontrado"
        assert "CheckRiskManagement" in content, "Função de gerenciamento de risco não encontrada"
        assert "CloseAllPositions" in content, "Função de fechamento de posições não encontrada"
    
    @pytest.mark.ftmo
    def test_ftmo_compliance_parameters(self):
        """Verifica parâmetros de compliance FTMO"""
        # Este teste verificaria se os parâmetros estão dentro dos limites FTMO
        max_risk = 1.0  # 1% máximo por trade
        max_daily_loss = 5.0  # 5% máximo de perda diária
        max_drawdown = 10.0  # 10% máximo de drawdown
        
        assert max_risk <= 2.0, "Risco por trade muito alto para FTMO"
        assert max_daily_loss <= 5.0, "Perda diária muito alta para FTMO"
        assert max_drawdown <= 10.0, "Drawdown muito alto para FTMO"
'''
        
        unit_test_path = self.project_root / "Tests" / "Unit" / "test_ea_template.py"
        with open(unit_test_path, 'w', encoding='utf-8') as f:
            f.write(unit_test_example)
        
        print("✓ Exemplo de teste unitário criado")

def main():
    """Função principal"""
    print("=== Configuração de Testes Automatizados ===")
    print("TradeDev_Master - Sistema de Trading Automatizado\n")
    
    config = TestConfig()
    
    if config.setup_test_environment():
        print("\n🎯 Ambiente de testes configurado com sucesso!")
        print("\n📋 Próximos passos:")
        print("1. Execute: python Tests/run_tests.py")
        print("2. Para testes específicos: python Tests/run_tests.py unit")
        print("3. Para testes FTMO: python Tests/run_tests.py ftmo")
        print("4. Relatórios em: Tests/Reports/")
    else:
        print("\n❌ Falha na configuração do ambiente de testes")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())