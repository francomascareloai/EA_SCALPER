"""
MQL5 Scraper using ScraperAPI
=============================
Uses ScraperAPI service for reliable scraping with rotating IPs.

Usage:
    python scrape_mql5_scraperapi.py --test
    python scrape_mql5_scraperapi.py --book -w 5 -m 500
    python scrape_mql5_scraperapi.py --all -w 5 -m 2000
"""

import asyncio
import aiohttp
import time
import json
import re
import random
from pathlib import Path
from urllib.parse import urljoin, urlparse, quote
from typing import Optional, Set, List
import argparse

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

# ScraperAPI endpoint
SCRAPERAPI_URL = "http://api.scraperapi.com"


class ScraperAPIScraper:
    """Scraper using ScraperAPI service"""
    
    def __init__(self, api_key: str, output_dir: Path, workers: int = 5):
        self.api_key = api_key
        self.output_dir = Path(output_dir)
        self.workers = min(workers, 5)  # Free tier: max 5 concurrent
        self.visited: Set[str] = set()
        self.failed: List[dict] = []
        self.success_count = 0
        self.error_count = 0
        self.credits_used = 0
        self.lock = asyncio.Lock()
        
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self._load_progress()
    
    def _load_progress(self):
        progress_file = self.output_dir / ".progress.json"
        if progress_file.exists():
            with open(progress_file, 'r') as f:
                data = json.load(f)
                self.visited = set(data.get('visited', []))
                self.credits_used = data.get('credits_used', 0)
            print(f"[RESUME] {len(self.visited)} pages done, {self.credits_used} credits used")
    
    def _save_progress(self):
        progress_file = self.output_dir / ".progress.json"
        with open(progress_file, 'w') as f:
            json.dump({
                'visited': list(self.visited),
                'credits_used': self.credits_used
            }, f)
    
    async def _fetch_page(self, session: aiohttp.ClientSession, url: str) -> Optional[str]:
        """Fetch page using ScraperAPI"""
        if url in self.visited:
            return None
        
        # ScraperAPI request
        params = {
            'api_key': self.api_key,
            'url': url,
            'render': 'false',  # Don't need JS rendering for MQL5
        }
        
        try:
            async with session.get(SCRAPERAPI_URL, params=params, timeout=60) as resp:
                async with self.lock:
                    self.credits_used += 1
                
                if resp.status == 200:
                    html = await resp.text()
                    if len(html) > 5000:
                        async with self.lock:
                            self.visited.add(url)
                        return html
                    else:
                        async with self.lock:
                            self.error_count += 1
                        return None
                
                elif resp.status == 403:
                    # ScraperAPI couldn't bypass
                    async with self.lock:
                        self.error_count += 1
                    return None
                
                elif resp.status == 429:
                    # Rate limited
                    print("\n[RATE LIMIT] Waiting 5s...")
                    await asyncio.sleep(5)
                    return None
                
                else:
                    async with self.lock:
                        self.error_count += 1
                    return None
                    
        except Exception as e:
            async with self.lock:
                self.error_count += 1
                self.failed.append({'url': url, 'error': str(e)[:100]})
            return None
    
    def _extract_content(self, html: str, url: str) -> Optional[dict]:
        """Extract content from HTML"""
        soup = BeautifulSoup(html, 'html.parser')
        
        content = None
        for selector in ['main', 'div.doc-content', 'article', 'body']:
            content = soup.select_one(selector)
            if content and len(content.get_text(strip=True)) > 100:
                break
        
        if not content:
            return None
        
        title = soup.find('h1')
        title_text = title.get_text(strip=True) if title else urlparse(url).path.split('/')[-1]
        
        for elem in content.find_all(['script', 'style', 'nav', 'footer', 'aside']):
            elem.decompose()
        
        markdown = md(str(content), heading_style="ATX", code_language="mql5")
        markdown = re.sub(r'\n{3,}', '\n\n', markdown)
        
        links = []
        for a in soup.find_all('a', href=True):
            href = a['href']
            full_url = urljoin(url, href)
            if full_url.startswith(BASE_URL) and '#' not in href:
                links.append(full_url)
        
        return {'url': url, 'title': title_text, 'content': markdown, 'links': links}
    
    def _save_page(self, data: dict):
        """Save page to file"""
        path = urlparse(data['url']).path
        path = re.sub(r'^/en/(docs|book|code)/?', '', path)
        filename = path.replace('/', '_').strip('_')[:80] or 'index'
        filename = re.sub(r'[<>:"/\\|?*]', '_', filename)
        
        filepath = self.output_dir / f"{filename}.md"
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(f"# {data['title']}\n\n")
            f.write(f"Source: {data['url']}\n\n")
            f.write(data['content'])
    
    async def _worker(self, session: aiohttp.ClientSession, queue: asyncio.Queue,
                      link_pattern: str, pbar: tqdm, max_pages: int, max_credits: int):
        """Worker coroutine"""
        while self.success_count < max_pages and self.credits_used < max_credits:
            try:
                url = await asyncio.wait_for(queue.get(), timeout=10)
            except asyncio.TimeoutError:
                break
            
            if url in self.visited:
                queue.task_done()
                continue
            
            html = await self._fetch_page(session, url)
            if html:
                data = self._extract_content(html, url)
                if data:
                    self._save_page(data)
                    
                    async with self.lock:
                        self.success_count += 1
                    
                    pbar.update(1)
                    pbar.set_postfix({
                        'ok': self.success_count,
                        'err': self.error_count,
                        'credits': self.credits_used
                    })
                    
                    for link in data['links']:
                        if link_pattern in link and link not in self.visited:
                            await queue.put(link)
            
            queue.task_done()
            
            # Small delay to be nice to the API
            await asyncio.sleep(0.2)
            
            if self.success_count % 25 == 0:
                self._save_progress()
    
    async def test_connection(self) -> bool:
        """Test ScraperAPI connection"""
        print("\n[TEST] Testing ScraperAPI connection...")
        
        params = {
            'api_key': self.api_key,
            'url': f'{BASE_URL}/en/book',
        }
        
        async with aiohttp.ClientSession() as session:
            try:
                async with session.get(SCRAPERAPI_URL, params=params, timeout=30) as resp:
                    print(f"[TEST] Status: {resp.status}")
                    if resp.status == 200:
                        html = await resp.text()
                        print(f"[TEST] Response: {len(html)} bytes")
                        if len(html) > 5000 and 'MQL5' in html:
                            print("[TEST] SUCCESS! ScraperAPI working!")
                            return True
                        else:
                            print("[TEST] FAILED - Response too short or blocked")
                            return False
                    elif resp.status == 401:
                        print("[TEST] FAILED - Invalid API key")
                        return False
                    elif resp.status == 403:
                        print("[TEST] FAILED - Access denied")
                        return False
                    else:
                        print(f"[TEST] FAILED - Status {resp.status}")
                        return False
            except Exception as e:
                print(f"[TEST] FAILED: {e}")
                return False
    
    async def scrape(self, start_url: str, link_pattern: str, max_pages: int = 500, max_credits: int = 5000):
        """Main scraping function"""
        print(f"\n{'='*60}")
        print(f"SCRAPERAPI SCRAPER - {self.workers} workers")
        print(f"{'='*60}")
        print(f"Start: {start_url}")
        print(f"Max pages: {max_pages}")
        print(f"Max credits: {max_credits}")
        print(f"Credits used so far: {self.credits_used}")
        
        queue: asyncio.Queue = asyncio.Queue()
        await queue.put(start_url)
        
        connector = aiohttp.TCPConnector(limit=self.workers)
        timeout = aiohttp.ClientTimeout(total=60)
        
        async with aiohttp.ClientSession(connector=connector, timeout=timeout) as session:
            with tqdm(total=max_pages, desc="Scraping") as pbar:
                pbar.update(0)  # Show initial state
                
                workers = [
                    asyncio.create_task(self._worker(session, queue, link_pattern, pbar, max_pages, max_credits))
                    for _ in range(self.workers)
                ]
                
                await asyncio.gather(*workers)
        
        self._save_progress()
        
        print(f"\n{'='*60}")
        print(f"COMPLETE")
        print(f"{'='*60}")
        print(f"Success: {self.success_count}")
        print(f"Errors: {self.error_count}")
        print(f"Credits used this session: {self.credits_used}")
        print(f"Output: {self.output_dir}")


async def main():
    parser = argparse.ArgumentParser(description="MQL5 ScraperAPI Scraper")
    parser.add_argument('--api-key', '-k', type=str, 
                        default='b84546de6adc1afc3a4fdfb85b1bdcd8',
                        help="ScraperAPI key")
    parser.add_argument('--output', '-o', default='./DOCS/SCRAPED', help="Output directory")
    parser.add_argument('--workers', '-w', type=int, default=5, help="Workers (max 5 for free)")
    parser.add_argument('--max-pages', '-m', type=int, default=500, help="Max pages")
    parser.add_argument('--max-credits', '-c', type=int, default=4500, help="Max credits to use")
    parser.add_argument('--test', action='store_true', help="Test connection only")
    
    parser.add_argument('--book', action='store_true', help="Scrape MQL5 Book")
    parser.add_argument('--reference', action='store_true', help="Scrape MQL5 Reference")
    parser.add_argument('--codebase', action='store_true', help="Scrape Code Base")
    parser.add_argument('--all', action='store_true', help="Scrape everything")
    
    args = parser.parse_args()
    
    output_dir = Path(args.output)
    
    if args.test:
        scraper = ScraperAPIScraper(args.api_key, output_dir, workers=1)
        success = await scraper.test_connection()
        return 0 if success else 1
    
    if args.all:
        args.book = args.reference = args.codebase = True
    
    if not any([args.book, args.reference, args.codebase]):
        args.book = True
    
    print("""
================================================================
     MQL5 SCRAPERAPI SCRAPER - PROFESSIONAL PROXIES
================================================================
  Features:
  - Automatic IP rotation
  - CAPTCHA bypass
  - Geo-targeting
  - 99.99% uptime
================================================================
    """)
    
    # Calculate credits per section
    sections = sum([args.book, args.reference, args.codebase])
    credits_per_section = args.max_credits // max(sections, 1)
    
    if args.book:
        scraper = ScraperAPIScraper(args.api_key, output_dir / "book", workers=args.workers)
        await scraper.scrape(BOOK_URL, '/en/book/', 
                            max_pages=min(args.max_pages, 300),
                            max_credits=credits_per_section)
    
    if args.reference:
        scraper = ScraperAPIScraper(args.api_key, output_dir / "reference", workers=args.workers)
        await scraper.scrape(DOCS_URL, '/en/docs/', 
                            max_pages=args.max_pages,
                            max_credits=credits_per_section)
    
    if args.codebase:
        creds_per_cb = credits_per_section // 4
        for section in ['experts', 'indicators', 'scripts', 'libraries']:
            scraper = ScraperAPIScraper(args.api_key, output_dir / f"codebase_{section}", workers=args.workers)
            await scraper.scrape(f"{CODEBASE_URL}/mt5/{section}", '/en/code/', 
                                max_pages=args.max_pages // 4,
                                max_credits=creds_per_cb)
    
    print("\n[DONE] Scraping complete!")
    return 0


if __name__ == "__main__":
    exit(asyncio.run(main()))
