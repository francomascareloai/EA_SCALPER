#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
EA FTMO Scalper Elite - Strategy Tester Configuration
Configuração automatizada para backtesting no MetaTrader 5

TradeDev_Master - Sistema de Trading de Elite
"""

import os
import json
import datetime
from pathlib import Path

class StrategyTesterConfig:
    def __init__(self):
        self.base_path = Path(__file__).parent
        self.ea_name = "EA_FTMO_Scalper_Elite"
        self.symbol = "XAUUSD"
        self.timeframe = "M15"
        
    def generate_test_config(self):
        """Gera configuração completa para Strategy Tester"""
        
        config = {
            "strategy_tester": {
                "ea_name": self.ea_name,
                "symbol": self.symbol,
                "timeframe": self.timeframe,
                "test_period": {
                    "start_date": "2024.01.01",
                    "end_date": "2024.12.31",
                    "description": "Ano completo 2024 para validação robusta"
                },
                "test_modes": [
                    {
                        "name": "FTMO_Challenge_Test",
                        "initial_deposit": 100000,
                        "leverage": 100,
                        "max_daily_loss": 5000,
                        "max_total_loss": 10000,
                        "profit_target": 10000,
                        "description": "Simulação FTMO Challenge"
                    },
                    {
                        "name": "Conservative_Test", 
                        "initial_deposit": 10000,
                        "leverage": 30,
                        "max_daily_loss": 200,
                        "max_total_loss": 500,
                        "profit_target": 1000,
                        "description": "Teste conservador para conta pequena"
                    },
                    {
                        "name": "Aggressive_Test",
                        "initial_deposit": 50000,
                        "leverage": 200,
                        "max_daily_loss": 2500,
                        "max_total_loss": 5000,
                        "profit_target": 5000,
                        "description": "Teste agressivo para prop firm"
                    }
                ],
                "optimization_parameters": {
                    "risk_per_trade": [0.5, 1.0, 1.5, 2.0],
                    "tp_multiplier": [1.5, 2.0, 2.5, 3.0],
                    "sl_multiplier": [1.0, 1.2, 1.5],
                    "max_trades_per_day": [5, 10, 15, 20],
                    "news_filter_minutes": [30, 60, 120]
                },
                "validation_criteria": {
                    "min_profit_factor": 1.3,
                    "max_drawdown_percent": 5.0,
                    "min_sharpe_ratio": 1.5,
                    "min_win_rate": 60.0,
                    "min_total_trades": 100,
                    "max_consecutive_losses": 5
                }
            }
        }
        
        return config
    
    def create_set_files(self):
        """Cria arquivos .set para diferentes configurações"""
        
        configs = {
            "FTMO_Challenge": {
                "RiskPerTrade": 1.0,
                "MaxDailyLoss": 5.0,
                "MaxDrawdown": 10.0,
                "TakeProfitMultiplier": 2.0,
                "StopLossMultiplier": 1.0,
                "MaxTradesPerDay": 10,
                "NewsFilterMinutes": 60,
                "EnableOrderBlocks": True,
                "EnableFVG": True,
                "EnableLiquidityDetection": True,
                "LogLevel": 2
            },
            "Conservative": {
                "RiskPerTrade": 0.5,
                "MaxDailyLoss": 2.0,
                "MaxDrawdown": 5.0,
                "TakeProfitMultiplier": 2.5,
                "StopLossMultiplier": 1.2,
                "MaxTradesPerDay": 5,
                "NewsFilterMinutes": 120,
                "EnableOrderBlocks": True,
                "EnableFVG": False,
                "EnableLiquidityDetection": True,
                "LogLevel": 1
            },
            "Aggressive": {
                "RiskPerTrade": 2.0,
                "MaxDailyLoss": 5.0,
                "MaxDrawdown": 8.0,
                "TakeProfitMultiplier": 1.5,
                "StopLossMultiplier": 1.0,
                "MaxTradesPerDay": 20,
                "NewsFilterMinutes": 30,
                "EnableOrderBlocks": True,
                "EnableFVG": True,
                "EnableLiquidityDetection": True,
                "LogLevel": 3
            }
        }
        
        set_files = {}
        for config_name, params in configs.items():
            set_content = f"; {self.ea_name} - {config_name} Configuration\n"
            set_content += f"; Generated on {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n"
            
            for param, value in params.items():
                if isinstance(value, bool):
                    set_content += f"{param}={str(value).lower()}\n"
                else:
                    set_content += f"{param}={value}\n"
            
            set_files[f"{self.ea_name}_{config_name}.set"] = set_content
        
        return set_files
    
    def generate_test_script(self):
        """Gera script de teste automatizado"""
        
        script = f"""
//+------------------------------------------------------------------+
//| {self.ea_name}_TestScript.mq5
//| Script para automação de testes no Strategy Tester
//+------------------------------------------------------------------+

#property script_show_inputs

input string TestMode = "FTMO_Challenge"; // Modo de teste
input datetime StartDate = D'2024.01.01'; // Data inicial
input datetime EndDate = D'2024.12.31';   // Data final
input double InitialDeposit = 100000;     // Depósito inicial
input int Leverage = 100;                 // Alavancagem

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{{
    Print("=== INICIANDO TESTE AUTOMATIZADO ===");
    Print("EA: {self.ea_name}");
    Print("Símbolo: {self.symbol}");
    Print("Timeframe: {self.timeframe}");
    Print("Modo: ", TestMode);
    Print("Período: ", TimeToString(StartDate), " - ", TimeToString(EndDate));
    Print("Depósito: $", InitialDeposit);
    Print("Alavancagem: 1:", Leverage);
    
    // Configurar parâmetros do Strategy Tester
    if(!ConfigureStrategyTester())
    {{
        Print("ERRO: Falha na configuração do Strategy Tester");
        return;
    }}
    
    Print("=== CONFIGURAÇÃO CONCLUÍDA ===");
    Print("Execute o teste manualmente no Strategy Tester");
    Print("Ou use o terminal para automação completa");
}}

//+------------------------------------------------------------------+
//| Configurar Strategy Tester                                       |
//+------------------------------------------------------------------+
bool ConfigureStrategyTester()
{{
    // Aqui seria implementada a configuração automática
    // Por limitações do MQL5, alguns passos devem ser manuais
    
    Print("Configurações recomendadas:");
    Print("- Expert: {self.ea_name}.ex5");
    Print("- Símbolo: {self.symbol}");
    Print("- Período: {self.timeframe}");
    Print("- Modelo: Todos os ticks");
    Print("- Otimização: Desabilitada (primeiro teste)");
    
    return true;
}}
"""
        
        return script
    
    def create_test_report_template(self):
        """Cria template para relatório de testes"""
        
        template = {
            "test_session": {
                "ea_name": self.ea_name,
                "symbol": self.symbol,
                "timeframe": self.timeframe,
                "test_date": datetime.datetime.now().isoformat(),
                "tester_version": "MetaTrader 5",
                "test_duration": "TBD"
            },
            "test_results": {
                "total_trades": 0,
                "winning_trades": 0,
                "losing_trades": 0,
                "win_rate": 0.0,
                "profit_factor": 0.0,
                "sharpe_ratio": 0.0,
                "maximum_drawdown": 0.0,
                "maximum_drawdown_percent": 0.0,
                "total_net_profit": 0.0,
                "gross_profit": 0.0,
                "gross_loss": 0.0,
                "largest_profit_trade": 0.0,
                "largest_loss_trade": 0.0,
                "average_profit_trade": 0.0,
                "average_loss_trade": 0.0,
                "consecutive_wins": 0,
                "consecutive_losses": 0,
                "modelling_quality": 0.0
            },
            "ftmo_compliance": {
                "max_daily_loss_violated": False,
                "max_total_loss_violated": False,
                "profit_target_reached": False,
                "trading_days": 0,
                "consistency_score": 0.0,
                "risk_management_score": 0.0
            },
            "performance_metrics": {
                "trades_per_day": 0.0,
                "average_holding_time": "TBD",
                "best_trading_day": 0.0,
                "worst_trading_day": 0.0,
                "monthly_returns": [],
                "volatility": 0.0,
                "calmar_ratio": 0.0
            },
            "recommendations": [],
            "next_steps": []
        }
        
        return template

def main():
    """Função principal"""
    print("🚀 EA FTMO Scalper Elite - Strategy Tester Setup")
    print("=" * 60)
    
    config_generator = StrategyTesterConfig()
    
    # Gerar configuração principal
    print("📋 Gerando configuração do Strategy Tester...")
    config = config_generator.generate_test_config()
    
    # Salvar configuração
    config_file = "strategy_tester_config.json"
    with open(config_file, 'w', encoding='utf-8') as f:
        json.dump(config, f, indent=2, ensure_ascii=False)
    print(f"✅ Configuração salva em: {config_file}")
    
    # Criar arquivos .set
    print("📁 Criando arquivos de configuração (.set)...")
    set_files = config_generator.create_set_files()
    
    for filename, content in set_files.items():
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✅ Arquivo criado: {filename}")
    
    # Criar script de teste
    print("📜 Gerando script de teste...")
    test_script = config_generator.generate_test_script()
    
    script_file = f"{config_generator.ea_name}_TestScript.mq5"
    with open(script_file, 'w', encoding='utf-8') as f:
        f.write(test_script)
    print(f"✅ Script criado: {script_file}")
    
    # Criar template de relatório
    print("📊 Criando template de relatório...")
    report_template = config_generator.create_test_report_template()
    
    template_file = "test_report_template.json"
    with open(template_file, 'w', encoding='utf-8') as f:
        json.dump(report_template, f, indent=2, ensure_ascii=False)
    print(f"✅ Template criado: {template_file}")
    
    print("\n🎯 PRÓXIMOS PASSOS:")
    print("1. Compile o EA no MetaEditor")
    print("2. Abra o Strategy Tester no MT5")
    print("3. Carregue uma das configurações .set")
    print("4. Execute o backtest")
    print("5. Analise os resultados")
    
    print("\n📋 CONFIGURAÇÕES DISPONÍVEIS:")
    for config_name in ["FTMO_Challenge", "Conservative", "Aggressive"]:
        print(f"   • {config_generator.ea_name}_{config_name}.set")
    
    print(f"\n✅ Setup do Strategy Tester concluído!")

if __name__ == "__main__":
    main()