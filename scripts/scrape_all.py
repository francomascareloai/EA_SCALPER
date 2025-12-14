#!/usr/bin/env python3
"""
MQL5 COMPLETE SCRAPER - Downloads ALL documentation
===================================================
- Reference docs (6800+ pages)
- Book (300 pages) 
- CodeBase: Experts, Indicators, Scripts, Libraries (4000+ pages)

Usage: python scrape_all.py
"""

import asyncio
import json
import sys
import threading
import time
import webbrowser
from http.server import HTTPServer, BaseHTTPRequestHandler
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from scrape_mql5_pro import ProScraper, test_keys, BASE_URL, CONCURRENT_PER_KEY

# Sections to scrape
SECTIONS = [
    {"name": "Reference", "path": "reference", "start": "/en/docs", "pattern": "/en/docs/", "max": 7000},
    {"name": "Book", "path": "book", "start": "/en/book", "pattern": "/en/book/", "max": 500},
    {"name": "CodeBase Experts", "path": "codebase_experts", "start": "/en/code/experts", "pattern": "/en/code/", "max": 2500},
    {"name": "CodeBase Indicators", "path": "codebase_indicators", "start": "/en/code/indicators", "pattern": "/en/code/", "max": 2000},
    {"name": "CodeBase Scripts", "path": "codebase_scripts", "start": "/en/code/scripts", "pattern": "/en/code/", "max": 800},
    {"name": "CodeBase Libraries", "path": "codebase_libraries", "start": "/en/code/libraries", "pattern": "/en/code/", "max": 500},
]

HTML = """<!DOCTYPE html>
<html>
<head>
    <title>MQL5 Complete Scraper</title>
    <meta charset="utf-8">
    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        body{font-family:'Segoe UI',sans-serif;background:#1a1a2e;color:#eee;padding:20px}
        .c{max-width:900px;margin:0 auto}
        h1{color:#00d4ff;text-align:center;margin-bottom:5px}
        h2{color:#888;text-align:center;margin-bottom:20px;font-weight:normal}
        .box{background:#16213e;border-radius:10px;padding:20px;margin-bottom:15px;border:1px solid #0f3460}
        .prog{background:#0f3460;border-radius:8px;height:30px;margin:10px 0;overflow:hidden}
        .bar{height:100%;background:linear-gradient(90deg,#00d4ff,#00ff88);border-radius:8px;
             display:flex;align-items:center;justify-content:center;font-weight:bold;color:#1a1a2e;transition:width .3s}
        .grid{display:grid;grid-template-columns:repeat(4,1fr);gap:10px}
        .card{background:#16213e;border-radius:8px;padding:12px;text-align:center;border:1px solid #0f3460}
        .val{font-size:1.8em;font-weight:bold;color:#00d4ff}
        .lbl{color:#888;font-size:.8em}
        .run{color:#00ff88}.stop{color:#ff6b6b}.wait{color:#ffd93d}
        .row{display:flex;justify-content:space-between;margin-bottom:10px}
        .section{background:#0f3460;border-radius:8px;padding:10px 15px;margin:8px 0;display:flex;justify-content:space-between;align-items:center}
        .section.active{border:2px solid #00d4ff}
        .section.done{border:2px solid #00ff88}
        .done-icon{color:#00ff88;font-weight:bold}
    </style>
</head>
<body>
<div class="c">
    <h1>MQL5 COMPLETE SCRAPER</h1>
    <h2>Downloading ALL Documentation</h2>
    
    <div class="box">
        <div class="row">
            <span>Status: <b id="st" class="wait">STARTING...</b></span>
            <span>Section: <b id="sec">-</b></span>
            <span><b id="spd">0</b> pg/s</span>
        </div>
        <div class="prog"><div class="bar" id="bar" style="width:0%">0%</div></div>
        <div class="row">
            <span>Queue: <b id="q">0</b></span>
            <span>ETA: <b id="eta">calculating...</b></span>
        </div>
    </div>
    
    <div class="grid">
        <div class="card"><div class="val" id="ok">0</div><div class="lbl">Downloaded</div></div>
        <div class="card"><div class="val" id="sk">0</div><div class="lbl">Skipped</div></div>
        <div class="card"><div class="val" id="cr">0</div><div class="lbl">Credits</div></div>
        <div class="card"><div class="val" id="tm">0s</div><div class="lbl">Time</div></div>
    </div>
    
    <div class="box" style="margin-top:15px">
        <h3 style="color:#00d4ff;margin-bottom:10px">Sections Progress</h3>
        <div id="sections"></div>
    </div>
</div>
<script>
let last=0,lt=Date.now();
async function u(){
    try{
        let r=await fetch('/s?'+Date.now());
        let d=await r.json();
        let now=Date.now(),dt=(now-lt)/1000,ds=(d.total_success||0)-last;
        let spd=dt>0?(ds/dt).toFixed(1):0;
        last=d.total_success||0;lt=now;
        
        document.getElementById('st').textContent=d.running?'RUNNING':'DONE';
        document.getElementById('st').className=d.running?'run':'stop';
        document.getElementById('sec').textContent=d.current_section||'-';
        document.getElementById('spd').textContent=spd;
        document.getElementById('q').textContent=d.queue||0;
        document.getElementById('ok').textContent=d.total_success||0;
        document.getElementById('sk').textContent=d.total_skipped||0;
        document.getElementById('cr').textContent=d.total_credits||0;
        
        let e=d.elapsed||0;
        document.getElementById('tm').textContent=e>=60?Math.floor(e/60)+'m'+Math.floor(e%60)+'s':Math.floor(e)+'s';
        
        // ETA
        if(spd>0 && d.queue>0){
            let eta=d.queue/spd;
            document.getElementById('eta').textContent=eta>=60?Math.floor(eta/60)+'m'+Math.floor(eta%60)+'s':Math.floor(eta)+'s';
        }
        
        // Overall progress
        let total=d.total_success+d.queue;
        let p=total>0?Math.min(100,d.total_success/total*100).toFixed(0):0;
        document.getElementById('bar').style.width=p+'%';
        document.getElementById('bar').textContent=p+'%';
        
        // Sections
        if(d.sections){
            let html='';
            d.sections.forEach(s=>{
                let cls=s.status=='done'?'done':s.status=='active'?'active':'';
                let icon=s.status=='done'?'<span class="done-icon">[OK]</span>':'';
                html+='<div class="section '+cls+'"><span>'+s.name+'</span><span>'+s.files+' files '+icon+'</span></div>';
            });
            document.getElementById('sections').innerHTML=html;
        }
    }catch(e){}
}
setInterval(u,1000);u();
</script>
</body>
</html>"""

status_data = {"running": False, "sections": []}

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/' or self.path.startswith('/index'):
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(HTML.encode())
        elif self.path.startswith('/s'):
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps(status_data).encode())
        else:
            self.send_response(404)
            self.end_headers()
    def log_message(self, *args): pass


def run_server(port):
    server = HTTPServer(('127.0.0.1', port), Handler)
    server.serve_forever()


class TrackedScraper(ProScraper):
    """Scraper that updates global status"""
    def __init__(self, *args, section_name="", **kwargs):
        super().__init__(*args, **kwargs)
        self.section_name = section_name
    
    def _save_status(self, speed=0):
        super()._save_status(speed)
        global status_data
        status_data.update({
            "running": self.running,
            "current_section": self.section_name,
            "queue": len(self.queue),
            "speed": speed,
            "success": self.stats.success,
            "skipped": self.stats.skipped,
            "credits": self.stats.credits,
            "elapsed": time.time() - self.stats.start_time,
        })


async def main():
    global status_data
    
    # Start web server
    port = 8888
    for p in [8888, 9000, 9090, 5000]:
        try:
            t = threading.Thread(target=run_server, args=(p,), daemon=True)
            t.start()
            port = p
            break
        except: continue
    
    print(f"\n{'='*60}")
    print(f"  MQL5 COMPLETE SCRAPER")
    print(f"  Monitor: http://localhost:{port}")
    print(f"{'='*60}\n")
    
    webbrowser.open(f'http://localhost:{port}')
    
    # Test keys
    working_keys = await test_keys()
    if not working_keys:
        print("No working keys!")
        return
    
    out = Path(__file__).parent.parent / "DOCS/SCRAPED"
    
    # Initialize sections status
    status_data["sections"] = [
        {"name": s["name"], "files": 0, "status": "pending"} 
        for s in SECTIONS
    ]
    
    total_success = 0
    total_skipped = 0
    total_credits = 0
    start_time = time.time()
    
    # Scrape each section
    for i, section in enumerate(SECTIONS):
        print(f"\n{'='*60}")
        print(f"  SECTION {i+1}/{len(SECTIONS)}: {section['name']}")
        print(f"{'='*60}")
        
        status_data["sections"][i]["status"] = "active"
        
        scraper = TrackedScraper(
            out / section["path"], 
            working_keys,
            section_name=section["name"]
        )
        
        await scraper.scrape(
            BASE_URL + section["start"],
            section["pattern"],
            section["max"]
        )
        
        # Update totals
        total_success += scraper.stats.success
        total_skipped += scraper.stats.skipped
        total_credits += scraper.stats.credits
        
        status_data["sections"][i]["files"] = len(scraper.existing_files) + scraper.stats.success
        status_data["sections"][i]["status"] = "done"
        status_data["total_success"] = total_success
        status_data["total_skipped"] = total_skipped
        status_data["total_credits"] = total_credits
        status_data["elapsed"] = time.time() - start_time
    
    status_data["running"] = False
    
    print(f"\n{'='*60}")
    print(f"  ALL SECTIONS COMPLETE!")
    print(f"{'='*60}")
    print(f"  Total Downloaded: {total_success}")
    print(f"  Total Skipped: {total_skipped}")
    print(f"  Total Credits: {total_credits}")
    print(f"  Time: {time.time() - start_time:.1f}s")
    print(f"{'='*60}\n")
    
    print("Press Ctrl+C to exit...")
    while True:
        await asyncio.sleep(1)


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nDone!")
