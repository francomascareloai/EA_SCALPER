"""Fast PDF to MD converter - processes in batches and saves incrementally"""
from pypdf import PdfReader
import os
import sys
import warnings
import time

warnings.filterwarnings('ignore')

pdf_path = r'C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\DOCS\BOOKS\mql5book (1).pdf'
output_dir = r'C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\DOCS\BOOKS\mql5book_parts'

# Create output directory
os.makedirs(output_dir, exist_ok=True)

print(f"Reading PDF: {pdf_path}")
start_time = time.time()

reader = PdfReader(pdf_path)
total_pages = len(reader.pages)
print(f"Total pages: {total_pages}")

# Process in batches of 200 pages
batch_size = 200
num_batches = (total_pages + batch_size - 1) // batch_size

for batch_num in range(num_batches):
    start_page = batch_num * batch_size
    end_page = min(start_page + batch_size, total_pages)
    
    output_path = os.path.join(output_dir, f'mql5book_part{batch_num+1:02d}.md')
    
    # Skip if already exists
    if os.path.exists(output_path):
        print(f"Part {batch_num+1}/{num_batches} already exists, skipping...")
        continue
    
    print(f"Processing Part {batch_num+1}/{num_batches} (pages {start_page+1}-{end_page})...")
    
    with open(output_path, 'w', encoding='utf-8', errors='ignore') as f:
        f.write(f'# MQL5 Book - Part {batch_num+1} (Pages {start_page+1}-{end_page})\n\n')
        
        for i in range(start_page, end_page):
            try:
                text = reader.pages[i].extract_text()
                if text and text.strip():
                    f.write(f'## Page {i+1}\n\n')
                    f.write(text)
                    f.write('\n\n---\n\n')
            except Exception as e:
                f.write(f'## Page {i+1}\n\n[Error extracting]\n\n---\n\n')
    
    size_kb = os.path.getsize(output_path) / 1024
    print(f"  Saved: {output_path} ({size_kb:.1f} KB)")

elapsed = time.time() - start_time
print(f"\nDone! Total time: {elapsed:.1f} seconds")
print(f"Output directory: {output_dir}")
