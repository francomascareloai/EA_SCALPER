# Checklists - ORACLE v2.2 (Institutional-Grade)

## 1. GO/NO-GO Master Checklist

### 1.1 AMOSTRA
```
□ Trades >= 100? (minimo absoluto)
□ Trades >= 200? (ideal)
□ Periodo >= 2 anos?
□ Inclui 2022 (bear market)?
□ Inclui 2023 (recovery)?
□ Inclui 2024 (atual)?
□ Diferentes regimes testados (bull, bear, sideways)?
□ Diferentes volatilidades (baixa, normal, alta)?
```

### 1.2 METRICAS CORE
```
□ Sharpe >= 1.5?
□ Sortino >= 2.0?
□ SQN >= 2.0?
□ Profit Factor >= 2.0?
□ Max DD <= 10%?
□ Win Rate 40-65%?
□ Average RR >= 1.5?
□ NENHUMA metrica com Red Flag?
```

### 1.3 WALK-FORWARD ANALYSIS
```
□ WFA executado?
□ Modo: Rolling ou Anchored definido?
□ N windows >= 10? (ideal 15)
□ Purge gap aplicado (2%)?
□ Embargo aplicado (1%)?
□ WFE calculado?
□ WFE >= 0.5? (minimo)
□ WFE >= 0.6? (ideal)
□ OOS positive >= 70%?
□ Consistencia entre janelas?
□ Sem degradacao ao longo do tempo?
```

### 1.4 MONTE CARLO BLOCK BOOTSTRAP
```
□ Monte Carlo executado?
□ N runs >= 5000?
□ Block bootstrap usado (nao shuffle simples)?
□ Block size otimo calculado?
□ 95th percentile DD calculado?
□ 95th DD <= 8%? (target)
□ 95th DD <= 10%? (minimo)
□ VaR 95% calculado?
□ CVaR 95% calculado?
□ P(Profit) >= 90%?
□ P(Ruin DD>10%) < 5%?
□ Median equity positivo?
```

### 1.5 OVERFITTING DETECTION
```
□ PSR (Probabilistic Sharpe) calculado?
□ PSR >= 0.90?
□ DSR (Deflated Sharpe) calculado?
□ Numero de trials informado para DSR?
□ DSR > 0?
□ PBO (Probability Backtest Overfitting) calculado?
□ PBO < 0.25? (ideal)
□ PBO < 0.50? (minimo)
□ MinTRL calculado?
□ N trades > MinTRL?
```

### 1.6 PROP FIRM (FTMO)
```
□ P(Daily DD > 5%) calculado?
□ P(Daily DD > 5%) < 5%?
□ P(Total DD > 10%) calculado?
□ P(Total DD > 10%) < 2%?
□ 10 losing streak simulado?
□ 10 losses DD < 5%?
□ Spread widening +50% testado?
□ Ainda lucrativo com spread +50%?
□ Risk per trade <= 1%?
```

### 1.7 EXECUTION COSTS
```
□ Slippage modelado?
□ Spread session-aware usado?
□ Latency considerada?
□ Order rejection simulada?
□ Modo PESSIMISTIC usado?
□ Metricas ainda passam com custos?
```

### 1.8 CONFIDENCE SCORE
```
□ WFA Component: ___/25
□ Monte Carlo Component: ___/25
□ Sharpe Component: ___/20
□ Prop Firm Component: ___/20
□ Level 4 Bonus: ___/10
□ Warnings Penalty: -___
□ TOTAL SCORE: ___/100
□ Score >= 70? (minimo para GO)
□ Score >= 85? (STRONG GO)
```

### RESULTADO FINAL
```
SCORE >= 85:  STRONG GO ✅ - Todos criterios com margem
SCORE 70-84:  GO ✅ - Criterios essenciais passam
SCORE 50-69:  INVESTIGATE ⚠️ - Revisar manualmente
SCORE < 50:   NO-GO ❌ - Nao prosseguir
```

---

## 2. 4-Level Robustness Testing Checklist

### LEVEL 1 - BASELINE (Obrigatorio para qualquer GO)
```
□ Out-of-Sample Testing (30% holdout genuino)?
□ Walk-Forward Analysis (15+ windows)?
□ WFE >= 0.5?
□ 200+ trades na amostra?
□ 2+ anos de dados historicos?
□ Diferentes regimes incluidos (bull, bear, sideways)?

LEVEL 1 RESULTADO: □ PASS  □ FAIL
```

### LEVEL 2 - ADVANCED (Recomendado para live trading)
```
□ PSR > 0.90?
□ DSR > 0?
□ PBO < 0.25?
□ Noise Test executado?
□ 80%+ performance mantida com ruido?
□ Multiplas janelas temporais testadas?
□ Monte Carlo 95th DD < 8%?

LEVEL 2 RESULTADO: □ PASS  □ FAIL
```

### LEVEL 3 - PROP FIRMS (Obrigatorio para FTMO)
```
□ P(Daily DD > 5%) < 5%?
□ P(Total DD > 10%) < 2%?
□ Spread widening +50% testado?
□ Ainda lucrativo com spread widening?
□ 10 losing streak simulado?
□ 10 losses nao viola DD?
□ Position sizing = max 1% risk?
□ Praticou em demo/free trial (1+ semana)?

LEVEL 3 RESULTADO: □ PASS  □ FAIL
```

### LEVEL 4 - INSTITUTIONAL (Para scaling)
```
□ CPCV (Combinatorial Purged CV)?
□ Multiple regime testing formal?
□ Stress scenarios testados (flash crash)?
□ Market impact simulado?
□ Execution costs EXTREME mode?
□ Slippage adverso com buffer?

LEVEL 4 RESULTADO: □ PASS  □ FAIL
```

### INTERPRETACAO
```
Level 1 PASS → Pode considerar paper trading
Level 1+2 PASS → Pode considerar demo
Level 1+2+3 PASS → Pode iniciar FTMO Challenge
Level 1+2+3+4 PASS → Institutional-grade, pronto para scaling
```

---

## 3. Anti-Overfitting Checklist (10 Pontos)

```
ANTES DE CONFIAR EM UM BACKTEST:

□ 1. Dados OOS genuinos (nunca vistos durante desenvolvimento)?
□ 2. WFA com WFE >= 0.6?
□ 3. Monte Carlo 95th DD < 8%?
□ 4. PSR > 0.90?
□ 5. DSR > 0 (ajustado por N testes)?
□ 6. PBO < 0.25?
□ 7. Numero de parametros <= 4?
□ 8. Mais de 200 trades na amostra?
□ 9. Mais de 2 anos de dados?
□ 10. Logica economica faz sentido (nao e curve-fit)?

CONTAGEM: ___/10

INTERPRETACAO:
- 10/10: Excelente - muito provavelmente robusto
- 8-9/10: Bom - provavelmente robusto
- 6-7/10: Marginal - investigar items faltantes
- < 6/10: SUSPEITO - alta chance de overfit
```

---

## 4. WFA Configuration Checklist

```
□ Modo selecionado?
  □ Rolling (recomendado para XAUUSD scalping)
  □ Anchored (para estrategias de longo prazo)

□ Parametros definidos?
  - n_windows: ___ (recomendado: 15, minimo: 10)
  - is_ratio: ___ (recomendado: 0.75)
  - overlap: ___ (recomendado: 0.20)
  - purge_gap: ___ (recomendado: 0.02 = 2%)
  - embargo_pct: ___ (recomendado: 0.01 = 1%)
  - min_trades_per_window: ___ (recomendado: 30)

□ Dados preparados?
  - Formato: datetime, pnl, direction
  - Sem gaps significativos
  - Periodo suficiente (>= 2 anos)

□ Execucao:
  python -m scripts.oracle.walk_forward \
    --input trades.csv \
    --mode rolling \
    --windows 15 \
    --purge 0.02 \
    --embargo 0.01

□ Resultados verificados?
  - WFE agregado: ___
  - WFE por janela: variacao aceitavel?
  - Windows OOS positivas: ___/%
  - Degradacao ao longo do tempo: □ SIM □ NAO
```

---

## 5. Monte Carlo Block Bootstrap Checklist

```
□ Dados de trades preparados?
  - Colunas: datetime, pnl (minimo)
  - Min 100 trades

□ Configuracao:
  - n_simulations: ___ (recomendado: 5000, minimo: 1000)
  - block_size: ___ (recomendado: auto = n^1/3)
  - initial_balance: ___ (recomendado: 100000)
  - seed: ___ (para reproducibilidade)

□ Execucao:
  python -m scripts.oracle.monte_carlo \
    --input trades.csv \
    --runs 5000 \
    --block-size auto

□ Outputs verificados:
  □ Median Final Equity: $___ (positivo?)
  □ 5th Percentile Equity: $___ (positivo?)
  □ 95th Percentile Max DD: ___% (< 8%?)
  □ 99th Percentile Max DD: ___% (< 10%?)
  □ VaR 95%: ___% (< 8%?)
  □ CVaR 95%: ___% (< 10%?)
  □ P(Profit): ___% (> 90%?)
  □ P(Ruin DD>10%): ___% (< 5%?)
```

---

## 6. Overfitting Detection Checklist (PSR/DSR/PBO)

### PSR (Probabilistic Sharpe)
```
□ Sharpe observado: ___
□ N trades: ___
□ Skewness: ___
□ Kurtosis: ___
□ PSR calculado: ___
□ PSR >= 0.90? □ SIM □ NAO
```

### DSR (Deflated Sharpe)
```
□ Quantos backtests/parametros testados? N = ___
□ E[max(SR)] para N trials: ___
□ DSR calculado: ___
□ DSR > 0? □ SIM □ NAO
□ Se DSR < 0: OVERFITTING CONFIRMADO!
```

### PBO (Probability of Backtest Overfitting)
```
□ Combinatorial Purged CV feito?
□ Correlacao rank IS vs OOS: ___
□ PBO calculado: ___
□ PBO < 0.25? □ SIM (baixo risco) □ NAO
□ PBO < 0.50? □ SIM (aceitavel) □ NAO

Se PBO > 0.50: ALTO RISCO DE OVERFIT!
```

### MinTRL (Minimum Track Record Length)
```
□ MinTRL calculado: ___ trades
□ N trades atual: ___
□ N trades > MinTRL? □ SIM □ NAO

Se N < MinTRL: Amostra INSUFICIENTE para conclusoes!
```

### Execucao
```
python -m scripts.oracle.deflated_sharpe \
  --input returns.csv \
  --trials [N_TRIALS]
```

---

## 7. Prop Firm Pre-Challenge Checklist (FTMO)

### VALIDACAO ESTATISTICA
```
□ GO/NO-GO checklist completo?
□ Todas metricas PASS?
□ WFA aprovado (WFE >= 0.6)?
□ Monte Carlo aprovado (95th DD < 8%)?
□ Overfitting descartado (PSR >= 0.90, DSR > 0)?
□ Confidence Score >= 70?
```

### VALIDACAO PROP FIRM ESPECIFICA
```
□ P(Daily DD > 5%) < 5%?
□ P(Total DD > 10%) < 2%?
□ 10 losing streak simulado?
□ 10 losses nao viola daily DD?
□ Spread widening +50% testado?
□ Ainda lucrativo com spreads altos?
□ Risk per trade <= 1%?
```

### PREPARACAO TECNICA
```
□ EA compilado sem erros?
□ EA testado em demo (1+ semana)?
□ VPS estavel configurado?
□ VPS latencia < 50ms para broker?
□ Broker correto selecionado (FTMO)?
□ Symbol = XAUUSD verificado?
□ Parametros IDENTICOS ao backtest aprovado?
□ CBacktestRealism.mqh desativado em live?
```

### RISK MANAGEMENT
```
□ Risk per trade definido: ___% (max 1%)
□ Max trades por dia: ___
□ Max daily DD interno: 4% (buffer antes de 5%)?
□ Max total DD interno: 8% (buffer antes de 10%)?
□ Circuit breakers ativos no EA?
□ Emergency mode testado?
□ Trailing DD desativado (FTMO nao usa)?
```

### TIMING
```
□ Comecar segunda-feira (nao sexta)?
□ Evitar semana de FOMC inicial?
□ Evitar semana de NFP inicial?
□ Primeiros dias: observar apenas?
□ Horario de trading definido (evitar Asian)?
```

### MENTAL
```
□ Preparado para drawdown?
□ Nao vai interferir manualmente?
□ Confianca no sistema validado?
□ Plano de contingencia se DD atingir 3%?
```

### TOTAL: ___/25
```
SE < 22 → NAO INICIAR CHALLENGE
```

---

## 8. Backtest Quality Checklist

### QUALIDADE DOS DADOS
```
□ Tick data ou OHLC de qualidade?
□ Fonte dos dados confiavel?
□ Spread realista incluido?
□ Spread variavel por sessao?
□ Slippage modelado?
□ Comissao incluida?
□ Swap/rollover considerado?
```

### EXECUCAO
```
□ Every tick ou Open prices? (usar: every tick)
□ Execution em close of bar?
□ Requote/rejection modelado?
□ Latencia considerada?
□ Partial fills considerados?
```

### PERIODO
```
□ >= 2 anos de dados?
□ Inclui volatilidade alta (2020, 2022)?
□ Inclui volatilidade baixa?
□ Diferentes regimes macro?
□ Inclui flash crashes?
□ Inclui news events importantes?
```

### CONFIGURACAO MT5
```
□ Modeling: Every tick based on real ticks?
□ Spread: Current ou Custom realista?
□ Commission: Igual ao broker real?
□ Initial deposit: $100,000?
□ Leverage: 1:30 (FTMO)?
□ CBacktestRealism mode: PESSIMISTIC?
```

---

## 9. Execution Simulation Checklist

### CONFIGURACAO
```
□ Modo selecionado?
  □ DEV (otimista - para desenvolvimento)
  □ VALIDATION (normal - para validacao)
  □ PESSIMISTIC (conservador - para FTMO)
  □ STRESS (extremo - para stress test)

□ Slippage configurado?
  - Base: ___ points (PESSIMISTIC: 5)
  - News mult: ___ (PESSIMISTIC: 10x)
  - Volatile mult: ___ (PESSIMISTIC: 3x)
  - Adverse only: □ SIM (recomendado)

□ Spread configurado?
  - Base: ___ points (PESSIMISTIC: 25)
  - News mult: ___ (PESSIMISTIC: 5x)
  - Asian mult: ___ (PESSIMISTIC: 3x)

□ Latency configurada?
  - Base: ___ ms (PESSIMISTIC: 100)
  - News latency: ___ ms (PESSIMISTIC: 500)
  - Max latency: ___ ms (PESSIMISTIC: 1500)
  - Spike prob: ___% (PESSIMISTIC: 15%)

□ Rejection configurada?
  - Base rejection: ___% (PESSIMISTIC: 10%)
```

### EXECUCAO
```
python -m scripts.oracle.execution_simulator \
  --input trades.csv \
  --mode pessimistic \
  --output trades_with_costs.csv
```

### VERIFICACAO
```
□ Total cost medio: ___ points/trade
□ Rejection rate: ___%
□ Metricas recalculadas com custos
□ Sharpe com custos: ___ (ainda >= 1.5?)
□ DD com custos: ___ (ainda <= 10%?)
□ PF com custos: ___ (ainda >= 2.0?)
```

---

## 10. Bias Detection Checklist

### 1. SURVIVORSHIP BIAS
```
□ Incluiu simbolos que nao existem mais?
□ Testou em periodo onde ativo existia?
□ Filtrou apenas winners historicos?
```

### 2. LOOK-AHEAD BIAS
```
□ Sem uso de dados futuros?
□ Indicadores calculados corretamente (nao repaint)?
□ Execucao em bar close, nao intra-bar?
□ Sem acesso a precos futuros em calculo?
```

### 3. DATA MINING BIAS
```
□ Quantas variacoes testadas? ___
□ DSR calculado com N correto?
□ Correcao de multiplos testes aplicada?
□ PBO < 0.25?
```

### 4. OVERFITTING
```
□ Numero de parametros razoavel (<= 4)?
□ WFE >= 0.6?
□ OOS performance >= 60% da IS?
□ Logica economica faz sentido?
```

### 5. SELECTION BIAS
```
□ Periodo nao cherry-picked?
□ Inclui diferentes condicoes de mercado?
□ Bear + Bull + Sideways?
□ Nao selecionou apenas periodo favoravel?
```

### 6. PUBLICATION BIAS
```
□ Reportou TODOS os testes (nao so os bons)?
□ Nao escondeu resultados ruins?
□ Documentacao completa?
□ N trials reportado honestamente?
```

---

## 11. FTMO Daily DD Calculation Checklist

```
IMPORTANTE: FTMO usa EQUITY, nao BALANCE!

□ Entendo que floating losses CONTAM?
□ Entendo que reset e meia-noite Prague Time?
□ Entendo que equity = balance + floating?

CALCULO:
Start_of_Day_Balance: $___
Current_Equity: $___
Initial_Balance: $100,000

Daily_DD = (Start - Current_Equity) / Initial * 100
Daily_DD = ($___ - $___)  / $100,000 * 100
Daily_DD = ___%

□ Daily DD < 5%? (limite absoluto)
□ Buffer de seguranca: DD < 4%?

EXEMPLO CRITICO:
Balance: $102,000
Floating Loss: -$4,000
Equity: $98,000

Daily DD = ($102,000 - $98,000) / $100,000 = 4%

SE floating for mais -$1,000:
Equity = $97,000
Daily DD = 5% → VIOLACAO!

□ Entendo que MESMO SEM FECHAR, ja viola?
```

---

## 12. Confidence Score Calculation Checklist

### COMPONENTES
```
WFA Component (25 pontos max):
□ WFE >= 0.6? → 25 pontos
□ WFE 0.5-0.6? → 15 pontos
□ WFE < 0.5? → 0 pontos
PONTOS WFA: ___/25

Monte Carlo Component (25 pontos max):
□ 95th DD < 6%? → 25 pontos
□ 95th DD 6-8%? → 20 pontos
□ 95th DD 8-10%? → 10 pontos
□ 95th DD > 10%? → 0 pontos
□ P(ruin) < 2%? → +5 bonus (se DD ok)
PONTOS MC: ___/25

Sharpe Component (20 pontos max):
□ PSR >= 0.95? → 10 pontos
□ PSR 0.90-0.95? → 7 pontos
□ PSR < 0.90? → 0 pontos
□ DSR > 1.0? → 10 pontos
□ DSR 0-1.0? → 7 pontos
□ DSR < 0? → 0 pontos (e WARNING)
PONTOS SHARPE: ___/20

Prop Firm Component (20 pontos max):
□ P(daily > 5%) < 2%? → 10 pontos
□ P(daily > 5%) 2-5%? → 7 pontos
□ P(daily > 5%) > 5%? → 0 pontos
□ P(total > 10%) < 1%? → 10 pontos
□ P(total > 10%) 1-2%? → 7 pontos
□ P(total > 10%) > 2%? → 0 pontos
PONTOS PROPFIRM: ___/20

Level 4 Bonus (10 pontos max):
□ Todos criterios Level 4 passam? → 10 pontos
PONTOS BONUS: ___/10

Warnings (Penalidade):
□ Numero de warnings: ___
□ Penalidade: ___ x -5 = -___
PENALIDADE: -___
```

### CALCULO FINAL
```
SCORE = WFA + MC + SHARPE + PROPFIRM + BONUS - WARNINGS
SCORE = ___ + ___ + ___ + ___ + ___ - ___
SCORE = ___/100
```

### DECISAO
```
□ SCORE >= 85: STRONG GO ✅
□ SCORE 70-84: GO ✅
□ SCORE 50-69: INVESTIGATE ⚠️
□ SCORE < 50: NO-GO ❌

DECISAO FINAL: ________________
```

---

*ORACLE v2.2 Checklists - Institutional-Grade Validation*
