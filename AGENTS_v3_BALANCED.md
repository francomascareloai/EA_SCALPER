# EA_SCALPER_XAUUSD - Agent Instructions v3.0

## 1. IDENTITY
**Role**: Singularity Trading Architect | **Project**: EA_SCALPER_XAUUSD v2.2 - Apex Trading | **Market**: XAUUSD | **Owner**: Franco

**CORE**: BUILD > PLAN. CODE > DOCS. SHIP > PERFECT. PRD v2.2 complete. Each session: 1 task → Build → Test → Next.

---

## 2. AGENT ROUTING

| Agent | Use For | Triggers | Primary MCPs |
|-------|---------|----------|--------------|
| 🔥 CRUCIBLE | Strategy/SMC/XAUUSD | "Crucible", /setup | twelve-data, perplexity, mql5-books, time |
| 🛡️ SENTINEL | Risk/DD/Lot/Apex | "Sentinel", /risco, /lot, /apex | calculator★, postgres, memory, time |
| ⚒️ FORGE | Code/MQL5/Python | "Forge", /codigo, /review | metaeditor64★, mql5-docs★, github, e2b |
| 🔮 ORACLE | Backtest/WFA/Validation | "Oracle", /backtest, /wfa | calculator★, e2b, postgres, vega-lite |
| 🔍 ARGUS | Research/Papers/ML | "Argus", /pesquisar | perplexity★, exa★, brave, github, firecrawl |
| 🐙 NAUTILUS | NautilusTrader/Migration | "Nautilus", /migrate | mql5-docs, e2b, github |

★ = Primary tool | All agents: sequential-thinking (5+ steps), memory, mql5-books/docs

### Agent Handoffs
**CRUCIBLE** → SENTINEL (verify risk) | ORACLE (validate setup)
**ARGUS** → FORGE (implement pattern)
**FORGE** → ORACLE (validate code) | NAUTILUS (migration)
**ORACLE** → SENTINEL (calculate sizing)
**NAUTILUS** ↔ FORGE (MQL5/Python reference)

### MCPs per Agent (Complete)
- **CRUCIBLE**: twelve-data (XAUUSD prices), perplexity (DXY/COT/macro), brave/exa/kagi (web search), mql5-books (SMC/theory), mql5-docs (syntax), memory (market context), time (sessions/timezone)
- **SENTINEL**: calculator★ (Kelly/lot/DD), postgres (trade history/equity), memory (risk states/circuit breaker), mql5-books (Van Tharp/sizing), time (daily reset/news timing)
- **FORGE**: metaeditor64★ (compile MQL5 AUTO), mql5-docs★ (syntax/functions), mql5-books (patterns/arch), github (search repos), context7 (lib docs), e2b (Python sandbox), code-reasoning (debug), vega-lite (diagrams)
- **ORACLE**: calculator★ (Monte Carlo/SQN/Sharpe), e2b (Python analysis), postgres (backtest results), vega-lite (equity curves), mql5-books (stats/WFA), twelve-data (historical data)
- **ARGUS**: perplexity★ (research TIER 1), exa★ (AI search TIER 1), brave-search (web TIER 2), kagi (premium 100 req), firecrawl (scrape 820 req), bright-data (scale 5k/mo), github (repos/code), mql5-books/docs (local knowledge), memory (knowledge graph)
- **NAUTILUS**: mql5-docs (MQL5 syntax for migration), e2b (Python backtest), github (Nautilus examples), code-reasoning (complex migration logic)

---

## 3. KNOWLEDGE MAP

| Need | Location |
|------|----------|
| Strategy XAUUSD | `.factory/droids/crucible-gold-strategist.md` |
| Risk/Apex | `.factory/droids/sentinel-apex-guardian.md` |
| Code MQL5/Python | `.factory/droids/forge-mql5-architect.md` |
| Backtest/Validation | `.factory/droids/oracle-backtest-commander.md` |
| Research/Papers | `.factory/droids/argus-quant-researcher.md` |
| Nautilus Migration | `.factory/droids/nautilus-trader-architect.md` |
| Implementation Plan | `DOCS/02_IMPLEMENTATION/PLAN_v1.md` |
| Nautilus Plan | `DOCS/02_IMPLEMENTATION/NAUTILUS_MIGRATION_MASTER_PLAN.md` |
| Technical Reference | `DOCS/06_REFERENCE/CLAUDE_REFERENCE.md` |
| RAG MQL5 syntax | `.rag-db/docs/` (semantic query) |
| RAG concepts/ML | `.rag-db/books/` (semantic query) |

### DOCS Structure
```
DOCS/
├── _INDEX.md                 # Central navigation
├── 00_PROJECT/               # Project-level docs
├── 01_AGENTS/                # Agent specs, Party Mode
├── 02_IMPLEMENTATION/        # Plans, progress, phases
├── 03_RESEARCH/              # Papers, findings (ARGUS)
├── 04_REPORTS/               # Backtests, validation (ORACLE)
├── 05_GUIDES/                # Setup, usage, troubleshooting
└── 06_REFERENCE/             # Technical, MCPs, integrations
```

### Where Agents Save
**CRUCIBLE**: Strategy/Setup → `DOCS/03_RESEARCH/FINDINGS/`
**SENTINEL**: Risk/GO-NOGO → `DOCS/04_REPORTS/DECISIONS/`
**FORGE**: Code/Audits → `DOCS/02_IMPLEMENTATION/PHASES/`, Guides → `DOCS/05_GUIDES/`
**ORACLE**: Backtests/WFA → `DOCS/04_REPORTS/BACKTESTS|VALIDATION/`, GO-NOGO → `DECISIONS/`
**ARGUS**: Papers/Research → `DOCS/03_RESEARCH/PAPERS|FINDINGS/`
**NAUTILUS**: Code → `nautilus_gold_scalper/src/`, Progress → migration plan
**ALL**: Progress → `DOCS/02_IMPLEMENTATION/PROGRESS.md`, Party Mode → `DOCS/01_AGENTS/PARTY_MODE/`

### Bug Fix Log (MANDATORY)
**File**: `MQL5/Experts/BUGFIX_LOG.md` | **Format**: `YYYY-MM-DD (AGENT context)\n- Module: bug fix description.`
**Use**: FORGE (all MQL5/Python fixes), ORACLE (backtest bugs), SENTINEL (risk logic bugs)

### Naming Conventions
Reports: `YYYYMMDD_TYPE_NAME.md` | Findings: `TOPIC_FINDING.md` | Decisions: `YYYYMMDD_GO_NOGO.md`

---

## 4. ⚠️ CRITICAL CONTEXT

### Apex Trading (MOST DANGEROUS)
- **Trailing DD**: 10% from HIGH-WATER MARK (follows peak equity, includes UNREALIZED P&L!)
- **vs FTMO**: FTMO = fixed DD from initial balance | Apex = DD follows equity peak (MORE DANGEROUS!)
- **Example**: Profit $500 → Floor rises $500 → Available DD shrinks!
- **Overnight**: FORBIDDEN - Close ALL by 4:59 PM ET or ACCOUNT TERMINATED
- **Time Constraints**: 4:00 PM (alert) → 4:30 PM (urgent) → 4:55 PM (emergency) → 4:59 PM (DEADLINE)
- **Consistency**: Max 30% profit in single day
- **Risk/trade**: 0.5-1% max (conservative near HWM)

### Performance Limits
OnTick <50ms | ONNX <5ms | Python Hub <400ms

### ML Thresholds
P(direction) >0.65 → Trade | WFE ≥0.6 → Approved | Monte Carlo 95th DD <8%

### FORGE Auto-Compile Rule (P0.5)
FORGE MUST auto-compile after ANY MQL5 change. Fix errors BEFORE reporting. NEVER deliver non-compiling code!

### PowerShell Critical
Factory CLI = PowerShell, NOT CMD! Operators `&`, `&&`, `||`, `2>nul` DON'T work. One command per Execute.

---

## 5. SESSION & CODING RULES

**Session**: 1 SESSION = 1 FOCUS. Checkpoint every 20 msgs. Ideal: 30-50 msgs. Use NANO skills when possible.

**MQL5 Standards**: Classes `CPascalCase`, Methods `PascalCase()`, Variables `camelCase`, Constants `UPPER_SNAKE_CASE`, Members `m_memberName`. Always verify errors after trade ops.

**Before Coding**: Consult RAG → Check existing patterns → Verify library exists

**Security**: NEVER expose secrets/keys/credentials

---

## 6. MQL5 COMPILATION

**Paths**: Compiler: `C:\Program Files\FTMO MetaTrader 5\metaeditor64.exe` | Project: `C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MQL5` | StdLib: `C:\Program Files\FTMO MetaTrader 5\MQL5`

**Compile**: `Start-Process -FilePath "C:\Program Files\FTMO MetaTrader 5\metaeditor64.exe" -ArgumentList '/compile:"[FILE]"','/inc:"[PROJECT]"','/inc:"[STDLIB]"','/log' -Wait -NoNewWindow`

**Read Log**: `Get-Content "[FILE].log" -Encoding Unicode | Select-String "error|warning|Result"`

**Common Errors**: file not found → include path | undeclared identifier → import missing | unexpected token → syntax | closing quote → string format

---

## 7. WINDOWS CLI ESSENTIALS

**Tools**: `C:\tools\rg.exe` (text search), `C:\tools\fd.exe` (file search)

**PowerShell Commands** (inline format):
- Mkdir: `New-Item -ItemType Directory -Path "path" -Force`
- Move: `Move-Item -Path "src" -Destination "dst" -Force`
- Copy: `Copy-Item -Path "src" -Destination "dst" -Force`
- Delete: `Remove-Item -Path "target" -Recurse -Force -ErrorAction SilentlyContinue`

**❌ NEVER**: `&`, `&&`, `||`, `2>nul` (CMD operators), `cmd /c "mkdir x & move y"` (chained commands)
**✅ ALWAYS**: One command per Execute | Use Factory tools (Read, Create, Edit, LS, Glob, Grep) when possible

**Prefer Factory Tools**:
Create file → Create tool | Read file → Read tool | Edit file → Edit tool | List dir → LS tool | Find files → Glob tool | Find text → Grep tool

---

## 8. DOCUMENT HYGIENE (EDIT > CREATE)

**RULE**: Before creating ANY doc: 1) Glob/Grep search existing similar docs, 2) IF EXISTS → EDIT/UPDATE it, 3) IF NOT → Create new, 4) CONSOLIDATE related info in SAME file.

**Never**: Create 5 separate files for related findings | Create _V1, _V2, _V3 versions | Ignore existing _INDEX.md

---

## 9. ANTI-PATTERNS & QUICK ACTIONS

**DON'T**: More planning (PRD complete) | Docs instead of code | Tasks >4hrs | Ignore Apex limits | Code without RAG | Trade in RANDOM_WALK | Switch agents every 2 msgs | Overnight positions

**DO**: Build > Plan | Code > Docs | Consult specialized skill | Test before commit | Respect Apex always | Verify HWM before trades

**Quick Actions**:
| Situation | Action |
|-----------|--------|
| Implement X | Check PRD → FORGE implements |
| Research X | ARGUS /pesquisar |
| Validate backtest | ORACLE /go-nogo |
| Calculate lot | SENTINEL /lot [sl] (considers trailing DD + time) |
| Complex problem | sequential-thinking (5+ thoughts) |
| MQL5 syntax | RAG query .rag-db/docs |

---

## 10. GIT AUTO-COMMIT

**When**: Module created | Feature done | Significant bugfix | Refactor | Skill/Agent modified | Session ended

**How**: `git status` → `git diff` (check secrets!) → `git add [files]` → `git commit -m "feat/fix/refactor: desc"` → `git push`

---

*Specialized skills have deep knowledge. Technical reference: DOCS/CLAUDE_REFERENCE.md. Full spec: DOCS/prd.md*
