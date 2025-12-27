# Disproof Tests Summary

**Version:** 1.0.0
**Created:** 2025-12-27
**Author:** FORGE-3 (Testing)
**Task:** 7.4 - MQL5 Migration MEGA-PLAN

---

## Overview

This document summarizes all disproof tests created during the MQL5 migration (Tasks 7.1-7.3). These tests follow the **falsification-first methodology** from CLAUDE.md: we design tests to **disprove** correctness rather than confirm it.

**Philosophy:** If a component can survive adversarial disproof tests, we have higher confidence in its correctness than from positive test cases alone.

---

## Test Script Index

| Script | Location | Purpose | Test Count |
|--------|----------|---------|------------|
| Test_DDTracker.mq5 | MQL5/Scripts/Tests/ | DD calculations | 50+ assertions |
| Test_TimeHandler.mq5 | MQL5/Scripts/Tests/ | DST algorithm | 45+ assertions |
| Test_WallClock.mq5 | MQL5/Scripts/Tests/ | Timer idempotency | 35+ assertions |
| TestGapCooldown.mq5 | MQL5/Scripts/ | Gap detection | 10 tests |

**Total:** ~140+ individual assertions across 4 test scripts

---

## 1. Test_DDTracker.mq5 (Task 7.1)

### Purpose
Validate CApexDDTracker implementation against CRITIC findings, specifically the HWM double-count bug that was the #1 issue.

### Test Suites

#### Suite 1: HWM Double-Count Prevention (CRITICAL)
**Disproof Target:** Verify that AccountEquity() is NOT double-counted with unrealized P/L.

| Test Case | Input | Expected | Disproof |
|-----------|-------|----------|----------|
| 1.1 Initial HWM | Init(50000) | HWM = 50000 | Would fail if HWM != equity |
| 1.2 No double-count | Update(51000) | HWM = 51000, NOT 52000 | Would fail if floating added twice |
| 1.3 HWM never decreases | Update(50000) after 51000 | HWM = 51000 | Would fail if HWM dropped |
| 1.4 HWM Trap Scenario | 50k->52k->49k | DD = 5.77%, TERMINATED | CLAUDE.md example |

**Key Assertion:**
```mql5
// CRITICAL: HWM should be 51000, NOT 52000 (no double-count)
Assert(tracker.GetHWM() == 51000.0, "HWM is 51000 (no double-count)");
```

#### Suite 2: Severity Thresholds
**Disproof Target:** Verify all 6 severity levels at exact boundary values.

| DD% | Expected Severity | Boundary |
|-----|-------------------|----------|
| 0-2.99% | DD_NORMAL | < 3.0% |
| 3.0-3.49% | DD_WARN | >= 3.0% |
| 3.5-3.99% | DD_CAUTION | >= 3.5% |
| 4.0-4.49% | DD_CRITICAL | >= 4.0% |
| 4.5-4.99% | DD_HALT | >= 4.5% |
| >= 5.0% | DD_TERMINATED | Apex limit |

**Test Cases:** 12 assertions testing exact boundary values.

#### Suite 3: Dynamic Daily Limit
**Disproof Target:** Verify formula: MIN(3.0%, remaining_buffer * 0.6)

| Trailing DD | Remaining Buffer | Expected Limit |
|-------------|------------------|----------------|
| 0% | 5.0% | 3.0% (capped) |
| 1% | 4.0% | 2.4% |
| 2% | 3.0% | 1.8% |
| 3% | 2.0% | 1.2% |
| 4% | 1.0% | 0.6% |
| 5% | 0.0% | 0.0% |

**Test Cases:** 7 assertions with worked examples.

#### Suite 4: Daily DD Thresholds
**Disproof Target:** Verify daily DD severity (from session start).

| Daily DD% | Expected Severity |
|-----------|-------------------|
| 0-1.49% | DD_NORMAL |
| 1.5-1.99% | DD_WARN |
| 2.0-2.49% | DD_CAUTION |
| 2.5-2.99% | DD_CRITICAL (REDUCE) |
| >= 3.0% | DD_HALT |

**Test Cases:** 8 assertions + 2 trading block verifications.

#### Suite 5: Combined DD Blocking
**Disproof Target:** Verify most restrictive action is used.

| Trailing | Daily | Expected |
|----------|-------|----------|
| 3% (OK) | 3% (HALT) | BLOCKED |
| 4% (HALT) | 2% (OK) | BLOCKED |
| 3% (OK) | 2% (OK) | ALLOWED |

#### Suite 6: Edge Cases
**Disproof Target:** Verify no crashes or incorrect values at extremes.

| Edge Case | Input | Verification |
|-----------|-------|--------------|
| Zero equity | equity = 0 | DD = 100%, no crash |
| Negative equity | equity = -10000 | DD clamped to <= 100% |
| Equity > HWM | rising equity | HWM updated correctly |
| Tiny DD | 99999.99/100000 | Precision preserved |
| Exact boundary | 97000/100000 | 3.0% = WARN (>=) |
| Multiple updates | sequence of changes | HWM monotonic |

---

## 2. Test_TimeHandler.mq5 (Task 7.2)

### Purpose
Validate CApexTimeHandler DST algorithm and time state transitions. DST bugs can cause incorrect time gates, leading to overnight positions (APEX KILLER).

### Test Suites

#### Suite 1: nth Sunday Algorithm
**Disproof Target:** Verify correct DST transition dates.

| Year | Month | nth | Expected Day |
|------|-------|-----|--------------|
| 2024 | March | 2 | 10 |
| 2024 | November | 1 | 3 |
| 2025 | March | 2 | 9 |
| 2025 | November | 1 | 2 |
| 2026 | March | 2 | 8 |
| 2026 | November | 1 | 1 |
| 2023 | March | 2 | 12 |
| 2023 | November | 1 | 5 |

**Algorithm:**
```mql5
int GetNthSundayOfMonth(int year, int month, int nth) {
    // Find first day of week for month
    // Calculate days to first Sunday
    // Add (nth - 1) * 7
}
```

#### Suite 2: DST Boundary Transitions (CRITICAL)
**Disproof Target:** Verify exact DST switch points.

| Test | UTC Time | Expected Zone | Expected Offset |
|------|----------|---------------|-----------------|
| Spring 2024 (before) | 2024-03-10 06:59 | EST | -5 |
| Spring 2024 (after) | 2024-03-10 07:01 | EDT | -4 |
| Fall 2024 (before) | 2024-11-03 05:59 | EDT | -4 |
| Fall 2024 (after) | 2024-11-03 06:01 | EST | -5 |
| Spring 2025 (before) | 2025-03-09 06:59 | EST | -5 |
| Spring 2025 (after) | 2025-03-09 07:01 | EDT | -4 |
| Fall 2025 (before) | 2025-11-02 05:59 | EDT | -4 |
| Fall 2025 (after) | 2025-11-02 06:01 | EST | -5 |
| Mid-summer | 2024-07-15 12:00 | EDT | -4 |
| Mid-winter | 2024-01-15 12:00 | EST | -5 |
| NYE 4:59 PM | 2024-12-31 21:59 | EST | -5 |
| July 4th 4:30 PM | 2024-07-04 20:30 | EDT | -4 |

**Key Transitions:**
- Spring forward: 2:00 AM EST -> 3:00 AM EDT (7:00 UTC)
- Fall back: 2:00 AM EDT -> 1:00 AM EST (6:00 UTC)

#### Suite 3: Time State Transitions
**Disproof Target:** Verify minute boundaries for Apex time gates.

| Minutes from Midnight | Expected State | ET Time |
|----------------------|----------------|---------|
| 0 | TIME_NORMAL | Midnight |
| 540 | TIME_NORMAL | 9:00 AM |
| 989 | TIME_NORMAL | 4:29 PM (last normal) |
| 990 | TIME_BLOCK_NEW | 4:30 PM (boundary) |
| 1014 | TIME_BLOCK_NEW | 4:54 PM (last block) |
| 1015 | TIME_EMERGENCY | 4:55 PM (boundary) |
| 1018 | TIME_EMERGENCY | 4:58 PM (last emergency) |
| 1019 | TIME_HALTED | 4:59 PM (boundary) |
| 1020 | TIME_HALTED | 5:00 PM |
| 1439 | TIME_HALTED | 11:59 PM |

#### Suite 4: CApexTimeHandler Integration
**Disproof Target:** Verify live handler produces consistent results.

| Test | Verification |
|------|--------------|
| Init() success | Returns true |
| GetCurrentUTC() valid | Returns datetime > 0 |
| GetCurrentET() offset | Differs by 4 or 5 hours from UTC |
| GetETOffsetHours() | Returns -4 or -5 |
| IsDST() consistency | Matches offset (-4 = DST, -5 = EST) |
| GetTimeState() valid | Returns valid enum |
| GetMinutesFromMidnight() | In range 0-1439 |
| Helper method consistency | All helpers match state |
| GetMinutesToClose() | Non-negative |
| GetDiagnosticInfo() | Non-empty string |

#### Suite 5: Edge Cases
**Disproof Target:** Verify no bugs at unusual times.

| Edge Case | Input | Verification |
|-----------|-------|--------------|
| Year boundary | Dec 31 -> Jan 1 | Both EST |
| Leap year | Feb 29, 2024 | No DST (February) |
| Exact DST start | 2024-03-10 07:00 | EDT |
| Before DST start | 2024-03-10 06:00 | EST |
| Minute threshold | 989 vs 990 | NORMAL vs BLOCK_NEW |
| Maximum minutes | 1439 | HALTED |
| Future year | 2030 | Summer=EDT, Winter=EST |

---

## 3. Test_WallClock.mq5 (Task 7.3)

### Purpose
Validate CWallClockEnforcer idempotent flatten behavior. Addresses CRITIC FIX #4: OnTimer can be delayed by minutes under CPU load, but flatten MUST still execute when it fires.

### Test Suites

#### Suite 1: Timer Gap - Flatten Still Executes
**Disproof Target:** OnTimer delayed by 6+ minutes still triggers flatten.

**Scenario:**
```
Hard deadline: 4:59 PM ET
OnTimer expected: 4:58, 4:59, 5:00 PM
OnTimer actual: 5:05 PM (CPU delay!)
Result: MUST flatten immediately when OnTimer finally fires
```

**Test Flow:**
1. Inject time = 5:05 PM (1025 minutes, 6 minutes past deadline)
2. Verify state = TIME_HALTED
3. Call CheckAndEnforce()
4. Assert: FlattenExecuted = true, FlattenCount = 1

#### Suite 2: Idempotent Flatten - Only Once
**Disproof Target:** Flatten executes exactly ONCE despite multiple calls.

**Scenario:**
```
4:59 PM: CheckAndEnforce() -> Flatten #1
5:00 PM: CheckAndEnforce() -> NO FLATTEN (already done!)
5:01 PM: CheckAndEnforce() -> NO FLATTEN
5:02 PM: CheckAndEnforce() -> NO FLATTEN
```

**Test Flow:**
1. First call at 4:59 PM -> FlattenCount = 1
2. Three more calls at 5:00, 5:01, 5:02 PM
3. Assert: FlattenCount still = 1 (idempotent)

#### Suite 3: Rapid Fire Calls
**Disproof Target:** 100 rapid calls still result in exactly ONE flatten.

**Test Flow:**
1. Set time = 5:00 PM (past deadline)
2. Execute 100 CheckAndEnforce() calls
3. Assert: FlattenCount = 1, CheckCount = 100

#### Suite 4: EA Restart After Deadline
**Disproof Target:** EA reloaded after deadline triggers immediate flatten in Init(), not waiting for OnTimer.

**Scenario:**
```
4:50 PM: EA unloaded
5:10 PM: User reloads EA
Init(): MUST detect past deadline and flatten immediately
```

**Test Flow:**
1. Pre-configure handler with time = 5:10 PM
2. Create enforcer and attach handler
3. Call Init()
4. Assert: WasDeadlineMissed = true, DidFlatten = true
5. Additional CheckAndEnforce() -> FlattenCount still = 1

#### Suite 5: State Progression
**Disproof Target:** Verify correct state machine transitions.

| Step | Time | State | Flatten? |
|------|------|-------|----------|
| 1 | 10:00 AM | TIME_NORMAL | No |
| 2 | 4:30 PM | TIME_BLOCK_NEW | No |
| 3 | 4:55 PM | TIME_EMERGENCY | No |
| 4 | 4:59 PM | TIME_HALTED | YES |
| 5 | After | TIME_HALTED | No more |

#### Suite 6: Reset Allows New Flatten
**Disproof Target:** New trading day (Reset) clears state for new flatten.

**Test Flow:**
1. Session 1: Trigger flatten -> FlattenCount = 1
2. Call Reset() (new trading day)
3. Assert: FlattenCount = 0, IsFlattenExecuted = false
4. Session 2: Trigger flatten -> FlattenCount = 1

#### Suite 7: Minutes Boundaries
**Disproof Target:** Verify exact minute thresholds.

| Minutes | Expected State |
|---------|----------------|
| 0 | TIME_NORMAL |
| 600 | TIME_NORMAL |
| 989 | TIME_NORMAL |
| 990 | TIME_BLOCK_NEW |
| 991 | TIME_BLOCK_NEW |
| 1014 | TIME_BLOCK_NEW |
| 1015 | TIME_EMERGENCY |
| 1016 | TIME_EMERGENCY |
| 1018 | TIME_EMERGENCY |
| 1019 | TIME_HALTED |
| 1020 | TIME_HALTED |
| 1080 | TIME_HALTED |

---

## 4. TestGapCooldown.mq5 (Task 3.3)

### Purpose
Validate CGapCooldown gap detection and cooldown enforcement.

### Test Cases

| Test | Purpose | Verification |
|------|---------|--------------|
| 1. Initialization | Init with threshold/duration | Returns true |
| 2. Initial State | Fresh instance | IsBlocked = false, Reason = GATE_OK |
| 3. Normal Progression | 1-min bars | No gap detected |
| 4. Gap Detection | 60-min gap (> 30 threshold) | GapsDetected >= 1 |
| 5. Gate Interface | IRiskGate methods | GetGateName(), GetReasonText() work |
| 6. ForceCooldown | Manual trigger | IsBlocked = true, Reason = GATE_GAP_COOLDOWN |
| 7. ClearCooldown | Manual clear | IsBlocked = false |
| 8. Configuration | Setters | GetGapThreshold(), GetCooldownDuration() |
| 9. Weekend Gap | Fri 5PM -> Sun 6PM | Large gap detected (~2940 min) |
| 10. Diagnostic | Status output | PrintStatus(), GetDiagnosticInfo() |

---

## CRITIC Issues Addressed

| CRITIC Issue | Test Coverage |
|--------------|---------------|
| #1 HWM Double-Count | Test_DDTracker Suite 1 |
| #2 Severity Boundaries | Test_DDTracker Suite 2 |
| #3 DST Algorithm | Test_TimeHandler Suites 1-2 |
| #4 Timer Gap Idempotency | Test_WallClock Suites 1-3 |
| #5 EA Restart | Test_WallClock Suite 4 |
| #6 Gap Cooldown | TestGapCooldown all |

---

## Running All Tests

### Quick Validation (Recommended Order)
1. **Test_DDTracker.mq5** - Most critical (HWM bug)
2. **Test_TimeHandler.mq5** - DST validation
3. **Test_WallClock.mq5** - Idempotency
4. **TestGapCooldown.mq5** - Gap handling

### Expected Results
All scripts must output:
```
*** ALL TESTS PASSED ***
```
or equivalent success message.

### Failure Protocol
1. Document exact failure in journal
2. Screenshot the Experts tab output
3. Create issue in BUGFIX_LOG.md
4. Fix and re-run ONLY the failed test first
5. Then re-run all tests to verify no regression

---

## Future Test Additions

### Recommended Additions
1. **Test_UnifiedRiskPolicy.mq5** - Combined gate logic
2. **Test_VirtualGate.mq5** - Virtual SL/TP
3. **Test_SpreadMonitor.mq5** - Spread blocking
4. **Test_Integration.mq5** - Full EA initialization

### Test Pattern Template
```mql5
//+------------------------------------------------------------------+
//| DISPROOF TEST: [Component] - [What We're Disproving]             |
//|                                                                   |
//| SCENARIO:                                                         |
//|   [Describe the failure mode we're testing for]                  |
//|                                                                   |
//| DISPROOF:                                                         |
//|   If test fails, [specific bug] exists                           |
//+------------------------------------------------------------------+
void Test_[ComponentName]()
{
    // 1. Setup test conditions
    // 2. Inject adversarial inputs
    // 3. Assert expected behavior
    // 4. Log pass/fail with details
}
```

---

*End of Disproof Tests Summary*
