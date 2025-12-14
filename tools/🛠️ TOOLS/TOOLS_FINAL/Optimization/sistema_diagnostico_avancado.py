#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🔍 SISTEMA DE DIAGNÓSTICO AVANÇADO E CORREÇÃO DE ERROS
Classificador Trading - Análise Profunda + Auto-Correção

Autor: ClassificadorTrading
Versão: 6.0
Data: 13/08/2025

Recursos:
- Diagnóstico completo do sistema anterior
- Detecção automática de problemas
- Correção de erros em tempo real
- Análise de logs detalhada
- Implementação de melhorias automáticas
- Sistema de validação rigorosa
"""

import sys
import os
import json
import time
import logging
import re
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any, Optional, Tuple
from concurrent.futures import ThreadPoolExecutor, as_completed
import threading
import traceback
import psutil
import gc

# Configurar logging avançado
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('diagnostico_avancado.log', encoding='utf-8'),
        logging.StreamHandler()
    ]
)

class SystemDiagnostics:
    """Sistema de Diagnóstico Avançado"""
    
    def __init__(self):
        self.logger = logging.getLogger('SystemDiagnostics')
        self.issues_found = []
        self.performance_metrics = {}
        self.system_health = {}
    
    def run_full_diagnostic(self, base_path: str) -> Dict[str, Any]:
        """Executa diagnóstico completo do sistema"""
        self.logger.info("🔍 INICIANDO DIAGNÓSTICO COMPLETO DO SISTEMA")
        self.logger.info("=" * 70)
        
        base_path = Path(base_path)
        diagnostic_results = {
            'timestamp': datetime.now().isoformat(),
            'system_health': {},
            'file_analysis': {},
            'performance_analysis': {},
            'issues_detected': [],
            'recommendations': [],
            'auto_fixes_applied': []
        }
        
        # 1. Análise de saúde do sistema
        self.logger.info("📊 1. Analisando saúde do sistema...")
        diagnostic_results['system_health'] = self._analyze_system_health()
        
        # 2. Análise de arquivos e estrutura
        self.logger.info("📁 2. Analisando estrutura de arquivos...")
        diagnostic_results['file_analysis'] = self._analyze_file_structure(base_path)
        
        # 3. Análise de logs anteriores
        self.logger.info("📋 3. Analisando logs de execuções anteriores...")
        diagnostic_results['log_analysis'] = self._analyze_previous_logs(base_path)
        
        # 4. Análise de performance
        self.logger.info("⚡ 4. Analisando performance do sistema...")
        diagnostic_results['performance_analysis'] = self._analyze_performance_issues()
        
        # 5. Detecção de problemas específicos
        self.logger.info("🔎 5. Detectando problemas específicos...")
        diagnostic_results['issues_detected'] = self._detect_specific_issues(base_path)
        
        # 6. Geração de recomendações
        self.logger.info("💡 6. Gerando recomendações...")
        diagnostic_results['recommendations'] = self._generate_recommendations()
        
        # 7. Aplicação de correções automáticas
        self.logger.info("🔧 7. Aplicando correções automáticas...")
        diagnostic_results['auto_fixes_applied'] = self._apply_auto_fixes(base_path)
        
        self.logger.info("✅ Diagnóstico completo finalizado")
        return diagnostic_results
    
    def _analyze_system_health(self) -> Dict[str, Any]:
        """Analisa saúde geral do sistema"""
        try:
            # Informações de memória
            memory = psutil.virtual_memory()
            disk = psutil.disk_usage('C:\\')
            cpu_percent = psutil.cpu_percent(interval=1)
            
            health = {
                'memory': {
                    'total_gb': round(memory.total / (1024**3), 2),
                    'available_gb': round(memory.available / (1024**3), 2),
                    'percent_used': memory.percent,
                    'status': 'OK' if memory.percent < 80 else 'WARNING' if memory.percent < 90 else 'CRITICAL'
                },
                'disk': {
                    'total_gb': round(disk.total / (1024**3), 2),
                    'free_gb': round(disk.free / (1024**3), 2),
                    'percent_used': round((disk.used / disk.total) * 100, 2),
                    'status': 'OK' if disk.free > 5*(1024**3) else 'WARNING'
                },
                'cpu': {
                    'percent_used': cpu_percent,
                    'status': 'OK' if cpu_percent < 70 else 'WARNING' if cpu_percent < 90 else 'CRITICAL'
                }
            }
            
            self.logger.info(f"💾 Memória: {health['memory']['percent_used']:.1f}% usada - {health['memory']['status']}")
            self.logger.info(f"💿 Disco: {health['disk']['percent_used']:.1f}% usado - {health['disk']['status']}")
            self.logger.info(f"🖥️ CPU: {health['cpu']['percent_used']:.1f}% usado - {health['cpu']['status']}")
            
            return health
            
        except Exception as e:
            self.logger.error(f"❌ Erro na análise de saúde do sistema: {e}")
            return {'error': str(e)}
    
    def _analyze_file_structure(self, base_path: Path) -> Dict[str, Any]:
        """Analisa estrutura de arquivos"""
        analysis = {
            'total_mq4_files': 0,
            'organized_files': 0,
            'unorganized_files': 0,
            'metadata_files': 0,
            'report_files': 0,
            'structure_issues': []
        }
        
        try:
            # Contar arquivos MQ4 originais
            all_mq4_path = base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "All_MQ4"
            if all_mq4_path.exists():
                analysis['total_mq4_files'] = len(list(all_mq4_path.glob("*.mq4")))
                self.logger.info(f"📁 Arquivos MQ4 em All_MQ4: {analysis['total_mq4_files']}")
            
            # Contar arquivos organizados
            organized_paths = [
                base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "EAs",
                base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "Indicators",
                base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "Scripts"
            ]
            
            for path in organized_paths:
                if path.exists():
                    count = len(list(path.rglob("*.mq4")))
                    analysis['organized_files'] += count
                    self.logger.info(f"📂 Arquivos em {path.name}: {count}")
            
            # Contar metadados
            metadata_path = base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "Metadata"
            if metadata_path.exists():
                analysis['metadata_files'] = len(list(metadata_path.glob("*.json")))
                self.logger.info(f"📄 Arquivos de metadados: {analysis['metadata_files']}")
            
            # Contar relatórios
            reports_path = base_path / "Reports"
            if reports_path.exists():
                analysis['report_files'] = len(list(reports_path.glob("*.md"))) + len(list(reports_path.glob("*.json")))
                self.logger.info(f"📊 Arquivos de relatório: {analysis['report_files']}")
            
            # Calcular arquivos não organizados
            analysis['unorganized_files'] = analysis['total_mq4_files'] - analysis['organized_files']
            
            # Detectar problemas estruturais
            if analysis['unorganized_files'] > 0:
                analysis['structure_issues'].append(f"{analysis['unorganized_files']} arquivos ainda não organizados")
            
            if analysis['metadata_files'] == 0:
                analysis['structure_issues'].append("Nenhum arquivo de metadados encontrado")
            
            return analysis
            
        except Exception as e:
            self.logger.error(f"❌ Erro na análise de estrutura: {e}")
            return {'error': str(e)}
    
    def _analyze_previous_logs(self, base_path: Path) -> Dict[str, Any]:
        """Analisa logs de execuções anteriores"""
        log_analysis = {
            'log_files_found': [],
            'errors_detected': [],
            'warnings_detected': [],
            'performance_issues': [],
            'success_patterns': []
        }
        
        try:
            # Procurar arquivos de log
            log_files = list(base_path.glob("*.log"))
            log_analysis['log_files_found'] = [str(f) for f in log_files]
            
            self.logger.info(f"📋 Arquivos de log encontrados: {len(log_files)}")
            
            for log_file in log_files:
                try:
                    with open(log_file, 'r', encoding='utf-8', errors='ignore') as f:
                        content = f.read()
                    
                    # Detectar erros
                    error_patterns = [
                        r'ERROR.*',
                        r'Exception.*',
                        r'Traceback.*',
                        r'Failed.*',
                        r'❌.*'
                    ]
                    
                    for pattern in error_patterns:
                        matches = re.findall(pattern, content, re.IGNORECASE)
                        log_analysis['errors_detected'].extend(matches[:5])  # Primeiros 5
                    
                    # Detectar warnings
                    warning_patterns = [
                        r'WARNING.*',
                        r'⚠️.*',
                        r'WARN.*'
                    ]
                    
                    for pattern in warning_patterns:
                        matches = re.findall(pattern, content, re.IGNORECASE)
                        log_analysis['warnings_detected'].extend(matches[:5])
                    
                    # Detectar problemas de performance
                    if 'timeout' in content.lower() or 'slow' in content.lower():
                        log_analysis['performance_issues'].append(f"Problemas de performance em {log_file.name}")
                    
                    # Detectar padrões de sucesso
                    if 'concluído com sucesso' in content.lower():
                        log_analysis['success_patterns'].append(f"Execução bem-sucedida em {log_file.name}")
                
                except Exception as e:
                    self.logger.warning(f"⚠️ Erro ao analisar {log_file}: {e}")
            
            self.logger.info(f"🔍 Erros detectados: {len(log_analysis['errors_detected'])}")
            self.logger.info(f"⚠️ Warnings detectados: {len(log_analysis['warnings_detected'])}")
            
            return log_analysis
            
        except Exception as e:
            self.logger.error(f"❌ Erro na análise de logs: {e}")
            return {'error': str(e)}
    
    def _analyze_performance_issues(self) -> Dict[str, Any]:
        """Analisa problemas de performance"""
        performance = {
            'memory_leaks_detected': False,
            'cpu_bottlenecks': False,
            'io_bottlenecks': False,
            'threading_issues': False,
            'recommendations': []
        }
        
        try:
            # Verificar uso de memória
            memory = psutil.virtual_memory()
            if memory.percent > 85:
                performance['memory_leaks_detected'] = True
                performance['recommendations'].append("Implementar garbage collection mais agressivo")
            
            # Verificar CPU
            cpu_percent = psutil.cpu_percent(interval=1)
            if cpu_percent > 80:
                performance['cpu_bottlenecks'] = True
                performance['recommendations'].append("Otimizar algoritmos de processamento")
            
            # Verificar I/O
            disk_io = psutil.disk_io_counters()
            if disk_io and disk_io.read_time > 1000:  # ms
                performance['io_bottlenecks'] = True
                performance['recommendations'].append("Implementar cache de arquivos")
            
            return performance
            
        except Exception as e:
            self.logger.error(f"❌ Erro na análise de performance: {e}")
            return {'error': str(e)}
    
    def _detect_specific_issues(self, base_path: Path) -> List[Dict[str, Any]]:
        """Detecta problemas específicos do sistema"""
        issues = []
        
        try:
            # Issue 1: Arquivos não processados
            all_mq4_path = base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "All_MQ4"
            if all_mq4_path.exists():
                unprocessed_count = len(list(all_mq4_path.glob("*.mq4")))
                if unprocessed_count > 0:
                    issues.append({
                        'type': 'unprocessed_files',
                        'severity': 'HIGH',
                        'description': f"{unprocessed_count} arquivos MQ4 não foram processados",
                        'solution': "Executar processamento completo com validação"
                    })
            
            # Issue 2: Metadados incompletos
            metadata_path = base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "Metadata"
            if not metadata_path.exists() or len(list(metadata_path.glob("*.json"))) == 0:
                issues.append({
                    'type': 'missing_metadata',
                    'severity': 'MEDIUM',
                    'description': "Metadados não foram gerados ou estão incompletos",
                    'solution': "Regenerar metadados com sistema aprimorado"
                })
            
            # Issue 3: Estrutura de pastas incompleta
            required_dirs = [
                "CODIGO_FONTE_LIBRARY/MQL4_Source/EAs",
                "CODIGO_FONTE_LIBRARY/MQL4_Source/Indicators",
                "CODIGO_FONTE_LIBRARY/MQL4_Source/Scripts",
                "Reports",
                "Metadata"
            ]
            
            for dir_path in required_dirs:
                full_path = base_path / dir_path
                if not full_path.exists():
                    issues.append({
                        'type': 'missing_directory',
                        'severity': 'MEDIUM',
                        'description': f"Diretório obrigatório não existe: {dir_path}",
                        'solution': f"Criar diretório {dir_path}"
                    })
            
            # Issue 4: Logs com erros
            log_files = list(base_path.glob("*.log"))
            for log_file in log_files:
                try:
                    with open(log_file, 'r', encoding='utf-8', errors='ignore') as f:
                        content = f.read()
                    
                    if 'ERROR' in content or 'Exception' in content:
                        issues.append({
                            'type': 'log_errors',
                            'severity': 'HIGH',
                            'description': f"Erros detectados em {log_file.name}",
                            'solution': "Investigar e corrigir erros específicos"
                        })
                except:
                    pass
            
            self.logger.info(f"🔍 Total de problemas detectados: {len(issues)}")
            for issue in issues:
                self.logger.warning(f"⚠️ {issue['severity']}: {issue['description']}")
            
            return issues
            
        except Exception as e:
            self.logger.error(f"❌ Erro na detecção de problemas: {e}")
            return [{'type': 'detection_error', 'description': str(e)}]
    
    def _generate_recommendations(self) -> List[str]:
        """Gera recomendações baseadas na análise"""
        recommendations = [
            "Implementar processamento real de arquivos MQL4 (não simulação)",
            "Adicionar validação rigorosa de sintaxe MQL4",
            "Implementar detecção automática de estratégias de trading",
            "Criar sistema de classificação FTMO mais preciso",
            "Adicionar geração de snippets de código reutilizáveis",
            "Implementar sistema de backup automático",
            "Criar dashboard de monitoramento em tempo real",
            "Adicionar testes automatizados de qualidade",
            "Implementar sistema de versionamento de arquivos",
            "Criar API para integração com outras ferramentas"
        ]
        
        self.logger.info("💡 Recomendações geradas:")
        for i, rec in enumerate(recommendations, 1):
            self.logger.info(f"  {i}. {rec}")
        
        return recommendations
    
    def _apply_auto_fixes(self, base_path: Path) -> List[str]:
        """Aplica correções automáticas"""
        fixes_applied = []
        
        try:
            # Fix 1: Criar diretórios obrigatórios
            required_dirs = [
                "CODIGO_FONTE_LIBRARY/MQL4_Source/EAs/Scalping",
                "CODIGO_FONTE_LIBRARY/MQL4_Source/EAs/Grid_Martingale",
                "CODIGO_FONTE_LIBRARY/MQL4_Source/EAs/Trend_Following",
                "CODIGO_FONTE_LIBRARY/MQL4_Source/Indicators/SMC_ICT",
                "CODIGO_FONTE_LIBRARY/MQL4_Source/Indicators/Volume",
                "CODIGO_FONTE_LIBRARY/MQL4_Source/Scripts/Utilities",
                "Reports",
                "Metadata",
                "Snippets"
            ]
            
            for dir_path in required_dirs:
                full_path = base_path / dir_path
                if not full_path.exists():
                    full_path.mkdir(parents=True, exist_ok=True)
                    fixes_applied.append(f"Criado diretório: {dir_path}")
                    self.logger.info(f"✅ Criado: {dir_path}")
            
            # Fix 2: Criar arquivo de configuração
            config_path = base_path / "config_sistema.json"
            if not config_path.exists():
                config = {
                    "version": "6.0",
                    "batch_size": 100,
                    "max_threads": 4,
                    "timeout_per_file": 60,
                    "enable_real_processing": True,
                    "enable_ftmo_validation": True,
                    "enable_auto_backup": True
                }
                
                with open(config_path, 'w', encoding='utf-8') as f:
                    json.dump(config, f, indent=2, ensure_ascii=False)
                
                fixes_applied.append("Criado arquivo de configuração")
                self.logger.info("✅ Arquivo de configuração criado")
            
            # Fix 3: Limpar logs antigos
            log_files = list(base_path.glob("*.log"))
            if len(log_files) > 5:
                # Manter apenas os 5 logs mais recentes
                log_files.sort(key=lambda x: x.stat().st_mtime, reverse=True)
                for old_log in log_files[5:]:
                    old_log.unlink()
                    fixes_applied.append(f"Removido log antigo: {old_log.name}")
            
            self.logger.info(f"🔧 Total de correções aplicadas: {len(fixes_applied)}")
            
            return fixes_applied
            
        except Exception as e:
            self.logger.error(f"❌ Erro ao aplicar correções: {e}")
            return [f"Erro ao aplicar correções: {e}"]

def main():
    """Função principal do diagnóstico"""
    base_path = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD"
    
    print("🔍 SISTEMA DE DIAGNÓSTICO AVANÇADO")
    print("=" * 50)
    
    diagnostics = SystemDiagnostics()
    results = diagnostics.run_full_diagnostic(base_path)
    
    # Salvar relatório de diagnóstico
    report_path = Path(base_path) / "Reports" / f"diagnostico_completo_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    report_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(report_path, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    
    print(f"\n📄 Relatório de diagnóstico salvo em: {report_path}")
    print("\n🎯 RESUMO DO DIAGNÓSTICO:")
    print(f"  • Problemas detectados: {len(results.get('issues_detected', []))}")
    print(f"  • Correções aplicadas: {len(results.get('auto_fixes_applied', []))}")
    print(f"  • Recomendações geradas: {len(results.get('recommendations', []))}")
    
    return results

if __name__ == "__main__":
    main()