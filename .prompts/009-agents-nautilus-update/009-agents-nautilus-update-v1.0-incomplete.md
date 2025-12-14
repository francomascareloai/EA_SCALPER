# 🔧 PROMPT: Ajustar AGENTS.md para Nautilus Focus

## 📋 Objective

Atualizar **AGENTS.md** para refletir a mudança de foco do projeto de MQL5 para **NautilusTrader (Python)** como plataforma principal de desenvolvimento. Ajustar seções de bugfix_protocol, forge_rule, error_recovery, e exemplos para referenciar Nautilus ao invés de MQL5.

**Why it matters:** O projeto migrou de EA MQL5 para NautilusTrader Python. AGENTS.md ainda referencia MQL5 em vários lugares, causando confusão e direcionamento incorreto para FORGE (que agora trabalha mais com Python/Nautilus do que MQL5).

---

## 📁 Context

**Current AGENTS.md sections referencing MQL5:**

From Grep results:
```
<bugfix_protocol>
  <file>MQL5/Experts/BUGFIX_LOG.md</file>
  <usage>
    <agent name="FORGE">all MQL5/Python fixes</agent>

<forge_rule priority="P0.5">
  FORGE MUST auto-compile after ANY MQL5 change...

<mql5_compilation>
  <paths>
    <compiler>C:\Program Files\FTMO MetaTrader 5\metaeditor64.exe</compiler>

<error_recovery>
  <protocol agent="FORGE" name="Compilation Failure - 3-Strike Rule">
    <attempt number="1" type="Auto">
      <action>Verify includes paths (PROJECT_MQL5 + STDLIB_MQL5)</action>
```

**New Reality:**
- Primary platform: **NautilusTrader (Python/Cython)**
- Primary bug location: `nautilus_gold_scalper/` (Python modules)
- Primary errors: Python syntax, Nautilus event-driven patterns, async issues
- Compilation: **Python type checking + pytest**, not MQL5 metaeditor64

**Nautilus project structure:**
```
nautilus_gold_scalper/
├── src/
│   ├── strategies/
│   ├── actors/
│   ├── indicators/
│   ├── risk/
│   ├── execution/
│   └── signals/
├── configs/
├── scripts/
└── tests/
```

---

## 🎯 Requirements

### 1. Update `<bugfix_protocol>`

**Current:**
```xml
<bugfix_protocol>
  <file>MQL5/Experts/BUGFIX_LOG.md</file>
  <format>YYYY-MM-DD (AGENT context)\n- Module: bug fix description.</format>
  <usage>
    <agent name="FORGE">all MQL5/Python fixes</agent>
    <agent name="ORACLE">backtest bugs</agent>
    <agent name="SENTINEL">risk logic bugs</agent>
  </usage>
</bugfix_protocol>
```

**Change to:**
```xml
<bugfix_protocol>
  <primary_log>nautilus_gold_scalper/BUGFIX_LOG.md</primary_log>
  <legacy_log>MQL5/Experts/BUGFIX_LOG.md</legacy_log>
  <format>YYYY-MM-DD (AGENT context)\n- Module: bug fix description.</format>
  <usage>
    <agent name="FORGE">all Python/Nautilus fixes (primary), MQL5 fixes (legacy)</agent>
    <agent name="NAUTILUS">migration issues, Actor/Strategy bugs</agent>
    <agent name="ORACLE">backtest bugs (Nautilus backtests)</agent>
    <agent name="SENTINEL">risk logic bugs (Python risk modules)</agent>
  </usage>
  <note>Primary development on NautilusTrader (Python). MQL5 is legacy/reference only.</note>
</bugfix_protocol>
```

---

### 2. Update `<forge_rule>` for Python Focus

**Current:**
```xml
<forge_rule priority="P0.5">
  FORGE MUST auto-compile after ANY MQL5 change. Fix errors BEFORE reporting. NEVER deliver non-compiling code!
</forge_rule>
```

**Change to:**
```xml
<forge_rule priority="P0.5">
  FORGE MUST validate Python code after ANY Nautilus change:
  - Run mypy type checking
  - Run pytest on affected modules
  - Fix errors BEFORE reporting
  - NEVER deliver non-passing code!
  
  For legacy MQL5 (if touched):
  - Auto-compile with metaeditor64
  - Fix compilation errors
</forge_rule>
```

---

### 3. Update `<error_recovery>` for Python/Nautilus

**Current:**
```xml
<error_recovery>
  <protocol agent="FORGE" name="Compilation Failure - 3-Strike Rule">
    <attempt number="1" type="Auto">
      <action>Verify includes paths (PROJECT_MQL5 + STDLIB_MQL5)</action>
      <action>Recompile with /log</action>
      <action>Read .log for error line</action>
    </attempt>
    <attempt number="2" type="RAG-Assisted">
      <action>Query `mql5-docs` RAG with error message</action>
      <action>Apply suggested fix</action>
      <action>Recompile</action>
    </attempt>
    <attempt number="3" type="Escalate">
      <action>ASK: "Debug manually or skip?"</action>
      <action>NEVER try 4+ times without intervention</action>
    </attempt>
    <example>Error "undeclared identifier 'PositionSelect'" → Query RAG: "PositionSelect syntax MQL5" → Fix: Add `#include &lt;Trade\Trade.mqh>` → Recompile SUCCESS</example>
  </protocol>
  <protocol agent="ORACLE" name="Backtest Non-Convergence">
    <!-- KEEP AS IS - still valid -->
  </protocol>
</error_recovery>
```

**Add NEW protocol for Python/Nautilus:**
```xml
<error_recovery>
  <protocol agent="FORGE" name="Python Type/Import Errors - 3-Strike Rule">
    <attempt number="1" type="Auto">
      <action>Run mypy on affected file: mypy --strict nautilus_gold_scalper/src/module.py</action>
      <action>Read type errors and identify missing imports/type annotations</action>
      <action>Apply fixes</action>
      <action>Re-run mypy</action>
    </attempt>
    <attempt number="2" type="RAG-Assisted">
      <action>Query `context7` for NautilusTrader patterns with error message</action>
      <action>Check mql5-books for trading concepts if logic error</action>
      <action>Apply suggested fix</action>
      <action>Run pytest on module</action>
    </attempt>
    <attempt number="3" type="Escalate">
      <action>ASK: "Debug manually or skip?"</action>
      <action>NEVER try 4+ times without intervention</action>
    </attempt>
    <example>Error "Module 'nautilus_trader.model' has no attribute 'OrderSide'" → Query context7: "OrderSide nautilus" → Fix: Import from correct submodule `from nautilus_trader.model.enums import OrderSide` → Retest SUCCESS</example>
  </protocol>
  
  <protocol agent="NAUTILUS" name="Event-Driven Pattern Violation">
    <detection>
      - Blocking calls in on_bar/on_quote_tick handlers (>1ms)
      - Global state usage (violates event-driven architecture)
      - Direct data access outside Cache
      - Missing async cleanup in on_stop()
    </detection>
    <resolution>
      <step>Identify blocking operation or state violation</step>
      <step>Refactor to async/await if I/O operation</step>
      <step>Move state to Actor attributes (no globals)</step>
      <step>Use Cache for data access, subscribe to data feed</step>
      <step>Add cleanup in on_stop()</step>
    </resolution>
    <example>Error "on_bar took 5ms (>1ms budget)" → Identify: Database query blocking → Fix: Move query to Actor, publish result via MessageBus → Strategy receives event (async) → Retest SUCCESS</example>
  </protocol>
  
  <protocol agent="FORGE" name="MQL5 Compilation Failure - 3-Strike Rule (LEGACY)">
    <note>Use ONLY for legacy MQL5 reference code. Primary development is Python/Nautilus.</note>
    <attempt number="1" type="Auto">
      <action>Verify includes paths (PROJECT_MQL5 + STDLIB_MQL5)</action>
      <action>Recompile with /log</action>
      <action>Read .log for error line</action>
    </attempt>
    <attempt number="2" type="RAG-Assisted">
      <action>Query `mql5-docs` RAG with error message</action>
      <action>Apply suggested fix</action>
      <action>Recompile</action>
    </attempt>
    <attempt number="3" type="Escalate">
      <action>ASK: "Debug manually or skip?"</action>
      <action>NEVER try 4+ times without intervention</action>
    </attempt>
  </protocol>
  
  <protocol agent="ORACLE" name="Backtest Non-Convergence">
    <!-- KEEP AS IS - still valid -->
  </protocol>
</error_recovery>
```

---

### 4. Update `<mql5_compilation>` Section Name

**Current:**
```xml
<mql5_compilation>
  <paths>
    <compiler>C:\Program Files\FTMO MetaTrader 5\metaeditor64.exe</compiler>
    <project>C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MQL5</project>
    <stdlib>C:\Program Files\FTMO MetaTrader 5\MQL5</stdlib>
  </paths>
  <commands>
    <!-- commands -->
  </commands>
  <common_errors>
    <!-- errors -->
  </common_errors>
</mql5_compilation>
```

**Rename and add Python section:**
```xml
<compilation_validation>
  <python_nautilus>
    <type_checking>
      <tool>mypy</tool>
      <command>mypy --strict nautilus_gold_scalper/src/</command>
      <config>pyproject.toml [tool.mypy] section</config>
    </type_checking>
    <testing>
      <tool>pytest</tool>
      <command>pytest nautilus_gold_scalper/tests/ -v</command>
      <coverage>pytest --cov=nautilus_gold_scalper --cov-report=term</coverage>
    </testing>
    <linting>
      <tool>ruff</tool>
      <command>ruff check nautilus_gold_scalper/</command>
    </linting>
    <common_errors>
      <error symptom="Module has no attribute">Import error - wrong submodule</error>
      <error symptom="Incompatible type">Type annotation mismatch</error>
      <error symptom="Event loop closed">Async cleanup missing in on_stop()</error>
      <error symptom="blocking call in on_bar">Performance violation (>1ms)</error>
    </common_errors>
  </python_nautilus>
  
  <mql5_legacy>
    <note>Legacy reference code only. Primary development is Python/Nautilus.</note>
    <paths>
      <compiler>C:\Program Files\FTMO MetaTrader 5\metaeditor64.exe</compiler>
      <project>C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MQL5</project>
      <stdlib>C:\Program Files\FTMO MetaTrader 5\MQL5</stdlib>
    </paths>
    <commands>
      <!-- KEEP existing commands -->
    </commands>
    <common_errors>
      <!-- KEEP existing errors -->
    </common_errors>
  </mql5_legacy>
</compilation_validation>
```

---

### 5. Update Examples Throughout AGENTS.md

Search and replace examples that reference MQL5 with Nautilus equivalents:

**Current examples:**
- "Migrate EA from MQL5 to NautilusTrader" (CRITICAL complexity)
- "Fix compilation error in indicator" (MEDIUM complexity)
- "FORGE: all MQL5/Python fixes"

**Update to prioritize Nautilus:**
- "Implement new Actor for RSI divergence" (COMPLEX)
- "Fix type error in Strategy module" (MEDIUM)
- "Refactor risk module for Apex compliance" (COMPLEX)
- "FORGE: all Python/Nautilus fixes (primary), MQL5 fixes (legacy)"

---

### 6. Update `<agents>` Section

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

**Change to:**
```xml
<agent>
  <emoji>⚒️</emoji>
  <name>FORGE</name>
  <use_for>Code/Python/Nautilus (primary), MQL5 (legacy)</use_for>
  <triggers>"Forge", /codigo, /review</triggers>
  <primary_mcps>context7★ (Nautilus docs), e2b★ (Python sandbox), github, mql5-docs (legacy)</primary_mcps>
  <validation>mypy + pytest for Python, metaeditor64 for legacy MQL5</validation>
</agent>
```

---

### 7. Update `<mcp_tooling>` Section

**Current FORGE MCPs:**
```xml
<agent name="FORGE">
  <mcp name="metaeditor64" primary="true">compile MQL5 AUTO</mcp>
  <mcp name="mql5-docs" primary="true">syntax/functions</mcp>
  <mcp name="mql5-books">patterns/arch</mcp>
  <mcp name="github">search repos</mcp>
  <mcp name="context7">lib docs</mcp>
  <mcp name="e2b">Python sandbox</mcp>
</agent>
```

**Change to:**
```xml
<agent name="FORGE">
  <mcp name="context7" primary="true">NautilusTrader docs, Python libs</mcp>
  <mcp name="e2b" primary="true">Python sandbox, pytest runner</mcp>
  <mcp name="github">search repos (Nautilus examples)</mcp>
  <mcp name="mql5-docs">syntax/functions (LEGACY)</mcp>
  <mcp name="metaeditor64">compile MQL5 (LEGACY)</mcp>
  <mcp name="mql5-books">patterns/arch (reference only)</mcp>
</agent>
```

---

## 📤 Output

### File to Edit
**File:** `AGENTS.md` (in-place edits)

### Backup
Before editing, create backup:
```bash
cp AGENTS.md AGENTS_v3.4_BACKUP_PRE_NAUTILUS_UPDATE.md
```

### Changes Summary

Document all changes in output XML:

```xml
<agents_md_nautilus_update>
  <metadata>
    <version>3.4.1</version>
    <date>{YYYY-MM-DD}</date>
    <change_type>Nautilus focus migration</change_type>
  </metadata>
  
  <backup>
    <file>AGENTS_v3.4_BACKUP_PRE_NAUTILUS_UPDATE.md</file>
    <status>created</status>
  </backup>
  
  <changes>
    <change section="bugfix_protocol">
      <action>Updated primary log to nautilus_gold_scalper/BUGFIX_LOG.md</action>
      <action>Added NAUTILUS agent to usage</action>
      <action>Marked MQL5 as legacy</action>
    </change>
    
    <change section="forge_rule">
      <action>Changed from MQL5 auto-compile to Python validation (mypy + pytest)</action>
      <action>Added legacy note for MQL5 compilation</action>
    </change>
    
    <change section="error_recovery">
      <action>Added "Python Type/Import Errors - 3-Strike Rule" protocol</action>
      <action>Added "Event-Driven Pattern Violation" protocol for NAUTILUS</action>
      <action>Marked MQL5 compilation protocol as LEGACY</action>
    </change>
    
    <change section="mql5_compilation">
      <action>Renamed to compilation_validation</action>
      <action>Added python_nautilus subsection with mypy, pytest, ruff</action>
      <action>Moved MQL5 to mql5_legacy subsection</action>
    </change>
    
    <change section="agents">
      <action>Updated FORGE use_for: Python/Nautilus (primary), MQL5 (legacy)</action>
      <action>Updated FORGE primary_mcps: context7★, e2b★ (Python focus)</action>
      <action>Added validation note: mypy + pytest for Python</action>
    </change>
    
    <change section="mcp_tooling">
      <action>FORGE: context7 and e2b now primary (was metaeditor64 + mql5-docs)</action>
      <action>FORGE: mql5-docs and metaeditor64 marked LEGACY</action>
    </change>
    
    <change section="examples">
      <action>Updated COMPLEX example: "Migrate EA from MQL5" → "Implement new Actor for RSI"</action>
      <action>Updated MEDIUM example: "Fix compilation error" → "Fix type error in Strategy"</action>
      <action>Added Nautilus-specific examples throughout</action>
    </change>
  </changes>
  
  <version_update>
    <from>3.4.0</from>
    <to>3.4.1</to>
    <changelog>
      - Primary platform: MQL5 → NautilusTrader (Python)
      - FORGE focus: Python/Nautilus with mypy + pytest validation
      - MQL5 marked as LEGACY (reference only)
      - Added Python/Nautilus error recovery protocols
      - Updated all examples to Nautilus context
    </changelog>
  </version_update>
  
  <next_steps>
    <step>Review AGENTS.md v3.4.1 changes</step>
    <step>Execute 010-droid-refactoring-master.md (FASE 2-4)</step>
    <step>Update all droids to inherit from AGENTS.md v3.4.1</step>
  </next_steps>
  
  <confidence>HIGH</confidence>
  <dependencies>
    <dependency>Backup created before edits</dependency>
    <dependency>Version updated in metadata (3.4.0 → 3.4.1)</dependency>
  </dependencies>
  
  <open_questions>
    <question>Should MQL5 be completely removed or kept as legacy reference?</question>
    <answer>KEEP as legacy - useful for migration understanding and reference</answer>
  </open_questions>
  
  <assumptions>
    <assumption>NautilusTrader is now primary platform (migration from MQL5 complete or near-complete)</assumption>
    <assumption>FORGE will work more with Python/Nautilus than MQL5 going forward</assumption>
  </assumptions>
</agents_md_nautilus_update>
```

---

### SUMMARY.md

**File:** `.prompts/009-agents-nautilus-update/SUMMARY.md`

```markdown
# AGENTS.md Nautilus Update Summary

**One-liner:** Updated AGENTS.md v3.4 → v3.4.1 to prioritize NautilusTrader (Python) over MQL5, marking MQL5 as LEGACY

## Version
v3.4.1 (from v3.4.0)

## Key Findings
• FORGE now validates with mypy + pytest (Python focus) instead of metaeditor64 (MQL5)
• Primary bugfix log: `nautilus_gold_scalper/BUGFIX_LOG.md` (was `MQL5/Experts/BUGFIX_LOG.md`)
• Added 2 new error recovery protocols: Python Type/Import Errors + Event-Driven Pattern Violation
• MQL5 compilation moved to `<mql5_legacy>` section (kept for reference)
• All examples updated to Nautilus context (Actors, Strategies, event-driven patterns)

## Files Modified
- `AGENTS.md` (v3.4.0 → v3.4.1)
- `AGENTS_v3.4_BACKUP_PRE_NAUTILUS_UPDATE.md` (backup created)

## Decisions Needed
None - changes align with project's migration to NautilusTrader

## Blockers
None

## Next Step
Execute 010-droid-refactoring-master.md (FASE 2-4: refactor TOP 5 droids with inheritance)
```

---

## ✅ Success Criteria

- [ ] Backup created: `AGENTS_v3.4_BACKUP_PRE_NAUTILUS_UPDATE.md`
- [ ] `<bugfix_protocol>` updated (primary log: nautilus_gold_scalper/, legacy: MQL5/)
- [ ] `<forge_rule>` updated (mypy + pytest validation for Python)
- [ ] `<error_recovery>` updated (2 new protocols for Python/Nautilus, MQL5 marked LEGACY)
- [ ] `<mql5_compilation>` renamed to `<compilation_validation>` with python_nautilus + mql5_legacy
- [ ] `<agents>` FORGE section updated (Python/Nautilus primary, MQL5 legacy)
- [ ] `<mcp_tooling>` FORGE section updated (context7★, e2b★ primary)
- [ ] Examples throughout updated to Nautilus context
- [ ] Version metadata updated (3.4.0 → 3.4.1)
- [ ] Changelog added to `<metadata>` section
- [ ] Output XML with all changes documented
- [ ] SUMMARY.md created

---

## ⚡ Intelligence Application

**Use sequential-thinking (7+ thoughts):**
1. What is REAL problem? → AGENTS.md references MQL5 but project uses Nautilus (misdirection)
2. What am I NOT seeing? → Some MQL5 knowledge is still valuable (keep as legacy, don't delete)
3. What breaks if I remove MQL5? → Lose reference for understanding original EA (keep as legacy)
4. What happens 5 steps ahead? → Droids inherit updated AGENTS.md → All agents focus on Nautilus
5. Edge cases? → What if user needs MQL5 compilation? (keep legacy section available)

**Proactive problem detection:**
- Maintainability: IMPROVED (correct platform focus)
- Performance: No impact (documentation change only)
- Dependencies: AGENTS.md droids will inherit updated focus

---

**EXECUTE THIS PROMPT WITH:** claude-sonnet-4 (precision required for in-place edits)
