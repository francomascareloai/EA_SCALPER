# CRITIC Adversarial Audit: cliproxy-engineer.md

**Agent**: CRITIC (Adversarial Review)
**Target**: `.claude/agents/cliproxy-engineer.md`
**Date**: 2025-12-16
**Status**: COMPLETE
**CLAUDE_MD_VERSION**: 3.10.9

---

## Executive Summary

The CLIPROXY-ENGINEER v1.0 specification is a solid foundation for proxy infrastructure management. It provides clear error patterns, practical debugging protocols, and organized structure. However, it **assumes happy-path scenarios** and lacks defensive measures for failure recovery, trading system coordination, and operational resilience.

**Severity Counts**:
| Severity | Count |
|----------|-------|
| CRITICAL | 3 |
| HIGH | 7 |
| MEDIUM | 6 |
| LOW | 3 |
| **TOTAL** | **19** |

---

## Technique 1: INVERSION (What Would Make This Agent Fail?)

### Failure Modes Identified

1. **Missing dependency handling** - No guidance when Go is not installed or wrong version
2. **CLIPROXY/ directory doesn't exist** - No handling for missing/misconfigured paths
3. **logs/server.out doesn't exist** - First run scenario not addressed
4. **Hung proxy server** - No timeout handling
5. **No rollback procedure** - If fix breaks proxy, no documented recovery
6. **Concurrent access issues** - Multiple users/processes not addressed
7. **Restart doesn't verify success** - Uses nohup but never confirms server started
8. **Port 8317 in use** - No detection or resolution
9. **Config path assumptions** - Hardcoded to ~/.cliproxy/config.yaml
10. **OAuth login commands incomplete** - Per-provider commands not fully specified
11. **Corrupted token files** - No handling guidance
12. **SSL/TLS certificate issues** - Not addressed
13. **Validation criteria vague** - "valid response" not defined
14. **No health check endpoint** - Monitoring not mentioned

---

## Technique 2: PRE-MORTEM (6 Months Later, What Went Wrong?)

### Scenario 1: "Agent Kept Breaking Things"
- No code review gate before pushing Go changes
- No mandatory test requirements before deploying fixes
- Self-review checklist is optional, not mandatory verification

### Scenario 2: "Agent Caused Production Outage"
- Force restart (`pkill -9`) doesn't drain connections gracefully
- **No guidance on checking if trading is active before restart**
- No coordination with trading system (Apex time gates: 4:30 PM block, 4:55 PM force-close)
- Restart during market hours could break emergency close

### Scenario 3: "Agent Introduced Security Vulnerabilities"
- OAuth token handling mentioned but no security best practices
- Token files in `~/.cli-proxy-api/` - no permission guidance (should be 600)
- No mention of avoiding logging sensitive credentials

### Scenario 4: "Agent Couldn't Diagnose Complex Issues"
- Limited error patterns (only 400/401/403/429)
- **No guidance on 502/503/504 gateway errors**
- No network debugging tools mentioned (tcpdump, wireshark, netstat)
- No guidance on upstream API health checks

---

## Technique 3: STRESS TEST (Extreme Conditions)

### 1. High Load Scenario
- No guidance on connection pooling or max connections
- No rate limiting configuration mentioned
- No guidance when ALL accounts hit 429 simultaneously

### 2. Multiple Concurrent OAuth Refreshes
- Race condition potential - no mention of token locking
- Multiple processes trying to refresh same token

### 3. Disk Full Scenario
- **logs/server.out grows unbounded** - no log rotation
- Token files could fail to write

### 4. Network Partition
- Proxy can't reach upstream APIs
- No circuit breaker pattern guidance
- No fallback behavior specified

### 5. Config Corruption
- Malformed YAML handling not addressed
- No config validation before restart

### 6. Memory Leak
- No monitoring guidance for long-running server
- No memory limits mentioned
- No restart-on-OOM guidance

---

## Technique 4: EDGE CASES (Boundary Conditions)

### First-Time Setup
- No `~/.cli-proxy-api/` directory
- No `config.yaml` exists
- No tokens exist
- Go not installed
- CLIPROXY submodule not initialized

### Version Mismatches
- Go 1.24+ mentioned but what if 1.23 installed?
- No dependency version checking (go.mod)
- Gin framework version compatibility

### Multi-Platform
- Spec assumes Linux (`pgrep`, `nohup`)
- macOS (Darwin) differences not addressed
- WSL-specific issues not covered

### Partial States
- Server started but not healthy
- Token refreshed but not persisted
- Config changed but server not restarted
- Go code compiled but old binary running

### Permission Issues
- Can't write to `~/.cli-proxy-api/`
- Can't bind to port 8317 (permission denied or in use)
- Can't read config file

---

## Technique 5: ASSUMPTION AUDIT

### Explicit Assumptions (Documented)
1. Go 1.24+ is installed and working
2. `CLIPROXY/CLIProxyAPI/` exists and is valid Go project
3. Server runs on port 8317
4. Config at `~/.cliproxy/config.yaml`
5. Tokens at `~/.cli-proxy-api/`

### Implicit Assumptions (DANGEROUS)
1. User has write access to home directory
2. Network is available for OAuth flows
3. Upstream APIs (Claude/Gemini/OpenAI) are available
4. Only one instance of proxy runs at a time
5. Binary name is "cli-proxy-api"
6. Gin framework is already installed
7. Server logs to stdout/stderr (captured by nohup)
8. User knows Go syntax for code changes
9. User has permissions to kill processes
10. System time is synchronized (for token expiry checks)

### Unchallenged Assumptions
- Why port 8317? What if it conflicts?
- Why single config file? Environment overrides?
- Why file-based token storage? Security implications?

---

## APEX TRAP Analysis (Trading System Impact)

### The Risk
The proxy is infrastructure for Claude Code / AI tools. If proxy fails during trading:

1. **Claude Code can't communicate with models** - Any AI-assisted trading decisions fail
2. **Risk management AI queries could fail** - SENTINEL can't get AI guidance
3. **Emergency close could fail** - If AI needed for position management

### Missing Safeguards
- **No coordination with trading time gates**
  - Apex requires no overnight positions (4:59 PM ET close)
  - Proxy restart at 4:58 PM could break emergency close
  - No mention of "safe restart windows"

- **Force restart during active request**
  - In-flight API calls would fail
  - Could interrupt trading decision mid-stream

### Recommendation
Add "TRADING-SAFE RESTART PROTOCOL":
```markdown
## TRADING-SAFE RESTART PROTOCOL

Before restarting during market hours (9:30 AM - 4:59 PM ET):
1. Check if trading system is active: `pgrep -af nautilus`
2. If active, coordinate with SENTINEL or wait for safe window
3. Never force restart within 30 minutes of market close (4:29 PM+)
4. Use graceful restart (SIGTERM) with 30s timeout before SIGKILL
5. Verify no in-flight requests before shutdown
```

---

## Structural Gaps

### Missing vs Other Agent Specs

| Section | Present? | Impact |
|---------|----------|--------|
| OUTPUT_PROTOCOL | No | No standardized response format |
| CRITIC_GATE integration | No | No self-review mandate |
| HANDOFF_FORMAT | No | Escalations lack structure |
| DECISION_FRAMEWORK | No | When to fix vs escalate unclear |
| SAMPLE_OUTPUTS | No | Expected report format unknown |
| TIMEOUT/ABORT criteria | No | Could debug forever |
| SUCCESS_METRICS | No | Definition of "done" vague |
| PREREQUISITES | No | Setup requirements undocumented |
| ROLLBACK_PROTOCOL | No | No recovery from bad changes |

### Integration Issues
1. Escalation table mentions FORGE/SENTINEL but no structured handoff format
2. No mention of CLAUDE.md context_budget_protocol
3. Should integrate with orchestration_output_protocol for heavy debugging

---

## Findings Summary (Prioritized)

### CRITICAL (3)

| ID | Finding | Risk | Recommendation |
|----|---------|------|----------------|
| C1 | No trading-safe restart protocol | Proxy restart during market hours could break AI-assisted trading or emergency close | Add TRADING-SAFE RESTART section with market hours awareness and SENTINEL coordination |
| C2 | No rollback procedure | Bad Go fix breaks proxy with no recovery path | Add ROLLBACK_PROTOCOL with git revert, binary backup, and config restore steps |
| C3 | No post-restart verification | nohup starts server but doesn't confirm it's healthy | Add health check: `curl -sf http://localhost:8317/v1/models || echo "FAILED"` after restart |

### HIGH (7)

| ID | Finding | Risk | Recommendation |
|----|---------|------|----------------|
| H1 | Missing prerequisites section | Agent can't operate if Go/deps missing | Add PREREQUISITES section with version checks and installation guidance |
| H2 | No port conflict resolution | Port 8317 in use = startup fails | Add port conflict detection: `lsof -i :8317` and resolution options |
| H3 | No log rotation | logs/server.out fills disk | Add logrotate config or built-in rotation guidance |
| H4 | No security best practices | Token files could be exposed | Add chmod 600 for tokens, avoid logging credentials |
| H5 | No upstream failure handling | All APIs down = no guidance | Add circuit breaker pattern, fallback behavior |
| H6 | Missing 502/503/504 handling | Gateway errors undocumented | Add error patterns for gateway timeouts |
| H7 | No first-time setup guide | Agent assumes everything configured | Add SETUP section for clean environment |

### MEDIUM (6)

| ID | Finding | Risk | Recommendation |
|----|---------|------|----------------|
| M1 | Linux-only commands | macOS/WSL users confused | Add platform-specific notes |
| M2 | No health check endpoint | Can't monitor proxy health | Document `/health` or `/v1/models` as health check |
| M3 | No resource monitoring | Memory leaks undetected | Add `top`/`htop` monitoring guidance |
| M4 | Token refresh race conditions | Concurrent refresh could corrupt | Mention file locking or sequential refresh |
| M5 | Incomplete OAuth examples | Users don't know exact commands | Add full `--claude-login`, `--gemini-login`, etc. |
| M6 | No config validation | Bad YAML crashes server | Add YAML validation before restart |

### LOW (3)

| ID | Finding | Risk | Recommendation |
|----|---------|------|----------------|
| L1 | No network debugging tools | Complex network issues hard to diagnose | Add tcpdump, netstat examples |
| L2 | No version mismatch detection | Wrong Go version causes subtle bugs | Add `go version` check in prerequisites |
| L3 | Limited example patterns | Agent may not recognize rare errors | Expand error pattern library over time |

---

## Recommended v1.1 Changes

### 1. Add PREREQUISITES Section
```markdown
## PREREQUISITES

Before operating, verify:
1. Go version: `go version` (must be 1.24+)
2. CLIPROXY submodule: `ls CLIPROXY/CLIProxyAPI/go.mod`
3. Dependencies: `cd CLIPROXY/CLIProxyAPI && go mod download`
4. Config exists: `test -f ~/.cliproxy/config.yaml && echo OK`
5. Port available: `! lsof -i :8317 && echo "Port free"`

If any fail, see FIRST-TIME SETUP section.
```

### 2. Add TRADING-SAFE RESTART Section
```markdown
## TRADING-SAFE RESTART PROTOCOL

Market hours: 9:30 AM - 4:59 PM ET

### During Market Hours
1. Check trading activity: `pgrep -af nautilus`
2. If trading active → coordinate with SENTINEL before restart
3. Never restart within 30min of close (after 4:29 PM ET)
4. Use graceful shutdown with verification

### Safe Restart
```bash
# Graceful with health check
kill $(pgrep -f cli-proxy-api)
sleep 5
cd CLIPROXY/CLIProxyAPI
nohup ./cli-proxy-api -config ~/.cliproxy/config.yaml > logs/server.out 2>&1 &
sleep 3
curl -sf http://localhost:8317/v1/models && echo "HEALTHY" || echo "FAILED"
```
```

### 3. Add ROLLBACK Protocol
```markdown
## ROLLBACK PROTOCOL

If fix breaks proxy:
1. Revert code: `cd CLIPROXY/CLIProxyAPI && git checkout HEAD~1 -- .`
2. Rebuild: `go build ./cmd/server/`
3. Restart: Use restart protocol above
4. Verify: `curl http://localhost:8317/v1/models`
5. Report: Document what failed and why
```

### 4. Add OUTPUT Protocol
```markdown
## OUTPUT FORMAT

All responses must include:

### CLIPROXY-ENGINEER Report
- **Status**: RESOLVED / PARTIAL / ESCALATED
- **Issue**: [brief description]
- **Root Cause**: [what was wrong]
- **Fix Applied**: [what changed]
- **Validation**: [how verified]
- **Risks**: [any remaining concerns]
- **Files Modified**: [list]
```

### 5. Add CRITIC_GATE Integration
```markdown
## SELF-REVIEW (MANDATORY)

Before reporting done, apply adversarial review:
1. What could still be broken?
2. Did I verify server health, not just "no errors"?
3. Is this change reversible?
4. Did I check trading system impact?
5. Are there race conditions in my fix?
```

---

## Conclusion

The CLIPROXY-ENGINEER v1.0 spec is a competent first version with good structure and practical guidance for common scenarios. However, it lacks the defensive measures required for production infrastructure supporting a trading system:

1. **No failure recovery** - Breaks with no rollback
2. **No trading awareness** - Could disrupt live trading
3. **No operational resilience** - Logs fill disk, no monitoring

**Recommendation**: Update to v1.1 with the five additions above. Priority order:
1. TRADING-SAFE RESTART (CRITICAL - trading system impact)
2. ROLLBACK PROTOCOL (CRITICAL - recovery capability)
3. PREREQUISITES + FIRST-TIME SETUP (HIGH - operational readiness)
4. OUTPUT FORMAT + CRITIC_GATE (MEDIUM - quality assurance)

---

## Appendix: CRITIC Techniques Applied

| Technique | Focus | Findings |
|-----------|-------|----------|
| INVERSION | What makes it fail? | 14 failure modes |
| PRE-MORTEM | Future disaster scenarios | 4 scenarios |
| STRESS TEST | Extreme conditions | 6 stress scenarios |
| EDGE CASES | Boundary conditions | 5 edge case categories |
| ASSUMPTION AUDIT | Hidden assumptions | 10 implicit, 3 unchallenged |
| APEX TRAP | Trading system impact | 3 risks identified |

---

*Generated by CRITIC adversarial audit process*
*CLAUDE.md version: 3.10.9*
