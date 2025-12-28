---
name: build-onnx
description: Build, train, and export ONNX models for MQL5 trading
---

# /build-onnx - ONNX Model Builder

Launch the **ONNX Model Builder** droid to create production-ready ML models for MQL5.

## Activation

Launch the Task tool with droid: `onnx-model-builder`

## Capabilities

### Model Types
- **Direction Model**: LSTM/xLSTM for bullish/bearish prediction
- **Volatility Model**: GRU for ATR forecasting
- **Fakeout Detector**: CNN for breakout validation
- **Regime Classifier**: Random Forest for market state

### Pipeline Steps
1. Requirements analysis
2. Feature engineering specification
3. Data pipeline creation
4. Model architecture design
5. Training with Walk-Forward Analysis
6. ONNX export and validation
7. MQL5 integration code generation
8. Documentation

## Usage

```
/build-onnx direction model for XAUUSD M15

/build-onnx volatility forecaster 5-bar horizon

/build-onnx fakeout detector for breakout trades

/build-onnx regime classifier Hurst entropy
```

## Deliverables

For each model:
- `model_name.onnx` - ONNX model file
- `model_name_integration.mqh` - MQL5 code
- `model_name_scaler.json` - Normalization params
- `model_name_docs.md` - Full documentation
- `training_script.py` - Reproducible training code

## Quality Standards

- WFE (Walk-Forward Efficiency) >= 0.6
- OOS Accuracy >= 55% for direction models
- Inference time < 50ms
- Proper normalization documented
