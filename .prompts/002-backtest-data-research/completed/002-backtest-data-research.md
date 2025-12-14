# PROMPT 002: Backtest Data Sources Research

## Objective

**Deep research** to evaluate and compare data sources for realistic XAUUSD backtesting:
- Current: Dukascopy tick data (as mentioned in plan)
- Alternatives: TrueFX, FXCM, Pepperstone, TickData.com, etc.
- Assess quality, completeness, cost, integration complexity
- Recommend best source(s) for Apex Trading compliance

**Why it matters**: Garbage data = garbage backtest. Need highest quality tick data to validate strategies before live trading. Apex Trading requires realistic slippage, spreads, and execution modeling.

---

## Context

**Current assumption**: Plan mentions "TIC da Dukascopy" as data source

**Dynamic context**:
- !`find data/ -name "*dukascopy*" -o -name "*tick*" 2>/dev/null | head -5` (current data files)
- !`grep -r "dukascopy\|tick.*data\|data.*source" nautilus_gold_scalper/ | head -10` (references in code)

**Requirements**:
- Tick-level data (not just M1 bars)
- Bid/Ask spreads (for realistic slippage)
- 5+ years history (for WFA)
- XAUUSD specific (gold vs USD)
- Volume data (if available)
- Minimal gaps/missing data

---

## Requirements

### 1. Multi-Source Comparison

**Evaluate at least 5 sources**:
1. **Dukascopy** (current assumption)
2. **TrueFX** (free tick data)
3. **TickData.com** (premium)
4. **FXCM** (via API)
5. **Pepperstone** (broker data)
6. **Others** (if relevant)

**Comparison matrix**:
| Source | Data Type | History | Cost | Quality Score | Gaps % | Integration |
|--------|-----------|---------|------|---------------|--------|-------------|
| Dukascopy | Tick (bid/ask) | ? | Free | ? | ? | ? |
| ... | ... | ... | ... | ... | ... | ... |

### 2. Quality Assessment

**For each source, verify**:
- **Completeness**: Missing periods? Weekends? Holidays?
- **Accuracy**: Spread realism? Outlier filtering?
- **Resolution**: True ticks vs interpolated?
- **Latency**: Historical only or real-time too?
- **Format**: CSV, Parquet, API, FIX?

**Scoring rubric** (0-10):
- 10: Tick-level bid/ask, <0.1% gaps, proven by institutions
- 7-9: Tick-level, <1% gaps, widely used
- 4-6: M1 bars or >1% gaps
- 0-3: Unusable (large gaps, unrealistic spreads)

### 3. Apex Trading Specific

**Apex requirements**:
- Realistic spreads (XAUUSD: 15-50 cents typical)
- Slippage modeling (5-15 cents on average)
- No "perfect" fills (real-world friction)
- Gap handling (Sunday opens, news events)

**Validate**: Does the data source support Apex-realistic backtesting?

### 4. Integration Complexity

**Assess**:
- NautilusTrader compatibility? (Parquet catalog format)
- Download automation? (API vs manual)
- Storage requirements? (5 years of ticks = how many GB?)
- Preprocessing needed? (clean, resample, validate)

### 5. Cost-Benefit Analysis

**Free vs Paid**:
- Is premium data worth the cost for this project?
- Can free sources (TrueFX, Dukascopy) meet quality bar?
- Monthly subscription vs one-time purchase?

### 6. Community Validation

**Research**:
- What do quant traders use for XAUUSD backtesting?
- Any academic papers citing specific sources?
- Nautilus documentation recommendations?
- Known issues/complaints about sources?

---

## Droid Assignment

**Use ARGUS droid** for this task:
- Expert in deep multi-source research
- Triangulates academic, industry, and empirical evidence
- Validates claims with confidence levels
- Produces structured reports with sources

Invoke with:
```
Task(
  subagent_type="argus-quant-researcher",
  description="Backtest data research",
  prompt="[This entire prompt]"
)
```

---

## Output Specification

### Primary Output

**File**: `.prompts/002-backtest-data-research/backtest-data-research.md`

**Structure**:
```markdown
# XAUUSD Backtest Data Sources - Research Report

<metadata>
<confidence>HIGH|MEDIUM|LOW</confidence>
<sources_evaluated>N</sources_evaluated>
<verification_method>Official docs + community surveys + sample data checks</verification_method>
<recommendation_confidence>HIGH|MEDIUM|LOW</recommendation_confidence>
</metadata>

## Executive Summary

[200 words - best source(s), why, key trade-offs]

## Source Comparison Matrix

| Source | Type | History | Cost | Quality | Gaps | Apex-Ready | Integration | Score |
|--------|------|---------|------|---------|------|------------|-------------|-------|
| Dukascopy | Tick bid/ask | 10y | Free | 8/10 | 0.5% | ✅ | Medium | 8.0 |
| TrueFX | Tick | 2y | Free | 7/10 | 2% | ⚠️ | Easy | 6.5 |
...

## Detailed Evaluations

### Dukascopy
**Overview**: [Description]
**Pros**: [List]
**Cons**: [List]
**Quality Score**: 8/10 - [Rationale with evidence]
**Apex Compliance**: [Yes/No + why]
**Integration**: [Complexity + code examples if available]
**Sources**: [Links to docs, community discussions, papers]

[Repeat for each source]

## Quality Deep Dive

### Spread Realism Check
[Analysis of typical XAUUSD spreads in each source vs market reality]

### Gap Analysis
[Which sources have the most complete history?]

### Outlier Handling
[Do sources filter unrealistic ticks?]

## Apex Trading Validation

**Requirements**:
1. Realistic spreads (15-50 cents) → [Which sources pass?]
2. Slippage modeling → [Which sources provide data for this?]
3. Gap handling → [Which sources handle Sunday opens correctly?]

**Verdict**: [Source X meets/doesn't meet Apex requirements because...]

## Integration Path

**Recommended source**: [X]

**Download/Access**:
```bash
# Example download script
curl https://...
```

**Preprocessing**:
```python
# Example cleaning/conversion to Parquet
import polars as pl
...
```

**NautilusTrader Integration**:
```python
# Example ParquetDataCatalog setup
catalog = ParquetDataCatalog("./data")
...
```

## Cost-Benefit Analysis

| Source | Cost/Year | Quality Gain | Verdict |
|--------|-----------|--------------|---------|
| Dukascopy | $0 | Baseline | Use if sufficient |
| TickData.com | $500 | +15% | Worth it if Dukascopy has gaps |

## Community Insights

**Quant trader forums**: [Summary of discussions]
**Academic papers**: [Citations of data sources]
**Nautilus docs**: [Official recommendations]

## Recommendation

**Primary**: [Source X] - [Rationale]
**Backup**: [Source Y] - [Why/when to use]
**Avoid**: [Source Z] - [Why not]

**Action items**:
1. [Download X from URL]
2. [Preprocess with script Y]
3. [Validate with check Z]

<open_questions>
- [What remains uncertain - e.g., "Dukascopy gap % for 2020-2023 not verified"]
</open_questions>

<assumptions>
- [E.g., "Assumed XAUUSD spread of 20 cents as typical"]
</assumptions>

<dependencies>
- [E.g., "Need Nautilus ParquetDataCatalog documentation"]
</dependencies>
```

### Secondary Output

**File**: `.prompts/002-backtest-data-research/SUMMARY.md`

```markdown
# Backtest Data Research - Summary

## One-Liner
[E.g., "Dukascopy recommended for free tick data; TickData.com if budget allows"]

## Version
v1 - Initial research (2025-12-07)

## Key Findings
• [Finding 1 with evidence]
• [Finding 2 with evidence]
• [Finding 3 with evidence]
• [Confidence in recommendation: HIGH/MEDIUM/LOW]

## Decisions Needed
- [E.g., "Approve $500/year for TickData.com vs stick with free Dukascopy"]

## Blockers
- [E.g., "Need to verify Dukascopy API rate limits"]

## Next Step
[E.g., "Download Dukascopy 5-year XAUUSD dataset and validate quality"]
```

---

## Tools to Use

**Research tools**:
- `perplexity-search` - Latest info on data sources (HIGH priority for ARGUS)
- `exa` - AI-native search for quant trading topics
- `brave-search` - Web search for community discussions
- `firecrawl` - Scrape data provider websites (pricing, docs)
- `github___search_repositories` - Find projects using these sources

**Validation**:
- `FetchUrl` - Read official documentation
- `Grep` - Search local code for data source references

**Example queries**:
```
perplexity: "Best tick data sources for XAUUSD gold forex backtesting 2024"
exa: "Dukascopy vs TrueFX tick data quality comparison"
github: "NautilusTrader XAUUSD data parquet"
```

---

## Success Criteria

**Research Depth**:
- [ ] At least 5 sources evaluated with evidence
- [ ] Quality scores justified with specific metrics (gaps %, spread realism)
- [ ] Apex Trading requirements validated for each source
- [ ] Integration complexity assessed with code examples

**Output Quality**:
- [ ] Comparison matrix is complete and actionable
- [ ] Recommendation has clear rationale with trade-offs
- [ ] Sources cited (URLs to docs, forums, papers)
- [ ] SUMMARY.md has substantive recommendation (not generic)

**Validation**:
- [ ] At least 2 community sources consulted (forums, papers)
- [ ] Official documentation reviewed for top 3 sources
- [ ] Sample data checked if publicly available

---

## Intelligence Rules

**Triangulation**: Use academic (papers) + industry (docs) + empirical (community) sources.

**Confidence levels**: Assign HIGH/MEDIUM/LOW confidence to each claim based on verification.

**Parallelism**: Run multiple searches simultaneously:
```
perplexity("Dukascopy"), exa("TrueFX"), brave("TickData reviews"), ... in ONE message
```

**Depth**: This is deep research - don't just skim first page of Google results.

---

## Notes

- User mentioned "TIC da Dukascopy" but unsure if it's the best
- Apex Trading requires realistic execution modeling
- This research informs prompt 003 (backtest code audit)
- No dependencies on other prompts (can run in parallel with 001)
