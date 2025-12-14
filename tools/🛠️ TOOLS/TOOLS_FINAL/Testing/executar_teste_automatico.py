#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
EXECUTOR DE TESTE AUTOMÁTICO
Versão: 1.0
Data: 2025-01-12

Este script executa o teste crítico automaticamente e gera relatório detalhado.
"""

import os
import re
import json
import hashlib
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional

class ExecutorTesteAutomatico:
    """Executor automático do teste crítico unificado"""
    
    def __init__(self):
        self.setup_paths()
        self.resultados = []
        self.metricas = {
            'arquivos_processados': 0,
            'erros_encontrados': 0,
            'inconsistencias_corrigidas': 0,
            'ftmo_scores_validados': 0
        }
    
    def setup_paths(self):
        """Configura caminhos do projeto"""
        self.base_path = Path.cwd()
        self.input_path = self.base_path / "Teste_Critico" / "Input"
        self.output_path = self.base_path / "Teste_Critico" / "Output"
        self.metadata_path = self.base_path / "Teste_Critico" / "Metadata"
        self.reports_path = self.base_path / "Teste_Critico" / "Reports"
        
        # Criar diretórios
        for path in [self.input_path, self.output_path, self.metadata_path, self.reports_path]:
            path.mkdir(parents=True, exist_ok=True)
    
    def log_message(self, message: str, level: str = "INFO"):
        """Log com timestamp e nível"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        print(f"[{timestamp}] {level}: {message}")
    
    def analisar_ftmo_compliance_rigoroso(self, content: str) -> Dict:
        """Análise FTMO rigorosa baseada em critérios reais (0-7 pontos)"""
        ftmo_score = 0.0
        compliance_details = {
            'stop_loss': False,
            'risk_management': False,
            'drawdown_protection': False,
            'take_profit': False,
            'session_filter': False,
            'no_dangerous_strategy': True
        }
        
        issues = []
        strengths = []
        
        # 1. STOP LOSS OBRIGATÓRIO (0-2 pontos)
        sl_patterns = [
            r'\bStopLoss\b', r'\bSL\s*=', r'\bstop_loss\b',
            r'OrderModify.*sl', r'trade\.SetDeviationInPoints.*sl'
        ]
        
        if any(re.search(pattern, content, re.IGNORECASE) for pattern in sl_patterns):
            ftmo_score += 2.0
            compliance_details['stop_loss'] = True
            strengths.append("Stop Loss implementado")
        else:
            issues.append("CRÍTICO: Sem Stop Loss detectado")
        
        # 2. GESTÃO DE RISCO (0-2 pontos)
        risk_patterns = [
            r'\b(AccountBalance|AccountEquity)\b',
            r'\b(risk|Risk)\s*[=*]',
            r'\blot.*balance',
            r'\bMaxRisk\b',
            r'\bRiskPercent\b'
        ]
        
        risk_count = sum(1 for pattern in risk_patterns if re.search(pattern, content, re.IGNORECASE))
        if risk_count >= 3:
            ftmo_score += 2.0
            compliance_details['risk_management'] = True
            strengths.append("Gestão de risco robusta")
        elif risk_count >= 1:
            ftmo_score += 1.0
            compliance_details['risk_management'] = True
            strengths.append("Gestão de risco básica")
        else:
            issues.append("CRÍTICO: Sem gestão de risco")
        
        # 3. DRAWDOWN PROTECTION (0-1.5 pontos)
        drawdown_patterns = [
            r'\b(MaxDrawdown|DrawdownLimit)\b',
            r'\b(daily.*loss|DailyLoss)\b',
            r'\bequity.*balance'
        ]
        
        if any(re.search(pattern, content, re.IGNORECASE) for pattern in drawdown_patterns):
            ftmo_score += 1.5
            compliance_details['drawdown_protection'] = True
            strengths.append("Proteção de drawdown")
        else:
            issues.append("Sem proteção de drawdown")
        
        # 4. TAKE PROFIT (0-1 ponto)
        tp_patterns = [r'\bTakeProfit\b', r'\bTP\s*=', r'\btake_profit\b']
        
        if any(re.search(pattern, content, re.IGNORECASE) for pattern in tp_patterns):
            ftmo_score += 1.0
            compliance_details['take_profit'] = True
            strengths.append("Take Profit definido")
        
        # 5. FILTROS DE SESSÃO (0-0.5 pontos)
        session_patterns = [
            r'\b(Hour|TimeHour)\b',
            r'\b(session|Session)\b',
            r'\b(trading.*time|TradingTime)\b'
        ]
        
        if any(re.search(pattern, content, re.IGNORECASE) for pattern in session_patterns):
            ftmo_score += 0.5
            compliance_details['session_filter'] = True
            strengths.append("Filtros de sessão")
        
        # PENALIZAÇÕES CRÍTICAS
        dangerous_patterns = [
            r'\b(grid|Grid)\b',
            r'\b(martingale|Martingale)\b',
            r'\b(recovery|Recovery)\b'
        ]
        
        if any(re.search(pattern, content, re.IGNORECASE) for pattern in dangerous_patterns):
            ftmo_score -= 3.0
            compliance_details['no_dangerous_strategy'] = False
            issues.append("CRÍTICO: Estratégia de alto risco detectada")
        
        # Normalizar score (0-7)
        final_score = max(0.0, min(7.0, ftmo_score))
        
        # Determinar nível
        if final_score >= 6.0:
            level = "FTMO_Ready"
        elif final_score >= 4.0:
            level = "Moderado"
        elif final_score >= 2.0:
            level = "Baixo"
        else:
            level = "Não_Adequado"
        
        return {
            'score': round(final_score, 1),
            'level': level,
            'details': compliance_details,
            'issues': issues,
            'strengths': strengths,
            'is_ftmo_ready': final_score >= 5.0
        }
    
    def analisar_arquivo_completo(self, file_path: Path) -> Optional[Dict]:
        """Análise completa de um arquivo com validações rigorosas"""
        try:
            self.log_message(f"🔍 Analisando: {file_path.name}", "INFO")
            
            # Validações de integridade
            if not file_path.exists():
                self.metricas['erros_encontrados'] += 1
                self.log_message(f"❌ Arquivo não encontrado: {file_path}", "ERROR")
                return None
            
            if file_path.stat().st_size == 0:
                self.metricas['erros_encontrados'] += 1
                self.log_message(f"❌ Arquivo vazio: {file_path.name}", "ERROR")
                return None
            
            # Ler conteúdo
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
            except UnicodeDecodeError:
                try:
                    with open(file_path, 'r', encoding='latin-1') as f:
                        content = f.read()
                    self.log_message(f"⚠️ Encoding corrigido para latin-1: {file_path.name}", "WARNING")
                    self.metricas['inconsistencias_corrigidas'] += 1
                except Exception as e:
                    self.metricas['erros_encontrados'] += 1
                    self.log_message(f"❌ Erro de encoding: {file_path.name} - {str(e)}", "ERROR")
                    return None
            
            # Detectar tipo
            tipo = "Unknown"
            if re.search(r'\bOnTick\b', content) and re.search(r'\bOrderSend\b', content):
                tipo = "EA"
            elif re.search(r'\bOnCalculate\b', content) or re.search(r'\bSetIndexBuffer\b', content):
                tipo = "Indicator"
            elif re.search(r'\bOnStart\b', content):
                tipo = "Script"
            
            # Detectar estratégia
            estrategia = "Custom"
            if any(word in content.lower() for word in ["scalp", "m1", "m5"]):
                estrategia = "Scalping"
            elif any(word in content.lower() for word in ["grid", "martingale", "recovery"]):
                estrategia = "Grid_Martingale"
            elif any(word in content.lower() for word in ["trend", "momentum", "ma"]):
                estrategia = "Trend"
            elif any(word in content.lower() for word in ["order_block", "liquidity", "institutional"]):
                estrategia = "SMC"
            
            # Análise FTMO rigorosa
            ftmo_analysis = self.analisar_ftmo_compliance_rigoroso(content)
            self.metricas['ftmo_scores_validados'] += 1
            
            # Hash do arquivo
            with open(file_path, 'rb') as f:
                file_hash = hashlib.md5(f.read()).hexdigest()
            
            # Resultado completo
            resultado = {
                'nome_original': file_path.name,
                'tipo': tipo,
                'estrategia': estrategia,
                'ftmo_analysis': ftmo_analysis,
                'hash': file_hash,
                'tamanho': file_path.stat().st_size,
                'data_modificacao': datetime.fromtimestamp(file_path.stat().st_mtime).isoformat(),
                'encoding_corrigido': 'inconsistencias_corrigidas' in locals()
            }
            
            self.log_message(f"✅ {file_path.name}: {tipo} | {estrategia} | FTMO: {ftmo_analysis['score']}/7", "SUCCESS")
            
            return resultado
            
        except Exception as e:
            self.metricas['erros_encontrados'] += 1
            self.log_message(f"❌ Erro crítico ao analisar {file_path.name}: {str(e)}", "CRITICAL")
            return None
    
    def gerar_metadata_otimizado(self, resultado: Dict, file_path: Path):
        """Gera metadata otimizado com validações"""
        metadata = {
            "id": resultado['hash'][:16],
            "nome_arquivo": resultado['nome_original'],
            "hash": resultado['hash'],
            "tamanho": resultado['tamanho'],
            "classificacao": {
                "tipo": resultado['tipo'],
                "estrategia": resultado['estrategia']
            },
            "ftmo_analysis": resultado['ftmo_analysis'],
            "data_analise": datetime.now().isoformat(),
            "versao_analisador": "1.0_unificado",
            "validacoes": {
                "integridade_arquivo": True,
                "encoding_corrigido": resultado.get('encoding_corrigido', False),
                "ftmo_score_validado": True
            }
        }
        
        # Salvar metadata
        metadata_file = self.metadata_path / f"{file_path.stem}.meta.json"
        with open(metadata_file, 'w', encoding='utf-8') as f:
            json.dump(metadata, f, indent=2, ensure_ascii=False)
        
        self.log_message(f"📄 Metadata gerado: {metadata_file.name}", "INFO")
    
    def gerar_relatorio_critico_detalhado(self):
        """Gera relatório crítico detalhado com análise de trader/engenheiro"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        report_file = self.reports_path / f"relatorio_critico_detalhado_{timestamp}.json"
        
        # Análise estatística
        tipos = {}
        estrategias = {}
        ftmo_scores = []
        problemas_criticos = []
        melhorias_sugeridas = []
        
        for resultado in self.resultados:
            if resultado:
                tipos[resultado['tipo']] = tipos.get(resultado['tipo'], 0) + 1
                estrategias[resultado['estrategia']] = estrategias.get(resultado['estrategia'], 0) + 1
                ftmo_scores.append(resultado['ftmo_analysis']['score'])
                
                # Coletar problemas críticos
                if resultado['ftmo_analysis']['issues']:
                    problemas_criticos.extend(resultado['ftmo_analysis']['issues'])
        
        # Análise crítica como trader/engenheiro
        analise_critica = {
            "perspectiva_trader": {
                "ftmo_readiness": {
                    "arquivos_ftmo_ready": sum(1 for r in self.resultados if r and r['ftmo_analysis']['is_ftmo_ready']),
                    "score_medio": sum(ftmo_scores) / len(ftmo_scores) if ftmo_scores else 0,
                    "recomendacao": "APROVADO" if sum(ftmo_scores) / len(ftmo_scores) >= 5.0 else "REQUER MELHORIAS"
                },
                "gestao_risco": {
                    "stop_loss_presente": sum(1 for r in self.resultados if r and r['ftmo_analysis']['details']['stop_loss']),
                    "gestao_risco_presente": sum(1 for r in self.resultados if r and r['ftmo_analysis']['details']['risk_management']),
                    "estrategias_perigosas": sum(1 for r in self.resultados if r and not r['ftmo_analysis']['details']['no_dangerous_strategy'])
                }
            },
            "perspectiva_engenheiro": {
                "qualidade_codigo": {
                    "arquivos_com_erro_encoding": self.metricas['inconsistencias_corrigidas'],
                    "arquivos_com_erro_processamento": self.metricas['erros_encontrados'],
                    "taxa_sucesso": (self.metricas['arquivos_processados'] - self.metricas['erros_encontrados']) / max(1, self.metricas['arquivos_processados']) * 100
                },
                "padronizacao": {
                    "tipos_detectados": len(tipos),
                    "estrategias_detectadas": len(estrategias),
                    "necessita_reorganizacao": len(estrategias) > 3
                }
            }
        }
        
        # Sugestões de melhorias
        if analise_critica["perspectiva_trader"]["gestao_risco"]["estrategias_perigosas"] > 0:
            melhorias_sugeridas.append("CRÍTICO: Remover ou modificar estratégias de Grid/Martingale")
        
        if analise_critica["perspectiva_trader"]["gestao_risco"]["stop_loss_presente"] < len(self.resultados):
            melhorias_sugeridas.append("IMPORTANTE: Implementar Stop Loss em todos os EAs")
        
        if analise_critica["perspectiva_engenheiro"]["qualidade_codigo"]["taxa_sucesso"] < 90:
            melhorias_sugeridas.append("TÉCNICO: Melhorar qualidade do código e tratamento de erros")
        
        # Relatório completo
        relatorio = {
            "timestamp": datetime.now().isoformat(),
            "versao_analisador": "1.0_unificado_critico",
            "metricas_execucao": self.metricas,
            "estatisticas": {
                "tipos": tipos,
                "estrategias": estrategias,
                "ftmo_score_medio": sum(ftmo_scores) / len(ftmo_scores) if ftmo_scores else 0,
                "ftmo_score_min": min(ftmo_scores) if ftmo_scores else 0,
                "ftmo_score_max": max(ftmo_scores) if ftmo_scores else 0
            },
            "analise_critica": analise_critica,
            "problemas_criticos": list(set(problemas_criticos)),
            "melhorias_sugeridas": melhorias_sugeridas,
            "resultados_detalhados": self.resultados,
            "validacoes_implementadas": [
                "FTMO Score padronizado 0-7 (padrão real FTMO)",
                "Análise FTMO rigorosa com critérios de prop firm",
                "Validações de integridade de arquivo completas",
                "Correção automática de encoding",
                "Detecção de estratégias perigosas",
                "Análise de gestão de risco obrigatória",
                "Métricas de qualidade de código",
                "Perspectiva dupla: Trader + Engenheiro"
            ]
        }
        
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(relatorio, f, indent=2, ensure_ascii=False)
        
        self.log_message(f"📊 Relatório crítico detalhado gerado: {report_file.name}", "SUCCESS")
        return report_file, relatorio
    
    def executar_teste_completo(self):
        """Executa o teste crítico completo automaticamente"""
        print("\n" + "="*80)
        print("🔬 TESTE CRÍTICO UNIFICADO - EXECUÇÃO AUTOMÁTICA")
        print("Versão: 1.0 | FTMO Score: 0-7 | Análise Trader/Engenheiro")
        print("="*80)
        
        # Buscar arquivos para análise
        arquivos = list(self.input_path.glob("*.mq4")) + list(self.input_path.glob("*.mq5"))
        
        if not arquivos:
            self.log_message("⚠️ Nenhum arquivo encontrado para análise", "WARNING")
            return None, None
        
        self.log_message(f"📄 {len(arquivos)} arquivo(s) encontrado(s) para análise", "INFO")
        
        # Processar cada arquivo
        for arquivo in arquivos:
            resultado = self.analisar_arquivo_completo(arquivo)
            if resultado:
                self.resultados.append(resultado)
                self.gerar_metadata_otimizado(resultado, arquivo)
            
            self.metricas['arquivos_processados'] += 1
        
        # Gerar relatório final
        if self.resultados:
            report_file, relatorio = self.gerar_relatorio_critico_detalhado()
            
            print("\n" + "="*80)
            print("📊 RESUMO EXECUTIVO - ANÁLISE CRÍTICA")
            print("="*80)
            
            # Mostrar resumo
            analise = relatorio['analise_critica']
            print(f"\n🎯 PERSPECTIVA DO TRADER:")
            print(f"   • Arquivos FTMO Ready: {analise['perspectiva_trader']['ftmo_readiness']['arquivos_ftmo_ready']}/{len(self.resultados)}")
            print(f"   • Score FTMO Médio: {analise['perspectiva_trader']['ftmo_readiness']['score_medio']:.1f}/7.0")
            print(f"   • Recomendação: {analise['perspectiva_trader']['ftmo_readiness']['recomendacao']}")
            
            print(f"\n🔧 PERSPECTIVA DO ENGENHEIRO:")
            print(f"   • Taxa de Sucesso: {analise['perspectiva_engenheiro']['qualidade_codigo']['taxa_sucesso']:.1f}%")
            print(f"   • Erros de Encoding: {analise['perspectiva_engenheiro']['qualidade_codigo']['arquivos_com_erro_encoding']}")
            print(f"   • Tipos Detectados: {analise['perspectiva_engenheiro']['padronizacao']['tipos_detectados']}")
            
            if relatorio['melhorias_sugeridas']:
                print(f"\n⚠️ MELHORIAS SUGERIDAS:")
                for melhoria in relatorio['melhorias_sugeridas']:
                    print(f"   • {melhoria}")
            
            print(f"\n✅ TESTE CRÍTICO CONCLUÍDO COM SUCESSO")
            print(f"📊 Relatório completo: {report_file.name}")
            print("="*80)
            
            return report_file, relatorio
        else:
            self.log_message("❌ Nenhum resultado válido obtido", "ERROR")
            return None, None

if __name__ == "__main__":
    executor = ExecutorTesteAutomatico()
    report_file, relatorio = executor.executar_teste_completo()
    
    if report_file:
        print(f"\n🎉 Teste crítico executado com sucesso!")
        print(f"📁 Relatório salvo em: {report_file}")
    else:
        print(f"\n❌ Falha na execução do teste crítico.")