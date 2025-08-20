#!/usr/bin/env python3
"""
Project Scaffolding MCP Server
Servidor MCP para criação automática de estruturas de projeto,
scaffolding de código e templates de desenvolvimento
"""

import os
import json
import shutil
from pathlib import Path
from typing import Dict, List, Optional, Any
from datetime import datetime
from dataclasses import dataclass

from fastmcp import FastMCP

# Inicializar servidor MCP
mcp = FastMCP("Project Scaffolding MCP")

# Configurações
PROJECT_ROOT = Path("C:/Users/Admin/Documents/EA_SCALPER_XAUUSD")
TEMPLATES_PATH = PROJECT_ROOT / "Templates"
SCAFFOLD_PATH = PROJECT_ROOT / "Scaffolded_Projects"

@dataclass
class ProjectTemplate:
    """Template de projeto"""
    name: str
    description: str
    structure: Dict[str, Any]
    files: Dict[str, str]
    dependencies: List[str]
    scripts: Dict[str, str]

# Templates predefinidos
PROJECT_TEMPLATES = {
    "trading_bot": ProjectTemplate(
        name="Trading Bot",
        description="Template para robô de trading com análise técnica",
        structure={
            "src": {
                "bot": {},
                "strategies": {},
                "indicators": {},
                "risk_management": {},
                "data": {},
                "utils": {}
            },
            "tests": {
                "unit": {},
                "integration": {},
                "backtesting": {}
            },
            "config": {},
            "docs": {},
            "scripts": {},
            "data": {
                "raw": {},
                "processed": {},
                "models": {}
            }
        },
        files={
            "src/bot/__init__.py": "",
            "src/bot/main.py": "# Trading Bot Main Module\n",
            "src/strategies/__init__.py": "",
            "src/indicators/__init__.py": "",
            "requirements.txt": "pandas\nnumpy\nccxt\nta-lib\npytest\n",
            "README.md": "# Trading Bot\n\nAutomated trading system\n",
            ".gitignore": "__pycache__/\n*.pyc\n.env\nconfig/secrets.json\n"
        },
        dependencies=["pandas", "numpy", "ccxt", "ta-lib", "pytest"],
        scripts={
            "start": "python src/bot/main.py",
            "test": "pytest tests/",
            "backtest": "python scripts/backtest.py"
        }
    ),
    
    "mql_analyzer": ProjectTemplate(
        name="MQL Code Analyzer",
        description="Template para analisador de código MQL4/MQL5",
        structure={
            "src": {
                "analyzer": {},
                "parsers": {
                    "mql4": {},
                    "mql5": {},
                    "pine_script": {}
                },
                "classifiers": {},
                "extractors": {},
                "generators": {},
                "utils": {}
            },
            "tests": {
                "unit": {},
                "integration": {},
                "sample_files": {
                    "mql4": {},
                    "mql5": {},
                    "pine": {}
                }
            },
            "templates": {
                "metadata": {},
                "reports": {},
                "documentation": {}
            },
            "output": {
                "classified": {},
                "reports": {},
                "metadata": {}
            }
        },
        files={
            "src/analyzer/__init__.py": "",
            "src/analyzer/main.py": "# MQL Code Analyzer\n",
            "requirements.txt": "pathlib\nre\njson\npandas\nast\n",
            "README.md": "# MQL Code Analyzer\n\nAnalyzer for MQL4/MQL5 trading code\n"
        },
        dependencies=["pathlib", "re", "json", "pandas"],
        scripts={
            "analyze": "python src/analyzer/main.py",
            "classify": "python src/classifiers/main.py"
        }
    ),
    
    "fastapi_service": ProjectTemplate(
        name="FastAPI Microservice",
        description="Template para microserviço FastAPI",
        structure={
            "app": {
                "api": {
                    "v1": {
                        "endpoints": {}
                    }
                },
                "core": {},
                "models": {},
                "services": {},
                "utils": {},
                "db": {}
            },
            "tests": {},
            "alembic": {
                "versions": {}
            },
            "scripts": {}
        },
        files={
            "app/__init__.py": "",
            "app/main.py": "# FastAPI Application\nfrom fastapi import FastAPI\n\napp = FastAPI()\n",
            "requirements.txt": "fastapi\nuvicorn\nsqlalchemy\nalembic\npydantic\n",
            "Dockerfile": "FROM python:3.9\nWORKDIR /app\nCOPY requirements.txt .\nRUN pip install -r requirements.txt\n"
        },
        dependencies=["fastapi", "uvicorn", "sqlalchemy", "alembic", "pydantic"],
        scripts={
            "dev": "uvicorn app.main:app --reload",
            "prod": "uvicorn app.main:app --host 0.0.0.0 --port 8000"
        }
    )
}

@mcp.tool
def create_project_from_template(template_name: str, project_name: str, 
                                 output_path: str = None, 
                                 custom_config: Dict[str, Any] = None) -> Dict[str, Any]:
    """
    Criar projeto a partir de template
    
    Args:
        template_name: Nome do template a usar
        project_name: Nome do projeto
        output_path: Caminho de saída (opcional)
        custom_config: Configurações customizadas
        
    Returns:
        Informações do projeto criado
    """
    try:
        if template_name not in PROJECT_TEMPLATES:
            return {
                "error": f"Template '{template_name}' não encontrado",
                "available_templates": list(PROJECT_TEMPLATES.keys())
            }
            
        template = PROJECT_TEMPLATES[template_name]
        
        # Definir caminho de saída
        if output_path:
            project_path = Path(output_path) / project_name
        else:
            project_path = SCAFFOLD_PATH / project_name
            
        if project_path.exists():
            return {"error": f"Projeto '{project_name}' já existe em {project_path}"}
            
        # Criar estrutura de diretórios
        _create_directory_structure(project_path, template.structure)
        
        # Criar arquivos
        created_files = _create_template_files(project_path, template.files, 
                                             project_name, custom_config)
        
        # Criar arquivo de configuração do projeto
        project_config = {
            "name": project_name,
            "template": template_name,
            "created_at": datetime.now().isoformat(),
            "dependencies": template.dependencies,
            "scripts": template.scripts,
            "custom_config": custom_config or {}
        }
        
        config_file = project_path / "project.json"
        with open(config_file, 'w', encoding='utf-8') as f:
            json.dump(project_config, f, indent=2)
            
        return {
            "status": "success",
            "project_name": project_name,
            "project_path": str(project_path),
            "template_used": template_name,
            "files_created": created_files,
            "next_steps": _generate_next_steps(template, project_path)
        }
        
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro ao criar projeto: {str(e)}"
        }

@mcp.tool
def list_available_templates() -> Dict[str, Any]:
    """
    Listar templates disponíveis
    
    Returns:
        Lista de templates com descrições
    """
    templates_info = {}
    
    for name, template in PROJECT_TEMPLATES.items():
        templates_info[name] = {
            "name": template.name,
            "description": template.description,
            "dependencies": template.dependencies,
            "scripts": list(template.scripts.keys())
        }
        
    return {
        "status": "success",
        "templates": templates_info,
        "total_templates": len(PROJECT_TEMPLATES)
    }

@mcp.tool
def create_custom_template(template_name: str, template_config: Dict[str, Any]) -> Dict[str, Any]:
    """
    Criar template customizado
    
    Args:
        template_name: Nome do template
        template_config: Configuração do template
        
    Returns:
        Confirmação de criação
    """
    try:
        required_fields = ["name", "description", "structure", "files"]
        
        for field in required_fields:
            if field not in template_config:
                return {"error": f"Campo obrigatório '{field}' não encontrado"}
                
        # Criar template
        custom_template = ProjectTemplate(
            name=template_config["name"],
            description=template_config["description"],
            structure=template_config["structure"],
            files=template_config["files"],
            dependencies=template_config.get("dependencies", []),
            scripts=template_config.get("scripts", {})
        )
        
        # Adicionar aos templates disponíveis
        PROJECT_TEMPLATES[template_name] = custom_template
        
        # Salvar template personalizado
        _save_custom_template(template_name, custom_template)
        
        return {
            "status": "success",
            "template_name": template_name,
            "message": "Template customizado criado com sucesso"
        }
        
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro ao criar template customizado: {str(e)}"
        }

@mcp.tool
def generate_code_scaffold(scaffold_type: str, name: str, 
                          options: Dict[str, Any] = None) -> Dict[str, Any]:
    """
    Gerar scaffold de código específico
    
    Args:
        scaffold_type: Tipo de scaffold (class, function, module, test)
        name: Nome do componente
        options: Opções específicas
        
    Returns:
        Código gerado
    """
    try:
        options = options or {}
        
        if scaffold_type == "class":
            code = _generate_class_scaffold(name, options)
        elif scaffold_type == "function":
            code = _generate_function_scaffold(name, options)
        elif scaffold_type == "module":
            code = _generate_module_scaffold(name, options)
        elif scaffold_type == "test":
            code = _generate_test_scaffold(name, options)
        elif scaffold_type == "mql_ea":
            code = _generate_mql_ea_scaffold(name, options)
        elif scaffold_type == "mql_indicator":
            code = _generate_mql_indicator_scaffold(name, options)
        else:
            return {"error": f"Tipo de scaffold '{scaffold_type}' não suportado"}
            
        return {
            "status": "success",
            "scaffold_type": scaffold_type,
            "name": name,
            "generated_code": code,
            "options_used": options
        }
        
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro ao gerar scaffold: {str(e)}"
        }

@mcp.tool
def create_project_structure(project_path: str, structure_config: Dict[str, Any]) -> Dict[str, Any]:
    """
    Criar estrutura de projeto customizada
    
    Args:
        project_path: Caminho do projeto
        structure_config: Configuração da estrutura
        
    Returns:
        Estrutura criada
    """
    try:
        project_path = Path(project_path)
        
        if project_path.exists() and any(project_path.iterdir()):
            return {"error": f"Diretório '{project_path}' não está vazio"}
            
        # Criar estrutura
        created_dirs = _create_directory_structure(project_path, structure_config)
        
        # Criar arquivos __init__.py em diretórios Python
        init_files = _create_init_files(project_path)
        
        return {
            "status": "success",
            "project_path": str(project_path),
            "directories_created": created_dirs,
            "init_files_created": init_files
        }
        
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro ao criar estrutura: {str(e)}"
        }

@mcp.tool
def generate_requirements_file(dependencies: List[str], 
                              output_path: str = None,
                              include_versions: bool = True) -> Dict[str, Any]:
    """
    Gerar arquivo requirements.txt
    
    Args:
        dependencies: Lista de dependências
        output_path: Caminho de saída
        include_versions: Incluir versões das dependências
        
    Returns:
        Arquivo requirements gerado
    """
    try:
        # Mapear dependências com versões recomendadas
        version_map = {
            "pandas": ">=1.3.0",
            "numpy": ">=1.21.0",
            "fastapi": ">=0.68.0",
            "uvicorn": ">=0.15.0",
            "pytest": ">=6.2.0",
            "sqlalchemy": ">=1.4.0",
            "pydantic": ">=1.8.0",
            "ccxt": ">=1.50.0",
            "ta-lib": ">=0.4.0"
        }
        
        requirements_content = []
        
        for dep in dependencies:
            if include_versions and dep in version_map:
                requirements_content.append(f"{dep}{version_map[dep]}")
            else:
                requirements_content.append(dep)
                
        requirements_text = "\n".join(requirements_content) + "\n"
        
        # Salvar arquivo se caminho especificado
        if output_path:
            output_file = Path(output_path) / "requirements.txt"
            output_file.parent.mkdir(parents=True, exist_ok=True)
            
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(requirements_text)
                
            return {
                "status": "success",
                "file_path": str(output_file),
                "dependencies_count": len(dependencies),
                "content": requirements_text
            }
        else:
            return {
                "status": "success",
                "dependencies_count": len(dependencies),
                "content": requirements_text
            }
            
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro ao gerar requirements: {str(e)}"
        }

@mcp.tool
def create_docker_setup(project_type: str, project_path: str, 
                       config: Dict[str, Any] = None) -> Dict[str, Any]:
    """
    Criar configuração Docker para projeto
    
    Args:
        project_type: Tipo do projeto (fastapi, flask, general)
        project_path: Caminho do projeto
        config: Configurações específicas
        
    Returns:
        Arquivos Docker criados
    """
    try:
        project_path = Path(project_path)
        config = config or {}
        
        # Gerar Dockerfile
        dockerfile_content = _generate_dockerfile(project_type, config)
        
        # Gerar docker-compose.yml
        compose_content = _generate_docker_compose(project_type, config)
        
        # Gerar .dockerignore
        dockerignore_content = _generate_dockerignore()
        
        # Salvar arquivos
        files_created = []
        
        dockerfile_path = project_path / "Dockerfile"
        with open(dockerfile_path, 'w', encoding='utf-8') as f:
            f.write(dockerfile_content)
        files_created.append(str(dockerfile_path))
        
        compose_path = project_path / "docker-compose.yml"
        with open(compose_path, 'w', encoding='utf-8') as f:
            f.write(compose_content)
        files_created.append(str(compose_path))
        
        dockerignore_path = project_path / ".dockerignore"
        with open(dockerignore_path, 'w', encoding='utf-8') as f:
            f.write(dockerignore_content)
        files_created.append(str(dockerignore_path))
        
        return {
            "status": "success",
            "project_type": project_type,
            "files_created": files_created,
            "docker_commands": {
                "build": "docker-compose build",
                "run": "docker-compose up",
                "dev": "docker-compose up --build"
            }
        }
        
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro ao criar configuração Docker: {str(e)}"
        }

# Funções auxiliares
def _create_directory_structure(base_path: Path, structure: Dict[str, Any]) -> List[str]:
    """Criar estrutura de diretórios recursivamente"""
    created_dirs = []
    
    def create_recursive(current_path: Path, current_structure: Dict[str, Any]):
        for name, content in current_structure.items():
            dir_path = current_path / name
            dir_path.mkdir(parents=True, exist_ok=True)
            created_dirs.append(str(dir_path))
            
            if isinstance(content, dict):
                create_recursive(dir_path, content)
                
    base_path.mkdir(parents=True, exist_ok=True)
    created_dirs.append(str(base_path))
    
    create_recursive(base_path, structure)
    return created_dirs

def _create_template_files(project_path: Path, files: Dict[str, str], 
                          project_name: str, custom_config: Dict[str, Any]) -> List[str]:
    """Criar arquivos do template"""
    created_files = []
    
    for file_path, content in files.items():
        full_path = project_path / file_path
        full_path.parent.mkdir(parents=True, exist_ok=True)
        
        # Substituir placeholders
        processed_content = content.replace("{{PROJECT_NAME}}", project_name)
        
        if custom_config:
            for key, value in custom_config.items():
                processed_content = processed_content.replace(f"{{{{{key}}}}}", str(value))
                
        with open(full_path, 'w', encoding='utf-8') as f:
            f.write(processed_content)
            
        created_files.append(str(full_path))
        
    return created_files

def _create_init_files(project_path: Path) -> List[str]:
    """Criar arquivos __init__.py em diretórios Python"""
    init_files = []
    
    # Procurar por diretórios que parecem ser pacotes Python
    for dir_path in project_path.rglob("*"):
        if (dir_path.is_dir() and 
            dir_path.name not in ['.git', '__pycache__', '.pytest_cache'] and
            not dir_path.name.startswith('.')):
            
            init_file = dir_path / "__init__.py"
            if not init_file.exists():
                init_file.touch()
                init_files.append(str(init_file))
                
    return init_files

def _generate_next_steps(template: ProjectTemplate, project_path: Path) -> List[str]:
    """Gerar próximos passos para o projeto"""
    steps = [
        f"cd {project_path}",
        "python -m venv venv",
        "source venv/bin/activate  # ou venv\\Scripts\\activate no Windows",
        "pip install -r requirements.txt"
    ]
    
    if "start" in template.scripts:
        steps.append(f"# Para executar: {template.scripts['start']}")
        
    if "test" in template.scripts:
        steps.append(f"# Para testar: {template.scripts['test']}")
        
    return steps

def _save_custom_template(template_name: str, template: ProjectTemplate) -> None:
    """Salvar template customizado"""
    TEMPLATES_PATH.mkdir(exist_ok=True)
    
    template_file = TEMPLATES_PATH / f"{template_name}.json"
    
    template_data = {
        "name": template.name,
        "description": template.description,
        "structure": template.structure,
        "files": template.files,
        "dependencies": template.dependencies,
        "scripts": template.scripts
    }
    
    with open(template_file, 'w', encoding='utf-8') as f:
        json.dump(template_data, f, indent=2)

# Geradores de scaffold
def _generate_class_scaffold(name: str, options: Dict[str, Any]) -> str:
    """Gerar scaffold de classe"""
    base_class = options.get("base_class", "")
    methods = options.get("methods", [])
    docstring = options.get("docstring", f"Class {name}")
    
    inheritance = f"({base_class})" if base_class else ""
    
    code = f'''class {name}{inheritance}:
    """{docstring}"""
    
    def __init__(self):
        """Initialize {name}"""
        pass
'''
    
    for method in methods:
        code += f'''
    def {method}(self):
        """Method {method}"""
        pass
'''
    
    return code

def _generate_function_scaffold(name: str, options: Dict[str, Any]) -> str:
    """Gerar scaffold de função"""
    params = options.get("parameters", [])
    return_type = options.get("return_type", "None")
    docstring = options.get("docstring", f"Function {name}")
    
    param_str = ", ".join(params) if params else ""
    
    code = f'''def {name}({param_str}) -> {return_type}:
    """{docstring}"""
    pass
'''
    
    return code

def _generate_module_scaffold(name: str, options: Dict[str, Any]) -> str:
    """Gerar scaffold de módulo"""
    description = options.get("description", f"Module {name}")
    author = options.get("author", "")
    
    code = f'''#!/usr/bin/env python3
"""
{name} Module

{description}
'''
    
    if author:
        code += f"Author: {author}\n"
        
    code += f'''
Created: {datetime.now().strftime("%Y-%m-%d")}
"""

import os
import sys
from typing import Any, Dict, List, Optional


def main():
    """Main function"""
    pass


if __name__ == "__main__":
    main()
'''
    
    return code

def _generate_test_scaffold(name: str, options: Dict[str, Any]) -> str:
    """Gerar scaffold de teste"""
    test_class = options.get("test_class", f"Test{name}")
    methods = options.get("test_methods", ["test_basic"])
    
    code = f'''import unittest
from unittest.mock import Mock, patch


class {test_class}(unittest.TestCase):
    """Test cases for {name}"""
    
    def setUp(self):
        """Set up test fixtures"""
        pass
    
    def tearDown(self):
        """Clean up after tests"""
        pass
'''
    
    for method in methods:
        code += f'''
    def {method}(self):
        """Test {method.replace('test_', '')}"""
        # Arrange
        
        # Act
        
        # Assert
        self.assertTrue(True)  # Replace with actual test
'''
    
    code += '''

if __name__ == '__main__':
    unittest.main()
'''
    
    return code

def _generate_mql_ea_scaffold(name: str, options: Dict[str, Any]) -> str:
    """Gerar scaffold de EA MQL"""
    version = options.get("version", "1.0")
    description = options.get("description", f"Expert Advisor {name}")
    
    code = f'''//+------------------------------------------------------------------+
//|                                                        {name}.mq5 |
//|                                  Copyright 2024, Your Company Ltd. |
//|                                             https://www.example.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Your Company Ltd."
#property link      "https://www.example.com"
#property version   "{version}"
#property description "{description}"

// Input parameters
input double LotSize = 0.01;           // Lot size
input int    StopLoss = 50;            // Stop Loss in points
input int    TakeProfit = 100;         // Take Profit in points
input int    MagicNumber = 12345;      // Magic number

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{{
   // Initialization code here
   Print("EA {name} initialized successfully");
   return(INIT_SUCCEEDED);
}}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{{
   // Cleanup code here
   Print("EA {name} deinitialized");
}}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{{
   // Main trading logic here
   
   // Example: Simple buy condition
   if(ShouldBuy())
   {{
      OpenBuyOrder();
   }}
   
   // Example: Simple sell condition
   if(ShouldSell())
   {{
      OpenSellOrder();
   }}
}}

//+------------------------------------------------------------------+
//| Check if should buy                                             |
//+------------------------------------------------------------------+
bool ShouldBuy()
{{
   // Implement buy logic here
   return false;
}}

//+------------------------------------------------------------------+
//| Check if should sell                                            |
//+------------------------------------------------------------------+
bool ShouldSell()
{{
   // Implement sell logic here
   return false;
}}

//+------------------------------------------------------------------+
//| Open buy order                                                  |
//+------------------------------------------------------------------+
void OpenBuyOrder()
{{
   // Implement buy order logic here
}}

//+------------------------------------------------------------------+
//| Open sell order                                                 |
//+------------------------------------------------------------------+
void OpenSellOrder()
{{
   // Implement sell order logic here
}}
'''
    
    return code

def _generate_mql_indicator_scaffold(name: str, options: Dict[str, Any]) -> str:
    """Gerar scaffold de indicador MQL"""
    version = options.get("version", "1.0")
    description = options.get("description", f"Custom Indicator {name}")
    
    code = f'''//+------------------------------------------------------------------+
//|                                                        {name}.mq5 |
//|                                  Copyright 2024, Your Company Ltd. |
//|                                             https://www.example.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Your Company Ltd."
#property link      "https://www.example.com"
#property version   "{version}"
#property description "{description}"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

// Plot settings
#property indicator_label1  "{name}"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

// Input parameters
input int Period = 14;                 // Calculation period

// Indicator buffers
double {name}Buffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{{
   // Set indicator buffers
   SetIndexBuffer(0, {name}Buffer, INDICATOR_DATA);
   
   // Set indicator properties
   IndicatorSetString(INDICATOR_SHORTNAME, "{name}(" + IntegerToString(Period) + ")");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   
   return(INIT_SUCCEEDED);
}}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{{
   // Calculate indicator values
   int start = prev_calculated;
   if(start == 0) start = Period;
   
   for(int i = start; i < rates_total; i++)
   {{
      // Implement calculation logic here
      {name}Buffer[i] = close[i]; // Example: just copy close price
   }}
   
   return(rates_total);
}}
'''
    
    return code

# Geradores Docker
def _generate_dockerfile(project_type: str, config: Dict[str, Any]) -> str:
    """Gerar Dockerfile"""
    python_version = config.get("python_version", "3.9")
    
    if project_type == "fastapi":
        return f'''FROM python:{python_version}-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
'''
    
    elif project_type == "flask":
        return f'''FROM python:{python_version}-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
'''
    
    else:  # general
        return f'''FROM python:{python_version}-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "main.py"]
'''

def _generate_docker_compose(project_type: str, config: Dict[str, Any]) -> str:
    """Gerar docker-compose.yml"""
    service_name = config.get("service_name", "app")
    
    if project_type == "fastapi":
        return f'''version: '3.8'

services:
  {service_name}:
    build: .
    ports:
      - "8000:8000"
    environment:
      - ENV=development
    volumes:
      - .:/app
    restart: unless-stopped
'''
    
    elif project_type == "flask":
        return f'''version: '3.8'

services:
  {service_name}:
    build: .
    ports:
      - "5000:5000"
    environment:
      - FLASK_ENV=development
    volumes:
      - .:/app
    restart: unless-stopped
'''
    
    else:  # general
        return f'''version: '3.8'

services:
  {service_name}:
    build: .
    volumes:
      - .:/app
    restart: unless-stopped
'''

def _generate_dockerignore() -> str:
    """Gerar .dockerignore"""
    return '''__pycache__
*.pyc
*.pyo
*.pyd
.Python
env
venv
.venv
pip-log.txt
pip-delete-this-directory.txt
.tox
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.log
.git
.mypy_cache
.pytest_cache
.hypothesis

.DS_Store
.vscode
.idea

*.sqlite
*.db

node_modules
npm-debug.log*
yarn-debug.log*
yarn-error.log*

.env
.env.local
.env.development.local
.env.test.local
.env.production.local
'''

if __name__ == "__main__":
    # Executar servidor MCP
    mcp.run()