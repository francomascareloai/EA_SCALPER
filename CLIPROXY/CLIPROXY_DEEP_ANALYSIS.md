# CLIProxyAPI Deep Analysis (for Franco Q&A)

Location analyzed: `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI`

This document is a reference for the **CLIProxyAPI** Go service: architecture, request/response flow, translators, auth providers, configuration, and operational scenarios.

---

## 1) Architecture Deep Dive

### 1.1 High-level components

**Entry point**
- `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/cmd/server/main.go`
  - Parses flags (server vs multiple `--*-login` modes).
  - Loads `.env` if present.
  - Loads config from either:
    - **Postgres token store** (via `PGSTORE_*` env vars), or
    - **Object store token store** (via `OBJECTSTORE_*` env vars), or
    - **Git token store** (via `GITSTORE_*` env vars), or
    - Explicit `-config` path, or
    - Default `./config.yaml`
  - Registers a shared token store once (`sdk/auth.RegisterTokenStore(...)`).
  - Starts the service (`cmd.StartService(...)`) unless running a login/import mode.

**HTTP API server (Gin)**
- `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/internal/api/server.go`
  - Hosts OpenAI-/Claude-/Gemini-compatible endpoints.
  - Adds:
    - request logging middleware (optional)
    - CORS middleware
    - authentication middleware
  - Attaches management routes only when a secret is configured.

**Core runtime (selection + retry + cooldown)**
- Implemented in SDK layer:
  - `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/sdk/cliproxy/auth/manager.go`
  - `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/sdk/cliproxy/auth/selector.go`
  - `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/sdk/cliproxy/auth/types.go`

**Translators (schema conversion)**
- Registered through blank imports:
  - `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/internal/translator/init.go`
- Wrapper registry:
  - `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/internal/translator/translator/translator.go`

**Executors (provider-specific upstream execution)**
- Live in internal runtime:
  - `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/internal/runtime/executor/*.go`
- Each executor:
  1) translates request to provider format
  2) injects required metadata
  3) executes outbound HTTP calls
  4) parses usage, records logs
  5) translates response back to the caller’s format

**Hot reload watcher**
- `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/internal/watcher/watcher.go`
  - Watches config file + auth directory for changes.
  - Debounces config reload and updates server runtime.
  - Synthesizes “auth entries” from both:
    - OAuth token JSON files in `auth-dir`
    - API key blocks in config (`gemini-api-key`, `claude-api-key`, `codex-api-key`, `openai-compatibility`, `vertex-api-key`)

### 1.2 Request flow (client → upstream)

Typical inbound flow for `/v1/chat/completions` or `/v1/messages`:

1) **Client sends request** to CLIProxyAPI.
2) **Auth middleware** validates inbound credential:
   - `AuthMiddleware` uses `sdk/access.Manager.Authenticate(...)`.
   - On success it sets `apiKey` and `accessProvider` on the Gin context.
3) **Handler selects protocol**
   - OpenAI-style: `/v1/chat/completions`, `/v1/responses`, etc.
   - Claude-style: `/v1/messages` and `/v1/messages/count_tokens`
   - Gemini-style: `/v1beta/models/...`
4) **Core auth manager selects a credential** for the chosen provider:
   - Round-robin selection (per provider + model) with cooldown filtering.
   - If all credentials are cooling down, returns a 429 with `Retry-After`.
5) **Executor calls upstream**
   - Applies translator conversions.
   - Uses proxy-aware HTTP client.
   - Records request/response logs (optional) and publishes usage stats.
6) **Response translated back** to the inbound format and returned.

### 1.3 Load balancing + retry model

There are two distinct “rotation” layers:

1) **Provider rotation** (multi-provider routing):
   - In `sdk/cliproxy/auth/manager.go`, `Execute/ExecuteStream` accepts `providers []string`.
   - It rotates provider order per `model` (`rotateProviders` + `advanceProviderCursor`).
   - This supports patterns like: try `gemini-cli` first, then `antigravity`, then `aistudio`, etc.

2) **Credential rotation** inside a provider:
   - `RoundRobinSelector.Pick(...)` in `sdk/cliproxy/auth/selector.go`.
   - For the `(provider, model)` key, it round-robins among candidates.

**Cooldown / quota backoff**
- `MarkResult(...)` updates per-model `ModelState` and sets cooldown windows when status is 429.
- Backoff can use either:
  - explicit `RetryAfter` from provider error (preferred), or
  - exponential cooldown (`nextQuotaCooldown`) up to 30 minutes.
- When all auths for a model are cooling down:
  - selector returns a `modelCooldownError` (HTTP 429 + JSON body + `Retry-After`).

**Config-driven retry**
- `request-retry` and `max-retry-interval` (config) control how many attempts CLIProxyAPI does.
- Important nuance: retry is not “blind”; the manager only waits if there is a known cooldown window <= `max-retry-interval`.

---

## 2) Translators (what exists, what each does)

Translator registration is done via init-time registration:
- `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/internal/translator/init.go` blank-imports all built-ins.
- Each translator folder has an `init.go` that calls `internal/translator/translator.Register(from, to, requestFn, responseFn)`.

### 2.1 Antigravity translators
Path root: `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/internal/translator/antigravity/`

- `antigravity/claude/*`
  - Purpose: Claude Code schema ↔ Antigravity (Gemini-like “Cloud Code Assist”) schema.
  - Key file: `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/internal/translator/antigravity/claude/antigravity_claude_request.go`
    - Converts Claude `messages[]` into Gemini-style `request.contents[]`.
    - Converts Claude `tool_use` into Gemini `functionCall` parts.
    - Converts Claude `tool_result` into Gemini `functionResponse` parts.
    - Sanitizes JSON schema for tools to remove `$ref`, `$defs`, etc.
    - Implements the critical “thinking + tool_use” safety gate (details in Scenarios).
  - Key file: `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/internal/translator/antigravity/claude/antigravity_claude_response.go`
    - Converts Antigravity/Gemini SSE stream into Claude streaming events.
    - Tracks state transitions between text, thinking, tool_use.
    - Intentionally does not emit Anthropic signed-thinking signatures.

- `antigravity/gemini/*`
  - Purpose: Gemini schema ↔ Antigravity schema.
  - Typical use: Gemini-compatible clients (or internal Gemini routes) backed by Antigravity.

- `antigravity/openai/chat-completions/*`
  - Purpose: OpenAI ChatCompletions schema ↔ Antigravity schema.

- `antigravity/openai/responses/*`
  - Purpose: OpenAI Responses API schema ↔ Antigravity schema.

### 2.2 Claude translators
Path root: `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/internal/translator/claude/`

- `claude/openai/chat-completions/*`
  - Bridges OpenAI ChatCompletions requests into Claude-style and back.

- `claude/openai/responses/*`
  - Bridges OpenAI Responses into Claude-style and back.

- `claude/gemini/*` and `claude/gemini-cli/*`
  - Bridges between Claude schema and Gemini or Gemini CLI schema.

### 2.3 Gemini translators
Path root: `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/internal/translator/gemini/`

- `gemini/gemini/*`: Gemini ↔ Gemini transformations.
- `gemini/claude/*`: Gemini ↔ Claude transformations.
- `gemini/gemini-cli/*`: Gemini ↔ Gemini CLI transformations.
- `gemini/openai/chat-completions/*` and `gemini/openai/responses/*`: Gemini ↔ OpenAI conversions.

### 2.4 Gemini-CLI translators
Path root: `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/internal/translator/gemini-cli/`

- `gemini-cli/claude/*`: Gemini CLI ↔ Claude conversions.
- `gemini-cli/gemini/*`: Gemini CLI ↔ Gemini conversions.
- `gemini-cli/openai/chat-completions/*` and `gemini-cli/openai/responses/*`: Gemini CLI ↔ OpenAI conversions.

### 2.5 OpenAI translators
Path root: `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/internal/translator/openai/`

- `openai/openai/chat-completions/*` and `openai/openai/responses/*`: OpenAI ↔ OpenAI.
- `openai/claude/*`: OpenAI ↔ Claude.
- `openai/gemini/*`: OpenAI ↔ Gemini.
- `openai/gemini-cli/*`: OpenAI ↔ Gemini CLI.

### 2.6 Codex translators
Path root: `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/internal/translator/codex/`

- `codex/openai/chat-completions/*` and `codex/openai/responses/*`:
  - Bridges Codex-specific expectations into OpenAI formats.
- `codex/claude/*`, `codex/gemini/*`, `codex/gemini-cli/*`:
  - Enables Codex-backed flows to surface as Claude/Gemini-compatible endpoints.

### 2.7 Known translator limitations (observed)

- Signed-thinking portability is not “real”: Antigravity’s `thoughtSignature` is *not* the same as Anthropic signed-thinking.
- Tool schema strictness varies by upstream; sanitization is necessary and can lose expressiveness (e.g., dropping `$ref`).
- Tool-use protocol correctness is strict for Claude-like clients: missing `tool_result` will 400.

---

## 3) Auth Providers (what exists, what each does)

Auth providers live under:
- `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/internal/auth/`

This repo supports both:
- **OAuth-based auth files** (stored under `auth-dir`, typically `~/.cli-proxy-api/*.json`), and
- **API-key config entries** (in config YAML).

### 3.1 Provider list (directories)

- `internal/auth/claude/`
  - Anthropic/Claude OAuth with PKCE.
  - Key file: `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/internal/auth/claude/anthropic_auth.go`
  - Uses:
    - `https://claude.ai/oauth/authorize` (authorize)
    - `https://console.anthropic.com/v1/oauth/token` (token/refresh)
  - Token storage: JSON saved to `auth-dir` (via the shared token store).

- `internal/auth/codex/`
  - OpenAI OAuth flow for Codex.
  - Key file: `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/internal/auth/codex/openai_auth.go`
  - Uses:
    - `https://auth.openai.com/oauth/authorize`
    - `https://auth.openai.com/oauth/token`
  - Uses PKCE and parses `id_token` to identify account.

- `internal/auth/gemini/`
  - Google OAuth for Gemini; also supports project selection and onboarding.
  - Login logic: `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/internal/cmd/login.go`

- `internal/auth/vertex/`
  - Vertex credential support (service account import). See CLI flag `--vertex-import`.

- `internal/auth/qwen/`
  - Qwen OAuth token support.

- `internal/auth/iflow/`
  - iFlow OAuth token support, plus cookie-based alternative.

- `internal/auth/empty/`
  - Placeholder/no-auth provider.

### 3.2 OAuth callback mechanics

The server exposes callback endpoints on the main port and writes a small `.oauth-<provider>-<state>.oauth` file into `auth-dir`:
- `/anthropic/callback`
- `/codex/callback`
- `/google/callback`
- `/iflow/callback`
- `/antigravity/callback`

Implementation: `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/internal/api/server.go`.

This is a coordination channel between:
- browser redirect, and
- the goroutine in the login flow waiting for `code` and `state`.

### 3.3 Token storage backends

The runtime can store tokens and config in different backends (decided by env vars in `cmd/server/main.go`):

- Default: local filesystem token store.
- Optional:
  - Postgres store (`PGSTORE_DSN`, etc.)
  - Git-backed store (`GITSTORE_*`)
  - Object store (S3/MinIO-like) (`OBJECTSTORE_*`)

All are registered once and used by login flows + watcher.

---

## 4) Configuration Guide (config.example.yaml)

Config template:
- `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/config.example.yaml`

### 4.1 Core server settings
- `host`: bind address. Use `127.0.0.1` or `localhost` to avoid exposing to LAN.
- `port`: default `8317`.
- `tls.enable/cert/key`: optional HTTPS.

### 4.2 Auth + security
- `auth-dir`: directory for OAuth token files and callback scratch files.
- `api-keys`: inbound API keys accepted by the proxy (protects the proxy endpoint).
- `ws-auth`: if true, authenticates websocket `/v1/ws`.

**Management API**
- `remote-management.secret-key`: enables `/v0/management/*` routes when set.
  - If plaintext, it gets bcrypt-hashed and persisted back to YAML.
- `remote-management.allow-remote`: if false, only localhost can access management.
- `MANAGEMENT_PASSWORD` env var: alternative secret enabling management routes.

### 4.3 Retry/cooldown
- `request-retry`: number of extra attempts.
- `max-retry-interval`: max time to wait for cooldown before retrying.
- `disable-cooling`: disables quota cooldown scheduling in the SDK manager.

### 4.4 Provider credentials

OAuth providers are stored as `.json` auth files in `auth-dir`.

API-key providers are declared in YAML:
- `gemini-api-key`: official Gemini API keys.
- `claude-api-key`: official Claude API keys.
- `codex-api-key`: Codex-style API keys (plus base-url overrides).
- `openai-compatibility`: arbitrary OpenAI-compatible providers (e.g., OpenRouter) with:
  - provider `name`
  - `base-url`
  - `api-key-entries` and optional per-key `proxy-url`
  - optional model aliases.
- `vertex-api-key`: Vertex-compatible third-party endpoints.

### 4.5 Amp integration
- `ampcode.upstream-url`: Amp control plane (for management reverse proxy).
- `ampcode.upstream-api-key`: optional override.
- `ampcode.restrict-management-to-localhost`: important security guard.
- `ampcode.model-mappings`: maps requested model IDs to available local ones.

### 4.6 Franco’s typical setup (recommended)

- Bind locally: `host: "127.0.0.1"`
- Use `api-keys` for local clients
- Enable `logging-to-file: true` and `request-log` (if you want audit trails)
- Enable `quota-exceeded.switch-project: true` for Gemini multi-project auth files.

---

## 5) Common Scenarios & Troubleshooting

### 5.1 Antigravity “thinking + tool_use” conflict

Reference: `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/docs/troubleshooting-antigravity.md`

Symptom:
- `400 invalid_request_error: Expected thinking, but found tool_use`
- or missing `messages.N.content.0.thinking.signature`

Root cause:
- Some upstreams enforce strict ordering when thinking is enabled: assistant tool-use messages must be preceded by a valid thinking block (often with signature). Old sessions may have tool_use without signatures.

What CLIProxyAPI does:
- Default safe behavior: if tool_use is present in assistant history, it suppresses thinking config and drops thinking blocks for Antigravity.
- It still adds a Gemini `thoughtSignature` field on tool call parts for validation using sentinel value: `skip_thought_signature_validator`.

Override:
- `CLIPROXY_ANTIGRAVITY_ALLOW_THINKING_WITH_TOOL_USE=1`
  - forces thinking config, but can reintroduce upstream 400s.

Key implementation file:
- `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/internal/translator/antigravity/claude/antigravity_claude_request.go`

### 5.2 Rate limiting / quota handling

Mechanisms:
- Executors parse retry hints when available (example: Gemini CLI parses RetryInfo.retryDelay).
- SDK auth manager sets cooldown windows and emits HTTP 429 with `Retry-After` when all credentials are cooling down.

User actions:
- Add more accounts (more auth files) and/or more projects.
- Reduce concurrency.
- Respect `Retry-After` (clients should back off).

### 5.3 Multi-account setup

- Add multiple OAuth auth files in `auth-dir` (e.g., multiple Claude accounts).
- Add multiple API keys under `gemini-api-key`, `claude-api-key`, etc.
- For Gemini CLI, auth metadata can include multiple projects (comma-separated) and watcher can synthesize “virtual” per-project auths.

### 5.4 Troubleshooting checklist

- If endpoints 401: check inbound `api-keys` and client headers.
- If upstream 401/403: re-run the corresponding login flow.
- If tool schema errors (`$ref` etc.): simplify tool JSON schemas or rely on built-in sanitization.
- If management API 404: you likely didn’t set `remote-management.secret-key` (or `MANAGEMENT_PASSWORD`).

---

## 6) Current State (repo snapshot)

Repository context:
- Repo path: `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI`
- Current branch: `fix/antigravity-thinking-tooluse`
- HEAD: `0977bd69f7da8a673ae9c0ff4a5831c9f81646c0`

Recent commits (top of log at time of analysis):
- `0977bd6 chore(logs): add redacted run log`
- `9ccf0e6 fix(antigravity/claude): harden thinking+tool_use translation`
- `ba5fa84 fix(antigravity/claude): preserve thinking signatures for tool_use`
- `2b877ac fix(antigravity): sanitize tool JSON schemas (strip $ref)`
- `cd2da15 feat(models): add GPT 5.2 model definition and prompts`

---

## Appendix A: Key files (quick links)

- README: `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/README.md`
- Entry point: `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/cmd/server/main.go`
- Server: `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/internal/api/server.go`
- Config template: `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/config.example.yaml`
- Antigravity troubleshooting: `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/docs/troubleshooting-antigravity.md`
- Amp integration: `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/docs/amp-cli-integration.md`
- SDK usage: `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/docs/sdk-usage.md`
- SDK access: `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/docs/sdk-access.md`
- SDK advanced: `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/docs/sdk-advanced.md`

---

## Appendix B: Notes on logs

Logs exist under:
- `/home/franco/projetos/EA_SCALPER_XAUUSD/CLIPROXY/CLIProxyAPI/logs/`

They include large request/response captures (some redacted). For Q&A, prioritize:
- `server.out` for startup errors.
- `main.log` for aggregated logs.
- `v1-messages-*` for Claude Code request traces (beware size).
