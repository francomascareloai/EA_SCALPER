#!/usr/bin/env python3
# Script para encontrar strings de documentação não fechadas

file_path = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MCP_Integration\servers\test_automation_mcp.py"

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

triple_quote_count = 0
open_docstring_line = None

for i, line in enumerate(lines, 1):
    if '"""' in line:
        count_in_line = line.count('"""')
        print(f"Line {i}: Found {count_in_line} triple quotes - {line.strip()}")
        
        triple_quote_count += count_in_line
        
        if triple_quote_count % 2 == 1 and open_docstring_line is None:
            open_docstring_line = i
            print(f"  -> Docstring opened at line {i}")
        elif triple_quote_count % 2 == 0 and open_docstring_line is not None:
            print(f"  -> Docstring closed (opened at line {open_docstring_line})")
            open_docstring_line = None

if open_docstring_line is not None:
    print(f"\nERROR: Unclosed docstring starting at line {open_docstring_line}")
else:
    print("\nAll docstrings are properly closed.")

print(f"\nTotal triple quote count: {triple_quote_count}")
if triple_quote_count % 2 != 0:
    print("ERROR: Odd number of triple quotes - there's an unclosed docstring!")