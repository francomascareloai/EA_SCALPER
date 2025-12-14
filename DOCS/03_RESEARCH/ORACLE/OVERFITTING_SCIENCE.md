# Deteccao Cientifica de Overfitting

> Baseado em: Bailey & Lopez de Prado (2014), "The Deflated Sharpe Ratio"
> Para: EA_SCALPER_XAUUSD - ORACLE Validation

---

## 1. O Problema Fundamental

**Overfitting** ocorre quando uma estrategia se ajusta ao RUIDO historico em vez de padroes REAIS.

### Por Que Isso Acontece?

```
SE VOCE TESTA N ESTRATEGIAS/PARAMETROS:

O Sharpe MAXIMO esperado por PURA SORTE e:

E[max(SR)] ≈ sqrt(2 × ln(N))

┌─────────────────────────────────────────────────────────┐
│  N Testes  │  E[max(SR)] Esperado por SORTE            │
├────────────┼────────────────────────────────────────────┤
│     10     │          1.2                              │
│    100     │          1.9                              │
│   1000     │          2.4                              │
│  10000     │          2.8                              │
└─────────────────────────────────────────────────────────┘

CONCLUSAO: Sharpe de 2.0 com 100 testes NAO e impressionante!
```

---

## 2. Probabilistic Sharpe Ratio (PSR)

### O Problema do Sharpe Tradicional

O Sharpe Ratio tradicional ignora:
1. Skewness (assimetria dos retornos)
2. Kurtosis (caudas gordas)
3. Tamanho da amostra
4. Numero de testes realizados

### Formula do PSR

```
PSR(SR*) = Φ[(SR_obs - SR*) × sqrt(n-1) / sqrt(1 + 0.5×SR² - γ₃×SR + (γ₄-3)/4 × SR²)]

Onde:
- Φ = CDF da normal padrao
- SR_obs = Sharpe observado
- SR* = Sharpe benchmark (geralmente 0)
- n = numero de observacoes
- γ₃ = skewness
- γ₄ = kurtosis
```

### Interpretacao

| PSR | Interpretacao | Acao |
|-----|---------------|------|
| **> 0.95** | Sharpe MUITO provavelmente real | GO com confianca |
| **0.90-0.95** | Provavelmente real | GO |
| **0.80-0.90** | Incerto, pode ser sorte | INVESTIGAR |
| **< 0.80** | Provavelmente SORTE/OVERFIT | NO-GO |

### Por Que PSR Funciona?

PSR responde: **"Qual a probabilidade de que o Sharpe verdadeiro seja maior que um benchmark?"**

Considera:
- Tamanho da amostra (mais trades = mais confianca)
- Assimetria dos retornos (caudas asimetricas)
- Caudas gordas (eventos extremos)

---

## 3. Deflated Sharpe Ratio (DSR)

### O Problema do Multiple Testing

Quando voce testa muitas estrategias/parametros, algumas vao parecer boas por PURA SORTE.

### Formula do DSR

```
DSR = (SR_obs - E[max(SR)]) / SE(SR)

Onde:
- SR_obs = Sharpe observado
- E[max(SR)] = Sharpe maximo esperado dado N testes
- SE(SR) = Erro padrao do Sharpe
```

### E[max(SR)] - O Sharpe da Sorte

```
E[max(SR)] ≈ sqrt(2 × ln(N)) - (γ + ln(ln(N))) / (2 × sqrt(2 × ln(N)))

Onde γ = 0.5772 (constante de Euler-Mascheroni)
```

### Interpretacao

| DSR | Interpretacao | Acao |
|-----|---------------|------|
| **> 2.0** | MUITO significativo | GO |
| **> 0** | Significativo | GO com cautela |
| **-0.5 a 0** | Marginal | INVESTIGAR |
| **< -0.5** | NAO significativo | NO-GO |

### Exemplo Pratico

```
CENARIO:
- Estrategia com Sharpe = 2.5
- Testou 50 configuracoes (N = 50)
- 200 trades

CALCULO:
1. E[max(SR)] para N=50 ≈ 1.8
2. SE(SR) ≈ 0.3 (dado 200 trades)
3. DSR = (2.5 - 1.8) / 0.3 = 2.33

RESULTADO: DSR = 2.33 > 0 → Edge provavelmente REAL!

SE fosse N = 500:
1. E[max(SR)] ≈ 2.3
2. DSR = (2.5 - 2.3) / 0.3 = 0.67

RESULTADO: DSR = 0.67 → Marginal, pode ser sorte
```

---

## 4. Probability of Backtest Overfitting (PBO)

### Conceito

PBO mede a probabilidade de que a melhor estrategia in-sample NAO seja a melhor out-of-sample.

```
LOGICA:
- Se ranking IS == ranking OOS → Baixo overfitting
- Se ranking IS != ranking OOS → Alto overfitting

PBO = (1 - correlacao_de_ranks_IS_vs_OOS) / 2
```

### Como Calcular

1. Usar CPCV (Combinatorial Purged Cross-Validation)
2. Gerar multiplos caminhos IS/OOS
3. Para cada caminho, calcular performance IS e OOS
4. Medir correlacao de Spearman entre rankings
5. PBO = (1 - correlacao) / 2

### Interpretacao

| PBO | Interpretacao | Acao |
|-----|---------------|------|
| **< 0.25** | BAIXO risco | GO |
| **0.25-0.50** | MODERADO risco | CAUTELA |
| **0.50-0.75** | ALTO risco | INVESTIGAR |
| **> 0.75** | MUITO ALTO | NO-GO |

---

## 5. Minimum Track Record Length (MinTRL)

### O Que E?

MinTRL responde: **"Quantos periodos preciso para ter X% de confianca no Sharpe?"**

### Formula

```
MinTRL = 1 + z² × (1 + 0.5×SR² - γ₃×SR + (γ₄-3)/4 × SR²) / (SR - SR*)²

Onde z = quantil da normal para confianca desejada (1.96 para 95%)
```

### Uso Pratico

Se seu backtest tem 100 trades mas MinTRL = 250:
- Voce NAO tem dados suficientes para confianca estatistica
- Precisa de mais 150 trades
- Ou aceitar menor confianca

---

## 6. Checklist Anti-Overfitting

```
□ 1. Dados OOS genuinos (nunca vistos durante desenvolvimento)?
□ 2. WFA com WFE >= 0.6?
□ 3. Monte Carlo 95th DD < 8%?
□ 4. PSR > 0.90?
□ 5. DSR > 0 (ajustado por N testes)?
□ 6. PBO < 0.50 (se CPCV disponivel)?
□ 7. Numero de parametros <= 7?
□ 8. Logica economica faz sentido?
□ 9. Mais de 200 trades na amostra?
□ 10. Mais de 2 anos de dados?

SCORE: ___/10

├── 9-10: APROVADO - Baixo risco de overfit
├── 7-8:  CAUTELA - Risco moderado
├── 5-6:  SUSPEITO - Investigar mais
└── <5:   REPROVADO - Alto risco de overfit
```

---

## 7. Referencias

1. Bailey, D.H. & Lopez de Prado, M. (2014). "The Deflated Sharpe Ratio: Correcting for Selection Bias, Backtest Overfitting, and Non-Normality"
2. Lopez de Prado, M. (2018). "Advances in Financial Machine Learning"
3. Bailey, D.H. et al. (2015). "Probability of Backtest Overfitting"

---

## 8. Implementacao

**Script Python**: `scripts/oracle/deflated_sharpe.py`

```bash
# Uso via CLI
python -m scripts.oracle.deflated_sharpe --input results.csv --trials 10

# Uso como modulo
from scripts.oracle.deflated_sharpe import SharpeAnalyzer
analyzer = SharpeAnalyzer()
result = analyzer.analyze(returns, n_trials=10)
print(result.interpretation)
```
