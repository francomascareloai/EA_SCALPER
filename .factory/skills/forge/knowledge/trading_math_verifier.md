# FORGE Knowledge: Trading Math Verifier

> Checklist matematico para verificar CORRETUDE de formulas de trading.
> Um GENIO verifica a matematica, nao apenas a sintaxe.

---

## 1. Position Sizing (Calculo de Lote)

### Formula Padrao
```
lot = risk_amount / (sl_pips * tick_value * point_factor)

Onde:
- risk_amount = equity * risk_percent / 100
- sl_pips = distancia do SL em pips
- tick_value = valor monetario de 1 tick
- point_factor = ajuste para diferentes ativos
```

### Checklist de Verificacao

```
□ 1. DIVISION BY ZERO GUARDS
   - tick_value pode ser 0 em mercado fechado?
   - sl_pips pode ser 0 se SL = entry?
   - Existe guard: if(tick_value <= 0 || sl_pips <= 0) return 0;

□ 2. EQUITY vs BALANCE
   - Usando AccountInfoDouble(ACCOUNT_EQUITY)?
   - NAO usando ACCOUNT_BALANCE (ignora posicoes abertas)

□ 3. NORMALIZACAO
   - NormalizeLot() aplicado ao resultado?
   - Verifica SYMBOL_VOLUME_STEP?
   - Arredonda para step correto?

□ 4. LIMITES
   - lot >= SYMBOL_VOLUME_MIN?
   - lot <= SYMBOL_VOLUME_MAX?
   - lot <= max_lot_configurado?

□ 5. REGIME MULTIPLIER
   - Regime RANDOM_WALK → lot * 0?
   - Regime NOISY → lot * 0.5?
   - Multiplier aplicado APOS normalizacao?

□ 6. MTF MULTIPLIER
   - Perfect alignment → 1.0?
   - Good alignment → 0.75?
   - Weak alignment → 0.5?
```

### Codigo de Referencia (CORRETO)
```mql5
double CalculateLotSize(double sl_points, double risk_percent) {
    // 1. Validar inputs
    if(sl_points <= 0) {
        Print("ERROR: SL points must be positive");
        return 0.0;
    }
    
    // 2. Obter valores de mercado
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);  // EQUITY, nao BALANCE!
    double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    
    // 3. Guards contra valores invalidos
    if(equity <= 0 || tick_value <= 0 || tick_size <= 0 || point <= 0) {
        Print("ERROR: Invalid market values");
        return 0.0;
    }
    
    // 4. Calcular risco em moeda
    double risk_amount = equity * risk_percent / 100.0;
    
    // 5. Calcular lot
    double tick_per_point = tick_size / point;
    double sl_ticks = sl_points / tick_per_point;
    double lot = risk_amount / (sl_ticks * tick_value);
    
    // 6. Normalizar
    double min_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double max_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    
    lot = MathFloor(lot / step) * step;  // Arredondar para baixo
    lot = MathMax(min_lot, MathMin(max_lot, lot));
    
    return NormalizeDouble(lot, 2);
}
// ✓ FORGE v3.1: Trading Math Verified
```

---

## 2. Drawdown Calculation

### Formula Padrao
```
daily_dd_percent = (daily_start_equity - current_equity) / daily_start_equity * 100
total_dd_percent = (peak_equity - current_equity) / peak_equity * 100
```

### Checklist de Verificacao

```
□ 1. HIGH-WATER MARK
   - peak_equity atualizado quando equity sobe?
   - if(current_equity > peak_equity) peak_equity = current_equity;

□ 2. DAILY RESET
   - daily_start_equity resetado em novo dia?
   - Usando hora do BROKER, nao local?

□ 3. DIVISION GUARDS
   - Guard: if(peak_equity <= 0) return 0.0;
   - Guard: if(daily_start <= 0) return 0.0;

□ 4. VALORES VALIDOS
   - DD sempre >= 0? (nunca negativo)
   - DD nunca > 100%?

□ 5. PERSISTENCIA
   - peak_equity salvo em GlobalVariable?
   - Sobrevive restart do MT5?

□ 6. USANDO EQUITY
   - NAO usando Balance (ignora floating P/L)
   - NAO usando FreeMargin
```

### Codigo de Referencia (CORRETO)
```mql5
double CalculateTotalDrawdown() {
    double current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
    
    // Guard contra valores invalidos
    if(current_equity <= 0) return 0.0;
    
    // Atualizar high-water mark
    if(current_equity > m_peakEquity) {
        m_peakEquity = current_equity;
        // Persistir
        GlobalVariableSet(GV_PEAK_EQUITY, m_peakEquity);
    }
    
    // Guard contra peak invalido
    if(m_peakEquity <= 0) return 0.0;
    
    // Calcular DD
    double dd = (m_peakEquity - current_equity) / m_peakEquity * 100.0;
    
    // Garantir valor valido
    return MathMax(0.0, MathMin(100.0, dd));
}
// ✓ FORGE v3.1: Trading Math Verified
```

---

## 3. Stop Loss Calculation

### Formula Padrao
```
Para BUY:  sl = entry_price - (atr * multiplier)
Para SELL: sl = entry_price + (atr * multiplier)
```

### Checklist de Verificacao

```
□ 1. DIRECAO CORRETA
   - BUY: SL ABAIXO do entry
   - SELL: SL ACIMA do entry
   - Validacao: if(type==BUY && sl >= entry) ERROR

□ 2. ATR VALIDO
   - Handle de ATR != INVALID_HANDLE?
   - CopyBuffer retornou > 0?
   - ATR > 0?

□ 3. LIMITES DE SL
   - SL >= minimo (ex: 15 pips para XAUUSD)?
   - SL <= maximo (ex: 50 pips para scalping)?

□ 4. STOPS LEVEL
   - Distancia >= SYMBOL_TRADE_STOPS_LEVEL?
   - Distancia >= SYMBOL_TRADE_FREEZE_LEVEL?

□ 5. NORMALIZACAO
   - SL normalizado com NormalizeDouble(_Digits)?
```

### Codigo de Referencia (CORRETO)
```mql5
double CalculateStopLoss(ENUM_ORDER_TYPE type, double entry, double atr) {
    // 1. Validar ATR
    if(atr <= 0) {
        Print("ERROR: Invalid ATR");
        return 0.0;
    }
    
    // 2. Obter limites do broker
    int stops_level = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    double min_distance = stops_level * point;
    
    // 3. Calcular SL baseado em ATR
    double sl_distance = atr * InpATRMultiplier;
    
    // 4. Aplicar limites
    sl_distance = MathMax(sl_distance, InpMinSL * point);  // Minimo
    sl_distance = MathMin(sl_distance, InpMaxSL * point);  // Maximo
    sl_distance = MathMax(sl_distance, min_distance);      // Broker limit
    
    // 5. Calcular preco do SL com DIRECAO CORRETA
    double sl;
    if(type == ORDER_TYPE_BUY) {
        sl = entry - sl_distance;  // SL ABAIXO para BUY
    } else {
        sl = entry + sl_distance;  // SL ACIMA para SELL
    }
    
    // 6. Validacao final
    if(type == ORDER_TYPE_BUY && sl >= entry) {
        Print("ERROR: SL above entry for BUY!");
        return 0.0;
    }
    if(type == ORDER_TYPE_SELL && sl <= entry) {
        Print("ERROR: SL below entry for SELL!");
        return 0.0;
    }
    
    return NormalizeDouble(sl, _Digits);
}
// ✓ FORGE v3.1: Trading Math Verified
```

---

## 4. Take Profit Calculation

### Formula Padrao
```
Para BUY:  tp = entry + (sl_distance * rr_ratio)
Para SELL: tp = entry - (sl_distance * rr_ratio)

Onde: sl_distance = |entry - sl|
```

### Checklist de Verificacao

```
□ 1. DIRECAO CORRETA
   - BUY: TP ACIMA do entry
   - SELL: TP ABAIXO do entry

□ 2. R:R RATIO
   - R:R >= minimo (ex: 1.5)?
   - R:R realista (ex: <= 5.0)?

□ 3. DISTANCIA VALIDA
   - TP distance > SL distance? (positivo expectancy)
   - TP dentro de range realista?

□ 4. STOPS LEVEL
   - Distancia >= SYMBOL_TRADE_STOPS_LEVEL?
```

---

## 5. Kelly Criterion

### Formula Padrao
```
f* = (W * R - L) / R

Onde:
- W = win rate (0.0 a 1.0)
- L = loss rate (1 - W)
- R = ratio avg_win / avg_loss
- f* = fracao otima do capital
```

### Checklist de Verificacao

```
□ 1. INPUTS VALIDOS
   - 0 < W < 1?
   - R > 0?
   - avg_loss != 0?

□ 2. FRACTIONAL KELLY
   - Usando f* / 2 ou f* / 4? (mais conservador)
   - Full Kelly e MUITO agressivo!

□ 3. DADOS SUFICIENTES
   - W e R calculados de >= 30 trades?
   - Dados do MESMO sistema/mercado?

□ 4. LIMITES
   - f* limitado a max (ex: 2%)?
   - f* >= 0 (nunca negativo)?
```

### Codigo de Referencia (CORRETO)
```mql5
double CalculateKellyFraction(double win_rate, double avg_win, double avg_loss) {
    // 1. Validar inputs
    if(win_rate <= 0 || win_rate >= 1) return 0.0;
    if(avg_win <= 0 || avg_loss <= 0) return 0.0;
    
    // 2. Calcular R (payoff ratio)
    double R = avg_win / avg_loss;
    
    // 3. Calcular Kelly
    double L = 1.0 - win_rate;
    double kelly = (win_rate * R - L) / R;
    
    // 4. Fractional Kelly (mais seguro)
    kelly = kelly / 2.0;  // Half Kelly
    
    // 5. Limitar
    kelly = MathMax(0.0, MathMin(kelly, 0.02));  // Max 2%
    
    return kelly;
}
// ✓ FORGE v3.1: Trading Math Verified
```

---

## 6. Profit Factor

### Formula Padrao
```
PF = gross_profit / gross_loss

Interpretacao:
- PF < 1.0: Sistema perdedor
- PF = 1.0: Break-even
- PF > 1.5: Sistema bom
- PF > 2.0: Sistema excelente
```

### Checklist de Verificacao

```
□ 1. DIVISION GUARD
   - if(gross_loss == 0) return INFINITY ou valor especial

□ 2. VALORES ABSOLUTOS
   - gross_loss sempre positivo? (usar MathAbs)

□ 3. INCLUIR CUSTOS
   - Spread incluido?
   - Comissao incluida?
   - Swap incluido?
```

---

## 7. Expectancy (Esperanca Matematica)

### Formula Padrao
```
E = (W * avg_win) - (L * avg_loss)

Onde:
- W = win rate
- L = 1 - W
- avg_win = media dos ganhos
- avg_loss = media das perdas (valor positivo)
```

### Checklist de Verificacao

```
□ 1. E > 0?
   - Se E <= 0, sistema nao tem edge

□ 2. SAMPLE SIZE
   - Calculado com >= 30 trades?
   - Preferivelmente >= 100 trades

□ 3. R-MULTIPLE
   - Converter para R-multiple: E_r = E / avg_loss
   - E_r > 0.2R e bom
   - E_r > 0.5R e excelente
```

---

## Quick Reference: Formulas Criticas

| Formula | Cuidados |
|---------|----------|
| `lot = risk / (sl * tick)` | Division guards, NormalizeLot |
| `dd = (peak - curr) / peak` | High-water mark, EQUITY |
| `sl_buy = entry - distance` | Direcao, limits, stops_level |
| `tp_buy = entry + (sl_dist * rr)` | R:R >= 1.5, direcao |
| `kelly = (W*R - L) / R` | Fractional, max limit |
| `pf = profit / loss` | Division guard |
| `E = W*win - L*loss` | Must be > 0 |

---

## Quando Usar Este Checklist

FORGE DEVE verificar matematica quando:

1. Implementar QUALQUER formula de position sizing
2. Implementar QUALQUER calculo de drawdown
3. Implementar QUALQUER logica de SL/TP
4. Review de codigo de Risk Management
5. Corrigir bugs em modulos de risco

**MARK WHEN VERIFIED:**
```mql5
// ✓ FORGE v3.1: Trading Math Verified
// Checklist: Position Sizing [x], DD Calc [x], SL/TP [x]
```
