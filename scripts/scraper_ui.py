#!/usr/bin/env python3
"""
Scraper Monitor UI - Simple web interface to monitor scraping progress
Run: python scraper_ui.py
Open: http://localhost:8080
"""

import asyncio
import json
import os
import sys
import threading
import time
from http.server import HTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
from datetime import datetime

# Add parent to path for imports
sys.path.insert(0, str(Path(__file__).parent))

PORTS = [8888, 9000, 9090, 8000, 5000]  # Try multiple ports
STATUS_FILE = Path(__file__).parent.parent / "DOCS/SCRAPED/.status.json"

HTML_TEMPLATE = """<!DOCTYPE html>
<html>
<head>
    <title>MQL5 Scraper Monitor</title>
    <meta charset="utf-8">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Segoe UI', Tahoma, sans-serif; 
            background: #1a1a2e; 
            color: #eee; 
            padding: 20px;
            min-height: 100vh;
        }
        .container { max-width: 1200px; margin: 0 auto; }
        h1 { 
            color: #00d4ff; 
            margin-bottom: 20px; 
            text-align: center;
            font-size: 2em;
        }
        .status-bar {
            background: #16213e;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            border: 1px solid #0f3460;
        }
        .progress-container {
            background: #0f3460;
            border-radius: 10px;
            height: 40px;
            overflow: hidden;
            margin: 15px 0;
        }
        .progress-bar {
            height: 100%;
            background: linear-gradient(90deg, #00d4ff, #00ff88);
            border-radius: 10px;
            transition: width 0.5s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            color: #1a1a2e;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 20px;
        }
        .stat-card {
            background: #16213e;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
            border: 1px solid #0f3460;
        }
        .stat-value {
            font-size: 2.5em;
            font-weight: bold;
            color: #00d4ff;
        }
        .stat-label {
            color: #888;
            margin-top: 5px;
            font-size: 0.9em;
        }
        .keys-section {
            margin-top: 20px;
        }
        .key-bar {
            display: flex;
            align-items: center;
            margin: 10px 0;
            background: #16213e;
            padding: 10px 15px;
            border-radius: 8px;
        }
        .key-name {
            width: 80px;
            font-weight: bold;
        }
        .key-progress {
            flex: 1;
            background: #0f3460;
            height: 20px;
            border-radius: 5px;
            margin: 0 15px;
            overflow: hidden;
        }
        .key-fill {
            height: 100%;
            background: #00d4ff;
            transition: width 0.3s;
        }
        .key-stats {
            width: 150px;
            text-align: right;
            font-size: 0.9em;
        }
        .key-cooling {
            background: #ff6b6b !important;
        }
        .log-section {
            margin-top: 20px;
            background: #16213e;
            border-radius: 10px;
            padding: 15px;
            max-height: 300px;
            overflow-y: auto;
            font-family: monospace;
            font-size: 0.85em;
            border: 1px solid #0f3460;
        }
        .log-entry {
            padding: 3px 0;
            border-bottom: 1px solid #0f3460;
        }
        .log-time { color: #888; }
        .log-success { color: #00ff88; }
        .log-error { color: #ff6b6b; }
        .log-skip { color: #ffd93d; }
        .running { color: #00ff88; }
        .stopped { color: #ff6b6b; }
        .controls {
            text-align: center;
            margin: 20px 0;
        }
        .btn {
            background: #00d4ff;
            color: #1a1a2e;
            border: none;
            padding: 12px 30px;
            border-radius: 8px;
            font-size: 1em;
            cursor: pointer;
            margin: 0 10px;
            font-weight: bold;
        }
        .btn:hover { background: #00ff88; }
        .btn-stop { background: #ff6b6b; }
        .btn-stop:hover { background: #ff4757; }
        .last-update {
            text-align: center;
            color: #666;
            font-size: 0.8em;
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>MQL5 PRO SCRAPER</h1>
        
        <div class="status-bar">
            <div style="display: flex; justify-content: space-between; align-items: center;">
                <span>Status: <span id="status" class="running">LOADING...</span></span>
                <span>Section: <span id="section">-</span></span>
                <span>Speed: <span id="speed">0</span> pages/sec</span>
            </div>
            <div class="progress-container">
                <div class="progress-bar" id="progress" style="width: 0%">0%</div>
            </div>
            <div style="display: flex; justify-content: space-between;">
                <span>Queue: <span id="queue">0</span> URLs</span>
                <span>ETA: <span id="eta">-</span></span>
            </div>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-value" id="success">0</div>
                <div class="stat-label">Pages Downloaded</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="existing">0</div>
                <div class="stat-label">Existing (Skipped)</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="errors">0</div>
                <div class="stat-label">Errors</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="credits">0</div>
                <div class="stat-label">Credits Used</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="total">0</div>
                <div class="stat-label">Total Files</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="elapsed">0s</div>
                <div class="stat-label">Time Elapsed</div>
            </div>
        </div>

        <div class="keys-section">
            <h3 style="margin-bottom: 10px; color: #00d4ff;">API Keys Status</h3>
            <div id="keys-container"></div>
        </div>

        <div class="log-section" id="log">
            <div class="log-entry">Waiting for scraper to start...</div>
        </div>

        <div class="last-update">Last update: <span id="last-update">-</span></div>
    </div>

    <script>
        let lastSuccess = 0;
        let lastTime = Date.now();
        
        async function updateStatus() {
            try {
                const response = await fetch('/status.json?' + Date.now());
                const data = await response.json();
                
                // Calculate speed
                const now = Date.now();
                const timeDiff = (now - lastTime) / 1000;
                const successDiff = data.success - lastSuccess;
                const speed = timeDiff > 0 ? (successDiff / timeDiff).toFixed(1) : 0;
                lastSuccess = data.success;
                lastTime = now;
                
                // Update UI
                document.getElementById('status').textContent = data.running ? 'RUNNING' : 'STOPPED';
                document.getElementById('status').className = data.running ? 'running' : 'stopped';
                document.getElementById('section').textContent = data.section || '-';
                document.getElementById('speed').textContent = speed;
                document.getElementById('queue').textContent = data.queue || 0;
                
                const pct = data.max_pages > 0 ? Math.min(100, (data.success / data.max_pages * 100)).toFixed(1) : 0;
                document.getElementById('progress').style.width = pct + '%';
                document.getElementById('progress').textContent = pct + '%';
                
                document.getElementById('success').textContent = data.success || 0;
                document.getElementById('existing').textContent = data.skipped || 0;
                document.getElementById('errors').textContent = data.errors || 0;
                document.getElementById('credits').textContent = data.credits || 0;
                document.getElementById('total').textContent = data.total_files || 0;
                
                const elapsed = data.elapsed || 0;
                const mins = Math.floor(elapsed / 60);
                const secs = Math.floor(elapsed % 60);
                document.getElementById('elapsed').textContent = mins > 0 ? mins + 'm ' + secs + 's' : secs + 's';
                
                // ETA
                if (speed > 0 && data.queue > 0) {
                    const eta = data.queue / speed;
                    const etaMins = Math.floor(eta / 60);
                    const etaSecs = Math.floor(eta % 60);
                    document.getElementById('eta').textContent = etaMins > 0 ? etaMins + 'm ' + etaSecs + 's' : etaSecs + 's';
                } else {
                    document.getElementById('eta').textContent = '-';
                }
                
                // Keys
                if (data.keys) {
                    let keysHtml = '';
                    data.keys.forEach((key, i) => {
                        const cooling = key.cooling ? 'key-cooling' : '';
                        const pct = key.requests > 0 ? Math.min(100, key.requests / 10) : 0;
                        keysHtml += `
                            <div class="key-bar">
                                <span class="key-name">Key ${i+1}</span>
                                <div class="key-progress">
                                    <div class="key-fill ${cooling}" style="width: ${pct}%"></div>
                                </div>
                                <span class="key-stats">${key.requests} req / ${key.errors} err</span>
                            </div>
                        `;
                    });
                    document.getElementById('keys-container').innerHTML = keysHtml;
                }
                
                // Log
                if (data.log && data.log.length > 0) {
                    let logHtml = '';
                    data.log.slice(-50).forEach(entry => {
                        const cls = entry.type === 'success' ? 'log-success' : 
                                   entry.type === 'error' ? 'log-error' : 'log-skip';
                        logHtml += `<div class="log-entry"><span class="log-time">${entry.time}</span> <span class="${cls}">${entry.msg}</span></div>`;
                    });
                    document.getElementById('log').innerHTML = logHtml;
                    document.getElementById('log').scrollTop = document.getElementById('log').scrollHeight;
                }
                
                document.getElementById('last-update').textContent = new Date().toLocaleTimeString();
                
            } catch (e) {
                document.getElementById('status').textContent = 'OFFLINE';
                document.getElementById('status').className = 'stopped';
            }
        }
        
        setInterval(updateStatus, 1000);
        updateStatus();
    </script>
</body>
</html>
"""

class MonitorHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/' or self.path == '/index.html':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(HTML_TEMPLATE.encode())
        elif self.path.startswith('/status.json'):
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Cache-Control', 'no-cache')
            self.end_headers()
            
            status = {"running": False, "success": 0, "errors": 0}
            
            # Try to read status from multiple possible locations
            status_files = [
                Path(__file__).parent.parent / "DOCS/SCRAPED/reference/.status.json",
                Path(__file__).parent.parent / "DOCS/SCRAPED/book/.status.json",
                Path(__file__).parent.parent / "DOCS/SCRAPED/.status.json",
            ]
            
            for sf in status_files:
                if sf.exists():
                    try:
                        with open(sf, 'r') as f:
                            status = json.load(f)
                            status['section'] = sf.parent.name
                            break
                    except:
                        pass
            
            self.wfile.write(json.dumps(status).encode())
        else:
            super().do_GET()
    
    def log_message(self, format, *args):
        pass  # Suppress logging


def run_server():
    server = None
    port = None
    
    for p in PORTS:
        try:
            server = HTTPServer(('127.0.0.1', p), MonitorHandler)
            port = p
            break
        except (PermissionError, OSError):
            continue
    
    if not server:
        print("ERROR: Could not bind to any port!")
        print(f"Tried: {PORTS}")
        return
    
    print(f"\n{'='*50}")
    print(f"  MQL5 SCRAPER MONITOR")
    print(f"{'='*50}")
    print(f"  Open: http://localhost:{port}")
    print(f"  Press Ctrl+C to stop")
    print(f"{'='*50}\n")
    
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down...")
        server.shutdown()


if __name__ == "__main__":
    run_server()
