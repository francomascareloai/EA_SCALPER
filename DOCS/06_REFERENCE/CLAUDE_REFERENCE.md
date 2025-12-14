# CLAUDE REFERENCE - Conhecimento Tecnico Detalhado

> **NOTA**: Este arquivo contem conhecimento de REFERENCIA.
> Consulte apenas quando precisar de detalhes tecnicos.
> Para instrucoes, veja AGENTS.md

---

## 1. REGIME DETECTION (Singularity Filter)

### Kalman Trend Filter

```python
class KalmanTrendFilter:
    def __init__(self, Q=0.01, R=1.0):
        self.Q = Q  # Process variance
        self.R = R  # Measurement variance
        self.x = None
        self.P = 1.0
    
    def update(self, measurement):
        if self.x is None:
            self.x = measurement
            return measurement, 0.0
        
        x_pred = self.x
        P_pred = self.P + self.Q
        K = P_pred / (P_pred + self.R)
        self.x = x_pred + K * (measurement - x_pred)
        self.P = (1 - K) * P_pred
        velocity = measurement - x_pred
        return self.x, velocity
```

### Regime Thresholds

```
H > 0.55 + S < 1.5  → PRIME_TRENDING    → Size: 100%
H > 0.55 + S ≥ 1.5  → NOISY_TRENDING    → Size: 50%
H < 0.45 + S < 1.5  → PRIME_REVERTING   → Size: 100%
H < 0.45 + S ≥ 1.5  → NOISY_REVERTING   → Size: 50%
0.45 ≤ H ≤ 0.55     → RANDOM_WALK       → Size: 0% (NO TRADE)
```

---

## 2. ONNX INTEGRATION

### Pipeline

```
Python (Dev)         ONNX (Bridge)       MQL5 (Prod)
───────────         ─────────────       ───────────
Train model    →    model.onnx     →    OnnxCreate()
Save scaler    →    scaler.json    →    Normalize()
Export         →                   →    OnnxRun()
```

### MQL5 Pattern

```mql5
class COnnxBrain {
private:
    long m_model_handle;
    float m_input[], m_output[];
    
public:
    bool Initialize() {
        m_model_handle = OnnxCreate("Models\\direction.onnx", ONNX_DEFAULT);
        return (m_model_handle != INVALID_HANDLE);
    }
    
    double GetProbability() {
        // Normalize inputs (MUST match training!)
        // Run inference
        if(!OnnxRun(m_model_handle, ONNX_NO_CONVERSION, m_input, m_output))
            return 0.5;
        return (double)m_output[1];
    }
};
```

### Model Specs

| Model | Input | Output | Threshold |
|-------|-------|--------|-----------|
| Direction | (100, 15) | [P(bear), P(bull)] | P > 0.65 |
| Volatility | (50, 5) | ATR[5] | - |
| Fakeout | (20, 4) | [P(fake), P(real)] | P(fake) < 0.4 |

---

## 3. SMART MONEY CONCEPTS (SMC)

### Order Blocks
- **Bullish OB**: Last DOWN candle before rally → Buy on return
- **Bearish OB**: Last UP candle before selloff → Sell on return

### Fair Value Gaps
- **Bullish FVG**: Gap between C1 high and C3 low
- **Bearish FVG**: Gap between C1 low and C3 high

### Liquidity
- **Sweep highs**: Buy-side grabbed → Reversal DOWN
- **Sweep lows**: Sell-side grabbed → Reversal UP

### Market Structure
- **HH + HL**: Bullish
- **LH + LL**: Bearish
- **BOS**: Break of Structure (continuation)
- **CHoCH**: Change of Character (reversal)

---

## 4. FEATURE ENGINEERING (15 Features)

| # | Feature | Calculation |
|---|---------|-------------|
| 1 | Returns | (close - prev) / prev |
| 2 | Log Returns | log(close / prev) |
| 3 | Range % | (high - low) / close |
| 4-6 | RSI M5/M15/H1 | RSI(14) / 100 |
| 7 | ATR Norm | ATR(14) / close |
| 8 | MA Distance | (close - MA20) / MA20 |
| 9 | BB Position | (close - mid) / width |
| 10 | Hurst | Rolling(100) |
| 11 | Entropy | Rolling(100) / 4 |
| 12 | Session | 0=Asia, 1=London, 2=NY |
| 13-14 | Hour Sin/Cos | Cyclic encoding |
| 15 | OB Distance | Dist to OB / ATR |

---

## 5. TOOLBOX REFERENCE

### Skills (.factory/skills/)

| Skill | Arquivo | Trigger |
|-------|---------|---------|
| CRUCIBLE | crucible-xauusd-expert.md | "Crucible", /setup |
| SENTINEL | sentinel-risk-guardian.md | "Sentinel", /risco |
| FORGE | forge-code-architect.md | "Forge", /codigo |
| ORACLE | oracle-backtest-commander.md | "Oracle", /backtest |
| ARGUS | argus-research-analyst.md | "Argus", /pesquisar |

### Droids (.factory/droids/)

| Droid | Model | Purpose |
|-------|-------|---------|
| deep-researcher | Opus | Academic research |
| onnx-model-builder | Sonnet | ML model building |
| project-reader | Sonnet | Codebase analysis |

### MCPs

| Category | Tools |
|----------|-------|
| Search | perplexity-search, brave-search |
| Docs | context7 |
| Code | github |
| Reasoning | sequential-thinking |
| RAG | mql5-docs, mql5-books |

---

## 6. WORKFLOWS

### Build/Code
1. Check PRD → 2. Identify files → 3. Read patterns → 4. Implement → 5. Test

### Research
1. Check Knowledge Base → 2. If not found, /research → 3. Triangulate → 4. Synthesize

### ML/ONNX
1. /singularity → 2. Define objective → 3. Features → 4. Architecture → 5. /build-onnx → 6. Validate WFE ≥ 0.6

### Validation
1. Backtest → 2. Monte Carlo (5000+) → 3. WFA (10+ windows) → 4. WFE ≥ 0.6? → 5. GO/NO-GO

---

## 7. PROJECT STRUCTURE

```
EA_SCALPER_XAUUSD/
├── MQL5/
│   ├── Experts/EA_SCALPER_XAUUSD.mq5
│   ├── Include/EA_SCALPER/
│   │   ├── Core/
│   │   ├── Analysis/
│   │   ├── Signal/
│   │   ├── Risk/
│   │   ├── Execution/
│   │   ├── Bridge/
│   │   └── Utils/
│   └── Models/
├── Python_Agent_Hub/
│   └── app/services/
├── DOCS/
│   ├── prd.md (SPEC COMPLETA)
│   └── CLAUDE_REFERENCE.md (este arquivo)
├── .factory/skills/ (AGENTES)
└── .rag-db/ (RAG databases)
```

---

## 8. CODING PATTERNS

### MQL5 Naming
```
Classes: CPascalCase
Methods: PascalCase()
Variables: camelCase
Constants: UPPER_SNAKE_CASE
Members: m_memberName
```

### Error Handling
```mql5
if(!trade.PositionOpen(...)) {
    int error = GetLastError();
    Print("Trade failed: ", error);
}
```

### Symbol Info
```mql5
double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
```

---

## 9. RAG DATABASES

### Books (.rag-db/books/) - 5,909 chunks
- mql5.pdf, mql5book.pdf
- neuronetworksbook.pdf (ML/ONNX)
- Algorithmic Trading (Hurst, Entropy)

### Docs (.rag-db/docs/) - 18,635 chunks
- MQL5 Reference
- CodeBase examples

### Query Pattern
```python
# Conceito? → books
query_rag("Hurst exponent", "books")

# Sintaxe? → docs
query_rag("OnnxRun parameters", "docs")
```

---

*Este arquivo e REFERENCIA. Para instrucoes, veja AGENTS.md*
