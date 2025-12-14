# MASTER EXECUTION PLAN v3.0 - GENIUS EDITION
## EA_SCALPER_XAUUSD - Institutional Grade + Mathematical Genius

**Criado**: 2025-12-01
**Versão**: 3.0 - GENIUS EDITION
**Filosofia**: "Maximize Expected Utility, Not Expected Return"

---

## OS 7 PRINCÍPIOS GENIUS

Antes de qualquer implementação, internalize estes princípios que separam traders medianos de traders de elite:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     OS 7 PRINCÍPIOS DO TRADER GENIUS                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. KELLY CRITERION - O Sizing Ótimo                                       │
│     "Maximize o crescimento geométrico do capital, não o lucro esperado"   │
│     f* = (p × b - q) / b                                                   │
│     Onde: p=prob win, q=prob loss, b=win/loss ratio                        │
│     → Usar FRACTIONAL KELLY (0.25-0.5) para safety margin                  │
│                                                                             │
│  2. CONVEXIDADE - Payoff Assimétrico                                       │
│     "Pequenas perdas frequentes, grandes ganhos raros = Convexidade"       │
│     → R:R mínimo 1.5:1, ideal 2:1+                                         │
│     → Cortar losses RÁPIDO, deixar winners RUN                             │
│     → Adicionar a winners, NUNCA a losers                                  │
│                                                                             │
│  3. PHASE TRANSITIONS - Física dos Regimes                                 │
│     "Mercados são sistemas complexos com transições de fase"               │
│     → Critical slowing down ANTES de transição                             │
│     → Detectar via: Hurst decay, variance increase, autocorr flip          │
│     → REDUZIR exposição durante transições (incerteza máxima)              │
│                                                                             │
│  4. FRACTAL GEOMETRY - Multi-Scale Patterns                                │
│     "Padrões se repetem em múltiplas escalas temporais"                    │
│     → Confluência MTF: M5 + M15 + H1 + H4                                  │
│     → Mesmo padrão em 3+ timeframes = ALTA CONFIANÇA                       │
│     → Divergência MTF = CAUTELA ou NO TRADE                                │
│                                                                             │
│  5. INFORMATION THEORY - Edge Decay                                        │
│     "Informação tem meio-vida. Edge decai com tempo e uso"                 │
│     → Medir edge decay: Sharpe rolling, PF rolling                         │
│     → Se edge < threshold por N dias: PARAR e recalibrar                   │
│     → Diversificar fontes de edge (não depender de uma)                    │
│                                                                             │
│  6. ENSEMBLE DIVERSITY - Correlação de Erros                               │
│     "O valor de um ensemble está na BAIXA correlação de erros"             │
│     → Combinar estratégias com diferentes failure modes                    │
│     → Momentum + Mean Reversion = baixa correlação                         │
│     → Medir: correlation matrix dos returns por estratégia                 │
│                                                                             │
│  7. TAIL RISK OBSESSION - Extreme Value Theory                             │
│     "Não é o DD médio que te quebra, é o DD extremo"                       │
│     → Modelar tail usando EVT (Generalized Pareto Distribution)            │
│     → Calcular Expected Shortfall (CVaR), não só VaR                       │
│     → Monte Carlo com TAIL SCENARIOS, não só shuffle                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## INTEGRAÇÃO DOS PRINCÍPIOS POR FASE

### Mapa de Aplicação

| Fase | Princípios Aplicados | Como |
|------|---------------------|------|
| **Fase 1: Data** | 3, 4 | Validar regime diversity, MTF coverage |
| **Fase 2: Backtest** | 1, 2, 3, 4 | Multi-regime, convexity metrics, Kelly prep |
| **Fase 3: ML** | 5, 6 | Edge decay monitoring, ensemble uncorrelated |
| **Fase 4: Shadow** | 7 | Tail latency injection, extreme scenarios |
| **Fase 5: Validation** | 1, 5, 7 | Kelly optimal calc, edge stability, EVT |
| **Fase 6: Stress** | 3, 7 | Phase transitions, tail events |
| **Fase 7-8: Live** | 1, 2, 5 | Fractional Kelly, convex sizing, edge monitor |

---

## FASE 0: AUDIT DO CÓDIGO ✅ COMPLETA

*(Mantido do v2.0 - Score médio 19.5/20)*

---

## FASE 1: VALIDAÇÃO DE DADOS + GENIUS

**Princípios Aplicados**: #3 (Phase Transitions), #4 (Fractals)

### 1.1 Validação Genius de Dados

```
ALÉM DA VALIDAÇÃO BÁSICA, VERIFICAR:

PRINCÍPIO #3 - PHASE TRANSITIONS:
├── Dados contêm TODAS as fases de mercado?
│   ├── Bull markets (trending up)
│   ├── Bear markets (trending down)
│   ├── Ranging/consolidation
│   ├── High volatility events (flash crashes)
│   └── Low volatility periods
├── Transições de regime estão presentes?
│   └── Mínimo 50 transições detectáveis para treinar detector
└── Volatility clustering presente? (GARCH-like behavior)

PRINCÍPIO #4 - FRACTALS:
├── Dados disponíveis em múltiplos timeframes?
│   ├── Tick data (base)
│   ├── M1, M5, M15, H1, H4, D1 (derivados)
│   └── Consistência entre TFs verificada
├── Padrões fractais detectáveis?
│   ├── Mesma estrutura em TFs diferentes
│   └── Self-similarity coefficient calculado
└── MTF alignment em dados históricos

SCRIPT: scripts/validate_data_genius.py
OUTPUT: DATA_QUALITY_GENIUS_REPORT.md

CRITÉRIOS ADICIONAIS:
├── Regime diversity score >= 80 (todos regimes representados)
├── Transition count >= 50
├── MTF consistency >= 95%
└── GARCH clustering detectável
```

### 1.2 Tarefa: Criar Validador Genius

```
PROMPT PARA FORGE:

"Forge, estenda validate_data.py para incluir validação genius:

ADICIONAR:

1. REGIME TRANSITION DETECTION:
   def count_regime_transitions(df, hurst_window=500):
       '''
       Detecta transições de regime usando Hurst Exponent.
       Retorna: count de transições, avg_duration, transition_velocity
       '''
       hursts = rolling_hurst(df['mid'], window=hurst_window)
       
       regimes = []
       for h in hursts:
           if h > 0.55: regimes.append('TRENDING')
           elif h < 0.45: regimes.append('REVERTING')
           else: regimes.append('RANDOM')
       
       transitions = sum(1 for i in range(1, len(regimes)) 
                        if regimes[i] != regimes[i-1])
       
       # Velocity: Quão rápido Hurst muda antes de transição
       velocities = np.diff(hursts)
       critical_velocities = velocities[np.abs(velocities) > 0.05]
       
       return {
           'transition_count': transitions,
           'avg_duration_hours': total_hours / (transitions + 1),
           'avg_transition_velocity': np.mean(np.abs(critical_velocities)),
           'max_transition_velocity': np.max(np.abs(critical_velocities))
       }

2. VOLATILITY CLUSTERING (GARCH-like):
   def check_volatility_clustering(df):
       '''
       Verifica se volatilidade apresenta clustering (autocorrelação).
       Mercados reais têm volatility clustering.
       '''
       returns = df['mid'].pct_change().dropna()
       abs_returns = np.abs(returns)
       
       # Autocorrelação de volatilidade
       autocorr_1 = abs_returns.autocorr(lag=1)
       autocorr_5 = abs_returns.autocorr(lag=5)
       autocorr_20 = abs_returns.autocorr(lag=20)
       
       # GARCH-like: autocorr deve ser positiva e significativa
       has_clustering = (autocorr_1 > 0.1 and autocorr_5 > 0.05)
       
       return {
           'has_clustering': has_clustering,
           'autocorr_lag1': autocorr_1,
           'autocorr_lag5': autocorr_5,
           'autocorr_lag20': autocorr_20,
           'clustering_score': (autocorr_1 + autocorr_5) / 2 * 100
       }

3. MTF CONSISTENCY:
   def check_mtf_consistency(tick_df):
       '''
       Verifica que dados agregados em diferentes TFs são consistentes.
       '''
       m5 = resample(tick_df, '5min')
       m15 = resample(tick_df, '15min')
       h1 = resample(tick_df, '1h')
       
       # M15 high deve ser max dos M5 highs correspondentes
       # H1 close deve ser igual ao último M5 close
       
       errors = 0
       for h1_bar in h1:
           corresponding_m5 = m5[h1_bar.start:h1_bar.end]
           if h1_bar.high != max(corresponding_m5.high):
               errors += 1
       
       consistency = 1 - (errors / len(h1))
       return {'mtf_consistency': consistency * 100}

4. QUALITY SCORE GENIUS (0-100):
   Componentes:
   ├── Basic Quality (40 pts): clean %, gaps, spread
   ├── Regime Diversity (20 pts): all regimes present
   ├── Transitions (15 pts): >= 50 detectáveis
   ├── Vol Clustering (15 pts): GARCH-like presente
   └── MTF Consistency (10 pts): >= 95%
"
```

---

## FASE 2: BACKTEST BASELINE + GENIUS

**Princípios Aplicados**: #1 (Kelly), #2 (Convexidade), #3 (Phase Transitions), #4 (Fractals)

### 2.1 Kelly Criterion Preparation

```
PRINCÍPIO #1 - KELLY CRITERION:

ANTES de rodar backtest, configurar para COLETAR dados de Kelly:

1. MÉTRICAS A COLETAR POR TRADE:
   ├── Win/Loss (binário)
   ├── R-multiple (profit / initial_risk)
   ├── Regime no momento do trade
   ├── Sessão no momento do trade
   └── MTF alignment score

2. APÓS BACKTEST, CALCULAR KELLY POR SEGMENTO:

   def calculate_kelly_by_segment(trades):
       segments = {}
       
       for regime in ['TRENDING', 'REVERTING']:
           for session in ['LONDON', 'OVERLAP', 'NY']:
               segment_trades = filter(trades, regime, session)
               
               wins = [t for t in segment_trades if t.profit > 0]
               losses = [t for t in segment_trades if t.profit <= 0]
               
               p = len(wins) / len(segment_trades)  # Win rate
               q = 1 - p
               avg_win = mean([t.profit for t in wins])
               avg_loss = abs(mean([t.profit for t in losses]))
               b = avg_win / avg_loss  # Win/Loss ratio
               
               kelly_full = (p * b - q) / b
               kelly_half = kelly_full * 0.5  # Safer
               kelly_quarter = kelly_full * 0.25  # Safest
               
               segments[f'{regime}_{session}'] = {
                   'kelly_full': kelly_full,
                   'kelly_half': kelly_half,
                   'kelly_quarter': kelly_quarter,
                   'sample_size': len(segment_trades),
                   'confidence': 'HIGH' if len(segment_trades) > 100 else 'LOW'
               }
       
       return segments

3. OUTPUT: KELLY_TABLE.md
   | Regime | Session | Kelly Full | Kelly Half | Sample | Confidence |
   |--------|---------|------------|------------|--------|------------|
   | TREND  | LONDON  | 4.2%       | 2.1%       | 234    | HIGH       |
   | TREND  | OVERLAP | 5.1%       | 2.55%      | 189    | HIGH       |
   | REVERT | NY      | 2.8%       | 1.4%       | 87     | MEDIUM     |
```

### 2.2 Convexity Metrics

```
PRINCÍPIO #2 - CONVEXIDADE:

MÉTRICAS DE CONVEXIDADE A CALCULAR:

1. PAYOFF ASYMMETRY:
   asymmetry = avg_win / abs(avg_loss)
   → Target: >= 1.5 (idealmente 2.0+)

2. SKEWNESS OF RETURNS:
   skew = scipy.stats.skew(returns)
   → Positive skew = convex (pequenas perdas, grandes ganhos)
   → Target: skew > 0

3. GAIN-TO-PAIN RATIO:
   gpr = sum(positive_returns) / abs(sum(negative_returns))
   → Similar a PF, mas usa soma, não média

4. TAIL RATIO:
   tail_ratio = percentile_95_wins / abs(percentile_95_losses)
   → Mede assimetria nas tails
   → Target: > 1.0

5. CONVEXITY SCORE:
   score = 25 * min(asymmetry/2, 1) + 
           25 * (1 if skew > 0 else 0) +
           25 * min(gpr/1.5, 1) +
           25 * min(tail_ratio, 1)
   → Target: >= 70/100

SCRIPT: scripts/oracle/convexity_metrics.py
```

### 2.3 Multi-Regime Backtest com Genius Metrics

```
PROMPT PARA FORGE:

"Forge, modifique o backtester para coletar genius metrics:

class GeniusBacktester(EventBacktester):
    def __init__(self, config):
        super().__init__(config)
        self.kelly_data = []
        self.convexity_tracker = ConvexityTracker()
        self.regime_tracker = RegimeTracker()
        self.mtf_tracker = MTFTracker()
    
    def on_trade_close(self, trade):
        # Coletar dados para Kelly
        self.kelly_data.append({
            'profit': trade.pnl,
            'risk': trade.initial_risk,
            'r_multiple': trade.pnl / trade.initial_risk,
            'regime': self.regime_tracker.current_regime,
            'session': self.session_tracker.current_session,
            'mtf_alignment': self.mtf_tracker.alignment_score
        })
        
        # Atualizar convexity tracker
        self.convexity_tracker.add(trade.pnl)
    
    def generate_genius_report(self):
        kelly_table = calculate_kelly_by_segment(self.kelly_data)
        convexity = self.convexity_tracker.get_metrics()
        regime_performance = self.regime_tracker.get_performance()
        
        return GeniusReport(
            kelly=kelly_table,
            convexity=convexity,
            regime=regime_performance,
            recommendations=self._generate_recommendations()
        )
    
    def _generate_recommendations(self):
        recs = []
        
        # Kelly recommendations
        for segment, data in self.kelly_table.items():
            if data['kelly_half'] > 3:
                recs.append(f'{segment}: Kelly alto ({data["kelly_half"]:.1f}%), pode aumentar size')
            elif data['kelly_half'] < 0:
                recs.append(f'{segment}: Kelly NEGATIVO! NÃO OPERAR neste segmento')
        
        # Convexity recommendations
        if self.convexity.asymmetry < 1.5:
            recs.append('Convexity: Aumentar R:R target ou melhorar entries')
        
        if self.convexity.skew < 0:
            recs.append('Convexity: Skew negativo - verificar se está cortando winners cedo')
        
        return recs
"
```

### 2.4 Phase Transition Detection em Backtest

```
PRINCÍPIO #3 - PHASE TRANSITIONS:

DURANTE BACKTEST, DETECTAR E REAGIR A TRANSIÇÕES:

class RegimeTracker:
    def __init__(self, hurst_window=100, critical_threshold=0.1):
        self.hurst_history = []
        self.current_regime = 'UNKNOWN'
        self.transition_warning = False
        
    def update(self, price):
        self.hurst_history.append(price)
        
        if len(self.hurst_history) >= self.hurst_window:
            hurst = calculate_hurst(self.hurst_history[-self.hurst_window:])
            
            # Detectar critical slowing down (precursor de transição)
            if len(self.hurst_history) >= self.hurst_window * 2:
                hurst_velocity = self._hurst_velocity()
                hurst_variance = self._hurst_variance()
                
                # Critical slowing down: velocity baixa + variance alta
                if abs(hurst_velocity) < 0.001 and hurst_variance > 0.02:
                    self.transition_warning = True
                else:
                    self.transition_warning = False
            
            # Atualizar regime
            if hurst > 0.55:
                new_regime = 'TRENDING'
            elif hurst < 0.45:
                new_regime = 'REVERTING'
            else:
                new_regime = 'RANDOM'
            
            if new_regime != self.current_regime:
                self._on_regime_change(self.current_regime, new_regime)
                self.current_regime = new_regime
    
    def should_reduce_exposure(self):
        '''
        Reduzir exposição durante transições (incerteza alta)
        '''
        return self.transition_warning or self.current_regime == 'RANDOM'
    
    def get_exposure_multiplier(self):
        '''
        Multiplier para position size baseado em regime
        '''
        if self.transition_warning:
            return 0.25  # Reduzir 75% durante transição
        elif self.current_regime == 'RANDOM':
            return 0.0   # Não operar em random walk
        elif self.current_regime == 'TRENDING':
            return 1.0   # Full exposure em trending
        else:  # REVERTING
            return 0.7   # Slightly reduced em reverting

MÉTRICAS A COLETAR:
├── Número de transições detectadas
├── Accuracy da detecção (se previu corretamente)
├── Performance durante transições vs normal
└── Drawdown durante transições vs normal
```

### 2.5 MTF Fractal Alignment

```
PRINCÍPIO #4 - FRACTAL GEOMETRY:

class MTFTracker:
    def __init__(self, timeframes=['M5', 'M15', 'H1', 'H4']):
        self.timeframes = timeframes
        self.signals = {tf: None for tf in timeframes}
    
    def update(self, tf, signal):
        '''
        signal: 'BUY', 'SELL', 'NEUTRAL'
        '''
        self.signals[tf] = signal
    
    @property
    def alignment_score(self):
        '''
        Score de 0-100 baseado em quantos TFs concordam
        '''
        if None in self.signals.values():
            return 0
        
        buy_count = sum(1 for s in self.signals.values() if s == 'BUY')
        sell_count = sum(1 for s in self.signals.values() if s == 'SELL')
        
        max_aligned = max(buy_count, sell_count)
        return (max_aligned / len(self.timeframes)) * 100
    
    @property
    def dominant_signal(self):
        '''
        Retorna sinal dominante se alignment > 75%
        '''
        if self.alignment_score < 75:
            return 'NEUTRAL'
        
        buy_count = sum(1 for s in self.signals.values() if s == 'BUY')
        sell_count = sum(1 for s in self.signals.values() if s == 'SELL')
        
        return 'BUY' if buy_count > sell_count else 'SELL'
    
    def get_fractal_confidence(self):
        '''
        Confiança baseada em padrão fractal
        Se mesmo padrão em 3+ TFs = ALTA
        '''
        # Verificar se estrutura de mercado é similar
        structures = self._detect_market_structures()
        
        similar_count = self._count_similar_structures(structures)
        
        if similar_count >= 3:
            return 'HIGH'
        elif similar_count >= 2:
            return 'MEDIUM'
        else:
            return 'LOW'

USO NO BACKTESTER:
if mtf_tracker.alignment_score >= 75 and mtf_tracker.get_fractal_confidence() == 'HIGH':
    position_multiplier = 1.2  # Boost position em alta confluência
elif mtf_tracker.alignment_score < 50:
    position_multiplier = 0.0  # Não operar sem confluência
```

---

## FASE 3: TREINAMENTO ML + GENIUS

**Princípios Aplicados**: #5 (Information Theory), #6 (Ensemble Diversity)

### 3.1 Edge Decay Monitoring

```
PRINCÍPIO #5 - INFORMATION THEORY:

CONCEITO: Todo edge tem meio-vida. Monitorar decay é crucial.

class EdgeDecayMonitor:
    def __init__(self, decay_threshold=0.3, lookback_windows=[20, 50, 100]):
        self.lookback_windows = lookback_windows
        self.decay_threshold = decay_threshold
        self.metrics_history = []
    
    def add_metric(self, sharpe, pf, win_rate, timestamp):
        self.metrics_history.append({
            'timestamp': timestamp,
            'sharpe': sharpe,
            'pf': pf,
            'win_rate': win_rate
        })
    
    def detect_decay(self):
        '''
        Detecta se edge está decaindo comparando janelas recentes vs históricas
        '''
        if len(self.metrics_history) < max(self.lookback_windows):
            return {'decaying': False, 'confidence': 'LOW'}
        
        recent = self.metrics_history[-20:]
        historical = self.metrics_history[-100:-20]
        
        # Comparar Sharpe
        recent_sharpe = np.mean([m['sharpe'] for m in recent])
        historical_sharpe = np.mean([m['sharpe'] for m in historical])
        
        sharpe_decay = (historical_sharpe - recent_sharpe) / historical_sharpe
        
        # Comparar PF
        recent_pf = np.mean([m['pf'] for m in recent])
        historical_pf = np.mean([m['pf'] for m in historical])
        
        pf_decay = (historical_pf - recent_pf) / historical_pf
        
        # Detectar decay significativo
        is_decaying = (sharpe_decay > self.decay_threshold or 
                       pf_decay > self.decay_threshold)
        
        return {
            'decaying': is_decaying,
            'sharpe_decay_pct': sharpe_decay * 100,
            'pf_decay_pct': pf_decay * 100,
            'action': 'PAUSE_AND_RECALIBRATE' if is_decaying else 'CONTINUE'
        }
    
    def calculate_edge_halflife(self):
        '''
        Estima meia-vida do edge baseado em decay histórico
        '''
        if len(self.metrics_history) < 50:
            return None
        
        sharpes = [m['sharpe'] for m in self.metrics_history]
        
        # Fit exponential decay
        from scipy.optimize import curve_fit
        
        def exp_decay(t, a, b):
            return a * np.exp(-b * t)
        
        try:
            popt, _ = curve_fit(exp_decay, range(len(sharpes)), sharpes)
            halflife = np.log(2) / popt[1]
            return halflife  # Em número de observações
        except:
            return None

INTEGRAÇÃO COM ML:

Durante treinamento:
├── Monitorar edge decay entre janelas WFA
├── Se edge decay > 30% entre janelas → modelo está overfitting
├── Ajustar regularização ou simplificar features

Durante live:
├── Calcular rolling metrics a cada N trades
├── Se detect_decay() → PARAR e retreinar
├── Não continuar operando com edge morto
```

### 3.2 Ensemble Diversity

```
PRINCÍPIO #6 - ENSEMBLE DIVERSITY:

CONCEITO: Combinar modelos com BAIXA CORRELAÇÃO DE ERROS

class EnsembleManager:
    def __init__(self):
        self.models = {}
        self.error_matrix = None
    
    def add_model(self, name, model, error_type):
        '''
        error_type: 'momentum', 'mean_reversion', 'breakout', 'ml'
        '''
        self.models[name] = {
            'model': model,
            'error_type': error_type,
            'predictions': [],
            'errors': []
        }
    
    def calculate_error_correlation(self, test_data):
        '''
        Calcula matriz de correlação de ERROS entre modelos
        Objetivo: erros devem ter correlação BAIXA
        '''
        for name, data in self.models.items():
            predictions = data['model'].predict(test_data)
            actuals = test_data['target']
            errors = predictions - actuals
            data['errors'] = errors
        
        # Matriz de correlação de erros
        error_df = pd.DataFrame({
            name: data['errors'] for name, data in self.models.items()
        })
        
        self.error_matrix = error_df.corr()
        return self.error_matrix
    
    def get_diversity_score(self):
        '''
        Score de diversidade baseado em correlação de erros
        Correlação baixa = alta diversidade = melhor ensemble
        '''
        if self.error_matrix is None:
            return 0
        
        # Média das correlações off-diagonal
        n = len(self.models)
        total_corr = 0
        count = 0
        
        for i in range(n):
            for j in range(i+1, n):
                total_corr += abs(self.error_matrix.iloc[i, j])
                count += 1
        
        avg_corr = total_corr / count if count > 0 else 1
        
        # Score: 0 correlação = 100, 1 correlação = 0
        diversity_score = (1 - avg_corr) * 100
        return diversity_score
    
    def optimal_weights(self):
        '''
        Calcula pesos ótimos para ensemble baseado em diversidade
        '''
        # Modelos com erros menos correlacionados recebem mais peso
        # Implementar usando otimização de portfólio (Markowitz-like)
        
        from scipy.optimize import minimize
        
        def portfolio_variance(weights):
            return weights @ self.error_matrix @ weights
        
        n = len(self.models)
        constraints = ({'type': 'eq', 'fun': lambda w: sum(w) - 1})
        bounds = [(0, 1) for _ in range(n)]
        
        result = minimize(
            portfolio_variance,
            x0=np.ones(n) / n,
            bounds=bounds,
            constraints=constraints
        )
        
        return dict(zip(self.models.keys(), result.x))

RECOMENDAÇÕES DE ENSEMBLE:

Combinações com BAIXA correlação de erros:
├── Momentum (trend following) + Mean Reversion: ~0.2 corr
├── Breakout + Range: ~0.3 corr
├── ML Direction + Rule-based: ~0.4 corr
└── Short-term + Long-term: ~0.3 corr

Combinações a EVITAR (alta correlação):
├── MA Cross + MACD: ~0.9 corr (ambos momentum)
├── RSI Overbought + Stochastic: ~0.85 corr
└── Múltiplos modelos ML no mesmo dado: ~0.8+ corr
```

### 3.3 Tarefa: ML Training com Genius

```
PROMPT PARA onnx-model-builder:

"Crie pipeline de ML com Edge Decay e Ensemble:

1. FEATURE ENGINEERING COM INFORMATION THEORY:
   - Calcular entropy de cada feature
   - Features com alta entropy = mais informativas
   - Remover features redundantes (mutual information)

2. TREINAR MULTIPLE MODELS PARA ENSEMBLE:
   Model A: LSTM para tendência (momentum errors)
   Model B: Random Forest para reversão (mean-rev errors)
   Model C: XGBoost para breakout (breakout errors)

3. CALCULAR ERROR CORRELATION:
   - Cada modelo prever no mesmo test set
   - Calcular matriz de correlação de erros
   - Se correlação > 0.5: ajustar ou remover modelo

4. OPTIMAL ENSEMBLE WEIGHTS:
   - Usar diversidade de erros para calcular pesos
   - Modelo com erros menos correlacionados = mais peso

5. EDGE DECAY MONITORING:
   - Para cada janela WFA, calcular métricas
   - Plotar decay de Sharpe ao longo do tempo
   - Se decay > 30%: ALERTA

6. EXPORT:
   - Ensemble model ou melhor single model
   - Weights do ensemble
   - Edge decay baseline para monitoramento futuro
"
```

---

## FASE 4: SHADOW EXCHANGE + GENIUS

**Princípio Aplicado**: #7 (Tail Risk Obsession)

### 4.1 Extreme Value Theory em Latência

```
PRINCÍPIO #7 - TAIL RISK:

CONCEITO: Não é a latência média que te mata, é a latência extrema.

class EVTLatencyModel:
    '''
    Modelo de latência usando Extreme Value Theory
    Foca nas TAILS, não na média
    '''
    
    def __init__(self, base_latency=20):
        self.base_latency = base_latency
        
        # Parâmetros GPD (Generalized Pareto Distribution)
        # Estimados de dados reais de trading
        self.gpd_shape = 0.3   # shape > 0 = heavy tail
        self.gpd_scale = 15    # scale
        self.gpd_threshold = 50  # threshold para tail
        
    def sample(self, n=1, market_condition='normal'):
        '''
        Gera samples de latência com tails realistas
        '''
        samples = []
        
        for _ in range(n):
            # Corpo da distribuição (Gamma)
            body = self.base_latency + np.random.gamma(2.0, 5.0)
            
            # Tail events usando GPD
            if np.random.random() < 0.05:  # 5% tail events
                tail = self._sample_gpd()
                latency = body + tail
            else:
                latency = body
            
            # Market condition multipliers
            if market_condition == 'news':
                latency *= 3
            elif market_condition == 'stress':
                latency *= 5
            elif market_condition == 'flash_crash':
                latency *= 10
            
            samples.append(latency)
        
        return samples if n > 1 else samples[0]
    
    def _sample_gpd(self):
        '''
        Sample da Generalized Pareto Distribution
        Para modelar eventos de tail
        '''
        u = np.random.uniform(0, 1)
        
        if self.gpd_shape == 0:
            return self.gpd_scale * (-np.log(1 - u))
        else:
            return (self.gpd_scale / self.gpd_shape) * ((1 - u)**(-self.gpd_shape) - 1)
    
    def expected_shortfall(self, percentile=95):
        '''
        CVaR: Expected value dado que estamos na tail
        '''
        samples = self.sample(n=10000)
        threshold = np.percentile(samples, percentile)
        tail_samples = [s for s in samples if s >= threshold]
        return np.mean(tail_samples)
    
    def probability_of_extreme(self, threshold_ms=500):
        '''
        P(latência > threshold)
        '''
        samples = self.sample(n=10000)
        return sum(1 for s in samples if s > threshold_ms) / 10000

USO NO SHADOW EXCHANGE:

class ShadowExchangeGENIUS(ShadowExchange):
    def __init__(self, config):
        super().__init__(config)
        self.latency_model = EVTLatencyModel()
        self.extreme_events_log = []
    
    def get_latency(self, market_condition):
        latency = self.latency_model.sample(market_condition=market_condition)
        
        # Log extreme events para análise
        if latency > 200:  # ms
            self.extreme_events_log.append({
                'latency': latency,
                'condition': market_condition,
                'timestamp': self.current_time
            })
        
        return latency
    
    def generate_tail_report(self):
        '''
        Relatório de eventos extremos de latência
        '''
        return {
            'total_extreme_events': len(self.extreme_events_log),
            'max_latency': max(e['latency'] for e in self.extreme_events_log),
            'p99_latency': np.percentile([e['latency'] for e in self.extreme_events_log], 99),
            'expected_shortfall_95': self.latency_model.expected_shortfall(95),
            'p_extreme_500ms': self.latency_model.probability_of_extreme(500)
        }
```

### 4.2 Tail Event Injection

```
STRESS SCENARIOS COM EVT:

class TailEventInjector:
    def __init__(self, shadow_exchange):
        self.exchange = shadow_exchange
        
    def inject_flash_crash(self, magnitude_pct=3.0, duration_ticks=100):
        '''
        Injeta flash crash com magnitude extrema
        Usa EVT para magnitude do gap
        '''
        # Gap size usando GPD (heavy tailed)
        gpd_shape = 0.5
        gpd_scale = magnitude_pct * 0.5
        gap = gpd_scale * (np.random.pareto(1/gpd_shape) + 1)
        
        # Latência extrema durante crash
        latency = self.exchange.latency_model.sample(market_condition='flash_crash')
        
        return {
            'gap_pct': gap,
            'latency_ms': latency,
            'duration_ticks': duration_ticks,
            'expected_sl_skip_pct': min(gap * 2, 100)  # % de chance de SL ser saltado
        }
    
    def inject_liquidity_crisis(self, duration_minutes=60):
        '''
        Spread extremo usando EVT
        '''
        # Spread multiplier usando GPD
        gpd_shape = 0.4
        gpd_scale = 3.0
        spread_mult = 1 + gpd_scale * (np.random.pareto(1/gpd_shape) + 1)
        
        return {
            'spread_multiplier': spread_mult,
            'duration_minutes': duration_minutes,
            'rejection_rate': min(0.5, 0.1 * spread_mult)
        }
    
    def inject_connection_loss(self):
        '''
        Duração de desconexão usando EVT
        '''
        # Heavy tail para duração
        base_seconds = 30
        tail = np.random.pareto(1.5) * 60  # Heavy tail em segundos
        duration = base_seconds + tail
        
        return {
            'duration_seconds': min(duration, 300),  # Cap em 5 min
            'market_movement_during': np.random.normal(0, 50)  # pips
        }
```

---

## FASE 5: VALIDAÇÃO ESTATÍSTICA + GENIUS

**Princípios Aplicados**: #1 (Kelly), #5 (Edge Decay), #7 (EVT)

### 5.1 Kelly Optimal Calculation

```
PRINCÍPIO #1 - KELLY OPTIMAL:

class KellyOptimizer:
    def __init__(self, trades_df, segments=None):
        self.trades = trades_df
        self.segments = segments or ['GLOBAL']
    
    def calculate_optimal_kelly(self, segment='GLOBAL'):
        '''
        Calcula Kelly ótimo com correções estatísticas
        '''
        trades = self._filter_segment(segment)
        
        wins = trades[trades['profit'] > 0]
        losses = trades[trades['profit'] <= 0]
        
        if len(wins) == 0 or len(losses) == 0:
            return {'kelly': 0, 'error': 'Insufficient data'}
        
        # Parâmetros básicos
        p = len(wins) / len(trades)
        q = 1 - p
        avg_win = wins['profit'].mean()
        avg_loss = abs(losses['profit'].mean())
        b = avg_win / avg_loss
        
        # Kelly básico
        kelly_basic = (p * b - q) / b
        
        # Correção por incerteza (sample size)
        n = len(trades)
        std_err_p = np.sqrt(p * q / n)
        
        # Kelly conservador (worst case do confidence interval)
        p_conservative = p - 1.96 * std_err_p  # 95% CI lower bound
        kelly_conservative = (p_conservative * b - (1 - p_conservative)) / b
        
        # Fractional Kelly recomendado
        kelly_half = kelly_basic * 0.5
        kelly_quarter = kelly_basic * 0.25
        
        return {
            'kelly_full': kelly_basic,
            'kelly_conservative': kelly_conservative,
            'kelly_half': kelly_half,
            'kelly_quarter': kelly_quarter,
            'recommended': kelly_quarter if n < 100 else kelly_half,
            'sample_size': n,
            'win_rate': p,
            'win_loss_ratio': b,
            'edge': p * b - q,
            'geometric_growth_rate': p * np.log(1 + b * kelly_half) + q * np.log(1 - kelly_half)
        }
    
    def kelly_by_regime(self):
        '''
        Kelly por regime de mercado
        '''
        results = {}
        for regime in ['TRENDING', 'REVERTING']:
            results[regime] = self.calculate_optimal_kelly(segment=regime)
        return results
    
    def kelly_by_session(self):
        '''
        Kelly por sessão
        '''
        results = {}
        for session in ['ASIA', 'LONDON', 'OVERLAP', 'NY']:
            results[session] = self.calculate_optimal_kelly(segment=session)
        return results

INTEGRAÇÃO NO GO/NO-GO:

kelly_results = KellyOptimizer(trades).calculate_optimal_kelly()

if kelly_results['edge'] <= 0:
    verdict = 'NO_GO - No positive edge'
elif kelly_results['edge'] < 0.05:
    verdict = 'CAUTIOUS - Edge too small'
else:
    recommended_risk = kelly_results['recommended'] * 100
    verdict = f'GO - Use {recommended_risk:.2f}% risk per trade'
```

### 5.2 EVT Monte Carlo

```
PRINCÍPIO #7 - EVT MONTE CARLO:

class EVTMonteCarlo:
    '''
    Monte Carlo com foco em eventos de tail usando EVT
    '''
    
    def __init__(self, trades_df, initial_capital=100000):
        self.trades = trades_df
        self.capital = initial_capital
        self.losses = trades_df[trades_df['profit'] < 0]['profit'].values
        
        # Fit GPD para losses extremos
        self._fit_gpd()
    
    def _fit_gpd(self):
        '''
        Fit Generalized Pareto Distribution para tails
        '''
        from scipy.stats import genpareto
        
        # Usar threshold = percentile 90
        threshold = np.percentile(np.abs(self.losses), 90)
        tail_losses = [l for l in np.abs(self.losses) if l > threshold]
        
        if len(tail_losses) > 10:
            # Fit GPD
            excesses = np.array(tail_losses) - threshold
            self.gpd_params = genpareto.fit(excesses)
            self.gpd_threshold = threshold
            self.gpd_fitted = True
        else:
            self.gpd_fitted = False
    
    def sample_extreme_loss(self):
        '''
        Sample um loss extremo da GPD fitted
        '''
        if not self.gpd_fitted:
            return np.random.choice(self.losses)
        
        from scipy.stats import genpareto
        excess = genpareto.rvs(*self.gpd_params)
        return -(self.gpd_threshold + excess)
    
    def run_evt_monte_carlo(self, n_simulations=5000, inject_extremes=True):
        '''
        Monte Carlo com injeção de eventos extremos
        '''
        results = []
        
        for _ in range(n_simulations):
            equity = self.capital
            peak = self.capital
            max_dd = 0
            
            # Shuffle trades
            shuffled = np.random.permutation(self.trades['profit'].values)
            
            # Injetar eventos extremos (5% das simulações)
            if inject_extremes and np.random.random() < 0.05:
                # Substituir alguns trades por losses extremos
                n_extremes = np.random.randint(1, 4)
                extreme_indices = np.random.choice(len(shuffled), n_extremes, replace=False)
                for idx in extreme_indices:
                    shuffled[idx] = self.sample_extreme_loss()
            
            for pnl in shuffled:
                equity += pnl
                peak = max(peak, equity)
                dd = (peak - equity) / peak
                max_dd = max(max_dd, dd)
            
            results.append({
                'max_dd': max_dd * 100,
                'final_equity': equity
            })
        
        max_dds = [r['max_dd'] for r in results]
        
        return {
            'dd_50th': np.percentile(max_dds, 50),
            'dd_95th': np.percentile(max_dds, 95),
            'dd_99th': np.percentile(max_dds, 99),
            'var_95': np.percentile(max_dds, 95),
            'cvar_95': np.mean([d for d in max_dds if d >= np.percentile(max_dds, 95)]),
            'p_ruin_5pct': sum(1 for d in max_dds if d >= 5) / len(max_dds) * 100,
            'p_ruin_10pct': sum(1 for d in max_dds if d >= 10) / len(max_dds) * 100,
            'evt_tail_index': self.gpd_params[0] if self.gpd_fitted else None
        }
```

### 5.3 Edge Stability Analysis

```
PRINCÍPIO #5 - EDGE STABILITY:

class EdgeStabilityAnalyzer:
    def __init__(self, trades_df, window_sizes=[20, 50, 100]):
        self.trades = trades_df
        self.window_sizes = window_sizes
    
    def rolling_sharpe(self, window=50):
        '''
        Sharpe rolling para detectar decay
        '''
        profits = self.trades['profit'].values
        sharpes = []
        
        for i in range(window, len(profits)):
            window_profits = profits[i-window:i]
            if np.std(window_profits) > 0:
                sharpe = np.mean(window_profits) / np.std(window_profits) * np.sqrt(252)
                sharpes.append(sharpe)
            else:
                sharpes.append(0)
        
        return sharpes
    
    def detect_regime_shifts(self):
        '''
        Detecta mudanças estruturais no edge
        '''
        sharpes = self.rolling_sharpe()
        
        # CUSUM test para detectar change points
        mean_sharpe = np.mean(sharpes)
        cusum = np.cumsum(sharpes - mean_sharpe)
        
        # Detectar pontos onde CUSUM cruza threshold
        threshold = 3 * np.std(sharpes) * np.sqrt(len(sharpes))
        
        change_points = []
        for i, c in enumerate(cusum):
            if abs(c) > threshold:
                change_points.append(i)
                # Reset CUSUM após detecção
                cusum[i:] -= c
        
        return {
            'change_points': change_points,
            'n_regime_shifts': len(change_points),
            'edge_stable': len(change_points) < 3
        }
    
    def calculate_edge_halflife(self):
        '''
        Estima meia-vida do edge
        '''
        sharpes = self.rolling_sharpe()
        
        if len(sharpes) < 50:
            return {'halflife': None, 'error': 'Insufficient data'}
        
        # Autocorrelação
        autocorr = np.correlate(sharpes - np.mean(sharpes), 
                               sharpes - np.mean(sharpes), 
                               mode='full')
        autocorr = autocorr[len(autocorr)//2:]
        autocorr /= autocorr[0]
        
        # Encontrar onde autocorr cai para 0.5
        halflife = None
        for i, ac in enumerate(autocorr):
            if ac < 0.5:
                halflife = i
                break
        
        return {
            'halflife_trades': halflife,
            'interpretation': self._interpret_halflife(halflife)
        }
    
    def _interpret_halflife(self, halflife):
        if halflife is None:
            return 'Edge muito estável ou dados insuficientes'
        elif halflife < 20:
            return 'ALERTA: Edge decai rápido. Retreinar frequentemente.'
        elif halflife < 50:
            return 'Edge moderadamente estável. Monitorar.'
        else:
            return 'Edge estável. Pode operar com confiança.'
```

---

## FASE 6: STRESS TESTING + GENIUS

**Princípios Aplicados**: #3 (Phase Transitions), #7 (Tail Risk)

### 6.1 Phase Transition Stress Test

```
PRINCÍPIO #3 - PHASE TRANSITIONS STRESS:

class PhaseTransitionStressTest(StressTest):
    '''
    Testa comportamento durante transições de regime
    '''
    
    def __init__(self):
        super().__init__('PHASE_TRANSITION', 'Multiple rapid regime changes')
        
    def inject(self, backtest_engine):
        '''
        Injeta sequência de transições rápidas
        '''
        # Padrão: Trending → Random → Reverting → Random → Trending
        # Em 1 dia (muito rápido)
        
        transitions = [
            {'hour': 0, 'regime': 'TRENDING', 'hurst': 0.65},
            {'hour': 4, 'regime': 'RANDOM', 'hurst': 0.50},
            {'hour': 8, 'regime': 'REVERTING', 'hurst': 0.35},
            {'hour': 12, 'regime': 'RANDOM', 'hurst': 0.50},
            {'hour': 16, 'regime': 'TRENDING', 'hurst': 0.60},
            {'hour': 20, 'regime': 'RANDOM', 'hurst': 0.48},
        ]
        
        for t in transitions:
            backtest_engine.schedule_regime_change(t)
    
    def evaluate(self, results) -> StressResult:
        # Durante transições, sistema deve:
        # 1. Detectar transição (critical slowing down)
        # 2. Reduzir exposição automaticamente
        # 3. Não ter DD > 3% em um único dia
        
        transition_dd = results.get_daily_dd(self.stress_day)
        detected_transitions = results.get_detected_transitions()
        exposure_reductions = results.get_exposure_reductions()
        
        passed = (
            transition_dd < 3.0 and
            detected_transitions >= 4 and  # Pelo menos 4 de 6
            exposure_reductions >= 3       # Reduziu em pelo menos 3
        )
        
        return StressResult(
            test_name=self.name,
            passed=passed,
            max_dd=transition_dd,
            details={
                'transitions_detected': detected_transitions,
                'exposure_reductions': exposure_reductions,
                'whipsaws_avoided': results.get_whipsaws_avoided()
            }
        )
```

### 6.2 Tail Event Stress Tests

```
PRINCÍPIO #7 - TAIL EVENT STRESS TESTS:

class TailEventStressTest(StressTest):
    '''
    Testa eventos extremos de tail usando EVT
    '''
    
    def __init__(self, event_type='FLASH_CRASH'):
        super().__init__(f'TAIL_{event_type}', f'Extreme {event_type} event')
        self.event_type = event_type
        
    def inject(self, backtest_engine):
        if self.event_type == 'FLASH_CRASH':
            # Gap de 5% em 30 segundos
            backtest_engine.inject_gap(
                magnitude_pct=5.0,
                duration_seconds=30,
                direction='AGAINST_POSITION'  # Sempre contra
            )
            
        elif self.event_type == 'LIQUIDITY_CRISIS':
            # Spread 20x por 2 horas
            backtest_engine.inject_spread_spike(
                multiplier=20,
                duration_hours=2
            )
            
        elif self.event_type == 'CASCADING_FAILURE':
            # Sequência: gap + spread + rejection + latência
            backtest_engine.inject_gap(magnitude_pct=2.0)
            backtest_engine.inject_spread_spike(multiplier=10)
            backtest_engine.inject_rejection_rate(rate=0.80)
            backtest_engine.inject_latency(multiplier=10)
    
    def evaluate(self, results) -> StressResult:
        # Para tail events, critério é SOBREVIVÊNCIA, não lucro
        
        survived = results.final_equity > 0
        dd_during_event = results.get_max_dd_during_event()
        recovery_time = results.get_recovery_time()
        
        if self.event_type == 'FLASH_CRASH':
            # Aceitável: DD < 8% (mesmo com 5% gap)
            # Porque SL pode ser saltado
            passed = dd_during_event < 8.0 and survived
            
        elif self.event_type == 'LIQUIDITY_CRISIS':
            # Sistema deve PARAR de operar
            trades_during = results.get_trades_during_event()
            passed = trades_during == 0  # Não operou = correto
            
        elif self.event_type == 'CASCADING_FAILURE':
            # DD < 10% mesmo com tudo dando errado
            passed = dd_during_event < 10.0 and survived
        
        return StressResult(
            test_name=self.name,
            passed=passed,
            max_dd=dd_during_event,
            details={
                'survived': survived,
                'recovery_time_hours': recovery_time,
                'event_type': self.event_type
            }
        )
```

---

## FASE 7-8: LIVE TRADING + GENIUS

**Princípios Aplicados**: #1 (Kelly), #2 (Convexidade), #5 (Edge Decay)

### 7.1 Position Sizing com Kelly Adaptativo

```
PRINCÍPIO #1 - KELLY ADAPTATIVO EM LIVE:

class AdaptiveKellySizer:
    '''
    Position sizing adaptativo baseado em Kelly
    Ajusta em tempo real baseado em performance recente
    '''
    
    def __init__(self, base_kelly=0.01, min_kelly=0.0025, max_kelly=0.02):
        self.base_kelly = base_kelly
        self.min_kelly = min_kelly
        self.max_kelly = max_kelly
        self.recent_trades = []
        self.lookback = 20
    
    def add_trade(self, profit, risk):
        self.recent_trades.append({'profit': profit, 'risk': risk})
        if len(self.recent_trades) > self.lookback:
            self.recent_trades.pop(0)
    
    def get_current_kelly(self):
        if len(self.recent_trades) < 10:
            return self.base_kelly  # Use base until enough data
        
        wins = [t for t in self.recent_trades if t['profit'] > 0]
        losses = [t for t in self.recent_trades if t['profit'] <= 0]
        
        if not wins or not losses:
            return self.base_kelly
        
        p = len(wins) / len(self.recent_trades)
        avg_win = np.mean([t['profit'] for t in wins])
        avg_loss = abs(np.mean([t['profit'] for t in losses]))
        b = avg_win / avg_loss
        
        kelly = (p * b - (1 - p)) / b
        kelly_half = kelly * 0.5
        
        # Clamp to safe range
        return np.clip(kelly_half, self.min_kelly, self.max_kelly)
    
    def get_confidence_adjusted_kelly(self, regime, session, mtf_alignment):
        '''
        Kelly ajustado por confiança do setup
        '''
        base = self.get_current_kelly()
        
        # Regime multiplier
        if regime == 'TRENDING':
            regime_mult = 1.2
        elif regime == 'REVERTING':
            regime_mult = 0.8
        else:
            regime_mult = 0.0  # Não operar
        
        # Session multiplier
        if session == 'OVERLAP':
            session_mult = 1.1
        elif session == 'ASIA':
            session_mult = 0.7
        else:
            session_mult = 1.0
        
        # MTF multiplier
        if mtf_alignment >= 75:
            mtf_mult = 1.2
        elif mtf_alignment >= 50:
            mtf_mult = 1.0
        else:
            mtf_mult = 0.5
        
        adjusted = base * regime_mult * session_mult * mtf_mult
        return np.clip(adjusted, self.min_kelly, self.max_kelly)
```

### 7.2 Convexity em Trade Management

```
PRINCÍPIO #2 - CONVEXIDADE EM LIVE:

class ConvexTradeManager:
    '''
    Gerencia trades para maximizar convexidade (assimetria positiva)
    '''
    
    def __init__(self, min_rr=1.5, target_rr=2.0, max_rr=5.0):
        self.min_rr = min_rr
        self.target_rr = target_rr
        self.max_rr = max_rr
    
    def validate_entry(self, entry, sl, tp):
        '''
        Só aceita trades com R:R adequado
        '''
        risk = abs(entry - sl)
        reward = abs(tp - entry)
        rr = reward / risk if risk > 0 else 0
        
        if rr < self.min_rr:
            return {
                'valid': False,
                'reason': f'R:R {rr:.2f} < minimum {self.min_rr}'
            }
        
        return {'valid': True, 'rr': rr}
    
    def manage_winner(self, position, current_price):
        '''
        Gerencia winners para maximizar ganhos (let winners run)
        '''
        unrealized_rr = position.get_current_rr(current_price)
        
        if unrealized_rr >= 1.0:
            # Move SL para breakeven
            new_sl = position.entry_price
            
        if unrealized_rr >= 2.0:
            # Lock 50% do profit
            profit = abs(current_price - position.entry_price)
            new_sl = position.entry_price + (profit * 0.5 * position.direction)
            
        if unrealized_rr >= 3.0:
            # Lock 75% do profit
            new_sl = position.entry_price + (profit * 0.75 * position.direction)
        
        return {'action': 'TRAIL_SL', 'new_sl': new_sl}
    
    def should_add_to_winner(self, position, current_price):
        '''
        Adicionar a winners (pyramiding) - NUNCA a losers
        '''
        if position.is_losing():
            return False
        
        unrealized_rr = position.get_current_rr(current_price)
        
        # Só adicionar após 1R de profit E se trending forte
        if unrealized_rr >= 1.0 and position.regime == 'TRENDING':
            # Adicionar 50% da posição original
            return {
                'add': True,
                'size_multiplier': 0.5,
                'new_sl': position.entry_price  # Proteger capital original
            }
        
        return {'add': False}
```

### 7.3 Edge Decay Monitoring em Live

```
PRINCÍPIO #5 - EDGE MONITORING EM LIVE:

class LiveEdgeMonitor:
    '''
    Monitora edge em tempo real e alerta quando decai
    '''
    
    def __init__(self, decay_threshold=0.3, min_trades=20):
        self.decay_threshold = decay_threshold
        self.min_trades = min_trades
        self.trades_history = []
        self.baseline_metrics = None
    
    def set_baseline(self, sharpe, pf, win_rate):
        '''
        Define baseline de backtest para comparação
        '''
        self.baseline_metrics = {
            'sharpe': sharpe,
            'pf': pf,
            'win_rate': win_rate
        }
    
    def add_live_trade(self, trade):
        self.trades_history.append(trade)
    
    def check_edge_health(self):
        '''
        Compara métricas live vs baseline
        '''
        if len(self.trades_history) < self.min_trades:
            return {'status': 'INSUFFICIENT_DATA', 'trades': len(self.trades_history)}
        
        recent = self.trades_history[-self.min_trades:]
        
        # Calcular métricas live
        wins = [t for t in recent if t['profit'] > 0]
        losses = [t for t in recent if t['profit'] <= 0]
        
        live_wr = len(wins) / len(recent)
        live_pf = (sum(t['profit'] for t in wins) / 
                   abs(sum(t['profit'] for t in losses))) if losses else float('inf')
        
        profits = [t['profit'] for t in recent]
        live_sharpe = (np.mean(profits) / np.std(profits) * np.sqrt(252) 
                       if np.std(profits) > 0 else 0)
        
        # Comparar com baseline
        sharpe_decay = ((self.baseline_metrics['sharpe'] - live_sharpe) / 
                        self.baseline_metrics['sharpe'])
        pf_decay = ((self.baseline_metrics['pf'] - live_pf) / 
                    self.baseline_metrics['pf'])
        wr_decay = ((self.baseline_metrics['win_rate'] - live_wr) / 
                    self.baseline_metrics['win_rate'])
        
        # Determinar status
        max_decay = max(sharpe_decay, pf_decay, wr_decay)
        
        if max_decay > self.decay_threshold:
            status = 'EDGE_DECAY_ALERT'
            action = 'PAUSE_TRADING'
        elif max_decay > self.decay_threshold * 0.5:
            status = 'EDGE_DEGRADING'
            action = 'REDUCE_SIZE'
        else:
            status = 'EDGE_HEALTHY'
            action = 'CONTINUE'
        
        return {
            'status': status,
            'action': action,
            'sharpe_decay_pct': sharpe_decay * 100,
            'pf_decay_pct': pf_decay * 100,
            'wr_decay_pct': wr_decay * 100,
            'live_sharpe': live_sharpe,
            'live_pf': live_pf,
            'live_wr': live_wr
        }
```

---

## GO/NO-GO GENIUS SCORING

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    GENIUS CONFIDENCE SCORE (0-100)                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  KELLY & EDGE (25 pontos):                                                 │
│  ├── Kelly positivo e > 0.5%:               10 pts                         │
│  ├── Edge estável (halflife > 50 trades):   10 pts                         │
│  └── Kelly consistente entre segmentos:      5 pts                         │
│                                                                             │
│  CONVEXIDADE (20 pontos):                                                  │
│  ├── R:R médio >= 1.5:                      10 pts                         │
│  ├── Skew positivo:                          5 pts                         │
│  └── Tail ratio > 1.0:                       5 pts                         │
│                                                                             │
│  REGIME HANDLING (15 pontos):                                              │
│  ├── Zero trades em RANDOM regime:           5 pts                         │
│  ├── Transition detection >= 80%:            5 pts                         │
│  └── Exposure reduction durante transição:   5 pts                         │
│                                                                             │
│  MTF FRACTAL (10 pontos):                                                  │
│  ├── MTF alignment >= 75% nos winners:       5 pts                         │
│  └── Fractal confidence correlation:         5 pts                         │
│                                                                             │
│  ENSEMBLE DIVERSITY (10 pontos):                                           │
│  ├── Error correlation < 0.5:                5 pts                         │
│  └── Multiple edge sources:                  5 pts                         │
│                                                                             │
│  TAIL RISK (20 pontos):                                                    │
│  ├── EVT MC 95th DD < 8%:                   10 pts                         │
│  ├── CVaR 95 < 10%:                          5 pts                         │
│  └── All stress tests PASS:                  5 pts                         │
│                                                                             │
│  TOTAL:                                    100 pts                         │
│                                                                             │
│  DECISÃO:                                                                  │
│  ├── >= 85: STRONG_GO (full Kelly half)                                    │
│  ├── 75-84: GO (Kelly quarter)                                             │
│  ├── 65-74: CAUTIOUS (Kelly quarter, reduced)                              │
│  └── < 65:  NO_GO (não operar)                                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## CHECKLIST GENIUS

### Por Princípio

| # | Princípio | Implementado em | Validado em |
|---|-----------|-----------------|-------------|
| 1 | Kelly Criterion | RiskManager, Backtest | Fase 5 |
| 2 | Convexidade | TradeManager, Backtest | Fase 2, 5 |
| 3 | Phase Transitions | RegimeDetector, Stress | Fase 2, 6 |
| 4 | Fractals | MTFManager, Confluence | Fase 2 |
| 5 | Information Theory | EdgeMonitor, ML | Fase 3, 7 |
| 6 | Ensemble Diversity | ML Training | Fase 3 |
| 7 | Tail Risk | EVT MC, Shadow, Stress | Fase 4, 5, 6 |

---

## RESUMO EXECUTIVO

Este plano v3.0 GENIUS integra 7 princípios matemáticos de elite:

1. **Kelly** - Sizing ótimo que maximiza crescimento geométrico
2. **Convexidade** - Payoff assimétrico (pequenas perdas, grandes ganhos)
3. **Phase Transitions** - Física de mudanças de regime
4. **Fractals** - Padrões multi-escala
5. **Information Theory** - Monitoramento de decay de edge
6. **Ensemble Diversity** - Combinação de estratégias descorrelacionadas
7. **Tail Risk** - EVT para eventos extremos

**Diferencial vs. traders comuns:**
- Traders comuns usam risk fixo → Nós usamos Kelly adaptativo
- Traders comuns focam em win rate → Nós focamos em convexidade
- Traders comuns ignoram transições → Nós detectamos e reagimos
- Traders comuns usam 1 timeframe → Nós usamos confluência fractal
- Traders comuns não monitoram decay → Nós medimos edge halflife
- Traders comuns usam 1 estratégia → Nós usamos ensemble descorrelacionado
- Traders comuns ignoram tails → Nós modelamos com EVT

**Este é o approach de um QUANT FUND, não de um trader retail.**

---

*"The goal is not to be right, but to make money when you're right and lose little when you're wrong."*

**IMPLEMENT GENIUS. VALIDATE RIGOROUSLY. TRADE PROFITABLY.**
