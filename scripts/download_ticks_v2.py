"""
Baixa tick data XAUUSD usando tickterial (mais estavel)
Formato MT5 Ticks: Date	Time	Bid	Ask	Last	Volume
"""

from datetime import datetime, timedelta
from tickterial import Tickloader
import os

OUTPUT_DIR = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\Python_Agent_Hub\ml_pipeline\data"

def download_ticks_for_period(start_date: datetime, end_date: datetime):
    """Baixa ticks hora a hora e junta tudo."""
    
    tickloader = Tickloader()
    all_ticks = []
    
    current = start_date
    total_hours = int((end_date - start_date).total_seconds() / 3600)
    hour_count = 0
    
    print(f"Baixando {total_hours} horas de ticks...")
    
    while current < end_date:
        hour_count += 1
        try:
            ticks = list(tickloader.download('XAUUSD', current))
            all_ticks.extend(ticks)
            if hour_count % 24 == 0:
                print(f"  Progresso: {hour_count}/{total_hours} horas ({len(all_ticks)} ticks)")
        except Exception as e:
            print(f"  Erro em {current}: {e}")
        
        current += timedelta(hours=1)
    
    return all_ticks


def convert_to_mt5_format(ticks: list, output_file: str):
    """Converte lista de ticks para formato MT5."""
    
    print(f"\nConvertendo {len(ticks)} ticks para formato MT5...")
    
    # Debug: ver estrutura do tick
    if ticks:
        print(f"Estrutura do tick: {type(ticks[0])}")
        print(f"Exemplo: {ticks[0]}")
    
    with open(output_file, 'w') as f:
        for tick in ticks:
            # tickterial retorna dict: {'timestamp': 1731380400.01, 'ask': 2622.285, 'bid': 2621.865, 'ask-vol': 90, 'bid-vol': 90}
            ts = tick['timestamp']
            ask_price = tick['ask']
            bid_price = tick['bid']
            bid_vol = tick.get('bid-vol', 1)
            
            # timestamp ja esta em segundos (com decimais para ms)
            dt = datetime.fromtimestamp(ts)
            ms = int((ts % 1) * 1000)
            date_str = dt.strftime('%Y.%m.%d')
            time_str = dt.strftime('%H:%M:%S.') + f"{ms:03d}"
            
            bid = round(bid_price, 2)
            ask = round(ask_price, 2)
            last = bid
            volume = int(bid_vol) if bid_vol else 1
            
            f.write(f"{date_str}\t{time_str}\t{bid}\t{ask}\t{last}\t{volume}\n")
    
    print(f"Arquivo salvo: {output_file}")


if __name__ == "__main__":
    # Baixa 3 dias de ticks (teste)
    end = datetime(2024, 11, 15, 0, 0)  # Data no passado que existe
    start = datetime(2024, 11, 12, 0, 0)  # 3 dias
    
    print("="*60)
    print("TICKTERIAL - XAUUSD TICK DOWNLOADER")
    print("="*60)
    print(f"Periodo: {start} ate {end}")
    
    ticks = download_ticks_for_period(start, end)
    
    if ticks:
        output = os.path.join(OUTPUT_DIR, f"xauusd-ticks-{start.strftime('%Y%m%d')}-{end.strftime('%Y%m%d')}_MT5.csv")
        convert_to_mt5_format(ticks, output)
        
        # Mostra amostra
        print(f"\nTotal: {len(ticks)} ticks")
        print("\nPrimeiros 5 ticks:")
        for t in ticks[:5]:
            dt = datetime.fromtimestamp(t[0]/1000)
            print(f"  {dt} | Bid: {t[2]:.2f} | Ask: {t[1]:.2f}")
    else:
        print("Nenhum tick baixado!")
