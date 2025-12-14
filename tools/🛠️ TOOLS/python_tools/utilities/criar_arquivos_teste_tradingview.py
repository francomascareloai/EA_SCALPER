#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Gerador de Arquivos de Teste TradingView
Cria 100 arquivos .txt simulando scripts Pine Script para teste do sistema multi-agente
"""

import os
import random
from datetime import datetime

def criar_arquivos_teste():
    """Cria 100 arquivos de teste simulando scripts TradingView"""
    
    # Criar pasta de teste
    pasta_teste = "Teste_TradingView_100_Arquivos"
    if not os.path.exists(pasta_teste):
        os.makedirs(pasta_teste)
    
    # Templates de scripts Pine Script
    templates = {
        "indicator": '''//@version=5
indicator("{nome}", shorttitle="{short}", overlay={overlay})

// Parâmetros
length = input.int({length}, "Length", minval=1)
source = input.source(close, "Source")

// Cálculo
{calculo}

// Plot
plot({plot_var}, "{nome}", color=color.{cor})
''',
        
        "strategy": '''//@version=5
strategy("{nome}", shorttitle="{short}", overlay={overlay}, default_qty_type=strategy.percent_of_equity, default_qty_value=10)

// Parâmetros
length = input.int({length}, "Length", minval=1)
stop_loss = input.float({sl}, "Stop Loss %", minval=0.1, step=0.1)
take_profit = input.float({tp}, "Take Profit %", minval=0.1, step=0.1)

// Estratégia
{estrategia}

// Execução
if (long_condition)
    strategy.entry("Long", strategy.long)
    strategy.exit("Exit Long", "Long", stop=close * (1 - stop_loss/100), limit=close * (1 + take_profit/100))

if (short_condition)
    strategy.entry("Short", strategy.short)
    strategy.exit("Exit Short", "Short", stop=close * (1 + stop_loss/100), limit=close * (1 - take_profit/100))
'''
    }
    
    # Dados para variação
    nomes_base = [
        "RSI_Enhanced", "MACD_Pro", "Bollinger_Advanced", "EMA_Cross", "Stochastic_Custom",
        "Volume_Flow", "Support_Resistance", "Trend_Detector", "Momentum_Scanner", "Price_Action",
        "Order_Blocks", "Liquidity_Zones", "Market_Structure", "Smart_Money", "ICT_Concepts",
        "Fibonacci_Auto", "Pivot_Points", "VWAP_Enhanced", "ATR_Bands", "Divergence_Hunter",
        "Breakout_Scanner", "Range_Detector", "Volatility_Index", "Correlation_Matrix", "Sentiment_Gauge"
    ]
    
    calculos = [
        "ma = ta.sma(source, length)",
        "rsi = ta.rsi(source, length)", 
        "macd = ta.macd(source, length, length*2, length//2)",
        "bb = ta.bb(source, length, 2)",
        "ema = ta.ema(source, length)",
        "stoch = ta.stoch(high, low, close, length)",
        "atr = ta.atr(length)",
        "volume_ma = ta.sma(volume, length)",
        "highest = ta.highest(high, length)",
        "lowest = ta.lowest(low, length)"
    ]
    
    estrategias = [
        "long_condition = ta.crossover(close, ta.sma(close, length))\nshort_condition = ta.crossunder(close, ta.sma(close, length))",
        "rsi_val = ta.rsi(close, length)\nlong_condition = rsi_val < 30\nshort_condition = rsi_val > 70",
        "[macd_line, signal_line, _] = ta.macd(close, 12, 26, 9)\nlong_condition = ta.crossover(macd_line, signal_line)\nshort_condition = ta.crossunder(macd_line, signal_line)",
        "ema_fast = ta.ema(close, length)\nema_slow = ta.ema(close, length*2)\nlong_condition = ta.crossover(ema_fast, ema_slow)\nshort_condition = ta.crossunder(ema_fast, ema_slow)"
    ]
    
    cores = ["blue", "red", "green", "orange", "purple", "yellow", "lime", "aqua"]
    
    # Gerar 100 arquivos
    for i in range(1, 101):
        # Escolher tipo aleatório
        tipo = random.choice(["indicator", "strategy"])
        
        # Gerar nome único
        nome_base = random.choice(nomes_base)
        nome = f"{nome_base}_{i}"
        short = nome_base[:8]
        
        # Parâmetros aleatórios
        length = random.choice([14, 20, 21, 50, 100, 200])
        overlay = random.choice(["true", "false"])
        cor = random.choice(cores)
        
        if tipo == "indicator":
            calculo = random.choice(calculos)
            plot_var = calculo.split(" = ")[0]
            
            conteudo = templates[tipo].format(
                nome=nome,
                short=short,
                overlay=overlay,
                length=length,
                calculo=calculo,
                plot_var=plot_var,
                cor=cor
            )
        else:  # strategy
            estrategia = random.choice(estrategias)
            sl = round(random.uniform(1.0, 5.0), 1)
            tp = round(random.uniform(2.0, 10.0), 1)
            
            conteudo = templates[tipo].format(
                nome=nome,
                short=short,
                overlay=overlay,
                length=length,
                estrategia=estrategia,
                sl=sl,
                tp=tp
            )
        
        # Adicionar comentários extras
        comentarios = f"""// Criado em: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
// Arquivo de teste #{i:03d}
// Tipo: {tipo.upper()}
// Categoria: {'SMC' if 'Order' in nome or 'Liquidity' in nome or 'Smart' in nome or 'ICT' in nome else 'Technical'}
// Mercado: {'Forex' if i % 3 == 0 else 'Crypto' if i % 3 == 1 else 'Indices'}
// Timeframe: {'M1' if i % 5 == 0 else 'M5' if i % 5 == 1 else 'M15' if i % 5 == 2 else 'H1' if i % 5 == 3 else 'H4'}

"""
        
        conteudo_final = comentarios + conteudo
        
        # Salvar arquivo
        nome_arquivo = f"{tipo}_{nome_base}_{i:03d}_v1.0.txt"
        caminho_arquivo = os.path.join(pasta_teste, nome_arquivo)
        
        with open(caminho_arquivo, 'w', encoding='utf-8') as f:
            f.write(conteudo_final)
    
    print(f"✅ Criados 100 arquivos de teste em: {pasta_teste}/")
    print(f"📊 Tipos gerados:")
    print(f"   - Indicators: ~50 arquivos")
    print(f"   - Strategies: ~50 arquivos")
    print(f"📁 Categorias: Technical Analysis, SMC/ICT")
    print(f"💱 Mercados: Forex, Crypto, Indices")
    print(f"⏰ Timeframes: M1, M5, M15, H1, H4")
    print(f"\n🚀 Pronto para teste do sistema multi-agente!")

if __name__ == "__main__":
    criar_arquivos_teste()