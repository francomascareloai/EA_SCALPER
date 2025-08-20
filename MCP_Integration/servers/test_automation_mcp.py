#!/usr/bin/env python3
"""
Test Automation MCP Server
Servidor MCP para automação completa de testes, cobertura de código,
integração contínua e garantia de qualidade
"""

import os
import json
import subprocess
import tempfile
from pathlib import Path
from typing import Dict, List, Optional, Any, Tuple
from datetime import datetime
import re
import ast
import coverage
import pytest

from fastmcp import FastMCP

# Inicializar servidor MCP
mcp = FastMCP("Test Automation MCP")

# Configurações
PROJECT_ROOT = Path("C:/Users/Admin/Documents/EA_SCALPER_XAUUSD")
TEST_REPORTS_PATH = PROJECT_ROOT / "Test_Reports"
COVERAGE_PATH = PROJECT_ROOT / "Coverage_Reports"

@mcp.tool
def run_test_suite(test_path: str, test_type: str = "pytest", 
                  coverage_enabled: bool = True, 
                  generate_report: bool = True) -> Dict[str, Any]:
    """
    Executar suite de testes completa com cobertura
    
    Args:
        test_path: Caminho dos testes
        test_type: Tipo de teste (pytest, unittest, nose)
        coverage_enabled: Habilitar análise de cobertura
        generate_report: Gerar relatório detalhado
        
    Returns:
        Resultados dos testes e cobertura
    """
    try:
        test_path = Path(test_path)
        if not test_path.exists():
            return {"error": f"Caminho de teste não encontrado: {test_path}"}
            
        # Preparar diretórios
        TEST_REPORTS_PATH.mkdir(exist_ok=True)
        COVERAGE_PATH.mkdir(exist_ok=True)
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        report_file = TEST_REPORTS_PATH / f"test_report_{timestamp}.json"
        coverage_file = COVERAGE_PATH / f"coverage_{timestamp}.html"
        
        results = {
            "timestamp": timestamp,
            "test_path": str(test_path),
            "test_type": test_type,
            "coverage_enabled": coverage_enabled
        }
        
        if test_type == "pytest":
            results.update(_run_pytest(test_path, coverage_enabled, coverage_file))
        elif test_type == "unittest":
            results.update(_run_unittest(test_path, coverage_enabled))
        else:
            return {"error": f"Tipo de teste não suportado: {test_type}"}
            
        # Gerar relatório se solicitado
        if generate_report:
            _generate_test_report(results, report_file)
            results["report_file"] = str(report_file)
            
        return results
        
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro ao executar testes: {str(e)}"
        }

@mcp.tool
def analyze_test_coverage(source_path: str, test_path: str, 
                         min_coverage: float = 80.0) -> Dict[str, Any]:
    """
    Analisar cobertura de testes detalhada
    
    Args:
        source_path: Caminho do código fonte
        test_path: Caminho dos testes
        min_coverage: Cobertura mínima esperada (%)
        
    Returns:
        Análise detalhada de cobertura
    """
    try:
        source_path = Path(source_path)
        test_path = Path(test_path)
        
        if not source_path.exists() or not test_path.exists():
            return {"error": "Caminhos de origem ou teste não encontrados"}
            
        # Configurar coverage
        cov = coverage.Coverage()
        cov.start()
        
        # Executar testes
        pytest_args = [str(test_path), "-v", "--tb=short"]
        result = subprocess.run(["python", "-m", "pytest"] + pytest_args, 
                              capture_output=True, text=True, cwd=source_path.parent)
        
        cov.stop()
        cov.save()
        
        # Analisar cobertura
        coverage_data = cov.get_data()
        total_coverage = cov.report(show_missing=True)
        
        # Análise por arquivo
        file_coverage = {}
        for filename in coverage_data.measured_files():
            if source_path.name in filename or str(source_path) in filename:
                analysis = cov.analysis2(filename)
                executed_lines = len(analysis[1])
                missing_lines = len(analysis[3])
                total_lines = executed_lines + missing_lines
                
                if total_lines > 0:
                    file_coverage[filename] = {
                        "executed_lines": executed_lines,
                        "missing_lines": missing_lines,
                        "total_lines": total_lines,
                        "coverage_percent": (executed_lines / total_lines) * 100,
                        "missing_line_numbers": list(analysis[3])
                    }
                    
        # Gerar relatório HTML
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        html_report = COVERAGE_PATH / f"detailed_coverage_{timestamp}.html"
        cov.html_report(directory=str(html_report.parent), 
                       title=f"Coverage Report {timestamp}")
        
        return {
            "status": "success",
            "total_coverage": total_coverage,
            "min_coverage": min_coverage,
            "coverage_passed": total_coverage >= min_coverage,
            "file_coverage": file_coverage,
            "html_report": str(html_report),
            "test_output": result.stdout,
            "test_errors": result.stderr if result.returncode != 0 else None
        }
        
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro na análise de cobertura: {str(e)}"
        }

@mcp.tool
def generate_performance_tests(module_path: str, 
                              test_scenarios: List[str] = None) -> Dict[str, Any]:
    """
    Gerar testes de performance automatizados
    
    Args:
        module_path: Caminho do módulo a testar
        test_scenarios: Cenários específicos de teste
        
    Returns:
        Código de testes de performance
    """
    try:
        module_path = Path(module_path)
        if not module_path.exists():
            return {"error": f"Módulo não encontrado: {module_path}"}
            
        # Analisar módulo
        with open(module_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        tree = ast.parse(content)
        
        # Extrair funções para teste
        functions = []
        for node in ast.walk(tree):
            if isinstance(node, ast.FunctionDef) and not node.name.startswith('_'):
                # Analisar complexidade da função
                complexity = _calculate_function_complexity(node)
                functions.append({
                    "name": node.name,
                    "args": [arg.arg for arg in node.args.args],
                    "complexity": complexity
                })
                
        # Gerar código de teste de performance
        perf_test_code = _generate_performance_test_code(
            module_path.stem, functions, test_scenarios or []
        )
        
        # Salvar arquivo de teste
        test_file = module_path.parent / f"test_performance_{module_path.stem}.py"
        test_file.write_text(perf_test_code, encoding='utf-8')
        
        return {
            "status": "success",
            "module_name": module_path.stem,
            "functions_analyzed": len(functions),
            "test_file": str(test_file),
            "test_code": perf_test_code,
            "functions": functions
        }
        
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro ao gerar testes de performance: {str(e)}"
        }

@mcp.tool
def run_load_testing(target_function: str, module_path: str,
                    concurrent_users: int = 10, duration_seconds: int = 60,
                    ramp_up_time: int = 10) -> Dict[str, Any]:
    """
    Executar teste de carga em função específica
    
    Args:
        target_function: Nome da função a testar
        module_path: Caminho do módulo
        concurrent_users: Número de usuários simultâneos
        duration_seconds: Duração do teste em segundos
        ramp_up_time: Tempo de ramp-up em segundos
        
    Returns:
        Resultados do teste de carga
    """
    try:
        import threading
        import time
        import statistics
        from concurrent.futures import ThreadPoolExecutor, as_completed
        
        module_path = Path(module_path)
        if not module_path.exists():
            return {"error": f"Módulo não encontrado: {module_path}"}
            
        # Importar módulo dinamicamente
        import importlib.util
        spec = importlib.util.spec_from_file_location("test_module", module_path)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        
        if not hasattr(module, target_function):
            return {"error": f"Função '{target_function}' não encontrada no módulo"}
            
        target_func = getattr(module, target_function)
        
        # Configurar teste de carga
        results = {
            "target_function": target_function,
            "concurrent_users": concurrent_users,
            "duration_seconds": duration_seconds,
            "ramp_up_time": ramp_up_time,
            "start_time": datetime.now().isoformat()
        }
        
        # Métricas de performance
        response_times = []
        errors = []
        successful_requests = 0
        total_requests = 0
        
        def worker_function():
            nonlocal successful_requests, total_requests, response_times, errors
            
            start_time = time.time()
            end_time = start_time + duration_seconds
            
            while time.time() < end_time:
                request_start = time.time()
                try:
                    # Executar função (assumindo que não precisa de argumentos)
                    # Para funções com argumentos, seria necessário configurar dados de teste
                    result = target_func()
                    request_end = time.time()
                    
                    response_times.append(request_end - request_start)
                    successful_requests += 1
                    
                except Exception as e:
                    errors.append(str(e))
                    
                total_requests += 1
                time.sleep(0.01)  # Pequena pausa para evitar sobrecarga
                
        # Executar teste com ramp-up
        with ThreadPoolExecutor(max_workers=concurrent_users) as executor:
            futures = []
            
            for i in range(concurrent_users):
                # Ramp-up gradual
                if ramp_up_time > 0:
                    time.sleep(ramp_up_time / concurrent_users)
                    
                future = executor.submit(worker_function)
                futures.append(future)
                
            # Aguardar conclusão
            for future in as_completed(futures):
                future.result()
                
        # Calcular estatísticas
        if response_times:
            results.update({
                "total_requests": total_requests,
                "successful_requests": successful_requests,
                "failed_requests": len(errors),
                "success_rate": (successful_requests / total_requests) * 100 if total_requests > 0 else 0,
                "avg_response_time": statistics.mean(response_times),
                "min_response_time": min(response_times),
                "max_response_time": max(response_times),
                "median_response_time": statistics.median(response_times),
                "requests_per_second": total_requests / duration_seconds,
                "errors": errors[:10],  # Primeiros 10 erros
                "end_time": datetime.now().isoformat()
            })
        else:
            results["error"] = "Nenhuma resposta válida obtida"
            
        return results
        
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro no teste de carga: {str(e)}"
        }

@mcp.tool
def setup_ci_pipeline(project_path: str, ci_type: str = "github") -> Dict[str, Any]:
    """
    Configurar pipeline de integração contínua
    
    Args:
        project_path: Caminho do projeto
        ci_type: Tipo de CI (github, gitlab, jenkins)
        
    Returns:
        Configuração do pipeline criada
    """
    try:
        project_path = Path(project_path)
        if not project_path.exists():
            return {"error": f"Projeto não encontrado: {project_path}"}
            
        if ci_type == "github":
            config = _create_github_actions_config(project_path)
        elif ci_type == "gitlab":
            config = _create_gitlab_ci_config(project_path)
        else:
            return {"error": f"Tipo de CI não suportado: {ci_type}"}
            
        return {
            "status": "success",
            "ci_type": ci_type,
            "project_path": str(project_path),
            "config_file": config["file_path"],
            "config_content": config["content"]
        }
        
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro ao configurar CI: {str(e)}"
        }

@mcp.tool
def generate_test_data(data_type: str, count: int = 100, 
                      schema: Dict[str, str] = None) -> Dict[str, Any]:
    """
    Gerar dados de teste automaticamente
    
    Args:
        data_type: Tipo de dados (user, product, transaction, custom)
        count: Quantidade de registros
        schema: Schema personalizado para dados
        
    Returns:
        Dados de teste gerados
    """
    try:
        import random
        import string
        from faker import Faker
        
        fake = Faker('pt_BR')
        
        if data_type == "user":
            data = _generate_user_data(fake, count)
        elif data_type == "product":
            data = _generate_product_data(fake, count)
        elif data_type == "transaction":
            data = _generate_transaction_data(fake, count)
        elif data_type == "custom" and schema:
            data = _generate_custom_data(fake, count, schema)
        else:
            return {"error": f"Tipo de dados não suportado: {data_type}"}
            
        # Salvar dados
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        data_file = TEST_REPORTS_PATH / f"test_data_{data_type}_{timestamp}.json"
        
        with open(data_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False, default=str)
            
        return {
            "status": "success",
            "data_type": data_type,
            "count": len(data),
            "data_file": str(data_file),
            "sample_data": data[:3] if len(data) > 3 else data
        }
        
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro ao gerar dados de teste: {str(e)}"
        }

# Funções auxiliares
def _run_pytest(test_path: Path, coverage_enabled: bool, coverage_file: Path) -> Dict[str, Any]:
    """Executar pytest"""
    args = ["python", "-m", "pytest", str(test_path), "-v", "--tb=short", "--json-report", "--json-report-file=test_results.json"]
    
    if coverage_enabled:
        args.extend(["--cov=.", f"--cov-report=html:{coverage_file}"])
        
    result = subprocess.run(args, capture_output=True, text=True, cwd=test_path.parent)
    
    # Tentar carregar resultados JSON
    json_file = test_path.parent / "test_results.json"
    test_results = {}
    
    if json_file.exists():
        try:
            with open(json_file, 'r') as f:
                test_results = json.load(f)
        except:
            pass
            
    return {
        "exit_code": result.returncode,
        "stdout": result.stdout,
        "stderr": result.stderr,
        "test_results": test_results,
        "coverage_file": str(coverage_file) if coverage_enabled else None
    }

def _run_unittest(test_path: Path, coverage_enabled: bool) -> Dict[str, Any]:
    """Executar unittest"""
    args = ["python", "-m", "unittest", "discover", "-s", str(test_path), "-v"]
    
    result = subprocess.run(args, capture_output=True, text=True)
    
    return {
        "exit_code": result.returncode,
        "stdout": result.stdout,
        "stderr": result.stderr
    }

def _generate_test_report(results: Dict[str, Any], report_file: Path) -> None:
    """Gerar relatório de teste"""
    with open(report_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False, default=str)

def _calculate_function_complexity(node: ast.FunctionDef) -> int:
    """Calcular complexidade de função"""
    complexity = 1  # Base complexity
    
    for child in ast.walk(node):
        if isinstance(child, (ast.If, ast.For, ast.While, ast.With, ast.Try)):
            complexity += 1
        elif isinstance(child, ast.BoolOp):
            complexity += len(child.values) - 1
            
    return complexity

def _generate_performance_test_code(module_name: str, functions: List[Dict], scenarios: List[str]) -> str:
    """Gerar código de teste de performance"""
    code = """import time
import statistics
import pytest
# from module_name import *

class TestPerformanceModule:
    def setup_method(self):
        self.iterations = 1000
        self.timeout = 5.0  # seconds
"""
    
    for func in functions:
        func_name = func['name']
        complexity = func['complexity']
        
        # Ajustar número de iterações baseado na complexidade
        iterations = max(100, 1000 // complexity)
        
        code += f"""
    def test_{func_name}_performance(self):
        times = []
        
        for _ in range({iterations}):
            start_time = time.time()
            try:
                # TODO: Configurar argumentos apropriados
                result = {func_name}()  # Ajustar argumentos conforme necessário
                end_time = time.time()
                times.append(end_time - start_time)
            except Exception as e:
                pytest.fail(f"Function failed: {{e}}")
                
        if times:
            avg_time = statistics.mean(times)
            max_time = max(times)
            
            # Assertions baseadas na complexidade
            assert avg_time < {0.01 * complexity}, f"Average time too high: {{avg_time}}"
            assert max_time < {0.1 * complexity}, f"Max time too high: {{max_time}}"
            
            print(f"{{func_name}} - Avg: {{avg_time:.4f}}s, Max: {{max_time:.4f}}s")
"""
    
    # Adicionar cenários personalizados
    for scenario in scenarios:
        code += f"""
    def test_scenario_{scenario.lower().replace(' ', '_')}(self):
        # TODO: Implementar cenário {scenario}
        pass
"""
    
    return code

def _create_github_actions_config(project_path: Path) -> Dict[str, str]:
    """Criar configuração GitHub Actions"""
    workflows_dir = project_path / ".github" / "workflows"
    workflows_dir.mkdir(parents=True, exist_ok=True)
    
    config_file = workflows_dir / "ci.yml"
    
    config_content = """name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.8, 3.9, '3.10']
        
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v3
      with:
        python-version: ${{ matrix.python-version }}
        
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install pytest pytest-cov
        if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
        
    - name: Run tests with coverage
      run: |
        pytest --cov=. --cov-report=xml
        
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml
        flags: unittests
        name: codecov-umbrella
"""
    
    config_file.write_text(config_content, encoding='utf-8')
    
    return {
        "file_path": str(config_file),
        "content": config_content
    }

def _create_gitlab_ci_config(project_path: Path) -> Dict[str, str]:
    """Criar configuração GitLab CI"""
    config_file = project_path / ".gitlab-ci.yml"
    
    config_content = """stages:
  - test
  - coverage

variables:
  PIP_CACHE_DIR: "$CI_PROJECT_DIR/.cache/pip"

cache:
  paths:
    - .cache/pip/
    - venv/

before_script:
  - python -V
  - pip install virtualenv
  - virtualenv venv
  - source venv/bin/activate
  - pip install -r requirements.txt
  - pip install pytest pytest-cov

test:
  stage: test
  script:
    - pytest --cov=. --cov-report=xml --cov-report=html
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml
    paths:
      - htmlcov/
  coverage: '/TOTAL.+ ([0-9]{1,3}%)$/'
"""
    
    config_file.write_text(config_content, encoding='utf-8')
    
    return {
        "file_path": str(config_file),
        "content": config_content
    }

def _generate_user_data(fake, count: int) -> List[Dict]:
    """Gerar dados de usuário"""
    return [
        {
            "id": i + 1,
            "name": fake.name(),
            "email": fake.email(),
            "phone": fake.phone_number(),
            "address": fake.address(),
            "birth_date": fake.date_of_birth().isoformat(),
            "created_at": fake.date_time_this_year().isoformat()
        }
        for i in range(count)
    ]

def _generate_product_data(fake, count: int) -> List[Dict]:
    """Gerar dados de produto"""
    categories = ['Electronics', 'Clothing', 'Books', 'Home', 'Sports']
    
    return [
        {
            "id": i + 1,
            "name": fake.catch_phrase(),
            "description": fake.text(max_nb_chars=200),
            "price": round(fake.random.uniform(10.0, 1000.0), 2),
            "category": fake.random.choice(categories),
            "stock": fake.random.randint(0, 100),
            "created_at": fake.date_time_this_year().isoformat()
        }
        for i in range(count)
    ]

def _generate_transaction_data(fake, count: int) -> List[Dict]:
    """Gerar dados de transação"""
    return [
        {
            "id": i + 1,
            "user_id": fake.random.randint(1, 100),
            "product_id": fake.random.randint(1, 50),
            "amount": round(fake.random.uniform(10.0, 500.0), 2),
            "quantity": fake.random.randint(1, 5),
            "status": fake.random.choice(['pending', 'completed', 'cancelled']),
            "created_at": fake.date_time_this_year().isoformat()
        }
        for i in range(count)
    ]

def _generate_custom_data(fake, count: int, schema: Dict[str, str]) -> List[Dict]:
    """Gerar dados personalizados baseado no schema"""
    data = []
    
    for i in range(count):
        record = {"id": i + 1}
        
        for field, field_type in schema.items():
            if field_type == "string":
                record[field] = fake.text(max_nb_chars=50)
            elif field_type == "email":
                record[field] = fake.email()
            elif field_type == "number":
                record[field] = fake.random.randint(1, 1000)
            elif field_type == "float":
                record[field] = round(fake.random.uniform(0.0, 100.0), 2)
            elif field_type == "date":
                record[field] = fake.date().isoformat()
            elif field_type == "datetime":
                record[field] = fake.date_time().isoformat()
            else:
                record[field] = fake.word()
                
        data.append(record)
        
    return data

if __name__ == "__main__":
    # Executar servidor MCP
    mcp.run()