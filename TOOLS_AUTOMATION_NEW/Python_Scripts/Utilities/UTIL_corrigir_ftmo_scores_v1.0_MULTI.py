#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
CORRETOR DE SCORES FTMO - ClassificadorTrading
Corrige todos os metadados com o sistema FTMO rigoroso correto

Autor: ClassificadorTrading
Data: 13/08/2025
Versão: 2.0 - Busca Inteligente
"""

import json
import re
from pathlib import Path
from typing import Dict, List, Any
import logging
from datetime import datetime
import time

class FTMOScoreCorrector:
    """Corretor de Scores FTMO com algoritmo rigoroso"""
    
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.logger = self._setup_logger()
        
        # Cache de arquivos para busca rápida
        self.file_cache = {}
        self._build_file_cache()
        
        # Estatísticas
        self.stats = {
            'total_metadata': 0,
            'corrected_metadata': 0,
            'errors': 0,
            'ftmo_ready_before': 0,
            'ftmo_ready_after': 0,
            'score_improvements': 0,
            'score_reductions': 0,
            'files_not_found': 0
        }
        
    def _setup_logger(self) -> logging.Logger:
        """Configura logging"""
        logger = logging.getLogger('FTMOScoreCorrector')
        logger.setLevel(logging.INFO)
        
        if not logger.handlers:
            handler = logging.StreamHandler()
            formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
            )
            handler.setFormatter(formatter)
            logger.addHandler(handler)
            
        return logger
    
    def _build_file_cache(self):
        """Constrói cache de arquivos para busca rápida"""
        self.logger.info("🔍 Construindo cache de arquivos...")
        
        # Buscar todos os arquivos .mq4 na estrutura organizada
        mql4_source = self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source"
        
        if mql4_source.exists():
            for mq4_file in mql4_source.rglob("*.mq4"):
                file_name = mq4_file.name
                self.file_cache[file_name] = mq4_file
        
        self.logger.info(f"📁 Cache construído: {len(self.file_cache)} arquivos encontrados")
    
    def _find_original_file(self, metadata: Dict[str, Any]) -> Path:
        """Encontra o arquivo original usando busca inteligente"""
        # Tentar obter nome do arquivo dos metadados
        file_name = None
        
        # Método 1: file_info.name
        if 'file_info' in metadata and 'name' in metadata['file_info']:
            file_name = metadata['file_info']['name']
        
        # Método 2: file_info.original_name
        elif 'file_info' in metadata and 'original_name' in metadata['file_info']:
            file_name = metadata['file_info']['original_name']
        
        # Método 3: extrair do caminho original
        elif 'file_info' in metadata and 'original_path' in metadata['file_info']:
            original_path = metadata['file_info']['original_path']
            file_name = Path(original_path).name
        
        # Método 4: usar chave do arquivo de metadados
        if not file_name:
            # Se o arquivo de metadados é "EA_Gold_v1.0_GOLD.meta.json"
            # O arquivo original seria "EA_Gold_v1.0_GOLD.mq4"
            return None
        
        # Buscar no cache
        if file_name in self.file_cache:
            return self.file_cache[file_name]
        
        # Busca alternativa: remover extensão e tentar variações
        base_name = Path(file_name).stem
        for cached_name, cached_path in self.file_cache.items():
            if Path(cached_name).stem == base_name:
                return cached_path
        
        return None
    
    def _analyze_ftmo_compliance_rigoroso(self, content: str) -> Dict[str, Any]:
        """Análise rigorosa de compliance FTMO com critérios detalhados (SISTEMA CORRETO)"""
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
        
        # Grid/Martingale (-3 pontos) - ELIMINATÓRIO
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
            'score': round(final_score, 1),
            'level': ftmo_level,
            'compliance_score': round(final_score * 10, 1)  # Para compatibilidade
        }
    
    def correct_metadata_file(self, metadata_path: Path) -> bool:
        """Corrige um arquivo de metadados específico"""
        try:
            # Ler metadados atuais
            with open(metadata_path, 'r', encoding='utf-8') as f:
                metadata = json.load(f)
            
            # Encontrar arquivo original
            original_file = self._find_original_file(metadata)
            
            if not original_file or not original_file.exists():
                self.stats['files_not_found'] += 1
                return False
            
            # Ler conteúdo do arquivo original
            with open(original_file, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            # Analisar FTMO com algoritmo correto
            old_ftmo = metadata.get('ftmo_analysis', {})
            old_score = old_ftmo.get('score', 0)
            old_compliance_score = old_ftmo.get('compliance_score', 0)
            
            new_ftmo_analysis = self._analyze_ftmo_compliance_rigoroso(content)
            new_score = new_ftmo_analysis.get('score', 0)
            
            # Atualizar metadados
            metadata['ftmo_analysis'] = new_ftmo_analysis
            
            # Atualizar classification se existir
            if 'classification' in metadata:
                metadata['classification']['ftmo_ready'] = new_ftmo_analysis['is_ftmo_ready']
            
            # Atualizar timestamp
            if 'analysis_metadata' not in metadata:
                metadata['analysis_metadata'] = {}
            
            metadata['analysis_metadata']['timestamp'] = datetime.now().isoformat()
            metadata['analysis_metadata']['corrected_by'] = 'FTMOScoreCorrector_v2.0'
            metadata['analysis_metadata']['correction_reason'] = 'Sistema FTMO Rigoroso Ultra Crítico'
            
            # Salvar metadados corrigidos
            with open(metadata_path, 'w', encoding='utf-8') as f:
                json.dump(metadata, f, indent=2, ensure_ascii=False)
            
            # Atualizar estatísticas
            if old_score != new_score or old_compliance_score != new_ftmo_analysis.get('compliance_score', 0):
                self.stats['corrected_metadata'] += 1
                if new_score > old_score:
                    self.stats['score_improvements'] += 1
                else:
                    self.stats['score_reductions'] += 1
            
            if old_ftmo.get('is_ftmo_ready', False):
                self.stats['ftmo_ready_before'] += 1
            if new_ftmo_analysis['is_ftmo_ready']:
                self.stats['ftmo_ready_after'] += 1
            
            self.logger.info(f"✅ Corrigido: {metadata_path.name} | Score: {old_score} → {new_score}")
            return True
            
        except Exception as e:
            self.logger.error(f"❌ Erro ao corrigir {metadata_path}: {e}")
            self.stats['errors'] += 1
            return False
    
    def correct_all_metadata(self) -> Dict[str, Any]:
        """Corrige todos os arquivos de metadados"""
        self.logger.info("🔧 INICIANDO CORREÇÃO DE SCORES FTMO v2.0")
        self.logger.info("=" * 60)
        
        start_time = time.time()
        
        # Encontrar todos os arquivos .meta.json
        metadata_files = list(self.base_path.rglob("*.meta.json"))
        self.stats['total_metadata'] = len(metadata_files)
        
        self.logger.info(f"📁 Total de metadados encontrados: {len(metadata_files)}")
        
        if not metadata_files:
            self.logger.warning("❌ Nenhum arquivo de metadados encontrado!")
            return self.stats
        
        # Processar em lotes
        batch_size = 50
        for i in range(0, len(metadata_files), batch_size):
            batch_num = (i // batch_size) + 1
            batch_files = metadata_files[i:i + batch_size]
            
            self.logger.info(f"\n📦 PROCESSANDO LOTE {batch_num} ({len(batch_files)} arquivos)")
            
            for j, metadata_file in enumerate(batch_files, 1):
                if j % 10 == 0 or j == len(batch_files):
                    progress = (j / len(batch_files)) * 100
                    self.logger.info(f"  📈 Progresso: {progress:.1f}% ({j}/{len(batch_files)})")
                
                self.correct_metadata_file(metadata_file)
            
            # Pausa entre lotes
            if i + batch_size < len(metadata_files):
                time.sleep(0.5)
        
        # Finalizar
        processing_time = time.time() - start_time
        self._generate_correction_report(processing_time)
        
        self.logger.info("\n✅ CORREÇÃO DE SCORES FTMO CONCLUÍDA!")
        return self.stats
    
    def _generate_correction_report(self, processing_time: float):
        """Gera relatório de correção"""
        report = {
            'correction_summary': {
                'timestamp': datetime.now().isoformat(),
                'processing_time_seconds': round(processing_time, 2),
                'total_metadata_files': self.stats['total_metadata'],
                'corrected_files': self.stats['corrected_metadata'],
                'files_not_found': self.stats['files_not_found'],
                'errors': self.stats['errors'],
                'success_rate': round((self.stats['corrected_metadata'] / self.stats['total_metadata']) * 100, 2) if self.stats['total_metadata'] > 0 else 0
            },
            'ftmo_analysis': {
                'ftmo_ready_before': self.stats['ftmo_ready_before'],
                'ftmo_ready_after': self.stats['ftmo_ready_after'],
                'improvement': self.stats['ftmo_ready_after'] - self.stats['ftmo_ready_before'],
                'score_improvements': self.stats['score_improvements'],
                'score_reductions': self.stats['score_reductions']
            },
            'algorithm_used': 'Sistema FTMO Rigoroso v3.0 - Ultra Crítico',
            'criteria': {
                'stop_loss': '0-2 pontos (obrigatório)',
                'risk_management': '0-2 pontos',
                'drawdown_protection': '0-1.5 pontos',
                'take_profit': '0-1 ponto',
                'session_filters': '0-0.5 pontos',
                'penalties': {
                    'grid_martingale': '-3 pontos (eliminatório)',
                    'hedging': '-1 ponto',
                    'no_trade_limit': '-0.5 pontos',
                    'news_without_filter': '-0.5 pontos'
                }
            }
        }
        
        # Salvar relatório
        report_path = self.base_path / "Reports" / f"correcao_ftmo_scores_v2_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        report_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        
        self.logger.info(f"📊 Relatório salvo em: {report_path}")
        
        # Log do resumo
        self.logger.info("\n📊 RESUMO DA CORREÇÃO:")
        self.logger.info(f"  📁 Total de metadados: {self.stats['total_metadata']}")
        self.logger.info(f"  ✅ Arquivos corrigidos: {self.stats['corrected_metadata']}")
        self.logger.info(f"  🔍 Arquivos não encontrados: {self.stats['files_not_found']}")
        self.logger.info(f"  ❌ Erros: {self.stats['errors']}")
        self.logger.info(f"  🏆 FTMO Ready antes: {self.stats['ftmo_ready_before']}")
        self.logger.info(f"  🏆 FTMO Ready depois: {self.stats['ftmo_ready_after']}")
        self.logger.info(f"  📈 Melhoria: {self.stats['ftmo_ready_after'] - self.stats['ftmo_ready_before']}")
        self.logger.info(f"  ⏱️ Tempo: {processing_time:.2f}s")

def main():
    """Função principal"""
    base_path = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD"
    
    corrector = FTMOScoreCorrector(base_path)
    results = corrector.correct_all_metadata()
    
    print("\n🎯 CORREÇÃO CONCLUÍDA COM SUCESSO!")
    print(f"📊 Metadados corrigidos: {results['corrected_metadata']}/{results['total_metadata']}")
    print(f"🏆 FTMO Ready: {results['ftmo_ready_before']} → {results['ftmo_ready_after']}")
    print(f"🔍 Arquivos não encontrados: {results['files_not_found']}")

if __name__ == "__main__":
    main()