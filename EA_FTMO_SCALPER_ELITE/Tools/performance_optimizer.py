#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
EA FTMO Scalper Elite - Performance Optimizer
Otimização automatizada de parâmetros e performance

TradeDev_Master - Sistema de Trading de Elite
"""

import json
import datetime
import itertools
import numpy as np
from pathlib import Path
from typing import Dict, List, Tuple, Optional

class PerformanceOptimizer:
    def __init__(self):
        self.base_path = Path(__file__).parent
        self.optimization_results = []
        
    def generate_optimization_sets(self) -> List[Dict]:
        """Gera conjuntos de parâmetros para otimização"""
        
        print("🎯 GERANDO CONJUNTOS DE OTIMIZAÇÃO")
        print("=" * 60)
        
        # Parâmetros base do EA
        base_params = {
            "Magic_Number": [12345],
            "Risk_Per_Trade": [0.5, 1.0, 1.5, 2.0],
            "Max_Daily_Loss": [3.0, 4.0, 5.0],
            "Max_Drawdown": [8.0, 10.0, 12.0],
            "Stop_Loss_Pips": [10, 15, 20, 25],
            "Take_Profit_Pips": [15, 20, 25, 30],
            "Trailing_Stop": [5, 10, 15],
            "News_Filter_Minutes": [15, 30, 60],
            "Max_Spread": [2.0, 3.0, 4.0],
            "Min_Equity": [95.0, 97.0, 99.0]
        }
        
        # Parâmetros ICT/SMC
        ict_params = {
            "Enable_Order_Blocks": [True],
            "OB_Lookback_Bars": [20, 50, 100],
            "OB_Min_Size_Pips": [5, 10, 15],
            "Enable_FVG": [True, False],
            "FVG_Min_Size_Pips": [2, 5, 8],
            "Enable_Liquidity_Zones": [True, False],
            "Liquidity_Threshold": [0.5, 1.0, 1.5]
        }
        
        # Parâmetros de Volume
        volume_params = {
            "Enable_Volume_Analysis": [True, False],
            "Volume_MA_Period": [10, 20, 30],
            "Volume_Threshold": [1.2, 1.5, 2.0],
            "Enable_Volume_Breakout": [True, False]
        }
        
        # Parâmetros de Timeframe
        timeframe_params = {
            "Primary_Timeframe": ["M5", "M15"],
            "Secondary_Timeframe": ["M15", "H1"],
            "Confirmation_Timeframe": ["H1", "H4"]
        }
        
        # Combinar todos os parâmetros
        all_params = {**base_params, **ict_params, **volume_params, **timeframe_params}
        
        # Gerar combinações otimizadas (não todas as combinações para evitar explosão combinatória)
        optimization_sets = []
        
        # 1. Conjunto Conservador
        conservative_set = {
            "name": "Conservative_FTMO",
            "description": "Configuração conservadora para FTMO Challenge",
            "parameters": {
                "Risk_Per_Trade": 0.5,
                "Max_Daily_Loss": 3.0,
                "Max_Drawdown": 8.0,
                "Stop_Loss_Pips": 20,
                "Take_Profit_Pips": 25,
                "Trailing_Stop": 10,
                "News_Filter_Minutes": 60,
                "Max_Spread": 2.0,
                "Min_Equity": 99.0,
                "Enable_Order_Blocks": True,
                "OB_Lookback_Bars": 50,
                "OB_Min_Size_Pips": 10,
                "Enable_FVG": True,
                "FVG_Min_Size_Pips": 5,
                "Enable_Liquidity_Zones": True,
                "Liquidity_Threshold": 1.0,
                "Enable_Volume_Analysis": True,
                "Volume_MA_Period": 20,
                "Volume_Threshold": 1.5,
                "Primary_Timeframe": "M15",
                "Secondary_Timeframe": "H1"
            }
        }
        
        # 2. Conjunto Agressivo
        aggressive_set = {
            "name": "Aggressive_Growth",
            "description": "Configuração agressiva para crescimento rápido",
            "parameters": {
                "Risk_Per_Trade": 2.0,
                "Max_Daily_Loss": 5.0,
                "Max_Drawdown": 12.0,
                "Stop_Loss_Pips": 15,
                "Take_Profit_Pips": 30,
                "Trailing_Stop": 5,
                "News_Filter_Minutes": 30,
                "Max_Spread": 4.0,
                "Min_Equity": 95.0,
                "Enable_Order_Blocks": True,
                "OB_Lookback_Bars": 20,
                "OB_Min_Size_Pips": 5,
                "Enable_FVG": True,
                "FVG_Min_Size_Pips": 2,
                "Enable_Liquidity_Zones": True,
                "Liquidity_Threshold": 0.5,
                "Enable_Volume_Analysis": True,
                "Volume_MA_Period": 10,
                "Volume_Threshold": 1.2,
                "Primary_Timeframe": "M5",
                "Secondary_Timeframe": "M15"
            }
        }
        
        # 3. Conjunto Balanceado
        balanced_set = {
            "name": "Balanced_Performance",
            "description": "Configuração balanceada entre risco e retorno",
            "parameters": {
                "Risk_Per_Trade": 1.0,
                "Max_Daily_Loss": 4.0,
                "Max_Drawdown": 10.0,
                "Stop_Loss_Pips": 18,
                "Take_Profit_Pips": 22,
                "Trailing_Stop": 8,
                "News_Filter_Minutes": 45,
                "Max_Spread": 3.0,
                "Min_Equity": 97.0,
                "Enable_Order_Blocks": True,
                "OB_Lookback_Bars": 35,
                "OB_Min_Size_Pips": 8,
                "Enable_FVG": True,
                "FVG_Min_Size_Pips": 4,
                "Enable_Liquidity_Zones": True,
                "Liquidity_Threshold": 1.2,
                "Enable_Volume_Analysis": True,
                "Volume_MA_Period": 15,
                "Volume_Threshold": 1.3,
                "Primary_Timeframe": "M15",
                "Secondary_Timeframe": "H1"
            }
        }
        
        # 4. Conjunto Scalping Extremo
        scalping_set = {
            "name": "Extreme_Scalping",
            "description": "Configuração para scalping de alta frequência",
            "parameters": {
                "Risk_Per_Trade": 1.5,
                "Max_Daily_Loss": 4.5,
                "Max_Drawdown": 9.0,
                "Stop_Loss_Pips": 10,
                "Take_Profit_Pips": 15,
                "Trailing_Stop": 5,
                "News_Filter_Minutes": 15,
                "Max_Spread": 2.5,
                "Min_Equity": 98.0,
                "Enable_Order_Blocks": True,
                "OB_Lookback_Bars": 20,
                "OB_Min_Size_Pips": 5,
                "Enable_FVG": True,
                "FVG_Min_Size_Pips": 2,
                "Enable_Liquidity_Zones": True,
                "Liquidity_Threshold": 0.8,
                "Enable_Volume_Analysis": True,
                "Volume_MA_Period": 10,
                "Volume_Threshold": 1.8,
                "Primary_Timeframe": "M5",
                "Secondary_Timeframe": "M15"
            }
        }
        
        optimization_sets = [conservative_set, aggressive_set, balanced_set, scalping_set]
        
        print(f"✅ Gerados {len(optimization_sets)} conjuntos de otimização")
        return optimization_sets
    
    def create_set_files(self, optimization_sets: List[Dict]) -> None:
        """Cria arquivos .set para cada conjunto de otimização"""
        
        print("\n📁 CRIANDO ARQUIVOS .SET")
        print("=" * 60)
        
        for opt_set in optimization_sets:
            set_filename = f"EA_FTMO_Scalper_Elite_{opt_set['name']}.set"
            set_content = self._generate_set_content(opt_set['parameters'])
            
            with open(set_filename, 'w', encoding='utf-8') as f:
                f.write(set_content)
            
            print(f"✅ Criado: {set_filename}")
    
    def _generate_set_content(self, parameters: Dict) -> str:
        """Gera conteúdo do arquivo .set"""
        
        set_content = ";EA FTMO Scalper Elite - Optimization Set\n"
        set_content += f";Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n"
        
        for param_name, param_value in parameters.items():
            if isinstance(param_value, bool):
                set_content += f"{param_name}={str(param_value).lower()}\n"
            elif isinstance(param_value, str):
                set_content += f"{param_name}={param_value}\n"
            else:
                set_content += f"{param_name}={param_value}\n"
        
        return set_content
    
    def generate_optimization_script(self) -> str:
        """Gera script MQL5 para otimização automática"""
        
        script_content = f"""//+------------------------------------------------------------------+
//| EA FTMO Scalper Elite - Optimization Script                     |
//| Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}                                    |
//| TradeDev_Master - Sistema de Trading de Elite                   |
//+------------------------------------------------------------------+

#property copyright "TradeDev_Master"
#property version   "1.00"
#property script_show_inputs

//--- Input parameters for optimization
input string OptimizationMode = "Conservative"; // Conservative, Aggressive, Balanced, Scalping
input datetime StartDate = D'2024.01.01';       // Optimization start date
input datetime EndDate = D'2024.12.31';         // Optimization end date
input ENUM_TIMEFRAMES OptTimeframe = PERIOD_M15; // Optimization timeframe
input double InitialDeposit = 100000.0;         // Initial deposit
input bool EnableGenetic = true;                // Enable genetic algorithm
input int MaxGenerations = 100;                 // Maximum generations
input double MutationRate = 0.1;                // Mutation rate

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{{
    Print("🚀 Starting EA FTMO Scalper Elite Optimization");
    Print("Mode: ", OptimizationMode);
    Print("Period: ", TimeToString(StartDate), " to ", TimeToString(EndDate));
    
    // Configure optimization parameters based on mode
    ConfigureOptimization();
    
    // Start optimization process
    StartOptimization();
    
    Print("✅ Optimization configuration completed");
    Print("📊 Check Strategy Tester for results");
}}

//+------------------------------------------------------------------+
//| Configure optimization parameters                                |
//+------------------------------------------------------------------+
void ConfigureOptimization()
{{
    Print("⚙️ Configuring optimization parameters...");
    
    if(OptimizationMode == "Conservative")
    {{
        Print("📊 Conservative mode: Low risk, stable returns");
        // Risk_Per_Trade: 0.5-1.0
        // Stop_Loss_Pips: 15-25
        // Take_Profit_Pips: 20-30
    }}
    else if(OptimizationMode == "Aggressive")
    {{
        Print("🚀 Aggressive mode: Higher risk, higher returns");
        // Risk_Per_Trade: 1.5-2.0
        // Stop_Loss_Pips: 10-20
        // Take_Profit_Pips: 25-35
    }}
    else if(OptimizationMode == "Balanced")
    {{
        Print("⚖️ Balanced mode: Moderate risk/reward");
        // Risk_Per_Trade: 1.0-1.5
        // Stop_Loss_Pips: 12-22
        // Take_Profit_Pips: 18-28
    }}
    else if(OptimizationMode == "Scalping")
    {{
        Print("⚡ Scalping mode: High frequency, tight spreads");
        // Risk_Per_Trade: 0.8-1.5
        // Stop_Loss_Pips: 8-15
        // Take_Profit_Pips: 12-20
    }}
}}

//+------------------------------------------------------------------+
//| Start optimization process                                        |
//+------------------------------------------------------------------+
void StartOptimization()
{{
    Print("🔄 Starting optimization process...");
    
    // This would integrate with MT5's Strategy Tester
    // For now, we provide configuration guidance
    
    Print("📋 Optimization Steps:");
    Print("1. Open Strategy Tester (Ctrl+R)");
    Print("2. Select EA: EA_FTMO_Scalper_Elite");
    Print("3. Set Symbol: XAUUSD");
    Print("4. Set Period: ", EnumToString(OptTimeframe));
    Print("5. Set Dates: ", TimeToString(StartDate), " - ", TimeToString(EndDate));
    Print("6. Enable Optimization");
    Print("7. Load appropriate .set file");
    Print("8. Start optimization");
    
    // Generate optimization report template
    GenerateOptimizationReport();
}}

//+------------------------------------------------------------------+
//| Generate optimization report template                            |
//+------------------------------------------------------------------+
void GenerateOptimizationReport()
{{
    Print("📊 Generating optimization report template...");
    
    string filename = "optimization_report_" + OptimizationMode + "_" + 
                     TimeToString(TimeCurrent(), TIME_DATE) + ".txt";
    
    int file_handle = FileOpen(filename, FILE_WRITE|FILE_TXT);
    
    if(file_handle != INVALID_HANDLE)
    {{
        FileWrite(file_handle, "EA FTMO Scalper Elite - Optimization Report");
        FileWrite(file_handle, "Mode: " + OptimizationMode);
        FileWrite(file_handle, "Date: " + TimeToString(TimeCurrent()));
        FileWrite(file_handle, "");
        FileWrite(file_handle, "OPTIMIZATION RESULTS:");
        FileWrite(file_handle, "=====================");
        FileWrite(file_handle, "");
        FileWrite(file_handle, "Best Parameters:");
        FileWrite(file_handle, "- Risk Per Trade: [TO BE FILLED]");
        FileWrite(file_handle, "- Stop Loss: [TO BE FILLED]");
        FileWrite(file_handle, "- Take Profit: [TO BE FILLED]");
        FileWrite(file_handle, "");
        FileWrite(file_handle, "Performance Metrics:");
        FileWrite(file_handle, "- Total Net Profit: [TO BE FILLED]");
        FileWrite(file_handle, "- Profit Factor: [TO BE FILLED]");
        FileWrite(file_handle, "- Maximum Drawdown: [TO BE FILLED]");
        FileWrite(file_handle, "- Win Rate: [TO BE FILLED]");
        FileWrite(file_handle, "");
        FileWrite(file_handle, "FTMO Compliance:");
        FileWrite(file_handle, "- Daily Loss Limit: [CHECK]");
        FileWrite(file_handle, "- Total Drawdown: [CHECK]");
        FileWrite(file_handle, "- Profit Target: [CHECK]");
        
        FileClose(file_handle);
        Print("✅ Report template saved: ", filename);
    }}
    else
    {{
        Print("❌ Failed to create report file");
    }}
}}
"""
        
        return script_content
    
    def create_optimization_guide(self) -> str:
        """Cria guia completo de otimização"""
        
        guide_content = f"""# 🎯 GUIA DE OTIMIZAÇÃO DE PERFORMANCE
## EA FTMO Scalper Elite

**Data de Criação**: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

---

## 📋 VISÃO GERAL

Este guia fornece instruções detalhadas para otimizar a performance do EA FTMO Scalper Elite usando diferentes estratégias e configurações.

### 🎯 Objetivos da Otimização
- **Maximizar Profit Factor** (>1.5)
- **Minimizar Drawdown** (<5%)
- **Manter Compliance FTMO** (100%)
- **Otimizar Win Rate** (>65%)
- **Balancear Risk/Reward** (>1.2)

---

## 🔧 CONJUNTOS DE OTIMIZAÇÃO

### 1. 🛡️ Conservative FTMO
**Objetivo**: Máxima segurança para FTMO Challenge
- **Risk per Trade**: 0.5%
- **Max Daily Loss**: 3.0%
- **Stop Loss**: 20 pips
- **Take Profit**: 25 pips
- **Timeframe**: M15/H1

**Características**:
- ✅ Baixo risco
- ✅ Drawdown mínimo
- ✅ Alta compliance FTMO
- ⚠️ Crescimento lento

### 2. 🚀 Aggressive Growth
**Objetivo**: Crescimento acelerado com risco controlado
- **Risk per Trade**: 2.0%
- **Max Daily Loss**: 5.0%
- **Stop Loss**: 15 pips
- **Take Profit**: 30 pips
- **Timeframe**: M5/M15

**Características**:
- ✅ Alto potencial de lucro
- ✅ Execução rápida
- ⚠️ Maior risco
- ⚠️ Requer monitoramento

### 3. ⚖️ Balanced Performance
**Objetivo**: Equilíbrio ideal entre risco e retorno
- **Risk per Trade**: 1.0%
- **Max Daily Loss**: 4.0%
- **Stop Loss**: 18 pips
- **Take Profit**: 22 pips
- **Timeframe**: M15/H1

**Características**:
- ✅ Risco moderado
- ✅ Retorno consistente
- ✅ Boa compliance
- ✅ Versátil

### 4. ⚡ Extreme Scalping
**Objetivo**: Scalping de alta frequência
- **Risk per Trade**: 1.5%
- **Max Daily Loss**: 4.5%
- **Stop Loss**: 10 pips
- **Take Profit**: 15 pips
- **Timeframe**: M5/M15

**Características**:
- ✅ Muitas oportunidades
- ✅ Lucros rápidos
- ⚠️ Sensível ao spread
- ⚠️ Requer VPS

---

## 📊 PROCESSO DE OTIMIZAÇÃO

### Passo 1: Preparação
1. **Abrir MetaTrader 5**
2. **Acessar Strategy Tester** (Ctrl+R)
3. **Selecionar EA**: EA_FTMO_Scalper_Elite
4. **Configurar Symbol**: XAUUSD
5. **Definir Período**: 2024.01.01 - 2024.12.31

### Passo 2: Configuração
1. **Habilitar Otimização**
2. **Selecionar Modo**: Genetic Algorithm
3. **Carregar arquivo .set** apropriado
4. **Configurar critério**: Balance + Profit Factor

### Passo 3: Execução
1. **Iniciar Otimização**
2. **Monitorar Progresso**
3. **Aguardar Conclusão**
4. **Analisar Resultados**

### Passo 4: Validação
1. **Verificar Compliance FTMO**
2. **Validar Métricas de Performance**
3. **Testar em Forward Testing**
4. **Confirmar Estabilidade**

---

## 📈 MÉTRICAS DE AVALIAÇÃO

### 🎯 Métricas Primárias
- **Total Net Profit**: >10% (FTMO Challenge)
- **Profit Factor**: >1.5
- **Maximum Drawdown**: <5%
- **Win Rate**: >60%

### 📊 Métricas Secundárias
- **Sharpe Ratio**: >1.2
- **Recovery Factor**: >3.0
- **Average Win/Loss**: >1.2
- **Consecutive Losses**: <5

### 🏆 Compliance FTMO
- **Daily Loss Violations**: 0
- **Total Drawdown**: <10%
- **Trading Days**: >10
- **Consistency**: <50% single day

---

## 🔍 ANÁLISE DE RESULTADOS

### ✅ Resultados Aceitáveis
- Todas as métricas primárias atendidas
- Zero violações FTMO
- Curva de equity suave
- Drawdown controlado

### ⚠️ Resultados Questionáveis
- Métricas limítrofes
- Poucas violações FTMO
- Volatilidade alta
- Períodos de perda longos

### ❌ Resultados Inaceitáveis
- Métricas abaixo do mínimo
- Violações FTMO frequentes
- Drawdown excessivo
- Instabilidade geral

---

## 🛠️ TROUBLESHOOTING

### Problema: Drawdown Alto
**Soluções**:
- Reduzir Risk_Per_Trade
- Aumentar Stop_Loss
- Ativar Trailing_Stop
- Melhorar filtros de entrada

### Problema: Poucas Operações
**Soluções**:
- Reduzir filtros restritivos
- Ajustar timeframes
- Revisar condições de entrada
- Verificar configurações de spread

### Problema: Win Rate Baixo
**Soluções**:
- Otimizar Take_Profit/Stop_Loss
- Melhorar análise de mercado
- Ajustar indicadores ICT/SMC
- Revisar gestão de posições

---

## 📋 CHECKLIST PÓS-OTIMIZAÇÃO

### ✅ Validação Técnica
- [ ] Compilação sem erros
- [ ] Testes unitários passando
- [ ] Performance aceitável
- [ ] Logs funcionando

### ✅ Validação FTMO
- [ ] Compliance 100%
- [ ] Drawdown <5%
- [ ] Daily loss <5%
- [ ] Profit target >10%

### ✅ Validação Prática
- [ ] Forward testing 30 dias
- [ ] Demo account testing
- [ ] Monitoramento real-time
- [ ] Documentação atualizada

---

## 🎯 PRÓXIMOS PASSOS

### 1. **Implementar Melhor Configuração**
- Aplicar parâmetros otimizados
- Atualizar arquivos .set
- Documentar mudanças

### 2. **Testes Avançados**
- Forward testing estendido
- Multi-symbol testing
- Stress testing

### 3. **Deploy Produção**
- Configurar VPS
- Monitoramento 24/7
- Backup automático

---

## 📞 SUPORTE

**Arquivos Relacionados**:
- `*.set` - Configurações otimizadas
- `optimization_script.mq5` - Script de otimização
- `ftmo_validator.py` - Validador de compliance

**TradeDev_Master - Sistema de Trading de Elite** 🚀
"""
        
        return guide_content
    
    def run_optimization(self) -> None:
        """Executa processo completo de otimização"""
        
        print("🎯 EA FTMO SCALPER ELITE - PERFORMANCE OPTIMIZER")
        print("=" * 70)
        
        # 1. Gerar conjuntos de otimização
        optimization_sets = self.generate_optimization_sets()
        
        # 2. Criar arquivos .set
        self.create_set_files(optimization_sets)
        
        # 3. Gerar script de otimização
        print("\n📝 CRIANDO SCRIPT DE OTIMIZAÇÃO")
        print("=" * 60)
        
        optimization_script = self.generate_optimization_script()
        with open("EA_FTMO_Optimization_Script.mq5", 'w', encoding='utf-8') as f:
            f.write(optimization_script)
        print("✅ Criado: EA_FTMO_Optimization_Script.mq5")
        
        # 4. Criar guia de otimização
        print("\n📚 CRIANDO GUIA DE OTIMIZAÇÃO")
        print("=" * 60)
        
        optimization_guide = self.create_optimization_guide()
        with open("GUIA_OTIMIZACAO_PERFORMANCE.md", 'w', encoding='utf-8') as f:
            f.write(optimization_guide)
        print("✅ Criado: GUIA_OTIMIZACAO_PERFORMANCE.md")
        
        # 5. Salvar configurações
        config_data = {
            "optimization_sets": optimization_sets,
            "generation_date": datetime.datetime.now().isoformat(),
            "total_sets": len(optimization_sets)
        }
        
        with open("optimization_config.json", 'w', encoding='utf-8') as f:
            json.dump(config_data, f, indent=2, ensure_ascii=False)
        print("✅ Criado: optimization_config.json")
        
        # 6. Resumo final
        print(f"\n🎯 OTIMIZAÇÃO CONFIGURADA COM SUCESSO!")
        print(f"   • {len(optimization_sets)} conjuntos de parâmetros")
        print(f"   • {len(optimization_sets)} arquivos .set criados")
        print(f"   • Script de otimização MQL5 gerado")
        print(f"   • Guia completo de otimização criado")
        
        print(f"\n📋 PRÓXIMOS PASSOS:")
        print(f"   1. Abrir MetaTrader 5")
        print(f"   2. Carregar EA_FTMO_Optimization_Script.mq5")
        print(f"   3. Executar otimização no Strategy Tester")
        print(f"   4. Analisar resultados com GUIA_OTIMIZACAO_PERFORMANCE.md")

def main():
    """Função principal"""
    optimizer = PerformanceOptimizer()
    optimizer.run_optimization()

if __name__ == "__main__":
    main()