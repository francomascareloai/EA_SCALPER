"""
MQL5 Scraper - Multi-Key ScraperAPI (TURBO MODE)
================================================
Uses multiple ScraperAPI keys for maximum speed.
3 keys x 5 threads = 15 concurrent requests!

Usage:
    python scrape_mql5_multikey.py --test
    python scrape_mql5_multikey.py --all
"""

import asyncio
import aiohttp
import time
import json
import re
from pathlib import Path
from urllib.parse import urljoin, urlparse
from typing import Optional, Set, List
import argparse
from itertools import cycle

try:
    from bs4 import BeautifulSoup
    from markdownify import markdownify as md
    from tqdm import tqdm
except ImportError:
    import subprocess
    subprocess.check_call(["pip", "install", "beautifulsoup4", "markdownify", "tqdm", "aiohttp"])
    from bs4 import BeautifulSoup
    from markdownify import markdownify as md
    from tqdm import tqdm

# API Keys (3 accounts x 5000 credits = 15000 total)
API_KEYS = [
    "b84546de6adc1afc3a4fdfb85b1bdcd8",
    "38386c4ea4b9408a6ddf792f17603fde",
    "9d9c82356cf9e7815a305bcde1a4e9ae",
]

# Configuration
BASE_URL = "https://www.mql5.com"
SCRAPERAPI_URL = "http://api.scraperapi.com"


class TurboScraper:
    def __init__(self, output_dir: Path):
        self.output_dir = Path(output_dir)
        self.api_keys = cycle(API_KEYS)
        self.visited: Set[str] = set()
        self.queue: asyncio.Queue = asyncio.Queue()
        self.success = 0
        self.errors = 0
        self.credits = 0
        self.lock = asyncio.Lock()
        self.pbar: Optional[tqdm] = None
        
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self._load_progress()
    
    def _load_progress(self):
        pf = self.output_dir / ".progress.json"
        if pf.exists():
            data = json.load(open(pf))
            self.visited = set(data.get('visited', []))
            self.credits = data.get('credits', 0)
            print(f"[RESUME] {len(self.visited)} done, {self.credits} credits used")
    
    def _save_progress(self):
        pf = self.output_dir / ".progress.json"
        json.dump({'visited': list(self.visited), 'credits': self.credits}, open(pf, 'w'))
    
    def _get_key(self) -> str:
        return next(self.api_keys)
    
    async def _fetch(self, session: aiohttp.ClientSession, url: str) -> Optional[str]:
        """Fetch with ScraperAPI"""
        if url in self.visited:
            return None
        
        key = self._get_key()
        params = {'api_key': key, 'url': url}
        
        try:
            async with session.get(SCRAPERAPI_URL, params=params, timeout=45) as r:
                async with self.lock:
                    self.credits += 1
                
                if r.status == 200:
                    html = await r.text()
                    if len(html) > 3000:
                        async with self.lock:
                            self.visited.add(url)
                        return html
                
                async with self.lock:
                    self.errors += 1
                return None
        except:
            async with self.lock:
                self.errors += 1
            return None
    
    def _parse(self, html: str, url: str) -> Optional[dict]:
        """Parse HTML to markdown"""
        soup = BeautifulSoup(html, 'html.parser')
        
        content = soup.select_one('main') or soup.select_one('body')
        if not content or len(content.get_text(strip=True)) < 100:
            return None
        
        title = soup.find('h1')
        title_text = title.get_text(strip=True) if title else url.split('/')[-1]
        
        for junk in content.find_all(['script', 'style', 'nav', 'footer', 'aside']):
            junk.decompose()
        
        markdown = md(str(content), heading_style="ATX", code_language="mql5")
        markdown = re.sub(r'\n{3,}', '\n\n', markdown)
        
        links = [urljoin(url, a['href']) for a in soup.find_all('a', href=True) 
                 if a['href'].startswith('/en/') and '#' not in a['href']]
        
        return {'url': url, 'title': title_text, 'content': markdown, 'links': links}
    
    def _save(self, data: dict):
        """Save to file"""
        path = urlparse(data['url']).path
        path = re.sub(r'^/en/(docs|book|code)/?', '', path)
        fname = path.replace('/', '_').strip('_')[:80] or 'index'
        fname = re.sub(r'[<>:"/\\|?*]', '_', fname)
        
        with open(self.output_dir / f"{fname}.md", 'w', encoding='utf-8') as f:
            f.write(f"# {data['title']}\n\nSource: {data['url']}\n\n{data['content']}")
    
    async def _worker(self, session: aiohttp.ClientSession, pattern: str, max_pages: int):
        """Worker task"""
        while self.success < max_pages:
            try:
                url = await asyncio.wait_for(self.queue.get(), timeout=5)
            except asyncio.TimeoutError:
                break
            
            if url in self.visited:
                self.queue.task_done()
                continue
            
            html = await self._fetch(session, url)
            if html:
                data = self._parse(html, url)
                if data:
                    self._save(data)
                    async with self.lock:
                        self.success += 1
                    
                    if self.pbar:
                        self.pbar.update(1)
                        self.pbar.set_postfix({'ok': self.success, 'err': self.errors, 'cred': self.credits})
                    
                    for link in data['links']:
                        if pattern in link and link not in self.visited:
                            await self.queue.put(link)
            
            self.queue.task_done()
            
            if self.success % 50 == 0:
                self._save_progress()
    
    async def scrape(self, start_url: str, pattern: str, max_pages: int = 1000):
        """Main scrape function"""
        print(f"\n{'='*60}")
        print(f"TURBO SCRAPER - 15 concurrent (3 keys x 5 threads)")
        print(f"{'='*60}")
        print(f"Target: {start_url}")
        print(f"Max: {max_pages} pages")
        print()
        
        await self.queue.put(start_url)
        
        conn = aiohttp.TCPConnector(limit=15)
        async with aiohttp.ClientSession(connector=conn) as session:
            self.pbar = tqdm(total=max_pages, desc="Scraping")
            
            # 15 workers (3 keys x 5 concurrent each)
            workers = [asyncio.create_task(self._worker(session, pattern, max_pages)) for _ in range(15)]
            await asyncio.gather(*workers)
            
            self.pbar.close()
        
        self._save_progress()
        print(f"\nDONE: {self.success} pages, {self.credits} credits used")


async def test():
    """Test all API keys"""
    print("\n[TEST] Testing API keys...")
    
    async with aiohttp.ClientSession() as session:
        for i, key in enumerate(API_KEYS, 1):
            params = {'api_key': key, 'url': f'{BASE_URL}/en/book'}
            try:
                async with session.get(SCRAPERAPI_URL, params=params, timeout=30) as r:
                    if r.status == 200 and len(await r.text()) > 5000:
                        print(f"  Key {i}: OK")
                    else:
                        print(f"  Key {i}: FAILED (status {r.status})")
            except Exception as e:
                print(f"  Key {i}: ERROR - {e}")
    
    print("\n[TEST] Complete!")
    return True


async def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--test', action='store_true')
    parser.add_argument('--book', action='store_true')
    parser.add_argument('--reference', action='store_true')
    parser.add_argument('--all', action='store_true')
    parser.add_argument('-m', '--max', type=int, default=1000)
    parser.add_argument('-o', '--output', default='./DOCS/SCRAPED')
    args = parser.parse_args()
    
    if args.test:
        return await test()
    
    if args.all:
        args.book = args.reference = True
    
    if not args.book and not args.reference:
        args.book = True
    
    print("""
================================================================
   TURBO SCRAPER - 3 API KEYS x 5 THREADS = 15 CONCURRENT
================================================================
   15,000 credits available | ~15 pages/second potential
================================================================
    """)
    
    out = Path(args.output)
    
    if args.book:
        scraper = TurboScraper(out / "book")
        await scraper.scrape(f"{BASE_URL}/en/book", '/en/book/', min(args.max, 300))
    
    if args.reference:
        scraper = TurboScraper(out / "reference")
        await scraper.scrape(f"{BASE_URL}/en/docs", '/en/docs/', args.max)


if __name__ == "__main__":
    asyncio.run(main())
