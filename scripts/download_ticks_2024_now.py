"""
Baixa tick data XAUUSD - 2024 ate agora
Usando tickterial
"""

from datetime import datetime, timedelta
from tickterial import Tickloader
import os

OUTPUT_DIR = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\Python_Agent_Hub\ml_pipeline\data"

def download_period(tickloader, start: datetime, end: datetime, output_file: str):
    total_ticks = 0
    current = start
    hours_total = int((end - start).total_seconds() / 3600)
    hours_done = 0
    
    mode = 'w'
    
    with open(output_file, mode) as f:
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
            except:
                pass
            
            current += timedelta(hours=1)
            hours_done += 1
            
            if hours_done % 24 == 0:
                pct = (hours_done / hours_total) * 100
                print(f"[TICKS 2024-NOW] [{pct:5.1f}%] {current.strftime('%Y-%m-%d')} | {total_ticks:,} ticks", flush=True)
    
    return total_ticks


def main():
    print("="*70)
    print("XAUUSD TICK DOWNLOADER - 2024 ATE AGORA")
    print("="*70)
    
    start_date = datetime(2024, 1, 1)
    end_date = datetime.now() - timedelta(days=1)
    end_date = end_date.replace(hour=23, minute=59, second=59, microsecond=0)
    
    output_file = os.path.join(OUTPUT_DIR, "xauusd-ticks-2024-now_MT5.csv")
    
    print(f"Periodo: {start_date.strftime('%Y-%m-%d')} ate {end_date.strftime('%Y-%m-%d')}")
    print(f"Arquivo: {output_file}")
    print("-"*70)
    
    tickloader = Tickloader()
    total = download_period(tickloader, start_date, end_date, output_file)
    
    print(f"\nCOMPLETO! Total: {total:,} ticks")
    if os.path.exists(output_file):
        size_mb = os.path.getsize(output_file) / (1024 * 1024)
        print(f"Arquivo: {size_mb:.1f} MB")


if __name__ == "__main__":
    main()
