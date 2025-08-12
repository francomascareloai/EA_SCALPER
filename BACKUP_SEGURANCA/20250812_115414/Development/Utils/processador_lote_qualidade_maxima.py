#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PROCESSADOR EM LOTE - QUALIDADE MÁXIMA
Classificação e organização automática de bibliotecas de trading
Autor: Classificador_Trading_Elite
Versão: 1.0
"""

import os
import json
import shutil
from pathlib import Path
from datetime import datetime
from classificador_qualidade_maxima import TradingCodeAnalyzer

class BatchProcessor:
    def __init__(self, base_path):
        self.base_path = Path(base_path)
        self.analyzer = TradingCodeAnalyzer(base_path)
        self.results = {
            'processed': [],
            'errors': [],
            'statistics': {},
            'moved_files': [],
            'skipped_files': []
        }
        
        # Extensões suportadas
        self.supported_extensions = {'.mq4', '.mq5', '.pine', '.ex4', '.ex5'}
        
        # Pastas de origem
        self.source_folders = [
            'CODIGO_FONTE_LIBRARY/MQL4_Source/All_MQ4',
            'CODIGO_FONTE_LIBRARY/MQL5_Source/All_MQ5', 
            'CODIGO_FONTE_LIBRARY/TradingView_Scripts/Pine_Script_Source'
        ]
    
    def create_folder_structure(self):
        """Cria estrutura de pastas conforme template"""
        folders = [
            # MQL4
            'CODIGO_FONTE_LIBRARY/MQL4_Source/EAs/Scalping',
            'CODIGO_FONTE_LIBRARY/MQL4_Source/EAs/Grid_Martingale',
            'CODIGO_FONTE_LIBRARY/MQL4_Source/EAs/Trend_Following',
            'CODIGO_FONTE_LIBRARY/MQL4_Source/EAs/SMC_ICT',
            'CODIGO_FONTE_LIBRARY/MQL4_Source/EAs/Volume_Analysis',
            'CODIGO_FONTE_LIBRARY/MQL4_Source/EAs/Others',
            'CODIGO_FONTE_LIBRARY/MQL4_Source/EAs/Misc',
            'CODIGO_FONTE_LIBRARY/MQL4_Source/Indicators/SMC_ICT',
            'CODIGO_FONTE_LIBRARY/MQL4_Source/Indicators/Volume',
            'CODIGO_FONTE_LIBRARY/MQL4_Source/Indicators/Trend',
            'CODIGO_FONTE_LIBRARY/MQL4_Source/Indicators/Custom',
            'CODIGO_FONTE_LIBRARY/MQL4_Source/Indicators/Misc',
            'CODIGO_FONTE_LIBRARY/MQL4_Source/Scripts/Utilities',
            'CODIGO_FONTE_LIBRARY/MQL4_Source/Scripts/Analysis',
            'CODIGO_FONTE_LIBRARY/MQL4_Source/Scripts/Misc',
            
            # MQL5
            'CODIGO_FONTE_LIBRARY/MQL5_Source/EAs/FTMO_Ready',
            'CODIGO_FONTE_LIBRARY/MQL5_Source/EAs/Advanced_Scalping',
            'CODIGO_FONTE_LIBRARY/MQL5_Source/EAs/Multi_Symbol',
            'CODIGO_FONTE_LIBRARY/MQL5_Source/EAs/Others',
            'CODIGO_FONTE_LIBRARY/MQL5_Source/EAs/Misc',
            'CODIGO_FONTE_LIBRARY/MQL5_Source/Indicators/Order_Blocks',
            'CODIGO_FONTE_LIBRARY/MQL5_Source/Indicators/Volume_Flow',
            'CODIGO_FONTE_LIBRARY/MQL5_Source/Indicators/Market_Structure',
            'CODIGO_FONTE_LIBRARY/MQL5_Source/Indicators/Custom',
            'CODIGO_FONTE_LIBRARY/MQL5_Source/Indicators/Misc',
            'CODIGO_FONTE_LIBRARY/MQL5_Source/Scripts/Risk_Tools',
            'CODIGO_FONTE_LIBRARY/MQL5_Source/Scripts/Analysis_Tools',
            'CODIGO_FONTE_LIBRARY/MQL5_Source/Scripts/Misc',
            
            # Pine Script
            'CODIGO_FONTE_LIBRARY/TradingView_Scripts/Pine_Script_Source/Indicators/SMC_Concepts',
            'CODIGO_FONTE_LIBRARY/TradingView_Scripts/Pine_Script_Source/Indicators/Volume_Analysis',
            'CODIGO_FONTE_LIBRARY/TradingView_Scripts/Pine_Script_Source/Indicators/Custom_Plots',
            'CODIGO_FONTE_LIBRARY/TradingView_Scripts/Pine_Script_Source/Indicators/Misc',
            'CODIGO_FONTE_LIBRARY/TradingView_Scripts/Pine_Script_Source/Strategies/Backtesting',
            'CODIGO_FONTE_LIBRARY/TradingView_Scripts/Pine_Script_Source/Strategies/Alert_Systems',
            'CODIGO_FONTE_LIBRARY/TradingView_Scripts/Pine_Script_Source/Strategies/Misc',
            'CODIGO_FONTE_LIBRARY/TradingView_Scripts/Pine_Script_Source/Libraries/Pine_Functions',
            
            # Metadados
            'Metadata',
            'Metadata/Individual',
            'Reports'
        ]
        
        for folder in folders:
            folder_path = self.base_path / folder
            folder_path.mkdir(parents=True, exist_ok=True)
        
        print(f"✅ Estrutura de pastas criada com sucesso!")
    
    def find_files_to_process(self):
        """Encontra todos os arquivos para processar"""
        files_to_process = []
        
        for source_folder in self.source_folders:
            source_path = self.base_path / source_folder
            if source_path.exists():
                for file_path in source_path.rglob('*'):
                    if file_path.is_file() and file_path.suffix.lower() in self.supported_extensions:
                        # Pular arquivos .ex4/.ex5 se existir .mq4/.mq5 correspondente
                        if file_path.suffix.lower() in {'.ex4', '.ex5'}:
                            source_file = file_path.with_suffix('.mq4' if file_path.suffix.lower() == '.ex4' else '.mq5')
                            if source_file.exists():
                                continue
                        files_to_process.append(file_path)
        
        return files_to_process
    
    def process_single_file(self, file_path):
        """Processa um único arquivo"""
        try:
            print(f"📁 Processando: {file_path.name}")
            
            # Analisar arquivo
            analysis = self.analyzer.analyze_file(file_path)
            
            if 'error' in analysis:
                self.results['errors'].append({
                    'file': str(file_path),
                    'error': analysis['error']
                })
                return False
            
            # Gerar metadados
            metadata = self.analyzer.generate_metadata(analysis)
            
            # Determinar pasta destino
            target_folder = self.base_path / 'CODIGO_FONTE_LIBRARY' / analysis['target_folder']
            target_folder.mkdir(parents=True, exist_ok=True)
            
            # Gerar nome do arquivo
            suggested_name = analysis['suggested_name']
            target_file = target_folder / suggested_name
            
            # Resolver conflitos de nome
            counter = 1
            while target_file.exists():
                name_parts = suggested_name.rsplit('.', 1)
                if len(name_parts) == 2:
                    new_name = f"{name_parts[0]}_{counter}.{name_parts[1]}"
                else:
                    new_name = f"{suggested_name}_{counter}"
                target_file = target_folder / new_name
                counter += 1
            
            # Mover arquivo
            shutil.copy2(file_path, target_file)
            
            # Salvar metadados
            metadata_file = self.base_path / 'Metadata' / 'Individual' / f"{target_file.stem}.meta.json"
            with open(metadata_file, 'w', encoding='utf-8') as f:
                json.dump(metadata, f, indent=2, ensure_ascii=False)
            
            # Registrar resultado
            result = {
                'original_file': str(file_path),
                'target_file': str(target_file),
                'metadata_file': str(metadata_file),
                'analysis': analysis,
                'metadata': metadata
            }
            
            self.results['processed'].append(result)
            self.results['moved_files'].append({
                'from': str(file_path),
                'to': str(target_file),
                'type': analysis['file_type'],
                'strategy': analysis['strategy'],
                'ftmo_level': analysis['ftmo_compliance']['level']
            })
            
            print(f"✅ {analysis['file_type']} {analysis['strategy']} → {analysis['target_folder']}")
            return True
            
        except Exception as e:
            self.results['errors'].append({
                'file': str(file_path),
                'error': str(e)
            })
            print(f"❌ Erro ao processar {file_path.name}: {e}")
            return False
    
    def generate_statistics(self):
        """Gera estatísticas do processamento"""
        stats = {
            'total_processed': len(self.results['processed']),
            'total_errors': len(self.results['errors']),
            'by_type': {},
            'by_strategy': {},
            'by_ftmo_level': {},
            'by_quality': {},
            'by_risk': {},
            'top_ftmo_ready': []
        }
        
        for result in self.results['processed']:
            analysis = result['analysis']
            
            # Por tipo
            file_type = analysis['file_type']
            stats['by_type'][file_type] = stats['by_type'].get(file_type, 0) + 1
            
            # Por estratégia
            strategy = analysis['strategy']
            stats['by_strategy'][strategy] = stats['by_strategy'].get(strategy, 0) + 1
            
            # Por nível FTMO
            ftmo_level = analysis['ftmo_compliance']['level']
            stats['by_ftmo_level'][ftmo_level] = stats['by_ftmo_level'].get(ftmo_level, 0) + 1
            
            # Por qualidade
            quality = analysis['code_quality']['quality_level']
            stats['by_quality'][quality] = stats['by_quality'].get(quality, 0) + 1
            
            # Por risco
            risk = analysis['risk_assessment']
            stats['by_risk'][risk] = stats['by_risk'].get(risk, 0) + 1
            
            # Top FTMO Ready
            if analysis['ftmo_compliance']['level'] in ['FTMO_Ready', 'Partially_Compliant']:
                stats['top_ftmo_ready'].append({
                    'name': analysis['suggested_name'],
                    'type': analysis['file_type'],
                    'strategy': analysis['strategy'],
                    'ftmo_score': analysis['ftmo_compliance']['score'],
                    'quality_score': analysis['code_quality']['quality_score'],
                    'confidence': result['metadata']['analysis_metadata']['confidence_score']
                })
        
        # Ordenar top FTMO ready
        stats['top_ftmo_ready'].sort(key=lambda x: (x['ftmo_score'], x['quality_score']), reverse=True)
        stats['top_ftmo_ready'] = stats['top_ftmo_ready'][:10]
        
        self.results['statistics'] = stats
        return stats
    
    def generate_report(self):
        """Gera relatório final"""
        stats = self.generate_statistics()
        
        report = f"""
🔍 RELATÓRIO DE CLASSIFICAÇÃO - QUALIDADE MÁXIMA
{'='*60}
📅 Data: {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}

📊 ESTATÍSTICAS GERAIS
{'='*30}
✅ Arquivos processados: {stats['total_processed']}
❌ Erros encontrados: {stats['total_errors']}

📁 POR TIPO DE ARQUIVO
{'='*30}
"""
        
        for file_type, count in stats['by_type'].items():
            report += f"{file_type}: {count}\n"
        
        report += f"""

📈 POR ESTRATÉGIA
{'='*30}
"""
        
        for strategy, count in stats['by_strategy'].items():
            report += f"{strategy}: {count}\n"
        
        report += f"""

✅ COMPLIANCE FTMO
{'='*30}
"""
        
        for level, count in stats['by_ftmo_level'].items():
            report += f"{level}: {count}\n"
        
        report += f"""

📊 QUALIDADE DO CÓDIGO
{'='*30}
"""
        
        for quality, count in stats['by_quality'].items():
            report += f"{quality}: {count}\n"
        
        report += f"""

⚠️ NÍVEL DE RISCO
{'='*30}
"""
        
        for risk, count in stats['by_risk'].items():
            report += f"{risk}: {count}\n"
        
        report += f"""

🏆 TOP 10 FTMO READY
{'='*30}
"""
        
        for i, ea in enumerate(stats['top_ftmo_ready'], 1):
            report += f"{i:2d}. {ea['name']}\n"
            report += f"    Tipo: {ea['type']} | Estratégia: {ea['strategy']}\n"
            report += f"    FTMO Score: {ea['ftmo_score']}/7 | Qualidade: {ea['quality_score']}/5\n"
            report += f"    Confiança: {ea['confidence']}%\n\n"
        
        if self.results['errors']:
            report += f"""
❌ ERROS ENCONTRADOS
{'='*30}
"""
            for error in self.results['errors']:
                report += f"• {Path(error['file']).name}: {error['error']}\n"
        
        return report
    
    def save_results(self):
        """Salva resultados completos"""
        # Salvar resultados JSON
        results_file = self.base_path / 'Reports' / f'classification_results_{datetime.now().strftime("%Y%m%d_%H%M%S")}.json'
        with open(results_file, 'w', encoding='utf-8') as f:
            json.dump(self.results, f, indent=2, ensure_ascii=False, default=str)
        
        # Salvar relatório
        report = self.generate_report()
        report_file = self.base_path / 'Reports' / f'classification_report_{datetime.now().strftime("%Y%m%d_%H%M%S")}.txt'
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write(report)
        
        print(f"\n💾 Resultados salvos:")
        print(f"📄 JSON: {results_file}")
        print(f"📄 Relatório: {report_file}")
        
        return results_file, report_file
    
    def process_library(self, max_files=None):
        """Processa toda a biblioteca"""
        print(f"🚀 INICIANDO PROCESSAMENTO EM LOTE - QUALIDADE MÁXIMA")
        print(f"{'='*60}")
        
        # Criar estrutura
        self.create_folder_structure()
        
        # Encontrar arquivos
        files_to_process = self.find_files_to_process()
        
        if max_files:
            files_to_process = files_to_process[:max_files]
        
        print(f"📁 Arquivos encontrados: {len(files_to_process)}")
        
        if not files_to_process:
            print(f"❌ Nenhum arquivo encontrado para processar!")
            return
        
        # Processar arquivos
        processed_count = 0
        for i, file_path in enumerate(files_to_process, 1):
            print(f"\n[{i}/{len(files_to_process)}] ", end="")
            if self.process_single_file(file_path):
                processed_count += 1
        
        # Gerar relatório
        print(f"\n\n📊 PROCESSAMENTO CONCLUÍDO")
        print(f"{'='*60}")
        print(self.generate_report())
        
        # Salvar resultados
        self.save_results()
        
        return self.results

# Função principal
def main():
    base_path = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD"
    processor = BatchProcessor(base_path)
    
    # Processar apenas 5 arquivos para teste
    print("🧪 MODO TESTE - Processando apenas 5 arquivos")
    results = processor.process_library(max_files=5)
    
    return results

if __name__ == "__main__":
    main()