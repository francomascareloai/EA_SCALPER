# User Preferences for Droid Refactoring

## Date: 2025-12-07

### Droids to EXCLUDE from Refactoring

**DO NOT touch these droids** (per user request):
1. **subagent-auditor** - Leave AS-IS
2. **skill-auditor** - Leave AS-IS

**Rationale**: These auditors are working well and should not be modified.

---

### MERGE Execution Status (OPTION 1)

#### ✅ MERGE 1 COMPLETE: Code Reviewers
- **Action**: Merged code-architect-reviewer + senior-code-reviewer → **generic-code-reviewer**
- **Result**: 10KB merged droid (67% reduction from 30KB combined)
- **Archived**: code-architect-reviewer.md.bak, senior-code-reviewer.md.bak
- **Date**: 2025-12-07
- **Status**: ✅ COMPLETE

#### ✅ MERGE 2 COMPLETE: Python Backend Engineer
- **Decision**: **KEEP SEPARATE** (no merge)
- **Rationale**: 
  - Different domains (web backend vs trading systems)
  - Only 15-20% overlap (generic Python foundations)
  - Project has NO backend (no FastAPI/Django/SQLAlchemy)
  - python-backend-engineer is PERSONAL droid (general-purpose, not project-specific)
- **Action**: Excluded from project refactoring scope
- **Date**: 2025-12-07
- **Status**: ✅ COMPLETE (no action needed)

#### ✅ MERGE 3 COMPLETE: Research Droids
- **Decision**: **ARCHIVE research-analyst-pro**, KEEP argus + deep-researcher
- **Analysis** (via project-reader subagent):
  - argus-quant-researcher: 87% relevance (CRITICAL), 80% usage, trading specialist
  - deep-researcher: 68% relevance (IMPORTANT), 18% usage, academic validation
  - research-analyst-pro: 32% relevance (PERIPHERAL), 2% usage, general-purpose
- **Action**: Archived research-analyst-pro.md → _archive/research-analyst-pro.md.archived
- **Token savings**: 31KB (53% reduction from 58KB to 27KB)
- **Routing**: argus (trading research), deep-researcher (academic/quant validation)
- **Date**: 2025-12-07
- **Status**: ✅ COMPLETE

**MERGE 1-3 Total Savings**: 41KB (10KB + 0KB + 31KB)

---

### Updated Project-Relevant Personal Droids (Phase 3)

**REFACTOR these 2 droids**:
1. **senior-code-reviewer** (~15KB → ~5KB)
   - Action: ✅ MERGED with code-architect-reviewer → generic-code-reviewer (COMPLETE)
   - Savings: ~10KB

2. **mcp-testing-engineer** (~8KB → ~3KB)
   - Action: Refactor for MCP validation (Twelve-Data, memory, time MCPs)
   - Savings: ~5KB

**EXCLUDE from refactoring** (not project-relevant):
3. **python-backend-engineer** (~31KB)
   - Reason: Project has NO backend (no FastAPI/Django/SQLAlchemy usage)
   - Domain: Web APIs vs Trading systems (orthogonal to FORGE)
   - Status: Keep as personal droid for future projects
   - Overlap with FORGE: Only 15-20% (generic Python foundations)

**Total savings** (2 droids): ~15KB

---

### Updated Ecosystem Totals

**Full Ecosystem** (35 droids):
- Before: 577KB (389 project + 188 personal)
- After: 264KB (101 project + 163 personal)
  - Project: 101KB (all 17 refactored)
  - Personal: 163KB (3 refactored, 2 auditors untouched, 13 non-relevant untouched)
- **Savings**: 313KB (54% reduction)
- **Token savings**: ~78,000 tokens

**Strategy**:
- ✅ Refactor all 17 project droids (Phase 1-2)
- ✅ Refactor 3 project-relevant personal droids (Phase 3)
- ❌ **DO NOT touch** 2 auditors (per user)
- ❌ Leave 13 non-relevant personal droids AS-IS (no effort wasted)

---

## Next Actions (Prioritized)

### Phase 1 (Week 1) - CRITICAL
1. CREATE security-compliance droid (CRITICAL)
2. CREATE performance-optimizer droid (HIGH)
3. Refactor TOP 5 (NAUTILUS, ORACLE, FORGE, SENTINEL, RESEARCH)
4. Refactor orchestrator → MAESTRO
5. Refactor onnx-model-builder

### Phase 2 (Week 2) - HIGH
1. Refactor remaining 12 project droids
2. MERGE code-architect-reviewer + senior-code-reviewer → generic-code-reviewer
3. CREATE data-pipeline, monitoring-alerting droids
4. Update AGENTS.md (decision_hierarchy, DAG, quality_monitoring)

### Phase 3 (Week 3) - SELECTIVE PERSONAL
1. ~~python-backend-engineer~~ → **SKIP** (not project-relevant, keep as personal droid)
2. Refactor mcp-testing-engineer
3. ~~subagent-auditor~~ → **SKIP** (user request)
4. ~~skill-auditor~~ → **SKIP** (user request)
5. Remaining project droids (crucible, argus, deep-researcher merge)
6. REMOVE database-optimization (duplicate)
