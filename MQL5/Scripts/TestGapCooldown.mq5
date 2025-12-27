//+------------------------------------------------------------------+
//|                                              TestGapCooldown.mq5 |
//|                     EA_SCALPER_XAUUSD - Apex Compliant Trading   |
//|                     Test script for CGapCooldown (Task 3.3)      |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property script_show_inputs

#include <EA_SCALPER\Risk\CGapCooldown.mqh>

input int InpGapThreshold = 30;   // Gap threshold (minutes)
input int InpCooldownDuration = 15; // Cooldown duration (minutes)

//+------------------------------------------------------------------+
//| Script program start function                                     |
//+------------------------------------------------------------------+
void OnStart()
{
    Print("========================================================");
    Print("   CGapCooldown - TEST SCRIPT");
    Print("========================================================");
    Print("");

    CGapCooldown cooldown;

    //--- Test 1: Initialization
    Print("TEST 1: Initialization");
    if(!cooldown.Init(InpGapThreshold, InpCooldownDuration, true))
    {
        Print("  FAILED: Init returned false");
        return;
    }
    Print("  PASSED: Initialized with threshold=", InpGapThreshold, ", cooldown=", InpCooldownDuration);
    Print("");

    //--- Test 2: Initial state
    Print("TEST 2: Initial State");
    if(cooldown.IsBlocked())
    {
        Print("  FAILED: IsBlocked() should be false initially");
        return;
    }
    if(cooldown.GetReason() != GATE_OK)
    {
        Print("  FAILED: GetReason() should be GATE_OK initially");
        return;
    }
    Print("  PASSED: Initial state is unblocked");
    Print("");

    //--- Test 3: Normal bar progression (no gap)
    Print("TEST 3: Normal Bar Progression");
    datetime base_time = D'2024.01.15 10:00:00';
    cooldown.OnNewBar(base_time);
    cooldown.OnNewBar(base_time + 60);   // 1 min later
    cooldown.OnNewBar(base_time + 120);  // 2 min later
    cooldown.OnNewBar(base_time + 180);  // 3 min later

    if(cooldown.IsBlocked())
    {
        Print("  FAILED: Should not be blocked after normal progression");
        return;
    }
    Print("  PASSED: No gap detected in normal progression");
    Print("");

    //--- Test 4: Gap detection
    Print("TEST 4: Gap Detection");
    // Reset for clean test
    cooldown.Reset();
    cooldown.OnNewBar(D'2024.01.15 10:00:00');  // First bar
    cooldown.OnNewBar(D'2024.01.15 11:00:00');  // 60 min gap (> 30 min threshold)

    // Note: The cooldown check uses TimeGMT() which is current time,
    // so we need to use ForceCooldown for testing or check the detection stats
    if(cooldown.GetGapsDetected() < 1)
    {
        Print("  FAILED: Gap should have been detected");
        return;
    }
    Print("  PASSED: Gap detected. Gaps count: ", cooldown.GetGapsDetected());
    Print("  Last gap: ", cooldown.GetLastGapMinutes(), " minutes");
    Print("");

    //--- Test 5: Gate interface
    Print("TEST 5: Gate Interface (IRiskGate)");
    Print("  GetGateName(): ", cooldown.GetGateName());
    Print("  GetReasonText(): ", cooldown.GetReasonText());
    Print("  GateReasonToString(): ", GateReasonToString(cooldown.GetReason()));
    Print("  PASSED: Interface methods work");
    Print("");

    //--- Test 6: ForceCooldown
    Print("TEST 6: Force Cooldown");
    cooldown.ClearCooldown();  // Clear any existing
    cooldown.ForceCooldown(1, "test");  // 1 minute forced cooldown

    if(!cooldown.IsBlocked())
    {
        Print("  FAILED: Should be blocked after ForceCooldown");
        return;
    }
    if(cooldown.GetReason() != GATE_GAP_COOLDOWN)
    {
        Print("  FAILED: Reason should be GATE_GAP_COOLDOWN");
        return;
    }
    Print("  PASSED: ForceCooldown works");
    Print("  Remaining: ", cooldown.GetRemainingCooldownSeconds(), " seconds");
    Print("");

    //--- Test 7: ClearCooldown
    Print("TEST 7: Clear Cooldown");
    cooldown.ClearCooldown();
    if(cooldown.IsBlocked())
    {
        Print("  FAILED: Should not be blocked after ClearCooldown");
        return;
    }
    Print("  PASSED: ClearCooldown works");
    Print("");

    //--- Test 8: Configuration setters
    Print("TEST 8: Configuration");
    cooldown.SetGapThreshold(45);
    cooldown.SetCooldownDuration(20);
    if(cooldown.GetGapThreshold() != 45)
    {
        Print("  FAILED: Gap threshold not set correctly");
        return;
    }
    if(cooldown.GetCooldownDuration() != 20)
    {
        Print("  FAILED: Cooldown duration not set correctly");
        return;
    }
    Print("  PASSED: Configuration setters work");
    Print("");

    //--- Test 9: Weekend gap simulation
    Print("TEST 9: Weekend Gap Simulation");
    CGapCooldown weekend_test;
    weekend_test.Init(30, 15, false);  // Quiet mode

    // Friday 5PM -> Sunday 6PM (49 hours = 2940 minutes)
    datetime friday_close = D'2024.01.12 22:00:00';  // Friday 5PM ET in UTC
    datetime sunday_open = D'2024.01.14 23:00:00';   // Sunday 6PM ET in UTC

    weekend_test.OnNewBar(friday_close);
    weekend_test.OnNewBar(sunday_open);

    if(weekend_test.GetGapsDetected() != 1)
    {
        Print("  FAILED: Weekend gap not detected");
        return;
    }
    int gap_min = weekend_test.GetLastGapMinutes();
    Print("  PASSED: Weekend gap detected: ", gap_min, " minutes (", gap_min/60, " hours)");
    Print("");

    //--- Print diagnostic info
    Print("TEST 10: Diagnostic Output");
    cooldown.PrintStatus();
    Print(cooldown.GetDiagnosticInfo());
    Print("");

    //--- Summary
    Print("========================================================");
    Print("   ALL TESTS PASSED!");
    Print("========================================================");
    Print("");
    Print("CGapCooldown is ready for use.");
    Print("Integration: Call OnNewBar(bar_time) on each new bar,");
    Print("             then check IsBlocked() before entries.");
}
//+------------------------------------------------------------------+
