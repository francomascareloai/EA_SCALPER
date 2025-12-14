"""
Baixa tick data XAUUSD completo - Jan 2024 ate hoje
Processa mes a mes pra nao estourar memoria
"""

from datetime import datetime, timedelta
from tickterial import Tickloader
import os

OUTPUT_DIR = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\Python_Agent_Hub\ml_pipeline\data"

def download_month(tickloader, year: int, month: int, output_file: str):
    """Baixa um mes de ticks."""
    
    start = datetime(year, month, 1)
    if month == 12:
        end = datetime(year + 1, 1, 1)
    else:
        end = datetime(year, month + 1, 1)
    
    # Nao passar de ontem
    yesterday = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0) - timedelta(days=1)
    if end > yesterday:
        end = yesterday
    if start > yesterday:
        return 0
    
    print(f"\n  [{year}-{month:02d}] Baixando {start.strftime('%Y-%m-%d')} ate {end.strftime('%Y-%m-%d')}...")
    
    total_ticks = 0
    current = start
    
    with open(output_file, 'a') as f:
        while current < end:
            try:
                ticks = list(tickloader.download('XAUUSD', current))
                for tick in ticks:
                    ts = tick['timestamp']
                    dt = datetime.fromtimestamp(ts)
                    ms = int((ts % 1) * 1000)
                    
                    line = f"{dt.strftime('%Y.%m.%d')}\t{dt.strftime('%H:%M:%S.')}{ms:03d}\t{tick['bid']:.2f}\t{tick['ask']:.2f}\t{tick['bid']:.2f}\t{int(tick.get('bid-vol', 1))}\n"
                    f.write(line)
                    total_ticks += 1
            except Exception as e:
                pass  # Skip hours sem dados
            
            current += timedelta(hours=1)
            
            # Progress a cada 24h
            if current.hour == 0:
                print(f"    {current.strftime('%Y-%m-%d')} - {total_ticks:,} ticks", end='\r')
    
    print(f"    {year}-{month:02d} completo: {total_ticks:,} ticks          ")
    return total_ticks


def main():
    print("="*60)
    print("XAUUSD TICK DOWNLOADER - FULL DATASET")
    print("Periodo: 2024-01-01 ate ontem")
    print("="*60)
    
    output_file = os.path.join(OUTPUT_DIR, "xauusd-ticks-2024-2025_MT5.csv")
    
    # Limpa arquivo se existir
    if os.path.exists(output_file):
        os.remove(output_file)
    
    tickloader = Tickloader()
    total = 0
    
    # 2024: Jan a Dez
    for month in range(1, 13):
        total += download_month(tickloader, 2024, month, output_file)
    
    # 2025: Jan ate mes atual
    current_month = datetime.now().month
    for month in range(1, current_month + 1):
        total += download_month(tickloader, 2025, month, output_file)
    
    print("\n" + "="*60)
    print(f"COMPLETO! Total: {total:,} ticks")
    print(f"Arquivo: {output_file}")
    print("="*60)
    
    # Tamanho do arquivo
    size_mb = os.path.getsize(output_file) / (1024 * 1024)
    print(f"Tamanho: {size_mb:.1f} MB")


if __name__ == "__main__":
    main()
