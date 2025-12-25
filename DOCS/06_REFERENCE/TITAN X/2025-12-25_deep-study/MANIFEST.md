# TITAN X – Deep Study Manifest

**Date:** 2025-12-25
**Source doc:** `DOCS/06_REFERENCE/TITAN X/Titan_X.md`

## Objective
Extract all actionable, non-proprietary learnings from Titan X documentation:
- Core mechanism (entries, grid/ladder logic, exits)
- Risk model + drawdown controls
- Prop-firm compliance fit (Apex/FTMO) and failure modes
- What can be safely replicated as generic ideas in our system (without copying proprietary expressions)

## Outputs
- `CRUCIBLE_output.md` – Strategy thesis, regime assumptions, edge plausibility
- `SENTINEL_output.md` – Risk/DD math review, prop-firm compatibility, blow-up modes
- `FORGE_output.md` – Implementation mapping ideas (what modules we'd need), invariants, test ideas
- `CRITIC_output.md` – Adversarial review: hidden risks, overfit cues, exploitation of market structure vs martingale
- `SYNTHESIS.md` – Consolidated takeaways + recommended next experiments

## Guardrails (IMPORTANT)
- This is a third-party paid product; we will not attempt to recreate protected code or bypass licensing.
- We only extract generalizable concepts (risk controls, scheduling, parameter hygiene, monitoring).
