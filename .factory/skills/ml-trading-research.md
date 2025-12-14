---
name: ml-trading-research
description: |
  Specialized skill for researching Machine Learning applications in algorithmic trading.
  Use this skill when you need to:
  - Research ML models for price prediction (LSTM, Transformer, xLSTM)
  - Find ONNX integration patterns for MQL5
  - Discover feature engineering techniques for trading
  - Evaluate ML papers and backtesting results
  - Research regime detection methods (Hurst, Entropy, HMM)
  - Find production-ready ML trading implementations
  
  Triggers: "ML trading research", "ONNX MQL5", "LSTM gold prediction", 
  "feature engineering trading", "regime detection", "machine learning forex"
---

# ML Trading Research Skill

## Purpose

This skill provides a structured approach to researching Machine Learning applications in algorithmic trading, with focus on:
- Deep Learning for financial time series
- ONNX integration with MQL5/MetaTrader 5
- Feature engineering for trading models
- Statistical regime detection
- Production deployment patterns

---

## Research Protocol

### Phase 1: Query Decomposition

Before searching, decompose the ML trading query into sub-questions:

1. **Theoretical Foundation**: What does academic research say?
2. **Implementation Examples**: What code/repos exist?
3. **Performance Evidence**: What backtests/live results exist?
4. **Production Considerations**: What are deployment challenges?

### Phase 2: Multi-Source Search Strategy

Execute searches across these source categories:

#### Academic Sources
```
Search patterns:
- "arXiv q-fin [topic]" - Quantitative finance papers
- "SSRN [topic] trading" - Financial economics papers
- "machine learning financial time series" - General ML finance
- "[model] gold price prediction" - Specific asset
```

Use: `perplexity-search` or `brave-search` with academic focus

#### Code Repositories
```
Search patterns:
- "GitHub [model] trading Python"
- "GitHub ONNX MQL5"
- "GitHub LSTM forex"
- "QuantConnect [strategy]"
```

Use: `github___search_repositories` or `github___search_code`

#### Technical Documentation
```
Search patterns:
- Context7 for library docs (PyTorch, TensorFlow, ONNX)
- MQL5.com documentation for ONNX functions
- Specific library documentation
```

Use: `context7___get-library-docs`

#### Industry/Practitioner Sources
```
Search patterns:
- "MQL5 community ONNX"
- "QuantConnect forum [topic]"
- "[broker] API machine learning"
```

Use: `brave-search` or `WebSearch`

### Phase 3: Evaluation Framework

For each finding, evaluate:

| Criterion | Questions |
|-----------|-----------|
| **Validity** | Is the methodology sound? Sample size? OOS testing? |
| **Reproducibility** | Can we implement this? Code available? |
| **Applicability** | Does it work for XAUUSD? Scalping timeframes? |
| **Production-Ready** | Latency acceptable? ONNX exportable? |

### Phase 4: Synthesis

Compile findings into actionable format:

```markdown
## ML Research Report: [TOPIC]

### Key Finding
[Main conclusion with confidence level]

### Implementation Recommendation
[Specific steps to implement]

### Code References
[Links to repos, papers, docs]

### Risks/Limitations
[What could go wrong]

### Next Steps
[Concrete actions]
```

---

## Search Templates by Topic

### LSTM/xLSTM for Price Prediction
```
Searches to execute:
1. perplexity: "LSTM gold XAUUSD price prediction accuracy 2024 2025"
2. github: "LSTM forex prediction Python"
3. context7: PyTorch LSTM documentation
4. brave: "xLSTM trading implementation"
```

### ONNX + MQL5 Integration
```
Searches to execute:
1. brave: "MQL5 ONNX tutorial 2024"
2. perplexity: "MetaTrader 5 ONNX best practices production"
3. github: "ONNX MQL5 EA"
4. context7: ONNX Runtime documentation
```

### Regime Detection (Hurst/Entropy)
```
Searches to execute:
1. perplexity: "Hurst exponent trading regime detection Python"
2. github: "hurst exponent trading"
3. brave: "Shannon entropy algorithmic trading"
4. perplexity: "Hidden Markov Model market regime"
```

### Feature Engineering for Trading
```
Searches to execute:
1. perplexity: "feature engineering financial time series ML"
2. github: "trading features machine learning"
3. brave: "technical indicators machine learning input"
4. perplexity: "normalization financial data neural network"
```

### Transformer Models for Trading
```
Searches to execute:
1. perplexity: "Transformer model stock prediction 2024"
2. github: "attention mechanism trading"
3. brave: "temporal fusion transformer trading"
4. perplexity: "Informer time series forecasting finance"
```

---

## Quality Signals

### High-Quality Sources
- Peer-reviewed papers (arXiv with citations, published journals)
- Production implementations (live trading results)
- Well-documented GitHub repos (>100 stars, active maintenance)
- Official documentation (PyTorch, TensorFlow, ONNX)

### Red Flags
- No out-of-sample testing
- Unrealistic accuracy claims (>80% for direction prediction)
- No code/reproducibility
- Cherry-picked time periods
- Single asset/timeframe only

---

## Output Format

When completing ML trading research, provide:

```markdown
# ML Trading Research: [Topic]

## Executive Summary
[2-3 sentences: main finding, confidence, applicability]

## Detailed Findings

### Academic Evidence
- [Finding 1]: [Source] - [Relevance]
- [Finding 2]: [Source] - [Relevance]

### Implementation Resources
- [Repo/Doc 1]: [Link] - [What it provides]
- [Repo/Doc 2]: [Link] - [What it provides]

### Performance Data
- [Result 1]: [Metrics] - [Conditions]
- [Result 2]: [Metrics] - [Conditions]

## Implementation Recommendation
[Specific, actionable steps]

## Code Snippet (if applicable)
```python
# Key implementation pattern
```

## Risks & Mitigations
| Risk | Mitigation |
|------|------------|
| [Risk 1] | [Mitigation] |

## Confidence Assessment
- **Finding Confidence**: [HIGH/MEDIUM/LOW] - [Why]
- **Implementation Feasibility**: [HIGH/MEDIUM/LOW] - [Why]

## Sources
[Full citation list with links]
```

---

## Integration with Project

After research, findings can feed into:
- **Singularity Architect**: ML strategy design
- **ONNX Model Builder**: Model implementation
- **PRD Updates**: Phase 4 ONNX documentation
- **Python Agent Hub**: Regime detection implementation

---

Now execute this research protocol with rigor and precision.
