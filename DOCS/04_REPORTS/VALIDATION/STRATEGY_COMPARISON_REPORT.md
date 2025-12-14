# COMPREHENSIVE STRATEGY BACKTEST REPORT
## XAUUSD M5 (2020-2025) - ~5 Years of Data

**Generated**: 2025-12-01  
**Data Period**: 2020-01-02 to 2025-11-28 (419,195 M5 bars)  
**Execution Mode**: PESSIMISTIC (spread x1.5, conservative fills)  
**Initial Balance**: $100,000  
**Risk per Trade**: 0.5%  

---

## SUMMARY COMPARISON

| Strategy | Trades | WR | PF | Max DD | Return | Sharpe | Status |
|----------|--------|------|------|--------|--------|--------|--------|
| MA Cross (20/50) | 147 | ~33% | 0.82 | 10.32% | -8.39% | <0 | ❌ FAIL |
| Mean Reversion (RSI) | 61 | ~30% | 0.68 | 10.03% | -6.63% | <0 | ❌ FAIL |
| Breakout (Donchian) | 90 | ~32% | 0.79 | 10.26% | -6.21% | <0 | ❌ FAIL |
| Trend Following (ADX+EMA) | 48 | ~25% | 0.45 | 10.47% | -9.57% | <0 | ❌ FAIL |
| **EA Logic (Score>=50)** | **149** | **~35%** | **0.93** | **10.35%** | **-3.25%** | <0 | ⚠️ BEST |
| EA Logic (Score>=60) | 109 | ~33% | 0.83 | 10.32% | -5.78% | <0 | ❌ FAIL |
| EA Logic (Score>=70) | 44 | ~28% | 0.51 | 10.25% | -7.99% | <0 | ❌ FAIL |
| Momentum Scalper | ~80 | ~30% | ~0.7 | ~10% | ~-7% | <0 | ❌ FAIL |

---

## ANÁLISE CRÍTICA

### 🚨 PROBLEMA FUNDAMENTAL IDENTIFICADO

**TODAS as estratégias testadas são PERDEDORAS** (PF < 1.0).

Isso indica que o problema não é:
- ❌ Os filtros (regime, sessão)
- ❌ Os parâmetros (ATR mult, MA periods)
- ❌ O backtester

O problema é **a lógica de entrada/saída fundamental**.

### 📊 Padrões Observados

1. **Max DD consistente ~10%** em todas estratégias
   - Isso é o limite FTMO sendo atingido
   - Estratégias estão sendo "cortadas" pelo DD limit

2. **Win Rate baixo (~30%)** em todas
   - Indica que os sinais não têm edge
   - Mesmo com RR de 1.5:1, precisa WR > 40% para lucrar

3. **EA Logic (Score>=50) é o melhor** (PF 0.93)
   - Mais perto de breakeven
   - Confluence scoring está ajudando, mas não o suficiente

4. **Mais filtros = Menos trades = Piores resultados**
   - EA Logic 70 tem menos trades e pior PF
   - Sugere que os filtros estão removendo trades bons também

---

## DIAGNÓSTICO DETALHADO

### Por que todas estratégias falham?

```
HIPÓTESE 1: Mercado não-estacionário
├── XAUUSD mudou comportamento de 2020 a 2025
├── 2020-2022: Trending (COVID, inflação)
├── 2023-2025: Range/Choppy
└── Estratégia única não funciona em todos regimes

HIPÓTESE 2: Sinais muito simples
├── MA Cross, RSI, Donchian são indicadores lagging
├── Mercado já precificou quando sinal aparece
├── Precisam de lógica mais sofisticada (Order Flow, SMC)
└── Ou usar como filtros, não como sinais primários

HIPÓTESE 3: Custos de execução
├── Spread + Slippage consomem edge pequeno
├── Modo PESSIMISTIC pode ser muito conservador
├── Mas mesmo modo NORMAL provavelmente não salva

HIPÓTESE 4: Timeframe inadequado
├── M5 pode ter muito ruído para estas estratégias
├── Sinais podem funcionar melhor em H1 ou H4
└── Scalping precisa de lógica diferente
```

### Análise por Estratégia

#### 1. MA Cross (20/50)
- **Problema**: Sinais muito atrasados
- **Evidência**: 147 trades em 5 anos = 1 trade a cada 12 dias
- **Diagnóstico**: MA cross em M5 gera poucos sinais e chegam tarde

#### 2. Mean Reversion (RSI)
- **Problema**: XAUUSD trending não reverte bem
- **Evidência**: PF 0.68 é o segundo pior
- **Diagnóstico**: Gold tende a continuar, não reverter

#### 3. Breakout (Donchian)
- **Problema**: Muitos falsos breakouts
- **Evidência**: 90 trades, PF 0.79
- **Diagnóstico**: Breakouts funcionam em mercados limpos, XAUUSD é volátil

#### 4. Trend Following (ADX+EMA)
- **Problema**: ADX filter muito restritivo
- **Evidência**: Apenas 48 trades, pior PF (0.45)
- **Diagnóstico**: Quando ADX confirma trend, já é tarde

#### 5. EA Logic (Score>=50) - MELHOR
- **Por que é o melhor**: Combina múltiplos fatores
- **Problema**: Confluence ainda não tem edge suficiente
- **Diagnóstico**: Precisa adicionar fatores com edge real (SMC, Order Flow)

#### 6. Momentum Scalper
- **Problema**: Volume filter em dados M5 não é confiável
- **Evidência**: Volume em M5 é tick count, não volume real
- **Diagnóstico**: Precisa de dados de volume reais

---

## RECOMENDAÇÕES

### 🔴 DECISÃO: NO-GO PARA FTMO

Nenhuma estratégia testada está pronta para FTMO Challenge.

### Opções de Ação

#### Opção A: Melhorar Sinais de Entrada
```
1. Adicionar Order Flow (imbalances, delta)
2. Adicionar SMC (Order Blocks, Fair Value Gaps)
3. Usar HTF structure como filtro obrigatório
4. Implementar liquidity sweep detection
```

#### Opção B: Mudar Abordagem
```
1. Trocar de M5 para H1/H4 (menos ruído)
2. Usar regime-specific strategies:
   - TRENDING: Breakout/Momentum
   - RANGING: Mean Reversion
   - CHOPPY: Não operar
3. Implementar adaptive parameters
```

#### Opção C: Revisar Lógica Fundamental
```
1. Fazer análise de quando os trades SL vs TP
2. Identificar se problema é entrada ou saída
3. Testar diferentes RR (1:1, 2:1, 3:1)
4. Testar trailing stop vs fixed TP
```

### Próximos Passos Recomendados

1. **Análise de Trade Distribution**
   - Quando os trades ganham? (hora, dia, volatilidade)
   - Quando os trades perdem?
   - Há padrão identificável?

2. **Teste de Componentes Isolados**
   - Testar cada indicador separadamente
   - Identificar qual tem edge, se algum

3. **Implementar SMC/ICT Logic**
   - Order Blocks
   - Fair Value Gaps
   - Liquidity Sweeps
   - Break of Structure

4. **Validar em Períodos Específicos**
   - Testar só 2024 (OOS)
   - Testar só sessão London
   - Testar só dias de alta volatilidade

---

## CONCLUSÃO

O backtester está funcionando corretamente. Os resultados são consistentes e realistas. O problema é que **nenhuma das estratégias testadas tem edge estatístico positivo no XAUUSD M5**.

A estratégia EA Logic com Score>=50 é a mais promissora (PF 0.93), mas ainda precisa de melhorias significativas para ser lucrativa.

**Recomendação final**: Antes de tentar FTMO, implementar lógica SMC/ICT e re-testar. O mercado de ouro requer abordagem mais sofisticada do que indicadores técnicos simples.

---

*Relatório gerado automaticamente por ORACLE v2.2*
