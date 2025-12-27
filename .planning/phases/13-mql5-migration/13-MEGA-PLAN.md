# MEGA-PLAN: Migração Completa Python/Nautilus → MQL5/MT5

**Date:** 2025-12-27
**Owner:** Franco
**Target:** Investidor Árabe - EA completo com indicadores visuais
**Scope:** Migrar toda lógica avançada do Python para MQL5
**CRITIC Review:** v2 - Issues críticos corrigidos

---

## CRITIC FIXES INCORPORATED (v2)

### Issue 1: HWM Double-Count (FIXED)
**Problema:** Passar `AccountEquity()` + `unrealized_pnl` duplica o floating P/L
**Solução:** Usar APENAS `AccountEquity()` (já inclui floating) OU calcular floating manualmente com BID/ASK

### Issue 2: Time Base Indefinido (FIXED)
**Problema:** `TimeCurrent()` vs `TimeGMT()` vs `TimeLocal()` não especificado
**Solução:** Usar `TimeGMT()` como base única, converter para ET

### Issue 3: DST Algorithm Vago (FIXED)
**Problema:** Algoritmo hand-wavy, pode errar na boundary
**Solução:** Algoritmo determinístico com nth-Sunday calculation + test vectors

### Issue 4: OnTimer Não Garantido (FIXED)
**Problema:** Sob carga, OnTimer pode atrasar
**Solução:** Design idempotente: `if now >= deadline then flatten` (catch-up logic)

### Issue 5: Struct com Dynamic Array (FIXED)
**Problema:** `string reasons[]` é MQL5 gotcha
**Solução:** Usar `ENUM_GATE_REASON` bitmask + array fixo `string reasons[8]`

---

## MANDATORY EXECUTION PROTOCOL

**ESTE PROTOCOLO DEVE SER SEGUIDO EM TODAS AS AÇÕES:**

### 1. Multi-Agent Paralelo (3-4 FORGEs)
```
┌─────────────────────────────────────────────────────────────┐
│  ORQUESTRADOR spawna 3-4 FORGEs em paralelo:                │
│                                                             │
│  FORGE-1 ──► Risk/DD components                             │
│  FORGE-2 ──► Time handling/Gates                            │
│  FORGE-3 ──► Indicators (OB/FVG/Sweep)                      │
│  FORGE-4 ──► Visual/HUD components                          │
│                                                             │
│  Cada FORGE: executa → CRITIC review → fix → próxima task   │
└─────────────────────────────────────────────────────────────┘
```

### 2. Autonomous Loop (CRITIC até GO)
```
Executar task → CRITIC review (opus) → GO?
                      ↓ NO
                Fix automático → CRITIC review → loop (max 3x)
                      ↓ ainda NO-GO após 3x
                Perguntar usuário
```

### 3. Compilação Obrigatória Após Cada Mudança
```bash
# OBRIGATÓRIO após qualquer mudança de código MQL5
# Verificar:
# - Código compila sem erros
# - Sem warnings críticos
# - Includes resolvidos corretamente
```

### 4. Anti-Hallucination MQL5
```bash
# ANTES de escrever código MQL5:
# 1. Verificar sintaxe MQL5 (não é C++ puro!)
# 2. Verificar funções nativas: iATR, iMA, OrderSend, etc.
# 3. Consultar MQL5 Reference se necessário
# 4. NUNCA inventar APIs - MQL5 tem sintaxe específica

# Diferenças críticas MQL5 vs C++:
# - Arrays: ArrayResize, ArraySetAsSeries
# - Strings: StringFormat, StringConcatenate
# - Time: TimeToStruct, StructToTime, TimeGMT (NOT TimeCurrent!)
# - Trade: CTrade class ou OrderSend direto
```

### 5. Falsification Tests ANTES de Implementar
```bash
# CRÍTICO: Rodar mini-testes de disproof antes de construir:
# 1. "HWM double-count disproof" - verificar que equity não infla HWM 2x
# 2. "DST boundary disproof" - testar 10 UTC timestamps nas transições
# 3. "Timer delay disproof" - simular missed ticks, confirmar flatten
```

---

## OVERVIEW: O Que Migrar

### Delta Report (Python tem, MQL5 falta):

| Componente | Prioridade | Complexidade | Paralelo? |
|------------|------------|--------------|-----------|
| VirtualGate | P0 | MEDIUM | FORGE-2 |
| UnifiedRiskPolicy | P0 | HIGH | FORGE-1 |
| DST-safe ET handling | P0 | HIGH | FORGE-2 |
| Wall-clock enforcement | P0 | HIGH | FORGE-2 |
| Apex DD taxonomy (6-level) | P0 | MEDIUM | FORGE-1 |
| SpreadMonitor | P0 | MEDIUM | FORGE-1 |
| Gap cooldown | P1 | LOW-MEDIUM | FORGE-2 |
| Dynamic daily limit | P1 | MEDIUM | FORGE-1 |
| ML Ensemble (LGB+XGB+RF) | P2 | HIGH | FORGE-3 |
| Calibration (Isotonic/Platt) | P2 | HIGH | FORGE-3 |
| Visual indicators update | P1 | MEDIUM | FORGE-4 |

---

## PHASE 1: Foundation & Build System
**Objetivo:** Garantir que o código MQL5 existente compila e está organizado

<tasks>

<task type="auto" agent="FORGE-1">
  <name>Task 1.1: Audit existing MQL5 structure</name>
  <files>
    MQL5/Experts/EA_SCALPER_XAUUSD.mq5
    MQL5/Include/EA_SCALPER/**/*.mqh
    MQL5/Indicators/SMC_Visual.mq5
  </files>
  <action>
    Auditar estrutura atual:
    1. Listar todos os arquivos .mq5 e .mqh
    2. Verificar includes e dependências
    3. Identificar código duplicado ou obsoleto
    4. Criar mapa de dependências entre módulos
    5. Verificar account mode handling (netting vs hedging)

    Output: relatório em .planning/phases/13-mql5-migration/AUDIT_REPORT.md
  </action>
  <verify>Relatório criado com lista completa de arquivos e dependências</verify>
  <done>Mapa de dependências documentado, arquivos obsoletos identificados</done>
</task>

<task type="auto" agent="FORGE-2">
  <name>Task 1.2: Create version constants, enums and interfaces</name>
  <files>
    MQL5/Include/EA_SCALPER/Core/Version.mqh (NEW)
    MQL5/Include/EA_SCALPER/Core/Definitions.mqh (UPDATE)
    MQL5/Include/EA_SCALPER/Core/IRiskGate.mqh (NEW)
  </files>
  <action>
    Criar sistema de versionamento e interfaces:

    1. Version.mqh:
    ```cpp
    #define EA_VERSION "4.0.0"
    #define BUILD_DATE __DATE__
    #define MIGRATION_SOURCE "Python/Nautilus v2.2"
    #define APEX_COMPLIANT true
    ```

    2. Definitions.mqh - enums corrigidos (CRITIC fix #5):
    ```cpp
    enum ENUM_DD_SEVERITY {
        DD_NORMAL,      // 0-3%
        DD_WARN,        // 3%
        DD_CAUTION,     // 3.5%
        DD_CRITICAL,    // 4%
        DD_HALT,        // 4.5%
        DD_TERMINATED   // 5%
    };

    enum ENUM_TIME_STATE {
        TIME_NORMAL,
        TIME_BLOCK_NEW,      // After 4:30 PM ET
        TIME_EMERGENCY,      // After 4:55 PM ET
        TIME_HALTED          // After 4:59 PM ET
    };

    // CRITIC FIX: Use bitmask instead of dynamic array
    enum ENUM_GATE_REASON {
        GATE_OK           = 0,
        GATE_TIME         = 1,
        GATE_DD_TRAILING  = 2,
        GATE_DD_DAILY     = 4,
        GATE_SPREAD       = 8,
        GATE_VIRTUAL      = 16,
        GATE_GAP_COOLDOWN = 32,
        GATE_NEWS         = 64,
        GATE_SESSION      = 128
    };
    ```

    3. IRiskGate.mqh - interface para gates:
    ```cpp
    class IRiskGate {
    public:
        virtual bool IsBlocked() = 0;
        virtual ENUM_GATE_REASON GetReason() = 0;
        virtual string GetReasonText() = 0;
    };
    ```
  </action>
  <verify>Arquivos criados, enums definidos corretamente, interface compila</verify>
  <done>Sistema de versão, enums e interface base prontos</done>
</task>

</tasks>

---

## PHASE 2: Apex Risk Core (P0 - CRÍTICO)
**Objetivo:** Implementar DD taxonomy + time handling com paridade Python
**Execução:** FORGE-1 e FORGE-2 em PARALELO

<tasks>

<!-- FORGE-1: Risk/DD Components -->

<task type="auto" agent="FORGE-1">
  <name>Task 2.1: Implement Apex DD Tracker (CRITIC FIXED)</name>
  <files>
    MQL5/Include/EA_SCALPER/Risk/CApexDDTracker.mqh (NEW)
  </files>
  <action>
    Criar CApexDDTracker com CRITIC fixes incorporados:

    ```cpp
    // CRITIC FIX #1: Use ONLY AccountEquity() - it already includes floating!
    // DO NOT add unrealized_pnl separately - that would double-count!

    class CApexDDTracker {
    private:
        double m_hwm;                    // High-water mark (never decreases)
        double m_session_start_equity;   // Equity at session start (6 PM ET)
        double m_current_equity;         // Current equity
        ENUM_DD_SEVERITY m_trailing_severity;
        ENUM_DD_SEVERITY m_daily_severity;

    public:
        void Init(double starting_equity) {
            m_hwm = starting_equity;
            m_session_start_equity = starting_equity;
            m_current_equity = starting_equity;
        }

        // CRITIC FIX: Single input - equity already includes floating
        void Update() {
            m_current_equity = AccountInfoDouble(ACCOUNT_EQUITY);

            // HWM only increases, never decreases
            if(m_current_equity > m_hwm) {
                m_hwm = m_current_equity;
            }

            // Validate
            assert(m_hwm >= 0);
            assert(m_current_equity >= 0);
        }

        double GetTrailingDDPercent() {
            if(m_hwm <= 0) return 0;
            // Formula: (HWM - current) / HWM * 100
            // Example: hwm=52000, equity=50000 → (52000-50000)/52000*100 = 3.85%
            double dd = (m_hwm - m_current_equity) / m_hwm * 100.0;
            assert(dd >= 0 && dd <= 100);
            return dd;
        }

        double GetDailyDDPercent() {
            if(m_session_start_equity <= 0) return 0;
            double dd = (m_session_start_equity - m_current_equity) / m_session_start_equity * 100.0;
            return MathMax(0, dd);  // Can be negative (profit)
        }

        ENUM_DD_SEVERITY GetTrailingSeverity() {
            double dd = GetTrailingDDPercent();
            if(dd >= 5.0) return DD_TERMINATED;
            if(dd >= 4.5) return DD_HALT;
            if(dd >= 4.0) return DD_CRITICAL;
            if(dd >= 3.5) return DD_CAUTION;
            if(dd >= 3.0) return DD_WARN;
            return DD_NORMAL;
        }

        bool MustHalt()    { return GetTrailingDDPercent() >= 4.0 || GetDailyDDPercent() >= 3.0; }
        bool MustFlatten() { return GetTrailingDDPercent() >= 4.5 || GetDailyDDPercent() >= 3.0; }
    };
    ```

    Taxonomia DD (CLAUDE.md authoritative):
    - Trailing: WARN 3.0%, CAUTION 3.5%, CRITICAL 4.0%, HALT 4.5%, TERMINATED 5.0%
    - Daily: WARN 1.5%, CAUTION 2.0%, REDUCE 2.5%, HALT 3.0%
  </action>
  <verify>
    DISPROOF TEST: Feed equity=51000 (includes $1000 floating).
    Verify HWM = 51000 (NOT 52000 from double-counting).
    All severity thresholds correct.
  </verify>
  <done>CApexDDTracker sem double-count, com assertions</done>
</task>

<task type="auto" agent="FORGE-1">
  <name>Task 2.2: Implement SpreadMonitor (CRITIC WARNING)</name>
  <files>
    MQL5/Include/EA_SCALPER/Safety/CSpreadMonitor.mqh (UPDATE or NEW)
  </files>
  <action>
    Verificar/criar SpreadMonitor para stress conditions:

    ```cpp
    class CSpreadMonitor : public IRiskGate {
    private:
        double m_max_spread_points;   // Default 80
        double m_current_spread;
        double m_median_spread;
        double m_zscore;

    public:
        void Update() {
            m_current_spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
            // Calculate z-score vs median
        }

        bool IsBlocked() override {
            return m_current_spread > m_max_spread_points;
        }

        ENUM_GATE_REASON GetReason() override {
            return GATE_SPREAD;
        }
    };
    ```

    CRÍTICO: Under stress (spread 3x normal), block entries to preserve DD buffer.
  </action>
  <verify>SpreadMonitor blocks when spread exceeds threshold</verify>
  <done>SpreadMonitor implemented and integrated</done>
</task>

<task type="auto" agent="FORGE-1">
  <name>Task 2.3: Implement Dynamic Daily Limit</name>
  <files>
    MQL5/Include/EA_SCALPER/Risk/CApexDDTracker.mqh (UPDATE)
  </files>
  <action>
    Adicionar dynamic daily limit:

    ```cpp
    // Dynamic Max Daily DD% = MIN(3%, Remaining_Buffer% × 0.6)
    double GetDynamicDailyLimit() {
        double remaining_buffer = 5.0 - GetTrailingDDPercent();
        double dynamic = remaining_buffer * 0.6;
        // Example: trailing=2% → buffer=3% → dynamic=1.8%
        // Example: trailing=0% → buffer=5% → dynamic=3.0% (capped)
        return MathMin(3.0, MathMax(0.0, dynamic));
    }
    ```
  </action>
  <verify>Dynamic limit calculation matches Python</verify>
  <done>Dynamic daily limit implemented</done>
</task>

<!-- FORGE-2: Time Handling Components -->

<task type="auto" agent="FORGE-2">
  <name>Task 2.4: Implement DST-safe ET Time Handler (CRITIC FIXED)</name>
  <files>
    MQL5/Include/EA_SCALPER/Risk/CApexTimeHandler.mqh (NEW)
  </files>
  <action>
    Criar CApexTimeHandler com CRITIC fixes:

    ```cpp
    // CRITIC FIX #2: Use TimeGMT() as ONLY time base
    // CRITIC FIX #3: Deterministic DST algorithm

    class CApexTimeHandler {
    private:
        int m_et_offset;  // -5 (EST) or -4 (EDT)

        // Deterministic nth-Sunday calculation
        int GetNthSundayOfMonth(int year, int month, int nth) {
            MqlDateTime mdt = {year, month, 1, 0, 0, 0, 0};
            datetime first = StructToTime(mdt);
            TimeToStruct(first, mdt);

            int first_dow = mdt.day_of_week;  // 0=Sunday
            int days_to_first_sunday = (7 - first_dow) % 7;
            int day = 1 + days_to_first_sunday + (nth - 1) * 7;
            return day;
        }

        bool IsDST(datetime utc_time) {
            MqlDateTime mdt;
            TimeToStruct(utc_time, mdt);

            int year = mdt.year;
            int month = mdt.mon;
            int day = mdt.day;
            int hour = mdt.hour;

            // US DST: 2nd Sunday March 2:00 AM → 1st Sunday November 2:00 AM
            int dst_start_day = GetNthSundayOfMonth(year, 3, 2);  // March 2nd Sunday
            int dst_end_day = GetNthSundayOfMonth(year, 11, 1);   // November 1st Sunday

            // Before March
            if(month < 3) return false;
            // After November
            if(month > 11) return false;
            // April to October = always DST
            if(month > 3 && month < 11) return true;

            // March - check exact day/hour
            if(month == 3) {
                if(day < dst_start_day) return false;
                if(day > dst_start_day) return true;
                // Exact day - check hour (2:00 AM local = 7:00 UTC)
                return hour >= 7;
            }

            // November - check exact day/hour
            if(month == 11) {
                if(day < dst_end_day) return true;
                if(day > dst_end_day) return false;
                // Exact day - check hour (2:00 AM local = 6:00 UTC during DST)
                return hour < 6;
            }

            return false;
        }

    public:
        void Init() {
            UpdateDSTStatus();
        }

        void UpdateDSTStatus() {
            // CRITIC FIX: Use TimeGMT() not TimeCurrent()
            datetime utc = TimeGMT();
            m_et_offset = IsDST(utc) ? -4 : -5;
        }

        datetime GetCurrentET() {
            return TimeGMT() + m_et_offset * 3600;
        }

        int GetETHour() {
            MqlDateTime mdt;
            TimeToStruct(GetCurrentET(), mdt);
            return mdt.hour;
        }

        int GetETMinute() {
            MqlDateTime mdt;
            TimeToStruct(GetCurrentET(), mdt);
            return mdt.min;
        }

        ENUM_TIME_STATE GetTimeState() {
            int h = GetETHour();
            int m = GetETMinute();
            int total_min = h * 60 + m;

            // 4:59 PM = 16:59 = 1019 minutes
            if(total_min >= 1019) return TIME_HALTED;
            // 4:55 PM = 16:55 = 1015 minutes
            if(total_min >= 1015) return TIME_EMERGENCY;
            // 4:30 PM = 16:30 = 990 minutes
            if(total_min >= 990) return TIME_BLOCK_NEW;

            return TIME_NORMAL;
        }

        bool IsAfterBlockNewTrades() { return GetTimeState() >= TIME_BLOCK_NEW; }
        bool IsAfterEmergencyClose() { return GetTimeState() >= TIME_EMERGENCY; }
        bool IsAfterHardClose()      { return GetTimeState() >= TIME_HALTED; }
    };
    ```
  </action>
  <verify>
    DISPROOF TEST - Test these UTC timestamps:
    - 2024-03-10 06:59 UTC → EST (offset -5)
    - 2024-03-10 07:01 UTC → EDT (offset -4)
    - 2024-11-03 05:59 UTC → EDT (offset -4)
    - 2024-11-03 06:01 UTC → EST (offset -5)
    - 2025 dates also work
  </verify>
  <done>CApexTimeHandler com DST determinístico usando TimeGMT()</done>
</task>

<task type="auto" agent="FORGE-2">
  <name>Task 2.5: Implement Wall-Clock Enforcement (CRITIC FIXED)</name>
  <files>
    MQL5/Include/EA_SCALPER/Risk/CWallClockEnforcer.mqh (NEW)
  </files>
  <action>
    Criar CWallClockEnforcer com CRITIC fixes:

    ```cpp
    // CRITIC FIX #4: Idempotent design - works even if OnTimer is delayed

    class CWallClockEnforcer {
    private:
        CApexTimeHandler* m_time_handler;
        datetime m_last_check_time;
        datetime m_last_tick_time;
        bool m_flatten_executed;

        // Absolute deadlines in ET (computed once per session)
        datetime m_block_deadline_et;     // 4:30 PM ET
        datetime m_emergency_deadline_et; // 4:55 PM ET
        datetime m_hard_deadline_et;      // 4:59 PM ET

    public:
        void Init(CApexTimeHandler* handler) {
            m_time_handler = handler;
            m_flatten_executed = false;
            ComputeDeadlines();
        }

        void ComputeDeadlines() {
            // Compute today's deadlines in ET
            datetime now_et = m_time_handler.GetCurrentET();
            MqlDateTime mdt;
            TimeToStruct(now_et, mdt);
            mdt.hour = 16; mdt.min = 30; mdt.sec = 0;
            m_block_deadline_et = StructToTime(mdt);
            mdt.min = 55;
            m_emergency_deadline_et = StructToTime(mdt);
            mdt.min = 59;
            m_hard_deadline_et = StructToTime(mdt);
        }

        void OnTick() {
            m_last_tick_time = TimeGMT();
            CheckAndEnforce();
        }

        void OnTimer() {
            CheckAndEnforce();
        }

        void CheckAndEnforce() {
            datetime now_et = m_time_handler.GetCurrentET();
            m_last_check_time = now_et;

            // CRITIC FIX: Idempotent - if past deadline, flatten NOW
            // Works even if OnTimer was delayed by minutes
            if(now_et >= m_hard_deadline_et && !m_flatten_executed) {
                ExecuteEmergencyFlatten("Hard deadline 4:59 PM ET");
                m_flatten_executed = true;
            }
            else if(now_et >= m_emergency_deadline_et && !m_flatten_executed) {
                ExecuteEmergencyFlatten("Emergency deadline 4:55 PM ET");
                m_flatten_executed = true;
            }

            // Catch-up logic: if we missed checks, still enforce
            datetime time_since_last = now_et - m_last_check_time;
            if(time_since_last > 60) {  // More than 60 seconds gap
                Print("WARNING: Timer gap detected (", time_since_last, "s). Checking deadlines.");
            }
        }

        void ExecuteEmergencyFlatten(string reason) {
            Print("EMERGENCY FLATTEN: ", reason);
            // Close all positions with retry
            for(int attempt = 1; attempt <= 3; attempt++) {
                if(FlattenAllPositions()) break;
                Sleep(500);
            }
        }

        bool ShouldBlockNewTrades() {
            return m_time_handler.GetCurrentET() >= m_block_deadline_et;
        }
    };
    ```
  </action>
  <verify>
    DISPROOF TEST: Simulate OnTimer gap (call with 5-minute delay).
    Verify flatten still executes immediately when now >= deadline.
  </verify>
  <done>Wall-clock enforcement idempotente, funciona mesmo com timer delays</done>
</task>

</tasks>

---

## PHASE 3: Entry Gates (P0-P1)
**Objetivo:** VirtualGate + UnifiedRiskPolicy + Gap Cooldown
**Execução:** FORGE-1, FORGE-2, FORGE-3 em PARALELO

<tasks>

<task type="auto" agent="FORGE-1">
  <name>Task 3.1: Implement UnifiedRiskPolicy (CRITIC FIXED)</name>
  <files>
    MQL5/Include/EA_SCALPER/Risk/CUnifiedRiskPolicy.mqh (NEW)
  </files>
  <action>
    Criar CUnifiedRiskPolicy com CRITIC fix #5:

    ```cpp
    // CRITIC FIX #5: Fixed-size arrays, not dynamic

    struct RiskDecision {
        bool can_open_new;
        double size_factor;      // 0.0 to 1.0
        bool must_flatten;
        int reason_flags;        // Bitmask of ENUM_GATE_REASON
        string reasons[8];       // Fixed array, not dynamic
        int reason_count;

        void AddReason(ENUM_GATE_REASON r, string text) {
            reason_flags |= r;
            if(reason_count < 8) {
                reasons[reason_count++] = text;
            }
        }

        string GetPrimaryReason() {
            return reason_count > 0 ? reasons[0] : "ok";
        }
    };

    class CUnifiedRiskPolicy {
    private:
        CApexDDTracker* m_dd_tracker;
        CApexTimeHandler* m_time_handler;
        CWallClockEnforcer* m_wall_clock;
        CVirtualGate* m_virtual_gate;
        CSpreadMonitor* m_spread_monitor;
        CGapCooldown* m_gap_cooldown;

    public:
        RiskDecision EvaluateEntry(int direction) {
            RiskDecision d = {true, 1.0, false, 0, {}, 0};

            // Gate evaluation order (from Python):
            // 1. Time gate
            if(m_time_handler.IsAfterHardClose()) {
                d.must_flatten = true;
                d.can_open_new = false;
                d.AddReason(GATE_TIME, "hard_close_4:59pm");
                return d;
            }
            if(m_time_handler.IsAfterBlockNewTrades()) {
                d.can_open_new = false;
                d.AddReason(GATE_TIME, "block_new_4:30pm");
            }

            // 2. DD gate
            if(m_dd_tracker.MustFlatten()) {
                d.must_flatten = true;
                d.can_open_new = false;
                d.AddReason(GATE_DD_TRAILING, "dd_flatten");
                return d;
            }
            if(m_dd_tracker.MustHalt()) {
                d.can_open_new = false;
                d.size_factor = 0.0;
                d.AddReason(GATE_DD_TRAILING, "dd_halt");
            }

            // 3. Spread gate
            if(m_spread_monitor != NULL && m_spread_monitor.IsBlocked()) {
                d.can_open_new = false;
                d.AddReason(GATE_SPREAD, "spread_too_wide");
            }

            // 4. Virtual gate
            if(m_virtual_gate != NULL && !m_virtual_gate.IsOK()) {
                d.can_open_new = false;
                d.AddReason(GATE_VIRTUAL, m_virtual_gate.GetReasonText());
            }

            // 5. Gap cooldown
            if(m_gap_cooldown != NULL && m_gap_cooldown.IsInCooldown()) {
                d.can_open_new = false;
                d.AddReason(GATE_GAP_COOLDOWN, "gap_cooldown_active");
            }

            return d;
        }

        RiskDecision EvaluateExit() {
            // CRÍTICO: Exits NEVER blocked
            RiskDecision d = {true, 1.0, false, 0, {}, 0};
            return d;
        }
    };
    ```
  </action>
  <verify>
    - Gate order matches Python
    - Exits always allowed
    - Bitmask reasons work
    - Fixed array doesn't overflow
  </verify>
  <done>CUnifiedRiskPolicy com fixed arrays e bitmask</done>
</task>

<task type="auto" agent="FORGE-2">
  <name>Task 3.2: Implement VirtualGate (CRITIC WARNING FIXED)</name>
  <files>
    MQL5/Include/EA_SCALPER/Risk/CVirtualGate.mqh (NEW)
  </files>
  <action>
    Criar CVirtualGate com CRITIC warning fix:

    ```cpp
    // CRITIC WARNING FIX: Enforce bar[1] only, ban bar[0]

    enum ENUM_VGATE_REASON {
        VGATE_OK,
        VGATE_TEMPORAL_VIOLATION,
        VGATE_RANGE_SPIKE,
        VGATE_TURBULENCE_CLUSTER,
        VGATE_INTRABAR_ACCESS      // NEW: Tried to use bar[0]
    };

    class CVirtualGate : public IRiskGate {
    private:
        double m_range_spike_multiplier;  // Default 3.0
        int m_cluster_lookback;           // Default 10
        int m_cluster_max_spikes;         // Default 3
        double m_median_range;
        ENUM_VGATE_REASON m_last_reason;
        int m_spike_count;

    public:
        void Init() {
            m_range_spike_multiplier = 3.0;
            m_cluster_lookback = 10;
            m_cluster_max_spikes = 3;
            m_last_reason = VGATE_OK;
        }

        // CRITIC FIX: bar_index must be >= 1 (completed bars only)
        bool Evaluate(int bar_index, datetime bar_ts, datetime decision_ts, double bar_range) {
            // Enforce completed bars only
            if(bar_index < 1) {
                m_last_reason = VGATE_INTRABAR_ACCESS;
                return false;
            }

            // Temporal check
            if(bar_ts >= decision_ts) {
                m_last_reason = VGATE_TEMPORAL_VIOLATION;
                return false;
            }

            // Range spike check
            if(m_median_range > 0 && bar_range > m_median_range * m_range_spike_multiplier) {
                m_last_reason = VGATE_RANGE_SPIKE;
                return false;
            }

            // Turbulence cluster check
            if(m_spike_count >= m_cluster_max_spikes) {
                m_last_reason = VGATE_TURBULENCE_CLUSTER;
                return false;
            }

            m_last_reason = VGATE_OK;
            return true;
        }

        bool IsBlocked() override { return m_last_reason != VGATE_OK; }
        bool IsOK() { return m_last_reason == VGATE_OK; }

        ENUM_GATE_REASON GetReason() override { return GATE_VIRTUAL; }

        string GetReasonText() {
            switch(m_last_reason) {
                case VGATE_TEMPORAL_VIOLATION: return "temporal_violation";
                case VGATE_RANGE_SPIKE: return "range_spike";
                case VGATE_TURBULENCE_CLUSTER: return "turbulence_cluster";
                case VGATE_INTRABAR_ACCESS: return "intrabar_access_banned";
                default: return "ok";
            }
        }
    };
    ```
  </action>
  <verify>
    - bar_index=0 is rejected (intrabar access banned)
    - Temporal check works
    - Range spike and cluster work
  </verify>
  <done>CVirtualGate com proteção contra intrabar access</done>
</task>

<task type="auto" agent="FORGE-3">
  <name>Task 3.3: Implement Gap Cooldown</name>
  <files>
    MQL5/Include/EA_SCALPER/Risk/CGapCooldown.mqh (NEW)
  </files>
  <action>
    Criar CGapCooldown:

    ```cpp
    class CGapCooldown : public IRiskGate {
    private:
        int m_gap_threshold_minutes;   // Default 30
        int m_cooldown_minutes;        // Default 15
        datetime m_cooldown_until;
        datetime m_last_bar_time;

    public:
        void Init() {
            m_gap_threshold_minutes = 30;
            m_cooldown_minutes = 15;
            m_cooldown_until = 0;
            m_last_bar_time = 0;
        }

        void OnNewBar(datetime bar_time) {
            if(m_last_bar_time > 0) {
                int gap_minutes = (int)(bar_time - m_last_bar_time) / 60;
                if(gap_minutes >= m_gap_threshold_minutes) {
                    m_cooldown_until = bar_time + m_cooldown_minutes * 60;
                    Print("GAP detected: ", gap_minutes, " min. Cooldown until ", TimeToString(m_cooldown_until));
                }
            }
            m_last_bar_time = bar_time;
        }

        bool IsInCooldown() {
            return TimeGMT() < m_cooldown_until;
        }

        bool IsBlocked() override { return IsInCooldown(); }
        ENUM_GATE_REASON GetReason() override { return GATE_GAP_COOLDOWN; }
    };
    ```
  </action>
  <verify>Gap detection and cooldown work correctly</verify>
  <done>CGapCooldown blocks entries after market gaps</done>
</task>

</tasks>

---

## PHASE 4: Integration & EA Update
**Objetivo:** Integrar todos os componentes + OnDeinit flatten
**Execução:** FORGE-1 (lead)

<tasks>

<task type="auto" agent="FORGE-1">
  <name>Task 4.1: Update EA with new components (CRITIC MISSING FIXED)</name>
  <files>
    MQL5/Experts/EA_SCALPER_XAUUSD.mq5
  </files>
  <action>
    Atualizar EA com CRITIC missing items:

    1. Includes
    2. Global objects
    3. OnInit() - initialize all
    4. OnTick() - use unified policy
    5. OnTimer() - wall-clock enforcement

    CRITIC FIX - Add OnDeinit flatten:
    ```cpp
    void OnDeinit(const int reason) {
        // ALWAYS flatten on EA removal/chart change
        Print("OnDeinit called, reason: ", reason);

        // Flatten all positions
        FlattenAllPositions("OnDeinit");

        // Cancel all pending orders
        for(int i = OrdersTotal() - 1; i >= 0; i--) {
            ulong ticket = OrderGetTicket(i);
            if(OrderSelect(ticket)) {
                if(OrderGetString(ORDER_SYMBOL) == _Symbol) {
                    trade.OrderDelete(ticket);
                }
            }
        }

        // Cleanup timer
        EventKillTimer();

        // Cleanup HUD
        g_HUD.Delete();
    }
    ```

    OnTick simplified:
    ```cpp
    void OnTick() {
        // Update components
        g_DDTracker.Update();
        g_WallClock.OnTick();
        g_TimeHandler.UpdateDSTStatus();

        // Get unified decision
        RiskDecision decision = g_RiskPolicy.EvaluateEntry(0);

        if(decision.must_flatten) {
            FlattenAllPositions(decision.GetPrimaryReason());
            return;
        }

        if(!decision.can_open_new) {
            return;  // No new entries
        }

        // ... trading logic with decision.size_factor
    }
    ```
  </action>
  <verify>EA compiles, OnDeinit tested, all components wired</verify>
  <done>EA integrado com OnDeinit flatten e cancel orders</done>
</task>

<task type="auto" agent="FORGE-2">
  <name>Task 4.2: Create Risk HUD panel</name>
  <files>
    MQL5/Include/EA_SCALPER/UI/CRiskHUD.mqh (NEW)
  </files>
  <action>
    Criar painel visual com:
    - DD Thermometer (0-5%)
    - Time state + countdown
    - Gate status icons
    - HWM display
  </action>
  <verify>HUD renders correctly</verify>
  <done>Risk HUD implemented</done>
</task>

</tasks>

---

## PHASE 5: ML Ensemble (P2 - OPTIONAL)
**Objetivo:** Multi-model ONNX - pode ser skipped se complexidade for problema
**CRITIC WARNING:** ML fail-open pode ser perigoso - considerar fail-closed

<tasks>

<task type="auto" agent="FORGE-3">
  <name>Task 5.1: Implement ONNX Ensemble (with fail-mode option)</name>
  <files>
    MQL5/Include/EA_SCALPER/Bridge/COnnxEnsemble.mqh (NEW)
  </files>
  <action>
    Criar ensemble com fail-mode configurável:

    ```cpp
    enum ENUM_ML_FAIL_MODE {
        ML_FAIL_OPEN,     // Allow trades if ML unavailable
        ML_FAIL_CLOSED,   // Block trades if ML unavailable
        ML_FAIL_REDUCE    // Reduce size 50% if ML unavailable
    };

    input ENUM_ML_FAIL_MODE InpMLFailMode = ML_FAIL_OPEN;
    ```

    NOTA: Para prop firm, considerar ML_FAIL_REDUCE como default.
  </action>
  <verify>Fail mode works correctly in all 3 cases</verify>
  <done>ONNX Ensemble com fail-mode configurável</done>
</task>

<task type="auto" agent="FORGE-4">
  <name>Task 5.2: Implement Calibration</name>
  <files>
    MQL5/Include/EA_SCALPER/Bridge/CCalibrator.mqh (NEW)
  </files>
  <action>Platt + Isotonic calibration from files</action>
  <verify>Calibration loads and applies correctly</verify>
  <done>Calibrator implemented</done>
</task>

</tasks>

---

## PHASE 6: Visual Indicators (Para Investidor Árabe)
**Objetivo:** SMC Visual + Dashboard profissional

<tasks>

<task type="auto" agent="FORGE-4">
  <name>Task 6.1: Enhance SMC_Visual</name>
  <files>MQL5/Indicators/SMC_Visual.mq5</files>
  <action>
    Adicionar:
    - DD Thermometer
    - Gate Status Panel
    - ET Countdown
    - ICT Killzones
    - ML Confidence (se ML enabled)
  </action>
  <verify>All visuals render correctly</verify>
  <done>SMC_Visual enhanced</done>
</task>

<task type="auto" agent="FORGE-4">
  <name>Task 6.2: Create Demo Mode</name>
  <files>MQL5/Indicators/SMC_Visual.mq5</files>
  <action>Demo animation for investor presentation</action>
  <verify>Demo runs smoothly</verify>
  <done>Demo mode ready</done>
</task>

<task type="auto" agent="FORGE-4">
  <name>Task 6.3: Create Trading Dashboard</name>
  <files>MQL5/Indicators/TradingDashboard.mq5 (NEW)</files>
  <action>Full dashboard with all metrics</action>
  <verify>Dashboard shows all info</verify>
  <done>Dashboard complete</done>
</task>

</tasks>

---

## PHASE 7: Testing & Validation
**Objetivo:** Validar com DISPROOF tests do CRITIC

<tasks>

<task type="auto" agent="FORGE-1">
  <name>Task 7.1: DD Tracker Disproof Tests</name>
  <files>MQL5/Scripts/Tests/Test_DDTracker.mq5 (NEW)</files>
  <action>
    DISPROOF TEST 1: HWM double-count
    - Set equity = 51000 (includes $1000 floating)
    - Verify HWM = 51000 NOT 52000
    - If HWM = 52000, test FAILS → fix the bug

    DISPROOF TEST 2: Severity thresholds
    - Test all 6 levels
    - Verify correct transitions
  </action>
  <verify>All disproof tests pass</verify>
  <done>DD Tracker validated</done>
</task>

<task type="auto" agent="FORGE-2">
  <name>Task 7.2: Time Handler Disproof Tests</name>
  <files>MQL5/Scripts/Tests/Test_TimeHandler.mq5 (NEW)</files>
  <action>
    DISPROOF TEST - DST boundaries (UTC timestamps):
    | UTC Timestamp | Expected Offset | Expected ET |
    |---------------|-----------------|-------------|
    | 2024-03-10 06:59 | -5 (EST) | 01:59 |
    | 2024-03-10 07:01 | -4 (EDT) | 03:01 |
    | 2024-11-03 05:59 | -4 (EDT) | 01:59 |
    | 2024-11-03 06:01 | -5 (EST) | 01:01 |
    | 2025-03-09 06:59 | -5 (EST) | 01:59 |
    | 2025-03-09 07:01 | -4 (EDT) | 03:01 |
  </action>
  <verify>All DST transitions correct</verify>
  <done>Time Handler validated</done>
</task>

<task type="auto" agent="FORGE-3">
  <name>Task 7.3: Timer Delay Disproof Test</name>
  <files>MQL5/Scripts/Tests/Test_WallClock.mq5 (NEW)</files>
  <action>
    DISPROOF TEST - Timer gaps:
    - Simulate 5-minute gap in OnTimer calls
    - Verify flatten still executes when now >= deadline
    - Must be idempotent (only flattens once)
  </action>
  <verify>Flatten works even with delayed timer</verify>
  <done>Wall-clock enforcement validated</done>
</task>

<task type="auto" agent="FORGE-3">
  <name>Task 7.4: Integration Backtest</name>
  <files>MQL5/Experts/EA_SCALPER_XAUUSD.mq5</files>
  <action>
    Strategy Tester:
    - XAUUSD M5, 2024.01-2024.12
    - Verify no overnight positions
    - Verify max DD < 5%
    - Verify time gates work
  </action>
  <verify>Backtest passes all criteria</verify>
  <done>Integration validated</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <name>Task 7.5: Visual Verification by Franco</name>
  <what-built>Complete MQL5 migration with all CRITIC fixes</what-built>
  <how-to-verify>
    1. Open MT5, attach EA to XAUUSD M5
    2. Verify HUD displays DD, time, gates
    3. Run backtest, check journal
    4. Confirm no overnight positions
  </how-to-verify>
  <resume-signal>Type "approved" or describe issues</resume-signal>
</task>

</tasks>

---

## EXECUTION STRATEGY

### Parallel Agent Assignment
```
Phase 1: FORGE-1 + FORGE-2 (parallel)
Phase 2: FORGE-1 (DD) + FORGE-2 (Time) (parallel)
Phase 3: FORGE-1 + FORGE-2 + FORGE-3 (parallel)
Phase 4: FORGE-1 (lead)
Phase 5: FORGE-3 + FORGE-4 (parallel, optional)
Phase 6: FORGE-4
Phase 7: FORGE-1 + FORGE-2 + FORGE-3 (parallel)
```

### Dependencies
```
Phase 1 ──► Phase 2 ──► Phase 3 ──► Phase 4 ──► Phase 7
                                       │
                                       ├──► Phase 5 (optional)
                                       │
                                       └──► Phase 6 (can start at Phase 4)
```

---

## SUCCESS CRITERIA

### CRITIC Fixes Verified
- [ ] HWM uses AccountEquity() only (no double-count)
- [ ] Time uses TimeGMT() as base
- [ ] DST algorithm is deterministic with test vectors
- [ ] OnTimer is idempotent (catches missed calls)
- [ ] RiskDecision uses fixed arrays

### Apex Compliance
- [ ] DD never exceeds 5% in tests
- [ ] No overnight positions
- [ ] Time gates at 4:30/4:55/4:59 PM ET
- [ ] OnDeinit flattens and cancels orders

### Functional
- [ ] All gates work (time, DD, spread, virtual, gap)
- [ ] Visual elements display correctly
- [ ] Demo mode works for investor

---

## OUTPUT

After completion, create:
- `.planning/phases/13-mql5-migration/13-SUMMARY.md`
- `.planning/phases/13-mql5-migration/BACKTEST_RESULTS.md`
- `.planning/phases/13-mql5-migration/DISPROOF_TESTS.md`
- `MQL5/Experts/CHANGELOG.md` (updated)
