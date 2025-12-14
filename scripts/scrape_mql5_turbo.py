"""
MQL5 TURBO Scraper - 5 Keys x 5 Threads = 25 Concurrent!
========================================================
"""

import asyncio
import aiohttp
import json
import os
import re
import sys
from pathlib import Path
from urllib.parse import urljoin, urlparse
from typing import Set
from collections import deque

try:
    from bs4 import BeautifulSoup
    from markdownify import markdownify as md
except ImportError:
    import subprocess
    subprocess.check_call(["pip", "install", "beautifulsoup4", "markdownify", "aiohttp"])
    from bs4 import BeautifulSoup
    from markdownify import markdownify as md

# 5 API Keys = 25,000 credits!
# IMPORTANT: never hard-code real ScraperAPI keys in this file.
# Configure them via environment variables instead (SCRAPERAPI_KEY_1..5).
API_KEYS = [
    key
    for key in [
        os.getenv("SCRAPERAPI_KEY_1"),
        os.getenv("SCRAPERAPI_KEY_2"),
        os.getenv("SCRAPERAPI_KEY_3"),
        os.getenv("SCRAPERAPI_KEY_4"),
        os.getenv("SCRAPERAPI_KEY_5"),
    ]
    if key
]

BASE_URL = "https://www.mql5.com"
SCRAPERAPI = "http://api.scraperapi.com"


async def test_keys():
    """Test all API keys"""
    print("\n" + "="*50)
    print("TESTING 5 API KEYS")
    print("="*50)
    
    working = []
    
    async with aiohttp.ClientSession() as session:
        for i, key in enumerate(API_KEYS, 1):
            sys.stdout.write(f"\rTesting key {i}/5...")
            sys.stdout.flush()
            
            try:
                params = {'api_key': key, 'url': f'{BASE_URL}/en/book'}
                async with session.get(SCRAPERAPI, params=params, timeout=30) as r:
                    if r.status == 200:
                        text = await r.text()
                        if len(text) > 5000:
                            working.append(key)
                            print(f"\r  Key {i}: OK ({len(text)} bytes)      ")
                        else:
                            print(f"\r  Key {i}: BLOCKED (short response)   ")
                    else:
                        print(f"\r  Key {i}: FAILED (status {r.status})    ")
            except Exception as e:
                print(f"\r  Key {i}: ERROR ({str(e)[:30]})        ")
    
    print(f"\n{len(working)}/{len(API_KEYS)} keys working")
    return working


class TurboScraper:
    def __init__(self, keys: list, output_dir: str):
        self.keys = keys
        self.key_index = 0
        self.output = Path(output_dir)
        self.output.mkdir(parents=True, exist_ok=True)
        
        self.visited: Set[str] = set()
        self.to_visit: deque = deque()
        self.success = 0
        self.errors = 0
        self.credits = 0
        self.running = True
        
        self._load()
    
    def _load(self):
        pf = self.output / ".progress.json"
        if pf.exists():
            d = json.load(open(pf))
            self.visited = set(d.get('visited', []))
            self.credits = d.get('credits', 0)
            print(f"[RESUME] {len(self.visited)} pages done")
    
    def _save(self):
        pf = self.output / ".progress.json"
        json.dump({'visited': list(self.visited), 'credits': self.credits}, open(pf, 'w'))
    
    def _next_key(self) -> str:
        key = self.keys[self.key_index % len(self.keys)]
        self.key_index += 1
        return key
    
    async def _fetch(self, session: aiohttp.ClientSession, url: str) -> str | None:
        if url in self.visited:
            return None
        
        key = self._next_key()
        params = {'api_key': key, 'url': url}
        
        try:
            async with session.get(SCRAPERAPI, params=params, timeout=45) as r:
                self.credits += 1
                if r.status == 200:
                    html = await r.text()
                    if len(html) > 3000:
                        self.visited.add(url)
                        return html
                self.errors += 1
        except:
            self.errors += 1
        return None
    
    def _parse(self, html: str, url: str, pattern: str) -> tuple:
        soup = BeautifulSoup(html, 'html.parser')
        
        content = soup.select_one('main') or soup.select_one('body')
        if not content:
            return None, []
        
        title = soup.find('h1')
        title_text = title.get_text(strip=True) if title else url.split('/')[-1]
        
        for junk in content.find_all(['script', 'style', 'nav', 'footer']):
            junk.decompose()
        
        markdown = md(str(content), heading_style="ATX", code_language="mql5")
        markdown = re.sub(r'\n{3,}', '\n\n', markdown)
        
        # Find links
        links = []
        for a in soup.find_all('a', href=True):
            href = a['href']
            full = urljoin(url, href)
            if pattern in full and full.startswith(BASE_URL) and '#' not in href:
                if full not in self.visited:
                    links.append(full)
        
        return {'url': url, 'title': title_text, 'content': markdown}, links
    
    def _save_page(self, data: dict):
        path = urlparse(data['url']).path
        path = re.sub(r'^/en/(docs|book|code)/?', '', path)
        fname = path.replace('/', '_').strip('_')[:80] or 'index'
        fname = re.sub(r'[<>:"/\\|?*]', '_', fname)
        
        fp = self.output / f"{fname}.md"
        with open(fp, 'w', encoding='utf-8') as f:
            f.write(f"# {data['title']}\n\nSource: {data['url']}\n\n{data['content']}")
    
    async def _worker(self, session: aiohttp.ClientSession, pattern: str, worker_id: int):
        while self.running:
            if not self.to_visit:
                await asyncio.sleep(0.5)
                continue
            
            try:
                url = self.to_visit.popleft()
            except:
                await asyncio.sleep(0.2)
                continue
            
            if url in self.visited:
                continue
            
            html = await self._fetch(session, url)
            if html:
                data, links = self._parse(html, url, pattern)
                if data:
                    self._save_page(data)
                    self.success += 1
                    
                    # Add new links
                    for link in links:
                        if link not in self.visited and link not in self.to_visit:
                            self.to_visit.append(link)
    
    async def _progress_reporter(self, max_pages: int):
        """Show progress every second"""
        last_success = 0
        while self.running:
            speed = self.success - last_success
            last_success = self.success
            
            bar_len = 30
            pct = min(100, self.success * 100 // max_pages) if max_pages > 0 else 0
            filled = bar_len * pct // 100
            bar = '█' * filled + '░' * (bar_len - filled)
            
            sys.stdout.write(f"\r[{bar}] {self.success}/{max_pages} | {speed}/s | Q:{len(self.to_visit)} | Err:{self.errors} | Cred:{self.credits}  ")
            sys.stdout.flush()
            
            if self.success >= max_pages:
                self.running = False
                break
            
            # Save progress periodically
            if self.success % 50 == 0 and self.success > 0:
                self._save()
            
            await asyncio.sleep(1)
    
    async def scrape(self, start_url: str, pattern: str, max_pages: int):
        print(f"\n{'='*60}")
        print(f"TURBO SCRAPER - {len(self.keys)} keys x 5 = {len(self.keys)*5} workers")
        print(f"{'='*60}")
        print(f"Target: {start_url}")
        print(f"Max: {max_pages} pages")
        print(f"Pattern: {pattern}")
        print()
        
        self.to_visit.append(start_url)
        self.running = True
        
        num_workers = len(self.keys) * 5  # 5 per key
        
        conn = aiohttp.TCPConnector(limit=num_workers + 5)
        async with aiohttp.ClientSession(connector=conn) as session:
            # Start workers
            workers = [asyncio.create_task(self._worker(session, pattern, i)) 
                      for i in range(num_workers)]
            
            # Start progress reporter
            reporter = asyncio.create_task(self._progress_reporter(max_pages))
            
            # Wait for completion or max pages
            while self.running and self.success < max_pages:
                await asyncio.sleep(0.5)
                
                # Check if queue is empty and no progress
                if len(self.to_visit) == 0 and self.success > 0:
                    await asyncio.sleep(2)  # Wait for pending requests
                    if len(self.to_visit) == 0:
                        print("\n\n[INFO] Queue empty - no more pages to scrape")
                        break
            
            self.running = False
            
            # Cancel workers
            for w in workers:
                w.cancel()
            reporter.cancel()
        
        self._save()
        
        print(f"\n\n{'='*60}")
        print(f"COMPLETE!")
        print(f"{'='*60}")
        print(f"Pages scraped: {self.success}")
        print(f"Errors: {self.errors}")
        print(f"Credits used: {self.credits}")
        print(f"Output: {self.output}")


async def main():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--test', action='store_true', help="Test API keys")
    parser.add_argument('--book', action='store_true', help="Scrape book")
    parser.add_argument('--reference', action='store_true', help="Scrape reference")  
    parser.add_argument('--all', action='store_true', help="Scrape all")
    parser.add_argument('-m', '--max', type=int, default=500, help="Max pages per section")
    parser.add_argument('-o', '--output', default='./DOCS/SCRAPED', help="Output dir")
    args = parser.parse_args()
    
    # Test keys first
    working_keys = await test_keys()
    
    if not working_keys:
        print("\n[ERROR] No working API keys!")
        return 1
    
    if args.test:
        return 0
    
    if args.all:
        args.book = args.reference = True
    
    if not args.book and not args.reference:
        args.book = True
    
    print(f"\n{'='*60}")
    print(f"READY: {len(working_keys)} keys = {len(working_keys)*5} concurrent workers")
    print(f"Total credits available: ~{len(working_keys)*5000}")
    print(f"{'='*60}")
    
    if args.book:
        scraper = TurboScraper(working_keys, f"{args.output}/book")
        await scraper.scrape(f"{BASE_URL}/en/book", '/en/book/', min(args.max, 300))
    
    if args.reference:
        scraper = TurboScraper(working_keys, f"{args.output}/reference")
        await scraper.scrape(f"{BASE_URL}/en/docs", '/en/docs/', args.max)
    
    print("\n[DONE] All scraping complete!")
    return 0


if __name__ == "__main__":
    exit(asyncio.run(main()))
