//+------------------------------------------------------------------+
//|                                         2CCI_ZeroCross_Alert.mq4 |
//|                   Copyright © 2005, Jason Robinson (jnrtrading). |
//|                                      http://www.jnrtrading.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Jason Robinson (jnrtrading)."
#property link      "http://www.jnrtrading.co.uk"

#property indicator_chart_window

extern int CCI_Trend = 50;
extern int CCI_Entry = 14;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   double cciTrendNow, cciTrendPrevious, cciEntry;
   
   cciTrendNow = iCCI(NULL, 0, CCI_Trend, PRICE_TYPICAL, 0);
   cciTrendPrevious = iCCI(NULL, 0, CCI_Trend, PRICE_TYPICAL, 1);
   cciEntry = iCCI(NULL, 0, CCI_Entry, PRICE_TYPICAL, 0);
   
//---- 
   //Print(cciTrendNow, "...", cciTrendPrevious, "...", cciEntry);

   if(cciEntry < 0) {
      if((cciTrendNow < 0) && (cciTrendPrevious >= 0)) {
         Alert(Symbol(), " M", Period(), " Trend & Entry CCI Have both crossed below zero");
      }
   }
   else if(cciEntry > 0) {
      if((cciTrendNow > 0) && (cciTrendPrevious <= 0)) {
         Alert(Symbol(), " M", Period(), " Trend & Entry CCI Have both crossed above zero");
      }
   }
   Comment("Trend CCI: ", cciTrendNow, " Entry CCI: ", cciEntry);

   
//----
   return(0);
  }
//+------------------------------------------------------------------+