//+------------------------------------------------------------------+
//|                                            CUnifiedRiskPolicy.mqh |
//|                     EA_SCALPER_XAUUSD - Apex Compliant Trading     |
//|                     Unified Risk Policy (Task 3.1)                 |
//+------------------------------------------------------------------+
//| UNIFIED RISK DECISION SURFACE                                     |
//| Provides SINGLE evaluation point for all risk gates.              |
//|                                                                   |
//| Gate Evaluation Order (from Python nautilus_gold_scalper):        |
//| 1. TIME GATE    - must_flatten if halted, block_new if 4:30 PM+   |
//| 2. DD GATE      - must_flatten if >= 4.5%, halt if >= 4.0%        |
//| 3. SPREAD GATE  - block_new if spread > max                       |
//| 4. VIRTUAL GATE - block_new if in virtual mode                    |
//| 5. GAP COOLDOWN - block_new during post-gap cooldown              |
//|                                                                   |
//| KEY RULE: Exits are NEVER blocked (EvaluateExit always can_open)  |
//|                                                                   |
//| CRITIC FIX #5: Uses fixed-size arrays, not dynamic                |
//+------------------------------------------------------------------+
#ifndef CUNIFIEDRISKPOLICY_MQH
#define CUNIFIEDRISKPOLICY_MQH

#property copyright "EA_SCALPER_XAUUSD - Apex Compliant Trading System"
#property strict

#include "../Core/Definitions.mqh"
#include "../Core/IRiskGate.mqh"
#include "CApexDDTracker.mqh"
#include "CApexTimeHandler.mqh"
#include "CWallClockEnforcer.mqh"
#include "../Safety/CSpreadMonitor.mqh"
#include "CVirtualGate.mqh"
#include "CGapCooldown.mqh"
#include "../Analysis/CNewsCalendarNative.mqh"  // v4.1: News gate integration

//--- Maximum number of reasons in fixed array (CRITIC FIX #5)
#define MAX_RISK_REASONS 8

//+------------------------------------------------------------------+
//| Size Factor Constants                                             |
//| Defines position sizing adjustments based on risk state           |
//+------------------------------------------------------------------+
#define SIZE_FACTOR_NORMAL       1.0     // Normal operation
#define SIZE_FACTOR_DD_WARN      0.75    // DD at warning level (3.0%)
#define SIZE_FACTOR_DD_CAUTION   0.50    // DD at caution level (3.5%)
#define SIZE_FACTOR_DD_CRITICAL  0.25    // DD at critical level (4.0%)
#define SIZE_FACTOR_DD_HALT      0.0     // DD at halt level (4.5%+)
#define SIZE_FACTOR_SPREAD_HIGH  0.50    // High spread conditions
#define SIZE_FACTOR_TIME_BLOCK   0.0     // After 4:30 PM ET

//+------------------------------------------------------------------+
//| RiskDecision Structure (CRITIC FIX #5: Fixed Arrays)              |
//| Single decision surface for all risk gates                        |
//+------------------------------------------------------------------+
struct RiskDecision
{
    bool              can_open_new;      // Can we open new positions?
    double            size_factor;       // Position sizing factor 0.0 to 1.0
    bool              must_flatten;      // Must close all positions immediately?
    int               reason_flags;      // Bitmask of ENUM_GATE_REASON
    string            reasons[MAX_RISK_REASONS];  // FIXED array (CRITIC FIX #5)
    int               reason_count;      // Number of reasons added

    //--- Reset to default (allow trading)
    void Reset()
    {
        can_open_new = true;
        size_factor = 1.0;
        must_flatten = false;
        reason_flags = GATE_OK;
        reason_count = 0;

        // Clear reasons array
        for(int i = 0; i < MAX_RISK_REASONS; i++)
        {
            reasons[i] = "";
        }
    }

    //--- Add a reason for blocking/restriction
    //--- @param r: Gate reason enum value
    //--- @param text: Human-readable description
    void AddReason(ENUM_GATE_REASON r, string text)
    {
        reason_flags |= r;
        if(reason_count < MAX_RISK_REASONS)
        {
            reasons[reason_count++] = text;
        }
    }

    //--- Get the primary (first) blocking reason
    string GetPrimaryReason()
    {
        return reason_count > 0 ? reasons[0] : "ok";
    }

    //--- Get all reasons as a concatenated string
    string GetAllReasons()
    {
        if(reason_count == 0)
            return "ok";

        string result = "";
        for(int i = 0; i < reason_count; i++)
        {
            if(i > 0) result += " | ";
            result += reasons[i];
        }
        return result;
    }

    //--- Check if a specific reason is set
    bool HasReason(ENUM_GATE_REASON r)
    {
        return ((reason_flags & r) != 0);
    }
};

//+------------------------------------------------------------------+
//| CUnifiedRiskPolicy Class                                          |
//| Single decision surface for all risk evaluations                  |
//+------------------------------------------------------------------+
class CUnifiedRiskPolicy
{
private:
    //--- Component pointers (not owned - caller manages lifecycle)
    CApexDDTracker*     m_dd_tracker;
    CApexTimeHandler*   m_time_handler;
    CWallClockEnforcer* m_wall_clock;
    CSpreadMonitor*     m_spread_monitor;
    CVirtualGate*       m_virtual_gate;     // Forward declared - may be NULL
    CGapCooldown*       m_gap_cooldown;     // Forward declared - may be NULL
    CNewsCalendarNative* m_news_filter;     // v4.1: News gate - may be NULL

    //--- State
    bool                m_initialized;
    RiskDecision        m_last_decision;    // Cache last decision for status
    datetime            m_last_eval_time;
    bool                m_disable_time_gates; // BACKTEST: Skip all time-based checks

    //--- Internal gate evaluation methods (order matters!)
    void                EvaluateTimeGate(RiskDecision &decision);
    void                EvaluateDDGate(RiskDecision &decision);
    void                EvaluateSpreadGate(RiskDecision &decision);
    void                EvaluateVirtualGate(RiskDecision &decision);
    void                EvaluateGapCooldown(RiskDecision &decision);
    void                EvaluateNewsGate(RiskDecision &decision);  // v4.1: News gate

public:
                        CUnifiedRiskPolicy();
                       ~CUnifiedRiskPolicy();

    //--- Initialization
    //--- Call after creating all component instances
    //--- virtual_gate and gap_cooldown can be NULL until implemented
    bool                Init(CApexDDTracker*     dd_tracker,
                            CApexTimeHandler*   time_handler,
                            CWallClockEnforcer* wall_clock,
                            CSpreadMonitor*     spread_monitor,
                            CVirtualGate*       virtual_gate = NULL,
                            CGapCooldown*       gap_cooldown = NULL);

    //--- Core evaluation methods
    //--- @param direction: 1 for long, -1 for short, 0 for any
    RiskDecision        EvaluateEntry(int direction = 0);

    //--- Exit evaluation - KEY RULE: Exits are NEVER blocked
    //--- Always returns can_open=true, size_factor=1.0, must_flatten=false
    RiskDecision        EvaluateExit();

    //--- Status summary for HUD display
    //--- Returns formatted string with current gate states
    string              GetStatusSummary();

    //--- Quick access methods
    bool                CanOpenNew()       { return m_last_decision.can_open_new; }
    bool                MustFlatten()      { return m_last_decision.must_flatten; }
    double              GetSizeFactor()    { return m_last_decision.size_factor; }
    ENUM_GATE_REASON    GetReasonFlags()   { return (ENUM_GATE_REASON)m_last_decision.reason_flags; }
    string              GetPrimaryReason() { return m_last_decision.GetPrimaryReason(); }

    //--- Check if specific gate is blocking
    bool                IsBlockedByTime()  { return m_last_decision.HasReason(GATE_TIME); }
    bool                IsBlockedByDD()    { return m_last_decision.HasReason(GATE_DD_TRAILING) ||
                                                    m_last_decision.HasReason(GATE_DD_DAILY); }
    bool                IsBlockedBySpread(){ return m_last_decision.HasReason(GATE_SPREAD); }
    bool                IsBlockedByVirtual(){ return m_last_decision.HasReason(GATE_VIRTUAL); }

    //--- BACKTEST: Disable time gates
    void                SetDisableTimeGates(bool disable) { m_disable_time_gates = disable; }
    bool                IsBlockedByGap()   { return m_last_decision.HasReason(GATE_GAP_COOLDOWN); }
    bool                IsBlockedByNews()  { return m_last_decision.HasReason(GATE_NEWS); }  // v4.1

    //--- v4.1: News filter setter
    void                SetNewsFilter(CNewsCalendarNative* filter) { m_news_filter = filter; }

    //--- Diagnostic
    void                PrintStatus();
    bool                IsInitialized()    { return m_initialized; }
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CUnifiedRiskPolicy::CUnifiedRiskPolicy()
{
    m_dd_tracker = NULL;
    m_time_handler = NULL;
    m_wall_clock = NULL;
    m_spread_monitor = NULL;
    m_virtual_gate = NULL;
    m_gap_cooldown = NULL;
    m_news_filter = NULL;  // v4.1: News gate

    m_initialized = false;
    m_last_eval_time = 0;
    m_disable_time_gates = false;  // Default: time gates enabled

    m_last_decision.Reset();
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CUnifiedRiskPolicy::~CUnifiedRiskPolicy()
{
    // We don't own any of the component pointers - caller manages lifecycle
    // Just null them out for safety
    m_dd_tracker = NULL;
    m_time_handler = NULL;
    m_wall_clock = NULL;
    m_spread_monitor = NULL;
    m_virtual_gate = NULL;
    m_gap_cooldown = NULL;
    m_news_filter = NULL;  // v4.1: News gate
}

//+------------------------------------------------------------------+
//| Initialize with component pointers                                |
//|                                                                   |
//| Required components:                                              |
//| - dd_tracker: For trailing/daily DD evaluation                    |
//| - time_handler: For ET time state (4:30 PM block, etc.)          |
//| - wall_clock: For emergency flatten enforcement                   |
//| - spread_monitor: For spread-based blocking                       |
//|                                                                   |
//| Optional components (can be NULL until implemented):              |
//| - virtual_gate: For virtual trading mode                         |
//| - gap_cooldown: For post-gap cooldown period                     |
//+------------------------------------------------------------------+
bool CUnifiedRiskPolicy::Init(CApexDDTracker*     dd_tracker,
                              CApexTimeHandler*   time_handler,
                              CWallClockEnforcer* wall_clock,
                              CSpreadMonitor*     spread_monitor,
                              CVirtualGate*       virtual_gate,
                              CGapCooldown*       gap_cooldown)
{
    //--- Validate required components
    if(dd_tracker == NULL)
    {
        Print("CUnifiedRiskPolicy: ERROR - dd_tracker is NULL");
        return false;
    }

    if(time_handler == NULL)
    {
        Print("CUnifiedRiskPolicy: ERROR - time_handler is NULL");
        return false;
    }

    if(wall_clock == NULL)
    {
        Print("CUnifiedRiskPolicy: ERROR - wall_clock is NULL");
        return false;
    }

    if(spread_monitor == NULL)
    {
        Print("CUnifiedRiskPolicy: ERROR - spread_monitor is NULL");
        return false;
    }

    //--- Store component pointers
    m_dd_tracker = dd_tracker;
    m_time_handler = time_handler;
    m_wall_clock = wall_clock;
    m_spread_monitor = spread_monitor;
    m_virtual_gate = virtual_gate;      // May be NULL
    m_gap_cooldown = gap_cooldown;      // May be NULL

    m_initialized = true;

    //--- Log initialization
    Print("CUnifiedRiskPolicy: Initialized");
    Print("  DD Tracker:     ", m_dd_tracker != NULL ? "OK" : "MISSING");
    Print("  Time Handler:   ", m_time_handler != NULL ? "OK" : "MISSING");
    Print("  Wall Clock:     ", m_wall_clock != NULL ? "OK" : "MISSING");
    Print("  Spread Monitor: ", m_spread_monitor != NULL ? "OK" : "MISSING");
    Print("  Virtual Gate:   ", m_virtual_gate != NULL ? "OK" : "Not attached");
    Print("  Gap Cooldown:   ", m_gap_cooldown != NULL ? "OK" : "Not attached");
    Print("  News Filter:    ", m_news_filter != NULL ? "OK" : "Not attached (use SetNewsFilter)");

    return true;
}

//+------------------------------------------------------------------+
//| Evaluate entry permission                                         |
//|                                                                   |
//| Evaluates all gates in order (Python parity):                     |
//| 1. Time Gate    - Check time state (4:30 PM block, halted)       |
//| 2. DD Gate      - Check trailing and daily drawdown               |
//| 3. Spread Gate  - Check current spread                           |
//| 4. Virtual Gate - Check virtual trading mode                     |
//| 5. Gap Cooldown - Check post-gap cooldown                        |
//|                                                                   |
//| @param direction: 1=long, -1=short, 0=any (reserved for future)  |
//| @return: RiskDecision with full gate evaluation results          |
//+------------------------------------------------------------------+
RiskDecision CUnifiedRiskPolicy::EvaluateEntry(int direction)
{
    RiskDecision decision;
    decision.Reset();

    if(!m_initialized)
    {
        decision.can_open_new = false;
        decision.size_factor = 0.0;
        // No specific gate reason - general error state (blocked via can_open_new=false)
        return decision;
    }

    //=================================================================
    // GATE EVALUATION ORDER (matches Python nautilus_gold_scalper)
    //=================================================================

    //--- 1. TIME GATE (highest priority)
    //--- Must evaluate first because time-based flatten overrides all
    EvaluateTimeGate(decision);

    //--- 2. DD GATE
    //--- Check trailing and daily drawdown limits
    EvaluateDDGate(decision);

    //--- 3. SPREAD GATE
    //--- Check if spread is within acceptable limits
    EvaluateSpreadGate(decision);

    //--- 4. VIRTUAL GATE
    //--- Check if in virtual trading mode (forward declared)
    EvaluateVirtualGate(decision);

    //--- 5. GAP COOLDOWN
    //--- Check if in post-gap cooldown period (forward declared)
    EvaluateGapCooldown(decision);

    //--- 6. NEWS GATE (v4.1)
    //--- Check if in high-impact news window
    EvaluateNewsGate(decision);

    //--- Store for status queries
    m_last_decision = decision;
    m_last_eval_time = TimeCurrent();

    return decision;
}

//+------------------------------------------------------------------+
//| Evaluate exit permission                                          |
//|                                                                   |
//| KEY RULE: Exits are NEVER blocked                                |
//| This is critical for risk management - we must ALWAYS be able    |
//| to close positions, regardless of spread, time, or other gates.  |
//|                                                                   |
//| @return: RiskDecision with can_open=true (always)                |
//+------------------------------------------------------------------+
RiskDecision CUnifiedRiskPolicy::EvaluateExit()
{
    RiskDecision decision;
    decision.Reset();

    //=================================================================
    // KEY RULE: Exits are NEVER blocked
    //
    // We must ALWAYS be able to close positions because:
    // 1. Risk reduction takes priority over spread costs
    // 2. Emergency flatten must work regardless of conditions
    // 3. Time-based close (4:59 PM ET) cannot be blocked
    // 4. DD-triggered exits must execute immediately
    //=================================================================

    decision.can_open_new = true;   // "can close" - always true
    decision.size_factor = 1.0;     // Full size exits
    decision.must_flatten = false;  // Exit decision, not flatten trigger

    return decision;
}

//+------------------------------------------------------------------+
//| Evaluate Time Gate (Gate #1)                                      |
//|                                                                   |
//| Time States (from CApexTimeHandler):                             |
//| - TIME_NORMAL:    Normal trading allowed                         |
//| - TIME_BLOCK_NEW: After 4:30 PM ET - block new trades            |
//| - TIME_EMERGENCY: After 4:55 PM ET - prepare for flatten         |
//| - TIME_HALTED:    After 4:59 PM ET - must flatten immediately    |
//|                                                                   |
//| APEX RULE: No overnight positions - close ALL by 4:59 PM ET      |
//+------------------------------------------------------------------+
void CUnifiedRiskPolicy::EvaluateTimeGate(RiskDecision &decision)
{
    // BACKTEST: Skip time gates if disabled
    if(m_disable_time_gates)
        return;

    //--- FAIL-CLOSED: NULL component = BLOCKED (safety-first)
    if(m_time_handler == NULL)
    {
        decision.can_open_new = false;
        decision.must_flatten = true;  // Conservative - assume near market close
        decision.AddReason(GATE_TIME, "Time handler unavailable - BLOCKED");
        return;
    }

    ENUM_TIME_STATE time_state = m_time_handler.GetTimeState();

    switch(time_state)
    {
        case TIME_HALTED:
            //--- After 4:59 PM ET - MUST FLATTEN immediately
            decision.can_open_new = false;
            decision.size_factor = 0.0;
            decision.must_flatten = true;  // Trigger emergency flatten
            decision.AddReason(GATE_TIME, "HALTED: Past 4:59 PM ET - market closed");
            break;

        case TIME_EMERGENCY:
            //--- After 4:55 PM ET - Block new, prepare flatten
            decision.can_open_new = false;
            decision.size_factor = 0.0;
            decision.must_flatten = true;  // Should be closing positions
            decision.AddReason(GATE_TIME,
                StringFormat("EMERGENCY: 4:55 PM ET - %d min to close",
                            m_time_handler.GetMinutesToClose()));
            break;

        case TIME_BLOCK_NEW:
            //--- After 4:30 PM ET - Block new trades only
            decision.can_open_new = false;
            decision.size_factor = SIZE_FACTOR_TIME_BLOCK;
            // must_flatten stays false - only blocking new trades
            decision.AddReason(GATE_TIME,
                StringFormat("BLOCK_NEW: 4:30 PM ET - %d min to close",
                            m_time_handler.GetMinutesToClose()));
            break;

        case TIME_NORMAL:
        default:
            // Normal operation - no restrictions from time gate
            break;
    }
}

//+------------------------------------------------------------------+
//| Evaluate DD Gate (Gate #2)                                        |
//|                                                                   |
//| Trailing DD Thresholds (from CLAUDE.md):                         |
//| - 3.0% = WARN      (size_factor 0.75)                            |
//| - 3.5% = CAUTION   (size_factor 0.50)                            |
//| - 4.0% = CRITICAL  (size_factor 0.25, block new)                 |
//| - 4.5% = HALT      (size_factor 0.0, block new, must flatten)    |
//| - 5.0% = TERMINATED (APEX LIMIT - ACCOUNT BLOWN)                 |
//|                                                                   |
//| Daily DD Thresholds (from CLAUDE.md):                            |
//| - 1.5% = WARN                                                    |
//| - 2.0% = CAUTION                                                 |
//| - 2.5% = REDUCE (50% position size)                              |
//| - 3.0% = HALT                                                    |
//|                                                                   |
//| HARD BLOCKS: Trailing DD >= 4.0% OR Daily DD >= 3.0%             |
//+------------------------------------------------------------------+
void CUnifiedRiskPolicy::EvaluateDDGate(RiskDecision &decision)
{
    //--- FAIL-CLOSED: NULL component = BLOCKED (safety-first)
    if(m_dd_tracker == NULL)
    {
        decision.can_open_new = false;
        decision.size_factor = 0.0;
        decision.AddReason(GATE_DD_TRAILING, "DD tracker unavailable - BLOCKED");
        return;
    }

    //--- Get current DD analysis
    SApexDDAnalysis dd = m_dd_tracker.GetAnalysis();

    //=================================================================
    // TRAILING DD EVALUATION (from HWM - APEX KILLER)
    //=================================================================

    //--- Formula: trailing_dd_pct = (HWM - current_equity) / HWM * 100
    //--- Example: HWM=52000, equity=50000 -> (52000-50000)/52000*100 = 3.85%

    if(dd.trailing_dd_pct >= APEX_DD_HALT)  // 4.5%
    {
        //--- HALT level - must flatten
        decision.can_open_new = false;
        decision.size_factor = MathMin(decision.size_factor, SIZE_FACTOR_DD_HALT);
        decision.must_flatten = true;
        decision.AddReason(GATE_DD_TRAILING,
            StringFormat("DD HALT: Trailing %.2f%% >= %.1f%% - FLATTEN NOW",
                        dd.trailing_dd_pct, APEX_DD_HALT));
    }
    else if(dd.trailing_dd_pct >= APEX_DD_CRITICAL)  // 4.0%
    {
        //--- CRITICAL level - block new trades (safety buffer before Apex)
        decision.can_open_new = false;
        decision.size_factor = MathMin(decision.size_factor, SIZE_FACTOR_DD_CRITICAL);
        decision.AddReason(GATE_DD_TRAILING,
            StringFormat("DD CRITICAL: Trailing %.2f%% >= %.1f%% - trading halted",
                        dd.trailing_dd_pct, APEX_DD_CRITICAL));
    }
    else if(dd.trailing_dd_pct >= APEX_DD_CAUTION)  // 3.5%
    {
        //--- CAUTION level - reduce position size
        decision.size_factor = MathMin(decision.size_factor, SIZE_FACTOR_DD_CAUTION);
        // can_open_new stays true but with reduced size
        decision.AddReason(GATE_DD_TRAILING,
            StringFormat("DD CAUTION: Trailing %.2f%% - reduced size",
                        dd.trailing_dd_pct));
    }
    else if(dd.trailing_dd_pct >= APEX_DD_WARN)  // 3.0%
    {
        //--- WARN level - slight size reduction
        decision.size_factor = MathMin(decision.size_factor, SIZE_FACTOR_DD_WARN);
        decision.AddReason(GATE_DD_TRAILING,
            StringFormat("DD WARN: Trailing %.2f%%", dd.trailing_dd_pct));
    }

    //=================================================================
    // DAILY DD EVALUATION (from session start)
    //=================================================================

    //--- Formula: daily_dd_pct = (session_start - current) / session_start * 100
    //--- Example: session_start=50000, equity=49000 -> 2.0%

    if(dd.daily_dd_pct >= APEX_DAILY_HALT)  // 3.0%
    {
        //--- HALT level - block new trades
        decision.can_open_new = false;
        decision.size_factor = MathMin(decision.size_factor, SIZE_FACTOR_DD_HALT);
        decision.AddReason(GATE_DD_DAILY,
            StringFormat("Daily DD HALT: %.2f%% >= %.1f%% - trading halted",
                        dd.daily_dd_pct, APEX_DAILY_HALT));
    }
    else if(dd.daily_dd_pct >= APEX_DAILY_REDUCE)  // 2.5%
    {
        //--- REDUCE level - 50% position size
        decision.size_factor = MathMin(decision.size_factor, SIZE_FACTOR_DD_CAUTION);
        decision.AddReason(GATE_DD_DAILY,
            StringFormat("Daily DD REDUCE: %.2f%% - 50%% size",
                        dd.daily_dd_pct));
    }
    else if(dd.daily_dd_pct >= APEX_DAILY_CAUTION)  // 2.0%
    {
        //--- CAUTION level
        decision.size_factor = MathMin(decision.size_factor, SIZE_FACTOR_DD_WARN);
        decision.AddReason(GATE_DD_DAILY,
            StringFormat("Daily DD CAUTION: %.2f%%", dd.daily_dd_pct));
    }
}

//+------------------------------------------------------------------+
//| Evaluate Spread Gate (Gate #3)                                    |
//|                                                                   |
//| Uses CSpreadMonitor analysis:                                     |
//| - SPREAD_BLOCKED: Block new trades (absolute max exceeded)       |
//| - SPREAD_EXTREME: Block new trades (ratio too high)              |
//| - SPREAD_HIGH:    Reduce position size to 25%                    |
//| - SPREAD_ELEVATED: Reduce position size to 50%                   |
//| - SPREAD_NORMAL:  Normal operation                               |
//+------------------------------------------------------------------+
void CUnifiedRiskPolicy::EvaluateSpreadGate(RiskDecision &decision)
{
    // v4.1: Skip spread gate if time gates are disabled (backtest mode)
    if(m_disable_time_gates)
        return;

    //--- FAIL-CLOSED: NULL component = BLOCKED (safety-first)
    if(m_spread_monitor == NULL)
    {
        decision.can_open_new = false;
        decision.AddReason(GATE_SPREAD, "Spread monitor unavailable - BLOCKED");
        return;
    }

    //--- Check if spread is blocking
    if(m_spread_monitor.IsBlocked())
    {
        decision.can_open_new = false;
        decision.size_factor = MathMin(decision.size_factor, 0.0);
        decision.AddReason(GATE_SPREAD, m_spread_monitor.GetReasonText());
    }
    else
    {
        //--- Apply size multiplier from spread analysis
        double spread_mult = m_spread_monitor.GetSizeMultiplier();
        if(spread_mult < 1.0)
        {
            decision.size_factor = MathMin(decision.size_factor, spread_mult);

            //--- Only add reason if spread is affecting sizing
            SSpreadAnalysis spread = m_spread_monitor.GetAnalysis();
            if(spread.status != SPREAD_NORMAL)
            {
                decision.AddReason(GATE_SPREAD,
                    StringFormat("Spread %s: %.1f pips (size %.0f%%)",
                                m_spread_monitor.GetStatusString(),
                                spread.current_spread_pips,
                                spread_mult * 100.0));
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Evaluate Virtual Gate (Gate #4)                                   |
//|                                                                   |
//| Virtual Gate checks for volatility spikes and turbulence using   |
//| bar range analysis (median-based spike detection).               |
//|                                                                   |
//| Block conditions (from CVirtualGate):                            |
//| - RANGE_SPIKE: Single bar range > spike_multiplier * median      |
//| - TURBULENCE_CLUSTER: Too many spikes in lookback window         |
//| - TEMPORAL_VIOLATION: Anti-lookahead check failed                |
//| - INTRABAR_ACCESS: Attempted to use bar[0] (forming bar)         |
//+------------------------------------------------------------------+
void CUnifiedRiskPolicy::EvaluateVirtualGate(RiskDecision &decision)
{
    // v4.1: Skip virtual gate if time gates are disabled (backtest mode)
    if(m_disable_time_gates)
        return;

    if(m_virtual_gate == NULL)
        return;  // Not attached

    //--- Check if virtual gate is blocking
    if(m_virtual_gate.IsBlocked())
    {
        decision.can_open_new = false;
        decision.size_factor = MathMin(decision.size_factor, 0.0);
        decision.AddReason(GATE_VIRTUAL, m_virtual_gate.GetReasonText());
    }
    else
    {
        //--- Apply gate score to size factor if not fully OK
        SVirtualGateResult vg_result = m_virtual_gate.GetLastResult();
        if(vg_result.gate_ok && vg_result.gate_score < 1.0)
        {
            //--- Reduce size based on volatility score
            decision.size_factor = MathMin(decision.size_factor, vg_result.gate_score);

            if(vg_result.gate_score < 0.75)
            {
                decision.AddReason(GATE_VIRTUAL,
                    StringFormat("Volatility elevated (score %.2f)", vg_result.gate_score));
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Evaluate Gap Cooldown (Gate #5)                                   |
//|                                                                   |
//| Post-gap cooldown period blocks new trades after a significant   |
//| price gap is detected, allowing market to stabilize.             |
//|                                                                   |
//| Gap types detected (from CGapCooldown):                          |
//| - WEEKEND: Friday 5PM -> Sunday 6PM EST (>40 hours)              |
//| - SESSION: >2 hours gap between sessions                         |
//| - FEED/NEWS: Unexpected data gap or news-related gap             |
//+------------------------------------------------------------------+
void CUnifiedRiskPolicy::EvaluateGapCooldown(RiskDecision &decision)
{
    // v4.1: Skip gap cooldown if time gates are disabled (backtest mode)
    if(m_disable_time_gates)
        return;

    if(m_gap_cooldown == NULL)
        return;  // Not attached

    //--- Check if in cooldown period
    if(m_gap_cooldown.IsBlocked())
    {
        decision.can_open_new = false;
        decision.size_factor = MathMin(decision.size_factor, 0.0);
        decision.AddReason(GATE_GAP_COOLDOWN, m_gap_cooldown.GetReasonText());
    }
}

//+------------------------------------------------------------------+
//| Evaluate News Gate (Gate #6) - v4.1                               |
//|                                                                   |
//| News-based blocking during high-impact economic releases.         |
//| Uses CNewsCalendarNative for real-time MQL5 calendar data.       |
//|                                                                   |
//| Block conditions:                                                 |
//| - NEWS_ACTION_BLOCK: Too close to news, no trading allowed       |
//| - Reduce size_factor based on news proximity                     |
//+------------------------------------------------------------------+
void CUnifiedRiskPolicy::EvaluateNewsGate(RiskDecision &decision)
{
    // v4.1: Skip news gate if time gates are disabled (backtest mode)
    if(m_disable_time_gates)
        return;

    if(m_news_filter == NULL)
        return;  // Not attached

    //--- Check news window
    SNewsWindowNative news = m_news_filter.CheckNewsWindow();

    //--- Block if in blocking window (critical/high impact events)
    if(news.action == NEWS_ACTION_BLOCK)
    {
        decision.can_open_new = false;
        decision.size_factor = MathMin(decision.size_factor, 0.0);
        decision.AddReason(GATE_NEWS, news.reason);
    }
    //--- Apply size reduction for caution/pre-position windows
    else if(news.size_multiplier < 1.0)
    {
        decision.size_factor = MathMin(decision.size_factor, news.size_multiplier);

        // Only add reason if news is affecting trading significantly
        if(news.size_multiplier <= 0.5 || news.in_window)
        {
            decision.AddReason(GATE_NEWS, news.reason);
        }
    }
}

//+------------------------------------------------------------------+
//| Get status summary for HUD display                                |
//|                                                                   |
//| Returns formatted string with current gate states:               |
//| TIME: NORMAL | DD: 2.5% (CAUTION) | SPREAD: OK | SIZE: 75%       |
//+------------------------------------------------------------------+
string CUnifiedRiskPolicy::GetStatusSummary()
{
    if(!m_initialized)
        return "NOT INITIALIZED";

    //--- Refresh decision
    EvaluateEntry(0);

    //--- Build status parts
    string time_status = "TIME: ";
    string dd_status = "DD: ";
    string spread_status = "SPREAD: ";
    string size_status = "SIZE: ";
    string action_status = "";

    //--- Time status
    if(m_time_handler != NULL)
    {
        ENUM_TIME_STATE ts = m_time_handler.GetTimeState();
        switch(ts)
        {
            case TIME_HALTED:    time_status += "HALTED";    break;
            case TIME_EMERGENCY: time_status += "EMERGENCY"; break;
            case TIME_BLOCK_NEW: time_status += "BLOCK";     break;
            default:             time_status += "NORMAL";    break;
        }
    }
    else
    {
        time_status += "N/A";
    }

    //--- DD status
    if(m_dd_tracker != NULL)
    {
        SApexDDAnalysis dd = m_dd_tracker.GetAnalysis();
        dd_status += StringFormat("%.1f%% (%s)",
                                 dd.trailing_dd_pct,
                                 EnumToString(dd.trailing_severity));
    }
    else
    {
        dd_status += "N/A";
    }

    //--- Spread status
    if(m_spread_monitor != NULL)
    {
        spread_status += m_spread_monitor.GetStatusString();
    }
    else
    {
        spread_status += "N/A";
    }

    //--- Size factor
    size_status += StringFormat("%.0f%%", m_last_decision.size_factor * 100.0);

    //--- Action status
    if(m_last_decision.must_flatten)
    {
        action_status = " | ACTION: FLATTEN";
    }
    else if(!m_last_decision.can_open_new)
    {
        action_status = " | ACTION: BLOCKED";
    }

    return time_status + " | " + dd_status + " | " + spread_status + " | " + size_status + action_status;
}

//+------------------------------------------------------------------+
//| Print detailed status to log                                      |
//+------------------------------------------------------------------+
void CUnifiedRiskPolicy::PrintStatus()
{
    Print("=== Unified Risk Policy Status ===");
    Print("Initialized: ", m_initialized ? "YES" : "NO");

    if(!m_initialized)
    {
        Print("================================");
        return;
    }

    //--- Evaluate current state
    RiskDecision decision = EvaluateEntry(0);

    Print("--- Decision ---");
    Print("  Can Open New:  ", decision.can_open_new ? "YES" : "NO");
    Print("  Size Factor:   ", DoubleToString(decision.size_factor, 2));
    Print("  Must Flatten:  ", decision.must_flatten ? "YES" : "NO");
    Print("  Reason Flags:  ", GateReasonToString((ENUM_GATE_REASON)decision.reason_flags));
    Print("  Reason Count:  ", decision.reason_count);

    if(decision.reason_count > 0)
    {
        Print("  Reasons:");
        for(int i = 0; i < decision.reason_count; i++)
        {
            Print("    ", i + 1, ": ", decision.reasons[i]);
        }
    }

    Print("--- Component Status ---");

    if(m_time_handler != NULL)
    {
        Print("  Time State: ", m_time_handler.GetTimeStateString());
        Print("  Minutes to Close: ", m_time_handler.GetMinutesToClose());
    }

    if(m_dd_tracker != NULL)
    {
        SApexDDAnalysis dd = m_dd_tracker.GetAnalysis();
        Print("  Trailing DD: ", DoubleToString(dd.trailing_dd_pct, 2), "%");
        Print("  Daily DD: ", DoubleToString(dd.daily_dd_pct, 2), "%");
        Print("  Buffer: ", DoubleToString(m_dd_tracker.GetRemainingBuffer(), 2), "%");
    }

    if(m_spread_monitor != NULL)
    {
        Print("  Spread: ", m_spread_monitor.GetStatusString());
        Print("  Spread Blocked: ", m_spread_monitor.IsBlocked() ? "YES" : "NO");
    }

    Print("  Virtual Gate: ", m_virtual_gate != NULL ?
          (m_virtual_gate.IsBlocked() ? "BLOCKED" : "OK") : "Not attached");
    Print("  Gap Cooldown: ", m_gap_cooldown != NULL ?
          (m_gap_cooldown.IsBlocked() ? "COOLING" : "OK") : "Not attached");
    Print("  News Filter:  ", m_news_filter != NULL ?
          (m_news_filter.ShouldBlockTrading() ? "BLOCKED" : "OK") : "Not attached");

    Print("--- Summary ---");
    Print("  ", GetStatusSummary());
    Print("================================");
}

#endif // CUNIFIEDRISKPOLICY_MQH
//+------------------------------------------------------------------+
