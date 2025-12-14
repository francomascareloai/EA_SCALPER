"""
MQL5 Documentation Scraper
==========================
Scrape oficial MQL5 documentation from mql5.com for local RAG indexing.

Usage:
    python scrape_mql5_docs.py --output ./DOCS/SCRAPED/mql5_reference
    python scrape_mql5_docs.py --articles --output ./DOCS/SCRAPED/mql5_articles
    
Requirements:
    pip install requests beautifulsoup4 markdownify tqdm
"""

import argparse
import time
import json
import re
from pathlib import Path
from urllib.parse import urljoin, urlparse
from typing import Optional
import hashlib

try:
    import requests
    from bs4 import BeautifulSoup
    from markdownify import markdownify as md
    from tqdm import tqdm
except ImportError:
    print("Installing required packages...")
    import subprocess
    subprocess.check_call(["pip", "install", "requests", "beautifulsoup4", "markdownify", "tqdm"])
    import requests
    from bs4 import BeautifulSoup
    from markdownify import markdownify as md
    from tqdm import tqdm


# Configuration
BASE_URL = "https://www.mql5.com"
DOCS_URL = f"{BASE_URL}/en/docs"
BOOK_URL = f"{BASE_URL}/en/book"
ARTICLES_URL = f"{BASE_URL}/en/articles"

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.5",
}

# Rate limiting
REQUEST_DELAY = 1.5  # seconds between requests (be nice to the server)


class MQL5Scraper:
    def __init__(self, output_dir: Path, delay: float = REQUEST_DELAY):
        self.output_dir = Path(output_dir)
        self.delay = delay
        self.session = requests.Session()
        self.session.headers.update(HEADERS)
        self.visited = set()
        self.failed = []
        
        # Create output directory
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        # Load progress if exists
        self.progress_file = self.output_dir / ".scrape_progress.json"
        self._load_progress()
    
    def _load_progress(self):
        """Load previous scraping progress"""
        if self.progress_file.exists():
            with open(self.progress_file, 'r') as f:
                data = json.load(f)
                self.visited = set(data.get('visited', []))
                self.failed = data.get('failed', [])
            print(f"Resuming from previous session: {len(self.visited)} pages already scraped")
    
    def _save_progress(self):
        """Save scraping progress"""
        with open(self.progress_file, 'w') as f:
            json.dump({
                'visited': list(self.visited),
                'failed': self.failed
            }, f)
    
    def _get_page(self, url: str) -> Optional[BeautifulSoup]:
        """Fetch and parse a page with rate limiting"""
        if url in self.visited:
            return None
        
        try:
            time.sleep(self.delay)
            response = self.session.get(url, timeout=30)
            response.raise_for_status()
            self.visited.add(url)
            return BeautifulSoup(response.text, 'html.parser')
        except Exception as e:
            print(f"Failed to fetch {url}: {e}")
            self.failed.append({'url': url, 'error': str(e)})
            return None
    
    def _extract_content(self, soup: BeautifulSoup, url: str) -> dict:
        """Extract main content from page"""
        # Try different content containers
        content_selectors = [
            'div.doc-content',
            'div.post__body',
            'article.article-content',
            'div.topic-text',
            'div#content'
        ]
        
        content = None
        for selector in content_selectors:
            content = soup.select_one(selector)
            if content:
                break
        
        if not content:
            content = soup.find('main') or soup.find('body')
        
        # Extract title
        title = soup.find('h1')
        title_text = title.get_text(strip=True) if title else urlparse(url).path.split('/')[-1]
        
        # Extract breadcrumb for hierarchy
        breadcrumb = soup.select_one('nav.breadcrumb, div.breadcrumb, ol.breadcrumb')
        hierarchy = []
        if breadcrumb:
            for item in breadcrumb.find_all(['a', 'span', 'li']):
                text = item.get_text(strip=True)
                if text and text not in ['>', '/', 'Home', 'MQL5 Reference']:
                    hierarchy.append(text)
        
        # Remove unwanted elements
        for elem in content.find_all(['script', 'style', 'nav', 'footer', 'aside', 'iframe']):
            elem.decompose()
        
        # Convert to markdown
        markdown_content = md(str(content), heading_style="ATX", code_language="mql5")
        
        # Clean up markdown
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
        # Remove leading /en/docs/ or similar
        path = re.sub(r'^/en/(docs|book|articles)/?', '', path)
        # Replace slashes with underscores
        filename = path.replace('/', '_').strip('_')
        # Ensure valid filename
        filename = re.sub(r'[<>:"/\\|?*]', '_', filename)
        return filename or 'index'
    
    def _save_page(self, data: dict):
        """Save page content as markdown"""
        filename = self._url_to_filename(data['url'])
        filepath = self.output_dir / f"{filename}.md"
        
        # Create frontmatter
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
    
    def _find_doc_links(self, soup: BeautifulSoup, base_url: str, pattern: str) -> list:
        """Find all documentation links on a page"""
        links = []
        for a in soup.find_all('a', href=True):
            href = a['href']
            full_url = urljoin(base_url, href)
            
            # Filter for documentation pages only
            if pattern in full_url and full_url.startswith(BASE_URL):
                # Skip anchors and external links
                if '#' not in href and 'javascript:' not in href:
                    links.append(full_url)
        
        return list(set(links))
    
    def scrape_reference(self, max_pages: int = 1000):
        """Scrape MQL5 Reference documentation"""
        print(f"\n=== Scraping MQL5 Reference ===")
        print(f"Output: {self.output_dir}")
        print(f"Max pages: {max_pages}")
        print(f"Delay: {self.delay}s between requests")
        print()
        
        # Start from main docs page
        to_visit = [DOCS_URL]
        pages_scraped = 0
        
        with tqdm(total=max_pages, desc="Scraping") as pbar:
            while to_visit and pages_scraped < max_pages:
                url = to_visit.pop(0)
                
                if url in self.visited:
                    continue
                
                soup = self._get_page(url)
                if not soup:
                    continue
                
                # Extract and save content
                try:
                    data = self._extract_content(soup, url)
                    if data['content'].strip():
                        filepath = self._save_page(data)
                        pages_scraped += 1
                        pbar.update(1)
                        pbar.set_postfix({'last': data['title'][:30]})
                except Exception as e:
                    print(f"\nError processing {url}: {e}")
                    self.failed.append({'url': url, 'error': str(e)})
                
                # Find more links
                new_links = self._find_doc_links(soup, url, '/en/docs/')
                for link in new_links:
                    if link not in self.visited and link not in to_visit:
                        to_visit.append(link)
                
                # Save progress periodically
                if pages_scraped % 50 == 0:
                    self._save_progress()
        
        self._save_progress()
        self._print_summary(pages_scraped)
    
    def scrape_book(self, max_pages: int = 500):
        """Scrape MQL5 Programming for Traders book"""
        print(f"\n=== Scraping MQL5 Book ===")
        print(f"Output: {self.output_dir}")
        
        to_visit = [BOOK_URL]
        pages_scraped = 0
        
        with tqdm(total=max_pages, desc="Scraping Book") as pbar:
            while to_visit and pages_scraped < max_pages:
                url = to_visit.pop(0)
                
                if url in self.visited:
                    continue
                
                soup = self._get_page(url)
                if not soup:
                    continue
                
                try:
                    data = self._extract_content(soup, url)
                    if data['content'].strip():
                        filepath = self._save_page(data)
                        pages_scraped += 1
                        pbar.update(1)
                except Exception as e:
                    self.failed.append({'url': url, 'error': str(e)})
                
                # Find more links within book
                new_links = self._find_doc_links(soup, url, '/en/book/')
                for link in new_links:
                    if link not in self.visited and link not in to_visit:
                        to_visit.append(link)
                
                if pages_scraped % 50 == 0:
                    self._save_progress()
        
        self._save_progress()
        self._print_summary(pages_scraped)
    
    def scrape_articles(self, max_pages: int = 100, categories: list = None):
        """Scrape selected MQL5 articles"""
        print(f"\n=== Scraping MQL5 Articles ===")
        
        # Focus on relevant categories
        if categories is None:
            categories = [
                'expert-advisors',
                'indicators',
                'neural-networks',
                'machine-learning',
                'trading-systems',
                'risk-management'
            ]
        
        pages_scraped = 0
        
        for category in categories:
            category_url = f"{ARTICLES_URL}/{category}"
            soup = self._get_page(category_url)
            if not soup:
                continue
            
            # Find article links
            article_links = self._find_doc_links(soup, category_url, '/en/articles/')
            
            print(f"\nCategory: {category} - Found {len(article_links)} articles")
            
            for url in tqdm(article_links[:max_pages // len(categories)], desc=category):
                if url in self.visited:
                    continue
                
                soup = self._get_page(url)
                if not soup:
                    continue
                
                try:
                    data = self._extract_content(soup, url)
                    data['hierarchy'].insert(0, category)  # Add category to hierarchy
                    if data['content'].strip():
                        self._save_page(data)
                        pages_scraped += 1
                except Exception as e:
                    self.failed.append({'url': url, 'error': str(e)})
        
        self._save_progress()
        self._print_summary(pages_scraped)
    
    def _print_summary(self, pages_scraped: int):
        """Print scraping summary"""
        print(f"\n=== Scraping Complete ===")
        print(f"Pages scraped: {pages_scraped}")
        print(f"Total visited: {len(self.visited)}")
        print(f"Failed: {len(self.failed)}")
        print(f"Output directory: {self.output_dir}")
        
        if self.failed:
            failed_file = self.output_dir / "failed_urls.json"
            with open(failed_file, 'w') as f:
                json.dump(self.failed, f, indent=2)
            print(f"Failed URLs saved to: {failed_file}")


    def scrape_codebase(self, section: str, max_pages: int = 100):
        """Scrape MQL5 Code Base (experts, indicators, scripts, libraries)"""
        print(f"\n=== Scraping MQL5 Code Base: {section} ===")
        
        base_url = f"{BASE_URL}/en/code/mt5/{section}"
        pages_scraped = 0
        page_num = 1
        
        with tqdm(total=max_pages, desc=f"Scraping {section}") as pbar:
            while pages_scraped < max_pages:
                # Get listing page
                if page_num == 1:
                    url = base_url
                else:
                    url = f"{base_url}/page{page_num}"
                
                soup = self._get_page(url)
                if not soup:
                    break
                
                # Find code links on this page
                code_links = []
                for a in soup.find_all('a', href=True):
                    href = a['href']
                    # Match code pages like /en/code/12345
                    if '/en/code/' in href and href.count('/') == 4:
                        full_url = urljoin(BASE_URL, href)
                        if full_url not in self.visited:
                            code_links.append(full_url)
                
                if not code_links:
                    break
                
                # Scrape each code page
                for code_url in code_links[:max_pages - pages_scraped]:
                    soup = self._get_page(code_url)
                    if not soup:
                        continue
                    
                    try:
                        data = self._extract_content(soup, code_url)
                        data['hierarchy'].insert(0, section)
                        if data['content'].strip():
                            self._save_page(data)
                            pages_scraped += 1
                            pbar.update(1)
                            pbar.set_postfix({'last': data['title'][:25]})
                    except Exception as e:
                        self.failed.append({'url': code_url, 'error': str(e)})
                
                page_num += 1
                
                if pages_scraped % 20 == 0:
                    self._save_progress()
        
        self._save_progress()
        self._print_summary(pages_scraped)


def main():
    parser = argparse.ArgumentParser(description="Scrape MQL5 documentation")
    parser.add_argument('--output', '-o', type=str, required=True,
                        help="Output directory for scraped files")
    parser.add_argument('--reference', action='store_true',
                        help="Scrape MQL5 Reference documentation")
    parser.add_argument('--book', action='store_true',
                        help="Scrape MQL5 Programming book")
    parser.add_argument('--articles', action='store_true',
                        help="Scrape MQL5 articles")
    parser.add_argument('--codebase', action='store_true',
                        help="Scrape MQL5 Code Base (experts, indicators, scripts, libraries)")
    parser.add_argument('--all', action='store_true',
                        help="Scrape everything")
    parser.add_argument('--max-pages', type=int, default=500,
                        help="Maximum pages to scrape per section")
    parser.add_argument('--delay', type=float, default=1.5,
                        help="Delay between requests in seconds")
    
    args = parser.parse_args()
    
    output_dir = Path(args.output)
    
    if args.all:
        args.reference = args.book = args.articles = args.codebase = True
    
    if not any([args.reference, args.book, args.articles, args.codebase]):
        args.reference = True  # Default to reference docs
    
    if args.reference:
        scraper = MQL5Scraper(output_dir / "reference", delay=args.delay)
        scraper.scrape_reference(max_pages=args.max_pages)
    
    if args.book:
        scraper = MQL5Scraper(output_dir / "book", delay=args.delay)
        scraper.scrape_book(max_pages=args.max_pages)
    
    if args.articles:
        scraper = MQL5Scraper(output_dir / "articles", delay=args.delay)
        scraper.scrape_articles(max_pages=args.max_pages)
    
    if args.codebase:
        for section in ['experts', 'indicators', 'scripts', 'libraries']:
            scraper = MQL5Scraper(output_dir / f"codebase_{section}", delay=args.delay)
            scraper.scrape_codebase(section, max_pages=args.max_pages // 4)
    
    print("\n=== All Done! ===")
    print(f"Scraped documentation saved to: {output_dir}")
    print("\nNext steps:")
    print("1. Review scraped files")
    print("2. Ingest into RAG: 'Ingest all files from ./DOCS/SCRAPED'")


if __name__ == "__main__":
    main()
