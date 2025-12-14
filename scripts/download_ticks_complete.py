"""
Baixa tick data XAUUSD completo - 2020 ate semana passada
Continua de onde parou se interrompido
"""

from datetime import datetime, timedelta
from tickterial import Tickloader
import os
import sys

OUTPUT_DIR = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\Python_Agent_Hub\ml_pipeline\data"
PROGRESS_FILE = os.path.join(OUTPUT_DIR, "download_progress.txt")

def get_last_downloaded_date(output_file: str) -> datetime:
    """Verifica ultima data baixada para continuar."""
    if not os.path.exists(output_file):
        return None
    
    try:
        with open(output_file, 'rb') as f:
            f.seek(-500, 2)
            last_lines = f.read().decode(errors='ignore').strip().split('\n')
            last_line = last_lines[-1]
            date_str = last_line.split('\t')[0]  # 2024.04.02
            time_str = last_line.split('\t')[1].split('.')[0]  # 13:59:37
            return datetime.strptime(f"{date_str} {time_str}", "%Y.%m.%d %H:%M:%S")
    except:
        return None


def download_period(tickloader, start: datetime, end: datetime, output_file: str):
    """Baixa ticks de um periodo."""
    
    total_ticks = 0
    current = start
    hours_total = int((end - start).total_seconds() / 3600)
    hours_done = 0
    
    mode = 'a' if os.path.exists(output_file) else 'w'
    
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
            
            # Progress a cada hora
            if hours_done % 24 == 0:
                pct = (hours_done / hours_total) * 100
                print(f"[{pct:5.1f}%] {current.strftime('%Y-%m-%d')} | {total_ticks:,} ticks | {hours_done}/{hours_total} horas", flush=True)
                
                # Salva progresso
                with open(PROGRESS_FILE, 'w') as pf:
                    pf.write(f"{current.isoformat()}\n{total_ticks}\n{hours_done}/{hours_total}")
    
    return total_ticks


def main():
    print("="*70)
    print("XAUUSD TICK DOWNLOADER - DATASET COMPLETO")
    print("="*70)
    
    # Periodo: 2020-01-01 ate semana passada
    start_date = datetime(2020, 1, 1)
    end_date = datetime.now() - timedelta(days=7)  # Semana passada
    end_date = end_date.replace(hour=0, minute=0, second=0, microsecond=0)
    
    output_file = os.path.join(OUTPUT_DIR, "xauusd-ticks-2020-2025-FULL_MT5.csv")
    
    # Verifica se pode continuar de onde parou
    last_date = get_last_downloaded_date(output_file)
    if last_date and last_date > start_date:
        print(f"Continuando de: {last_date}")
        start_date = last_date + timedelta(hours=1)
    
    print(f"Periodo: {start_date.strftime('%Y-%m-%d')} ate {end_date.strftime('%Y-%m-%d')}")
    print(f"Arquivo: {output_file}")
    print("-"*70)
    
    tickloader = Tickloader()
    
    total = download_period(tickloader, start_date, end_date, output_file)
    
    print("\n" + "="*70)
    print(f"COMPLETO! Total nesta sessao: {total:,} ticks")
    
    # Stats finais
    if os.path.exists(output_file):
        size_mb = os.path.getsize(output_file) / (1024 * 1024)
        with open(output_file, 'r') as f:
            total_lines = sum(1 for _ in f)
        print(f"Arquivo final: {size_mb:.1f} MB | {total_lines:,} ticks totais")
    
    print("="*70)


if __name__ == "__main__":
    main()
