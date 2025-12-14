"""
MQL5 Multi-Proxy Scraper - Rotating Free Proxies
=================================================
Uses multiple free proxies to rotate IPs and avoid blocking.

Usage:
    python scrape_mql5_multiproxy.py --test           # Test and find working proxies
    python scrape_mql5_multiproxy.py --book -w 20     # Scrape book with 20 workers
    python scrape_mql5_multiproxy.py --all -w 30      # Scrape everything
"""

import asyncio
import aiohttp
import time
import json
import re
import random
from pathlib import Path
from urllib.parse import urljoin, urlparse
from typing import Optional, Set, List, Dict
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
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
]

# Free proxy sources
PROXY_SOURCES = [
    "https://raw.githubusercontent.com/TheSpeedX/PROXY-List/master/http.txt",
    "https://raw.githubusercontent.com/clarketm/proxy-list/master/proxy-list-raw.txt",
    "https://raw.githubusercontent.com/ShiftyTR/Proxy-List/master/http.txt",
    "https://raw.githubusercontent.com/monosans/proxy-list/main/proxies/http.txt",
    "https://raw.githubusercontent.com/hookzof/socks5_list/master/proxy.txt",
]


class ProxyManager:
    """Manages a pool of rotating proxies"""
    
    def __init__(self):
        self.all_proxies: List[str] = []
        self.working_proxies: List[str] = []
        self.failed_proxies: Set[str] = set()
        self.proxy_fails: Dict[str, int] = {}
        self.lock = asyncio.Lock()
    
    async def fetch_proxies(self) -> int:
        """Fetch proxies from multiple sources"""
        print("\n[PROXY] Fetching proxy lists...")
        
        all_proxies = set()
        
        async with aiohttp.ClientSession() as session:
            for source in PROXY_SOURCES:
                try:
                    async with session.get(source, timeout=10) as resp:
                        if resp.status == 200:
                            text = await resp.text()
                            # Parse proxies (format: ip:port)
                            for line in text.strip().split('\n'):
                                line = line.strip()
                                if ':' in line and len(line) < 25:
                                    # Clean up the proxy
                                    proxy = line.split()[0] if ' ' in line else line
                                    if re.match(r'^\d+\.\d+\.\d+\.\d+:\d+$', proxy):
                                        all_proxies.add(proxy)
                            print(f"  [+] {source.split('/')[-1]}: found proxies")
                except Exception as e:
                    print(f"  [-] {source.split('/')[-1]}: failed")
        
        self.all_proxies = list(all_proxies)
        random.shuffle(self.all_proxies)
        
        print(f"\n[PROXY] Total unique proxies: {len(self.all_proxies)}")
        return len(self.all_proxies)
    
    async def test_proxy(self, session: aiohttp.ClientSession, proxy: str) -> bool:
        """Test if a proxy works with MQL5"""
        proxy_url = f"http://{proxy}"
        
        try:
            async with session.get(
                f"{BASE_URL}/en/book",
                proxy=proxy_url,
                timeout=aiohttp.ClientTimeout(total=15),
                headers={"User-Agent": random.choice(USER_AGENTS)},
                ssl=False  # Skip SSL verification for proxies
            ) as resp:
                if resp.status == 200:
                    text = await resp.text()
                    if len(text) > 5000:
                        return True
        except:
            pass
        return False
    
    async def find_working_proxies(self, max_proxies: int = 50, max_test: int = 200) -> int:
        """Test proxies and find working ones"""
        print(f"\n[PROXY] Testing proxies (max {max_test})...")
        
        if not self.all_proxies:
            await self.fetch_proxies()
        
        tested = 0
        working = 0
        
        connector = aiohttp.TCPConnector(limit=30, limit_per_host=5)
        async with aiohttp.ClientSession(connector=connector) as session:
            
            # Test in batches
            batch_size = 30
            proxies_to_test = self.all_proxies[:max_test]
            
            with tqdm(total=min(max_test, len(proxies_to_test)), desc="Testing proxies") as pbar:
                for i in range(0, len(proxies_to_test), batch_size):
                    batch = proxies_to_test[i:i+batch_size]
                    
                    tasks = [self.test_proxy(session, proxy) for proxy in batch]
                    results = await asyncio.gather(*tasks, return_exceptions=True)
                    
                    for proxy, result in zip(batch, results):
                        tested += 1
                        pbar.update(1)
                        
                        if result is True:
                            self.working_proxies.append(proxy)
                            working += 1
                            pbar.set_postfix({'working': working})
                            
                            if working >= max_proxies:
                                break
                    
                    if working >= max_proxies:
                        break
        
        print(f"\n[PROXY] Found {len(self.working_proxies)} working proxies")
        return len(self.working_proxies)
    
    async def get_proxy(self) -> Optional[str]:
        """Get a random working proxy"""
        async with self.lock:
            if not self.working_proxies:
                return None
            return random.choice(self.working_proxies)
    
    async def report_failure(self, proxy: str):
        """Report a proxy failure"""
        async with self.lock:
            self.proxy_fails[proxy] = self.proxy_fails.get(proxy, 0) + 1
            
            # Remove proxy if too many failures
            if self.proxy_fails[proxy] >= 3:
                if proxy in self.working_proxies:
                    self.working_proxies.remove(proxy)
                    self.failed_proxies.add(proxy)
    
    async def report_success(self, proxy: str):
        """Report a proxy success - reset failure count"""
        async with self.lock:
            self.proxy_fails[proxy] = 0


class MultiProxyScraper:
    """Scraper with rotating proxy support"""
    
    def __init__(self, output_dir: Path, workers: int = 20, delay: float = 0.1):
        self.output_dir = Path(output_dir)
        self.workers = workers
        self.delay = delay
        self.visited: Set[str] = set()
        self.failed: List[dict] = []
        self.success_count = 0
        self.error_count = 0
        self.blocked_count = 0
        self.proxy_manager = ProxyManager()
        self.lock = asyncio.Lock()
        
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
    
    async def _fetch_with_proxy(self, session: aiohttp.ClientSession, url: str) -> Optional[str]:
        """Fetch URL using a rotating proxy"""
        if url in self.visited:
            return None
        
        # Try up to 3 different proxies
        for attempt in range(3):
            proxy = await self.proxy_manager.get_proxy()
            if not proxy:
                # No proxies available, try direct
                proxy = None
            
            try:
                await asyncio.sleep(self.delay + random.uniform(0, 0.1))
                
                proxy_url = f"http://{proxy}" if proxy else None
                
                async with session.get(
                    url,
                    proxy=proxy_url,
                    headers=self._get_headers(),
                    timeout=aiohttp.ClientTimeout(total=15)
                ) as resp:
                    if resp.status == 200:
                        html = await resp.text()
                        if len(html) > 5000:
                            async with self.lock:
                                self.visited.add(url)
                            if proxy:
                                await self.proxy_manager.report_success(proxy)
                            return html
                        else:
                            # Might be blocked
                            if proxy:
                                await self.proxy_manager.report_failure(proxy)
                    
                    elif resp.status == 403:
                        async with self.lock:
                            self.blocked_count += 1
                        if proxy:
                            await self.proxy_manager.report_failure(proxy)
                    
                    elif resp.status == 429:
                        await asyncio.sleep(5)
                        if proxy:
                            await self.proxy_manager.report_failure(proxy)
                            
            except Exception as e:
                if proxy:
                    await self.proxy_manager.report_failure(proxy)
        
        async with self.lock:
            self.error_count += 1
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
                      link_pattern: str, pbar: tqdm, max_pages: int):
        """Worker coroutine"""
        while self.success_count < max_pages:
            try:
                url = await asyncio.wait_for(queue.get(), timeout=10)
            except asyncio.TimeoutError:
                break
            
            if url in self.visited:
                queue.task_done()
                continue
            
            html = await self._fetch_with_proxy(session, url)
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
                        'blk': self.blocked_count,
                        'prx': len(self.proxy_manager.working_proxies)
                    })
                    
                    for link in data['links']:
                        if link_pattern in link and link not in self.visited:
                            await queue.put(link)
            
            queue.task_done()
            
            if self.success_count % 50 == 0:
                self._save_progress()
    
    async def scrape(self, start_url: str, link_pattern: str, max_pages: int = 500):
        """Main scraping function"""
        print(f"\n{'='*60}")
        print(f"MULTI-PROXY SCRAPER - {self.workers} workers")
        print(f"{'='*60}")
        print(f"Start: {start_url}")
        print(f"Max pages: {max_pages}")
        
        # Find working proxies first
        num_proxies = await self.proxy_manager.find_working_proxies(max_proxies=50, max_test=300)
        
        if num_proxies < 5:
            print("\n[WARNING] Very few working proxies found. Scraping may be slow.")
        
        queue: asyncio.Queue = asyncio.Queue()
        await queue.put(start_url)
        
        connector = aiohttp.TCPConnector(limit=self.workers * 2, limit_per_host=5)
        timeout = aiohttp.ClientTimeout(total=20)
        
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
        print(f"Blocked: {self.blocked_count}")
        print(f"Working proxies remaining: {len(self.proxy_manager.working_proxies)}")
        print(f"Output: {self.output_dir}")


async def test_proxies():
    """Test proxy fetching and validation"""
    pm = ProxyManager()
    await pm.fetch_proxies()
    await pm.find_working_proxies(max_proxies=30, max_test=200)
    
    print(f"\n[RESULT] Working proxies: {len(pm.working_proxies)}")
    for proxy in pm.working_proxies[:10]:
        print(f"  - {proxy}")
    
    return len(pm.working_proxies)


async def main():
    parser = argparse.ArgumentParser(description="MQL5 Multi-Proxy Scraper")
    parser.add_argument('--output', '-o', default='./DOCS/SCRAPED', help="Output directory")
    parser.add_argument('--workers', '-w', type=int, default=20, help="Number of workers")
    parser.add_argument('--delay', '-d', type=float, default=0.1, help="Delay between requests")
    parser.add_argument('--max-pages', '-m', type=int, default=500, help="Max pages")
    parser.add_argument('--test', action='store_true', help="Test proxies only")
    
    parser.add_argument('--book', action='store_true', help="Scrape MQL5 Book")
    parser.add_argument('--reference', action='store_true', help="Scrape MQL5 Reference")
    parser.add_argument('--codebase', action='store_true', help="Scrape Code Base")
    parser.add_argument('--all', action='store_true', help="Scrape everything")
    
    args = parser.parse_args()
    
    if args.test:
        working = await test_proxies()
        return 0 if working > 0 else 1
    
    if args.all:
        args.book = args.reference = args.codebase = True
    
    if not any([args.book, args.reference, args.codebase]):
        args.book = True
    
    output_dir = Path(args.output)
    
    print("""
================================================================
     MQL5 MULTI-PROXY SCRAPER - ROTATING IPS
================================================================
  Features:
  - Fetches free proxies from multiple sources
  - Tests and validates each proxy
  - Rotates IP for each request
  - Auto-removes dead proxies
================================================================
    """)
    
    if args.reference:
        scraper = MultiProxyScraper(output_dir / "reference", workers=args.workers, delay=args.delay)
        await scraper.scrape(DOCS_URL, '/en/docs/', max_pages=args.max_pages)
    
    if args.book:
        scraper = MultiProxyScraper(output_dir / "book", workers=args.workers, delay=args.delay)
        await scraper.scrape(BOOK_URL, '/en/book/', max_pages=args.max_pages)
    
    if args.codebase:
        for section in ['experts', 'indicators', 'scripts', 'libraries']:
            scraper = MultiProxyScraper(output_dir / f"codebase_{section}", workers=args.workers, delay=args.delay)
            await scraper.scrape(f"{CODEBASE_URL}/mt5/{section}", '/en/code/', max_pages=args.max_pages // 4)
    
    print("\n[DONE] Scraping complete!")
    return 0


if __name__ == "__main__":
    exit(asyncio.run(main()))
