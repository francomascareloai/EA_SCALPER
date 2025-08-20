//+------------------------------------------------------------------+
//|                                        Simple Expert Advisor.mq4 |
//|                                                  Andrew R. Young |
//|                                 http://www.expertadvisorbook.com |
//+------------------------------------------------------------------+

#property copyright     "Andrew R. Young"
#property link          "http://www.expertadvisorbook.com"
#property description   "A simple expert advisor that places market orders"
#property strict


// Input variables
input int MagicNumber = 101;
input int Slippage = 10;

input double LotSize = 0.1;
input int StopLoss = 0;
input int TakeProfit = 0;

input int MaPeriod = 5;
input ENUM_MA_METHOD MaMethod = MODE_EMA;
input ENUM_APPLIED_PRICE MaPrice = PRICE_CLOSE;

// Trailing stop (Chapter 20)
input int TrailingStop = 500;
input int MinimumProfit = 200;
input int Step = 10;


// Global variables
int gBuyTicket, gSellTicket;


// OnTick() event handler
void OnTick()
{
   
   // Current order counts
   int buyCount = 0, sellCount = 0;
   
   for(int order = 0; order <= OrdersTotal() - 1; order++)
   {
      bool select = OrderSelect(order,SELECT_BY_POS);
      
      if(OrderMagicNumber() == MagicNumber && select == true)
      {
         if(OrderType() == OP_BUY) buyCount++;
         else if(OrderType() == OP_SELL) sellCount++;
      }   
   }
   
   
   // Moving average and close price from last bar
   double ma = iMA(_Symbol,_Period,MaPeriod,0,MaMethod,MaPrice,1);
   double close = Close[1];
   
   
   // Buy order condition
   if(close > ma && buyCount == 0 && gBuyTicket == 0)
   {
      // Close sell order
      for(int order = 0; order <= OrdersTotal() - 1; order++)
      {
         bool select = OrderSelect(order,SELECT_BY_POS);
         
         if(OrderType() == OP_SELL && OrderMagicNumber() == MagicNumber && select == true)
         {
            // Close order
            bool closed = OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,clrRed);
            if(closed == true) order--;
         }
      }
      
      // Open buy order
      gBuyTicket = OrderSend(_Symbol,OP_BUY,LotSize,Ask,Slippage,0,0,"Buy order",MagicNumber,0,clrGreen);
      gSellTicket = 0;
      
      // Add stop loss & take profit to order
      if(gBuyTicket > 0 && (StopLoss > 0 || TakeProfit > 0))
      {
         bool select = OrderSelect(gBuyTicket,SELECT_BY_TICKET);
         
         // Calculate stop loss & take profit
         double stopLoss = 0, takeProfit = 0;
         if(StopLoss > 0) stopLoss = OrderOpenPrice() - (StopLoss * _Point);
         if(TakeProfit > 0) takeProfit = OrderOpenPrice() + (TakeProfit * _Point);
         
         // Verify stop loss & take profit
         double stopLevel = MarketInfo(_Symbol,MODE_STOPLEVEL) * _Point;
         
         RefreshRates();
         double upperStopLevel = Ask + stopLevel;
         double lowerStopLevel = Bid - stopLevel;
         
         if(takeProfit <= upperStopLevel && takeProfit != 0) takeProfit = upperStopLevel + _Point;
         if(stopLoss >= lowerStopLevel && stopLoss  != 0) stopLoss = lowerStopLevel - _Point; 
         
         // Modify order
         bool modify = OrderModify(gBuyTicket,0,stopLoss,takeProfit,0);
      }
   }
   
   
   // Sell order condition
   if(close < ma && sellCount == 0 && gSellTicket == 0)
   {
      // Close buy order
      for(int order = 0; order <= OrdersTotal() - 1; order++)
      {
         bool select = OrderSelect(order,SELECT_BY_POS);
         
         if(OrderType() == OP_BUY && OrderMagicNumber() == MagicNumber && select == true)
         {
            // Close order
            bool closed = OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,clrRed);
            
            if(closed == true)
            {
               gBuyTicket = 0;
               order--;
            }
         }
      }
      
      // Open sell order
      gSellTicket = OrderSend(_Symbol,OP_SELL,LotSize,Bid,Slippage,0,0,"Sell order",MagicNumber,0,clrRed);
      gBuyTicket = 0;
      
      // Add stop loss & take profit to order
      if(gSellTicket > 0 && (StopLoss > 0 || TakeProfit > 0))
      {
         bool select = OrderSelect(gSellTicket,SELECT_BY_TICKET);
         
         // Calculate stop loss & take profit
         double stopLoss = 0, takeProfit = 0;
         if(StopLoss > 0) stopLoss = OrderOpenPrice() + (StopLoss * _Point);
         if(TakeProfit > 0) takeProfit = OrderOpenPrice() - (TakeProfit * _Point);
         
         // Verify stop loss & take profit
         double stopLevel = MarketInfo(_Symbol,MODE_STOPLEVEL) * _Point;
         
         RefreshRates();
         double upperStopLevel = Ask + stopLevel;
         double lowerStopLevel = Bid - stopLevel;
         
         if(takeProfit >= lowerStopLevel && takeProfit != 0) takeProfit = lowerStopLevel - _Point;
         if(stopLoss <= upperStopLevel && stopLoss != 0) stopLoss = upperStopLevel + _Point; 
         
         // Modify order
         bool modify = OrderModify(gSellTicket,0,stopLoss,takeProfit,0);
      }
   }
   
   
   // Trailing stop (Chapter 20)
   for(int order = 0; order <= OrdersTotal() - 1; order++)
   {
      bool select = OrderSelect(order,SELECT_BY_POS);
      
      if(TrailingStop > 0 && OrderMagicNumber() == MagicNumber && select == true)
      {
         RefreshRates();
         
         // Check buy order trailing stops
         if(OrderType() == OP_BUY)
         {
            double trailStopPrice = Bid - (TrailingStop * _Point);
            trailStopPrice = NormalizeDouble(trailStopPrice,_Digits);
            
            double currentStopLoss = NormalizeDouble(OrderStopLoss(),_Digits);
            double currentProfit = Bid - OrderOpenPrice();
            double minProfit = MinimumProfit * _Point;
            
            int getStep = 0;
            if(Step < 10) getStep = 10;
	         double step = getStep * _Point;
            
            if(trailStopPrice > currentStopLoss + step && currentProfit >= minProfit)
            {
               bool modify = OrderModify(OrderTicket(),OrderOpenPrice(),trailStopPrice,OrderTakeProfit(),0);
            }
         }
         
         // Check sell order trailing stops
         else if(OrderType() == OP_SELL && TrailingStop > 0)
         {
            double trailStopPrice = Ask + (TrailingStop * _Point);
            trailStopPrice = NormalizeDouble(trailStopPrice,_Digits);
            
            double currentStopLoss = NormalizeDouble(OrderStopLoss(),_Digits);
            double currentProfit = OrderOpenPrice() - Ask;
            double minProfit = MinimumProfit * _Point;
            
            int getStep = 0;
            if(Step < 10) getStep = 10;
	         double step = getStep * _Point;
            
            if((trailStopPrice < currentStopLoss - step || currentStopLoss == 0) && currentProfit >= minProfit)
            {
               bool modify = OrderModify(OrderTicket(),OrderOpenPrice(),trailStopPrice,OrderTakeProfit(),0);
            }
         }
      }
   }
   
}