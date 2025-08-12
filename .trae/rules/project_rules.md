# Regras de Classificação e Organização

## 1. Pastas Destino (Primárias)

- MQL4_Source/EAs/Scalping  
- MQL4_Source/EAs/Grid_Martingale  
- MQL4_Source/EAs/Trend_Following  
- MQL4_Source/Indicators/SMC_ICT  
- MQL4_Source/Indicators/Volume  
- MQL4_Source/Indicators/Trend  
- MQL4_Source/Indicators/Custom  
- MQL4_Source/Scripts/Utilities  
- MQL4_Source/Scripts/Analysis  

- MQL5_Source/EAs/FTMO_Ready  
- MQL5_Source/EAs/Advanced_Scalping  
- MQL5_Source/EAs/Multi_Symbol  
- MQL5_Source/EAs/Others  
- MQL5_Source/Indicators/Order_Blocks  
- MQL5_Source/Indicators/Volume_Flow  
- MQL5_Source/Indicators/Market_Structure  
- MQL5_Source/Indicators/Custom  
- MQL5_Source/Scripts/Risk_Tools  
- MQL5_Source/Scripts/Analysis_Tools  

- TradingView_Scripts/Pine_Script_Source/Indicators/SMC_Concepts  
- TradingView_Scripts/Pine_Script_Source/Indicators/Volume_Analysis  
- TradingView_Scripts/Pine_Script_Source/Indicators/Custom_Plots  
- TradingView_Scripts/Pine_Script_Source/Strategies/Backtesting  
- TradingView_Scripts/Pine_Script_Source/Strategies/Alert_Systems  
- TradingView_Scripts/Pine_Script_Source/Libraries/Pine_Functions  

## 2. Fallback “Misc”

Se nenhum padrão rígido for detectado, mover para:

- `…/EAs/Misc/`, `…/Indicators/Misc/`, `…/Scripts/Misc/`, `…/Strategies/Misc/`

## 3. Criação de Novas Categorias

- Se ≥5 arquivos com mesmo padrão não previsto, criar subpasta (ex.: `EAs/News_Trading`).

## 4. Decisão de Tipo

- **EA**: contém `OnTick()` + `OrderSend()` ou `trade.Buy/Sell()`.  
- **Indicator**: contém `OnCalculate()` ou `SetIndexBuffer()`.  
- **Script**: contém apenas `OnStart()`.  
- **Pine**: contém `study()` ou `strategy()`.

## 5. Estratégias (keywords)

- **Scalping**: `scalp`, `M1`, `M5`  
- **Grid_Martingale**: `grid`, `martingale`, `recovery`  
- **SMC/ICT**: `order_block`, `liquidity`, `institutional`  
- **Trend_Following**: `trend`, `momentum`, `MA`  
- **Volume_Analysis**: `volume`, `OBV`, `flow`  

## 6. FTMO Compliance

- **FTMO_Ready**: presença de risk management, stop loss, drawdown checks.  
- **Não_FTMO**: grid/martingale sem proteções.

## 7. Nomenclatura

- [PREFIX]_[NAME]v[MAJOR.MINOR][MARKET].[EXT]
- Prefixos: EA, IND, SCR, STR, LIB

## 8. Sistema de **Tags**

Para cada arquivo, adicionar tags extraídas do conteúdo:

- **Tipo**: `#EA`, `#Indicator`, `#Script`, `#Pine`  
- **Estratégia**: `#Scalping`, `#Grid_Martingale`, `#SMC`, `#Trend`, `#Volume`  
- **Mercado**: `#Forex`, `#XAUUSD`, `#Indices`, `#Crypto`  
- **Timeframe**: `#M1`, `#M5`, `#M15`, `#H1`, `#H4`, `#D1`  
- **FTMO**: `#FTMO_Ready`, `#LowRisk`, `#Conservative`  
- **Extras**: `#News_Trading`, `#AI`, `#ML`, `#Backtest`

Exemplo de metadata no índice:

- EA_OrderBlocks_v2.1_XAUUSD_FTMO.mq5
Tags: #EA #SMC #Order_Blocks #XAUUSD #M15 #FTMO_Ready #LowRisk

## 9. Checklist de Qualidade

- [ ] Pasta destino correta  
- [ ] Nome segue convenção  
- [ ] Tags completas adicionadas  
- [ ] Entry criada no índice  
- [ ] Status de teste anotado  
- [ ] Nova categoria sugerida se necessário  
