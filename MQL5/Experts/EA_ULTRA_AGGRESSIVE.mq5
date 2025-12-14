//+------------------------------------------------------------------+
//|                                          EA_ULTRA_AGGRESSIVE.mq5 |
//|                                                            Franco |
//|              ULTRA AGGRESSIVE v2.0 - COM FIBONACCI               |
//+------------------------------------------------------------------+
#property copyright "Franco"
#property version   "2.00"
#property strict
#property description "Ultra Aggressive v2.0 - Fibonacci + Auto-Adapt"

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>

//+------------------------------------------------------------------+
//| INPUTS                                                            |
//+------------------------------------------------------------------+
input group "=== RISCO ==="
input double   InpRiskPercent   = 2.0;      // Risco % por trade
input double   InpMaxDailyDD    = 15.0;     // Max DD diário % (para tudo)
input int      InpMaxTrades     = 20;       // Max trades por dia

input group "=== TRADE ==="
input double   InpSL_Points     = 150;      // Stop Loss (pontos XAUUSD = $1.50)
input double   InpTP_RR         = 2.0;      // Take Profit R:R
input int      InpMaxSpread     = 100;      // Max Spread (pontos)

input group "=== ESTRATÉGIA ==="
input int      InpFastMA        = 8;        // MA Rápida
input int      InpSlowMA        = 21;       // MA Lenta
input int      InpRSI_Period    = 14;       // RSI Período
input int      InpRSI_OB        = 70;       // RSI Overbought
input int      InpRSI_OS        = 30;       // RSI Oversold
input bool     InpUseRSI        = true;     // Usar filtro RSI

input group "=== FIBONACCI ==="
input bool     InpUseFibo       = true;     // Usar Fibonacci
input int      InpFiboLookback  = 50;       // Lookback para Swing Hi/Lo
input double   InpFiboZone      = 5.0;      // Tolerância zona Fibo (pontos)

input group "=== MAGIC ==="
input ulong    InpMagic         = 999999;   // Magic Number

//+------------------------------------------------------------------+
//| GLOBALS                                                           |
//+------------------------------------------------------------------+
CTrade         trade;
CPositionInfo  pos;
CAccountInfo   acc;
CSymbolInfo    sym;

int            h_fast_ma;
int            h_slow_ma;
int            h_rsi;
int            h_atr;

double         g_daily_start = 0;
int            g_trades_today = 0;
datetime       g_last_bar = 0;
datetime       g_current_day = 0;

// Fibonacci
double         g_fibo_382 = 0;
double         g_fibo_500 = 0;
double         g_fibo_618 = 0;
double         g_swing_high = 0;
double         g_swing_low = 0;

//+------------------------------------------------------------------+
//| INIT                                                              |
//+------------------------------------------------------------------+
int OnInit()
{
   if(!sym.Name(_Symbol))
   {
      Print("ERRO: Symbol inválido");
      return INIT_FAILED;
   }
   sym.Refresh();
   
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(100);
   trade.SetTypeFilling(ORDER_FILLING_IOC);
   
   // Indicadores
   h_fast_ma = iMA(_Symbol, PERIOD_M15, InpFastMA, 0, MODE_EMA, PRICE_CLOSE);
   h_slow_ma = iMA(_Symbol, PERIOD_M15, InpSlowMA, 0, MODE_EMA, PRICE_CLOSE);
   h_rsi = iRSI(_Symbol, PERIOD_M15, InpRSI_Period, PRICE_CLOSE);
   h_atr = iATR(_Symbol, PERIOD_M15, 14);
   
   if(h_fast_ma == INVALID_HANDLE || h_slow_ma == INVALID_HANDLE || 
      h_rsi == INVALID_HANDLE || h_atr == INVALID_HANDLE)
   {
      Print("ERRO: Não conseguiu criar indicadores");
      return INIT_FAILED;
   }
   
   g_daily_start = acc.Equity();
   
   Print("===========================================");
   Print("EA_ULTRA_AGGRESSIVE v2.0 + FIBONACCI");
   Print("Risco: ", InpRiskPercent, "%");
   Print("SL: ", InpSL_Points, " pontos | R:R: ", InpTP_RR);
   Print("Fibonacci: ", InpUseFibo ? "ON" : "OFF");
   Print("===========================================");
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| DEINIT                                                            |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(h_fast_ma != INVALID_HANDLE) IndicatorRelease(h_fast_ma);
   if(h_slow_ma != INVALID_HANDLE) IndicatorRelease(h_slow_ma);
   if(h_rsi != INVALID_HANDLE) IndicatorRelease(h_rsi);
   if(h_atr != INVALID_HANDLE) IndicatorRelease(h_atr);
   
   Print("EA_ULTRA_AGGRESSIVE v2.0 - Trades hoje: ", g_trades_today);
}

//+------------------------------------------------------------------+
//| TICK                                                              |
//+------------------------------------------------------------------+
void OnTick()
{
   // Novo dia?
   CheckNewDay();
   
   // Check DD
   if(CheckDailyDD())
   {
      Comment("DD MÁXIMO ATINGIDO - PARADO");
      return;
   }
   
   // Max trades
   if(g_trades_today >= InpMaxTrades)
   {
      Comment("Max trades atingido: ", g_trades_today);
      return;
   }
   
   // Nova barra?
   if(!IsNewBar())
      return;
   
   // Já tem posição?
   if(HasPosition())
   {
      Comment("Posição aberta - aguardando...");
      return;
   }
   
   // Spread ok?
   sym.Refresh();
   if(sym.Spread() > InpMaxSpread)
   {
      Comment("Spread alto: ", sym.Spread());
      return;
   }
   
   // GERAR SINAL
   int signal = GetSignal();
   
   if(signal != 0)
   {
      ExecuteTrade(signal);
   }
   else
   {
      Comment("Aguardando sinal... | Trades hoje: ", g_trades_today);
   }
}

//+------------------------------------------------------------------+
//| NOVA BARRA                                                        |
//+------------------------------------------------------------------+
bool IsNewBar()
{
   datetime current = iTime(_Symbol, PERIOD_M15, 0);
   if(current == g_last_bar)
      return false;
   g_last_bar = current;
   return true;
}

//+------------------------------------------------------------------+
//| NOVO DIA                                                          |
//+------------------------------------------------------------------+
void CheckNewDay()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   datetime today = StringToTime(StringFormat("%d.%02d.%02d", dt.year, dt.mon, dt.day));
   
   if(today != g_current_day)
   {
      g_current_day = today;
      g_daily_start = acc.Equity();
      g_trades_today = 0;
      Print("Novo dia - Reset | Equity: ", g_daily_start);
   }
}

//+------------------------------------------------------------------+
//| CHECK DD                                                          |
//+------------------------------------------------------------------+
bool CheckDailyDD()
{
   if(g_daily_start <= 0) return false;
   
   double dd = (g_daily_start - acc.Equity()) / g_daily_start * 100;
   
   if(dd >= InpMaxDailyDD)
   {
      Print("!!! DD MÁXIMO: ", dd, "% - TRADING PARADO !!!");
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| TEM POSIÇÃO                                                       |
//+------------------------------------------------------------------+
bool HasPosition()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(pos.SelectByIndex(i))
      {
         if(pos.Magic() == InpMagic && pos.Symbol() == _Symbol)
            return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| GERAR SINAL - COM FIBONACCI                                       |
//+------------------------------------------------------------------+
int GetSignal()
{
   // Pegar valores dos indicadores
   double fast[], slow[], rsi[];
   ArraySetAsSeries(fast, true);
   ArraySetAsSeries(slow, true);
   ArraySetAsSeries(rsi, true);
   
   if(CopyBuffer(h_fast_ma, 0, 0, 5, fast) < 5) return 0;
   if(CopyBuffer(h_slow_ma, 0, 0, 5, slow) < 5) return 0;
   if(CopyBuffer(h_rsi, 0, 0, 5, rsi) < 5) return 0;
   
   // Calcular Fibonacci
   CalcFibonacci();
   
   // Pegar preço atual
   double close[];
   ArraySetAsSeries(close, true);
   if(CopyClose(_Symbol, PERIOD_M15, 0, 3, close) < 3) return 0;
   double price = close[0];
   
   // Checar se está em zona Fibo
   int fibo_level = 0;
   bool at_fibo = IsAtFiboLevel(price, fibo_level);
   
   // Direção das MAs
   bool ma_bullish = fast[1] > slow[1];
   bool ma_bearish = fast[1] < slow[1];
   
   // Cruzamento de MAs
   bool cross_up = (fast[1] > slow[1]) && (fast[2] <= slow[2]);
   bool cross_down = (fast[1] < slow[1]) && (fast[2] >= slow[2]);
   
   // RSI
   bool rsi_ok_buy = !InpUseRSI || (rsi[1] < InpRSI_OB && rsi[1] > InpRSI_OS);
   bool rsi_ok_sell = !InpUseRSI || (rsi[1] > InpRSI_OS && rsi[1] < InpRSI_OB);
   
   // Oversold/Overbought para reversão
   bool rsi_oversold = rsi[1] < InpRSI_OS;
   bool rsi_overbought = rsi[1] > InpRSI_OB;
   
   int signal = 0;
   string reason = "";
   
   // === ESTRATÉGIA 1: Cruzamento de MA ===
   if(cross_up && rsi_ok_buy)
   {
      signal = 1;
      reason = "MA Cross UP";
   }
   else if(cross_down && rsi_ok_sell)
   {
      signal = -1;
      reason = "MA Cross DOWN";
   }
   
   // === ESTRATÉGIA 2: Fibonacci + Momentum ===
   if(signal == 0 && InpUseFibo && at_fibo)
   {
      // BUY: Preço no Fibo, MA bullish, RSI não overbought
      if(ma_bullish && !rsi_overbought && price < g_fibo_500)
      {
         signal = 1;
         reason = "FIBO " + IntegerToString(fibo_level) + " + MA Bull";
      }
      // SELL: Preço no Fibo, MA bearish, RSI não oversold
      else if(ma_bearish && !rsi_oversold && price > g_fibo_500)
      {
         signal = -1;
         reason = "FIBO " + IntegerToString(fibo_level) + " + MA Bear";
      }
   }
   
   // === ESTRATÉGIA 3: RSI Extremo + Fibo ===
   if(signal == 0 && InpUseFibo && at_fibo)
   {
      if(rsi_oversold && price <= g_fibo_618)
      {
         signal = 1;
         reason = "RSI Oversold + FIBO 618";
      }
      else if(rsi_overbought && price >= g_fibo_382)
      {
         signal = -1;
         reason = "RSI Overbought + FIBO 382";
      }
   }
   
   if(signal != 0)
   {
      Print(">>> SINAL ", (signal > 0 ? "BUY" : "SELL"), " | ", reason);
      Print("    Price=", price, " | Fast=", fast[1], " | Slow=", slow[1], " | RSI=", rsi[1]);
      if(InpUseFibo)
         Print("    Fibo: 382=", g_fibo_382, " | 500=", g_fibo_500, " | 618=", g_fibo_618);
   }
   
   return signal;
}

//+------------------------------------------------------------------+
//| EXECUTAR TRADE - CORRIGIDO                                        |
//+------------------------------------------------------------------+
void ExecuteTrade(int signal)
{
   sym.Refresh();
   sym.RefreshRates();
   
   double ask = sym.Ask();
   double bid = sym.Bid();
   double point = sym.Point();
   int digits = (int)sym.Digits();
   
   // Pegar ATR para SL dinâmico
   double atr[];
   ArraySetAsSeries(atr, true);
   if(CopyBuffer(h_atr, 0, 0, 3, atr) < 3)
   {
      Print("Erro ao copiar ATR");
      return;
   }
   
   // Calcular SL em preço (usar ATR ou pontos fixos, o que for maior)
   double sl_distance = MathMax(InpSL_Points * point, atr[0] * 1.5);
   double tp_distance = sl_distance * InpTP_RR;
   
   double entry_price, sl_price, tp_price;
   
   if(signal > 0) // BUY
   {
      entry_price = ask;
      sl_price = NormalizeDouble(entry_price - sl_distance, digits);
      tp_price = NormalizeDouble(entry_price + tp_distance, digits);
   }
   else // SELL
   {
      entry_price = bid;
      sl_price = NormalizeDouble(entry_price + sl_distance, digits);
      tp_price = NormalizeDouble(entry_price - tp_distance, digits);
   }
   
   // Validar stops
   double min_stop = sym.StopsLevel() * point;
   if(min_stop == 0) min_stop = 10 * point; // Default mínimo
   
   if(MathAbs(entry_price - sl_price) < min_stop)
   {
      sl_price = (signal > 0) ? entry_price - min_stop * 2 : entry_price + min_stop * 2;
      sl_price = NormalizeDouble(sl_price, digits);
   }
   
   if(MathAbs(entry_price - tp_price) < min_stop)
   {
      tp_price = (signal > 0) ? entry_price + min_stop * 2 : entry_price - min_stop * 2;
      tp_price = NormalizeDouble(tp_price, digits);
   }
   
   // Calcular lot
   double sl_points = MathAbs(entry_price - sl_price) / point;
   double lot = CalcLot(sl_points);
   
   // Log detalhado
   Print("=== EXECUTANDO TRADE ===");
   Print("Direção: ", (signal > 0 ? "BUY" : "SELL"));
   Print("Entry: ", entry_price, " | SL: ", sl_price, " | TP: ", tp_price);
   Print("SL Distance: ", sl_distance, " | TP Distance: ", tp_distance);
   Print("Lot: ", lot, " | ATR: ", atr[0]);
   
   // Executar
   bool ok = false;
   
   if(signal > 0)
      ok = trade.Buy(lot, _Symbol, 0, sl_price, tp_price, "ULTRA_BUY");
   else
      ok = trade.Sell(lot, _Symbol, 0, sl_price, tp_price, "ULTRA_SELL");
   
   if(ok && trade.ResultRetcode() == TRADE_RETCODE_DONE)
   {
      g_trades_today++;
      Print("*** TRADE OK! #", g_trades_today, " ***");
   }
   else
   {
      Print("ERRO: ", trade.ResultRetcode(), " - ", trade.ResultRetcodeDescription());
      Print("Check: Entry=", entry_price, " SL=", sl_price, " TP=", tp_price);
   }
}

//+------------------------------------------------------------------+
//| CALCULAR LOT                                                      |
//+------------------------------------------------------------------+
double CalcLot(double sl_points)
{
   if(sl_points <= 0) return sym.LotsMin();
   
   double equity = acc.Equity();
   double risk_money = equity * InpRiskPercent / 100.0;
   
   double tick_value = sym.TickValue();
   double tick_size = sym.TickSize();
   double point = sym.Point();
   
   if(tick_size == 0 || tick_value == 0) 
      return sym.LotsMin();
   
   // Para XAUUSD: tick_value é o valor de 1 tick (0.01) por 1 lote
   double value_per_point = tick_value * (point / tick_size);
   
   if(value_per_point == 0) return sym.LotsMin();
   
   double lot = risk_money / (sl_points * value_per_point);
   
   // Normalizar
   double lot_step = sym.LotsStep();
   lot = MathFloor(lot / lot_step) * lot_step;
   lot = MathMax(sym.LotsMin(), lot);
   lot = MathMin(sym.LotsMax(), lot);
   lot = NormalizeDouble(lot, 2);
   
   return lot;
}

//+------------------------------------------------------------------+
//| CALCULAR FIBONACCI                                                |
//+------------------------------------------------------------------+
void CalcFibonacci()
{
   if(!InpUseFibo) return;
   
   double highs[], lows[];
   ArraySetAsSeries(highs, true);
   ArraySetAsSeries(lows, true);
   
   if(CopyHigh(_Symbol, PERIOD_M15, 0, InpFiboLookback, highs) < InpFiboLookback) return;
   if(CopyLow(_Symbol, PERIOD_M15, 0, InpFiboLookback, lows) < InpFiboLookback) return;
   
   // Encontrar Swing High e Low
   g_swing_high = highs[0];
   g_swing_low = lows[0];
   
   for(int i = 1; i < InpFiboLookback; i++)
   {
      if(highs[i] > g_swing_high) g_swing_high = highs[i];
      if(lows[i] < g_swing_low) g_swing_low = lows[i];
   }
   
   double range = g_swing_high - g_swing_low;
   
   // Níveis Fibonacci (retracement)
   g_fibo_382 = g_swing_high - range * 0.382;
   g_fibo_500 = g_swing_high - range * 0.500;
   g_fibo_618 = g_swing_high - range * 0.618;
}

//+------------------------------------------------------------------+
//| CHECAR SE PREÇO ESTÁ EM ZONA FIBO                                 |
//+------------------------------------------------------------------+
bool IsAtFiboLevel(double price, int &fibo_level)
{
   if(!InpUseFibo) return true; // Se desativado, sempre OK
   
   double tolerance = InpFiboZone * sym.Point();
   
   // Checar proximidade aos níveis
   if(MathAbs(price - g_fibo_382) <= tolerance)
   {
      fibo_level = 382;
      return true;
   }
   if(MathAbs(price - g_fibo_500) <= tolerance)
   {
      fibo_level = 500;
      return true;
   }
   if(MathAbs(price - g_fibo_618) <= tolerance)
   {
      fibo_level = 618;
      return true;
   }
   
   fibo_level = 0;
   return false;
}

//+------------------------------------------------------------------+
//| ON TRADE                                                          |
//+------------------------------------------------------------------+
void OnTrade()
{
   // Log de trades fechados
   static int last_deals = 0;
   HistorySelect(0, TimeCurrent());
   int total = HistoryDealsTotal();
   
   if(total > last_deals)
   {
      for(int i = last_deals; i < total; i++)
      {
         ulong ticket = HistoryDealGetTicket(i);
         if(ticket > 0)
         {
            if(HistoryDealGetInteger(ticket, DEAL_MAGIC) == InpMagic)
            {
               int entry = (int)HistoryDealGetInteger(ticket, DEAL_ENTRY);
               if(entry == DEAL_ENTRY_OUT)
               {
                  double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
                  Print("Trade fechado: Profit = ", profit);
               }
            }
         }
      }
   }
   last_deals = total;
}
//+------------------------------------------------------------------+
