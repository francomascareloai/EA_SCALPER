//+------------------------------------------------------------------+
//|                                                Footprint_POC.mq5 |
//|                          EA_SCALPER_XAUUSD - Visual Indicators   |
//|                                                                  |
//|  POC (Point of Control), VAH, VAL como linhas no grafico         |
//|  POC = Preco com maior volume (linha grossa)                     |
//|  VAH/VAL = Limites da Value Area 70% (linhas finas)              |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3

// Plot 1: POC
#property indicator_label1  "POC"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGold
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

// Plot 2: VAH
#property indicator_label2  "VAH"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_DOT
#property indicator_width2  1

// Plot 3: VAL
#property indicator_label3  "VAL"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrangeRed
#property indicator_style3  STYLE_DOT
#property indicator_width3  1

// Inputs
input double   InpClusterSize     = 0.50;   // Cluster Size (pontos)
input int      InpBarsToCalculate = 200;    // Barras para calcular
input double   InpValueAreaPct    = 0.70;   // Value Area % (0.70 = 70%)

// Buffers
double g_poc[];
double g_vah[];
double g_val[];

// Estrutura para nivel de preco
struct SPriceLevel {
   double price;
   long   volume;
};

//+------------------------------------------------------------------+
//| Custom indicator initialization function                          |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, g_poc, INDICATOR_DATA);
   SetIndexBuffer(1, g_vah, INDICATOR_DATA);
   SetIndexBuffer(2, g_val, INDICATOR_DATA);
   
   ArraySetAsSeries(g_poc, true);
   ArraySetAsSeries(g_vah, true);
   ArraySetAsSeries(g_val, true);
   
   IndicatorSetString(INDICATOR_SHORTNAME, "FP POC/VA");
   IndicatorSetInteger(INDICATOR_DIGITS, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Normaliza preco para cluster                                      |
//+------------------------------------------------------------------+
double NormalizeToCluster(double price, double clusterSize)
{
   return MathRound(price / clusterSize) * clusterSize;
}

//+------------------------------------------------------------------+
//| Calcula POC e Value Area de uma barra                             |
//+------------------------------------------------------------------+
void CalculateValueArea(int barIndex, double &poc, double &vah, double &val)
{
   poc = 0;
   vah = 0;
   val = 0;
   
   datetime barTime = iTime(_Symbol, _Period, barIndex);
   int barSeconds = PeriodSeconds(_Period);
   datetime barEnd = barTime + barSeconds;
   
   MqlTick ticks[];
   int copied = CopyTicksRange(_Symbol, ticks, COPY_TICKS_ALL,
                               barTime * 1000, barEnd * 1000);
   
   if(copied <= 0)
      return;
   
   double clusterSize = InpClusterSize;
   if(clusterSize <= 0) clusterSize = 0.50;
   
   // Agrupa volume por nivel de preco
   SPriceLevel levels[];
   int levelCount = 0;
   long totalVolume = 0;
   
   for(int i = 0; i < copied; i++)
   {
      double price = (ticks[i].last > 0) ? ticks[i].last : ticks[i].bid;
      price = NormalizeToCluster(price, clusterSize);
      long vol = (ticks[i].volume > 0) ? (long)ticks[i].volume : 1;
      
      // Procura nivel existente
      int foundIdx = -1;
      for(int j = 0; j < levelCount; j++)
      {
         if(MathAbs(levels[j].price - price) < clusterSize / 2)
         {
            foundIdx = j;
            break;
         }
      }
      
      if(foundIdx >= 0)
      {
         levels[foundIdx].volume += vol;
      }
      else
      {
         ArrayResize(levels, levelCount + 1);
         levels[levelCount].price = price;
         levels[levelCount].volume = vol;
         levelCount++;
      }
      
      totalVolume += vol;
   }
   
   if(levelCount == 0)
      return;
   
   // Ordena por preco
   for(int i = 0; i < levelCount - 1; i++)
   {
      for(int j = i + 1; j < levelCount; j++)
      {
         if(levels[i].price > levels[j].price)
         {
            SPriceLevel temp = levels[i];
            levels[i] = levels[j];
            levels[j] = temp;
         }
      }
   }
   
   // Encontra POC (nivel com maior volume)
   int pocIdx = 0;
   long maxVol = 0;
   for(int i = 0; i < levelCount; i++)
   {
      if(levels[i].volume > maxVol)
      {
         maxVol = levels[i].volume;
         pocIdx = i;
      }
   }
   
   poc = levels[pocIdx].price;
   vah = poc;
   val = poc;
   
   // Calcula Value Area (70% do volume)
   long targetVol = (long)(totalVolume * InpValueAreaPct);
   long currentVol = maxVol;
   
   int upperIdx = pocIdx;
   int lowerIdx = pocIdx;
   
   while(currentVol < targetVol && (upperIdx < levelCount - 1 || lowerIdx > 0))
   {
      long upperVol = 0, lowerVol = 0;
      
      if(upperIdx < levelCount - 1)
         upperVol = levels[upperIdx + 1].volume;
      if(lowerIdx > 0)
         lowerVol = levels[lowerIdx - 1].volume;
      
      if(upperVol >= lowerVol && upperIdx < levelCount - 1)
      {
         upperIdx++;
         currentVol += upperVol;
         vah = levels[upperIdx].price;
      }
      else if(lowerIdx > 0)
      {
         lowerIdx--;
         currentVol += lowerVol;
         val = levels[lowerIdx].price;
      }
      else
         break;
   }
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
   
   for(int i = 0; i < limit && i < rates_total; i++)
   {
      double poc, vah, val;
      CalculateValueArea(i, poc, vah, val);
      
      g_poc[i] = poc;
      g_vah[i] = vah;
      g_val[i] = val;
   }
   
   return(rates_total);
}
//+------------------------------------------------------------------+
