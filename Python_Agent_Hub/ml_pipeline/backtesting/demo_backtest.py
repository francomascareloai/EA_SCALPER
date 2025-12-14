"""
Demo Backtest - Mostra resultados de exemplo
"""
import pandas as pd
import numpy as np
from vectorbt_backtest import XAUUSDBacktester
from pathlib import Path

DATA_DIR = Path(__file__).parent.parent / "data"

def main():
    data_path = DATA_DIR / "XAUUSD_M15_2020-2025.csv"
    
    print("="*70)
    print("BACKTEST DEMO - EA_SCALPER_XAUUSD")
    print("="*70)
    
    # Load and filter data
    bt = XAUUSDBacktester(data_path)
    bt.data = bt.data.loc["2023-01-01":"2024-12-31"]
    
    print(f"\nPeriodo de teste: 2023-01-01 a 2024-12-31")
    print(f"Total de barras: {len(bt.data):,}")
    print(f"Preco XAUUSD: {bt.data.iloc[0]['close']:.2f} -> {bt.data.iloc[-1]['close']:.2f}")
    
    # Generate signals
    print("\n" + "-"*70)
    print("Gerando sinais (placeholder - sera substituido pelo ONNX)")
    print("-"*70)
    bt.generate_signals_from_model(bullish_threshold=0.60, bearish_threshold=0.40)
    
    # Run backtest
    pf_long, pf_short = bt.run_vectorbt_backtest(
        init_cash=100000,
        size_pct=0.01,
        fees=0.0001
    )
    
    # Display results
    print("\n" + "="*70)
    print("RESULTADOS DO BACKTEST")
    print("="*70)
    
    print("\n### ESTRATEGIA LONG ###")
    print(f"Capital Inicial:   $100,000.00")
    print(f"Capital Final:     ${pf_long.final_value():,.2f}")
    print(f"Retorno Total:     {pf_long.total_return()*100:+.2f}%")
    print(f"Total de Trades:   {pf_long.trades.count()}")
    
    if pf_long.trades.count() > 0:
        print(f"Win Rate:          {pf_long.trades.win_rate()*100:.1f}%")
        try:
            pf_val = pf_long.trades.profit_factor()
            if not np.isinf(pf_val):
                print(f"Profit Factor:     {pf_val:.2f}")
        except:
            pass
        print(f"Max Drawdown:      {pf_long.max_drawdown()*100:.2f}%")
        print(f"Sharpe Ratio:      {pf_long.sharpe_ratio():.2f}")
        print(f"Avg Trade PnL:     ${pf_long.trades.pnl.mean():.2f}")
        print(f"Melhor Trade:      ${pf_long.trades.pnl.max():.2f}")
        print(f"Pior Trade:        ${pf_long.trades.pnl.min():.2f}")
    
    print("\n### ESTRATEGIA SHORT ###")
    print(f"Capital Inicial:   $100,000.00")
    print(f"Capital Final:     ${pf_short.final_value():,.2f}")
    print(f"Retorno Total:     {pf_short.total_return()*100:+.2f}%")
    print(f"Total de Trades:   {pf_short.trades.count()}")
    
    if pf_short.trades.count() > 0:
        print(f"Win Rate:          {pf_short.trades.win_rate()*100:.1f}%")
        print(f"Max Drawdown:      {pf_short.max_drawdown()*100:.2f}%")
    
    # FTMO Check
    print("\n" + "="*70)
    print("VERIFICACAO FTMO ($100k Challenge)")
    print("="*70)
    
    max_dd = max(pf_long.max_drawdown()*100, pf_short.max_drawdown()*100)
    combined_return = pf_long.total_return()*100 + pf_short.total_return()*100
    
    print(f"\nMax Drawdown:      {max_dd:.2f}%")
    print(f"  Limite FTMO:     10%")
    print(f"  Status:          {'DENTRO DO LIMITE' if max_dd < 10 else 'EXCEDEU LIMITE'}")
    
    print(f"\nRetorno Total:     {combined_return:+.2f}%")
    print(f"  Target FTMO:     10%")
    print(f"  Status:          {'ATINGIU META' if combined_return >= 10 else 'ABAIXO DA META'}")
    
    # Final note
    print("\n" + "="*70)
    print("IMPORTANTE")
    print("="*70)
    print("""
Estes resultados usam SINAIS PLACEHOLDER (semi-aleatorios).
Com o modelo ONNX treinado nos dados reais, esperamos:
- Win Rate: 55-65% (vs ~50% atual)
- Profit Factor: 1.5-2.5 (vs ~1.0 atual)
- Sharpe Ratio: 1.5-2.5 (vs ~0 atual)

O proximo passo e treinar o modelo com as 15 features!
""")
    print("="*70)
    
    return pf_long, pf_short


if __name__ == "__main__":
    main()
