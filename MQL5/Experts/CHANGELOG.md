# MQL5 EA - Code Change Log

**Purpose:** Log COMPLETED MQL5 work units (features, improvements, breaking changes, config)  
**Owner:** FORGE (MQL5 mode)  
**Format:** Chronological (newest first)  
**When:** ONLY when work unit fully complete (all edits done, compilation passing). NOT during individual edits.  
**Usage:** Understand what changed, why, and impact in MQL5 codebase

---

## Template (copy for new entries)

```markdown
## [Module] - YYYY-MM-DD HH:MM (AGENT)

### 🐛 BUGFIX | 🚀 IMPROVEMENT | ✨ FEATURE | ⚠️ BREAKING | ⚙️ CONFIG

**What:** Brief description (1 line)  
**Why:** Problem solved / motivation / context  
**Impact:** What changed (behavior, API, performance, dependencies)  
**Files:**
- MQL5/Experts/path/to/file.mq5
- MQL5/Include/path/to/file.mqh

**Validation:** metaeditor64 compilation status, visual testing  
**Commit:** [hash if committed]
```

---

## 2025-12-08 18:00 (FORGE)

### ⚙️ CONFIG

**What:** Created CHANGELOG.md tracking system for MQL5 codebase  
**Why:** Franco requested systematic logging to track MQL5 evolution alongside Nautilus  
**Impact:** FORGE now MUST log all MQL5 code changes before reporting completion  
**Files:**
- MQL5/Experts/CHANGELOG.md (this file)
- MQL5/Experts/BUGFIX_LOG.md (created)

**Validation:** Documentation complete  
**Commit:** pending
