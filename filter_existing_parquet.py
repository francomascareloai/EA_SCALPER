"""
Filtrar parquet existente para manter apenas sessões tradeáveis.
ESTRATÉGIA GENIUS: Reaproveitar processamento já feito!
"""
import pandas as pd
import pytz
from pathlib import Path
from datetime import datetime

# Configurações
TRADEABLE_HOURS_GMT = list(range(7, 17))  # 07:00-17:00 GMT

def filter_parquet(input_path, output_path):
    """Filtra parquet existente para sessões tradeáveis."""
    
    print("="*80)
    print("FILTRO RÁPIDO DE PARQUET EXISTENTE")
    print("="*80)
    
    print(f"\n>> Lendo: {input_path.name}")
    print(f"   Tamanho: {input_path.stat().st_size / 1024**2:.1f} MB")
    
    # Ler parquet existente
    df = pd.read_parquet(input_path)
    
    print(f"\n>> Dados originais:")
    print(f"   - Total ticks: {len(df):,}")
    print(f"   - Periodo: {df['datetime'].min()} ate {df['datetime'].max()}")
    print(f"   - Dias: {df['datetime'].dt.date.nunique()}")
    
    # Garantir timezone
    if df['datetime'].dt.tz is None:
        print(f"   - Adicionando timezone UTC...")
        df['datetime'] = df['datetime'].dt.tz_localize('UTC')
    
    # Distribuição por hora ANTES do filtro
    df['hour_gmt'] = df['datetime'].dt.hour
    hour_dist_before = df['hour_gmt'].value_counts().sort_index()
    
    print(f"\n>> Distribuicao por hora GMT (antes do filtro):")
    for hour, count in hour_dist_before.items():
        pct = count / len(df) * 100
        in_range = "[OK]" if hour in TRADEABLE_HOURS_GMT else "[X]"
        print(f"   {in_range} {hour:02d}:00 -> {count:>8,} ticks ({pct:>5.1f}%)")
    
    # Aplicar filtro
    print(f"\n>> Aplicando filtro: 07:00-17:00 GMT (London + Overlap + NY)...")
    df_filtered = df[df['hour_gmt'].isin(TRADEABLE_HOURS_GMT)].copy()
    
    # Remover coluna auxiliar
    df_filtered = df_filtered.drop('hour_gmt', axis=1)
    
    # Estatísticas pós-filtro
    print(f"\n[OK] Apos filtro:")
    print(f"   - Total ticks: {len(df_filtered):,}")
    print(f"   - Aproveitamento: {len(df_filtered)/len(df)*100:.1f}%")
    print(f"   - Descartado: {len(df) - len(df_filtered):,} ticks ({(1-len(df_filtered)/len(df))*100:.1f}%)")
    print(f"   - Densidade: {len(df_filtered) / df_filtered['datetime'].dt.date.nunique():.0f} ticks/dia")
    
    # Salvar
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    print(f"\n>> Salvando: {output_path.name}...")
    df_filtered.to_parquet(
        output_path,
        engine='pyarrow',
        compression='snappy',
        index=False
    )
    
    file_size_mb = output_path.stat().st_size / 1024**2
    print(f"   [OK] Salvo: {file_size_mb:.1f} MB (era {input_path.stat().st_size / 1024**2:.1f} MB)")
    print(f"   Reducao: {(1 - file_size_mb / (input_path.stat().st_size / 1024**2)) * 100:.1f}%")
    
    return df_filtered

if __name__ == "__main__":
    # Parquet atual
    input_path = Path("data/ticks/xauusd_2020_2024_stride20.parquet")
    output_path = Path("data/ticks/filtered/xauusd_2020_2024_stride20_filtered.parquet")
    
    if not input_path.exists():
        print(f"❌ Arquivo não encontrado: {input_path}")
        exit(1)
    
    # Processar
    df_filtered = filter_parquet(input_path, output_path)
    
    print("\n" + "="*80)
    print("[OK] FILTRO CONCLUIDO!")
    print("="*80)
    print(f"\n>> Novo arquivo: {output_path}")
    print(f"\n>> Proximos passos:")
    print(f"   1. Rodar: python check_data_quality.py (atualizar path no script)")
    print(f"   2. Testar backtest com dados filtrados")
    print(f"   3. Se OK -> mover para data/ticks/")
