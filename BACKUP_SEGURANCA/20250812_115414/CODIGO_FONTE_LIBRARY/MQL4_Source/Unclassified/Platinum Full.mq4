#property copyright "Ex4toMq4Decompiler MT4 Expert Advisors and Indicators Base of Source Codes"
#property link      "https://ex4tomq4decompiler.com/"
//---
//---- input parameters

extern double    MaxReqSwing=90;
extern double    Margin=20;
extern double    DeadBand=20;
extern double    StopLoss=66;
extern double    TakeProfit=34;
extern double    MinLots=0.01;
extern double    MaxLots=10;
extern double    RiskFactor=0.075;
extern bool      SL_Reverse=false;
extern int       TriggerTime=17;
extern string    ExpirationTime="23:00";
extern int       magicno=888;
int cnbr_uey;
static int       LASTRUN;
static int       buy_orders_open=0;
static int       sell_orders_open=0;



//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//---- Alert if period is not equal to 5 minute charts
   if(Period() != PERIOD_H1)
      {
      Alert("Error - Chart period is <> 5 minutes.");
      }

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
   {

   double yesterday_high=0;
   double yesterday_low=0;
   double yesterday_close=0;
   double maxdiff=0;
   double highdiff=0;
   double lowdiff=0;
   double stop=0;
   double TP=0;
   double lots=1;
   double price=0;
   int seed=0;
   int slip=5;
   int ticket=0;
   int i=0; // Counter


// Number of bars in previous day

   double prev_day_highs[24];
   double prev_day_lows[24];




   while((TimeDayOfWeek(Time[0])  > 0) && (TimeDayOfWeek(Time[0]) <6))
      {
      Comment("It's a trading day!!");
      if ((LASTRUN == Time[0]))
         {
         return(0);
         Comment("It's a no go, no new bar!!");
         }
      else
         {
         LASTRUN = Time[0];
         Comment("Now we check whether the trigger time has come up");
         if (TimeHour(Time[0]) != TriggerTime)
            return(0);
         }

      Print("We're now executing the main code!!");


//---- Get new daily prices

      ArrayCopySeries(prev_day_highs, MODE_HIGH, Symbol(), PERIOD_H1);
      ArrayCopySeries(prev_day_lows, MODE_LOW, Symbol(), PERIOD_H1);
      yesterday_close = iOpen(Symbol(), PERIOD_H1, 0);
      yesterday_high = prev_day_highs[ArrayMaximum(prev_day_highs, 24, 0)];
      yesterday_low = prev_day_lows[ArrayMinimum(prev_day_lows, 24, 0)];
Print("New daily stats : ", "Date : ", Month( ), "/", Day(), "Close ", yesterday_close, "  ", "High ", yesterday_high, "  ", "Low ", yesterday_low);

      maxdiff = yesterday_high - yesterday_low;
      highdiff = yesterday_high-yesterday_close;
      lowdiff = yesterday_close - yesterday_low;



// Check if there are open / pending Orders
      buy_orders_open = 0;
      sell_orders_open = 0;
      for (i=0; i<=OrdersTotal(); i++)
         {
         cnbr_uey = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         if((OrderSymbol()==Symbol()) && (OrderMagicNumber() == magicno))
            {
            if((OrderType() == OP_BUY) || (OrderType() == OP_BUYSTOP))
               buy_orders_open = buy_orders_open + 1;
            if((OrderType() == OP_SELL) || (OrderType() == OP_SELLSTOP))
               sell_orders_open = sell_orders_open + 1;
            }
         }
Print("Buy orders = ", buy_orders_open, "   Sell orders = ", sell_orders_open);




//Buystop
      price = yesterday_high - (DeadBand/10000);
      stop = price - (StopLoss/10000);
      TP = price + (TakeProfit/10000);
      lots = NormalizeDouble((RiskFactor * AccountEquity() / (Ask+(DeadBand/20000))/1000), 1);


      if (((maxdiff) >= (MaxReqSwing/10000)) && (((highdiff) >= (Margin/10000)) && ((lowdiff) >= (Margin/10000))))
         {
         if(buy_orders_open==0)
            {
            ticket = OrderSend(Symbol(), OP_BUYSTOP, lots, price, slip, stop, TP, "Buy Order", magicno, StrToTime(ExpirationTime), Blue);
            Print("Buy =  ", price, "    lots = ", lots, "    Stop = ", stop, "    TP = ", TP, "    Order no = ", ticket);
            if(ticket<0)
               {
               Print("Buy Order failed with error #",GetLastError());
               ticket = 0;
               return(0);
               }
            }

         price = yesterday_low + (DeadBand/10000);
         stop = price + (StopLoss/10000);
         TP = price - (TakeProfit/10000);
         
         if(sell_orders_open==0)
            {
            ticket = OrderSend(Symbol(), OP_SELLSTOP, lots, price, slip, stop, TP, "Sell Order", magicno, StrToTime(ExpirationTime), Blue);
            Print("Sell =  ", price, "lots = ", lots, "    Stop = ", stop, "    TP = ", TP, "     Order no = ", ticket);
            if(ticket<0)
               {
               Print("Buy Order failed with error #",GetLastError());
               ticket = 0;
               return(0);
               }
            }
         }  
      } 
   return(0);
   }
//+------------------------------------------------------------------+