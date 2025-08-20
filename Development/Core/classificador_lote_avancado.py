#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🔧 CLASSIFICADOR LOTE AVANÇADO - PASSO 2
Sistema de classificação automática em lote com interface de progresso

Autor: Classificador_Trading
Versão: 2.0
Data: 12/08/2025

Recursos:
- Processamento em lote de múltiplos arquivos
- Interface de progresso em tempo real
- Processamento paralelo (multithreading)
- Relatórios detalhados por categoria
- Sistema de backup automático
- Detecção de erros e recuperação
- Estatísticas avançadas
"""

import os
import sys
import json
import time
import threading
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
import shutil
from typing import Dict, List, Tuple, Optional

# Importar o sistema principal
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from classificador_qualidade_maxima import TradingCodeAnalyzer

class ClassificadorLoteAvancado:
    """
    Sistema avançado de classificação em lote com interface de progresso
    """
    
    def __init__(self, max_workers: int = 4, base_path: str = "."):
        self.analyzer = TradingCodeAnalyzer(base_path)
        self.max_workers = max_workers
        self.stats = {
            'total_files': 0,
            'processed': 0,
            'successful': 0,
            'errors': 0,
            'skipped': 0,
            'start_time': None,
            'end_time': None,
            'categories': {},
            'quality_distribution': {},
            'ftmo_distribution': {},
            'errors_list': []
        }
        self.progress_callback = None
        self.stop_processing = False
        
    def set_progress_callback(self, callback):
        """Define callback para atualização de progresso"""
        self.progress_callback = callback
        
    def _update_progress(self, message: str, percentage: float = None):
        """Atualiza progresso via callback ou print"""
        if self.progress_callback:
            self.progress_callback(message, percentage)
        else:
            if percentage is not None:
                print(f"\r[{percentage:6.2f}%] {message}", end='', flush=True)
            else:
                print(f"\n{message}")
                
    def _create_backup(self, source_dir: str) -> str:
        """Cria backup da pasta antes do processamento"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_dir = f"BACKUP_LOTE_{timestamp}"
        backup_path = os.path.join(os.path.dirname(source_dir), backup_dir)
        
        self._update_progress(f"🔄 Criando backup em {backup_dir}...")
        shutil.copytree(source_dir, backup_path)
        self._update_progress(f"✅ Backup criado: {backup_path}")
        
        return backup_path
        
    def _scan_files(self, directory: str, extensions: List[str]) -> List[str]:
        """Escaneia diretório em busca de arquivos para processar"""
        files = []
        
        self._update_progress("🔍 Escaneando arquivos...")
        
        for root, dirs, filenames in os.walk(directory):
            for filename in filenames:
                if any(filename.lower().endswith(ext) for ext in extensions):
                    files.append(os.path.join(root, filename))
                    
        self._update_progress(f"📁 Encontrados {len(files)} arquivos para processar")
        return files
        
    def _process_single_file(self, file_path: str) -> Dict:
        """Processa um único arquivo"""
        try:
            if self.stop_processing:
                return {'status': 'stopped', 'file': file_path}
                
            # Analisar arquivo
            result = self.analyzer.analyze_file(file_path)
            
            # Atualizar estatísticas
            self._update_stats(result)
            
            return {
                'status': 'success',
                'file': file_path,
                'result': result
            }
            
        except Exception as e:
            error_info = {
                'file': file_path,
                'error': str(e),
                'timestamp': datetime.now().isoformat()
            }
            self.stats['errors_list'].append(error_info)
            
            return {
                'status': 'error',
                'file': file_path,
                'error': str(e)
            }
            
    def _update_stats(self, result: Dict):
        """Atualiza estatísticas em tempo real"""
        # Categoria
        category = result.get('detected_type', 'Unknown')
        self.stats['categories'][category] = self.stats['categories'].get(category, 0) + 1
        
        # Qualidade
        quality_level = result.get('quality_level', 'Unknown')
        self.stats['quality_distribution'][quality_level] = self.stats['quality_distribution'].get(quality_level, 0) + 1
        
        # FTMO
        ftmo_level = result.get('ftmo_level', 'Unknown')
        self.stats['ftmo_distribution'][ftmo_level] = self.stats['ftmo_distribution'].get(ftmo_level, 0) + 1
        
    def _generate_progress_report(self) -> str:
        """Gera relatório de progresso em tempo real"""
        elapsed = time.time() - self.stats['start_time']
        rate = self.stats['processed'] / elapsed if elapsed > 0 else 0
        
        report = f"""
📊 PROGRESSO EM TEMPO REAL

⏱️  Tempo decorrido: {elapsed:.1f}s
📈 Taxa: {rate:.1f} arquivos/s
✅ Processados: {self.stats['processed']}/{self.stats['total_files']}
🎯 Sucessos: {self.stats['successful']}
❌ Erros: {self.stats['errors']}
⏭️  Ignorados: {self.stats['skipped']}

📁 CATEGORIAS DETECTADAS:
"""
        
        for category, count in self.stats['categories'].items():
            percentage = (count / self.stats['processed']) * 100 if self.stats['processed'] > 0 else 0
            report += f"   {category}: {count} ({percentage:.1f}%)\n"
            
        return report
        
    def process_directory(self, 
                         source_dir: str, 
                         extensions: List[str] = ['.mq4', '.mq5', '.pine'],
                         create_backup: bool = True,
                         show_progress: bool = True,
                         config: Dict = None) -> Dict:
        """Processa diretório completo em lote"""
        
        # Aplicar configurações se fornecidas
        if config is None:
            config = {}
        
        # Aplicar configurações
        self.max_workers = config.get('parallel_workers', self.max_workers)
        create_backup = config.get('create_backup', create_backup)
        show_progress = config.get('show_progress', show_progress)
        
        self.stats['start_time'] = time.time()
        
        try:
            # Criar backup se solicitado
            backup_path = None
            if create_backup:
                backup_path = self._create_backup(source_dir)
                
            # Escanear arquivos
            files = self._scan_files(source_dir, extensions)
            self.stats['total_files'] = len(files)
            
            if not files:
                self._update_progress("⚠️ Nenhum arquivo encontrado para processar")
                return self._generate_final_report(backup_path)
                
            # Processar arquivos em paralelo
            self._update_progress(f"🚀 Iniciando processamento com {self.max_workers} threads...")
            
            results = []
            with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
                # Submeter tarefas
                future_to_file = {executor.submit(self._process_single_file, file_path): file_path 
                                for file_path in files}
                
                # Processar resultados conforme completam
                for future in as_completed(future_to_file):
                    if self.stop_processing:
                        break
                        
                    result = future.result()
                    results.append(result)
                    
                    self.stats['processed'] += 1
                    
                    if result['status'] == 'success':
                        self.stats['successful'] += 1
                    elif result['status'] == 'error':
                        self.stats['errors'] += 1
                    else:
                        self.stats['skipped'] += 1
                        
                    # Atualizar progresso
                    percentage = (self.stats['processed'] / self.stats['total_files']) * 100
                    self._update_progress(
                        f"Processando {os.path.basename(result['file'])}...", 
                        percentage
                    )
                    
                    # Mostrar relatório a cada 10 arquivos
                    if show_progress and self.stats['processed'] % 10 == 0:
                        print("\n" + self._generate_progress_report())
                        
            self.stats['end_time'] = time.time()
            
            # Gerar relatório final
            final_report = self._generate_final_report(backup_path, results)
            
            self._update_progress("\n✅ Processamento concluído!")
            
            return final_report
            
        except Exception as e:
            self._update_progress(f"❌ Erro crítico: {str(e)}")
            raise
            
    def _generate_final_report(self, backup_path: str = None, results: List[Dict] = None) -> Dict:
        """Gera relatório final detalhado"""
        
        total_time = (self.stats['end_time'] or time.time()) - self.stats['start_time']
        
        report = {
            'timestamp': datetime.now().isoformat(),
            'execution_time': total_time,
            'backup_path': backup_path,
            'statistics': self.stats.copy(),
            'performance': {
                'files_per_second': self.stats['processed'] / total_time if total_time > 0 else 0,
                'success_rate': (self.stats['successful'] / self.stats['processed']) * 100 if self.stats['processed'] > 0 else 0,
                'error_rate': (self.stats['errors'] / self.stats['processed']) * 100 if self.stats['processed'] > 0 else 0
            },
            'recommendations': self._generate_recommendations(),
            'top_categories': self._get_top_categories(),
            'quality_summary': self._get_quality_summary(),
            'ftmo_summary': self._get_ftmo_summary()
        }
        
        # Salvar relatório
        report_filename = f"relatorio_lote_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        report_path = os.path.join("Development", "Reports", "Auto_Avaliacao", report_filename)
        
        os.makedirs(os.path.dirname(report_path), exist_ok=True)
        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
            
        self._update_progress(f"📊 Relatório salvo: {report_path}")
        
        return report
        
    def _generate_recommendations(self) -> List[str]:
        """Gera recomendações baseadas nos resultados"""
        recommendations = []
        
        # Taxa de erro
        error_rate = (self.stats['errors'] / self.stats['processed']) * 100 if self.stats['processed'] > 0 else 0
        if error_rate > 10:
            recommendations.append(f"⚠️ Alta taxa de erros ({error_rate:.1f}%) - revisar arquivos problemáticos")
            
        # Categorias desconhecidas
        unknown_count = self.stats['categories'].get('Unknown', 0)
        if unknown_count > 0:
            unknown_rate = (unknown_count / self.stats['processed']) * 100 if self.stats['processed'] > 0 else 0
            recommendations.append(f"🔍 {unknown_count} arquivos não classificados ({unknown_rate:.1f}%) - melhorar padrões de detecção")
            
        # Performance
        rate = self.stats['processed'] / (time.time() - self.stats['start_time']) if self.stats['start_time'] else 0
        if rate < 10:
            recommendations.append(f"⚡ Performance baixa ({rate:.1f} arq/s) - considerar otimizações")
            
        return recommendations
        
    def _get_top_categories(self) -> List[Tuple[str, int]]:
        """Retorna top 5 categorias mais comuns"""
        return sorted(self.stats['categories'].items(), key=lambda x: x[1], reverse=True)[:5]
        
    def _get_quality_summary(self) -> Dict:
        """Resumo da distribuição de qualidade"""
        return self.stats['quality_distribution'].copy()
        
    def _get_ftmo_summary(self) -> Dict:
        """Resumo da distribuição FTMO"""
        return self.stats['ftmo_distribution'].copy()
        
    def stop(self):
        """Para o processamento"""
        self.stop_processing = True
        self._update_progress("🛑 Parando processamento...")

def main():
    """Função principal para teste"""
    print("🔧 CLASSIFICADOR LOTE AVANÇADO - PASSO 2")
    print("="*50)
    
    # Configurar diretório de teste
    test_dir = "CODIGO_FONTE_LIBRARY"
    
    if not os.path.exists(test_dir):
        print(f"❌ Diretório {test_dir} não encontrado")
        return
        
    # Criar classificador
    classificador = ClassificadorLoteAvancado(max_workers=4)
    
    try:
        # Processar diretório
        report = classificador.process_directory(
            source_dir=test_dir,
            extensions=['.mq4', '.mq5', '.pine'],
            create_backup=True,
            show_progress=True
        )
        
        # Mostrar resumo
        print("\n" + "="*50)
        print("📊 RESUMO FINAL")
        print("="*50)
        print(f"⏱️  Tempo total: {report['execution_time']:.2f}s")
        print(f"📈 Taxa: {report['performance']['files_per_second']:.1f} arquivos/s")
        print(f"✅ Taxa de sucesso: {report['performance']['success_rate']:.1f}%")
        print(f"❌ Taxa de erro: {report['performance']['error_rate']:.1f}%")
        
        print("\n🏆 TOP CATEGORIAS:")
        for category, count in report['top_categories']:
            print(f"   {category}: {count} arquivos")
            
        if report['recommendations']:
            print("\n💡 RECOMENDAÇÕES:")
            for rec in report['recommendations']:
                print(f"   {rec}")
                
    except KeyboardInterrupt:
        print("\n🛑 Processamento interrompido pelo usuário")
        classificador.stop()
    except Exception as e:
        print(f"\n❌ Erro: {str(e)}")
        
if __name__ == "__main__":
    main()