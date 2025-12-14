# Walk-Forward Analysis (WFA) Methodology

> Para: EA_SCALPER_XAUUSD - ORACLE Validation
> Status: Padrao Ouro de validacao

---

## 1. O Que E WFA?

Walk-Forward Analysis simula o cenario REAL: otimizar no passado, operar no futuro.

### Conceito

```
┌─────────────────────────────────────────────────────────────────┐
│                    WALK-FORWARD ANALYSIS                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Window 1: |====IS====|==OOS==|                                 │
│  Window 2:    |====IS====|==OOS==|                              │
│  Window 3:       |====IS====|==OOS==|                           │
│  Window 4:          |====IS====|==OOS==|                        │
│  ...                                                            │
│  Window N:                      |====IS====|==OOS==|            │
│                                                                 │
│  IS = In-Sample (otimizacao)                                    │
│  OOS = Out-of-Sample (teste)                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Formula do WFE

```
WFE (Walk-Forward Efficiency) = Performance_OOS / Performance_IS

Onde:
- Performance_OOS = Media da performance nas janelas Out-of-Sample
- Performance_IS = Media da performance nas janelas In-Sample
```

### Interpretacao

| WFE | Interpretacao | Acao |
|-----|---------------|------|
| >= 0.6 | **APROVADO** | Pode prosseguir |
| 0.5-0.6 | **MARGINAL** | Revisar estrategia |
| 0.4-0.5 | **SUSPEITO** | Simplificar |
| < 0.4 | **REJEITADO** | Refazer estrategia |

---

## 3. Tipos de WFA

### Rolling (Anchored Start)

```
Window 1: [----IS----][OOS]
Window 2:    [----IS----][OOS]
Window 3:       [----IS----][OOS]

- Janela de tamanho FIXO que "rola"
- Mais sensivel a mudancas recentes
- Bom para mercados que mudam
```

### Anchored (Fixed Start)

```
Window 1: [IS][OOS]
Window 2: [---IS---][OOS]
Window 3: [-----IS-----][OOS]

- IS sempre comeca do mesmo ponto
- IS cresce a cada janela
- Mais estavel, menos adaptativo
```

### Recomendacao

| Mercado | Tipo | Motivo |
|---------|------|--------|
| XAUUSD (volátil) | Rolling | Regimes mudam |
| Indices estáveis | Anchored | Mais dados = melhor |
| Criptomoedas | Rolling curto | Muito volatil |

---

## 4. Configuracao Recomendada

```
CONFIGURACAO PADRAO:

- Numero de janelas: 10-20
- Split IS/OOS: 70/30 ou 80/20
- Periodo minimo total: 2 anos
- Trades por janela: Minimo 10 (ideal 20+)

PARA XAUUSD M5:
- Janelas: 12 (1 mes OOS cada)
- IS: 3 meses
- OOS: 1 mes
- Total: 16 meses de dados
```

---

## 5. Purged Cross-Validation

### Problema

Em series temporais, dados de treino e teste podem estar correlacionados (data leakage).

**Exemplo de Leakage:**
- Trade em t usa dados ate t-1
- Se IS inclui t-1 e OOS inclui t, ha leakage
- Resultado: WFE inflado, falsa confianca

### Solucao: Purging

```
Remover dados adjacentes entre IS e OOS:

[----IS----][PURGE][--OOS--]
              ↑
       Gap de N periodos
       
N = tempo maximo que uma observacao pode influenciar futuras
```

### Configuracao de Purge por Timeframe

| Timeframe | Purge Gap | Motivo |
|-----------|-----------|--------|
| M1-M5 | 5-10 bars | Alta autocorrelacao |
| M15-H1 | 3-5 bars | Autocorrelacao media |
| H4-D1 | 1-2 bars | Baixa autocorrelacao |

### Embargo

Alem do purge, adicionar embargo no fim do OOS:

```
[----IS----][PURGE][--OOS--][EMBARGO]
                              ↑
                    Nao usar para proximo IS
```

### Codigo Python

```python
from scripts.oracle.walk_forward import PurgedKFold

pkf = PurgedKFold(n_splits=5, purge_gap=5, embargo_pct=0.01)
for train_idx, test_idx in pkf.split(data):
    # train_idx exclui purge + embargo
    pass
```

---

## 6. CPCV (Combinatorial Purged CV)

### Conceito

CPCV testa TODAS as combinacoes possiveis de IS/OOS, nao apenas sequenciais.

### Vantagem

- Mais robusto estatisticamente
- Permite calcular PBO (Probability of Backtest Overfitting)
- Detecta overfitting mais facilmente

### Quando Usar

- Quando disponivel (computacionalmente caro)
- Para validacao final antes de go-live
- Quando suspeita de overfitting

---

## 7. Output Template WFA

```
┌─────────────────────────────────────────────────────────────────────┐
│               WALK-FORWARD ANALYSIS REPORT                          │
│ Estrategia: [Name] | Windows: 12 | IS/OOS Split: 70/30             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│ SUMMARY:                                                            │
│ WFE (Walk-Forward Efficiency): 0.62                                 │
│ Status: APPROVED ✓                                                  │
│                                                                     │
│ WINDOW DETAILS:                                                     │
│ ┌────────┬─────────────┬─────────────┬──────────┬────────┐         │
│ │ Window │ IS Period   │ OOS Period  │ IS Perf  │OOS Perf│         │
│ ├────────┼─────────────┼─────────────┼──────────┼────────┤         │
│ │   1    │ Jan-Mar '23 │ Apr '23     │  +15.2%  │ +9.1%  │         │
│ │   2    │ Feb-Apr '23 │ May '23     │  +12.8%  │ +7.5%  │         │
│ │  ...   │    ...      │    ...      │   ...    │  ...   │         │
│ │  12    │ Nov-Jan '24 │ Feb '24     │  +14.5%  │ +8.8%  │         │
│ └────────┴─────────────┴─────────────┴──────────┴────────┘         │
│                                                                     │
│ AGGREGATE:                                                          │
│ Mean IS Performance:  +14.8%                                        │
│ Mean OOS Performance: +9.2%                                         │
│ WFE = 9.2 / 14.8 = 0.62 ✓                                          │
│                                                                     │
│ CONSISTENCY CHECK:                                                  │
│ OOS Positive Windows: 10/12 (83%)                                   │
│ StdDev of OOS Performance: 2.1%                                     │
│ Worst OOS Window: #5 (-1.2%)                                        │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 8. Por Que WFA Funciona?

### Problema do Backtest Tradicional

```
BACKTEST TRADICIONAL:
- Otimiza em 100% dos dados
- Testa nos MESMOS dados
- Resultado: Performance inflada (curve-fitting)
- Realidade: FALHA em live
```

### Solucao WFA

```
WFA:
- Simula cenario real: otimiza passado, testa "futuro"
- Repete N vezes para robustez estatistica
- Mede DEGRADACAO de performance (IS → OOS)
- Se degradacao < 40%, edge provavelmente e real
```

---

## 9. Implementacao

**Script Python**: `scripts/oracle/walk_forward.py` (a implementar)

### Uso via ORACLE

```
/wfa [dados] --windows 12 --split 70/30 --mode rolling
```

### Parametros

| Parametro | Default | Descricao |
|-----------|---------|-----------|
| windows | 10 | Numero de janelas |
| split | 70/30 | Proporcao IS/OOS |
| mode | rolling | rolling ou anchored |
| purge | 0 | Periodos de purge |

---

## 10. Checklist WFA

```
□ 1. Minimo 10 janelas?
□ 2. Cada janela tem 10+ trades OOS?
□ 3. WFE >= 0.6?
□ 4. >= 80% das janelas OOS positivas?
□ 5. StdDev OOS < 50% da media?
□ 6. Pior janela OOS > -5%?
□ 7. Purge aplicado se necessario?
□ 8. Testado em rolling E anchored?

SCORE: ___/8
```
