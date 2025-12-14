# G3 (AI Coding Agent) — Guia de Uso no EA_SCALPER_XAUUSD

Este projeto já vem com o **g3** integrado e configurado para usar o seu **CLIProxyAPI** local (OpenAI-compatible).

## Onde está (como “chegar nele”)

- Rodar o g3 (atalho do projeto): `./g3`
- Código-fonte do g3 (para editar): `tools/g3/`
- Binário compilado: `tools/g3/target/release/g3`
- Script de build (recompila e mantém o atalho): `tools/g3/build-release.sh`
- Smoke test (valida proxy + g3): `tools/g3/smoke-test.sh`

## Pré-requisitos (proxy)

O g3 depende do **CLIProxyAPI** rodando em `http://127.0.0.1:8317`.

Checar se está rodando:
- `ss -ltnp | rg ':8317'`

Listar modelos do proxy (precisa da key):
- `curl -sS -H "Authorization: Bearer <SUA_KEY>" http://127.0.0.1:8317/v1/models | jq -r '.data[].id'`

## Configuração local (UMA vez)

O arquivo **local** do g3 é:
- `tools/g3/config.local.toml`

Ele é **gitignored** (contém segredos). Se ainda não existir:
- `cp tools/g3/config.local.toml.example tools/g3/config.local.toml`
- Edite `tools/g3/config.local.toml` e configure:
  - `api_key = "sk-local-proxy-..."`
  - `base_url = "http://127.0.0.1:8317/v1"`
  - `model = "gemini-claude-opus-4-5-thinking"` (ou outro que exista no `/v1/models`)
  - `max_tokens = 65536` (limite máximo de saída por resposta; útil para gerar arquivos grandes)

## Compilar / atualizar o g3 (quando você mexer no código)

- `./tools/g3/build-release.sh`

Isso recompila o g3 e garante que `./g3` continue usando `tools/g3/config.local.toml`.

## Testar (smoke test “100% pronto”)

- `./tools/g3/smoke-test.sh`

Esse teste valida:
1) Proxy responde em `/v1/models`
2) Proxy responde em `/v1/chat/completions`
3) `./g3` funciona em modo single-shot

## Como usar (no dia a dia)

### 1) Single-shot (mais simples)

Você passa uma tarefa e o g3 executa:
- `./g3 "faça um script python que abre o parquet e imprime colunas"`

Dica: use tarefas pequenas e incrementais.

### 2) Modo chat (interativo)

- `./g3`

Sair:
- `Ctrl-D`
- ou `exit` / `quit`
- ou `/exit` / `/quit`

Comandos úteis no chat:
- `/help` (lista comandos)
- `/stats` (stats do contexto)
- `/readme` (recarrega README.md + AGENTS.md)
- `/compact` (força sumarização)
- `/thinnify` e `/skinnify` (reduz “tool output” grande no contexto)

### 3) Accumulative autonomous

Acumula requisitos e roda autonomamente a cada entrada:
- `./g3 --auto`

### 4) Autonomous (coach-player loop)

Roda iterativamente:
- `./g3 --autonomous --max-turns 10`

Ou passando requisitos direto:
- `./g3 --autonomous --requirements "faça X; depois faça Y"`

## Auditoria profunda (pronto para usar)

Para pedir uma análise profunda do projeto (somente leitura) e gerar um relatório:
- `./tools/g3/audit-project.sh`

Ele cria `G3_AUDIT_REPORT.md` na raiz.

### 5) Planning mode

Modo mais “processual”:
- `./g3 --planning --codepath . --workspace . --no-git`

## Logs e troubleshooting

- Logs do projeto: `logs/`
- Erros detalhados: `logs/errors/`

Rodar com debug:
- `./g3 -v "sua tarefa"`

Erros comuns:
- `Context window at capacity...`: confirme que está rodando `./g3` (wrapper) e que `tools/g3/config.local.toml` tem `max_context_length = 200000`.
- `auth_unavailable` / `404`: confirme proxy na 8317, `base_url` terminando em `/v1`, `api_key` correta e `model` existente em `/v1/models`.
