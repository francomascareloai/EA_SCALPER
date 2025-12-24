# CLI Proxy API - Guia Rápido (Foco Codex)

Servidor proxy para usar OpenAI/Claude/Gemini via CLI.

## Instalação Rápida

### Build Manual
```bash
git clone https://github.com/luispater/CLIProxyAPI.git
cd CLIProxyAPI
go build -o cli-proxy-api ./cmd/server
```

### Homebrew
```bash
brew install cliproxyapi
brew services start cliproxyapi
```

## Comandos Essenciais

### 1. Login / Autenticação (Codex + Antigravity)

> Dica (WSL): se o browser não abrir corretamente, use `--no-browser` para imprimir a URL e finalize o OAuth manualmente.

#### 1.1. Codex (OpenAI)
```bash
cd /home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI
./cli-proxy-api -config /home/franco/.cliproxy/config.yaml -codex-login
```
Se falhar:
```bash
cd /home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI
./cli-proxy-api -config /home/franco/.cliproxy/config.yaml -codex-login -no-browser
```

#### 1.2. Antigravity (Claude/Gemini via Cloud Code)
```bash
cd /home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI
./cli-proxy-api -config /home/franco/.cliproxy/config.yaml -antigravity-login
```
Se falhar:
```bash
cd /home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI
./cli-proxy-api -config /home/franco/.cliproxy/config.yaml -antigravity-login -no-browser
```

### 2. Iniciar Servidor
```bash
cd /home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI
./cli-proxy-api -config /home/franco/.cliproxy/config.yaml
```
- Servidor: `http://localhost:8317`
- Endpoint: `http://127.0.0.1:8317/v1`

### 2.1. Iniciar em background (recomendado no WSL)
```bash
cd /home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI
nohup ./cli-proxy-api -config /home/franco/.cliproxy/config.yaml > ./cliproxyapi.run.log 2>&1 & disown
```
Check rápido (não precisa API key, só confirma que respondeu):
```bash
curl -sS -m 2 http://127.0.0.1:8317/v1/models | head
```

### 2.2. Restart + testes (script)
```bash
cd /home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI
bash ./cliproxyctl.sh doctor
```

### 2.3. Ver quais contas/auth existem (sem expor tokens)

### 2.4. Parar/Desligar o proxy
```bash
pkill -f "cli-proxy-api"
# Verificar se parou:
ps aux | grep cli-proxy-api | grep -v grep
```
```bash
cd /home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI
bash ./cliproxyctl.sh accounts
```

## Windows (controller com botao)

### Opcao A (recomendado): GUI rapido (Start/Stop/Restart/Status)
Abra um PowerShell no Windows e rode:
```powershell
cd C:\Users\franco\projetos\EA_SCALPER_XAUUSD\CLIPROXY\CLIProxyAPI
.\cliproxyctl-gui.cmd
```
No app, selecione:
- `windows` para controlar `cli-proxy-api.exe` (proxy nativo no Windows)
- `wsl` para controlar o proxy dentro do WSL (chama `bash ./cliproxyctl.sh` via `wsl.exe`)

### Opcao B: CLI (PowerShell)
```powershell
cd C:\Users\franco\projetos\EA_SCALPER_XAUUSD\CLIPROXY\CLIProxyAPI
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\cliproxyctl.ps1 -Action status -Mode windows
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\cliproxyctl.ps1 -Action restart -Mode windows
```

### 2.1. Sidecar Copilot (GitHub Copilot)
```bash
# 1) Autenticar (primeira vez)
# 2) Subir sidecar (porta 4141)
# 3) Testar sidecar
curl http://localhost:4141/v1/models
```
- O CLIProxy já aponta `github-copilot` para `http://localhost:4141/v1` via `config.yaml`.
```bash
curl http://localhost:8317/v1/models
```

## Default recomendado (Antigravity Claude Opus)
- Modelo default: `gemini-claude-opus-4-5-thinking`
- reasoning.effort default: `high` (forçado em `config.yaml` via `payload.override`)
- Exemplo rápido (chat/completions):
```bash
curl -X POST http://127.0.0.1:8317/v1/chat/completions \
  -H "Authorization: Bearer <SUA_LOCAL_PROXY_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemini-claude-opus-4-5-thinking",
    "messages": [{"role": "user", "content": "Explique trailing DD 5% e a regra de fechar tudo 4:59 PM ET em 3 bullets."}],
    "max_tokens": 120
  }'
```
- Codex CLI (`~/.codex/config.toml`):
```toml
model_provider = "cliproxyapi"
model = "gemini-claude-opus-4-5-thinking"
model_reasoning_effort = "high"

[model_providers.cliproxyapi]
name = "cliproxyapi"
base_url = "http://127.0.0.1:8317/v1"
wire_api = "responses"
```

## Modelos Codex (principais)
- `gpt-5`
- `gpt-5-codex`
- `gpt-5-high`
- `gpt-5-medium`
- `gpt-5-minimal`

## Configurar Modelos Claude Code
```bash
# Claude Code v2
export ANTHROPIC_BASE_URL=http://127.0.0.1:8317
export ANTHROPIC_AUTH_TOKEN=sk-dummy
export ANTHROPIC_DEFAULT_OPUS_MODEL=gemini-claude-opus-4-5-thinking
export ANTHROPIC_DEFAULT_SONNET_MODEL=gemini-claude-sonnet-4-5-thinking
# "Haiku" é o slot rápido: use um modelo rápido/estável (ex: Sonnet sem thinking ou Gemini Flash)
export ANTHROPIC_DEFAULT_HAIKU_MODEL=gemini-claude-sonnet-4-5

# Para OpenAI via proxy (reasoning): use sufixos como -high ou -xhigh (ex.: gpt-5.2-xhigh)

# Claude Code v1
export ANTHROPIC_BASE_URL=http://127.0.0.1:8317
export ANTHROPIC_AUTH_TOKEN=sk-dummy
export ANTHROPIC_MODEL=gemini-claude-opus-4-5-thinking
export ANTHROPIC_SMALL_FAST_MODEL=gemini-claude-sonnet-4-5
```

## Exemplo de Uso (Python)
```python
from openai import OpenAI

client = OpenAI(
    api_key="dummy",
    base_url="http://localhost:8317/v1"
)

response = client.chat.completions.create(
    model="gpt-5-codex",
    messages=[{"role": "user", "content": "Crie uma função Python"}]
)

print(response.choices[0].message.content)
```

## Configuração Mínima
```yaml
port: 8317
auth-dir: "~/.cli-proxy-api"
debug: false
```

## Troubleshooting
- Permissão: `chmod +x cli-proxy-api`
- Porta ocupada: ajuste `port:` em `/home/franco/.cliproxy/config.yaml` e reinicie (`bash ./cliproxyctl.sh restart`)
- Verificar auth: `ls ~/.cli-proxy-api/`
- Contar logins: `ls ~/.cli-proxy-api/*.json 2>/dev/null | wc -l`
- Contar Antigravity: `ls ~/.cli-proxy-api/antigravity-*.json 2>/dev/null | wc -l`
- Contar Codex: `ls ~/.cli-proxy-api/codex-*.json 2>/dev/null | wc -l`
- Logs ao vivo: `./cli-proxy-api --debug | tee cli-proxy.log`
- Tail: `tail -f ~/.cli-proxy-api/logs/*.log`
- Antigravity (Claude/Gemini): `docs/troubleshooting-antigravity.md`

---

Para mais detalhes, veja [README.md](README.md).
