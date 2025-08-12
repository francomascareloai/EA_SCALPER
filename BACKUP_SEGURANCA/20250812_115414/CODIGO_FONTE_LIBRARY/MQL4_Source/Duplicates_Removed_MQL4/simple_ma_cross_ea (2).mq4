//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
#property strict
//------------------------------------------------------------------

extern int    MagicNumber = 123456;  // Magic number to use for the EA
extern bool   EcnBroker   = false;   // Is your broker ECN/STP type of broker?
extern double LotSize     = 0.1;     // Lot size to use for trading
extern int    Slippage    = 3;       // Slipage to use when opening new orders
extern double StopLoss    = 100;     // Initial stop loss (in pips)
extern double TakeProfit  = 100;     // Initial take profit (in pips)

extern string dummy1      = "";      // .
extern string dummy2      = "";      // Settings for indicators
extern int    BarToUse    = 1;       // Bar to test (0, for still opened, 1 for first closed, and so on)
extern int                Ma1Period   = 12;          // Fast ma period
extern ENUM_APPLIED_PRICE Ma1Price    = PRICE_CLOSE; // Fast ma price
extern ENUM_MA_METHOD     Ma1Method   = MODE_SMA;    // Fast ma method
extern int                Ma2Period   = 26;          // Slow ma period
extern ENUM_APPLIED_PRICE Ma2Price    = PRICE_CLOSE; // Slow ma price
extern ENUM_MA_METHOD     Ma2Method   = MODE_SMA;    // Slow ma method 

extern string dummy3      = "";      // . 
extern string dummy4      = "";      // General settings
extern bool   DisplayInfo = true;    // Dislay info

bool dummyResult;
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()   { return(0); }
int deinit() { return(0); }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define _doNothing 0
#define _doBuy     1
#define _doSell    2
int start()
{
   int doWhat = _doNothing;
      double diffc = iMA(NULL,0,Ma1Period,0,Ma1Method,Ma1Price,BarToUse)  -iMA(NULL,0,Ma2Period,0,Ma2Method,Ma2Price,BarToUse);
      double diffp = iMA(NULL,0,Ma1Period,0,Ma1Method,Ma1Price,BarToUse+1)-iMA(NULL,0,Ma2Period,0,Ma2Method,Ma2Price,BarToUse+1);
      if ((diffc*diffp)<0)
         if (diffc>0)
               doWhat = _doBuy;
         else  doWhat = _doSell;
         if (doWhat==_doNothing && !DisplayInfo) return(0);
         
   //
   //
   //
   //
   //
   
   int    openedBuys    = 0;
   int    openedSells   = 0;
   double currentProfit = 0;
   for (int i = OrdersTotal()-1; i>=0; i--)
   {
      if (!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if (OrderSymbol()      != Symbol())            continue;
      if (OrderMagicNumber() != MagicNumber)         continue;

      //
      //
      //
      //
      //
      
      if (DisplayInfo) currentProfit += OrderProfit()+OrderCommission()+OrderSwap();
         
         if (OrderType()==OP_BUY)
            if (doWhat==_doSell)
                  { RefreshRates(); if (!OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,CLR_NONE)) openedBuys++; }
            else  openedBuys++;
         if (OrderType()==OP_SELL)
            if (doWhat==_doBuy)
                  { RefreshRates(); if (!OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,CLR_NONE)) openedSells++; }
            else  openedSells++;            
   }
   if (DisplayInfo) Comment("Current profit : "+DoubleToStr(currentProfit,2)+" "+AccountCurrency()); if (doWhat==_doNothing) return(0);

   //
   //
   //
   //
   //

   if (doWhat==_doBuy && openedBuys==0)
      {
         RefreshRates();
         double stopLossBuy   = 0; if (StopLoss>0)   stopLossBuy   = Ask-StopLoss*Point*MathPow(10,Digits%2);
         double takeProfitBuy = 0; if (TakeProfit>0) takeProfitBuy = Ask+TakeProfit*Point*MathPow(10,Digits%2);
         if (EcnBroker)
         {
            int ticketb = OrderSend(Symbol(),OP_BUY,LotSize,Ask,Slippage,0,0,"",MagicNumber,0,CLR_NONE);
            if (ticketb>-1)
              dummyResult = OrderModify(ticketb,OrderOpenPrice(),stopLossBuy,takeProfitBuy,0,CLR_NONE);
         }
         else dummyResult = OrderSend(Symbol(),OP_BUY,LotSize,Ask,Slippage,stopLossBuy,takeProfitBuy,"",MagicNumber,0,CLR_NONE);
      }
   if (doWhat==_doSell && openedSells==0)
      {
         RefreshRates();
         double stopLossSell   = 0; if (StopLoss>0)   stopLossSell   = Bid+StopLoss*Point*MathPow(10,Digits%2);
         double takeProfitSell = 0; if (TakeProfit>0) takeProfitSell = Bid-TakeProfit*Point*MathPow(10,Digits%2);
         if (EcnBroker)
         {
            int tickets = OrderSend(Symbol(),OP_SELL,LotSize,Bid,Slippage,0,0,"",MagicNumber,0,CLR_NONE);
            if (tickets>-1)
              dummyResult = OrderModify(tickets,OrderOpenPrice(),stopLossSell,takeProfitSell,0,CLR_NONE);
         }
         else dummyResult = OrderSend(Symbol(),OP_SELL,LotSize,Bid,Slippage,stopLossSell,takeProfitSell,"",MagicNumber,0,CLR_NONE);
      }
   return(0);
}