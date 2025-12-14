#!/usr/bin/env python3
"""
FORGE v3.1 - MQL5 Complexity Analyzer (GENIUS EDITION)

Analyzes MQL5 code for:
- Cyclomatic Complexity (McCabe)
- Cognitive Complexity
- Nesting Depth
- Function Length
- Parameter Count
- Code Smells

Based on scientific metrics used by SonarQube, CodeClimate, etc.

Usage:
    python mql5_complexity_analyzer.py <file.mqh>
    python mql5_complexity_analyzer.py --all
    python mql5_complexity_analyzer.py --report
"""

import sys
import re
from pathlib import Path
from dataclasses import dataclass, field
from typing import List, Dict, Tuple, Optional
import json

# =============================================================================
# DATA STRUCTURES
# =============================================================================

@dataclass
class FunctionMetrics:
    """Metrics for a single function."""
    name: str
    file: str
    line_start: int
    line_end: int
    length: int  # Lines of code
    cyclomatic_complexity: int  # McCabe complexity
    cognitive_complexity: int  # Cognitive complexity
    max_nesting_depth: int
    parameter_count: int
    return_statements: int
    
    @property
    def risk_level(self) -> str:
        """Calculate risk level based on metrics."""
        score = 0
        
        # Cyclomatic complexity scoring
        if self.cyclomatic_complexity > 20:
            score += 3
        elif self.cyclomatic_complexity > 10:
            score += 2
        elif self.cyclomatic_complexity > 5:
            score += 1
        
        # Length scoring
        if self.length > 100:
            score += 3
        elif self.length > 50:
            score += 2
        elif self.length > 30:
            score += 1
        
        # Nesting scoring
        if self.max_nesting_depth > 5:
            score += 3
        elif self.max_nesting_depth > 4:
            score += 2
        elif self.max_nesting_depth > 3:
            score += 1
        
        # Parameter scoring
        if self.parameter_count > 7:
            score += 2
        elif self.parameter_count > 5:
            score += 1
        
        if score >= 6:
            return "CRITICAL"
        elif score >= 4:
            return "HIGH"
        elif score >= 2:
            return "MEDIUM"
        else:
            return "LOW"

@dataclass
class FileMetrics:
    """Metrics for an entire file."""
    path: str
    total_lines: int
    code_lines: int
    comment_lines: int
    blank_lines: int
    functions: List[FunctionMetrics] = field(default_factory=list)
    classes: int = 0
    includes: int = 0
    globals: int = 0
    
    @property
    def avg_complexity(self) -> float:
        if not self.functions:
            return 0.0
        return sum(f.cyclomatic_complexity for f in self.functions) / len(self.functions)
    
    @property
    def max_complexity(self) -> int:
        if not self.functions:
            return 0
        return max(f.cyclomatic_complexity for f in self.functions)
    
    @property
    def code_smells(self) -> List[str]:
        smells = []
        for func in self.functions:
            if func.cyclomatic_complexity > 10:
                smells.append(f"{func.name}: Cyclomatic complexity {func.cyclomatic_complexity} > 10")
            if func.length > 50:
                smells.append(f"{func.name}: Function length {func.length} > 50 lines")
            if func.max_nesting_depth > 4:
                smells.append(f"{func.name}: Nesting depth {func.max_nesting_depth} > 4")
            if func.parameter_count > 5:
                smells.append(f"{func.name}: Parameter count {func.parameter_count} > 5")
        return smells

# =============================================================================
# MQL5 PARSER
# =============================================================================

class MQL5Parser:
    """Simple MQL5 parser for complexity analysis."""
    
    # Patterns that increase cyclomatic complexity
    COMPLEXITY_PATTERNS = [
        r'\bif\s*\(',
        r'\belse\s+if\s*\(',
        r'\bwhile\s*\(',
        r'\bfor\s*\(',
        r'\bcase\s+',
        r'\bcatch\s*\(',
        r'\?\s*[^:]+\s*:',  # Ternary operator
        r'\b(&&|\|\|)\b',   # Logical operators
    ]
    
    # Patterns that increase cognitive complexity
    COGNITIVE_PATTERNS = [
        (r'\bif\s*\(', 1),
        (r'\belse\s+if\s*\(', 1),
        (r'\belse\s*{', 1),
        (r'\bwhile\s*\(', 1),
        (r'\bfor\s*\(', 1),
        (r'\bswitch\s*\(', 1),
        (r'\bcatch\s*\(', 1),
        (r'\bgoto\s+', 2),  # goto is extra bad
        (r'\bbreak\s*;', 0),  # break doesn't add complexity
        (r'\bcontinue\s*;', 1),
        (r'&&', 1),
        (r'\|\|', 1),
    ]
    
    # Function definition pattern for MQL5
    FUNCTION_PATTERN = re.compile(
        r'^[\s]*((?:static\s+)?(?:virtual\s+)?(?:const\s+)?'
        r'(?:void|bool|int|uint|long|ulong|double|float|string|datetime|color|'
        r'ENUM_\w+|[A-Z]\w*(?:\s*[*&])?)\s+)'
        r'(\w+)\s*\(([^)]*)\)',
        re.MULTILINE
    )
    
    # Class definition pattern
    CLASS_PATTERN = re.compile(r'\bclass\s+(\w+)')
    
    def __init__(self, content: str, filepath: str):
        self.content = content
        self.filepath = filepath
        self.lines = content.split('\n')
    
    def analyze(self) -> FileMetrics:
        """Analyze the entire file."""
        metrics = FileMetrics(
            path=self.filepath,
            total_lines=len(self.lines),
            code_lines=0,
            comment_lines=0,
            blank_lines=0,
        )
        
        in_multiline_comment = False
        
        for line in self.lines:
            stripped = line.strip()
            
            if not stripped:
                metrics.blank_lines += 1
            elif stripped.startswith('//'):
                metrics.comment_lines += 1
            elif '/*' in stripped:
                metrics.comment_lines += 1
                in_multiline_comment = True
            elif '*/' in stripped:
                metrics.comment_lines += 1
                in_multiline_comment = False
            elif in_multiline_comment:
                metrics.comment_lines += 1
            else:
                metrics.code_lines += 1
            
            # Count includes
            if stripped.startswith('#include'):
                metrics.includes += 1
            
            # Count global variables (rough heuristic)
            if re.match(r'^(static\s+)?(const\s+)?\w+\s+g_\w+', stripped):
                metrics.globals += 1
        
        # Count classes
        metrics.classes = len(self.CLASS_PATTERN.findall(self.content))
        
        # Analyze functions
        metrics.functions = self._analyze_functions()
        
        return metrics
    
    def _analyze_functions(self) -> List[FunctionMetrics]:
        """Extract and analyze all functions."""
        functions = []
        
        # Find all function definitions
        for match in self.FUNCTION_PATTERN.finditer(self.content):
            func_name = match.group(2)
            params = match.group(3)
            start_pos = match.start()
            
            # Find line number
            line_start = self.content[:start_pos].count('\n') + 1
            
            # Find function body (matching braces)
            body_start = self.content.find('{', match.end())
            if body_start == -1:
                continue
            
            body_end = self._find_matching_brace(body_start)
            if body_end == -1:
                continue
            
            line_end = self.content[:body_end].count('\n') + 1
            func_body = self.content[body_start:body_end + 1]
            
            # Calculate metrics
            func_metrics = FunctionMetrics(
                name=func_name,
                file=self.filepath,
                line_start=line_start,
                line_end=line_end,
                length=line_end - line_start + 1,
                cyclomatic_complexity=self._calc_cyclomatic(func_body),
                cognitive_complexity=self._calc_cognitive(func_body),
                max_nesting_depth=self._calc_nesting_depth(func_body),
                parameter_count=self._count_parameters(params),
                return_statements=func_body.count('return ')
            )
            
            functions.append(func_metrics)
        
        return functions
    
    def _find_matching_brace(self, start: int) -> int:
        """Find the matching closing brace."""
        depth = 0
        i = start
        while i < len(self.content):
            if self.content[i] == '{':
                depth += 1
            elif self.content[i] == '}':
                depth -= 1
                if depth == 0:
                    return i
            i += 1
        return -1
    
    def _calc_cyclomatic(self, body: str) -> int:
        """Calculate McCabe cyclomatic complexity."""
        complexity = 1  # Base complexity
        
        for pattern in self.COMPLEXITY_PATTERNS:
            matches = re.findall(pattern, body)
            complexity += len(matches)
        
        return complexity
    
    def _calc_cognitive(self, body: str) -> int:
        """Calculate cognitive complexity (more nuanced than cyclomatic)."""
        complexity = 0
        nesting = 0
        
        for line in body.split('\n'):
            stripped = line.strip()
            
            # Increase nesting for control structures
            if re.search(r'\b(if|for|while|switch)\s*\(', stripped):
                complexity += 1 + nesting  # Nesting adds to complexity
                nesting += 1
            elif re.search(r'\belse\s*{', stripped):
                complexity += 1
            
            # Decrease nesting at closing braces (rough heuristic)
            if stripped == '}' and nesting > 0:
                nesting -= 1
            
            # Logical operators add complexity
            complexity += stripped.count('&&')
            complexity += stripped.count('||')
        
        return complexity
    
    def _calc_nesting_depth(self, body: str) -> int:
        """Calculate maximum nesting depth."""
        max_depth = 0
        current_depth = 0
        
        for char in body:
            if char == '{':
                current_depth += 1
                max_depth = max(max_depth, current_depth)
            elif char == '}':
                current_depth = max(0, current_depth - 1)
        
        return max_depth
    
    def _count_parameters(self, params: str) -> int:
        """Count function parameters."""
        if not params.strip():
            return 0
        # Split by comma, but be careful with template parameters
        return len([p for p in params.split(',') if p.strip()])

# =============================================================================
# TRADING MATH VERIFIER
# =============================================================================

class TradingMathVerifier:
    """Verify mathematical correctness of trading formulas."""
    
    TRADING_PATTERNS = {
        'position_sizing': {
            'pattern': r'(\w+)\s*=\s*[^;]*risk[^;]*/[^;]*sl[^;]*tick',
            'checks': [
                'Division by zero guard for tick_value?',
                'Division by zero guard for sl_pips?',
                'NormalizeLot() applied?',
                'Min/Max lot limits checked?',
            ]
        },
        'drawdown_calc': {
            'pattern': r'(\w+)\s*=\s*\([^)]*peak[^)]*-[^)]*current[^)]*\)\s*/\s*peak',
            'checks': [
                'Peak can never be zero?',
                'Peak >= current always?',
                'Using EQUITY not BALANCE?',
                'High-water mark updated?',
            ]
        },
        'risk_percent': {
            'pattern': r'(\w+)\s*=\s*[^;]*equity[^;]*\*[^;]*risk[^;]*/\s*100',
            'checks': [
                'Equity > 0 verified?',
                'Risk percent within limits (0.5-2%)?',
                'Result clamped to max risk amount?',
            ]
        },
        'sl_distance': {
            'pattern': r'sl[^=]*=\s*[^;]*(?:entry|price)[^;]*[-+][^;]*atr',
            'checks': [
                'Direction correct for BUY vs SELL?',
                'ATR handle validated?',
                'Minimum SL distance enforced?',
                'Maximum SL distance enforced?',
            ]
        },
        'tp_calculation': {
            'pattern': r'tp[^=]*=\s*[^;]*(?:entry|sl)[^;]*\*[^;]*(?:rr|ratio)',
            'checks': [
                'Direction correct for BUY vs SELL?',
                'R:R ratio > 1.0?',
                'TP not beyond realistic range?',
            ]
        },
    }
    
    def verify(self, content: str) -> Dict[str, List[str]]:
        """Verify trading math in code."""
        findings = {}
        
        for name, config in self.TRADING_PATTERNS.items():
            matches = re.findall(config['pattern'], content, re.IGNORECASE)
            if matches:
                findings[name] = {
                    'found_in': matches,
                    'verify_checklist': config['checks']
                }
        
        return findings

# =============================================================================
# REPORT GENERATOR
# =============================================================================

def generate_report(metrics: List[FileMetrics], output_path: Optional[Path] = None) -> str:
    """Generate a comprehensive complexity report."""
    
    report = []
    report.append("=" * 70)
    report.append("FORGE v3.1 - MQL5 COMPLEXITY ANALYSIS REPORT")
    report.append("=" * 70)
    report.append("")
    
    # Summary
    total_functions = sum(len(m.functions) for m in metrics)
    total_smells = sum(len(m.code_smells) for m in metrics)
    critical_functions = sum(
        1 for m in metrics for f in m.functions if f.risk_level == "CRITICAL"
    )
    high_functions = sum(
        1 for m in metrics for f in m.functions if f.risk_level == "HIGH"
    )
    
    report.append("SUMMARY")
    report.append("-" * 40)
    report.append(f"Files analyzed:        {len(metrics)}")
    report.append(f"Total functions:       {total_functions}")
    report.append(f"Total code smells:     {total_smells}")
    report.append(f"Critical risk funcs:   {critical_functions}")
    report.append(f"High risk functions:   {high_functions}")
    report.append("")
    
    # Critical functions
    if critical_functions > 0:
        report.append("🔴 CRITICAL RISK FUNCTIONS (Refactor Immediately)")
        report.append("-" * 40)
        for m in metrics:
            for f in m.functions:
                if f.risk_level == "CRITICAL":
                    report.append(f"  {f.name} ({Path(m.path).name}:{f.line_start})")
                    report.append(f"    Cyclomatic: {f.cyclomatic_complexity}, "
                                f"Nesting: {f.max_nesting_depth}, "
                                f"Length: {f.length}")
        report.append("")
    
    # High risk functions
    if high_functions > 0:
        report.append("🟠 HIGH RISK FUNCTIONS (Consider Refactoring)")
        report.append("-" * 40)
        for m in metrics:
            for f in m.functions:
                if f.risk_level == "HIGH":
                    report.append(f"  {f.name} ({Path(m.path).name}:{f.line_start})")
                    report.append(f"    Cyclomatic: {f.cyclomatic_complexity}, "
                                f"Nesting: {f.max_nesting_depth}, "
                                f"Length: {f.length}")
        report.append("")
    
    # Code smells by file
    report.append("CODE SMELLS BY FILE")
    report.append("-" * 40)
    for m in metrics:
        if m.code_smells:
            report.append(f"\n📁 {Path(m.path).name}")
            for smell in m.code_smells:
                report.append(f"  ⚠️  {smell}")
    report.append("")
    
    # Complexity thresholds reference
    report.append("THRESHOLDS REFERENCE")
    report.append("-" * 40)
    report.append("Cyclomatic Complexity:")
    report.append("  1-5:   LOW (simple, easy to test)")
    report.append("  6-10:  MEDIUM (moderate complexity)")
    report.append("  11-20: HIGH (complex, hard to test)")
    report.append("  >20:   CRITICAL (very complex, refactor!)")
    report.append("")
    report.append("Function Length:")
    report.append("  <30:   Ideal")
    report.append("  30-50: Acceptable")
    report.append("  >50:   Too long, split it")
    report.append("")
    report.append("Nesting Depth:")
    report.append("  ≤3:    Good")
    report.append("  4:     Acceptable")
    report.append("  >4:    Too deep, flatten logic")
    report.append("")
    report.append("=" * 70)
    
    report_text = "\n".join(report)
    
    if output_path:
        output_path.write_text(report_text, encoding='utf-8')
    
    return report_text

# =============================================================================
# MAIN
# =============================================================================

def analyze_file(filepath: Path) -> FileMetrics:
    """Analyze a single MQL5 file."""
    content = filepath.read_text(encoding='utf-8', errors='ignore')
    parser = MQL5Parser(content, str(filepath))
    return parser.analyze()

def main():
    if len(sys.argv) < 2:
        print("Usage: python mql5_complexity_analyzer.py <file.mqh>")
        print("       python mql5_complexity_analyzer.py --all")
        print("       python mql5_complexity_analyzer.py --report")
        sys.exit(1)
    
    mql5_dir = Path(r'C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MQL5')
    
    if sys.argv[1] == '--all' or sys.argv[1] == '--report':
        files = list(mql5_dir.rglob('*.mqh')) + list(mql5_dir.rglob('*.mq5'))
        files = [f for f in files if 'backup' not in str(f).lower()]
    else:
        filepath = Path(sys.argv[1])
        if not filepath.exists():
            # Try to find in MQL5 dir
            found = list(mql5_dir.rglob(f'*{filepath.name}*'))
            if found:
                filepath = found[0]
            else:
                print(f"[ERROR] File not found: {filepath}")
                sys.exit(1)
        files = [filepath]
    
    metrics_list = []
    for f in files:
        try:
            metrics = analyze_file(f)
            metrics_list.append(metrics)
        except Exception as e:
            print(f"[WARN] Could not analyze {f}: {e}")
    
    if sys.argv[1] == '--report':
        report_path = mql5_dir.parent / 'DOCS' / '04_REPORTS' / 'COMPLEXITY_REPORT.md'
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report = generate_report(metrics_list, report_path)
        print(report)
        print(f"\n[INFO] Report saved to: {report_path}")
    else:
        # Print individual file analysis
        for metrics in metrics_list:
            print(f"\n{'='*60}")
            print(f"FILE: {Path(metrics.path).name}")
            print('='*60)
            print(f"Lines: {metrics.total_lines} total, {metrics.code_lines} code, "
                  f"{metrics.comment_lines} comment, {metrics.blank_lines} blank")
            print(f"Classes: {metrics.classes}, Functions: {len(metrics.functions)}, "
                  f"Includes: {metrics.includes}")
            
            if metrics.functions:
                print(f"\nAvg Complexity: {metrics.avg_complexity:.1f}, "
                      f"Max Complexity: {metrics.max_complexity}")
                
                print("\nFUNCTIONS:")
                for f in sorted(metrics.functions, 
                              key=lambda x: x.cyclomatic_complexity, reverse=True)[:10]:
                    risk_icon = {
                        'CRITICAL': '🔴',
                        'HIGH': '🟠', 
                        'MEDIUM': '🟡',
                        'LOW': '🟢'
                    }.get(f.risk_level, '⚪')
                    print(f"  {risk_icon} {f.name}()")
                    print(f"      Lines: {f.line_start}-{f.line_end} ({f.length}), "
                          f"CC: {f.cyclomatic_complexity}, "
                          f"Nesting: {f.max_nesting_depth}, "
                          f"Params: {f.parameter_count}")
            
            if metrics.code_smells:
                print("\n⚠️  CODE SMELLS:")
                for smell in metrics.code_smells:
                    print(f"  - {smell}")
    
    # Also run trading math verifier
    if '--math' in sys.argv or '--all' in sys.argv or '--report' in sys.argv:
        print(f"\n{'='*60}")
        print("TRADING MATH VERIFICATION")
        print('='*60)
        verifier = TradingMathVerifier()
        for f in files:
            content = f.read_text(encoding='utf-8', errors='ignore')
            findings = verifier.verify(content)
            if findings:
                print(f"\n📐 {Path(f).name}:")
                for pattern_name, data in findings.items():
                    print(f"  {pattern_name}: Found in {data['found_in']}")
                    print("  Verify:")
                    for check in data['verify_checklist']:
                        print(f"    □ {check}")

if __name__ == '__main__':
    main()
