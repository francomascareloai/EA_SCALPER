
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
