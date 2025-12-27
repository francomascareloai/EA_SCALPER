# CRUCIBLE Review — Phase 14 Plan

AGENT: crucible-gold-strategist
STATUS: COMPLETE
VERDICT: GO with constraints

Source plan:
- `/.planning/phases/14-nautilus-expansion/14-00-PLAN_MASTER.md`

Agent output (verbatim):

## CRUCIBLE Output

AGENT: CRUCIBLE
VERSION: 4.2
CLAUDE_MD_VERSION: 3.10.9
STATUS: COMPLETE

Summary
Phase 14’s indicator expansion is directionally sound as an architecture/framework upgrade, but the proposed indicator set risks adding parameter surface and data-vendor artifacts (especially VWAP/Pressure) unless integrated as constrained gates with falsification-first testing and explicit XAUUSD execution realism.

Verdict
GO with constraints

Integration recommendations
- Treat the 5 indicators as risk reducers (filters/gates) first, not “edge creators”; prioritize fewer trades with higher expectancy over more signals.
- Enforce parameter discipline: freeze canonical defaults and allow at most 1–2 tunables total.
- Use two-stage scoring:
  - Stage 1 (Regime/conditions gate): EfficiencyRatio decides trend-efficient vs noisy/range; selects strategy template.
  - Stage 2 (Confluence score): keep existing SMC/structure as primary; add new indicators as capped, monotonic penalties.
- Indicator-specific roles:
  - EfficiencyRatio: regime gate only.
  - KeltnerPosition: location filter as soft penalty.
  - VWAP: anchor distance sanity check; beware volume semantics.
  - Pressure: diagnostic first; if used, penalty/veto for entries fighting sustained pressure.
  - FuzzyCandlesticks: closed-bar only; veto if no rejection confirmation.
- Add missing XAUUSD scalp realism requirements:
  - Variable spread model + session multipliers; ensure SL distance > 3× expected spread.
  - Slippage + latency modeled before trusting incremental edge.

Falsification test suite
- Ghost test: random entries while keeping all new gates/time/DD rules constant; profitability persisting implies bias/artifact.
- Permutation importance: block-shuffle each indicator stream; keep only those with material degradation when permuted.
- Shifted-levels: perturb VWAP and SMC levels by bounded offsets; unchanged performance implies precision illusion.
- Cost-stress sweep: spread/slippage/latency multipliers by session.
- Session-split OOS: tune on London/overlap, test on NY-only and Asia-only.
