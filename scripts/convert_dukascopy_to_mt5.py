"""
Converte dados Dukascopy CSV para formato MT5 Custom Symbol Import
Formato MT5: YYYY.MM.DD	HH:MM	Open	High	Low	Close	TickVolume
"""

import pandas as pd
from datetime import datetime
import os

def convert_dukascopy_to_mt5(input_file: str, output_file: str = None, digits: int = 2):
    """
    Converte CSV Dukascopy para formato MT5.
    
    Args:
        input_file: Caminho do CSV Dukascopy
        output_file: Caminho de saida (opcional, gera automatico)
        digits: Casas decimais (FTMO XAUUSD = 2)
    """
    print(f"Lendo arquivo: {input_file}")
    df = pd.read_csv(input_file)
    
    print(f"Total de barras: {len(df)}")
    print(f"Periodo: {datetime.fromtimestamp(df['timestamp'].iloc[0]/1000)} ate {datetime.fromtimestamp(df['timestamp'].iloc[-1]/1000)}")
    
    # Converte timestamp Unix (ms) para datetime
    df['datetime'] = pd.to_datetime(df['timestamp'], unit='ms')
    
    # Formata para MT5: YYYY.MM.DD	HH:MM
    df['Date'] = df['datetime'].dt.strftime('%Y.%m.%d')
    df['Time'] = df['datetime'].dt.strftime('%H:%M')
    
    # Arredonda precos para o numero de digitos correto (FTMO = 2)
    df['Open'] = df['open'].round(digits)
    df['High'] = df['high'].round(digits)
    df['Low'] = df['low'].round(digits)
    df['Close'] = df['close'].round(digits)
    
    # Volume - MT5 espera TickVolume como inteiro
    # Dukascopy volume e em lotes, multiplicamos por 1000 para ter valores razoaveis
    df['TickVolume'] = (df['volume'] * 1000).astype(int)
    df.loc[df['TickVolume'] == 0, 'TickVolume'] = 1  # Minimo 1
    
    # Seleciona colunas no formato MT5
    mt5_df = df[['Date', 'Time', 'Open', 'High', 'Low', 'Close', 'TickVolume']]
    
    # Gera nome do arquivo de saida
    if output_file is None:
        base_name = os.path.splitext(input_file)[0]
        output_file = f"{base_name}_MT5.csv"
    
    # Salva com TAB como separador (formato MT5)
    mt5_df.to_csv(output_file, sep='\t', index=False, header=False)
    
    print(f"\nArquivo convertido salvo em: {output_file}")
    print(f"Formato: Date[TAB]Time[TAB]Open[TAB]High[TAB]Low[TAB]Close[TAB]TickVolume")
    print(f"\nPrimeiras 5 linhas:")
    print(mt5_df.head().to_string(index=False))
    
    return output_file


if __name__ == "__main__":
    # Arquivos Dukascopy disponiveis
    data_dir = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\Python_Agent_Hub\ml_pipeline\data"
    
    files_to_convert = [
        "xauusd-m15-bid-2020-01-01-2025-11-28.csv",  # M15 completo
        "xauusd-h1-bid-2020-01-01-2025-11-28.csv",   # H1 completo
    ]
    
    for filename in files_to_convert:
        input_path = os.path.join(data_dir, filename)
        if os.path.exists(input_path):
            print(f"\n{'='*60}")
            convert_dukascopy_to_mt5(input_path, digits=2)
        else:
            print(f"Arquivo nao encontrado: {input_path}")
