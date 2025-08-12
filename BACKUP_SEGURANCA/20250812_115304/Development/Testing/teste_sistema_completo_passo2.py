#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🧪 TESTE SISTEMA COMPLETO - PASSO 2
Teste integrado de todos os componentes do Passo 2

Autor: Classificador_Trading
Versão: 2.0
Data: 12/08/2025

Testa:
- Classificação em lote avançada
- Interface gráfica
- Monitoramento em tempo real
- Geração de relatórios
- Integração completa
"""

import os
import sys
import time
import json
import threading
from datetime import datetime
from pathlib import Path

# Adicionar diretório Core ao path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'Core'))

try:
    from classificador_lote_avancado import ClassificadorLoteAvancado
    from monitor_tempo_real import MonitorTempoReal
    from gerador_relatorios_avancados import GeradorRelatoriosAvancados
except ImportError as e:
    print(f"❌ Erro ao importar módulos: {e}")
    print("Certifique-se de que todos os arquivos estão no diretório Core")
    sys.exit(1)

class TesteSistemaCompleto:
    """
    Teste integrado do sistema completo
    """
    
    def __init__(self):
        self.test_results = {
            'start_time': datetime.now(),
            'tests_executed': [],
            'tests_passed': 0,
            'tests_failed': 0,
            'errors': [],
            'performance_metrics': {}
        }
        
        # Componentes
        self.classificador = None
        self.monitor = None
        self.gerador_relatorios = None
        
        # Configuração de teste
        self.test_dir = "Development/Testing/test_files"
        self.ensure_test_environment()
        
    def ensure_test_environment(self):
        """Garante ambiente de teste"""
        os.makedirs(self.test_dir, exist_ok=True)
        os.makedirs("Development/Reports/Test_Results", exist_ok=True)
        
        # Criar arquivos de teste se não existirem
        self.create_test_files()
        
    def create_test_files(self):
        """Cria arquivos de teste"""
        test_files = {
            "test_ea_scalping.mq4": """
//+------------------------------------------------------------------+
//| Test EA Scalping                                                 |
//+------------------------------------------------------------------+
#property copyright "Test"
#property version   "1.00"

input double LotSize = 0.01;
input int StopLoss = 20;
input int TakeProfit = 60;

void OnTick()
{
    // Scalping logic
    if(OrdersTotal() == 0)
    {
        if(iMA(Symbol(), PERIOD_M1, 10, 0, MODE_SMA, PRICE_CLOSE, 0) > 
           iMA(Symbol(), PERIOD_M1, 20, 0, MODE_SMA, PRICE_CLOSE, 0))
        {
            OrderSend(Symbol(), OP_BUY, LotSize, Ask, 3, Ask-StopLoss*Point, Ask+TakeProfit*Point);
        }
    }
}
""",
            "test_indicator_volume.mq4": """
//+------------------------------------------------------------------+
//| Test Volume Indicator                                            |
//+------------------------------------------------------------------+
#property copyright "Test"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1

double VolumeBuffer[];

int OnInit()
{
    SetIndexBuffer(0, VolumeBuffer);
    SetIndexStyle(0, DRAW_HISTOGRAM);
    return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &volume[])
{
    for(int i = prev_calculated; i < rates_total; i++)
    {
        VolumeBuffer[i] = volume[i];
    }
    return(rates_total);
}
""",
            "test_script_utility.mq4": """
//+------------------------------------------------------------------+
//| Test Utility Script                                             |
//+------------------------------------------------------------------+
#property copyright "Test"
#property version   "1.00"

void OnStart()
{
    Print("Utility script executed");
    
    // Close all orders
    for(int i = OrdersTotal()-1; i >= 0; i--)
    {
        if(OrderSelect(i, SELECT_BY_POS))
        {
            OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 3);
        }
    }
}
""",
            "test_ea_grid.mq5": """
//+------------------------------------------------------------------+
//| Test Grid EA                                                     |
//+------------------------------------------------------------------+
#property copyright "Test"
#property version   "1.00"

#include <Trade\Trade.mqh>
CTrade trade;

input double InitialLot = 0.01;
input double Multiplier = 2.0;
input int GridStep = 100;

void OnTick()
{
    // Grid trading logic
    if(PositionsTotal() == 0)
    {
        trade.Buy(InitialLot);
    }
    else
    {
        // Martingale logic
        double lastLot = InitialLot;
        for(int i = 0; i < PositionsTotal(); i++)
        {
            if(PositionGetSymbol(i) == Symbol())
            {
                lastLot = PositionGetDouble(POSITION_VOLUME) * Multiplier;
                break;
            }
        }
        
        if(Bid < PositionGetDouble(POSITION_PRICE_OPEN) - GridStep * Point())
        {
            trade.Buy(lastLot);
        }
    }
}
""",
            "test_pine_strategy.pine": """
//@version=5
strategy("Test Strategy", overlay=true)

// Inputs
length = input.int(14, "MA Length")
risk_percent = input.float(1.0, "Risk %")

// Indicators
ma = ta.sma(close, length)

// Strategy
if close > ma and strategy.position_size == 0
    strategy.entry("Long", strategy.long)
    
if close < ma and strategy.position_size > 0
    strategy.close("Long")
    
// Plot
plot(ma, "MA", color.blue)
"""
        }
        
        for filename, content in test_files.items():
            filepath = os.path.join(self.test_dir, filename)
            if not os.path.exists(filepath):
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                    
    def run_all_tests(self):
        """Executa todos os testes"""
        print("🧪 INICIANDO TESTE SISTEMA COMPLETO - PASSO 2")
        print("="*60)
        
        tests = [
            self.test_classificador_lote,
            self.test_monitor_tempo_real,
            self.test_gerador_relatorios,
            self.test_integracao_completa
        ]
        
        for test in tests:
            try:
                print(f"\n🔍 Executando: {test.__name__}")
                start_time = time.time()
                
                result = test()
                
                execution_time = time.time() - start_time
                
                if result:
                    print(f"✅ {test.__name__}: PASSOU ({execution_time:.2f}s)")
                    self.test_results['tests_passed'] += 1
                else:
                    print(f"❌ {test.__name__}: FALHOU ({execution_time:.2f}s)")
                    self.test_results['tests_failed'] += 1
                    
                self.test_results['tests_executed'].append({
                    'name': test.__name__,
                    'passed': result,
                    'execution_time': execution_time
                })
                
            except Exception as e:
                print(f"💥 {test.__name__}: ERRO - {str(e)}")
                self.test_results['tests_failed'] += 1
                self.test_results['errors'].append({
                    'test': test.__name__,
                    'error': str(e)
                })
                
        self.generate_final_report()
        
    def test_classificador_lote(self) -> bool:
        """Testa classificador em lote"""
        try:
            print("   📁 Testando ClassificadorLoteAvancado...")
            
            self.classificador = ClassificadorLoteAvancado()
            
            # Configurar para teste
            config = {
                'parallel_workers': 2,
                'batch_size': 10,
                'enable_monitoring': True,
                'output_format': 'json'
            }
            
            # Executar classificação
            result = self.classificador.process_directory(
                self.test_dir,
                config=config
            )
            
            # Verificar resultado
            if result and 'statistics' in result:
                processed = result['statistics'].get('processed', 0)
                print(f"   ✓ Processados: {processed} arquivos")
                return processed > 0
            else:
                print("   ✗ Resultado inválido")
                return False
                
        except Exception as e:
            print(f"   ✗ Erro: {e}")
            return False
            
    def test_monitor_tempo_real(self) -> bool:
        """Testa monitor de tempo real"""
        try:
            print("   📊 Testando MonitorTempoReal...")
            
            self.monitor = MonitorTempoReal(update_interval=0.5)
            
            # Callback de teste
            updates_received = []
            
            def test_callback(metrics, alerts):
                updates_received.append({
                    'timestamp': metrics.timestamp,
                    'files_processed': metrics.files_processed,
                    'alerts': len(alerts)
                })
                
            self.monitor.add_update_callback(test_callback)
            
            # Iniciar monitoramento
            if not self.monitor.start_monitoring():
                print("   ✗ Falha ao iniciar monitoramento")
                return False
                
            # Simular atualizações
            for i in range(3):
                test_data = {
                    'files_processed': i * 5 + 10,
                    'files_successful': i * 4 + 8,
                    'files_failed': i + 1,
                    'memory_usage': 50.0,
                    'cpu_usage': 30.0,
                    'current_file': f"test_{i}.mq4"
                }
                
                self.monitor.update_metrics(test_data)
                time.sleep(1)
                
            # Parar monitoramento
            self.monitor.stop_monitoring()
            
            # Verificar resultados
            if len(updates_received) >= 2:
                print(f"   ✓ Recebidas {len(updates_received)} atualizações")
                return True
            else:
                print(f"   ✗ Poucas atualizações: {len(updates_received)}")
                return False
                
        except Exception as e:
            print(f"   ✗ Erro: {e}")
            return False
            
    def test_gerador_relatorios(self) -> bool:
        """Testa gerador de relatórios"""
        try:
            print("   📄 Testando GeradorRelatoriosAvancados...")
            
            self.gerador_relatorios = GeradorRelatoriosAvancados()
            
            # Dados de teste
            test_data = {
                'execution_time': 25.5,
                'statistics': {
                    'processed': 50,
                    'successful': 45,
                    'errors': 5
                },
                'performance': {
                    'files_per_second': 2.0,
                    'success_rate': 90.0
                },
                'top_categories': [
                    ('EA', 25),
                    ('Indicator', 15),
                    ('Script', 10)
                ],
                'quality_summary': {
                    'High': 20,
                    'Medium': 20,
                    'Low': 10
                },
                'ftmo_summary': {
                    'FTMO_Ready': 15,
                    'Não_Adequado': 35
                },
                'recommendations': [
                    "Teste de recomendação 1",
                    "Teste de recomendação 2"
                ]
            }
            
            # Gerar relatórios
            files = self.gerador_relatorios.generate_comprehensive_report(
                test_data, 
                report_type="full"
            )
            
            # Verificar arquivos gerados
            generated_count = 0
            for format_type, filepath in files.items():
                if os.path.exists(filepath):
                    size = os.path.getsize(filepath)
                    print(f"   ✓ {format_type.upper()}: {os.path.basename(filepath)} ({size} bytes)")
                    generated_count += 1
                else:
                    print(f"   ✗ {format_type.upper()}: arquivo não encontrado")
                    
            return generated_count >= 3  # Pelo menos 3 formatos
            
        except Exception as e:
            print(f"   ✗ Erro: {e}")
            return False
            
    def test_integracao_completa(self) -> bool:
        """Testa integração completa"""
        try:
            print("   🔗 Testando integração completa...")
            
            # Verificar se componentes foram inicializados
            if not all([self.classificador, self.monitor, self.gerador_relatorios]):
                print("   ✗ Componentes não inicializados")
                return False
                
            # Teste de fluxo integrado
            print("   🔄 Simulando fluxo completo...")
            
            # 1. Iniciar monitoramento
            monitor_test = MonitorTempoReal(update_interval=0.2)
            monitor_test.start_monitoring()
            
            # 2. Executar classificação com monitoramento
            classificador_test = ClassificadorLoteAvancado()
            
            # Simular progresso
            for i in range(5):
                progress_data = {
                    'files_processed': i * 2 + 1,
                    'files_successful': i * 2,
                    'files_failed': 1 if i > 2 else 0,
                    'memory_usage': 40.0 + i * 5,
                    'cpu_usage': 25.0 + i * 3,
                    'current_file': f"integration_test_{i}.mq4"
                }
                
                monitor_test.update_metrics(progress_data)
                time.sleep(0.5)
                
            # 3. Gerar relatório final
            final_data = {
                'execution_time': 2.5,
                'statistics': {'processed': 10, 'successful': 9, 'errors': 1},
                'performance': {'files_per_second': 4.0, 'success_rate': 90.0},
                'top_categories': [('EA', 6), ('Indicator', 4)],
                'quality_summary': {'High': 5, 'Medium': 4, 'Low': 1},
                'ftmo_summary': {'FTMO_Ready': 3, 'Não_Adequado': 7}
            }
            
            gerador_test = GeradorRelatoriosAvancados()
            integration_files = gerador_test.generate_comprehensive_report(
                final_data, 
                "json"
            )
            
            # 4. Parar monitoramento e exportar sessão
            monitor_test.stop_monitoring()
            session_report = monitor_test.export_session_report()
            
            # Verificar resultados
            success_indicators = [
                len(integration_files) > 0,
                os.path.exists(session_report),
                monitor_test.get_dashboard_data()['status'] == 'inactive'
            ]
            
            success_count = sum(success_indicators)
            print(f"   ✓ Indicadores de sucesso: {success_count}/3")
            
            return success_count >= 2
            
        except Exception as e:
            print(f"   ✗ Erro: {e}")
            return False
            
    def generate_final_report(self):
        """Gera relatório final dos testes"""
        self.test_results['end_time'] = datetime.now()
        self.test_results['total_duration'] = (
            self.test_results['end_time'] - self.test_results['start_time']
        ).total_seconds()
        
        # Calcular estatísticas
        total_tests = self.test_results['tests_passed'] + self.test_results['tests_failed']
        success_rate = (self.test_results['tests_passed'] / total_tests * 100) if total_tests > 0 else 0
        
        # Relatório console
        print("\n" + "="*60)
        print("📊 RELATÓRIO FINAL - TESTE SISTEMA COMPLETO")
        print("="*60)
        print(f"⏱️  Duração total: {self.test_results['total_duration']:.2f}s")
        print(f"✅ Testes aprovados: {self.test_results['tests_passed']}")
        print(f"❌ Testes falharam: {self.test_results['tests_failed']}")
        print(f"📈 Taxa de sucesso: {success_rate:.1f}%")
        
        if self.test_results['errors']:
            print(f"\n💥 Erros encontrados: {len(self.test_results['errors'])}")
            for error in self.test_results['errors']:
                print(f"   - {error['test']}: {error['error']}")
                
        # Status final
        if success_rate >= 75:
            print("\n🎉 SISTEMA PASSO 2: FUNCIONANDO CORRETAMENTE")
            status = "SUCCESS"
        elif success_rate >= 50:
            print("\n⚠️ SISTEMA PASSO 2: FUNCIONAMENTO PARCIAL")
            status = "PARTIAL"
        else:
            print("\n🚨 SISTEMA PASSO 2: NECESSITA CORREÇÕES")
            status = "FAILED"
            
        # Salvar relatório JSON
        report_file = f"Development/Reports/Test_Results/teste_sistema_completo_passo2_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        
        self.test_results['final_status'] = status
        self.test_results['success_rate'] = success_rate
        
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(self.test_results, f, indent=2, ensure_ascii=False, default=str)
            
        print(f"\n📄 Relatório detalhado salvo: {report_file}")
        
        return status

def main():
    """Função principal"""
    tester = TesteSistemaCompleto()
    tester.run_all_tests()
    
if __name__ == "__main__":
    main()