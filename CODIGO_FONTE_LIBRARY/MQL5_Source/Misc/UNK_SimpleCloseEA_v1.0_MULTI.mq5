//+------------------------------------------------------------------+
//|                                       SimpleCloseAllEA_MT5.mq5 |
//|                      Copyright 2025, Google AI (Gemini)        |
//|                                       https://www.google.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Google AI (Gemini)"
#property link      "https://www.google.com"
#property version   "1.00"

#include <Trade\Trade.mqh>

CTrade trade;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong position_ticket = PositionGetTicket(i);
      if(position_ticket > 0)
        {
         trade.PositionClose(position_ticket);
        }
     }
  }
//+------------------------------------------------------------------+