# Backtesting Scripts - Map & Recommendations

**Objetivo:** evitar confusão entre dezenas de scripts e indicar o fluxo recomendado. Nada foi apagado; marcamos o que é core, utilitário e legado.

---

## Core (use primeiro)
- `realistic_backtester.py` — engine event-driven v2.0 (FTMO DD, latência, slippage, onnx mock, confluência).  
- `run_realistic_test.py` — CLI rápido para amostra; usa `realistic_backtester`.

### Como rodar (multi-anos, Parquet)
```bash
python -c "import pandas as pd; \
from scripts.backtest.realistic_backtester import RealisticBacktester, RealisticBacktestConfig, ExecutionMode; \
cfg=RealisticBacktestConfig(execution_mode=ExecutionMode.PESSIMISTIC, enable_latency_sim=True, enable_onnx_mock=True, min_confluence=65.0, debug=False); \
bt=RealisticBacktester(cfg); \
res=bt.run(r'data/ticks/xauusd_2020_2024_stride20.parquet', max_ticks=5_000_000, start_date='2020-01-01', end_date='2024-12-31'); \
print(res['metrics']); \
bt.export_trades(r'data/realistic_trades_2020_2024_stride20.csv'); \
pd.DataFrame([res['metrics']]).to_csv('data/backtest_metrics_2020_2024_stride20.csv', index=False)"
```

---

## Úteis / análise
- `ablation_study.py` — ablação de filtros SMC.
- `wfa_filter_study.py` — WFA/grid de filtros.
- `diagnose_ea_logic.py`, `diagnose_ea_logic_v2.py`, `diagnose_mtf.py` — debug de lógica/MTF.
- `parity_validator.py` — confere paridade de resultados.
- `footprint_analyzer.py` — análise footprint (ordem de fluxo).
- `segment_data.py` — segmentação de dados.

---

## Legado / especializado (usar só se precisar do caso específico)
- `tick_backtester.py`, `multi_year_backtest.py`, `realistic_multi_year.py`, `quick_multi_year.py` — pipelines antigos (tick_backtester) com fricções custom; manter por referência.
- `run_fase2_ea_backtest.py`, `comprehensive_validation.py`, `comprehensive_test.py`, `full_validation_session.py` — orquestrações faseadas; precisam ser revisadas (ex.: atributo `closed_trades`).
- `final_smc_test.py`, `incremental_smc_test.py`, `smc_optimized_test.py`, `quick_ob_test.py`, `debug_ob_test.py`, `test_full_ea_logic.py`, `test_real_thresholds.py`, `test_ea_single_bar.py` — harnesses de teste unitário/SMC.
- `shadow_exchange.py`, `studio.py`, `ultra_realistic_test.py`, `stress_test_degradation.py`, `monte_carlo_degradation.py` — protótipos/stress; manter para consulta.

---

## Estratégia recomendada daqui em diante
1) Dados: preferir Parquet (ex.: `data/ticks/xauusd_2020_2024_stride20.parquet`).  
2) Backtest: usar `realistic_backtester.py` com os comandos acima.  
3) Validação: exportar `trades.csv` e passar pelo pipeline Oracle (Monte Carlo / prop validator).  
4) Se precisar de WFA ou ablação, use `wfa_filter_study.py` e `ablation_study.py`.

---

*Não removemos scripts; este README apenas orienta o que é core e o que é legado.* 
