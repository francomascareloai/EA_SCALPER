# CLIPROXY Agents

> Registry of specialized agents for CLIProxyAPI development and troubleshooting.

---

## Available Agents

| Agent | Purpose | Triggers | Spec |
|-------|---------|----------|------|
| **CLIPROXY_ENGINEER** | Proxy infrastructure, OAuth, troubleshooting, Go code | `cliproxy`, `proxy`, `oauth`, `401`, `403`, `429`, `antigravity`, `translator` | `.claude/agents/cliproxy-engineer.md` |

---

## CLIPROXY_ENGINEER

**Domain**: CLIProxyAPI proxy server infrastructure

### Responsibilities
- Troubleshooting proxy errors (400, 401, 403, 429, 500)
- OAuth flow management (Claude, Gemini, Codex, Antigravity)
- Configuration management (`config.yaml`)
- Token refresh and storage issues
- Go code modifications (translators, auth, handlers)

### When to Use
- Server won't start or crashes
- Authentication failures
- Rate limiting / quota issues
- Thinking + tool_use conflicts (Antigravity)
- Schema validation errors
- Need to modify proxy behavior

### Quick Debug
```bash
# Check if running
pgrep -af cli-proxy-api

# Check logs
tail -100 CLIPROXY/CLIProxyAPI/logs/server.out

# Test endpoint
curl http://localhost:8317/v1/models

# Check auth tokens
ls -la ~/.cli-proxy-api/
```

### Key Paths
```
CLIPROXY/CLIProxyAPI/
├── cmd/server/main.go          # Entry point
├── internal/api/server.go      # Core HTTP server
├── internal/translator/        # Protocol translators
├── internal/auth/              # OAuth providers
├── config.example.yaml         # Config template
└── logs/server.out             # Runtime logs
```

---

## Error Quick Reference

| Error | Likely Cause | Quick Fix |
|-------|--------------|-----------|
| `400 Expected thinking, but found tool_use` | Antigravity thinking+tools conflict | Start fresh conversation |
| `400 Unknown name "$ref"` | Schema validation | Auto-sanitized, check translator |
| `401 Unauthorized` | Token expired | Re-run OAuth login |
| `403 SUBSCRIPTION_REQUIRED` | Wrong project fallback | Pin `base_url` in auth JSON |
| `429 RESOURCE_EXHAUSTED` | Rate limit | Wait for `Retry-After` |
| `429 model_cooldown` | All accounts cooling | Add more accounts or wait |

---

## Adding New Agents

To add a new CLIPROXY-specific agent:

1. Create spec in `.claude/agents/<name>.md`
2. Add route in main `CLAUDE.md` router
3. Update this file (`CLIPROXY/agents.md`)
4. Test with trigger keywords

---

## Related Documentation

| File | Content |
|------|---------|
| `CLIPROXY/CLAUDE.md` | Context file for CLIPROXY work |
| `CLIPROXY/CLIProxyAPI/README.md` | Project overview |
| `CLIPROXY/CLIProxyAPI/docs/troubleshooting-antigravity.md` | Antigravity issues |
| `CLIPROXY/CLIProxyAPI/docs/amp-cli-integration.md` | Amp CLI setup |
