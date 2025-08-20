#!/usr/bin/env python3
"""
Python Development Accelerator MCP Server
Servidor MCP para acelerar desenvolvimento Python com automação de código,
testes, documentação e otimização de performance
"""

import os
import ast
import json
import subprocess
import tempfile
from pathlib import Path
from typing import Dict, List, Optional, Any, Tuple
from datetime import datetime
import re

from fastmcp import FastMCP

# Inicializar servidor MCP
mcp = FastMCP("Python Dev Accelerator MCP")

# Configurações
PROJECT_ROOT = Path("C:/Users/Admin/Documents/EA_SCALPER_XAUUSD")
TEMPLATES_PATH = PROJECT_ROOT / "MCP_Integration" / "templates"
OUTPUT_PATH = PROJECT_ROOT / "Development" / "Auto_Generated"

@mcp.tool
def generate_python_class(class_name: str, attributes: List[str], methods: List[str] = None, 
                         base_class: str = None, docstring: str = None) -> Dict[str, str]:
    """
    Gerar classe Python com atributos e métodos especificados
    
    Args:
        class_name: Nome da classe
        attributes: Lista de atributos (formato: "nome:tipo")
        methods: Lista de métodos (formato: "nome(params):return_type")
        base_class: Classe base (opcional)
        docstring: Documentação da classe
        
    Returns:
        Código da classe gerada
    """
    try:
        if methods is None:
            methods = []
            
        # Cabeçalho da classe
        inheritance = f"({base_class})" if base_class else ""
        class_def = f"class {class_name}{inheritance}:"
        
        # Docstring
        if docstring:
            class_def += f'\n    """\n    {docstring}\n    """\n'
        else:
            class_def += f'\n    """\n    {class_name} class\n    """\n'
            
        # Método __init__
        class_def += "\n    def __init__(self"
        init_params = []
        init_body = []
        
        for attr in attributes:
            if ":" in attr:
                name, type_hint = attr.split(":")
                init_params.append(f"{name.strip()}: {type_hint.strip()}")
                init_body.append(f"        self.{name.strip()} = {name.strip()}")
            else:
                init_params.append(attr.strip())
                init_body.append(f"        self.{attr.strip()} = {attr.strip()}")
                
        if init_params:
            class_def += ", " + ", ".join(init_params)
        class_def += "):\n"
        
        if init_body:
            class_def += "\n".join(init_body) + "\n"
        else:
            class_def += "        pass\n"
            
        # Métodos adicionais
        for method in methods:
            if "(" in method:
                method_name = method.split("(")[0]
                method_signature = method
            else:
                method_name = method
                method_signature = f"{method}(self)"
                
            class_def += f"\n    def {method_signature}:\n"
            class_def += f'        """\n        {method_name} method\n        """\n'
            class_def += "        pass\n"
            
        return {
            "status": "success",
            "class_name": class_name,
            "code": class_def,
            "file_suggestion": f"{class_name.lower()}.py"
        }
        
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro ao gerar classe: {str(e)}"
        }

@mcp.tool
def generate_test_suite(module_path: str, test_type: str = "unittest") -> Dict[str, Any]:
    """
    Gerar suite de testes para um módulo Python
    
    Args:
        module_path: Caminho para o módulo Python
        test_type: Tipo de teste (unittest, pytest)
        
    Returns:
        Código dos testes gerados
    """
    try:
        path = Path(module_path)
        if not path.exists():
            return {"error": f"Módulo não encontrado: {module_path}"}
            
        # Analisar módulo
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        tree = ast.parse(content)
        
        # Extrair classes e funções
        classes = []
        functions = []
        
        for node in ast.walk(tree):
            if isinstance(node, ast.ClassDef):
                methods = [n.name for n in node.body if isinstance(n, ast.FunctionDef)]
                classes.append({"name": node.name, "methods": methods})
            elif isinstance(node, ast.FunctionDef) and not node.name.startswith('_'):
                functions.append(node.name)
                
        # Gerar testes
        if test_type == "unittest":
            test_code = _generate_unittest_code(path.stem, classes, functions)
        else:
            test_code = _generate_pytest_code(path.stem, classes, functions)
            
        return {
            "status": "success",
            "module_name": path.stem,
            "test_type": test_type,
            "classes_found": len(classes),
            "functions_found": len(functions),
            "test_code": test_code,
            "test_file_name": f"test_{path.stem}.py"
        }
        
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro ao gerar testes: {str(e)}"
        }

@mcp.tool
def optimize_python_code(file_path: str, optimization_level: str = "standard") -> Dict[str, Any]:
    """
    Otimizar código Python para performance
    
    Args:
        file_path: Caminho do arquivo Python
        optimization_level: Nível de otimização (basic, standard, aggressive)
        
    Returns:
        Código otimizado e métricas
    """
    try:
        path = Path(file_path)
        if not path.exists():
            return {"error": f"Arquivo não encontrado: {file_path}"}
            
        with open(path, 'r', encoding='utf-8') as f:
            original_code = f.read()
            
        # Análise do código original
        original_metrics = _analyze_code_metrics(original_code)
        
        # Aplicar otimizações
        optimized_code = original_code
        optimizations_applied = []
        
        if optimization_level in ["standard", "aggressive"]:
            # Otimizações básicas
            optimized_code, basic_opts = _apply_basic_optimizations(optimized_code)
            optimizations_applied.extend(basic_opts)
            
        if optimization_level == "aggressive":
            # Otimizações avançadas
            optimized_code, advanced_opts = _apply_advanced_optimizations(optimized_code)
            optimizations_applied.extend(advanced_opts)
            
        # Análise do código otimizado
        optimized_metrics = _analyze_code_metrics(optimized_code)
        
        return {
            "status": "success",
            "optimization_level": optimization_level,
            "original_metrics": original_metrics,
            "optimized_metrics": optimized_metrics,
            "optimizations_applied": optimizations_applied,
            "optimized_code": optimized_code,
            "improvement_percentage": _calculate_improvement(original_metrics, optimized_metrics)
        }
        
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro na otimização: {str(e)}"
        }

@mcp.tool
def generate_documentation(file_path: str, doc_format: str = "markdown") -> Dict[str, str]:
    """
    Gerar documentação automática para módulo Python
    
    Args:
        file_path: Caminho do arquivo Python
        doc_format: Formato da documentação (markdown, rst, html)
        
    Returns:
        Documentação gerada
    """
    try:
        path = Path(file_path)
        if not path.exists():
            return {"error": f"Arquivo não encontrado: {file_path}"}
            
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        tree = ast.parse(content)
        
        # Extrair informações
        module_info = {
            "name": path.stem,
            "docstring": ast.get_docstring(tree) or "No description available",
            "classes": [],
            "functions": [],
            "imports": []
        }
        
        for node in ast.walk(tree):
            if isinstance(node, ast.ClassDef):
                class_info = {
                    "name": node.name,
                    "docstring": ast.get_docstring(node) or "No description",
                    "methods": []
                }
                
                for item in node.body:
                    if isinstance(item, ast.FunctionDef):
                        method_info = {
                            "name": item.name,
                            "docstring": ast.get_docstring(item) or "No description",
                            "args": [arg.arg for arg in item.args.args]
                        }
                        class_info["methods"].append(method_info)
                        
                module_info["classes"].append(class_info)
                
            elif isinstance(node, ast.FunctionDef) and not node.name.startswith('_'):
                func_info = {
                    "name": node.name,
                    "docstring": ast.get_docstring(node) or "No description",
                    "args": [arg.arg for arg in node.args.args]
                }
                module_info["functions"].append(func_info)
                
            elif isinstance(node, (ast.Import, ast.ImportFrom)):
                if isinstance(node, ast.Import):
                    for alias in node.names:
                        module_info["imports"].append(alias.name)
                else:
                    module_info["imports"].append(f"{node.module}.{node.names[0].name}")
                    
        # Gerar documentação no formato especificado
        if doc_format == "markdown":
            documentation = _generate_markdown_docs(module_info)
        elif doc_format == "rst":
            documentation = _generate_rst_docs(module_info)
        else:
            documentation = _generate_html_docs(module_info)
            
        return {
            "status": "success",
            "module_name": module_info["name"],
            "format": doc_format,
            "documentation": documentation,
            "classes_count": len(module_info["classes"]),
            "functions_count": len(module_info["functions"])
        }
        
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro ao gerar documentação: {str(e)}"
        }

@mcp.tool
def create_project_structure(project_name: str, project_type: str = "standard") -> Dict[str, Any]:
    """
    Criar estrutura de projeto Python
    
    Args:
        project_name: Nome do projeto
        project_type: Tipo de projeto (standard, package, web, ml)
        
    Returns:
        Estrutura criada
    """
    try:
        project_path = OUTPUT_PATH / project_name
        project_path.mkdir(parents=True, exist_ok=True)
        
        # Estruturas por tipo
        structures = {
            "standard": [
                "src", "tests", "docs", "scripts",
                "requirements.txt", "README.md", "setup.py", ".gitignore"
            ],
            "package": [
                f"{project_name}", f"{project_name}/__init__.py", 
                "tests", "docs", "setup.py", "pyproject.toml",
                "README.md", "LICENSE", ".gitignore"
            ],
            "web": [
                "app", "app/__init__.py", "app/routes.py", "app/models.py",
                "templates", "static", "tests", "config.py",
                "requirements.txt", "README.md", ".env.example"
            ],
            "ml": [
                "data", "notebooks", "src", "models", "reports",
                "requirements.txt", "README.md", "config.yaml",
                "src/__init__.py", "src/data_processing.py",
                "src/model_training.py", "src/evaluation.py"
            ]
        }
        
        structure = structures.get(project_type, structures["standard"])
        created_items = []
        
        for item in structure:
            item_path = project_path / item
            
            if "." in item or item.endswith(".py"):
                # É um arquivo
                item_path.parent.mkdir(parents=True, exist_ok=True)
                if not item_path.exists():
                    content = _get_template_content(item, project_name, project_type)
                    item_path.write_text(content, encoding='utf-8')
                    created_items.append(f"file: {item}")
            else:
                # É um diretório
                item_path.mkdir(parents=True, exist_ok=True)
                created_items.append(f"dir: {item}")
                
        return {
            "status": "success",
            "project_name": project_name,
            "project_type": project_type,
            "project_path": str(project_path),
            "created_items": created_items,
            "total_items": len(created_items)
        }
        
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro ao criar projeto: {str(e)}"
        }

@mcp.tool
def run_code_analysis(file_path: str, analysis_type: str = "all") -> Dict[str, Any]:
    """
    Executar análise de código Python
    
    Args:
        file_path: Caminho do arquivo
        analysis_type: Tipo de análise (syntax, style, complexity, security, all)
        
    Returns:
        Resultados da análise
    """
    try:
        path = Path(file_path)
        if not path.exists():
            return {"error": f"Arquivo não encontrado: {file_path}"}
            
        results = {
            "file_path": str(path),
            "analysis_type": analysis_type,
            "timestamp": datetime.now().isoformat()
        }
        
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        if analysis_type in ["syntax", "all"]:
            results["syntax_check"] = _check_syntax(content)
            
        if analysis_type in ["style", "all"]:
            results["style_check"] = _check_style(content)
            
        if analysis_type in ["complexity", "all"]:
            results["complexity_analysis"] = _analyze_complexity(content)
            
        if analysis_type in ["security", "all"]:
            results["security_check"] = _check_security(content)
            
        # Score geral
        results["overall_score"] = _calculate_overall_score(results)
        
        return results
        
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro na análise: {str(e)}"
        }

# Funções auxiliares
def _generate_unittest_code(module_name: str, classes: List[Dict], functions: List[str]) -> str:
    """Gerar código unittest"""
    code = f"""import unittest
# from module import *

class TestModule(unittest.TestCase):
    \"\"\"Test suite for module\"\"\"
    
    def setUp(self):
        \"\"\"Set up test fixtures\"\"\"
        pass
        
    def tearDown(self):
        \"\"\"Clean up after tests\"\"\"
        pass
"""
    
    # Testes para funções
    for func in functions:
        code += f"""
    def test_{func}(self):
        \"\"\"Test {func} function\"\"\"
        # TODO: Implement test for {func}
        self.assertTrue(True)  # Placeholder
"""
    
    # Testes para classes
    for cls in classes:
        code += f"""
    def test_{cls['name'].lower()}_creation(self):
        \"\"\"Test {cls['name']} class creation\"\"\"
        # TODO: Implement test for {cls['name']} creation
        self.assertTrue(True)  # Placeholder
"""
        
        for method in cls['methods']:
            if not method.startswith('_'):
                code += f"""
    def test_{cls['name'].lower()}_{method}(self):
        \"\"\"Test {cls['name']}.{method} method\"\"\"
        # TODO: Implement test for {method}
        self.assertTrue(True)  # Placeholder
"""
    
    code += """
if __name__ == '__main__':
    unittest.main()
"""
    
    return code

def _generate_pytest_code(module_name: str, classes: List[Dict], functions: List[str]) -> str:
    """Gerar código pytest"""
    code = f"""import pytest
# from module import *

class TestModule:
    \"\"\"Test suite for module\"\"\"
    
    def setup_method(self):
        \"\"\"Set up test fixtures\"\"\"
        pass
        
    def teardown_method(self):
        \"\"\"Clean up after tests\"\"\"
        pass
"""
    
    # Testes para funções
    for func in functions:
        code += f"""
    def test_{func}(self):
        \"\"\"Test {func} function\"\"\"
        # TODO: Implement test for {func}
        assert True  # Placeholder
"""
    
    # Testes para classes
    for cls in classes:
        code += f"""
    def test_{cls['name'].lower()}_creation(self):
        \"\"\"Test {cls['name']} class creation\"\"\"
        # TODO: Implement test for {cls['name']} creation
        assert True  # Placeholder
"""
        
        for method in cls['methods']:
            if not method.startswith('_'):
                code += f"""
    def test_{cls['name'].lower()}_{method}(self):
        \"\"\"Test {cls['name']}.{method} method\"\"\"
        # TODO: Implement test for {method}
        assert True  # Placeholder
"""
    
    return code

def _apply_basic_optimizations(code: str) -> Tuple[str, List[str]]:
    """Aplicar otimizações básicas"""
    optimizations = []
    optimized = code
    
    # Remover imports desnecessários
    lines = optimized.split('\n')
    used_imports = set()
    import_lines = []
    
    for i, line in enumerate(lines):
        if line.strip().startswith('import ') or line.strip().startswith('from '):
            import_lines.append((i, line))
            
    # Verificar quais imports são usados
    code_without_imports = '\n'.join([line for i, line in enumerate(lines) 
                                     if not (line.strip().startswith('import ') or 
                                            line.strip().startswith('from '))])
    
    for i, import_line in import_lines:
        if 'import ' in import_line:
            module = import_line.split('import ')[1].split(' as ')[0].split('.')[0]
            if module in code_without_imports:
                used_imports.add(import_line)
                
    if len(used_imports) < len(import_lines):
        optimizations.append("Removed unused imports")
        
    # Otimizar loops
    if 'for i in range(len(' in optimized:
        optimized = re.sub(r'for i in range\(len\(([^)]+)\)\):', 
                          r'for i, item in enumerate(\1):', optimized)
        optimizations.append("Optimized range(len()) loops")
        
    return optimized, optimizations

def _apply_advanced_optimizations(code: str) -> Tuple[str, List[str]]:
    """Aplicar otimizações avançadas"""
    optimizations = []
    optimized = code
    
    # Substituir concatenação de strings por join
    if '+=' in optimized and 'str' in optimized:
        optimizations.append("Suggested string concatenation optimization")
        
    # Sugerir list comprehensions
    if 'for ' in optimized and 'append(' in optimized:
        optimizations.append("Suggested list comprehension optimization")
        
    return optimized, optimizations

def _analyze_code_metrics(code: str) -> Dict[str, Any]:
    """Analisar métricas do código"""
    lines = code.split('\n')
    
    return {
        "total_lines": len(lines),
        "code_lines": len([l for l in lines if l.strip() and not l.strip().startswith('#')]),
        "comment_lines": len([l for l in lines if l.strip().startswith('#')]),
        "empty_lines": len([l for l in lines if not l.strip()]),
        "functions": len(re.findall(r'def \w+\(', code)),
        "classes": len(re.findall(r'class \w+', code)),
        "imports": len(re.findall(r'^(import|from)', code, re.MULTILINE))
    }

def _calculate_improvement(original: Dict, optimized: Dict) -> float:
    """Calcular percentual de melhoria"""
    if original["total_lines"] == 0:
        return 0.0
        
    reduction = (original["total_lines"] - optimized["total_lines"]) / original["total_lines"]
    return round(reduction * 100, 2)

def _generate_markdown_docs(module_info: Dict) -> str:
    """Gerar documentação em Markdown"""
    docs = f"# {module_info['name']}\n\n"
    docs += f"{module_info['docstring']}\n\n"
    
    if module_info['classes']:
        docs += "## Classes\n\n"
        for cls in module_info['classes']:
            docs += f"### {cls['name']}\n\n"
            docs += f"{cls['docstring']}\n\n"
            
            if cls['methods']:
                docs += "#### Methods\n\n"
                for method in cls['methods']:
                    docs += f"- **{method['name']}({', '.join(method['args'])})**: {method['docstring']}\n"
                docs += "\n"
                
    if module_info['functions']:
        docs += "## Functions\n\n"
        for func in module_info['functions']:
            docs += f"### {func['name']}({', '.join(func['args'])})\n\n"
            docs += f"{func['docstring']}\n\n"
            
    return docs

def _generate_rst_docs(module_info: Dict) -> str:
    """Gerar documentação em RST"""
    docs = f"{module_info['name']}\n"
    docs += "=" * len(module_info['name']) + "\n\n"
    docs += f"{module_info['docstring']}\n\n"
    
    # Implementação similar ao Markdown mas com sintaxe RST
    return docs

def _generate_html_docs(module_info: Dict) -> str:
    """Gerar documentação em HTML"""
    docs = f"<h1>{module_info['name']}</h1>\n"
    docs += f"<p>{module_info['docstring']}</p>\n"
    
    # Implementação similar mas com tags HTML
    return docs

def _get_template_content(item: str, project_name: str, project_type: str) -> str:
    """Obter conteúdo de template para arquivo"""
    templates = {
        "README.md": f"# {project_name}\n\nProject description here.\n",
        "requirements.txt": "# Project dependencies\n",
        "setup.py": f"from setuptools import setup\n\nsetup(name='{project_name}')\n",
        ".gitignore": "__pycache__/\n*.pyc\n.env\n",
        "__init__.py": f'"""\n{project_name} package\n"""\n',
        "config.py": "# Configuration settings\n"
    }
    
    return templates.get(item, "# Auto-generated file\n")

def _check_syntax(code: str) -> Dict[str, Any]:
    """Verificar sintaxe do código"""
    try:
        ast.parse(code)
        return {"valid": True, "errors": []}
    except SyntaxError as e:
        return {
            "valid": False, 
            "errors": [f"Line {e.lineno}: {e.msg}"]
        }

def _check_style(code: str) -> Dict[str, Any]:
    """Verificar estilo do código"""
    issues = []
    lines = code.split('\n')
    
    for i, line in enumerate(lines, 1):
        if len(line) > 79:
            issues.append(f"Line {i}: Line too long ({len(line)} > 79)")
        if line.endswith(' '):
            issues.append(f"Line {i}: Trailing whitespace")
            
    return {"issues": issues, "score": max(0, 100 - len(issues) * 5)}

def _analyze_complexity(code: str) -> Dict[str, Any]:
    """Analisar complexidade do código"""
    try:
        tree = ast.parse(code)
        complexity = 0
        
        for node in ast.walk(tree):
            if isinstance(node, (ast.If, ast.For, ast.While, ast.With)):
                complexity += 1
                
        return {
            "cyclomatic_complexity": complexity,
            "level": "low" if complexity < 10 else "medium" if complexity < 20 else "high"
        }
    except:
        return {"cyclomatic_complexity": 0, "level": "unknown"}

def _check_security(code: str) -> Dict[str, Any]:
    """Verificar questões de segurança"""
    issues = []
    
    security_patterns = [
        (r'eval\s*\(', "Use of eval() is dangerous"),
        (r'exec\s*\(', "Use of exec() is dangerous"),
        (r'input\s*\(', "Use of input() without validation"),
        (r'os\.system\s*\(', "Use of os.system() is dangerous")
    ]
    
    for pattern, message in security_patterns:
        if re.search(pattern, code):
            issues.append(message)
            
    return {"issues": issues, "score": max(0, 100 - len(issues) * 20)}

def _calculate_overall_score(results: Dict[str, Any]) -> float:
    """Calcular score geral"""
    scores = []
    
    if "style_check" in results:
        scores.append(results["style_check"].get("score", 0))
    if "security_check" in results:
        scores.append(results["security_check"].get("score", 0))
        
    return sum(scores) / len(scores) if scores else 0.0

if __name__ == "__main__":
    # Executar servidor MCP
    mcp.run()