# Micro-auditoria — QTradeX-Algo-Trading-SDK (squidKid-deluxe)

- Repo: https://github.com/squidKid-deluxe/QTradeX-Algo-Trading-SDK
- Data: 2025-12-25
- Objetivo: avaliar utilidade para `EA_SCALPER_XAUUSD` (XAUUSD/Apex) e compatibilidade com NautilusTrader.

## 1) TL;DR
**Recomendação:** **NO-GO** (não adotar como dependência / não integrar com NautilusTrader).

**Motivos principais:**
- Escopo atual é **crypto + CCXT + candles** (Forex/Comex aparece só como *roadmap* no README).
- Integrar um “engine” paralelo de backtest/execução cria **divergência de semântica** vs nosso stack (tick-level, bid/ask, slippage, time-gates ET, HWM/trailing DD Apex).
- **Licença ambígua**: `setup.py` declara **MIT**, mas o arquivo `LICENSE` contém um texto tipo **WTFPL/paródia** (risco jurídico e de governança).

## 2) Fit vs nosso projeto (NautilusTrader + XAUUSD + Apex)
### O que o nosso stack precisa
- Backtest e simulação com **ticks** e **bid/ask** (evitar “mid price fills”).
- Regras Apex: **time-gate ET (4:30 / 4:55 / 4:59)** + **HWM/trailing DD** tick-a-tick.
- Validação/robustez: evitar look-ahead, slippage realista, invariantes fortes.

### O que o QTradeX entrega (pelas fontes do repo)
- Framework Python para backtest/otimização e “deploy” focado em **100+ exchanges via CCXT**.
- Não há menções explícitas a: **tick data**, **bid/ask**, **slippage**, **Forex/XAUUSD/MT5** no README.
- *Roadmap*: “TradFi connectors: Stocks, Forex, and Comex support” (não implementado).

**Conclusão de fit:** incompatível como runtime/backtest para nossa realidade (XAUUSD/Apex). No máximo, serve como inspiração de ideias (ex.: estrutura de CLI, heurísticas de otimização), sem incorporar código.

## 3) Sinais de maturidade/manutenção
- Projeto relativamente novo, com releases recentes (GitHub indica release em 2025).
- Comunidade pequena (poucos contribuidores). Isso aumenta risco de comportamento não documentado e regressões.

## 4) Licença (red flag)
- `setup.py` declara `license="MIT"`.
- `LICENSE` é um texto no estilo **WTFPL/paródia**.

**Risco:** ambiguidade pode bloquear uso corporativo/prop (compliance) e cria incerteza de direitos. Antes de qualquer adoção, precisaria de clarificação explícita do autor (e idealmente correção no repo).

## 5) Supply-chain / CI (GitHub Actions)
- Workflow de publish identificado: `.github/workflows/publish.yml`.
- **Boas práticas observadas:** permissões restritas (`contents: read`), publicação via OIDC (`id-token: write`) para PyPI.
- **Risco médio:** actions não estão “pinned” por SHA (ex.: `actions/checkout@v4`), o que é comum mas não ideal.

## 6) Fastest disproof test (≤ 1 hora)
Objetivo: provar (ou refutar) que o QTradeX suporta semântica mínima para XAUUSD/Apex.

1) **Scan de escopo** (se não aparecer nada, encerrar):
   - procurar termos: `MetaTrader`, `MT5`, `forex`, `XAUUSD`, `bid`, `ask`, `tick`, `slippage`, `FIX`.
2) Se aparecer algo convincente:
   - spike mínimo: ingerir um pequeno slice do nosso parquet tick e validar invariantes:
     - PnL sensível a spread (bid/ask),
     - slippage configurável,
     - timezone e time-gates ET possíveis.
   - Se falhar em qualquer um → descartar.

## 7) Decisão
**NO-GO** para integrar ao nosso stack Nautilus.

**Ação recomendada:** manter nosso pipeline único (Nautilus + scripts internos). Se a motivação era “otimização/backtest mais rápido”, implementamos isso dentro do nosso `nautilus_gold_scalper/scripts/` para não duplicar motor de simulação.

## 8) Addendum — repo de estratégias/AI Agents (QTradeX-AI-Agents)
### O que é
- Repo: https://github.com/squidKid-deluxe/QTradeX-AI-Agents
- Conteúdo: coleção de *estratégias/bots* em Python (arquivos `.py` na raiz) para rodar em cima do SDK QTradeX.
- Estrutura: flat (muitos arquivos `.py` no root) + pasta `tunes/`.

### Fit com nosso projeto
- Não há evidência (README/API listing) de suporte real a **XAUUSD/MT5**, **tick**, **bid/ask**, **slippage**, ou regras **Apex**.
- Estratégias parecem ser majoritariamente “indicator bots” (EMA/RSI/MACD/Ichimoku/Renko etc.) orientadas a **candle trading**.

**Conclusão:** útil apenas como **referência/inspiração** de ideias de sinais/combinações de indicadores; não como componente reutilizável no nosso runtime/backtest.

### Red flags
- Licença também aparece como **WTFPL/paródia** (risco jurídico/compliance).
- Repo parece pouco ativo (último push em 2025-05, conforme API).

### Fastest disproof test (≤ 30 min)
- Verificar se qualquer bot menciona explicitamente `forex`, `XAUUSD`, `bid`, `ask`, `tick`, `slippage`.
- Se não existir nada → considerar 100% “crypto/candle indicator bots” → descartar para integração.

## Referências (fontes)
- QTradeX SDK repo: https://github.com/squidKid-deluxe/QTradeX-Algo-Trading-SDK
- QTradeX SDK README (raw): https://raw.githubusercontent.com/squidKid-deluxe/QTradeX-Algo-Trading-SDK/master/README.md
- QTradeX SDK setup.py (raw): https://raw.githubusercontent.com/squidKid-deluxe/QTradeX-Algo-Trading-SDK/master/setup.py
- QTradeX SDK LICENSE (raw): https://raw.githubusercontent.com/squidKid-deluxe/QTradeX-Algo-Trading-SDK/master/LICENSE
- QTradeX SDK publish workflow (raw): https://raw.githubusercontent.com/squidKid-deluxe/QTradeX-Algo-Trading-SDK/master/.github/workflows/publish.yml
- QTradeX AI Agents repo: https://github.com/squidKid-deluxe/QTradeX-AI-Agents
- QTradeX AI Agents README (raw): https://raw.githubusercontent.com/squidKid-deluxe/QTradeX-AI-Agents/master/README.md
- QTradeX AI Agents LICENSE (raw): https://raw.githubusercontent.com/squidKid-deluxe/QTradeX-AI-Agents/master/LICENSE
