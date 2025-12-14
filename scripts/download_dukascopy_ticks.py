"""
Baixa tick data da Dukascopy e converte para formato MT5
Formato MT5 Ticks: Date	Time	Bid	Ask	Last	Volume	Flags
"""

from datetime import datetime, timedelta
import dukascopy_python as duka
import pandas as pd
import os

OUTPUT_DIR = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\Python_Agent_Hub\ml_pipeline\data"

def download_xauusd_ticks(start_date: datetime, end_date: datetime, output_file: str = None):
    """
    Baixa tick data XAUUSD da Dukascopy e salva em formato MT5.
    """
    print(f"Baixando ticks XAUUSD de {start_date} ate {end_date}...")
    print("Isso pode demorar alguns minutos dependendo do periodo...")
    
    # Baixa ticks da Dukascopy
    df = duka.fetch(
        instrument="XAUUSD",
        interval=duka.INTERVAL_TICK,
        offer_side=duka.OFFER_SIDE_BID,
        start=start_date,
        end=end_date
    )
    
    print(f"Total de ticks baixados: {len(df)}")
    
    if len(df) == 0:
        print("Nenhum tick baixado!")
        return None
    
    # Converte para formato MT5
    # MT5 espera: Date	Time	Bid	Ask	Last	Volume	Flags
    df['Date'] = df.index.strftime('%Y.%m.%d')
    df['Time'] = df.index.strftime('%H:%M:%S.%f').str[:-3]  # Milliseconds
    df['Bid'] = df['bidPrice'].round(2)
    df['Ask'] = df['askPrice'].round(2) if 'askPrice' in df.columns else df['Bid'] + 0.20  # Spread ~20 cents
    df['Last'] = df['Bid']  # Last = Bid para CFD
    df['Volume'] = (df['bidVolume'] * 100).astype(int) if 'bidVolume' in df.columns else 1
    df['Flags'] = 0
    
    mt5_df = df[['Date', 'Time', 'Bid', 'Ask', 'Last', 'Volume', 'Flags']]
    
    # Gera nome do arquivo
    if output_file is None:
        output_file = os.path.join(
            OUTPUT_DIR, 
            f"xauusd-ticks-{start_date.strftime('%Y%m%d')}-{end_date.strftime('%Y%m%d')}_MT5.csv"
        )
    
    # Salva com TAB
    mt5_df.to_csv(output_file, sep='\t', index=False, header=False)
    
    print(f"\nArquivo salvo: {output_file}")
    print(f"\nPrimeiros 10 ticks:")
    print(mt5_df.head(10).to_string(index=False))
    
    return output_file


if __name__ == "__main__":
    # Comeca com 1 semana pra testar (tick data e ENORME)
    end = datetime.now()
    start = end - timedelta(days=7)  # 1 semana
    
    # Ou periodo especifico:
    # start = datetime(2024, 11, 1)
    # end = datetime(2024, 11, 30)
    
    print("="*60)
    print("DUKASCOPY TICK DATA DOWNLOADER - XAUUSD")
    print("="*60)
    
    download_xauusd_ticks(start, end)
