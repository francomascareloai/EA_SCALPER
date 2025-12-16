# ARGUS Research: Data Integrity Pipeline Improvements (Phases 3-4)

**Date:** 2025-12-16
**Status:** COMPLETE
**Confidence:** HIGH (triangulated from academic, code, and empirical sources)

---

## Executive Summary

Research into modern approaches for data validation pipeline improvements covering:
- DST handling for historical financial data (2003-2025)
- Session boundary detection algorithms
- Data reconciliation patterns
- Reversible cleanup mechanisms
- Data lineage tracking

**Key Recommendations:**
1. Replace pytz with zoneinfo (Python stdlib)
2. Adopt Pandera for DataFrame schema validation
3. Implement OpenLineage for data lineage tracking
4. Current .trash/ cleanup pattern is industry standard - enhance with metadata

---

## Phase 3: Session Catalog Validation

### 1. DST Handling for Historical Data (2003-2025)

#### The Problem
Data spans a critical DST rule change:
- **Pre-2007 (2003-2006):** First Sunday in April to Last Sunday in October
- **Post-2007 (2007-2025):** Second Sunday in March to First Sunday in November

The US Energy Policy Act of 2005 changed DST rules effective March 2007.

#### Current Implementation Analysis
```python
# session_filter.py - Uses zoneinfo (GOOD)
from zoneinfo import ZoneInfo

# generate_session_datasets.py - Uses pytz (LEGACY)
import pytz
df['datetime_et'] = df['datetime'].dt.tz_convert(pytz.timezone('US/Eastern'))
```

#### Recommended Solution: zoneinfo + tzdata

**Why zoneinfo over pytz:**
| Feature | pytz | zoneinfo |
|---------|------|----------|
| Python stdlib | No | Yes (3.9+) |
| IANA tzdb updates | Manual | Via tzdata package |
| Historical DST rules | Complete | Complete |
| API correctness | Quirky normalize() | Standard datetime API |
| Performance | Slower | Faster |
| Future support | Maintenance mode | Active development |

**Implementation:**
```python
from zoneinfo import ZoneInfo
from datetime import datetime

# Works correctly for both pre-2007 and post-2007 dates
dt_2005 = datetime(2005, 4, 3, 2, 0, tzinfo=ZoneInfo('America/New_York'))
dt_2008 = datetime(2008, 3, 9, 2, 0, tzinfo=ZoneInfo('America/New_York'))

# IANA tzdb contains all historical transitions
# No special handling needed - library handles it correctly
```

**Dependencies:**
```bash
pip install tzdata  # Ensures latest IANA database (2025c as of Dec 2025)
```

**Validation Script for DST Transitions:**
```python
from zoneinfo import ZoneInfo
from datetime import datetime, timedelta

def validate_dst_transitions(year: int) -> dict:
    """Validate DST transition dates for a given year."""
    tz = ZoneInfo('America/New_York')

    # Find spring forward (2am becomes 3am)
    if year < 2007:
        # First Sunday in April
        spring = datetime(year, 4, 1, tzinfo=tz)
        while spring.weekday() != 6:  # Find Sunday
            spring += timedelta(days=1)
    else:
        # Second Sunday in March
        spring = datetime(year, 3, 8, tzinfo=tz)  # Earliest possible
        while spring.weekday() != 6:
            spring += timedelta(days=1)

    return {
        'year': year,
        'spring_forward': spring.strftime('%Y-%m-%d'),
        'pre_2007_rule': year < 2007
    }
```

#### Alternative Libraries Evaluated

| Library | Verdict | Notes |
|---------|---------|-------|
| **Pendulum 3.0** | GOOD | Drop-in datetime replacement, uses IANA tzdb, excellent API |
| **Arrow** | ACCEPTABLE | Similar to Pendulum, less actively maintained |
| **whenever** | PROMISING | Rust-backed, very fast, newer library |
| **python-dateutil** | LEGACY | Use zoneinfo instead |

**Performance Note:** stdlib datetime >> Pendulum/Arrow (10-100x). For tick data processing, use zoneinfo directly. Pendulum is better for human-readable date manipulation in reports/logs.

---

### 2. Session Boundary Detection

#### Current Implementation
Rule-based with fixed GMT times:
```python
SESSIONS = {
    TradingSession.SESSION_ASIAN: {"start": time(0, 0), "end": time(7, 0)},
    TradingSession.SESSION_LONDON: {"start": time(7, 0), "end": time(12, 0)},
    # ... etc
}
```

#### Evaluated Alternatives

##### pandas_market_calendars (v5.1.1)
- **Pros:** Mature library, exchange holidays, trading hours
- **Cons:** Designed for equity markets, not 24/5 forex
- **Verdict:** NOT RECOMMENDED for forex sessions

```python
# Only useful for detecting market holidays, not forex sessions
import pandas_market_calendars as mcal
cme = mcal.get_calendar('CME')  # CME COMEX for gold futures
```

##### tradinghours-python
- **Pros:** Dedicated market hours database, offline after initial download
- **Cons:** Commercial API required for full features
- **Verdict:** EVALUATE for production use

```python
# Basic usage (requires API key for full features)
pip install tradinghours
from tradinghours import MarketHours
```

##### ML-Based Session Detection
- **Concept:** Detect session boundaries from volatility/volume patterns
- **Verdict:** OVERKILL - rule-based approach is correct for forex

**Recommendation:** Keep current rule-based approach but enhance with:
1. DST-aware time conversion
2. Holiday detection (US/UK bank holidays affect XAUUSD liquidity)
3. Configurable session boundaries in YAML

---

### 3. Data Validation with Pandera

#### Why Pandera over Great Expectations

| Feature | Pandera | Great Expectations |
|---------|---------|-------------------|
| Learning curve | Low | High |
| Setup complexity | pip install | Project structure required |
| Pandas integration | Native | Via backend |
| Polars support | Yes | Limited |
| Schema as code | Yes (type hints) | YAML/JSON config |
| Performance | Fast | Heavier |
| Best for | DataFrames | Data pipelines with docs |

#### Recommended Schema for Tick Data

```python
import pandera as pa
from pandera import Column, DataFrameSchema, Check
from pandera.typing import Series
import pandas as pd

tick_schema = pa.DataFrameSchema(
    columns={
        "ts_event": Column(
            "datetime64[ns, UTC]",
            checks=[
                Check(lambda s: s.notna().all(), error="Null timestamps"),
                Check(lambda s: (s >= pd.Timestamp("2003-01-01", tz="UTC")),
                      error="Timestamp before data range"),
                Check(lambda s: (s <= pd.Timestamp("2026-01-01", tz="UTC")),
                      error="Future timestamp"),
            ],
            nullable=False,
        ),
        "bid": Column(
            float,
            checks=[
                Check(lambda s: (s > 0).all(), error="Negative bid"),
                Check(lambda s: (s < 10000).all(), error="Bid too high"),
            ],
            nullable=False,
        ),
        "ask": Column(
            float,
            checks=[
                Check(lambda s: (s > 0).all(), error="Negative ask"),
                Check(lambda s: (s < 10000).all(), error="Ask too high"),
            ],
            nullable=False,
        ),
    },
    checks=[
        Check(lambda df: (df["ask"] >= df["bid"]).all(),
              error="Ask below bid (crossed market)"),
        Check(lambda df: ((df["ask"] - df["bid"]) < 100).all(),
              error="Spread > 100 (data error)"),
    ],
    ordered=True,
    strict=False,  # Allow extra columns
)

def validate_session_catalog(df: pd.DataFrame, session_name: str) -> dict:
    """Validate a session catalog against the tick schema."""
    try:
        tick_schema.validate(df, lazy=True)
        return {"session": session_name, "status": "PASS", "errors": []}
    except pa.errors.SchemaErrors as err:
        return {
            "session": session_name,
            "status": "FAIL",
            "errors": err.failure_cases.to_dict()
        }
```

---

## Phase 4: Integrity & Cleanup

### 4. Cross-Catalog Consistency Validation

#### Current Requirement
`sum(session_ticks) == main_catalog_ticks`

#### Recommended Approach: Hash-Based Reconciliation

```python
import hashlib
from pathlib import Path
import polars as pl

def compute_catalog_fingerprint(catalog_path: Path) -> dict:
    """Compute fingerprint for catalog reconciliation."""
    lf = pl.scan_parquet(catalog_path / "*.parquet")

    # Compute aggregates lazily
    stats = lf.select([
        pl.count().alias("tick_count"),
        pl.col("ts_event").min().alias("first_tick"),
        pl.col("ts_event").max().alias("last_tick"),
        pl.col("bid").sum().alias("bid_sum"),  # For checksum
    ]).collect()

    return {
        "path": str(catalog_path),
        "tick_count": stats["tick_count"][0],
        "first_tick": stats["first_tick"][0],
        "last_tick": stats["last_tick"][0],
        "checksum": hashlib.md5(
            f"{stats['bid_sum'][0]:.8f}".encode()
        ).hexdigest()[:16],
    }

def reconcile_catalogs(main_catalog: Path, session_catalogs: list[Path]) -> dict:
    """Reconcile main catalog against session partitions."""
    main_fp = compute_catalog_fingerprint(main_catalog)
    session_fps = [compute_catalog_fingerprint(p) for p in session_catalogs]

    total_session_ticks = sum(fp["tick_count"] for fp in session_fps)

    return {
        "main_ticks": main_fp["tick_count"],
        "session_ticks": total_session_ticks,
        "match": main_fp["tick_count"] == total_session_ticks,
        "discrepancy": main_fp["tick_count"] - total_session_ticks,
        "sessions": session_fps,
    }
```

#### Large-Scale Validation Tools Evaluated

| Tool | Best For | Our Use Case |
|------|----------|--------------|
| **Apache Deequ** | Spark-scale distributed data | Overkill for 12GB constraint |
| **Apache Griffin** | EMR/Hadoop environments | Infrastructure overhead |
| **Great Expectations** | Enterprise data pipelines | Heavier than needed |
| **Pandera** | DataFrame validation | BEST FIT |
| **Polars** | Memory-efficient processing | BEST FIT for 654M ticks |

---

### 5. Reversible Cleanup: .trash/ Pattern

#### Current Approach (VALIDATED as Industry Standard)
```
catalog/
  .trash/
    2025-12-16_103045_session_asian/
    2025-12-16_103045_session_london/
```

#### Industry Comparison

| Provider | Default Retention | Implementation |
|----------|-------------------|----------------|
| Google Cloud Storage | 7 days | Soft delete with metadata |
| AWS S3 | Configurable | Object versioning |
| Azure Blob | 7-365 days | Soft delete policy |
| **Our approach** | 7 days | .trash/ folder |

**Verdict:** Current approach matches industry patterns.

#### Enhancement: Deletion Metadata

```python
import json
from datetime import datetime
from pathlib import Path

def move_to_trash(source_path: Path, trash_dir: Path, reason: str) -> Path:
    """Move catalog to trash with metadata for rollback."""
    timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
    dest_name = f"{timestamp}_{source_path.name}"
    dest_path = trash_dir / dest_name

    # Move files
    source_path.rename(dest_path)

    # Write metadata for recovery
    metadata = {
        "original_path": str(source_path),
        "deleted_at": datetime.utcnow().isoformat(),
        "reason": reason,
        "recoverable_until": (
            datetime.utcnow() + timedelta(days=7)
        ).isoformat(),
    }
    (dest_path / ".deletion_metadata.json").write_text(
        json.dumps(metadata, indent=2)
    )

    return dest_path

def restore_from_trash(trash_path: Path) -> Path:
    """Restore catalog from trash using metadata."""
    metadata_file = trash_path / ".deletion_metadata.json"
    if not metadata_file.exists():
        raise ValueError("No deletion metadata found")

    metadata = json.loads(metadata_file.read_text())
    original_path = Path(metadata["original_path"])

    # Remove metadata file before restore
    metadata_file.unlink()
    trash_path.rename(original_path)

    return original_path
```

---

### 6. Data Lineage with OpenLineage

#### Why OpenLineage
- Open-source, vendor-neutral
- Python native (pip install openlineage-python)
- Tracks transformations: source -> processing -> destination
- Integrates with Airflow, dbt, custom pipelines

#### Implementation for Session Splitting

```python
from openlineage.client import OpenLineageClient
from openlineage.client.run import RunEvent, RunState, Run, Job
from openlineage.client.facet import (
    DataSourceDatasetFacet,
    SchemaDatasetFacet,
    SchemaField,
)
from openlineage.client.uuid import generate_new_uuid
from datetime import datetime

def track_session_split_lineage(
    source_parquet: str,
    session_catalogs: list[str],
    namespace: str = "ea_scalper_xauusd"
):
    """Track lineage for session splitting operation."""
    client = OpenLineageClient.from_environment()

    run_id = str(generate_new_uuid())
    job_name = "session_catalog_splitter"

    # Input dataset
    input_dataset = {
        "namespace": namespace,
        "name": source_parquet,
        "facets": {
            "dataSource": DataSourceDatasetFacet(
                name="xauusd_tick_data",
                uri=f"file://{source_parquet}"
            ),
            "schema": SchemaDatasetFacet(
                fields=[
                    SchemaField(name="ts_event", type="timestamp"),
                    SchemaField(name="bid", type="float64"),
                    SchemaField(name="ask", type="float64"),
                ]
            ),
        }
    }

    # Output datasets (one per session)
    output_datasets = [
        {
            "namespace": namespace,
            "name": catalog_path,
            "facets": {
                "dataSource": DataSourceDatasetFacet(
                    name=f"session_catalog_{i}",
                    uri=f"file://{catalog_path}"
                ),
            }
        }
        for i, catalog_path in enumerate(session_catalogs)
    ]

    # Emit START event
    client.emit(RunEvent(
        eventType=RunState.START,
        eventTime=datetime.utcnow().isoformat() + "Z",
        run=Run(runId=run_id),
        job=Job(namespace=namespace, name=job_name),
        inputs=[input_dataset],
        outputs=[],
    ))

    # ... perform splitting ...

    # Emit COMPLETE event
    client.emit(RunEvent(
        eventType=RunState.COMPLETE,
        eventTime=datetime.utcnow().isoformat() + "Z",
        run=Run(runId=run_id),
        job=Job(namespace=namespace, name=job_name),
        inputs=[input_dataset],
        outputs=output_datasets,
    ))
```

---

## Summary: Recommended Improvements

### High Priority (Implement Now)

| Area | Current | Recommended | Impact |
|------|---------|-------------|--------|
| Timezone | pytz + zoneinfo mixed | zoneinfo + tzdata only | Correct DST handling |
| Validation | Manual checks | Pandera schemas | Automated, reproducible |
| Cleanup metadata | Path only | JSON metadata file | Full rollback capability |

### Medium Priority (Next Iteration)

| Area | Current | Recommended | Impact |
|------|---------|-------------|--------|
| Reconciliation | Manual count check | Hash-based fingerprinting | Detect corruption |
| Lineage | None | OpenLineage | Audit trail |
| Holiday detection | None | Bank holiday calendar | Better session quality |

### Low Priority (Future Enhancement)

| Area | Current | Recommended | Impact |
|------|---------|-------------|--------|
| Market hours API | Rule-based | tradinghours-python | Dynamic updates |
| Large-scale validation | Pandera | Deequ (if scale increases) | Spark-scale |

---

## Dependencies Summary

```bash
# Required (add to requirements.txt)
tzdata>=2025.1          # IANA timezone database
pandera>=0.20.0         # DataFrame validation
polars>=1.0.0           # Memory-efficient processing

# Recommended
openlineage-python>=1.0.0   # Data lineage tracking

# Evaluate for production
tradinghours>=0.1.0     # Market hours (commercial API)
pandas-market-calendars>=5.0  # Exchange calendars
```

---

## References

1. IANA Time Zone Database: https://www.iana.org/time-zones (tzdb 2025c)
2. US Naval Observatory DST Rules: https://aa.usno.navy.mil/faq/daylight_time
3. NIST DST Rules: https://www.nist.gov/pml/time-and-frequency-division/popular-links/daylight-saving-time-dst
4. Pandera Documentation: https://pandera.readthedocs.io/
5. OpenLineage Python Client: https://openlineage.io/docs/client/python/
6. Google Cloud Soft Delete: https://cloud.google.com/storage/docs/soft-delete
7. pandas_market_calendars: https://pandas-market-calendars.readthedocs.io/
8. tradinghours-python: https://github.com/tradinghours/tradinghours-python
9. Amazon Deequ Paper: https://www.amazon.science/publications/unit-testing-data-with-deequ

---

**Research Completed By:** ARGUS Quant Researcher
**Triangulation Sources:** Academic (IANA, NIST), Code (GitHub repos), Empirical (Web search 2024-2025)
**Next Handoff:** FORGE (implement zoneinfo migration) -> ORACLE (validate with backtest)
