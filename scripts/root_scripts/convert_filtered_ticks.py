"""
Conversão inteligente de CSV fonte → Parquet filtrado com sessões tradeáveis.

GENIUS v1.0 - Processamento otimizado com chunking, filtro inline, progress bar.
"""
import pandas as pd
import numpy as np
from pathlib import Path
from datetime import datetime, time
import pytz
from tqdm import tqdm
import argparse

# Configurações
TRADEABLE_HOURS_GMT = range(7, 17)  # 07:00-17:00 GMT (London + Overlap + NY)
CHUNK_SIZE = 100_000  # Linhas por chunk (otimizado para memória)

def parse_ftmo_datetime(date_str):
    """Parse formato FTMO: YYYYMMDD HH:MM:SS.mmm"""
    return pd.to_datetime(date_str, format='%Y%m%d %H:%M:%S.%f')

def validate_csv_source(csv_path, sample_lines=10000):
    """Valida formato do CSV fonte."""
    print("\n" + "="*80)
    print("FASE 1 - VALIDAÇÃO DO CSV FONTE")
    print("="*80)
    
    print(f"\nArquivo: {csv_path.name}")
    print(f"Tamanho: {csv_path.stat().st_size / 1024**3:.2f} GB")
    
    # Ler primeiras linhas para validar formato
    print(f"\nLendo primeiras {sample_lines:,} linhas para validação...")
    df_sample = pd.read_csv(
        csv_path,
        nrows=sample_lines,
        header=None,
        names=['datetime', 'bid', 'ask']
    )
    
    # Parse datetime
    df_sample['datetime'] = parse_ftmo_datetime(df_sample['datetime'])
    
    print(f"\n✅ Formato validado:")
    print(f"   - Colunas: datetime, bid, ask")
    print(f"   - Primeiro tick: {df_sample['datetime'].iloc[0]}")
    print(f"   - Último tick (amostra): {df_sample['datetime'].iloc[-1]}")
    print(f"   - Bid range: {df_sample['bid'].min():.2f} - {df_sample['bid'].max():.2f}")
    print(f"   - Ask range: {df_sample['ask'].min():.2f} - {df_sample['ask'].max():.2f}")
    
    # Verificar timezone (assumindo UTC/GMT)
    df_sample['hour'] = df_sample['datetime'].dt.hour
    hour_dist = df_sample['hour'].value_counts().sort_index()
    print(f"\n   - Distribuição por hora (amostra):")
    for hour, count in hour_dist.head(5).items():
        print(f"     {hour:02d}:00 → {count:,} ticks")
    
    return df_sample

def count_total_lines(csv_path):
    """Conta total de linhas no CSV (rápido)."""
    print(f"\n📊 Contando total de linhas no CSV...")
    
    # Método rápido: ler em chunks grandes e somar
    total = 0
    with open(csv_path, 'r') as f:
        for chunk in pd.read_csv(f, chunksize=1_000_000, header=None, usecols=[0]):
            total += len(chunk)
    
    print(f"   Total: {total:,} linhas")
    return total

def process_csv_filtered(
    csv_path, 
    output_dir, 
    strides=[5, 10, 20],
    start_date=None,
    end_date=None,
    dry_run=False
):
    """
    Processa CSV com filtro de sessões tradeáveis.
    
    Args:
        csv_path: Path do CSV fonte
        output_dir: Diretório de saída
        strides: Lista de strides a gerar
        start_date: Filtro inicial (YYYY-MM-DD)
        end_date: Filtro final (YYYY-MM-DD)
        dry_run: Se True, não salva arquivos (apenas validação)
    """
    print("\n" + "="*80)
    print("FASE 2 - PROCESSAMENTO COM FILTRO")
    print("="*80)
    
    if start_date:
        print(f"\n📅 Período: {start_date} até {end_date or 'fim'}")
    
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Contagem rápida (opcional - pode comentar se demora muito)
    # total_lines = count_total_lines(csv_path)
    
    # Coletar todos os dados filtrados
    print(f"\n🔄 Processando CSV com chunking ({CHUNK_SIZE:,} linhas/chunk)...")
    print(f"   Filtro: 07:00-17:00 GMT (London + Overlap + NY)")
    
    all_data = []
    total_ticks_read = 0
    total_ticks_filtered = 0
    
    # Progress bar estimado
    pbar = tqdm(desc="Processando", unit=" chunks")
    
    for chunk in pd.read_csv(
        csv_path,
        chunksize=CHUNK_SIZE,
        header=None,
        names=['datetime', 'bid', 'ask']
    ):
        total_ticks_read += len(chunk)
        
        # Parse datetime
        chunk['datetime'] = parse_ftmo_datetime(chunk['datetime'])
        
        # Filtro por data (se especificado)
        if start_date:
            chunk = chunk[chunk['datetime'] >= pd.Timestamp(start_date)]
        if end_date:
            chunk = chunk[chunk['datetime'] <= pd.Timestamp(end_date) + pd.Timedelta(days=1)]
        
        # Filtro por hora GMT (07:00-17:00)
        chunk = chunk[chunk['datetime'].dt.hour.isin(TRADEABLE_HOURS_GMT)]
        
        total_ticks_filtered += len(chunk)
        
        if len(chunk) > 0:
            all_data.append(chunk)
        
        pbar.update(1)
        pbar.set_postfix({
            'lidos': f"{total_ticks_read:,}",
            'filtrados': f"{total_ticks_filtered:,}",
            'aproveitamento': f"{total_ticks_filtered/total_ticks_read*100:.1f}%"
        })
    
    pbar.close()
    
    # Concatenar todos os chunks
    print(f"\n📦 Consolidando dados...")
    df = pd.concat(all_data, ignore_index=True)
    
    print(f"\n✅ Filtro aplicado:")
    print(f"   - Total lido: {total_ticks_read:,} ticks")
    print(f"   - Após filtro: {total_ticks_filtered:,} ticks ({total_ticks_filtered/total_ticks_read*100:.1f}%)")
    print(f"   - Descartado: {total_ticks_read - total_ticks_filtered:,} ticks ({(1-total_ticks_filtered/total_ticks_read)*100:.1f}%)")
    
    # Estatísticas
    print(f"\n📊 Estatísticas dos dados filtrados:")
    print(f"   - Período: {df['datetime'].min()} até {df['datetime'].max()}")
    print(f"   - Dias únicos: {df['datetime'].dt.date.nunique()}")
    print(f"   - Média ticks/dia: {len(df) / df['datetime'].dt.date.nunique():.0f}")
    
    # Calcular mid price
    df['mid'] = (df['bid'] + df['ask']) / 2.0
    
    # Gerar versões com diferentes strides
    print(f"\n" + "-"*80)
    print("FASE 3 - GERANDO VERSÕES COM STRIDE")
    print("-"*80)
    
    results = {}
    for stride in strides:
        print(f"\n📌 Gerando stride{stride}...")
        
        # Aplicar stride
        df_stride = df.iloc[::stride].copy()
        
        # Adicionar timezone UTC se necessário
        if df_stride['datetime'].dt.tz is None:
            df_stride['datetime'] = df_stride['datetime'].dt.tz_localize('UTC')
        
        print(f"   - Ticks após stride: {len(df_stride):,}")
        print(f"   - Densidade média: {len(df_stride) / df['datetime'].dt.date.nunique():.0f} ticks/dia")
        
        # Nome do arquivo
        period_str = f"{start_date}_{end_date}" if start_date else "2020_2024"
        filename = f"xauusd_{period_str}_stride{stride}_filtered.parquet"
        output_path = output_dir / filename
        
        if not dry_run:
            # Salvar parquet com compressão
            print(f"   - Salvando: {filename}...")
            df_stride.to_parquet(
                output_path,
                engine='pyarrow',
                compression='snappy',
                index=False
            )
            
            file_size_mb = output_path.stat().st_size / 1024**2
            print(f"   ✅ Salvo: {file_size_mb:.1f} MB")
        else:
            print(f"   ⚠️ DRY RUN - não salvando arquivo")
        
        results[stride] = {
            'ticks': len(df_stride),
            'path': output_path,
            'density': len(df_stride) / df['datetime'].dt.date.nunique()
        }
    
    return results

def main():
    parser = argparse.ArgumentParser(description='Converter CSV FTMO para Parquet filtrado')
    parser.add_argument('--start-date', type=str, help='Data inicial (YYYY-MM-DD)')
    parser.add_argument('--end-date', type=str, help='Data final (YYYY-MM-DD)')
    parser.add_argument('--strides', type=str, default='5,10,20', help='Strides separados por vírgula')
    parser.add_argument('--dry-run', action='store_true', help='Não salvar arquivos (apenas teste)')
    parser.add_argument('--csv', type=str, help='Path do CSV fonte (opcional)')
    
    args = parser.parse_args()
    
    # Localizar CSV fonte
    if args.csv:
        csv_path = Path(args.csv)
    else:
        # Usar padrão
        csv_path = Path("Python_Agent_Hub/ml_pipeline/data/CSV-2020-2025XAUUSD_ftmo-TICK-No Session.csv")
    
    if not csv_path.exists():
        print(f"❌ ERRO: CSV não encontrado: {csv_path}")
        return
    
    # Validar CSV
    validate_csv_source(csv_path)
    
    # Processar
    strides = [int(s.strip()) for s in args.strides.split(',')]
    output_dir = Path("data/ticks/filtered")
    
    results = process_csv_filtered(
        csv_path=csv_path,
        output_dir=output_dir,
        strides=strides,
        start_date=args.start_date,
        end_date=args.end_date,
        dry_run=args.dry_run
    )
    
    # Sumário final
    print("\n" + "="*80)
    print("SUMÁRIO FINAL")
    print("="*80)
    
    for stride, info in results.items():
        print(f"\nStride {stride}:")
        print(f"  - Ticks: {info['ticks']:,}")
        print(f"  - Densidade: {info['density']:.0f} ticks/dia")
        if not args.dry_run:
            print(f"  - Arquivo: {info['path'].name}")
    
    print("\n✅ Processamento concluído!")
    
    if not args.dry_run:
        print(f"\n📂 Arquivos salvos em: {output_dir.absolute()}")
        print("\n🔍 Próximo passo: Rodar check_data_quality.py para validar")

if __name__ == "__main__":
    main()
