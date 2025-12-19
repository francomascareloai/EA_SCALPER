# Phase 04.5 Findings: ML Pipeline Audit

**Scope:** ML feature engineering, training, and inference components for Nautilus gold scalper.

**Files reviewed (source of truth):**
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/ml/feature_engineering.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/ml/ensemble_predictor.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/ml/model_trainer.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/ml/README.md` (intended usage)

**Plan applied:** `.planning/phases/08-nautilus-deep-audit/05.5-PHASE-04.5-PLAN.md` (file discovery + ML leakage checklist).

---

## Executive Verdict

**Look-ahead bias verdict: FAIL (CRITICAL)**
- `StackingEnsemble.fit()` uses non-temporal `KFold` and trains on future data relative to validation folds. This is a direct look-ahead leak if used for time-series. (See Issues: C-ML-001)

**Overall ML pipeline status:** **BLOCKED** until leakage risk is removed and train/inference parity is enforced.

---

## 1) File Discovery (MANDATORY FIRST STEP)

**Expected files found:**
- `nautilus_gold_scalper/src/ml/feature_engineering.py`
- `nautilus_gold_scalper/src/ml/ensemble_predictor.py`
- `nautilus_gold_scalper/src/ml/model_trainer.py`

**Additional ML-relevant files:**
- `nautilus_gold_scalper/src/ml/README.md`
- `nautilus_gold_scalper/src/ml/__init__.py`

No other ML training/inference usage found in `nautilus_gold_scalper/src/` (these modules are not yet wired into strategies).

---

## 2) Feature Engineering Audit (`feature_engineering.py`)

### Summary
- No negative shifts found (no `shift(-1)` usage).
- No `rolling(..., center=True)` usage.
- No `bfill`, `ffill`, `interpolate`, or `reindex(fill_method=...)` calls.
- All features use trailing windows or current-bar data only.
- **Critical dependency:** index order must be chronological ascending; not enforced in code.

### Temporal Trace (unique feature patterns; 5+ patterns, 3 bars each)

> Note: traces below are conceptual window boundaries derived from the code. They assume bars are time-sorted ascending and represent completed bars (close available at bar end).

#### Pattern A: Shift-based return
**Feature:** `returns = close.pct_change()`
**Dependencies:** `close[t]`, `close[t-1]` (<= T)
**Temporal integrity:** uses only current + prior bar

- Bar 1: 2024-03-15 10:30:00 -> uses 10:30 and 10:25
- Bar 2: 2024-07-02 09:15:00 -> uses 09:15 and 09:10
- Bar 3: 2025-01-08 14:55:00 -> uses 14:55 and 14:50

#### Pattern B: Rolling mean/std (trailing)
**Feature:** `volume_ratio = volume / volume.rolling(20).mean()`
**Dependencies:** `volume[t-19:t]` (20 bars, <= T)
**Temporal integrity:** trailing window, no future bars

- Bar 1: 2024-03-15 10:30:00 -> window 09:35 to 10:30
- Bar 2: 2024-07-02 09:15:00 -> window 08:20 to 09:15
- Bar 3: 2025-01-08 14:55:00 -> window 14:00 to 14:55

#### Pattern C: Exponential moving average
**Feature:** `ema_21_dist = (close - close.ewm(span=21).mean()) / close`
**Dependencies:** current and prior closes only (EWMA is causal when adjust=False)
**Temporal integrity:** causal with `adjust=False`

- Bar 1: 2024-03-15 10:30:00 -> uses all closes <= 10:30
- Bar 2: 2024-07-02 09:15:00 -> uses all closes <= 09:15
- Bar 3: 2025-01-08 14:55:00 -> uses all closes <= 14:55

#### Pattern D: Rolling max/min (structure)
**Feature:** `swing_high_distance = (high.rolling(11).max() - close) / close`
**Dependencies:** `high[t-10:t]` (11 bars, <= T)
**Temporal integrity:** trailing max, no center window

- Bar 1: 2024-03-15 10:30:00 -> window 09:40 to 10:30
- Bar 2: 2024-07-02 09:15:00 -> window 08:25 to 09:15
- Bar 3: 2025-01-08 14:55:00 -> window 14:05 to 14:55

#### Pattern E: Rolling apply with custom function
**Feature:** `hurst_exponent = close.rolling(100).apply(_calculate_hurst_simple)`
**Dependencies:** `close[t-99:t]` (100 bars, <= T)
**Temporal integrity:** trailing window

- Bar 1: 2024-03-15 10:30:00 -> window 02:15 to 10:30
- Bar 2: 2024-07-02 09:15:00 -> window 01:00 to 09:15
- Bar 3: 2025-01-08 14:55:00 -> window 06:40 to 14:55

#### Pattern F: Temporal features (time-of-day)
**Feature:** `hour_sin = sin(2*pi*hour/24)`
**Dependencies:** timestamp of current bar only
**Temporal integrity:** current bar timestamp only

- Bar 1: 2024-03-15 10:30:00 -> hour=10
- Bar 2: 2024-07-02 09:15:00 -> hour=9
- Bar 3: 2025-01-08 14:55:00 -> hour=14

### Pandas leakage traps check (explicit)
- `shift(-1)`: **NOT FOUND**
- `rolling(center=True)`: **NOT FOUND**
- `bfill` / `ffill`: **NOT FOUND**
- `interpolate`: **NOT FOUND**
- `reindex(fill_method=...)`: **NOT FOUND**

### Edge cases tested (static review)
- **Insufficient history**: rolling windows produce NaN; `compute_all_features()` drops rows -> caller must align labels.
- **Unsorted index**: rolling windows operate on row order, not chronological time (potential look-ahead if descending).
- **Zero or NaN volume**: VWAP/volume_ratio divisions may yield inf/NaN; no explicit guard beyond `+1e-10`.

### Confidence
**MEDIUM.** Feature calculations are causal, but lack of index-order validation and external label alignment reduce certainty.

**Verification method:** Add unit test asserting `df.index.is_monotonic_increasing` and validate a known sample window vs expected; enforce or sort input.

**Escalation:** Human review required unless index-order validation is added and enforced.

---

## 3) Model Training Audit (`model_trainer.py`)

### Summary
- Uses `WalkForwardValidator` with `gap` and sequential train/test windows (good).
- Falls back to `PurgedTimeSeriesSplit` (train strictly before test with gap).
- **No explicit enforcement of chronological order** of `X`/`y`.
- **No label alignment checks** (e.g., verifying that `y[t]` is derived from future returns and aligned with features).
- **No scaler integration/persistence** (scaling is outside of trainer; risk of leakage if fit on full dataset).

### Walk-forward schedule (as implemented)
- Train: `train_size=5000`
- Gap: `gap=10`
- Test: `test_size=500`
- Step: `step_size=250`
- Splits progress forward only; no overlap leakage between train/test due to gap.

### Edge cases tested (static review)
- **Small dataset**: if `len(X)` < `train_size + gap + test_size`, no splits -> falls back to purged split; may still yield zero splits.
- **Gap larger than train span**: can cause `train_end <= 0` and drop folds.
- **NaN features**: no internal handling; assumes `X` already cleaned.

### Confidence
**MEDIUM.** Temporal split logic is correct, but correctness depends on external ordering + label alignment + scaling discipline.

**Verification method:** Add explicit `assert np.all(np.diff(time_index) > 0)` or pass timestamps into trainer; include label alignment test (target at t+N vs features at t).

**Escalation:** Human review required unless ordering/label checks are enforced in code.

---

## 4) Ensemble Predictor & Stacking (`ensemble_predictor.py`)

### Summary
- Weighted voting inference is purely forward-looking with provided features.
- Calibration (`fit_calibration`) can leak if passed test data (no guard).
- **StackingEnsemble.fit uses `KFold(shuffle=False)`**, which still trains on future samples relative to validation folds in time series.

### Edge cases tested (static review)
- **Feature shape**: `predict()` coerces 1D to 2D; no feature count validation.
- **ONNX output shape**: assumes binary classification; other shapes may mis-map probabilities.
- **No models loaded**: returns neutral prediction with 0 confidence (safe default).

### Confidence
**MEDIUM.** Inference path is safe if input features are correct, but stacking CV is a hard look-ahead leak.

**Verification method:** Replace `KFold` with `TimeSeriesSplit` or `PurgedTimeSeriesSplit`; add unit tests verifying fold ordering.

**Escalation:** Human review required until stacking CV is corrected.

---

## 5) Train vs Inference Parity (DIFF Verification)

**Required DIFF checks (explicit):**
1. **Feature set**: Training uses `FeatureEngineer.compute_all_features()`. Inference must use the same class/version. **No enforcement or version pin.**
2. **Feature order**: Models consume raw numpy arrays with no column names. **No stored feature order.**
3. **Scaling/normalization**: `scale_features(fit=True)` exists but trainer/predictor do not persist scaler. **No parity guarantee.**
4. **Target alignment**: No validation that `y` aligns to features (e.g., `y[t]` for future return). **Not enforced.**
5. **Windowing**: Rolling windows require sufficient history; inference must ensure enough bars. **Not enforced.**

**Verdict:** Train/inference parity is **NOT VERIFIED**; requires explicit pipeline enforcement.

---

## 6) ONNX Serialization & Normalization Params

- ModelTrainer exports model to ONNX (or pickle fallback).
- **Normalization/scaler parameters are not stored** in ONNX metadata or alongside the model.
- `FeatureEngineer` keeps scaler in-memory only; no persistence path or retrieval in inference.

**Risk:** Inference may apply different scaling or none at all, causing silent performance drift and false backtest optimism.

---

## 7) Mandatory Adversarial Checks

### “How would I accidentally leak future data?” (per module)
- **FeatureEngineer:**
  - If input is sorted descending, rolling windows use future bars.
  - If using partial (incomplete) current bar, features incorporate data not available at decision time.
  - If scaler is fit on full dataset (train + test), leakage occurs.

- **ModelTrainer:**
  - Passing `X`/`y` not in chronological order breaks walk-forward semantics.
  - `y` derived from `close.shift(-1)` but not aligned with `X` will leak future info into train/test.
  - Hyperparameter tuning or calibration on test data (external usage) leaks.

- **EnsemblePredictor/Stacking:**
  - `StackingEnsemble.fit` uses KFold -> training folds include future data.
  - Calibration fitted on test set inflates reported accuracy and confidence.

### Pre-mortem: “Why would this fail in live trading?”
- Backtest appears strong due to stacking leakage or scaling on full data.
- Live inference uses different feature order/scaling than training, collapsing accuracy.
- Data feed provides incomplete bars; features drift intra-bar and mismatch training assumptions.
- Unsorted data in backtest silently injects future information into rolling windows.

### “What assumptions about data availability?”
- Bar data is **chronologically ordered**, complete, and final (close/high/low fixed).
- Sufficient warmup history exists (>= 200 bars for Hurst/EMA/RSI chains).
- Feature columns are stable and ordered consistently between training and inference.
- Labels are aligned to features with explicit future horizon shifts (not shown in code).

### Edge cases (minimum 3 per module)
- **FeatureEngineer:** insufficient bars; descending index; zero/NaN volume.
- **ModelTrainer:** too-short dataset yields zero splits; large gap removes train window; NaN features.
- **EnsemblePredictor:** models missing; ONNX output not binary; feature count mismatch.

### Confidence Level
- FeatureEngineer: **MEDIUM** (index-order + label alignment risks)
- ModelTrainer: **MEDIUM** (ordering + scaling + label alignment external)
- EnsemblePredictor: **MEDIUM** (stacking leak + feature order not enforced)

**Uncertainty + verification required:** add explicit tests for time ordering, label alignment, and scaler persistence; replace stacking CV with time-series CV.

---

## 8) Issues Found (Severity)

### CRITICAL
1. **C-ML-001 (Look-ahead leak):** `StackingEnsemble.fit()` uses `KFold` which trains on future data relative to validation folds. **Direct look-ahead for time series.**
   - **Location:** `ensemble_predictor.py` (StackingEnsemble.fit)
   - **Fix:** use `TimeSeriesSplit` or `PurgedTimeSeriesSplit` with embargo; train only on past.

### HIGH
1. **H-ML-001 (Scaling leakage / parity):** `FeatureEngineer.scale_features()` can fit on full dataset; no trainer-level enforcement or scaler persistence. Inference may use different scaling.
   - **Fix:** fit scaler on train only; persist scaler params; enforce transform in inference.
2. **H-ML-002 (Chronological order not enforced):** rolling windows assume ascending index; descending or unsorted data causes implicit look-ahead.
   - **Fix:** assert `df.index.is_monotonic_increasing` or sort with explicit warning.

### MEDIUM
1. **M-ML-001 (Feature order/metadata not enforced):** models consume numpy arrays with no stored feature list. Feature drift or column reorder can silently corrupt inference.
   - **Fix:** store `feature_names` alongside model; validate on load/inference.
2. **M-ML-002 (Label alignment not validated):** trainer assumes `y` aligned to `X`; no guard against future-shifted labels leaking into current features.
   - **Fix:** add alignment checks or include label generation utilities with explicit horizon.

---

## 9) Recommendations (Priority Order)

1. **Replace stacking CV with time-series-safe CV** (TimeSeriesSplit or PurgedTimeSeriesSplit).
2. **Introduce a unified ML pipeline object** that:
   - validates chronological order,
   - computes features,
   - fits scaler on train only,
   - persists scaler + feature list,
   - enforces parity on inference.
3. **Add label-alignment helper** (explicit horizon `y[t] = sign(close[t+h] - close[t])`) and assert alignment.
4. **Add unit tests**: index monotonicity, scaler persistence parity, stacking CV ordering, and feature order checks.

---

**Phase 04.5 Status:** COMPLETE (BLOCKED by look-ahead leak in stacking + parity gaps)
