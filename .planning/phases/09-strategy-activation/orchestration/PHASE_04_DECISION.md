# Phase 04 Decision Record: MEAN_REVERT

decision:
  date: 2025-12-24
  choice: IMPLEMENT
  rationale: "Quero implementar uma estratégia focada em reversão para entender o que acontece e validar na prática. Não faz sentido remover sem ter desenvolvido e testado. Deve ser algo bem pensado e analisado (Crucible + Critic + etc.)."
  action_plan: |
    1) Implementar um gerador de sinais Mean Revert mínimo (BB+RSI) backtest-safe.
    2) Integrar ao `GoldScalperStrategy` com gating por `StrategySelector` (STRATEGY_MEAN_REVERT) + toggle `enable_mean_revert`.
    3) Adicionar RouterArm para rastrear performance no AdaptiveEVRouter.
    4) Criar testes unitários para o gerador (série sintética determinística).
    5) Rodar validações obrigatórias: `mypy --strict`, `pytest -q`, e quick backtest 2024-01-01→2024-01-07.

notes:
  - "Hoje, antes desta fase, MEAN_REVERT podia ser selecionado pelo selector mas não havia implementação dedicada (comportamento enganoso)."
  - "Implementação é opt-in (enable_mean_revert=false por padrão)."

addendum_phase_00c_retrofit:
  date: 2025-12-24
  context: "Phase 00-C (Portfolio Strategy Review) foi inserida retroativamente após a execução da Phase 04, para travar decisões do portfólio e thresholds falsification-first antes de seguir para Phase 05/06."
  alignment:
    - "A decisão IMPLEMENT permanece (vamos ter Mean Revert para validar), mas Mean Revert não vira 'pilar' do portfólio até passar nos gates de falsificação e survival (Apex/HWM)."
    - "Não adicionar novas estratégias (ex.: breakout/VWAP) nem expandir escopo do MR sem passar pelos testes do Phase 00-C."
  required_next_steps:
    - "Executar /run-plan .planning/phases/09-strategy-activation/11-PHASE-00C-PLAN.md"
    - "Aprovar o deliverable: .planning/phases/09-strategy-activation/orchestration/PHASE_00C_PORTFOLIO_REVIEW.md"
