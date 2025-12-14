# Checklists - SENTINEL

## FTMO Compliance Checklist

```
VERIFICACAO DIARIA:

DRAWDOWN:
□ Daily DD < 5%? (atual: ___%)
□ Total DD < 10%? (atual: ___%)
? DD_cenario (DD + risco aberto) < Envelope diario (4%)? (atual: ___%)
□ Buffer total > 2%? (atual: ___%)

POSICOES:
? Todas as posicoes com SL definido?
? Risco aberto total < Envelope diario (4%)?
? Correlacao/verificacao de concentracao OK?
? Sexta: Fechou antes do weekend?

NEWS:
□ Verificou calendario hoje?
□ Nao operou 2min antes/depois de HIGH?
□ Posicoes protegidas durante news?

TEMPO:
□ Min 4 dias de trading cumprido?
□ Gaps > 2h: Posicoes fechadas?

STATUS: [COMPLIANT / VIOLATION RISK / VIOLATED]
```

---

## Pre-Trade Risk Checklist

```
ANTES DE CADA TRADE:

DRAWDOWN:
? DD_cenario atual permite novo trade?
□ Circuit breaker permite (Level 0-2)?
□ Buffer suficiente para SL?

POSITION SIZING:
□ Lot CALCULADO (nao adivinhado)?
□ Risk % dentro do limite (0.5-1%)?
□ Multiplicadores aplicados (regime, DD, ML)?

EXPOSURE:
? Risco da nova ideia + risco aberto <= Envelope diario?
? Correlacao verificada?
? Exposure total (DD_cenario) < Envelope diario?

TIMING:
□ Nao e pre-news (30min)?
□ Nao e sexta tarde (14:00+ GMT)?
□ Sessao apropriada (nao Asia)?

RESULTADO: [GO / REDUCE SIZE / NO GO]
```

---

## Recovery Mode Checklist

```
ENTRADA EM RECOVERY:
□ DD > 5% total?
□ OU 5+ losses consecutivas?
□ OU circuit breaker Level 3+?
□ Review de trades feito?
□ Causa identificada?

DURANTE RECOVERY (FASE 1):
□ Risk reduzido para 0.25%?
□ Apenas setups Tier A?
□ Max 2 trades por dia?
□ Review apos CADA trade?

PROGRESSAO FASE 1 → 2:
□ 3 wins consecutivos?
□ DD estabilizado?
□ Confianca restaurada?

PROGRESSAO FASE 2 → 3:
□ 3 wins consecutivos (0.35% risk)?
□ DD < 4%?

SAIDA DE RECOVERY:
□ DD < 3%?
□ 5 wins em ultimos 7 trades?
□ 3 wins consecutivos em Fase 3?

STATUS: [FASE 1 / FASE 2 / FASE 3 / EXIT]
```

---

## Circuit Breaker Checklist

```
VERIFICACAO DE STATUS:

LEVEL 0 - NORMAL (DD < 2%):
□ Operando normalmente
□ Size 100%
□ Sem restricoes

LEVEL 1 - WARNING (DD_cenario 2-3%):
□ Aumentar vigilancia
□ Size ainda 100%
□ Alertas ativos

LEVEL 2 - CAUTION (DD_cenario 3-3.8%):
□ Size REDUZIDO para 50%
□ Apenas Tier A/B
□ Priorizar preservacao
□ Review obrigatorio

LEVEL 3 - SOFT STOP (DD_cenario 3.8-4% aprox.):
□ ZERO novos trades
□ Gerenciar existentes apenas
□ Proteger buffer restante
□ Preparar para recovery

LEVEL 4 - EMERGENCY (DD_cenario >= 4% ou Daily DD >=4.5%):
□ FECHAR todas posicoes
□ Proteger os 0.5% restantes
□ Nao operar mais hoje
□ Review profundo obrigatorio

TRANSICAO PARA RECOVERY:
□ DD estabilizou?
□ Pelo menos 3 wins?
□ Protocolo de recovery iniciado?
```

---

## Loss Streak Checklist

```
APOS CADA LOSS:

2 LOSSES:
□ Status: Normal
□ Acao: Monitorar
□ Size: Manter 100%

3 LOSSES:
□ Status: Alerta
□ Acao: Cooldown 1 hora
□ Size: Reduzir para 75%
□ Review: Por que 3 perdas?

4 LOSSES:
□ Status: Cautela
□ Acao: Cooldown 2 horas
□ Size: Reduzir para 50%
□ Review: Obrigatorio antes de continuar

5+ LOSSES:
□ Status: PARAR
□ Acao: Parar por HOJE
□ Size: 0%
□ Review: Deep analysis

PERGUNTAS DO REVIEW:
□ 1. Mercado mudou de regime?
□ 2. Estrategia ainda valida?
□ 3. Execucao foi correta?
□ 4. Spread/slippage afetou?
□ 5. Emocao influenciou?
□ 6. Horario era adequado?
□ 7. News impactou?
```

---

## Position Size Validation

```
ANTES DE SUBMETER ORDEM:

FORMULA VERIFICADA:
□ Lot = (Equity × Risk%) / (SL_pips × Tick_Value)

MULTIPLICADORES APLICADOS:
□ Regime: ×___ (PRIME=1.0, NOISY=0.5, RANDOM=0)
□ DD: ×___ (Normal=1.0, Warning=0.85, Caution=0.5)
□ Circuit: ×___ (L0-1=1.0, L2=0.5, L3+=0)
□ ML Confidence: ×___ (>=0.80=1.25, >=0.70=1.0, etc)
□ Loss Streak: ×___ (3+=0.5)

LOT FINAL: ___

VALIDACOES:
□ Lot >= Min broker?
□ Lot <= Max broker?
□ Lot <= Max permitido interno?
□ Step size correto?
□ Risk em $ calculado?
□ Risk % < limite?

APROVADO: [SIM / NAO - MOTIVO]
```

---

## Stress Test Checklist

```
CENARIOS A TESTAR:

GAP ADVERSO:
□ Se gap de 50 pips contra, DD fica em ___%
□ Dentro do limite FTMO? [SIM/NAO]

LOSS STREAK:
□ Se 5 losses seguidos, DD fica em ___%
□ Dentro do limite FTMO? [SIM/NAO]

SLIPPAGE:
□ Se slippage de 10 pips em cada trade, impacto ___%
□ Aceitavel? [SIM/NAO]

SPREAD SPIKE:
□ Se spread triplicar, impacto no trade ___%
□ SL ainda adequado? [SIM/NAO]

NEWS SPIKE:
□ Se movimento de 100 pips em 5 min, DD ___%
□ Posicoes protegidas? [SIM/NAO]

RESULTADO STRESS TEST: [PASS / FAIL - AJUSTES]
```

