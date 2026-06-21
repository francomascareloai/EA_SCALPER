# EA_SCALPER_XAUUSD — XAUUSD (Gold) Trading Research, in the open

> **Status: work in progress.** This is an active research-and-engineering project, not a finished product. The robot is **not** "done" — we are still building, fixing, and validating in the open. If you're here for a plug-and-play money machine, this isn't it (and you should be suspicious of anyone selling you one).

This repository is the public **MQL5 snapshot** of a larger XAUUSD automated-trading project. It's kept public for **study, analysis, and engineering collaboration**.

## Why this project exists

Before writing a line of strategy code, we analyzed **5,000+ trading bots** floating around forums, marketplaces and Telegram groups — to map what's real engineering versus what's repackaged hype. Most were the same recycled martingale/grid with a new skin. This project is the attempt to do the opposite, in the open: show the actual code, the actual decisions, and the actual unfinished parts.

So the honest pitch is: **no scams, no signals, no "guaranteed" returns — just the engineering, visible and in progress.**

## What this is

- A public MQL5 snapshot (larger than the minimal CORE demo) you can read and learn from.
- A reference codebase to discuss architecture, study prop-firm constraints (Apex / FTMO style), and contribute improvements in **docs / infra / quality**.
- A "building in public" log of a real, messy, still-evolving system.

## What this is NOT

- ❌ Not a promise of profitability — there are no live performance claims here.
- ❌ Not financial advice.
- ❌ Not a finished or production-ready robot.
- ❌ Not allowed for live/funded trading or broker-connected paper/demo execution (see `TRADING_RESTRICTIONS.md`).

## The bigger picture (open-core split)

- **Public minimal CORE (study/demo only):** [`aurum-core`](https://github.com/francomascareloai/aurum-core)
  - Minimal, auditable demo EA + educational indicators.
- **This repo:** the broader MQL5 snapshot for study and collaboration.
- **Private work-in-progress system:** the Python/NautilusTrader stack where the active development happens (not public yet).

The private side is where we're currently working on the hard parts:

- Strategy layer (multiple variants, routing/selection) — *in progress*
- Execution layer (adapters, cost/latency/slippage modeling) — *in progress*
- Risk & compliance (drawdown tracking, safety gates, time windows) — *in progress*
- Backtesting & optimization (walk-forward, Monte Carlo, stress tests) — *in progress*
- Observability and runbooks — *in progress*

None of the proprietary rules, parameters, or "go-live" wiring are included in this public snapshot — partly because they're proprietary, and partly because **they're not finished and we won't pretend otherwise.**

## Tech stack

- **MQL5** — MetaTrader 5 Expert Advisors and indicators (this snapshot).
- **Python + NautilusTrader** — event-driven backtesting/execution (private side).
- **SMC concepts, ML regime detection, ONNX inference** — explored and being validated, not all wired end-to-end yet.

## Contributing (limited PR scope)

This repository accepts PRs with a **limited scope**:

- ✅ Accepted: docs, CI/build, tooling, refactors for clarity, and non-edge bugfixes.
- ❌ Not accepted: strategy changes, entry/exit rules, or anything that bypasses `TRADING_RESTRICTIONS.md`.

A lightweight CLA is required before merging contributions (see `CONTRIBUTING.md`).

## For serious engineers — let's build together

If you're a serious, dedicated engineer (quant, Python/Nautilus, MQL5, ML, infra) and you genuinely want to help move this project forward, there's an open door. This isn't a "leave a drive-by PR" ask — it's an invitation to real collaboration.

The deal is simple and two-way:

- You contribute real engineering to the project.
- In return, I help you back — mentorship, deep technical Q&A, and working through hard problems together.

If that's you, reach out on Telegram (**@francomascareloai**) with a bit about your background and what you'd like to work on. Strong contributors can earn access to deeper parts of the project beyond this public snapshot.

What I'm *not* looking for: signal-seekers, copy-paste contributors, or anyone trying to extract the edge. This is for people who like the engineering.

## Support development (optional)

If the project is useful to you and you want to support the engineering work:

- GitHub Sponsors: https://github.com/sponsors/francomascareloai
- Telegram (engineering Q&A): @francomascareloai

Support is for educational content and engineering Q&A — **not signals, not performance claims.**

## Contact

- Telegram: @francomascareloai

---

## Disclaimer

This project is shared for educational purposes only. Trading involves substantial risk of loss and is not suitable for all investors. Past results — simulated or real — do not guarantee future performance.
