//+------------------------------------------------------------------+
//|                                                  CVirtualGate.mqh |
//|                     EA_SCALPER_XAUUSD - Virtual Gate               |
//|                     Temporal Validation & Volatility Check         |
//|                     Migrated from Python nautilus_gold_scalper     |
//+------------------------------------------------------------------+
#ifndef CVIRTUALGATE_MQH
#define CVIRTUALGATE_MQH

#property copyright "EA_SCALPER_XAUUSD - Apex Compliant Trading System"
#property strict

#include "../Core/Definitions.mqh"
#include "../Core/IRiskGate.mqh"

//+------------------------------------------------------------------+
//| CVirtualGate                                                       |
//|                                                                    |
//| Entry-only virtual gate (bar-only, deterministic, anti-lookahead). |
//| This gate is intentionally simple and timestamp-validated:         |
//| - Consumes COMPLETED bars only (bar_index >= 1 MANDATORY)          |
//| - Rejects any input bar with ts >= decision_ts (lookahead ban)     |
//| - Detects single-bar range spikes and multi-bar turbulence.        |
//|                                                                    |
//| CRITIC FIX: ENFORCE bar[1] ONLY - bar[0] ACCESS IS BANNED!         |
//| bar_index=0 represents the FORMING bar (incomplete data).          |
//| Using bar[0] is a TEMPORAL VIOLATION (anti-lookahead principle).   |
//|                                                                    |
//| Notes:                                                             |
//| - This is a *tradability* filter (microstructure/volatility).      |
//| - NOT a directional signal - pure risk gate.                       |
//| - All calculations are O(N) over lookback.                         |
//+------------------------------------------------------------------+

//--- Virtual Gate specific reasons
//--- More granular than ENUM_GATE_REASON for diagnostics
enum ENUM_VGATE_REASON
{
    VGATE_OK = 0,                    // Gate passed - trading allowed
    VGATE_TEMPORAL_VIOLATION = 1,    // Bar timestamp >= decision timestamp (lookahead)
    VGATE_RANGE_SPIKE = 2,           // Single-bar volatility spike detected
    VGATE_TURBULENCE_CLUSTER = 3,    // Multiple spikes in lookback window
    VGATE_INTRABAR_ACCESS = 4,       // CRITICAL: Tried to use bar[0] (forming bar)
    VGATE_INSUFFICIENT_HISTORY = 5,  // Not enough bars for reliable calculation
    VGATE_INVALID_INPUT = 6,         // Invalid input data (negative range, etc.)
    VGATE_NON_MONOTONIC_TS = 7,      // Timestamps not strictly increasing
    VGATE_ZERO_MEDIAN_RANGE = 8      // Median range is zero (can't calculate ratios)
};

//--- Default configuration values
#define VGATE_DEFAULT_LOOKBACK             20    // Bars for median calculation
#define VGATE_DEFAULT_SPIKE_MULTIPLIER     3.0   // Single-bar spike threshold
#define VGATE_DEFAULT_CLUSTER_MULTIPLIER   2.5   // Cluster spike threshold
#define VGATE_DEFAULT_CLUSTER_MAX_FRACTION 0.30  // Max 30% of bars can be spikes

//+------------------------------------------------------------------+
//| Virtual Gate Result Structure                                      |
//+------------------------------------------------------------------+
struct SVirtualGateResult
{
    bool              gate_ok;             // True = trading allowed
    ENUM_VGATE_REASON reason;              // Specific reason for block/pass
    double            gate_score;          // 0.0 = bad, 1.0 = excellent
    double            last_range_ratio;    // Range ratio of last bar vs median
    int               spike_count;         // Number of spikes in lookback
    double            spike_fraction;      // Fraction of lookback that are spikes
    double            median_range;        // Calculated median range

    void Reset()
    {
        gate_ok = false;
        reason = VGATE_INSUFFICIENT_HISTORY;
        gate_score = 0.0;
        last_range_ratio = 0.0;
        spike_count = 0;
        spike_fraction = 0.0;
        median_range = 0.0;
    }
};

//+------------------------------------------------------------------+
//| CVirtualGate Class                                                 |
//+------------------------------------------------------------------+
class CVirtualGate : public IRiskGate
{
private:
    //--- Configuration
    int               m_lookback_bars;           // Number of bars for median calc
    double            m_range_spike_multiplier;  // Single-bar spike threshold (default 3.0)
    double            m_cluster_spike_multiplier;// Cluster spike threshold (default 2.5)
    double            m_cluster_max_fraction;    // Max fraction of spikes allowed (0.30)
    bool              m_fail_open_on_insufficient; // If true, allow trade on insufficient data

    //--- State
    double            m_cached_median_range;     // Cached median range
    ENUM_VGATE_REASON m_last_reason;             // Last evaluation reason
    SVirtualGateResult m_last_result;            // Last evaluation result
    bool              m_initialized;

    //--- Internal methods
    double            CalculateMedian(const double& ranges[]);
    double            ClampScore(double value);

public:
                      CVirtualGate();
                     ~CVirtualGate();

    //--- Initialization
    bool              Init(int lookback_bars = VGATE_DEFAULT_LOOKBACK,
                          double range_spike_mult = VGATE_DEFAULT_SPIKE_MULTIPLIER,
                          double cluster_spike_mult = VGATE_DEFAULT_CLUSTER_MULTIPLIER,
                          double cluster_max_frac = VGATE_DEFAULT_CLUSTER_MAX_FRACTION,
                          bool fail_open = false);

    //--- Core evaluation
    //--- CRITIC FIX: bar_index MUST be >= 1 (completed bars only!)
    //--- bar_index=0 is the FORMING bar and will be REJECTED!
    bool              Evaluate(int bar_index,
                              datetime bar_ts,
                              datetime decision_ts,
                              double bar_range);

    //--- Full evaluation with arrays (matches Python interface)
    //--- bar_ts_array[]: timestamps of bars (must be BEFORE decision_ts)
    //--- bar_ranges[]: high - low for each bar
    SVirtualGateResult EvaluateFull(datetime decision_ts,
                                    const datetime& bar_ts_array[],
                                    const double& bar_ranges[]);

    //--- Update median range from external data
    //--- ranges[] should be from COMPLETED bars only (bar[1] onwards)
    void              UpdateMedianRange(const double& ranges[]);

    //--- Getters
    ENUM_VGATE_REASON GetLastVGateReason()  { return m_last_reason; }
    SVirtualGateResult GetLastResult()      { return m_last_result; }
    double            GetMedianRange()      { return m_cached_median_range; }
    bool              IsOK()                { return m_last_reason == VGATE_OK; }

    //--- Convert reason to text
    string            VGateReasonToString(ENUM_VGATE_REASON reason);

    //--- IRiskGate interface implementation
    virtual bool              IsBlocked(void)     { return m_last_reason != VGATE_OK; }
    virtual ENUM_GATE_REASON  GetReason(void)     { return m_last_reason != VGATE_OK ? GATE_VIRTUAL : GATE_OK; }
    virtual string            GetReasonText(void);
    virtual void              OnTick(void)        { /* No tick-level update needed */ }
    virtual void              Reset(void);
    virtual string            GetGateName(void)   { return "VirtualGate"; }

    //--- Debug
    void              PrintStatus();
};

//+------------------------------------------------------------------+
//| Constructor                                                        |
//+------------------------------------------------------------------+
CVirtualGate::CVirtualGate()
{
    m_lookback_bars = VGATE_DEFAULT_LOOKBACK;
    m_range_spike_multiplier = VGATE_DEFAULT_SPIKE_MULTIPLIER;
    m_cluster_spike_multiplier = VGATE_DEFAULT_CLUSTER_MULTIPLIER;
    m_cluster_max_fraction = VGATE_DEFAULT_CLUSTER_MAX_FRACTION;
    m_fail_open_on_insufficient = false;

    m_cached_median_range = 0.0;
    m_last_reason = VGATE_INSUFFICIENT_HISTORY;
    m_last_result.Reset();
    m_initialized = false;
}

//+------------------------------------------------------------------+
//| Destructor                                                         |
//+------------------------------------------------------------------+
CVirtualGate::~CVirtualGate()
{
}

//+------------------------------------------------------------------+
//| Initialize with configuration                                      |
//+------------------------------------------------------------------+
bool CVirtualGate::Init(int lookback_bars = VGATE_DEFAULT_LOOKBACK,
                        double range_spike_mult = VGATE_DEFAULT_SPIKE_MULTIPLIER,
                        double cluster_spike_mult = VGATE_DEFAULT_CLUSTER_MULTIPLIER,
                        double cluster_max_frac = VGATE_DEFAULT_CLUSTER_MAX_FRACTION,
                        bool fail_open = false)
{
    //--- Validate parameters
    if(lookback_bars <= 1)
    {
        Print("CVirtualGate::Init ERROR - lookback_bars must be > 1, got: ", lookback_bars);
        return false;
    }

    if(range_spike_mult <= 1.0)
    {
        Print("CVirtualGate::Init ERROR - range_spike_multiplier must be > 1.0, got: ",
              DoubleToString(range_spike_mult, 2));
        return false;
    }

    if(cluster_spike_mult <= 1.0)
    {
        Print("CVirtualGate::Init ERROR - cluster_spike_multiplier must be > 1.0, got: ",
              DoubleToString(cluster_spike_mult, 2));
        return false;
    }

    if(cluster_max_frac < 0.0 || cluster_max_frac > 1.0)
    {
        Print("CVirtualGate::Init ERROR - cluster_max_fraction must be in [0, 1], got: ",
              DoubleToString(cluster_max_frac, 2));
        return false;
    }

    //--- Store configuration
    m_lookback_bars = lookback_bars;
    m_range_spike_multiplier = range_spike_mult;
    m_cluster_spike_multiplier = cluster_spike_mult;
    m_cluster_max_fraction = cluster_max_frac;
    m_fail_open_on_insufficient = fail_open;

    //--- Reset state
    m_cached_median_range = 0.0;
    m_last_reason = VGATE_INSUFFICIENT_HISTORY;
    m_last_result.Reset();
    m_initialized = true;

    Print("CVirtualGate: Initialized");
    Print("  Lookback bars: ", m_lookback_bars);
    Print("  Spike multiplier: ", DoubleToString(m_range_spike_multiplier, 2));
    Print("  Cluster multiplier: ", DoubleToString(m_cluster_spike_multiplier, 2));
    Print("  Cluster max fraction: ", DoubleToString(m_cluster_max_fraction, 2));
    Print("  Fail open: ", m_fail_open_on_insufficient);

    return true;
}

//+------------------------------------------------------------------+
//| Simple single-bar evaluation                                       |
//|                                                                    |
//| CRITIC FIX: bar_index MUST be >= 1!                                |
//| bar_index=0 is the FORMING bar (incomplete) and is BANNED!         |
//|                                                                    |
//| Parameters:                                                        |
//|   bar_index   - Index of bar (MUST be >= 1 for completed bars)    |
//|   bar_ts      - Timestamp of the bar being evaluated               |
//|   decision_ts - Current decision timestamp                         |
//|   bar_range   - High - Low of the bar                              |
//|                                                                    |
//| Returns: true if trading allowed, false if blocked                 |
//+------------------------------------------------------------------+
bool CVirtualGate::Evaluate(int bar_index,
                           datetime bar_ts,
                           datetime decision_ts,
                           double bar_range)
{
    //=========================================================
    // CRITIC FIX: INTRABAR ACCESS BANNED!
    // bar_index=0 is the FORMING bar - its data is INCOMPLETE!
    // Using bar[0] violates anti-lookahead principle because:
    // 1. High/Low of bar[0] can change until bar closes
    // 2. Decisions based on incomplete bar data are temporal violations
    // 3. Only COMPLETED bars (bar_index >= 1) have final OHLC
    //=========================================================
    if(bar_index < 1)
    {
        m_last_reason = VGATE_INTRABAR_ACCESS;
        m_last_result.gate_ok = false;
        m_last_result.reason = VGATE_INTRABAR_ACCESS;
        m_last_result.gate_score = 0.0;
        Print("CVirtualGate: BLOCKED - Intrabar access attempted (bar_index=",
              bar_index, "). Only bar[1]+ allowed!");
        return false;
    }

    //--- Temporal check: bar must be from BEFORE decision time
    //--- If bar_ts >= decision_ts, we'd be using future data (lookahead)
    //--- Formula check: bar_ts < decision_ts (strict less than)
    if(bar_ts >= decision_ts)
    {
        m_last_reason = VGATE_TEMPORAL_VIOLATION;
        m_last_result.gate_ok = false;
        m_last_result.reason = VGATE_TEMPORAL_VIOLATION;
        m_last_result.gate_score = 0.0;
        Print("CVirtualGate: BLOCKED - Temporal violation! bar_ts=",
              TimeToString(bar_ts), " >= decision_ts=", TimeToString(decision_ts));
        return false;
    }

    //--- Validate range
    if(bar_range < 0.0)
    {
        m_last_reason = VGATE_INVALID_INPUT;
        m_last_result.gate_ok = false;
        m_last_result.reason = VGATE_INVALID_INPUT;
        m_last_result.gate_score = 0.0;
        return false;
    }

    //--- Check if we have cached median for comparison
    if(m_cached_median_range <= 0.0)
    {
        //--- No median yet - can't do spike detection
        if(m_fail_open_on_insufficient)
        {
            m_last_reason = VGATE_OK;
            m_last_result.gate_ok = true;
            m_last_result.reason = VGATE_OK;
            m_last_result.gate_score = 1.0;
            return true;
        }

        m_last_reason = VGATE_INSUFFICIENT_HISTORY;
        m_last_result.gate_ok = false;
        m_last_result.reason = VGATE_INSUFFICIENT_HISTORY;
        m_last_result.gate_score = 0.0;
        return false;
    }

    //--- Range spike check
    //--- Formula: ratio = bar_range / median_range
    //--- Block if ratio > spike_multiplier
    //--- Example: median=50 pips, bar_range=180 pips, multiplier=3.0
    //---          ratio = 180/50 = 3.6 > 3.0 => BLOCKED
    double ratio = bar_range / m_cached_median_range;
    m_last_result.last_range_ratio = ratio;

    if(ratio > m_range_spike_multiplier)
    {
        m_last_reason = VGATE_RANGE_SPIKE;
        m_last_result.gate_ok = false;
        m_last_result.reason = VGATE_RANGE_SPIKE;
        m_last_result.gate_score = 0.0;
        Print("CVirtualGate: BLOCKED - Range spike detected! ratio=",
              DoubleToString(ratio, 2), " > threshold=",
              DoubleToString(m_range_spike_multiplier, 2));
        return false;
    }

    //--- Passed all checks
    //--- Calculate score: 1.0 for ratio <= 1.0, decreasing to 0.0 at threshold
    double score;
    if(ratio <= 1.0)
    {
        score = 1.0;
    }
    else
    {
        // Linear decay from 1.0 to 0.0 as ratio goes from 1.0 to threshold
        // Formula: score = 1 - ((ratio - 1) / (threshold - 1))
        score = ClampScore(1.0 - ((ratio - 1.0) / (m_range_spike_multiplier - 1.0)));
    }

    m_last_reason = VGATE_OK;
    m_last_result.gate_ok = true;
    m_last_result.reason = VGATE_OK;
    m_last_result.gate_score = score;
    m_last_result.median_range = m_cached_median_range;

    return true;
}

//+------------------------------------------------------------------+
//| Full evaluation with arrays (matches Python VirtualGate.evaluate)  |
//|                                                                    |
//| This performs complete validation including:                       |
//| 1. Bar[0] access protection (intrabar ban)                        |
//| 2. Temporal validation (all bars must be < decision_ts)           |
//| 3. Monotonic timestamp check                                      |
//| 4. Median range calculation                                       |
//| 5. Single-bar spike detection                                     |
//| 6. Multi-bar turbulence cluster detection                         |
//|                                                                    |
//| Parameters:                                                        |
//|   decision_ts   - Current decision timestamp                       |
//|   bar_ts_array  - Timestamps of bars (oldest to newest)            |
//|   bar_ranges    - High - Low for each bar                          |
//|                                                                    |
//| IMPORTANT: Arrays should contain COMPLETED bars only (bar[1]+)     |
//| DO NOT pass bar[0] data to this function!                          |
//+------------------------------------------------------------------+
SVirtualGateResult CVirtualGate::EvaluateFull(datetime decision_ts,
                                              const datetime& bar_ts_array[],
                                              const double& bar_ranges[])
{
    SVirtualGateResult result;
    result.Reset();

    //--- Validate inputs
    int array_size = ArraySize(bar_ts_array);
    if(array_size == 0 || ArraySize(bar_ranges) == 0)
    {
        result.reason = VGATE_INVALID_INPUT;
        m_last_reason = VGATE_INVALID_INPUT;
        m_last_result = result;
        return result;
    }

    if(array_size != ArraySize(bar_ranges))
    {
        result.reason = VGATE_INVALID_INPUT;
        Print("CVirtualGate::EvaluateFull ERROR - Array size mismatch: ts=",
              array_size, " ranges=", ArraySize(bar_ranges));
        m_last_reason = VGATE_INVALID_INPUT;
        m_last_result = result;
        return result;
    }

    //--- Check we have enough history
    if(array_size < m_lookback_bars)
    {
        if(m_fail_open_on_insufficient)
        {
            result.gate_ok = true;
            result.reason = VGATE_OK;
            result.gate_score = 1.0;
            m_last_reason = VGATE_OK;
            m_last_result = result;
            return result;
        }

        result.reason = VGATE_INSUFFICIENT_HISTORY;
        m_last_reason = VGATE_INSUFFICIENT_HISTORY;
        m_last_result = result;
        return result;
    }

    //--- Work with last N bars
    int start_idx = array_size - m_lookback_bars;
    int end_idx = array_size;

    //--- Anti-lookahead: ALL input bars must be completed before decision timestamp
    //--- This is the CRITICAL temporal validation check
    for(int i = start_idx; i < end_idx; i++)
    {
        if(bar_ts_array[i] >= decision_ts)
        {
            result.reason = VGATE_TEMPORAL_VIOLATION;
            Print("CVirtualGate: TEMPORAL VIOLATION at index ", i,
                  " bar_ts=", TimeToString(bar_ts_array[i]),
                  " >= decision_ts=", TimeToString(decision_ts));
            m_last_reason = VGATE_TEMPORAL_VIOLATION;
            m_last_result = result;
            return result;
        }
    }

    //--- Feed sanity: ensure strictly increasing timestamps
    for(int i = start_idx + 1; i < end_idx; i++)
    {
        if(bar_ts_array[i] <= bar_ts_array[i-1])
        {
            result.reason = VGATE_NON_MONOTONIC_TS;
            Print("CVirtualGate: Non-monotonic timestamps at index ", i);
            m_last_reason = VGATE_NON_MONOTONIC_TS;
            m_last_result = result;
            return result;
        }
    }

    //--- Validate ranges and collect for median calculation
    double ranges[];
    ArrayResize(ranges, m_lookback_bars);

    for(int i = 0; i < m_lookback_bars; i++)
    {
        int src_idx = start_idx + i;
        double range_val = bar_ranges[src_idx];

        if(range_val < 0.0)
        {
            result.reason = VGATE_INVALID_INPUT;
            Print("CVirtualGate: Invalid range at index ", src_idx, ": ", range_val);
            m_last_reason = VGATE_INVALID_INPUT;
            m_last_result = result;
            return result;
        }

        ranges[i] = range_val;
    }

    //--- Calculate median range
    double median_range = CalculateMedian(ranges);

    if(median_range <= 0.0)
    {
        result.reason = VGATE_ZERO_MEDIAN_RANGE;
        m_last_reason = VGATE_ZERO_MEDIAN_RANGE;
        m_last_result = result;
        return result;
    }

    result.median_range = median_range;
    m_cached_median_range = median_range;

    //--- Get last bar range (most recent completed bar)
    double last_range = ranges[m_lookback_bars - 1];
    double ratio = last_range / median_range;
    result.last_range_ratio = ratio;

    //--- Single-bar volatility spike check
    if(ratio > m_range_spike_multiplier)
    {
        result.reason = VGATE_RANGE_SPIKE;
        result.gate_score = 0.0;
        Print("CVirtualGate: RANGE SPIKE detected! ratio=",
              DoubleToString(ratio, 2), " > ", DoubleToString(m_range_spike_multiplier, 2));
        m_last_reason = VGATE_RANGE_SPIKE;
        m_last_result = result;
        return result;
    }

    //--- Multi-bar turbulence cluster check
    //--- Count how many bars exceed cluster_spike_multiplier * median
    int spike_count = 0;
    for(int i = 0; i < m_lookback_bars; i++)
    {
        double r = ranges[i] / median_range;
        if(r > m_cluster_spike_multiplier)
        {
            spike_count++;
        }
    }

    result.spike_count = spike_count;
    double spike_fraction = (double)spike_count / (double)m_lookback_bars;
    result.spike_fraction = spike_fraction;

    //--- Block if too many spikes in lookback window
    if(m_cluster_max_fraction <= 0.0)
    {
        //--- Zero tolerance mode: any spike blocks
        if(spike_count > 0)
        {
            result.reason = VGATE_TURBULENCE_CLUSTER;
            result.gate_score = 0.0;
            Print("CVirtualGate: TURBULENCE CLUSTER (zero tolerance)! spikes=", spike_count);
            m_last_reason = VGATE_TURBULENCE_CLUSTER;
            m_last_result = result;
            return result;
        }
    }
    else if(spike_fraction > m_cluster_max_fraction)
    {
        result.reason = VGATE_TURBULENCE_CLUSTER;
        result.gate_score = ClampScore(1.0 - (spike_fraction / m_cluster_max_fraction));
        Print("CVirtualGate: TURBULENCE CLUSTER! spike_fraction=",
              DoubleToString(spike_fraction * 100.0, 1), "% > max=",
              DoubleToString(m_cluster_max_fraction * 100.0, 1), "%");
        m_last_reason = VGATE_TURBULENCE_CLUSTER;
        m_last_result = result;
        return result;
    }

    //--- PASSED all checks
    //--- Calculate combined score
    double score_spike;
    if(ratio <= 1.0)
    {
        score_spike = 1.0;
    }
    else
    {
        score_spike = ClampScore(1.0 - ((ratio - 1.0) / (m_range_spike_multiplier - 1.0)));
    }

    double score_cluster;
    if(m_cluster_max_fraction <= 0.0)
    {
        score_cluster = 1.0;  // Already passed zero-tolerance check
    }
    else
    {
        score_cluster = ClampScore(1.0 - (spike_fraction / m_cluster_max_fraction));
    }

    result.gate_ok = true;
    result.reason = VGATE_OK;
    result.gate_score = MathMin(score_spike, score_cluster);

    m_last_reason = VGATE_OK;
    m_last_result = result;

    return result;
}

//+------------------------------------------------------------------+
//| Update median range from external bar data                         |
//|                                                                    |
//| ranges[] should contain COMPLETED bar ranges only (bar[1]+)        |
//| This allows pre-computing median without full evaluation           |
//+------------------------------------------------------------------+
void CVirtualGate::UpdateMedianRange(const double& ranges[])
{
    int size = ArraySize(ranges);
    if(size == 0)
    {
        Print("CVirtualGate::UpdateMedianRange WARNING - Empty array");
        return;
    }

    //--- Validate all ranges are non-negative
    for(int i = 0; i < size; i++)
    {
        if(ranges[i] < 0.0)
        {
            Print("CVirtualGate::UpdateMedianRange ERROR - Negative range at index ", i);
            return;
        }
    }

    m_cached_median_range = CalculateMedian(ranges);

    if(m_cached_median_range <= 0.0)
    {
        Print("CVirtualGate::UpdateMedianRange WARNING - Median is zero or negative");
    }
}

//+------------------------------------------------------------------+
//| Calculate median from array                                        |
//+------------------------------------------------------------------+
double CVirtualGate::CalculateMedian(const double& ranges[])
{
    int size = ArraySize(ranges);
    if(size == 0) return 0.0;

    //--- Copy and sort
    double sorted[];
    ArrayResize(sorted, size);
    ArrayCopy(sorted, ranges);
    ArraySort(sorted);

    //--- Calculate median
    if(size % 2 == 1)
    {
        //--- Odd count: middle element
        return sorted[size / 2];
    }
    else
    {
        //--- Even count: average of two middle elements
        int mid = size / 2;
        return (sorted[mid - 1] + sorted[mid]) / 2.0;
    }
}

//+------------------------------------------------------------------+
//| Clamp score to [0, 1] range                                        |
//+------------------------------------------------------------------+
double CVirtualGate::ClampScore(double value)
{
    if(value <= 0.0) return 0.0;
    if(value >= 1.0) return 1.0;
    return value;
}

//+------------------------------------------------------------------+
//| Reset gate state                                                   |
//+------------------------------------------------------------------+
void CVirtualGate::Reset(void)
{
    m_cached_median_range = 0.0;
    m_last_reason = VGATE_INSUFFICIENT_HISTORY;
    m_last_result.Reset();
}

//+------------------------------------------------------------------+
//| Convert VGate reason to string                                     |
//+------------------------------------------------------------------+
string CVirtualGate::VGateReasonToString(ENUM_VGATE_REASON reason)
{
    switch(reason)
    {
        case VGATE_OK:                   return "OK";
        case VGATE_TEMPORAL_VIOLATION:   return "TEMPORAL_VIOLATION";
        case VGATE_RANGE_SPIKE:          return "RANGE_SPIKE";
        case VGATE_TURBULENCE_CLUSTER:   return "TURBULENCE_CLUSTER";
        case VGATE_INTRABAR_ACCESS:      return "INTRABAR_ACCESS";
        case VGATE_INSUFFICIENT_HISTORY: return "INSUFFICIENT_HISTORY";
        case VGATE_INVALID_INPUT:        return "INVALID_INPUT";
        case VGATE_NON_MONOTONIC_TS:     return "NON_MONOTONIC_TS";
        case VGATE_ZERO_MEDIAN_RANGE:    return "ZERO_MEDIAN_RANGE";
        default:                         return "UNKNOWN";
    }
}

//+------------------------------------------------------------------+
//| Get reason text (IRiskGate interface)                              |
//+------------------------------------------------------------------+
string CVirtualGate::GetReasonText(void)
{
    if(m_last_reason == VGATE_OK)
        return "OK";

    string base_reason = VGateReasonToString(m_last_reason);

    switch(m_last_reason)
    {
        case VGATE_INTRABAR_ACCESS:
            return base_reason + " - bar[0] access is BANNED! Use bar[1]+ only.";

        case VGATE_TEMPORAL_VIOLATION:
            return base_reason + " - bar timestamp >= decision timestamp (lookahead)";

        case VGATE_RANGE_SPIKE:
            return StringFormat("%s - ratio %.2f > threshold %.1f",
                               base_reason, m_last_result.last_range_ratio,
                               m_range_spike_multiplier);

        case VGATE_TURBULENCE_CLUSTER:
            return StringFormat("%s - spike_fraction %.1f%% > max %.1f%%",
                               base_reason, m_last_result.spike_fraction * 100.0,
                               m_cluster_max_fraction * 100.0);

        case VGATE_INSUFFICIENT_HISTORY:
            return StringFormat("%s - need %d bars", base_reason, m_lookback_bars);

        default:
            return base_reason;
    }
}

//+------------------------------------------------------------------+
//| Print current status                                               |
//+------------------------------------------------------------------+
void CVirtualGate::PrintStatus()
{
    Print("=== Virtual Gate Status ===");
    Print("Initialized: ", m_initialized);
    Print("Lookback bars: ", m_lookback_bars);
    Print("Spike multiplier: ", DoubleToString(m_range_spike_multiplier, 2));
    Print("Cluster multiplier: ", DoubleToString(m_cluster_spike_multiplier, 2));
    Print("Cluster max fraction: ", DoubleToString(m_cluster_max_fraction * 100.0, 1), "%");
    Print("---");
    Print("Cached median range: ", DoubleToString(m_cached_median_range, _Digits));
    Print("Last reason: ", VGateReasonToString(m_last_reason));
    Print("Last gate_ok: ", m_last_result.gate_ok);
    Print("Last gate_score: ", DoubleToString(m_last_result.gate_score, 2));
    Print("Last range ratio: ", DoubleToString(m_last_result.last_range_ratio, 2));
    Print("Last spike count: ", m_last_result.spike_count);
    Print("Last spike fraction: ", DoubleToString(m_last_result.spike_fraction * 100.0, 1), "%");
    Print("===========================");
}

#endif // CVIRTUALGATE_MQH
//+------------------------------------------------------------------+
