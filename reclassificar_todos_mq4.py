#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para Reclassificação Completa de Arquivos MQ4
Classificador_Trading - Correção Abrangente
"""

import os
import re
import json
import shutil
from pathlib import Path
from datetime import datetime

class ClassificadorMQ4:
    def __init__(self, base_path):
        self.base_path = Path(base_path)
        self.unclassified_path = self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "Unclassified"
        self.mql4_source = self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source"
        self.metadata_path = self.base_path / "CODIGO_FONTE_LIBRARY" / "MQL4_Source" / "Metadata"
        
        # Contadores
        self.stats = {
            'total_processados': 0,
            'eas_ftmo_ready': 0,
            'eas_trend': 0,
            'eas_scalping': 0,
            'eas_grid': 0,
            'indicators': 0,
            'scripts': 0,
            'misc': 0,
            'erros': 0
        }
        
        self.relatorio = []
        
    def analisar_codigo(self, filepath):
        """Analisa o código MQ4 para determinar tipo e estratégia"""
        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read().lower()
        except:
            try:
                with open(filepath, 'r', encoding='latin-1', errors='ignore') as f:
                    content = f.read().lower()
            except:
                return None
                
        analise = {
            'tipo': 'Unknown',
            'estrategia': [],
            'mercado': 'MULTI',
            'timeframe': 'MULTI',
            'ftmo_score': 0.0,
            'ftmo_ready': False,
            'funcoes_principais': [],
            'tem_sl': False,
            'tem_tp': False,
            'tem_risk_mgmt': False,
            'tem_grid': False,
            'tem_martingale': False
        }
        
        # Determinar tipo
        if 'ontick()' in content and ('ordersend(' in content or 'trade.buy' in content or 'trade.sell' in content):
            analise['tipo'] = 'EA'
        elif 'oncalculate()' in content or 'setindexbuffer(' in content or 'setindexstyle(' in content:
            analise['tipo'] = 'Indicator'
        elif 'onstart()' in content and 'ontick()' not in content:
            analise['tipo'] = 'Script'
        else:
            # Análise por nome e conteúdo
            filename = os.path.basename(filepath).lower()
            if any(word in filename for word in ['ea', 'expert', 'robot', 'bot']):
                analise['tipo'] = 'EA'
            elif any(word in filename for word in ['indicator', 'ind', 'arrow', 'signal']):
                analise['tipo'] = 'Indicator'
            else:
                analise['tipo'] = 'EA'  # Default para EA
        
        # Detectar estratégias
        estrategias = []
        
        # Scalping
        if any(word in content for word in ['scalp', 'm1', 'm5', 'minute', 'quick', 'fast']):
            estrategias.append('Scalping')
            
        # Grid/Martingale
        if any(word in content for word in ['grid', 'martingale', 'recovery', 'hedge', 'averaging']):
            estrategias.append('Grid_Martingale')
            analise['tem_grid'] = True
            analise['tem_martingale'] = True
            
        # Trend Following
        if any(word in content for word in ['trend', 'ma', 'moving average', 'ema', 'sma', 'momentum']):
            estrategias.append('Trend_Following')
            
        # SMC/ICT
        if any(word in content for word in ['order block', 'liquidity', 'institutional', 'smc', 'ict']):
            estrategias.append('SMC_ICT')
            
        # Volume Analysis
        if any(word in content for word in ['volume', 'obv', 'flow', 'tick']):
            estrategias.append('Volume_Analysis')
            
        # News Trading
        if any(word in content for word in ['news', 'event', 'calendar']):
            estrategias.append('News_Trading')
            
        if not estrategias:
            estrategias = ['Trend_Following']  # Default
            
        analise['estrategia'] = estrategias
        
        # Detectar mercado
        mercados = []
        if any(word in content for word in ['eurusd', 'eur/usd', 'eur_usd']):
            mercados.append('EURUSD')
        if any(word in content for word in ['gbpusd', 'gbp/usd', 'gbp_usd']):
            mercados.append('GBPUSD')
        if any(word in content for word in ['xauusd', 'gold', 'xau/usd', 'xau_usd']):
            mercados.append('XAUUSD')
        if any(word in content for word in ['usdjpy', 'usd/jpy', 'usd_jpy']):
            mercados.append('USDJPY')
        if any(word in content for word in ['nas100', 'nasdaq', 'us100']):
            mercados.append('NAS100')
            
        analise['mercado'] = mercados[0] if mercados else 'MULTI'
        
        # Detectar timeframe
        timeframes = []
        if any(word in content for word in ['period_m1', 'm1', '1 min']):
            timeframes.append('M1')
        if any(word in content for word in ['period_m5', 'm5', '5 min']):
            timeframes.append('M5')
        if any(word in content for word in ['period_m15', 'm15', '15 min']):
            timeframes.append('M15')
        if any(word in content for word in ['period_h1', 'h1', '1 hour']):
            timeframes.append('H1')
        if any(word in content for word in ['period_h4', 'h4', '4 hour']):
            timeframes.append('H4')
        if any(word in content for word in ['period_d1', 'd1', 'daily']):
            timeframes.append('D1')
            
        analise['timeframe'] = timeframes[0] if timeframes else 'MULTI'
        
        # Análise FTMO
        analise['tem_sl'] = any(word in content for word in ['stoploss', 'sl', 'stop_loss'])
        analise['tem_tp'] = any(word in content for word in ['takeprofit', 'tp', 'take_profit'])
        analise['tem_risk_mgmt'] = any(word in content for word in ['risk', 'drawdown', 'equity', 'balance'])
        
        # Calcular FTMO Score
        score = 0.0
        
        if analise['tem_sl']:
            score += 2.5
        if analise['tem_tp']:
            score += 1.5
        if analise['tem_risk_mgmt']:
            score += 2.0
        if not analise['tem_grid'] and not analise['tem_martingale']:
            score += 2.0
        if 'Scalping' in estrategias and analise['tem_sl']:
            score += 1.0
        if 'Trend_Following' in estrategias:
            score += 1.0
            
        analise['ftmo_score'] = min(score, 10.0)
        analise['ftmo_ready'] = score >= 6.0
        
        return analise
    
    def gerar_nome_arquivo(self, original_name, analise):
        """Gera nome padronizado para o arquivo"""
        # Remove extensão
        base_name = os.path.splitext(original_name)[0]
        
        # Limpa caracteres especiais
        base_name = re.sub(r'[^a-zA-Z0-9_\-]', '_', base_name)
        base_name = re.sub(r'_+', '_', base_name).strip('_')
        
        # Prefixo baseado no tipo
        if analise['tipo'] == 'EA':
            prefix = 'EA'
        elif analise['tipo'] == 'Indicator':
            prefix = 'IND'
        elif analise['tipo'] == 'Script':
            prefix = 'SCR'
        else:
            prefix = 'UNK'
            
        # Versão
        version = 'v1.0'
        
        # Mercado
        mercado = analise['mercado']
        
        return f"{prefix}_{base_name}_{version}_{mercado}.mq4"
    
    def determinar_pasta_destino(self, analise):
        """Determina a pasta de destino baseada na análise"""
        tipo = analise['tipo']
        estrategias = analise['estrategia']
        
        if tipo == 'EA':
            if analise['ftmo_ready']:
                return self.mql4_source / "EAs" / "FTMO_Ready"
            elif 'Scalping' in estrategias:
                return self.mql4_source / "EAs" / "Scalping"
            elif 'Grid_Martingale' in estrategias:
                return self.mql4_source / "EAs" / "Grid_Martingale"
            elif 'Trend_Following' in estrategias:
                return self.mql4_source / "EAs" / "Trend_Following"
            elif 'News_Trading' in estrategias:
                return self.mql4_source / "EAs" / "News_Trading"
            else:
                return self.mql4_source / "EAs" / "Misc"
                
        elif tipo == 'Indicator':
            if 'SMC_ICT' in estrategias:
                return self.mql4_source / "Indicators" / "SMC_ICT"
            elif 'Volume_Analysis' in estrategias:
                return self.mql4_source / "Indicators" / "Volume"
            elif 'Trend_Following' in estrategias:
                return self.mql4_source / "Indicators" / "Trend"
            else:
                return self.mql4_source / "Indicators" / "Custom"
                
        elif tipo == 'Script':
            return self.mql4_source / "Scripts" / "Utilities"
            
        else:
            return self.mql4_source / "Misc"
    
    def criar_metadados(self, arquivo_path, analise, novo_nome):
        """Cria arquivo de metadados"""
        metadata = {
            "file_info": {
                "original_name": os.path.basename(arquivo_path),
                "new_name": novo_nome,
                "file_size": os.path.getsize(arquivo_path),
                "created_date": datetime.now().isoformat(),
                "file_type": "MQL4",
                "classification_version": "2.0"
            },
            "classification": {
                "type": analise['tipo'],
                "strategy": analise['estrategia'],
                "market": analise['mercado'],
                "timeframe": analise['timeframe'],
                "complexity": "Medium"
            },
            "ftmo_analysis": {
                "score": analise['ftmo_score'],
                "level": "Adequado" if analise['ftmo_ready'] else "Não_Adequado",
                "ready": analise['ftmo_ready'],
                "has_stop_loss": analise['tem_sl'],
                "has_take_profit": analise['tem_tp'],
                "has_risk_management": analise['tem_risk_mgmt'],
                "has_grid_martingale": analise['tem_grid'] or analise['tem_martingale']
            },
            "tags": self.gerar_tags(analise),
            "quality_metrics": {
                "code_quality": "Medium",
                "documentation": "Basic",
                "testing_status": "Pending"
            }
        }
        
        # Salvar metadados
        meta_filename = os.path.splitext(novo_nome)[0] + ".meta.json"
        meta_path = self.metadata_path / meta_filename
        
        with open(meta_path, 'w', encoding='utf-8') as f:
            json.dump(metadata, f, indent=2, ensure_ascii=False)
            
        return meta_path
    
    def gerar_tags(self, analise):
        """Gera tags baseadas na análise"""
        tags = []
        
        # Tipo
        tags.append(f"#{analise['tipo']}")
        
        # Estratégias
        for estrategia in analise['estrategia']:
            tags.append(f"#{estrategia}")
            
        # Mercado
        tags.append(f"#{analise['mercado']}")
        
        # Timeframe
        tags.append(f"#{analise['timeframe']}")
        
        # FTMO
        if analise['ftmo_ready']:
            tags.append("#FTMO_Ready")
            tags.append("#LowRisk")
        else:
            tags.append("#Nao_FTMO")
            
        if analise['tem_grid'] or analise['tem_martingale']:
            tags.append("#HighRisk")
            
        return tags
    
    def processar_arquivo(self, arquivo_path):
        """Processa um único arquivo MQ4"""
        try:
            print(f"Processando: {os.path.basename(arquivo_path)}")
            
            # Analisar código
            analise = self.analisar_codigo(arquivo_path)
            if not analise:
                self.stats['erros'] += 1
                return False
                
            # Gerar novo nome
            novo_nome = self.gerar_nome_arquivo(os.path.basename(arquivo_path), analise)
            
            # Determinar pasta destino
            pasta_destino = self.determinar_pasta_destino(analise)
            pasta_destino.mkdir(parents=True, exist_ok=True)
            
            # Caminho final
            caminho_final = pasta_destino / novo_nome
            
            # Resolver conflitos de nome
            contador = 1
            while caminho_final.exists():
                base, ext = os.path.splitext(novo_nome)
                novo_nome_temp = f"{base}_{contador}{ext}"
                caminho_final = pasta_destino / novo_nome_temp
                contador += 1
                
            # Copiar arquivo
            shutil.copy2(arquivo_path, caminho_final)
            
            # Criar metadados
            self.criar_metadados(arquivo_path, analise, caminho_final.name)
            
            # Atualizar estatísticas
            self.stats['total_processados'] += 1
            
            if analise['tipo'] == 'EA':
                if analise['ftmo_ready']:
                    self.stats['eas_ftmo_ready'] += 1
                if 'Trend_Following' in analise['estrategia']:
                    self.stats['eas_trend'] += 1
                if 'Scalping' in analise['estrategia']:
                    self.stats['eas_scalping'] += 1
                if 'Grid_Martingale' in analise['estrategia']:
                    self.stats['eas_grid'] += 1
            elif analise['tipo'] == 'Indicator':
                self.stats['indicators'] += 1
            elif analise['tipo'] == 'Script':
                self.stats['scripts'] += 1
            else:
                self.stats['misc'] += 1
                
            # Adicionar ao relatório
            self.relatorio.append({
                'original': os.path.basename(arquivo_path),
                'novo': caminho_final.name,
                'tipo': analise['tipo'],
                'estrategia': ', '.join(analise['estrategia']),
                'ftmo_score': analise['ftmo_score'],
                'ftmo_ready': analise['ftmo_ready'],
                'pasta': str(pasta_destino.relative_to(self.mql4_source))
            })
            
            print(f"✓ {os.path.basename(arquivo_path)} → {caminho_final.name} (Score: {analise['ftmo_score']:.1f})")
            return True
            
        except Exception as e:
            print(f"✗ Erro ao processar {os.path.basename(arquivo_path)}: {e}")
            self.stats['erros'] += 1
            return False
    
    def processar_todos(self):
        """Processa todos os arquivos na pasta Unclassified"""
        print("=== INICIANDO RECLASSIFICAÇÃO COMPLETA ===")
        print(f"Pasta origem: {self.unclassified_path}")
        
        # Listar todos os arquivos .mq4
        arquivos_mq4 = list(self.unclassified_path.glob("*.mq4"))
        print(f"Total de arquivos encontrados: {len(arquivos_mq4)}")
        
        if not arquivos_mq4:
            print("Nenhum arquivo .mq4 encontrado na pasta Unclassified")
            return
            
        # Processar cada arquivo
        for arquivo in arquivos_mq4:
            self.processar_arquivo(arquivo)
            
        # Gerar relatório final
        self.gerar_relatorio_final()
        
    def gerar_relatorio_final(self):
        """Gera relatório final da reclassificação"""
        print("\n=== RELATÓRIO FINAL DA RECLASSIFICAÇÃO ===")
        print(f"Total processados: {self.stats['total_processados']}")
        print(f"EAs FTMO Ready: {self.stats['eas_ftmo_ready']}")
        print(f"EAs Trend Following: {self.stats['eas_trend']}")
        print(f"EAs Scalping: {self.stats['eas_scalping']}")
        print(f"EAs Grid/Martingale: {self.stats['eas_grid']}")
        print(f"Indicadores: {self.stats['indicators']}")
        print(f"Scripts: {self.stats['scripts']}")
        print(f"Misc: {self.stats['misc']}")
        print(f"Erros: {self.stats['erros']}")
        
        # Top 10 FTMO Ready
        ftmo_ready = [item for item in self.relatorio if item['ftmo_ready']]
        ftmo_ready.sort(key=lambda x: x['ftmo_score'], reverse=True)
        
        print("\n=== TOP 10 EAs FTMO READY ===")
        for i, item in enumerate(ftmo_ready[:10], 1):
            print(f"{i:2d}. {item['novo']} (Score: {item['ftmo_score']:.1f}) - {item['estrategia']}")
            
        # Salvar relatório detalhado
        relatorio_path = self.base_path / "RELATORIO_RECLASSIFICACAO_COMPLETA.json"
        with open(relatorio_path, 'w', encoding='utf-8') as f:
            json.dump({
                'timestamp': datetime.now().isoformat(),
                'estatisticas': self.stats,
                'arquivos_processados': self.relatorio
            }, f, indent=2, ensure_ascii=False)
            
        print(f"\nRelatório detalhado salvo em: {relatorio_path}")

def main():
    base_path = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD"
    
    classificador = ClassificadorMQ4(base_path)
    classificador.processar_todos()
    
    print("\n=== RECLASSIFICAÇÃO CONCLUÍDA ===")
    print("Verifique as pastas de destino e os metadados gerados.")

if __name__ == "__main__":
    main()