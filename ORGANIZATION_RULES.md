# 📋 REGRAS DE ORGANIZAÇÃO - PROJETO TRADING

## 🎯 SISTEMA DE NOMENCLATURA RIGOROSO

### PADRÃO OBRIGATÓRIO:
```
[TIPO]_[NOME]v[VERSAO][ESPECIFICO].[EXT]
```

### EXEMPLOS CORRETOS:
✅ `EA_OrderBlocks_v2.1_XAUUSD_FTMO.mq5`
✅ `IND_VolumeFlow_v1.3_SMC_Multi.mq4`
✅ `SCR_RiskCalculator_v1.0_FTMO.mq5`
✅ `STR_Scalper_v2.0_Backtest.pine`

### PREFIXOS OBRIGATÓRIOS:
- **EA_**: Expert Advisors
- **IND_**: Indicators
- **SCR_**: Scripts
- **STR_**: Strategies (TradingView)
- **LIB_**: Libraries/Functions

## 📁 ESTRUTURA DE PASTAS

### MQL4_Source/:
- **EAs/**: Scalping, Grid_Martingale, Trend_Following, Others
- **Indicators/**: SMC_ICT, Volume, Trend, Custom
- **Scripts/**: Utilities, Analysis

### MQL5_Source/:
- **EAs/**: FTMO_Ready, Advanced_Scalping, Multi_Symbol, Others
- **Indicators/**: Order_Blocks, Volume_Flow, Market_Structure, Custom
- **Scripts/**: Risk_Tools, Analysis_Tools

### TradingView_Scripts/:
- **Indicators/**: SMC_Concepts, Volume_Analysis, Custom_Plots
- **Strategies/**: Backtesting, Alert_Systems
- **Libraries/**: Pine_Functions

## 🏷️ SISTEMA DE TAGS

### TAGS PRINCIPAIS:
- `#ftmo` `#xauusd` `#scalping` `#orderblocks` `#smc`
- `#lowrisk` `#conservative` `#grid` `#martingale` `#recovery`
- `#aggressive` `#highrisk` `#trend` `#momentum` `#breakout`
- `#volume` `#institutional` `#smartmoney` `#flow`

## ✅ CHECKLIST DE QUALIDADE

### OBRIGATÓRIO para cada arquivo:
□ Nome segue padrão rigoroso
□ Pasta correta por estratégia/tipo
□ Entry criado no INDEX apropriado
□ Tags relevantes adicionadas
□ Status de teste indicado
□ Descrição clara e concisa
□ Compatibilidade FTMO indicada

## 🎯 PRIORIDADES

### ALTA PRIORIDADE:
1. EAs compatíveis FTMO
2. Order Blocks/SMC indicators
3. Volume Flow analysis tools
4. Risk management scripts

### MÉDIA PRIORIDADE:
1. Scalping systems gerais
2. Trend following EAs
3. Custom indicators

### BAIXA PRIORIDADE:
1. Grid/Martingale systems
2. Experimental codes
3. Obsolete versions

## 🔒 POLÍTICAS DE SEGURANÇA

### REGRA ABSOLUTA: NUNCA DELETAR
- ❌ **PROIBIDO**: Deletar qualquer arquivo durante organização
- ✅ **PERMITIDO**: Apenas mover e renomear
- 🛡️ **PROTEÇÃO**: Preservar integridade dos dados sempre

### RESOLUÇÃO DE CONFLITOS DE NOME
```
Se arquivo já existe no destino:
1. Manter arquivo original intocado
2. Adicionar sufixo ao novo arquivo: _1, _2, _3...
3. Exemplo: EA_Scalper_v1.0_XAUUSD.mq4 -> EA_Scalper_v1.0_XAUUSD_1.mq4
```

### LOG OBRIGATÓRIO
- 📝 Registrar TODAS as operações no CHANGELOG.md
- ⏰ Timestamp de cada ação
- 📍 Caminho origem e destino
- 🔧 Resolução de conflitos aplicada

---
*Agente Organizador - Padrão Profissional*
*Política de Segurança: ZERO PERDA DE DADOS*