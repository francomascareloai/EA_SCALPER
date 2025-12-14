# MQL5 RAG Search Skill

## Description
Skill for semantic search in the local knowledge base of EA_SCALPER_XAUUSD project. Uses two separate RAG databases for precise queries.

## Trigger Phrases
- "search documentation"
- "search in books"
- "query RAG"
- "search MQL5"
- "how to do X in MQL5"
- "syntax of X"
- "example of X"

## RAG Databases

### Base 1: BOOKS (Conceptual Knowledge)
- **Path**: `.rag-db/books`
- **Content**: 5,909 chunks from 15 PDFs
- **Use for**:
  - Trading concepts (SMC, Price Action, Volume Profile)
  - Machine Learning for trading (LSTM, ONNX, features)
  - Statistics (Hurst, Entropy, Kalman)
  - Strategies and methodologies
  - MQL5 fundamentals

### Base 2: DOCS (MQL5 Technical Reference)
- **Path**: `.rag-db/docs`
- **Content**: 18,635 chunks from 7,629 pages
- **Use for**:
  - MQL5 function syntax
  - Function parameters and returns
  - Code examples
  - ONNX documentation in MQL5
  - Native classes and structures

## How to Use

### Python Code for Query

```python
import lancedb
from sentence_transformers import SentenceTransformer

# Load embedding model
model = SentenceTransformer('all-MiniLM-L6-v2')

def search_rag(query: str, database: str = "books", limit: int = 5) -> list[dict]:
    """
    Semantic search in RAG.
    
    Args:
        query: Question or search term
        database: "books" (concepts) or "docs" (MQL5 syntax)
        limit: Number of results
    
    Returns:
        List of relevant chunks with source and text
    """
    db_path = f".rag-db/{database}"
    db = lancedb.connect(db_path)
    tbl = db.open_table("documents")
    
    # Create query embedding
    query_embedding = model.encode(query)
    
    # Search
    results = tbl.search(query_embedding).limit(limit).to_pandas()
    
    return [
        {
            "source": row["source"],
            "text": row["text"],
            "score": row["_distance"]
        }
        for _, row in results.iterrows()
    ]


def search_both(query: str, limit_each: int = 3) -> dict:
    """
    Search both databases and combine results.
    """
    return {
        "books": search_rag(query, "books", limit_each),
        "docs": search_rag(query, "docs", limit_each)
    }
```

### Usage Examples

#### Search Concept (use BOOKS)
```python
# When: "How does regime detection work?"
results = search_rag("Hurst exponent regime detection trading", "books", 5)
```

#### Search Syntax (use DOCS)
```python
# When: "What is the OnnxRun syntax?"
results = search_rag("OnnxRun function parameters usage", "docs", 5)
```

#### Search Both
```python
# When: "How to implement ONNX in MQL5?"
results = search_both("ONNX model inference MQL5 implementation", 3)
```

## Decision: Which Database to Use?

| Question Type | Database | Example |
|---------------|----------|---------|
| "How does X work?" | BOOKS | "How does Hurst exponent work?" |
| "What is X?" | BOOKS | "What is Smart Money Concepts?" |
| "Strategy for X" | BOOKS | "Strategy for scalping gold" |
| "Syntax of X" | DOCS | "Syntax of ArrayResize" |
| "Parameters of X" | DOCS | "Parameters of OrderSend" |
| "Example of X" | DOCS | "Example of iMA usage" |
| "How to implement X?" | BOTH | "How to implement ONNX?" |
| "Code for X" | BOTH | "Code to calculate ATR" |

## Agent Integration

All code-related agents must:

1. **BEFORE writing MQL5 code**: Query DOCS for correct syntax
2. **BEFORE implementing concept**: Query BOOKS to understand theory
3. **When in doubt**: Query BOTH and combine information

### Workflow Example

```
TASK: Implement Hurst Exponent calculation in MQL5

1. [BOOKS] Search "Hurst exponent calculation algorithm"
   → Understand the formula and R/S method

2. [DOCS] Search "MQL5 array functions statistics"
   → See available functions (MathStandardDeviation, etc)

3. [DOCS] Search "MQL5 loop array iteration"
   → See correct loop syntax

4. Implement code combining knowledge from both databases
```

## Configured MCP Servers

The `.factory/mcp.json` file defines two MCP servers:

```json
{
  "mcpServers": {
    "mql5-books": {
      "env": {
        "BASE_DIR": "DOCS/BOOKS",
        "DB_PATH": ".rag-db/books"
      }
    },
    "mql5-docs": {
      "env": {
        "BASE_DIR": "DOCS/SCRAPED", 
        "DB_PATH": ".rag-db/docs"
      }
    }
  }
}
```

## Database Statistics

| Database | Chunks | Sources | Size |
|----------|--------|---------|------|
| BOOKS | 5,909 | 15 PDFs | 23 MB |
| DOCS | 18,635 | 7,629 pages | 61 MB |
| **TOTAL** | **24,544** | - | **84 MB** |

## Main Sources in BOOKS

| PDF | Chunks | Topics |
|-----|--------|--------|
| mql5.pdf | 2,195 | Official documentation |
| mql5book.pdf | 1,558 | Complete tutorial |
| neuronetworksbook.pdf | 578 | ML/ONNX for trading |
| Algorithmic Trading | 485 | Advanced statistics |
| EA Programming MT5 | 211 | EA programming |
