//+------------------------------------------------------------------+
//|                                                 SafetyIndex.mqh |
//|                                                           Franco |
//|                   EA_SCALPER_XAUUSD v4.0 - Safety Layer Index    |
//+------------------------------------------------------------------+
#property copyright "Franco"
#property link      "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Safety Layer Components                                           |
//|                                                                   |
//| Purpose: Protect the account from catastrophic losses             |
//|                                                                   |
//| Components:                                                       |
//| 1. CCircuitBreaker - DD limits, consecutive loss tracking         |
//| 2. CSpreadMonitor - Spread analysis and trading gates             |
//+------------------------------------------------------------------+

#include "CCircuitBreaker.mqh"
#include "CSpreadMonitor.mqh"

//+------------------------------------------------------------------+
//| Consolidated Safety Gate                                          |
//| Use this struct to combine all safety checks                      |
//+------------------------------------------------------------------+
struct SSafetyGate
{
   bool              can_trade;
   double            size_multiplier;   // 0.0 - 1.0
   int               score_adjustment;  // Negative adjustments
   string            reason;
   
   // Individual statuses
   bool              circuit_ok;
   bool              spread_ok;
   
   void Reset()
   {
      can_trade = true;
      size_multiplier = 1.0;
      score_adjustment = 0;
      reason = "OK";
      circuit_ok = true;
      spread_ok = true;
   }
};

//+------------------------------------------------------------------+
//| Helper class to combine all safety checks                         |
//+------------------------------------------------------------------+
class CSafetyManager
{
private:
   CCircuitBreaker   m_circuit_breaker;
   CSpreadMonitor    m_spread_monitor;
   SSafetyGate       m_gate;
   bool              m_initialized;
   
public:
                     CSafetyManager() { m_initialized = false; m_gate.Reset(); }
                    ~CSafetyManager() {}
   
   //--- Initialization
   bool Init(string symbol = "", 
             double daily_dd = 4.0, 
             double total_dd = 8.0,
             int max_consecutive = 5,
             int cooldown_min = 120,
             int spread_history = 100)
   {
      bool ok = true;
      
      ok &= m_circuit_breaker.Init(daily_dd, total_dd, max_consecutive, cooldown_min);
      ok &= m_spread_monitor.Init(symbol, spread_history);
      
      m_initialized = ok;
      
      if(ok)
         Print("CSafetyManager: All safety components initialized");
      else
         Print("CSafetyManager: WARNING - Some components failed to initialize");
      
      return ok;
   }
   
   //--- Main check - call before any trade decision
   SSafetyGate Check()
   {
      m_gate.Reset();
      
      if(!m_initialized)
      {
         m_gate.can_trade = false;
         m_gate.reason = "Safety system not initialized";
         return m_gate;
      }
      
      // Check circuit breaker
      SCircuitStatus circuit = m_circuit_breaker.GetStatus();
      m_gate.circuit_ok = circuit.can_trade;
      
      if(!circuit.can_trade)
      {
         m_gate.can_trade = false;
         m_gate.size_multiplier = 0;
         m_gate.reason = "Circuit breaker: " + circuit.reason;
         return m_gate;
      }
      
      // Check spread
      SSpreadAnalysis spread = m_spread_monitor.GetAnalysis();
      m_gate.spread_ok = spread.can_trade;
      
      if(!spread.can_trade)
      {
         m_gate.can_trade = false;
         m_gate.size_multiplier = 0;
         m_gate.reason = "Spread: " + spread.reason;
         return m_gate;
      }
      
      // All OK - combine adjustments
      m_gate.can_trade = true;
      m_gate.size_multiplier = spread.size_multiplier;
      m_gate.score_adjustment = spread.score_adjustment;
      m_gate.reason = "OK";
      
      return m_gate;
   }
   
   //--- Quick check
   bool CanTrade() { Check(); return m_gate.can_trade; }
   double GetSizeMultiplier() { Check(); return m_gate.size_multiplier; }
   int GetScoreAdjustment() { Check(); return m_gate.score_adjustment; }
   
   //--- Trade result notification
   void OnTradeResult(bool is_win, double profit_loss)
   {
      m_circuit_breaker.OnTradeResult(is_win, profit_loss);
   }
   
   //--- Access to individual components
   CCircuitBreaker*  GetCircuitBreaker() { return GetPointer(m_circuit_breaker); }
   CSpreadMonitor*   GetSpreadMonitor() { return GetPointer(m_spread_monitor); }
   
   //--- Status
   void PrintStatus()
   {
      Print("=== Safety Manager Status ===");
      Print("Can Trade: ", m_gate.can_trade);
      Print("Size Mult: ", m_gate.size_multiplier);
      Print("Score Adj: ", m_gate.score_adjustment);
      Print("Reason: ", m_gate.reason);
      Print("============================");
      m_circuit_breaker.PrintStatus();
      m_spread_monitor.PrintStatus();
   }
};

//+------------------------------------------------------------------+
