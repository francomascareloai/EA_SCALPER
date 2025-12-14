#!/usr/bin/env python3
"""
MQL5 PRO Scraper - Production Grade
====================================
- Multi-key rotation with per-key semaphores
- Smart resume (skip existing files)
- Real-time progress display
- Graceful shutdown on Ctrl+C
- Atomic file writes

Usage:
    python scrape_mql5_pro.py --test
    python scrape_mql5_pro.py --book --reference -m 2000
"""

import asyncio
import aiohttp
import hashlib
import json
import os
import re
import signal
import sys
import time
from collections import deque
from pathlib import Path
from urllib.parse import urljoin, urlparse
from typing import Optional
from dataclasses import dataclass, field

try:
    from bs4 import BeautifulSoup
    from markdownify import markdownify as md
except ImportError:
    os.system("pip install beautifulsoup4 markdownify aiohttp -q")
    from bs4 import BeautifulSoup
    from markdownify import markdownify as md

# ===============================================================
# CONFIGURATION
# ===============================================================

API_KEYS = [
    "b84546de6adc1afc3a4fdfb85b1bdcd8",
    "38386c4ea4b9408a6ddf792f17603fde",
    "9d9c82356cf9e7815a305bcde1a4e9ae",
    "9bcf4a57a86b52aa42f329761d83f500",
    "720e5b13aeb4c16e6b9b4f66e21419fb",
]

SCRAPERAPI = "http://api.scraperapi.com"
BASE_URL = "https://www.mql5.com"
CONCURRENT_PER_KEY = 5  # Max 5 per key = 25 total workers
REQUEST_TIMEOUT = 15
MAX_RETRIES = 2

# ===============================================================
# DATA CLASSES
# ===============================================================

@dataclass
class KeyState:
    key: str
    semaphore: asyncio.Semaphore = field(default_factory=lambda: asyncio.Semaphore(CONCURRENT_PER_KEY))
    requests: int = 0
    errors: int = 0
    cooling_until: float = 0

@dataclass  
class Stats:
    success: int = 0
    errors: int = 0
    skipped: int = 0
    credits: int = 0
    start_time: float = field(default_factory=time.time)

# ===============================================================
# PRO SCRAPER
# ===============================================================

class ProScraper:
    def __init__(self, output_dir: str, keys: list[str]):
        self.output = Path(output_dir)
        self.output.mkdir(parents=True, exist_ok=True)
        
        # Key management
        self.keys = [KeyState(k) for k in keys if k]
        self.key_index = 0
        
        # URL tracking
        self.visited: set[str] = set()
        self.queue: deque[str] = deque()
        self.existing_files: set[str] = set()
        
        # Stats
        self.stats = Stats()
        self.running = True
        self.max_pages = 0
        
        # Load state (pattern will be set later in scrape)
        self._pattern = None
        self._load_progress()
        
        # Handle Ctrl+C
        signal.signal(signal.SIGINT, self._shutdown)
    
    def _url_to_filename(self, url: str) -> str:
        """Convert URL to safe filename"""
        path = urlparse(url).path
        path = re.sub(r'^/en/(docs|book|code)/?', '', path)
        name = path.replace('/', '_').strip('_')[:80] or 'index'
        return re.sub(r'[<>:"/\\|?*]', '_', name) + '.md'
    
    def _load_existing_files(self, pattern: str = None):
        """Scan for already downloaded files and extract links from them"""
        if self.output.exists():
            for f in self.output.glob('*.md'):
                self.existing_files.add(f.name)
                
                # Extract source URL from file and add to visited
                try:
                    text = f.read_text(encoding='utf-8')
                    for line in text[:1000].split('\n'):
                        if line.startswith('Source: https://'):
                            url = line[8:].strip()
                            self.visited.add(url)
                            
                            # Extract links from file to seed queue
                            if pattern:
                                # Match relative links like (/en/docs/something)
                                for match in re.findall(r'\(' + pattern + r'[^)"\s]+', text):
                                    path = match[1:]  # Remove leading (
                                    link = BASE_URL + path
                                    if link not in self.visited:
                                        self.queue.append(link)
                            break
                except:
                    pass
        
        print(f"[RESUME] Found {len(self.existing_files)} existing files, {len(self.visited)} visited URLs")
    
    def _load_progress(self):
        """Load visited URLs from progress file"""
        pf = self.output / '.progress.json'
        if pf.exists():
            try:
                data = json.load(open(pf))
                self.visited = set(data.get('visited', []))
                self.stats.credits = data.get('credits', 0)
                print(f"[RESUME] {len(self.visited)} URLs in history, {self.stats.credits} credits used")
            except:
                pass
    
    def _save_progress(self):
        """Save progress atomically"""
        pf = self.output / '.progress.json'
        tmp = self.output / '.progress.tmp'
        data = {
            'visited': list(self.visited),
            'credits': self.stats.credits,
            'success': self.stats.success,
            'timestamp': time.time()
        }
        try:
            json.dump(data, open(tmp, 'w'))
            tmp.replace(pf)
        except:
            pass
    
    def _shutdown(self, *args):
        """Graceful shutdown"""
        print("\n\n[SHUTDOWN] Saving progress...")
        self.running = False
        self._save_progress()
    
    def _get_key(self) -> Optional[KeyState]:
        """Get next available key (round-robin, skip cooling)"""
        now = time.time()
        for _ in range(len(self.keys)):
            self.key_index = (self.key_index + 1) % len(self.keys)
            ks = self.keys[self.key_index]
            if ks.cooling_until < now:
                return ks
        return None
    
    def _should_skip(self, url: str) -> bool:
        """Check if URL should be skipped (already exists)"""
        if url in self.visited:
            return True
        fname = self._url_to_filename(url)
        if fname in self.existing_files:
            self.visited.add(url)
            self.stats.skipped += 1
            return True
        return False
    
    async def _fetch(self, session: aiohttp.ClientSession, url: str) -> Optional[str]:
        """Fetch URL with retry and key rotation"""
        for attempt in range(MAX_RETRIES):
            ks = self._get_key()
            if not ks:
                await asyncio.sleep(1)
                continue
            
            async with ks.semaphore:
                try:
                    params = {'api_key': ks.key, 'url': url}
                    async with session.get(SCRAPERAPI, params=params, timeout=REQUEST_TIMEOUT) as r:
                        self.stats.credits += 1
                        ks.requests += 1
                        
                        if r.status == 200:
                            html = await r.text()
                            if len(html) > 2000:
                                return html
                        
                        elif r.status in (403, 429):
                            ks.cooling_until = time.time() + 30
                            ks.errors += 1
                        
                        else:
                            ks.errors += 1
                            
                except asyncio.TimeoutError:
                    ks.errors += 1
                except Exception:
                    ks.errors += 1
            
            if attempt < MAX_RETRIES - 1:
                await asyncio.sleep(0.5 * (attempt + 1))
        
        return None
    
    def _parse(self, html: str, url: str, pattern: str) -> tuple[Optional[dict], list[str]]:
        """Parse HTML, extract content and links"""
        try:
            soup = BeautifulSoup(html, 'html.parser')
            
            content = soup.select_one('main') or soup.select_one('body')
            if not content or len(content.get_text(strip=True)) < 50:
                return None, []
            
            title = soup.find('h1')
            title_text = title.get_text(strip=True) if title else urlparse(url).path.split('/')[-1]
            
            for junk in content.find_all(['script', 'style', 'nav', 'footer', 'aside', 'iframe']):
                junk.decompose()
            
            markdown = md(str(content), heading_style="ATX", code_language="mql5")
            markdown = re.sub(r'\n{3,}', '\n\n', markdown).strip()
            
            links = []
            for a in soup.find_all('a', href=True):
                href = a['href']
                full = urljoin(url, href)
                if (pattern in full and 
                    full.startswith(BASE_URL) and 
                    '#' not in href and
                    full not in self.visited):
                    links.append(full)
            
            return {'url': url, 'title': title_text, 'content': markdown}, links
        except:
            return None, []
    
    def _save_page(self, data: dict):
        """Save page atomically"""
        fname = self._url_to_filename(data['url'])
        final = self.output / fname
        tmp = self.output / f".{fname}.tmp"
        
        content = f"# {data['title']}\n\nSource: {data['url']}\n\n{data['content']}"
        
        try:
            tmp.write_text(content, encoding='utf-8')
            tmp.replace(final)
            self.existing_files.add(fname)
        except:
            pass
    
    async def _worker(self, session: aiohttp.ClientSession, pattern: str):
        """Worker coroutine"""
        while self.running and self.stats.success < self.max_pages:
            if not self.queue:
                await asyncio.sleep(0.1)
                continue
            
            try:
                url = self.queue.popleft()
            except:
                continue
            
            # Skip if already visited in this session
            if url in self.visited:
                continue
            
            # Check if file already exists - skip without fetching (save credits!)
            fname = self._url_to_filename(url)
            if fname in self.existing_files:
                self.visited.add(url)
                self.stats.skipped += 1
                continue
            
            # Fetch only new pages
            html = await self._fetch(session, url)
            if html:
                data, links = self._parse(html, url, pattern)
                
                # Add discovered links to queue
                for link in links:
                    if link not in self.visited and link not in self.queue:
                        self.queue.append(link)
                
                if data:
                    self._save_page(data)
                    self.visited.add(url)
                    self.stats.success += 1
            else:
                self.stats.errors += 1
    
    def _save_status(self, speed: float = 0):
        """Save status JSON for UI monitor"""
        now = time.time()
        status = {
            "running": self.running,
            "success": self.stats.success,
            "skipped": self.stats.skipped,
            "errors": self.stats.errors,
            "credits": self.stats.credits,
            "queue": len(self.queue),
            "max_pages": self.max_pages,
            "total_files": len(self.existing_files) + self.stats.success,
            "elapsed": now - self.stats.start_time,
            "speed": speed,
            "keys": [
                {
                    "requests": k.requests,
                    "errors": k.errors,
                    "cooling": k.cooling_until > now
                }
                for k in self.keys
            ],
            "timestamp": now
        }
        try:
            sf = self.output / ".status.json"
            json.dump(status, open(sf, 'w'))
        except:
            pass
    
    async def _display(self):
        """Real-time progress display"""
        last = 0
        while self.running and self.stats.success < self.max_pages:
            elapsed = time.time() - self.stats.start_time
            speed = (self.stats.success - last) if elapsed > 1 else 0
            last = self.stats.success
            
            pct = (self.stats.success * 100 // self.max_pages) if self.max_pages else 0
            bar = '#' * (pct // 5) + '-' * (20 - pct // 5)
            
            eta = ((self.max_pages - self.stats.success) / speed) if speed > 0 else 0
            eta_str = f"{int(eta)}s" if eta < 300 else f"{int(eta/60)}m"
            
            active_keys = sum(1 for k in self.keys if k.cooling_until < time.time())
            
            sys.stdout.write(
                f"\r[{bar}] {self.stats.success}/{self.max_pages} "
                f"| {speed}/s | Q:{len(self.queue)} | Skip:{self.stats.skipped} "
                f"| Err:{self.stats.errors} | Keys:{active_keys}/{len(self.keys)} "
                f"| ETA:{eta_str}   "
            )
            sys.stdout.flush()
            
            # Save status for UI
            self._save_status(speed)
            
            if self.stats.success % 100 == 0 and self.stats.success > 0:
                self._save_progress()
            
            await asyncio.sleep(1)
    
    async def scrape(self, start_url: str, pattern: str, max_pages: int):
        """Main scraping function"""
        self.max_pages = max_pages
        self.stats = Stats()
        self._pattern = pattern
        
        # Load existing files and seed queue with their links
        print("[INIT] Loading existing files...")
        self._load_existing_files(pattern)
        
        print(f"\n{'='*60}")
        print(f"PRO SCRAPER")
        print(f"{'='*60}")
        print(f"Target: {start_url}")
        print(f"Pattern: {pattern}")
        print(f"Max pages: {max_pages}")
        print(f"Keys: {len(self.keys)} ({len(self.keys)*CONCURRENT_PER_KEY} concurrent)")
        print(f"Existing files: {len(self.existing_files)}")
        print(f"Seeded queue: {len(self.queue)} URLs from existing files")
        print(f"{'='*60}\n")
        
        # Add start_url if not already in queue
        if start_url not in self.visited and start_url not in self.queue:
            self.queue.appendleft(start_url)
        
        num_workers = len(self.keys) * CONCURRENT_PER_KEY
        
        conn = aiohttp.TCPConnector(limit=num_workers + 10)
        timeout = aiohttp.ClientTimeout(total=REQUEST_TIMEOUT + 5)
        
        async with aiohttp.ClientSession(connector=conn, timeout=timeout) as session:
            workers = [asyncio.create_task(self._worker(session, pattern)) for _ in range(num_workers)]
            display = asyncio.create_task(self._display())
            
            # Wait until done or queue empty
            empty_count = 0
            while self.running and self.stats.success < max_pages:
                await asyncio.sleep(0.5)
                if len(self.queue) == 0:
                    empty_count += 1
                    if empty_count > 10:  # 5 seconds of empty queue
                        break
                else:
                    empty_count = 0
            
            self.running = False
            display.cancel()
            for w in workers:
                w.cancel()
        
        self._save_progress()
        
        print(f"\n\n{'='*60}")
        print(f"COMPLETE")
        print(f"{'='*60}")
        print(f"Success: {self.stats.success}")
        print(f"Skipped (existing): {self.stats.skipped}")
        print(f"Errors: {self.stats.errors}")
        print(f"Credits used: {self.stats.credits}")
        print(f"Time: {time.time() - self.stats.start_time:.1f}s")
        print(f"Output: {self.output}")


# ===============================================================
# TEST KEYS
# ===============================================================

async def test_keys() -> list[str]:
    """Test all keys and return working ones"""
    print("\n" + "="*50)
    print("TESTING API KEYS")
    print("="*50)
    
    working = []
    async with aiohttp.ClientSession() as session:
        for i, key in enumerate(API_KEYS, 1):
            try:
                params = {'api_key': key, 'url': f'{BASE_URL}/en/book'}
                async with session.get(SCRAPERAPI, params=params, timeout=20) as r:
                    if r.status == 200 and len(await r.text()) > 5000:
                        print(f"  Key {i}: OK OK")
                        working.append(key)
                    else:
                        print(f"  Key {i}: X Status {r.status}")
            except Exception as e:
                print(f"  Key {i}: X Error")
    
    print(f"\n{len(working)}/{len(API_KEYS)} keys working\n")
    return working


# ===============================================================
# MAIN
# ===============================================================

async def main():
    import argparse
    p = argparse.ArgumentParser(description="MQL5 Pro Scraper")
    p.add_argument('--test', action='store_true', help="Test API keys only")
    p.add_argument('--book', action='store_true', help="Scrape MQL5 Book")
    p.add_argument('--reference', action='store_true', help="Scrape MQL5 Reference")
    p.add_argument('--all', action='store_true', help="Scrape everything")
    p.add_argument('-m', '--max', type=int, default=500, help="Max pages per section")
    p.add_argument('-o', '--output', default='./DOCS/SCRAPED', help="Output directory")
    args = p.parse_args()
    
    # Always test keys first
    working_keys = await test_keys()
    
    if not working_keys:
        print("[ERROR] No working API keys!")
        return 1
    
    if args.test:
        return 0
    
    if args.all:
        args.book = args.reference = True
    
    if not args.book and not args.reference:
        args.book = True
    
    out = Path(args.output)
    
    if args.book:
        scraper = ProScraper(out / "book", working_keys)
        await scraper.scrape(f"{BASE_URL}/en/book", '/en/book/', min(args.max, 300))
    
    if args.reference:
        scraper = ProScraper(out / "reference", working_keys)
        await scraper.scrape(f"{BASE_URL}/en/docs", '/en/docs/', args.max)
    
    print("\n[DONE] All scraping complete!")
    return 0


if __name__ == "__main__":
    try:
        exit(asyncio.run(main()))
    except KeyboardInterrupt:
        print("\n[INTERRUPTED]")
        exit(0)
