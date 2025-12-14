//+------------------------------------------------------------------+
//|                                              BacktestIndex.mqh   |
//|                                                           Franco |
//|                   EA_SCALPER_XAUUSD v4.0 - Backtest Layer Index  |
//+------------------------------------------------------------------+
#property copyright "Franco"
#property link      "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Backtest Layer Components                                         |
//|                                                                   |
//| Purpose: Add realism to backtests for robust strategy validation  |
//|                                                                   |
//| Components:                                                       |
//| 1. CBacktestRealism - Slippage, spread, latency simulation        |
//|                                                                   |
//| Philosophy:                                                       |
//| "If it works in pessimistic backtest, it will work live"          |
//+------------------------------------------------------------------+

#include "CBacktestRealism.mqh"

//+------------------------------------------------------------------+
//| Usage Example                                                     |
//+------------------------------------------------------------------+
/*
CBacktestRealism g_backtest;

// OnInit
g_backtest.Init(_Symbol, SIM_PESSIMISTIC);

// Before each trade
ENUM_MARKET_CONDITION condition = g_backtest.DetectCondition(
   in_news_window, 
   is_asian_session, 
   volatility_percentile
);

SSimulationResult sim = g_backtest.SimulateTrade(
   requested_price, 
   is_buy, 
   condition
);

if(sim.order_rejected)
{
   Print("Order rejected: ", sim.reject_reason);
   return;
}

// Use adjusted entry
double actual_entry = sim.adjusted_entry;
double actual_spread = sim.adjusted_spread;
int latency = sim.latency_ms;

Print("Slippage: ", sim.slippage_points, " points");
Print("Total cost: ", sim.total_cost_points, " points");

// OnDeinit - Print statistics
g_backtest.PrintStatistics();
*/

//+------------------------------------------------------------------+
//| Simulation Modes Summary                                          |
//+------------------------------------------------------------------+
/*
┌────────────────┬─────────────┬──────────┬─────────┬────────────┐
│ Mode           │ Slippage    │ Spread   │ Latency │ Rejection  │
├────────────────┼─────────────┼──────────┼─────────┼────────────┤
│ OPTIMISTIC     │ 0 pts       │ 1.5 pips │ 0 ms    │ 0%         │
│ NORMAL         │ 2-10 pts    │ 2-6 pips │ 50-500ms│ 2%         │
│ PESSIMISTIC    │ 5-50 pts    │ 2.5-12 p │ 100-1.5s│ 10%        │
│ EXTREME        │ 10-200 pts  │ 4-40 p   │ 200-3s  │ 25%        │
└────────────────┴─────────────┴──────────┴─────────┴────────────┘

Recommended: SIM_PESSIMISTIC for validation
*/

//+------------------------------------------------------------------+
//| News Event Multipliers (Pessimistic Mode)                         |
//+------------------------------------------------------------------+
/*
During HIGH impact news:
- Slippage: 10x base (50+ points possible)
- Spread: 5x base (12+ pips)
- Latency: +500ms extra
- Rejection: 30% (3x normal)

This ensures the EA can handle worst-case scenarios.
*/

//+------------------------------------------------------------------+
