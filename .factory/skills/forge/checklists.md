# Checklists - FORGE

## Code Review Checklist (20 Items)

### ESTRUTURA (5 pontos)
```
□ 1. Naming conventions (C, m_, g_, UPPER)?
□ 2. Estrutura de arquivo correta?
□ 3. Modularidade (uma responsabilidade)?
□ 4. Dependencias bem definidas (#include)?
□ 5. Documentacao adequada?
```

### QUALIDADE (5 pontos)
```
□ 6. Error handling (OrderSend, CopyBuffer)?
□ 7. Input validation?
□ 8. Null/invalid checks (handles, pointers)?
□ 9. Edge cases tratados?
□ 10. Logging adequado?
```

### PERFORMANCE (5 pontos)
```
□ 11. Latencia aceitavel (OnTick < 50ms)?
□ 12. Memory management (delete, Release)?
□ 13. Sem alocacoes em loops criticos?
□ 14. Caching de indicadores?
□ 15. Algoritmos eficientes?
```

### SEGURANCA (5 pontos)
```
□ 16. Sem dados sensiveis expostos?
□ 17. Inputs sanitizados?
□ 18. Limites de recursos?
□ 19. Timeout em externos?
□ 20. Graceful degradation?
```

**SCORING:**
- 18-20: APPROVED ✅ - Pronto para live
- 14-17: NEEDS_WORK ⚠️ - Corrigir antes
- 10-13: MAJOR_ISSUES 🔶 - Refatorar
- < 10: REJECTED ❌ - Reescrever

---

## Self-Correction Checklist (5 Checks)

```
EXECUTAR ANTES DE MOSTRAR QUALQUER CODIGO:

□ CHECK 1: ERROR HANDLING
  - Todo OrderSend tem verificacao de retorno?
  - Todo CopyBuffer verifica resultado?
  - Operacoes de arquivo verificam sucesso?
  - WebRequest tem tratamento de timeout?

□ CHECK 2: BOUNDS & NULL
  - Todo array access verifica ArraySize?
  - Todo ponteiro verifica CheckPointer/NULL?
  - Todo handle verifica INVALID_HANDLE?
  - Todo string operation verifica StringLen?

□ CHECK 3: DIVISION BY ZERO
  - Toda divisao tem guard?
  - Calculos de percentage protegidos?
  - Tick value / tick size verificados?

□ CHECK 4: RESOURCE MANAGEMENT
  - Todo 'new' tem 'delete' correspondente?
  - Indicator handles liberados em OnDeinit?
  - Arrays globais, nao recriados em loop?
  - Strings nao crescem infinitamente?

□ CHECK 5: FTMO COMPLIANCE
  - DD check presente antes de trade?
  - Position size limitado?
  - Emergency mode considerado?
  - Daily reset implementado?

SE ALGUM FALHAR: CORRIGIR ANTES DE MOSTRAR
ADICIONAR AO CODIGO: // ✓ FORGE v2.1 Self-Correction: 5/5 checks passed
```

---

## FTMO Code Compliance Checklist

### Drawdown Tracking
```
□ Daily DD calculado corretamente (Equity, nao Balance)?
□ Total DD calculado (Peak Equity - Current)?
□ Peak equity tracked e atualizado?
□ Daily reset em novo dia implementado?
```

### Limites
```
□ Buffer diario (4%) trigger implementado?
□ Buffer total (8%) trigger implementado?
□ Hard stop em 5%/10%?
□ Alertas antes de atingir limites?
```

### Position Sizing
```
□ Formula correta: Risk / (SL * TickValue)?
□ Max lot limitado (SYMBOL_VOLUME_MAX)?
□ Lot normalizado (SYMBOL_VOLUME_STEP)?
□ Regime multiplier aplicado?
```

### Emergency
```
□ Emergency mode implementado?
□ Close all funciona corretamente?
□ Halt new trades funciona?
□ Recovery mode existe?
```

---

## ONNX Integration Checklist (15 Items)

### Model Loading
```
□ Path correto para .onnx file?
□ OnnxCreate com error handling?
□ Handle verificado (INVALID_HANDLE)?
□ OnnxRelease em OnDeinit?
```

### Inference
```
□ Input shape correto (batch, seq, features)?
□ Output shape correto?
□ Latencia < 5ms?
□ Error handling em OnnxRun?
□ Fallback em erro (return neutral)?
```

### Normalizacao
```
□ Scaler params carregados?
□ Match com Python (mesmos valores)?
□ Ordem das features identica ao treino?
□ Buffer pre-alocado (nao em OnTick)?
```

### Features (15 do modelo)
```
□ 1. Returns (StandardScaler)
□ 2. Log Returns (StandardScaler)
□ 3. Range % (StandardScaler)
□ 4. RSI M5 (/ 100)
□ 5. RSI M15 (/ 100)
□ 6. RSI H1 (/ 100)
□ 7. ATR Norm (StandardScaler)
□ 8. MA Distance (StandardScaler)
□ 9. BB Position (-1 to 1)
□ 10. Hurst (0 to 1)
□ 11. Entropy (/ 4)
□ 12. Session (0,1,2)
□ 13. Hour Sin (-1 to 1)
□ 14. Hour Cos (-1 to 1)
□ 15. OB Distance (StandardScaler)
```

---

## Test Scaffold Template

```mql5
//+------------------------------------------------------------------+
//| Test_{{ModuleName}}.mq5 - Unit Tests                              |
//| Gerado por FORGE v2.1 - TDD Protocol                              |
//+------------------------------------------------------------------+
#include "{{ModuleName}}.mqh"

int tests_passed = 0;
int tests_failed = 0;

void OnStart() {
    Print("=== TEST SUITE: {{ModuleName}} ===");
    
    Test_Initialize();
    Test_EdgeCases();
    Test_HappyPath();
    Test_ErrorConditions();
    
    Print("=== RESULTS: ", tests_passed, "/", 
          tests_passed + tests_failed, " passed ===");
    
    if(tests_failed > 0) 
        Print("❌ SOME TESTS FAILED!");
    else 
        Print("✅ ALL TESTS PASSED!");
}

void Assert(bool condition, string test_name) {
    if(condition) { 
        tests_passed++; 
        Print("✓ ", test_name); 
    } else { 
        tests_failed++; 
        Print("✗ FAILED: ", test_name); 
    }
}

void Test_Initialize() {
    {{ModuleName}} obj;
    Assert(obj.Initialize(), "Initialize returns true");
    Assert(obj.IsReady(), "IsReady after init");
}

void Test_EdgeCases() {
    {{ModuleName}} obj;
    obj.Initialize();
    
    // Zero input
    Assert(obj.Process(0) >= 0, "Zero input handled");
    
    // Negative input
    Assert(obj.Process(-1) >= 0, "Negative input handled");
    
    // Null/empty
    Assert(obj.ProcessArray(NULL) == false, "Null array rejected");
}

void Test_HappyPath() {
    {{ModuleName}} obj;
    obj.Initialize();
    
    double result = obj.Process(100);
    Assert(result > 0, "Normal input produces valid output");
}

void Test_ErrorConditions() {
    {{ModuleName}} obj;
    // Sem Initialize - deve falhar gracefully
    Assert(obj.Process(100) == 0, "Uninitialized returns safe value");
    Assert(obj.GetLastError() != 0, "Error code set");
}
```

---

## Error Handling Pattern

```mql5
// PADRAO OBRIGATORIO para trade execution
bool ExecuteTrade(ENUM_ORDER_TYPE type, double lots, double sl, double tp) {
    // 1. Validar inputs
    if(lots <= 0 || lots > GetMaxLot()) {
        Print("ERROR: Invalid lot size: ", lots);
        return false;
    }
    
    // 2. Verificar condicoes FTMO
    if(!IsTradeAllowed()) {
        Print("WARN: Trading not allowed (DD limit)");
        return false;
    }
    
    // 3. Preparar e executar com retry
    MqlTradeRequest request = {};
    MqlTradeResult result = {};
    // ... setup request ...
    
    int attempts = 3;
    while(attempts > 0) {
        ResetLastError();
        if(OrderSend(request, result)) {
            if(result.retcode == TRADE_RETCODE_DONE) {
                Print("SUCCESS: Trade #", result.order);
                return true;
            }
        }
        
        int error = GetLastError();
        if(error == ERR_REQUOTE) {
            RefreshRates();
            attempts--;
            continue;
        }
        break;  // Erro nao-recuperavel
    }
    
    Print("ERROR: Trade failed. Code=", GetLastError());
    return false;
}
// ✓ FORGE v2.1 Self-Correction: 5/5 checks passed
```

---

## Indicator Caching Pattern

```mql5
// PADRAO OBRIGATORIO para indicadores
class CIndicatorManager {
private:
    int m_handleATR, m_handleRSI;
    double m_cachedATR, m_cachedRSI;
    datetime m_lastBarTime;
    
public:
    bool Initialize() {
        m_handleATR = iATR(_Symbol, PERIOD_CURRENT, 14);
        m_handleRSI = iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
        
        if(m_handleATR == INVALID_HANDLE || m_handleRSI == INVALID_HANDLE) {
            Print("ERROR: Failed to create handles");
            return false;
        }
        return true;
    }
    
    void UpdateCache() {
        datetime currentBar = iTime(_Symbol, PERIOD_CURRENT, 0);
        if(currentBar == m_lastBarTime) return;  // Ja atualizado
        
        double buffer[];
        ArraySetAsSeries(buffer, true);
        
        if(CopyBuffer(m_handleATR, 0, 0, 1, buffer) > 0)
            m_cachedATR = buffer[0];
        if(CopyBuffer(m_handleRSI, 0, 0, 1, buffer) > 0)
            m_cachedRSI = buffer[0];
            
        m_lastBarTime = currentBar;
    }
    
    double GetATR() { return m_cachedATR; }  // RAPIDO - usa cache
    double GetRSI() { return m_cachedRSI; }
    
    void Deinitialize() {
        if(m_handleATR != INVALID_HANDLE) IndicatorRelease(m_handleATR);
        if(m_handleRSI != INVALID_HANDLE) IndicatorRelease(m_handleRSI);
    }
};
// ✓ FORGE v2.1 Self-Correction: 5/5 checks passed
```
