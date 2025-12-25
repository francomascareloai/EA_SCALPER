# FUTURE IMPROVEMENTS - Nautilus Gold Scalper (NautilusTrader)

> **Author:** FORGE, NAUTILUS, ALL agents  
> **Date:** 2025-12-08  
> **Status:** Living Document - Ideas Repository  

---

## STATUS GERAL

### ✅ JA IMPLEMENTADO

| Feature | Arquivo/Modulo | Data |
|---------|----------------|------|
| **Tick-Level Backtesting** | `scripts/run_backtest.py` | 2025-12-03 |
| **Intrabar Drawdown Tracking** | `src/risk/drawdown_tracker.py` | 2025-12-03 |
| **News Calendar Integration** | `src/signals/news_calendar.py` | 2025-12-03 |
| **Prop Firm Risk Manager** | `src/risk/prop_firm_manager.py` | 2025-12-03 |
| **Footprint Analysis** | `src/indicators/footprint_analyzer.py` | 2025-12-03 |
| **Regime Detection** | `src/indicators/regime_detector.py` | 2025-12-03 |
| **MTF Structure Analysis** | `src/indicators/mtf_structure.py` | 2025-12-03 |

### ❌ NAO IMPLEMENTADO (BACKLOG)

| Feature | Prioridade | Esforco | Status |
|---------|------------|---------|--------|
| **Setup Quality Filter** | P1 | 4-6h | TODO (conditional) |
| **Fibonacci Golden Pocket** | P1 | 4-6h | TODO |
| **Adaptive Kelly Sizing** | P1 | 6-8h | TODO |
| **Spread-Aware Entry** | P1 | 4-6h | TODO |
| **Kaufman ER Breakout (Donchian)** | P2 | 1-2d | IDEA (needs validation) |
| **Bayesian Confluence** | P2 | 2-3d | PLANNED |
| **HMM Regime Predictor** | P2 | 3-5d | PLANNED |
| **Strategy Selector** | P2 | 8-12h | PLANNED |
| **Transformer-Lite ONNX** | P2 | 1-2w | PLANNED |
| **Order Flow Imbalance** | P3 | 1-2d | PLANNED |
| **Walk-Forward Optimization** | P3 | 3-5d | PLANNED |
| **Dynamic Circuit Breaker** | P3 | 6-8h | PLANNED |
| **Meta-Learning Selector** | P4 | 2-3w | IDEA |
| **Spread Predictor LSTM** | P4 | 1-2w | IDEA |
| **Portfolio Heat Manager** | P4 | 1w | IDEA |

---

## CRUCIBLE (2025-12-24) — Portfolio Strategy Review (Trend/MeanRevert/SMC/Scalper)

> **Status:** 📋 PLANNED (analysis captured; requires ORACLE+SENTINEL validation before implementation)
>
> **Goal:** Maximize lucratividade com menor risco, mantendo compliance Apex (HWM trailing DD 5% inclui unrealized; sem overnight; time gates 4:30/4:55/4:59 ET).
>
> **Key Decision (recommended):** Consolidar `SMC + scalper` (alto overlap/correlação) em um único “microstructure scalper” mais robusto (zonas + confirmação + gates) e manter `trend-follow` + `mean-revert` como pilares por regime. Adicionar no máximo 2 edges complementares (somente se os testes falsificação-first apontarem necessidade): **Volatility Expansion Breakout** e **Anchored VWAP MR**.

### Diagnóstico do portfólio (redundâncias / conflitos / gaps)
- **Redundância provável:** `SMC scalper` e `scalper` operam a mesma microestrutura → duplica custo/risco em vez de diversificar edge.
- **Conflito típico:** trend-follow vs mean-revert em transição rápida de regime → flip-flop/churn.
- **Gaps de edge:** falta um edge menos dependente de “níveis SMC precisos” para (a) expansão de volatilidade/breakouts e/ou (b) mean-revert mais estrutural (VWAP/anchor).

### Apex / HWM Trap (risco principal)
- **Maior risco:** trend-follow (winners elevam HWM e reversões intraday podem matar via trailing DD). Também qualquer lógica que “deixa correr” perto do close.
- **Mitigação obrigatória:** de-risk em lucro (parcial + stop conservador), caps por sessão/hora, e saídas agressivas conforme aproxima `4:55–4:59 PM ET`.

### Melhorias por estratégia (ideias de lógica/execução, não-código)
**Trend-follow**
- De-risk em lucro (objetivo: reduzir variância de equity e evitar HWM trap, não maximizar R por trade).
- Filtro de volatility expansion (evitar trend-follow em compressão/chop).
- Anti-flip-flop (persistência de regime antes de alternar).
- Time-based exits (flatten mais cedo conforme aproxima o close ET).

**Mean reversion / min-revert**
- Proibir MR em regime de ruptura/spikes/news (MR = edge de range, não de cauda).
- Entradas por zona (bands) + confirmação (falha em continuar + retorno), não por nível “milimétrico”.
- Cap de re-entries por janela/sessão (evita death-by-a-thousand-cuts).
- SL adaptativo ao spread/sessão: se spread subiu e o SL mínimo não cabe no risco, não operar.

**SMC**
- Tratar OB/FVG como zonas com tolerância; precisão extrema é suspeita (overfit).
- Confirmar com eventos observáveis (quebra/reteste/falha), sem depender de barras futuras.
- Regras explícitas por sessão (London/NY overlap por padrão; bloquear Asia/late NY).
- News-aware: bloquear pré-evento e operar pós-evento com atraso/confirm.

**Scalper (genérico)**
- Consolidar com SMC para reduzir correlação e custo.
- Trocar “mais trades” por “melhor fill”: operar só com spread aceitável.
- Impor `min SL vs spread` + anti-noise/tempo mínimo de hold quando aplicável.
- Cap de frequência por hora/sessão para proteger o dia (Apex: sobreviver > brilhar).

### Estratégias adicionais (no máximo 2, somente se necessário)
**1) Volatility Expansion Breakout (range → impulso)**
- **Hipótese de edge:** XAUUSD frequentemente sai de compressões com movimentos rápidos.
- **Complementa:** quando mean-revert falha (início de tendência) e quando SMC “preciso” é frágil.
- **Risco:** false breakouts em chop → mitigação com confirmação + gates de sessão/spread/news.

**2) Anchored VWAP / Intraday VWAP Pullback**
- **Hipótese de edge:** MR mais robusto ao redor de “preço justo” intraday do que OB/FVG milimétrico.
- **Complementa:** range pós-impulso com sinal menos narrativo.
- **Risco:** tendência forte “escada” contra VWAP → mitigação com regime filter (não operar em expansion/trend).

### Falsificação-first (testes baratos antes de investir tempo)
**Test 1 — Ghost Test (sinal vs filtros)**
- Manter gates (sessão/spread/news/tempo/risco) e substituir o gerador de entradas por baseline simples/aleatório.
- **Interpretação:** se performance/DD mudam pouco → edge vem de filtros/seleção (ou viés), não do sinal.

**Test 2 — Shifted Levels (precisão SMC é ilusão?)**
- Aplicar jitter controlado nos níveis OB/FVG/liquidez mantendo o resto igual.
- **Interpretação:** se resultado não degrada materialmente → simplificar para zonas/bands/VWAP.

**Opcional — Monte Carlo Survival (robustez Apex)**
- Simular slippage/spread hostis e medir sobrevivência; preferir distribuição a ponto.
- Gate recomendado: `MC95DD < 4%` (buffer antes do 5% Apex).

### Métricas e gates para GO (ORACLE)
- Exigir WFA/OOS + robustez: `WFE`, `SQN`, `PSR`, `DSR`, `PBO`, `MC95DD`.

---

## PHASE 1: QUICK WINS (P1) ⚡

### 1.X Kaufman ER‑Gated Donchian Breakout ("Breakout Chinês" — parâmetros inspiracionais) [PRIORIDADE: P2]

**Contexto:** Recebemos apenas o set de parâmetros de um EA proprietário focado em breakout (sem código e sem conseguir rodar). O objetivo aqui NÃO é copiar o robô, e sim extrair ideias genéricas e testáveis que façam sentido para XAUUSD sob regras Apex.

**O que os parâmetros sugerem (hipótese):**
- `KaufmanEffRtoPrd=48` → filtro de regime por **Kaufman Efficiency Ratio** (market “limpo” vs chop)
- `Period=30` → breakout tipo **Donchian N‑bar** (rompe máxima/mínima dos últimos N candles)
- `ProfitTargetCoef=4.8` → alvo como múltiplo de risco (**TP ≈ 4.8R**)
- `TrailingActCoef=1.7` + `TrailingStop=70` → trailing com **gatilho de ativação** (ativa só depois de ~1.7R)
- `volatility filter period=14` + `smoothing=3` → pré‑condição de volatilidade + suavização de sinal

**Por que pode valer a pena:**
- Breakout tende a funcionar melhor quando o mercado está “direcional”; ER é um filtro simples e conhecido para separar ruído de impulso.
- Separar `trail_activate_R` de `trail_distance` é uma alavanca real para reduzir stopouts precoces em tendências.
- `TP em R` permite otimização coerente e comparável entre regimes (evita parâmetros em “pips” não portáveis).

**Por que pode NÃO valer a pena / riscos (Apex + XAUUSD):**
- Unidades ambíguas (`StopLoss=55`, `TrailingStop=70`) podem ser **incompatíveis** com spread/slippage reais do XAUUSD.
- TP alto (4.8R) + trailing tardio pode aumentar exposição ao **HWM trap** (unrealized sobe HWM; reversões matam via trailing DD).
- Sem evidência (sem backtest do EA), a gente pode estar perseguindo um “edge narrativo” que na prática vem de filtros/execução.

**Plano de validação (falsificação‑first, barato):**
1) **Ghost test (filtros vs sinal):** comparar breakout com ER‑gate ON vs OFF vs gate aleatório (mesma frequência).
2) **Shifted levels:** jitter no nível do Donchian; se performance não muda, a precisão do breakout é placebo.
3) **Cenário conservador de execução:** spread×1.5 + slippage adverso; exigir `MC95DD < 4%` (buffer Apex) + `WFE≥0.60` + `PSR≥0.85` + `DSR>0`.

**Integração prevista (quando for implementar):**
- Reusar o caminho existente de breakout em `src/signals/trend_follow.py` e adicionar parâmetros opcionais para ER‑gate + trailing activation + TP em R.
- Manter time gates Apex (4:30/4:55/4:59 ET) como hard constraints (não otimizar).

**Status:** IDEA (requer ORACLE + SENTINEL antes de qualquer merge)


### 1.0 Setup Quality Filter [PRIORITY: HIGH] ⭐ NEW

**Source:** Phase 00-C Portfolio Review → CRUCIBLE / SENTINEL analysis

**Motivacao:** Reduzir churn e melhorar assertividade filtrando trades de baixa qualidade ANTES de entrar. Trades ruíns (baixa confluência, regime indefinido, muito próximo do último trade) destroem edge e aumentam risco HWM.

**Arquivos alvo:**
- `src/risk/setup_quality_filter.py` (a criar)
- `src/strategies/gold_scalper_strategy.py`
- `src/signals/confluence_engine.py`

**Proposta (conceito):**
```python
class SetupQualityFilter:
    """Filter trades by quality score."""

    def __init__(self):
        self.session_thresholds = {
            "LONDON": 75,      # Highest bar (best liquidity)
            "NY_OVERLAP": 70,  # High bar
            "NY": 65,          # Medium bar
            "ASIAN": 80,       # Very selective (low liquidity)
        }
        self.min_time_between_trades_minutes = 30  # Anti-churn
        self.regime_clarity_threshold = 0.7  # Hurst distance from 0.5

    def passes_quality_gate(
        self,
        confluence_score: float,
        session: str,
        minutes_since_last_trade: int,
        regime_clarity: float,
    ) -> bool:
        threshold = self.session_thresholds.get(session, 70)
        if confluence_score < threshold:
            return False
        if minutes_since_last_trade < self.min_time_between_trades_minutes:
            return False
        if regime_clarity < self.regime_clarity_threshold:
            return False
        return True
```

**Gate condicional:** Implementar SOMENTE se Ghost Test (T1) confirmar que sinais adicionam edge.

**Impacto esperado:**
- Frequência de trades: -30% a -50%
- Win rate: +10% a +20%
- Variância de equity: -20% a -30%

**Esforço:** 4-6 horas
**Prioridade:** **P1**
**Status:** ❌ TODO (conditional on Ghost Test)
**Referencias:** Phase 00-C Portfolio Review, CRUCIBLE analysis 2025-12-24

---

### 1.1 Fibonacci Golden Pocket Integration [PRIORITY: HIGH]

**Source:** ARGUS Research → `DOCS/03_RESEARCH/FINDINGS/FIBONACCI_XAUUSD_RESEARCH.md` (SSRN Paper: Shanaev & Gibson, 2022)

**Motivacao:** SSRN Paper (Shanaev & Gibson, 2022) mostra que niveis 38.2%, 50%, 61.8% sao estatisticamente significativos para reversoes em XAUUSD. "Golden pocket" (61.8%-65%) + OB/FVG = alta probabilidade de entrada.

**Arquivos alvo:**
- `src/signals/confluence_engine.py`
- `src/indicators/structure_detector.py`
- `src/strategies/gold_scalper_strategy.py`

**Proposta (conceito):**
```python
def detect_golden_pocket(swing_high: float, swing_low: float, current_price: float) -> bool:
    """Detect if price is in Fibonacci golden pocket (61.8%-65% retracement)"""
    range_size = swing_high - swing_low
    fib_618 = swing_high - (range_size * 0.618)
    fib_65 = swing_high - (range_size * 0.65)
    return fib_65 <= current_price <= fib_618

# In ConfluenceEngine
def calculate_score(...):
    if detect_golden_pocket(swing_high, swing_low, bar.close):
        score += 15  # Base Fib score
        if overlaps_orderblock(bar.close):
            score += 10  # OB confluence
        if in_fvg_zone(bar.close):
            score += 10  # FVG confluence
```

**Esforco:** 4-6 horas  
**Prioridade:** **P1**  
**Status:** ❌ TODO  
**Referencias:** `DOCS/03_RESEARCH/FINDINGS/FIBONACCI_XAUUSD_RESEARCH.md`

---

### 1.2 Adaptive Kelly Position Sizing [PRIORITY: HIGH]

**Source:** Trading Theory (Ralph Vince "Portfolio Mathematics") + ORACLE insights (optimal sizing improves returns without increasing DD)

**Motivacao:** Fixed 1% risk subotimo. Kelly sizing otimiza tamanho de posicao baseado em edge (win rate, avg R). Quando edge forte (alta confluencia), aumenta size; quando fraco, reduz. Teoricamente 15-25% mais retorno sem aumentar max DD.

**Arquivos alvo:**
- `src/risk/position_sizer.py`
- `src/risk/prop_firm_manager.py`

**Proposta (conceito):**
```python
def calculate_kelly_fraction(win_rate: float, avg_win: float, avg_loss: float) -> float:
    """Calculate optimal Kelly fraction for position sizing"""
    kelly = (win_rate * avg_win - (1 - win_rate) * avg_loss) / avg_win
    return kelly * 0.5  # Half-Kelly for safety

class AdaptivePositionSizer:
    def calculate_size(...):
        kelly = self.calculate_kelly_fraction(recent_win_rate, avg_win, avg_loss)
        risk_pct = kelly * base_risk_pct
        
        # Reduce size during drawdown
        if current_dd > 0.03:
            risk_pct *= 0.5  # 50% size at 3% DD
        if current_dd > 0.05:
            risk_pct *= 0.25  # 25% size at 5% DD (near Apex limit)
        
        return self._calculate_units(risk_pct, sl_distance)
```

**Esforco:** 6-8 horas  
**Prioridade:** **P1**  
**Status:** ❌ TODO  
**Referencias:** Ralph Vince "Portfolio Mathematics"

---

### 1.3 Spread-Aware Entry Timing [PRIORITY: HIGH]

**Source:** FORGE bottleneck analysis + `DOCS/02_IMPLEMENTATION/FUTURE_IMPROVEMENTS.md` (Spread Awareness section)

**Motivacao:** Wide spreads (>15 points XAUUSD) matam R:R. Entrando cegamente durante spike de spread desperdiça edge. Monitorar spread + adiar entry quando spread >1.5x media pode reduzir slippage 5-10%.

**Arquivos alvo:**
- `src/execution/trade_executor.py` (a criar)
- `src/indicators/spread_monitor.py` (a criar)

**Proposta (conceito):**
```python
class SpreadMonitor:
    def __init__(self):
        self.spread_history = deque(maxlen=100)
        self.avg_spread = 0.0
    
    def is_spread_acceptable(self, current_spread: float) -> bool:
        """Check if spread is within acceptable range"""
        if not self.spread_history:
            return True
        
        spread_ratio = current_spread / self.avg_spread
        return spread_ratio <= 1.5  # Block if spread >1.5x average

class TradeExecutor:
    def execute_entry(...):
        if not self.spread_monitor.is_spread_acceptable(current_spread):
            self.logger.warning("Wide spread detected, delaying entry")
            return None  # Wait for better spread
        
        # Proceed with entry...
```

**Esforco:** 4-6 horas  
**Prioridade:** **P1**  
**Status:** ❌ TODO

---

## PHASE 2: HIGH-VALUE ENHANCEMENTS (P2) 🚀

### 2.1 Bayesian Confluence System [PRIORITY: HIGH]

**Motivacao:** Score aditivo atual (0-100) trata indicadores como independentes. Bayesian approach modela probabilidades condicionais P(Win|HTF,MTF,LTF,Regime,Session) → estimativas de confianca mais precisas, menos falsos positivos.

**Arquivos alvo:**
- `src/signals/confluence_engine.py`

**Proposta (conceito):**
```python
class BayesianConfluenceEngine:
    def __init__(self):
        # Priors calibrados de backtest data (>1000 trades)
        self.p_win_given_htf_aligned = 0.62
        self.p_win_given_mtf_structure = 0.58
        self.p_win_given_ltf_confirmed = 0.55
        self.p_win_given_trending_regime = 0.60
        self.p_win_baseline = 0.52
    
    def calculate_probability(self, context: SignalContext) -> float:
        """Calculate P(Win|Evidence) using Bayesian inference"""
        p_win = self.p_win_baseline
        
        if context.htf_aligned:
            p_win *= self.p_win_given_htf_aligned / self.p_win_baseline
        if context.mtf_structure_valid:
            p_win *= self.p_win_given_mtf_structure / self.p_win_baseline
        if context.ltf_confirmed:
            p_win *= self.p_win_given_ltf_confirmed / self.p_win_baseline
        
        return min(p_win, 0.95)  # Cap at 95%
```

**Esforco:** 2-3 dias  
**Prioridade:** P2  
**Status:** ❌ PLANNED  
**Dependencies:** >1000 trades backtest data para calibrar priors  
**Referencias:** Pearl "Probabilistic Reasoning in Intelligent Systems"

---

### 2.2 Hidden Markov Model (HMM) Regime Predictor [PRIORITY: HIGH]

**Motivacao:** Hurst/Entropy atuais sao reativos. HMM prediz transicoes de regime proativamente → evita entrar em regime shift, reduz whipsaws 20-30%.

**Arquivos alvo:**
- `src/indicators/hmm_regime_predictor.py` (a criar)
- `src/strategies/gold_scalper_strategy.py`

**Proposta (conceito):**
```python
from hmmlearn import hmm

class HMMRegimePredictor:
    def __init__(self):
        self.model = hmm.GaussianHMM(n_components=3)  # trending/ranging/transitional
        self.state_names = ['trending', 'ranging', 'transitional']
    
    def train(self, returns: np.ndarray):
        """Train HMM on historical returns"""
        X = returns.reshape(-1, 1)
        self.model.fit(X)
    
    def predict_regime(self, recent_returns: np.ndarray) -> str:
        """Predict current regime state"""
        X = recent_returns.reshape(-1, 1)
        state = self.model.predict(X)[-1]
        return self.state_names[state]
    
    def get_transition_probability(self) -> float:
        """Probability of regime transition in next period"""
        return 1.0 - np.max(self.model.transmat_[self.current_state])
```

**Esforco:** 3-5 dias  
**Prioridade:** P2  
**Status:** ❌ PLANNED  
**Dependencies:** hmmlearn library  
**Referencias:** Rabiner "A Tutorial on Hidden Markov Models"

---

### 2.3 Strategy Selector Actor [PRIORITY: MEDIUM]

**Motivacao:** Single strategy nao otimo em todos regimes. Ensemble approach switch entre strategies (scalper/swing/reversal) baseado em market context. Sharpe ratio +25-40% (teorico, precisa validacao).

**Arquivos alvo:**
- `src/strategies/strategy_selector.py` (a criar - NautilusTrader Actor)
- `src/strategies/gold_scalper_strategy.py`

**Proposta (conceito):**
```python
class StrategySelector(Actor):
    """Routes to optimal strategy based on regime/volatility/session"""
    
    def __init__(self):
        self.strategies = {
            'scalper': GoldScalperStrategy(...),
            'swing': SwingStrategy(...),
            'reversal': ReversalStrategy(...)
        }
        self.current_strategy = 'scalper'
    
    def on_regime_change(self, regime: RegimeType):
        """Switch strategy on regime change"""
        if regime == RegimeType.TRENDING:
            self.current_strategy = 'scalper'
        elif regime == RegimeType.MEAN_REVERTING:
            self.current_strategy = 'reversal'
        else:  # RANDOM_WALK
            self.current_strategy = None  # No trading
        
        self.log.info(f"Strategy switched to: {self.current_strategy}")
```

**Esforco:** 8-12 horas  
**Prioridade:** P2  
**Status:** ❌ PLANNED  
**Dependencies:** Multiple validated strategies

---

### 2.4 Transformer-Lite Direction Predictor [PRIORITY: MEDIUM]

**Motivacao:** LSTM/MLP nao capturam long-range dependencies bem. Transformers melhores para price action sequences. Lightweight (4 heads, 32 dim, ~10K params) pode melhorar direcao 5-15% vs LSTM baseline com <5ms latency ONNX.

**Arquivos alvo:**
- `src/ml/transformer_predictor.py` (a criar)
- Training pipeline separado

**Proposta (conceito):**
```python
import torch.nn as nn

class TransformerLite(nn.Module):
    def __init__(self, input_dim=10, embed_dim=32, num_heads=4):
        super().__init__()
        self.embedding = nn.Linear(input_dim, embed_dim)
        self.transformer = nn.TransformerEncoder(
            nn.TransformerEncoderLayer(embed_dim, num_heads, dim_feedforward=64),
            num_layers=2
        )
        self.direction_head = nn.Linear(embed_dim, 3)  # long/short/neutral
        self.magnitude_head = nn.Linear(embed_dim, 1)  # expected move
        self.confidence_head = nn.Linear(embed_dim, 1)  # sigmoid confidence
    
    def forward(self, x):  # x: [batch, seq_len=100, features=10]
        x = self.embedding(x)
        x = self.transformer(x)
        pooled = x.mean(dim=1)
        
        direction = self.direction_head(pooled).softmax(dim=-1)
        magnitude = self.magnitude_head(pooled)
        confidence = self.confidence_head(pooled).sigmoid()
        
        return direction, magnitude, confidence
```

**Esforco:** 1-2 semanas (training + ONNX export + validation)  
**Prioridade:** P2  
**Status:** ❌ PLANNED  
**Dependencies:** GPU para training, large tick dataset  
**Referencias:** Vaswani "Attention Is All You Need"

---

## PHASE 3: NICE TO HAVE (P3) 📊

### 3.1 Order Flow Imbalance Detection [PRIORITY: MEDIUM]

**Motivacao:** Institutional order flow (large buy/sell imbalances) prediz short-term moves. Volume spikes, absorption patterns, rejection candles → melhora timing de entry 5-10%.

**Arquivos alvo:**
- `src/indicators/orderflow_analyzer.py` (a criar)

**Proposta (conceito):**
```python
class OrderFlowAnalyzer:
    def detect_imbalance(self, ticks: List[QuoteTick]) -> ImbalanceSignal:
        """Detect order flow patterns from tick data"""
        buy_volume = sum(t.size for t in ticks if t.is_buy)
        sell_volume = sum(t.size for t in ticks if t.is_sell)
        
        imbalance_ratio = buy_volume / sell_volume if sell_volume > 0 else 1.0
        
        if imbalance_ratio > 2.0:
            return ImbalanceSignal.STRONG_BUY
        elif imbalance_ratio < 0.5:
            return ImbalanceSignal.STRONG_SELL
        else:
            return ImbalanceSignal.NEUTRAL
```

**Esforco:** 1-2 dias  
**Prioridade:** P3  
**Status:** ❌ PLANNED  
**Dependencies:** Tick-level volume data (QuoteTick)

---

### 3.2 Walk-Forward Optimization Framework [PRIORITY: MEDIUM]

**Motivacao:** Static backtests overfitam. WFO split data em train/test windows, reoptimiza parametros periodicamente → performance realista.

**Arquivos alvo:**
- `scripts/wfo_runner.py` (a criar)

**Proposta (conceito):**
```python
class WalkForwardOptimizer:
    def __init__(self, train_window=180, test_window=30, step=30):
        self.train_window = train_window  # days
        self.test_window = test_window
        self.step = step
    
    def run(self, data, parameter_space):
        """Run walk-forward optimization"""
        results = []
        
        for start_date in self.generate_windows(data):
            # Train window
            train_data = data[start_date:start_date + self.train_window]
            best_params = optimize(train_data, parameter_space)
            
            # Test window (out-of-sample)
            test_data = data[start_date + self.train_window:start_date + self.train_window + self.test_window]
            test_result = backtest(test_data, best_params)
            results.append(test_result)
        
        return self.aggregate_results(results)
```

**Esforco:** 3-5 dias  
**Prioridade:** P3  
**Status:** ❌ PLANNED  
**Dependencies:** Existing backtest framework, Optuna  
**Referencias:** Pardo "The Evaluation and Optimization of Trading Strategies"

---

### 3.3 Dynamic Circuit Breaker [PRIORITY: MEDIUM]

**Motivacao:** Fixed 5% DD muito rigido. Dynamic CB adapta ao regime de volatilidade - tighter em ranging, looser em trending. Reduz false stops 10-20%.

**Arquivos alvo:**
- `src/risk/dynamic_circuit_breaker.py` (a criar)
- `src/risk/prop_firm_manager.py`

**Proposta (conceito):**
```python
class DynamicCircuitBreaker:
    def __init__(self, base_dd_limit=0.05):
        self.base_dd_limit = base_dd_limit
    
    def calculate_adjusted_limit(self, atr_regime: float) -> float:
        """Adjust DD limit based on volatility regime"""
        if atr_regime > 1.5:  # High volatility
            multiplier = 1.2  # +20% tolerance
        elif atr_regime < 0.7:  # Low volatility
            multiplier = 0.8  # -20% tighter
        else:
            multiplier = 1.0
        
        return self.base_dd_limit * multiplier
    
    def should_halt(self, current_dd: float, atr_regime: float) -> bool:
        """Check if trading should halt"""
        adjusted_limit = self.calculate_adjusted_limit(atr_regime)
        return current_dd >= adjusted_limit
```

**Esforco:** 6-8 horas  
**Prioridade:** P3  
**Status:** ❌ PLANNED

---

## PHASE 4: RESEARCH & EXPERIMENTATION (P4) 🔬

### 4.1 Meta-Learning Strategy Selector [PRIORITY: LOW]

**Motivacao:** Train meta-model que aprende QUANDO cada strategy funciona melhor → automatic strategy switching.

**Arquivos alvo:**
- `src/ml/meta_learner.py` (a criar)

**Proposta (conceito):**
```python
import xgboost as xgb

class MetaLearner:
    def __init__(self):
        self.model = xgb.XGBClassifier()
    
    def train(self, features, strategy_performance):
        """Train meta-model: features → best strategy"""
        # Features: regime, volatility, time, drawdown state, ...
        # Target: which strategy performed best
        self.model.fit(features, strategy_performance)
    
    def predict_best_strategy(self, current_context) -> str:
        """Predict optimal strategy for current context"""
        features = self.extract_features(current_context)
        return self.model.predict(features)[0]
```

**Esforco:** 2-3 semanas  
**Prioridade:** P4  
**Status:** 💡 IDEA  
**Dependencies:** Multiple validated strategies, large historical dataset  
**Referencias:** Hospedales "Meta-Learning in Neural Networks"

---

### 4.2 Spread Predictor LSTM [PRIORITY: LOW]

**Motivacao:** Spread widens predictably antes de news/volatile moves. Prever spread 5-15min ahead → atrasar entries se spike predicted. Reduz adverse fills 3-5%.

**Arquivos alvo:**
- `src/ml/spread_predictor.py` (a criar)

**Proposta (conceito):**
```python
class SpreadPredictorLSTM:
    def __init__(self):
        self.model = self.build_model()
    
    def build_model(self):
        model = Sequential([
            LSTM(64, return_sequences=True, input_shape=(60, 5)),  # 60 minutes, 5 features
            LSTM(32),
            Dense(16, activation='relu'),
            Dense(1)  # Predicted spread in 15 minutes
        ])
        return model
    
    def predict_spread(self, historical_spreads, calendar_features):
        """Predict spread in next 15 minutes"""
        features = self.engineer_features(historical_spreads, calendar_features)
        return self.model.predict(features)[0]
```

**Esforco:** 1-2 semanas  
**Prioridade:** P4  
**Status:** 💡 IDEA  
**Dependencies:** Historical spread dataset

---

### 4.3 Portfolio Heat Management [PRIORITY: LOW]

**Motivacao:** Multiple correlated positions (3 XAUUSD longs) = compounded risk. Portfolio heat = sum of correlated risks. Reduce size quando heat >threshold → -10-15% correlated drawdowns.

**Arquivos alvo:**
- `src/risk/portfolio_heat_manager.py` (a criar)

**Proposta (conceito):**
```python
class PortfolioHeatManager:
    def __init__(self, max_heat=0.03):
        self.max_heat = max_heat
        self.correlation_matrix = None
    
    def calculate_portfolio_heat(self, positions: List[Position]) -> float:
        """Calculate aggregate risk across correlated positions"""
        if len(positions) <= 1:
            return sum(p.risk_dollars for p in positions)
        
        risks = np.array([p.risk_dollars for p in positions])
        correlation = self.estimate_correlation(positions)
        
        # Portfolio variance = sum(ri * rj * corr_ij)
        portfolio_risk = np.sqrt(risks @ correlation @ risks.T)
        return portfolio_risk / self.account_equity
    
    def should_reduce_size(self, heat: float) -> bool:
        """Check if position sizes should be reduced"""
        return heat > self.max_heat
```

**Esforco:** 1 semana  
**Prioridade:** P4  
**Status:** 💡 IDEA  
**Dependencies:** Multi-position support

---

## ARCHIVED - IMPLEMENTED ✅

### Tick-Level Backtesting
**Status:** ✅ DONE  
**Date:** 2025-12-03  
**Impact:** Backtests 90%+ aligned with live (vs 60% before)  
**Files:** `scripts/run_backtest.py`

### Intrabar Drawdown Tracking
**Status:** ✅ DONE  
**Date:** 2025-12-03  
**Impact:** Prevents Apex 5% trailing DD violations  
**Files:** `src/risk/drawdown_tracker.py`

### News Calendar Integration
**Status:** ✅ DONE  
**Date:** 2025-12-03  
**Impact:** 40-60% reduction in whipsaw losses during news  
**Files:** `src/signals/news_calendar.py`

---

## ARCHIVED - REJECTED ❌

### Grid/Martingale Position Averaging
**Status:** ❌ REJECTED  
**Date:** 2025-12-01  
**Reason:** Violates Apex rules (trailing DD), high risk of account blow-up, conflicts with BUILD>PLAN philosophy. We build robust edges, not gamble recovery.

### High-Frequency Scalping (<1min holds)
**Status:** ❌ REJECTED  
**Date:** 2025-11-28  
**Reason:** Spread costs too high (15-20 points XAUUSD), latency requirements unrealistic for retail Apex setup. Focus on 5-30min holds instead.

---

## REFERENCES

**Papers:**
- Shanaev & Gibson (2022) - "Fibonacci Retracements in XAUUSD"
- Ralph Vince - "Portfolio Mathematics" (Kelly sizing)
- Pearl - "Probabilistic Reasoning in Intelligent Systems" (Bayesian)
- Rabiner - "A Tutorial on Hidden Markov Models"
- Pardo - "The Evaluation and Optimization of Trading Strategies" (WFO)
- Vaswani et al - "Attention Is All You Need" (Transformers)

**NautilusTrader:**
- Official docs: https://nautilustrader.io/
- Strategy examples: https://github.com/nautechsystems/nautilus_trader/tree/develop/examples
- Actor pattern: https://nautilustrader.io/docs/latest/concepts/advanced/actors

---

## CHANGELOG

| Date | Change |
|------|--------|
| 2025-12-24 | **NEW** - Added Setup Quality Filter (P1, conditional on Ghost Test) from Phase 00-C |
| 2025-12-08 | **TEMPLATE FIX** - Reformatted to match DOCS/02_IMPLEMENTATION/FUTURE_IMPROVEMENTS.md structure |
| 2025-12-08 | Initial creation with 12 ideas organized by priority (P1-P4) |

---

*"Ideas are cheap. Implementation is expensive. Choose wisely."* - FORGE
