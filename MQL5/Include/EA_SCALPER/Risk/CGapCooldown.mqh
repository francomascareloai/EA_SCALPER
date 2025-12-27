//+------------------------------------------------------------------+
//|                                                  CGapCooldown.mqh |
//|                     EA_SCALPER_XAUUSD - Apex Compliant Trading    |
//|                     Gap Detection and Cooldown System (Task 3.3)  |
//+------------------------------------------------------------------+
//| PURPOSE: Block entries after market gaps to avoid gap risk        |
//|                                                                   |
//| USE CASES:                                                        |
//|   - Weekend gap (Friday 5PM -> Sunday 6PM EST)                    |
//|   - Session gap (e.g., London close -> Asian open)                |
//|   - News gap (unexpected large time gap in feed)                  |
//|                                                                   |
//| DESIGN:                                                           |
//|   - Detects gaps by comparing consecutive bar times               |
//|   - If gap >= threshold, activates cooldown period                |
//|   - During cooldown, blocks new entries via IRiskGate interface   |
//|   - Uses TimeGMT() for consistency across brokers                 |
//|                                                                   |
//| INTEGRATION:                                                      |
//|   - Call OnNewBar(bar_time) from EA's OnTick when new bar forms   |
//|   - Call IsBlocked() before allowing new entries                  |
//+------------------------------------------------------------------+
#ifndef CGAPCOOLDOWN_MQH
#define CGAPCOOLDOWN_MQH

#property copyright "EA_SCALPER_XAUUSD - Apex Compliant Trading System"
#property strict

#include "../Core/Definitions.mqh"
#include "../Core/IRiskGate.mqh"

//+------------------------------------------------------------------+
//| Gap Cooldown Status Enum                                          |
//+------------------------------------------------------------------+
enum ENUM_GAP_COOLDOWN_STATUS
{
    GAP_STATUS_NORMAL = 0,       // No gap detected, no cooldown
    GAP_STATUS_GAP_DETECTED = 1, // Gap just detected
    GAP_STATUS_COOLING_DOWN = 2, // In cooldown period
    GAP_STATUS_COOLDOWN_ENDED = 3 // Cooldown just ended
};

//+------------------------------------------------------------------+
//| Gap Detection Result Structure                                    |
//+------------------------------------------------------------------+
struct SGapDetection
{
    bool                detected;           // Was a gap detected?
    int                 gap_minutes;        // Gap duration in minutes
    datetime            gap_start_time;     // When gap started (last bar before gap)
    datetime            gap_end_time;       // When gap ended (first bar after gap)
    datetime            cooldown_until;     // Cooldown end time
    int                 remaining_seconds;  // Seconds remaining in cooldown
    ENUM_GAP_COOLDOWN_STATUS status;        // Current status

    void Reset()
    {
        detected = false;
        gap_minutes = 0;
        gap_start_time = 0;
        gap_end_time = 0;
        cooldown_until = 0;
        remaining_seconds = 0;
        status = GAP_STATUS_NORMAL;
    }
};

//+------------------------------------------------------------------+
//| Class: CGapCooldown                                               |
//| Purpose: Block entries after market gaps                          |
//| Implements: IRiskGate interface for unified gate system           |
//|                                                                   |
//| Configuration:                                                    |
//|   - gap_threshold_minutes: minimum gap to trigger cooldown (30)   |
//|   - cooldown_minutes: how long to block after gap (15)            |
//|                                                                   |
//| Gate Behavior:                                                    |
//|   - Returns GATE_GAP_COOLDOWN when in cooldown period             |
//|   - Cooldown timer uses TimeGMT() for broker-independent time     |
//+------------------------------------------------------------------+
class CGapCooldown : public IRiskGate
{
private:
    //--- Configuration
    int                 m_gap_threshold_minutes;    // Minimum gap to trigger cooldown (default 30)
    int                 m_cooldown_minutes;         // Cooldown duration (default 15)

    //--- State
    datetime            m_cooldown_until;           // UTC time when cooldown ends
    datetime            m_last_bar_time;            // Last bar time seen
    bool                m_initialized;              // Has Init() been called?

    //--- Statistics
    int                 m_gaps_detected;            // Total gaps detected
    int                 m_cooldowns_applied;        // Total cooldowns applied
    datetime            m_last_gap_time;            // Last gap detection time
    int                 m_last_gap_minutes;         // Last gap duration

    //--- Logging
    bool                m_verbose;                  // Verbose logging?

    //--- OnTick state tracking (avoids static variable issue with multiple instances)
    bool                m_was_in_cooldown;          // Previous cooldown state for edge detection

public:
    //--- Constructor / Destructor
                        CGapCooldown();
                       ~CGapCooldown();

    //--- Initialization
    bool                Init(int gap_threshold_min = 30, int cooldown_min = 15, bool verbose = true);

    //--- Configuration (can be changed at runtime)
    void                SetGapThreshold(int minutes);
    void                SetCooldownDuration(int minutes);
    int                 GetGapThreshold() const { return m_gap_threshold_minutes; }
    int                 GetCooldownDuration() const { return m_cooldown_minutes; }

    //--- Core functionality
    void                OnNewBar(datetime bar_time);
    bool                IsInCooldown();
    int                 GetRemainingCooldownSeconds();

    //--- Status accessors
    SGapDetection       GetStatus();
    int                 GetGapsDetected() const { return m_gaps_detected; }
    int                 GetCooldownsApplied() const { return m_cooldowns_applied; }
    datetime            GetLastGapTime() const { return m_last_gap_time; }
    int                 GetLastGapMinutes() const { return m_last_gap_minutes; }
    datetime            GetCooldownUntil() const { return m_cooldown_until; }

    //--- IRiskGate interface implementation
    virtual bool        IsBlocked(void) override;
    virtual ENUM_GATE_REASON GetReason(void) override;
    virtual string      GetReasonText(void) override;
    virtual void        OnTick(void) override;
    virtual void        Reset(void) override;
    virtual string      GetGateName(void) override { return "GapCooldown"; }

    //--- Utility
    void                ForceCooldown(int minutes, string reason = "manual");
    void                ClearCooldown();
    void                PrintStatus();
    string              GetDiagnosticInfo();
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CGapCooldown::CGapCooldown()
{
    m_gap_threshold_minutes = 30;   // Default: 30 min gap triggers cooldown
    m_cooldown_minutes = 15;        // Default: 15 min cooldown after gap

    m_cooldown_until = 0;
    m_last_bar_time = 0;
    m_initialized = false;

    m_gaps_detected = 0;
    m_cooldowns_applied = 0;
    m_last_gap_time = 0;
    m_last_gap_minutes = 0;

    m_verbose = true;
    m_was_in_cooldown = false;
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CGapCooldown::~CGapCooldown()
{
    // Nothing to clean up
}

//+------------------------------------------------------------------+
//| Initialize the gap cooldown system                                |
//+------------------------------------------------------------------+
bool CGapCooldown::Init(int gap_threshold_min = 30, int cooldown_min = 15, bool verbose = true)
{
    // Validate inputs
    // Formula: gap_threshold_min must be positive (minimum gap to trigger cooldown)
    // Example: 30 min gap threshold -> gaps >= 30 min trigger cooldown
    if(gap_threshold_min <= 0)
    {
        Print("CGapCooldown: ERROR - gap_threshold_min must be positive, got ", gap_threshold_min);
        return false;
    }

    // Formula: cooldown_min must be non-negative (0 = no cooldown, just log gap)
    // Example: 15 min cooldown -> block entries for 15 min after gap
    if(cooldown_min < 0)
    {
        Print("CGapCooldown: ERROR - cooldown_min must be non-negative, got ", cooldown_min);
        return false;
    }

    m_gap_threshold_minutes = gap_threshold_min;
    m_cooldown_minutes = cooldown_min;
    m_verbose = verbose;

    // Reset state
    m_cooldown_until = 0;
    m_last_bar_time = 0;
    m_gaps_detected = 0;
    m_cooldowns_applied = 0;
    m_last_gap_time = 0;
    m_last_gap_minutes = 0;

    m_initialized = true;

    if(m_verbose)
    {
        Print("CGapCooldown: Initialized");
        Print("  Gap threshold: ", m_gap_threshold_minutes, " minutes");
        Print("  Cooldown duration: ", m_cooldown_minutes, " minutes");
    }

    return true;
}

//+------------------------------------------------------------------+
//| Set gap threshold (minimum gap in minutes to trigger cooldown)    |
//+------------------------------------------------------------------+
void CGapCooldown::SetGapThreshold(int minutes)
{
    if(minutes <= 0)
    {
        Print("CGapCooldown: WARNING - ignoring invalid gap threshold: ", minutes);
        return;
    }

    m_gap_threshold_minutes = minutes;

    if(m_verbose)
        Print("CGapCooldown: Gap threshold set to ", minutes, " minutes");
}

//+------------------------------------------------------------------+
//| Set cooldown duration (how long to block after gap)               |
//+------------------------------------------------------------------+
void CGapCooldown::SetCooldownDuration(int minutes)
{
    if(minutes < 0)
    {
        Print("CGapCooldown: WARNING - ignoring invalid cooldown duration: ", minutes);
        return;
    }

    m_cooldown_minutes = minutes;

    if(m_verbose)
        Print("CGapCooldown: Cooldown duration set to ", minutes, " minutes");
}

//+------------------------------------------------------------------+
//| Called on each new bar to detect gaps                             |
//| bar_time: the time of the new bar that just formed                |
//+------------------------------------------------------------------+
void CGapCooldown::OnNewBar(datetime bar_time)
{
    if(!m_initialized)
    {
        Print("CGapCooldown: WARNING - OnNewBar called before Init()");
        Init();  // Use defaults
    }

    // Need previous bar time to compare
    if(m_last_bar_time > 0)
    {
        // Formula: gap_minutes = (bar_time - m_last_bar_time) / 60
        // Example: bar_time=1700000000, last=1700000000-3600 -> gap=60 min
        // Safety: ensure bar_time > m_last_bar_time to avoid negative
        if(bar_time > m_last_bar_time)
        {
            int gap_seconds = (int)(bar_time - m_last_bar_time);
            int gap_minutes = gap_seconds / 60;

            // Validate gap calculation
            // Assertion: gap_minutes should be reasonable (0 to ~4000 for weekend)
            // Weekend gap: Friday 17:00 to Sunday 18:00 = ~49 hours = ~2940 minutes
            if(gap_minutes < 0 || gap_minutes > 5000)
            {
                Print("CGapCooldown: WARNING - Invalid gap_minutes calculated: ", gap_minutes);
                Print("  bar_time: ", TimeToString(bar_time, TIME_DATE | TIME_SECONDS));
                Print("  last_bar_time: ", TimeToString(m_last_bar_time, TIME_DATE | TIME_SECONDS));
            }
            else if(gap_minutes >= m_gap_threshold_minutes)
            {
                // GAP DETECTED!
                m_gaps_detected++;
                m_last_gap_time = bar_time;
                m_last_gap_minutes = gap_minutes;

                // Formula: cooldown_until = bar_time + cooldown_minutes * 60
                // Note: We use bar_time (not TimeGMT()) as the reference
                // because we want cooldown relative to when gap was detected
                // BUT we use TimeGMT() in IsInCooldown() for accurate comparison
                datetime now_utc = TimeGMT();
                m_cooldown_until = now_utc + m_cooldown_minutes * 60;
                m_cooldowns_applied++;

                Print("CGapCooldown: ========== GAP DETECTED ==========");
                Print("  Gap duration: ", gap_minutes, " minutes (threshold: ", m_gap_threshold_minutes, ")");
                Print("  Gap from: ", TimeToString(m_last_bar_time, TIME_DATE | TIME_SECONDS));
                Print("  Gap to: ", TimeToString(bar_time, TIME_DATE | TIME_SECONDS));
                Print("  Cooldown until: ", TimeToString(m_cooldown_until, TIME_DATE | TIME_SECONDS), " UTC");
                Print("  Cooldown duration: ", m_cooldown_minutes, " minutes");
                Print("  Total gaps detected: ", m_gaps_detected);
                Print("================================================");

                // Categorize gap type for logging
                if(gap_minutes >= 2400)  // > 40 hours = weekend
                {
                    Print("CGapCooldown: Gap type: WEEKEND (", gap_minutes / 60, " hours)");
                }
                else if(gap_minutes >= 120)  // > 2 hours = session gap
                {
                    Print("CGapCooldown: Gap type: SESSION (", gap_minutes, " minutes)");
                }
                else
                {
                    Print("CGapCooldown: Gap type: FEED/NEWS (", gap_minutes, " minutes)");
                }
            }
        }
        else if(bar_time < m_last_bar_time)
        {
            // Bar time went backwards - this is unusual but can happen
            // with tick data replay or time adjustments
            if(m_verbose)
            {
                Print("CGapCooldown: WARNING - Bar time went backwards");
                Print("  Expected > ", TimeToString(m_last_bar_time, TIME_DATE | TIME_SECONDS));
                Print("  Got: ", TimeToString(bar_time, TIME_DATE | TIME_SECONDS));
            }
        }
        // If bar_time == m_last_bar_time, same bar - ignore
    }

    // Update last bar time
    m_last_bar_time = bar_time;
}

//+------------------------------------------------------------------+
//| Check if currently in cooldown period                             |
//| Uses TimeGMT() for broker-independent time comparison             |
//+------------------------------------------------------------------+
bool CGapCooldown::IsInCooldown()
{
    if(m_cooldown_until == 0)
        return false;

    datetime now_utc = TimeGMT();

    // Formula: in_cooldown = now_utc < m_cooldown_until
    // Example: now=1700000000, cooldown_until=1700001000 -> true (1000 seconds left)
    return (now_utc < m_cooldown_until);
}

//+------------------------------------------------------------------+
//| Get remaining cooldown time in seconds                            |
//+------------------------------------------------------------------+
int CGapCooldown::GetRemainingCooldownSeconds()
{
    if(!IsInCooldown())
        return 0;

    datetime now_utc = TimeGMT();

    // Formula: remaining = cooldown_until - now_utc
    // Example: cooldown_until=1700001000, now=1700000000 -> 1000 seconds
    int remaining = (int)(m_cooldown_until - now_utc);

    // Validate: should be non-negative (we already checked IsInCooldown)
    if(remaining < 0)
    {
        Print("CGapCooldown: WARNING - GetRemainingCooldownSeconds returned negative: ", remaining);
        return 0;
    }

    return remaining;
}

//+------------------------------------------------------------------+
//| Get comprehensive status                                          |
//+------------------------------------------------------------------+
SGapDetection CGapCooldown::GetStatus()
{
    SGapDetection result;
    result.Reset();

    bool in_cooldown = IsInCooldown();

    result.detected = (m_last_gap_minutes > 0);
    result.gap_minutes = m_last_gap_minutes;
    result.gap_start_time = (m_last_bar_time > 0 && m_last_gap_minutes > 0)
                            ? m_last_bar_time - m_last_gap_minutes * 60
                            : 0;
    result.gap_end_time = m_last_gap_time;
    result.cooldown_until = m_cooldown_until;
    result.remaining_seconds = GetRemainingCooldownSeconds();

    if(in_cooldown)
        result.status = GAP_STATUS_COOLING_DOWN;
    else if(m_last_gap_minutes > 0)
        result.status = GAP_STATUS_COOLDOWN_ENDED;
    else
        result.status = GAP_STATUS_NORMAL;

    return result;
}

//+------------------------------------------------------------------+
//| IRiskGate: Check if trading is blocked                            |
//+------------------------------------------------------------------+
bool CGapCooldown::IsBlocked(void)
{
    return IsInCooldown();
}

//+------------------------------------------------------------------+
//| IRiskGate: Get the reason for blocking                            |
//+------------------------------------------------------------------+
ENUM_GATE_REASON CGapCooldown::GetReason(void)
{
    if(!IsBlocked())
        return GATE_OK;

    return GATE_GAP_COOLDOWN;
}

//+------------------------------------------------------------------+
//| IRiskGate: Get human-readable reason text                         |
//+------------------------------------------------------------------+
string CGapCooldown::GetReasonText(void)
{
    if(!IsBlocked())
        return "OK";

    int remaining = GetRemainingCooldownSeconds();
    int remaining_min = remaining / 60;
    int remaining_sec = remaining % 60;

    return StringFormat("Gap cooldown active: %d:%02d remaining (last gap: %d min)",
                       remaining_min, remaining_sec, m_last_gap_minutes);
}

//+------------------------------------------------------------------+
//| IRiskGate: Called on each tick (optional monitoring)              |
//+------------------------------------------------------------------+
void CGapCooldown::OnTick(void)
{
    // Check if cooldown just ended (edge detection)
    bool in_cooldown = IsInCooldown();

    if(m_was_in_cooldown && !in_cooldown)
    {
        if(m_verbose)
        {
            Print("CGapCooldown: Cooldown period ENDED. Trading allowed.");
        }
    }

    m_was_in_cooldown = in_cooldown;
}

//+------------------------------------------------------------------+
//| IRiskGate: Reset state for new session                            |
//+------------------------------------------------------------------+
void CGapCooldown::Reset(void)
{
    m_cooldown_until = 0;
    m_last_bar_time = 0;
    // Note: We keep statistics (gaps_detected, etc.) across resets
    // Only clear state, not history

    if(m_verbose)
        Print("CGapCooldown: State reset. Statistics preserved.");
}

//+------------------------------------------------------------------+
//| Force a cooldown period (for manual or external triggers)         |
//+------------------------------------------------------------------+
void CGapCooldown::ForceCooldown(int minutes, string reason = "manual")
{
    if(minutes <= 0)
    {
        Print("CGapCooldown: WARNING - ignoring ForceCooldown with invalid minutes: ", minutes);
        return;
    }

    datetime now_utc = TimeGMT();
    m_cooldown_until = now_utc + minutes * 60;
    m_cooldowns_applied++;

    Print("CGapCooldown: FORCED cooldown activated");
    Print("  Reason: ", reason);
    Print("  Duration: ", minutes, " minutes");
    Print("  Until: ", TimeToString(m_cooldown_until, TIME_DATE | TIME_SECONDS), " UTC");
}

//+------------------------------------------------------------------+
//| Clear any active cooldown (emergency override)                    |
//+------------------------------------------------------------------+
void CGapCooldown::ClearCooldown()
{
    if(m_cooldown_until > 0)
    {
        Print("CGapCooldown: Cooldown CLEARED manually");
        Print("  Was until: ", TimeToString(m_cooldown_until, TIME_DATE | TIME_SECONDS), " UTC");
        Print("  Remaining was: ", GetRemainingCooldownSeconds(), " seconds");
    }

    m_cooldown_until = 0;
}

//+------------------------------------------------------------------+
//| Print current status                                              |
//+------------------------------------------------------------------+
void CGapCooldown::PrintStatus()
{
    SGapDetection status = GetStatus();

    Print("=== Gap Cooldown Status ===");
    Print("  Initialized: ", m_initialized ? "YES" : "NO");
    Print("  Gap threshold: ", m_gap_threshold_minutes, " minutes");
    Print("  Cooldown duration: ", m_cooldown_minutes, " minutes");
    Print("  ---");
    Print("  In cooldown: ", IsInCooldown() ? "YES" : "NO");
    if(IsInCooldown())
    {
        Print("  Remaining: ", status.remaining_seconds / 60, ":",
              StringFormat("%02d", status.remaining_seconds % 60));
        Print("  Until: ", TimeToString(m_cooldown_until, TIME_DATE | TIME_SECONDS), " UTC");
    }
    Print("  ---");
    Print("  Last bar time: ", m_last_bar_time > 0
          ? TimeToString(m_last_bar_time, TIME_DATE | TIME_SECONDS) : "N/A");
    Print("  Last gap: ", m_last_gap_minutes > 0
          ? StringFormat("%d min at %s", m_last_gap_minutes,
            TimeToString(m_last_gap_time, TIME_DATE | TIME_SECONDS)) : "None");
    Print("  ---");
    Print("  Total gaps detected: ", m_gaps_detected);
    Print("  Total cooldowns applied: ", m_cooldowns_applied);
    Print("===========================");
}

//+------------------------------------------------------------------+
//| Get diagnostic information as string                              |
//+------------------------------------------------------------------+
string CGapCooldown::GetDiagnosticInfo()
{
    SGapDetection status = GetStatus();

    string info = StringFormat(
        "\nGap Cooldown Diagnostic:\n"
        "  Threshold: %d min\n"
        "  Cooldown: %d min\n"
        "  In cooldown: %s\n"
        "  Remaining: %d sec\n"
        "  Last bar: %s\n"
        "  Last gap: %d min\n"
        "  Gaps detected: %d\n"
        "  Cooldowns applied: %d\n",
        m_gap_threshold_minutes,
        m_cooldown_minutes,
        IsInCooldown() ? "YES" : "NO",
        status.remaining_seconds,
        m_last_bar_time > 0 ? TimeToString(m_last_bar_time, TIME_DATE | TIME_SECONDS) : "N/A",
        m_last_gap_minutes,
        m_gaps_detected,
        m_cooldowns_applied
    );

    return info;
}

#endif // CGAPCOOLDOWN_MQH
//+------------------------------------------------------------------+
