# RAG Local Setup Guide - MQL5 Knowledge Base

## Visao Geral

Este guia configura um sistema RAG (Retrieval-Augmented Generation) 100% local para documentacao MQL5.

**Stack escolhido:**
- **MCP Server**: `mcp-local-rag` (Node.js - funciona no Windows!)
- **Vector DB**: LanceDB (arquivo local, sem servidor)
- **Embeddings**: all-MiniLM-L6-v2 (local, offline apos download)
- **Chunking**: 512 tokens com 100 overlap

## Pre-requisitos

- Node.js v18+ (voce tem v22 ✓)
- ~200MB espaco disco (modelo + database)
- Livros em PDF em `DOCS/BOOKS/`

## Passo 1: Verificar Node.js

```powershell
node --version
# Deve mostrar v18+ (voce tem v22.19.0 ✓)
```

## Passo 2: Primeira Execucao (Download do Modelo)

Na primeira vez, o modelo sera baixado (~90MB):

```powershell
# Testar se funciona
npx -y mcp-local-rag
# Ctrl+C para parar apos confirmar que funciona
```

## Passo 3: Configurar no Factory/Cursor

### Opcao A: Factory Droid

Ja criado em `.factory/mcp.json`:
```json
{
  "mcpServers": {
    "mql5-knowledge": {
      "command": "npx",
      "args": ["-y", "mcp-local-rag"],
      "env": {
        "BASE_DIR": "C:\\Users\\Admin\\Documents\\EA_SCALPER_XAUUSD\\DOCS\\BOOKS",
        "DB_PATH": "C:\\Users\\Admin\\Documents\\EA_SCALPER_XAUUSD\\.rag-db\\lancedb",
        "CACHE_DIR": "C:\\Users\\Admin\\Documents\\EA_SCALPER_XAUUSD\\.rag-db\\models"
      }
    }
  }
}
```

### Opcao B: Cursor IDE

Adicione em `~/.cursor/mcp.json` ou `.cursor/mcp.json` no projeto:
```json
{
  "mcpServers": {
    "mql5-knowledge": {
      "command": "npx",
      "args": ["-y", "mcp-local-rag"],
      "env": {
        "BASE_DIR": "C:\\Users\\Admin\\Documents\\EA_SCALPER_XAUUSD\\DOCS\\BOOKS",
        "DB_PATH": "C:\\Users\\Admin\\Documents\\EA_SCALPER_XAUUSD\\.rag-db\\lancedb",
        "CACHE_DIR": "C:\\Users\\Admin\\Documents\\EA_SCALPER_XAUUSD\\.rag-db\\models"
      }
    }
  }
}
```

## Passo 4: Ingerir Documentos

Apos configurar, reinicie o Cursor/Factory e use:

### Ingerir livros MQL5 principais:

```
"Ingest C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\DOCS\BOOKS\mql5.pdf"
"Ingest C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\DOCS\BOOKS\mql5book (1).pdf"
"Ingest C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\DOCS\BOOKS\Expert_Advisor_Programming_for_MetaTrader_5_(_PDFDrive_).pdf"
"Ingest C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\DOCS\BOOKS\Smart Money Concept (SMC).pdf"
```

### Verificar status:
```
"Show RAG server status"
"List all ingested files"
```

## Passo 5: Usar o RAG

Apos ingestao, pergunte naturalmente:

```
"Como usar OnnxCreate no MQL5?"
"Qual a sintaxe do OnTick?"
"Explique Order Blocks do Smart Money Concept"
"Como calcular Hurst Exponent em MQL5?"
"Quais funcoes de array existem no MQL5?"
```

## Passo 6: Scraping da Documentacao Online (Opcional)

Para ter 100% da documentacao:

```powershell
# Instalar dependencias do scraper
pip install requests beautifulsoup4 markdownify tqdm

# Scrape tudo (vai demorar ~30-60 min)
python scripts/scrape_mql5_docs.py --all --output ./DOCS/SCRAPED --max-pages 500

# Ou scrape apenas a referencia
python scripts/scrape_mql5_docs.py --reference --output ./DOCS/SCRAPED
```

Depois, ingerir os arquivos scraped:
```
"Ingest all markdown files from C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\DOCS\SCRAPED"
```

## Estrutura Final

```
DOCS/
├── BOOKS/                    # ✓ Livros PDF (ja tem!)
│   ├── mql5.pdf
│   ├── mql5book (1).pdf
│   ├── Smart Money Concept.pdf
│   └── ...
├── SCRAPED/                  # Documentacao online (apos scrape)
│   ├── reference/
│   ├── book/
│   └── articles/
└── RAG_SETUP_GUIDE.md        # Este guia

.rag-db/                      # Database local (auto-criado)
├── lancedb/                  # Vetores e metadados
└── models/                   # Modelo de embeddings cached
```

## Troubleshooting

### "No results found"
- Certifique-se de ingerir documentos primeiro
- Use `"List all ingested files"` para verificar

### Modelo nao baixa
- Verifique conexao com internet
- Primeira execucao precisa de internet
- Depois funciona 100% offline

### Erro de path
- Use paths absolutos com `\\` no Windows
- Verifique se BASE_DIR aponta para pasta correta

### Performance lenta
- Normal: ~5-10s por MB de PDF
- Queries: ~1-3s
- Depois da ingestao, e rapido!

## Comparacao: Antes vs Depois

| Aspecto | Context7 | RAG Local |
|---------|----------|-----------|
| Tokens/query | ~3000 | ~500 |
| Latencia | ~500ms | ~50ms |
| Cobertura | Parcial | 100% |
| Offline | Nao | Sim |
| Windows | ✓ | ✓ |
| Controle | Nenhum | Total |
| Custo | Gratis | Gratis |

## Proximos Passos

1. [ ] Ingerir livros MQL5 core
2. [ ] Testar queries basicas
3. [ ] Rodar scraper para documentacao online
4. [ ] Ingerir documentacao scraped
5. [ ] Profit! 🚀
