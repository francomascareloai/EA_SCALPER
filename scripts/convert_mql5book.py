"""Convert mql5book PDF to markdown for RAG indexing"""
from pypdf import PdfReader
import os
import sys
import warnings

warnings.filterwarnings('ignore')

pdf_path = r'C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\DOCS\BOOKS\mql5book (1).pdf'
output_path = r'C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\DOCS\BOOKS\mql5book_converted.md'

print(f"Reading PDF: {pdf_path}")
reader = PdfReader(pdf_path)
total_pages = len(reader.pages)
print(f"Total pages: {total_pages}")

with open(output_path, 'w', encoding='utf-8', errors='ignore') as f:
    f.write('# MQL5 Book - Complete Tutorial\n\n')
    
    for i, page in enumerate(reader.pages):
        try:
            text = page.extract_text()
            if text and text.strip():
                f.write(f'## Page {i+1}\n\n')
                f.write(text)
                f.write('\n\n---\n\n')
        except Exception as e:
            f.write(f'## Page {i+1}\n\n[Error extracting page]\n\n---\n\n')
        
        if (i+1) % 100 == 0:
            print(f"Progress: {i+1}/{total_pages} ({100*(i+1)//total_pages}%)")
            sys.stdout.flush()

size_mb = os.path.getsize(output_path) / (1024*1024)
print(f"\nDone! Output: {output_path}")
print(f"Size: {size_mb:.2f} MB")
