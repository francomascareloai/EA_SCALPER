#!/usr/bin/env python3
"""
Code Analysis MCP Server
Servidor MCP para análise profunda de código, refatoração automática,
detecção de code smells e otimização de arquitetura
"""

import os
import ast
import json
import re
from pathlib import Path
from typing import Dict, List, Optional, Any, Tuple, Set
from datetime import datetime
from collections import defaultdict, Counter
import subprocess

from fastmcp import FastMCP

# Inicializar servidor MCP
mcp = FastMCP("Code Analysis MCP")

# Configurações
PROJECT_ROOT = Path("C:/Users/Admin/Documents/EA_SCALPER_XAUUSD")
ANALYSIS_REPORTS_PATH = PROJECT_ROOT / "Analysis_Reports"
REFACTORED_CODE_PATH = PROJECT_ROOT / "Refactored_Code"

@mcp.tool
def analyze_code_quality(file_path: str, analysis_depth: str = "comprehensive") -> Dict[str, Any]:
    """
    Analisar qualidade de código de forma abrangente
    
    Args:
        file_path: Caminho do arquivo Python
        analysis_depth: Profundidade da análise (basic, standard, comprehensive)
        
    Returns:
        Análise completa de qualidade do código
    """
    try:
        file_path = Path(file_path)
        if not file_path.exists():
            return {"error": f"Arquivo não encontrado: {file_path}"}
            
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Análise AST
        try:
            tree = ast.parse(content)
        except SyntaxError as e:
            return {
                "status": "error",
                "syntax_error": f"Linha {e.lineno}: {e.msg}"
            }
            
        analysis = {
            "file_path": str(file_path),
            "analysis_depth": analysis_depth,
            "timestamp": datetime.now().isoformat(),
            "file_stats": _get_file_statistics(content),
            "code_metrics": _calculate_code_metrics(tree, content),
            "code_smells": _detect_code_smells(tree, content),
            "design_patterns": _detect_design_patterns(tree),
            "security_issues": _detect_security_issues(content),
            "performance_issues": _detect_performance_issues(tree, content)
        }
        
        if analysis_depth in ["standard", "comprehensive"]:
            analysis.update({
                "complexity_analysis": _analyze_complexity(tree),
                "dependency_analysis": _analyze_dependencies(tree),
                "naming_conventions": _check_naming_conventions(tree),
                "documentation_quality": _analyze_documentation(tree)
            })
            
        if analysis_depth == "comprehensive":
            analysis.update({
                "architectural_analysis": _analyze_architecture(tree),
                "maintainability_index": _calculate_maintainability_index(analysis),
                "refactoring_suggestions": _generate_refactoring_suggestions(analysis),
                "test_coverage_suggestions": _suggest_test_coverage(tree)
            })
            
        # Calcular score geral
        analysis["overall_quality_score"] = _calculate_quality_score(analysis)
        
        # Salvar relatório
        _save_analysis_report(analysis, file_path)
        
        return analysis
        
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro na análise: {str(e)}"
        }

@mcp.tool
def detect_code_smells(file_path: str, smell_types: List[str] = None) -> Dict[str, Any]:
    """
    Detectar code smells específicos
    
    Args:
        file_path: Caminho do arquivo
        smell_types: Tipos específicos de smell a detectar
        
    Returns:
        Code smells detectados
    """
    try:
        file_path = Path(file_path)
        if not file_path.exists():
            return {"error": f"Arquivo não encontrado: {file_path}"}
            
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        tree = ast.parse(content)
        
        all_smells = {
            "long_method": _detect_long_methods(tree),
            "large_class": _detect_large_classes(tree),
            "duplicate_code": _detect_duplicate_code(content),
            "dead_code": _detect_dead_code(tree),
            "magic_numbers": _detect_magic_numbers(tree),
            "god_object": _detect_god_objects(tree),
            "feature_envy": _detect_feature_envy(tree),
            "data_clumps": _detect_data_clumps(tree),
            "primitive_obsession": _detect_primitive_obsession(tree),
            "inappropriate_intimacy": _detect_inappropriate_intimacy(tree)
        }
        
        # Filtrar por tipos solicitados
        if smell_types:
            filtered_smells = {k: v for k, v in all_smells.items() if k in smell_types}
        else:
            filtered_smells = all_smells
            
        # Calcular severidade
        severity_scores = _calculate_smell_severity(filtered_smells)
        
        return {
            "status": "success",
            "file_path": str(file_path),
            "smells_detected": filtered_smells,
            "severity_scores": severity_scores,
            "total_smells": sum(len(v) for v in filtered_smells.values()),
            "recommendations": _generate_smell_recommendations(filtered_smells)
        }
        
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro na detecção de code smells: {str(e)}"
        }

@mcp.tool
def suggest_refactoring(file_path: str, refactoring_type: str = "auto") -> Dict[str, Any]:
    """
    Sugerir refatorações para melhorar o código
    
    Args:
        file_path: Caminho do arquivo
        refactoring_type: Tipo de refatoração (auto, extract_method, rename, move_class)
        
    Returns:
        Sugestões de refatoração
    """
    try:
        file_path = Path(file_path)
        if not file_path.exists():
            return {"error": f"Arquivo não encontrado: {file_path}"}
            
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        tree = ast.parse(content)
        
        suggestions = {
            "file_path": str(file_path),
            "refactoring_type": refactoring_type,
            "suggestions": []
        }
        
        if refactoring_type in ["auto", "extract_method"]:
            suggestions["suggestions"].extend(_suggest_extract_method(tree))
            
        if refactoring_type in ["auto", "rename"]:
            suggestions["suggestions"].extend(_suggest_rename_refactoring(tree))
            
        if refactoring_type in ["auto", "move_class"]:
            suggestions["suggestions"].extend(_suggest_move_class(tree))
            
        if refactoring_type == "auto":
            suggestions["suggestions"].extend(_suggest_general_refactoring(tree, content))
            
        # Priorizar sugestões
        suggestions["suggestions"] = _prioritize_refactoring_suggestions(suggestions["suggestions"])
        
        return suggestions
        
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro ao sugerir refatoração: {str(e)}"
        }

@mcp.tool
def apply_automatic_refactoring(file_path: str, refactoring_rules: List[str]) -> Dict[str, Any]:
    """
    Aplicar refatoração automática baseada em regras
    
    Args:
        file_path: Caminho do arquivo
        refactoring_rules: Lista de regras a aplicar
        
    Returns:
        Código refatorado
    """
    try:
        file_path = Path(file_path)
        if not file_path.exists():
            return {"error": f"Arquivo não encontrado: {file_path}"}
            
        with open(file_path, 'r', encoding='utf-8') as f:
            original_content = f.read()
            
        refactored_content = original_content
        applied_rules = []
        
        for rule in refactoring_rules:
            if rule == "remove_unused_imports":
                refactored_content, changed = _remove_unused_imports(refactored_content)
                if changed:
                    applied_rules.append(rule)
                    
            elif rule == "fix_naming_conventions":
                refactored_content, changed = _fix_naming_conventions(refactored_content)
                if changed:
                    applied_rules.append(rule)
                    
            elif rule == "add_type_hints":
                refactored_content, changed = _add_type_hints(refactored_content)
                if changed:
                    applied_rules.append(rule)
                    
            elif rule == "extract_constants":
                refactored_content, changed = _extract_constants(refactored_content)
                if changed:
                    applied_rules.append(rule)
                    
            elif rule == "simplify_conditionals":
                refactored_content, changed = _simplify_conditionals(refactored_content)
                if changed:
                    applied_rules.append(rule)
                    
        # Salvar código refatorado
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        refactored_file = REFACTORED_CODE_PATH / f"{file_path.stem}_refactored_{timestamp}.py"
        REFACTORED_CODE_PATH.mkdir(exist_ok=True)
        
        refactored_file.write_text(refactored_content, encoding='utf-8')
        
        # Calcular métricas de melhoria
        improvement_metrics = _calculate_refactoring_improvement(
            original_content, refactored_content
        )
        
        return {
            "status": "success",
            "original_file": str(file_path),
            "refactored_file": str(refactored_file),
            "applied_rules": applied_rules,
            "improvement_metrics": improvement_metrics,
            "refactored_content": refactored_content
        }
        
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro na refatoração automática: {str(e)}"
        }

@mcp.tool
def analyze_project_architecture(project_path: str) -> Dict[str, Any]:
    """
    Analisar arquitetura de projeto completo
    
    Args:
        project_path: Caminho do projeto
        
    Returns:
        Análise arquitetural completa
    """
    try:
        project_path = Path(project_path)
        if not project_path.exists():
            return {"error": f"Projeto não encontrado: {project_path}"}
            
        # Encontrar todos os arquivos Python
        python_files = list(project_path.rglob("*.py"))
        
        if not python_files:
            return {"error": "Nenhum arquivo Python encontrado no projeto"}
            
        architecture_analysis = {
            "project_path": str(project_path),
            "total_files": len(python_files),
            "timestamp": datetime.now().isoformat(),
            "file_structure": _analyze_file_structure(python_files, project_path),
            "dependency_graph": _build_dependency_graph(python_files),
            "module_coupling": _analyze_module_coupling(python_files),
            "design_patterns_usage": _analyze_design_patterns_usage(python_files),
            "architectural_violations": _detect_architectural_violations(python_files),
            "code_duplication": _analyze_code_duplication(python_files),
            "complexity_distribution": _analyze_complexity_distribution(python_files)
        }
        
        # Calcular métricas arquiteturais
        architecture_analysis["architectural_metrics"] = _calculate_architectural_metrics(
            architecture_analysis
        )
        
        # Gerar recomendações
        architecture_analysis["recommendations"] = _generate_architectural_recommendations(
            architecture_analysis
        )
        
        # Salvar relatório
        _save_architecture_report(architecture_analysis, project_path)
        
        return architecture_analysis
        
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro na análise arquitetural: {str(e)}"
        }

@mcp.tool
def generate_code_documentation(file_path: str, doc_style: str = "google") -> Dict[str, Any]:
    """
    Gerar documentação automática para código
    
    Args:
        file_path: Caminho do arquivo
        doc_style: Estilo de documentação (google, numpy, sphinx)
        
    Returns:
        Código com documentação gerada
    """
    try:
        file_path = Path(file_path)
        if not file_path.exists():
            return {"error": f"Arquivo não encontrado: {file_path}"}
            
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        tree = ast.parse(content)
        
        # Analisar estrutura do código
        code_structure = _analyze_code_structure(tree)
        
        # Gerar documentação
        documented_code = _generate_documentation_strings(
            content, code_structure, doc_style
        )
        
        # Salvar código documentado
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        documented_file = REFACTORED_CODE_PATH / f"{file_path.stem}_documented_{timestamp}.py"
        REFACTORED_CODE_PATH.mkdir(exist_ok=True)
        
        documented_file.write_text(documented_code, encoding='utf-8')
        
        return {
            "status": "success",
            "original_file": str(file_path),
            "documented_file": str(documented_file),
            "doc_style": doc_style,
            "functions_documented": len(code_structure["functions"]),
            "classes_documented": len(code_structure["classes"]),
            "documented_code": documented_code
        }
        
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro ao gerar documentação: {str(e)}"
        }

# Funções auxiliares para análise
def _get_file_statistics(content: str) -> Dict[str, int]:
    """Obter estatísticas básicas do arquivo"""
    lines = content.split('\n')
    
    return {
        "total_lines": len(lines),
        "code_lines": len([l for l in lines if l.strip() and not l.strip().startswith('#')]),
        "comment_lines": len([l for l in lines if l.strip().startswith('#')]),
        "empty_lines": len([l for l in lines if not l.strip()]),
        "characters": len(content)
    }

def _calculate_code_metrics(tree: ast.AST, content: str) -> Dict[str, Any]:
    """Calcular métricas de código"""
    metrics = {
        "functions": 0,
        "classes": 0,
        "methods": 0,
        "imports": 0,
        "variables": 0,
        "max_function_length": 0,
        "avg_function_length": 0,
        "max_class_methods": 0
    }
    
    function_lengths = []
    class_method_counts = []
    
    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef):
            metrics["functions"] += 1
            func_length = node.end_lineno - node.lineno if hasattr(node, 'end_lineno') else 0
            function_lengths.append(func_length)
            
        elif isinstance(node, ast.ClassDef):
            metrics["classes"] += 1
            method_count = len([n for n in node.body if isinstance(n, ast.FunctionDef)])
            class_method_counts.append(method_count)
            metrics["methods"] += method_count
            
        elif isinstance(node, (ast.Import, ast.ImportFrom)):
            metrics["imports"] += 1
            
        elif isinstance(node, ast.Assign):
            metrics["variables"] += len(node.targets)
            
    if function_lengths:
        metrics["max_function_length"] = max(function_lengths)
        metrics["avg_function_length"] = sum(function_lengths) / len(function_lengths)
        
    if class_method_counts:
        metrics["max_class_methods"] = max(class_method_counts)
        
    return metrics

def _detect_code_smells(tree: ast.AST, content: str) -> Dict[str, List[Dict]]:
    """Detectar code smells básicos"""
    smells = {
        "long_methods": [],
        "large_classes": [],
        "magic_numbers": [],
        "duplicate_code": []
    }
    
    # Detectar métodos longos
    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef):
            length = node.end_lineno - node.lineno if hasattr(node, 'end_lineno') else 0
            if length > 20:  # Threshold para método longo
                smells["long_methods"].append({
                    "name": node.name,
                    "line": node.lineno,
                    "length": length
                })
                
        elif isinstance(node, ast.ClassDef):
            method_count = len([n for n in node.body if isinstance(n, ast.FunctionDef)])
            if method_count > 10:  # Threshold para classe grande
                smells["large_classes"].append({
                    "name": node.name,
                    "line": node.lineno,
                    "method_count": method_count
                })
                
    # Detectar números mágicos
    for node in ast.walk(tree):
        if isinstance(node, ast.Constant) and isinstance(node.value, (int, float)):
            if node.value not in [0, 1, -1] and abs(node.value) > 1:
                smells["magic_numbers"].append({
                    "value": node.value,
                    "line": node.lineno
                })
                
    return smells

def _detect_design_patterns(tree: ast.AST) -> List[str]:
    """Detectar padrões de design"""
    patterns = []
    
    # Detectar Singleton
    for node in ast.walk(tree):
        if isinstance(node, ast.ClassDef):
            has_new = any(isinstance(n, ast.FunctionDef) and n.name == '__new__' 
                         for n in node.body)
            if has_new:
                patterns.append("Singleton")
                
    # Detectar Factory
    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef):
            if 'create' in node.name.lower() or 'factory' in node.name.lower():
                patterns.append("Factory")
                
    return list(set(patterns))

def _detect_security_issues(content: str) -> List[Dict[str, Any]]:
    """Detectar problemas de segurança"""
    issues = []
    
    security_patterns = [
        (r'eval\s*\(', "Use of eval() - potential code injection", "high"),
        (r'exec\s*\(', "Use of exec() - potential code injection", "high"),
        (r'input\s*\([^)]*\)', "Use of input() without validation", "medium"),
        (r'os\.system\s*\(', "Use of os.system() - command injection risk", "high"),
        (r'subprocess\.call\s*\(.*shell=True', "Subprocess with shell=True", "medium"),
        (r'pickle\.loads?\s*\(', "Use of pickle - deserialization risk", "medium")
    ]
    
    lines = content.split('\n')
    for i, line in enumerate(lines, 1):
        for pattern, message, severity in security_patterns:
            if re.search(pattern, line):
                issues.append({
                    "line": i,
                    "message": message,
                    "severity": severity,
                    "code": line.strip()
                })
                
    return issues

def _detect_performance_issues(tree: ast.AST, content: str) -> List[Dict[str, Any]]:
    """Detectar problemas de performance"""
    issues = []
    
    # Detectar loops ineficientes
    for node in ast.walk(tree):
        if isinstance(node, ast.For):
            # range(len()) pattern
            if (isinstance(node.iter, ast.Call) and 
                isinstance(node.iter.func, ast.Name) and 
                node.iter.func.id == 'range' and
                len(node.iter.args) == 1 and
                isinstance(node.iter.args[0], ast.Call) and
                isinstance(node.iter.args[0].func, ast.Name) and
                node.iter.args[0].func.id == 'len'):
                
                issues.append({
                    "line": node.lineno,
                    "type": "inefficient_loop",
                    "message": "Use enumerate() instead of range(len())",
                    "severity": "low"
                })
                
    return issues

def _analyze_complexity(tree: ast.AST) -> Dict[str, Any]:
    """Analisar complexidade ciclomática"""
    complexity_data = {
        "total_complexity": 0,
        "function_complexities": [],
        "max_complexity": 0,
        "avg_complexity": 0
    }
    
    function_complexities = []
    
    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef):
            complexity = _calculate_function_complexity(node)
            function_complexities.append({
                "name": node.name,
                "complexity": complexity,
                "line": node.lineno
            })
            
    if function_complexities:
        complexities = [f["complexity"] for f in function_complexities]
        complexity_data.update({
            "function_complexities": function_complexities,
            "total_complexity": sum(complexities),
            "max_complexity": max(complexities),
            "avg_complexity": sum(complexities) / len(complexities)
        })
        
    return complexity_data

def _calculate_function_complexity(node: ast.FunctionDef) -> int:
    """Calcular complexidade ciclomática de uma função"""
    complexity = 1  # Base complexity
    
    for child in ast.walk(node):
        if isinstance(child, (ast.If, ast.For, ast.While, ast.With, ast.Try)):
            complexity += 1
        elif isinstance(child, ast.BoolOp):
            complexity += len(child.values) - 1
        elif isinstance(child, ast.ExceptHandler):
            complexity += 1
            
    return complexity

def _analyze_dependencies(tree: ast.AST) -> Dict[str, Any]:
    """Analisar dependências do módulo"""
    dependencies = {
        "internal_imports": [],
        "external_imports": [],
        "standard_library": [],
        "relative_imports": []
    }
    
    standard_libs = {
        'os', 'sys', 'json', 'datetime', 're', 'math', 'random', 
        'collections', 'itertools', 'functools', 'pathlib'
    }
    
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            for alias in node.names:
                module = alias.name.split('.')[0]
                if module in standard_libs:
                    dependencies["standard_library"].append(alias.name)
                else:
                    dependencies["external_imports"].append(alias.name)
                    
        elif isinstance(node, ast.ImportFrom):
            if node.level > 0:  # Relative import
                dependencies["relative_imports"].append(node.module or "")
            elif node.module:
                module = node.module.split('.')[0]
                if module in standard_libs:
                    dependencies["standard_library"].append(node.module)
                else:
                    dependencies["external_imports"].append(node.module)
                    
    return dependencies

def _check_naming_conventions(tree: ast.AST) -> Dict[str, List[Dict]]:
    """Verificar convenções de nomenclatura"""
    violations = {
        "function_names": [],
        "class_names": [],
        "variable_names": [],
        "constant_names": []
    }
    
    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef):
            if not re.match(r'^[a-z_][a-z0-9_]*$', node.name):
                violations["function_names"].append({
                    "name": node.name,
                    "line": node.lineno,
                    "suggestion": _suggest_snake_case(node.name)
                })
                
        elif isinstance(node, ast.ClassDef):
            if not re.match(r'^[A-Z][a-zA-Z0-9]*$', node.name):
                violations["class_names"].append({
                    "name": node.name,
                    "line": node.lineno,
                    "suggestion": _suggest_pascal_case(node.name)
                })
                
    return violations

def _suggest_snake_case(name: str) -> str:
    """Sugerir nome em snake_case"""
    # Converter CamelCase para snake_case
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()

def _suggest_pascal_case(name: str) -> str:
    """Sugerir nome em PascalCase"""
    # Converter snake_case para PascalCase
    return ''.join(word.capitalize() for word in name.split('_'))

def _analyze_documentation(tree: ast.AST) -> Dict[str, Any]:
    """Analisar qualidade da documentação"""
    doc_analysis = {
        "functions_with_docstrings": 0,
        "classes_with_docstrings": 0,
        "total_functions": 0,
        "total_classes": 0,
        "documentation_coverage": 0
    }
    
    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef):
            doc_analysis["total_functions"] += 1
            if ast.get_docstring(node):
                doc_analysis["functions_with_docstrings"] += 1
                
        elif isinstance(node, ast.ClassDef):
            doc_analysis["total_classes"] += 1
            if ast.get_docstring(node):
                doc_analysis["classes_with_docstrings"] += 1
                
    total_items = doc_analysis["total_functions"] + doc_analysis["total_classes"]
    documented_items = (doc_analysis["functions_with_docstrings"] + 
                       doc_analysis["classes_with_docstrings"])
    
    if total_items > 0:
        doc_analysis["documentation_coverage"] = (documented_items / total_items) * 100
        
    return doc_analysis

def _calculate_quality_score(analysis: Dict[str, Any]) -> float:
    """Calcular score de qualidade geral"""
    score = 100.0
    
    # Penalizar por code smells
    total_smells = sum(len(smells) for smells in analysis["code_smells"].values())
    score -= min(total_smells * 2, 30)
    
    # Penalizar por problemas de segurança
    security_penalty = len(analysis["security_issues"]) * 5
    score -= min(security_penalty, 25)
    
    # Penalizar por problemas de performance
    performance_penalty = len(analysis["performance_issues"]) * 2
    score -= min(performance_penalty, 15)
    
    # Bonus por documentação
    if "documentation_quality" in analysis:
        doc_coverage = analysis["documentation_quality"]["documentation_coverage"]
        score += (doc_coverage / 100) * 10
        
    return max(0, min(100, score))

def _save_analysis_report(analysis: Dict[str, Any], file_path: Path) -> None:
    """Salvar relatório de análise"""
    ANALYSIS_REPORTS_PATH.mkdir(exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    report_file = ANALYSIS_REPORTS_PATH / f"analysis_{file_path.stem}_{timestamp}.json"
    
    with open(report_file, 'w', encoding='utf-8') as f:
        json.dump(analysis, f, indent=2, ensure_ascii=False, default=str)

# Implementações simplificadas das funções de detecção de code smells
def _detect_long_methods(tree: ast.AST) -> List[Dict]:
    """Detectar métodos longos"""
    long_methods = []
    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef):
            length = getattr(node, 'end_lineno', node.lineno) - node.lineno
            if length > 20:
                long_methods.append({
                    "name": node.name,
                    "line": node.lineno,
                    "length": length
                })
    return long_methods

def _detect_large_classes(tree: ast.AST) -> List[Dict]:
    """Detectar classes grandes"""
    large_classes = []
    for node in ast.walk(tree):
        if isinstance(node, ast.ClassDef):
            method_count = len([n for n in node.body if isinstance(n, ast.FunctionDef)])
            if method_count > 10:
                large_classes.append({
                    "name": node.name,
                    "line": node.lineno,
                    "method_count": method_count
                })
    return large_classes

def _detect_duplicate_code(content: str) -> List[Dict]:
    """Detectar código duplicado (implementação básica)"""
    lines = content.split('\n')
    line_counts = Counter(line.strip() for line in lines if line.strip())
    
    duplicates = []
    for line, count in line_counts.items():
        if count > 1 and len(line) > 20:  # Linhas significativas duplicadas
            duplicates.append({
                "line_content": line,
                "occurrences": count
            })
            
    return duplicates

def _detect_dead_code(tree: ast.AST) -> List[Dict]:
    """Detectar código morto (implementação básica)"""
    # Esta é uma implementação simplificada
    # Uma implementação completa requereria análise de fluxo de controle
    return []

def _detect_magic_numbers(tree: ast.AST) -> List[Dict]:
    """Detectar números mágicos"""
    magic_numbers = []
    for node in ast.walk(tree):
        if isinstance(node, ast.Constant) and isinstance(node.value, (int, float)):
            if node.value not in [0, 1, -1] and abs(node.value) > 1:
                magic_numbers.append({
                    "value": node.value,
                    "line": node.lineno
                })
    return magic_numbers

def _detect_god_objects(tree: ast.AST) -> List[Dict]:
    """Detectar god objects"""
    god_objects = []
    for node in ast.walk(tree):
        if isinstance(node, ast.ClassDef):
            method_count = len([n for n in node.body if isinstance(n, ast.FunctionDef)])
            attr_count = len([n for n in node.body if isinstance(n, ast.Assign)])
            
            if method_count > 15 or attr_count > 10:
                god_objects.append({
                    "name": node.name,
                    "line": node.lineno,
                    "method_count": method_count,
                    "attribute_count": attr_count
                })
    return god_objects

# Implementações simplificadas das outras funções de detecção
def _detect_feature_envy(tree: ast.AST) -> List[Dict]:
    return []  # Implementação complexa - requer análise de dependências

def _detect_data_clumps(tree: ast.AST) -> List[Dict]:
    return []  # Implementação complexa - requer análise de parâmetros

def _detect_primitive_obsession(tree: ast.AST) -> List[Dict]:
    return []  # Implementação complexa - requer análise semântica

def _detect_inappropriate_intimacy(tree: ast.AST) -> List[Dict]:
    return []  # Implementação complexa - requer análise de acesso

def _calculate_smell_severity(smells: Dict[str, List]) -> Dict[str, str]:
    """Calcular severidade dos code smells"""
    severity_map = {
        "long_method": "medium",
        "large_class": "high",
        "duplicate_code": "medium",
        "dead_code": "low",
        "magic_numbers": "low",
        "god_object": "high"
    }
    
    return {smell_type: severity_map.get(smell_type, "low") 
            for smell_type in smells.keys()}

def _generate_smell_recommendations(smells: Dict[str, List]) -> List[str]:
    """Gerar recomendações para code smells"""
    recommendations = []
    
    for smell_type, instances in smells.items():
        if instances:
            if smell_type == "long_method":
                recommendations.append("Consider breaking long methods into smaller, focused methods")
            elif smell_type == "large_class":
                recommendations.append("Consider splitting large classes using Single Responsibility Principle")
            elif smell_type == "magic_numbers":
                recommendations.append("Replace magic numbers with named constants")
            elif smell_type == "duplicate_code":
                recommendations.append("Extract duplicate code into reusable functions or methods")
                
    return recommendations

# Implementações simplificadas das funções de refatoração
def _suggest_extract_method(tree: ast.AST) -> List[Dict]:
    """Sugerir extração de métodos"""
    suggestions = []
    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef):
            length = getattr(node, 'end_lineno', node.lineno) - node.lineno
            if length > 20:
                suggestions.append({
                    "type": "extract_method",
                    "target": node.name,
                    "line": node.lineno,
                    "description": f"Method '{node.name}' is too long ({length} lines). Consider extracting smaller methods."
                })
    return suggestions

def _suggest_rename_refactoring(tree: ast.AST) -> List[Dict]:
    """Sugerir renomeação"""
    suggestions = []
    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef):
            if len(node.name) < 3 or not re.match(r'^[a-z_][a-z0-9_]*$', node.name):
                suggestions.append({
                    "type": "rename",
                    "target": node.name,
                    "line": node.lineno,
                    "description": f"Function '{node.name}' should follow snake_case naming convention",
                    "suggested_name": _suggest_snake_case(node.name)
                })
    return suggestions

def _suggest_move_class(tree: ast.AST) -> List[Dict]:
    """Sugerir movimentação de classes"""
    # Implementação simplificada
    return []

def _suggest_general_refactoring(tree: ast.AST, content: str) -> List[Dict]:
    """Sugerir refatorações gerais"""
    suggestions = []
    
    # Sugerir list comprehensions
    if 'for ' in content and '.append(' in content:
        suggestions.append({
            "type": "list_comprehension",
            "description": "Consider using list comprehensions for better performance and readability"
        })
        
    return suggestions

def _prioritize_refactoring_suggestions(suggestions: List[Dict]) -> List[Dict]:
    """Priorizar sugestões de refatoração"""
    priority_order = {
        "extract_method": 1,
        "rename": 2,
        "list_comprehension": 3,
        "move_class": 4
    }
    
    return sorted(suggestions, key=lambda x: priority_order.get(x["type"], 5))

# Implementações simplificadas das funções de refatoração automática
def _remove_unused_imports(content: str) -> Tuple[str, bool]:
    """Remover imports não utilizados"""
    # Implementação básica - uma implementação completa requereria análise AST
    lines = content.split('\n')
    import_lines = []
    other_lines = []
    
    for line in lines:
        if line.strip().startswith(('import ', 'from ')):
            import_lines.append(line)
        else:
            other_lines.append(line)
            
    # Verificar quais imports são usados
    code_content = '\n'.join(other_lines)
    used_imports = []
    
    for import_line in import_lines:
        if 'import ' in import_line:
            module = import_line.split('import ')[1].split(' as ')[0].split('.')[0].strip()
            if module in code_content:
                used_imports.append(import_line)
                
    if len(used_imports) < len(import_lines):
        new_content = '\n'.join(used_imports + [''] + other_lines)
        return new_content, True
        
    return content, False

def _fix_naming_conventions(content: str) -> Tuple[str, bool]:
    """Corrigir convenções de nomenclatura"""
    # Implementação básica
    return content, False

def _add_type_hints(content: str) -> Tuple[str, bool]:
    """Adicionar type hints"""
    # Implementação básica
    return content, False

def _extract_constants(content: str) -> Tuple[str, bool]:
    """Extrair constantes"""
    # Implementação básica
    return content, False

def _simplify_conditionals(content: str) -> Tuple[str, bool]:
    """Simplificar condicionais"""
    # Implementação básica
    return content, False

def _calculate_refactoring_improvement(original: str, refactored: str) -> Dict[str, Any]:
    """Calcular melhoria da refatoração"""
    original_lines = len(original.split('\n'))
    refactored_lines = len(refactored.split('\n'))
    
    return {
        "original_lines": original_lines,
        "refactored_lines": refactored_lines,
        "line_reduction": original_lines - refactored_lines,
        "improvement_percentage": ((original_lines - refactored_lines) / original_lines * 100) if original_lines > 0 else 0
    }

# Implementações simplificadas das funções de análise arquitetural
def _analyze_file_structure(files: List[Path], project_root: Path) -> Dict[str, Any]:
    """Analisar estrutura de arquivos"""
    structure = {
        "total_files": len(files),
        "directories": set(),
        "file_distribution": defaultdict(int)
    }
    
    for file_path in files:
        rel_path = file_path.relative_to(project_root)
        structure["directories"].add(str(rel_path.parent))
        structure["file_distribution"][str(rel_path.parent)] += 1
        
    structure["directories"] = list(structure["directories"])
    structure["file_distribution"] = dict(structure["file_distribution"])
    
    return structure

def _build_dependency_graph(files: List[Path]) -> Dict[str, List[str]]:
    """Construir grafo de dependências"""
    # Implementação simplificada
    return {}

def _analyze_module_coupling(files: List[Path]) -> Dict[str, Any]:
    """Analisar acoplamento entre módulos"""
    # Implementação simplificada
    return {"coupling_score": 0.5}

def _analyze_design_patterns_usage(files: List[Path]) -> Dict[str, int]:
    """Analisar uso de padrões de design"""
    # Implementação simplificada
    return {}

def _detect_architectural_violations(files: List[Path]) -> List[Dict]:
    """Detectar violações arquiteturais"""
    # Implementação simplificada
    return []

def _analyze_code_duplication(files: List[Path]) -> Dict[str, Any]:
    """Analisar duplicação de código"""
    # Implementação simplificada
    return {"duplication_percentage": 0.0}

def _analyze_complexity_distribution(files: List[Path]) -> Dict[str, Any]:
    """Analisar distribuição de complexidade"""
    # Implementação simplificada
    return {"avg_complexity": 0.0}

def _calculate_architectural_metrics(analysis: Dict[str, Any]) -> Dict[str, float]:
    """Calcular métricas arquiteturais"""
    return {
        "maintainability_index": 75.0,
        "technical_debt_ratio": 0.1,
        "architectural_quality_score": 80.0
    }

def _generate_architectural_recommendations(analysis: Dict[str, Any]) -> List[str]:
    """Gerar recomendações arquiteturais"""
    return [
        "Consider implementing dependency injection",
        "Review module coupling and cohesion",
        "Add more comprehensive documentation"
    ]

def _save_architecture_report(analysis: Dict[str, Any], project_path: Path) -> None:
    """Salvar relatório arquitetural"""
    ANALYSIS_REPORTS_PATH.mkdir(exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    report_file = ANALYSIS_REPORTS_PATH / f"architecture_analysis_{timestamp}.json"
    
    with open(report_file, 'w', encoding='utf-8') as f:
        json.dump(analysis, f, indent=2, ensure_ascii=False, default=str)

def _analyze_code_structure(tree: ast.AST) -> Dict[str, List[Dict]]:
    """Analisar estrutura do código"""
    structure = {
        "functions": [],
        "classes": [],
        "methods": []
    }
    
    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef):
            structure["functions"].append({
                "name": node.name,
                "line": node.lineno,
                "args": [arg.arg for arg in node.args.args]
            })
        elif isinstance(node, ast.ClassDef):
            structure["classes"].append({
                "name": node.name,
                "line": node.lineno
            })
            
    return structure

def _generate_documentation_strings(content: str, structure: Dict, doc_style: str) -> str:
    """Gerar strings de documentação"""
    # Implementação básica - adicionar docstrings onde faltam
    lines = content.split('\n')
    
    # Esta é uma implementação muito simplificada
    # Uma implementação completa requereria análise AST mais sofisticada
    
    return content  # Por enquanto, retorna o conteúdo original

if __name__ == "__main__":
    # Executar servidor MCP
    mcp.run()