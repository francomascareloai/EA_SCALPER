//https://forex-station.com/viewtopic.php?t=8414309&p=1294828273#p1294828273
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
enum enFilterWhat
{
   flt_prc,  // Filter the price
   flt_val,  // Filter the step ma
   flt_both  // Filter both
};
enum enRsiTypes
{
   rsi_cut,  // Cuttlers RSI
   rsi_har,  // Harris' RSI
   rsi_rap,  // Rapid RSI
   rsi_rsi,  // RSI
   rsi_rsx,  // RSX
   rsi_slo   // Slow RSI
};


extern int    MagicNumber = 123456;  // Magic number to use for the EA
extern bool   EcnBroker   = false;   // Is your broker ECN/STP type of broker?
extern double LotSize     = 0.1;     // Lot size to use for trading
extern int    Slippage    = 3;       // Slipage to use when opening new orders
extern double StopLoss    = 100;     // Initial stop loss (in pips)
extern double TakeProfit  = 100;     // Initial take profit (in pips)

extern string dummy1      = "";      // .
extern string dummy2      = "";      // Settings for indicators
extern int    BarToUse    = 1;       // Bar to test (0, for still opened, 1 for first closed, and so on)
extern enRsiTypes      RsiType            = rsi_rsi;       // RSI calculation method
extern int             RsiLength          = 14;            // Rsi length
extern enPrices        RsiPrice           = pr_close;      // Rsi price
extern double          Sensitivity        = 4;             // Sensivity Factor
extern double          StepSize           = 5;             // Atr step divisor
extern double          Filter             = 0;             // Filter (<=0, no filtering)
extern int             FilterPeriod       = 0;             // Filter period (0<= use rsi period)
extern enFilterWhat    FilterOn           = flt_val;       // Apply filter to :

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
      double stepma_trend_current  = iCustom(NULL,0,"StepMA of rsi adaptive ema 2.9",PERIOD_CURRENT,RsiType,RsiLength,RsiPrice,Sensitivity,StepSize,Filter,FilterPeriod,FilterOn,10,BarToUse);
      double stepma_trend_previous = iCustom(NULL,0,"StepMA of rsi adaptive ema 2.9",PERIOD_CURRENT,RsiType,RsiLength,RsiPrice,Sensitivity,StepSize,Filter,FilterPeriod,FilterOn,10,BarToUse+1);
      if (stepma_trend_current!=stepma_trend_previous)
         if (stepma_trend_current==1)
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