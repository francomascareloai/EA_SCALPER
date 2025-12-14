"""
News Sentiment Analyzer using FinBERT
=====================================
Analyzes gold-related news for sentiment.

Uses:
- FinBERT for financial sentiment analysis
- NewsAPI for news data

Research shows FinBERT outperforms generic VADER/TextBlob
for financial text by 15-20% accuracy.
"""

import os
import logging
from datetime import datetime, timedelta
from typing import Optional, List
import requests

logger = logging.getLogger(__name__)

# Lazy load transformer model (heavy)
_finbert_model = None
_finbert_tokenizer = None

def get_finbert():
    """Lazy load FinBERT model."""
    global _finbert_model, _finbert_tokenizer
    
    if _finbert_model is None:
        logger.info("Loading FinBERT model (first time, may take a minute)...")
        try:
            from transformers import AutoTokenizer, AutoModelForSequenceClassification
            import torch
            
            model_name = "ProsusAI/finbert"
            _finbert_tokenizer = AutoTokenizer.from_pretrained(model_name)
            _finbert_model = AutoModelForSequenceClassification.from_pretrained(model_name)
            _finbert_model.eval()
            
            logger.info("FinBERT loaded successfully")
        except Exception as e:
            logger.error(f"Failed to load FinBERT: {e}")
            return None, None
    
    return _finbert_model, _finbert_tokenizer


class NewsAPIClient:
    """Client for NewsAPI.org."""
    
    def __init__(self):
        self.api_key = os.getenv('NEWSAPI_KEY')
        self.base_url = "https://newsapi.org/v2"
        
    def search_news(self, query: str = "gold price", days: int = 2, page_size: int = 10) -> List[dict]:
        """Fetch news articles from NewsAPI."""
        if not self.api_key:
            logger.warning("NEWSAPI_KEY not configured")
            return []
        
        from_date = (datetime.now() - timedelta(days=days)).strftime('%Y-%m-%d')
        
        try:
            response = requests.get(
                f"{self.base_url}/everything",
                params={
                    'q': query,
                    'from': from_date,
                    'sortBy': 'publishedAt',
                    'language': 'en',
                    'pageSize': page_size,
                    'apiKey': self.api_key
                },
                timeout=10
            )
            
            if response.status_code != 200:
                logger.error(f"NewsAPI error: {response.text}")
                return []
            
            data = response.json()
            articles = []
            
            for article in data.get('articles', []):
                articles.append({
                    'title': article.get('title', ''),
                    'description': article.get('description', ''),
                    'source': article.get('source', {}).get('name', ''),
                    'published_at': article.get('publishedAt', ''),
                    'url': article.get('url', '')
                })
            
            return articles
            
        except Exception as e:
            logger.error(f"Error fetching news: {e}")
            return []


class SentimentAnalyzer:
    """FinBERT-based sentiment analyzer."""
    
    def analyze_text(self, text: str) -> dict:
        """Analyze sentiment of a single text."""
        model, tokenizer = get_finbert()
        
        if model is None:
            return {
                'sentiment': 'neutral',
                'confidence': 0.0,
                'scores': {'positive': 0.33, 'negative': 0.33, 'neutral': 0.34}
            }
        
        try:
            import torch
            
            # Truncate text to model max length
            text = text[:512]
            
            inputs = tokenizer(text, return_tensors="pt", padding=True, truncation=True, max_length=512)
            
            with torch.no_grad():
                outputs = model(**inputs)
                probs = torch.softmax(outputs.logits, dim=1)[0]
            
            # FinBERT labels: positive, negative, neutral
            scores = {
                'positive': float(probs[0]),
                'negative': float(probs[1]),
                'neutral': float(probs[2])
            }
            
            # Get dominant sentiment
            sentiment = max(scores, key=scores.get)
            confidence = scores[sentiment]
            
            return {
                'sentiment': sentiment,
                'confidence': round(confidence, 3),
                'scores': {k: round(v, 3) for k, v in scores.items()}
            }
            
        except Exception as e:
            logger.error(f"Error analyzing sentiment: {e}")
            return {
                'sentiment': 'neutral',
                'confidence': 0.0,
                'error': str(e)
            }
    
    def analyze_multiple(self, texts: List[str]) -> dict:
        """Analyze multiple texts and aggregate."""
        if not texts:
            return {
                'overall_sentiment': 'neutral',
                'overall_score': 0,
                'confidence': 0.0,
                'count': 0
            }
        
        positive_sum = 0
        negative_sum = 0
        neutral_sum = 0
        
        results = []
        for text in texts:
            result = self.analyze_text(text)
            results.append(result)
            positive_sum += result['scores'].get('positive', 0.33)
            negative_sum += result['scores'].get('negative', 0.33)
            neutral_sum += result['scores'].get('neutral', 0.34)
        
        n = len(texts)
        avg_positive = positive_sum / n
        avg_negative = negative_sum / n
        avg_neutral = neutral_sum / n
        
        # Determine overall sentiment
        if avg_positive > avg_negative and avg_positive > avg_neutral:
            sentiment = 'positive'
            confidence = avg_positive
        elif avg_negative > avg_positive and avg_negative > avg_neutral:
            sentiment = 'negative'
            confidence = avg_negative
        else:
            sentiment = 'neutral'
            confidence = avg_neutral
        
        # Calculate score (-10 to +10)
        sentiment_score = (avg_positive - avg_negative) * 10
        
        return {
            'overall_sentiment': sentiment,
            'overall_score': round(sentiment_score, 2),
            'confidence': round(confidence, 3),
            'average_scores': {
                'positive': round(avg_positive, 3),
                'negative': round(avg_negative, 3),
                'neutral': round(avg_neutral, 3)
            },
            'count': n,
            'individual_results': results
        }


class NewsSentimentService:
    """
    Main service combining news fetching and sentiment analysis.
    
    GOLD-SPECIFIC QUERIES:
    - "gold price" - general gold news
    - "XAUUSD" - forex-specific
    - "federal reserve gold" - Fed impact
    - "inflation gold" - inflation hedge narrative
    """
    
    def __init__(self):
        self.news_client = NewsAPIClient()
        self.analyzer = SentimentAnalyzer()
        self._cache = {}
        self._cache_time = None
        self._cache_ttl = 300  # 5 minutes
        logger.info("NewsSentimentService initialized")
    
    def _is_cache_valid(self) -> bool:
        if self._cache_time is None:
            return False
        return (datetime.now() - self._cache_time).total_seconds() < self._cache_ttl
    
    def analyze_gold_sentiment(self, days: int = 2) -> dict:
        """Get gold news sentiment analysis."""
        
        cache_key = f"gold_{days}"
        if self._is_cache_valid() and cache_key in self._cache:
            return self._cache[cache_key]
        
        # Multiple queries for comprehensive coverage
        queries = [
            ("gold price", 5),
            ("gold xauusd", 3),
            ("gold federal reserve", 2)
        ]
        
        all_articles = []
        for query, count in queries:
            articles = self.news_client.search_news(query, days, count)
            all_articles.extend(articles)
        
        if not all_articles:
            return {
                'sentiment': 'neutral',
                'score': 0,
                'confidence': 0.0,
                'article_count': 0,
                'error': 'No articles found',
                'timestamp': datetime.now().isoformat()
            }
        
        # Extract text for analysis (title + description)
        texts = []
        for article in all_articles:
            text = f"{article.get('title', '')}. {article.get('description', '')}"
            if len(text.strip()) > 10:
                texts.append(text)
        
        # Analyze
        analysis = self.analyzer.analyze_multiple(texts)
        
        result = {
            'sentiment': analysis['overall_sentiment'],
            'score': analysis['overall_score'],
            'confidence': analysis['confidence'],
            'article_count': analysis['count'],
            'average_scores': analysis['average_scores'],
            'recent_headlines': [a.get('title', '')[:100] for a in all_articles[:5]],
            'timestamp': datetime.now().isoformat()
        }
        
        self._cache[cache_key] = result
        self._cache_time = datetime.now()
        
        return result
    
    def get_trading_signal(self) -> dict:
        """
        Get trading signal based on news sentiment.
        
        Returns signal compatible with EA integration.
        """
        analysis = self.analyze_gold_sentiment()
        score = analysis.get('score', 0)
        confidence = analysis.get('confidence', 0.5)
        
        # Determine signal with confidence threshold
        if confidence < 0.5:
            signal = 'NEUTRAL'
            score_adjustment = 0
        elif score > 4:
            signal = 'BULLISH'
            score_adjustment = 8
        elif score > 2:
            signal = 'SLIGHTLY_BULLISH'
            score_adjustment = 4
        elif score < -4:
            signal = 'BEARISH'
            score_adjustment = -8
        elif score < -2:
            signal = 'SLIGHTLY_BEARISH'
            score_adjustment = -4
        else:
            signal = 'NEUTRAL'
            score_adjustment = 0
        
        return {
            'signal': signal,
            'score': round(score, 2),
            'score_adjustment': score_adjustment,
            'confidence': round(confidence, 2),
            'sentiment': analysis.get('sentiment', 'neutral'),
            'article_count': analysis.get('article_count', 0),
            'timestamp': datetime.now().isoformat()
        }


# Global service instance
_sentiment_service: Optional[NewsSentimentService] = None

def get_sentiment_service() -> NewsSentimentService:
    """Get or create the sentiment service singleton."""
    global _sentiment_service
    if _sentiment_service is None:
        _sentiment_service = NewsSentimentService()
    return _sentiment_service
