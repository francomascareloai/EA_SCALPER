# References - ARGUS

## MCPs de Pesquisa

| MCP | Uso | Limite | Tier |
|-----|-----|--------|------|
| perplexity | Research geral, macro, noticias | Normal | 1 |
| exa | AI-native search, codigo, artigos | Free | 1 |
| brave-search | Web ampla, backup | Normal | 2 |
| kagi | Premium search | 100 req | 2 |
| github | Repos, code search, PRs | Normal | 1 |
| firecrawl | Scrape paginas | 820 req | 2 |
| bright-data | Scraping escala | 5k/mes | 3 |

## MCPs de Conhecimento Local

| MCP | Conteudo | Chunks |
|-----|----------|--------|
| mql5-books | SMC, Order Flow, ML, teoria | 5,909 |
| mql5-docs | Sintaxe, funcoes, exemplos | 18,635 |
| memory | Knowledge graph persistente | - |

---

## RAG Queries Templates

```bash
# SMC / ICT
mql5-books "order block" OR "fair value gap" OR "liquidity sweep"
mql5-books "SMC" OR "smart money" OR "ICT" OR "inner circle"

# Order Flow
mql5-books "footprint" OR "delta" OR "imbalance" OR "absorption"
mql5-books "volume profile" OR "POC" OR "value area"

# Machine Learning
mql5-books "ONNX" OR "neural network" OR "LSTM" OR "machine learning"
mql5-books "feature engineering" OR "regime detection"

# Backtesting
mql5-books "walk forward" OR "monte carlo" OR "overfitting"
mql5-books "sharpe ratio" OR "sortino" OR "SQN"

# Gold / Macro
mql5-books "gold" OR "XAUUSD" OR "precious metals"
mql5-books "DXY" OR "dollar index" OR "real yields"

# Sintaxe MQL5
mql5-docs "OrderSend" OR "CopyBuffer" OR "iATR"
mql5-docs "OnnxCreate" OR "OnnxRun"
```

---

## Fontes Externas por Area

### Papers Academicos
| Fonte | Area | Como Acessar |
|-------|------|--------------|
| arXiv q-fin | Quant Finance | perplexity/exa |
| arXiv stat.ML | ML/Stats | perplexity/exa |
| SSRN | Finance research | perplexity |
| Google Scholar | Geral | perplexity |

### Codigo / Implementacoes
| Fonte | Tipo | Como Acessar |
|-------|------|--------------|
| GitHub | Repos publicos | github MCP |
| Kaggle | Notebooks, datasets | perplexity/exa |
| Papers with Code | Paper + codigo | perplexity |

### Comunidades / Forums
| Fonte | Foco | Como Acessar |
|-------|------|--------------|
| Forex Factory | Retail traders | firecrawl |
| Elite Trader | Discussoes pro | firecrawl |
| QuantConnect | Algo community | perplexity |
| Reddit r/algotrading | Discussoes | perplexity |

### Industria / Blogs
| Fonte | Conteudo | Como Acessar |
|-------|----------|--------------|
| QuantStart | Tutoriais quant | perplexity |
| Towards Data Science | ML aplicado | perplexity |
| Medium quant tags | Artigos variados | perplexity/exa |

---

## Handoffs

| Para | Quando | Exemplo |
|------|--------|---------|
| FORGE | Implementar codigo | "implementar", "codar pattern" |
| ORACLE | Validar finding | "testar", "validar estatistica" |
| CRUCIBLE | Aplicar estrategia | "usar no setup", "trading" |
| SENTINEL | Avaliar risco | "risk de implementar" |

---

## Niveis de Confianca

| Nivel | Condicao | Acao |
|-------|----------|------|
| ALTA | 3 fontes concordam | Implementar |
| MEDIA | 2 fontes concordam | Implementar com cautela |
| BAIXA | Fontes divergem | Mais pesquisa |
| SUSPEITO | 1 fonte apenas | Nao confiar |
| RED FLAG | Muito bom pra ser verdade | Investigar fundo |

---

## Arquivos do Projeto para Contexto

| Arquivo | Caminho |
|---------|---------|
| EA Principal | `MQL5/Experts/EA_SCALPER_XAUUSD.mq5` |
| Arquitetura | `MQL5/Include/EA_SCALPER/INDEX.md` |
| Order Flow | `MQL5/Include/EA_SCALPER/Analysis/ORDER_FLOW_README.md` |
| RAG Docs | `.rag-db/docs/` |
| RAG Books | `.rag-db/books/` |

---

## ONDE SALVAR OUTPUTS

| Tipo | Pasta | Naming |
|------|-------|--------|
| Paper summaries | `DOCS/03_RESEARCH/PAPERS/` | `YYYYMMDD_AUTHOR_TITLE.md` |
| Research findings | `DOCS/03_RESEARCH/FINDINGS/` | `TOPIC_FINDING.md` |
| Repo references | `DOCS/03_RESEARCH/REPOS/REPO_INDEX.md` | Append |
| Citations | `DOCS/03_RESEARCH/CITATIONS.md` | Append |
| Progress | `DOCS/02_IMPLEMENTATION/PROGRESS.md` | Append |

---

## Search Query Templates

### Perplexity
```
"[topico] algorithmic trading state of the art 2024"
"[topico] quantitative finance implementation"
"[topico] gold XAUUSD trading strategy"
```

### GitHub
```
"[topico] trading" language:python stars:>50
"[topico] mql5" language:mql5
"ONNX trading" language:python
```

### arXiv/Academic
```
"[topico] site:arxiv.org q-fin"
"[topico] machine learning trading SSRN"
"[topico] financial markets deep learning"
```
