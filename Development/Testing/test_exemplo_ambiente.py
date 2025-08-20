#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Teste de exemplo para verificar o ambiente
"""

import pytest
import sys
from pathlib import Path

def test_python_version():
    """Testa se a versão do Python é adequada"""
    assert sys.version_info >= (3, 8), "Python 3.8+ é necessário"

def test_pathlib_funcionando():
    """Testa se pathlib está funcionando"""
    current_dir = Path.cwd()
    assert current_dir.exists()
    assert current_dir.is_dir()

def test_imports_basicos():
    """Testa imports básicos do sistema"""
    import json
    import os
    import datetime
    assert True  # Se chegou aqui, os imports funcionaram

@pytest.mark.slow
def test_exemplo_lento():
    """Exemplo de teste marcado como lento"""
    import time
    time.sleep(0.1)  # Simula operação lenta
    assert True

if __name__ == "__main__":
    # Executa os testes se chamado diretamente
    pytest.main([__file__, "-v"])
