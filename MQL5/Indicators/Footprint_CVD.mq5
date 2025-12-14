//+------------------------------------------------------------------+
//|                                                Footprint_CVD.mq5 |
//|                          EA_SCALPER_XAUUSD - Visual Indicators   |
//|                                                                  |
//|  Cumulative Volume Delta - Linha cumulativa                      |
//|  Subindo = Compradores acumulando                                |
//|  Descendo = Vendedores acumulando                                |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1

// Plot: CVD Line
#property indicator_label1  "CVD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

// Inputs
input int      InpBarsToCalculate = 500;    // Barras para calcular
input bool     InpResetDaily      = true;   // Reset diario do CVD

// Buffers
double g_cvd[];
double g_delta[];

// Variaveis globais
datetime g_lastResetDay = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                          |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, g_cvd, INDICATOR_DATA);
   SetIndexBuffer(1, g_delta, INDICATOR_CALCULATIONS);
   
   ArraySetAsSeries(g_cvd, true);
   ArraySetAsSeries(g_delta, true);
   
   IndicatorSetString(INDICATOR_SHORTNAME, "FP CVD");
   IndicatorSetInteger(INDICATOR_DIGITS, 0);
   
   // Nivel zero
   IndicatorSetInteger(INDICATOR_LEVELS, 1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, 0.0);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR, 0, clrGray);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE, 0, STYLE_DOT);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Processa ticks de uma barra e retorna delta                       |
//+------------------------------------------------------------------+
long CalculateBarDelta(int barIndex)
{
   datetime barTime = iTime(_Symbol, _Period, barIndex);
   int barSeconds = PeriodSeconds(_Period);
   datetime barEnd = barTime + barSeconds;
   
   MqlTick ticks[];
   int copied = CopyTicksRange(_Symbol, ticks, COPY_TICKS_ALL,
                               barTime * 1000, barEnd * 1000);
   
   if(copied <= 0)
      return 0;
   
   long delta = 0;
   double lastPrice = 0;
   
   for(int i = 0; i < copied; i++)
   {
      double price = (ticks[i].last > 0) ? ticks[i].last : ticks[i].bid;
      long vol = (ticks[i].volume > 0) ? (long)ticks[i].volume : 1;
      
      int direction = 0;
      
      bool hasBuy = (ticks[i].flags & TICK_FLAG_BUY) != 0;
      bool hasSell = (ticks[i].flags & TICK_FLAG_SELL) != 0;
      
      if(hasBuy && !hasSell)
         direction = 1;
      else if(hasSell && !hasBuy)
         direction = -1;
      else if(ticks[i].ask > 0 && ticks[i].bid > 0)
      {
         double mid = (ticks[i].bid + ticks[i].ask) / 2;
         direction = (price >= mid) ? 1 : -1;
      }
      else if(lastPrice > 0)
      {
         if(price > lastPrice) direction = 1;
         else if(price < lastPrice) direction = -1;
      }
      
      delta += direction * vol;
      lastPrice = price;
   }
   
   return delta;
}

//+------------------------------------------------------------------+
//| Verifica se e novo dia                                            |
//+------------------------------------------------------------------+
bool IsNewDay(datetime t1, datetime t2)
{
   MqlDateTime dt1, dt2;
   TimeToStruct(t1, dt1);
   TimeToStruct(t2, dt2);
   return (dt1.day != dt2.day || dt1.mon != dt2.mon || dt1.year != dt2.year);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                               |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   ArraySetAsSeries(time, true);
   
   int limit = rates_total - prev_calculated;
   if(limit <= 0) limit = 1;
   
   if(limit > InpBarsToCalculate)
      limit = InpBarsToCalculate;
   
   // Calcula de tras pra frente para acumular corretamente
   // Primeiro: calcula deltas individuais
   for(int i = limit - 1; i >= 0 && i < rates_total; i--)
   {
      g_delta[i] = (double)CalculateBarDelta(i);
   }
   
   // Segundo: acumula CVD (da barra mais antiga para mais recente)
   for(int i = limit - 1; i >= 0; i--)
   {
      if(i >= rates_total - 1)
      {
         // Primeira barra
         g_cvd[i] = g_delta[i];
      }
      else
      {
         // Reset diario?
         if(InpResetDaily && IsNewDay(time[i], time[i + 1]))
         {
            g_cvd[i] = g_delta[i];
         }
         else
         {
            g_cvd[i] = g_cvd[i + 1] + g_delta[i];
         }
      }
   }
   
   return(rates_total);
}
//+------------------------------------------------------------------+
