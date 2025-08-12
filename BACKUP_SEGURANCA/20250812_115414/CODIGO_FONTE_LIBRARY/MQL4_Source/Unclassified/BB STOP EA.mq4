//------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"
#property strict
//------------------------------------------------------------------
enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2  // Heiken ashi trend biased (extreme) price
};

enum enMaTypes
{
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma,   // Linear weighted MA
   ma_tema    // Triple exponential moving average - TEMA
};

input double          MaxLot          = 3;                            // Maximum lots to risk
input double          LotsPer15K      = 1;                            // Lots per $15K in account
extern string         dummy1          = "";                           // . 
extern double         TakeProfit      = 800;                          // Initial take profit (in pips)
extern double         StopLoss        = 0;                            // Initial stop loss (in pips)
extern string          dummy2         = "";                           // Settings for indicators
input int              BandsPeriod    = 21;                            // Super trend atr period
extern double          BandsDeviation = 3;               // Bands deviation
extern bool            BandsDeviationSample = false;      // Bands deviation with sample correction?
extern double          BandsRisk      = 3;               // Bands risk
extern enMaTypes       BandsMaType    = ma_sma;          // Bands average type
extern enPrices        Price          = pr_close;        // Price

extern bool            Interpolate    = true;            // Interpolate in multi time frame mode?
//
//
extern string          dummy3          = "";                         // 
extern int             MagicNumber     = 123456;                     // Magic number to use for the EA
extern bool            EcnBroker       = true;                       // Is your broker ECN/STP type of broker?
extern bool            MulOnSame       = false;                      // Allow multiple opened and closed orders on a same bar?
extern string          dummy4          = "";                        // General settings
extern bool            DisplayInfo     = true;                      // Dislay info
extern int             Slippage        = 25;                        // Slipage to use when opening new orders
extern int             BarToUse        = 1;                         // Bar to test (0, for still opened, 1 for first closed, and so on)
input int              Maximum_Spread_Points = 25;                   // Maximum   Spread to use when opening new orders

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
 double MM_Size() //Calculate position sizing
  {
   double lots = ((AccountEquity() / 15000)*LotsPer15K); //calculate the lot size according to how many lots input per 15K in "LotsPer 15K"
   if(lots > MaxLot) lots = MaxLot;  //if greater than max set it to the maxlot size
   return(lots);
  }

//
//
//
//

#define TRADE_RETRY_COUNT 4
#define TRADE_RETRY_WAIT  100
#define _doNothing 0
#define _doBuy     1
#define _doSell    2

int start()

{
   
   int doWhat = _doNothing;
      double bbstoptrend_trend_current  = iCustom(NULL,0,"BB stops (new format) 1.3 )",PERIOD_CURRENT,0,21,3,false,3,ma_sma,pr_close, Interpolate ,7,BarToUse);

      double bbstoptrend_trend_previous = iCustom(NULL,0,"BB stops (new format) 1.3 )",PERIOD_CURRENT,0,21,3,false,3,ma_sma,pr_close, Interpolate ,7,BarToUse+1);

     
     if (bbstoptrend_trend_current!=bbstoptrend_trend_previous)
         if (bbstoptrend_trend_current==1)
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
      
    //  if (DisplayInfo) currentProfit += OrderProfit()+OrderCommission()+OrderSwap();
         
         //
         //
         //
         //
         //
         
         if (OrderType()==OP_BUY)
            if (doWhat==_doSell)
                  { RefreshRates(); if (!OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,CLR_NONE)) openedBuys++; }
            else  openedBuys++;
            
            
         if (OrderType()==OP_SELL)
            if (doWhat==_doBuy)
                  { RefreshRates(); if (!OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,CLR_NONE)) openedSells++; }
            else  openedSells++;            
   }
  

   //
   //
   //
   //
   //
 if (doWhat!=_doNothing && !MulOnSame)
      {
         for (int i = OrdersHistoryTotal()-1; i>=0; i--)
         {
               if (!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
               if (OrderSymbol()      != Symbol())             continue;
               if (OrderMagicNumber() != MagicNumber)          continue;
               if (iBarShift(NULL,0,OrderCloseTime())!=0)      continue;
               if (OrderType()==OP_BUY  && doWhat ==_doBuy)  { doWhat = _doNothing; break; }
               if (OrderType()==OP_SELL && doWhat ==_doSell) { doWhat = _doNothing; break; }
         }
      }          
   if (doWhat==_doBuy && openedBuys==0)
      {
         RefreshRates();
         double stopLossBuy   = 0; if (StopLoss>0)   stopLossBuy   = Ask-StopLoss*Point*MathPow(10,Digits%2);
         double takeProfitBuy = 0; if (TakeProfit>0) takeProfitBuy = Ask+TakeProfit*Point*MathPow(10,Digits%2);
         if (EcnBroker)
         {
            int ticketb = OrderSend(Symbol(),OP_BUY,MM_Size() ,Ask,Slippage,0,0,"",MagicNumber,0,CLR_NONE);
            if (ticketb>-1)
              dummyResult = OrderModify(ticketb,OrderOpenPrice(),stopLossBuy,takeProfitBuy,0,CLR_NONE);
         }
         else dummyResult = OrderSend(Symbol(),OP_BUY,MM_Size(),Ask,Slippage,stopLossBuy,takeProfitBuy,"",MagicNumber,0,CLR_NONE);
      }
   if (doWhat==_doSell && openedSells==0)
      {
         RefreshRates();
         double stopLossSell   = 0; if (StopLoss>0)   stopLossSell   = Bid+StopLoss*Point*MathPow(10,Digits%2);
         double takeProfitSell = 0; if (TakeProfit>0) takeProfitSell = Bid-TakeProfit*Point*MathPow(10,Digits%2);
         if (EcnBroker)
         {
            int tickets = OrderSend(Symbol(),OP_SELL,MM_Size() ,Bid,Slippage,0,0,"",MagicNumber,0,CLR_NONE);
            if (tickets>-1)
              dummyResult = OrderModify(tickets,OrderOpenPrice(),stopLossSell,takeProfitSell,0,CLR_NONE);
         }
         else dummyResult = OrderSend(Symbol(),OP_SELL,MM_Size() ,Bid,Slippage,stopLossSell,takeProfitSell,"",MagicNumber,0,CLR_NONE);
      }
   return(0);
}
//------------------------------------------------------------------
//
//------------------------------------------------------------------
bool IsWithinMaxSpread()
{
    bool WithinMaxSpread = true;

    for (int attempt = 0; attempt < TRADE_RETRY_COUNT; attempt++)
    {
        RefreshRates();
        WithinMaxSpread = true;

        if (Maximum_Spread_Points > 0)
        {
            double spread = NormalizeDouble(((Ask - Bid) /_Point ), 0);
            //Need NormalizeDouble here because of rounding errors in MT4 that otherwise occur (confirmed in several backtests).

            if (spread > Maximum_Spread_Points)
            {
                Print("The current spread of ", DoubleToString(spread, 0), " points, is higher than the maximum allowed of ", DoubleToString(Maximum_Spread_Points, 0), " points. Try ", IntegerToString(attempt + 1), " of ", IntegerToString(TRADE_RETRY_COUNT), ".");
                WithinMaxSpread = false;
            }
        }
        Sleep(TRADE_RETRY_WAIT);
    }
    
    return(WithinMaxSpread);
}
//------------------------------------------------------------------
//
//------------------------------------------------------------------