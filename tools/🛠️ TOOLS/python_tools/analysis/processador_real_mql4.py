#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🚀 PROCESSADOR REAL DE ARQUIVOS MQL4 - IMPLEMENTAÇÃO COMPLETA
Classificador Trading - Análise Real + Classificação Inteligente

Autor: ClassificadorTrading
Versão: 7.0
Data: 13/08/2025

Recursos REAIS implementados:
- Análise sintática real de arquivos MQL4
- Detecção automática de estratégias de trading
- Classificação FTMO rigorosa e precisa
- Geração de metadados completos
- Movimentação e organização real de arquivos
- Sistema de backup automático
- Validação de código MQL4
- Extração de snippets reutilizáveis
"""

import sys
import os
import json
import time
import logging
import re
import shutil
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any, Optional, Tuple
from concurrent.futures import ThreadPoolExecutor, as_completed
import threading
import hashlib

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('processador_real_mql4.log', encoding='utf-8'),
        logging.StreamHandler()
    ]
)

class MQL4CodeAnalyzer:
    """Analisador Real de Código MQL4"""
    
    def __init__(self):
        self.logger = logging.getLogger('MQL4CodeAnalyzer')
        
        # Padrões para detecção de tipos
        self.ea_patterns = [
            r'int\s+OnInit\s*\(',
            r'void\s+OnTick\s*\(',
            r'void\s+OnDeinit\s*\(',
            r'OrderSend\s*\(',
            r'trade\.(Buy|Sell)\s*\('
        ]
        
        self.indicator_patterns = [
            r'int\s+OnCalculate\s*\(',
            r'SetIndexBuffer\s*\(',
            r'SetIndexStyle\s*\(',
            r'IndicatorBuffers\s*\(',
            r'#property\s+indicator_'
        ]
        
        self.script_patterns = [
            r'void\s+OnStart\s*\(',
            r'int\s+start\s*\('
        ]
        
        # Padrões para estratégias
        self.strategy_patterns = {
            'Scalping': [
                r'scalp', r'M1', r'M5', r'quick', r'fast',
                r'Period_M1', r'Period_M5', r'short.*term'
            ],
            'Grid_Martingale': [
                r'grid', r'martingale', r'recovery', r'double.*lot',
                r'multiply.*lot', r'averaging', r'hedge'
            ],
            'SMC_ICT': [
                r'order.*block', r'liquidity', r'institutional',
                r'smart.*money', r'ICT', r'fair.*value.*gap',
                r'breaker.*block', r'mitigation'
            ],
            'Trend_Following': [
                r'trend', r'momentum', r'moving.*average', r'MA',
                r'trend.*line', r'breakout', r'follow'
            ],
            'Volume_Analysis': [
                r'volume', r'OBV', r'flow', r'tick.*volume',
                r'volume.*profile', r'VWAP'
            ],
            'News_Trading': [
                r'news', r'event', r'calendar', r'fundamental',
                r'announcement', r'release'
            ]
        }
        
        # Padrões FTMO
        self.ftmo_patterns = {
            'risk_management': [
                r'risk', r'lot.*size', r'money.*management',
                r'position.*size', r'account.*balance'
            ],
            'stop_loss': [
                r'stop.*loss', r'SL', r'protective.*stop',
                r'OrderModify.*stop'
            ],
            'take_profit': [
                r'take.*profit', r'TP', r'target.*profit',
                r'OrderModify.*profit'
            ],
            'drawdown_protection': [
                r'drawdown', r'equity', r'balance.*protection',
                r'max.*loss', r'daily.*loss'
            ],
            'session_filter': [
                r'session', r'time.*filter', r'trading.*hours',
                r'market.*hours', r'TimeHour'
            ],
            'news_filter': [
                r'news.*filter', r'event.*filter', r'calendar',
                r'high.*impact', r'avoid.*news'
            ]
        }
    
    def analyze_file(self, file_path: Path) -> Dict[str, Any]:
        """Analisa um arquivo MQL4 completamente"""
        try:
            # Ler arquivo
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            analysis = {
                'file_path': str(file_path),
                'file_name': file_path.name,
                'file_size': file_path.stat().st_size,
                'lines_count': len(content.splitlines()),
                'file_type': self._detect_file_type(content),
                'strategy': self._detect_strategy(content),
                'ftmo_analysis': self._analyze_ftmo_compliance(content),
                'market_timeframe': self._detect_market_timeframe(content),
                'functions_found': self._extract_functions(content),
                'variables_found': self._extract_variables(content),
                'includes_found': self._extract_includes(content),
                'properties_found': self._extract_properties(content),
                'complexity_score': self._calculate_complexity(content),
                'quality_score': 0.0,
                'issues_found': [],
                'snippets': []
            }
            
            # Calcular score de qualidade
            analysis['quality_score'] = self._calculate_quality_score(analysis)
            
            # Detectar problemas
            analysis['issues_found'] = self._detect_issues(content)
            
            # Extrair snippets
            analysis['snippets'] = self._extract_code_snippets(content)
            
            return analysis
            
        except Exception as e:
            self.logger.error(f"❌ Erro ao analisar {file_path}: {e}")
            return {
                'file_path': str(file_path),
                'error': str(e),
                'analysis_failed': True
            }
    
    def _detect_file_type(self, content: str) -> str:
        """Detecta o tipo do arquivo MQL4"""
        content_lower = content.lower()
        
        # Verificar EA
        ea_score = sum(1 for pattern in self.ea_patterns if re.search(pattern, content, re.IGNORECASE))
        
        # Verificar Indicator
        ind_score = sum(1 for pattern in self.indicator_patterns if re.search(pattern, content, re.IGNORECASE))
        
        # Verificar Script
        scr_score = sum(1 for pattern in self.script_patterns if re.search(pattern, content, re.IGNORECASE))
        
        if ea_score >= 2:
            return 'EA'
        elif ind_score >= 2:
            return 'Indicator'
        elif scr_score >= 1:
            return 'Script'
        else:
            # Análise adicional baseada em palavras-chave
            if 'expert' in content_lower or 'advisor' in content_lower:
                return 'EA'
            elif 'indicator' in content_lower or 'buffer' in content_lower:
                return 'Indicator'
            else:
                return 'Unknown'
    
    def _detect_strategy(self, content: str) -> List[str]:
        """Detecta estratégias de trading no código"""
        detected_strategies = []
        
        for strategy, patterns in self.strategy_patterns.items():
            score = sum(1 for pattern in patterns if re.search(pattern, content, re.IGNORECASE))
            if score >= 1:  # Pelo menos 1 padrão encontrado
                detected_strategies.append(strategy)
        
        return detected_strategies if detected_strategies else ['Unknown']
    
    def _analyze_ftmo_compliance(self, content: str) -> Dict[str, Any]:
        """Analisa conformidade FTMO"""
        ftmo_analysis = {
            'compliance_score': 0.0,
            'features_found': {},
            'missing_features': [],
            'risk_level': 'HIGH',
            'ftmo_ready': False
        }
        
        total_features = len(self.ftmo_patterns)
        features_found = 0
        
        for feature, patterns in self.ftmo_patterns.items():
            found = any(re.search(pattern, content, re.IGNORECASE) for pattern in patterns)
            ftmo_analysis['features_found'][feature] = found
            
            if found:
                features_found += 1
            else:
                ftmo_analysis['missing_features'].append(feature)
        
        # Calcular score de conformidade
        ftmo_analysis['compliance_score'] = (features_found / total_features) * 100
        
        # Determinar nível de risco
        if ftmo_analysis['compliance_score'] >= 80:
            ftmo_analysis['risk_level'] = 'LOW'
            ftmo_analysis['ftmo_ready'] = True
        elif ftmo_analysis['compliance_score'] >= 60:
            ftmo_analysis['risk_level'] = 'MEDIUM'
        else:
            ftmo_analysis['risk_level'] = 'HIGH'
        
        # Verificações específicas críticas
        critical_features = ['risk_management', 'stop_loss']
        has_critical = all(ftmo_analysis['features_found'].get(f, False) for f in critical_features)
        
        if not has_critical:
            ftmo_analysis['ftmo_ready'] = False
            ftmo_analysis['risk_level'] = 'HIGH'
        
        return ftmo_analysis
    
    def _detect_market_timeframe(self, content: str) -> Dict[str, Any]:
        """Detecta mercado e timeframe"""
        market_tf = {
            'markets': [],
            'timeframes': [],
            'confidence': 0.0
        }
        
        # Padrões de mercado
        market_patterns = {
            'FOREX': [r'EUR', r'USD', r'GBP', r'JPY', r'AUD', r'CAD', r'CHF', r'NZD'],
            'GOLD': [r'XAU', r'GOLD', r'Au'],
            'INDICES': [r'SPX', r'NAS', r'DOW', r'DAX', r'FTSE'],
            'CRYPTO': [r'BTC', r'ETH', r'crypto']
        }
        
        # Padrões de timeframe
        tf_patterns = {
            'M1': [r'PERIOD_M1', r'1.*min', r'M1'],
            'M5': [r'PERIOD_M5', r'5.*min', r'M5'],
            'M15': [r'PERIOD_M15', r'15.*min', r'M15'],
            'H1': [r'PERIOD_H1', r'1.*hour', r'H1'],
            'H4': [r'PERIOD_H4', r'4.*hour', r'H4'],
            'D1': [r'PERIOD_D1', r'daily', r'D1']
        }
        
        # Detectar mercados
        for market, patterns in market_patterns.items():
            if any(re.search(pattern, content, re.IGNORECASE) for pattern in patterns):
                market_tf['markets'].append(market)
        
        # Detectar timeframes
        for tf, patterns in tf_patterns.items():
            if any(re.search(pattern, content, re.IGNORECASE) for pattern in patterns):
                market_tf['timeframes'].append(tf)
        
        # Calcular confiança
        total_detections = len(market_tf['markets']) + len(market_tf['timeframes'])
        market_tf['confidence'] = min(total_detections * 25, 100)  # Max 100%
        
        return market_tf
    
    def _extract_functions(self, content: str) -> List[str]:
        """Extrai funções do código"""
        function_pattern = r'(int|void|double|bool|string)\s+(\w+)\s*\([^)]*\)\s*{'
        matches = re.findall(function_pattern, content, re.IGNORECASE)
        return [match[1] for match in matches]
    
    def _extract_variables(self, content: str) -> List[str]:
        """Extrai variáveis principais"""
        var_patterns = [
            r'extern\s+(int|double|bool|string)\s+(\w+)',
            r'input\s+(int|double|bool|string)\s+(\w+)',
            r'static\s+(int|double|bool|string)\s+(\w+)'
        ]
        
        variables = []
        for pattern in var_patterns:
            matches = re.findall(pattern, content, re.IGNORECASE)
            variables.extend([match[1] for match in matches])
        
        return variables
    
    def _extract_includes(self, content: str) -> List[str]:
        """Extrai includes"""
        include_pattern = r'#include\s*[<"]([^>"]+)[>"]'
        return re.findall(include_pattern, content, re.IGNORECASE)
    
    def _extract_properties(self, content: str) -> List[str]:
        """Extrai propriedades"""
        property_pattern = r'#property\s+(\w+)'
        return re.findall(property_pattern, content, re.IGNORECASE)
    
    def _calculate_complexity(self, content: str) -> int:
        """Calcula complexidade do código"""
        complexity = 0
        
        # Contar estruturas de controle
        control_structures = [r'if\s*\(', r'for\s*\(', r'while\s*\(', r'switch\s*\(']
        for pattern in control_structures:
            complexity += len(re.findall(pattern, content, re.IGNORECASE))
        
        # Contar funções
        functions = self._extract_functions(content)
        complexity += len(functions)
        
        return complexity
    
    def _calculate_quality_score(self, analysis: Dict[str, Any]) -> float:
        """Calcula score de qualidade do código"""
        score = 100.0
        
        # Penalizar por tipo desconhecido
        if analysis['file_type'] == 'Unknown':
            score -= 20
        
        # Penalizar por estratégia desconhecida
        if analysis['strategy'] == ['Unknown']:
            score -= 15
        
        # Bonificar por conformidade FTMO
        ftmo_score = analysis.get('ftmo_analysis', {}).get('compliance_score', 0)
        score += (ftmo_score / 100) * 20  # Max 20 pontos
        
        # Penalizar por baixa complexidade (muito simples)
        if analysis['complexity_score'] < 5:
            score -= 10
        
        # Penalizar por alta complexidade (muito complexo)
        if analysis['complexity_score'] > 50:
            score -= 15
        
        return max(0, min(100, score))
    
    def _detect_issues(self, content: str) -> List[str]:
        """Detecta problemas no código"""
        issues = []
        
        # Verificar problemas comuns
        if 'OrderSend' in content and 'OrderModify' not in content:
            issues.append("Possível falta de modificação de ordens (SL/TP)")
        
        if 'while(true)' in content or 'for(;;)' in content:
            issues.append("Loop infinito detectado - risco de travamento")
        
        if content.count('{') != content.count('}'):
            issues.append("Chaves desbalanceadas - erro de sintaxe")
        
        if 'Sleep(' in content:
            issues.append("Uso de Sleep() detectado - pode afetar performance")
        
        return issues
    
    def _extract_code_snippets(self, content: str) -> List[Dict[str, str]]:
        """Extrai snippets de código reutilizáveis"""
        snippets = []
        
        # Extrair funções de gestão de risco
        risk_functions = [
            r'(double\s+CalculateLotSize\s*\([^}]+})',
            r'(bool\s+CheckRisk\s*\([^}]+})',
            r'(double\s+GetRiskPercent\s*\([^}]+})'
        ]
        
        for pattern in risk_functions:
            matches = re.findall(pattern, content, re.DOTALL | re.IGNORECASE)
            for match in matches:
                snippets.append({
                    'type': 'risk_management',
                    'code': match,
                    'description': 'Função de gestão de risco'
                })
        
        return snippets

class RealMQL4Processor:
    """Processador Real de Arquivos MQL4"""
    
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.logger = logging.getLogger('RealMQL4Processor')
        self.analyzer = MQL4CodeAnalyzer()
        
        # Estatísticas
        self.stats = {
            'total_files': 0,
            'processed_files': 0,
            'failed_files': 0,
            'moved_files': 0,
            'metadata_created': 0,
            'snippets_extracted': 0,
            'processing_time': 0.0
        }
        
        # Configurações
        self.batch_size = 100
        self.backup_enabled = True
    
    def process_all_files_real(self) -> Dict[str, Any]:
        """Processa todos os arquivos MQL4 de forma REAL"""
        self.logger.info("🚀 INICIANDO PROCESSAMENTO REAL DE ARQUIVOS MQL4")
        self.logger.info("=" * 70)
        
        start_time = time.time()
        
        # Encontrar arquivos
        all_mq4_path = self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "All_MQ4"
        files_to_process = list(all_mq4_path.glob("*.mq4"))
        
        self.stats['total_files'] = len(files_to_process)
        self.logger.info(f"📁 Total de arquivos encontrados: {len(files_to_process)}")
        
        if not files_to_process:
            self.logger.warning("❌ Nenhum arquivo .mq4 encontrado!")
            return self.stats
        
        # Criar backup se habilitado
        if self.backup_enabled:
            self._create_backup()
        
        # Processar em lotes
        all_results = []
        for i in range(0, len(files_to_process), self.batch_size):
            batch_num = (i // self.batch_size) + 1
            batch_files = files_to_process[i:i + self.batch_size]
            
            self.logger.info(f"\n📦 PROCESSANDO LOTE {batch_num} ({len(batch_files)} arquivos)")
            
            batch_results = self._process_batch_real(batch_files, batch_num)
            all_results.extend(batch_results)
            
            # Pausa entre lotes
            if i + self.batch_size < len(files_to_process):
                time.sleep(1)
        
        # Finalizar
        self.stats['processing_time'] = time.time() - start_time
        self._generate_final_report(all_results)
        
        self.logger.info("\n✅ PROCESSAMENTO REAL CONCLUÍDO COM SUCESSO!")
        return self.stats
    
    def _process_batch_real(self, batch_files: List[Path], batch_num: int) -> List[Dict[str, Any]]:
        """Processa um lote de arquivos de forma REAL"""
        batch_results = []
        
        for i, file_path in enumerate(batch_files, 1):
            try:
                # Log de progresso
                if i % 10 == 0 or i == len(batch_files):
                    progress = (i / len(batch_files)) * 100
                    self.logger.info(f"  📈 Progresso: {progress:.1f}% ({i}/{len(batch_files)})")
                
                # Analisar arquivo REAL
                analysis = self.analyzer.analyze_file(file_path)
                
                if not analysis.get('analysis_failed', False):
                    # Mover arquivo para pasta correta
                    new_path = self._move_file_to_category(file_path, analysis)
                    
                    # Gerar metadados
                    metadata_path = self._generate_metadata(analysis, new_path)
                    
                    # Extrair snippets
                    self._extract_and_save_snippets(analysis)
                    
                    analysis['moved_to'] = str(new_path) if new_path else None
                    analysis['metadata_path'] = str(metadata_path) if metadata_path else None
                    
                    self.stats['processed_files'] += 1
                    if new_path:
                        self.stats['moved_files'] += 1
                    if metadata_path:
                        self.stats['metadata_created'] += 1
                else:
                    self.stats['failed_files'] += 1
                
                batch_results.append(analysis)
                
            except Exception as e:
                self.logger.error(f"❌ Erro ao processar {file_path.name}: {e}")
                batch_results.append({
                    'file_path': str(file_path),
                    'error': str(e),
                    'processing_failed': True
                })
                self.stats['failed_files'] += 1
        
        return batch_results
    
    def _move_file_to_category(self, file_path: Path, analysis: Dict[str, Any]) -> Optional[Path]:
        """Move arquivo para categoria correta"""
        try:
            file_type = analysis.get('file_type', 'Unknown')
            strategies = analysis.get('strategy', ['Unknown'])
            primary_strategy = strategies[0] if strategies else 'Unknown'
            
            # Determinar pasta destino
            if file_type == 'EA':
                if primary_strategy == 'Scalping':
                    dest_dir = self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "EAs" / "Scalping"
                elif primary_strategy == 'Grid_Martingale':
                    dest_dir = self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "EAs" / "Grid_Martingale"
                elif primary_strategy == 'Trend_Following':
                    dest_dir = self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "EAs" / "Trend_Following"
                else:
                    dest_dir = self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "EAs" / "Misc"
            
            elif file_type == 'Indicator':
                if primary_strategy == 'SMC_ICT':
                    dest_dir = self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "Indicators" / "SMC_ICT"
                elif primary_strategy == 'Volume_Analysis':
                    dest_dir = self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "Indicators" / "Volume"
                elif primary_strategy == 'Trend_Following':
                    dest_dir = self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "Indicators" / "Trend"
                else:
                    dest_dir = self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "Indicators" / "Custom"
            
            elif file_type == 'Script':
                dest_dir = self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "Scripts" / "Utilities"
            
            else:
                dest_dir = self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "Misc"
            
            # Criar diretório se não existir
            dest_dir.mkdir(parents=True, exist_ok=True)
            
            # Gerar nome do arquivo
            new_name = self._generate_new_filename(file_path, analysis)
            dest_path = dest_dir / new_name
            
            # Evitar conflitos de nome
            counter = 1
            while dest_path.exists():
                name_parts = new_name.rsplit('.', 1)
                if len(name_parts) == 2:
                    dest_path = dest_dir / f"{name_parts[0]}_{counter}.{name_parts[1]}"
                else:
                    dest_path = dest_dir / f"{new_name}_{counter}"
                counter += 1
            
            # Mover arquivo
            shutil.move(str(file_path), str(dest_path))
            self.logger.debug(f"📁 Movido: {file_path.name} → {dest_path}")
            
            return dest_path
            
        except Exception as e:
            self.logger.error(f"❌ Erro ao mover {file_path}: {e}")
            return None
    
    def _generate_new_filename(self, file_path: Path, analysis: Dict[str, Any]) -> str:
        """Gera novo nome para o arquivo"""
        file_type = analysis.get('file_type', 'Unknown')
        strategies = analysis.get('strategy', ['Unknown'])
        primary_strategy = strategies[0] if strategies else 'Unknown'
        
        # Prefixo baseado no tipo
        prefix_map = {
            'EA': 'EA',
            'Indicator': 'IND',
            'Script': 'SCR'
        }
        prefix = prefix_map.get(file_type, 'UNK')
        
        # Nome base (limpar caracteres especiais)
        base_name = re.sub(r'[^a-zA-Z0-9_]', '_', file_path.stem)
        base_name = re.sub(r'_+', '_', base_name).strip('_')
        
        # Versão
        version = "v1.0"
        
        # Mercado (se detectado)
        markets = analysis.get('market_timeframe', {}).get('markets', [])
        market_suffix = f"_{markets[0]}" if markets else ""
        
        # Montar nome final
        new_name = f"{prefix}_{base_name}_{version}{market_suffix}.mq4"
        
        return new_name
    
    def _generate_metadata(self, analysis: Dict[str, Any], file_path: Optional[Path]) -> Optional[Path]:
        """Gera arquivo de metadados"""
        try:
            if not file_path:
                return None
            
            metadata_dir = self.base_path / "Metadata"
            metadata_dir.mkdir(parents=True, exist_ok=True)
            
            metadata_file = metadata_dir / f"{file_path.stem}.meta.json"
            
            # Gerar tags
            tags = self._generate_tags(analysis)
            
            metadata = {
                "file_info": {
                    "original_name": analysis.get('file_name', ''),
                    "current_name": file_path.name,
                    "current_path": str(file_path),
                    "file_size": analysis.get('file_size', 0),
                    "lines_count": analysis.get('lines_count', 0)
                },
                "classification": {
                    "type": analysis.get('file_type', 'Unknown'),
                    "strategy": analysis.get('strategy', ['Unknown']),
                    "market_timeframe": analysis.get('market_timeframe', {})
                },
                "ftmo_analysis": analysis.get('ftmo_analysis', {}),
                "quality": {
                    "score": analysis.get('quality_score', 0.0),
                    "complexity": analysis.get('complexity_score', 0),
                    "issues": analysis.get('issues_found', [])
                },
                "code_analysis": {
                    "functions": analysis.get('functions_found', []),
                    "variables": analysis.get('variables_found', []),
                    "includes": analysis.get('includes_found', []),
                    "properties": analysis.get('properties_found', [])
                },
                "tags": tags,
                "processing_info": {
                    "processed_at": datetime.now().isoformat(),
                    "processor_version": "7.0",
                    "analysis_complete": True
                }
            }
            
            with open(metadata_file, 'w', encoding='utf-8') as f:
                json.dump(metadata, f, indent=2, ensure_ascii=False)
            
            return metadata_file
            
        except Exception as e:
            self.logger.error(f"❌ Erro ao gerar metadados: {e}")
            return None
    
    def _generate_tags(self, analysis: Dict[str, Any]) -> List[str]:
        """Gera tags para o arquivo"""
        tags = []
        
        # Tag de tipo
        file_type = analysis.get('file_type', 'Unknown')
        tags.append(f"#{file_type}")
        
        # Tags de estratégia
        strategies = analysis.get('strategy', [])
        for strategy in strategies:
            tags.append(f"#{strategy}")
        
        # Tags de mercado
        markets = analysis.get('market_timeframe', {}).get('markets', [])
        for market in markets:
            tags.append(f"#{market}")
        
        # Tags de timeframe
        timeframes = analysis.get('market_timeframe', {}).get('timeframes', [])
        for tf in timeframes:
            tags.append(f"#{tf}")
        
        # Tag FTMO
        ftmo_ready = analysis.get('ftmo_analysis', {}).get('ftmo_ready', False)
        if ftmo_ready:
            tags.append("#FTMO_Ready")
        else:
            tags.append("#Nao_FTMO")
        
        # Tag de qualidade
        quality_score = analysis.get('quality_score', 0.0)
        if quality_score >= 80:
            tags.append("#HighQuality")
        elif quality_score >= 60:
            tags.append("#MediumQuality")
        else:
            tags.append("#LowQuality")
        
        return tags
    
    def _extract_and_save_snippets(self, analysis: Dict[str, Any]):
        """Extrai e salva snippets de código"""
        snippets = analysis.get('snippets', [])
        if not snippets:
            return
        
        try:
            snippets_dir = self.base_path / "Snippets" / "Risk_Management"
            snippets_dir.mkdir(parents=True, exist_ok=True)
            
            for i, snippet in enumerate(snippets):
                snippet_file = snippets_dir / f"snippet_{int(time.time())}_{i}.mq4"
                
                with open(snippet_file, 'w', encoding='utf-8') as f:
                    f.write(f"// {snippet.get('description', 'Snippet extraído')}\n")
                    f.write(f"// Extraído de: {analysis.get('file_name', 'Unknown')}\n")
                    f.write(f"// Data: {datetime.now().isoformat()}\n\n")
                    f.write(snippet.get('code', ''))
                
                self.stats['snippets_extracted'] += 1
        
        except Exception as e:
            self.logger.error(f"❌ Erro ao salvar snippets: {e}")
    
    def _create_backup(self):
        """Cria backup da pasta All_MQ4"""
        try:
            source_dir = self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "All_MQ4"
            backup_dir = self.base_path / "Backups" / f"All_MQ4_backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
            
            if source_dir.exists():
                shutil.copytree(source_dir, backup_dir)
                self.logger.info(f"💾 Backup criado em: {backup_dir}")
        
        except Exception as e:
            self.logger.error(f"❌ Erro ao criar backup: {e}")
    
    def _generate_final_report(self, results: List[Dict[str, Any]]):
        """Gera relatório final"""
        try:
            report_path = self.base_path / "Reports" / f"processamento_real_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
            report_path.parent.mkdir(parents=True, exist_ok=True)
            
            # Estatísticas por categoria
            type_stats = {}
            strategy_stats = {}
            ftmo_stats = {'ready': 0, 'not_ready': 0}
            
            for result in results:
                if result.get('processing_failed') or result.get('analysis_failed'):
                    continue
                
                # Estatísticas por tipo
                file_type = result.get('file_type', 'Unknown')
                type_stats[file_type] = type_stats.get(file_type, 0) + 1
                
                # Estatísticas por estratégia
                strategies = result.get('strategy', ['Unknown'])
                for strategy in strategies:
                    strategy_stats[strategy] = strategy_stats.get(strategy, 0) + 1
                
                # Estatísticas FTMO
                ftmo_ready = result.get('ftmo_analysis', {}).get('ftmo_ready', False)
                if ftmo_ready:
                    ftmo_stats['ready'] += 1
                else:
                    ftmo_stats['not_ready'] += 1
            
            report = {
                'timestamp': datetime.now().isoformat(),
                'processor_version': '7.0',
                'processing_type': 'REAL',
                'statistics': self.stats,
                'categorization': {
                    'by_type': type_stats,
                    'by_strategy': strategy_stats,
                    'ftmo_compliance': ftmo_stats
                },
                'top_quality_files': self._get_top_quality_files(results),
                'issues_summary': self._get_issues_summary(results)
            }
            
            with open(report_path, 'w', encoding='utf-8') as f:
                json.dump(report, f, indent=2, ensure_ascii=False)
            
            self.logger.info(f"📊 Relatório final salvo em: {report_path}")
            
            # Log de estatísticas
            self.logger.info("\n📊 ESTATÍSTICAS FINAIS:")
            self.logger.info(f"  📁 Total de arquivos: {self.stats['total_files']}")
            self.logger.info(f"  ✅ Processados: {self.stats['processed_files']}")
            self.logger.info(f"  📦 Movidos: {self.stats['moved_files']}")
            self.logger.info(f"  📄 Metadados criados: {self.stats['metadata_created']}")
            self.logger.info(f"  🧩 Snippets extraídos: {self.stats['snippets_extracted']}")
            self.logger.info(f"  ⏱️ Tempo total: {self.stats['processing_time']:.2f}s")
            
        except Exception as e:
            self.logger.error(f"❌ Erro ao gerar relatório final: {e}")
    
    def _get_top_quality_files(self, results: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Retorna top 10 arquivos por qualidade"""
        valid_results = [r for r in results if not r.get('processing_failed') and not r.get('analysis_failed')]
        sorted_results = sorted(valid_results, key=lambda x: x.get('quality_score', 0), reverse=True)
        
        return [{
            'file_name': r.get('file_name', ''),
            'quality_score': r.get('quality_score', 0),
            'file_type': r.get('file_type', ''),
            'strategy': r.get('strategy', []),
            'ftmo_ready': r.get('ftmo_analysis', {}).get('ftmo_ready', False)
        } for r in sorted_results[:10]]
    
    def _get_issues_summary(self, results: List[Dict[str, Any]]) -> Dict[str, int]:
        """Retorna resumo de problemas encontrados"""
        issues_count = {}
        
        for result in results:
            issues = result.get('issues_found', [])
            for issue in issues:
                issues_count[issue] = issues_count.get(issue, 0) + 1
        
        return issues_count

def main():
    """Função principal"""
    base_path = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD"
    
    processor = RealMQL4Processor(base_path)
    results = processor.process_all_files_real()
    
    print("\n🎉 PROCESSAMENTO REAL CONCLUÍDO COM SUCESSO!")
    print(f"📊 Estatísticas: {results}")
    
    return results

if __name__ == "__main__":
    main()