#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Classificador Trading Otimizado - Versão Deduplicada
Versão: 2.0
Autor: Classificador_Trading
Data: 2025-01-27

Este agente implementa processamento otimizado que evita duplicação
de análise do mesmo robô em arquivos diferentes.
"""

import os
import json
import re
import hashlib
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional
from collections import defaultdict
import shutil
from datetime import datetime

class ClassificadorTradingOtimizado:
    """Classificador otimizado que processa cada robô único apenas uma vez."""
    
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.metadata_path = self.base_path / "Metadata"
        self.source_path = self.base_path / "CODIGO_FONTE_LIBRARY"
        self.processed_robots = set()
        self.robot_signatures = {}
        self.duplicate_groups = defaultdict(list)
        self.changelog_entries = []
        
    def calculate_code_signature(self, filepath: str) -> str:
        """Calcula assinatura única do código baseada no conteúdo funcional."""
        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            # Remove comentários e espaços para focar na lógica
            content_clean = re.sub(r'//.*?\n', '', content)
            content_clean = re.sub(r'/\*.*?\*/', '', content_clean, flags=re.DOTALL)
            content_clean = re.sub(r'\s+', ' ', content_clean)
            
            # Extrai funções principais para criar assinatura
            functions = re.findall(r'(OnTick|OnInit|OnStart|OnCalculate|OnTimer)\s*\([^)]*\)', content_clean)
            variables = re.findall(r'input\s+\w+\s+(\w+)', content_clean)
            
            signature_data = {
                'functions': sorted(functions),
                'inputs': sorted(variables),
                'content_hash': hashlib.md5(content_clean.encode()).hexdigest()[:16]
            }
            
            return json.dumps(signature_data, sort_keys=True)
            
        except Exception as e:
            print(f"Erro ao calcular assinatura de {filepath}: {e}")
            return str(filepath)
    
    def extract_robot_base_name(self, filename: str) -> str:
        """Extrai nome base removendo sufixos de duplicação."""
        name = Path(filename).stem
        
        # Padrões de duplicação comuns
        patterns = [
            r'\s*\(\d+\)$',  # (2), (3), (4)
            r'\s*-\s*\d+$',  # - 2, - 3
            r'_\d+$',       # _1, _2, _3
            r'\s*copy\s*\d*$',  # copy, copy2
            r'\s*Copy\s*\d*$',  # Copy, Copy2
            r'\s*-\s*Copy\s*\d*$',  # - Copy, - Copy2
            r'\s*\(Copy\)$',     # (Copy)
            r'\s*\(copy\)$',     # (copy)
        ]
        
        base_name = name
        for pattern in patterns:
            base_name = re.sub(pattern, '', base_name, flags=re.IGNORECASE)
        
        return base_name.strip()
    
    def scan_and_group_files(self, source_dirs: List[str]) -> Dict[str, List[Dict]]:
        """Escaneia diretórios e agrupa arquivos por assinatura única."""
        file_groups = defaultdict(list)
        
        for source_dir in source_dirs:
            source_path = self.base_path / source_dir
            if not source_path.exists():
                continue
                
            print(f"Escaneando: {source_path}")
            
            # Processa arquivos MQL4/MQL5
            for ext in ['*.mq4', '*.mq5', '*.ex4', '*.ex5']:
                for filepath in source_path.rglob(ext):
                    if filepath.is_file():
                        signature = self.calculate_code_signature(str(filepath))
                        base_name = self.extract_robot_base_name(filepath.name)
                        
                        file_info = {
                            'filepath': str(filepath),
                            'filename': filepath.name,
                            'base_name': base_name,
                            'signature': signature,
                            'size': filepath.stat().st_size,
                            'modified': filepath.stat().st_mtime
                        }
                        
                        file_groups[signature].append(file_info)
        
        return file_groups
    
    def select_best_file_from_group(self, file_group: List[Dict]) -> Dict:
        """Seleciona o melhor arquivo de um grupo de duplicatas."""
        if len(file_group) == 1:
            return file_group[0]
        
        # Critérios de seleção:
        # 1. Nome mais limpo (sem sufixos)
        # 2. Arquivo maior (mais completo)
        # 3. Mais recente
        
        best_file = file_group[0]
        best_score = 0
        
        for file_info in file_group:
            score = 0
            
            # Nome limpo (peso 50)
            if file_info['filename'] == file_info['base_name'] + Path(file_info['filename']).suffix:
                score += 50
            elif not re.search(r'[\(\)\d_-]+', file_info['base_name']):
                score += 30
            
            # Tamanho do arquivo (peso 30)
            score += min(file_info['size'] / 1000, 30)
            
            # Data de modificação (peso 20)
            score += min(file_info['modified'] / 1000000000, 20)
            
            if score > best_score:
                best_score = score
                best_file = file_info
        
        return best_file
    
    def analyze_code_file(self, filepath: str) -> Dict:
        """Analisa um arquivo de código e extrai metadados."""
        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except:
            return {'error': 'Não foi possível ler o arquivo'}
        
        # Detecta tipo
        if 'OnTick' in content or 'OnStart' in content:
            code_type = 'EA'
        elif 'OnCalculate' in content or 'IndicatorBuffers' in content:
            code_type = 'Indicator'
        elif 'OnStart' in content and 'OnTick' not in content:
            code_type = 'Script'
        else:
            code_type = 'Unknown'
        
        # Detecta estratégia
        strategy = 'Misc'
        if any(term in content.lower() for term in ['scalp', 'quick', 'fast']):
            strategy = 'Scalping'
        elif any(term in content.lower() for term in ['grid', 'martingale', 'recovery']):
            strategy = 'Grid_Martingale'
        elif any(term in content.lower() for term in ['orderblock', 'smc', 'smart money']):
            strategy = 'SMC_ICT'
        elif any(term in content.lower() for term in ['trend', 'momentum', 'breakout']):
            strategy = 'Trend_Following'
        
        # Detecta mercado
        market = 'MULTI'
        if 'XAUUSD' in content or 'Gold' in content:
            market = 'XAUUSD'
        elif 'EURUSD' in content:
            market = 'EURUSD'
        elif 'GBPUSD' in content:
            market = 'GBPUSD'
        elif 'BTCUSD' in content or 'Bitcoin' in content:
            market = 'BTCUSD'
        
        # Análise FTMO
        ftmo_score = self.calculate_ftmo_score(content)
        
        return {
            'type': code_type,
            'strategy': strategy,
            'market': market,
            'ftmo_score': ftmo_score,
            'language': 'MQL5' if filepath.endswith('.mq5') else 'MQL4',
            'content_size': len(content)
        }
    
    def calculate_ftmo_score(self, content: str) -> int:
        """Calcula score de compatibilidade FTMO (0-10)."""
        score = 0
        
        # Verificações positivas
        if 'StopLoss' in content or 'SL' in content:
            score += 2
        if 'TakeProfit' in content or 'TP' in content:
            score += 1
        if any(term in content for term in ['Risk', 'Lot', 'Money']):
            score += 2
        if any(term in content for term in ['Session', 'Time', 'Hour']):
            score += 1
        if 'News' in content:
            score += 1
        
        # Verificações negativas
        if any(term in content.lower() for term in ['martingale', 'grid', 'recovery']):
            score -= 3
        if 'Risk' in content and any(term in content for term in ['5%', '10%', '0.05', '0.1']):
            score -= 2
        
        return max(0, min(10, score))
    
    def generate_new_filename(self, analysis: Dict, original_name: str) -> str:
        """Gera novo nome seguindo convenções."""
        base_name = self.extract_robot_base_name(original_name)
        
        # Remove caracteres especiais
        clean_name = re.sub(r'[^a-zA-Z0-9_]', '', base_name)
        
        # Prefixo baseado no tipo
        prefix_map = {
            'EA': 'EA_',
            'Indicator': 'IND_',
            'Script': 'SCR_'
        }
        
        prefix = prefix_map.get(analysis['type'], 'EA_')
        market = analysis['market']
        extension = '.mq5' if analysis['language'] == 'MQL5' else '.mq4'
        
        return f"{prefix}{clean_name}_v1.0_{market}{extension}"
    
    def process_unique_robots(self, source_dirs: List[str]):
        """Processa cada robô único apenas uma vez."""
        print("=== CLASSIFICADOR TRADING OTIMIZADO ===")
        print("Iniciando processamento com deduplicação...\n")
        
        # 1. Escanear e agrupar arquivos
        print("1. Escaneando e agrupando arquivos duplicados...")
        file_groups = self.scan_and_group_files(source_dirs)
        
        total_files = sum(len(group) for group in file_groups.values())
        unique_robots = len(file_groups)
        
        print(f"   Total de arquivos encontrados: {total_files}")
        print(f"   Robôs únicos identificados: {unique_robots}")
        print(f"   Duplicatas evitadas: {total_files - unique_robots}\n")
        
        # 2. Processar cada grupo único
        print("2. Processando robôs únicos...")
        processed_count = 0
        
        for signature, file_group in file_groups.items():
            if signature in self.processed_robots:
                continue
                
            # Seleciona melhor arquivo do grupo
            best_file = self.select_best_file_from_group(file_group)
            
            print(f"\n   Processando: {best_file['base_name']}")
            print(f"   Arquivo principal: {best_file['filename']}")
            
            if len(file_group) > 1:
                print(f"   Duplicatas encontradas: {len(file_group) - 1}")
                for dup in file_group:
                    if dup != best_file:
                        print(f"     - {dup['filename']}")
            
            # Analisa o código
            analysis = self.analyze_code_file(best_file['filepath'])
            
            if 'error' in analysis:
                print(f"   ❌ Erro na análise: {analysis['error']}")
                continue
            
            # Gera novo nome
            new_filename = self.generate_new_filename(analysis, best_file['filename'])
            
            print(f"   Tipo: {analysis['type']} | Estratégia: {analysis['strategy']}")
            print(f"   Mercado: {analysis['market']} | FTMO Score: {analysis['ftmo_score']}/10")
            print(f"   Novo nome: {new_filename}")
            
            # Determina pasta de destino
            dest_path = self.determine_destination_path(analysis)
            
            print(f"   Destino: {dest_path}")
            print(f"   ✅ Processado com sucesso")
            
            # Marca como processado
            self.processed_robots.add(signature)
            processed_count += 1
            
            # Log da operação
            self.changelog_entries.append({
                'timestamp': datetime.now().isoformat(),
                'action': 'PROCESSED_UNIQUE_ROBOT',
                'robot_name': best_file['base_name'],
                'files_in_group': len(file_group),
                'selected_file': best_file['filename'],
                'new_name': new_filename,
                'analysis': analysis
            })
        
        print(f"\n=== RESUMO DO PROCESSAMENTO ===")
        print(f"Robôs únicos processados: {processed_count}")
        print(f"Duplicatas evitadas: {total_files - processed_count}")
        print(f"Eficiência: {((total_files - processed_count) / total_files * 100):.1f}% de redução")
        
        # Salva log
        self.save_processing_log()
    
    def determine_destination_path(self, analysis: Dict) -> str:
        """Determina pasta de destino baseada na análise."""
        language = analysis['language']
        code_type = analysis['type']
        strategy = analysis['strategy']
        
        if language == 'MQL5':
            if code_type == 'EA':
                if strategy == 'Scalping':
                    return "MQL5_Source/EAs/Advanced_Scalping"
                elif strategy == 'SMC_ICT':
                    return "MQL5_Source/EAs/FTMO_Ready"
                elif strategy == 'Trend_Following':
                    return "MQL5_Source/EAs/Multi_Symbol"
                else:
                    return "MQL5_Source/EAs/Others"
            elif code_type == 'Indicator':
                return "MQL5_Source/Indicators/Custom"
            else:
                return "MQL5_Source/Scripts/Utilities"
        else:  # MQL4
            if code_type == 'EA':
                return f"MQL4_Source/EAs/{strategy}"
            elif code_type == 'Indicator':
                return "MQL4_Source/Indicators/Custom"
            else:
                return "MQL4_Source/Scripts/Utilities"
    
    def save_processing_log(self):
        """Salva log do processamento."""
        log_file = self.base_path / "processing_log_optimized.json"
        
        log_data = {
            'timestamp': datetime.now().isoformat(),
            'total_processed': len(self.processed_robots),
            'entries': self.changelog_entries
        }
        
        with open(log_file, 'w', encoding='utf-8') as f:
            json.dump(log_data, f, indent=2, ensure_ascii=False)
        
        print(f"\nLog salvo em: {log_file}")

# Função principal
def main():
    """Executa o classificador otimizado."""
    base_path = r"c:\Users\Admin\Documents\EA_SCALPER_XAUUSD"
    
    classificador = ClassificadorTradingOtimizado(base_path)
    
    # Diretórios para processar
    source_dirs = [
        "CODIGO_FONTE_LIBRARY/MQL4_Source/All_MQ4",
        "CODIGO_FONTE_LIBRARY/MQL5_Source/All_MQ5"
    ]
    
    classificador.process_unique_robots(source_dirs)

if __name__ == "__main__":
    main()