# Phase 1: Discovery & Configuration

**Phase ID**: 01
**Status**: ⏳ Pending
**Estimated Agents**: 1 (Orchestrator direct)
**Execution Mode**: Sequential

---

## Objective

Establish single source of truth for data configuration and create complete inventory of all data assets before validation begins.

---

## Prerequisites

- None (this is the first phase)

---

## Tasks

### Task 1.1: Update config.yaml

**Description**: Fix the active dataset path to point to the newest complete catalog

**Current State**:
```yaml
active_dataset: xauusd_2003_2025_stride1_full  # OLD
```

**Target State**:
```yaml
active_dataset: xauusd_2003_2025_stride1_COMPLETE  # NEW - 654.6M ticks
```

**Commands**:
```bash
# Verify the COMPLETE catalog exists
ls -la data/catalog_native/xauusd_2003_2025_stride1_COMPLETE/

# Check checkpoint for confirmation
cat data/catalog_native/xauusd_2003_2025_stride1_COMPLETE/.checkpoint.json

# Edit config.yaml
# Use Edit tool to update active_dataset
```

**Validation**:
```bash
# Verify config update
python -c "import yaml; c=yaml.safe_load(open('data/config.yaml')); print(c['active_dataset'])"
```

---

### Task 1.2: Create Catalog Inventory

**Description**: Document all existing catalogs with sizes, dates, and status

**Catalogs to Inventory**:

| Path | Type | Status Check |
|------|------|--------------|
| `data/catalog_native/xauusd_2003_2025_stride1_COMPLETE/` | Main | Primary |
| `data/catalog_native/xauusd_2003_2025_stride1_full/` | Main | Older version |
| `data/catalog_native/xauusd_2003_2025_stride20_full_INCOMPLETE/` | Main | Incomplete |
| `data/catalog_native/xauusd_2003_2025_stride200000_full/` | Main | Heavy stride |
| `data/catalog_native_sessions/xauusd_2003_2025_stride1_ASIAN/` | Session | Validate |
| `data/catalog_native_sessions/xauusd_2003_2025_stride1_LONDON/` | Session | Validate |
| `data/catalog_native_sessions/xauusd_2003_2025_stride1_OVERLAP/` | Session | Validate |
| `data/catalog_native_sessions/xauusd_2003_2025_stride1_NY/` | Session | Validate |
| `data/catalog_native_sessions/xauusd_2003_2025_stride1_LATE_NY/` | Session | Validate |
| `data/catalog_native_sessions/xauusd_2003_2025_stride1_EVENING/` | Session | Validate |

**Commands**:
```bash
# Get sizes
du -sh data/catalog_native/*/
du -sh data/catalog_native_sessions/*/

# Count files in each catalog
for d in data/catalog_native/*/; do echo "$d: $(find $d -name '*.parquet' | wc -l) parquet files"; done
for d in data/catalog_native_sessions/*/; do echo "$d: $(find $d -name '*.parquet' | wc -l) parquet files"; done
```

**Output**: `CATALOG_INVENTORY.json`

---

### Task 1.3: Validate Config Resolution

**Description**: Verify that config.yaml correctly resolves to catalog paths

**Validation Script**:
```python
import yaml
from pathlib import Path

config = yaml.safe_load(open('data/config.yaml'))
active = config['active_dataset']
catalog_path = Path(f"data/catalog_native/{active}")

assert catalog_path.exists(), f"Catalog not found: {catalog_path}"
assert (catalog_path / '.checkpoint.json').exists(), "Missing checkpoint"
assert (catalog_path / 'data' / 'quote_tick').exists(), "Missing quote_tick data"

print(f"✅ Config resolves to: {catalog_path}")
print(f"✅ Checkpoint exists")
print(f"✅ Quote tick data exists")
```

---

## Success Criteria

| Criterion | Check |
|-----------|-------|
| config.yaml updated | `active_dataset == stride1_COMPLETE` |
| Catalog inventory complete | All 10 catalogs documented |
| Path resolution works | Config → Catalog → Data verified |

---

## Deliverables

1. **Updated `data/config.yaml`** - Points to COMPLETE catalog
2. **`CATALOG_INVENTORY.json`** - Full inventory with sizes, dates, status

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Wrong catalog path | HIGH | Verify .checkpoint.json exists |
| Missing session catalogs | MEDIUM | Document gaps for Phase 3 |

---

## Next Phase

After completion, proceed to [Phase 2: Main Catalog Validation](./02-PHASE-PLAN.md)
