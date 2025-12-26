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

Migration is complete. For current active modules and architecture state, see `INDEX.md`.

## Operational Docs

Start here:
- `docs/INDEX.md`

## Quick Start

```bash
cd nautilus_gold_scalper
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```
