---
name: create-plan
description: Create hierarchical project plans for solo agentic development (briefs, roadmaps, phase plans) using XML format
argument-hint: [what to plan]
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Task
  - AskUserQuestion
---

<objective>
Create a Claude-executable project plan for: $ARGUMENTS

This command enables hierarchical project planning optimized for solo agentic development.
Plans are written in XML format that Claude can execute without interpretation.
</objective>

<skill_knowledge>
Load and follow the patterns from these reference files:

**Core skill definition:**
@~/.claude/plugins/marketplaces/taches-cc-resources/skills/create-plans/SKILL.md

**Plan format (CRITICAL - defines XML structure for PLAN.md):**
@~/.claude/plugins/marketplaces/taches-cc-resources/skills/create-plans/references/plan-format.md

**Templates:**
@~/.claude/plugins/marketplaces/taches-cc-resources/skills/create-plans/templates/phase-prompt.md
@~/.claude/plugins/marketplaces/taches-cc-resources/skills/create-plans/templates/brief.md
@~/.claude/plugins/marketplaces/taches-cc-resources/skills/create-plans/templates/roadmap.md
</skill_knowledge>

<dynamic_context>
Current planning state:
- Planning folder: !`ls -la .planning/ 2>/dev/null || echo "No .planning folder found"`
- Existing brief: !`cat .planning/BRIEF.md 2>/dev/null | head -30 || echo "No BRIEF.md"`
- Existing roadmap: !`cat .planning/ROADMAP.md 2>/dev/null | head -50 || echo "No ROADMAP.md"`
- Continue-here files: !`find . -name ".continue-here*.md" -type f 2>/dev/null || echo "No handoff files"`
- Git status: !`git rev-parse --git-dir 2>/dev/null && echo "Git repo exists" || echo "No git repo"`
</dynamic_context>

<process>
1. **Scan context** - Check dynamic_context above to understand current planning state

2. **Determine workflow** based on state:
   - No .planning folder → Offer to create brief first
   - Has BRIEF but no ROADMAP → Create roadmap from brief
   - Has ROADMAP → Plan next phase or specific phase
   - Has .continue-here file → Offer to resume from handoff
   - User specified "$ARGUMENTS" → Interpret intent and route appropriately

3. **Route to appropriate workflow:**
   | Intent | Workflow file to load |
   |--------|----------------------|
   | "brief", "new project" | @~/.claude/plugins/marketplaces/taches-cc-resources/skills/create-plans/workflows/create-brief.md |
   | "roadmap", "phases" | @~/.claude/plugins/marketplaces/taches-cc-resources/skills/create-plans/workflows/create-roadmap.md |
   | "phase", "plan phase" | @~/.claude/plugins/marketplaces/taches-cc-resources/skills/create-plans/workflows/plan-phase.md |
   | "research", "investigate" | @~/.claude/plugins/marketplaces/taches-cc-resources/skills/create-plans/workflows/research-phase.md |
   | "handoff", "stopping" | @~/.claude/plugins/marketplaces/taches-cc-resources/skills/create-plans/workflows/handoff.md |
   | "resume", "continue" | @~/.claude/plugins/marketplaces/taches-cc-resources/skills/create-plans/workflows/resume.md |

4. **Follow the workflow** - Read and execute the workflow file exactly

5. **Create artifacts** - All plans MUST use XML format from plan-format.md:
   - PLAN.md files use `<objective>`, `<context>`, `<tasks>`, `<verification>`, `<success_criteria>`, `<output>`
   - Tasks use `<task type="auto">` with `<name>`, `<files>`, `<action>`, `<verify>`, `<done>`
   - Checkpoints use `<task type="checkpoint:human-verify">` or `<task type="checkpoint:decision">`

6. **Save to .planning/** - Create files in proper hierarchy:
   ```
   .planning/
   ├── BRIEF.md
   ├── ROADMAP.md
   └── phases/
       └── XX-name/
           ├── XX-YY-PLAN.md
           └── XX-YY-SUMMARY.md
   ```
</process>

<xml_plan_structure>
Every PLAN.md MUST follow this structure:

```xml
---
phase: XX-name
type: execute
---

<objective>
[What this phase accomplishes]

Purpose: [Why this matters]
Output: [What artifacts will be created]
</objective>

<context>
@.planning/BRIEF.md
@.planning/ROADMAP.md
@relevant/source/files
</context>

<tasks>

<task type="auto">
  <name>Task N: [Action-oriented name]</name>
  <files>path/to/file.ext</files>
  <action>[Specific implementation - what to do, what to avoid and WHY]</action>
  <verify>[Command or check to prove it worked]</verify>
  <done>[Measurable acceptance criteria]</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>[What Claude automated]</what-built>
  <how-to-verify>
    1. Run: [command]
    2. Visit: [URL]
    3. Confirm: [expected behavior]
  </how-to-verify>
  <resume-signal>Type "approved" or describe issues</resume-signal>
</task>

</tasks>

<verification>
- [ ] [Specific test command]
- [ ] [Build passes]
- [ ] [Behavior verification]
</verification>

<success_criteria>
- All tasks completed
- All verification checks pass
- [Phase-specific criteria]
</success_criteria>

<output>
After completion, create `.planning/phases/XX-name/XX-YY-SUMMARY.md`
</output>
```
</xml_plan_structure>

<essential_principles>
From the create-plans skill:

1. **Solo developer + Claude** - No teams, no ceremonies. User = visionary, Claude = builder.

2. **Plans are prompts** - PLAN.md IS the prompt Claude executes. Not documentation.

3. **Scope control** - Plans must complete within ~50% context. Split into small atomic plans (2-3 tasks each).

4. **Human checkpoints** - Claude automates everything with CLI/API. Checkpoints are for verification and decisions only.

5. **Deviation rules** - Auto-fix bugs, auto-add critical, auto-fix blockers, ask about architectural, log enhancements to ISSUES.md.
</essential_principles>

<mandatory_execution_protocol>
**EVERY phase plan MUST include this protocol section after Metadata:**

```markdown
## MANDATORY EXECUTION PROTOCOL

**ESTE PROTOCOLO DEVE SER SEGUIDO EM TODAS AS ACOES:**

### 1. Autonomous Loop (CRITIC ate GO)
\`\`\`
Executar task → CRITIC review (opus) → GO?
                      ↓ NO
                Fix automatico → CRITIC review → loop (max 3x)
                      ↓ ainda NO-GO apos 3x
                Perguntar usuario
\`\`\`

### 2. Quick Backtest Apos Cada Fix
\`\`\`bash
# OBRIGATORIO apos qualquer mudanca de codigo
python -m nautilus_gold_scalper.run_backtest --start 2024-01-01 --end 2024-01-07

# Verificar:
# - Trades > 0 (senao algo quebrou)
# - Sem erros no log
# - Trade count nao caiu 50%+
\`\`\`

### 3. Parallel Agents (sem limite)
- Pode spawnar multiplos agents em paralelo para fixes
- FORGE + ORACLE + SENTINEL simultaneo se necessario
- Nao economizar - usar quantos precisar

### 4. Anti-Hallucination
- SEMPRE mostrar output dos comandos
- NUNCA dizer "deve funcionar" sem testar
- NUNCA inventar metricas - usar output real

### 5. Consultar Documentacao NautilusTrader
\`\`\`bash
# ANTES de escrever codigo NautilusTrader:
# 1. Buscar em external/nautilus_trader/examples/
# 2. Buscar em external/nautilus_trader/docs/
# 3. Se nao encontrar: usar context7 MCP para docs atualizados
# 4. NUNCA inventar APIs - sempre verificar assinatura real
rg -n "metodo_ou_classe" external/nautilus_trader/
\`\`\`

### 6. Verificacao Obrigatoria
\`\`\`bash
# Antes de qualquer GO:
mypy --strict nautilus_gold_scalper/
pytest -q
# Quick backtest (1 semana)
\`\`\`
```

**WHY this matters:**
- Autonomous loop: Agent fixes issues without asking, only escalates after 3 failed attempts
- Quick backtest: Empirical verification catches regressions immediately
- Parallel agents: Maximize speed with unlimited compute resources
- Anti-hallucination: Prevents fabricated metrics or untested claims
- NautilusTrader docs: Prevents API hallucination by requiring source verification
- Verification: Ensures code quality before marking phase complete
</mandatory_execution_protocol>

<success_criteria>
- Context scanned and understood
- Appropriate workflow selected based on state and user intent
- Plan artifacts created in XML format
- **MANDATORY EXECUTION PROTOCOL included in every phase plan**
- Files saved to .planning/ with proper hierarchy
- User understands next steps
</success_criteria>
