# Nautilus Gold Scalper

Professional XAUUSD Gold Scalping System built on NautilusTrader.

## Structure

```
nautilus_gold_scalper/
├── configs/          # YAML configurations
├── data/             # Raw, processed data and models
├── src/              # Source code
│   ├── core/         # Base definitions, data types, exceptions
│   ├── indicators/   # Technical indicators (session, regime, structure)
│   ├── risk/         # Risk management (prop firm, position sizing)
│   ├── signals/      # Signal generation (confluence, MTF)
│   ├── strategies/   # NautilusTrader strategies
│   ├── ml/           # Machine learning models
│   ├── execution/    # Order execution (Apex adapter)
│   └── utils/        # Utilities
├── tests/            # Unit tests
├── notebooks/        # Jupyter notebooks
└── scripts/          # Execution scripts
```

## Migration Status

- [x] STREAM CORE: definitions.py, data_types.py, exceptions.py
- [ ] STREAM A: session_filter.py, regime_detector.py
- [ ] STREAM B: structure_analyzer.py, footprint_analyzer.py
- [ ] STREAM C: order_block, fvg, liquidity_sweep, amd
- [ ] STREAM D: prop_firm_manager, position_sizer, drawdown, var
- [ ] STREAM E: mtf_manager, confluence_scorer
- [ ] STREAM F: base_strategy, gold_scalper_strategy
- [ ] STREAM G: feature_engineering, model_trainer, ensemble
- [ ] STREAM H: trade_manager, apex_adapter

## Quick Start

```bash
cd nautilus_gold_scalper
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```
