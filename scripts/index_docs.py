#!/usr/bin/env python3
"""
Index scraped MQL5 docs into RAG
"""

import sys
import time
from pathlib import Path

try:
    import lancedb
    from sentence_transformers import SentenceTransformer
except ImportError:
    import subprocess
    subprocess.run([sys.executable, "-m", "pip", "install", "lancedb", "sentence-transformers", "-q"])
    import lancedb
    from sentence_transformers import SentenceTransformer

BASE = Path(__file__).parent.parent
DOCS_DIR = BASE / "DOCS" / "SCRAPED"
DB_PATH = BASE / ".rag-db" / "docs"

def chunk_text(text, chunk_size=400, overlap=80):
    """Split text into overlapping chunks"""
    words = text.split()
    chunks = []
    for i in range(0, len(words), chunk_size - overlap):
        chunk = ' '.join(words[i:i + chunk_size])
        if len(chunk) > 80:
            chunks.append(chunk[:2000])
    return chunks

def main():
    print("\n" + "="*60)
    print("  MQL5 DOCS INDEXER")
    print("="*60 + "\n")
    
    # Find all .md files
    md_files = list(DOCS_DIR.rglob("*.md"))
    # Filter out hidden files
    md_files = [f for f in md_files if not f.name.startswith('.')]
    
    print(f"Found {len(md_files)} markdown files\n")
    
    # Load model
    print("Loading embedding model...")
    model = SentenceTransformer('all-MiniLM-L6-v2')
    print("Model loaded!\n")
    
    # Process files
    all_chunks = []
    errors = 0
    
    for i, md_file in enumerate(md_files, 1):
        try:
            text = md_file.read_text(encoding='utf-8', errors='ignore')
            if len(text) < 100:
                continue
            
            chunks = chunk_text(text)
            
            # Get relative path for source
            try:
                rel_path = md_file.relative_to(DOCS_DIR)
                source = str(rel_path)
            except:
                source = md_file.name
            
            for j, chunk in enumerate(chunks):
                all_chunks.append({
                    "text": chunk,
                    "source": source,
                    "chunk_id": f"{md_file.stem}_{j}"
                })
            
            if i % 500 == 0:
                print(f"  Processed {i}/{len(md_files)} files, {len(all_chunks)} chunks")
                
        except Exception as e:
            errors += 1
            continue
    
    print(f"\nTotal: {len(all_chunks)} chunks from {len(md_files)} files ({errors} errors)")
    
    # Create embeddings
    print("\nCreating embeddings...")
    start = time.time()
    
    batch_size = 128
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
    
    try:
        db.drop_table("documents")
    except:
        pass
    
    db.create_table("documents", all_chunks)
    
    print(f"\n" + "="*60)
    print(f"  COMPLETE!")
    print(f"  Indexed: {len(all_chunks)} chunks from {len(md_files)} docs")
    print(f"  Database: {DB_PATH}")
    print("="*60 + "\n")

if __name__ == "__main__":
    main()
