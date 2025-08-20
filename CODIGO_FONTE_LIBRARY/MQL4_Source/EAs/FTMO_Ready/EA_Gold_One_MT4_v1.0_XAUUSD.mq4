
#property strict
 
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
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased   // Heiken ashi trend biased price
};
enum enFilterWhat
{
   flt_prc,  // Filter the price
   flt_val,  // Filter the step ma
   flt_both  // Filter both
};
enum enRsiTypes
{
   rsi_rsi,  // Regular RSI
   rsi_wil,  // Slow RSI
   rsi_rap,  // Rapid RSI
   rsi_har,  // Harris RSI
   rsi_rsx,  // RSX
   rsi_cut   // Cuttlers RSI
};

extern string _s1_ = "************";
extern string symbols = "XAUUSD";
extern int number_main_ = 46335;
extern int strategy_type = 0;
extern string comment_order_ = "";
extern string _s2_ = "************";
extern int management_method_lot_ = 1;
extern double percentoftraderisk = 3.0;
extern double size_fixed_lot_ = 0.2;
extern double sizemaximumlot = 40.0;
extern double size_minimum_lot_ = 0.01;
extern string _s3_ = "************";
extern double maxSpread = 75.0;
extern string _s4_ = "************";
extern bool tradingmonday = FALSE;
extern bool trading_tuesday_ = TRUE;
extern bool trading_wednesday_ = TRUE;
extern bool trading_thursday_ = TRUE;
extern bool trading_friday_ = TRUE;
extern string _s5_ = "************";
extern int max_lost_trade_per_day1_ = 3;
extern bool enable_high_impact_filter1_ = FALSE;
extern bool _enablemediumimpactnewsfilter = FALSE;
extern bool enable_low_impact_filter1_ = FALSE;
extern int _avoidhourbefore1 = 2;
extern int avoid_trading_post_news1_ = 2;
extern string _s6_ = "************";
extern bool use_martingale1_ = FALSE;
extern int start_method_martingale1_ = 1;
extern int martingale_tp_type_ = 3;
extern int distance_tp_percent1_ = 60;
extern int fixedpipsmartingale1 = 200;
extern int martingaleperiodicatr = 40;
extern double martingale_atr_multiplier_pip_ = 1.5;
extern double _maxaddmartingalepercent = 110.0;
extern int martingale_profitt_profit_type_ = 1;
extern int total_cash_martingale_profit_ = 15;
extern double totalcashpercentmartingaleprofit = 2.0;


  int    MagicNumber = 123456;  // Magic number to use for the EA
  bool   EcnBroker   = false;   // Is your broker ECN/STP type of broker?
  double LotSize     = 0.1;     // Lot size to use for trading
  int    Slippage    = 3;       // Slipage to use when opening new orders
  double StopLoss    = 100;     // Initial stop loss (in pips)
  double TakeProfit  = 100;     // Initial take profit (in pips)

  string dummy1      = "";      // .
  string dummy2      = "";      // Settings for indicators
  int    BarToUse    = 1;       // Bar to test (0, for still opened, 1 for first closed, and so on)
  enRsiTypes      RsiType            = rsi_rsi;       // RSI calculation method
  int             RsiLength          = 14;            // Rsi length
  enPrices        RsiPrice           = pr_close;      // Rsi price
  double          Sensitivity        = 4;             // Sensivity Factor
  double          StepSize           = 5;             // Atr step divisor
  double          Filter             = 0;             // Filter (<=0, no filtering)
  int             FilterPeriod       = 0;             // Filter period (0<= use rsi period)
  enFilterWhat    FilterOn           = flt_val;       // Apply filter to :

  string dummy3      = "";      // . 
  string dummy4      = "";      // General settings
  bool   DisplayInfo = true;    // Dislay info

bool dummyResult;
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()   {


 return(0); }
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
      double hull_trend_current  = iCustom(NULL,0,"Gold One MT4",PERIOD_CURRENT,RsiType,RsiLength,RsiPrice,Sensitivity,StepSize,Filter,FilterPeriod,FilterOn,10,BarToUse);
      double hull_trend_previous = iCustom(NULL,0,"Gold One MT4",PERIOD_CURRENT,RsiType,RsiLength,RsiPrice,Sensitivity,StepSize,Filter,FilterPeriod,FilterOn,10,BarToUse+1);
      if (hull_trend_current!=hull_trend_previous)
         if (hull_trend_current==1)
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