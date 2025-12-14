"""
Baixa barras H1 XAUUSD - 2020 ate agora
Usando dukascopy-python
"""

from datetime import datetime, timedelta
import dukascopy_python as duka
import pandas as pd
import os

OUTPUT_DIR = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\Python_Agent_Hub\ml_pipeline\data"

def main():
    print("="*70)
    print("XAUUSD H1 BARS DOWNLOADER - 2020 ATE AGORA")
    print("="*70)
    
    start_date = datetime(2020, 1, 1)
    end_date = datetime.now() - timedelta(days=1)
    
    output_file = os.path.join(OUTPUT_DIR, "xauusd-H1-2020-2025.csv")
    
    current_start = start_date
    all_dfs = []
    
    while current_start < end_date:
        current_end = min(current_start + timedelta(days=365), end_date)
        
        print(f"\n[H1] Chunk: {current_start.strftime('%Y-%m-%d')} -> {current_end.strftime('%Y-%m-%d')}")
        
        try:
            df = duka.fetch(
                instrument="XAUUSD",
                interval=duka.INTERVAL_HOUR_1,
                offer_side=duka.OFFER_SIDE_BID,
                start=current_start,
                end=current_end
            )
            
            if len(df) > 0:
                all_dfs.append(df)
                print(f"[H1] +{len(df)} barras")
        except Exception as e:
            print(f"[H1] Erro: {e}")
        
        current_start = current_end
    
    if all_dfs:
        final_df = pd.concat(all_dfs)
        final_df = final_df[~final_df.index.duplicated(keep='first')]
        final_df.sort_index(inplace=True)
        final_df.reset_index(inplace=True)
        final_df.columns = ['time', 'open', 'high', 'low', 'close', 'volume']
        final_df.to_csv(output_file, index=False)
        
        size_mb = os.path.getsize(output_file) / (1024 * 1024)
        print(f"\n[H1] COMPLETO! {len(final_df):,} barras | {size_mb:.1f} MB")
        print(f"[H1] Arquivo: {output_file}")


if __name__ == "__main__":
    main()
