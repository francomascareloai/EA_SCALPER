<coding_guidelines>
<!-- CORE v3.9.2: Bootstrap-only (small). Delegate details to subagents/docs. -->
<metadata>
  <title>EA_SCALPER_XAUUSD - Claude CORE</title>
  <version>3.10.18</version>
  <last_updated>2025-12-19</last_updated>
  <changelog>v3.10.18: Document CLIProxy model mapping (opus→GPT-5.2 xhigh) for critical reviews.</changelog>
  <previous_changes>v3.10.17: REVIEWER to opus policy | v3.10.16: CLIPROXY protection rule | v3.10.15: Local-first NautilusTrader docs</previous_changes>

  <!-- CRITICAL: Version Control for CLAUDE.md -->
  <version_control_rule priority="MANDATORY">
    <rule>After ANY modification to CLAUDE.md: IMMEDIATELY commit and push to GitHub</rule>
    <reason>Prevent loss of configuration changes; ensure team sync; enable rollback</reason>
    <workflow>
      1. Edit CLAUDE.md
      2. git add CLAUDE.md
      3. git commit -m "chore(claude): [brief description of change] - v[NEW_VERSION]"
      4. git push
    </workflow>
    <enforcement>Do NOT report CLAUDE.md edit as "done" until push succeeds</enforcement>
  </version_control_rule>
</metadata>

<identity>
  <project>EA_SCALPER_XAUUSD v2.2 - Apex Trading</project>
  <market>XAUUSD</market>
  <owner>Franco</owner>
  <core_directive>1 session = 1 task → build → test → next</core_directive>
</identity>

<cliproxy_protection priority="CRITICAL">
  <rule>NEVER restart, kill, or stop CLIProxy without EXPLICIT user confirmation</rule>
  <rule>NEVER run pkill/kill on cli-proxy-api without asking Franco first</rule>
  <reason>
    Restarting proxy mid-response corrupts Claude Code conversation state.
    The tool_call streaming gets interrupted, leaving orphan call_ids that
    cause "No tool call found" errors. Recovery requires /clear or new session.
  </reason>
  <workflow>
    1. BEFORE any proxy restart: ASK "Posso reiniciar o CLIProxy? Isso pode corromper conversas ativas."
    2. WAIT for explicit "sim" or "pode" from Franco
    3. Only then execute the restart
    4. If urgent (proxy crashed): inform Franco and recommend /clear on affected sessions
  </workflow>
  <exception>If proxy is already dead (not running), can restart without asking</exception>
</cliproxy_protection>

<core>
  <dataset>
    data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet (32.7M ticks, 2003-05-05 → 2025-11-28, stride 20). Use this single file in ALL backtests.
  </dataset>

  <apex_non_negotiables>
    <rule>Trailing DD = 5% from HIGH-WATER MARK (includes unrealized)</rule>
    <rule>NO overnight positions: close ALL by 4:59 PM ET</rule>
    <rule>Max 30% profit/day (consistency) - LIVE ACCOUNTS ONLY, not required during evaluation but recommended as best practice</rule>
    <rule>Time gate: block new trades after 4:30 PM ET; emergency force-close from 4:55 PM ET</rule>

    <timekeeping_contract priority="CRITICAL">
      <purpose>Ensure accurate ET time for market close compliance</purpose>
      <time_source>
        <primary>NTP-synchronized system clock (pool.ntp.org or time.google.com)</primary>
        <validation>Verify clock drift less than 500ms at startup; alert if greater</validation>
        <fallback>If NTP unreachable for greater than 5 minutes: use conservative earlier close times</fallback>
      </time_source>
      <timezone_handling>
        <canonical>America/New_York (handles EST/EDT automatically)</canonical>
        <dst_rule>Use system timezone library (pytz/zoneinfo) - NEVER manually calculate DST</dst_rule>
        <validation>Log timezone offset at session start; alert if unexpected</validation>
      </timezone_handling>
      <drift_protection>
        <threshold>If clock drift greater than 1 second: trigger WARN alert</threshold>
        <threshold>If clock drift greater than 5 seconds: shift all time gates 5 minutes earlier</threshold>
        <threshold>If clock drift unknown: assume worst case, close at 4:45 PM ET</threshold>
      </drift_protection>
      <degraded_mode_times note="Use when time source is uncertain">
        <block_new_trades>4:20 PM ET (10 min earlier)</block_new_trades>
        <emergency_close>4:45 PM ET (10 min earlier)</emergency_close>
      </degraded_mode_times>
    </timekeeping_contract>

    <hwm_trap_warning priority="CRITICAL">
      <explanation>HWM is tracked tick-by-tick and NEVER decreases during a session. Unrealized profit raises your floor PERMANENTLY for that session.</explanation>
      <price_basis note="MANDATORY - prevents artificial HWM inflation">
        <rule>LONG positions: use BID price for unrealized exit value (conservative)</rule>
        <rule>SHORT positions: use ASK price for unrealized exit value (conservative)</rule>
        <rule>NEVER use MID price - it can artificially inflate unrealized profit</rule>
        <rule>HWM = max(HWM, current_equity + sum(unrealized_pnl_at_conservative_prices))</rule>
      </price_basis>
      <example>
        Account: $50,000 starting equity
        Trade goes to $52,000 unrealized profit → HWM = $52,000
        New trailing DD floor = $52,000 * 0.95 = $49,400
        Trade reverses to $49,000 → ACCOUNT TERMINATED
        Net result: Lost only $1,000 from starting equity but BLOWN because HWM was $52k
      </example>
      <defense>Always consider unrealized PnL as "locked in" for HWM purposes. Scale out winners early.</defense>
    </hwm_trap_warning>
  </apex_non_negotiables>

  <dd_limits>
    <taxonomy note="AUTHORITATIVE - all monitoring/playbooks MUST reference these exact thresholds">
      <trailing_dd description="From HIGH-WATER MARK (includes unrealized) - APEX KILLER">
        <threshold level="WARN">3.0%</threshold>
        <threshold level="CAUTION">3.5%</threshold>
        <threshold level="CRITICAL">4.0%</threshold>
        <threshold level="HALT">4.5%</threshold>
        <threshold level="TERMINATED">5.0% (APEX LIMIT - ACCOUNT BLOWN)</threshold>
      </trailing_dd>
      <daily_dd description="From session start equity">
        <threshold level="WARN">1.5%</threshold>
        <threshold level="CAUTION">2.0%</threshold>
        <threshold level="REDUCE">2.5% (reduce position size by 50%)</threshold>
        <threshold level="HALT">3.0%</threshold>
      </daily_dd>
    </taxonomy>
    <hard_blocks>Trailing DD ≥4.0% OR Daily DD ≥3.0% → HALT immediately (safety buffer before Apex limits)</hard_blocks>
    <implementation_note>Always check BOTH trailing and daily DD on every tick. Use the MORE RESTRICTIVE action.</implementation_note>
  </dd_limits>

  <thinking_protocol>
    <min_checklist>Root cause (5 whys) | consequences (2nd/3rd order) | edge cases | simplest safe fix | bias checks (look-ahead/slippage) | Apex impact | performance budget</min_checklist>
    <escalation>Trading/risk/architecture changes → sequential-thinking (10+ thoughts) + tests</escalation>
  </thinking_protocol>

  <context_budget_protocol>
    <why>Antigravity/Gemini can fail with 400 "Prompt is too long". The proxy does NOT safely truncate chat history. A single oversized orchestration thread can become unusable.</why>
    <rules>
      <rule>After any heavy orchestration (multi-agents, large refactor, deep backtest): produce a CHECKPOINT SUMMARY and start a fresh conversation for the next phase.</rule>
      <rule>Never paste huge logs/diffs/results into chat. Prefer: file paths + small excerpts (≤200 lines) + a concise summary.</rule>
      <rule>Tool outputs must be compacted: keep only metrics + file paths; never dump full backtest logs into the conversation.</rule>
      <rule>Limit fan-out: avoid many sub-agents in parallel; prefer 2–3 per round and iterate.</rule>
    </rules>
    <checkpoint_summary_format>Goal | Current state | Decisions made | Files changed | Commands run | Key metrics (WFE/SQN/PSR/DSR/MC DD) | Next steps (3–7 bullets)</checkpoint_summary_format>
  </context_budget_protocol>

  <pre_subagent_gate>
    <goal>Prevent context-window overflow before spawning sub-agents.</goal>
    <when>BEFORE starting sub-agents/orchestrator (especially for refactors/backtests).</when>
    <checklist>
      <item>If the thread already contains large tool_results/diffs/logs: write a CHECKPOINT SUMMARY first and start a fresh thread.</item>
      <item>Hard cap: 2–3 sub-agents per round; run sequential rounds instead of large fan-out.</item>
      <item>Each sub-agent must have a narrow scope (one module/file/objective). No "analyze the entire repo" tasks.</item>
      <item>Sub-agent output contract: return (a) a short plan, (b) file list, (c) minimal patch guidance. No long dumps.</item>
    </checklist>
  </pre_subagent_gate>

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

  <performance_limits>OnTick less than 50ms (block deploy if exceeded) | ONNX less than 5ms | Python Hub less than 400ms</performance_limits>

  <ml_validation>
    <trade_gate>P(direction) greater than 0.65</trade_gate>
    <approval_gate>WFE greater than or equal 0.6 | SQN greater than or equal 2.0 | PSR greater than or equal 0.85 | DSR greater than 0 | PBO less than 25% | MC95DD less than 4%</approval_gate>
    <sample_requirements>≥200 trades AND ≥5 years AND multiple regimes (trend/range/volatile) across different market conditions</sample_requirements>
  </ml_validation>

  <handoff_chain>
    <decision_priority>SENTINEL > ORACLE > CRUCIBLE</decision_priority>
    <trading_logic>FORGE → REVIEWER → ORACLE → SENTINEL (mandatory)</trading_logic>
    <critic_integration>After each agent output, orchestrator spawns CRITIC to review before passing to next agent</critic_integration>
    <flow_example>FORGE outputs → CRITIC reviews → if PASS → REVIEWER → CRITIC reviews → if PASS → ORACLE → etc.</flow_example>
  </handoff_chain>

  <production_workflow>
    <purpose>Define the complete path from backtest to live trading</purpose>

    <phases>
      <phase name="1_backtest">Strategy validation via ORACLE (WFE/SQN/PSR/DSR/MC)</phase>
      <phase name="2_paper_trading" mandatory="true">
        <duration>Minimum 2 weeks with live data feed, no real money</duration>
        <requirements>
          - Run strategy on LIVE data stream (not backtest replay)
          - Track unrealized PnL and HWM exactly as Apex would
          - Verify time gates work correctly (4:30 PM block, 4:55 PM force-close)
          - Confirm emergency close executes within latency budget
          - Log all trades, entries, exits, and slippage observed
        </requirements>
        <gate>Pass = no critical issues in 2 weeks of paper trading</gate>
      </phase>
      <phase name="3_go_live_decision">
        <external_critic mandatory="true">
          Orchestrator spawns EXTERNAL CRITIC (not self-review) to analyze:
          - Paper trading results
          - All validation artifacts
          - Strategy code
          Fresh context = fresh perspective = catch blind spots
        </external_critic>
        <sentinel_approval mandatory="true">SENTINEL final sign-off on Apex compliance</sentinel_approval>
      </phase>
      <phase name="4_live">Deploy to Apex with smallest account size first ($50k)</phase>
    </phases>
  </production_workflow>

  <!-- Infrastructure externalized to .claude/ for size optimization -->
  <live_infrastructure ref=".claude/infra/live-infrastructure.md">MGC specs, data feed, execution, monitoring, logging</live_infrastructure>
  <incident_response ref=".claude/playbooks/incident-response.md">NETWORK_DISCONNECT, EMERGENCY_CLOSE, DD_BREACH, STALE_DATA, POSITION_MISMATCH playbooks</incident_response>
  <network_resilience ref=".claude/infra/network-resilience.md">Connection management, data integrity, graceful degradation, async patterns</network_resilience>

  <structured_handoff>
    <purpose>Prevent information loss between agents</purpose>
    <required_sections>Context (task, files) | Decisions (+ rationale) | Assumptions | Risks (+ mitigation) | Open Questions | Next Agent Actions</required_sections>
    <when>Artifact handoff in chain | GO/NO-GO | Cross-phase handoff</when>
  </structured_handoff>

  <verdict_synthesizer>
    <purpose>Resolve conflicting agent verdicts</purpose>
    <priority>SENTINEL > ORACLE > CRUCIBLE (SENTINEL NO-GO = final)</priority>
    <rule>Never GO if CRITICAL unresolved. Conflict between non-critical → escalate to user with summary.</rule>
  </verdict_synthesizer>

  <output_destinations>Findings: DOCS/03_RESEARCH/FINDINGS/ | Decisions: DOCS/04_REPORTS/DECISIONS/ | Code logs: CHANGELOG.md + nautilus_gold_scalper/BUGFIX_LOG.md + MQL5/Experts/BUGFIX_LOG.md</output_destinations>

  <doc_hygiene>Search before creating docs; update existing; avoid _V1/_V2; keep DOCS/_INDEX.md current</doc_hygiene>

  <nautilus_trader_local_docs priority="HIGH">
    <purpose>Provide fast, offline, version-auditable NautilusTrader docs/examples without relying on large MCP doc pulls.</purpose>
    <workspace_path note="Preferred">external/nautilus_trader/ (symlink to local clone; git-ignored)</workspace_path>
    <search_order>1) external/nautilus_trader (docs/ + examples/ + source) → 2) installed package (site-packages) → 3) docs MCP (context7) → 4) web search (exa) as last resort</search_order>
    <rules>
      <rule>When answering Nautilus API questions, cite from local repo/code first; do not guess.</rule>
      <rule>Never scan the whole Nautilus repo unnecessarily; always scope searches to a path (docs/, examples/, nautilus_trader/).</rule>
      <rule>Prefer examples as canonical usage patterns: external/nautilus_trader/examples/.</rule>
      <rule>Keep retrieval compact: return file paths + small excerpts only (avoid dumping whole docs pages).</rule>
    </rules>
    <quick_commands>
      <cmd>rg -n -S "TERM" external/nautilus_trader/docs</cmd>
      <cmd>rg -n -S "SYMBOL" external/nautilus_trader/examples</cmd>
      <cmd>python3 -c "import nautilus_trader, importlib.metadata as m; print(m.version('nautilus-trader')); print(nautilus_trader.__file__)"</cmd>
    </quick_commands>
  </nautilus_trader_local_docs>

  <security>Never expose secrets/keys/credentials</security>
</core>

<orchestration_protocol>
  <purpose>Maximize quality via structured thinking and context preservation</purpose>

  <task_classification>
    <simple triggers="single file edit|quick lookup|git status|simple question">
      Execute directly. No special protocol needed.
    </simple>

    <complex triggers="trading|risk|sizing|drawdown|apex|architecture|debug|validate|design|strategy|multi-file">
      MANDATORY: Use sequential-thinking MCP tool (8-15 thoughts minimum).
      Structure: problem → options → 1st/2nd/3rd order consequences → pre-mortem → Apex check → decision → validation plan.
      Output: DECISION + RATIONALE + RISKS + MITIGATIONS + VALIDATION + NEXT.
    </complex>

    <heavy triggers="find all X|understand how Y works|scan codebase|large refactor|analyze results|search pattern across files|read >500 lines">
      MANDATORY: Delegate to Explorer sub-agent (Task tool with subagent_type=Explore).
      Explorer does the heavy lifting and returns structured summary.
      Orchestrator acts on summary, preserving main context clean.
    </heavy>
  </task_classification>

  <thinking_depth>
    <standard thoughts="5-7">Simple decisions, small implementations</standard>
    <deep thoughts="8-12">Trading logic, risk, architecture, multi-file changes</deep>
    <exhaustive thoughts="15+">Go-live decisions, critical bugs, Apex compliance, money at risk</exhaustive>
  </thinking_depth>

  <sequential_thinking_structure>
    1. State problem/decision clearly
    2. List 2-3 options
    3. Analyze 1st order consequences (immediate)
    4. Analyze 2nd order consequences (downstream)
    5. Analyze 3rd order consequences (systemic)
    6. Pre-mortem: what could go wrong?
    7. Check Apex compliance (DD, time gates, consistency)
    8. Check temporal correctness (no look-ahead)
    9. Check performance budgets
    10. Make decision with clear rationale
    11. Verify decision against all constraints
    12. Define validation steps
  </sequential_thinking_structure>

  <explorer_delegation>
    <when>Task requires scanning/reading large portions of codebase</when>
    <how>Spawn Task with subagent_type=Explore, clear objective, expected output format</how>
    <output_contract>Explorer returns: FINDINGS (structured) + RELEVANT_FILES + SUMMARY (≤500 words)</output_contract>
    <benefit>Main context stays clean; Explorer absorbs the noise</benefit>
  </explorer_delegation>

  <mandatory_delegation>
    <purpose>Prevent context overflow by FORCING delegation for large read operations</purpose>
    <rule>NEVER read backtest results, logs, or data files (>100 lines) directly into main context</rule>
    <rule>NEVER glob/grep and then read multiple large files in sequence</rule>
    <rule>ALWAYS spawn Explorer (haiku) first to get: file list + sizes + key metrics summary</rule>
    <rule>ONLY after Explorer summary: decide which specific small section to read directly (if needed)</rule>

    <triggers_for_mandatory_explorer>
      <trigger>Analyze backtest results</trigger>
      <trigger>Review multiple log files</trigger>
      <trigger>Scan data/ or catalog/ directories</trigger>
      <trigger>Understand codebase structure</trigger>
      <trigger>Find all files matching pattern</trigger>
      <trigger>Compare multiple configurations</trigger>
    </triggers_for_mandatory_explorer>

    <workflow>
      1. Receive task that matches triggers above
      2. DO NOT read files directly
      3. Spawn Explorer (model: haiku) with specific objective
      4. Wait for Explorer summary (≤500 words)
      5. Based on summary, create plan OR spawn focused follow-up
      6. Only read specific small sections if absolutely necessary
    </workflow>
  </mandatory_delegation>

  <context_hygiene>
    <rule>After heavy orchestration: produce CHECKPOINT SUMMARY, consider fresh conversation</rule>
    <rule>Never paste huge logs/diffs/results. Use: file paths + excerpts (≤200 lines) + summary</rule>
    <rule>Tool outputs: keep only metrics + file paths; never dump full logs</rule>
    <rule>Limit fan-out: 2-3 sub-agents per round max (default)</rule>
  </context_hygiene>

  <orchestration_flexibility>
    <purpose>Allow plans to override default orchestration limits when user has resources</purpose>

    <default_mode>
      <rule>Use 2-3 sub-agents per round to prevent context overflow</rule>
      <rule>Sequential execution for dependent tasks</rule>
      <rule>Apply when no explicit plan exists</rule>
    </default_mode>

    <plan_override_mode>
      <when>Active plan exists in .planning/ directory</when>
      <rule>Follow the plan's orchestration spec (sub-agent count, parallelism, sequence)</rule>
      <rule>Plan can specify unlimited parallel sub-agents if user confirmed resources</rule>
      <rule>Plan defines which agents to spawn and in what order</rule>
      <example>Plan says "spawn CRITIC + ORACLE + SENTINEL in parallel" → do exactly that</example>
    </plan_override_mode>

    <user_override>
      <when>User explicitly says "spawn X agents in parallel" or "use unlimited"</when>
      <action>Follow user instruction, ignore default limits</action>
    </user_override>
  </orchestration_flexibility>

  <critic_gate spec=".claude/agents/critic-adversarial.md">
    <purpose>Adversarial review before reporting done</purpose>
    <two_layer>
      <layer1>Sub-agent self-review (5-7 thoughts, fix obvious issues)</layer1>
      <layer2>Orchestrator spawns CRITIC (12-15 thoughts, 7 techniques: INVERSION, PRE-MORTEM, STRESS, REGIME, APEX_TRAP, EDGE, ASSUMPTION)</layer2>
    </two_layer>
    <spawn_when>Trading code | Risk/sizing | GO/NO-GO | Architecture</spawn_when>
    <checklist>Bugs | Logic | Apex compliance | Temporal (look-ahead) | Performance | Edge cases | Assumptions</checklist>
    <skip>SIMPLE tasks | Docs-only | User requests no review</skip>
  </critic_gate>

  <model_policy>
    <opus>trading|risk|apex|architecture|strategy|FORGE|ORACLE|SENTINEL|CRUCIBLE|NAUTILUS|CRITIC|DAEMON|REVIEWER</opus>
    <haiku>Explore|git|docs|file search</haiku>
    <default>When in doubt → opus for money/risk/trading</default>
    <cliproxy_mapping note="When running through CLIProxy">
      <map from="opus" to="GPT-5.2 (xhigh reasoning)" reason="More critical, deterministic analysis"/>
      <map from="sonnet" to="GPT-5.2 (high reasoning)" reason="Standard tasks"/>
      <map from="haiku" to="GPT-5 (low reasoning)" reason="Fast exploration only"/>
    </cliproxy_mapping>
    <version_reporting>Sub-agents include: AGENT_VERSION + CLAUDE_MD_VERSION + STATUS in output header</version_reporting>
  </model_policy>

  <orchestration_output_protocol>
    <purpose>Persist sub-agent outputs to files when ≥3 agents OR heavy orchestration</purpose>
    <location>.planning/phases/XX/orchestration/ OR .claude/orchestration/sessions/YYYY-MM-DD_HH-MM/</location>
    <protocol>1. Create session folder → 2. Agents write to [folder]/[AGENT]_output.md, return 300-word summary → 3. Create MANIFEST.md → 4. Read MANIFEST if context overflows</protocol>
    <daemon_note>DAEMON is heavy; spawn sequentially OR run_in_background with extended timeout</daemon_note>
  </orchestration_output_protocol>
</orchestration_protocol>

<router>
  <!-- Strategy & Design -->
  <route intent="Setup/SMC/Strategy" agent="CRUCIBLE" trigger="Crucible|/setup|strategy design" spec=".claude/agents/crucible-gold-strategist.md"/>
  <route intent="NautilusTrader Architecture" agent="NAUTILUS" trigger="Nautilus|architecture|Strategy|Actor|BacktestNode" spec=".claude/agents/nautilus-trader-architect.md"/>

  <!-- Code & Implementation -->
  <route intent="Code (Python/Nautilus)" agent="FORGE" trigger="Forge|/codigo|implement|fix|refactor" spec=".claude/agents/forge-nautilus.md"/>
  <route intent="Code Review/Audit" agent="REVIEWER" trigger="review|/audit" spec=".claude/agents/generic-code-reviewer.md"/>

  <!-- Validation & Testing -->
  <route intent="Backtest/WFA/GO-NOGO" agent="ORACLE" trigger="Oracle|/backtest|/wfa|validate|Monte Carlo" spec=".claude/agents/oracle-backtest-commander.md"/>
  <route intent="Massive Backtest/Optimization" agent="SCALE_RUNNER" trigger="scale|massive|parameter sweep|grid search|optimization" spec=".claude/agents/scale-runner.md"/>
  <route intent="Adversarial Review" agent="CRITIC" trigger="/critic|/review-deep|adversarial" spec=".claude/agents/critic-adversarial.md"/>

  <!-- Strategic Advisory -->
  <route intent="Strategic Genius/Paradigm Breaking" agent="DAEMON" trigger="Daemon|/genius|strategic review|why are we|fundamentally|paradigm" spec=".claude/agents/daemon-strategic-advisor.md"/>

  <!-- Risk & Compliance -->
  <route intent="Risk/DD/Lot/Apex" agent="SENTINEL" trigger="Sentinel|/risk|/risco|/lot [sl]|/apex|drawdown" spec=".claude/agents/sentinel-apex-guardian.md"/>

  <!-- ML & Models -->
  <route intent="ONNX/ML Pipeline" agent="ONNX_BUILDER" trigger="onnx|model|ml export|ml pipeline" spec=".claude/agents/onnx-model-builder.md"/>

  <!-- Research & Docs -->
  <route intent="Research/Papers/ML" agent="ARGUS" trigger="Argus|/search|/pesquisar|research|papers" spec=".claude/agents/argus-quant-researcher.md"/>
  <route intent="Documentation" agent="DOCS" trigger="docs|document|readme|index" spec=".claude/agents/trading-project-documenter.md"/>

  <!-- Infrastructure -->
  <route intent="Git hygiene" agent="GIT_GUARDIAN" trigger="git|commit|secrets" spec=".claude/agents/git-guardian-nano.md"/>
  <route intent="Perf profiling" agent="PERF_OPT" trigger="profile|latency|performance" spec=".claude/agents/performance-optimizer.md"/>
  <route intent="Proxy/OAuth/CLIProxy" agent="CLIPROXY_ENGINEER" trigger="cliproxy|proxy|oauth|401|403|429|antigravity|translator" spec=".claude/agents/cliproxy-engineer.md"/>
</router>

<wsl_cli note="Project-specific exclusions; Claude knows standard commands">
  <exclude>.venv/ | .rag-db/ | data/ | tools/antigravity/ | external/</exclude>
  <rg_default>rg -n -S --glob '!.venv/**' --glob '!.rag-db/**' --glob '!data/**' --glob '!tools/antigravity/**' --glob '!external/**' "pattern" .</rg_default>
</wsl_cli>

<references>
  <doc>DOCS/_INDEX.md (navigation)</doc>
  <doc>DOCS/06_REFERENCE/CLAUDE_REFERENCE.md (deep technical reference; not CORE)</doc>
  <doc>DOCS/02_IMPLEMENTATION/ (plans/progress)</doc>
  <doc>.claude/commands/ (short, on-demand workflows)</doc>
</references>
</coding_guidelines>
