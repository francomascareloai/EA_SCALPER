"""
MQL5 FAST Scraper - Maximum Speed Mode
======================================
Uses direct IP (no Tor) with async/parallel requests for maximum speed.
Will likely get blocked after 200-500 pages, but scrapes fast until then.

Usage:
    python scrape_mql5_fast.py --test          # Test connection
    python scrape_mql5_fast.py --book -w 10    # Scrape book with 10 workers
    python scrape_mql5_fast.py --all -w 15     # Scrape everything with 15 workers
"""

import asyncio
import aiohttp
import time
import json
import re
import random
from pathlib import Path
from urllib.parse import urljoin, urlparse
from typing import Optional, Set, List
import argparse
from dataclasses import dataclass
from collections import deque

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


# Configuration
BASE_URL = "https://www.mql5.com"
DOCS_URL = f"{BASE_URL}/en/docs"
BOOK_URL = f"{BASE_URL}/en/book"
CODEBASE_URL = f"{BASE_URL}/en/code"

USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15",
]


@dataclass
class ScrapedPage:
    url: str
    title: str
    content: str
    links: List[str]


class FastMQL5Scraper:
    def __init__(self, output_dir: Path, workers: int = 10, delay: float = 0.3):
        self.output_dir = Path(output_dir)
        self.workers = workers
        self.delay = delay
        self.visited: Set[str] = set()
        self.failed: List[dict] = []
        self.success_count = 0
        self.error_count = 0
        self.blocked = False
        
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self._load_progress()
    
    def _load_progress(self):
        progress_file = self.output_dir / ".progress.json"
        if progress_file.exists():
            with open(progress_file, 'r') as f:
                data = json.load(f)
                self.visited = set(data.get('visited', []))
            print(f"[RESUME] {len(self.visited)} pages already done")
    
    def _save_progress(self):
        progress_file = self.output_dir / ".progress.json"
        with open(progress_file, 'w') as f:
            json.dump({'visited': list(self.visited)}, f)
    
    def _get_headers(self) -> dict:
        return {
            "User-Agent": random.choice(USER_AGENTS),
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "en-US,en;q=0.9",
        }
    
    async def _fetch_page(self, session: aiohttp.ClientSession, url: str) -> Optional[str]:
        if url in self.visited or self.blocked:
            return None
        
        try:
            await asyncio.sleep(self.delay + random.uniform(0, 0.2))
            
            async with session.get(url, headers=self._get_headers(), timeout=30) as response:
                if response.status == 200:
                    self.visited.add(url)
                    return await response.text()
                elif response.status == 403:
                    self.error_count += 1
                    if self.error_count > 10:
                        print("\n[BLOCKED] Too many 403 errors - stopping")
                        self.blocked = True
                    return None
                elif response.status == 429:
                    print("\n[RATE LIMITED] Waiting 30s...")
                    await asyncio.sleep(30)
                    return None
                else:
                    return None
        except Exception as e:
            self.failed.append({'url': url, 'error': str(e)[:100]})
            return None
    
    def _extract_content(self, html: str, url: str) -> Optional[ScrapedPage]:
        soup = BeautifulSoup(html, 'html.parser')
        
        # Find content
        content = None
        for selector in ['main', 'div.doc-content', 'article', 'body']:
            content = soup.select_one(selector)
            if content and len(content.get_text(strip=True)) > 100:
                break
        
        if not content:
            return None
        
        # Title
        title = soup.find('h1')
        title_text = title.get_text(strip=True) if title else urlparse(url).path.split('/')[-1]
        
        # Remove junk
        for elem in content.find_all(['script', 'style', 'nav', 'footer', 'aside']):
            elem.decompose()
        
        # Convert to markdown
        markdown = md(str(content), heading_style="ATX", code_language="mql5")
        markdown = re.sub(r'\n{3,}', '\n\n', markdown)
        
        # Find links
        links = []
        for a in soup.find_all('a', href=True):
            href = a['href']
            full_url = urljoin(url, href)
            if full_url.startswith(BASE_URL) and '#' not in href:
                links.append(full_url)
        
        return ScrapedPage(url=url, title=title_text, content=markdown, links=links)
    
    def _save_page(self, page: ScrapedPage):
        path = urlparse(page.url).path
        path = re.sub(r'^/en/(docs|book|code)/?', '', path)
        filename = path.replace('/', '_').strip('_')[:80] or 'index'
        filename = re.sub(r'[<>:"/\\|?*]', '_', filename)
        
        filepath = self.output_dir / f"{filename}.md"
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(f"# {page.title}\n\n")
            f.write(f"Source: {page.url}\n\n")
            f.write(page.content)
    
    async def _worker(self, session: aiohttp.ClientSession, queue: asyncio.Queue, 
                      link_pattern: str, pbar: tqdm, max_pages: int):
        while self.success_count < max_pages and not self.blocked:
            try:
                url = await asyncio.wait_for(queue.get(), timeout=5)
            except asyncio.TimeoutError:
                break
            
            if url in self.visited:
                queue.task_done()
                continue
            
            html = await self._fetch_page(session, url)
            if html:
                page = self._extract_content(html, url)
                if page:
                    self._save_page(page)
                    self.success_count += 1
                    pbar.update(1)
                    pbar.set_postfix({'page': page.title[:20], 'ok': self.success_count, 'err': self.error_count})
                    
                    # Add new links
                    for link in page.links:
                        if link_pattern in link and link not in self.visited:
                            await queue.put(link)
            
            queue.task_done()
            
            if self.success_count % 50 == 0:
                self._save_progress()
    
    async def scrape(self, start_url: str, link_pattern: str, max_pages: int = 500):
        print(f"\n{'='*60}")
        print(f"FAST SCRAPER - {self.workers} workers")
        print(f"{'='*60}")
        print(f"Start: {start_url}")
        print(f"Max pages: {max_pages}")
        print(f"Delay: {self.delay}s")
        print()
        
        queue: asyncio.Queue = asyncio.Queue()
        await queue.put(start_url)
        
        connector = aiohttp.TCPConnector(limit=self.workers, limit_per_host=self.workers)
        timeout = aiohttp.ClientTimeout(total=30)
        
        async with aiohttp.ClientSession(connector=connector, timeout=timeout) as session:
            with tqdm(total=max_pages, desc="Scraping") as pbar:
                workers = [
                    asyncio.create_task(self._worker(session, queue, link_pattern, pbar, max_pages))
                    for _ in range(self.workers)
                ]
                
                await asyncio.gather(*workers)
        
        self._save_progress()
        
        print(f"\n{'='*60}")
        print(f"COMPLETE")
        print(f"{'='*60}")
        print(f"Success: {self.success_count}")
        print(f"Errors: {self.error_count}")
        print(f"Blocked: {self.blocked}")
        print(f"Output: {self.output_dir}")
    
    async def test_connection(self) -> bool:
        print("\n[TEST] Testing connection...")
        
        connector = aiohttp.TCPConnector(limit=1)
        async with aiohttp.ClientSession(connector=connector) as session:
            try:
                async with session.get(f"{BASE_URL}/en/docs", headers=self._get_headers(), timeout=15) as resp:
                    print(f"[TEST] Status: {resp.status}")
                    if resp.status == 200:
                        html = await resp.text()
                        print(f"[TEST] Response: {len(html)} bytes")
                        print("[TEST] SUCCESS!")
                        return True
                    else:
                        print("[TEST] FAILED - Non-200 status")
                        return False
            except Exception as e:
                print(f"[TEST] FAILED: {e}")
                return False


async def main():
    parser = argparse.ArgumentParser(description="MQL5 Fast Scraper")
    parser.add_argument('--output', '-o', default='./DOCS/SCRAPED', help="Output directory")
    parser.add_argument('--workers', '-w', type=int, default=10, help="Number of workers (5-20)")
    parser.add_argument('--delay', '-d', type=float, default=0.3, help="Delay between requests")
    parser.add_argument('--max-pages', '-m', type=int, default=500, help="Max pages to scrape")
    parser.add_argument('--test', action='store_true', help="Test connection only")
    
    parser.add_argument('--book', action='store_true', help="Scrape MQL5 Book")
    parser.add_argument('--reference', action='store_true', help="Scrape MQL5 Reference")
    parser.add_argument('--codebase', action='store_true', help="Scrape Code Base")
    parser.add_argument('--all', action='store_true', help="Scrape everything")
    
    args = parser.parse_args()
    args.workers = max(3, min(20, args.workers))
    
    output_dir = Path(args.output)
    
    if args.test:
        scraper = FastMQL5Scraper(output_dir, workers=1)
        success = await scraper.test_connection()
        return 0 if success else 1
    
    if args.all:
        args.book = args.reference = args.codebase = True
    
    if not any([args.book, args.reference, args.codebase]):
        args.book = True
    
    print("""
================================================================
     MQL5 FAST SCRAPER - MAXIMUM SPEED MODE
================================================================
  WARNING: Using direct IP (no Tor)
  - Fast but may get blocked after ~200-500 pages
  - Progress is saved - can resume if blocked
================================================================
    """)
    
    if args.reference:
        scraper = FastMQL5Scraper(output_dir / "reference", workers=args.workers, delay=args.delay)
        await scraper.scrape(DOCS_URL, '/en/docs/', max_pages=args.max_pages)
    
    if args.book:
        scraper = FastMQL5Scraper(output_dir / "book", workers=args.workers, delay=args.delay)
        await scraper.scrape(BOOK_URL, '/en/book/', max_pages=args.max_pages)
    
    if args.codebase:
        for section in ['experts', 'indicators', 'scripts', 'libraries']:
            scraper = FastMQL5Scraper(output_dir / f"codebase_{section}", workers=args.workers, delay=args.delay)
            await scraper.scrape(f"{CODEBASE_URL}/mt5/{section}", '/en/code/', max_pages=args.max_pages // 4)
    
    print("\n[DONE] Scraping complete!")
    return 0


if __name__ == "__main__":
    exit(asyncio.run(main()))
