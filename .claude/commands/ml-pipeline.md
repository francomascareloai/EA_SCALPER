---
name: ml-pipeline
description: Full ML pipeline - from research to deployed ONNX model in MQL5
---

# /ml-pipeline - Complete ML Trading Pipeline

Execute the complete Machine Learning pipeline for trading systems.

## Pipeline Stages

### Stage 1: Research & Design
- Invoke `/ml-research` for topic exploration
- Invoke `/singularity` for architecture design
- Define features, model type, validation criteria

### Stage 2: Implementation
- Invoke `/build-onnx` for model creation
- Generate training scripts
- Create data pipelines
- Implement feature engineering

### Stage 3: Validation
- Walk-Forward Analysis (WFE >= 0.6)
- Monte Carlo simulation
- Out-of-sample testing
- Overfitting checks

### Stage 4: Integration
- Export to ONNX format
- Generate MQL5 integration code
- Update Python Agent Hub
- Test end-to-end inference

### Stage 5: Documentation
- Model specifications
- Feature documentation
- Usage guide
- Performance benchmarks

## Usage

```
/ml-pipeline direction prediction XAUUSD

/ml-pipeline regime detection system

/ml-pipeline fakeout filter for OB breakouts

/ml-pipeline complete ML-enhanced EA
```

## Orchestration

This command orchestrates:
1. **Singularity Architect** - Strategy design
2. **ml-trading-research skill** - Research phase
3. **onnx-model-builder droid** - Implementation
4. **Backtest Commander** - Validation

## Timeline Estimates

| Pipeline | Research | Build | Validate | Total |
|----------|----------|-------|----------|-------|
| Simple Model | 1-2h | 2-4h | 2-4h | 5-10h |
| Complex Model | 2-4h | 4-8h | 4-8h | 10-20h |
| Full System | 4-8h | 8-16h | 8-16h | 20-40h |

## Quality Gates

- [ ] Research completed with confidence > MEDIUM
- [ ] Architecture approved by Singularity Architect
- [ ] WFE >= 0.6 on Walk-Forward Analysis
- [ ] OOS performance >= 55% of IS
- [ ] Inference time < 50ms
- [ ] MQL5 integration tested
- [ ] Documentation complete
