#!/usr/bin/env python3
"""
Run scraper with built-in web monitor
Usage: python run_scraper.py [--book] [--reference] [--all] [-m MAX]
"""

import asyncio
import json
import os
import sys
import threading
import webbrowser
from http.server import HTTPServer, BaseHTTPRequestHandler
from pathlib import Path

# Add scripts to path
sys.path.insert(0, str(Path(__file__).parent))

from scrape_mql5_pro import ProScraper, test_keys, BASE_URL, CONCURRENT_PER_KEY

HTML = """<!DOCTYPE html>
<html>
<head>
    <title>MQL5 Scraper</title>
    <meta charset="utf-8">
    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        body{font-family:'Segoe UI',sans-serif;background:#1a1a2e;color:#eee;padding:20px}
        .c{max-width:800px;margin:0 auto}
        h1{color:#00d4ff;text-align:center;margin-bottom:20px}
        .box{background:#16213e;border-radius:10px;padding:20px;margin-bottom:15px;border:1px solid #0f3460}
        .prog{background:#0f3460;border-radius:10px;height:35px;margin:15px 0;overflow:hidden}
        .bar{height:100%;background:linear-gradient(90deg,#00d4ff,#00ff88);border-radius:10px;
             display:flex;align-items:center;justify-content:center;font-weight:bold;color:#1a1a2e;transition:width .3s}
        .grid{display:grid;grid-template-columns:repeat(3,1fr);gap:10px}
        .card{background:#16213e;border-radius:8px;padding:15px;text-align:center;border:1px solid #0f3460}
        .val{font-size:2em;font-weight:bold;color:#00d4ff}
        .lbl{color:#888;font-size:.85em}
        .run{color:#00ff88}.stop{color:#ff6b6b}
        .row{display:flex;justify-content:space-between;margin-bottom:10px}
    </style>
</head>
<body>
<div class="c">
    <h1>MQL5 SCRAPER</h1>
    <div class="box">
        <div class="row">
            <span>Status: <b id="st" class="stop">LOADING</b></span>
            <span><b id="spd">0</b> pg/s</span>
            <span>Queue: <b id="q">0</b></span>
        </div>
        <div class="prog"><div class="bar" id="bar" style="width:0%">0%</div></div>
    </div>
    <div class="grid">
        <div class="card"><div class="val" id="ok">0</div><div class="lbl">Downloaded</div></div>
        <div class="card"><div class="val" id="sk">0</div><div class="lbl">Skipped</div></div>
        <div class="card"><div class="val" id="er">0</div><div class="lbl">Errors</div></div>
        <div class="card"><div class="val" id="cr">0</div><div class="lbl">Credits</div></div>
        <div class="card"><div class="val" id="tot">0</div><div class="lbl">Total</div></div>
        <div class="card"><div class="val" id="tm">0s</div><div class="lbl">Time</div></div>
    </div>
</div>
<script>
let last=0,lt=Date.now();
async function u(){
    try{
        let r=await fetch('/s?'+Date.now());
        let d=await r.json();
        let now=Date.now(),dt=(now-lt)/1000,ds=d.success-last;
        let spd=dt>0?(ds/dt).toFixed(1):0;
        last=d.success;lt=now;
        document.getElementById('st').textContent=d.running?'RUNNING':'DONE';
        document.getElementById('st').className=d.running?'run':'stop';
        document.getElementById('spd').textContent=spd;
        document.getElementById('q').textContent=d.queue||0;
        document.getElementById('ok').textContent=d.success||0;
        document.getElementById('sk').textContent=d.skipped||0;
        document.getElementById('er').textContent=d.errors||0;
        document.getElementById('cr').textContent=d.credits||0;
        document.getElementById('tot').textContent=d.total_files||0;
        let e=d.elapsed||0;
        document.getElementById('tm').textContent=e>=60?Math.floor(e/60)+'m'+Math.floor(e%60)+'s':Math.floor(e)+'s';
        let p=d.max_pages>0?Math.min(100,d.success/d.max_pages*100).toFixed(0):0;
        document.getElementById('bar').style.width=p+'%';
        document.getElementById('bar').textContent=p+'%';
    }catch(e){}
}
setInterval(u,1000);u();
</script>
</body>
</html>"""

status_data = {"running": False, "success": 0}

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
    
    def log_message(self, *args):
        pass


def run_server(port):
    server = HTTPServer(('127.0.0.1', port), Handler)
    server.serve_forever()


async def main():
    global status_data
    
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument('--book', action='store_true')
    p.add_argument('--reference', action='store_true')
    p.add_argument('--all', action='store_true')
    p.add_argument('-m', '--max', type=int, default=5000)
    p.add_argument('-p', '--port', type=int, default=8888)
    args = p.parse_args()
    
    if args.all:
        args.book = args.reference = True
    if not args.book and not args.reference:
        args.reference = True
    
    # Start web server
    port = args.port
    for p in [args.port, 9000, 9090, 5000, 3000]:
        try:
            t = threading.Thread(target=run_server, args=(p,), daemon=True)
            t.start()
            port = p
            break
        except:
            continue
    
    print(f"\n{'='*50}")
    print(f"  MONITOR: http://localhost:{port}")
    print(f"{'='*50}\n")
    
    # Open browser
    webbrowser.open(f'http://localhost:{port}')
    
    # Test keys
    working_keys = await test_keys()
    if not working_keys:
        print("No working keys!")
        return
    
    out = Path(__file__).parent.parent / "DOCS/SCRAPED"
    
    # Custom scraper that updates status_data
    class MonitoredScraper(ProScraper):
        def _save_status(self, speed=0):
            super()._save_status(speed)
            global status_data
            status_data = {
                "running": self.running,
                "success": self.stats.success,
                "skipped": self.stats.skipped,
                "errors": self.stats.errors,
                "credits": self.stats.credits,
                "queue": len(self.queue),
                "max_pages": self.max_pages,
                "total_files": len(self.existing_files) + self.stats.success,
                "elapsed": time.time() - self.stats.start_time,
                "speed": speed
            }
    
    import time
    
    if args.reference:
        scraper = MonitoredScraper(out / "reference", working_keys)
        await scraper.scrape(f"{BASE_URL}/en/docs", '/en/docs/', args.max)
    
    if args.book:
        scraper = MonitoredScraper(out / "book", working_keys)
        await scraper.scrape(f"{BASE_URL}/en/book", '/en/book/', min(args.max, 500))
    
    status_data["running"] = False
    print("\n\nDONE! Press Ctrl+C to exit.")
    
    # Keep server running
    while True:
        await asyncio.sleep(1)


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nBye!")
