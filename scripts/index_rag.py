#!/usr/bin/env python3
"""
RAG Indexer - Index books and docs into separate RAG databases
==============================================================
Usage: python index_rag.py [--books] [--docs] [--all]
"""

import os
import sys
import json
import subprocess
import webbrowser
import threading
import time
from pathlib import Path
from http.server import HTTPServer, BaseHTTPRequestHandler

BASE = Path(__file__).parent.parent
BOOKS_DIR = BASE / "DOCS" / "BOOKS"
SCRAPED_DIR = BASE / "DOCS" / "SCRAPED"
RAG_DB = BASE / ".rag-db"

status_data = {"phase": "starting", "progress": 0, "message": "Initializing..."}

HTML = """<!DOCTYPE html>
<html>
<head>
    <title>RAG Indexer</title>
    <meta charset="utf-8">
    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        body{font-family:'Segoe UI',sans-serif;background:#1a1a2e;color:#eee;padding:40px;display:flex;justify-content:center;align-items:center;min-height:100vh}
        .c{max-width:600px;width:100%}
        h1{color:#00d4ff;text-align:center;margin-bottom:30px}
        .box{background:#16213e;border-radius:15px;padding:30px;border:1px solid #0f3460}
        .phase{font-size:1.2em;margin-bottom:15px;color:#00ff88}
        .msg{color:#888;margin-bottom:20px}
        .prog{background:#0f3460;border-radius:10px;height:30px;overflow:hidden}
        .bar{height:100%;background:linear-gradient(90deg,#00d4ff,#00ff88);border-radius:10px;transition:width .5s;display:flex;align-items:center;justify-content:center;font-weight:bold;color:#1a1a2e}
        .stats{margin-top:20px;display:grid;grid-template-columns:1fr 1fr;gap:10px}
        .stat{background:#0f3460;padding:15px;border-radius:8px;text-align:center}
        .stat-val{font-size:1.5em;color:#00d4ff;font-weight:bold}
        .stat-lbl{color:#888;font-size:.85em}
    </style>
</head>
<body>
<div class="c">
    <h1>RAG INDEXER</h1>
    <div class="box">
        <div class="phase" id="phase">Starting...</div>
        <div class="msg" id="msg">Initializing indexer...</div>
        <div class="prog"><div class="bar" id="bar" style="width:0%">0%</div></div>
        <div class="stats">
            <div class="stat"><div class="stat-val" id="files">0</div><div class="stat-lbl">Files Processed</div></div>
            <div class="stat"><div class="stat-val" id="chunks">0</div><div class="stat-lbl">Chunks Created</div></div>
        </div>
    </div>
</div>
<script>
async function u(){
    try{
        let r=await fetch('/s?'+Date.now());
        let d=await r.json();
        document.getElementById('phase').textContent=d.phase||'Working...';
        document.getElementById('msg').textContent=d.message||'';
        document.getElementById('bar').style.width=(d.progress||0)+'%';
        document.getElementById('bar').textContent=(d.progress||0)+'%';
        document.getElementById('files').textContent=d.files||0;
        document.getElementById('chunks').textContent=d.chunks||0;
    }catch(e){}
}
setInterval(u,500);u();
</script>
</body>
</html>"""

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path.startswith('/s'):
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(status_data).encode())
        else:
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(HTML.encode())
    def log_message(self, *args): pass

def run_server(port):
    HTTPServer(('127.0.0.1', port), Handler).serve_forever()

def count_files(directory, extensions):
    """Count files with given extensions"""
    count = 0
    for ext in extensions:
        count += len(list(directory.rglob(f"*{ext}")))
    return count

def index_with_mcp(base_dir, db_path, name):
    """Index files using mcp-local-rag"""
    global status_data
    
    # Create db directory
    db_path.mkdir(parents=True, exist_ok=True)
    
    # Set environment
    env = os.environ.copy()
    env.update({
        "BASE_DIR": str(base_dir),
        "DB_PATH": str(db_path),
        "CACHE_DIR": str(RAG_DB / "models"),
        "CHUNK_SIZE": "512" if "BOOKS" in str(base_dir) else "400",
        "CHUNK_OVERLAP": "100" if "BOOKS" in str(base_dir) else "80",
        "MAX_FILE_SIZE": "209715200"
    })
    
    status_data["message"] = f"Running mcp-local-rag indexer for {name}..."
    
    # Run indexer
    try:
        result = subprocess.run(
            ["npx", "-y", "mcp-local-rag", "--index"],
            env=env,
            capture_output=True,
            text=True,
            timeout=3600,
            cwd=str(base_dir)
        )
        
        if result.returncode == 0:
            status_data["message"] = f"{name} indexed successfully!"
            return True
        else:
            status_data["message"] = f"Error indexing {name}: {result.stderr[:200]}"
            print(f"STDERR: {result.stderr}")
            return False
    except subprocess.TimeoutExpired:
        status_data["message"] = f"Timeout indexing {name}"
        return False
    except Exception as e:
        status_data["message"] = f"Error: {str(e)}"
        return False

def manual_index(base_dir, db_path, name, extensions):
    """Manual indexing using LanceDB directly"""
    global status_data
    
    try:
        import lancedb
        from sentence_transformers import SentenceTransformer
    except ImportError:
        status_data["message"] = "Installing dependencies..."
        subprocess.run([sys.executable, "-m", "pip", "install", "lancedb", "sentence-transformers", "-q"])
        import lancedb
        from sentence_transformers import SentenceTransformer
    
    status_data["phase"] = f"Indexing {name}"
    status_data["message"] = "Loading embedding model..."
    
    # Load model
    model = SentenceTransformer('all-MiniLM-L6-v2')
    
    # Connect to DB
    db_path.mkdir(parents=True, exist_ok=True)
    db = lancedb.connect(str(db_path))
    
    # Collect files
    files = []
    for ext in extensions:
        files.extend(base_dir.rglob(f"*{ext}"))
    
    total_files = len(files)
    status_data["message"] = f"Found {total_files} files to index"
    
    # Process files
    all_chunks = []
    chunk_size = 512 if "BOOKS" in str(base_dir) else 400
    overlap = 100 if "BOOKS" in str(base_dir) else 80
    
    for i, file_path in enumerate(files):
        try:
            # Read file
            if file_path.suffix == '.pdf':
                try:
                    import fitz  # PyMuPDF
                    doc = fitz.open(str(file_path))
                    text = "\n".join([page.get_text() for page in doc])
                    doc.close()
                except:
                    continue
            else:
                text = file_path.read_text(encoding='utf-8', errors='ignore')
            
            if len(text) < 50:
                continue
            
            # Chunk text
            words = text.split()
            for j in range(0, len(words), chunk_size - overlap):
                chunk_words = words[j:j + chunk_size]
                if len(chunk_words) < 50:
                    continue
                
                chunk_text = ' '.join(chunk_words)
                all_chunks.append({
                    "text": chunk_text[:2000],
                    "source": str(file_path.relative_to(base_dir)),
                    "chunk_id": f"{file_path.stem}_{j}"
                })
            
            # Update progress
            progress = int((i + 1) / total_files * 100)
            status_data["progress"] = progress
            status_data["files"] = i + 1
            status_data["chunks"] = len(all_chunks)
            status_data["message"] = f"Processing: {file_path.name}"
            
        except Exception as e:
            continue
    
    # Create embeddings in batches
    status_data["message"] = "Creating embeddings..."
    batch_size = 100
    
    for i in range(0, len(all_chunks), batch_size):
        batch = all_chunks[i:i + batch_size]
        texts = [c["text"] for c in batch]
        embeddings = model.encode(texts, show_progress_bar=False)
        
        for j, emb in enumerate(embeddings):
            batch[j]["vector"] = emb.tolist()
        
        status_data["progress"] = int((i + batch_size) / len(all_chunks) * 100)
        status_data["message"] = f"Embedding batch {i // batch_size + 1}/{len(all_chunks) // batch_size + 1}"
    
    # Save to LanceDB
    status_data["message"] = "Saving to database..."
    
    if all_chunks:
        # Check if table exists
        try:
            db.drop_table("documents")
        except:
            pass
        
        db.create_table("documents", all_chunks)
        status_data["message"] = f"Indexed {len(all_chunks)} chunks from {total_files} files"
        return True
    else:
        status_data["message"] = "No chunks created"
        return False

def main():
    global status_data
    
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument('--books', action='store_true', help="Index books only")
    p.add_argument('--docs', action='store_true', help="Index scraped docs only")
    p.add_argument('--all', action='store_true', help="Index everything")
    args = p.parse_args()
    
    if args.all:
        args.books = args.docs = True
    if not args.books and not args.docs:
        args.all = args.books = args.docs = True
    
    # Start web server
    port = 8889
    for p in [8889, 9001, 9091]:
        try:
            t = threading.Thread(target=run_server, args=(p,), daemon=True)
            t.start()
            port = p
            break
        except: continue
    
    print(f"\n{'='*50}")
    print(f"  RAG INDEXER")
    print(f"  Monitor: http://localhost:{port}")
    print(f"{'='*50}\n")
    
    webbrowser.open(f'http://localhost:{port}')
    time.sleep(1)
    
    # Create base directories
    (RAG_DB / "books").mkdir(parents=True, exist_ok=True)
    (RAG_DB / "docs").mkdir(parents=True, exist_ok=True)
    (RAG_DB / "models").mkdir(parents=True, exist_ok=True)
    
    results = {}
    
    if args.books:
        print("\n[1/2] Indexing BOOKS...")
        status_data = {"phase": "Indexing BOOKS", "progress": 0, "message": "Starting...", "files": 0, "chunks": 0}
        
        book_files = count_files(BOOKS_DIR, ['.pdf', '.md', '.txt'])
        print(f"Found {book_files} book files")
        
        success = manual_index(BOOKS_DIR, RAG_DB / "books", "BOOKS", ['.pdf', '.md', '.txt'])
        results["books"] = success
    
    if args.docs:
        print("\n[2/2] Indexing SCRAPED DOCS...")
        status_data = {"phase": "Indexing DOCS", "progress": 0, "message": "Starting...", "files": 0, "chunks": 0}
        
        doc_files = count_files(SCRAPED_DIR, ['.md', '.html', '.txt'])
        print(f"Found {doc_files} doc files")
        
        success = manual_index(SCRAPED_DIR, RAG_DB / "docs", "DOCS", ['.md', '.html', '.txt'])
        results["docs"] = success
    
    # Summary
    status_data["phase"] = "COMPLETE!"
    status_data["progress"] = 100
    status_data["message"] = f"Books: {'OK' if results.get('books') else 'SKIP'} | Docs: {'OK' if results.get('docs') else 'SKIP'}"
    
    print(f"\n{'='*50}")
    print(f"  INDEXING COMPLETE!")
    print(f"{'='*50}")
    for k, v in results.items():
        print(f"  {k}: {'SUCCESS' if v else 'FAILED/SKIPPED'}")
    print(f"{'='*50}\n")
    
    print("Press Ctrl+C to exit...")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        pass

if __name__ == "__main__":
    main()
