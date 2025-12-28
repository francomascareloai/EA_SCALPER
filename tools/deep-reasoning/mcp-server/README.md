# Deep Reasoning MCP Server

MCP Server para acessar modelos de raciocínio profundo (GPT-5 Pro, O1-Pro, Gemini DeepThink) via interfaces web.

## Arquitetura

```
┌─────────────────────────────────────────────────────┐
│              deep-reasoning-mcp                     │
├─────────────────────────────────────────────────────┤
│  Tools:                                             │
│  - ask_deep(question, models[], hints[])            │
│  - get_task_status(task_id)                         │
│  - list_tasks()                                     │
│  - cancel_task(task_id)                             │
│  - available_models()                               │
├─────────────────────────────────────────────────────┤
│  Backends:                                          │
│  ┌─────────────────┐    ┌─────────────────────────┐│
│  │    chat2api     │    │  Playwright (Browser)   ││
│  │   (ChatGPT)     │    │  ChatGPT + Gemini       ││
│  │  Fast, no web   │    │  Real research/think    ││
│  └─────────────────┘    └─────────────────────────┘│
└─────────────────────────────────────────────────────┘
```

## Quick Start

### 1. Instalar dependências

```bash
cd tools/deep-reasoning/mcp-server
pip install -e .
pip install playwright
playwright install chromium
playwright install-deps chromium
```

### 2. Configurar sessão do ChatGPT

**Primeira vez** - Fazer login interativo:
```bash
cd tools/deep-reasoning/mcp-server
DISPLAY=:0 python login_chatgpt_timed.py 120
```

Um browser abrirá. Faça login no ChatGPT dentro de 2 minutos.
A sessão será salva automaticamente em `~/.deep-reasoning/chatgpt-session/`.

### 3. Configurar sessão do Gemini (opcional)

```bash
DISPLAY=:0 python login_gemini.py
```

Faça login no Google e feche o browser para salvar.

### 4. Adicionar ao Claude Code

Adicione ao seu `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "deep-reasoning": {
      "command": "python",
      "args": ["-m", "deep_reasoning_mcp.server"],
      "cwd": "/home/franco/projetos/EA_SCALPER_XAUUSD/tools/deep-reasoning/mcp-server"
    }
  }
}
```

## Uso para Sub-Agents

### Pesquisa com Deep Research (ChatGPT)

```python
# Trigger: usa hints=["research"] para ativar Search mode
await mcp.call_tool("deep-reasoning", "ask_deep", {
    "question": "What are the latest developments in quantum computing in 2025?",
    "models": ["gpt-5-pro"],
    "hints": ["research"],  # Ativa web research
    "wait": True
})
```

Tempo esperado: 20-60 segundos (com web search ativo)

### Raciocínio Profundo (sem pesquisa)

```python
# Sem hints - resposta direta do modelo
await mcp.call_tool("deep-reasoning", "ask_deep", {
    "question": "Explain the mathematical foundations of Black-Scholes",
    "models": ["o1-pro"],
    "wait": True
})
```

Tempo esperado: 10-30 segundos

### Query Assíncrona (para pesquisas longas)

```python
# 1. Iniciar query (não bloqueia)
result = await mcp.call_tool("deep-reasoning", "ask_deep", {
    "question": "Deep analysis of AI regulation trends globally",
    "models": ["gpt-5-pro", "gemini-deepthink"],
    "hints": ["research"],
    "wait": False  # Retorna imediatamente
})
task_id = result["task_id"]

# 2. Verificar status periodicamente
while True:
    status = await mcp.call_tool("deep-reasoning", "get_task_status", {
        "task_id": task_id
    })
    if status["status"] == "completed":
        break
    await asyncio.sleep(30)

# 3. Respostas ficam em status["results"]
```

## Backends

### Playwright Browser Backend (Recomendado)

- **Vantagem**: Acesso real ao Deep Research/Search do ChatGPT
- **Requisito**: Display disponível (WSLg com DISPLAY=:0)
- **Sessão**: Salva em `~/.deep-reasoning/chatgpt-session/`
- **Headless**: Bloqueado por Cloudflare - usa modo visible via WSLg

### chat2api Backend (Alternativo)

Para uso sem browser (mais rápido, mas sem web research real):

1. Iniciar chat2api em terminal separado:
```bash
cd tools/deep-reasoning
./start-chat2api.sh
```

2. Configurar token:
```bash
# 1. Login em https://chatgpt.com
# 2. Abrir https://chatgpt.com/api/auth/session
# 3. Copiar accessToken
export CHATGPT_ACCESS_TOKEN='eyJ...'
```

## Modelos Disponíveis

### ChatGPT (Playwright ou chat2api)
| Modelo | Descrição | Use Case |
|--------|-----------|----------|
| `gpt-5-pro` | GPT-5 Pro | Complex reasoning |
| `o1-pro` | O1 Pro | Step-by-step reasoning |
| `o1-mini` | O1 Mini | Faster O1 |
| `o3-mini` | O3 Mini | Latest reasoning |
| `o3-mini-high` | O3 Mini High | More compute |
| `gpt-4o` | GPT-4o | Fast general use |

### Gemini (Playwright only)
| Modelo | Descrição | Use Case |
|--------|-----------|----------|
| `gemini-deepthink` | Gemini DeepThink | Deep reasoning |
| `gemini-2.5-pro` | Gemini 2.5 Pro | Latest Gemini |

## Hints Disponíveis

| Hint | Efeito |
|------|--------|
| `research` | Ativa Search mode - pesquisa web real |
| `think_deeply` | Solicita raciocínio estendido |

## Storage

Respostas são persistidas em:
- Database: `~/.deep-reasoning/tasks.db`
- Responses: `~/.deep-reasoning/responses/{task_id}/{model}.md`

## Variáveis de Ambiente

| Variável | Descrição | Default |
|----------|-----------|---------|
| `CHATGPT_ACCESS_TOKEN` | Token para chat2api | - |
| `CHAT2API_URL` | URL do chat2api | http://localhost:5005 |
| `DEEP_REASONING_DIR` | Storage directory | ~/.deep-reasoning |
| `DISPLAY` | Display para Playwright | :0 |

## Troubleshooting

### "Not logged in" error
```bash
# Refazer login
DISPLAY=:0 python login_chatgpt_timed.py 120
```

### Cloudflare blocking
O modo headless é bloqueado. Use `headless=False` (default) com WSLg.

### Browser não abre
Verificar WSLg:
```bash
echo $DISPLAY  # Deve ser :0
xeyes  # Deve abrir janela
```

### Session expired
Sessões expiram após ~7 dias. Refaça o login quando necessário.
