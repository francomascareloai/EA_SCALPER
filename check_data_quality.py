"""Análise de qualidade dos dados parquet disponíveis."""
import pandas as pd
import pytz
import yaml
from pathlib import Path

print("=" * 80)
print("ANÁLISE DE QUALIDADE DOS DADOS PARQUET")
print("=" * 80)

# Load data configuration (SINGLE SOURCE OF TRUTH)
config_path = Path("data/config.yaml")
if not config_path.exists():
    print(f"\nERRO: Arquivo de configuração não encontrado: {config_path}")
    print("Por favor, crie data/config.yaml primeiro!")
    exit(1)

config = yaml.safe_load(open(config_path))
print(f"\n[OK] Configuração carregada de: {config_path}")

# Get active dataset from config
active_dataset = config["active_dataset"]
main_file = Path(active_dataset["path"])

print(f"\n{'-' * 80}")
print(f"DATASET ATIVO (de config.yaml):")
print(f"{'-' * 80}")
print(f"Nome: {active_dataset['name']}")
print(f"Path: {main_file}")
print(f"Descrição: {active_dataset['description']}")

if not main_file.exists():
    print(f"\n[X] ERRO: Arquivo não encontrado: {main_file}")
    print("Verifique se o path em config.yaml está correto!")
    exit(1)

print(f"[OK] Arquivo encontrado: {main_file.stat().st_size / 1024 / 1024:.1f} MB")

print(f"\n{'=' * 80}")
print(f"ANÁLISE DETALHADA: {main_file.name}")
print(f"{'=' * 80}")

df = pd.read_parquet(main_file)
print(f"\nTotal de ticks: {len(df):,}")
print(f"Período: {df['datetime'].min()} até {df['datetime'].max()}")
print(f"Total de dias: {df['datetime'].dt.date.nunique()}")

# Distribuição por dia
print(f"\n{'-' * 80}")
print("DISTRIBUICAO POR DIA (resumo):")
print(f"{'-' * 80}")
daily_dist = df.groupby(df['datetime'].dt.date).size()
print(f"Primeiro dia: {daily_dist.index[0]} ({daily_dist.iloc[0]:,} ticks)")
print(f"Ultimo dia:   {daily_dist.index[-1]} ({daily_dist.iloc[-1]:,} ticks)")
print(f"Media:        {daily_dist.mean():.0f} ticks/dia")
print(f"Mediana:      {daily_dist.median():.0f} ticks/dia")

# Converter para ET (Eastern Time)
# Primeiro localizar para UTC se necessário
if df['datetime'].dt.tz is None:
    df['datetime'] = df['datetime'].dt.tz_localize('UTC')
df['datetime_et'] = df['datetime'].dt.tz_convert(pytz.timezone('US/Eastern'))
df['hour_et'] = df['datetime_et'].dt.hour
df['date'] = df['datetime'].dt.date

# Distribuição por hora (ET)
print(f"\n{'-' * 80}")
print("DISTRIBUICAO POR HORA (Eastern Time):")
print(f"{'-' * 80}")
hourly_dist = df.groupby('hour_et').size()
for hour, count in hourly_dist.items():
    pct = count / len(df) * 100
    bar = '#' * int(pct / 2)
    print(f"{hour:02d}:00 ET | {count:>7,} ticks | {pct:>5.1f}% | {bar}")

# Análise de sessões
print(f"\n{'-' * 80}")
print("ANALISE POR SESSAO DE TRADING:")
print(f"{'-' * 80}")

# London: 07:00-12:00 GMT = 02:00-07:00 ET (horário padrão EST)
london_ticks = len(df[(df['hour_et'] >= 2) & (df['hour_et'] < 7)])
london_pct = london_ticks / len(df) * 100

# NY Overlap: 12:00-15:00 GMT = 07:00-10:00 ET
overlap_ticks = len(df[(df['hour_et'] >= 7) & (df['hour_et'] < 10)])
overlap_pct = overlap_ticks / len(df) * 100

# NY: 15:00-17:00 GMT = 10:00-12:00 ET  
ny_ticks = len(df[(df['hour_et'] >= 10) & (df['hour_et'] < 12)])
ny_pct = ny_ticks / len(df) * 100

# Asian: 00:00-07:00 GMT = 19:00-02:00 ET (previous day)
asian_ticks = len(df[(df['hour_et'] >= 19) | (df['hour_et'] < 2)])
asian_pct = asian_ticks / len(df) * 100

# Late NY: 17:00-21:00 GMT = 12:00-16:00 ET
late_ny_ticks = len(df[(df['hour_et'] >= 12) & (df['hour_et'] < 16)])
late_ny_pct = late_ny_ticks / len(df) * 100

print(f"Asian (19:00-02:00 ET):      {asian_ticks:>8,} ticks ({asian_pct:>5.1f}%) - [X] BLOQUEADA por padrao")
print(f"London (02:00-07:00 ET):     {london_ticks:>8,} ticks ({london_pct:>5.1f}%) - [OK] Trading ativo")
print(f"Overlap (07:00-10:00 ET):    {overlap_ticks:>8,} ticks ({overlap_pct:>5.1f}%) - [OK] Prime time")
print(f"NY (10:00-12:00 ET):         {ny_ticks:>8,} ticks ({ny_pct:>5.1f}%) - [OK] Trading ativo")
print(f"Late NY (12:00-16:00 ET):    {late_ny_ticks:>8,} ticks ({late_ny_pct:>5.1f}%) - [X] BLOQUEADA por padrao")

tradeable_ticks = london_ticks + overlap_ticks + ny_ticks
tradeable_pct = tradeable_ticks / len(df) * 100
print(f"\n{'=' * 80}")
print(f"TOTAL TRADEABLE (Londres/Overlap/NY): {tradeable_ticks:>8,} ticks ({tradeable_pct:>5.1f}%)")
print(f"{'=' * 80}")

# Análise por dia de semana
print(f"\n{'-' * 80}")
print("DISTRIBUICAO POR DIA DA SEMANA:")
print(f"{'-' * 80}")
df['weekday'] = df['datetime_et'].dt.day_name()
weekday_order = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
weekday_dist = df.groupby('weekday').size().reindex(weekday_order, fill_value=0)
for day, count in weekday_dist.items():
    pct = count / len(df) * 100 if count > 0 else 0
    print(f"{day:>9} | {count:>7,} ticks | {pct:>5.1f}%")

# Análise de dias individuais mais promissores
print(f"\n{'-' * 80}")
print("TOP 10 DIAS COM MAIS TICKS EM SESSOES TRADEAVEIS:")
print(f"{'-' * 80}")

# Filtrar apenas sessões tradeáveis
df_tradeable = df[(df['hour_et'] >= 2) & (df['hour_et'] < 12)]
top_days = df_tradeable.groupby('date').size().sort_values(ascending=False).head(10)
for date, count in top_days.items():
    weekday = pd.Timestamp(date).day_name()
    print(f"{date} ({weekday[:3]}) | {count:>6,} ticks tradeaveis")

# Recomendações
print(f"\n{'=' * 80}")
print("RECOMENDACOES:")
print(f"{'=' * 80}")

if tradeable_pct < 30:
    print("[X] CRITICO: Apenas {:.1f}% dos dados estao em sessoes tradeaveis!".format(tradeable_pct))
    print("   Recomendacao: Gerar novos parquets focando em:")
    print("   - Meses com melhor cobertura de London/NY (ex: outubro/novembro)")
    print("   - Stride menor (stride10 ou stride5) para mais densidade")
    print("   - Filtrar por horario durante geracao (07:00-17:00 GMT)")
elif tradeable_pct < 50:
    print("[!] ATENCAO: Apenas {:.1f}% dos dados estao em sessoes tradeaveis.".format(tradeable_pct))
    print("   Recomendacao: Considerar gerar dados adicionais ou usar stride menor.")
else:
    print("[OK] BOM: {:.1f}% dos dados estao em sessoes tradeaveis.".format(tradeable_pct))
    print("   Os dados atuais sao adequados para backtesting com configuracoes reais.")

# Verificar densidade (ticks/hora)
total_hours = (df['datetime'].max() - df['datetime'].min()).total_seconds() / 3600
tradeable_hours = total_hours * (tradeable_pct / 100)
avg_ticks_per_hour = tradeable_ticks / tradeable_hours if tradeable_hours > 0 else 0
print(f"\nDensidade media (sessoes tradeaveis): {avg_ticks_per_hour:.0f} ticks/hora")
if avg_ticks_per_hour < 50:
    print("   [!] Densidade baixa - considerar stride menor (stride10 ou stride5)")
elif avg_ticks_per_hour < 100:
    print("   [OK] Densidade adequada para backtesting")
else:
    print("   [OK] Densidade alta - bom para backtesting realista")

print(f"\n{'=' * 80}")
