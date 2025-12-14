---
name: forge-nano
description: |
  FORGE NANO v3.1 - Compact mode for Party Mode sessions (~4KB vs 50KB full).
  Use when: Multi-agent sessions, context is limited, quick code tasks.
  
  ESSENTIALS ONLY:
  - 7 checks + trading math verification
  - Top 10 anti-patterns + top 5 bug patterns
  - Auto-compile command
  - Smart handoffs
  - Complexity check trigger
  
  For FULL capabilities, use: forge-code-architect (SKILL.md)

  Triggers: "Forge nano", "quick code", "party mode forge"
---

# FORGE NANO v3.1 - Genius Compact Edition

> Para sessoes multi-agente com contexto limitado.

---

## Quick Reference

### 7 Checks (ANTES de entregar codigo)

```
□ 1. Error handling? (OrderSend, CopyBuffer verificados)
□ 2. Bounds & Null? (arrays, pointers, handles)
□ 3. Division by zero? (guards em todas divisoes)
□ 4. Resources? (delete, IndicatorRelease)
□ 5. FTMO? (DD check, position size)
□ 6. Regression? (grep por dependentes)
□ 7. Bug patterns? (BP-01 a BP-12)

SE FALHAR: Corrigir antes de mostrar
MARK: // ✓ FORGE v3.0: 7/7 checks
```

---

## Top 10 Anti-Patterns

| ID | Pattern | Fix Rapido |
|----|---------|------------|
| AP-01 | OrderSend sem check | `if(!OrderSend(...)) handle()` |
| AP-02 | CopyBuffer sem Series | `ArraySetAsSeries(arr,true)` ANTES |
| AP-03 | Lot sem normalize | `NormalizeLot(lot)` |
| AP-04 | Divisao sem zero | `(d!=0) ? a/d : 0` |
| AP-05 | Array sem bounds | `if(i < ArraySize(arr))` |
| AP-06 | Handle invalido | `if(handle == INVALID_HANDLE) return` |
| AP-07 | New sem delete | Sempre `delete` + `= NULL` |
| AP-08 | Print em OnTick | Rate limit ou remover |
| AP-09 | DD com Balance | Usar EQUITY, nao Balance |
| AP-10 | Retry ausente | Max 3 retries com RefreshRates |

---

## Auto-Compile

```powershell
# Compilar EA
Start-Process -FilePath "C:\Program Files\FTMO MetaTrader 5\metaeditor64.exe" `
  -ArgumentList '/compile:"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MQL5\Experts\EA_SCALPER_XAUUSD.mq5"','/inc:"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MQL5"','/inc:"C:\Program Files\FTMO MetaTrader 5\MQL5"','/log' `
  -Wait -NoNewWindow

# Verificar resultado
Get-Content "C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MQL5\Experts\EA_SCALPER_XAUUSD.log" -Encoding Unicode | Select-String "error|warning|Result"
```

**REGRA**: Compilar AUTOMATICAMENTE apos qualquer mudanca MQL5.

---

## Handoffs

### → ORACLE (apos changes)
```
🔮 HANDOFF → ORACLE
RESUMO: [1 frase]
ARQUIVOS: [lista]
RISCO: [o que pode quebrar]
PEDIDO: Backtest rapido
```

### → SENTINEL (risk changes)
```
🛡️ HANDOFF → SENTINEL
RESUMO: [mudanca em risco]
VALORES: old → new
PEDIDO: Verificar FTMO
```

---

## Modulos Criticos (NAO MODIFICAR SEM CUIDADO)

| Modulo | Criticidade | Motivo |
|--------|-------------|--------|
| Definitions.mqh | MAXIMA | Todos dependem |
| FTMO_RiskManager.mqh | MAXIMA | FTMO compliance |
| CTradeManager.mqh | ALTA | Gerencia posicoes |
| TradeExecutor.mqh | ALTA | Executa ordens |
| CConfluenceScorer.mqh | MEDIA | Agrega sinais |

---

## Bug Patterns Criticos

| ID | Modulo | Cuidado |
|----|--------|---------|
| BP-02 | Varios | ATR handle SEMPRE validar |
| BP-05 | RiskManager | Division by zero em equity |
| BP-06 | TradeManager | SL/TP direcao |
| BP-07 | TradeExecutor | Spread/freeze |

---

## FTMO Limites (HARDCODED)

```
Daily DD: 5% ($5,000) → Buffer: 4%
Total DD: 10% ($10,000) → Buffer: 8%
Risk/trade: 0.5-1% max
VIOLACAO = CONTA TERMINADA
```

---

## Naming Quick Reference

```mql5
class CMyClass { };      // Classes: CPascalCase
double m_memberVar;      // Membros: m_prefix
ENUM_MY_ENUM { };        // Enums: ENUM_ prefix
#define MY_CONST 100     // Constantes: UPPER_CASE
```

---

## Performance Targets

```
OnTick total: < 50ms
ONNX inference: < 5ms
Indicator calc: < 10ms
```

---

*Para capabilities completas: .factory/skills/forge/SKILL.md*

// ✓ FORGE NANO v3.0 - Compact Mode
