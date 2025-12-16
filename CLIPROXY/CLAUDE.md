# CLIPROXY - Claude Context

> **Purpose**: Context file for Claude agents working within the CLIPROXY directory.
> **Version**: 1.0.0
> **Last Updated**: 2025-12-15

## What is CLIPROXY?

CLIProxyAPI is a **Go-based API proxy server** that provides OpenAI/Claude/Gemini-compatible endpoints for CLI models. It enables multi-account OAuth, load balancing, streaming, thinking, and tools support.

**Key Use Case**: Franco uses this to proxy Claude Code, Gemini CLI, and other LLM CLIs through a unified endpoint with authentication management.

---

## Quick Reference

### Server Location
```
CLIPROXY/CLIProxyAPI/
```

### Key Paths
| Path | Purpose |
|------|---------|
| `cmd/server/main.go` | Main entry point (480 lines) |
| `internal/api/server.go` | Core HTTP server (Gin) |
| `internal/translator/` | Protocol translators (Claude/Gemini/OpenAI) |
| `internal/auth/` | OAuth providers (Claude, Gemini, Codex, etc.) |
| `internal/store/` | Token storage backends |
| `config.example.yaml` | Configuration template |
| `docs/` | SDK and integration documentation |

### Default Port
```
8317
```

### Config File Location (Franco's setup)
```
~/.cliproxy/config.yaml
```

---

## Architecture Overview

```
Client (OpenAI SDK / Claude Code / Amp CLI)
    |
    v
API Server (Gin HTTP) [:8317]
    |
    v
Authentication Middleware (API key / OAuth token)
    |
    v
Protocol Translator (OpenAI <-> Claude <-> Gemini)
    |
    v
Provider Executor (retry logic, quota management)
    |
    v
Upstream API (Claude.ai, Gemini, Vertex, etc.)
```

### Core Components

1. **Translators** (`internal/translator/`)
   - `antigravity/` - Claude/Gemini via Google Cloud
   - `claude/` - Claude API
   - `gemini/` - Gemini API
   - `openai/` - OpenAI compatibility layer

2. **Auth Providers** (`internal/auth/`)
   - `claude/` - Claude Code OAuth
   - `gemini/` - Gemini CLI OAuth
   - `codex/` - OpenAI Codex OAuth
   - `vertex/` - Vertex AI service account
   - `qwen/`, `iflow/` - Other providers

3. **Storage Backends** (`internal/store/`)
   - File-based (default): `~/.cli-proxy-api/`
   - PostgreSQL: Centralized multi-instance
   - Git-backed: Version-controlled tokens
   - Object Store: S3/MinIO

---

## Common Operations

### Start Server
```bash
cd CLIPROXY/CLIProxyAPI
./cli-proxy-api -config ~/.cliproxy/config.yaml
```

### Start in Background
```bash
nohup ./cli-proxy-api -config ~/.cliproxy/config.yaml > logs/server.out 2>&1 &
```

### OAuth Login Flows
```bash
# Claude Code OAuth
./cli-proxy-api --claude-login

# Gemini CLI OAuth
./cli-proxy-api --login

# OpenAI Codex OAuth
./cli-proxy-api --codex-login

# Antigravity (Claude via Google)
./cli-proxy-api --antigravity-login
```

### Check Server Status
```bash
curl http://localhost:8317/v1/models
```

### View Logs
```bash
tail -f CLIPROXY/CLIProxyAPI/logs/server.out
```

---

## Known Issues & Troubleshooting

### 1. Thinking + Tool Use Conflict (Antigravity)

**Symptom**: `400 invalid_request_error: Expected thinking, but found tool_use`

**Cause**: When thinking is enabled, some backends require `tool_use` messages to start with a `thinking` block containing a valid `signature`.

**Default Behavior**: CLIProxyAPI **suppresses thinking** when tool_use exists in history (safe mode).

**Override** (experimental):
```bash
export CLIPROXY_ANTIGRAVITY_ALLOW_THINKING_WITH_TOOL_USE=1
```

**Best Practice**: Start a fresh conversation after upgrading to avoid signature-less tool_use history.

### 2. Schema Validation Errors

**Symptom**: `400 INVALID_ARGUMENT: Unknown name "$ref"`

**Cause**: Some endpoints reject JSON Schemas with `$ref`, `$defs`, `propertyNames`, etc.

**Fix**: CLIProxyAPI auto-sanitizes schemas, but if issues persist, inline schemas manually.

### 3. Rate Limiting / Quota

**Symptom**: `429 RESOURCE_EXHAUSTED` followed by `403 SUBSCRIPTION_REQUIRED`

**Cause**: Fallback to a project requiring Gemini Code Assist license.

**Fix**: Pin `base_url` in auth JSON.

### 4. All Credentials Cooling Down

**Symptom**: `429 model_cooldown`

**Fix**: Respect `Retry-After` header, reduce concurrency, or add more accounts.

---

## Configuration Reference

### Minimal config.yaml
```yaml
port: 8317
auth-dir: ~/.cli-proxy-api
debug: false
logging-to-file: true
request-retry: true
max-retry-interval: 60

api-keys:
  - your-api-key-here
```

### With Proxy Support
```yaml
proxy-url: socks5://127.0.0.1:1080
# or: http://proxy.example.com:8080
```

### Quota Exceeded Handling
```yaml
quota-exceeded:
  switch-project: true    # Try other projects
  switch-to-preview: true # Fall back to preview models
```

### Model Mapping (Amp integration)
```yaml
ampcode:
  model-mapping:
    - claude-opus-4.5 -> claude-sonnet-4
```

---

## For Subagent: CLIPROXY-ENGINEER

When spawning the CLIPROXY-ENGINEER subagent, it should:

1. **Read this file first** for context
2. **Check logs** at `logs/server.out` for errors
3. **Review config** at Franco's `~/.cliproxy/config.yaml`
4. **Consult docs** in `docs/` directory for SDK/integration details
5. **Check auth files** in `~/.cli-proxy-api/` for token issues

### Key Debugging Steps

1. Check if server is running: `pgrep -af cli-proxy-api`
2. Check server logs: `tail -100 logs/server.out`
3. Test endpoint: `curl http://localhost:8317/v1/models`
4. Check auth tokens: `ls -la ~/.cli-proxy-api/`
5. Review config: `cat ~/.cliproxy/config.yaml`

---

## Existing Documentation

| File | Content |
|------|---------|
| `README.md` | Project overview |
| `docs/sdk-usage.md` | Embedding as Go SDK |
| `docs/sdk-advanced.md` | Custom executors/translators |
| `docs/sdk-access.md` | Access control |
| `docs/amp-cli-integration.md` | Amp CLI setup |
| `docs/troubleshooting-antigravity.md` | Antigravity issues |

---

## Quick Links

- **Main Entry**: `cmd/server/main.go`
- **Server**: `internal/api/server.go`
- **Translators**: `internal/translator/*/`
- **Auth**: `internal/auth/*/`
- **Config Example**: `config.example.yaml`
