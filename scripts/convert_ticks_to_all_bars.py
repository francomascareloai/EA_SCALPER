"""
Converte tick data Dukascopy para barras OHLCV (M5, M15, H1)
Processa em chunks para nao estourar memoria
NAO MODIFICA o arquivo original
"""

import pandas as pd
import numpy as np
from pathlib import Path
from datetime import datetime
import gc

DATA_DIR = Path(r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\Python_Agent_Hub\ml_pipeline\data")
TICK_FILE = DATA_DIR / "XAUUSD_ftmo_2020_ticks_dukascopy.csv"

CHUNK_SIZE = 10_000_000  # 10M linhas por chunk

def process_chunk(chunk: pd.DataFrame) -> pd.DataFrame:
    """Processa um chunk de ticks."""
    chunk.columns = ['datetime', 'bid', 'ask']
    chunk['datetime'] = pd.to_datetime(chunk['datetime'], format='%Y.%m.%d %H:%M:%S.%f', errors='coerce')
    chunk = chunk.dropna(subset=['datetime'])
    chunk['mid'] = (chunk['bid'] + chunk['ask']) / 2
    chunk['spread'] = chunk['ask'] - chunk['bid']
    chunk.set_index('datetime', inplace=True)
    return chunk


def ticks_to_ohlcv(df: pd.DataFrame, rule: str) -> pd.DataFrame:
    """Converte ticks para OHLCV com features de microestrutura."""
    ohlcv = df['mid'].resample(rule).agg(
        open='first',
        high='max',
        low='min',
        close='last'
    )
    ohlcv['volume'] = df['mid'].resample(rule).count()
    ohlcv['spread_mean'] = df['spread'].resample(rule).mean()
    ohlcv['spread_max'] = df['spread'].resample(rule).max()
    ohlcv['tick_count'] = df['mid'].resample(rule).count()
    return ohlcv


def main():
    print("="*70)
    print("TICK TO BARS CONVERTER - M5, M15, H1")
    print("="*70)
    print(f"Arquivo fonte: {TICK_FILE}")
    print(f"Tamanho: {TICK_FILE.stat().st_size / (1024**3):.2f} GB")
    print("-"*70)
    
    # Inicializa DataFrames para cada timeframe
    all_m5 = []
    all_m15 = []
    all_h1 = []
    
    # Processa em chunks
    chunk_num = 0
    total_ticks = 0
    
    print("\nProcessando em chunks de 10M linhas...")
    
    for chunk in pd.read_csv(TICK_FILE, chunksize=CHUNK_SIZE, header=None):
        chunk_num += 1
        total_ticks += len(chunk)
        
        print(f"\n[Chunk {chunk_num}] {total_ticks:,} ticks processados", flush=True)
        
        # Processa chunk
        df = process_chunk(chunk)
        
        if len(df) == 0:
            continue
        
        print(f"  Periodo: {df.index.min()} -> {df.index.max()}")
        
        # Converte para cada timeframe
        print("  Convertendo M5...", end=" ", flush=True)
        m5 = ticks_to_ohlcv(df, '5min')
        all_m5.append(m5)
        print(f"{len(m5)} barras")
        
        print("  Convertendo M15...", end=" ", flush=True)
        m15 = ticks_to_ohlcv(df, '15min')
        all_m15.append(m15)
        print(f"{len(m15)} barras")
        
        print("  Convertendo H1...", end=" ", flush=True)
        h1 = ticks_to_ohlcv(df, '1h')
        all_h1.append(h1)
        print(f"{len(h1)} barras")
        
        # Libera memoria
        del df, chunk
        gc.collect()
    
    print("\n" + "="*70)
    print("CONSOLIDANDO E SALVANDO...")
    print("="*70)
    
    # Consolida M5
    print("\nM5:", flush=True)
    df_m5 = pd.concat(all_m5)
    df_m5 = df_m5.groupby(df_m5.index).agg({
        'open': 'first', 'high': 'max', 'low': 'min', 'close': 'last',
        'volume': 'sum', 'spread_mean': 'mean', 'spread_max': 'max', 'tick_count': 'sum'
    })
    df_m5 = df_m5.sort_index()
    output_m5 = DATA_DIR / "XAUUSD_M5_2020-2025.csv"
    df_m5.to_csv(output_m5)
    print(f"  Salvo: {output_m5}")
    print(f"  Barras: {len(df_m5):,}")
    print(f"  Periodo: {df_m5.index.min()} -> {df_m5.index.max()}")
    print(f"  Tamanho: {output_m5.stat().st_size / (1024**2):.1f} MB")
    del df_m5, all_m5
    gc.collect()
    
    # Consolida M15
    print("\nM15:", flush=True)
    df_m15 = pd.concat(all_m15)
    df_m15 = df_m15.groupby(df_m15.index).agg({
        'open': 'first', 'high': 'max', 'low': 'min', 'close': 'last',
        'volume': 'sum', 'spread_mean': 'mean', 'spread_max': 'max', 'tick_count': 'sum'
    })
    df_m15 = df_m15.sort_index()
    output_m15 = DATA_DIR / "XAUUSD_M15_2020-2025.csv"
    df_m15.to_csv(output_m15)
    print(f"  Salvo: {output_m15}")
    print(f"  Barras: {len(df_m15):,}")
    print(f"  Periodo: {df_m15.index.min()} -> {df_m15.index.max()}")
    print(f"  Tamanho: {output_m15.stat().st_size / (1024**2):.1f} MB")
    del df_m15, all_m15
    gc.collect()
    
    # Consolida H1
    print("\nH1:", flush=True)
    df_h1 = pd.concat(all_h1)
    df_h1 = df_h1.groupby(df_h1.index).agg({
        'open': 'first', 'high': 'max', 'low': 'min', 'close': 'last',
        'volume': 'sum', 'spread_mean': 'mean', 'spread_max': 'max', 'tick_count': 'sum'
    })
    df_h1 = df_h1.sort_index()
    output_h1 = DATA_DIR / "XAUUSD_H1_2020-2025.csv"
    df_h1.to_csv(output_h1)
    print(f"  Salvo: {output_h1}")
    print(f"  Barras: {len(df_h1):,}")
    print(f"  Periodo: {df_h1.index.min()} -> {df_h1.index.max()}")
    print(f"  Tamanho: {output_h1.stat().st_size / (1024**2):.1f} MB")
    
    print("\n" + "="*70)
    print("CONVERSAO COMPLETA!")
    print("="*70)
    print(f"\nTotal de ticks processados: {total_ticks:,}")
    print(f"\nArquivos gerados:")
    print(f"  - {output_m5.name}")
    print(f"  - {output_m15.name}")
    print(f"  - {output_h1.name}")
    print("\nArquivo original INTACTO.")


if __name__ == "__main__":
    main()
