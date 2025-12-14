#!/usr/bin/env python3
"""
FORGE v3.0 Pre-Check Script
Runs basic checks BEFORE compilation to catch common issues early.

Usage:
    python forge_precheck.py <file.mqh>
    python forge_precheck.py --all  # Check all MQL5 files
"""

import sys
import re
from pathlib import Path
from typing import List, Tuple

# Bug patterns from BUGFIX_LOG (condensed)
BUG_PATTERNS = [
    # BP-01: OrderSend sem check
    (r'OrderSend\s*\([^)]+\)\s*;', 'BP-01: OrderSend sem verificacao de retorno'),
    
    # BP-02: CopyBuffer sem ArraySetAsSeries
    (r'CopyBuffer\s*\([^)]+\)(?!.*ArraySetAsSeries)', 'BP-02: CopyBuffer pode precisar de ArraySetAsSeries'),
    
    # BP-04: Divisao sem guard
    (r'[^/]/\s*[a-zA-Z_][a-zA-Z0-9_]*(?!\s*!=\s*0)(?!\s*>\s*0)', 'BP-04: Divisao potencial sem guard de zero'),
    
    # BP-06: Handle sem INVALID_HANDLE check
    (r'i(ATR|RSI|MA|MACD|Stochastic)\s*\([^)]+\)\s*;(?!.*INVALID_HANDLE)', 'BP-06: Handle de indicador pode nao estar validado'),
    
    # AP-08: Print em OnTick
    (r'void\s+OnTick\s*\([^)]*\)[^}]*Print\s*\(', 'AP-08: Print dentro de OnTick (performance)'),
]

# Anti-patterns
ANTI_PATTERNS = [
    (r'new\s+C[a-zA-Z]+(?!.*delete)', 'AP-07: new sem delete correspondente (verificar)'),
    (r'Sleep\s*\(\s*\d+\s*\)', 'AP-09: Sleep em EA pode travar'),
    (r'ACCOUNT_BALANCE(?!.*ACCOUNT_EQUITY)', 'Possivel uso de Balance em vez de Equity para DD'),
]

def check_file(filepath: Path) -> List[Tuple[int, str, str]]:
    """Check a single file for patterns. Returns list of (line_num, pattern_id, content)."""
    issues = []
    
    try:
        content = filepath.read_text(encoding='utf-8', errors='ignore')
        lines = content.split('\n')
        
        for line_num, line in enumerate(lines, 1):
            # Skip comments
            if line.strip().startswith('//'):
                continue
            
            for pattern, message in BUG_PATTERNS + ANTI_PATTERNS:
                if re.search(pattern, line, re.IGNORECASE):
                    issues.append((line_num, message, line.strip()[:60]))
        
    except Exception as e:
        issues.append((0, f'Error reading file: {e}', ''))
    
    return issues

def check_dependencies(filepath: Path, mql5_dir: Path) -> List[str]:
    """Find files that depend on this module."""
    module_name = filepath.stem
    dependents = []
    
    for f in mql5_dir.rglob('*.mq*'):
        if f == filepath:
            continue
        try:
            content = f.read_text(encoding='utf-8', errors='ignore')
            if f'#include' in content and module_name in content:
                dependents.append(f.relative_to(mql5_dir))
        except:
            pass
    
    return dependents

def main():
    if len(sys.argv) < 2:
        print("Usage: python forge_precheck.py <file.mqh> [--deps]")
        print("       python forge_precheck.py --all")
        sys.exit(1)
    
    mql5_dir = Path(r'C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MQL5')
    
    if sys.argv[1] == '--all':
        files = list(mql5_dir.rglob('*.mqh')) + list(mql5_dir.rglob('*.mq5'))
    else:
        files = [Path(sys.argv[1])]
    
    check_deps = '--deps' in sys.argv
    
    total_issues = 0
    
    for filepath in files:
        if not filepath.exists():
            print(f"[ERROR] File not found: {filepath}")
            continue
        
        issues = check_file(filepath)
        
        if issues:
            print(f"\n{'='*60}")
            print(f"FILE: {filepath.name}")
            print('='*60)
            for line_num, message, content in issues:
                print(f"  L{line_num:4d}: {message}")
                if content:
                    print(f"         {content}...")
            total_issues += len(issues)
        
        if check_deps:
            deps = check_dependencies(filepath, mql5_dir)
            if deps:
                print(f"\n  DEPENDENTS ({len(deps)}):")
                for d in deps[:10]:  # Limit to 10
                    print(f"    - {d}")
                if len(deps) > 10:
                    print(f"    ... and {len(deps)-10} more")
    
    print(f"\n{'='*60}")
    print(f"TOTAL ISSUES FOUND: {total_issues}")
    if total_issues > 0:
        print("⚠️  Review issues before compiling")
    else:
        print("✅ No obvious issues detected")
    print('='*60)
    
    return 0 if total_issues == 0 else 1

if __name__ == '__main__':
    sys.exit(main())
