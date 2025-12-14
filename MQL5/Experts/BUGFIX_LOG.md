# MQL5 EA - Bug Fix Log

**Purpose:** Track MQL5 bugs with ROOT CAUSE analysis to prevent recurrence  
**Owner:** FORGE (MQL5 mode)  
**Format:** Structured Markdown (newest first)  
**Usage:** Debugging, compilation patterns, post-mortem analysis

**CRITICAL bugs (account risk, Apex violations):** MUST include 5 Whys + Prevention (AGENTS.md updates)

---

## Template for Standard Bugs

```markdown
## YYYY-MM-DD HH:MM [AGENT] - Module

**Bug:** Brief description  
**Impact:** What broke / consequences  
**Root Cause:** Why it happened (1-2 sentences)  
**Fix:** Solution applied  
**Files:** List of modified files (.mqh, .mq5)  
**Validation:** Compilation passed, backtest results  
**Commit:** hash
```

---

## Template for CRITICAL Bugs (🚨 Account Risk / Apex Violations)

```markdown
## 🚨 YYYY-MM-DD HH:MM [AGENT] - CRITICAL

**Module:** MQL5/Include/EA_SCALPER/Module.mqh  
**Severity:** CRITICAL (Account survival - $50k risk) | HIGH (Trading logic) | MEDIUM  
**Bug:** Brief description  
**Impact:** Specific consequences (would violate Apex? lose money?)  

**Root Cause (5 Whys):**
1. Why? [First level]
2. Why? [Deeper]
3. Why? [Process issue]
4. Why? [Missing validation]
5. Why? [Root cause]

**Fix:** Solution applied  

**Prevention (MANDATORY - Protocol Updates):**
- ✅ Updated AGENTS.md: [which section, what added]
- ✅ Added test: [manual backtest, compilation check]
- ✅ Added pattern: [if repeatable bug pattern]
- ✅ Updated complexity: [if escalation needed]

**Files:**
- MQL5/Include/path/to/file.mqh (fixed)
- MQL5/Experts/EA_NAME.mq5 (test)
- AGENTS.md (protocol update)

**Validation:** [proof fix works - compilation + backtest]  
**Commit:** hash
```

---

## Log Entries

### 2025-12-08 18:00 [FORGE] - BUGFIX_LOG.md

**Bug:** No structured MQL5 bug tracking system  
**Impact:** MQL5 bugs not analyzed for root cause, compilation patterns not learned  
**Root Cause:** Missing systematic logging for MQL5 codebase with prevention enforcement  
**Fix:** Created BUGFIX_LOG.md with mandatory Root Cause + Prevention for CRITICAL bugs  
**Files:** BUGFIX_LOG.md  
**Validation:** Template complete with 🚨 CRITICAL protocol  
**Commit:** pending
