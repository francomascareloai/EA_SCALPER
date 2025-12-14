"""
Converte tick data para barras OHLCV em multiplos timeframes
Roda em paralelo para M5, M15, H1
"""

import pandas as pd
import numpy as np
from pathlib import Path
from datetime import datetime
import sys
import os

DATA_DIR = Path(r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\Python_Agent_Hub\ml_pipeline\data")
TICK_DIR = Path(r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\.tick-data\XAUUSD")

def load_ticks_from_files(tick_dir: Path, start_year: int = 2020) -> pd.DataFrame:
    """Carrega todos os arquivos de tick em um DataFrame."""
    print(f"Carregando ticks de {tick_dir}...")
    
    all_data = []
    files = sorted(tick_dir.glob("XAUUSD_*"))
    total = len(files)
    
    for i, f in enumerate(files):
        if i % 1000 == 0:
            print(f"  Processando arquivo {i}/{total} ({100*i/total:.1f}%)", flush=True)
        
        try:
            # Parse filename: XAUUSD_2024-11-13_21
            parts = f.name.replace("XAUUSD_", "").split("_")
            date_str = parts[0]
            hour = int(parts[1]) if len(parts) > 1 else 0
            
            year = int(date_str.split("-")[0])
            if year < start_year:
                continue
            
            with open(f, 'r') as file:
                for line in file:
                    parts = line.strip().split('\t')
                    if len(parts) >= 4:
                        # Date Time Bid Ask Last Vol
                        dt_str = f"{parts[0]} {parts[1]}"
                        bid = float(parts[2])
                        ask = float(parts[3])
                        all_data.append({
                            'datetime': dt_str,
                            'bid': bid,
                            'ask': ask,
                            'mid': (bid + ask) / 2
                        })
        except Exception as e:
            continue
    
    print(f"  Total de ticks carregados: {len(all_data):,}")
    
    df = pd.DataFrame(all_data)
    df['datetime'] = pd.to_datetime(df['datetime'], format='%Y.%m.%d %H:%M:%S.%f', errors='coerce')
    df = df.dropna(subset=['datetime'])
    df.set_index('datetime', inplace=True)
    df.sort_index(inplace=True)
    
    return df


def ticks_to_ohlcv(df: pd.DataFrame, timeframe: str) -> pd.DataFrame:
    """Converte ticks para OHLCV."""
    print(f"Convertendo para {timeframe}...")
    
    tf_map = {
        'M1': '1min',
        'M5': '5min',
        'M15': '15min',
        'M30': '30min',
        'H1': '1h',
        'H4': '4h',
        'D1': '1D'
    }
    
    rule = tf_map.get(timeframe, '15min')
    
    ohlcv = df['mid'].resample(rule).agg({
        'open': 'first',
        'high': 'max',
        'low': 'min',
        'close': 'last',
    })
    
    # Volume = count de ticks
    ohlcv['volume'] = df['mid'].resample(rule).count()
    
    ohlcv = ohlcv.dropna()
    
    print(f"  {timeframe}: {len(ohlcv):,} barras")
    return ohlcv


def main():
    timeframe = sys.argv[1] if len(sys.argv) > 1 else 'M15'
    start_year = int(sys.argv[2]) if len(sys.argv) > 2 else 2020
    
    print("="*70)
    print(f"TICK TO BARS CONVERTER - {timeframe}")
    print("="*70)
    
    # Carrega ticks
    df = load_ticks_from_files(TICK_DIR, start_year)
    
    if len(df) == 0:
        print("Nenhum tick encontrado!")
        return
    
    print(f"\nPeriodo: {df.index.min()} ate {df.index.max()}")
    
    # Converte
    ohlcv = ticks_to_ohlcv(df, timeframe)
    
    # Salva
    output_file = DATA_DIR / f"xauusd-{timeframe}-{start_year}-2025.csv"
    ohlcv.to_csv(output_file)
    
    size_mb = output_file.stat().st_size / (1024 * 1024)
    print(f"\nSalvo: {output_file}")
    print(f"Tamanho: {size_mb:.1f} MB")
    print(f"Barras: {len(ohlcv):,}")
    print(f"Periodo: {ohlcv.index.min()} ate {ohlcv.index.max()}")


if __name__ == "__main__":
    main()
