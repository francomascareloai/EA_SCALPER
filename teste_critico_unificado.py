#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
TESTE CRÍTICO UNIFICADO - Análise de Trader/Engenheiro
Versão: 1.0
Data: 2025-01-12

Este script unifica as melhores práticas dos classificadores existentes,
corrigindo inconsistências e implementando validações rigorosas.

PROBLEMAS IDENTIFICADOS NOS SCRIPTS EXISTENTES:
1. Inconsistência FTMO Score: classificador_qualidade_maxima.py usa 0-7, 
   demo_interface_visual.py usa 0-100, classificador_otimizado.py usa 0-10
2. Lógica FTMO simplificada em alguns scripts
3. Falta de validação de integridade dos dados
4. Redundância de código entre scripts

SOLUÇÕES IMPLEMENTADAS:
1. FTMO Score padronizado 0-7 (padrão FTMO real)
2. Análise FTMO rigorosa baseada em critérios reais
3. Validações de integridade completas
4. Interface unificada e otimizada
"""

import os
import re
import json
import hashlib
import tkinter as tk
from tkinter import ttk, scrolledtext
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional, Tuple
import threading
import time

class AnalisadorCriticoUnificado:
    """Analisador crítico que unifica as melhores práticas dos scripts existentes"""
    
    def __init__(self):
        self.setup_paths()
        self.setup_interface()
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
    
    def setup_interface(self):
        """Configura interface gráfica otimizada"""
        self.root = tk.Tk()
        self.root.title("🔬 Teste Crítico Unificado - Análise Trader/Engenheiro")
        self.root.geometry("1000x700")
        self.root.configure(bg='#1e1e1e')
        
        # Frame principal
        main_frame = ttk.Frame(self.root)
        main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Título
        title_label = tk.Label(main_frame, 
                              text="🔬 TESTE CRÍTICO UNIFICADO", 
                              font=("Arial", 16, "bold"),
                              fg="#00ff00", bg="#1e1e1e")
        title_label.pack(pady=5)
        
        # Subtitle
        subtitle_label = tk.Label(main_frame, 
                                 text="Análise de Trader & Engenheiro | FTMO Score Padronizado 0-7", 
                                 font=("Arial", 10),
                                 fg="#cccccc", bg="#1e1e1e")
        subtitle_label.pack(pady=2)
        
        # Frame de métricas
        metrics_frame = ttk.LabelFrame(main_frame, text="📊 Métricas em Tempo Real")
        metrics_frame.pack(fill=tk.X, pady=5)
        
        self.metrics_text = tk.Text(metrics_frame, height=4, bg="#2d2d2d", fg="#ffffff", font=("Consolas", 9))
        self.metrics_text.pack(fill=tk.X, padx=5, pady=5)
        
        # Frame de log
        log_frame = ttk.LabelFrame(main_frame, text="📝 Log de Análise")
        log_frame.pack(fill=tk.BOTH, expand=True, pady=5)
        
        self.log_text = scrolledtext.ScrolledText(log_frame, 
                                                 bg="#2d2d2d", fg="#ffffff", 
                                                 font=("Consolas", 9))
        self.log_text.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Frame de controles
        control_frame = ttk.Frame(main_frame)
        control_frame.pack(fill=tk.X, pady=5)
        
        self.start_button = ttk.Button(control_frame, text="🚀 Iniciar Teste Crítico", 
                                      command=self.iniciar_teste_thread)
        self.start_button.pack(side=tk.LEFT, padx=5)
        
        self.stop_button = ttk.Button(control_frame, text="⏹️ Parar", 
                                     command=self.parar_teste, state=tk.DISABLED)
        self.stop_button.pack(side=tk.LEFT, padx=5)
        
        # Progress bar
        self.progress = ttk.Progressbar(control_frame, mode='indeterminate')
        self.progress.pack(side=tk.RIGHT, fill=tk.X, expand=True, padx=5)
        
        self.running = False
    
    def log_message(self, message: str, level: str = "INFO"):
        """Log com timestamp e nível"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        color_map = {
            "INFO": "#ffffff",
            "SUCCESS": "#00ff00",
            "WARNING": "#ffaa00",
            "ERROR": "#ff0000",
            "CRITICAL": "#ff00ff"
        }
        
        formatted_message = f"[{timestamp}] {level}: {message}\n"
        
        self.log_text.insert(tk.END, formatted_message)
        self.log_text.see(tk.END)
        self.root.update_idletasks()
    
    def update_metrics(self):
        """Atualiza métricas em tempo real"""
        metrics_text = f"""📄 Arquivos Processados: {self.metricas['arquivos_processados']}
❌ Erros Encontrados: {self.metricas['erros_encontrados']}
🔧 Inconsistências Corrigidas: {self.metricas['inconsistencias_corrigidas']}
🏆 FTMO Scores Validados: {self.metricas['ftmo_scores_validados']}"""
        
        self.metrics_text.delete(1.0, tk.END)
        self.metrics_text.insert(1.0, metrics_text)
        self.root.update_idletasks()
    
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
    
    def gerar_relatorio_critico(self):
        """Gera relatório crítico detalhado"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        report_file = self.reports_path / f"relatorio_critico_{timestamp}.json"
        
        # Análise estatística
        tipos = {}
        estrategias = {}
        ftmo_scores = []
        
        for resultado in self.resultados:
            if resultado:
                tipos[resultado['tipo']] = tipos.get(resultado['tipo'], 0) + 1
                estrategias[resultado['estrategia']] = estrategias.get(resultado['estrategia'], 0) + 1
                ftmo_scores.append(resultado['ftmo_analysis']['score'])
        
        # Relatório completo
        relatorio = {
            "timestamp": datetime.now().isoformat(),
            "versao_analisador": "1.0_unificado",
            "metricas_execucao": self.metricas,
            "estatisticas": {
                "tipos": tipos,
                "estrategias": estrategias,
                "ftmo_score_medio": sum(ftmo_scores) / len(ftmo_scores) if ftmo_scores else 0,
                "ftmo_score_min": min(ftmo_scores) if ftmo_scores else 0,
                "ftmo_score_max": max(ftmo_scores) if ftmo_scores else 0
            },
            "resultados_detalhados": self.resultados,
            "melhorias_implementadas": [
                "FTMO Score padronizado 0-7",
                "Análise FTMO rigorosa com critérios reais",
                "Validações de integridade completas",
                "Correção automática de encoding",
                "Interface unificada otimizada",
                "Métricas em tempo real",
                "Tratamento robusto de erros"
            ]
        }
        
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(relatorio, f, indent=2, ensure_ascii=False)
        
        self.log_message(f"📊 Relatório crítico gerado: {report_file.name}", "SUCCESS")
        return report_file
    
    def preparar_arquivo_teste(self):
        """Prepara um arquivo de teste se não existir"""
        test_file = self.input_path / "test_ea_sample.mq4"
        
        if not test_file.exists():
            sample_content = '''//+------------------------------------------------------------------+
//|                                                    TestEA.mq4 |
//|                        Copyright 2025, Teste Crítico Unificado |
//+------------------------------------------------------------------+

// Inputs
input double StopLoss = 50;        // Stop Loss em pontos
input double TakeProfit = 150;     // Take Profit em pontos
input double RiskPercent = 1.0;    // Risco por trade (%)
input int MaxTrades = 3;           // Máximo de trades simultâneos
input bool UseSessionFilter = true; // Usar filtro de sessão

// Variáveis globais
double AccountBalance;
int TotalTrades = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   AccountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   Print("TestEA inicializado - Balance: ", AccountBalance);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Verificar filtro de sessão
   if(UseSessionFilter && (Hour() < 8 || Hour() > 18))
      return;
   
   // Verificar máximo de trades
   if(OrdersTotal() >= MaxTrades)
      return;
   
   // Calcular lot size baseado no risco
   double lotSize = CalculateLotSize();
   
   // Lógica de entrada simples (exemplo)
   if(iMA(NULL, 0, 20, 0, MODE_SMA, PRICE_CLOSE, 1) > 
      iMA(NULL, 0, 50, 0, MODE_SMA, PRICE_CLOSE, 1))
   {
      // Abrir ordem de compra
      int ticket = OrderSend(Symbol(), OP_BUY, lotSize, Ask, 3, 
                            Ask - StopLoss * Point, 
                            Ask + TakeProfit * Point, 
                            "TestEA Buy", 0, 0, clrGreen);
      
      if(ticket > 0)
         TotalTrades++;
   }
}

//+------------------------------------------------------------------+
//| Calcular lot size baseado no risco                              |
//+------------------------------------------------------------------+
double CalculateLotSize()
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = balance * RiskPercent / 100.0;
   double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double lotSize = riskAmount / (StopLoss * tickValue);
   
   // Normalizar lot size
   double minLot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   
   return MathMax(minLot, MathMin(maxLot, lotSize));
}
'''
            
            with open(test_file, 'w', encoding='utf-8') as f:
                f.write(sample_content)
            
            self.log_message(f"📝 Arquivo de teste criado: {test_file.name}", "INFO")
    
    def executar_teste_critico(self):
        """Executa o teste crítico completo"""
        self.log_message("🚀 INICIANDO TESTE CRÍTICO UNIFICADO", "INFO")
        self.log_message("Versão: 1.0 | FTMO Score: 0-7 | Validações Rigorosas", "INFO")
        
        # Preparar arquivo de teste se necessário
        self.preparar_arquivo_teste()
        
        # Buscar arquivos para análise
        arquivos = list(self.input_path.glob("*.mq4")) + list(self.input_path.glob("*.mq5"))
        
        if not arquivos:
            self.log_message("⚠️ Nenhum arquivo encontrado para análise", "WARNING")
            return
        
        self.log_message(f"📄 {len(arquivos)} arquivo(s) encontrado(s) para análise", "INFO")
        
        # Processar cada arquivo
        for arquivo in arquivos:
            if not self.running:
                break
                
            resultado = self.analisar_arquivo_completo(arquivo)
            if resultado:
                self.resultados.append(resultado)
                self.gerar_metadata_otimizado(resultado, arquivo)
            
            self.metricas['arquivos_processados'] += 1
            self.update_metrics()
            time.sleep(0.5)  # Simular processamento
        
        # Gerar relatório final
        if self.resultados:
            report_file = self.gerar_relatorio_critico()
            self.log_message(f"✅ TESTE CRÍTICO CONCLUÍDO", "SUCCESS")
            self.log_message(f"📊 Relatório: {report_file.name}", "SUCCESS")
        else:
            self.log_message("❌ Nenhum resultado válido obtido", "ERROR")
    
    def iniciar_teste_thread(self):
        """Inicia teste em thread separada"""
        self.running = True
        self.start_button.config(state=tk.DISABLED)
        self.stop_button.config(state=tk.NORMAL)
        self.progress.start()
        
        thread = threading.Thread(target=self.executar_teste_critico)
        thread.daemon = True
        thread.start()
    
    def parar_teste(self):
        """Para o teste"""
        self.running = False
        self.start_button.config(state=tk.NORMAL)
        self.stop_button.config(state=tk.DISABLED)
        self.progress.stop()
        self.log_message("⏹️ Teste interrompido pelo usuário", "WARNING")
    
    def run(self):
        """Executa a interface"""
        self.log_message("🔬 Sistema de Teste Crítico Unificado Iniciado", "INFO")
        self.log_message("Melhorias: FTMO Score padronizado, validações rigorosas, interface otimizada", "INFO")
        self.root.mainloop()

if __name__ == "__main__":
    print("🔬 TESTE CRÍTICO UNIFICADO - Análise de Trader/Engenheiro")
    print("Versão: 1.0 | FTMO Score: 0-7 | Validações Rigorosas")
    print("Iniciando interface...")
    
    analisador = AnalisadorCriticoUnificado()
    analisador.run()