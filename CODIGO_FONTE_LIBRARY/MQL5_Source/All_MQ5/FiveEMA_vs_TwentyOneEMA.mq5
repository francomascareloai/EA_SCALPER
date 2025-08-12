//+------------------------------------------------------------------+
//|                                     FiveEMA_vs_TwentyOneEMA.mq5 |
//|                    Created by ChatGPT (OpenAI)                  |
//+------------------------------------------------------------------+
#property copyright "OpenAI ChatGPT"
#property version   "1.00"
#property strict

// Input parameters
input double LotSize   = 0.1;          // Lot size
input int    Slippage  = 3;            // Slippage
input int    MagicNum  = 123456;       // Magic number

// EMA handles
int ema5_handle;
int ema21_handle;

// Buffers to hold EMA data
double ema5_buffer[];
double ema21_buffer[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   ema5_handle = iMA(_Symbol, _Period, 5, 0, MODE_EMA, PRICE_CLOSE);
   ema21_handle = iMA(_Symbol, _Period, 21, 0, MODE_EMA, PRICE_CLOSE);

   if (ema5_handle == INVALID_HANDLE || ema21_handle == INVALID_HANDLE)
     {
      Print("Error creating EMA handles: ", GetLastError());
      return INIT_FAILED;
     }
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if (ema5_handle != INVALID_HANDLE) IndicatorRelease(ema5_handle);
   if (ema21_handle != INVALID_HANDLE) IndicatorRelease(ema21_handle);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Get latest 2 values for each EMA
   if (CopyBuffer(ema5_handle, 0, 0, 2, ema5_buffer) <= 0 ||
       CopyBuffer(ema21_handle, 0, 0, 2, ema21_buffer) <= 0)
     {
      Print("Error copying EMA buffers: ", GetLastError());
      return;
     }

   double close_current  = iClose(_Symbol, _Period, 0);
   double close_previous = iClose(_Symbol, _Period, 1);

   double ema5_current   = ema5_buffer[0];
   double ema5_previous  = ema5_buffer[1];

   double ema21_current  = ema21_buffer[0];
   double ema21_previous = ema21_buffer[1];

   // Conditions
   bool buySignal  = (close_previous <= ema5_previous) && (close_current > ema5_current);
   bool sellSignal = (ema5_previous >= ema21_previous) && (ema5_current < ema21_current);

   bool haveOpenBuy = CheckOpenBuy();

   // Trade logic
   if (buySignal && !haveOpenBuy)
     {
      OpenBuyOrder();
     }
   else if (sellSignal && haveOpenBuy)
     {
      CloseBuyOrders();
     }
  }
//+------------------------------------------------------------------+
//| Check if EA has an open Buy position                             |
//+------------------------------------------------------------------+
bool CheckOpenBuy()
  {
   for (int i=0; i<PositionsTotal(); i++)
     {
      if (PositionGetTicket(i) > 0)
        {
         if (PositionGetInteger(POSITION_MAGIC) == MagicNum &&
             PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY &&
             PositionGetString(POSITION_SYMBOL) == _Symbol)
            return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Open Buy order                                                   |
//+------------------------------------------------------------------+
void OpenBuyOrder()
  {
   MqlTradeRequest request;
   MqlTradeResult  result;
   ZeroMemory(request);
   ZeroMemory(result);

   request.action   = TRADE_ACTION_DEAL;
   request.symbol   = _Symbol;
   request.volume   = LotSize;
   request.type     = ORDER_TYPE_BUY;
   request.price    = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   request.sl       = 0;
   request.tp       = 0;
   request.deviation= Slippage;
   request.magic    = MagicNum;
   request.comment  = "5 EMA Buy";

   if (!OrderSend(request, result))
     {
      Print("OrderSend failed: ", GetLastError());
     }
   else if (result.retcode != TRADE_RETCODE_DONE)
     {
      Print("OrderSend failed, retcode: ", result.retcode);
     }
   else
     {
      Print("Buy order placed successfully, ticket: ", result.order);
     }
  }
//+------------------------------------------------------------------+
//| Close open Buy orders                                            |
//+------------------------------------------------------------------+
void CloseBuyOrders()
  {
   for (int i=PositionsTotal()-1; i>=0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if (ticket > 0)
        {
         if (PositionGetInteger(POSITION_MAGIC) == MagicNum &&
             PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY &&
             PositionGetString(POSITION_SYMBOL) == _Symbol)
           {
            double volume = PositionGetDouble(POSITION_VOLUME);
            double price  = SymbolInfoDouble(_Symbol, SYMBOL_BID);

            MqlTradeRequest request;
            MqlTradeResult  result;
            ZeroMemory(request);
            ZeroMemory(result);

            request.action     = TRADE_ACTION_DEAL;
            request.symbol     = _Symbol;
            request.position   = ticket;
            request.volume     = volume;
            request.type       = ORDER_TYPE_SELL; // to close buy, we sell
            request.price      = price;
            request.deviation  = Slippage;
            request.magic      = MagicNum;
            request.comment    = "Close 5 EMA Buy";

            if (!OrderSend(request, result))
              {
               Print("OrderClose failed: ", GetLastError());
              }
            else if (result.retcode != TRADE_RETCODE_DONE)
              {
               Print("OrderClose failed, retcode: ", result.retcode);
              }
            else
              {
               Print("Buy position closed, ticket: ", ticket);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
