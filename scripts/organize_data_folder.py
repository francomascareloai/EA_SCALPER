"""
Script para organizar a pasta data/ e reduzir bagunça.
Remove duplicatas, arquivos temporários e organiza por categoria.
"""
from pathlib import Path
import shutil
from datetime import datetime
import json

def analyze_data_folder(data_path: Path):
    """Analisa conteúdo da pasta data."""
    print("="*60)
    print("ANÁLISE DA PASTA DATA/")
    print("="*60)
    
    # Estatísticas
    stats = {
        'csv_files': [],
        'parquet_files': [],
        'db_files': [],
        'duplicate_trades': [],
        'temp_files': [],
        'total_size_mb': 0
    }
    
    # Scan files
    for file in data_path.rglob('*'):
        if file.is_file():
            size_mb = file.stat().st_size / (1024 * 1024)
            stats['total_size_mb'] += size_mb
            
            if file.suffix == '.csv':
                stats['csv_files'].append({'path': file, 'size_mb': size_mb})
            elif file.suffix == '.parquet':
                stats['parquet_files'].append({'path': file, 'size_mb': size_mb})
            elif file.suffix == '.db':
                stats['db_files'].append({'path': file, 'size_mb': size_mb})
            
            # Detect duplicates
            if 'trade' in file.name.lower():
                stats['duplicate_trades'].append({'path': file, 'size_mb': size_mb})
    
    # Report
    print(f"\nTotal size: {stats['total_size_mb']:.2f} MB")
    print(f"CSV files: {len(stats['csv_files'])}")
    print(f"Parquet files: {len(stats['parquet_files'])}")
    print(f"DB files: {len(stats['db_files'])}")
    print(f"Trade CSVs (potential duplicates): {len(stats['duplicate_trades'])}")
    
    return stats


def create_organization_plan(stats: dict, data_path: Path):
    """Cria plano de organização."""
    plan = {
        'actions': [],
        'space_saved_mb': 0
    }
    
    # 1. Consolidar trade CSVs (muitos duplicados)
    print("\n" + "="*60)
    print("PLANO DE ORGANIZAÇÃO")
    print("="*60)
    
    print("\n1. Trade CSVs duplicados:")
    trade_csvs = sorted(stats['duplicate_trades'], key=lambda x: x['size_mb'], reverse=True)
    
    # Keep only the largest/most recent
    if len(trade_csvs) > 3:
        keep = trade_csvs[:3]
        archive = trade_csvs[3:]
        
        for f in keep:
            print(f"   KEEP: {f['path'].name} ({f['size_mb']:.2f} MB)")
        
        print(f"\n   ARCHIVE {len(archive)} files:")
        archive_folder = data_path / "_archived_trades"
        for f in archive:
            plan['actions'].append({
                'type': 'move',
                'src': f['path'],
                'dst': archive_folder / f['path'].name
            })
            plan['space_saved_mb'] += f['size_mb'] * 0.0  # Moving doesn't save space
            print(f"   -> {f['path'].name}")
    
    # 2. Remove temp DBs
    print("\n2. Database files:")
    for db in stats['db_files']:
        if 'demo' in db['path'].name or 'task' in db['path'].name:
            print(f"   DELETE: {db['path'].name} ({db['size_mb']:.2f} MB)")
            plan['actions'].append({
                'type': 'delete',
                'src': db['path']
            })
            plan['space_saved_mb'] += db['size_mb']
    
    # 3. Organize by type
    print("\n3. Organize remaining files:")
    print("   data/raw/ - Original CSVs")
    print("   data/processed/ - Parquet files")
    print("   data/results/ - Trade results")
    print("   data/archive/ - Old/unused files")
    
    return plan


def execute_plan(plan: dict, dry_run: bool = True):
    """Executa o plano de organização."""
    if dry_run:
        print("\n" + "="*60)
        print("DRY RUN - No files will be modified")
        print("="*60)
    else:
        print("\n" + "="*60)
        print("EXECUTING ORGANIZATION PLAN")
        print("="*60)
    
    for action in plan['actions']:
        if action['type'] == 'move':
            if dry_run:
                print(f"WOULD MOVE: {action['src'].name} -> {action['dst']}")
            else:
                action['dst'].parent.mkdir(parents=True, exist_ok=True)
                shutil.move(str(action['src']), str(action['dst']))
                print(f"MOVED: {action['src'].name}")
        
        elif action['type'] == 'delete':
            if dry_run:
                print(f"WOULD DELETE: {action['src'].name}")
            else:
                action['src'].unlink()
                print(f"DELETED: {action['src'].name}")
    
    print(f"\nSpace that would be saved: {plan['space_saved_mb']:.2f} MB")


def main():
    """Main entry point."""
    import argparse
    
    parser = argparse.ArgumentParser(description='Organize data/ folder')
    parser.add_argument('--execute', action='store_true', help='Execute plan (default: dry-run)')
    args = parser.parse_args()
    
    data_path = Path(__file__).parent.parent / 'data'
    
    if not data_path.exists():
        print(f"Error: {data_path} not found")
        return
    
    # Analyze
    stats = analyze_data_folder(data_path)
    
    # Plan
    plan = create_organization_plan(stats, data_path)
    
    # Execute (or dry-run)
    execute_plan(plan, dry_run=not args.execute)
    
    if not args.execute:
        print("\n" + "="*60)
        print("To execute, run with --execute flag")
        print("="*60)


if __name__ == "__main__":
    main()
