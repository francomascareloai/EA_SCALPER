#!/usr/bin/env python3
"""
EA FTMO Scalper Elite - Syntax Checker
Análise de sintaxe e verificação de dependências
"""

import os
import re
import sys
from pathlib import Path
from typing import List, Dict, Set, Tuple

class MQL5SyntaxChecker:
    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.source_dir = self.project_root / "MQL5_Source"
        self.errors = []
        self.warnings = []
        self.includes_found = set()
        self.includes_required = set()
        
    def check_file_exists(self, file_path: Path) -> bool:
        """Verifica se arquivo existe"""
        return file_path.exists() and file_path.is_file()
    
    def extract_includes(self, content: str) -> List[str]:
        """Extrai includes do código MQL5"""
        includes = []
        lines = content.split('\n')
        
        for line_num, line in enumerate(lines, 1):
            line = line.strip()
            
            # Include com aspas duplas
            match = re.match(r'#include\s+"([^"]+)"', line)
            if match:
                includes.append(match.group(1))
                continue
                
            # Include com brackets
            match = re.match(r'#include\s+<([^>]+)>', line)
            if match:
                includes.append(match.group(1))
                
        return includes
    
    def check_basic_syntax(self, content: str, file_path: str) -> List[str]:
        """Verificação básica de sintaxe MQL5"""
        errors = []
        lines = content.split('\n')
        
        brace_count = 0
        paren_count = 0
        bracket_count = 0
        
        for line_num, line in enumerate(lines, 1):
            original_line = line
            line = line.strip()
            
            # Ignorar comentários
            if line.startswith('//') or line.startswith('/*') or line.startswith('*'):
                continue
                
            # Contar chaves, parênteses e colchetes
            brace_count += line.count('{') - line.count('}')
            paren_count += line.count('(') - line.count(')')
            bracket_count += line.count('[') - line.count(']')
            
            # Verificar ponto e vírgula em declarações
            if (line.endswith(';') == False and 
                not line.endswith('{') and 
                not line.endswith('}') and
                not line.startswith('#') and
                not line.startswith('//') and
                line != '' and
                not line.endswith(',') and
                not line.endswith('\\') and
                'if' not in line and
                'else' not in line and
                'for' not in line and
                'while' not in line and
                'switch' not in line and
                'case' not in line and
                'default' not in line):
                
                # Verificar se é uma declaração que precisa de ;
                if any(keyword in line for keyword in ['int ', 'double ', 'string ', 'bool ', 'datetime ', 'return ']):
                    errors.append(f"Linha {line_num}: Possível ponto e vírgula ausente: {original_line[:50]}...")
        
        # Verificar balanceamento final
        if brace_count != 0:
            errors.append(f"Chaves desbalanceadas: {brace_count} chaves não fechadas")
        if paren_count != 0:
            errors.append(f"Parênteses desbalanceados: {paren_count} parênteses não fechados")
        if bracket_count != 0:
            errors.append(f"Colchetes desbalanceados: {bracket_count} colchetes não fechados")
            
        return errors
    
    def check_ftmo_compliance(self, content: str) -> List[str]:
        """Verifica compliance FTMO básico"""
        warnings = []
        
        # Verificar se há gestão de risco
        if 'StopLoss' not in content and 'SL' not in content:
            warnings.append("FTMO: Stop Loss não encontrado no código")
            
        if 'TakeProfit' not in content and 'TP' not in content:
            warnings.append("FTMO: Take Profit não encontrado no código")
            
        if 'MaxDrawdown' not in content and 'drawdown' not in content.lower():
            warnings.append("FTMO: Controle de drawdown não encontrado")
            
        if 'DailyLoss' not in content and 'daily' not in content.lower():
            warnings.append("FTMO: Controle de perda diária não encontrado")
            
        # Verificar se há martingale (não permitido no FTMO)
        if 'martingale' in content.lower() or 'grid' in content.lower():
            warnings.append("FTMO: Possível uso de Martingale/Grid detectado (não permitido)")
            
        return warnings
    
    def analyze_file(self, file_path: Path) -> Dict:
        """Analisa um arquivo MQL5"""
        result = {
            'file': str(file_path),
            'exists': False,
            'size': 0,
            'lines': 0,
            'includes': [],
            'syntax_errors': [],
            'ftmo_warnings': [],
            'functions': [],
            'classes': []
        }
        
        if not self.check_file_exists(file_path):
            result['syntax_errors'].append(f"Arquivo não encontrado: {file_path}")
            return result
            
        result['exists'] = True
        result['size'] = file_path.stat().st_size
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except UnicodeDecodeError:
            try:
                with open(file_path, 'r', encoding='latin-1') as f:
                    content = f.read()
            except Exception as e:
                result['syntax_errors'].append(f"Erro ao ler arquivo: {e}")
                return result
        
        result['lines'] = len(content.split('\n'))
        result['includes'] = self.extract_includes(content)
        result['syntax_errors'] = self.check_basic_syntax(content, str(file_path))
        result['ftmo_warnings'] = self.check_ftmo_compliance(content)
        
        # Extrair funções
        functions = re.findall(r'(?:int|double|string|bool|void|datetime)\s+(\w+)\s*\([^)]*\)', content)
        result['functions'] = functions
        
        # Extrair classes
        classes = re.findall(r'class\s+(\w+)', content)
        result['classes'] = classes
        
        return result
    
    def check_dependencies(self, main_file_analysis: Dict) -> List[str]:
        """Verifica dependências dos includes"""
        missing_deps = []
        
        for include in main_file_analysis['includes']:
            # Pular includes do sistema
            if include.startswith('Trade\\') or include.startswith('Object\\'):
                continue
                
            # Construir caminho do include
            include_path = self.source_dir / "Source" / include
            
            if not self.check_file_exists(include_path):
                missing_deps.append(f"Include não encontrado: {include} -> {include_path}")
                
        return missing_deps
    
    def run_analysis(self) -> Dict:
        """Executa análise completa"""
        print("🔍 Iniciando análise de sintaxe do EA FTMO Scalper Elite...")
        print("=" * 60)
        
        # Arquivo principal
        main_ea_path = self.source_dir / "EA_FTMO_Scalper_Elite.mq5"
        
        # Analisar arquivo principal
        print(f"📁 Analisando arquivo principal: {main_ea_path.name}")
        main_analysis = self.analyze_file(main_ea_path)
        
        # Verificar dependências
        print("🔗 Verificando dependências...")
        dependency_errors = self.check_dependencies(main_analysis)
        
        # Analisar includes principais
        include_analyses = {}
        core_includes = [
            "Source/Core/DataStructures.mqh",
            "Source/Core/Interfaces.mqh", 
            "Source/Core/Logger.mqh",
            "Source/Core/ConfigManager.mqh",
            "Source/Core/CacheManager.mqh",
            "Source/Core/PerformanceAnalyzer.mqh",
            "Source/Strategies/ICT/OrderBlockDetector.mqh",
            "Source/Strategies/ICT/FVGDetector.mqh",
            "Source/Strategies/ICT/LiquidityDetector.mqh",
            "Source/Strategies/ICT/MarketStructureAnalyzer.mqh"
        ]
        
        print("📋 Analisando módulos principais...")
        for include in core_includes:
            include_path = self.source_dir / include
            print(f"  • {include_path.name}")
            include_analyses[include] = self.analyze_file(include_path)
        
        # Compilar resultados
        total_errors = len(main_analysis['syntax_errors']) + len(dependency_errors)
        total_warnings = len(main_analysis['ftmo_warnings'])
        total_lines = main_analysis['lines']
        total_functions = len(main_analysis['functions'])
        total_classes = len(main_analysis['classes'])
        
        for analysis in include_analyses.values():
            total_errors += len(analysis['syntax_errors'])
            total_warnings += len(analysis['ftmo_warnings'])
            total_lines += analysis['lines']
            total_functions += len(analysis['functions'])
            total_classes += len(analysis['classes'])
        
        # Resultado final
        result = {
            'main_file': main_analysis,
            'includes': include_analyses,
            'dependency_errors': dependency_errors,
            'summary': {
                'total_files': 1 + len(include_analyses),
                'total_lines': total_lines,
                'total_functions': total_functions,
                'total_classes': total_classes,
                'total_errors': total_errors,
                'total_warnings': total_warnings,
                'compilation_ready': total_errors == 0
            }
        }
        
        return result
    
    def print_report(self, analysis: Dict):
        """Imprime relatório de análise"""
        print("\n" + "=" * 60)
        print("📊 RELATÓRIO DE ANÁLISE DE SINTAXE")
        print("=" * 60)
        
        summary = analysis['summary']
        
        print(f"📁 Arquivos analisados: {summary['total_files']}")
        print(f"📝 Total de linhas: {summary['total_lines']:,}")
        print(f"⚙️  Total de funções: {summary['total_functions']}")
        print(f"🏗️  Total de classes: {summary['total_classes']}")
        print(f"❌ Total de erros: {summary['total_errors']}")
        print(f"⚠️  Total de avisos: {summary['total_warnings']}")
        
        status = "✅ PRONTO PARA COMPILAÇÃO" if summary['compilation_ready'] else "❌ REQUER CORREÇÕES"
        print(f"\n🎯 Status: {status}")
        
        # Erros detalhados
        if summary['total_errors'] > 0:
            print("\n" + "=" * 40)
            print("❌ ERROS ENCONTRADOS:")
            print("=" * 40)
            
            # Erros do arquivo principal
            if analysis['main_file']['syntax_errors']:
                print(f"\n📄 {analysis['main_file']['file']}:")
                for error in analysis['main_file']['syntax_errors']:
                    print(f"  • {error}")
            
            # Erros de dependências
            if analysis['dependency_errors']:
                print(f"\n🔗 Dependências:")
                for error in analysis['dependency_errors']:
                    print(f"  • {error}")
            
            # Erros dos includes
            for include_path, include_analysis in analysis['includes'].items():
                if include_analysis['syntax_errors']:
                    print(f"\n📋 {include_path}:")
                    for error in include_analysis['syntax_errors']:
                        print(f"  • {error}")
        
        # Avisos FTMO
        if summary['total_warnings'] > 0:
            print("\n" + "=" * 40)
            print("⚠️  AVISOS FTMO:")
            print("=" * 40)
            
            if analysis['main_file']['ftmo_warnings']:
                for warning in analysis['main_file']['ftmo_warnings']:
                    print(f"  • {warning}")
        
        print("\n" + "=" * 60)
        
        if summary['compilation_ready']:
            print("✅ O EA está pronto para compilação no MetaEditor!")
            print("\n📋 Próximos passos:")
            print("1. Abra o MetaEditor (MetaTrader 5)")
            print("2. Abra o arquivo: MQL5_Source/EA_FTMO_Scalper_Elite.mq5")
            print("3. Pressione F7 para compilar")
            print("4. Execute testes no Strategy Tester")
        else:
            print("❌ Corrija os erros antes de compilar!")
            
        print("=" * 60)

def main():
    """Função principal"""
    project_root = os.getcwd()
    checker = MQL5SyntaxChecker(project_root)
    
    try:
        analysis = checker.run_analysis()
        checker.print_report(analysis)
        
        # Retornar código de saída apropriado
        if analysis['summary']['compilation_ready']:
            sys.exit(0)
        else:
            sys.exit(1)
            
    except Exception as e:
        print(f"❌ Erro durante análise: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()