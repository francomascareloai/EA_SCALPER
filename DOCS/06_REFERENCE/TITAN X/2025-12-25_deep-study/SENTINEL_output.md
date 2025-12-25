SENTINEL v3.2 - Apex Trading Guardian
CLAUDE_MD_VERSION: 3.10.23
DATE: 2025-12-25

DECISION
- NO-GO for adopting Titan X “ladder/grid + Lots Multiplier” mechanics on Apex as-is.
- Conditional GO only for borrowing defensive controls (exposure caps, step expansion), but ONLY after adding explicit Apex HWM-trailing-DD monitoring + ET time gates.

RISK MODEL (DOC SUMMARY)
- Starting lot sizing:
  - Fixed: LS Amount for level 1.
  - “Risk Level” auto lot formula (as stated): Lot size = ((current account balance * account leverage/contract size) * Risk)/100))/10.
  - Auto-Scale compounding: lot increases by fixed increments per cash amount (example pattern: +0.01 lots per $2000).
- Lot growth across levels (core risk driver):
  - Lots Multiplier multiplies the previous level’s lot each new level.
  - Rounding/step rule: lot sizes have 2 decimals and next trade must increase by at least 0.01.
  - LSM Interval applies multiplier every N levels; Max Lot Size caps per-trade lot.
- Pip-step dynamics (how fast levels accumulate):
  - Fixed: new level when price moves PS Amount pips (with Pip Step Multiplier to widen distance by level).
  - Dynamic: Current Pip Step = average(ATR(3) on H1, H4, D1, W1) / DPS Divider; recalculates after each new trade.
  - Time-based: new levels triggered by minutes, not price distance.
  - Stacked: levels can open into profit and drawdown; next lot is based on the farthest trade, then LS Multiplier applied.
- Max Levels: hard cap on number of levels (maximum cost-average steps).
- Stops/closures:
  - “Stop Loss (Each Trade)” can be set to 0.0 (no SL).
  - Account-level closures exist (Account SL/TP, equity protectors, schedule closures) and are tied to VPS local time.

MARTINGALE / GRID ASSESSMENT
- YES, the described “Lots Multiplier + cost averaging levels” is martingale-ish (geometric exposure into adverse move), even if Max Lot Size and LSM Interval are used.

BLOW-UP MODES (STRUCTURE, NOT PERFORMANCE CLAIMS)
- Geometric exposure: with multiplier r>1 and max levels N, total lots scale roughly like LS * (r^N − 1)/(r − 1) until Max Lot Size binds. Deeper levels → rapidly increasing $/pip and margin pressure.
- Faster level accumulation risk:
  - Small fixed PS, shrinking dynamic PS in low vol (ATR small), or time-based stepping can open many levels quickly.
  - Stacked mode can add trades even while “winning”, increasing gross exposure.
  - Bi-directional mode can run two ladders simultaneously (two independent exposure stacks).
- “Rounding + minimum +0.01” can make near-1 multipliers behave more aggressively at small lots.

PROP-FIRM COMPATIBILITY (FTMO VS APEX)
- Titan includes FTMO-style “Max Daily Loss” equity protector logic (as described):
  - Daily Floating = Closed P/L (midnight→midnight) + Floating P/L.
  - Uses CE(S)T day boundaries and mentions an automatic close at 23:45 if breaching to avoid reset failure.
- Apex mismatch (critical):
  - Apex trailing DD is 5% from HIGH-WATER MARK (HWM), and HWM includes unrealized P/L tick-by-tick.
  - A midnight-reset MDL model does not protect against the Apex HWM trap (intraday unrealized peaks raise the floor; reversal can terminate the account even if net P/L is small).

TIMEKEEPING / SCHEDULE RISKS
- The doc repeatedly ties schedule + loss protectors to VPS local time (and even CE(S)T for MDL). Any TZ/drift mismatch vs America/New_York can cause an Apex violation (must be flat by 4:59 PM ET).

GUARDRAILS REQUIRED IF WE BORROW ANY CONCEPTS
- Hard blocks for Apex:
  - Disallow Lots Multiplier > 1, Stacked mode, and Bi-directional mode by default.
  - Require broker-side SL at order entry; never allow “SL=0.0” live.
  - Enforce trailing-DD buffers per project rules (halt at trailing DD ≥ 4.0%; halt-all at ≥4.5%) with tick-by-tick HWM tracking (conservative BID/ASK).
  - Cap: max open ladders (like “Max Charts”), max total lots per symbol, and low Max Levels; require a minimum pip-step floor and mandatory step expansion as DD/levels increase.
  - Enforce ET gates: block new trades after 4:30 PM ET; force-close starting 4:55 PM ET; flat by 4:59 PM ET.

NEXT
- If you want to explore this safely: run a falsification-first “Apex HWM survival” simulation (Monte Carlo on adverse excursions) before implementing any grid mechanics.
