//+------------------------------------------------------------------+
//|                                              Footprint_Delta.mq5 |
//|                          EA_SCALPER_XAUUSD - Visual Indicators   |
//|                                                                  |
//|  Histograma de Delta Volume por barra                            |
//|  Verde = Delta positivo (compradores dominam)                    |
//|  Vermelho = Delta negativo (vendedores dominam)                  |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2

// Plot 1: Delta positivo (verde)
#property indicator_label1  "Delta+"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3

// Plot 2: Delta negativo (vermelho)
#property indicator_label2  "Delta-"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrCrimson
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3

// Inputs
input double   InpClusterSize     = 0.50;   // Cluster Size (pontos)
input int      InpBarsToCalculate = 500;    // Barras para calcular

// Buffers
double g_deltaPlus[];
double g_deltaMinus[];
double g_deltaRaw[];
double g_volume[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                          |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, g_deltaPlus, INDICATOR_DATA);
   SetIndexBuffer(1, g_deltaMinus, INDICATOR_DATA);
   SetIndexBuffer(2, g_deltaRaw, INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, g_volume, INDICATOR_CALCULATIONS);
   
   ArraySetAsSeries(g_deltaPlus, true);
   ArraySetAsSeries(g_deltaMinus, true);
   ArraySetAsSeries(g_deltaRaw, true);
   ArraySetAsSeries(g_volume, true);
   
   IndicatorSetString(INDICATOR_SHORTNAME, "FP Delta");
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

   if(barSeconds <= 0)
      return 0;

   ulong from_msc = (ulong)barTime * 1000ULL;
   ulong to_msc = (ulong)barEnd * 1000ULL;
   if(to_msc > 0)
      to_msc -= 1ULL; // avoid bar boundary bleed
   if(to_msc <= from_msc)
      return 0;

   MqlTick ticks[];
   int copied = CopyTicksRange(_Symbol, ticks, COPY_TICKS_ALL, from_msc, to_msc);

   if(copied <= 0)
      return 0;

   long delta = 0;
   double lastBid = 0.0;
   double lastAsk = 0.0;
   double lastTrade = 0.0;

   double clusterSize = InpClusterSize;
   if(clusterSize <= 0) clusterSize = 0.50;

   for(int i = 0; i < copied; i++)
   {
      const double bid = ticks[i].bid;
      const double ask = ticks[i].ask;
      const double last = ticks[i].last;

      long vol = (ticks[i].volume > 0) ? (long)ticks[i].volume : 1;

      int direction = 0;

      bool hasBuy = (ticks[i].flags & TICK_FLAG_BUY) != 0;
      bool hasSell = (ticks[i].flags & TICK_FLAG_SELL) != 0;

      if(hasBuy && !hasSell)
      {
         direction = 1;
      }
      else if(hasSell && !hasBuy)
      {
         direction = -1;
      }
      else if(last > 0 && bid > 0 && ask > 0)
      {
         // Prefer trade-price classification when available
         const double mid = (bid + ask) / 2.0;
         direction = (last >= mid) ? 1 : -1;
      }
      else
      {
         // Quote-based fallback (avoids systematic sell-bias when last==0)
         if(lastBid > 0 && bid > 0)
         {
            if(bid > lastBid) direction = 1;
            else if(bid < lastBid) direction = -1;
         }
         else if(lastAsk > 0 && ask > 0)
         {
            if(ask > lastAsk) direction = 1;
            else if(ask < lastAsk) direction = -1;
         }
         else if(lastTrade > 0 && last > 0)
         {
            if(last > lastTrade) direction = 1;
            else if(last < lastTrade) direction = -1;
         }
      }

      delta += direction * vol;

      if(bid > 0) lastBid = bid;
      if(ask > 0) lastAsk = ask;
      if(last > 0) lastTrade = last;
   }

   return delta;
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
   if(limit <= 0) limit = 1;  // Sempre recalcula barra atual
   
   // Limita processamento
   if(limit > InpBarsToCalculate)
      limit = InpBarsToCalculate;
   
   for(int i = 0; i < limit && i < rates_total; i++)
   {
      long delta = CalculateBarDelta(i);
      
      g_deltaRaw[i] = (double)delta;
      
      if(delta >= 0)
      {
         g_deltaPlus[i] = (double)delta;
         g_deltaMinus[i] = 0;
      }
      else
      {
         g_deltaPlus[i] = 0;
         g_deltaMinus[i] = (double)delta;
      }
   }
   
   return(rates_total);
}
//+------------------------------------------------------------------+
