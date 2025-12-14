#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🧠 TESTE AVANÇADO DE INTELIGÊNCIA - Classificador Trading

Testa a capacidade de autocorreção e validação do algoritmo
com 5 arquivos diferentes para avaliar:
- Detecção automática de erros
- Autocorreção de inconsistências
- Validação de metadados
- Classificação inteligente
- Robustez do sistema

Autor: Classificador_Tradingkb
Versão: 2.0 - Inteligência Avançada
Data: 2025-01-12
"""

import os
import sys
import json
import hashlib
import re
import chardet
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple, Optional, Any
import logging
from sistema_avaliacao_ftmo_rigoroso import AvaliadorFTMORigoroso

class TesteInteligenciaAvancado:
    """Teste avançado para avaliar inteligência do algoritmo"""
    
    def __init__(self):
        self.setup_paths()
        self.setup_logging()
        
        # Inicializar avaliador FTMO rigoroso
        self.avaliador_ftmo = AvaliadorFTMORigoroso()
        
        self.resultados = {
            'timestamp': datetime.now().strftime('%Y%m%d_%H%M%S'),
            'arquivos_processados': 0,
            'erros_detectados': 0,
            'autocorrecoes_aplicadas': 0,
            'inconsistencias_resolvidas': 0,
            'validacoes_executadas': 0,
            'score_inteligencia': 0.0,
            'detalhes_arquivos': [],
            'metricas_qualidade': {},
            'sugestoes_melhorias': []
        }
        
        # Padrões para detecção inteligente
        self.padroes_estrategia = {
            'Scalping': [
                r'scalp', r'M1', r'M5', r'quick', r'fast', r'rapid',
                r'1\s*min', r'5\s*min', r'short\s*term'
            ],
            'Grid_Martingale': [
                r'grid', r'martingale', r'recovery', r'double\s*down',
                r'lot\s*multiply', r'averaging', r'hedge'
            ],
            'Trend_Following': [
                r'trend', r'momentum', r'\bMA\b', r'moving\s*average',
                r'direction', r'follow', r'breakout'
            ],
            'SMC_ICT': [
                r'order\s*block', r'liquidity', r'institutional',
                r'smart\s*money', r'ICT', r'supply\s*demand'
            ],
            'Volume_Analysis': [
                r'volume', r'OBV', r'flow', r'accumulation',
                r'distribution', r'tick\s*volume'
            ]
        }
        
        # Sistema de avaliação FTMO ultra rigoroso integrado
        # (Configurações movidas para AvaliadorFTMORigoroso)
        pass
    
    def setup_paths(self):
        """Configura caminhos do projeto"""
        self.base_path = Path(r'C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\Teste_Critico')
        self.input_path = self.base_path / 'Input'
        self.output_path = self.base_path / 'Output'
        self.metadata_path = self.base_path / 'Metadata'
        self.reports_path = self.base_path / 'Reports'
        
        # Criar diretórios se não existirem
        for path in [self.output_path, self.metadata_path, self.reports_path]:
            path.mkdir(parents=True, exist_ok=True)
    
    def setup_logging(self):
        """Configura sistema de logging"""
        log_file = self.reports_path / f'teste_inteligencia_{datetime.now().strftime("%Y%m%d_%H%M%S")}.log'
        
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_file, encoding='utf-8'),
                logging.StreamHandler(sys.stdout)
            ]
        )
        self.logger = logging.getLogger(__name__)
    
    def detectar_encoding(self, file_path: Path) -> Tuple[str, float]:
        """Detecta encoding do arquivo com alta precisão"""
        try:
            with open(file_path, 'rb') as f:
                raw_data = f.read()
            
            result = chardet.detect(raw_data)
            encoding = result.get('encoding', 'utf-8')
            confidence = result.get('confidence', 0.0)
            
            # Validação adicional para encodings comuns
            if confidence < 0.7:
                for test_encoding in ['utf-8', 'cp1252', 'iso-8859-1', 'ascii']:
                    try:
                        raw_data.decode(test_encoding)
                        return test_encoding, 0.9
                    except UnicodeDecodeError:
                        continue
            
            return encoding, confidence
        except Exception as e:
            self.logger.warning(f"Erro na detecção de encoding para {file_path}: {e}")
            return 'utf-8', 0.5
    
    def corrigir_encoding(self, file_path: Path) -> bool:
        """Corrige encoding do arquivo se necessário"""
        encoding, confidence = self.detectar_encoding(file_path)
        
        if confidence < 0.8 or encoding.lower() not in ['utf-8', 'ascii']:
            try:
                # Ler com encoding detectado
                with open(file_path, 'r', encoding=encoding, errors='ignore') as f:
                    content = f.read()
                
                # Reescrever em UTF-8
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                self.resultados['autocorrecoes_aplicadas'] += 1
                self.logger.info(f"✅ Encoding corrigido: {file_path.name} ({encoding} → UTF-8)")
                return True
            except Exception as e:
                self.logger.error(f"❌ Erro ao corrigir encoding de {file_path.name}: {e}")
                return False
        
        return False
    
    def analisar_arquivo_completo(self, file_path: Path) -> Dict[str, Any]:
        """Análise completa e inteligente do arquivo"""
        try:
            # Correção automática de encoding
            encoding_corrigido = self.corrigir_encoding(file_path)
            
            # Ler conteúdo
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            # Análise básica
            analise = {
                'nome_arquivo': file_path.name,
                'tamanho_bytes': file_path.stat().st_size,
                'linhas_codigo': len(content.splitlines()),
                'hash_md5': hashlib.md5(content.encode('utf-8')).hexdigest(),
                'encoding_corrigido': encoding_corrigido,
                'data_modificacao': datetime.fromtimestamp(file_path.stat().st_mtime).isoformat()
            }
            
            # Detecção inteligente de tipo
            tipo_detectado = self.detectar_tipo_inteligente(content)
            analise['tipo'] = tipo_detectado
            
            # Detecção de estratégia com autocorreção
            estrategia_detectada = self.detectar_estrategia_inteligente(content, file_path.name)
            analise['estrategia'] = estrategia_detectada
            
            # Análise FTMO rigorosa
            ftmo_score, ftmo_detalhes = self.analisar_ftmo_rigoroso(content, file_path.name, estrategia_detectada)
            analise['ftmo_score'] = ftmo_score
            analise['ftmo_detalhes'] = ftmo_detalhes
            analise['ftmo_status'] = self.classificar_ftmo_status(ftmo_score)
            
            # Detecção de mercado e timeframe
            mercado, timeframe = self.detectar_mercado_timeframe(content, file_path.name)
            analise['mercado'] = mercado
            analise['timeframe'] = timeframe
            
            # Validações de integridade
            validacoes = self.executar_validacoes_integridade(content, analise)
            analise['validacoes'] = validacoes
            
            # Sugestões de melhorias
            sugestoes = self.gerar_sugestoes_melhorias(content, analise)
            analise['sugestoes_melhorias'] = sugestoes
            
            self.resultados['validacoes_executadas'] += len(validacoes)
            
            return analise
            
        except Exception as e:
            self.logger.error(f"❌ Erro na análise de {file_path.name}: {e}")
            self.resultados['erros_detectados'] += 1
            return {'erro': str(e), 'nome_arquivo': file_path.name}
    
    def detectar_tipo_inteligente(self, content: str) -> str:
        """Detecção inteligente do tipo de arquivo"""
        content_lower = content.lower()
        
        # Padrões específicos para cada tipo
        if re.search(r'ontick\s*\(', content_lower) and re.search(r'ordersend|trade\.(buy|sell)', content_lower):
            return 'EA'
        elif re.search(r'oncalculate\s*\(|setindexbuffer', content_lower):
            return 'Indicator'
        elif re.search(r'onstart\s*\(', content_lower) and not re.search(r'ontick|oncalculate', content_lower):
            return 'Script'
        elif re.search(r'study\s*\(|strategy\s*\(|indicator\s*\(', content_lower):
            return 'Pine_Script'
        else:
            # Análise secundária baseada em funções
            if re.search(r'(buy|sell)\s*order|position\s*(open|close)', content_lower):
                return 'EA'
            elif re.search(r'indicator|buffer|plot', content_lower):
                return 'Indicator'
            else:
                return 'Unknown'
    
    def detectar_estrategia_inteligente(self, content: str, filename: str) -> str:
        """Detecção inteligente de estratégia com autocorreção"""
        content_lower = content.lower()
        filename_lower = filename.lower()
        
        scores = {}
        
        # Análise por padrões no conteúdo
        for estrategia, patterns in self.padroes_estrategia.items():
            score = 0
            for pattern in patterns:
                matches_content = len(re.findall(pattern, content_lower))
                matches_filename = len(re.findall(pattern, filename_lower))
                score += matches_content + (matches_filename * 2)  # Nome do arquivo tem peso maior
            scores[estrategia] = score
        
        # Autocorreção baseada em contexto
        if scores['Grid_Martingale'] > 0 and scores['Scalping'] > 0:
            # Conflito detectado - analisar contexto
            if re.search(r'(M1|M5|scalp)', content_lower) and not re.search(r'(grid|martingale)', content_lower):
                scores['Grid_Martingale'] = 0  # Remover falso positivo
        
        # Retornar estratégia com maior score
        if max(scores.values()) > 0:
            estrategia_detectada = max(scores, key=scores.get)
            
            # Validação adicional
            if estrategia_detectada == 'Grid_Martingale':
                if not re.search(r'(grid|martingale|recovery)', content_lower):
                    estrategia_detectada = 'Trend_Following'  # Autocorreção
                    self.resultados['inconsistencias_resolvidas'] += 1
            
            return estrategia_detectada
        
        return 'Unknown'
    
    def analisar_ftmo_rigoroso(self, content: str, filename: str = '', estrategia: str = '') -> Tuple[float, Dict[str, Any]]:
        """Análise FTMO ultra rigorosa usando o novo sistema"""
        # Usar o novo avaliador FTMO rigoroso
        analise_rigorosa = self.avaliador_ftmo.analisar_ftmo_ultra_rigoroso(content, filename, estrategia)
        
        # Converter para formato compatível
        criterios = analise_rigorosa.get('criterios_atendidos', {})
        
        detalhes = {
            'stop_loss': criterios.get('stop_loss_obrigatorio', False),
            'take_profit': criterios.get('take_profit', False),
            'risk_management': criterios.get('risk_management', False),
            'drawdown_protection': criterios.get('max_drawdown_protection', False),
            'session_filter': criterios.get('session_filter', False),
            'news_filter': criterios.get('news_filter', False),
            'eliminatorio': analise_rigorosa.get('eliminatorio', False),
            'penalidades_aplicadas': analise_rigorosa.get('penalidades_aplicadas', {}),
            'riscos_detectados': analise_rigorosa.get('riscos_detectados', []),
            'observacoes': analise_rigorosa.get('observacoes', []),
            'componentes_uteis': analise_rigorosa.get('componentes_uteis', []),
            'snippets_detectados': analise_rigorosa.get('snippets_detectados', [])
        }
        
        score_final = analise_rigorosa.get('score_final', 0.0)
        
        return score_final, detalhes
    
    def classificar_ftmo_status(self, score: float) -> str:
        """Classifica status FTMO baseado no score ultra rigoroso"""
        if score >= 9.0:
            return "FTMO_ELITE"
        elif score >= 7.5:
            return "FTMO_READY"
        elif score >= 6.0:
            return "FTMO_CONDICIONAL"
        elif score >= 4.0:
            return "ALTO_RISCO"
        elif score >= 2.0:
            return "INADEQUADO"
        else:
            return "PROIBIDO_FTMO"
    
    def detectar_mercado_timeframe(self, content: str, filename: str) -> Tuple[str, str]:
        """Detecta mercado e timeframe com inteligência"""
        content_lower = content.lower()
        filename_lower = filename.lower()
        
        # Detecção de mercado
        mercados = {
            'XAUUSD': [r'xauusd', r'gold', r'ouro'],
            'EURUSD': [r'eurusd', r'eur.*usd'],
            'GBPUSD': [r'gbpusd', r'gbp.*usd'],
            'USDJPY': [r'usdjpy', r'usd.*jpy'],
            'Forex': [r'forex', r'fx', r'currency'],
            'Indices': [r'nas100', r'spx500', r'dax', r'index'],
            'Crypto': [r'btc', r'bitcoin', r'crypto', r'eth']
        }
        
        mercado_detectado = 'Multi'
        for mercado, patterns in mercados.items():
            for pattern in patterns:
                if re.search(pattern, content_lower) or re.search(pattern, filename_lower):
                    mercado_detectado = mercado
                    break
            if mercado_detectado != 'Multi':
                break
        
        # Detecção de timeframe
        timeframes = {
            'M1': [r'\bm1\b', r'1\s*min', r'period_m1'],
            'M5': [r'\bm5\b', r'5\s*min', r'period_m5'],
            'M15': [r'\bm15\b', r'15\s*min', r'period_m15'],
            'H1': [r'\bh1\b', r'1\s*hour', r'period_h1'],
            'H4': [r'\bh4\b', r'4\s*hour', r'period_h4'],
            'D1': [r'\bd1\b', r'daily', r'period_d1']
        }
        
        timeframe_detectado = 'Multi'
        for tf, patterns in timeframes.items():
            for pattern in patterns:
                if re.search(pattern, content_lower):
                    timeframe_detectado = tf
                    break
            if timeframe_detectado != 'Multi':
                break
        
        return mercado_detectado, timeframe_detectado
    
    def executar_validacoes_integridade(self, content: str, analise: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Executa validações de integridade do arquivo"""
        validacoes = []
        
        # Validação 1: Consistência de tipo
        if analise['tipo'] == 'EA' and 'ontick' not in content.lower():
            validacoes.append({
                'tipo': 'inconsistencia_tipo',
                'status': 'warning',
                'mensagem': 'EA sem função OnTick detectada'
            })
        
        # Validação 2: FTMO Score vs Estratégia
        if analise.get('estrategia') == 'Grid_Martingale' and analise.get('ftmo_score', 0) > 3.0:
            validacoes.append({
                'tipo': 'inconsistencia_ftmo',
                'status': 'error',
                'mensagem': 'Grid/Martingale com FTMO score alto - revisar'
            })
        
        # Validação 3: Tamanho do arquivo
        if analise.get('tamanho_bytes', 0) < 1000:
            validacoes.append({
                'tipo': 'arquivo_pequeno',
                'status': 'warning',
                'mensagem': 'Arquivo muito pequeno - pode estar incompleto'
            })
        
        # Validação 4: Linhas de código
        if analise.get('linhas_codigo', 0) < 50:
            validacoes.append({
                'tipo': 'codigo_limitado',
                'status': 'info',
                'mensagem': 'Poucas linhas de código - verificar complexidade'
            })
        
        return validacoes
    
    def gerar_sugestoes_melhorias(self, content: str, analise: Dict[str, Any]) -> List[str]:
        """Gera sugestões inteligentes de melhorias"""
        sugestoes = []
        
        # Sugestões baseadas no FTMO score
        if analise.get('ftmo_score', 0) < 4.0:
            if not analise.get('ftmo_detalhes', {}).get('stop_loss', False):
                sugestoes.append('Implementar Stop Loss obrigatório')
            if not analise.get('ftmo_detalhes', {}).get('risk_management', False):
                sugestoes.append('Adicionar gestão de risco adequada')
            if not analise.get('ftmo_detalhes', {}).get('drawdown_protection', False):
                sugestoes.append('Implementar proteção de drawdown')
        
        # Sugestões baseadas no tipo
        if analise.get('tipo') == 'EA':
            if 'grid' in content.lower() or 'martingale' in content.lower():
                sugestoes.append('Considerar estratégia menos arriscada para FTMO')
        
        # Sugestões baseadas na estratégia
        if analise.get('estrategia') == 'Unknown':
            sugestoes.append('Definir estratégia mais claramente no código')
        
        return sugestoes
    
    def gerar_metadados_otimizados(self, analise: Dict[str, Any]) -> Dict[str, Any]:
        """Gera metadados otimizados com validações"""
        timestamp = datetime.now().isoformat()
        
        # Tags inteligentes
        tags = [f"#{analise.get('tipo', 'Unknown')}"]
        
        if analise.get('estrategia') != 'Unknown':
            tags.append(f"#{analise['estrategia']}")
        
        if analise.get('mercado') != 'Multi':
            tags.append(f"#{analise['mercado']}")
        
        if analise.get('timeframe') != 'Multi':
            tags.append(f"#{analise['timeframe']}")
        
        tags.append(f"#{analise.get('ftmo_status', 'Não_Adequado')}")
        
        # Metadados completos
        metadata = {
            'arquivo': {
                'nome': analise['nome_arquivo'],
                'tipo': analise.get('tipo', 'Unknown'),
                'estrategia': analise.get('estrategia', 'Unknown'),
                'mercado': analise.get('mercado', 'Multi'),
                'timeframe': analise.get('timeframe', 'Multi'),
                'tamanho_bytes': analise.get('tamanho_bytes', 0),
                'linhas_codigo': analise.get('linhas_codigo', 0),
                'hash_md5': analise.get('hash_md5', ''),
                'data_modificacao': analise.get('data_modificacao', '')
            },
            'ftmo': {
                'score': analise.get('ftmo_score', 0.0),
                'status': analise.get('ftmo_status', 'Não_Adequado'),
                'detalhes': analise.get('ftmo_detalhes', {}),
                'ftmo_ready': analise.get('ftmo_score', 0) >= 6.0
            },
            'qualidade': {
                'encoding_corrigido': analise.get('encoding_corrigido', False),
                'validacoes': analise.get('validacoes', []),
                'sugestoes_melhorias': analise.get('sugestoes_melhorias', [])
            },
            'componentes_uteis': analise.get('ftmo_detalhes', {}).get('componentes_uteis', []),
            'snippets_detectados': analise.get('ftmo_detalhes', {}).get('snippets_detectados', []),
            'tags': tags,
            'analise': {
                'timestamp': timestamp,
                'versao_algoritmo': '3.0',
                'inteligencia_aplicada': True,
                'extração_snippets': len(analise.get('ftmo_detalhes', {}).get('snippets_detectados', [])) > 0
            }
        }
        
        return metadata
    
    def calcular_score_inteligencia(self) -> float:
        """Calcula score de inteligência do algoritmo"""
        if self.resultados['arquivos_processados'] == 0:
            return 0.0
        
        # Métricas de qualidade
        taxa_sucesso = (self.resultados['arquivos_processados'] - self.resultados['erros_detectados']) / self.resultados['arquivos_processados']
        taxa_autocorrecao = self.resultados['autocorrecoes_aplicadas'] / max(1, self.resultados['arquivos_processados'])
        taxa_resolucao = self.resultados['inconsistencias_resolvidas'] / max(1, self.resultados['arquivos_processados'])
        
        # Score ponderado
        score = (taxa_sucesso * 0.4) + (taxa_autocorrecao * 0.3) + (taxa_resolucao * 0.3)
        
        return min(10.0, score * 10.0)
    
    def executar_teste_completo(self) -> Dict[str, Any]:
        """Executa teste completo de inteligência"""
        self.logger.info("🧠 INICIANDO TESTE AVANÇADO DE INTELIGÊNCIA")
        self.logger.info("=" * 60)
        
        # Processar todos os arquivos
        arquivos = list(self.input_path.glob('*.mq4'))
        
        for arquivo in arquivos:
            self.logger.info(f"📁 Processando: {arquivo.name}")
            
            analise = self.analisar_arquivo_completo(arquivo)
            
            if 'erro' not in analise:
                # Gerar metadados
                metadata = self.gerar_metadados_otimizados(analise)
                
                # Salvar metadados
                metadata_file = self.metadata_path / f"{arquivo.stem}.meta.json"
                with open(metadata_file, 'w', encoding='utf-8') as f:
                    json.dump(metadata, f, indent=2, ensure_ascii=False)
                
                self.resultados['detalhes_arquivos'].append(analise)
                self.resultados['arquivos_processados'] += 1
                
                self.logger.info(f"✅ Processado com sucesso: {arquivo.name}")
            else:
                self.logger.error(f"❌ Erro no processamento: {arquivo.name}")
        
        # Calcular métricas finais
        self.resultados['score_inteligencia'] = self.calcular_score_inteligencia()
        
        # Gerar relatório final
        relatorio_file = self.reports_path / f'teste_inteligencia_avancado_{self.resultados["timestamp"]}.json'
        with open(relatorio_file, 'w', encoding='utf-8') as f:
            json.dump(self.resultados, f, indent=2, ensure_ascii=False)
        
        self.logger.info("=" * 60)
        self.logger.info(f"🎯 TESTE CONCLUÍDO - Score de Inteligência: {self.resultados['score_inteligencia']:.2f}/10.0")
        self.logger.info(f"📊 Arquivos processados: {self.resultados['arquivos_processados']}")
        self.logger.info(f"🔧 Autocorreções aplicadas: {self.resultados['autocorrecoes_aplicadas']}")
        self.logger.info(f"⚡ Inconsistências resolvidas: {self.resultados['inconsistencias_resolvidas']}")
        self.logger.info(f"📋 Relatório salvo: {relatorio_file}")
        
        return self.resultados

if __name__ == '__main__':
    teste = TesteInteligenciaAvancado()
    resultados = teste.executar_teste_completo()
    
    print(f"\n🎯 RESULTADO FINAL:")
    print(f"Score de Inteligência: {resultados['score_inteligencia']:.2f}/10.0")
    print(f"Arquivos processados: {resultados['arquivos_processados']}")
    print(f"Autocorreções: {resultados['autocorrecoes_aplicadas']}")
    print(f"Inconsistências resolvidas: {resultados['inconsistencias_resolvidas']}")