"""
MQL5 Documentation Scraper - TOR EDITION
=========================================
Advanced scraper with Tor proxy, user-agent rotation, and anti-blocking measures.

Prerequisites:
    1. Install Tor Browser OR Tor service
       - Tor Browser: Uses port 9150
       - Tor service: Uses port 9050
    
    2. Install Python packages:
       pip install requests[socks] beautifulsoup4 markdownify tqdm stem

Usage:
    # With Tor Browser running:
    python scrape_mql5_tor.py --output ./DOCS/SCRAPED --reference --tor-port 9150
    
    # With Tor service:
    python scrape_mql5_tor.py --output ./DOCS/SCRAPED --all --tor-port 9050
    
    # Test connection first:
    python scrape_mql5_tor.py --test-tor --tor-port 9150

Author: EA_SCALPER_XAUUSD Project
"""

import argparse
import time
import json
import re
import random
from pathlib import Path
from urllib.parse import urljoin, urlparse
from typing import Optional, List
import hashlib
from concurrent.futures import ThreadPoolExecutor, as_completed
import threading

try:
    import requests
    from bs4 import BeautifulSoup
    from markdownify import markdownify as md
    from tqdm import tqdm
except ImportError:
    print("Installing required packages...")
    import subprocess
    subprocess.check_call(["pip", "install", "requests[socks]", "beautifulsoup4", "markdownify", "tqdm", "PySocks"])
    import requests
    from bs4 import BeautifulSoup
    from markdownify import markdownify as md
    from tqdm import tqdm


# ============================================================================
# CONFIGURATION
# ============================================================================

BASE_URL = "https://www.mql5.com"
DOCS_URL = f"{BASE_URL}/en/docs"
BOOK_URL = f"{BASE_URL}/en/book"
ARTICLES_URL = f"{BASE_URL}/en/articles"
CODEBASE_URL = f"{BASE_URL}/en/code"

# Realistic User-Agent pool (Chrome, Firefox, Edge on Windows/Mac)
USER_AGENTS = [
    # Chrome Windows
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36",
    # Chrome Mac
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36",
    # Firefox Windows
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:120.0) Gecko/20100101 Firefox/120.0",
    # Firefox Mac
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:121.0) Gecko/20100101 Firefox/121.0",
    # Edge Windows
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0",
    # Safari Mac
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15",
]

# Browser headers (simplified for better compatibility)
def get_browser_headers(referer: str = None) -> dict:
    """Generate realistic browser headers"""
    headers = {
        "User-Agent": random.choice(USER_AGENTS),
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language": "en-US,en;q=0.9",
        # NOTE: Do NOT use Accept-Encoding with Tor - causes compression issues
        "Connection": "keep-alive",
        "Upgrade-Insecure-Requests": "1",
    }
    if referer:
        headers["Referer"] = referer
    return headers


# ============================================================================
# TOR SCRAPER CLASS
# ============================================================================

class TorMQL5Scraper:
    """Advanced MQL5 scraper with Tor proxy and anti-blocking measures"""
    
    def __init__(
        self, 
        output_dir: Path, 
        tor_port: int = 9150,
        min_delay: float = 2.0,
        max_delay: float = 5.0,
        use_tor: bool = True,
        cookies: dict = None
    ):
        self.output_dir = Path(output_dir)
        self.tor_port = tor_port
        self.min_delay = min_delay
        self.max_delay = max_delay
        self.use_tor = use_tor
        self.visited = set()
        self.failed = []
        self.last_url = BASE_URL
        self.request_count = 0
        self.consecutive_errors = 0
        self.lock = threading.Lock()  # Thread safety
        
        # Create session
        self.session = requests.Session()
        
        # Configure Tor proxy (socks5h for remote DNS resolution)
        if use_tor:
            self.session.proxies = {
                'http': f'socks5h://127.0.0.1:{tor_port}',
                'https': f'socks5h://127.0.0.1:{tor_port}'
            }
            print(f"[TOR] Configured SOCKS5 proxy on port {tor_port}")
        
        # Set initial cookies if provided
        if cookies:
            for name, value in cookies.items():
                self.session.cookies.set(name, value, domain='.mql5.com')
        
        # Create output directory
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        # Load progress
        self.progress_file = self.output_dir / ".scrape_progress.json"
        self._load_progress()
    
    def _load_progress(self):
        """Load previous scraping progress"""
        if self.progress_file.exists():
            with open(self.progress_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                self.visited = set(data.get('visited', []))
                self.failed = data.get('failed', [])
            print(f"[RESUME] {len(self.visited)} pages already scraped")
    
    def _save_progress(self):
        """Save scraping progress"""
        with open(self.progress_file, 'w', encoding='utf-8') as f:
            json.dump({
                'visited': list(self.visited),
                'failed': self.failed,
                'last_request_count': self.request_count
            }, f, indent=2)
    
    def _random_delay(self):
        """Random delay between requests"""
        delay = random.uniform(self.min_delay, self.max_delay)
        # Add extra delay every 15 requests to let Tor breathe
        if self.request_count % 15 == 0 and self.request_count > 0:
            delay += random.uniform(10, 20)
            print(f"\n[PAUSE] Extended delay ({delay:.1f}s) after {self.request_count} requests - letting Tor rest")
        time.sleep(delay)
    
    def test_tor_connection(self) -> bool:
        """Test if Tor connection is working"""
        print("\n[TEST] Testing Tor connection...")
        
        try:
            # Get IP without Tor
            normal_ip = requests.get('https://api.ipify.org', timeout=10).text
            print(f"[TEST] Normal IP: {normal_ip}")
        except:
            normal_ip = "unknown"
        
        try:
            # Get IP through Tor
            tor_ip = self.session.get('https://api.ipify.org', timeout=30).text
            print(f"[TEST] Tor IP: {tor_ip}")
            
            if tor_ip != normal_ip:
                print("[TEST] SUCCESS! Tor is working - IPs are different")
                
                # Test MQL5 access
                print("[TEST] Testing MQL5 access...")
                response = self.session.get(
                    f"{BASE_URL}/en/docs",
                    headers=get_browser_headers(),
                    timeout=30
                )
                print(f"[TEST] MQL5 Status: {response.status_code}")
                return response.status_code == 200
            else:
                print("[TEST] WARNING: IPs are the same - Tor may not be working")
                return False
                
        except Exception as e:
            print(f"[TEST] FAILED: {e}")
            return False
    
    def _reset_session(self):
        """Reset the session and reconnect to Tor"""
        print("\n[RECONNECT] Resetting Tor session...")
        self.session = requests.Session()
        if self.use_tor:
            self.session.proxies = {
                'http': f'socks5h://127.0.0.1:{self.tor_port}',
                'https': f'socks5h://127.0.0.1:{self.tor_port}'
            }
        time.sleep(5)  # Give Tor time to establish new circuit
    
    def _get_page(self, url: str, retry: int = 5) -> Optional[BeautifulSoup]:
        """Fetch and parse a page with retry logic"""
        if url in self.visited:
            return None
        
        for attempt in range(retry):
            try:
                self._random_delay()
                
                headers = get_browser_headers(referer=self.last_url)
                response = self.session.get(url, headers=headers, timeout=45)
                
                self.request_count += 1
                
                if response.status_code == 200:
                    self.visited.add(url)
                    self.last_url = url
                    self.consecutive_errors = 0
                    return BeautifulSoup(response.text, 'html.parser')
                
                elif response.status_code == 403:
                    self.consecutive_errors += 1
                    print(f"\n[403] Forbidden at {url} (attempt {attempt + 1}/{retry})")
                    
                    if self.consecutive_errors >= 3:
                        print("[BLOCK] Multiple 403s - resetting session and waiting 90s...")
                        self._reset_session()
                        time.sleep(90)
                        self.consecutive_errors = 0
                    else:
                        time.sleep(15)
                    
                elif response.status_code == 429:
                    print(f"\n[429] Rate limited - waiting 120s...")
                    time.sleep(120)
                
                else:
                    print(f"\n[{response.status_code}] Unexpected status for {url}")
                    time.sleep(10)
            
            except requests.exceptions.Timeout:
                print(f"\n[TIMEOUT] {url} (attempt {attempt + 1}/{retry})")
                time.sleep(15)
                
            except requests.exceptions.ConnectionError as e:
                error_str = str(e)
                # SOCKS connection errors - Tor circuit likely expired
                if 'SOCKS' in error_str or 'SOCKSHTTPSConnectionPool' in error_str:
                    print(f"\n[SOCKS ERROR] Tor connection lost (attempt {attempt + 1}/{retry})")
                    print("[SOCKS ERROR] Resetting session and waiting 60s for new circuit...")
                    self._reset_session()
                    time.sleep(60)
                else:
                    print(f"\n[CONN ERROR] {url}: {e}")
                    time.sleep(20)
                    
            except Exception as e:
                error_str = str(e)
                if 'SOCKS' in error_str:
                    print(f"\n[SOCKS ERROR] {url} (attempt {attempt + 1}/{retry})")
                    self._reset_session()
                    time.sleep(60)
                else:
                    print(f"\n[ERROR] {url}: {e}")
                    time.sleep(10)
        
        self.failed.append({'url': url, 'error': 'Max retries exceeded'})
        return None
    
    def _extract_content(self, soup: BeautifulSoup, url: str) -> dict:
        """Extract main content from page"""
        if soup is None:
            raise ValueError("BeautifulSoup object is None")
        
        content_selectors = [
            'main',  # Try main first for modern sites
            'div.doc-content',
            'div.post__body',
            'article.article-content',
            'div.topic-text',
            'div#content',
            'div.content',
            'div.body',
            'article',
            'body'  # Fallback to body
        ]
        
        content = None
        for selector in content_selectors:
            elem = soup.select_one(selector)
            if elem:
                text = elem.get_text(strip=True)
                if len(text) > 100:
                    content = elem
                    break
        
        if not content:
            raise ValueError(f"No content found in page: {url}")
        
        # Extract title
        title = soup.find('h1')
        title_text = title.get_text(strip=True) if title else urlparse(url).path.split('/')[-1]
        
        # Extract breadcrumb
        breadcrumb = soup.select_one('nav.breadcrumb, div.breadcrumb, ol.breadcrumb')
        hierarchy = []
        if breadcrumb:
            for item in breadcrumb.find_all(['a', 'span', 'li']):
                text = item.get_text(strip=True)
                if text and text not in ['>', '/', 'Home', 'MQL5 Reference']:
                    hierarchy.append(text)
        
        # Remove unwanted elements
        for elem in content.find_all(['script', 'style', 'nav', 'footer', 'aside', 'iframe', 'noscript']):
            elem.decompose()
        
        # Convert to markdown
        markdown_content = md(str(content), heading_style="ATX", code_language="mql5")
        markdown_content = re.sub(r'\n{3,}', '\n\n', markdown_content)
        markdown_content = re.sub(r' +', ' ', markdown_content)
        
        return {
            'title': title_text,
            'url': url,
            'hierarchy': hierarchy,
            'content': markdown_content
        }
    
    def _url_to_filename(self, url: str) -> str:
        """Convert URL to safe filename"""
        path = urlparse(url).path
        path = re.sub(r'^/en/(docs|book|articles|code)/?', '', path)
        filename = path.replace('/', '_').strip('_')
        filename = re.sub(r'[<>:"/\\|?*]', '_', filename)
        return filename[:100] or 'index'
    
    def _save_page(self, data: dict):
        """Save page content as markdown"""
        filename = self._url_to_filename(data['url'])
        filepath = self.output_dir / f"{filename}.md"
        
        frontmatter = f"""---
title: "{data['title']}"
url: "{data['url']}"
hierarchy: {json.dumps(data['hierarchy'])}
scraped_at: "{time.strftime('%Y-%m-%d %H:%M:%S')}"
---

# {data['title']}

"""
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(frontmatter + data['content'])
        
        return filepath
    
    def _find_links(self, soup: BeautifulSoup, base_url: str, pattern: str) -> List[str]:
        """Find all relevant links on a page"""
        links = []
        for a in soup.find_all('a', href=True):
            href = a['href']
            full_url = urljoin(base_url, href)
            
            if pattern in full_url and full_url.startswith(BASE_URL):
                if '#' not in href and 'javascript:' not in href:
                    links.append(full_url)
        
        return list(set(links))
    
    def scrape_reference(self, max_pages: int = 500):
        """Scrape MQL5 Reference documentation"""
        print(f"\n{'='*60}")
        print("SCRAPING MQL5 REFERENCE")
        print(f"{'='*60}")
        print(f"Output: {self.output_dir}")
        print(f"Max pages: {max_pages}")
        print(f"Delay: {self.min_delay}-{self.max_delay}s (random)")
        print(f"Tor: {'ENABLED' if self.use_tor else 'DISABLED'}")
        print()
        
        to_visit = [DOCS_URL]
        pages_scraped = 0
        
        with tqdm(total=max_pages, desc="Reference") as pbar:
            while to_visit and pages_scraped < max_pages:
                url = to_visit.pop(0)
                
                if url in self.visited:
                    continue
                
                soup = self._get_page(url)
                if soup is None:
                    continue
                
                try:
                    data = self._extract_content(soup, url)
                    if data['content'].strip():
                        self._save_page(data)
                        pages_scraped += 1
                        pbar.update(1)
                        pbar.set_postfix({
                            'page': data['title'][:25],
                            'reqs': self.request_count
                        })
                    
                    # Find more links
                    new_links = self._find_links(soup, url, '/en/docs/')
                    random.shuffle(new_links)
                    for link in new_links:
                        if link not in self.visited and link not in to_visit:
                            to_visit.append(link)
                            
                except Exception as e:
                    self.failed.append({'url': url, 'error': str(e)})
                    print(f"\n[ERROR] {url}: {e}")
                
                if pages_scraped % 25 == 0:
                    self._save_progress()
        
        self._save_progress()
        self._print_summary("Reference", pages_scraped)
    
    def _scrape_url(self, url: str, link_pattern: str) -> tuple:
        """Scrape a single URL (thread-safe). Returns (success, new_links)"""
        with self.lock:
            if url in self.visited:
                return (False, [])
        
        soup = self._get_page(url)
        if soup is None:
            return (False, [])
        
        try:
            data = self._extract_content(soup, url)
            if data['content'].strip():
                self._save_page(data)
                new_links = self._find_links(soup, url, link_pattern)
                return (True, new_links, data['title'][:25])
            return (False, [])
        except Exception as e:
            with self.lock:
                self.failed.append({'url': url, 'error': str(e)})
            return (False, [])
    
    def scrape_book(self, max_pages: int = 300, workers: int = 1):
        """Scrape MQL5 Programming for Traders book"""
        print(f"\n{'='*60}")
        print("SCRAPING MQL5 BOOK")
        print(f"{'='*60}")
        print(f"Workers: {workers} | Max pages: {max_pages}")
        
        to_visit = [BOOK_URL]
        pages_scraped = 0
        
        if workers == 1:
            # Sequential mode (original)
            with tqdm(total=max_pages, desc="Book") as pbar:
                while to_visit and pages_scraped < max_pages:
                    url = to_visit.pop(0)
                    
                    if url in self.visited:
                        continue
                    
                    soup = self._get_page(url)
                    if soup is None:
                        continue
                    
                    try:
                        data = self._extract_content(soup, url)
                        if data['content'].strip():
                            self._save_page(data)
                            pages_scraped += 1
                            pbar.update(1)
                            pbar.set_postfix({
                                'page': data['title'][:25],
                                'reqs': self.request_count
                            })
                        
                        new_links = self._find_links(soup, url, '/en/book/')
                        random.shuffle(new_links)
                        for link in new_links:
                            if link not in self.visited and link not in to_visit:
                                to_visit.append(link)
                                
                    except Exception as e:
                        self.failed.append({'url': url, 'error': str(e)})
                        print(f"\n[ERROR] {url}: {e}")
                    
                    if pages_scraped % 25 == 0:
                        self._save_progress()
        else:
            # Parallel mode
            print(f"[PARALLEL] Using {workers} concurrent workers")
            with tqdm(total=max_pages, desc="Book") as pbar:
                while pages_scraped < max_pages:
                    # Get batch of URLs to process
                    batch = []
                    while to_visit and len(batch) < workers:
                        url = to_visit.pop(0)
                        if url not in self.visited:
                            batch.append(url)
                    
                    if not batch:
                        break
                    
                    # Process batch in parallel
                    with ThreadPoolExecutor(max_workers=workers) as executor:
                        futures = {executor.submit(self._scrape_url, url, '/en/book/'): url for url in batch}
                        
                        for future in as_completed(futures):
                            result = future.result()
                            if result[0]:  # Success
                                pages_scraped += 1
                                pbar.update(1)
                                if len(result) > 2:
                                    pbar.set_postfix({'page': result[2], 'reqs': self.request_count})
                                
                                # Add new links
                                for link in result[1]:
                                    with self.lock:
                                        if link not in self.visited and link not in to_visit:
                                            to_visit.append(link)
                    
                    if pages_scraped % 25 == 0:
                        self._save_progress()
        
        self._save_progress()
        self._print_summary("Book", pages_scraped)
    
    def scrape_codebase(self, section: str, max_pages: int = 100):
        """Scrape MQL5 Code Base section"""
        print(f"\n{'='*60}")
        print(f"SCRAPING CODE BASE: {section.upper()}")
        print(f"{'='*60}")
        
        base_url = f"{CODEBASE_URL}/mt5/{section}"
        pages_scraped = 0
        page_num = 1
        
        with tqdm(total=max_pages, desc=section.capitalize()) as pbar:
            while pages_scraped < max_pages:
                # Get listing page
                if page_num == 1:
                    url = base_url
                else:
                    url = f"{base_url}/page{page_num}"
                
                soup = self._get_page(url)
                if soup is None:
                    if self.consecutive_errors >= 3:
                        print(f"\n[STOP] Too many errors on {section}")
                        break
                    page_num += 1
                    continue
                
                # Find code links
                code_links = []
                try:
                    for a in soup.find_all('a', href=True):
                        href = a['href']
                        if '/en/code/' in href and re.match(r'/en/code/\d+', href):
                            full_url = urljoin(BASE_URL, href)
                            if full_url not in self.visited:
                                code_links.append(full_url)
                except Exception as e:
                    print(f"\n[ERROR] Finding links on {url}: {e}")
                    page_num += 1
                    continue
                
                if not code_links:
                    print(f"\n[END] No more code links on page {page_num}")
                    break
                
                random.shuffle(code_links)
                
                for code_url in code_links[:max_pages - pages_scraped]:
                    code_soup = self._get_page(code_url)
                    if code_soup is None:
                        continue
                    
                    try:
                        data = self._extract_content(code_soup, code_url)
                        data['hierarchy'].insert(0, f"CodeBase/{section}")
                        if data['content'].strip():
                            self._save_page(data)
                            pages_scraped += 1
                            pbar.update(1)
                            pbar.set_postfix({
                                'page': data['title'][:20],
                                'reqs': self.request_count
                            })
                    except Exception as e:
                        self.failed.append({'url': code_url, 'error': str(e)})
                
                page_num += 1
                
                if pages_scraped % 20 == 0:
                    self._save_progress()
        
        self._save_progress()
        self._print_summary(f"CodeBase/{section}", pages_scraped)
    
    def scrape_articles(self, max_pages: int = 100, categories: List[str] = None):
        """Scrape MQL5 articles by category"""
        print(f"\n{'='*60}")
        print("SCRAPING MQL5 ARTICLES")
        print(f"{'='*60}")
        
        if categories is None:
            categories = [
                'expert-advisors',
                'indicators',
                'neural-networks', 
                'machine-learning',
                'trading-systems',
                'risk-management',
                'statistics-and-analysis'
            ]
        
        pages_scraped = 0
        
        for category in categories:
            category_url = f"{ARTICLES_URL}/{category}"
            soup = self._get_page(category_url)
            if not soup:
                continue
            
            article_links = self._find_links(soup, category_url, '/en/articles/')
            random.shuffle(article_links)
            
            print(f"\n[CATEGORY] {category}: {len(article_links)} articles found")
            
            for url in tqdm(article_links[:max_pages // len(categories)], desc=category[:15]):
                if url in self.visited:
                    continue
                
                soup = self._get_page(url)
                if not soup:
                    continue
                
                try:
                    data = self._extract_content(soup, url)
                    data['hierarchy'].insert(0, f"Articles/{category}")
                    if data['content'].strip():
                        self._save_page(data)
                        pages_scraped += 1
                except Exception as e:
                    self.failed.append({'url': url, 'error': str(e)})
        
        self._save_progress()
        self._print_summary("Articles", pages_scraped)
    
    def _print_summary(self, section: str, pages_scraped: int):
        """Print scraping summary"""
        print(f"\n{'='*60}")
        print(f"{section} COMPLETE")
        print(f"{'='*60}")
        print(f"Pages scraped: {pages_scraped}")
        print(f"Total requests: {self.request_count}")
        print(f"Total visited: {len(self.visited)}")
        print(f"Failed: {len(self.failed)}")
        print(f"Output: {self.output_dir}")
        
        if self.failed:
            failed_file = self.output_dir / "failed_urls.json"
            with open(failed_file, 'w', encoding='utf-8') as f:
                json.dump(self.failed[-50:], f, indent=2)  # Last 50 failures
            print(f"Failed URLs: {failed_file}")


# ============================================================================
# MAIN
# ============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="MQL5 Scraper with Tor Proxy",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Test Tor connection first
  python scrape_mql5_tor.py --test-tor --tor-port 9150
  
  # Scrape reference docs with Tor Browser
  python scrape_mql5_tor.py -o ./DOCS/SCRAPED --reference --tor-port 9150
  
  # Scrape everything with Tor service
  python scrape_mql5_tor.py -o ./DOCS/SCRAPED --all --tor-port 9050
  
  # Without Tor (not recommended)
  python scrape_mql5_tor.py -o ./DOCS/SCRAPED --reference --no-tor
        """
    )
    
    parser.add_argument('--output', '-o', type=str, default='./DOCS/SCRAPED',
                        help="Output directory")
    parser.add_argument('--tor-port', type=int, default=9150,
                        help="Tor SOCKS5 port (9150=Browser, 9050=Service)")
    parser.add_argument('--no-tor', action='store_true',
                        help="Disable Tor proxy (not recommended)")
    parser.add_argument('--test-tor', action='store_true',
                        help="Test Tor connection and exit")
    parser.add_argument('--min-delay', type=float, default=3.0,
                        help="Minimum delay between requests (seconds)")
    parser.add_argument('--max-delay', type=float, default=7.0,
                        help="Maximum delay between requests (seconds)")
    
    # Scraping targets
    parser.add_argument('--reference', action='store_true',
                        help="Scrape MQL5 Reference")
    parser.add_argument('--book', action='store_true',
                        help="Scrape MQL5 Book")
    parser.add_argument('--articles', action='store_true',
                        help="Scrape MQL5 Articles")
    parser.add_argument('--codebase', action='store_true',
                        help="Scrape Code Base (experts, indicators, etc)")
    parser.add_argument('--all', action='store_true',
                        help="Scrape everything")
    
    parser.add_argument('--max-pages', type=int, default=300,
                        help="Max pages per section")
    parser.add_argument('--workers', '-w', type=int, default=1,
                        help="Number of parallel workers (1-5, default=1 for sequential)")
    
    args = parser.parse_args()
    
    # Validate workers
    args.workers = max(1, min(5, args.workers))  # Clamp to 1-5
    
    # Test Tor
    if args.test_tor:
        scraper = TorMQL5Scraper(
            Path(args.output),
            tor_port=args.tor_port,
            use_tor=not args.no_tor
        )
        success = scraper.test_tor_connection()
        return 0 if success else 1
    
    # Default to reference if nothing specified
    if args.all:
        args.reference = args.book = args.articles = args.codebase = True
    
    if not any([args.reference, args.book, args.articles, args.codebase]):
        args.reference = True
    
    output_dir = Path(args.output)
    
    print("""
================================================================
         MQL5 DOCUMENTATION SCRAPER - TOR EDITION
================================================================
  Anti-blocking features:
  [x] Tor SOCKS5 proxy (anonymous IP)
  [x] User-Agent rotation (10+ browsers)
  [x] Random delays (2-5s + extended pauses)
  [x] Full browser headers
  [x] Session cookies
  [x] Automatic retry on errors
================================================================
    """)
    
    if args.reference:
        scraper = TorMQL5Scraper(
            output_dir / "reference",
            tor_port=args.tor_port,
            min_delay=args.min_delay,
            max_delay=args.max_delay,
            use_tor=not args.no_tor
        )
        if scraper.use_tor and not scraper.test_tor_connection():
            print("\n[ERROR] Tor not working. Start Tor Browser or service first!")
            print("        Or use --no-tor (not recommended)")
            return 1
        scraper.scrape_reference(max_pages=args.max_pages)
    
    if args.book:
        scraper = TorMQL5Scraper(
            output_dir / "book",
            tor_port=args.tor_port,
            min_delay=args.min_delay,
            max_delay=args.max_delay,
            use_tor=not args.no_tor
        )
        scraper.scrape_book(max_pages=args.max_pages, workers=args.workers)
    
    if args.articles:
        scraper = TorMQL5Scraper(
            output_dir / "articles",
            tor_port=args.tor_port,
            min_delay=args.min_delay,
            max_delay=args.max_delay,
            use_tor=not args.no_tor
        )
        scraper.scrape_articles(max_pages=args.max_pages)
    
    if args.codebase:
        for section in ['experts', 'indicators', 'scripts', 'libraries']:
            scraper = TorMQL5Scraper(
                output_dir / f"codebase_{section}",
                tor_port=args.tor_port,
                min_delay=args.min_delay,
                max_delay=args.max_delay,
                use_tor=not args.no_tor
            )
            scraper.scrape_codebase(section, max_pages=args.max_pages // 4)
    
    print("""
================================================================
                    SCRAPING COMPLETE!
================================================================
  Next steps:
  1. Review scraped files in DOCS/SCRAPED/
  2. Ingest into RAG system
================================================================
    """)
    
    return 0


if __name__ == "__main__":
    exit(main())
