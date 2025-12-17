<coding_guidelines>
<!-- CORE v3.9.2: Bootstrap-only (small). Delegate details to subagents/docs. -->
<metadata>
  <title>EA_SCALPER_XAUUSD - Claude CORE</title>
  <version>3.10.12</version>
  <last_updated>2025-12-17</last_updated>
  <changelog>v3.10.12: Added live_infrastructure (data feed, execution, monitoring), incident_response (5 playbooks), network_resilience, sample requirements (100→200 trades, 2→5 years), paper trading (1→2 weeks).</changelog>
  <previous_changes>v3.10.11: CRITIC two-layer system, HWM trap warning, 30% rule clarified | v3.10.10: Mandatory commit+push rule</previous_changes>

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

<core>
  <dataset>
    data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet (32.7M ticks, 2003-05-05 → 2025-11-28, stride 20). Use this single file in ALL backtests.
  </dataset>

  <apex_non_negotiables>
    <rule>Trailing DD = 5% from HIGH-WATER MARK (includes unrealized)</rule>
    <rule>NO overnight positions: close ALL by 4:59 PM ET</rule>
    <rule>Max 30% profit/day (consistency) - LIVE ACCOUNTS ONLY, not required during evaluation but recommended as best practice</rule>
    <rule>Time gate: block new trades after 4:30 PM ET; emergency force-close from 4:55 PM ET</rule>

    <hwm_trap_warning priority="CRITICAL">
      <explanation>HWM is tracked tick-by-tick and NEVER decreases during a session. Unrealized profit raises your floor PERMANENTLY for that session.</explanation>
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
    <daily>1.5% warn → 2.0% caution → 2.5% reduce → 3.0% HALT</daily>
    <total>3.0% warn → 3.5% caution → 4.0% CRITICAL → 4.5% HALT → 5.0% TERMINATED</total>
    <hard_blocks>Trailing DD ≥4.0% OR Total DD ≥4.5% → HALT (safety buffer)</hard_blocks>
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

  <live_infrastructure>
    <purpose>Define required infrastructure for paper trading and live deployment</purpose>

    <data_feed>
      <provider>Apex / NinjaTrader / Rithmic (any provider with XAUUSD tick data)</provider>
      <requirements>
        <item>Tick-by-tick or 1-second bars minimum for HWM tracking</item>
        <item>Latency target: receive tick within 50ms of exchange timestamp</item>
        <item>Fallback: if primary feed drops, halt trading (do NOT use stale data)</item>
      </requirements>
      <validation>Validate timestamps are monotonically increasing; reject out-of-order ticks</validation>
    </data_feed>

    <execution>
      <broker>Apex Trader Funding (evaluation → funded)</broker>
      <latency_budget>Order submission to acknowledgment less than 200ms</latency_budget>
      <order_types>Market orders for emergency close; limit orders for entries</order_types>
      <slippage_assumption>1-2 pips for XAUUSD during normal conditions; 5+ pips during news</slippage_assumption>
      <partial_fills>If partial fill, treat filled portion as open position; remainder as canceled</partial_fills>
    </execution>

    <monitoring>
      <realtime_metrics>
        <metric>Current DD % (tick-by-tick)</metric>
        <metric>HWM value and timestamp of last update</metric>
        <metric>Open positions count and unrealized PnL</metric>
        <metric>Time to market close (countdown)</metric>
        <metric>Daily profit % (for 30% cap tracking in live)</metric>
      </realtime_metrics>
      <alerts>
        <alert level="WARN">DD exceeds 1.5%</alert>
        <alert level="CAUTION">DD exceeds 2.5%</alert>
        <alert level="CRITICAL">DD exceeds 3.5%</alert>
        <alert level="HALT">DD exceeds 4.0% OR network disconnect greater than 30s</alert>
      </alerts>
      <health_checks>
        <check interval="5s">Data feed heartbeat</check>
        <check interval="10s">Broker connection status</check>
        <check interval="60s">Position reconciliation (local vs broker)</check>
      </health_checks>
    </monitoring>

    <logging>
      <trade_log>Every entry/exit with timestamp, price, slippage, HWM at time of trade</trade_log>
      <system_log>Connection events, errors, latency spikes, health check failures</system_log>
      <retention>Keep logs for minimum 90 days for compliance/debugging</retention>
    </logging>
  </live_infrastructure>

  <incident_response>
    <purpose>Playbooks for handling critical incidents during live trading</purpose>

    <playbook id="NETWORK_DISCONNECT">
      <trigger>Data feed or broker connection lost for greater than 10 seconds</trigger>
      <severity>CRITICAL</severity>
      <immediate_actions>
        <action>1. HALT all new trade entries immediately</action>
        <action>2. Attempt reconnection with exponential backoff (1s, 2s, 4s, 8s, 16s)</action>
        <action>3. If reconnection fails after 30s: trigger EMERGENCY_CLOSE playbook</action>
        <action>4. Log disconnect timestamp, duration, and any data gaps</action>
      </immediate_actions>
      <post_recovery>
        <action>Reconcile local state with broker state</action>
        <action>Verify no phantom positions exist</action>
        <action>Check for missed fills during disconnect</action>
      </post_recovery>
    </playbook>

    <playbook id="EMERGENCY_CLOSE">
      <trigger>Time gate (4:55 PM ET) OR network disconnect greater than 30s OR DD exceeds 4.0%</trigger>
      <severity>CRITICAL</severity>
      <immediate_actions>
        <action>1. Submit market close orders for ALL open positions</action>
        <action>2. Confirm each close order acknowledged (retry up to 3x)</action>
        <action>3. If broker unreachable: log FAILED_EMERGENCY_CLOSE + alert human</action>
        <action>4. Set trading halted flag (prevent any new orders)</action>
      </immediate_actions>
      <human_escalation>If emergency close fails after 3 retries: IMMEDIATE human notification required</human_escalation>
    </playbook>

    <playbook id="DD_BREACH">
      <trigger>Drawdown exceeds threshold (warn/caution/critical/halt levels)</trigger>
      <severity_matrix>
        <level dd="1.5%">WARN - log + continue with reduced sizing</level>
        <level dd="2.5%">CAUTION - log + reduce position size by 50%</level>
        <level dd="3.5%">CRITICAL - close half of open positions</level>
        <level dd="4.0%">HALT - execute EMERGENCY_CLOSE immediately</level>
      </severity_matrix>
      <post_incident>Review all trades since last good state; identify root cause</post_incident>
    </playbook>

    <playbook id="STALE_DATA">
      <trigger>No new ticks for greater than 5 seconds during market hours</trigger>
      <severity>HIGH</severity>
      <immediate_actions>
        <action>1. HALT new trade entries</action>
        <action>2. Mark current prices as STALE in UI/logs</action>
        <action>3. Do NOT use stale prices for any calculations</action>
        <action>4. If persists greater than 30s: consider emergency close</action>
      </immediate_actions>
    </playbook>

    <playbook id="POSITION_MISMATCH">
      <trigger>Local position state differs from broker reported state</trigger>
      <severity>HIGH</severity>
      <immediate_actions>
        <action>1. HALT all trading immediately</action>
        <action>2. Log both local and broker states</action>
        <action>3. Trust broker state as source of truth</action>
        <action>4. Reconcile and correct local state</action>
        <action>5. Investigate cause before resuming</action>
      </immediate_actions>
    </playbook>

    <escalation_contacts>
      <note>Define actual contacts before go-live</note>
      <contact role="Primary">Franco (owner) - phone/telegram</contact>
      <contact role="Fallback">Automated SMS/email alert service</contact>
    </escalation_contacts>
  </incident_response>

  <network_resilience>
    <purpose>Ensure robust handling of network failures and degraded conditions</purpose>

    <connection_management>
      <primary_reconnect>Exponential backoff: 1s → 2s → 4s → 8s → 16s → cap at 30s</primary_reconnect>
      <max_reconnect_attempts>10 attempts before declaring connection dead</max_reconnect_attempts>
      <circuit_breaker>After 3 consecutive failures in 5 minutes: halt trading for 15 minutes</circuit_breaker>
    </connection_management>

    <data_integrity>
      <sequence_validation>Reject out-of-order messages; request gap fill if sequence breaks</sequence_validation>
      <stale_threshold>Data older than 5 seconds is STALE; do not use for decisions</stale_threshold>
      <heartbeat_interval>Expect heartbeat every 5 seconds; trigger reconnect if missed 3x</heartbeat_interval>
    </data_integrity>

    <graceful_degradation>
      <level1 condition="Latency spike greater than 500ms">Log warning; continue with caution</level1>
      <level2 condition="Latency spike greater than 2s">Halt new entries; monitor existing positions</level2>
      <level3 condition="Connection lost">Execute NETWORK_DISCONNECT playbook</level3>
    </graceful_degradation>

    <testing_requirements>
      <requirement>Simulate network disconnect during paper trading</requirement>
      <requirement>Verify emergency close works with broker connection restored mid-close</requirement>
      <requirement>Test reconnection logic with various failure durations</requirement>
    </testing_requirements>
  </network_resilience>

  <structured_handoff>
    <purpose>Prevent information loss between agents</purpose>
    <format>
      ## HANDOFF: [Source Agent] → [Target Agent]

      ### Context
      - Task: [what was done]
      - Files: [list of files modified/analyzed]

      ### Decisions Made
      - [decision 1 + rationale]
      - [decision 2 + rationale]

      ### Assumptions
      - [assumption 1 - why it's safe]
      - [assumption 2 - why it's safe]

      ### Risks Identified
      - [risk 1 + mitigation]
      - [risk 2 + mitigation]

      ### Open Questions
      - [question for downstream agent]

      ### Next Agent Should
      - [specific action 1]
      - [specific action 2]
    </format>
    <when_required>
      <trigger>Any artifact passed between agents in handoff_chain</trigger>
      <trigger>GO/NO-GO decision handoff</trigger>
      <trigger>Cross-phase handoff in plans</trigger>
    </when_required>
  </structured_handoff>

  <verdict_synthesizer>
    <purpose>Resolve conflicting verdicts when multiple agents review same artifact</purpose>
    <when>Multiple agents return conflicting recommendations (GO vs NO-GO, different risk assessments)</when>
    <protocol>
      1. Collect all verdicts: CRITIC, ORACLE, SENTINEL, REVIEWER
      2. Apply decision_priority: SENTINEL > ORACLE > CRUCIBLE
      3. If SENTINEL says NO-GO → NO-GO (final)
      4. If ORACLE says NO-GO but others say GO → NO-GO with explanation
      5. If conflict between non-critical agents → escalate to user with summary:
         - Who said what
         - Key disagreement point
         - Recommended action
      6. Never proceed with GO if any CRITICAL issue is unresolved
    </protocol>
    <output_format>
      ## VERDICT SYNTHESIS
      | Agent | Verdict | Key Concern | Weight |
      |-------|---------|-------------|--------|
      | SENTINEL | NO-GO | DD exceeds buffer | FINAL |
      | ORACLE | GO | Metrics pass | - |

      **Final Verdict**: NO-GO (SENTINEL authority)
      **Rationale**: [explanation]
      **Next Steps**: [what to fix]
    </output_format>
  </verdict_synthesizer>

  <output_destinations>Findings: DOCS/03_RESEARCH/FINDINGS/ | Decisions: DOCS/04_REPORTS/DECISIONS/ | Code logs: CHANGELOG.md + nautilus_gold_scalper/BUGFIX_LOG.md + MQL5/Experts/BUGFIX_LOG.md</output_destinations>

  <doc_hygiene>Search before creating docs; update existing; avoid _V1/_V2; keep DOCS/_INDEX.md current</doc_hygiene>

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

  <critic_gate>
    <purpose>Adversarial review to catch bugs, logic errors, and compliance issues BEFORE reporting done</purpose>
    <spec>.claude/agents/critic-adversarial.md</spec>
    <mindset>Red Team / Devil's Advocate - assumes bugs exist and hunts them</mindset>

    <two_layer_system>
      <layer1 name="Sub-Agent Self-Review">
        <description>Each sub-agent performs internal self-review before returning output</description>
        <rule>Sub-agent completes artifact (code/plan/strategy)</rule>
        <rule>Sub-agent applies adversarial mindset internally (5-7 thoughts)</rule>
        <rule>If obvious issues found → sub-agent fixes before returning</rule>
        <rule>Sub-agent returns output + confidence level to orchestrator</rule>
        <benefit>First-pass quality gate, catches obvious issues early</benefit>
      </layer1>

      <layer2 name="Orchestrator-Spawned CRITIC">
        <description>Orchestrator spawns SEPARATE CRITIC agent to review sub-agent output</description>
        <rule>Orchestrator receives sub-agent output</rule>
        <rule>Orchestrator spawns CRITIC agent with sub-agent output as input</rule>
        <rule>CRITIC applies full 7 techniques (12-15 sequential thoughts)</rule>
        <rule>CRITIC returns: PASS/FAIL + issues + recommendations</rule>
        <rule>If FAIL → orchestrator routes back to original agent for fixes</rule>
        <benefit>Fresh perspective, separation of concerns, maximum quality</benefit>
      </layer2>
    </two_layer_system>

    <critic_techniques note="Applied by CRITIC agent in Layer 2">
      <technique>INVERSION: What would make this fail?</technique>
      <technique>PRE-MORTEM: Imagine failure, trace back to causes</technique>
      <technique>STRESS TEST: Extreme conditions behavior</technique>
      <technique>REGIME SHIFT: Market/team/tech changes resilience</technique>
      <technique>APEX TRAP: Could following this literally violate Apex?</technique>
      <technique>EDGE CASES: Corner cases not handled</technique>
      <technique>ASSUMPTION AUDIT: Challenge implicit assumptions</technique>
    </critic_techniques>

    <when_to_spawn_critic>
      <always>Trading code written (Python or MQL5)</always>
      <always>Risk/sizing calculation done</always>
      <always>GO/NO-GO decision pending</always>
      <always>Architecture designed</always>
      <optional>Plan/strategy completed (if complex)</optional>
      <optional>Script created (if touches trading/risk)</optional>
    </when_to_spawn_critic>

    <critic_checklist note="Used by CRITIC agent">
      <item>Bugs: off-by-one, null handling, type errors, race conditions</item>
      <item>Logic: contradictions, missing cases, boundary conditions</item>
      <item>Apex: trailing DD, time gates, overnight, 30% consistency (live)</item>
      <item>Temporal: look-ahead, data leakage, future peeking</item>
      <item>Performance: hot paths within budget</item>
      <item>Edge cases: extreme conditions, failures, partial fills</item>
      <item>Assumptions: challenged and validated</item>
    </critic_checklist>

    <skip_critic_when>
      <case>SIMPLE tasks (single file edit, lookup, git status)</case>
      <case>Documentation-only changes</case>
      <case>User explicitly requests no review</case>
    </skip_critic_when>
  </critic_gate>

  <model_policy>
    <purpose>Ensure appropriate model selection when spawning sub-agents via Task tool</purpose>

    <opus_required triggers="trading|risk|sizing|apex|validation|go-live|architecture|strategy|FORGE|ORACLE|SENTINEL|CRUCIBLE|NAUTILUS|SCALE_RUNNER|ONNX_BUILDER|REVIEWER|PERF_OPT|ARGUS|CRITIC|DAEMON|/genius">
      <rule>Use model: "opus" explicitly in Task tool call</rule>
      <agents>FORGE, ORACLE, SENTINEL, CRUCIBLE, NAUTILUS, SCALE_RUNNER, ONNX_BUILDER, REVIEWER, PERF_OPT, ARGUS, CRITIC, DAEMON</agents>
      <reason>Trading-critical agents require highest reasoning capability</reason>
    </opus_required>

    <haiku_allowed triggers="Explore|git status|simple lookup|documentation|file search">
      <rule>Use model: "haiku" for speed and cost efficiency</rule>
      <agents>Explore, GIT_GUARDIAN (simple ops), DOCS</agents>
      <reason>Simple tasks don't need opus overhead</reason>
    </haiku_allowed>

    <default>When in doubt, use opus for anything touching money/risk/trading logic</default>

    <version_reporting>
      <purpose>Ensure agents use latest specs and track versions for reproducibility</purpose>
      <rule>Every sub-agent MUST include in output: AGENT_VERSION: [version from spec header]</rule>
      <rule>Orchestrator verifies version matches current spec before accepting output</rule>
      <rule>If version mismatch → warn user, consider re-running with updated spec</rule>
      <format>
        ## Agent Output Header
        AGENT: [name]
        VERSION: [from spec, e.g., FORGE v2.1]
        CLAUDE_MD_VERSION: [e.g., 3.10.9]
        STATUS: COMPLETE/PARTIAL/FAILED
      </format>
    </version_reporting>
  </model_policy>

  <orchestration_output_protocol>
    <purpose>Persist sub-agent outputs to survive context summarization</purpose>
    <problem>When spawning multiple sub-agents, their outputs flood the context. If context overflows, summarization loses critical details.</problem>

    <when_to_apply>
      <trigger>Spawning ≥3 sub-agents in parallel</trigger>
      <trigger>Any sub-agent expected to produce >500 words of output</trigger>
      <trigger>Heavy orchestration (analysis, audit, multi-agent review)</trigger>
    </when_to_apply>

    <protocol>
      <step>1. BEFORE spawning: Create session folder</step>
      <location_if_plan>.planning/phases/XX/orchestration/</location_if_plan>
      <location_if_no_plan>.claude/orchestration/sessions/YYYY-MM-DD_HH-MM/</location_if_no_plan>

      <step>2. Include OUTPUT INSTRUCTION in each sub-agent prompt:</step>
      <output_instruction>
        OUTPUT PROTOCOL (MANDATORY):
        - Write your COMPLETE analysis to: [session_folder]/[AGENT_NAME]_output.md
        - Return ONLY a SUMMARY (max 300 words) to chat containing:
          * Top 3-5 key findings
          * Severity counts: CRITICAL/HIGH/MEDIUM/LOW
          * Output file path
          * Status: COMPLETE/PARTIAL/FAILED
      </output_instruction>

      <step>3. AFTER sub-agents return: Create MANIFEST.md</step>
      <manifest_template>
        # Orchestration Session: [datetime]
        ## Objective: [what was being analyzed]
        ## Agents
        | Agent | Status | Output | Key Findings |
        |-------|--------|--------|--------------|
        | CRITIC | ✅ | CRITIC_output.md | 3 CRITICAL |
        ## Synthesis: [brief summary]
        ## Next Steps: [actions]
      </manifest_template>

      <step>4. If context overflows: Read MANIFEST to recover</step>
    </protocol>

    <daemon_special_handling>
      <issue>DAEMON is heavy (15-20 thoughts + 5 lenses). May timeout in parallel.</issue>
      <rule>Do NOT spawn DAEMON in parallel with >2 other opus agents</rule>
      <rule>Consider run_in_background: true with extended timeout</rule>
      <rule>Or run DAEMON as separate sequential step after other agents</rule>
    </daemon_special_handling>

    <cleanup>
      <rule>Sessions older than 7 days may be archived or deleted</rule>
      <archive_path>.claude/orchestration/archive/</archive_path>
    </cleanup>
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
