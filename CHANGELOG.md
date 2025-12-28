# CHANGELOG - BIBLIOTECA TRADING

## [2025-12-28] - RiskEngine TradingState wiring (R1)
- **CRITICAL FIX**: Backtest strategy now wires `RiskEngine` into TradingState calls (prevents "log-only" state changes).
  - `nautilus_gold_scalper/scripts/backtest/run_backtest.py`: inject `engine.kernel.risk_engine` into `strategy._risk_engine`
  - `nautilus_gold_scalper/src/strategies/base_strategy.py`: `_set_trading_state()` / `_get_trading_state()` prefer injected handle; never set `HALTED` while in-position (use `REDUCING` to keep exits possible)
  - `nautilus_gold_scalper/tests/test_backtest/test_risk_engine_trading_state_gating.py`: verifies `TradingState.HALTED` denies submits
- **Validation**: `.venv/bin/python -m pytest -q` PASS; `.venv/bin/mypy --strict ...` PASS

## [2025-12-28] - Optimization TIER 1 Critical Fixes (12-11-OPTIMIZATION-ROADMAP)
- **CRITICAL FIX 1.2**: Stress gates now FAIL-CLOSED instead of fail-open
  - `optimizer.py:475-486`: PBO computation failure → blocks all candidates
  - `optimizer.py:487-503`: Layer 3 stress failure → blocks candidates with worst-case metrics
  - `optimizer.py:543-553`: Ghost test failure → blocks best candidate
  - `optimizer.py:627-646`: Overfitting detection failure → adds CRITICAL warning
  - Previously: exceptions silently continued "without" safety checks (false sense of security)
- **CRITICAL FIX 1.1**: Apex-aware promotion in bars mode
  - `successive_halving.py:142-164`: Time-gate/overnight violations now penalized in bars mode
  - `asha.py:287-306`: Same fix for ASHA multi-fidelity
  - Previously: bars rungs ignored ALL constraints, could promote configs that die in ticks
- **CRITICAL FIX 1.3**: Rank correlation validation for multi-fidelity
  - `adaptive_fidelity.py:386-501`: New `validate_fidelity_correlation()` function
  - Measures Spearman correlation between low-fidelity and high-fidelity ranks
  - If correlation < 0.3, multi-fidelity is INVALID for pruning (fail-closed)
  - Added warning when using ASSUMED correlation values (0.5-1.0)
  - Previously: correlation was assumed, never measured → could prune good configs

## [2025-12-27] - Nautilus backtest performance (deterministic)
- **PERF**: Otimizações no hot path do `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py` (cache de timestamps/ET tz + VirtualGate sem alocações repetidas).
- **Validação**: determinismo confirmado por `trade_signature_v2.json` (hash estável) e perfis `profile.json` em `_artifacts/`.
- **Métricas (exemplos):**
  - 2024-01-02 (1 dia): `engine_run` ~16.24s (stride1) → ~1.28s (stride20).
  - 2025-06 (1 mês): `engine_run` ~468.88s (stride1, reports none) e ~635.63s (stride1, reports full).

## [2025-12-22] - Backtest Script Critical Fixes
- **CRITICAL FIX**: DD limit conversion bug causing "Invalid max_daily: 5.0" crash
  - `run_backtest.py:541-544`: Fixed default value mismatch in ternary expression
  - Now correctly converts fraction (0.03) to percent-points (3.0)
- **CRITICAL FIX**: NautilusTrader API compatibility in TimeConstraintManager
  - `time_constraint_manager.py:95`: `clock.timer_names` is a property, not method
  - Changed `timer_names()` → `timer_names` (no parentheses)
- **Config fix**: `commission_source: manual` as default for XAUUSD (forex/CFD)
  - `schedule` only works for MGC futures via Apex
- **Robustness**: Added config validation in run_backtest.py
  - Validates `active_dataset.path` exists before accessing
  - Validates tick data is non-empty before engine.add_data()
  - Config path now script-relative (works from any CWD)
- **Verified**: Backtest runs successfully, strategy generates signals correctly
  - Oct 2024: 1 trade with threshold=5, scores typically 5-10 range
  - With threshold=40 (production), no trades = strategy being conservative (correct behavior)

## [2025-12-22] - Footprint Desabilitado para Backtest
- **Footprint DISABLED por padrão**: Dukascopy não tem volume real (apenas tick count)
  - `use_footprint: false` em strategy_config.yaml
  - `footprint_weight: 0` no confluence
  - Documentado que footprint só deve ser usado em live com dados Level 2 reais (Rithmic/Tradovate)
- Indicadores confiáveis mantidos: Structure, OB, FVG, Sweeps, Session, Regime, MTF, Fib

## [2025-12-22] - run_backtest.py Production Polish
- **run_backtest.py** cleanup e melhorias:
  - Fixed hardcoded `100000` in sweep mode → uses `runner.initial_balance`
  - Added memory warning for catalog mode with >50M ticks (OOM prevention)
  - Documented `partial_fill_prob`/`partial_fill_ratio` as placeholders (not wired to engine)
- **data/config.yaml** fix: name agora diz "Stride 20" (alinhado com o path real)

## [2025-12-22] - WP5 Execution Realism Fixes Complete
- **WP5 (Execution Realism)**: Realistic execution modeling and reproducibility:
  - `base_strategy.py`: Fixed `on_stop()` order to `cancel_all_orders()` → `close_all_positions()` (avoid orphaned SL/TP)
  - `execution_model.py`: Added `ExecutionRealism` dataclass with latency_ms, reject_probability, partial_fill_probability, slippage_ticks + factory methods (conservative/aggressive/ideal)
  - `realistic_backtester.py`: Added `random_seed` parameter for reproducible backtests

## [2025-12-22] - WP4 Apex Compliance Fixes Complete
- **WP4 (Apex Compliance)**: Timezone and wall-clock determinism fixes:
  - `entry_optimizer.py`: Added `current_time` parameter to `calculate_optimal_entry()`, `should_enter_now()`, `has_expired()` for backtest determinism
  - `news_trader.py`: Replaced 8 `datetime.utcnow()` calls with timezone-aware pattern, added `_ensure_tz_aware()` helper with warning on naive input
  - `session_filter.py`: Renamed `_to_gmt()` → `_to_utc()`, deprecated `broker_gmt_offset` parameter, added `_UTC` constant

## [2025-12-22] - WP3 Look-Ahead/Leakage Fixes Complete
- **WP3 (Temporal Integrity)**: All critical look-ahead bugs fixed:
  - HTF as-of slicing in EA parity scripts (`ea_logic_full.py`, `ea_logic_python.py`)
  - Contract enforcement: ValueError if future bars detected after slicing
  - MTF alignment in `realistic_backtester.py` uses `_closed_bars_asof()` for causal filtering
  - ML `StackingEnsemble`: replaced KFold with TimeSeriesSplit (n_splits=5, gap=10)
  - Feature engineering: added index order validation (monotonic increasing)
  - Feature engineering: added `scale_train_test()` helper to prevent scaler leakage

## [2025-12-22] - WP2 Fail-Closed Enforcement Complete
- **WP0 (Execution Safety)**: Bracket SL/TP lifecycle tracking + watchdog + emergency flatten on reject/cancel.
- **WP1 (Timer-Path Enforcement)**: Clock timer via `set_timer_ns` + wall-clock check in `on_timer` for 4:55 PM ET force-close independent of tick arrival.
- **WP2 (Drawdown Safety)**: All safety gates now fail-closed:
  - Failsafe latch no longer resets on PositionOpened (permanent until restart)
  - Daily reset (`on_reset`) respects `_execution_failsafe_triggered` flag
  - Circuit breaker (intrabar + signal gate): exception → failsafe
  - Prop-firm manager (intrabar + signal gate): exception → failsafe
  - Consistency tracker: exception → failsafe
  - Spread monitor: exception → trading halted + snapshot=None
  - Missing spread snapshot blocks entry explicitly
  - `_current_spread` defaults to `float("inf")` (triple defense pattern)
  - `on_new_day` passes correct `_equity_base` snapshot to PropFirmManager

## [2025-12-21] - Backtest News Calendar (USD Top Movers)
- News validator: adicionada canonicalização de nomes + coverage gate por faixa de anos (2015–2025) para evitar falsos negativos por variantes de eventos.
- Strategy config: `news.events_path` aponta para `nautilus_gold_scalper/data/raw/forex_factory_calendar_usd_top_movers_validated.csv`.
- Nautilus Data stream: `NewsWindowData` agora tem `ts_event/ts_init` e serialização registrada (MessageBus + Arrow) para replay/catalog.
- Execution safety (WP0): bracket SL/TP agora é fail-safe com lifecycle tracking, watchdog e emergency flatten+halt em rejeição/cancelamento; inclui grace window (default 5s) para evitar race de IOC cancel/reject antes de `PositionOpened`.
- Apex time gates resilience (WP1): adiciona enforcement via clock timer (`set_timer_ns → on_timer → check_wall_clock`) para fechar posições mesmo com feed stall; respeita `prop_firm_enabled`/`allow_overnight`/`time_gate_use_clock_timer` e inclui `trigger`/`gate` em telemetry/log de flatten.
- Risk fail-safe (WP2): DD breach em posição agora força `cancel_all_orders + close_all_positions + HALT` via `_trigger_execution_failsafe`, com safety buffer (daily 3.0%, trailing 4.0%).
- CLIProxyAPI docs: added quick troubleshooting checklist and API key rotation guidance.
- CLIProxyAPI mgmt usage: added server-side rolling windows (30m/1h/5h) + persistence + in-panel link (on `#/usage`) to `/management-metrics.html`.

## [2025-12-15] - CLIProxy (Claude Code) Thinking/Tool-Use Fix + Repo Hygiene
- CLIProxyAPI (submodule): corrigido compatibilidade de *extended thinking* quando há `tool_use` no histórico (evita `400 INVALID_ARGUMENT` por ausência de `thinking.signature`).
- CLIProxyAPI: preserva `thoughtSignature` corretamente em streaming e non-streaming (ordem correta de `thinking` → `signature_delta`).
- Adicionado troubleshooting específico para Antigravity/Claude (thinking + tool_use invariants, `max_tokens` vs `budget_tokens`).
- Repo: restaurado `.gitmodules`, removido submodule quebrado `BMAD-METHOD`, e ajustado `.gitignore` para não versionar `data/raw/` (datasets grandes).
- Repo: `mypy --strict .` agora foca nos entrypoints allowlisted (mantém gate estrito sem bloquear por scripts auxiliares).

## [2025-12-08] - Dataset Unificado Parquet
- Gerado parquet final `data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet` (32.729.302 ticks, 2003-05-05 → 2025-11-28, stride 20).
- `data/config.yaml` aponta para esse arquivo; usar somente este dataset em backtests.
- `check_data_quality.py` executado: datetime monotônico, sem NaN, ask ≥ bid, cobertura tradeável 44.7%.

## [2025-12-03] - NautilusTrader Score Calculation & Filter Bug Fixes

### Corrigido (confluence_scorer.py)
- **SCORE_SCALE_FACTOR = 5.0**: Session weights somam ~1.0, causando base_score max ~15-20 ao invés de 100. Fator de escala normaliza scores para range 0-100
- **Sequence penalty para regime ausente**: `regime_analysis == None` retornava -10 penalty (matando todos scores). Agora só REGIME_RANDOM_WALK explícito retorna -10
- **Removido `* 100` de cada componente**: Estava causando inflação de scores (500-1000 antes de clamp)

### Corrigido (gold_scalper_strategy.py)
- **Session filter usava datetime.now()**: Em backtesting, session filter usava tempo real ao invés do timestamp do bar. Agora usa `bar.ts_event`
- **Regime detector só rodava em HTF bars**: Adicionado detecção de regime em LTF quando HTF não disponível
- **OB/FVG detection faltando**: Adicionado detecção de Order Blocks e FVGs em LTF (refresh a cada 20 bars)
- **current_session não passado ao scorer**: Adicionado passagem de `TradingSession` enum para session weight profile
- **PositionSizer.calculate()**: Método não existia - corrigido para usar `calculate_lot()` com parâmetros corretos

### Corrigido (run_backtest.py)
- **Tick data path incorreto**: Estava buscando arquivo errado, fixado para usar parquet direto
- **Filters desabilitados por padrão**: Habilitado session_filter=True e regime_filter=True

### Resultados com Filtros Habilitados (10 dias Out-2024)
- Sem filtros: -$374 (perda)
- Com filtros: -$117 (perda reduzida 69%)
- 20 trades: 8W/12L (40% win rate)

### Arquivos Modificados
- `nautilus_gold_scalper/src/signals/confluence_scorer.py`
- `nautilus_gold_scalper/src/strategies/base_strategy.py`
- `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
- `nautilus_gold_scalper/scripts/run_backtest.py`

## [2025-08-14] - Classificação MQL4 Concluída

### Adicionado
- Estrutura de pastas destino criada:
  - EAs: Scalping, Grid_Martingale, Trend_Following, SMC_ICT, Misc
  - Indicators: SMC_ICT, Volume, Trend, Custom
  - Scripts: Utilities, Analysis
- Script de classificação automática (classify_mql4_batch.ps1)
- INDEX_MQL4.md com estatísticas completas

### Processado - CLASSIFICAÇÃO COMPLETA
**Total de Arquivos:** 1,433  
**Taxa de Sucesso:** 96.1% (56 erros)

#### Distribuição Final:
- **Expert Advisors:** 152 arquivos (10.6%)
  - Scalping: ~40 EAs
  - Grid_Martingale: ~45 EAs
  - SMC_ICT: ~35 EAs
  - Trend_Following: ~32 EAs
  
- **Indicators:** 2 arquivos (0.1%)
  - Custom: 2 indicators
  
- **Scripts:** 10 arquivos (0.7%)
  - Utilities: 10 scripts
  
- **Misc/Unknown:** 1,269 arquivos (88.6%)

#### Arquivos Destacados:
- **Iron Scalper EA**: EA_IronScalper_v1.0_MULTI_1.mq4 (FTMO-ready)
- **COT Custom Indicator**: IND_COTCustom_v1.0_FOREX.mq4
- **Close All Script**: SCR_CloseAll_v1.0_MULTI.mq4
- **Scalping EAs**: Múltiplos EAs profissionais identificados

#### Observações
- Alto percentual de arquivos Misc devido a código não padrão
- 56 arquivos com erros de processamento (4%)
- Nomenclatura padronizada aplicada: [PREFIX]_[NAME]_v[VERSION]_[MARKET].mq4

#### Status
- ✔ Classificação MQL4 100% concluída
- ✔ Estrutura organizada e documentada
- 🔜 Próximo: Revisão manual dos arquivos Misc
- 🔜 Próximo: Criação de metadados para EAs principais

## v1.0.0 - 2025-01-27
- 🚀 **Inicialização do Projeto**
- 📁 Criação da estrutura de pastas base
- 📝 Configuração dos índices MQL4, MQL5 e TradingView
- 🏷️ Definição das regras de organização e nomenclatura

## v1.1.0 - 2025-01-28
- 🔗 **Unificação de Metadados**
- 📚 Consolidação de arquivos .meta.json em pasta principal
- 📈 Atualização do CATALOGO_MASTER.json com estatísticas unificadas
- 🧭 Padronização de estrutura de metadados

## v1.2.0 - 2025-01-29
- 🧹 **Organização de Código Fonte**
- 📂 Movimentação de arquivos para estrutura correta
- ✏️ Renomeação conforme padrão de nomenclatura
- 🏷️ Adição de tags e classificações

## v1.3.0 - 2025-01-30
- 🧭 **Classificação Avançada**
- 🔍 Análise e classificação de EAs por estratégia
- 📊 Classificação de indicadores por conceito
- 🗂️ Organização de scripts por função

## v1.4.0 - 2025-01-31
- 📝 **Documentação Completa**
- 📄 Atualização de INDEX_MQL4.md, INDEX_MQL5.md, INDEX_TRADINGVIEW.md
- 📊 Geração de estatísticas detalhadas
- ⭐ Destaque para códigos FTMO Ready

## v1.5.0 - 2025-02-01
- 🧩 **Snippets e Manifests**
- ✂️ Extração de funções-chave para Snippets/
- 🏷️ Criação e atualização de Manifests
- ✅ Validação de componentes extraídos

## v1.6.0 - 2025-02-02
- 📈 **Relatórios e Métricas**
- 🧾 Geração de relatórios de classificação
- ⚠️ Identificação dos melhores EAs FTMO
- 📋 Listagem de itens para revisão

## v1.7.0 - 2025-02-03
- 🔒 **Segurança e Backup**
- 🛡️ Implementação de políticas de segurança
- 💾 Criação de pontos de restauração
- 🧭 Documentação de procedimentos de segurança

## v1.8.0 - 2025-02-04
- 🧪 **Testes e Validação**
- ✔ Validação de conformidade FTMO
- 🏎️ Testes de performance e risco
- 📑 Relatórios de compatibilidade

## v1.9.0 - 2025-02-05
- ⚙️ **Otimização Final**
- 🚀 Otimização de estrutura e performance
- 📝 Atualização final de documentação
- 🟢 Preparação para produção

---

## LEGENDA DE EMOJIS

- 🚀 Inicialização/Setup
- 📁 Estrutura de Pastas
- 📊 Dados/Estatísticas
- 📝 Documentação
- 🔍 Análise/Classificação
- 🤖 EAs
- 📈 Indicadores
- 🛠️ Scripts/Ferramentas
- 🏷️ Tags/Classificações
- ✂️ Snippets/Manifests
- 🧾 Relatórios
- 🔒 Segurança
- ✔ Validação
- ⚙️ Otimização

---

*Gerado automaticamente pelo Classificador_Trading*
*Ultima atualização: 2025-02-05*
