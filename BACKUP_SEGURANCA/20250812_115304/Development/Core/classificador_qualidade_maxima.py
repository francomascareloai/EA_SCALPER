#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
CLASSIFICADOR DE QUALIDADE MÁXIMA - TRADING CODE ANALYZER
Análise profunda e classificação de códigos de trading com foco em compliance FTMO
Autor: Classificador_Trading_Elite
Versão: 1.0
"""

import os
import re
import json
import shutil
from datetime import datetime
from pathlib import Path
import hashlib

class TradingCodeAnalyzer:
    def __init__(self, base_path):
        self.base_path = Path(base_path)
        self.analysis_results = []
        
        # Padrões de detecção avançados refinados
        self.patterns = {
            'ea_patterns': [
                r'void\s+OnTick\s*\(',
                r'int\s+OnTick\s*\(',
                r'OnTick\s*\(',
                r'OrderSend\s*\(',
                r'trade\.Buy\s*\(',
                r'trade\.Sell\s*\(',
                r'PositionOpen\s*\(',
                r'extern\s+(double|int|bool).*Risk',
                r'extern\s+(double|int|bool).*Lot',
                r'extern.*Risk',
                r'extern.*Lot'
            ],
            'indicator_patterns': [
                r'void\s+OnCalculate\s*\(',
                r'int\s+OnCalculate\s*\(',
                r'SetIndexBuffer\s*\(',
                r'IndicatorBuffers\s*\(',
                r'PlotIndexSetInteger\s*\(',
                r'#property\s+indicator_buffers',
                r'#property\s+indicator_plots'
            ],
            'script_patterns': [
                r'void\s+OnStart\s*\(',
                r'int\s+start\s*\(',
                r'void\s+start\s*\('
            ],
            'strategy_patterns': {
                'scalping': [
                    r'scalp', r'scalper', r'Scalper', r'SCALP', r'quick', r'fast', r'rapid',
                    r'short.?term', r'pip.?hunter', r'micro.?profit',
                    r'entry.?pips', r'spread.*check', r'trailing.*stop',
                    r'iron.*scalp', r'Iron.*Scalp', r'turbo', r'speed',
                    r'EntryPips', r'TrailingStop', r'StopLoss'
                ],
                'grid_martingale': [
                    r'grid', r'martingale', r'recovery', r'averaging',
                    r'double.?down', r'lot.?multiplier', r'hedge',
                    r'basket', r'recovery.*zone'
                ],
                'smc_ict': [
                    r'order.?block', r'liquidity', r'institutional',
                    r'smart.?money', r'market.?structure', r'imbalance',
                    r'fair.?value.?gap', r'breaker', r'bos', r'choch'
                ],
                'trend_following': [
                    r'trend', r'momentum', r'moving.?average', r'ma\b',
                    r'ema\b', r'sma\b', r'direction', r'breakout'
                ],
                'volume_analysis': [
                    r'volume', r'obv', r'flow', r'accumulation',
                    r'distribution', r'tick.?volume', r'money.?flow'
                ]
            },
            'ftmo_compliance': {
                'risk_management': [
                    r'risk', r'Risk', r'RISK', r'stop.?loss', r'sl\b', r'SL\b',
                    r'drawdown', r'equity', r'balance', r'margin',
                    r'AccountBalance', r'AccountEquity', r'StopLoss',
                    r'extern.*Risk', r'extern.*SL'
                ],
                'position_sizing': [
                    r'lot.?size', r'Lot', r'LOT', r'position.?size', 
                    r'money.?management', r'risk.?percent', r'account.?balance',
                    r'extern.*Lot', r'LotSize', r'FixedLot', r'extern\s+double\s+Lot',
                    r'extern\s+double.*Risk'
                ],
                'session_filters': [
                    r'time.?filter', r'session', r'trading.?hours',
                    r'TimeHour', r'TimeStart', r'TimeEnd', r'Hour\(',
                    r'StartTime', r'EndTime', r'TradingTime'
                ],
                'news_filters': [
                    r'news', r'economic', r'calendar', r'high.?impact',
                    r'NewsFilter', r'EconomicNews'
                ],
                'max_trades': [
                    r'max.?trades', r'MaxTrades', r'position.?limit', 
                    r'concurrent', r'OrdersTotal', r'PositionsTotal'
                ]
            }
        }
    
    def analyze_file(self, file_path):
        """Análise profunda de um arquivo de trading"""
        try:
            # Tentar diferentes encodings incluindo UTF-16
            content = None
            encodings = ['utf-16', 'utf-16le', 'utf-16be', 'utf-8', 'cp1251', 'latin-1', 'cp1252']
            
            for encoding in encodings:
                try:
                    with open(file_path, 'r', encoding=encoding, errors='ignore') as f:
                        content = f.read()
                    # Verificar se o conteúdo faz sentido
                    if 'OnTick' in content or 'extern' in content or len(content.replace('\x00', '')) > 100:
                        break
                except:
                    continue
            
            if content is None:
                return {'error': 'Encoding error', 'file_path': str(file_path)}
            
            analysis = {
                'file_path': str(file_path),
                'file_name': file_path.name,
                'file_size': file_path.stat().st_size,
                'file_hash': self._calculate_hash(content),
                'analysis_timestamp': datetime.now().isoformat(),
                'language': self._detect_language(file_path),
                'file_type': self._detect_file_type(content),
                'strategy': self._detect_strategy(content),
                'market_analysis': self._analyze_market_focus(content),
                'timeframe_analysis': self._analyze_timeframes(content),
                'ftmo_compliance': self._analyze_ftmo_compliance(content),
                'code_quality': self._analyze_code_quality(content),
                'risk_assessment': self._assess_risk_level(content),
                'suggested_name': '',
                'target_folder': '',
                'tags': [],
                'metadata': {}
            }
            
            # Gerar nome sugerido e pasta destino
            analysis['suggested_name'] = self._generate_suggested_name(analysis)
            analysis['target_folder'] = self._determine_target_folder(analysis)
            analysis['tags'] = self._generate_tags(analysis)
            
            return analysis
            
        except Exception as e:
            return {
                'file_path': str(file_path),
                'error': str(e),
                'analysis_timestamp': datetime.now().isoformat()
            }
    
    def _calculate_hash(self, content):
        """Calcula hash MD5 do conteúdo"""
        return hashlib.md5(content.encode('utf-8')).hexdigest()
    
    def _detect_language(self, file_path):
        """Detecta linguagem do arquivo"""
        ext = file_path.suffix.lower()
        if ext == '.mq4':
            return 'MQL4'
        elif ext == '.mq5':
            return 'MQL5'
        elif ext == '.pine':
            return 'Pine Script'
        return 'Unknown'
    
    def _detect_file_type(self, content, file_path=None):
        """Detecta o tipo do arquivo baseado no conteúdo com padrões robustos"""
        
        # Padrões regex mais precisos
        patterns = {
            'EA': [
                r'\bvoid\s+OnTick\s*\(',
                r'\bOrderSend\s*\(',
                r'\btrade\.Buy\s*\(',
                r'\btrade\.Sell\s*\(',
                r'\bPositionOpen\s*\(',
                r'\bOrderSendAsync\s*\('
            ],
            'Indicator': [
                r'\bint\s+OnCalculate\s*\(',
                r'\bSetIndexBuffer\s*\(',
                r'\bPlotIndexSetInteger\s*\(',
                r'\bSetIndexStyle\s*\(',
                r'\bIndicatorBuffers\s*\(',
                r'\bIndicatorSetInteger\s*\('
            ],
            'Script': [
                r'\bvoid\s+OnStart\s*\(',
                r'\bint\s+OnStart\s*\('
            ],
            'Pine_Strategy': [
                r'strategy\s*\(',
                r'strategy\.entry\s*\(',
                r'strategy\.close\s*\('
            ],
            'Pine_Indicator': [
                r'study\s*\(',
                r'indicator\s*\(',
                r'plot\s*\(',
                r'plotshape\s*\('
            ]
        }
        
        # Contadores de matches para cada tipo
        type_scores = {}
        
        for file_type, type_patterns in patterns.items():
            score = 0
            for pattern in type_patterns:
                matches = len(re.findall(pattern, content, re.IGNORECASE))
                score += matches
            
            if score > 0:
                type_scores[file_type] = score
        
        # Lógica de decisão aprimorada
        if not type_scores:
            return 'Unknown'
        
        # Encontrar o tipo com maior score
        best_type = max(type_scores.items(), key=lambda x: x[1])
        
        # Validações específicas
        if best_type[0] == 'EA':
            # EA deve ter OnTick E funções de trading
            has_ontick = bool(re.search(r'\bvoid\s+OnTick\s*\(', content, re.IGNORECASE))
            has_trading = bool(re.search(r'\b(OrderSend|trade\.(Buy|Sell)|PositionOpen)\s*\(', content, re.IGNORECASE))
            if has_ontick and has_trading:
                return 'EA'
        
        elif best_type[0] == 'Indicator':
            # Indicator deve ter OnCalculate OU SetIndexBuffer
            has_oncalculate = bool(re.search(r'\bint\s+OnCalculate\s*\(', content, re.IGNORECASE))
            has_buffer = bool(re.search(r'\bSetIndexBuffer\s*\(', content, re.IGNORECASE))
            if has_oncalculate or has_buffer:
                return 'Indicator'
        
        elif best_type[0] == 'Script':
            # Script deve ter OnStart mas NÃO OnTick
            has_onstart = bool(re.search(r'\b(void|int)\s+OnStart\s*\(', content, re.IGNORECASE))
            has_ontick = bool(re.search(r'\bvoid\s+OnTick\s*\(', content, re.IGNORECASE))
            if has_onstart and not has_ontick:
                return 'Script'
        
        elif best_type[0].startswith('Pine_'):
            return best_type[0]
        
        # Fallback para detecção original
        if 'OnTick' in content or 'OrderSend' in content:
            return 'EA'
        if 'OnCalculate' in content or 'SetIndexBuffer' in content:
            return 'Indicator'
        if 'OnStart' in content:
            return 'Script'
            
        return 'Unknown'
    
    def _detect_strategy(self, content):
        """Detecta estratégia principal"""
        content_lower = content.lower()
        strategy_scores = {}
        
        for strategy, patterns in self.patterns['strategy_patterns'].items():
            score = 0
            for pattern in patterns:
                matches = len(re.findall(pattern, content_lower))
                score += matches
            strategy_scores[strategy] = score
        
        # Retorna estratégia com maior score
        if strategy_scores:
            max_strategy = max(strategy_scores, key=strategy_scores.get)
            if strategy_scores[max_strategy] > 0:
                return max_strategy
        
        return 'Custom'
    
    def _analyze_market_focus(self, content):
        """Analisa foco de mercado"""
        markets = {
            'XAUUSD': r'(xau|gold|ouro)',
            'EURUSD': r'eur.?usd',
            'GBPUSD': r'gbp.?usd',
            'USDJPY': r'usd.?jpy',
            'Forex': r'(forex|fx|currency)',
            'Indices': r'(index|indices|us30|nas100|spx500)',
            'Crypto': r'(crypto|bitcoin|btc|ethereum|eth)'
        }
        
        detected_markets = []
        content_lower = content.lower()
        
        for market, pattern in markets.items():
            if re.search(pattern, content_lower):
                detected_markets.append(market)
        
        return detected_markets if detected_markets else ['Multi']
    
    def _analyze_timeframes(self, content):
        """Analisa timeframes utilizados"""
        timeframes = {
            'M1': r'(m1|1.?min|period_m1)',
            'M5': r'(m5|5.?min|period_m5)',
            'M15': r'(m15|15.?min|period_m15)',
            'M30': r'(m30|30.?min|period_m30)',
            'H1': r'(h1|1.?hour|period_h1)',
            'H4': r'(h4|4.?hour|period_h4)',
            'D1': r'(d1|daily|period_d1)'
        }
        
        detected_timeframes = []
        content_lower = content.lower()
        
        for tf, pattern in timeframes.items():
            if re.search(pattern, content_lower):
                detected_timeframes.append(tf)
        
        return detected_timeframes if detected_timeframes else ['Multi']
    
    def _analyze_ftmo_compliance(self, content):
        """Análise rigorosa de compliance FTMO com critérios detalhados"""
        ftmo_score = 0.0
        compliance_issues = []
        compliance_strengths = []
        
        # 1. STOP LOSS OBRIGATÓRIO (0-2 pontos)
        sl_patterns = [
            r'\bStopLoss\b',
            r'\bSL\s*=',
            r'\bstop_loss\b',
            r'OrderModify.*sl',
            r'trade\.SetDeviationInPoints.*sl'
        ]
        
        has_stop_loss = any(re.search(pattern, content, re.IGNORECASE) for pattern in sl_patterns)
        if has_stop_loss:
            ftmo_score += 2.0
            compliance_strengths.append("Stop Loss implementado")
        else:
            compliance_issues.append("CRÍTICO: Sem Stop Loss detectado")
        
        # 2. GESTÃO DE RISCO (0-2 pontos)
        risk_patterns = [
            r'\b(AccountBalance|AccountEquity)\b',
            r'\b(risk|Risk)\s*[=*]',
            r'\blot.*balance',
            r'\bMaxRisk\b',
            r'\bRiskPercent\b',
            r'\bAccountInfoDouble\(ACCOUNT_BALANCE\)'
        ]
        
        risk_management_count = sum(1 for pattern in risk_patterns if re.search(pattern, content, re.IGNORECASE))
        if risk_management_count >= 3:
            ftmo_score += 2.0
            compliance_strengths.append("Gestão de risco robusta")
        elif risk_management_count >= 1:
            ftmo_score += 1.0
            compliance_strengths.append("Gestão de risco básica")
        else:
            compliance_issues.append("CRÍTICO: Sem gestão de risco")
        
        # 3. DRAWDOWN PROTECTION (0-1.5 pontos)
        drawdown_patterns = [
            r'\b(MaxDrawdown|DrawdownLimit)\b',
            r'\b(daily.*loss|DailyLoss)\b',
            r'\bequity.*balance',
            r'\bAccountInfoDouble\(ACCOUNT_EQUITY\)'
        ]
        
        has_drawdown_protection = any(re.search(pattern, content, re.IGNORECASE) for pattern in drawdown_patterns)
        if has_drawdown_protection:
            ftmo_score += 1.5
            compliance_strengths.append("Proteção de drawdown")
        else:
            compliance_issues.append("Sem proteção de drawdown")
        
        # 4. TAKE PROFIT / RISK-REWARD (0-1 ponto)
        tp_patterns = [
            r'\bTakeProfit\b',
            r'\bTP\s*=',
            r'\btake_profit\b',
            r'\bRR\s*=',
            r'\bRiskReward\b'
        ]
        
        has_take_profit = any(re.search(pattern, content, re.IGNORECASE) for pattern in tp_patterns)
        if has_take_profit:
            ftmo_score += 1.0
            compliance_strengths.append("Take Profit definido")
        
        # 5. FILTROS DE SESSÃO/HORÁRIO (0-0.5 pontos)
        session_patterns = [
            r'\b(Hour|TimeHour)\b',
            r'\b(session|Session)\b',
            r'\b(trading.*time|TradingTime)\b',
            r'\b(news.*filter|NewsFilter)\b'
        ]
        
        has_session_filter = any(re.search(pattern, content, re.IGNORECASE) for pattern in session_patterns)
        if has_session_filter:
            ftmo_score += 0.5
            compliance_strengths.append("Filtros de sessão")
        
        # PENALIZAÇÕES CRÍTICAS
        
        # Grid/Martingale (-3 pontos)
        dangerous_patterns = [
            r'\b(grid|Grid)\b',
            r'\b(martingale|Martingale)\b',
            r'\b(recovery|Recovery)\b',
            r'\blot.*\*.*2',
            r'\bdouble.*lot'
        ]
        
        has_dangerous_strategy = any(re.search(pattern, content, re.IGNORECASE) for pattern in dangerous_patterns)
        if has_dangerous_strategy:
            ftmo_score -= 3.0
            compliance_issues.append("CRÍTICO: Estratégia de alto risco (Grid/Martingale)")
        
        # Hedging (-1 ponto)
        if re.search(r'\b(hedge|Hedge|hedging)\b', content, re.IGNORECASE):
            ftmo_score -= 1.0
            compliance_issues.append("Hedging detectado")
        
        # Sem limite de trades (-0.5 pontos)
        if not re.search(r'\b(MaxTrades|max.*trade|trade.*limit)\b', content, re.IGNORECASE):
            ftmo_score -= 0.5
            compliance_issues.append("Sem limite de trades simultâneos")
        
        # News trading sem filtro (-0.5 pontos)
        if re.search(r'\b(news|News)\b', content, re.IGNORECASE) and not has_session_filter:
            ftmo_score -= 0.5
            compliance_issues.append("News trading sem filtros")
        
        # Normalizar score (0-7)
        final_score = max(0.0, min(7.0, ftmo_score))
        
        # Determinar nível FTMO
        if final_score >= 6.0:
            ftmo_level = "FTMO_Ready"
        elif final_score >= 4.0:
            ftmo_level = "Moderado"
        elif final_score >= 2.0:
            ftmo_level = "Baixo"
        else:
            ftmo_level = "Não_Adequado"
        
        return {
            'ftmo_score': round(final_score, 1),
            'ftmo_level': ftmo_level,
            'compliance_issues': compliance_issues,
            'compliance_strengths': compliance_strengths,
            'is_ftmo_ready': final_score >= 5.0,
            'risk_category': 'Low' if final_score >= 5.0 else 'High' if final_score < 2.0 else 'Medium',
            'score': int(final_score),
            'level': ftmo_level
        }
    
    def _analyze_code_quality(self, content):
        """Análise de qualidade do código com métricas detalhadas"""
        lines = content.split('\n')
        total_lines = len(lines)
        comment_lines = len([line for line in lines if line.strip().startswith('//')]) 
        empty_lines = len([line for line in lines if not line.strip()])
        code_lines = total_lines - comment_lines - empty_lines
        
        quality_score = 5.0  # Score base
        issues = []
        strengths = []
        
        # Métricas básicas
        comment_ratio = comment_lines / total_lines if total_lines > 0 else 0
        complexity_score = len(re.findall(r'\bif\s*\(|\bfor\s*\(|\bwhile\s*\(', content))
        function_count = len(re.findall(r'(void|double|int|bool|string)\s+\w+\s*\(', content))
        extern_params = len(re.findall(r'extern\s+(double|int|bool|string)', content))
        
        # 1. Análise de estrutura (0-2 pontos)
        structure_score = 0
        if total_lines > 50:
            structure_score += 0.5
            strengths.append("Código substancial")
        if total_lines > 200:
            structure_score += 0.5
            strengths.append("Código complexo")
        if re.search(r'\bclass\s+\w+', content, re.IGNORECASE):
            structure_score += 0.5
            strengths.append("Uso de classes")
        if re.search(r'\bstruct\s+\w+', content, re.IGNORECASE):
            structure_score += 0.3
            strengths.append("Uso de estruturas")
        
        quality_score += min(2.0, structure_score)
        
        # 2. Análise de comentários (0-1.5 pontos)
        if comment_ratio > 0.15:
            quality_score += 1.5
            strengths.append("Bem documentado")
        elif comment_ratio > 0.08:
            quality_score += 1.0
            strengths.append("Documentação adequada")
        elif comment_ratio > 0.03:
            quality_score += 0.5
        else:
            quality_score -= 0.5
            issues.append("Poucos comentários")
        
        # 3. Análise de boas práticas (0-2 pontos)
        practices_score = 0
        
        # Verificar tratamento de erros
        if re.search(r'\b(GetLastError|ErrorDescription|try|catch)\b', content, re.IGNORECASE):
            practices_score += 0.5
            strengths.append("Tratamento de erros")
        
        # Verificar validação de parâmetros
        if re.search(r'\b(if\s*\(.*[<>=!]|return\s*false|return\s*-1)\b', content, re.IGNORECASE):
            practices_score += 0.3
            strengths.append("Validação de parâmetros")
        
        # Verificar uso de constantes
        if re.search(r'\b(const\s+|#define\s+|enum\s+)\w+', content, re.IGNORECASE):
            practices_score += 0.4
            strengths.append("Uso de constantes")
        
        # Verificar funções customizadas
        if function_count > 3:
            practices_score += 0.5
            strengths.append("Código modular")
        elif function_count > 1:
            practices_score += 0.3
        
        quality_score += min(2.0, practices_score)
        
        # 4. Penalizações (-0.5 a -2 pontos)
        if 'TODO' in content or 'FIXME' in content:
            quality_score -= 0.5
            issues.append("Contém TODOs/FIXMEs")
        
        if len(content) < 200:
            quality_score -= 1.0
            issues.append("Código muito pequeno")
        
        # Verificar complexidade excessiva
        if complexity_score > 100:
            quality_score -= 0.5
            issues.append("Complexidade alta")
        
        # 5. Bônus por características especiais (0-0.5 pontos)
        if extern_params > 5:
            quality_score += 0.2
            strengths.append("Parâmetros configuráveis")
        
        if re.search(r'\b(Alert|Print|Comment)\s*\(', content, re.IGNORECASE):
            quality_score += 0.1
            strengths.append("Sistema de logs")
        
        # Normalizar score (1-10)
        final_score = max(1.0, min(10.0, quality_score))
        
        return {
            'total_lines': total_lines,
            'code_lines': code_lines,
            'comment_lines': comment_lines,
            'comment_ratio': round(comment_ratio, 3),
            'complexity_score': complexity_score,
            'function_count': function_count,
            'extern_params': extern_params,
            'quality_score': round(final_score, 1),
            'quality_level': 'High' if final_score >= 7 else 'Medium' if final_score >= 4 else 'Low',
            'issues': issues,
            'strengths': strengths
        }
    
    def _assess_risk_level(self, content):
        """Avalia nível de risco da estratégia"""
        content_lower = content.lower()
        risk_factors = {
            'martingale': len(re.findall(r'martingale|double.?down', content_lower)),
            'grid': len(re.findall(r'grid|averaging', content_lower)),
            'no_stop_loss': 1 if not re.search(r'stop.?loss|sl\b', content_lower) else 0,
            'high_leverage': len(re.findall(r'leverage|margin', content_lower)),
            'news_trading': len(re.findall(r'news|economic', content_lower))
        }
        
        total_risk = sum(risk_factors.values())
        
        if total_risk >= 5:
            return 'High'
        elif total_risk >= 2:
            return 'Medium'
        else:
            return 'Low'
    
    def _generate_suggested_name(self, analysis):
        """Gera nome sugerido baseado na análise"""
        prefix_map = {
            'EA': 'EA_',
            'Indicator': 'IND_',
            'Script': 'SCR_'
        }
        
        prefix = prefix_map.get(analysis['file_type'], 'UNK_')
        
        # Nome base do arquivo
        base_name = Path(analysis['file_name']).stem
        base_name = re.sub(r'[^a-zA-Z0-9_]', '', base_name)
        
        # Estratégia
        strategy = analysis['strategy'].title().replace('_', '')
        
        # Mercado
        market = analysis['market_analysis'][0] if analysis['market_analysis'] else 'MULTI'
        
        # Versão
        version = 'v1.0'
        
        # Extensão
        ext = Path(analysis['file_name']).suffix
        
        return f"{prefix}{strategy}_{base_name}_{version}_{market}{ext}"
    
    def _determine_target_folder(self, analysis):
        """Determina pasta destino baseada na análise"""
        language_map = {
            'MQL4': 'MQL4_Source',
            'MQL5': 'MQL5_Source',
            'Pine Script': 'TradingView_Scripts/Pine_Script_Source'
        }
        
        base_folder = language_map.get(analysis['language'], 'Unknown')
        
        type_folder = {
            'EA': 'EAs',
            'Indicator': 'Indicators', 
            'Script': 'Scripts'
        }.get(analysis['file_type'], 'Misc')
        
        # Subpasta baseada na estratégia e compliance FTMO
        if analysis['file_type'] == 'EA':
            if analysis['ftmo_compliance']['level'] == 'FTMO_Ready':
                strategy_folder = 'FTMO_Ready'
            else:
                strategy_map = {
                    'scalping': 'Scalping',
                    'grid_martingale': 'Grid_Martingale',
                    'smc_ict': 'SMC_ICT',
                    'trend_following': 'Trend_Following',
                    'volume_analysis': 'Volume_Analysis'
                }
                strategy_folder = strategy_map.get(analysis['strategy'], 'Others')
        else:
            strategy_map = {
                'smc_ict': 'SMC_ICT',
                'volume_analysis': 'Volume_Analysis',
                'trend_following': 'Trend',
                'scalping': 'Custom'
            }
            strategy_folder = strategy_map.get(analysis['strategy'], 'Custom')
        
        return f"{base_folder}/{type_folder}/{strategy_folder}"
    
    def _generate_tags(self, analysis):
        """Gera tags baseadas na análise"""
        tags = []
        
        # Tipo
        tags.append(f"#{analysis['file_type']}")
        
        # Estratégia
        tags.append(f"#{analysis['strategy'].title()}")
        
        # Mercados
        for market in analysis['market_analysis']:
            tags.append(f"#{market}")
        
        # Timeframes
        for tf in analysis['timeframe_analysis']:
            tags.append(f"#{tf}")
        
        # FTMO
        tags.append(f"#{analysis['ftmo_compliance']['level']}")
        
        # Risco
        tags.append(f"#{analysis['risk_assessment']}Risk")
        
        # Qualidade
        tags.append(f"#{analysis['code_quality']['quality_level']}Quality")
        
        return tags
    
    def _detect_special_cases(self, file_path, content):
        """Detecta casos especiais com análise detalhada"""
        import hashlib
        import re
        
        special_cases = []
        filename = os.path.basename(file_path)
        
        # 1. DETECÇÃO DE DUPLICATAS
        # Por nome (padrões comuns)
        duplicate_patterns = [
            r'\(\d+\)',  # file(1).mq4
            r'\s+\(\d+\)',  # file (1).mq4
            r'_copy\d*',  # file_copy.mq4, file_copy1.mq4
            r'_\d+$',  # file_1.mq4
            r'\s+-\s+Copy',  # file - Copy.mq4
            r'\s+Copy\s*\d*'  # file Copy.mq4, file Copy 1.mq4
        ]
        
        for pattern in duplicate_patterns:
            if re.search(pattern, filename, re.IGNORECASE):
                special_cases.append(f"Duplicata por nome: {pattern}")
                break
        
        # Por conteúdo (hash MD5)
        content_hash = hashlib.md5(content.encode('utf-8', errors='ignore')).hexdigest()
        if hasattr(self, '_content_hashes'):
            if content_hash in self._content_hashes:
                special_cases.append(f"Duplicata por conteúdo: {self._content_hashes[content_hash]}")
            else:
                self._content_hashes[content_hash] = filename
        else:
            self._content_hashes = {content_hash: filename}
        
        # 2. ARQUIVOS CORROMPIDOS/PROBLEMÁTICOS
        # Muito pequenos
        if len(content) < 50:
            special_cases.append("Arquivo muito pequeno (<50 chars)")
        elif len(content) < 200:
            special_cases.append("Arquivo pequeno (<200 chars)")
        
        # Muito grandes (suspeito)
        if len(content) > 500000:  # 500KB
            special_cases.append("Arquivo muito grande (>500KB)")
        
        # Problemas de encoding
        try:
            content.encode('utf-8')
        except UnicodeEncodeError:
            special_cases.append("Problemas de encoding UTF-8")
        
        # Caracteres suspeitos
        if re.search(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F-\x9F]', content):
            special_cases.append("Caracteres de controle detectados")
        
        # 3. NOMES PROBLEMÁTICOS
        problematic_name_patterns = [
            r'^[\s\-_]+',  # Inicia com espaços/hífens
            r'[\s\-_]+$',  # Termina com espaços/hífens
            r'\s{2,}',  # Múltiplos espaços
            r'[<>:"|\*\?]',  # Caracteres inválidos no Windows
            r'^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])$',  # Nomes reservados Windows
        ]
        
        for pattern in problematic_name_patterns:
            if re.search(pattern, filename, re.IGNORECASE):
                special_cases.append(f"Nome problemático: {pattern}")
        
        # 4. CONTEÚDO SUSPEITO
        # Arquivo vazio ou só comentários
        code_lines = [line for line in content.split('\n') 
                     if line.strip() and not line.strip().startswith('//')]
        if len(code_lines) < 5:
            special_cases.append("Pouco código real (só comentários)")
        
        # Código repetitivo (possível gerado automaticamente)
        lines = content.split('\n')
        line_counts = {}
        for line in lines:
            clean_line = re.sub(r'\s+', ' ', line.strip())
            if len(clean_line) > 10:
                line_counts[clean_line] = line_counts.get(clean_line, 0) + 1
        
        repeated_lines = sum(count - 1 for count in line_counts.values() if count > 3)
        if repeated_lines > len(lines) * 0.3:
            special_cases.append("Código muito repetitivo (possível auto-gerado)")
        
        # 5. VERSÕES ANTIGAS/OBSOLETAS
        if re.search(r'\bMQL4\b.*\b(build\s*[0-9]{3}|version\s*[0-4])', content, re.IGNORECASE):
            special_cases.append("Versão MQL4 muito antiga")
        
        # Funções depreciadas
        deprecated_functions = [
            'WindowRedraw', 'GetLastError', 'MarketInfo', 'RefreshRates',
            'OrderSelect', 'OrdersTotal', 'OrderType', 'OrderLots'
        ]
        
        found_deprecated = [func for func in deprecated_functions 
                          if re.search(f'\\b{func}\\b', content, re.IGNORECASE)]
        
        if found_deprecated:
            special_cases.append(f"Funções depreciadas: {', '.join(found_deprecated[:3])}")
        
        # 6. ARQUIVOS DE TESTE/DESENVOLVIMENTO
        test_indicators = [
            r'\btest\b', r'\bdemo\b', r'\bsample\b', r'\bexample\b',
            r'\btmp\b', r'\btemp\b', r'\bdebug\b', r'\bdev\b'
        ]
        
        for pattern in test_indicators:
            if re.search(pattern, filename, re.IGNORECASE):
                special_cases.append(f"Arquivo de teste/desenvolvimento: {pattern}")
                break
        
        return special_cases
    
    def generate_metadata(self, analysis):
        """Gera metadados ricos em formato JSON"""
        metadata = {
            "file_info": {
                "original_name": analysis['file_name'],
                "suggested_name": analysis['suggested_name'],
                "file_size": analysis['file_size'],
                "file_hash": analysis['file_hash'],
                "language": analysis['language']
            },
            "classification": {
                "type": analysis['file_type'],
                "strategy": analysis['strategy'],
                "markets": analysis['market_analysis'],
                "timeframes": analysis['timeframe_analysis']
            },
            "ftmo_analysis": analysis['ftmo_compliance'],
            "code_quality": analysis['code_quality'],
            "risk_assessment": {
                "level": analysis['risk_assessment'],
                "factors": []
            },
            "organization": {
                "target_folder": analysis['target_folder'],
                "tags": analysis['tags']
            },
            "analysis_metadata": {
                "timestamp": analysis['analysis_timestamp'],
                "analyzer_version": "1.0",
                "confidence_score": self._calculate_confidence(analysis)
            }
        }
        
        return metadata
    
    def _calculate_confidence(self, analysis):
        """Calcula score de confiança da análise"""
        score = 0
        
        # Tipo detectado
        if analysis['file_type'] != 'Unknown':
            score += 25
        
        # Estratégia detectada
        if analysis['strategy'] != 'Custom':
            score += 25
        
        # Mercado detectado
        if analysis['market_analysis'] != ['Multi']:
            score += 25
        
        # Qualidade do código
        if analysis['code_quality']['quality_score'] >= 3:
            score += 25
        
        return min(score, 100)

# Função principal para teste
def test_analyzer():
    """Testa o analisador com o Iron Scalper EA"""
    base_path = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD"
    analyzer = TradingCodeAnalyzer(base_path)
    
    test_file = Path(base_path) / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "All_MQ4" / "1. Iron Scalper EA" / "Iron Scalper EA.mq4"
    
    if test_file.exists():
        print("🔍 ANÁLISE DE QUALIDADE MÁXIMA - IRON SCALPER EA")
        print("=" * 60)
        
        analysis = analyzer.analyze_file(test_file)
        metadata = analyzer.generate_metadata(analysis)
        
        print(f"📁 Arquivo: {analysis['file_name']}")
        print(f"🏷️  Tipo: {analysis['file_type']}")
        print(f"📈 Estratégia: {analysis['strategy']}")
        print(f"💰 Mercados: {', '.join(analysis['market_analysis'])}")
        print(f"⏰ Timeframes: {', '.join(analysis['timeframe_analysis'])}")
        print(f"✅ FTMO Compliance: {analysis['ftmo_compliance']['level']} (Score: {analysis['ftmo_compliance']['score']}/7)")
        print(f"📊 Qualidade: {analysis['code_quality']['quality_level']} (Score: {analysis['code_quality']['quality_score']}/5)")
        print(f"⚠️  Risco: {analysis['risk_assessment']}")
        print(f"📝 Nome Sugerido: {analysis['suggested_name']}")
        print(f"📂 Pasta Destino: {analysis['target_folder']}")
        print(f"🏷️  Tags: {', '.join(analysis['tags'])}")
        print(f"🎯 Confiança: {metadata['analysis_metadata']['confidence_score']}%")
        
        # Salvar metadados
        metadata_file = Path(base_path) / "test_iron_scalper_metadata.json"
        with open(metadata_file, 'w', encoding='utf-8') as f:
            json.dump(metadata, f, indent=2, ensure_ascii=False)
        
        print(f"\n💾 Metadados salvos em: {metadata_file}")
        
        return analysis, metadata
    else:
        print(f"❌ Arquivo não encontrado: {test_file}")
        return None, None

if __name__ == "__main__":
    test_analyzer()