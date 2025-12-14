# PROMPT MASTER: MIGRAÇÃO COMPLETA MQL5 + PYTHON → NAUTILUSTRADER

## CONTEXTO GERAL

Você é um especialista em arquitetura de trading quantitativo e NautilusTrader. Sua missão é migrar completamente uma codebase complexa de:
- **MQL5 Expert Advisor** (robô principal com lógica ICT/SMC/Order Blocks)
- **19 bibliotecas Python** (análise, ML, risco, integração)
- **Backtesting atual** (VectorBT + dados de tick)

Para uma arquitetura unificada em **NautilusTrader com suporte completo a Machine Learning**.

---

## PARTE 1: ANÁLISE DA CODEBASE EXISTENTE

### Informações do Projeto Atual

**Linguagens atuais:**
- MQL5 (EA principal + bibliotecas)
- Python (19 deps: sklearn, pandas, numpy, ta-lib, requests, etc)

**Funcionalidades principais:**
- Order Block Detection (mitigation 50-70%)
- Volume Flow Analysis (OBV, institutional patterns)
- ICT/SMC confirmações (ADX > 25, RSI momentum)
- Risk Management (0.5-1% risk, <3% drawdown diário)
- Trailing Stops adaptativos
- Take Profit dinâmico
- Position Sizing by volatility (ATR-based)
- FTMO compliance (max 2-3 trades/dia)
- XAUUSD specialization (session filters: London/NY)

**Dependências Python atuais (aproximadas):**
```
sklearn, pandas, numpy, numba, ta-lib, requests,
talib, matplotlib, plotly, jupyter, pytest, pytest-cov,
vectorbt, riskfolio-lib, pyportfolioopt, keras/tensorflow,
joblib, sqlalchemy, [+4 customizadas]
```

**Dados:**
- Tick data histórico XAUUSD (5+ anos)
- H1 timeframe principal
- Multi-venue opportunity (Apex, MT5, Tradovate)

---

## PARTE 2: ARQUITETURA ALVO

### Estrutura NautilusTrader

```
projeto_nautilus/
├── data/
│   ├── xauusd_h1_5years.parquet
│   └── ml_models/
│       ├── ob_detector_v2.pkl
│       ├── volume_classifier.pkl
│       └── ensemble_model.h5
│
├── src/
│   ├── strategies/
│   │   ├── base_strategy.py
│   │   ├── order_block_strategy.py
│   │   ├── ml_ensemble_strategy.py
│   │   ├── risk_manager.py
│   │   └── position_sizer.py
│   │
│   ├── indicators/
│   │   ├── custom_ob_detector.py
│   │   ├── volume_flow.py
│   │   ├── ict_confirmations.py
│   │   └── session_filters.py
│   │
│   ├── ml/
│   │   ├── feature_engineering.py
│   │   ├── model_trainer.py
│   │   ├── ensemble_predictor.py
│   │   └── retraining_pipeline.py
│   │
│   ├── risk/
│   │   ├── portfolio_risk.py
│   │   ├── drawdown_tracker.py
│   │   ├── var_cvar.py
│   │   └── kelly_criterion.py
│   │
│   ├── executors/
│   │   ├── mt5_webhook_receiver.py
│   │   ├── apex_api_client.py
│   │   └── signal_distributor.py
│   │
│   └── utils/
│       ├── data_loader.py
│       ├── backtester.py
│       └── logging_config.py
│
├── notebooks/
│   ├── 01_exploratory_analysis.ipynb
│   ├── 02_ml_model_training.ipynb
│   ├── 03_backtest_results.ipynb
│   └── 04_parameter_optimization.ipynb
│
├── configs/
│   ├── strategy_config.yaml
│   ├── backtest_config.yaml
│   ├── ml_config.yaml
│   └── risk_config.yaml
│
└── tests/
    ├── test_ob_detection.py
    ├── test_ml_pipeline.py
    ├── test_risk_management.py
    └── test_integration.py
```

---

## PARTE 3: REQUISITOS ESPECÍFICOS DE MIGRAÇÃO

### 3.1 - DETECÇÃO DE ORDER BLOCKS

**Funcionalidade atual (MQL5):**
```
- Identifica blocos de liquidez (RB levels)
- Calcula mitigação 50-70%
- Volume flow confirmation
- Entry logic: quando preço retorna ao bloco
```

**Migrar para NautilusTrader:**
- Função pura Python (sem dependências MQL5)
- Parametrizável (RB_LEVELS, VOLUME_THRESHOLD)
- Retorna: {level, type (buy/sell), strength, volume_ratio}
- Integrada em `on_bar()` callback
- Output: triggers automáticos para entradas

### 3.2 - MACHINE LEARNING PIPELINE

**Modelos a treinar:**

1. **Order Block Detector** (RandomForest)
   - Input: [close, high, low, volume, OBV, ATR, volatility]
   - Output: Probability de ser true OB (0-1)

2. **Volume Flow Classifier** (XGBoost)
   - Input: [volume, OBV, price_range, institutional_pattern]
   - Output: Confidence de volume institucional

3. **Ensemble Predictor** (Neural Network)
   - Input: [OB probability, Volume confidence, ADX, RSI, session]
   - Output: Entry probability + confidence interval

4. **Risk Predictor** (Regression)
   - Input: [volatility, session, slippage_historical]
   - Output: Expected drawdown para próximo trade

**Requirementos:**
- Treinar offline em Jupyter/Colab
- Salvar modelos em `.pkl` (sklearn) ou `.h5` (Keras)
- Carregar em estratégia Nautilus
- Auto-retraining a cada semana
- Versionamento de modelos

### 3.3 - RISK MANAGEMENT AVANÇADO

**Implementar:**
- Value at Risk (VaR 95%)
- Conditional VaR (CVaR/CDaR)
- Kelly Criterion for position sizing
- Drawdown tracking (max 2.5%, daily <3%)
- Trailing stops adaptativos por volatilidade
- OCO orders (TP cancels SL e vice-versa)
- Iceberg order support (fracciona)
- Dynamic take profit (sobe a cada 5% ganho)

### 3.4 - FILTROS DE SESSÃO

**Implementar:**
- London session (08:00-17:00 GMT)
- NY session (13:00-22:00 GMT)
- Spread dinâmico por sessão (London tight, Tóquio wide)
- Volume patterns por sessão
- Volatilidade histórica por hora

### 3.5 - INTEGRAÇÃO MULTI-BROKER

**Executores:**

1. **MT5 via Webhooks**
   - JSON signal format
   - Simple webhook receiver em MQL5
   - ~100 linhas de código

2. **Apex Trading**
   - API client Python
   - Tradovate integration
   - Futures trading parameters

3. **Tradovate Direct**
   - REST API integration
   - Order management
   - Position monitoring

---

## PARTE 4: INSTRUÇÕES DETALHADAS POR ARQUIVO

### 4.1 - order_block_strategy.py

Crie arquivo `src/strategies/order_block_strategy.py` com:

**Classe Base:**
```python
from nautilus_trader.trading.strategy import Strategy
from nautilus_trader.core.data import Bar
from nautilus_trader.model.objects import Price, Quantity
import numpy as np

class OrderBlockStrategy(Strategy):
    """
    Estratégia de Order Blocks com ICT/SMC
    - Detecta blocos de liquidez (50-70% mitigation)
    - Confirma com ADX > 25 e RSI momentum
    - Volume flow analysis
    - Trailing stops adaptativos
    - FTMO compliant
    """
    
    def __init__(self, config):
        super().__init__(config)
        self.ob_detector = None
        self.volume_analyzer = None
        self.ml_predictor = None
        self.risk_manager = None
        self.position_sizer = None
        self.session_filter = None
```

**Métodos required:**
- `on_start()` - Carrega modelos ML
- `on_bar()` - Lógica principal por candle
- `detect_order_blocks()` - Detecta OBs
- `confirm_signal()` - Confirma com ADX/RSI/ML
- `calculate_position()` - Sizing por risco
- `submit_order()` - Envia ordem com SL/TP

### 4.2 - ml_ensemble_strategy.py

Crie arquivo `src/strategies/ml_ensemble_strategy.py` com:

**Classe:**
```python
class MLEnsembleStrategy(Strategy):
    """
    Estratégia com Ensemble ML
    - RandomForest + XGBoost + Neural Network
    - Features: OB detection, Volume flow, Price action, Session
    - Output: Entry probability + confidence
    - Retraining automático weekly
    """
```

**Métodos:**
- `load_models()` - Carrega sklearn/Keras models
- `extract_features()` - Feature engineering
- `predict_signal()` - Ensemble prediction
- `get_confidence()` - Calcula confidence interval
- `retrain_models()` - Automático ou manual

### 4.3 - risk_manager.py

Crie arquivo `src/risk/risk_manager.py` com:

```python
class PortfolioRiskManager:
    """
    Gerenciam risco do portfólio
    - VAR/CVaR
    - Kelly Criterion
    - Drawdown tracking
    - Dynamic position sizing
    - FTMO rules enforcement
    """
    
    def __init__(self, account_size, daily_limit=0.03, max_dd=0.25):
        self.account_size = account_size  # 100k FTMO
        self.daily_loss_limit = account_size * daily_limit  # <3%
        self.max_drawdown = max_dd  # <25%
        self.daily_loss = 0
```

**Métodos:**
- `calculate_kelly_position()` - Kelly criterion
- `calculate_var_cvar()` - Value at Risk
- `track_drawdown()` - Max DD monitor
- `enforce_ftmo_rules()` - Daily/Monthly limits
- `calculate_atr_position()` - ATR-based sizing

### 4.4 - position_sizer.py

Crie arquivo `src/strategies/position_sizer.py` com:

```python
class AdaptivePositionSizer:
    """
    Dimensiona posições baseado em:
    - Volatilidade (ATR)
    - Risco por trade (0.5-1%)
    - Drawdown atual
    - Session (London tight, Tóquio wide)
    """
    
    def calculate_size(self, atr, stop_loss_pips, current_dd, session):
        """Retorna tamanho ótimo em lotes"""
```

### 4.5 - feature_engineering.py

Crie arquivo `src/ml/feature_engineering.py` com:

```python
class FeatureEngineer:
    """
    Extrai features para ML models
    Features utilizadas:
    - OHLCV básico
    - OBV, ATR, ADX, RSI (TA-Lib)
    - Order Block strength
    - Volume ratios
    - Session info
    - Time features
    """
    
    def extract_features(self, bar_data, lookback=50):
        """
        Retorna numpy array de features para model prediction
        Shape: (1, n_features) para prediction
        ou (n_bars, n_features) para training
        """
```

### 4.6 - model_trainer.py

Crie arquivo `src/ml/model_trainer.py` com:

```python
class ModelTrainer:
    """
    Treina e valida modelos ML
    - RandomForest (OB detector)
    - XGBoost (Volume classifier)
    - Neural Network (Ensemble)
    - Walk-forward validation
    - Hyperparameter optimization
    """
    
    def train_ensemble(self, X_train, y_train, X_test, y_test):
        """Treina ensemble de modelos"""
        
    def backtest_with_predictions(self, predictions, actual_returns):
        """Valida performance do modelo"""
        
    def save_models(self, version='v2.3'):
        """Salva modelos treinados"""
```

### 4.7 - backtester.py

Crie arquivo `src/utils/backtester.py` com:

```python
class NautilusBacktester:
    """
    Runner de backtests em NautilusTrader
    - Setup engine de backtest
    - Carrega dados XAUUSD H1
    - Roda estratégia
    - Gera reports (Sharpe, Drawdown, Win Rate)
    """
    
    def run_backtest(self, strategy_config, start_date, end_date):
        """Executa backtest completo"""
        
    def optimize_parameters(self, param_grid, n_jobs=4):
        """Otimização paramétrica paralela"""
```

### 4.8 - mt5_webhook_receiver.py

Crie arquivo `src/executors/mt5_webhook_receiver.py` com:

```python
from flask import Flask, request
import json
import requests

class MT5WebhookReceiver:
    """
    Server Flask que recebe signals de Nautilus
    e envia para MT5 via webhook
    """
    
    def __init__(self, mt5_webhook_url):
        self.app = Flask(__name__)
        self.mt5_webhook_url = mt5_webhook_url
        
    @self.app.route('/signal', methods=['POST'])
    def receive_signal(self):
        """
        Recebe POST com sinal de Nautilus
        {
            'symbol': 'XAUUSD',
            'action': 'BUY',
            'qty': 1.5,
            'stop_loss': 1.0900,
            'take_profit': 1.1100,
            'ml_confidence': 0.87
        }
        """
```

### 4.9 - apex_api_client.py

Crie arquivo `src/executors/apex_api_client.py` com:

```python
class ApexAPIClient:
    """
    Client para integração com Apex Trader Funding
    - Autenticação
    - Place orders
    - Manage positions
    - Track account
    """
    
    def __init__(self, api_key, api_secret):
        self.api_key = api_key
        self.api_secret = api_secret
        
    def place_order(self, symbol, side, qty, order_type, **kwargs):
        """Coloca ordem em Apex"""
```

---

## PARTE 5: DADOS E CONFIGURAÇÃO

### 5.1 - strategy_config.yaml

```yaml
strategy:
  name: "OrderBlockEnsemble"
  version: "2.3"
  
symbol:
  name: "XAUUSD"
  timeframe: "H1"
  
order_block:
  rb_levels: 20
  volume_threshold: 0.6
  mitigation_target: 0.65
  
indicators:
  adx_period: 14
  adx_threshold: 25
  rsi_period: 14
  atr_period: 14
  
ml_model:
  ensemble_type: "voting"
  models:
    - type: "RandomForest"
      n_estimators: 100
      version: "v2.3"
    - type: "XGBoost"
      n_estimators: 200
      version: "v2.2"
    - type: "NeuralNetwork"
      layers: [64, 32, 16]
      version: "v2.1"
  min_confidence: 0.75
  
risk:
  account_size: 100000
  risk_per_trade: 0.01
  daily_loss_limit: 0.03
  max_drawdown: 0.25
  trailing_stop: true
  trailing_offset: 50
  
position_sizing:
  method: "kelly"
  kelly_fraction: 0.25
  max_position_size: 2.0
  atr_multiplier: 1.5
  
session_filters:
  - name: "london"
    start: "08:00"
    end: "17:00"
    timezone: "GMT"
  - name: "ny"
    start: "13:00"
    end: "22:00"
    timezone: "EST"
```

### 5.2 - backtest_config.yaml

```yaml
backtest:
  start_date: "2020-01-01"
  end_date: "2024-12-31"
  venue: "Forex"
  instrument: "XAUUSD"
  
data:
  format: "parquet"
  path: "data/xauusd_h1_5years.parquet"
  
simulation:
  commissions: 0.0005  # 5 pips
  spread_bid_ask: 0.0005
  slippage: 0.00005
  latency_ms: 100
  
optimization:
  parameters_to_tune:
    - "adx_threshold": [20, 25, 30, 35]
    - "volume_threshold": [0.5, 0.6, 0.7, 0.8]
    - "trailing_offset": [20, 30, 40, 50]
  parallel_jobs: 4
```

---

## PARTE 6: INSTRUÇÕES DE IMPLEMENTAÇÃO

### Fase 1: Core Strategy (Dia 1)

1. Crie classe `OrderBlockStrategy` em NautilusTrader
2. Implemente `on_bar()` callback
3. Implemente detecção de Order Blocks
4. Teste backtest básico (sem ML)

**Deliverable:** `src/strategies/order_block_strategy.py` funcional

### Fase 2: Indicadores e Confirmaçõ es (Dia 2)

1. Crie `src/indicators/ict_confirmations.py`
2. Implemente ADX, RSI, Volume Flow
3. Integrate session filters
4. Teste confirmações

**Deliverable:** Indicadores funcionando em backtest

### Fase 3: ML Pipeline (Dia 3-4)

1. Crie `src/ml/feature_engineering.py`
2. Implemente model trainer
3. Treina 3 modelos (RF, XGB, NN)
4. Salva modelos `.pkl` e `.h5`
5. Integra em estratégia

**Deliverable:** ML predictions em backtest

### Fase 4: Risk Management (Dia 5)

1. Crie `src/risk/risk_manager.py`
2. Implementar Kelly Criterion
3. Implementar VaR/CVaR
4. Drawdown tracking
5. FTMO compliance checks

**Deliverable:** Risk management completo

### Fase 5: Executores (Dia 6)

1. Crie `src/executors/mt5_webhook_receiver.py`
2. Crie `src/executors/apex_api_client.py`
3. Teste signal distribution
4. Teste ordem execution

**Deliverable:** Multi-broker support pronto

### Fase 6: Backtesting e Otimização (Dia 7)

1. Implementar `src/utils/backtester.py`
2. Rodar otimização de parâmetros
3. Walk-forward validation
4. Gerar reports

**Deliverable:** Backtest completo, top 5 configs

---

## PARTE 7: OUTPUTS ESPERADOS

### Estrutura de Diretórios Final

```
projeto_nautilus/
├── [Todos os arquivos acima]
├── README.md (documentação)
├── requirements.txt (dependências)
├── ARCHITECTURE.md (diagrama arquitetura)
└── MIGRATION_CHECKLIST.md
```

### Arquivos Gerados

1. **10 arquivos Python** (estratégias, indicadores, ML, risco)
2. **4 arquivos YAML** (configurações)
3. **2 executores** (MT5 webhook, Apex API)
4. **ML models** (RF, XGB, NN - .pkl/.h5)
5. **Notebook Jupyter** (análise + treinamento)
6. **Testes unitários** (pytest)
7. **Documentação** (README, arquitetura)

### Validações Finitas

```
✅ Backtest roda sem erros
✅ Sharpe Ratio > 1.5
✅ Win Rate > 65%
✅ Max Drawdown < 25%
✅ Daily loss < 3%
✅ ML models treinados (>85% accuracy)
✅ Multi-broker support funcional
✅ Código 100% comentado
✅ Testes passando
✅ Pronto para FTMO + Apex
```

---

## PARTE 8: NOTAS IMPORTANTES

### Linguagem

- **Tudo em Python** (tirando executor MT5 que é MQL5 mínimo)
- Usar NumPy/Pandas para performance
- Numba para loops críticos
- Sklearn para ML

### Estilo de Código

- Type hints em todas as funções
- Docstrings completas (Google style)
- PEP 8 compliance
- Modular e testável

### Dependências

```
NautilusTrader
pandas>=2.0
numpy>=1.24
scikit-learn>=1.3
xgboost>=2.0
tensorflow>=2.13
ta-lib
requests
pyyaml
pytest
```

### Versionamento

- Código: Git com commits atômicos
- Modelos ML: Versionar com timestamp + metrics
- Configurações: YAML versionado

---

## PARTE 9: COMO USAR ESTE PROMPT

### Primeira Chamada (Fase 1):

```
"Você é um especialista em NautilusTrader. Use este prompt:

[COPIAR TUDO ACIMA]

Crie SOMENTE os arquivos da FASE 1:
- src/strategies/order_block_strategy.py
- src/indicators/ict_confirmations.py
- tests/test_ob_detection.py

Requisitos:
- Código 100% funcional
- Type hints completos
- Docstrings detalhadas
- Pronto pra rodar: python -m nautilus.backtest.runner"
```

### Próximas Chamadas:

```
"Continue do prompt anterior. Agora implemente FASE 2:
- src/ml/feature_engineering.py
- src/ml/model_trainer.py
- Notebook: 02_ml_model_training.ipynb

[Repetir para próximas fases]"
```

---

## CHECKLIST FINAL

- [ ] Core strategy funcional
- [ ] Indicadores implementados
- [ ] ML pipeline treinado
- [ ] Risk management ativo
- [ ] Executores testados
- [ ] Backtests validados
- [ ] Documentação completa
- [ ] Código commitado
- [ ] Testes passando
- [ ] Pronto para deploy FTMO

---

**STATUS: Pronto para migração completa. Direcione este prompt ao Claude Opus 4.5 com suas 19 dependências Python e lógica MQL5 específica para obter codebase 100% funcional em 7 dias.**