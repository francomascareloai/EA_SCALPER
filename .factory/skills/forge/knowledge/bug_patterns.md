# FORGE Knowledge: Bug Patterns

> Condensado do BUGFIX_LOG.md - Consultar ANTES de modificar modulos similares

---

## BP-01: Off-by-One em Imbalance Diagonal

**Modulo**: CFootprintAnalyzer.mqh
**Erro**: Buy imbalance comparava nivel i+1 vs i (errado)
**Correto**: Ask[i] vs Bid[i-1] (diagonal ATAS style)

```mql5
// ERRADO (off-by-one)
bool buyImb = (askVol[i+1] / bidVol[i]) >= 3.0;

// CORRETO
bool buyImb = (askVol[i] / bidVol[i-1]) >= 3.0;
```

**Quando suspeitar**: Qualquer comparacao diagonal entre niveis de preco.

---

## BP-02: ATR Handle Nao Validado

**Modulo**: CFootprintAnalyzer, CTradeManager, outros
**Erro**: Usar handle de ATR sem verificar se criou corretamente

```mql5
// ERRADO
int handle = iATR(_Symbol, tf, 14);
double atr[];
CopyBuffer(handle, 0, 0, 1, atr);  // CRASH se handle invalido!

// CORRETO
int handle = iATR(_Symbol, tf, 14);
if(handle == INVALID_HANDLE) {
    Print("ERROR: Failed to create ATR handle");
    return false;
}
double atr[];
ArraySetAsSeries(atr, true);
if(CopyBuffer(handle, 0, 0, 1, atr) <= 0) {
    Print("ERROR: CopyBuffer failed");
    return false;
}
```

**Quando suspeitar**: QUALQUER criacao de indicador (iATR, iRSI, etc).

---

## BP-03: Bias Calculado Apos Breaks (Ordem Errada)

**Modulo**: CStructureAnalyzer.mqh
**Erro**: Classificar BOS/CHoCH usando o bias ANTES de recalcular

```mql5
// ERRADO - bias antigo usado para classificar quebra nova
DetectBreaks();  // Usa bias antigo
CalculateBias(); // Recalcula depois (tarde demais!)

// CORRETO - bias primeiro
CalculateBias(); // Atualiza bias
DetectBreaks();  // Usa bias correto
CalculateBias(); // Recalcula apos quebras
```

**Quando suspeitar**: Sequencia de operacoes que dependem de estado.

---

## BP-04: Heuristica de OB Inflando Confluencia

**Modulo**: CMTFManager.mqh
**Erro**: Marcar OB/FVG apenas por BOS (heuristica, nao real)

```mql5
// ERRADO - inflava confluencia falsamente
if(bos_detected) {
    m_mtfAnalysis.has_ob_zone = true;  // Heuristica!
}

// CORRETO - usar apenas flags dos detectors reais
m_mtfAnalysis.has_ob_zone = m_obDetector.HasValidOB();
m_mtfAnalysis.has_fvg_zone = m_fvgDetector.HasValidFVG();
```

**Quando suspeitar**: Qualquer "atalho" para preencher estruturas.

---

## BP-05: Division by Zero em Equity Checks

**Modulo**: FTMO_RiskManager.mqh
**Erro**: Dividir por equity sem verificar se > 0

```mql5
// ERRADO
double dd_percent = (peak - current) / peak * 100.0;  // CRASH se peak == 0!

// CORRETO
double dd_percent = 0.0;
if(peak > 0.0)
    dd_percent = (peak - current) / peak * 100.0;
```

**Quando suspeitar**: QUALQUER divisao, especialmente com valores financeiros.

---

## BP-06: SL/TP Direcao Invalida

**Modulo**: CTradeManager.mqh, TradeExecutor.mqh
**Erro**: Colocar SL acima de entry em BUY (ou abaixo em SELL)

```mql5
// ERRADO - sem validacao
request.sl = sl_price;
request.tp = tp_price;

// CORRETO - validar direcao
if(type == ORDER_TYPE_BUY) {
    if(sl_price >= entry_price) {
        Print("ERROR: SL must be BELOW entry for BUY");
        return false;
    }
    if(tp_price <= entry_price) {
        Print("ERROR: TP must be ABOVE entry for BUY");
        return false;
    }
}
```

**Quando suspeitar**: Qualquer codigo que define SL/TP.

---

## BP-07: Spread/Freeze Distance Ignorados

**Modulo**: TradeExecutor.mqh
**Erro**: Enviar ordem sem verificar spread e freeze level

```mql5
// ERRADO - ignorar limites do broker
OrderSend(request, result);

// CORRETO - preflight checks
double spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
double freeze = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);
double stops = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);

if(spread > InpMaxSpread) {
    Print("ERROR: Spread too high: ", spread);
    return false;
}

double sl_distance = MathAbs(entry - sl) / _Point;
if(sl_distance < stops) {
    Print("ERROR: SL too close, min: ", stops);
    return false;
}
```

**Quando suspeitar**: Qualquer OrderSend, OrderModify.

---

## BP-08: Requote/Price Changed Sem Retry

**Modulo**: TradeExecutor.mqh
**Erro**: Falhar permanentemente em requote ao inves de retry

```mql5
// ERRADO - falha permanente
if(!OrderSend(request, result)) {
    Print("OrderSend failed");
    return false;
}

// CORRETO - retry com RefreshRates
int attempts = 3;
while(attempts > 0) {
    if(OrderSend(request, result)) {
        if(result.retcode == TRADE_RETCODE_DONE)
            return true;
    }
    
    int err = GetLastError();
    if(err == ERR_REQUOTE || err == ERR_PRICE_CHANGED) {
        RefreshRates();
        // Atualizar precos na request
        request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
        attempts--;
        continue;
    }
    break;  // Erro nao recuperavel
}
return false;
```

**Quando suspeitar**: OrderSend, OrderModify durante volatilidade.

---

## BP-09: High-Water Mark Nao Usado para DD

**Modulo**: FTMO_RiskManager.mqh
**Erro**: Calcular Total DD usando balance inicial, nao peak

```mql5
// ERRADO - DD calculado do inicio
double dd = (initial_balance - current_equity) / initial_balance;

// CORRETO - usar high-water mark (peak)
if(current_equity > m_peakEquity)
    m_peakEquity = current_equity;

double dd = (m_peakEquity - current_equity) / m_peakEquity;
```

**Quando suspeitar**: Qualquer calculo de drawdown.

---

## BP-10: GlobalVariable Nao Persistido

**Modulo**: FTMO_RiskManager.mqh
**Erro**: Perder daily start equity em restart do MT5

```mql5
// ERRADO - perde em restart
static double g_dailyStartEquity = 0;

void OnInit() {
    g_dailyStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
}

// CORRETO - persistir via GlobalVariable
void OnInit() {
    string gv_name = "EA_DAILY_START_" + IntegerToString(InpMagicNumber);
    if(GlobalVariableCheck(gv_name)) {
        g_dailyStartEquity = GlobalVariableGet(gv_name);
    } else {
        g_dailyStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
        GlobalVariableSet(gv_name, g_dailyStartEquity);
    }
}
```

**Quando suspeitar**: Estado que precisa sobreviver restart.

---

## BP-11: Momentum Sem Verificar Barras Disponiveis

**Modulo**: CMTFManager.mqh
**Erro**: Usar iClose com index fixo sem verificar se existe

```mql5
// ERRADO - assume que barra 5 existe
double momentum = iClose(_Symbol, PERIOD_M5, 0) - iClose(_Symbol, PERIOD_M5, 5);

// CORRETO - verificar disponibilidade
double closes[];
ArraySetAsSeries(closes, true);
if(CopyClose(_Symbol, PERIOD_M5, 0, 6, closes) < 6) {
    Print("ERROR: Not enough bars for momentum");
    return 0.0;
}
double momentum = closes[0] - closes[5];
```

**Quando suspeitar**: iClose, iHigh, iLow com index > 0.

---

## BP-12: Absorcao Classificada por Preco (Nao Delta)

**Modulo**: CFootprintAnalyzer.mqh
**Erro**: Classificar absorcao pela posicao do preco, nao pelo sinal do delta

```mql5
// ERRADO - heuristica por preco
if(close > open)
    absorption_type = BUY_ABSORPTION;
else
    absorption_type = SELL_ABSORPTION;

// CORRETO - classificar pelo sinal do delta
if(delta > 0)
    absorption_type = BUY_ABSORPTION;  // Compradores absorvendo vendedores
else
    absorption_type = SELL_ABSORPTION; // Vendedores absorvendo compradores
```

**Quando suspeitar**: Classificacao baseada em preco vs volume/delta.

---

## Tabela Resumo

| ID | Modulo | Tipo | Severidade |
|----|--------|------|------------|
| BP-01 | CFootprintAnalyzer | Off-by-one | ALTA |
| BP-02 | Varios | Handle invalido | CRITICA |
| BP-03 | CStructureAnalyzer | Ordem de operacoes | ALTA |
| BP-04 | CMTFManager | Heuristica falsa | MEDIA |
| BP-05 | FTMO_RiskManager | Division by zero | CRITICA |
| BP-06 | CTradeManager | Validacao SL/TP | ALTA |
| BP-07 | TradeExecutor | Spread/freeze | ALTA |
| BP-08 | TradeExecutor | Retry ausente | MEDIA |
| BP-09 | FTMO_RiskManager | DD calculation | CRITICA |
| BP-10 | FTMO_RiskManager | Persistencia | ALTA |
| BP-11 | CMTFManager | Bars check | MEDIA |
| BP-12 | CFootprintAnalyzer | Classificacao | MEDIA |

---

## Quando Consultar Este Arquivo

FORGE DEVE consultar este arquivo AUTOMATICAMENTE quando:

1. Modificar qualquer modulo listado acima
2. Escrever codigo com divisoes
3. Escrever codigo com handles de indicadores
4. Escrever codigo com OrderSend/OrderModify
5. Escrever codigo que calcula drawdown
6. Escrever codigo com comparacoes entre niveis de preco
