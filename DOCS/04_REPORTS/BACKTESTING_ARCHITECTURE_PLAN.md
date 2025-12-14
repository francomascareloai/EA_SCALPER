# DEEP BACKTESTING ARCHITECTURE: THE TRUTH ENGINE
**Versão:** 1.0  
**Data:** 2025-11-30  
**Autor:** ARGUS (Research Analyst)  
**Projeto:** EA_SCALPER_XAUUSD v2.2 (FTMO Challenge)

---

## 1. EXECUTIVE SUMMARY

Para validar um sistema híbrido de alta frequência (MQL5 + Python + ML) em XAUUSD, as ferramentas tradicionais (MT5 Strategy Tester padrão, Backtrader) são **insuficientes e perigosas**. Elas ignoram a latência de rede, o tempo de inferência do ML e o slippage de execução real, criando uma ilusão de lucratividade ("Backtest Iludido").

Este plano define a **"Shadow Exchange Architecture"**: um ambiente de simulação que replica a infraestrutura física do trade, não apenas a lógica da estratégia.

**Core Philosophy:** *"Se o backtest não dói, ele está mentindo."*

---

## 2. O PROBLEMA: A ILUSÃO DO SCALPER

### Por que Backtests Tradicionais Mentem?
1.  **Ignoram a Latência do Python:** O MT5 assume que o Python responde instantaneamente. Na realidade, o round-trip (MT5 -> Python -> MT5) leva 10-50ms. Em scalping de ouro, 50ms é a diferença entre lucro e prejuízo.
2.  **Ignoram Filas de Ordens:** Assumem que você é preenchido no preço que vê. Em HFT, o preço "foge" antes da sua ordem chegar.
3.  **Fazem "Look-ahead" Involuntário:** Usam barras M1 fechadas para tomar decisões intra-candle.

### A Solução: Event-Driven Latency Simulation
Precisamos de um motor que simule:
`Sinal (T)` -> `Inferência (+5ms)` -> `Rede (+10ms)` -> `Execução (Preço em T+15ms)`

---

## 3. ARSENAL TECNOLÓGICO (2025)

Após pesquisa profunda, estas são as ferramentas selecionadas para a **Truth Engine**:

| Componente | Ferramenta Escolhida | Justificativa |
|------------|----------------------|---------------|
| **Core Engine** | **Nautilus Trader** (ou **HftBacktest**) | Únicos capazes de simular latência de microestrutura e *event-driven* architecture com performance (Rust/C++ bindings). |
| **Data Feed** | **Dukascopy Tick Data** | Já possuímos. Dados Tick-by-Tick (Bid/Ask reais) são mandatórios. |
| **Alpha Research** | **VectorBT Pro** | Apenas para testar *ideias* iniciais de ML (vetorizado = rápido). Não usar para validação final. |
| **Execution Bridge** | **Custom Python Harness** | Script que carrega o `Agent Hub` como biblioteca para eliminar latência HTTP no backtest, mas *simula* o delay matematicamente. |

---

## 4. IMPLEMENTATION PLAN: "THE SHADOW EXCHANGE"

### FASE 1: Preparação dos Dados (Data Engineering)
**Objetivo:** Converter CSVs brutos da Dukascopy em formato otimizado para simulação de eventos.

1.  **Ingestão:** Converter `XAUUSD_ticks.csv` (2020-2025) para formato binário (HDF5 ou Parquet).
2.  **Cleaning:** Remover ticks com spread negativo ou volume zero (ruído de dados).
3.  **Feature Pre-calculation:**
    *   Para otimizar velocidade, pré-calcular features pesadas (ex: Hurst, Volatility) e salvar alinhado com timestamps.
    *   *Nota:* O simulador lerá (Tick Data + Features Pré-calculadas) para simular "Real-time".

### FASE 2: O Simulador de Latência (The Delay Model)
**Objetivo:** Criar o modelo matemático que pune o robô pelos atrasos reais.

Implementar decorador de latência no Python:
```python
def simulate_execution(signal_time, current_price):
    # Modelagem de Latência Realista
    inference_delay = random.normal(5ms, 2ms)  # Tempo do modelo ONNX
    network_delay = random.normal(15ms, 5ms)   # Ping VPS -> Broker
    broker_delay = random.normal(50ms, 10ms)   # Tempo de processamento da FTMO
    
    total_delay = inference_delay + network_delay + broker_delay
    execution_time = signal_time + total_delay
    
    # Buscar qual era o preço REAL no futuro (execution_time)
    # É AQUI QUE A MAIORIA DAS ESTRATÉGIAS MORRE
    executed_price = get_price_at(execution_time) 
    
    return executed_price
```

### FASE 3: Integração Híbrida (MQL5 Logic in Python)
Como não podemos rodar MQL5 nativo dentro do Python facilmente, faremos a **Portabilidade Lógica**:

1.  **Traduzir Regras de Entrada:** As regras de filtro do MQL5 (`AdvancedFilters.mqh`) devem ser reimplementadas fielmente em Python para o backtest.
2.  **Validar Paridade:** Rodar um pequeno período no MT5 e no Python e garantir que os trades batem 100%.

### FASE 4: Stress Testing (The Crucible)
Rodar o sistema sob condições extremas:
1.  **Variable Spread:** Simular abertura de Londres/NY com spreads 3x maiores.
2.  **Execution Lag:** Testar com pings de 100ms (pior caso VPS).
3.  **Slippage Injection:** Adicionar slippage negativo aleatório em 30% das ordens.

---

## 5. ROADMAP DE EXECUÇÃO

### Passo 1: Setup do Ambiente (Imediato)
*   [ ] Instalar `nautilus_trader` e `hftbacktest`.
*   [ ] Criar script de conversão de dados Dukascopy -> Formato HftBacktest (`.npz`).

### Passo 2: Protótipo da Engine (Semana 1)
*   [ ] Criar `backtest_engine.py`.
*   [ ] Implementar `LatencyModel` simples.
*   [ ] Rodar estratégia "Dummy" (Random) para validar o fluxo de ordens.

### Passo 3: Migração da Estratégia (Semana 1-2)
*   [ ] Conectar `Agent Hub` (ML predictions) no loop do backtest.
*   [ ] Replicar lógica de `RiskManager` (FTMO rules) no backtest.

### Passo 4: Validação Final (Semana 2)
*   [ ] Rodar simulação 2023-2024.
*   [ ] Gerar relatório "The Truth Report" com métricas de latência.

---

## 6. REFERÊNCIAS & FONTES

*   **Nautilus Trader:** [GitHub](https://github.com/nautechsystems/nautilus_trader) - *Plataforma de backtesting event-driven de alta performance.*
*   **HftBacktest:** [GitHub](https://github.com/nkaz001/hftbacktest) - *Framework focado em replay de dados tick-by-tick com latência.*
*   **Book:** *Trades, Quotes and Prices* (J.P. Bouchaud) - *Bíblia da microestrutura de mercado.*
*   **Article:** *Backtesting: The subtle trap of look-ahead bias in HFT* (QuantStart).

---

**VERDICTO DO ARGUS:**
Este plano remove a "mágica" e traz a dor necessária. Se o robô lucrar aqui, ele lucrará na FTMO. Se falhar aqui, economizamos meses de frustração e dinheiro em taxas de exame.

**Próximo Passo Sugerido:** Autorizar o Agente **FORGE** a iniciar a "Fase 1: Setup do Ambiente" e criar o script de conversão de dados.
