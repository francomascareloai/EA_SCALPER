# 🔧 PROMPT: AGENTS.md Dual-Platform Update (V2.0)

## 📋 Objective

Atualizar **AGENTS.md** para refletir dual-platform approach: **Nautilus (Python) como PRIMARY** para desenvolvimento atual, **MQL5 como SECONDARY** (ainda importante para futuro). Adicionar apenas o necessário para suportar Nautilus sem remover ou deprecar MQL5.

**Why it matters:** Projeto está focado em NautilusTrader AGORA mas MQL5 permanece importante para o futuro. AGENTS.md precisa suportar AMBOS sem confusão sobre prioridades.

**Why V2.0:** V1.0 tinha 15 problemas críticos incluindo corruption risk, no verification gates, e marcava MQL5 como "legacy" (incorreto). V2.0 é lightweight, safe, e mantém ambas plataformas ativas.

---

## 📁 Context

**Current AGENTS.md state:**
- Version: 3.4.0
- Size: ~80,000 chars
- Platform focus: Mostly MQL5 references
- Needs: Nautilus support WITHOUT deprecating MQL5

**What we're NOT doing (V1.0 mistakes):**
- ❌ Marking MQL5 as "LEGACY"
- ❌ Removing MQL5 sections
- ❌ Breaking existing droid references
- ❌ Major version bump (stays 3.4.x)

**What we ARE doing (V2.0 approach):**
- ✅ Add Nautilus-specific sections (NEW content)
- ✅ Update FORGE to support BOTH platforms
- ✅ Add Python/Nautilus error recovery (alongside MQL5)
- ✅ Keep MQL5 fully intact and functional
- ✅ Incremental validation (XML check after each edit)
- ✅ Smoke tests before/after

---

## 🎯 Pre-Execution Verification Gates

### Gate 1: Migration Status Check

**BEFORE updating AGENTS.md, verify:**

```
Question: What % of project is migrated to Nautilus?
- [ ] >80% migrated → Proceed with Nautilus PRIMARY
- [ ] 50-80% migrated → Proceed with EQUAL priority (both primary)
- [ ] <50% migrated → ABORT (too early, MQL5 still dominant)

How to check:
1. Count Python files in nautilus_gold_scalper/: {N} files
2. Count MQL5 files in MQL5/: {M} files
3. Check git log recent commits: Nautilus vs MQL5 activity
4. If Nautilus activity >80% → Proceed
```

**If check fails:** ABORT prompt 009, return to user with recommendation to delay update.

---

### Gate 2: Droid Dependency Scan

**BEFORE marking any platform priority, scan droids:**

```bash
# Check how many droids reference MQL5 vs Nautilus
grep -r "MQL5\|mql5" .factory/droids/*.md | wc -l  # MQL5 refs
grep -r "Nautilus\|nautilus" .factory/droids/*.md | wc -l  # Nautilus refs
```

**Decision matrix:**
- MQL5 refs > Nautilus refs → Equal priority (both primary)
- Nautilus refs > MQL5 refs → Nautilus primary, MQL5 secondary
- Close split → Equal priority

**If MQL5 refs still dominant:** Warn user that update may cause confusion.

---

### Gate 3: Backup Verification

```bash
# Create backup with timestamp
cp AGENTS.md "AGENTS_v3.4.0_BACKUP_$(date +%Y%m%d_%H%M%S).md"

# Verify backup created
if [ ! -f AGENTS_v3.4.0_BACKUP_*.md ]; then
    echo "ERROR: Backup failed!"
    exit 1
fi
```

**Rollback procedure:**
```bash
# If update breaks something:
cp AGENTS_v3.4.0_BACKUP_20251207_*.md AGENTS.md
git checkout AGENTS.md  # if committed
```

---

## 🎯 Requirements (Lightweight Additions)

### 1. Add `<platform_support>` Section (NEW)

**Location:** Add AFTER `<session_rules>` section

```xml
<platform_support>
  <description>
    Project supports dual-platform development:
    - PRIMARY: NautilusTrader (Python/Cython) - current focus
    - SECONDARY: MQL5 - important for future, not deprecated
  </description>
  
  <nautilus_trader priority="primary">
    <language>Python 3.11+, Cython for performance</language>
    <architecture>Event-driven (MessageBus, Cache, Actor/Strategy patterns)</architecture>
    <validation>mypy --strict, pytest, ruff</validation>
    <docs_mcp>context7 (NautilusTrader official docs)</docs_mcp>
    <sandbox>e2b (Python sandbox for testing)</sandbox>
    <use_when>
      - New feature development
      - Strategy/Actor implementation
      - Backtesting with ParquetDataCatalog
      - Production deployment (live trading)
    </use_when>
  </nautilus_trader>
  
  <mql5 priority="secondary">
    <language>MQL5</language>
    <compiler>metaeditor64.exe</compiler>
    <validation>Auto-compile with metaeditor64, check .log for errors</validation>
    <docs_mcp>mql5-docs, mql5-books</docs_mcp>
    <use_when>
      - Reference for migration (understand original EA logic)
      - Future MQL5 development (if needed)
      - Comparison/validation against original EA
    </use_when>
    <note>MQL5 is NOT deprecated - remains important for future work</note>
  </mql5>
  
  <routing_rules>
    <rule scenario="New Python/Nautilus code">FORGE (Python mode) or NAUTILUS</rule>
    <rule scenario="New MQL5 code">FORGE (MQL5 mode)</rule>
    <rule scenario="Migration task">NAUTILUS (has migration mappings)</rule>
    <rule scenario="Code review Python">FORGE (Python focus)</rule>
    <rule scenario="Code review MQL5">FORGE (MQL5 knowledge retained)</rule>
  </routing_rules>
</platform_support>
```

**Incremental validation:**
```bash
# After adding section, validate XML
xmllint --noout AGENTS.md 2>&1 | grep -i error
# If errors found, fix before proceeding
```

---

### 2. Update `<bugfix_protocol>` (ADDITIVE)

**Current:**
```xml
<bugfix_protocol>
  <file>MQL5/Experts/BUGFIX_LOG.md</file>
```

**Add alongside (keep MQL5 log):**
```xml
<bugfix_protocol>
  <nautilus_log>nautilus_gold_scalper/BUGFIX_LOG.md</nautilus_log>
  <mql5_log>MQL5/Experts/BUGFIX_LOG.md</mql5_log>
  <format>YYYY-MM-DD (AGENT context)\n- Module: bug fix description.</format>
  <usage>
    <agent name="FORGE">Python/Nautilus fixes → nautilus_log, MQL5 fixes → mql5_log</agent>
    <agent name="NAUTILUS">Migration issues → nautilus_log</agent>
    <agent name="ORACLE">Backtest bugs → nautilus_log (if Nautilus backtest)</agent>
    <agent name="SENTINEL">Risk logic → nautilus_log (Python risk modules)</agent>
  </usage>
  <note>Both logs active - use appropriate log based on platform</note>
</bugfix_protocol>
```

**Incremental validation:** XML check

---

### 3. Update `<forge_rule>` (EXPAND, not replace)

**Current:**
```xml
<forge_rule priority="P0.5">
  FORGE MUST auto-compile after ANY MQL5 change. Fix errors BEFORE reporting. NEVER deliver non-compiling code!
</forge_rule>
```

**Expand to:**
```xml
<forge_rule priority="P0.5">
  FORGE MUST validate code after ANY change:
  
  <python_nautilus>
    - Run mypy --strict on changed files
    - Run pytest on affected modules
    - Fix errors BEFORE reporting
    - NEVER deliver non-passing code
  </python_nautilus>
  
  <mql5>
    - Auto-compile with metaeditor64
    - Fix compilation errors BEFORE reporting
    - NEVER deliver non-compiling code
  </mql5>
  
  FORGE auto-detects platform from file extension (.py → Python, .mq5 → MQL5).
</forge_rule>
```

**Incremental validation:** XML check

---

### 4. Add Python/Nautilus Error Recovery (NEW protocols)

**Location:** Add INSIDE existing `<error_recovery>` section (keep all existing protocols)

```xml
<!-- ADD these NEW protocols, keep ALL existing ones -->

<protocol agent="FORGE" name="Python Type/Import Errors - 3-Strike Rule">
  <platform>Nautilus (Python)</platform>
  <attempt number="1" type="Auto">
    <action>Run mypy --strict on affected file</action>
    <action>Identify missing imports or type annotations</action>
    <action>Apply fixes</action>
    <action>Re-run mypy</action>
  </attempt>
  <attempt number="2" type="RAG-Assisted">
    <action>Query context7 for NautilusTrader patterns with error message</action>
    <action>Apply suggested fix</action>
    <action>Run pytest on module</action>
  </attempt>
  <attempt number="3" type="Escalate">
    <action>ASK: "Debug manually or skip?"</action>
    <action>NEVER try 4+ times without intervention</action>
  </attempt>
  <example>Error "Module 'nautilus_trader.model' has no attribute 'OrderSide'" → Query context7: "OrderSide nautilus" → Fix: from nautilus_trader.model.enums import OrderSide → SUCCESS</example>
</protocol>

<protocol agent="NAUTILUS" name="Event-Driven Pattern Violation">
  <platform>Nautilus (Python)</platform>
  <detection>
    - Blocking calls in on_bar/on_quote_tick handlers (>1ms)
    - Global state usage
    - Direct data access outside Cache
    - Missing async cleanup in on_stop()
  </detection>
  <resolution>
    <step>Identify blocking operation</step>
    <step>Refactor to async/await if I/O</step>
    <step>Move state to Actor attributes</step>
    <step>Use Cache for data access</step>
    <step>Add cleanup in on_stop()</step>
  </resolution>
  <example>Error "on_bar took 5ms" → Move DB query to Actor → Publish via MessageBus → Strategy receives async → SUCCESS</example>
</protocol>
```

**Incremental validation:** XML check after adding protocols

---

### 5. Update `<agents>` Section (FORGE only)

**Current:**
```xml
<agent>
  <emoji>⚒️</emoji>
  <name>FORGE</name>
  <use_for>Code/MQL5/Python</use_for>
  <triggers>"Forge", /codigo, /review</triggers>
  <primary_mcps>metaeditor64★, mql5-docs★, github, e2b</primary_mcps>
</agent>
```

**Update to:**
```xml
<agent>
  <emoji>⚒️</emoji>
  <name>FORGE</name>
  <use_for>Code/Python/Nautilus (primary), Code/MQL5 (secondary)</use_for>
  <triggers>"Forge", /codigo, /review</triggers>
  <primary_mcps>
    Nautilus: context7★ (docs), e2b★ (sandbox)
    MQL5: metaeditor64, mql5-docs
    Both: github (repos), sequential-thinking (complex bugs)
  </primary_mcps>
  <validation>
    Python: mypy + pytest
    MQL5: metaeditor64 auto-compile
  </validation>
  <note>FORGE supports BOTH platforms - auto-detects from file extension</note>
</agent>
```

**Incremental validation:** XML check

---

### 6. Add Examples for Nautilus (ADDITIVE)

**Find existing examples** in `<complexity_assessment>` and ADD Nautilus equivalents:

**Example additions:**
```xml
<!-- In MEDIUM complexity examples -->
<example>"Fix type error in Nautilus Strategy module"</example>
<example>"Add logging to Nautilus Actor"</example>

<!-- In COMPLEX complexity examples -->
<example>"Implement new Actor for RSI divergence detection"</example>
<example>"Refactor risk module for Apex compliance (Python)"</example>

<!-- Keep ALL existing MQL5 examples -->
```

---

## 📤 Output & Validation

### Execution Steps (SAFE, incremental)

```
STEP 1: Pre-execution gates
├─ Gate 1: Migration status check (>80% Nautilus?) ✅
├─ Gate 2: Droid dependency scan ✅
└─ Gate 3: Backup creation + verification ✅

STEP 2: Add platform_support section
├─ Add XML after <session_rules>
├─ Incremental validation: xmllint check ✅
└─ Git add + commit: "feat: add platform_support (Nautilus primary, MQL5 secondary)"

STEP 3: Update bugfix_protocol
├─ Add nautilus_log alongside mql5_log
├─ Incremental validation: xmllint check ✅
└─ Git add + commit: "feat: dual bugfix logs (Nautilus + MQL5)"

STEP 4: Expand forge_rule
├─ Add Python validation rules
├─ Incremental validation: xmllint check ✅
└─ Git add + commit: "feat: FORGE dual-platform validation"

STEP 5: Add Python error recovery protocols
├─ Add 2 NEW protocols INSIDE <error_recovery>
├─ Incremental validation: xmllint check ✅
└─ Git add + commit: "feat: Python/Nautilus error recovery protocols"

STEP 6: Update FORGE agent metadata
├─ Update use_for, primary_mcps, add validation note
├─ Incremental validation: xmllint check ✅
└─ Git add + commit: "feat: FORGE dual-platform metadata"

STEP 7: Add Nautilus examples
├─ Add examples in complexity_assessment
├─ Incremental validation: xmllint check ✅
└─ Git add + commit: "docs: add Nautilus examples to complexity levels"

STEP 8: Version bump + changelog
├─ Update <metadata> version: 3.4.0 → 3.4.1
├─ Add <changelog> entry
├─ Final validation: xmllint full file ✅
└─ Git add + commit: "chore: bump version 3.4.1 (dual-platform support)"

STEP 9: Post-execution smoke tests
├─ Invoke FORGE with Python task: "List Python files in nautilus_gold_scalper/"
├─ Invoke FORGE with MQL5 task: "List MQL5 files in MQL5/"
├─ Verify both work correctly ✅
└─ If failures detected: Git revert + restore backup
```

---

### Output File

**File:** `.prompts/009-agents-nautilus-update/agents-nautilus-update-v2-completion.md`

```xml
<agents_nautilus_update_v2>
  <metadata>
    <version>3.4.1</version>
    <date>{YYYY-MM-DD}</date>
    <change_type>Dual-platform support (additive)</change_type>
    <approach>Lightweight additions, MQL5 fully retained</approach>
  </metadata>
  
  <pre_execution_gates>
    <gate name="migration_status" result="PASS">
      Nautilus activity: {XX}%
      Threshold: >80%
      Decision: Proceed with Nautilus PRIMARY
    </gate>
    <gate name="droid_dependencies" result="PASS">
      MQL5 refs: {N}
      Nautilus refs: {M}
      Decision: Nautilus {primary|equal} based on ratio
    </gate>
    <gate name="backup" result="PASS">
      Backup file: AGENTS_v3.4.0_BACKUP_{timestamp}.md
      Verified: ✅
    </gate>
  </pre_execution_gates>
  
  <changes_applied>
    <change step="1" section="platform_support">
      Action: Added NEW section after <session_rules>
      Validation: xmllint PASS ✅
      Git commit: {hash}
    </change>
    
    <change step="2" section="bugfix_protocol">
      Action: Added nautilus_log alongside mql5_log
      Validation: xmllint PASS ✅
      Git commit: {hash}
    </change>
    
    <change step="3" section="forge_rule">
      Action: Expanded to support Python + MQL5 validation
      Validation: xmllint PASS ✅
      Git commit: {hash}
    </change>
    
    <change step="4" section="error_recovery">
      Action: Added 2 NEW protocols (Python Type/Import + Event-Driven Pattern)
      Existing protocols: KEPT (no deletions)
      Validation: xmllint PASS ✅
      Git commit: {hash}
    </change>
    
    <change step="5" section="agents (FORGE)">
      Action: Updated use_for, primary_mcps, added validation note
      Validation: xmllint PASS ✅
      Git commit: {hash}
    </change>
    
    <change step="6" section="complexity_assessment">
      Action: Added Nautilus examples (KEPT all MQL5 examples)
      Validation: xmllint PASS ✅
      Git commit: {hash}
    </change>
    
    <change step="7" section="metadata">
      Action: Version 3.4.0 → 3.4.1, added changelog
      Validation: xmllint full file PASS ✅
      Git commit: {hash}
    </change>
  </changes_applied>
  
  <smoke_tests>
    <test name="FORGE Python task" result="PASS">
      Task: "List Python files in nautilus_gold_scalper/"
      Output: {file list}
      Validation: ✅ FORGE responded correctly
    </test>
    
    <test name="FORGE MQL5 task" result="PASS">
      Task: "List MQL5 files in MQL5/"
      Output: {file list}
      Validation: ✅ FORGE responded correctly with MQL5 knowledge
    </test>
    
    <test name="XML integrity" result="PASS">
      Command: xmllint --noout AGENTS.md
      Result: No errors
      Validation: ✅ AGENTS.md XML valid
    </test>
  </smoke_tests>
  
  <version_update>
    <from>3.4.0</from>
    <to>3.4.1</to>
    <changelog>
      - Added dual-platform support (Nautilus PRIMARY, MQL5 SECONDARY)
      - Added <platform_support> section with routing rules
      - Expanded FORGE to support Python/Nautilus validation (mypy + pytest)
      - Added Python/Nautilus error recovery protocols (2 NEW)
      - Added Nautilus examples to complexity assessment
      - MQL5 fully retained (NOT deprecated, important for future)
    </changelog>
  </version_update>
  
  <rollback_if_needed>
    <command>cp AGENTS_v3.4.0_BACKUP_{timestamp}.md AGENTS.md</command>
    <command>git revert {commit_hashes}</command>
  </rollback_if_needed>
  
  <next_steps>
    <step>Review AGENTS.md v3.4.1 changes</step>
    <step>Test droids in real session (FORGE with Python + MQL5 tasks)</step>
    <step>Execute 010-droid-refactoring-master-v2.md (if approved)</step>
  </next_steps>
  
  <confidence>HIGH</confidence>
  <breaking_changes>NONE (additive only, MQL5 fully functional)</breaking_changes>
  
  <improvements_over_v1>
    <improvement>Pre-execution verification gates (migration status, dependencies, backup)</improvement>
    <improvement>Incremental XML validation (after each edit, not just at end)</improvement>
    <improvement>Granular git commits (7 commits, easy rollback per-step)</improvement>
    <improvement>Post-execution smoke tests (verify FORGE works for both platforms)</improvement>
    <improvement>MQL5 NOT marked as legacy (remains important for future)</improvement>
    <improvement>Additive approach (no deletions, no breaking changes)</improvement>
    <improvement>Clear rollback procedure (backup + git revert commands)</improvement>
    <improvement>Realistic execution time (1-1.5h with validation, not 15-20 min)</improvement>
  </improvements_over_v1>
</agents_nautilus_update_v2>
```

---

## ✅ Success Criteria

**Pre-execution:**
- [ ] Migration status >80% Nautilus (or user approved equal priority)
- [ ] Droid dependency scan completed
- [ ] Backup created and verified

**During execution:**
- [ ] Each XML edit followed by xmllint validation
- [ ] 7 granular git commits (one per step)
- [ ] No XML syntax errors at any point

**Post-execution:**
- [ ] Smoke test 1: FORGE responds correctly to Python task
- [ ] Smoke test 2: FORGE responds correctly to MQL5 task
- [ ] Final XML validation: xmllint full file PASS
- [ ] Version updated: 3.4.0 → 3.4.1
- [ ] Changelog includes all changes
- [ ] MQL5 sections fully functional (not deprecated)

**If ANY criterion fails:** Execute rollback procedure immediately.

---

## 🎯 Estimated Time

- Pre-execution gates: 15 min
- Step 1-2 (platform_support + bugfix_protocol): 20 min
- Step 3-4 (forge_rule + error_recovery): 20 min
- Step 5-6 (agents + examples): 15 min
- Step 7-8 (version + changelog): 10 min
- Step 9 (smoke tests): 10 min
- **Total: 1h 30min** (realistic, with validation and safety checks)

---

## 🚨 CRITICAL NOTES

1. **MQL5 is NOT deprecated** - Remains fully functional and important
2. **Additive only** - No deletions, no "legacy" labels
3. **Incremental validation** - XML check after EACH edit
4. **Granular commits** - 7 commits for easy per-step rollback
5. **Smoke tests mandatory** - Test BOTH platforms before declaring success

---

**EXECUTE THIS PROMPT WITH:** claude-sonnet-4 (precision + safety required)
