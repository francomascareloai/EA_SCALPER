#!/usr/bin/env python3
"""
FORGE v3.0 Regression Checker
Finds all files that depend on a given module to assess impact of changes.

Usage:
    python check_regression.py CRegimeDetector
    python check_regression.py CTradeManager.mqh
"""

import sys
from pathlib import Path
from typing import Dict, List, Set

# Critical modules that affect many others
CRITICAL_MODULES = {
    'Definitions.mqh': 'MAXIMA - Todos dependem',
    'FTMO_RiskManager.mqh': 'MAXIMA - FTMO compliance',
    'CTradeManager.mqh': 'ALTA - Gerencia posicoes',
    'TradeExecutor.mqh': 'ALTA - Executa ordens',
    'CConfluenceScorer.mqh': 'MEDIA - Agrega sinais',
}

def find_dependents(module_name: str, mql5_dir: Path) -> Dict[str, List[str]]:
    """Find all files that include or reference the given module."""
    
    # Normalize module name
    if not module_name.endswith('.mqh') and not module_name.endswith('.mq5'):
        module_name_base = module_name
    else:
        module_name_base = Path(module_name).stem
    
    dependents = {
        'direct_include': [],
        'class_usage': [],
        'function_calls': [],
    }
    
    # Search patterns
    include_pattern = f'#include.*{module_name_base}'
    class_pattern = f'{module_name_base}'  # Class name (assuming C prefix)
    
    for f in mql5_dir.rglob('*.mq*'):
        try:
            content = f.read_text(encoding='utf-8', errors='ignore')
            rel_path = str(f.relative_to(mql5_dir))
            
            # Check for #include
            if f'#include' in content and module_name_base in content:
                dependents['direct_include'].append(rel_path)
            
            # Check for class usage (instantiation or method calls)
            elif module_name_base in content:
                dependents['class_usage'].append(rel_path)
                
        except Exception as e:
            print(f"[WARN] Could not read {f}: {e}")
    
    return dependents

def get_criticality(module_name: str) -> str:
    """Get criticality level for a module."""
    for critical, description in CRITICAL_MODULES.items():
        if critical in module_name or module_name in critical:
            return description
    return 'BAIXA - Modulo independente'

def main():
    if len(sys.argv) < 2:
        print("Usage: python check_regression.py <ModuleName>")
        print("Example: python check_regression.py CRegimeDetector")
        sys.exit(1)
    
    module_name = sys.argv[1]
    mql5_dir = Path(r'C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MQL5')
    
    print(f"\n{'='*60}")
    print(f"REGRESSION CHECK: {module_name}")
    print('='*60)
    
    # Get criticality
    criticality = get_criticality(module_name)
    print(f"\nCRITICALIDADE: {criticality}")
    
    # Find dependents
    dependents = find_dependents(module_name, mql5_dir)
    
    total_dependents = sum(len(v) for v in dependents.values())
    
    if total_dependents == 0:
        print("\n✅ Nenhum dependente encontrado - mudanca segura")
    else:
        print(f"\n⚠️  TOTAL DEPENDENTES: {total_dependents}")
        
        if dependents['direct_include']:
            print(f"\n📦 DIRECT INCLUDES ({len(dependents['direct_include'])}):")
            for f in dependents['direct_include']:
                print(f"   - {f}")
        
        if dependents['class_usage']:
            print(f"\n🔗 CLASS USAGE ({len(dependents['class_usage'])}):")
            for f in dependents['class_usage'][:15]:
                print(f"   - {f}")
            if len(dependents['class_usage']) > 15:
                print(f"   ... and {len(dependents['class_usage'])-15} more")
    
    # Impact assessment
    print(f"\n{'='*60}")
    print("IMPACT ASSESSMENT:")
    print('='*60)
    
    if total_dependents > 10:
        print("🔴 ALTO IMPACTO - Mudanca afeta muitos modulos")
        print("   → Recomendado: Backtest completo apos mudanca")
        print("   → Handoff para ORACLE obrigatorio")
    elif total_dependents > 3:
        print("🟡 MEDIO IMPACTO - Mudanca afeta alguns modulos")
        print("   → Recomendado: Teste rapido apos mudanca")
    else:
        print("🟢 BAIXO IMPACTO - Mudanca relativamente isolada")
    
    print('='*60)
    
    return 0

if __name__ == '__main__':
    sys.exit(main())
