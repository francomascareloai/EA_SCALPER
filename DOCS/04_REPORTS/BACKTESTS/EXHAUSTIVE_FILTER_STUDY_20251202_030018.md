# EXHAUSTIVE FILTER ABLATION STUDY

**Generated**: 2025-12-02 03:00:18

---

## BEST CONFIGURATIONS SUMMARY

### SESSION_FILTERS

**Best**: SESSION_ASIA_EXCLUDED
- PF: 0.86
- Return: -7.4%
- Trades: 226
- Win Rate: 38.1%
- Max DD: 10.2%
- SQN: -1.11

### REGIME_FILTERS

**Best**: REGIME_HURST_0.52
- PF: 1.02
- Return: 0.7%
- Trades: 186
- Win Rate: 40.3%
- Max DD: 5.8%
- SQN: 0.12

### TIMEFRAMES

**Best**: TIMEFRAME_5min
- PF: 0.83
- Return: -9.7%
- Trades: 269
- Win Rate: 35.3%
- Max DD: 10.3%
- SQN: -1.38

### RISK_LEVELS

**Best**: RISK_0.7pct
- PF: 0.84
- Return: -10.2%
- Trades: 277
- Win Rate: 35.4%
- Max DD: 10.2%
- SQN: -1.27

### COMBINED

**Best**: COMBINED_ASIA_EXCLUDED+HURST_0.60
- PF: 0.99
- Return: -0.1%
- Trades: 47
- Win Rate: 38.3%
- Max DD: 4.0%
- SQN: -0.02

### GRID_SEARCH

**Best**: GRID_ACTIVE_HOURS_HURST_0.60_15min
- PF: 1.05
- Return: 0.4%
- Trades: 36
- Win Rate: 38.9%
- Max DD: 3.3%
- SQN: 0.15

---

## SESSION_FILTERS

| Configuration | Trades | WR | PF | Return | DD | SQN |
|--------------|--------|----|----|--------|----|----- |
| SESSION_ASIA_EXCLUDED | 226 | 38.1% | 0.86 | -7.4% | 10.2% | -1.11 |
| SESSION_MORNING_LONDON | 180 | 36.1% | 0.81 | -6.4% | 10.4% | -1.30 |
| SESSION_EXTENDED_ACTIVE | 202 | 36.6% | 0.80 | -9.2% | 10.0% | -1.46 |
| SESSION_ACTIVE_HOURS | 189 | 36.5% | 0.79 | -9.3% | 10.2% | -1.52 |
| SESSION_NO_FILTER | 222 | 34.2% | 0.79 | -10.2% | 10.2% | -1.64 |
| SESSION_LONDON_ONLY | 158 | 34.2% | 0.73 | -8.6% | 10.3% | -1.83 |
| SESSION_AFTERNOON_NY | 117 | 32.5% | 0.71 | -9.2% | 10.0% | -1.75 |
| SESSION_NY_ONLY | 125 | 33.6% | 0.70 | -9.8% | 10.1% | -1.91 |
| SESSION_LONDON_NY_OVERLAP | 80 | 28.7% | 0.56 | -8.9% | 10.1% | -2.46 |

## REGIME_FILTERS

| Configuration | Trades | WR | PF | Return | DD | SQN |
|--------------|--------|----|----|--------|----|----- |
| REGIME_HURST_0.52 | 186 | 40.3% | 1.02 | 0.7% | 5.8% | 0.12 |
| REGIME_HURST_0.60 | 57 | 38.6% | 1.00 | 0.0% | 4.3% | 0.01 |
| REGIME_HURST_0.58 | 80 | 38.8% | 1.00 | -0.0% | 4.2% | -0.01 |
| REGIME_HURST_0.55 | 121 | 38.0% | 0.92 | -2.0% | 4.5% | -0.43 |
| REGIME_HURST_0.50 | 240 | 37.5% | 0.91 | -4.8% | 9.4% | -0.73 |
| REGIME_NO_REGIME | 275 | 35.3% | 0.83 | -10.0% | 10.0% | -1.41 |

## TIMEFRAMES

| Configuration | Trades | WR | PF | Return | DD | SQN |
|--------------|--------|----|----|--------|----|----- |
| TIMEFRAME_5min | 269 | 35.3% | 0.83 | -9.7% | 10.3% | -1.38 |
| TIMEFRAME_1min | 277 | 35.4% | 0.83 | -10.1% | 10.1% | -1.43 |
| TIMEFRAME_15min | 272 | 35.3% | 0.83 | -10.1% | 10.1% | -1.42 |
| TIMEFRAME_30min | 268 | 35.4% | 0.83 | -10.1% | 10.1% | -1.43 |

## RISK_LEVELS

| Configuration | Trades | WR | PF | Return | DD | SQN |
|--------------|--------|----|----|--------|----|----- |
| RISK_0.7pct | 277 | 35.4% | 0.84 | -10.2% | 10.2% | -1.27 |
| RISK_1.0pct | 224 | 35.3% | 0.83 | -10.0% | 10.2% | -1.23 |
| RISK_0.5pct | 266 | 35.3% | 0.83 | -10.1% | 10.1% | -1.46 |
| RISK_0.3pct | 312 | 34.6% | 0.81 | -9.8% | 10.0% | -1.75 |

## COMBINED

| Configuration | Trades | WR | PF | Return | DD | SQN |
|--------------|--------|----|----|--------|----|----- |
| COMBINED_ASIA_EXCLUDED+HURST_0.60 | 47 | 38.3% | 0.99 | -0.1% | 4.0% | -0.02 |
| COMBINED_ASIA_EXCLUDED+HURST_0.58 | 68 | 38.2% | 0.99 | -0.2% | 3.7% | -0.05 |
| COMBINED_ASIA_EXCLUDED+HURST_0.55 | 107 | 38.3% | 0.97 | -0.7% | 3.1% | -0.15 |
| COMBINED_ASIA_EXCLUDED+HURST_0.52 | 158 | 38.6% | 0.95 | -1.6% | 6.8% | -0.29 |
| COMBINED_ASIA_EXCLUDED+HURST_0.50 | 201 | 37.3% | 0.89 | -5.0% | 8.8% | -0.82 |
| COMBINED_ASIA_EXCLUDED+NO_REGIME | 228 | 37.7% | 0.84 | -8.2% | 10.3% | -1.22 |

## GRID_SEARCH

| Configuration | Trades | WR | PF | Return | DD | SQN |
|--------------|--------|----|----|--------|----|----- |
| GRID_ACTIVE_HOURS_HURST_0.60_15min | 36 | 38.9% | 1.05 | 0.4% | 3.3% | 0.15 |
| GRID_NO_FILTER_HURST_0.55_5min | 122 | 40.2% | 1.03 | 0.7% | 3.5% | 0.14 |
| GRID_NO_FILTER_HURST_0.55_15min | 124 | 40.3% | 1.00 | 0.1% | 3.6% | 0.02 |
| GRID_ACTIVE_HOURS_HURST_0.60_5min | 37 | 37.8% | 1.00 | -0.0% | 3.7% | -0.00 |
| GRID_NO_FILTER_HURST_0.60_15min | 53 | 37.7% | 0.96 | -0.4% | 4.6% | -0.13 |
| GRID_ACTIVE_HOURS_HURST_0.55_5min | 87 | 37.9% | 0.96 | -0.7% | 3.3% | -0.17 |
| GRID_NO_FILTER_HURST_0.60_5min | 52 | 36.5% | 0.95 | -0.5% | 3.9% | -0.18 |
| GRID_ACTIVE_HOURS_HURST_0.55_15min | 86 | 37.2% | 0.92 | -1.5% | 4.1% | -0.36 |
| GRID_ACTIVE_HOURS_NO_REGIME_5min | 217 | 37.3% | 0.85 | -7.4% | 10.1% | -1.10 |
| GRID_ACTIVE_HOURS_NO_REGIME_15min | 216 | 37.0% | 0.85 | -7.4% | 10.1% | -1.12 |
| GRID_LONDON_NY_OVERLAP_HURST_0.60_5min | 15 | 33.3% | 0.82 | -0.6% | 2.5% | -0.35 |
| GRID_LONDON_NY_OVERLAP_HURST_0.60_15min | 15 | 33.3% | 0.82 | -0.6% | 2.5% | -0.35 |
| GRID_NO_FILTER_NO_REGIME_5min | 252 | 34.5% | 0.82 | -10.4% | 10.4% | -1.51 |
| GRID_NO_FILTER_NO_REGIME_15min | 234 | 35.0% | 0.80 | -10.1% | 10.1% | -1.56 |
| GRID_LONDON_NY_OVERLAP_HURST_0.55_5min | 33 | 30.3% | 0.68 | -2.5% | 3.3% | -1.07 |
| GRID_LONDON_NY_OVERLAP_HURST_0.55_15min | 34 | 29.4% | 0.66 | -2.7% | 3.5% | -1.16 |
| GRID_LONDON_NY_OVERLAP_NO_REGIME_5min | 101 | 30.7% | 0.65 | -8.7% | 10.2% | -2.05 |
| GRID_LONDON_NY_OVERLAP_NO_REGIME_15min | 97 | 29.9% | 0.63 | -8.9% | 10.0% | -2.15 |

---

## FINAL RECOMMENDATIONS

### Top 5 by Profit Factor

1. **GRID_ACTIVE_HOURS_HURST_0.60_15min**: PF=1.05, Return=0.4%, DD=3.3%
2. **GRID_NO_FILTER_HURST_0.55_5min**: PF=1.03, Return=0.7%, DD=3.5%
3. **REGIME_HURST_0.52**: PF=1.02, Return=0.7%, DD=5.8%
4. **REGIME_HURST_0.60**: PF=1.00, Return=0.0%, DD=4.3%
5. **GRID_NO_FILTER_HURST_0.55_15min**: PF=1.00, Return=0.1%, DD=3.6%

### Top 5 by Return (DD < 5%)

1. **GRID_NO_FILTER_HURST_0.55_5min**: Return=0.7%, PF=1.03, DD=3.5%
2. **GRID_ACTIVE_HOURS_HURST_0.60_15min**: Return=0.4%, PF=1.05, DD=3.3%
3. **GRID_NO_FILTER_HURST_0.55_15min**: Return=0.1%, PF=1.00, DD=3.6%
4. **REGIME_HURST_0.60**: Return=0.0%, PF=1.00, DD=4.3%
5. **GRID_ACTIVE_HOURS_HURST_0.60_5min**: Return=-0.0%, PF=1.00, DD=3.7%

### Top 5 by SQN

1. **GRID_ACTIVE_HOURS_HURST_0.60_15min**: SQN=0.15, PF=1.05, Return=0.4%
2. **GRID_NO_FILTER_HURST_0.55_5min**: SQN=0.14, PF=1.03, Return=0.7%
3. **REGIME_HURST_0.52**: SQN=0.12, PF=1.02, Return=0.7%
4. **GRID_NO_FILTER_HURST_0.55_15min**: SQN=0.02, PF=1.00, Return=0.1%
5. **REGIME_HURST_0.60**: SQN=0.01, PF=1.00, Return=0.0%

---

*Report generated by ORACLE + FORGE - Exhaustive Filter Study*
