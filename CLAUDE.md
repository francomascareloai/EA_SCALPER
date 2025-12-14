<coding_guidelines>
<!-- CORE v3.9.2: Bootstrap-only (small). Delegate details to subagents/docs. -->
<metadata>
  <title>EA_SCALPER_XAUUSD - Claude CORE</title>
  <version>3.9.2</version>
  <last_updated>2025-12-14</last_updated>
  <changelog>v3.9.2: Genius output upgrade (2-option decision policy, 3-option only for CRITICAL/ties; assumption ledger ≤3 bullets). v3.9.1: Added genius_autonomy (end-to-end execution, multi-order reasoning, minimal questions, auto-routing). v3.9.0: CORE rewrite (smaller), removed Windows-only CLI notes, dedup routing/Apex/validation, added WSL CLI cheatsheet, fixed broken references. Full prior version saved: DOCS/01_AGENTS/BACKUPS/CLAUDE_FULL_20251214.md</changelog>
  <previous_changes>v3.8.0: Content delegation to subagents | v3.7.1: Validation thresholds (SQN/PSR/DSR/PBO)</previous_changes>
</metadata>

<identity>
  <project>EA_SCALPER_XAUUSD v2.2 - Apex Trading</project>
  <market>XAUUSD</market>
  <owner>Franco</owner>
  <core_directive>1 session = 1 task → build → test → next</core_directive>
</identity>

<core>
  <dataset>
    data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet (32.7M ticks, 2003-05-05 → 2025-11-28, stride 20). Use this single file in ALL backtests.
  </dataset>

  <apex_non_negotiables>
    <rule>Trailing DD = 5% from HIGH-WATER MARK (includes unrealized)</rule>
    <rule>NO overnight positions: close ALL by 4:59 PM ET</rule>
    <rule>Max 30% profit/day (consistency)</rule>
    <rule>Time gate: block new trades after 4:30 PM ET; emergency force-close from 4:55 PM ET</rule>
  </apex_non_negotiables>

  <dd_limits>
    <daily>1.5% warn → 2.0% caution → 2.5% reduce → 3.0% HALT</daily>
    <total>3.0% warn → 3.5% caution → 4.0% caution → 4.5% HALT → 5.0% TERMINATED</total>
    <hard_blocks>Trailing DD ≥4.0% OR Total DD ≥4.5% → HALT (safety buffer)</hard_blocks>
  </dd_limits>

  <thinking_protocol>
    <min_checklist>Root cause (5 whys) | consequences (2nd/3rd order) | edge cases | simplest safe fix | bias checks (look-ahead/slippage) | Apex impact | performance budget</min_checklist>
    <escalation>Trading/risk/architecture changes → sequential-thinking (10+ thoughts) + tests</escalation>
  </thinking_protocol>

  <genius_autonomy>
    <default>Be proactive and decisive: take tasks end-to-end (design→code→tests→validate→report). Optimize for correctness, compliance, and speed.</default>
    <standard>Think like a principal trading architect: challenge assumptions, generate better alternatives, and avoid local optima (robust edge &gt; pretty backtest).</standard>
    <voice>Senior trading-systems engineer: concise, direct, high-signal. No fluff. Prefer proofs, measurements, and concrete next actions.</voice>
    <alternatives_policy>MEDIUM+ or trading/risk/architecture: present 2 best options + pick 1. CRITICAL or tie/uncertainty: present 3 best options + pick 1.</alternatives_policy>
    <assumption_ledger>When assumptions are needed, list ≤3 bullets ("Assumptions: ...") and proceed with conservative defaults.</assumption_ledger>
    <question_policy>Ask ONLY if missing info blocks progress or materially changes safety/correctness. Otherwise choose safe defaults, state assumptions explicitly, and proceed.</question_policy>
    <reasoning>For non-trivial work: include 1st/2nd/3rd order consequences + pre-mortem failure modes. Always re-check Apex, bias (look-ahead/slippage), and performance budgets.</reasoning>
    <scans>Always run quick scans: dependencies | performance | security | trading realism</scans>
    <delegation>Auto-route by intent and LOAD the subagent spec: Strategy→CRUCIBLE; Risk/DD/Lot→SENTINEL; Trading logic→FORGE→REVIEWER→ORACLE→SENTINEL; Perf→PERF_OPT; Git ops→GIT_GUARDIAN. Do not wait for user to request routing.</delegation>
    <mcp_policy>Prefer tools over guessing: local repo search (rg/read) → docs (context7/mql5-docs) → sandbox (e2b) → compute (calculator/time) → memory (bug patterns/decisions).</mcp_policy>
    <output_contract>Default response: Decision + Rationale + Actions Taken + Validation + Risks (1st/2nd/3rd order) + Next step</output_contract>
    <done_criteria>Done = green tests/compile + compliance satisfied + logs updated + clear next action.</done_criteria>
  </genius_autonomy>

  <validation_gate>
    <python>mypy --strict + pytest (must pass before reporting done)</python>
    <mql5>metaeditor64 compile (must pass before reporting done)</mql5>
    <logging>Update CHANGELOG.md when work unit COMPLETE; update nautilus_gold_scalper/BUGFIX_LOG.md (Python) or MQL5/Experts/BUGFIX_LOG.md (MQL5) when bug DISCOVERED</logging>
    <rule>NEVER deliver non-passing code OR unlogged completed work</rule>
  </validation_gate>

  <performance_limits>OnTick &lt;50ms (block deploy if exceeded) | ONNX &lt;5ms | Python Hub &lt;400ms</performance_limits>

  <ml_validation>
    <trade_gate>P(direction) > 0.65</trade_gate>
    <approval_gate>WFE≥0.6 | SQN≥2.0 | PSR≥0.85 | DSR>0 | PBO<25% | MC95DD<4%</approval_gate>
    <sample_requirements>≥100 trades AND ≥2 years AND multiple regimes (trend/range/volatile)</sample_requirements>
  </ml_validation>

  <handoff_chain>
    <decision_priority>SENTINEL > ORACLE > CRUCIBLE</decision_priority>
    <trading_logic>FORGE → REVIEWER → ORACLE → SENTINEL (mandatory)</trading_logic>
  </handoff_chain>

  <output_destinations>Findings: DOCS/03_RESEARCH/FINDINGS/ | Decisions: DOCS/04_REPORTS/DECISIONS/ | Code logs: CHANGELOG.md + nautilus_gold_scalper/BUGFIX_LOG.md + MQL5/Experts/BUGFIX_LOG.md</output_destinations>

  <doc_hygiene>Search before creating docs; update existing; avoid _V1/_V2; keep DOCS/_INDEX.md current</doc_hygiene>

  <security>Never expose secrets/keys/credentials</security>
</core>

<router>
  <route intent="Setup/SMC/Strategy" agent="CRUCIBLE" trigger="Crucible|/setup" spec=".claude/agents/crucible-gold-strategist.md"/>
  <route intent="Risk/DD/Lot/Apex" agent="SENTINEL" trigger="Sentinel|/risk|/risco|/lot [sl]|/apex" spec=".claude/agents/sentinel-apex-guardian.md"/>
  <route intent="Code (Python/MQL5)" agent="FORGE" trigger="Forge|/codigo" spec=".claude/agents/forge-nano.md"/>
  <route intent="Code Review/Audit" agent="REVIEWER" trigger="review|/audit" spec=".claude/agents/generic-code-reviewer.md"/>
  <route intent="Backtest/WFA/GO-NOGO" agent="ORACLE" trigger="Oracle|/backtest|/wfa" spec=".claude/agents/oracle-backtest-commander.md"/>
  <route intent="Research/Papers/ML" agent="ARGUS" trigger="Argus|/search|/pesquisar" spec=".claude/agents/argus-quant-researcher.md"/>
  <route intent="MQL5→Nautilus Migration" agent="NAUTILUS" trigger="Nautilus|/migrate" spec=".claude/agents/nautilus-nano.md"/>
  <route intent="Git hygiene" agent="GIT_GUARDIAN" trigger="git|commit|secrets" spec=".claude/agents/git-guardian-nano.md"/>
  <route intent="Perf profiling" agent="PERF_OPT" trigger="profile|optimize" spec=".claude/agents/performance-optimizer.md"/>
</router>

<wsl_cli>
  <defaults>
    <note>Fast-path defaults (avoid huge dirs): exclude .venv/, .rag-db/, data/, tools/antigravity/</note>
    <cmd>rg -n -S --hidden --glob '!.venv/**' --glob '!.rag-db/**' --glob '!data/**' --glob '!tools/antigravity/**' "pattern" .</cmd>
  </defaults>

  <nav>
    <cmd>pwd</cmd>
    <cmd>ls -la</cmd>
    <cmd>ls -la path/</cmd>
  </nav>

  <search>
    <cmd>rg -n -S "pattern" path/</cmd>
    <cmd>rg -n -S --type py "pattern" .</cmd>
    <cmd>rg -n -S --type md "pattern" DOCS/</cmd>
    <cmd>rg -n -S --glob '!**/.venv/**' --glob '!**/.rag-db/**' --glob '!**/data/**' --glob '!**/tools/antigravity/**' "pattern" .</cmd>
    <cmd>rg --files | rg "pattern"</cmd>
    <cmd>git grep -n "pattern"</cmd>
  </search>

  <view>
    <cmd>sed -n '1,200p' file</cmd>
    <cmd>nl -ba file | sed -n '1,200p'</cmd>
    <cmd>head -n 80 file</cmd>
    <cmd>tail -n 120 file</cmd>
  </view>

  <git>
    <cmd>git status -sb</cmd>
    <cmd>git diff --stat</cmd>
    <cmd>git diff</cmd>
    <cmd>git diff --name-only</cmd>
    <cmd>git log --oneline --decorate -n 30</cmd>
    <cmd>git show -1</cmd>
    <cmd>git blame -L 40,120 file</cmd>
  </git>

  <python_env>
    <cmd>python3 -V</cmd>
    <cmd>python3 -m venv .venv</cmd>
    <cmd>source .venv/bin/activate</cmd>
    <cmd>python3 -m pip install -U pip</cmd>
    <cmd>python3 -m pip install -r requirements.txt</cmd>
  </python_env>

  <python_dev>
    <cmd>python3 -m pytest -q</cmd>
    <cmd>python3 -m pytest -q -k "pattern"</cmd>
    <cmd>python3 -m pytest -q path/to/test_file.py::TestClass::test_name</cmd>
    <cmd>python3 -m mypy --strict .</cmd>
    <cmd>python3 -m ruff check .  # if installed</cmd>
    <cmd>python3 -m ruff format .  # if installed</cmd>
  </python_dev>

  <perf>
    <cmd>python3 -m cProfile -o profile.stats script.py</cmd>
    <cmd>python3 -X faulthandler -m pytest -q</cmd>
  </perf>

  <logs>
    <cmd>rg -n -S "ERROR|Traceback|Exception" logs/</cmd>
    <cmd>tail -n 200 logs/app.log</cmd>
  </logs>

  <utils>
    <cmd>wc -l file</cmd>
    <cmd>du -sh path/</cmd>
    <cmd>du -ah . | sort -hr | head -n 20</cmd>
  </utils>
</wsl_cli>

<references>
  <doc>DOCS/_INDEX.md (navigation)</doc>
  <doc>DOCS/06_REFERENCE/CLAUDE_REFERENCE.md (deep technical reference; not CORE)</doc>
  <doc>DOCS/02_IMPLEMENTATION/ (plans/progress)</doc>
  <doc>.claude/commands/ (short, on-demand workflows)</doc>
</references>
</coding_guidelines>
