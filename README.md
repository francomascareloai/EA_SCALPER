# EA_SCALPER_XAUUSD (MQL5 Snapshot)

This repository is now the public **MQL5 snapshot** of the original project.

It is kept public for **study, analysis, and engineering collaboration** (PR scope is limited — see below).

## What this is

- A public MQL5 snapshot (larger than the minimal CORE demo).
- A reference codebase to learn from, discuss architecture, and contribute improvements in **docs/infra/quality**.

## What this is NOT

- Not a promise of profitability.
- Not financial advice.
- Not allowed for live/funded trading or broker-connected paper/demo execution.

## Important: Trading restrictions

This repository is published for **study and demonstration only**.

- See `TRADING_RESTRICTIONS.md`
- See `LICENSE`

## Where to go now (Open-Core split)

- **Public minimal CORE (study/demo only):** `aurum-core`
  - https://github.com/francomascareloai/aurum-core
  - Minimal, auditable demo EA + educational indicators.

- **Private PREMIUM (production / edge):** `aurum-pro`
  - https://github.com/francomascareloai/aurum-pro (private)
  - Python/Nautilus production system + operational tooling.

## PREMIUM teaser (Python system — high level)

The private PREMIUM system (`aurum-pro`) is a production-grade Python stack focused on:

- Strategy layer (multiple variants, routing/selection)
- Execution layer (adapters, cost/latency modeling, ops wiring)
- Risk & compliance (drawdown tracking, safety gates, time windows)
- Backtesting & optimization (walk-forward validation, stress tests)
- Observability and runbooks

This public snapshot does not include proprietary rules, parameters, or operational “go-live” wiring.

## Support development (PC/infra goal: US$ 3,000)

If you want to support development (new PC/infra + dedicated time), you can:

- GitHub Sponsors: https://github.com/sponsors/francomascareloai
- Telegram (private automation / partnerships): @francomascareloai

Support tiers are intended for educational content and engineering Q&A — not signals, not performance claims.

## Contributing (PR scope)

This repository accepts PRs with a **limited scope**:

- ✅ Accepted: docs, CI/build, tooling, refactors for clarity, and non-edge bugfixes.
- ❌ Not accepted: strategy/edge changes, entry/exit rules, or anything that bypasses `TRADING_RESTRICTIONS.md`.

A lightweight CLA is required before merging contributions (details in `CONTRIBUTING.md`).

## Contact

- Telegram: @francomascareloai

---

## Disclaimer

This project is shared for educational purposes only. Trading involves substantial risk of loss and is not suitable for all investors.
