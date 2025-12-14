# Backtest Data Research - Summary

## One-Liner
**Dukascopy is the recommended free source for XAUUSD tick data (2003+, true bid/ask, realistic spreads); use FXCM (2015+) as validation backup.**

## Version
v2 - Apex readiness + QC checklist (2025-12-07)

## Key Findings

### 1. Dukascopy is the Best Free Option (HIGH confidence)
- **Evidence**: 20+ years of XAUUSD tick data (May 2003+)
- **Quality**: True bid/ask with realistic spreads (20-50 cents typical)
- **Community**: De facto standard per Elite Trader, StrategyQuant, Quant Stack Exchange
- **Limitation**: Pre-2008 spread data may be interpolated

### 2. FXCM Provides Good Validation Data (HIGH confidence)
- **Evidence**: Direct URL access to tick data (2015+)
- **Quality**: Different liquidity pool than Dukascopy
- **Use case**: Cross-validate Dukascopy backtest results

### 3. TrueFX Should NOT be Used for XAUUSD (HIGH confidence)
- **Evidence**: Limited XAUUSD coverage, data availability uncertain
- **Recommendation**: Skip entirely for gold-specific backtesting

### 4. Premium Sources (TickData.com) Not Justified (MEDIUM confidence)
- **Evidence**: $500+/year for ~10-15% quality improvement
- **Rationale**: Free Dukascopy sufficient for this project's scope
- **Reconsider if**: Institutional audit requirements emerge

### 5. Apex Trading Requirements Achievable (HIGH confidence)
- **Spreads**: Dukascopy 20-50 cents matches live XAUUSD conditions
- **Slippage**: Must be simulated (data provides quotes, not executions)
- **Gaps**: Weekend/holiday gaps correctly represented

## Source Comparison (Top 3)

| Rank | Source | Score | Cost | History | Apex-Ready |
|------|--------|-------|------|---------|------------|
| 1 | **Dukascopy** | 8.8/10 | Free | 2003-05-05+ | YES (add slippage) |
| 2 | **FXCM** | 7.6/10 | Free | 2015+ | YES (add slippage) |
| 3 | **Tickstory** | 8.1/10 | Free/$ | 2003+ | YES (Dukascopy relay) |

## Decisions Needed

1. **Approve Dukascopy as primary source?** → Recommended: YES
2. **Download historical depth**: 5 years (2020-2024) or 10 years (2015-2024)?
   - Recommendation: 5 years initially, expand if WFA requires longer history
3. **Slippage modeling approach**: Simple random vs volatility-adjusted?
   - Recommendation: Volatility-adjusted (code provided in main report)
4. **QC gate**: Run ET alignment + gap/spread checks before catalog write

## Blockers

- **None identified** - Dukascopy data freely accessible without restrictions
- **Minor**: Verify Dukascopy API rate limits before bulk download

## Storage Requirements

| Period | Compressed | Parquet |
|--------|------------|---------|
| 5 years | ~10 GB | ~7 GB |
| 10 years | ~20 GB | ~15 GB |

## Next Steps

1. **Immediate**: Download Dukascopy XAUUSD tick data (2020-2024)
   ```bash
   pip install tickterial
   tickterial --symbols XAUUSD --start '2020-01-01' --end '2024-12-31' --progress true
   ```

2. **Week 1**: Preprocess data (outlier filtering, Parquet conversion)

3. **Week 2**: Integrate with NautilusTrader ParquetDataCatalog

4. **Week 3**: Validate with FXCM comparison dataset

## Confidence Assessment

| Finding | Confidence | Evidence Strength |
|---------|------------|-------------------|
| Dukascopy recommendation | HIGH | Multiple independent sources agree |
| Quality scores | MEDIUM-HIGH | Based on community + documentation |
| Apex compliance | HIGH | Spread ranges verified against live data |
| Cost-benefit analysis | MEDIUM | Subjective project scope assessment |

---

**Research completed by**: Argus Deep Researcher
**Date**: 2025-12-07
**Sources analyzed**: 8 data providers, 15+ community discussions, official documentation
