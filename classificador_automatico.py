#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Classificador Trading - Agente de IA para organização automática de bibliotecas de códigos de trading
Conformidade FTMO e classificação inteligente de EAs, Indicadores e Scripts
"""

import os
import re
import json
import hashlib
from pathlib import Path
from typing import Dict, List, Tuple, Optional
import shutil
from datetime import datetime

class ClassificadorTrading:
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.context_path = self.base_path / ".trae" / "context"
        self.load_context_files()
        
    def load_context_files(self):
        """Carrega arquivos de contexto com regras e templates"""
        with open(self.context_path / "classification_rules.json", 'r', encoding='utf-8') as f:
            self.classification_rules = json.load(f)
            
        with open(self.context_path / "naming_conventions.json", 'r', encoding='utf-8') as f:
            self.naming_conventions = json.load(f)
            
        with open(self.context_path / "meta_template.json", 'r', encoding='utf-8') as f:
            self.meta_template = json.load(f)
            
        with open(self.context_path / "trading_code_patterns.json", 'r', encoding='utf-8') as f:
            self.trading_patterns = json.load(f)
    
    def analyze_file(self, file_path: Path) -> Dict:
        """Analisa um arquivo de código e extrai metadados"""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except:
            try:
                with open(file_path, 'r', encoding='latin-1', errors='ignore') as f:
                    content = f.read()
            except:
                return None
                
        # Análise básica
        analysis = {
            'arquivo': file_path.name,
            'hash': hashlib.md5(content.encode('utf-8', errors='ignore')).hexdigest()[:16],
            'tipo': self.detect_file_type(content, file_path.suffix),
            'linguagem': 'MQL4' if file_path.suffix == '.mq4' else 'MQL5',
            'estrategia': self.detect_strategy(content),
            'mercados': self.detect_markets(content),
            'timeframes': self.detect_timeframes(content),
            'funcoes_chave': self.extract_key_functions(content),
            'ftmo_score': self.calculate_ftmo_score(content),
            'riscos_detectados': self.detect_risks(content)
        }
        
        return analysis
    
    def detect_file_type(self, content: str, extension: str) -> str:
        """Detecta o tipo do arquivo (EA, Indicator, Script)"""
        content_lower = content.lower()
        
        if 'ontick' in content_lower and ('ordersend' in content_lower or 'trade.buy' in content_lower):
            return 'EA'
        elif 'oncalculate' in content_lower or 'setindexbuffer' in content_lower:
            return 'Indicator'
        elif 'onstart' in content_lower:
            return 'Script'
        else:
            return 'Unknown'
    
    def detect_strategy(self, content: str) -> str:
        """Detecta a estratégia principal do código"""
        content_lower = content.lower()
        
        # Verifica padrões de estratégias
        if any(word in content_lower for word in ['grid', 'martingale', 'recovery']):
            return 'Grid_Martingale'
        elif any(word in content_lower for word in ['scalp', 'quick', 'fast']):
            return 'Scalping'
        elif any(word in content_lower for word in ['order_block', 'fvg', 'bos', 'choch', 'smc']):
            return 'SMC'
        elif any(word in content_lower for word in ['trend', 'momentum', 'breakout']):
            return 'Trend'
        elif any(word in content_lower for word in ['volume', 'obv', 'profile']):
            return 'Volume'
        else:
            return 'Custom'
    
    def detect_markets(self, content: str) -> List[str]:
        """Detecta mercados mencionados no código"""
        markets = []
        content_upper = content.upper()
        
        market_patterns = ['XAUUSD', 'EURUSD', 'GBPUSD', 'USDJPY', 'USDCAD', 'AUDUSD', 'NZDUSD']
        
        for market in market_patterns:
            if market in content_upper:
                markets.append(market)
                
        if len(markets) > 3 or 'symbol' in content.lower():
            return ['MULTI']
            
        return markets if markets else ['MULTI']
    
    def detect_timeframes(self, content: str) -> List[str]:
        """Detecta timeframes mencionados no código"""
        timeframes = []
        content_lower = content.lower()
        
        tf_patterns = {
            'M1': ['m1', 'period_m1', '1 min'],
            'M5': ['m5', 'period_m5', '5 min'],
            'M15': ['m15', 'period_m15', '15 min'],
            'M30': ['m30', 'period_m30', '30 min'],
            'H1': ['h1', 'period_h1', '1 hour'],
            'H4': ['h4', 'period_h4', '4 hour'],
            'D1': ['d1', 'period_d1', 'daily']
        }
        
        for tf, patterns in tf_patterns.items():
            if any(pattern in content_lower for pattern in patterns):
                timeframes.append(tf)
                
        return timeframes if timeframes else ['MULTI']
    
    def extract_key_functions(self, content: str) -> List[str]:
        """Extrai funções-chave do código"""
        functions = []
        
        # Padrões de funções importantes
        function_patterns = [
            r'(Calculate\w*Lot\w*)',
            r'(Risk\w*Management)',
            r'(Order\w*Block\w*)',
            r'(Volume\w*Analysis)',
            r'(Trailing\w*Stop)',
            r'(Break\w*Even)'
        ]
        
        for pattern in function_patterns:
            matches = re.findall(pattern, content, re.IGNORECASE)
            functions.extend(matches)
            
        return list(set(functions))[:10]  # Máximo 10 funções
    
    def calculate_ftmo_score(self, content: str) -> int:
        """Calcula score de compatibilidade FTMO"""
        score = 0
        content_lower = content.lower()
        
        # Critérios FTMO
        if 'stoploss' in content_lower or 'sl' in content_lower:
            score += 20
        if 'risk' in content_lower and ('percent' in content_lower or '%' in content_lower):
            score += 15
        if 'takeprofit' in content_lower or 'tp' in content_lower:
            score += 10
        if not any(word in content_lower for word in ['grid', 'martingale', 'recovery']):
            score += 20
        if 'session' in content_lower or 'time' in content_lower:
            score += 10
        if 'drawdown' in content_lower or 'dd' in content_lower:
            score += 15
        if 'lot' in content_lower and 'calculate' in content_lower:
            score += 10
            
        return min(score, 100)
    
    def detect_risks(self, content: str) -> List[str]:
        """Detecta riscos no código"""
        risks = []
        content_lower = content.lower()
        
        if 'martingale' in content_lower or 'grid' in content_lower:
            risks.append('Martingale/Grid detected')
        if 'stoploss' not in content_lower and 'sl' not in content_lower:
            risks.append('No Stop Loss detected')
        if 'risk' not in content_lower:
            risks.append('No risk management detected')
            
        return risks
    
    def generate_new_filename(self, analysis: Dict, original_path: Path) -> str:
        """Gera novo nome seguindo convenções"""
        tipo = analysis['tipo']
        estrategia = analysis['estrategia']
        mercados = analysis['mercados']
        
        # Prefixo baseado no tipo
        prefix_map = {'EA': 'EA', 'Indicator': 'IND', 'Script': 'SCR'}
        prefix = prefix_map.get(tipo, 'UNK')
        
        # Nome base limpo
        base_name = re.sub(r'[^a-zA-Z0-9]', '', original_path.stem)[:20]
        
        # Versão padrão
        version = 'v1.0'
        
        # Mercado principal
        market = mercados[0] if mercados else 'MULTI'
        
        # Extensão original
        ext = original_path.suffix
        
        return f"{prefix}_{base_name}_{version}_{market}{ext}"
    
    def determine_target_folder(self, analysis: Dict) -> str:
        """Determina pasta de destino baseada na análise"""
        tipo = analysis['tipo']
        estrategia = analysis['estrategia']
        ftmo_score = analysis['ftmo_score']
        
        if tipo == 'EA':
            if ftmo_score >= 70:
                return 'MQL4_Source/EAs/FTMO_Ready'
            elif estrategia == 'Scalping':
                return 'MQL4_Source/EAs/Scalping'
            elif estrategia == 'Grid_Martingale':
                return 'MQL4_Source/EAs/Grid_Martingale'
            elif estrategia == 'Trend':
                return 'MQL4_Source/EAs/Trend_Following'
            else:
                return 'MQL4_Source/EAs/Misc'
        elif tipo == 'Indicator':
            if estrategia == 'SMC':
                return 'MQL4_Source/Indicators/SMC_ICT'
            elif estrategia == 'Volume':
                return 'MQL4_Source/Indicators/Volume'
            elif estrategia == 'Trend':
                return 'MQL4_Source/Indicators/Trend'
            else:
                return 'MQL4_Source/Indicators/Custom'
        elif tipo == 'Script':
            if 'risk' in analysis.get('funcoes_chave', []):
                return 'MQL4_Source/Scripts/Utilities'
            else:
                return 'MQL4_Source/Scripts/Analysis'
        else:
            return 'MQL4_Source/Misc'
    
    def create_metadata_file(self, analysis: Dict, target_path: Path) -> None:
        """Cria arquivo de metadados"""
        metadata = self.meta_template.copy()
        metadata.update({
            'id': analysis['hash'],
            'arquivo': analysis['arquivo'],
            'hash': analysis['hash'],
            'tipo': analysis['tipo'],
            'linguagem': analysis['linguagem'],
            'estrategia': analysis['estrategia'],
            'mercados': analysis['mercados'],
            'timeframes': analysis['timeframes'],
            'funcoes_chave': analysis['funcoes_chave'],
            'ftmo_score': analysis['ftmo_score'],
            'riscos_detectados': analysis['riscos_detectados'],
            'qualidade_codigo_score': min(analysis['ftmo_score'] + 20, 100)
        })
        
        # Salva metadados
        metadata_path = self.base_path / 'Metadata' / f"{target_path.stem}.meta.json"
        with open(metadata_path, 'w', encoding='utf-8') as f:
            json.dump(metadata, f, indent=2, ensure_ascii=False)
    
    def process_all_files(self) -> Dict:
        """Processa todos os arquivos na pasta All_MQ4"""
        source_path = self.base_path / 'CODIGO_FONTE_LIBRARY' / 'MQL4_Source' / 'All_MQ4'
        results = {
            'processed': 0,
            'moved': 0,
            'errors': 0,
            'ftmo_ready': 0,
            'categories': {}
        }
        
        print("🤖 Classificador Trading ativado - Iniciando análise automática...")
        
        for file_path in source_path.glob('*.mq4'):
            try:
                print(f"📊 Analisando: {file_path.name}")
                
                # Analisa arquivo
                analysis = self.analyze_file(file_path)
                if not analysis:
                    results['errors'] += 1
                    continue
                
                # Gera novo nome
                new_filename = self.generate_new_filename(analysis, file_path)
                
                # Determina pasta de destino
                target_folder = self.determine_target_folder(analysis)
                target_dir = self.base_path / 'CODIGO_FONTE_LIBRARY' / target_folder
                target_dir.mkdir(parents=True, exist_ok=True)
                
                # Resolve conflitos de nome
                target_path = target_dir / new_filename
                counter = 1
                while target_path.exists():
                    name_parts = new_filename.rsplit('.', 1)
                    target_path = target_dir / f"{name_parts[0]}_{counter}.{name_parts[1]}"
                    counter += 1
                
                # Move arquivo
                shutil.move(str(file_path), str(target_path))
                
                # Cria metadados
                self.create_metadata_file(analysis, target_path)
                
                # Atualiza estatísticas
                results['processed'] += 1
                results['moved'] += 1
                
                if analysis['ftmo_score'] >= 70:
                    results['ftmo_ready'] += 1
                
                category = analysis['estrategia']
                results['categories'][category] = results['categories'].get(category, 0) + 1
                
                print(f"✅ {file_path.name} → {target_path.relative_to(self.base_path)}")
                print(f"   📈 FTMO Score: {analysis['ftmo_score']}/100")
                print(f"   🎯 Estratégia: {analysis['estrategia']}")
                print(f"   💱 Mercados: {', '.join(analysis['mercados'])}")
                print()
                
            except Exception as e:
                print(f"❌ Erro processando {file_path.name}: {str(e)}")
                results['errors'] += 1
        
        return results
    
    def generate_report(self, results: Dict) -> str:
        """Gera relatório final"""
        report = f"""
🤖 RELATÓRIO DE CLASSIFICAÇÃO AUTOMÁTICA
{'='*50}

📊 ESTATÍSTICAS GERAIS:
• Arquivos processados: {results['processed']}
• Arquivos movidos: {results['moved']}
• Erros encontrados: {results['errors']}
• EAs FTMO-Ready: {results['ftmo_ready']}

📈 DISTRIBUIÇÃO POR CATEGORIA:
"""
        
        for category, count in results['categories'].items():
            report += f"• {category}: {count} arquivos\n"
        
        report += f"""

✅ PROCESSO CONCLUÍDO
Data: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

Próximos passos:
1. Revisar arquivos em Misc/
2. Validar metadados gerados
3. Atualizar índices principais
"""
        
        return report

def main():
    base_path = r"c:\Users\Admin\Documents\EA_SCALPER_XAUUSD"
    classificador = ClassificadorTrading(base_path)
    
    # Executa classificação
    results = classificador.process_all_files()
    
    # Gera e exibe relatório
    report = classificador.generate_report(results)
    print(report)
    
    # Salva relatório
    report_path = Path(base_path) / 'Reports' / f'classificacao_{datetime.now().strftime("%Y%m%d_%H%M%S")}.txt'
    report_path.parent.mkdir(exist_ok=True)
    with open(report_path, 'w', encoding='utf-8') as f:
        f.write(report)
    
    print(f"📄 Relatório salvo em: {report_path}")

if __name__ == "__main__":
    main()