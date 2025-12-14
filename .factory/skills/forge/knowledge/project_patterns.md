# FORGE Knowledge: Project Patterns

> Convencoes e padroes ESPECIFICOS deste projeto (aprendidos do codigo existente)

---

## 1. Naming Conventions

### Classes
```mql5
// Prefixo C para classes
class CRegimeDetector { };
class CTradeManager { };
class CConfluenceScorer { };

// Excecao: structs usam prefixo S
struct SEliteOrderBlock { };
struct SFootprintLevel { };
struct STradeSignal { };
```

### Membros
```mql5
// m_ para membros privados
class CMyClass {
private:
    double m_stopLoss;
    int    m_magicNumber;
    bool   m_isInitialized;
};
```

### Enums
```mql5
// ENUM_ prefixo, valores em UPPER_CASE
enum ENUM_REGIME_TYPE {
    REGIME_TRENDING,
    REGIME_RANGING,
    REGIME_RANDOM_WALK
};

enum ENUM_SIGNAL_TYPE {
    SIGNAL_NONE,
    SIGNAL_BUY,
    SIGNAL_SELL
};
```

### Constantes
```mql5
// #define para constantes de compilacao
#define MAX_SLIPPAGE        50
#define FTMO_DAILY_DD       5.0
#define FTMO_TOTAL_DD       10.0
```

---

## 2. Estrutura de Arquivo .mqh

```mql5
//+------------------------------------------------------------------+
//| NomeDoModulo.mqh                                                  |
//| Copyright 2024, EA_SCALPER_XAUUSD Project                        |
//+------------------------------------------------------------------+
#ifndef __NOME_DO_MODULO_MQH__
#define __NOME_DO_MODULO_MQH__

// 1. Includes necessarios
#include "../Core/Definitions.mqh"

// 2. Estruturas locais (se houver)
struct SLocalStruct {
    // ...
};

// 3. Classe principal
class CNomeDoModulo {
private:
    // Membros privados
    double m_cache;
    bool   m_initialized;
    
public:
    // Construtor/Destrutor
    CNomeDoModulo();
    ~CNomeDoModulo();
    
    // Inicializacao (OBRIGATORIO)
    bool Init(string symbol);
    void Deinit();
    
    // Metodos principais
    void   Update();
    double GetValue();
    bool   IsValid();
};

// 4. Implementacao inline ou no mesmo arquivo
CNomeDoModulo::CNomeDoModulo() {
    m_initialized = false;
    m_cache = 0.0;
}

// ... resto da implementacao

#endif // __NOME_DO_MODULO_MQH__
```

---

## 3. Padrao de Inicializacao

**TODAS as classes de Analysis seguem este padrao:**

```mql5
class CMyAnalyzer {
private:
    string m_symbol;
    bool   m_initialized;
    int    m_handleATR;  // Handles de indicadores

public:
    CMyAnalyzer() : m_initialized(false), m_handleATR(INVALID_HANDLE) {}
    
    bool Init(string symbol) {
        m_symbol = symbol;
        
        // Criar handles
        m_handleATR = iATR(m_symbol, PERIOD_M5, 14);
        if(m_handleATR == INVALID_HANDLE) {
            Print("ERROR: Failed to create ATR handle");
            return false;
        }
        
        m_initialized = true;
        return true;
    }
    
    void Deinit() {
        if(m_handleATR != INVALID_HANDLE) {
            IndicatorRelease(m_handleATR);
            m_handleATR = INVALID_HANDLE;
        }
        m_initialized = false;
    }
    
    bool IsInitialized() { return m_initialized; }
};
```

---

## 4. Padrao de Error Handling

### Para Indicadores
```mql5
// SEMPRE verificar handle
int handle = iATR(_Symbol, PERIOD_M5, 14);
if(handle == INVALID_HANDLE) {
    PrintFormat("ERROR: iATR failed [%s]", _Symbol);
    return false;
}

// SEMPRE verificar CopyBuffer
double buffer[];
ArraySetAsSeries(buffer, true);
int copied = CopyBuffer(handle, 0, 0, 1, buffer);
if(copied <= 0) {
    PrintFormat("ERROR: CopyBuffer failed, copied=%d", copied);
    return 0.0;
}
```

### Para Trades
```mql5
// SEMPRE verificar OrderSend
MqlTradeRequest request = {};
MqlTradeResult result = {};

if(!OrderSend(request, result)) {
    PrintFormat("ERROR: OrderSend failed [%d] %s", 
                GetLastError(), 
                result.comment);
    return false;
}

if(result.retcode != TRADE_RETCODE_DONE) {
    PrintFormat("ERROR: Trade rejected [%d] %s",
                result.retcode,
                result.comment);
    return false;
}
```

---

## 5. Padrao de Logging

```mql5
// Formato padrao de logs
PrintFormat("[%s] INFO: Mensagem com %s e %d", 
            __FUNCTION__, stringVar, intVar);

PrintFormat("[%s] WARN: Alerta sobre %s", 
            __FUNCTION__, descricao);

PrintFormat("[%s] ERROR: Falha em %s [%d]", 
            __FUNCTION__, operacao, GetLastError());

// Para trades - comentario padrao
string comment = StringFormat("SINGULARITY|%s|%d|%.2f", 
                              signal_type, score, lot);
```

---

## 6. Padrao de Confluencia

**O projeto usa sistema de GATES sequenciais:**

```mql5
// OnTick() segue este padrao:
void OnTick() {
    // GATE 1: Emergency Mode
    if(g_RiskManager.IsEmergency()) return;
    
    // GATE 2: Risk Check
    if(!g_RiskManager.CanTrade()) return;
    
    // GATE 3: Session Filter
    if(!g_SessionFilter.IsValidSession()) return;
    
    // GATE 4: News Filter
    if(g_NewsFilter.HasHighImpact()) return;
    
    // GATE 5: Regime Filter
    if(g_RegimeDetector.IsRandomWalk()) return;
    
    // GATE 6: MTF Direction
    if(!g_MTFManager.IsAligned()) return;
    
    // ... mais gates ...
    
    // PASSED ALL GATES -> Execute
    ExecuteTrade(signal);
}
```

---

## 7. Padrao de Score

**Sistema de pontuacao 0-100 com tiers:**

```mql5
// Thresholds padrao
#define SCORE_TIER_A    90   // Perfeito
#define SCORE_TIER_B    75   // Bom
#define SCORE_TIER_C    60   // Minimo
#define SCORE_TIER_D    0    // No trade

// Conversao para tier
ENUM_SIGNAL_TIER GetTier(int score) {
    if(score >= SCORE_TIER_A) return TIER_A;
    if(score >= SCORE_TIER_B) return TIER_B;
    if(score >= SCORE_TIER_C) return TIER_C;
    return TIER_D;
}

// Multiplicador de posicao
double GetSizeMultiplier(ENUM_SIGNAL_TIER tier) {
    switch(tier) {
        case TIER_A: return 1.00;
        case TIER_B: return 0.75;
        case TIER_C: return 0.50;
        default:     return 0.00;
    }
}
```

---

## 8. Padrao FTMO

**Regras HARDCODED que NUNCA mudam:**

```mql5
// Limites FTMO $100k - NAO MODIFICAR
#define FTMO_DAILY_DD_LIMIT    5.0    // 5% = $5,000
#define FTMO_TOTAL_DD_LIMIT    10.0   // 10% = $10,000
#define FTMO_DAILY_DD_BUFFER   4.0    // 4% trigger soft-stop
#define FTMO_TOTAL_DD_BUFFER   8.0    // 8% trigger emergency

// Calculo de DD usa EQUITY, nao BALANCE
double equity = AccountInfoDouble(ACCOUNT_EQUITY);
double dd = (m_peakEquity - equity) / m_peakEquity * 100.0;

// High-water mark OBRIGATORIO
if(equity > m_peakEquity)
    m_peakEquity = equity;
```

---

## 9. Padrao de Session Times

**Horarios em GMT (ajustar para broker):**

```mql5
// Sessoes padrao do projeto
#define LONDON_START    7    // 07:00 GMT
#define LONDON_END      16   // 16:00 GMT
#define OVERLAP_START   12   // 12:00 GMT (London + NY)
#define OVERLAP_END     16   // 16:00 GMT
#define NY_START        16   // 16:00 GMT (pra nos)
#define NY_END          21   // 21:00 GMT
#define LATE_NY_END     0    // 00:00 GMT

// NUNCA operar em:
// - Asia (00-07 GMT) - baixo volume
// - Late NY (21-00 GMT) - spreads altos
// - Friday apos 14:00 GMT - risco weekend
```

---

## 10. Padrao de Order Blocks / FVG

**Deteccao institucional REAL (nao heuristica):**

```mql5
// Order Block REAL requer:
// 1. Ultima vela CONTRA a direcao do movimento
// 2. Deslocamento FORTE (> 1.5x ATR) nos proximos candles
// 3. Volume spike (opcional, mas preferido)

bool IsValidBullishOB(int barIndex) {
    // Vela deve ser bearish (ULTIMA antes do rally)
    if(close[barIndex] >= open[barIndex]) return false;
    
    // Deslocamento nos proximos 5 candles
    double displacement = 0;
    for(int i = barIndex - 1; i >= barIndex - 5 && i >= 0; i--) {
        displacement = MathMax(displacement, high[i] - close[barIndex]);
    }
    
    // Deslocamento minimo = 1.5x ATR
    if(displacement < 1.5 * atr) return false;
    
    return true;
}

// FVG REAL requer GAP entre candle 1 e candle 3
// NAO e qualquer movimento forte!
bool IsValidBullishFVG(int barIndex) {
    // Gap: high[barIndex+2] < low[barIndex]
    double gap = low[barIndex] - high[barIndex + 2];
    
    // Gap minimo = spread + buffer
    if(gap < minGapSize) return false;
    
    return true;
}
```

---

## 11. Padrao de Performance

**Targets de latencia do projeto:**

```mql5
// Limites de performance
#define MAX_ONTICK_MS       50     // OnTick total
#define MAX_ONNX_MS         5      // Inferencia ONNX
#define MAX_INDICATOR_MS    10     // Calculo de indicador
#define MAX_PYTHON_MS       400    // Round-trip Python Hub

// Medicao padrao
ulong start = GetMicrosecondCount();
// ... operacao ...
ulong elapsed = GetMicrosecondCount() - start;
if(elapsed > MAX_ONTICK_MS * 1000) {
    PrintFormat("WARN: OnTick too slow: %d us", elapsed);
}
```

---

## 12. Arquivos de Referencia

| Tipo | Arquivo |
|------|---------|
| Enums e Structs | `Core/Definitions.mqh` |
| Risk Rules | `Risk/FTMO_RiskManager.mqh` |
| Trade Execution | `Execution/TradeExecutor.mqh` |
| Score System | `Signal/CConfluenceScorer.mqh` |
| MTF Logic | `Analysis/CMTFManager.mqh` |
| Session Times | `Analysis/CSessionFilter.mqh` |

---

## Quando Consultar Este Arquivo

FORGE DEVE consultar este arquivo AUTOMATICAMENTE quando:

1. Criar nova classe ou modulo
2. Implementar error handling
3. Escrever logica de score/tier
4. Implementar deteccao de OB/FVG
5. Trabalhar com horarios de sessao
6. Verificar padroes de logging
7. Garantir compliance FTMO
