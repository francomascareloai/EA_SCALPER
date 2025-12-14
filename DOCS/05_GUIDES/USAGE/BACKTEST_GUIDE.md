# Guia Completo: Backtest, Dados e Deploy
## EA_SCALPER_XAUUSD - Singularity Edition

**Data:** 2025-11-28  
**Versão:** 1.0

---

## Sumário

1. [Visão Geral do Processo](#1-visão-geral-do-processo)
2. [Extraindo Dados Históricos do MT5](#2-extraindo-dados-históricos-do-mt5)
3. [Treinando os Modelos ML](#3-treinando-os-modelos-ml)
4. [Executando Backtest no Strategy Tester](#4-executando-backtest-no-strategy-tester)
5. [Walk-Forward Analysis](#5-walk-forward-analysis)
6. [Deploy para Demo/FTMO](#6-deploy-para-demoftmo)
7. [Checklist Completo](#7-checklist-completo)

---

## 1. Visão Geral do Processo

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PIPELINE COMPLETO                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  [1] EXTRAIR DADOS    →  [2] TREINAR ML   →  [3] EXPORTAR ONNX     │
│      (MT5 Python)         (PyTorch)            (models/)            │
│           │                   │                    │                │
│           ▼                   ▼                    ▼                │
│  [4] BACKTEST        →  [5] WALK-FORWARD  →  [6] DEPLOY            │
│      (Strategy Tester)     (Validação)         (Demo/FTMO)         │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Tempo Estimado Total:** 4-8 horas (primeira vez), 1-2 horas (iterações)

---

## 2. Extraindo Dados Históricos do MT5

### 2.1 Pré-requisitos

```bash
# Instalar dependências Python
cd Python_Agent_Hub
pip install MetaTrader5 pandas numpy torch onnx onnxruntime scikit-learn
```

### 2.2 Garantir que MT5 está Pronto

1. **Abrir MetaTrader 5**
2. **Fazer login** na conta (demo ou real)
3. **Verificar conexão** - ícone verde no canto inferior direito
4. **Abrir gráfico XAUUSD** - para garantir que o símbolo está disponível

### 2.3 Extrair Dados via Python

```python
# Executar no terminal Python
import MetaTrader5 as mt5
import pandas as pd
from datetime import datetime, timedelta

# 1. Inicializar conexão
if not mt5.initialize():
    print(f"Falha ao conectar: {mt5.last_error()}")
    quit()

print(f"Conectado: {mt5.terminal_info().name}")

# 2. Configurar parâmetros
symbol = "XAUUSD"
timeframe = mt5.TIMEFRAME_M15  # M15 para o EA
days = 365  # 1 ano de dados

end_date = datetime.now()
start_date = end_date - timedelta(days=days)

# 3. Extrair dados
rates = mt5.copy_rates_range(symbol, timeframe, start_date, end_date)

if rates is None:
    print(f"Erro: {mt5.last_error()}")
else:
    # 4. Converter para DataFrame
    df = pd.DataFrame(rates)
    df['time'] = pd.to_datetime(df['time'], unit='s')
    df.set_index('time', inplace=True)
    df.columns = ['open', 'high', 'low', 'close', 'tick_volume', 'spread', 'real_volume']
    
    # 5. Salvar
    output_file = f"Python_Agent_Hub/ml_pipeline/data/xauusd_M15_{days}d.csv"
    df.to_csv(output_file)
    print(f"Dados salvos: {len(df)} barras em {output_file}")
    print(f"Período: {df.index[0]} até {df.index[-1]}")

# 6. Fechar conexão
mt5.shutdown()
```

### 2.4 Alternativa: Dados Manuais

Se o Python não funcionar, exporte manualmente:

1. **MT5** → **File** → **Open Data Folder**
2. Navegar para `bases/Default/XAUUSD/`
3. Os arquivos `.dat` contêm os dados
4. Ou usar **MT5** → **Tools** → **History Center** → Export

---

## 3. Treinando os Modelos ML

### 3.1 Executar o Pipeline Completo

```bash
cd Python_Agent_Hub

# Opção 1: Pipeline automático
python -m ml_pipeline.train_and_export --data-file data/xauusd_M15_365d.csv

# Opção 2: Com coleta automática do MT5
python -m ml_pipeline.train_and_export --days 365

# Opção 3: Rápido (sem Walk-Forward Analysis)
python -m ml_pipeline.train_and_export --skip-wfa
```

### 3.2 O que o Pipeline Faz

1. **Carrega dados** do CSV ou MT5
2. **Cria 15 features**:
   - Returns, Log Returns, Range %
   - RSI M5, M15, H1
   - ATR normalizado, MA distance, BB position
   - Hurst Exponent, Shannon Entropy
   - Session, Hour (sin/cos), OB distance
3. **Treina modelo LSTM** para direção
4. **Walk-Forward Analysis** (10 janelas)
5. **Exporta para ONNX** → `MQL5/Models/direction_model.onnx`
6. **Salva parâmetros** → `MQL5/Models/scaler_params.json`

### 3.3 Métricas de Sucesso

| Métrica | Mínimo | Bom | Excelente |
|---------|--------|-----|-----------|
| Walk-Forward Efficiency | 0.50 | 0.60 | 0.70+ |
| Validation Accuracy | 52% | 55% | 60%+ |
| Consistência (Std) | < 0.10 | < 0.07 | < 0.05 |

> **IMPORTANTE:** WFE < 0.50 indica overfitting. Não usar em produção!

---

## 4. Executando Backtest no Strategy Tester

### 4.1 Configurar o Strategy Tester

1. **Abrir** → View → Strategy Tester (Ctrl+R)
2. **Configurações:**

| Configuração | Valor Recomendado |
|--------------|-------------------|
| EA | EA_SCALPER_XAUUSD |
| Symbol | XAUUSD |
| Period | M15 |
| Dates | Custom (1 ano) |
| Forward | No forward |
| Modeling | Every tick |
| Deposit | 100000 (FTMO) |
| Leverage | 1:100 |
| Optimization | Disabled (primeiro) |

### 4.2 Configurações Críticas para XAUUSD

```
┌─────────────────────────────────────────────────────────────┐
│                  SETTINGS RECOMENDADAS                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Modeling:          Every tick (based on real ticks)        │
│                     ↳ ESSENCIAL para scalping               │
│                                                              │
│  Spread:            Current                                  │
│                     ↳ Usa spread real do broker              │
│                                                              │
│  Execution:         Random delay                             │
│                     ↳ Simula latência real                   │
│                                                              │
│  Profit in:         USD                                      │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 4.3 Parâmetros do EA para Teste

```
=== Risk Management (FTMO) ===
Risk Per Trade:      0.5%      (conservador)
Max Daily Loss:      5.0%      (FTMO limit)
Soft Stop Level:     3.5%      (trigger warning)
Max Total Loss:      10.0%     (FTMO limit)
Max Trades Per Day:  10        (limitar overtrading)

=== Scoring Engine ===
Execution Threshold: 70        (Tier B mínimo)
Min Confluences:     3         (3+ fatores)

=== ML Settings ===
Use ML:              true      (se modelo treinado)
ML Threshold:        0.65      (65% confiança)
```

### 4.4 Interpretar Resultados

**Métricas Essenciais para FTMO:**

| Métrica | Meta FTMO | Aceitável |
|---------|-----------|-----------|
| Net Profit | > $10,000 (10%) | > $5,000 |
| Max Drawdown | < 10% | < 8% |
| Daily Max DD | < 5% | < 4% |
| Profit Factor | > 1.5 | > 1.3 |
| Win Rate | > 50% | > 45% |
| Avg Trade | > $50 | > $30 |

### 4.5 Salvar Relatório

1. Clicar em **Backtest** (abas inferiores)
2. Clicar direito → **Save as report**
3. Salvar em `logs/backtest_YYYYMMDD.html`

---

## 5. Walk-Forward Analysis (Validação Robusta)

### 5.1 Por que é Importante

Walk-Forward Analysis previne **overfitting** e valida se a estratégia funciona em dados nunca vistos.

```
┌─────────────────────────────────────────────────────────────────┐
│                 WALK-FORWARD ANALYSIS                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Período 1: ████████░░░░  In-Sample → [Otimiza] → Out-Sample    │
│  Período 2: ░░████████░░  In-Sample → [Otimiza] → Out-Sample    │
│  Período 3: ░░░░████████  In-Sample → [Otimiza] → Out-Sample    │
│                                                                  │
│  WFE = Média(Out-Sample Performance) / Std(Out-Sample Perf)     │
│                                                                  │
│  WFE > 0.6 = ✅ Robusto                                         │
│  WFE < 0.5 = ❌ Overfitting                                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 Fazer WFA no MT5

1. **Strategy Tester** → **Forward** → **Custom**
2. Definir período Out-of-Sample (últimos 3 meses)
3. **Optimization** → **Genetic algorithm**
4. Executar e comparar In-Sample vs Forward

### 5.3 WFA Manual (Mais Confiável)

1. **Dividir dados em 10 partes** (ex: 1 ano = ~36 dias cada)
2. **Para cada janela:**
   - Otimizar nos primeiros 80%
   - Testar nos últimos 20%
   - Registrar resultados
3. **Calcular WFE:**
   ```
   WFE = Média(Profit Factors) - Desvio Padrão(Profit Factors)
   ```

---

## 6. Deploy para Demo/FTMO

### 6.1 Checklist Pré-Deploy

- [ ] Backtest com profit > 10% em 1 ano
- [ ] Max Drawdown < 8%
- [ ] WFE > 0.6
- [ ] Testado em conta demo por 1+ semanas
- [ ] Modelo ONNX exportado e funcionando
- [ ] Logs configurados

### 6.2 Configurar VPS (Recomendado)

Para FTMO, usar VPS garante execução 24/7:

1. **Provedores recomendados:**
   - ForexVPS.net
   - BeeksFX
   - FXVM

2. **Especificações mínimas:**
   - Windows Server 2019+
   - 2GB RAM
   - SSD
   - Latência < 5ms para broker

### 6.3 Deploy no MT5

1. **Copiar arquivos:**
   ```
   MQL5/Experts/EA_SCALPER_XAUUSD.ex5 → Terminal/MQL5/Experts/
   MQL5/Include/EA_SCALPER/          → Terminal/MQL5/Include/
   MQL5/Models/                       → Terminal/MQL5/Models/
   ```

2. **Reiniciar MT5**

3. **Anexar ao gráfico:**
   - Abrir XAUUSD M15
   - Arrastar EA para o gráfico
   - Configurar parâmetros
   - Habilitar "Allow Algo Trading"

### 6.4 Configurações para FTMO Challenge

```
┌─────────────────────────────────────────────────────────────┐
│              CONFIGURAÇÕES FTMO $100K                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Risk Per Trade:      0.5%    ($500 max por trade)          │
│  Max Daily Loss:      4.0%    (Buffer de 1% do limite)      │
│  Max Total Loss:      8.0%    (Buffer de 2% do limite)      │
│  Max Trades/Day:      5       (Evitar overtrading)          │
│                                                              │
│  Target:              10% em ~20-30 dias de trading         │
│  Dias Mínimos:        4 dias (FTMO requirement)             │
│                                                              │
│  Sessions:            London + NY (horários XAUUSD)         │
│  Avoid:               News de alto impacto, sextas PM       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 6.5 Monitoramento

1. **Logs diários:** Verificar `logs/` folder
2. **Drawdown:** Alertas em 3% e 4%
3. **Trades:** Máximo 5/dia inicialmente
4. **Equity curve:** Deve ser crescente e suave

---

## 7. Checklist Completo

### Fase 1: Preparação (1-2 horas)

- [ ] MT5 instalado e logado
- [ ] Python environment configurado
- [ ] Dependências instaladas (`pip install -r requirements.txt`)
- [ ] Código compilado sem erros

### Fase 2: Dados (30 min - 1 hora)

- [ ] Extrair 1 ano de dados M15
- [ ] Verificar qualidade (sem gaps grandes)
- [ ] Salvar CSV em `ml_pipeline/data/`

### Fase 3: ML Training (1-2 horas)

- [ ] Executar pipeline de treinamento
- [ ] WFE > 0.6 ✅
- [ ] Modelo ONNX exportado
- [ ] scaler_params.json copiado

### Fase 4: Backtest (1-2 horas)

- [ ] Strategy Tester configurado
- [ ] "Every tick" selecionado
- [ ] Spread realista configurado
- [ ] Executar backtest de 1 ano
- [ ] Profit > 10%
- [ ] Max DD < 8%
- [ ] Salvar relatório

### Fase 5: Validação (1-2 horas)

- [ ] Walk-Forward Analysis executado
- [ ] Consistência entre janelas
- [ ] Teste em período não visto (hold-out)
- [ ] Monte Carlo opcional

### Fase 6: Demo Testing (1 semana)

- [ ] Deploy em conta demo
- [ ] Monitorar por 5+ dias
- [ ] Verificar execução de ordens
- [ ] Confirmar drawdown controlado
- [ ] Logs funcionando

### Fase 7: FTMO Challenge

- [ ] VPS configurado (opcional mas recomendado)
- [ ] Configurações conservadoras
- [ ] Iniciar com risco baixo (0.5%)
- [ ] Monitorar diariamente
- [ ] Não alterar configurações mid-challenge

---

## Comandos Rápidos

```bash
# 1. Compilar EA
powershell -ExecutionPolicy Bypass -File scripts/build.ps1

# 2. Treinar modelo
cd Python_Agent_Hub
python -m ml_pipeline.train_and_export --data-file data/xauusd_M15_365d.csv

# 3. Extrair dados (Python interativo)
python -c "from ml_pipeline.data_collector import collect_training_data; collect_training_data(days=365)"
```

---

## Problemas Comuns

| Problema | Solução |
|----------|---------|
| MT5 não conecta ao Python | Verificar se MT5 está aberto e logado |
| Modelo ONNX não carrega | Verificar caminho: `Models/direction_model.onnx` |
| Backtest muito lento | Usar "Every tick based on real ticks" apenas para final |
| WFE muito baixo | Simplificar features, mais dados, menos parâmetros |
| Drawdown alto em demo | Reduzir risk % ou aumentar threshold |

---

**Próximos Passos:**
1. Extrair dados do MT5
2. Treinar modelo
3. Rodar backtest
4. Validar com WFA
5. Deploy em demo
6. FTMO Challenge!

---

*Documento gerado automaticamente - EA_SCALPER_XAUUSD Singularity Edition*
