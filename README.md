# Aurum (Legacy Snapshot)

This repository is kept **unarchived** as a **legacy snapshot** of the original project to preserve history, stars, forks, and references.

## Origin (short)

This started as a hands-on effort: studying and testing many approaches to separate what is real from what is noise in live markets.

Over time, the main system grew into a much larger production stack (validation workflows, safety constraints, operational tooling). At that point, keeping everything public no longer made sense, so the project moved to an **open-core split**:

- **CORE** stays public as a minimal demo for learning.
- **PREMIUM** stays private as the production codebase.

## Where to go now (Open-Core split)

- **Public demo CORE (study/demo only):** `aurum-core`
  - GitHub: https://github.com/francomascareloai/aurum-core
  - What it is: a **simplified MQL5 demo EA** intended for study and demonstration.
  - What it is NOT: production code.

- **Private PREMIUM (production / edge):** `aurum-pro`
  - GitHub (private): https://github.com/francomascareloai/aurum-pro
  - What it is: the private production codebase (strategies, optimization, infra, etc.).

## Important (read first)

- This legacy repository is **not** the place for new development.
- **No market dataset is redistributed** in the public CORE.
- The public CORE is licensed for **non-commercial** use and explicitly forbids **live/funded** trading and **broker-connected paper/demo** usage.
  - Source of truth for restrictions: `TRADING_RESTRICTIONS.md` in `aurum-core`.

## What changes here going forward

- This repo remains online for reference and historical context.
- Updates here should be limited to:
  - Documentation pointing people to `aurum-core` / `aurum-pro`
  - Clarifications, security notices, and migration notes

## Support / Issues

- For anything related to the **public demo CORE**, open issues in `aurum-core`:
  - https://github.com/francomascareloai/aurum-core/issues
- For PREMIUM support (private), use the private channels you already have with Franco.

## Migration notes (for developers)

If you cloned this repo previously:

- If you want the **public demo / study** version: move to `aurum-core`.
- If you are a collaborator on the private repo: use `aurum-pro`.

This repo is intentionally not positioned as “runnable” for trading.

## What was removed from `main`

- The Python/Nautilus implementation (`nautilus_gold_scalper/`) was removed from `main` to keep the legacy repo focused and reduce duplication with the private `aurum-pro`.
- If you need the production-grade Python system, it lives in `aurum-pro` (private).

---

## Disclaimer

This project is shared for educational purposes only. Trading involves substantial risk of loss and is not suitable for all investors.
