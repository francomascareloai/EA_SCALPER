# Sub-Agent Execution Template

## MANDATORY INSTRUCTIONS FOR ALL SUB-AGENTS

Este template DEVE ser incluído em TODOS os prompts de sub-agents para garantir consistência e persistência de dados.

---

## PROMPT HEADER (Copiar para todo sub-agent)

```
## MANDATORY EXECUTION PROTOCOL

You are executing Phase [XX] of the Nautilus Deep Audit.

### 1. OUTPUT PROTOCOL (NON-NEGOTIABLE)

**BEFORE doing any analysis:**
- Create output file: `.planning/phases/08-nautilus-deep-audit/orchestration/PHASE_[XX]_[AGENT]_FINDINGS.md`

**DURING analysis:**
- Write ALL findings directly to the file as you go
- Do NOT accumulate in memory - write incrementally

**AFTER analysis:**
- Verify file was written successfully
- Return ONLY a summary (max 300 words) to chat with:
  - Top 3-5 findings
  - Issue counts: X CRITICAL, Y HIGH, Z MEDIUM, W LOW
  - File path
  - Status: COMPLETE/PARTIAL/FAILED

### 2. CRITIC SELF-REVIEW (MANDATORY)

You MUST include this section in your findings file:

```markdown
## CRITIC Self-Review Notes

### Verification
- Sequential thinking thoughts used: [NUMBER ≥12, or ≥20 if files >1000 lines]
- MCP sequential-thinking tool invoked: [YES/NO]
- Adversarial techniques applied: [LIST]

### Issues Found During Self-Review
1. [Issue] → [How addressed]

### Assumptions Challenged
1. [Assumption] → [Challenge] → [Conclusion]

### Confidence Level: [LOW/MEDIUM/HIGH]
[Justification]
```

### 3. CHECKPOINT SUMMARY (END OF PHASE)

At the END of your analysis, append to your findings file:

```markdown
---
## Checkpoint Summary

### Phase Completed: [XX]
### Status: [COMPLETE/PARTIAL]
### Files Created: [list]
### Issues Found: X CRITICAL, Y HIGH, Z MEDIUM, W LOW
### Blocking Issues: [any that prevent next phase]
### Ready for Next Phase: [YES/NO]
```

### 4. IF ANYTHING GOES WRONG

- If you cannot write to file: STOP and report error immediately
- If you find CRITICAL issue: Flag it prominently at TOP of file
- If unsure about something: Document as assumption, don't guess
- If running out of context: Write partial findings, mark as PARTIAL

### 5. FILES TO READ FIRST

Before starting analysis:
1. Read `PROTOCOLS.md` for full protocol details
2. Read previous phase findings if relevant
3. Read MANIFEST.md if it exists
```

---

## CHECKLIST FOR ORCHESTRATOR

Before spawning any sub-agent, verify:

- [ ] Output file path is specified in prompt
- [ ] CRITIC requirements are included
- [ ] Checkpoint summary is requested
- [ ] Previous findings path provided (if dependent phase)

After sub-agent returns:

- [ ] Verify file was created in orchestration/
- [ ] Check summary has issue counts
- [ ] Update MANIFEST.md
- [ ] Create checkpoint if switching sessions

---

## PHASE-SPECIFIC PROMPTS

### Phase 01 Prompt Template
```
You are executing Phase 01 (Core Strategy Audit) of the Nautilus Deep Audit.

[Include MANDATORY EXECUTION PROTOCOL above]

## Your Task
Analyze the following files for bugs, Apex compliance, and look-ahead bias:
- nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py
- nautilus_gold_scalper/src/strategies/base_strategy.py
- nautilus_gold_scalper/src/strategies/strategy_selector.py

## Output File
.planning/phases/08-nautilus-deep-audit/orchestration/PHASE_01_FINDINGS.md

## Focus Areas
[Copy from 02-PHASE-01-PLAN.md]

## CRITIC Checklist
[Copy checklist from plan]

BEGIN ANALYSIS.
```

### Parallel Phase Prompt Template (e.g., Phase 02 Round 1 Agent A)
```
You are executing Phase 02 Round 1 Agent A (Indicators) of the Nautilus Deep Audit.

[Include MANDATORY EXECUTION PROTOCOL above]

## Your Task
Analyze the following files:
- nautilus_gold_scalper/src/indicators/regime_detector.py
- nautilus_gold_scalper/src/indicators/session_filter.py
- nautilus_gold_scalper/src/indicators/amd_cycle_tracker.py

## Output File
.planning/phases/08-nautilus-deep-audit/orchestration/PHASE_02_R1_A_FINDINGS.md

## Focus Areas
[Copy from plan]

## Temporal Verification (MANDATORY)
For EACH file, trace data access for 3 random bars.

BEGIN ANALYSIS.
```

---

## SESSION HANDOFF TEMPLATE

When ending a session and starting fresh:

### End of Session
```
Create a handoff document at:
.planning/phases/08-nautilus-deep-audit/orchestration/HANDOFF_SESSION_[N].md

Include:
1. Phases completed this session
2. Current state of MANIFEST.md
3. Any issues needing attention
4. Exact next step to execute
5. Any context the next session needs
```

### Start of New Session
```
Read the following files to understand current state:
1. .planning/phases/08-nautilus-deep-audit/MANIFEST.md (if exists)
2. .planning/phases/08-nautilus-deep-audit/orchestration/HANDOFF_SESSION_[N-1].md
3. .planning/phases/08-nautilus-deep-audit/01-ROADMAP.md (for progress)

Then execute: [next phase command]
```
