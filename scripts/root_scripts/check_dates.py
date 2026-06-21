import pandas as pd

# Ler apenas coluna datetime para ser mais rápido
df = pd.read_parquet('C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/data/ticks/xauusd_2020_2024_stride20.parquet', columns=['datetime'])
df['datetime'] = pd.to_datetime(df['datetime'])

print('=== Datas únicas em Dezembro 2024 ===')
dec_2024 = df[df['datetime'].dt.strftime('%Y-%m').eq('2024-12')]
unique_dates = sorted(dec_2024['datetime'].dt.date.unique())
print(f"Total: {len(unique_dates)} dias com dados")
for date in unique_dates:
    print(f"  - {date}")

print('\n=== Análise de 2024-12-27 ===')
dec27 = df[df['datetime'].dt.date.eq(pd.Timestamp('2024-12-27').date())]
if len(dec27) > 0:
    print(f"Primeiro tick: {dec27.iloc[0]['datetime']}")
    print(f"Último tick: {dec27.iloc[-1]['datetime']}")
    print(f"Total ticks: {len(dec27):,}")
    
    # Convert to ET (UTC-5)
    dec27_et = dec27.copy()
    dec27_et['datetime_et'] = dec27_et['datetime'].dt.tz_localize('UTC').dt.tz_convert('America/New_York')
    print(f"\nPrimeiro tick (ET): {dec27_et.iloc[0]['datetime_et']}")
    print(f"Último tick (ET): {dec27_et.iloc[-1]['datetime_et']}")
    
    # Check if any before 16:59 ET
    cutoff = pd.Timestamp('2024-12-27 16:59:00', tz='America/New_York')
    before_cutoff = dec27_et[dec27_et['datetime_et'] < cutoff]
    print(f"\nTicks ANTES de 16:59 ET: {len(before_cutoff):,}")
    print(f"Ticks DEPOIS de 16:59 ET: {len(dec27_et) - len(before_cutoff):,}")
else:
    print("Sem dados para 2024-12-27!")
