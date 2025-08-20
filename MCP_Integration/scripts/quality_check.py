#!/usr/bin/env python3
"""
Script de Verificação de Qualidade Automatizada
Integra todas as ferramentas de análise de código para garantir qualidade e conformidade FTMO.

Autor: Classificador_Trading
Versão: 1.0
Data: 2025
"""

import os
import sys
import subprocess
import json
import argparse
from pathlib import Path
from typing import Dict, List, Tuple, Optional
import logging

# Configuração de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('quality_check.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class QualityChecker:
    """Classe principal para verificação de qualidade de código."""
    
    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.results = {
            'python': {},
            'javascript': {},
            'mql': {},
            'overall': {}
        }
        
    def run_command(self, command: List[str], cwd: Optional[str] = None) -> Tuple[int, str, str]:
        """Executa comando e retorna código de saída, stdout e stderr."""
        try:
            result = subprocess.run(
                command,
                cwd=cwd or self.project_root,
                capture_output=True,
                text=True,
                timeout=300
            )
            return result.returncode, result.stdout, result.stderr
        except subprocess.TimeoutExpired:
            logger.error(f"Timeout executando comando: {' '.join(command)}")
            return -1, "", "Timeout"
        except Exception as e:
            logger.error(f"Erro executando comando {' '.join(command)}: {e}")
            return -1, "", str(e)
    
    def check_python_files(self, directory: str) -> Dict:
        """Verifica arquivos Python com Pylint, Flake8 e Black."""
        logger.info(f"Verificando arquivos Python em: {directory}")
        python_results = {
            'pylint': {'score': 0, 'errors': [], 'warnings': []},
            'flake8': {'errors': [], 'warnings': []},
            'black': {'formatted': False, 'issues': []},
            'pytest': {'passed': 0, 'failed': 0, 'coverage': 0}
        }
        
        python_files = list(Path(directory).rglob('*.py'))
        if not python_files:
            logger.info("Nenhum arquivo Python encontrado")
            return python_results
        
        # Pylint
        for py_file in python_files:
            logger.info(f"Executando Pylint em: {py_file}")
            code, stdout, stderr = self.run_command(['pylint', str(py_file), '--output-format=json'])
            if code == 0 or stdout:
                try:
                    pylint_data = json.loads(stdout) if stdout.strip() else []
                    for issue in pylint_data:
                        if issue['type'] == 'error':
                            python_results['pylint']['errors'].append(issue)
                        else:
                            python_results['pylint']['warnings'].append(issue)
                except json.JSONDecodeError:
                    # Fallback para formato texto
                    if 'Your code has been rated at' in stdout:
                        score_line = [line for line in stdout.split('\n') if 'rated at' in line]
                        if score_line:
                            score = float(score_line[0].split('rated at ')[1].split('/')[0])
                            python_results['pylint']['score'] = max(python_results['pylint']['score'], score)
        
        # Flake8
        logger.info("Executando Flake8")
        code, stdout, stderr = self.run_command(['flake8', directory, '--format=json'])
        if stdout:
            try:
                flake8_data = json.loads(stdout)
                python_results['flake8']['errors'] = flake8_data
            except json.JSONDecodeError:
                python_results['flake8']['errors'] = stdout.split('\n')
        
        # Black
        logger.info("Verificando formatação Black")
        code, stdout, stderr = self.run_command(['black', directory, '--check', '--diff'])
        python_results['black']['formatted'] = (code == 0)
        if code != 0:
            python_results['black']['issues'] = stdout.split('\n')
        
        # Pytest
        test_dir = self.project_root / 'tests'
        if test_dir.exists():
            logger.info("Executando testes Pytest")
            code, stdout, stderr = self.run_command(['pytest', str(test_dir), '-v', '--tb=short'])
            if 'passed' in stdout:
                lines = stdout.split('\n')
                for line in lines:
                    if 'passed' in line and 'failed' in line:
                        parts = line.split()
                        for i, part in enumerate(parts):
                            if part == 'passed' and i > 0:
                                python_results['pytest']['passed'] = int(parts[i-1])
                            elif part == 'failed' and i > 0:
                                python_results['pytest']['failed'] = int(parts[i-1])
        
        return python_results
    
    def check_javascript_files(self, directory: str) -> Dict:
        """Verifica arquivos JavaScript/TypeScript com ESLint."""
        logger.info(f"Verificando arquivos JavaScript em: {directory}")
        js_results = {
            'eslint': {'errors': [], 'warnings': []}
        }
        
        js_files = list(Path(directory).rglob('*.js')) + list(Path(directory).rglob('*.ts'))
        if not js_files:
            logger.info("Nenhum arquivo JavaScript/TypeScript encontrado")
            return js_results
        
        # ESLint
        for js_file in js_files:
            logger.info(f"Executando ESLint em: {js_file}")
            code, stdout, stderr = self.run_command(['eslint', str(js_file), '--format=json'])
            if stdout:
                try:
                    eslint_data = json.loads(stdout)
                    for file_result in eslint_data:
                        for message in file_result.get('messages', []):
                            if message['severity'] == 2:
                                js_results['eslint']['errors'].append(message)
                            else:
                                js_results['eslint']['warnings'].append(message)
                except json.JSONDecodeError:
                    js_results['eslint']['errors'].append({'message': stdout})
        
        return js_results
    
    def check_mql_files(self, directory: str) -> Dict:
        """Verifica arquivos MQL4/MQL5 com o MCP Code Checker."""
        logger.info(f"Verificando arquivos MQL em: {directory}")
        mql_results = {
            'ftmo_compliance': {'score': 0, 'issues': []},
            'code_quality': {'score': 0, 'issues': []},
            'trading_patterns': {'detected': [], 'issues': []}
        }
        
        mql_files = (list(Path(directory).rglob('*.mq4')) + 
                    list(Path(directory).rglob('*.mq5')) + 
                    list(Path(directory).rglob('*.mqh')))
        
        if not mql_files:
            logger.info("Nenhum arquivo MQL encontrado")
            return mql_results
        
        # MCP Code Checker
        mcp_checker = self.project_root / 'MCP_Integration' / 'servers' / 'mcp_code_checker.py'
        if mcp_checker.exists():
            for mql_file in mql_files:
                logger.info(f"Executando MCP Code Checker em: {mql_file}")
                code, stdout, stderr = self.run_command([
                    'python', str(mcp_checker), '--analyze', str(mql_file)
                ])
                
                # Análise básica do código MQL
                with open(mql_file, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                    
                # Verificação FTMO básica
                ftmo_score = 0
                ftmo_issues = []
                
                if 'StopLoss' in content or 'SL' in content:
                    ftmo_score += 2
                else:
                    ftmo_issues.append('Stop Loss não detectado')
                
                if 'TakeProfit' in content or 'TP' in content:
                    ftmo_score += 1
                else:
                    ftmo_issues.append('Take Profit não detectado')
                
                if 'AccountBalance' in content or 'risk' in content.lower():
                    ftmo_score += 2
                else:
                    ftmo_issues.append('Gerenciamento de risco não detectado')
                
                if 'Martingale' in content or 'grid' in content.lower():
                    ftmo_issues.append('Estratégia de alto risco detectada (Martingale/Grid)')
                    ftmo_score -= 2
                
                mql_results['ftmo_compliance']['score'] = max(0, min(10, ftmo_score))
                mql_results['ftmo_compliance']['issues'].extend(ftmo_issues)
                
                # Detecção de padrões
                if 'OnTick' in content:
                    mql_results['trading_patterns']['detected'].append('Expert Advisor')
                if 'OnCalculate' in content:
                    mql_results['trading_patterns']['detected'].append('Indicator')
                if 'OnStart' in content and 'OnTick' not in content:
                    mql_results['trading_patterns']['detected'].append('Script')
        
        return mql_results
    
    def generate_report(self) -> str:
        """Gera relatório completo de qualidade."""
        report = []
        report.append("=" * 80)
        report.append("RELATÓRIO DE QUALIDADE DE CÓDIGO")
        report.append("=" * 80)
        report.append(f"Projeto: {self.project_root}")
        report.append(f"Data: {__import__('datetime').datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        report.append("")
        
        # Resultados Python
        if self.results['python']:
            report.append("📊 ANÁLISE PYTHON")
            report.append("-" * 40)
            py_results = self.results['python']
            
            if 'pylint' in py_results:
                pylint = py_results['pylint']
                report.append(f"Pylint Score: {pylint['score']:.1f}/10")
                report.append(f"Erros: {len(pylint['errors'])}")
                report.append(f"Warnings: {len(pylint['warnings'])}")
            
            if 'flake8' in py_results:
                flake8 = py_results['flake8']
                report.append(f"Flake8 Issues: {len(flake8['errors'])}")
            
            if 'black' in py_results:
                black = py_results['black']
                status = "✅ Formatado" if black['formatted'] else "❌ Precisa formatação"
                report.append(f"Black: {status}")
            
            if 'pytest' in py_results:
                pytest = py_results['pytest']
                report.append(f"Testes: {pytest['passed']} passou, {pytest['failed']} falhou")
            
            report.append("")
        
        # Resultados JavaScript
        if self.results['javascript']:
            report.append("📊 ANÁLISE JAVASCRIPT/TYPESCRIPT")
            report.append("-" * 40)
            js_results = self.results['javascript']
            
            if 'eslint' in js_results:
                eslint = js_results['eslint']
                report.append(f"ESLint Erros: {len(eslint['errors'])}")
                report.append(f"ESLint Warnings: {len(eslint['warnings'])}")
            
            report.append("")
        
        # Resultados MQL
        if self.results['mql']:
            report.append("📊 ANÁLISE MQL4/MQL5")
            report.append("-" * 40)
            mql_results = self.results['mql']
            
            if 'ftmo_compliance' in mql_results:
                ftmo = mql_results['ftmo_compliance']
                report.append(f"FTMO Compliance Score: {ftmo['score']}/10")
                if ftmo['issues']:
                    report.append("Issues FTMO:")
                    for issue in ftmo['issues']:
                        report.append(f"  - {issue}")
            
            if 'trading_patterns' in mql_results:
                patterns = mql_results['trading_patterns']
                if patterns['detected']:
                    report.append(f"Padrões detectados: {', '.join(patterns['detected'])}")
            
            report.append("")
        
        # Resumo geral
        report.append("📋 RESUMO GERAL")
        report.append("-" * 40)
        
        total_errors = 0
        total_warnings = 0
        
        if self.results['python']:
            py = self.results['python']
            total_errors += len(py.get('pylint', {}).get('errors', []))
            total_errors += len(py.get('flake8', {}).get('errors', []))
            total_warnings += len(py.get('pylint', {}).get('warnings', []))
        
        if self.results['javascript']:
            js = self.results['javascript']
            total_errors += len(js.get('eslint', {}).get('errors', []))
            total_warnings += len(js.get('eslint', {}).get('warnings', []))
        
        if self.results['mql']:
            mql = self.results['mql']
            total_errors += len(mql.get('ftmo_compliance', {}).get('issues', []))
        
        report.append(f"Total de Erros: {total_errors}")
        report.append(f"Total de Warnings: {total_warnings}")
        
        # Status geral
        if total_errors == 0:
            report.append("\n✅ STATUS: APROVADO - Código pronto para produção")
        elif total_errors <= 5:
            report.append("\n⚠️  STATUS: ATENÇÃO - Corrigir erros antes da entrega")
        else:
            report.append("\n❌ STATUS: REPROVADO - Muitos erros, revisão necessária")
        
        report.append("=" * 80)
        
        return "\n".join(report)
    
    def run_full_check(self, directories: List[str] = None) -> str:
        """Executa verificação completa de qualidade."""
        if directories is None:
            directories = [
                str(self.project_root / 'MQL_Scripts'),
                str(self.project_root / 'MQL4_Source'),
                str(self.project_root / 'MQL5_Source'),
                str(self.project_root / 'TradingView_Scripts'),
                str(self.project_root / 'MCP_Integration')
            ]
        
        logger.info("Iniciando verificação completa de qualidade")
        
        for directory in directories:
            if Path(directory).exists():
                logger.info(f"Verificando diretório: {directory}")
                
                # Verificar Python
                py_results = self.check_python_files(directory)
                if py_results:
                    self.results['python'].update(py_results)
                
                # Verificar JavaScript
                js_results = self.check_javascript_files(directory)
                if js_results:
                    self.results['javascript'].update(js_results)
                
                # Verificar MQL
                mql_results = self.check_mql_files(directory)
                if mql_results:
                    self.results['mql'].update(mql_results)
        
        # Gerar relatório
        report = self.generate_report()
        
        # Salvar relatório
        report_file = self.project_root / 'quality_report.txt'
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write(report)
        
        logger.info(f"Relatório salvo em: {report_file}")
        
        return report

def main():
    """Função principal."""
    parser = argparse.ArgumentParser(description='Verificação de Qualidade de Código')
    parser.add_argument('--project-root', default='.', help='Diretório raiz do projeto')
    parser.add_argument('--directories', nargs='+', help='Diretórios específicos para verificar')
    parser.add_argument('--python-only', action='store_true', help='Verificar apenas arquivos Python')
    parser.add_argument('--mql-only', action='store_true', help='Verificar apenas arquivos MQL')
    parser.add_argument('--js-only', action='store_true', help='Verificar apenas arquivos JavaScript')
    
    args = parser.parse_args()
    
    checker = QualityChecker(args.project_root)
    
    if args.python_only:
        directories = args.directories or [args.project_root]
        for directory in directories:
            results = checker.check_python_files(directory)
            checker.results['python'].update(results)
    elif args.mql_only:
        directories = args.directories or [args.project_root]
        for directory in directories:
            results = checker.check_mql_files(directory)
            checker.results['mql'].update(results)
    elif args.js_only:
        directories = args.directories or [args.project_root]
        for directory in directories:
            results = checker.check_javascript_files(directory)
            checker.results['javascript'].update(results)
    else:
        report = checker.run_full_check(args.directories)
        print(report)
        return
    
    # Gerar relatório para verificações específicas
    report = checker.generate_report()
    print(report)

if __name__ == '__main__':
    main()