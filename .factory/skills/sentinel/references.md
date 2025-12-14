# References - SENTINEL

## MCPs Primarios

| MCP | Uso | Frequencia |
|-----|-----|------------|
| calculator | Kelly, lot size, DD %, formulas | Alta |
| postgres | Trade history, equity curve, DD tracking | Alta |
| memory | Estados de risco, circuit breaker | Alta |
| twelve-data | Preco atual para calculos | Media |
| time | Sessoes, reset diario, news timing | Media |
| mql5-books | Van Tharp, Kelly, position sizing | Media |
| mql5-docs | AccountInfo, PositionGet funcoes | Media |
| perplexity | FTMO rules atualizadas | Baixa |

---

## Arquivos do Projeto (Risk Code)

| Arquivo | Descricao |
|---------|-----------|
| `Risk/FTMO_RiskManager.mqh` | Compliance FTMO (261 linhas) |
| `Risk/CDynamicRiskManager.mqh` | Ajuste dinamico por performance |
| `Safety/CCircuitBreaker.mqh` | Circuit breaker states |
| `Safety/CSpreadMonitor.mqh` | Spread monitoring |
| `Bridge/CMemoryBridge.mqh` | RiskModeSelector |
| `Analysis/CRegimeDetector.mqh` | Regime → size multiplier |
| `Analysis/CSessionFilter.mqh` | Sessao → risk adjustment |
| `Analysis/CNewsFilter.mqh` | News → block trades |

---

## FTMO Rules Oficiais ($100k)

### Limites de Drawdown
| Limite | Valor | Nosso Buffer |
|--------|-------|--------------|
| Max Daily Loss | 5% ($5,000) | Trigger: 4% |
| Max Total Loss | 10% ($10,000) | Trigger: 8% |
| HARD STOP Daily | 4.5% | Emergencia |
| HARD STOP Total | 9% | Emergencia |

### Profit Targets
| Fase | Target |
|------|--------|
| Challenge (P1) | 10% ($10,000) |
| Verification (P2) | 5% ($5,000) |
| FTMO Account | Sem target (consistencia) |

### Regras de Tempo
| Regra | Detalhe |
|-------|---------|
| Min Trading Days | 4 dias |
| Max Time | Ilimitado |
| News Trading | 2 min antes/depois = PROIBIDO |
| Weekend | Fechar ANTES de sexta close |
| Gap > 2h | Nao segurar posicoes |

### Limites Tecnicos
| Limite | Valor |
|--------|-------|
| Max ordens simultaneas | 200 |
| Max posicoes por dia | 2,000 |
| Max lot por ordem (Forex) | 50 |

---

## Position Sizing Formulas

### Formula Base
```
Lot = (Equity × Risk%) / (SL_pips × Tick_Value)

Exemplo XAUUSD:
Equity: $100,000
Risk: 0.5%
SL: 35 pips
Tick Value: $10/pip
Lot = ($100,000 × 0.005) / (35 × $10) = 1.43 lots
```

### Kelly Criterion
```
f* = (b × p - q) / b

Onde:
b = Avg Win / Avg Loss (R:R)
p = Win Rate
q = Loss Rate (1 - p)
f* = Fracao otima do capital
```

### Fractional Kelly
| Kelly % | Risk | Uso |
|---------|------|-----|
| 100% | Teorico | Suicida |
| 50% | Alto | Agressivo demais |
| 25% | Conservador | Recomendado |
| 10% | Ultra safe | Ideal para FTMO |

> **Van Tharp**: "25% risk da melhor reward-to-risk MAS voce teria que tolerar 84% drawdown!"

### Multiplicadores de Ajuste
| Fator | Multiplicador |
|-------|---------------|
| Regime PRIME | ×1.0 |
| Regime NOISY | ×0.5 |
| Regime RANDOM | ×0.0 |
| DD Warning (2-3%) | ×0.85 |
| DD Caution (3-4%) | ×0.5 |
| DD Soft Stop (4%+) | ×0.0 |
| Loss Streak (3+) | ×0.5 |
| ML Confidence ≥0.80 | ×1.25 |
| ML Confidence ≥0.70 | ×1.00 |
| ML Confidence ≥0.65 | ×0.75 |
| ML Confidence <0.55 | ×0.00 |

---

## Circuit Breaker Detalhado

### Levels
| Level | DD | Size | Acao |
|-------|----|----- |------|
| 0 NORMAL | < 2% | 100% | Operar normalmente |
| 1 WARNING | 2-3% | 100% | Aumentar vigilancia |
| 2 CAUTION | 3-4% | 50% | Apenas Tier A/B |
| 3 SOFT STOP | 4-4.5% | 0% | Gerenciar existentes |
| 4 EMERGENCY | ≥ 4.5% | 0% | Fechar tudo |

### Total DD Triggers (Paralelo)
| DD Total | Acao |
|----------|------|
| 5% | Warning |
| 8% | Soft Stop |
| 9% | Emergency |

---

## Recovery Mode

### Quando Ativa
- DD > 5% total
- 5+ losses consecutivas
- Circuit breaker Level 3+

### Progressao
| Fase | Risk | Setups | Saida |
|------|------|--------|-------|
| 1 | 0.25% | Tier A only | 3 wins seguidos |
| 2 | 0.35% | Tier A/B | 3 wins seguidos |
| 3 | 0.50% | Normal | DD < 3% + 5 wins/7 |

---

## Loss Streak Management

| Losses | Status | Cooldown | Size |
|--------|--------|----------|------|
| 2 | Normal | - | 100% |
| 3 | Alerta | 1 hora | 75% |
| 4 | Cautela | 2 horas | 50% |
| 5+ | Parar | Resto do dia | 0% |

### Review Questions
1. Mercado mudou de regime?
2. Estrategia ainda valida?
3. Execucao foi correta?
4. Spread/slippage afetou?
5. Emocao influenciou?

---

## Time-Based Risk

### News Risk
| Tempo | Acao |
|-------|------|
| 30 min antes HIGH | Cautela |
| 2 min antes/depois | BLOQUEADO (FTMO) |
| Durante news | Nao operar |
| 15 min depois | Normalizar |

### Sexta-feira
| Horario GMT | Acao |
|-------------|------|
| Manha | Normal |
| 14:00+ | Reduzir novas |
| 16:00+ | Fechar posicoes |
| Weekend | ZERO posicoes (FTMO) |

### Sessoes
| Sessao | Risco |
|--------|-------|
| Asia | CAUTELA (spread alto) |
| London | Normal |
| NY | Normal |
| Overlap | IDEAL |
| Late NY (21:00+) | CAUTELA |

---

## Position Correlation Risk

### Regras
- Max 3 posicoes simultaneas XAUUSD
- Exposure combinado ≤ 3% equity
- Direcoes iguais: somar risk
- Direcoes opostas: hedge parcial

### Formula Exposure
```
TotalExposure = Σ(LotSize × TickValue × SL_pips)
RiskPercent = TotalExposure / Equity × 100
LIMITE: RiskPercent ≤ 3%
```

---

## State Machine (MQL5 Pseudo-code)

```cpp
enum RiskState {
    STATE_NORMAL,      // DD < 3%
    STATE_CAUTION,     // 3% <= DD < 4%
    STATE_RESTRICTED,  // 4% <= DD < 5%
    STATE_BLOCKED,     // DD >= 5%
    STATE_RECOVERY     // Saindo de DD alto
};

double GetSizeMultiplier(RiskState state, int recoveryPhase) {
    switch(state) {
        case STATE_NORMAL:     return 1.00;
        case STATE_CAUTION:    return 0.75;
        case STATE_RESTRICTED: return 0.50;
        case STATE_BLOCKED:    return 0.00;
        case STATE_RECOVERY:
            if(recoveryPhase == 1) return 0.25;
            if(recoveryPhase == 2) return 0.50;
            if(recoveryPhase == 3) return 0.75;
    }
    return 1.00;
}
```

---

## Handoffs

| De/Para | Quando | Trigger |
|---------|--------|---------|
| ← CRUCIBLE | Antes de trade | "calcular lot", "posso operar" |
| ← ORACLE | Validar estrategia | "max DD aceitavel" |
| → FORGE | Implementar | "implementar risk rules" |
