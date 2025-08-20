//+------------------------------------------------------------------+
//|                        GoldLondonNY_EA.mq5                       |
//|    Trend EA for Gold using 5 EMA & 21 EMA with time filter       |
//+------------------------------------------------------------------+
#property copyright "OpenAI ChatGPT"
#property version   "1.00"
#property strict

// ===== Inputs =====
input double LotSize            = 0.1;    // Lot size
input int    Slippage           = 3;      // Slippage
input int    MagicNum           = 123456; // Magic number
input double StopLossPips       = 30;     // Stop Loss in pips
input double TakeProfitPips     = 60;     // Take Profit in pips
input bool   UseTrailingStop    = true;   // Enable trailing stop?
input double TrailingStartPips  = 20;     // Start trailing after profit (pips)
input double TrailingStepPips   = 10;     // Trailing distance (pips)

// Time filter (server time, usually UTC+0)
input int LondonStartHour = 8;
input int LondonEndHour   = 12;
input int NYStartHour     = 13;
input int NYEndHour       = 17;

// ===== Internal handles & buffers =====
int ema5_handle, ema21_handle;
double ema5_buffer[], ema21_buffer[];

//+------------------------------------------------------------------+
int OnInit()
  {
   ema5_handle  = iMA(_Symbol, _Period, 5, 0, MODE_EMA, PRICE_CLOSE);
   ema21_handle = iMA(_Symbol, _Period, 21, 0, MODE_EMA, PRICE_CLOSE);
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(ema5_handle != INVALID_HANDLE) IndicatorRelease(ema5_handle);
   if(ema21_handle != INVALID_HANDLE) IndicatorRelease(ema21_handle);
  }
//+------------------------------------------------------------------+
void OnTick()
  {
   if(CopyBuffer(ema5_handle,0,0,2,ema5_buffer)<=0 ||
      CopyBuffer(ema21_handle,0,0,2,ema21_buffer)<=0)
     {
      Print("Failed to copy EMA buffers: ",GetLastError());
      return;
     }

   double close_current  = iClose(_Symbol, _Period, 0);
   double close_previous = iClose(_Symbol, _Period, 1);
   double ema5_current   = ema5_buffer[0];
   double ema5_previous  = ema5_buffer[1];
   double ema21_current  = ema21_buffer[0];
   double ema21_previous = ema21_buffer[1];

   bool haveBuy  = CheckOpenBuy();
   bool haveSell = CheckOpenSell();

   // === Buy open when price crosses below ema5 ===
   bool openBuySignal  = (close_previous >= ema5_previous) && (close_current < ema5_current);
   // Close buy when ema5 crosses below ema21
   bool closeBuySignal = (ema5_previous >= ema21_previous) && (ema5_current < ema21_current);

   // === Sell open when price crosses above ema5 ===
   bool openSellSignal  = (close_previous <= ema5_previous) && (close_current > ema5_current);
   // Close sell when price closes fully above ema5
   bool closeSellSignal = (close_current > ema5_current);

   // === Only open new trades inside London/NY session ===
   if(IsTradingHour())
     {
      if(openBuySignal && !haveBuy)
         OpenBuyOrder();
      if(openSellSignal && !haveSell)
         OpenSellOrder();
     }

   // Close logic always
   if(closeBuySignal && haveBuy)
      CloseBuyOrders();
   if(closeSellSignal && haveSell)
      CloseSellOrders();

   // Trailing stop
   if(UseTrailingStop)
     {
      ManageTrailingBuy();
      ManageTrailingSell();
     }
  }
//+------------------------------------------------------------------+
bool IsTradingHour()
  {
   int hour = TimeHour(TimeCurrent());
   if(hour >= LondonStartHour && hour < LondonEndHour)
      return true;
   if(hour >= NYStartHour && hour < NYEndHour)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
//| Helpers: check positions                                         |
//+------------------------------------------------------------------+
bool CheckOpenBuy()
  {
   for(int i=0;i<PositionsTotal();i++)
     {
      if(PositionSelectByIndex(i) &&
         PositionGetInteger(POSITION_MAGIC)==MagicNum &&
         PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY &&
         PositionGetString(POSITION_SYMBOL)==_Symbol)
         return true;
     }
   return false;
  }
bool CheckOpenSell()
  {
   for(int i=0;i<PositionsTotal();i++)
     {
      if(PositionSelectByIndex(i) &&
         PositionGetInteger(POSITION_MAGIC)==MagicNum &&
         PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL &&
         PositionGetString(POSITION_SYMBOL)==_Symbol)
         return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Open orders                                                      |
//+------------------------------------------------------------------+
void OpenBuyOrder()
  {
   double price=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double sl=price - StopLossPips*_Point;
   double tp=price + TakeProfitPips*_Point;

   MqlTradeRequest request;
   MqlTradeResult  result;
   ZeroMemory(request); ZeroMemory(result);

   request.action    = TRADE_ACTION_DEAL;
   request.symbol    = _Symbol;
   request.volume    = LotSize;
   request.type      = ORDER_TYPE_BUY;
   request.price     = price;
   request.sl        = NormalizeDouble(sl,_Digits);
   request.tp        = NormalizeDouble(tp,_Digits);
   request.deviation = Slippage;
   request.magic     = MagicNum;
   request.comment   = "Buy EMA";

   OrderSend(request,result);
  }
//+------------------------------------------------------------------+
void OpenSellOrder()
  {
   double price=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double sl=price + StopLossPips*_Point;
   double tp=price - TakeProfitPips*_Point;

   MqlTradeRequest request;
   MqlTradeResult  result;
   ZeroMemory(request); ZeroMemory(result);

   request.action    = TRADE_ACTION_DEAL;
   request.symbol    = _Symbol;
   request.volume    = LotSize;
   request.type      = ORDER_TYPE_SELL;
   request.price     = price;
   request.sl        = NormalizeDouble(sl,_Digits);
   request.tp        = NormalizeDouble(tp,_Digits);
   request.deviation = Slippage;
   request.magic     = MagicNum;
   request.comment   = "Sell EMA";

   OrderSend(request,result);
  }
//+------------------------------------------------------------------+
//| Close positions                                                  |
//+------------------------------------------------------------------+
void CloseBuyOrders()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      if(PositionSelectByIndex(i) &&
         PositionGetInteger(POSITION_MAGIC)==MagicNum &&
         PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY &&
         PositionGetString(POSITION_SYMBOL)==_Symbol)
        {
         ulong ticket=PositionGetInteger(POSITION_TICKET);
         double volume=PositionGetDouble(POSITION_VOLUME);

         MqlTradeRequest request;
         MqlTradeResult  result;
         ZeroMemory(request); ZeroMemory(result);

         request.action   = TRADE_ACTION_DEAL;
         request.symbol   = _Symbol;
         request.position = ticket;
         request.volume   = volume;
         request.type     = ORDER_TYPE_SELL;
         request.price    = SymbolInfoDouble(_Symbol,SYMBOL_BID);
         request.deviation= Slippage;
         request.magic    = MagicNum;
         request.comment  ="Close Buy";

         OrderSend(request,result);
        }
     }
  }
//+------------------------------------------------------------------+
void CloseSellOrders()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      if(PositionSelectByIndex(i) &&
         PositionGetInteger(POSITION_MAGIC)==MagicNum &&
         PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL &&
         PositionGetString(POSITION_SYMBOL)==_Symbol)
        {
         ulong ticket=PositionGetInteger(POSITION_TICKET);
         double volume=PositionGetDouble(POSITION_VOLUME);

         MqlTradeRequest request;
         MqlTradeResult  result;
         ZeroMemory(request); ZeroMemory(result);

         request.action   = TRADE_ACTION_DEAL;
         request.symbol   = _Symbol;
         request.position = ticket;
         request.volume   = volume;
         request.type     = ORDER_TYPE_BUY;
         request.price    = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
         request.deviation= Slippage;
         request.magic    = MagicNum;
         request.comment  ="Close Sell";

         OrderSend(request,result);
        }
     }
  }
//+------------------------------------------------------------------+
//| Trailing stop                                                    |
//+------------------------------------------------------------------+
void ManageTrailingBuy()
  {
   for(int i=0;i<PositionsTotal();i++)
     {
      if(PositionSelectByIndex(i) &&
         PositionGetInteger(POSITION_MAGIC)==MagicNum &&
         PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY &&
         PositionGetString(POSITION_SYMBOL)==_Symbol)
        {
         double openPrice=PositionGetDouble(POSITION_PRICE_OPEN);
         double price=SymbolInfoDouble(_Symbol,SYMBOL_BID);
         double sl=PositionGetDouble(POSITION_SL);
         double trailStart=TrailingStartPips*_Point;
         double trailStep=TrailingStepPips*_Point;

         if(price - openPrice > trailStart)
           {
            double newSL=NormalizeDouble(price - trailStep,_Digits);
            if(newSL > sl)
              {
               MqlTradeRequest request;
               MqlTradeResult  result;
               ZeroMemory(request); ZeroMemory(result);

               request.action   = TRADE_ACTION_SLTP;
               request.symbol   = _Symbol;
               request.position = PositionGetInteger(POSITION_TICKET);
               request.sl       = newSL;
               request.tp       = PositionGetDouble(POSITION_TP);
               request.magic    = MagicNum;

               OrderSend(request,result);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
void ManageTrailingSell()
  {
   for(int i=0;i<PositionsTotal();i++)
     {
      if(PositionSelectByIndex(i) &&
         PositionGetInteger(POSITION_MAGIC)==MagicNum &&
         PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL &&
         PositionGetString(POSITION_SYMBOL)==_Symbol)
        {
         double openPrice=PositionGetDouble(POSITION_PRICE_OPEN);
         double price=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
         double sl=PositionGetDouble(POSITION_SL);
         double trailStart=TrailingStartPips*_Point;
         double trailStep=TrailingStepPips*_Point;

         if(openPrice - price > trailStart)
           {
            double newSL=NormalizeDouble(price + trailStep,_Digits);
            if(newSL < sl || sl==0)
              {
               MqlTradeRequest request;
               MqlTradeResult  result;
               ZeroMemory(request); ZeroMemory(result);

               request.action   = TRADE_ACTION_SLTP;
               request.symbol   = _Symbol;
               request.position = PositionGetInteger(POSITION_TICKET);
               request.sl       = newSL;
               request.tp       = PositionGetDouble(POSITION_TP);
               request.magic    = MagicNum;

               OrderSend(request,result);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
