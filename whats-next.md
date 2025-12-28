<original_task>
Criar um plano cirúrgico e executar otimizações de performance (Python/Nautilus) no backtest do `nautilus_gold_scalper` focando nos 3 maiores consumidores do tick-path: (1) spread monitor, (2) circuit breaker/safety breaker, (3) trabalho geral do `on_quote_tick` (tick-path). Também responder se vale mais analisar em stride=1 vs stride=20 e validar com dados.
</original_task>

<work_completed>
## 0) Contexto do repo/ambiente e regras (críticas)
- Repo: `/home/franco/projetos/EA_SCALPER_XAUUSD` (git, branch `main`).
- OS/host: Linux (WSL2). Python: 3.12.
- Regras do projeto (de `CLAUDE.md` na raiz):
  - NÃO reiniciar/derrubar CLIProxy sem confirmação explícita.
  - NÃO usar `git checkout/switch`, `git reset --hard`, `git clean -fd` etc sem confirmação explícita.
  - Validação gate: antes de dizer “done”, rodar `.venv/bin/python -m pytest -q` e `.venv/bin/mypy --strict ...`.
- Regras específicas de `nautilus_gold_scalper/CLAUDE.md`:
  - Gate de validação explícito para Python:
    - `.venv/bin/python -m pytest -q`
    - `.venv/bin/mypy --strict nautilus_gold_scalper/src nautilus_gold_scalper/scripts/optimize.py nautilus_gold_scalper/scripts/run_backtest.py nautilus_gold_scalper/scripts/backtest/run_backtest.py`

## 1) O que foi analisado (profiling artifacts) e por quê
Foram lidos vários artifacts JSON com tempos de execução (coarse profile) e fine timers (ns) para localizar gargalos no tick-path.

### Artifacts lidos (antes desta rodada)
- `nautilus_gold_scalper/_artifacts/_deep_profile_2024-01-02_2024-01-05/profile.json`
  - `total_seconds`: 5.34
  - `engine_run`: 4.432575
- `nautilus_gold_scalper/_artifacts/_deep_profile2_2024-01-02_2024-01-05/profile.json`
  - `total_seconds`: 19.359
  - `engine_run`: 16.022749
- `nautilus_gold_scalper/_artifacts/_deep_profile2_2024-01-02_2024-01-05/fine_profile.json`
  - Mostrou o tick-path dominando e CB relevante (ex: `base_on_quote_tick`, `cb_update_equity`, `cb_get_state` etc.).

### Baselines executados e lidos nesta continuação (Jan/02..Jan/03)
Comandos executados (sempre ticks + catalog):
- Stride20 baseline:
  - `.venv/bin/python nautilus_gold_scalper/scripts/backtest/run_backtest.py --start 2024-01-02 --end 2024-01-03 --product xauusd --feed ticks --source catalog --catalog-stride 20 --reports none --profile --fine-profile --out-dir nautilus_gold_scalper/_artifacts/perf_stride20_2024-01-02_2024-01-03 --quiet`
  - Logs mostraram failsafe em `time_gate_emergency_close` (esperado pelo time gate), mas run completou e gerou artifacts.
  - Coarse profile: `nautilus_gold_scalper/_artifacts/perf_stride20_2024-01-02_2024-01-03/profile.json`
    - `total_seconds`: 15.993
    - `engine_run`: 13.519588
  - Fine profile: `.../fine_profile.json`
    - `base_on_quote_tick` total_ns: 4,777,837,714 (count 14,937; avg ~319,865ns)
    - `cb_update_equity` total_ns: 211,205,599 (count 9,495)
    - `cb_get_state` total_ns: 163,458,732 (count 9,495)
  - Trade signature: `.../trade_signature_v2.json`
    - `schema`: trade_signature_v2
    - `count`: 6
    - `sha256`: `c07155e25f390424634a985176a8278f01a61da556b86003d5914685903e3133`

- Stride1 baseline:
  - `.venv/bin/python nautilus_gold_scalper/scripts/backtest/run_backtest.py --start 2024-01-02 --end 2024-01-03 --product xauusd --feed ticks --source catalog --catalog-stride 1 --reports none --profile --fine-profile --out-dir nautilus_gold_scalper/_artifacts/perf_stride1_2024-01-02_2024-01-03 --quiet`
  - Coarse profile: `.../profile.json`
    - `total_seconds`: 97.708
    - `engine_run`: 96.151364
  - Fine profile: `.../fine_profile.json`
    - `base_on_quote_tick` total_ns: 50,344,591,325 (count 298,740; avg ~168,523ns)
    - `cb_update_equity` total_ns: 2,412,310,396 (count 174,711)
    - `cb_get_state` total_ns: 2,327,611,630 (count 174,711)
  - Trade signature: `.../trade_signature_v2.json`
    - `count`: 5
    - `sha256`: `8534b59d2fdef2712a65eb64cee681f2820c98e694cf5863087ceb73aea0bd67`

Conclusão: stride1 é muito mais caro (tick volume), e o gargalo dominante é `base_on_quote_tick`. O CB e spread são relevantes dentro do tick-path.

## 2) Decisão técnica sobre stride=1 vs stride=20
- Foi verificado no runner que existe suporte a `--catalog-stride {1,5,10,20}` e também `--fidelity-stride1`.
  - Referências no arquivo: `nautilus_gold_scalper/scripts/backtest/run_backtest.py:2922` (`--catalog-stride`), `run_backtest.py:2934` (`--fidelity-stride1`), `run_backtest.py:3850` (checks do `--fidelity-stride1`).
- Decisão: iterar performance usando stride20/10/5 para velocidade e ranking de hotspots; validar fidelidade e resultado final com stride1 e/ou `--fidelity-stride1`.
- Importante: proporções não são exatamente iguais entre stride20 e stride1 porque o volume de ticks muda e o caminho de decisão pode divergir (inclusive trade_signature difere entre stride20 vs stride1, como mostrado acima). Porém, os hotspots do tick-path continuam dominantes em ambos.

## 3) Plano aprovado (plan file)
- Foi criado e salvo o plano em: `/home/franco/.claude/plans/compiled-coalescing-hejlsberg.md`.
- Conteúdo: plano cirúrgico para (1) CB single-lock snapshot, (2) gating agressivo do spread (tick time), (3) possíveis APIs `update_ts_ns`, (4) micro-optimizações no tick path, (5) caching de atributos de posição, (6) validação e re-profile.
- Observação: o usuário perguntou sobre Renko: “E os dados renko??? entra onde nessa atualizacao do plano?”
  - Resposta/posição técnica usada: Renko entra quando `--feed=bars` e `--bars-agg=renko` (ver CLI help do runner). Esse trabalho atual focou `--feed=ticks` (tick-path). Em bars/renko, `GoldScalperStrategy.on_quote_tick` não roda (e o spread monitor pode nem inicializar dependendo da aggregation source), então o plano atual não cobre renko diretamente.

## 4) Mudanças de código implementadas nesta continuação (detalhadas)

### 4.1) CircuitBreaker: acesso rápido sem cópia (reduz cb_get_state)
Arquivo: `nautilus_gold_scalper/src/risk/circuit_breaker.py`
- Adicionado método “fast-path”:
  - `def get_level_and_drawdown(self) -> tuple[CircuitBreakerLevel, float, float, float, float]:`
  - Referência atual (grep): `circuit_breaker.py:340`.
  - Retorna: `(level, daily_dd_percent, total_dd_percent, peak_equity, daily_start_equity)` sob um único `with self._lock:`.
- Motivação: reduzir custo de `get_state()` que copiava um dataclass inteiro sob lock a cada tick.

NOTA IMPORTANTE: Durante esta sessão houve também alterações mais amplas no `CircuitBreaker` (registradas em system-reminder ao sair do plan mode), adicionando “probe mode” e backoff de cooldown.
- `CircuitBreakerState` ganhou:
  - `probe_trades_remaining`, `probe_until`, `cooldown_backoff`
- `CircuitBreaker` ganhou constantes (ex.):
  - `PROBE_TRADES`, `PROBE_WINDOW_MINUTES`, `COOLDOWN_BACKOFF_FACTOR`, etc.
- `register_trade_result` e `can_trade` incorporaram lógica de probe/cooldown.
- Foram adicionados helpers como `_enter_cooldown`, `_maybe_deescalate`.
Essas mudanças impactam comportamento e devem ser consideradas na continuação. (Não foram revertidas.)

### 4.2) BaseStrategy tick-path: eliminar cópia do state e reduzir getattr/re-int
Arquivo: `nautilus_gold_scalper/src/strategies/base_strategy.py`

Mudança 1 — trocar `get_state()` por fast snapshot:
- Antes: `cb_state = self._circuit_breaker.get_state()`
- Depois: `(...)= circuit_breaker.get_level_and_drawdown()`
- Referência (grep):
  - `base_strategy.py:769` começa `cb_get_state` timer
  - `base_strategy.py:776` chamada `get_level_and_drawdown()`

Mudança 2 — ajustar telemetria de dd_snapshot sem `hasattr`/dataclass:
- Emite payload diretamente com floats retornados (`peak_equity`, `daily_start_equity`).

Mudança 3 — micro-opts para reduzir `int(tick.ts_event)` repetido:
- `self._attempt_failsafe_flatten(now_ts_ns=tick_ts_ns)`
  - Referência: `base_strategy.py:647`
- `elapsed_ns = tick_ts_ns - int(self._bracket_submitted_ts_ns)`
  - Referência: `base_strategy.py:684`
- `elapsed_since_open_ns = tick_ts_ns - int(self._position_opened_ts_ns)`
  - Referência: `base_strategy.py:697`

Mudança 4 — remover bloco redundante que reobtinha `now_dt` após `_compute_equity_from_tick`:
- Removido o trecho que fazia `now_dt = self._last_tick_dt` / fallback `fromtimestamp` depois de `equity = self._compute_equity_from_tick(tick)`.

Mudança 5 — reduzir overhead de `getattr` em loops:
- Introduzidos locals:
  - `position = self._position`
  - `drawdown_tracker = getattr(self, "_drawdown_tracker", None)`
  - `prop_firm = getattr(self, "_prop_firm", None)`
  - `circuit_breaker = getattr(self, "_circuit_breaker", None)`
- E usá-los no restante do tick path.
- Atenção: um trecho ainda ficou usando `self._prop_firm.ensure_compliance` e foi ajustado para `prop_firm.ensure_compliance`.

### 4.3) GoldScalperStrategy: gating de SpreadMonitor por tick time
Arquivo: `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
- Implementado gating de atualização do spread monitor no `on_quote_tick`:
  - Referência (grep): `gold_scalper_strategy.py:4487` (`interval_s = int(getattr(self.config, "spread_update_interval", 0) or 0)`)
  - Usa `ts_ns = int(tick.ts_event)` e `_last_spread_update_ts_ns` para só chamar `SpreadMonitor.update(...)` quando o intervalo passou.
  - Referência: `_last_spread_update_ts_ns` em `gold_scalper_strategy.py:4491` e set em `gold_scalper_strategy.py:4506`.
- Racional: spread não muda tão rápido; não faz sentido rodar análise estatística pesada a cada tick (especialmente stride1).

## 5) Validação executada nesta continuação

### Tests
- Circuit breaker tests após mudanças:
  - `.venv/bin/python -m pytest -q nautilus_gold_scalper/tests/test_risk/test_circuit_breaker_levels.py nautilus_gold_scalper/tests/test_risk/test_circuit_breaker_integration.py`
  - Resultado: 7 passed.
- Smoke de regressão CB + spread rate limiting:
  - `.venv/bin/python -m pytest -q nautilus_gold_scalper/tests/test_risk/test_circuit_breaker_levels.py nautilus_gold_scalper/tests/test_spread_monitor.py::TestSpreadMonitorUpdate::test_update_rate_limiting`
  - Resultado: 3 passed.

### mypy
- `.venv/bin/mypy --strict nautilus_gold_scalper/src/risk/circuit_breaker.py nautilus_gold_scalper/src/strategies/base_strategy.py nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
  - Resultado: Success.
- `.venv/bin/mypy --strict nautilus_gold_scalper/src/strategies/base_strategy.py`
  - Resultado: Success.

## 6) Re-profile (antes/depois) e resultados mensuráveis

### 6.1) Pós-otimização CB (cbfast)
Comando:
- `.venv/bin/python nautilus_gold_scalper/scripts/backtest/run_backtest.py --start 2024-01-02 --end 2024-01-03 --product xauusd --feed ticks --source catalog --catalog-stride 1 --reports none --profile --fine-profile --out-dir nautilus_gold_scalper/_artifacts/perf_stride1_2024-01-02_2024-01-03_cbfast --quiet`

Resultados:
- `.../profile.json`:
  - `total_seconds`: 63.341
  - `engine_run`: 61.834769
- `.../fine_profile.json`:
  - `base_on_quote_tick` total_ns: 31,004,396,581 (antes ~50,344,591,325)
  - `cb_update_equity` total_ns: 1,493,838,304 (antes ~2,412,310,396)
  - `cb_get_state` total_ns: 374,200,403 (antes ~2,327,611,630)

### 6.2) Pós-micro-opts no tick-path (tickopt)
Comando:
- `.venv/bin/python nautilus_gold_scalper/scripts/backtest/run_backtest.py --start 2024-01-02 --end 2024-01-03 --product xauusd --feed ticks --source catalog --catalog-stride 1 --reports none --profile --fine-profile --out-dir nautilus_gold_scalper/_artifacts/perf_stride1_2024-01-02_2024-01-03_tickopt --quiet`

Resultados:
- `.../profile.json`:
  - `total_seconds`: 53.537
  - `engine_run`: 51.875961
- `.../fine_profile.json`:
  - `base_on_quote_tick` total_ns: 26,594,259,046
  - `cb_update_equity` total_ns: 1,339,682,157
  - `cb_get_state` total_ns: 331,888,699

### 6.3) Determinismo / “same trades” após mudanças
- `trade_signature_v2.json` do stride1 baseline vs cbfast vs tickopt:
  - Baseline stride1: `sha256 = 8534b59d2fdef2712a65eb64cee681f2820c98e694cf5863087ceb73aea0bd67`
  - cbfast: `sha256 = 8534b59d2fdef2712a65eb64cee681f2820c98e694cf5863087ceb73aea0bd67`
  - tickopt: `sha256 = 8534b59d2fdef2712a65eb64cee681f2820c98e694cf5863087ceb73aea0bd67`
  - Ou seja: as otimizações (CB fast snapshot + tick micro-opts) preservaram o resultado de trades para stride1 nesse window.

## 7) Ações/ferramentas usadas (para rastreio)
- `Read` em vários artifacts JSON e arquivos de código.
- `Grep` para localizar flags e blocos relevantes, ex. `--catalog-stride`, `--fidelity-stride1`, `on_quote_tick`, etc.
- `Bash` para rodar backtests de baseline e re-profile, `pytest`, `mypy`.
- Foi invocado `Skill whats-next` em paralelo com leituras (isso gerou o `whats-next.md` anterior que estava desatualizado/fora do contexto; este arquivo será sobrescrito agora pelo handoff correto).

</work_completed>

<work_remaining>
## P0 — Atualizar TODOs / finalizar o bloco “tick-path” atual
Estado atual do TODO list (no final desta sessão):
- [pending] Optimize SpreadMonitor update/analyze hot path
- [in_progress] Reduce tick-path overhead in BaseStrategy.on_quote_tick
- [pending] Run mypy/pytest and re-profile to confirm gains

Apesar do re-profile já ter sido executado e testes mínimos passarem, ainda falta:
- Consolidar a etapa 4 do plano (micro-opts) com o restante das ideias (sem quebrar determinismo) OU marcar como concluída e mover para spread.
- Rodar o gate completo (`pytest -q` full + mypy strict full scope) antes de “done”.

## 1) CircuitBreaker: implementar “single-call” (update + snapshot) para eliminar double-lock
Requisito do usuário: “Yes, merge calls”.
- Atualmente, no tick path de `BaseStrategy`, ainda há:
  - `circuit_breaker.update_equity(...)` e depois `circuit_breaker.get_level_and_drawdown(...)` (2 locks separados).
  - Referência: `base_strategy.py:764` e `base_strategy.py:776`.
- Implementar no `CircuitBreaker` um método único (sob um único lock):
  - Ex: `update_equity_and_get_level_and_drawdown(current_equity: float, now: datetime | None = None) -> tuple[...]`
- Substituir no tick-path por essa chamada única.
- Revalidar com:
  - `pytest` circuit breaker tests (`test_risk/test_circuit_breaker_levels.py`, `test_risk/test_circuit_breaker_integration.py`).
  - Re-profile stride1 (mesmo window) e comparar `cb_update_equity` + `cb_get_state`.
  - Confirmar `trade_signature_v2.json` hash permanece igual.

## 2) SpreadMonitor: reduzir ainda mais custo (sem perder a semântica de rate limiting)
Situação atual:
- Já existe gating em `gold_scalper_strategy.py` via `_last_spread_update_ts_ns`.
- `SpreadMonitor.update()` ainda faz:
  - validações, record, análise estatística e cria `SpreadSnapshot`.
- Test crítico: `nautilus_gold_scalper/tests/test_spread_monitor.py::test_update_rate_limiting` exige `snapshot1 is snapshot2` quando rate-limited (linha do teste: `test_spread_monitor.py:120`).

Próximos passos sugeridos (em ordem, mantendo segurança):
1) Confirmar que o gating no strategy está realmente usando o mesmo intervalo do config (`spread_update_interval`) e que o default não chama SpreadMonitor excessivamente.
2) Se ainda hot: implementar `SpreadMonitor.update_ts_ns(bid, ask, *, now_ts_ns: int)` com rate limiting por ns (evita `datetime` e `.total_seconds()`).
   - Deve preservar: quando rate-limited e `_snapshot` existe, retornar exatamente `_snapshot` (mantém o `is` do teste).
3) Opcional (somente se necessário): um método unchecked para tick data, mas isso tem risco.

Validação:
- `pytest -q nautilus_gold_scalper/tests/test_spread_monitor.py`
- re-profile stride1; adicionar timer fino opcional ao redor do spread update (se ainda estiver “invisível” nos fine timers atuais).

## 3) Tick-path: caching de atributos de posição (ainda não feito)
Arquivo alvo: `nautilus_gold_scalper/src/strategies/base_strategy.py`.
- `_compute_equity_from_tick` (atualmente em torno de `base_strategy.py:2216`) ainda usa muitos `getattr/hasattr/as_double` por tick.
- Próximo passo: cachear entry price/qty/side/point_value quando a posição abre (`on_position_opened`) e limpar ao fechar.
- Cuidado: parcial/modify e price objects vs float.
- Validar determinismo via `trade_signature_v2`.

## 4) Renko (pergunta do usuário)
- Renko entra no runner via `--feed=bars` e `--bars-agg=renko` (ver help e flags em `run_backtest.py`).
- O trabalho atual focou ticks; para renko:
  - O hotspot será em `on_bar`/pipeline de bars, não `on_quote_tick`.
  - Spread monitor e CB intrabar por tick podem não ser acionados.
- Próximo passo (se renko for prioridade): rodar um perfil separado `--feed=bars --bars-agg=renko` e identificar hotspots equivalentes (bar-path).

## 5) Validação final (gate completo)
Antes de declarar concluído:
- `.venv/bin/python -m pytest -q`
- `.venv/bin/mypy --strict nautilus_gold_scalper/src nautilus_gold_scalper/scripts/optimize.py nautilus_gold_scalper/scripts/run_backtest.py nautilus_gold_scalper/scripts/backtest/run_backtest.py`
- (Opcional) `--fidelity-stride1` para confirmar fidelidade na mesma janela.

</work_remaining>

<attempted_approaches>
## 1) Comparar stride1 vs stride20 sem medir
- Foi considerado “assumir” que a proporção seria igual, mas foi decidido medir com runs reais em `2024-01-02..2024-01-03` para ter evidência concreta.
- Resultado: ranking similar, mas custos absolutos e trade results mudam com stride (trade_signature difere entre stride20 vs stride1).

## 2) Focar só em `_check_for_signal`/confluence
- Era uma hipótese inicial (por fine_profile antigo) que confluence seria grande.
- Medições mostraram que o tick-path domina o `engine_run`, então o foco mudou para `on_quote_tick`, CB e spread.

## 3) Uso do `Skill whats-next` no meio do trabalho
- Foi invocado `Skill whats-next` durante uma etapa de profiling para gerar handoff.
- Isso gerou um `whats-next.md` anterior com conteúdo não alinhado ao estado atual do trabalho (misturou com outro contexto de otimizações em arrays/confluence).
- Este handoff atual sobrescreve esse arquivo com o estado correto.

## 4) Plan mode acionado no meio (mishap)
- Houve uma entrada em plan mode via `EnterPlanMode` durante a execução; isso restringe ferramentas.
- Foi corrigido criando o plano em `/home/franco/.claude/plans/compiled-coalescing-hejlsberg.md`, perguntando ao usuário (AskUserQuestion), e saindo via `ExitPlanMode`.

## 5) Logs de failsafe/time gate durante perf runs
- Os runs imprimiram mensagens de `[FAILSAFE] time_gate_emergency_close` e tentativas de flatten.
- Não foi tratado como erro, porque o sistema de prop firm/time gate força close e halt. Importante: não “corrigir” isso como bug durante perf.

</attempted_approaches>

<critical_context>
## 1) Objetivo técnico e métrica
- Meta: acelerar `engine_run` (dominante) reduzindo `base_on_quote_tick` e custos internos, sem alterar decisões de trade.
- Métrica de determinismo: `trade_signature_v2.json` (hash SHA256) deve permanecer igual para o mesmo window/config.

## 2) Hotspots atuais (após otimizações já feitas)
- Após tickopt (stride1 Jan/02..Jan/03):
  - `profile.json total_seconds`: 53.537 (antes 97.708)
  - `engine_run`: 51.876 (antes 96.151)
  - `fine_profile base_on_quote_tick`: 26.594s-equivalente (ns total)
  - `cb_update_equity`: ~1.340s; `cb_get_state`: ~0.332s
- Ainda há muito tempo dentro de `base_on_quote_tick`; próximos ganhos devem vir de:
  - reduzir custo de `_compute_equity_from_tick`
  - reduzir custo de spread monitor (se ainda relevante)
  - reduzir custo de CB lock (single-call)

## 3) Determinismo e riscos
- Regras Apex/prop firm e time gates são críticas; não rate-limit DD checks de forma que possa “perder” um breach.
- Usar `tick.ts_event` (ns) como tempo canônico em backtest; não usar wall-clock.
- Spread rate limiting precisa manter semântica dos testes (snapshot identity) e evitar mudar “can_trade” em momentos de spread spike.

## 4) Renko: escopo
- Renko é um modo alternativo de feed (bars) e muda o caminho de execução.
- O plano atual é para tick feed; para renko precisa um perfil separado.

## 5) Arquivos-chave e referências
- Runner e flags:
  - `nautilus_gold_scalper/scripts/backtest/run_backtest.py:2908` (`--fine-profile`)
  - `.../run_backtest.py:2922` (`--catalog-stride`)
  - `.../run_backtest.py:2934` (`--fidelity-stride1`)
  - `.../run_backtest.py:3850` (`--fidelity-stride1` validation)
- Strategy tick path:
  - `nautilus_gold_scalper/src/strategies/base_strategy.py:620` (`on_quote_tick`)
  - `nautilus_gold_scalper/src/strategies/base_strategy.py:2216` (`_compute_equity_from_tick`)
- Spread:
  - `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:4457` (`on_quote_tick` override)
  - `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:4487` (spread gating)
  - `nautilus_gold_scalper/src/risk/spread_monitor.py` (update + rate limiting; test expects cached object)
- Circuit breaker:
  - `nautilus_gold_scalper/src/risk/circuit_breaker.py:340` (`get_level_and_drawdown`)

## 6) Artifacts e pastas relevantes
- Perf artifacts criados nesta sessão:
  - `nautilus_gold_scalper/_artifacts/perf_stride20_2024-01-02_2024-01-03/`
  - `nautilus_gold_scalper/_artifacts/perf_stride1_2024-01-02_2024-01-03/`
  - `nautilus_gold_scalper/_artifacts/perf_stride1_2024-01-02_2024-01-03_cbfast/`
  - `nautilus_gold_scalper/_artifacts/perf_stride1_2024-01-02_2024-01-03_tickopt/`
- Plan file:
  - `/home/franco/.claude/plans/compiled-coalescing-hejlsberg.md`

</critical_context>

<current_state>
## Deliverables/status
- Baseline profiling (stride20 vs stride1) para Jan/02..Jan/03: COMPLETO.
- CircuitBreaker fast snapshot (`get_level_and_drawdown`) + uso no tick path: COMPLETO e medido.
- Micro-opts no tick-path (`base_strategy.py`) para reduzir `int()` repetido, `getattr` repetido e remover redundância: PARCIALMENTE COMPLETO (já gerou ganhos mensuráveis).
- SpreadMonitor hot-path (além do gating no strategy): PENDENTE.
- CircuitBreaker single-call (update + snapshot sob um lock): PENDENTE (usuário aprovou “merge calls”).
- Validação final completa (pytest full + mypy strict full scope): PENDENTE.

## O que está salvo vs temporário
- Código foi editado diretamente nos arquivos do repo (não é só experimento local).
- Artifacts de perf estão em `_artifacts/` e servem como baseline/after.
- `whats-next.md` anterior estava desalinhado; este arquivo agora deve ser o handoff correto.

## Estado de determinismo
- Para stride1 Jan/02..Jan/03, os hashes `trade_signature_v2.json` bateram entre baseline e runs otimizados (cbfast/tickopt). Isso é um checkpoint forte de “no behavior change” nesse window.

## Posição no workflow
- Próximo passo recomendado para continuar em novo contexto:
  1) Implementar CB single-call para eliminar double-lock.
  2) Implementar/confirmar otimização do spread (provavelmente `update_ts_ns` se ainda hot).
  3) Caching de atributos de posição em `_compute_equity_from_tick`.
  4) Rodar gates completos e re-profile final.

</current_state>
