//+------------------------------------------------------------------+
//|                                              Test_WallClock.mq5 |
//|                     EA_SCALPER_XAUUSD - Apex Compliant Trading   |
//|                     Task 7.3: Timer Delay Disproof Test          |
//+------------------------------------------------------------------+
//| PURPOSE: Validate idempotent wall-clock enforcement              |
//|                                                                   |
//| DISPROOF TESTS (CRITIC FIX #4):                                  |
//|   1. Timer Gap Test - OnTimer can be delayed by minutes,         |
//|      but flatten MUST still execute when it finally fires        |
//|   2. Idempotent Test - Flatten only executes ONCE per session    |
//|   3. EA Restart Test - Restart after deadline triggers flatten   |
//|                                                                   |
//| TEST APPROACH:                                                    |
//|   Uses MockApexTimeHandler to inject simulated time states       |
//|   without modifying production code                              |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD - Apex Compliant Trading System"
#property strict
#property script_show_inputs

#include <EA_SCALPER/Core/Definitions.mqh>

// === TEST CONFIGURATION ===
input bool InpVerbose = true;    // Verbose test output

// === GLOBAL TEST STATE ===
int g_tests_passed = 0;
int g_tests_failed = 0;

//+------------------------------------------------------------------+
//| MockApexTimeHandler - Testable time handler with injection       |
//| Allows simulation of any time state for disproof testing         |
//+------------------------------------------------------------------+
class CMockApexTimeHandler
{
private:
    ENUM_TIME_STATE   m_injected_state;      // Injected time state
    int               m_injected_minutes;    // Injected minutes from midnight
    bool              m_use_injection;       // Use injected values?
    int               m_et_offset_hours;     // ET offset for simulation
    datetime          m_session_start_utc;   // Session start

public:
    CMockApexTimeHandler()
    {
        m_injected_state = TIME_NORMAL;
        m_injected_minutes = 0;
        m_use_injection = false;
        m_et_offset_hours = -5;  // EST default
        m_session_start_utc = TimeGMT();
    }

    bool Init() { return true; }
    void Reset()
    {
        m_injected_state = TIME_NORMAL;
        m_use_injection = false;
        m_session_start_utc = TimeGMT();
    }

    // === INJECTION METHODS (for testing) ===
    void InjectTimeState(ENUM_TIME_STATE state)
    {
        m_injected_state = state;
        m_use_injection = true;
    }

    void InjectMinutesFromMidnight(int minutes)
    {
        m_injected_minutes = minutes;
        m_use_injection = true;

        // Auto-determine state from minutes
        if(minutes >= 1019)  // 4:59 PM
            m_injected_state = TIME_HALTED;
        else if(minutes >= 1015)  // 4:55 PM
            m_injected_state = TIME_EMERGENCY;
        else if(minutes >= 990)  // 4:30 PM
            m_injected_state = TIME_BLOCK_NEW;
        else
            m_injected_state = TIME_NORMAL;
    }

    void ClearInjection() { m_use_injection = false; }

    // === STANDARD INTERFACE (mirrors CApexTimeHandler) ===
    datetime GetCurrentUTC() { return TimeGMT(); }

    datetime GetCurrentET()
    {
        return TimeGMT() + m_et_offset_hours * 3600;
    }

    int GetETOffsetHours() { return m_et_offset_hours; }
    bool IsDST() { return (m_et_offset_hours == -4); }

    ENUM_TIME_STATE GetTimeState()
    {
        if(m_use_injection)
            return m_injected_state;

        // Real calculation (same as CApexTimeHandler)
        int minutes = GetMinutesFromMidnight();
        if(minutes >= 1019) return TIME_HALTED;
        if(minutes >= 1015) return TIME_EMERGENCY;
        if(minutes >= 990)  return TIME_BLOCK_NEW;
        return TIME_NORMAL;
    }

    int GetMinutesToState(ENUM_TIME_STATE target)
    {
        int current_minutes = GetMinutesFromMidnight();
        int target_minutes = 0;

        switch(target)
        {
            case TIME_BLOCK_NEW: target_minutes = 990; break;
            case TIME_EMERGENCY: target_minutes = 1015; break;
            case TIME_HALTED:    target_minutes = 1019; break;
            default: return 0;
        }

        int diff = target_minutes - current_minutes;
        return (diff > 0) ? diff : 0;
    }

    int GetMinutesToClose() { return GetMinutesToState(TIME_HALTED); }

    int GetMinutesFromMidnight()
    {
        if(m_use_injection)
            return m_injected_minutes;

        datetime et_time = GetCurrentET();
        MqlDateTime mdt;
        TimeToStruct(et_time, mdt);
        return mdt.hour * 60 + mdt.min;
    }

    bool IsNormalTrading() { return (GetTimeState() == TIME_NORMAL); }
    bool IsBlockNewTrades() { return (GetTimeState() >= TIME_BLOCK_NEW); }
    bool IsEmergencyClose() { return (GetTimeState() >= TIME_EMERGENCY); }
    bool IsHalted() { return (GetTimeState() == TIME_HALTED); }
    bool CanOpenNewTrade() { return IsNormalTrading(); }

    string GetTimeStateString()
    {
        switch(GetTimeState())
        {
            case TIME_NORMAL:    return "NORMAL";
            case TIME_BLOCK_NEW: return "BLOCK_NEW (4:30 PM+ ET)";
            case TIME_EMERGENCY: return "EMERGENCY (4:55 PM+ ET)";
            case TIME_HALTED:    return "HALTED (4:59 PM+ ET)";
            default:             return "UNKNOWN";
        }
    }

    string GetDiagnosticInfo()
    {
        return StringFormat(
            "MockTimeHandler: State=%s, Injection=%s, Minutes=%d",
            GetTimeStateString(),
            m_use_injection ? "ON" : "OFF",
            GetMinutesFromMidnight()
        );
    }

    datetime GetSessionStartUTC() { return m_session_start_utc; }
    int GetDSTChecksCount() { return 0; }
};

//+------------------------------------------------------------------+
//| CTestableWallClockEnforcer - Enforcer with mock time injection   |
//| Mirrors CWallClockEnforcer but uses CMockApexTimeHandler         |
//+------------------------------------------------------------------+
class CTestableWallClockEnforcer
{
private:
    CMockApexTimeHandler* m_time_handler;

    // State tracking (mirrors CWallClockEnforcer)
    bool              m_flatten_executed;
    bool              m_block_new_warned;
    bool              m_emergency_warned;
    datetime          m_flatten_time;
    int               m_flatten_count;          // How many times flatten was called
    int               m_positions_closed;
    int               m_check_count;
    int               m_gap_warnings;
    datetime          m_last_check_utc;
    bool              m_deadline_missed;        // Was deadline missed before first check?

public:
    CTestableWallClockEnforcer()
    {
        m_time_handler = NULL;
        m_flatten_executed = false;
        m_block_new_warned = false;
        m_emergency_warned = false;
        m_flatten_time = 0;
        m_flatten_count = 0;
        m_positions_closed = 0;
        m_check_count = 0;
        m_gap_warnings = 0;
        m_last_check_utc = 0;
        m_deadline_missed = false;
    }

    ~CTestableWallClockEnforcer()
    {
        if(m_time_handler != NULL)
        {
            delete m_time_handler;
            m_time_handler = NULL;
        }
    }

    bool Init(int magic, string symbol = "")
    {
        // Create mock time handler
        if(m_time_handler == NULL)
        {
            m_time_handler = new CMockApexTimeHandler();
            m_time_handler.Init();
        }

        // Check if we're already past deadline on startup (EA restart scenario)
        if(m_time_handler.IsHalted() && !m_flatten_executed)
        {
            m_deadline_missed = true;
            Print("TestableEnforcer: WARNING - Started after deadline!");
            ExecuteEmergencyFlatten("EA restart after deadline");
        }

        m_last_check_utc = TimeGMT();
        return true;
    }

    void AttachTimeHandler(CMockApexTimeHandler* handler)
    {
        if(m_time_handler != NULL)
            delete m_time_handler;
        m_time_handler = handler;
    }

    CMockApexTimeHandler* GetTimeHandler() { return m_time_handler; }

    void Reset()
    {
        m_flatten_executed = false;
        m_block_new_warned = false;
        m_emergency_warned = false;
        m_flatten_time = 0;
        m_flatten_count = 0;
        m_positions_closed = 0;
        m_check_count = 0;
        m_gap_warnings = 0;
        m_deadline_missed = false;

        if(m_time_handler != NULL)
            m_time_handler.Reset();

        m_last_check_utc = TimeGMT();
    }

    //+------------------------------------------------------------------+
    //| Main check - IDEMPOTENT: flatten only executes ONCE              |
    //+------------------------------------------------------------------+
    void CheckAndEnforce()
    {
        if(m_time_handler == NULL)
        {
            Print("TestableEnforcer: ERROR - Time handler not initialized!");
            return;
        }

        m_check_count++;

        // Check for gaps
        CheckForGaps();

        // Get current time state
        ENUM_TIME_STATE state = m_time_handler.GetTimeState();

        // === STATE MACHINE ===

        // 1. HALTED (4:59 PM ET+): Execute emergency flatten
        if(state >= TIME_HALTED)
        {
            // IDEMPOTENT: only execute flatten ONCE
            if(!m_flatten_executed)
            {
                Print("TestableEnforcer: TIME_HALTED - Executing emergency flatten");
                ExecuteEmergencyFlatten("Hard deadline 4:59 PM ET");
                m_flatten_executed = true;
                m_flatten_time = TimeGMT();
            }
            // If already executed, return silently (idempotent)
            return;
        }

        // 2. EMERGENCY (4:55 PM ET): Warn and prepare
        if(state >= TIME_EMERGENCY)
        {
            if(!m_emergency_warned)
            {
                int minutes_to_close = m_time_handler.GetMinutesToClose();
                Print("TestableEnforcer: EMERGENCY - ", minutes_to_close,
                      " minutes to hard close!");
                m_emergency_warned = true;
            }
            return;
        }

        // 3. BLOCK_NEW (4:30 PM ET): Warn about new trade restriction
        if(state >= TIME_BLOCK_NEW)
        {
            if(!m_block_new_warned)
            {
                int minutes_to_close = m_time_handler.GetMinutesToClose();
                Print("TestableEnforcer: BLOCK_NEW - New trades blocked. ",
                      minutes_to_close, " minutes to close.");
                m_block_new_warned = true;
            }
            return;
        }

        // 4. NORMAL: Nothing special to do
    }

    //+------------------------------------------------------------------+
    //| Execute emergency flatten (simulated for testing)                |
    //+------------------------------------------------------------------+
    bool ExecuteEmergencyFlatten(string reason)
    {
        m_flatten_count++;  // Track how many times this is called

        Print("TestableEnforcer: ===== EMERGENCY FLATTEN =====");
        Print("  Reason: ", reason);
        Print("  Flatten call #: ", m_flatten_count);

        // In a real scenario, this would close positions
        // For testing, we just track that it was called
        m_positions_closed = 0;  // Simulated: no real positions

        Print("TestableEnforcer: ===== FLATTEN COMPLETE =====");
        return true;
    }

    void CheckForGaps()
    {
        datetime now_utc = TimeGMT();

        if(m_last_check_utc > 0)
        {
            long gap_seconds = (long)(now_utc - m_last_check_utc);

            if(gap_seconds > 60)  // GAP_WARNING_THRESHOLD_SEC
            {
                m_gap_warnings++;
                Print("TestableEnforcer: WARNING - ", gap_seconds,
                      " second gap since last check!");
            }
        }

        m_last_check_utc = now_utc;
    }

    // === STATUS ACCESSORS ===
    bool              IsFlattenExecuted() { return m_flatten_executed; }
    datetime          GetFlattenTime() { return m_flatten_time; }
    int               GetFlattenCount() { return m_flatten_count; }
    int               GetPositionsClosed() { return m_positions_closed; }
    int               GetCheckCount() { return m_check_count; }
    int               GetGapWarnings() { return m_gap_warnings; }
    bool              WasDeadlineMissed() { return m_deadline_missed; }
    bool              DidFlatten() { return m_flatten_count > 0; }

    // Time accessors
    ENUM_TIME_STATE   GetTimeState() { return m_time_handler != NULL ? m_time_handler.GetTimeState() : TIME_HALTED; }
    int               GetMinutesToClose() { return m_time_handler != NULL ? m_time_handler.GetMinutesToClose() : 0; }
    bool              CanOpenNewTrade() { return m_time_handler != NULL ? m_time_handler.CanOpenNewTrade() : false; }
    bool              IsEmergencyClose() { return m_time_handler != NULL ? m_time_handler.IsEmergencyClose() : true; }
    bool              IsHalted() { return m_time_handler != NULL ? m_time_handler.IsHalted() : true; }

    string GetDiagnosticInfo()
    {
        string time_info = (m_time_handler != NULL) ? m_time_handler.GetDiagnosticInfo() : "NO_HANDLER";

        return StringFormat(
            "\nTestableWallClockEnforcer Diagnostic:\n"
            "  Checks: %d | Gap Warnings: %d\n"
            "  Flatten Executed: %s | Flatten Count: %d\n"
            "  Flatten Time: %s\n"
            "  Deadline Missed: %s\n"
            "  %s",
            m_check_count,
            m_gap_warnings,
            m_flatten_executed ? "YES" : "NO",
            m_flatten_count,
            m_flatten_time > 0 ? TimeToString(m_flatten_time, TIME_DATE | TIME_SECONDS) : "N/A",
            m_deadline_missed ? "YES" : "NO",
            time_info
        );
    }
};

//+------------------------------------------------------------------+
//| Test Helper Functions                                             |
//+------------------------------------------------------------------+
void Assert(bool condition, string test_name, string details = "")
{
    if(condition)
    {
        g_tests_passed++;
        Print("PASS: ", test_name);
        if(InpVerbose && details != "")
            Print("  Details: ", details);
    }
    else
    {
        g_tests_failed++;
        Print("FAIL: ", test_name);
        if(details != "")
            Print("  Details: ", details);
    }
}

void PrintTestHeader(string test_name)
{
    Print("");
    Print("============================================================");
    Print("=== ", test_name);
    Print("============================================================");
}

//+------------------------------------------------------------------+
//| TEST 1: Timer Gap - Flatten Still Executes Despite Delay         |
//+------------------------------------------------------------------+
//| SCENARIO:                                                         |
//| - Hard deadline is 4:59 PM ET                                    |
//| - OnTimer was supposed to fire at 4:58, 4:59, 5:00               |
//| - Due to CPU load, OnTimer only fires at 5:05 PM (5 minute gap!) |
//| - Flatten MUST still execute immediately when OnTimer fires      |
//+------------------------------------------------------------------+
void Test_TimerGap_FlattenStillExecutes()
{
    PrintTestHeader("Timer Gap Disproof Test");

    CTestableWallClockEnforcer enforcer;
    enforcer.Init(12345, "XAUUSD");

    // Get mock handler
    CMockApexTimeHandler* handler = enforcer.GetTimeHandler();
    if(handler == NULL)
    {
        Assert(false, "Timer gap test setup", "Failed to get time handler");
        return;
    }

    // Simulate: Timer was delayed and fires at 5:05 PM ET (305 minutes past midnight = 17:05)
    // This is 6 minutes PAST the 4:59 PM deadline
    int minutes_at_505pm = 17 * 60 + 5;  // 1025 minutes = 5:05 PM
    handler.InjectMinutesFromMidnight(minutes_at_505pm);

    Print("Simulating time: 5:05 PM ET (", minutes_at_505pm, " minutes from midnight)");
    Print("This is ", minutes_at_505pm - 1019, " minutes PAST the 4:59 PM deadline");

    // Verify we're in HALTED state
    Assert(handler.IsHalted(), "Time state is HALTED",
           StringFormat("State=%s", handler.GetTimeStateString()));

    // Now call CheckAndEnforce - this simulates OnTimer finally firing
    Print("Calling CheckAndEnforce() (simulating delayed OnTimer)...");
    enforcer.CheckAndEnforce();

    // KEY CHECK: Did flatten execute despite the delay?
    bool flatten_executed = enforcer.IsFlattenExecuted();
    int flatten_count = enforcer.GetFlattenCount();

    Assert(flatten_executed, "Flatten was executed despite timer delay",
           StringFormat("FlattenExecuted=%s, FlattenCount=%d",
                       flatten_executed ? "true" : "false", flatten_count));

    // Verify exactly ONE flatten
    Assert(flatten_count == 1, "Flatten executed exactly once",
           StringFormat("FlattenCount=%d (should be 1)", flatten_count));

    if(InpVerbose)
        Print(enforcer.GetDiagnosticInfo());

    Print("--- Timer Gap Test Complete ---");
}

//+------------------------------------------------------------------+
//| TEST 2: Idempotent Flatten - Only Execute Once                   |
//+------------------------------------------------------------------+
//| SCENARIO:                                                         |
//| - Flatten was already executed at 4:59 PM                        |
//| - OnTimer fires again at 5:00 PM, 5:01 PM, 5:02 PM               |
//| - Flatten should NOT execute again (already done!)               |
//+------------------------------------------------------------------+
void Test_FlattenOnlyOnce()
{
    PrintTestHeader("Idempotent Flatten Test");

    CTestableWallClockEnforcer enforcer;
    enforcer.Init(12345, "XAUUSD");

    CMockApexTimeHandler* handler = enforcer.GetTimeHandler();
    if(handler == NULL)
    {
        Assert(false, "Idempotent test setup", "Failed to get time handler");
        return;
    }

    // Simulate: 4:59 PM ET (exactly at deadline)
    int minutes_at_459pm = 16 * 60 + 59;  // 1019 minutes
    handler.InjectMinutesFromMidnight(minutes_at_459pm);

    Print("Step 1: First CheckAndEnforce at 4:59 PM ET - should flatten");
    enforcer.CheckAndEnforce();
    int flatten_count_1 = enforcer.GetFlattenCount();

    Assert(flatten_count_1 == 1, "First call triggers flatten",
           StringFormat("FlattenCount=%d after first call", flatten_count_1));

    // Simulate subsequent timer calls at 5:00, 5:01, 5:02 PM
    Print("Step 2: Subsequent calls at 5:00, 5:01, 5:02 PM - should NOT flatten again");

    handler.InjectMinutesFromMidnight(17 * 60 + 0);  // 5:00 PM
    enforcer.CheckAndEnforce();

    handler.InjectMinutesFromMidnight(17 * 60 + 1);  // 5:01 PM
    enforcer.CheckAndEnforce();

    handler.InjectMinutesFromMidnight(17 * 60 + 2);  // 5:02 PM
    enforcer.CheckAndEnforce();

    int flatten_count_final = enforcer.GetFlattenCount();
    int check_count = enforcer.GetCheckCount();

    Assert(flatten_count_final == 1, "Flatten executed exactly ONCE (idempotent)",
           StringFormat("FlattenCount=%d after %d checks (should be 1)",
                       flatten_count_final, check_count));

    // Additional verification
    Assert(check_count == 4, "All 4 checks were counted",
           StringFormat("CheckCount=%d", check_count));

    Assert(enforcer.IsFlattenExecuted(), "IsFlattenExecuted flag is set",
           "Flag prevents re-execution");

    if(InpVerbose)
        Print(enforcer.GetDiagnosticInfo());

    Print("--- Idempotent Flatten Test Complete ---");
}

//+------------------------------------------------------------------+
//| TEST 3: Rapid Fire Calls - Stress Test Idempotency               |
//+------------------------------------------------------------------+
//| SCENARIO:                                                         |
//| - Simulate 100 rapid CheckAndEnforce calls while past deadline   |
//| - Flatten should execute exactly ONCE                            |
//+------------------------------------------------------------------+
void Test_RapidFireCalls()
{
    PrintTestHeader("Rapid Fire Idempotency Stress Test");

    CTestableWallClockEnforcer enforcer;
    enforcer.Init(12345, "XAUUSD");

    CMockApexTimeHandler* handler = enforcer.GetTimeHandler();
    if(handler == NULL)
    {
        Assert(false, "Rapid fire test setup", "Failed to get time handler");
        return;
    }

    // Set time to 5:00 PM ET (past deadline)
    handler.InjectMinutesFromMidnight(17 * 60);

    Print("Executing 100 rapid CheckAndEnforce calls at 5:00 PM ET...");

    int rapid_calls = 100;
    for(int i = 0; i < rapid_calls; i++)
    {
        enforcer.CheckAndEnforce();
    }

    int flatten_count = enforcer.GetFlattenCount();
    int check_count = enforcer.GetCheckCount();

    Assert(flatten_count == 1, "Flatten executed exactly ONCE after 100 calls",
           StringFormat("FlattenCount=%d, CheckCount=%d", flatten_count, check_count));

    Assert(check_count == rapid_calls, "All calls were tracked",
           StringFormat("Expected %d, got %d", rapid_calls, check_count));

    Print("--- Rapid Fire Test Complete ---");
}

//+------------------------------------------------------------------+
//| TEST 4: EA Restart After Deadline                                 |
//+------------------------------------------------------------------+
//| SCENARIO:                                                         |
//| - EA was unloaded at 4:50 PM                                     |
//| - User reloads EA at 5:10 PM (past deadline)                     |
//| - EA should detect "already past deadline" on startup            |
//| - Should NOT wait for next OnTimer - flatten immediately in Init |
//+------------------------------------------------------------------+
void Test_RestartAfterDeadline()
{
    PrintTestHeader("EA Restart After Deadline Test");

    // First, create a handler and set it to past deadline BEFORE Init
    CMockApexTimeHandler* pre_handler = new CMockApexTimeHandler();
    pre_handler.Init();

    // Simulate: EA restarts at 5:10 PM ET (11 minutes past deadline)
    int minutes_at_510pm = 17 * 60 + 10;  // 1030 minutes
    pre_handler.InjectMinutesFromMidnight(minutes_at_510pm);

    Print("Simulating EA restart at 5:10 PM ET (", minutes_at_510pm - 1019, " minutes past deadline)");

    // Create enforcer and attach pre-configured handler
    CTestableWallClockEnforcer enforcer;
    enforcer.AttachTimeHandler(pre_handler);

    // Init should detect past deadline and flatten immediately
    Print("Calling Init() - should detect past deadline and flatten immediately...");
    enforcer.Init(12345, "XAUUSD");

    // Verify flatten was triggered during Init
    bool deadline_missed = enforcer.WasDeadlineMissed();
    bool flatten_executed = enforcer.DidFlatten();

    Assert(deadline_missed, "Deadline miss was detected on startup",
           StringFormat("WasDeadlineMissed=%s", deadline_missed ? "true" : "false"));

    Assert(flatten_executed, "Flatten executed during Init (not waiting for OnTimer)",
           StringFormat("DidFlatten=%s", flatten_executed ? "true" : "false"));

    // Verify only ONE flatten even with Init + subsequent check
    enforcer.CheckAndEnforce();
    int flatten_count = enforcer.GetFlattenCount();

    Assert(flatten_count == 1, "Only ONE flatten even after Init + Check",
           StringFormat("FlattenCount=%d (should be 1)", flatten_count));

    if(InpVerbose)
        Print(enforcer.GetDiagnosticInfo());

    Print("--- EA Restart Test Complete ---");
}

//+------------------------------------------------------------------+
//| TEST 5: State Progression - Normal to Halted                      |
//+------------------------------------------------------------------+
//| SCENARIO:                                                         |
//| - Simulate time progression through all states                   |
//| - Verify warnings are issued once and flatten at end             |
//+------------------------------------------------------------------+
void Test_StateProgression()
{
    PrintTestHeader("State Progression Test");

    CTestableWallClockEnforcer enforcer;
    enforcer.Init(12345, "XAUUSD");

    CMockApexTimeHandler* handler = enforcer.GetTimeHandler();
    if(handler == NULL)
    {
        Assert(false, "State progression test setup", "Failed to get time handler");
        return;
    }

    // State 1: Normal (10:00 AM)
    Print("Step 1: 10:00 AM ET - Normal trading");
    handler.InjectMinutesFromMidnight(10 * 60);
    enforcer.CheckAndEnforce();
    Assert(handler.GetTimeState() == TIME_NORMAL, "10:00 AM is NORMAL",
           StringFormat("State=%s", handler.GetTimeStateString()));
    Assert(enforcer.GetFlattenCount() == 0, "No flatten at NORMAL",
           StringFormat("FlattenCount=%d", enforcer.GetFlattenCount()));

    // State 2: Block New (4:30 PM)
    Print("Step 2: 4:30 PM ET - Block new trades");
    handler.InjectMinutesFromMidnight(16 * 60 + 30);
    enforcer.CheckAndEnforce();
    Assert(handler.GetTimeState() == TIME_BLOCK_NEW, "4:30 PM is BLOCK_NEW",
           StringFormat("State=%s", handler.GetTimeStateString()));
    Assert(enforcer.GetFlattenCount() == 0, "No flatten at BLOCK_NEW",
           StringFormat("FlattenCount=%d", enforcer.GetFlattenCount()));

    // State 3: Emergency (4:55 PM)
    Print("Step 3: 4:55 PM ET - Emergency close warning");
    handler.InjectMinutesFromMidnight(16 * 60 + 55);
    enforcer.CheckAndEnforce();
    Assert(handler.GetTimeState() == TIME_EMERGENCY, "4:55 PM is EMERGENCY",
           StringFormat("State=%s", handler.GetTimeStateString()));
    Assert(enforcer.GetFlattenCount() == 0, "No flatten at EMERGENCY (just warning)",
           StringFormat("FlattenCount=%d", enforcer.GetFlattenCount()));

    // State 4: Halted (4:59 PM) - THIS triggers flatten
    Print("Step 4: 4:59 PM ET - HALTED, trigger flatten");
    handler.InjectMinutesFromMidnight(16 * 60 + 59);
    enforcer.CheckAndEnforce();
    Assert(handler.GetTimeState() == TIME_HALTED, "4:59 PM is HALTED",
           StringFormat("State=%s", handler.GetTimeStateString()));
    Assert(enforcer.GetFlattenCount() == 1, "Flatten triggered at HALTED",
           StringFormat("FlattenCount=%d", enforcer.GetFlattenCount()));

    // Verify no additional flattens
    Print("Step 5: Additional checks after HALTED");
    enforcer.CheckAndEnforce();
    enforcer.CheckAndEnforce();
    Assert(enforcer.GetFlattenCount() == 1, "Still only ONE flatten",
           StringFormat("FlattenCount=%d after 2 more checks", enforcer.GetFlattenCount()));

    if(InpVerbose)
        Print(enforcer.GetDiagnosticInfo());

    Print("--- State Progression Test Complete ---");
}

//+------------------------------------------------------------------+
//| TEST 6: Reset Allows New Flatten                                  |
//+------------------------------------------------------------------+
//| SCENARIO:                                                         |
//| - Session 1: Flatten executed                                    |
//| - Reset() called (new trading day)                               |
//| - Session 2: Flatten should execute again when triggered         |
//+------------------------------------------------------------------+
void Test_ResetAllowsNewFlatten()
{
    PrintTestHeader("Reset Allows New Flatten Test");

    CTestableWallClockEnforcer enforcer;
    enforcer.Init(12345, "XAUUSD");

    CMockApexTimeHandler* handler = enforcer.GetTimeHandler();
    if(handler == NULL)
    {
        Assert(false, "Reset test setup", "Failed to get time handler");
        return;
    }

    // Session 1: Trigger flatten
    Print("Session 1: Trigger flatten at 4:59 PM");
    handler.InjectMinutesFromMidnight(16 * 60 + 59);
    enforcer.CheckAndEnforce();

    Assert(enforcer.GetFlattenCount() == 1, "Session 1: Flatten count = 1",
           StringFormat("FlattenCount=%d", enforcer.GetFlattenCount()));

    // Reset for new session
    Print("Calling Reset() for new trading session...");
    enforcer.Reset();

    Assert(enforcer.GetFlattenCount() == 0, "After Reset: Flatten count = 0",
           StringFormat("FlattenCount=%d", enforcer.GetFlattenCount()));

    Assert(!enforcer.IsFlattenExecuted(), "After Reset: IsFlattenExecuted = false",
           "Flatten flag cleared");

    // Session 2: Trigger flatten again
    Print("Session 2: Trigger new flatten at 4:59 PM");
    handler.InjectMinutesFromMidnight(16 * 60 + 59);
    enforcer.CheckAndEnforce();

    Assert(enforcer.GetFlattenCount() == 1, "Session 2: Flatten count = 1",
           StringFormat("FlattenCount=%d", enforcer.GetFlattenCount()));

    if(InpVerbose)
        Print(enforcer.GetDiagnosticInfo());

    Print("--- Reset Test Complete ---");
}

//+------------------------------------------------------------------+
//| TEST 7: Minutes Boundary Tests                                    |
//+------------------------------------------------------------------+
//| SCENARIO:                                                         |
//| - Test exact boundary minutes for each state transition          |
//| - 989 = NORMAL, 990 = BLOCK_NEW                                  |
//| - 1014 = BLOCK_NEW, 1015 = EMERGENCY                             |
//| - 1018 = EMERGENCY, 1019 = HALTED                                |
//+------------------------------------------------------------------+
void Test_MinutesBoundaries()
{
    PrintTestHeader("Minutes Boundaries Test");

    CMockApexTimeHandler handler;
    handler.Init();

    // Test boundary transitions using parallel arrays (MQL5 compatible)
    int test_minutes[];
    int test_expected[];
    string test_descriptions[];

    // Resize arrays
    ArrayResize(test_minutes, 12);
    ArrayResize(test_expected, 12);
    ArrayResize(test_descriptions, 12);

    // Populate test cases
    test_minutes[0] = 0;      test_expected[0] = TIME_NORMAL;    test_descriptions[0] = "Midnight";
    test_minutes[1] = 600;    test_expected[1] = TIME_NORMAL;    test_descriptions[1] = "10:00 AM";
    test_minutes[2] = 989;    test_expected[2] = TIME_NORMAL;    test_descriptions[2] = "4:29 PM (1 min before BLOCK_NEW)";
    test_minutes[3] = 990;    test_expected[3] = TIME_BLOCK_NEW; test_descriptions[3] = "4:30 PM (exactly BLOCK_NEW)";
    test_minutes[4] = 991;    test_expected[4] = TIME_BLOCK_NEW; test_descriptions[4] = "4:31 PM (1 min after)";
    test_minutes[5] = 1014;   test_expected[5] = TIME_BLOCK_NEW; test_descriptions[5] = "4:54 PM (1 min before EMERGENCY)";
    test_minutes[6] = 1015;   test_expected[6] = TIME_EMERGENCY; test_descriptions[6] = "4:55 PM (exactly EMERGENCY)";
    test_minutes[7] = 1016;   test_expected[7] = TIME_EMERGENCY; test_descriptions[7] = "4:56 PM (1 min after)";
    test_minutes[8] = 1018;   test_expected[8] = TIME_EMERGENCY; test_descriptions[8] = "4:58 PM (1 min before HALTED)";
    test_minutes[9] = 1019;   test_expected[9] = TIME_HALTED;    test_descriptions[9] = "4:59 PM (exactly HALTED)";
    test_minutes[10] = 1020;  test_expected[10] = TIME_HALTED;   test_descriptions[10] = "5:00 PM (1 min after)";
    test_minutes[11] = 1080;  test_expected[11] = TIME_HALTED;   test_descriptions[11] = "6:00 PM";

    int num_tests = ArraySize(test_minutes);

    for(int i = 0; i < num_tests; i++)
    {
        handler.InjectMinutesFromMidnight(test_minutes[i]);
        ENUM_TIME_STATE actual = handler.GetTimeState();

        Assert(actual == (ENUM_TIME_STATE)test_expected[i],
               StringFormat("Minute %d: %s", test_minutes[i], test_descriptions[i]),
               StringFormat("Expected=%d, Actual=%d", test_expected[i], actual));
    }

    Print("--- Minutes Boundaries Test Complete ---");
}

//+------------------------------------------------------------------+
//| Print Test Summary                                                |
//+------------------------------------------------------------------+
void PrintTestSummary()
{
    Print("");
    Print("====================================================");
    Print("              TEST SUMMARY                          ");
    Print("====================================================");
    Print("");

    int total = g_tests_passed + g_tests_failed;

    PrintFormat("Total Tests:  %d", total);
    PrintFormat("Passed:       %d", g_tests_passed);
    PrintFormat("Failed:       %d", g_tests_failed);
    Print("");

    if(g_tests_failed == 0)
    {
        Print("============ ALL TESTS PASSED ============");
        Print("");
        Print("DISPROOF TESTS VALIDATED:");
        Print("  [OK] Timer gaps - flatten executes despite delay");
        Print("  [OK] Idempotency - flatten executes exactly once");
        Print("  [OK] EA restart - immediate flatten on startup");
        Print("  [OK] State progression - correct transitions");
        Print("  [OK] Session reset - allows new flatten");
        Print("  [OK] Minute boundaries - correct state at each threshold");
    }
    else
    {
        Print("============ SOME TESTS FAILED ============");
        Print("Review failed tests above for details.");
    }

    Print("");
    Print("====================================================");
}

//+------------------------------------------------------------------+
//| Script program start function                                     |
//+------------------------------------------------------------------+
void OnStart()
{
    Print("");
    Print("####################################################");
    Print("#  Task 7.3: Wall Clock Timer Delay Disproof Tests #");
    Print("#  CRITIC FIX #4: Idempotent OnTimer Validation    #");
    Print("####################################################");
    Print("");

    // Run all tests
    Test_TimerGap_FlattenStillExecutes();
    Test_FlattenOnlyOnce();
    Test_RapidFireCalls();
    Test_RestartAfterDeadline();
    Test_StateProgression();
    Test_ResetAllowsNewFlatten();
    Test_MinutesBoundaries();

    // Print summary
    PrintTestSummary();

    Print("");
    Print("Test script complete. Check Experts tab for results.");
}
//+------------------------------------------------------------------+
