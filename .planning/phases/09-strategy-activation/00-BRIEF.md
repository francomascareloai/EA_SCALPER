# BRIEF: Strategy Activation & Validation

## Objective

Ativar, validar e integrar TODAS as estratégias disponíveis no robô Nautilus para criar um sistema multi-estratégia robusto. O trabalho anterior construiu a infraestrutura (StrategySelector, AdaptiveEVRouter, TrendFollow, indicadores SMC) - agora precisamos USAR tudo isso.

## Problema

O robô tem múltiplas estratégias implementadas mas:
1. **SMC_SCALPER** é a única ativa por default
2. **TREND_FOLLOW** está implementado mas desabilitado (`enable_trend_follow=False`)
3. **MEAN_REVERT** tem enum definido mas ZERO implementação
4. **StrategySelector** funciona mas algumas estratégias que ele escolhe não existem
5. **AdaptiveEVRouter** está pronto mas desabilitado (`router_adaptive_ev=False`)
6. Não há validação rigorosa de edge para nenhuma estratégia

**Resultado:** Sistema sub-utilizado, dependência de uma única estratégia, risco de não ter edge real.

## Scope

### In-Scope

1. **Auditoria Estratégica Profunda (CRUCIBLE)**
   - SMC_SCALPER: Validar os 9 indicadores SMC
   - TREND_FOLLOW: Validar pullback + breakout
   - MEAN_REVERT: Implementar ou remover
   - StrategySelector: Validar gates e decisões
   - AdaptiveEVRouter: Validar learning + selection

2. **Cleanup de Código Morto**
   - NEWS_TRADER: Remover do fluxo (não operamos notícias)
   - FOOTPRINT: Arquivar (sem dados de futuros)
   - MTF duplicado: Consolidar
   - Scripts legacy ea_logic_*.py: Arquivar

3. **Integração Completa**
   - Ativar TREND_FOLLOW por default
   - Implementar ou remover MEAN_REVERT
   - Ativar AdaptiveEVRouter
   - Documentar fluxo de decisão

4. **Backtest Multi-Estratégia**
   - Cada estratégia isolada
   - Estratégias combinadas via Selector
   - Estratégias combinadas via Router
   - Métricas: WFE, SQN, PSR, MC95DD

### Out-of-Scope

- NEWS_TRADER (não operamos notícias)
- FOOTPRINT (sem dados de futuros - arquivar para futuro)
- MQL5 code (foco em Python/Nautilus)
- Dados de mercado (usar dataset existente)

## Estratégias a Validar

| Estratégia | Status Atual | Ação |
|------------|--------------|------|
| SMC_SCALPER | Ativa, não validada | CRUCIBLE audit + backtest |
| TREND_FOLLOW | Implementada, desabilitada | Ativar + validar |
| MEAN_REVERT | Enum sem código | Implementar OU remover |
| SAFE_MODE | Funciona | Apenas documentar |
| NEWS_TRADER | Implementado | REMOVER do fluxo |

## Success Criteria

1. **Cada estratégia validada** com backtest rigoroso (WFE >= 0.6, SQN >= 2.0)
2. **Múltiplas estratégias ativas** para robustez
3. **StrategySelector funcionando** com todas as estratégias válidas
4. **AdaptiveEVRouter opcional** mas funcional
5. **Código limpo** - sem dead code, sem duplicações
6. **Documentação completa** do fluxo de decisão

## Deliverables

1. `AUDIT_REPORT.md` - Análise profunda de cada estratégia
2. `BACKTEST_RESULTS.md` - Métricas por estratégia
3. `INTEGRATION_GUIDE.md` - Como as estratégias se conectam
4. Código atualizado com estratégias ativas
5. Testes unitários para cada estratégia

## Constraints

- CRUCIBLE review obrigatório para cada estratégia
- Backtest com dataset canônico (xauusd_2003_2025_stride20_full.parquet)
- Apex compliance em todas as estratégias
- NO look-ahead bias
- Performance budget: <50ms on_tick

## Estimated Effort

- ~15,000 linhas de código a analisar
- 4 estratégias a validar
- 2 frameworks (Selector + Router) a integrar
- ~500 linhas de código morto a arquivar

## Owner

Franco

## Status

DRAFT - Pending approval
