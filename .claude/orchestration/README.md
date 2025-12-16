# Orchestration Output Protocol

This folder stores persistent outputs from multi-agent orchestration sessions.

## Purpose

When spawning multiple sub-agents (≥3), their outputs can flood the context window. If context overflows, summarization loses critical details. This protocol persists outputs to files.

## Structure

```
.claude/orchestration/
├── sessions/
│   └── YYYY-MM-DD_HH-MM/
│       ├── MANIFEST.md        # Index of all outputs
│       ├── CRITIC_output.md   # Full CRITIC analysis
│       ├── ORACLE_output.md   # Full ORACLE analysis
│       └── ...
└── archive/                   # Sessions older than 7 days
```

## How It Works

1. **Before spawning**: Orchestrator creates session folder
2. **Sub-agents**: Write complete output to file, return only summary to chat
3. **After completion**: Orchestrator creates MANIFEST.md with index
4. **If context overflows**: Orchestrator reads MANIFEST to recover

## MANIFEST Format

```markdown
# Orchestration Session: 2025-12-15 14:30:00

## Objective
[What was being analyzed]

## Agents
| Agent | Status | Output | Key Findings |
|-------|--------|--------|--------------|
| CRITIC | ✅ | CRITIC_output.md | 3 CRITICAL, 5 HIGH |
| ORACLE | ✅ | ORACLE_output.md | WFE threshold fixed |

## Synthesis
[Brief summary of combined findings]

## Next Steps
[Actions to take]
```

## Cleanup Policy

- Sessions older than 7 days may be moved to `archive/`
- Archive can be cleaned periodically

## Reference

See `CLAUDE.md` section `<orchestration_output_protocol>` for full specification.
