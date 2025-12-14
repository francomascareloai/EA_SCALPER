#!/usr/bin/env python3
"""
Index PDF books into RAG - Simple and robust
"""

import sys
import time
from pathlib import Path

# Install deps if needed
try:
    import lancedb
    from sentence_transformers import SentenceTransformer
    import fitz  # PyMuPDF
except ImportError:
    import subprocess
    print("Installing dependencies...")
    subprocess.run([sys.executable, "-m", "pip", "install", "lancedb", "sentence-transformers", "pymupdf", "-q"])
    import lancedb
    from sentence_transformers import SentenceTransformer
    import fitz

BASE = Path(__file__).parent.parent
BOOKS_DIR = BASE / "DOCS" / "BOOKS"
DB_PATH = BASE / ".rag-db" / "books"

def extract_pdf_text(pdf_path):
    """Extract text from PDF"""
    try:
        doc = fitz.open(str(pdf_path))
        text = ""
        for page in doc:
            text += page.get_text() + "\n"
        doc.close()
        return text
    except Exception as e:
        print(f"  ERROR reading {pdf_path.name}: {e}")
        return ""

def chunk_text(text, chunk_size=500, overlap=100):
    """Split text into overlapping chunks"""
    words = text.split()
    chunks = []
    for i in range(0, len(words), chunk_size - overlap):
        chunk = ' '.join(words[i:i + chunk_size])
        if len(chunk) > 100:  # Min chunk size
            chunks.append(chunk[:2500])  # Max chunk size
    return chunks

def main():
    print("\n" + "="*60)
    print("  PDF BOOKS INDEXER")
    print("="*60 + "\n")
    
    # Find PDFs
    pdfs = list(BOOKS_DIR.rglob("*.pdf"))
    print(f"Found {len(pdfs)} PDF files\n")
    
    # Load model
    print("Loading embedding model...")
    model = SentenceTransformer('all-MiniLM-L6-v2')
    print("Model loaded!\n")
    
    # Process each PDF
    all_chunks = []
    
    for i, pdf in enumerate(pdfs, 1):
        print(f"[{i}/{len(pdfs)}] {pdf.name}...")
        
        # Extract text
        text = extract_pdf_text(pdf)
        if not text:
            print(f"  Skipped (no text)")
            continue
        
        # Chunk
        chunks = chunk_text(text)
        print(f"  Extracted {len(chunks)} chunks")
        
        # Add to list
        for j, chunk in enumerate(chunks):
            all_chunks.append({
                "text": chunk,
                "source": pdf.name,
                "chunk_id": f"{pdf.stem}_{j}"
            })
    
    print(f"\nTotal chunks: {len(all_chunks)}")
    
    # Create embeddings
    print("\nCreating embeddings (this takes a while)...")
    start = time.time()
    
    batch_size = 64
    for i in range(0, len(all_chunks), batch_size):
        batch = all_chunks[i:i + batch_size]
        texts = [c["text"] for c in batch]
        embeddings = model.encode(texts, show_progress_bar=False)
        
        for j, emb in enumerate(embeddings):
            batch[j]["vector"] = emb.tolist()
        
        pct = min(100, int((i + batch_size) / len(all_chunks) * 100))
        print(f"  Progress: {pct}%", end="\r")
    
    print(f"\nEmbeddings created in {time.time() - start:.1f}s")
    
    # Save to LanceDB
    print("\nSaving to LanceDB...")
    DB_PATH.mkdir(parents=True, exist_ok=True)
    db = lancedb.connect(str(DB_PATH))
    
    # Drop existing table
    try:
        db.drop_table("documents")
    except:
        pass
    
    # Create new table
    db.create_table("documents", all_chunks)
    
    print(f"\n" + "="*60)
    print(f"  COMPLETE!")
    print(f"  Indexed: {len(all_chunks)} chunks from {len(pdfs)} PDFs")
    print(f"  Database: {DB_PATH}")
    print("="*60 + "\n")

if __name__ == "__main__":
    main()
