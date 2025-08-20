#property copyright "Ex4toMq4Decompiler MT4 Expert Advisors and Indicators Base of Source Codes"
#property link      "https://ex4tomq4decompiler.com/"
//---

//---- constant values ------------------------------------------------------------------------+
#define Account_Number                  898264     // write here the number of account; 0 = does not check the number of account
#define IndicatorFileName_KC            "Keltner Channels"

//---- external parameters --------------------------------------------------------------------+

extern string    DispEquityProtection         = "if true, then the expert will protect the account equity to the percent specified";
extern bool      EquityProtection            = true;          // if true, then the expert will protect the account equity to the percent specified
extern string    AverageEquityProtection      ="percent of the account to protect on a set of trades";
extern int       AccountEquityPercentProtection= 75; // percent of the account to protect on a set of trades

extern bool   UseMM                           = true;   // enable/disable auto-calculation for size of lots: false = constant size of lots (value of parameter "Lots"); true = calculate size of lots by percent from FreeMargin (parameter "Risk")
extern double Lots                            = 0.01;   // size of lots (used if UseMM = false)
extern double MinLots                         = 0.01;
extern double MaxLots                         = 100000.0;
extern double Risk                            = 3.0;
extern int    BarAndMA_Mode                   = 0; //2;      // (0-3) mode for rule "bullish(bearish) bar should be above(below) MA": 0 = does not use this rule; 1 = Close of bar should be above(below) MA; 2 = body of bar should be above(below) MA; 3 = Low(High) of bar should be above(below) MA
extern int    RangeFilter                     = 10;      // (amount pips) minimum body of candle for trading signal
extern double StopLoss                        = 0;     // (amount pips) stop-loss; 0 = without stop-loss
extern double TakeProfit                      = 10;      // (amount pips) take profit; 0 = without take profit
extern double MoveToBE                        = 5;     // (amount pips) profit when move the stop-loss level to opening price; 0 = without move to BE (option is disabled)
extern double MoveToBE_Offset                 = 2;      // (amount pips) offset of the new level stop-loss from the opening price of order, positive_value = offset to side of profit, negative_value = offset to side of loss
extern int    TrailingLimit                   = 3;      // (amount pips) distance to pending order
extern int    TrailingDistance                = 1;      // (amount pips) trailing stop; 0 = without trailing-stop
extern int    MAPeriod                        = 7;
extern int    MAShift                         = 0;
extern int    MAMethod                        = MODE_LWMA; // (0-3)
extern double MaxSpreadWithCommission         = 20.0;   // (amount pips)
extern double DefaultCommisionPoints          = 0;      // (amount pips)
extern string RangeFilterNote                 = "H-S 0-0: 250 0-1: 300 1-0: 80 1-1: 250";
extern string MAMethodNote                    = "SMA: 0 EMA: 1 SMMA: 2 LWMA 3";
extern int    Slippage                        = 3;      // (amount pips) maximum price slippage at open and close orders
extern int    MagicNumber                     = 41403;
extern string TradeComment                    = "Liquidex_MKH-M15";
extern color  ColorBuy                        = clrLime;   // color arrows of Buy-orders
extern color  ColorSell                       = clrOrange; // color arrows of Sell-orders
extern bool   ShowComment                     = true;   // enable/disable show comment on chart
extern bool   WriteDebugLog                   = false;  // enable/disable write to log the debug information
extern string ___Keltner_Channel____          = "---------------------------------------------";
extern bool   UseFilterKeltnerChannel         = false;   // true = use indicator "Keltner Channels"; false = does not use indicator "Keltner Channels"
extern int    KC_Period                       = 6; //12;     // parameter for indicator "Keltner Channels"

//----- global variables ----------------------------------------------------------------------+

extern string partInRange = "sur EURJPY par de trades entre 23h et 2 heures du mat";
extern int     EntryHourFrom = 2;          
extern int     EntryHourTo   = 24;        
extern int     FridayEndHour = 22;        
    
extern string part_iVAR = " Ivar pour supprimer les fausses entrees  periods = 5 par def ";
extern int TimeFrameiVAR = 1;
extern int    periods = 5;
extern double a1    = 0.01;
extern double a2    = 0.01;
extern double a3    = 0.55;
extern double a4    = 0.54;

//|------------------------------------------
// TICKWARE
//|__________________________________________
extern int     TicksPeriod =    33;
extern int     Length      =    33; //14; //Period of evaluation for AVG Bears and Bulls by default 14
extern int     MA_Mode     =     3; //2; //MA Mode: 0-SMA,1-EMA,2-Wilder(SMMA),3-LWMA
extern int     NumTicks    =     0; //TimeFrame in ticks (=0 if NumSecs  > 0)
extern int     NumSecs     =    70; // 0; //20; //TimeFrame in secs  (=0 if NumTicks > 0)
extern string  DispMaxBars =  " MaxBars is matrix 'size, correlated to volatility check out";

extern int     MaxBars     =    350 ;// 150; //Max Number of Bars
int maxsize                =  1200; // 1200 *0.2 (minimal time) gives a Time frame 4MN

double Ticks[];
double Bulls[];
double Bears[];
double AvgBulls[];
double AvgBears[];
double tRSI;

extern bool    UseRSI      =  false;
int  RSIdirection          = 0;

double   Hi;
double   Lo;
double   tOpen;
double   tClose;
int      tickCounter=0, barCounter, pSecs;
datetime pTime;
string   short_name, t;

int LastTm;
double max =  -1000000.0;
double min =   1000000.0;

double stoplevel, freezelevel;
string message;
////////////////////////////////////////////////////


int    slippage;
int    digits;
double point;
int    my_digits;
double my_point;
int    pips_digits;
int    lots_digits;
double minlots;
double maxlots;
string symbol;
double risk;
double maxSpreadWithCommission;
double trailingLimit;
double trailingDistance;
double rangeFilter;
bool   gotCommissionPointsFromTrade;
double commissionPoints;
double spreadHistory[30];
int    spreadHistoryCount = 0;
string objname_hline;
bool   is_testing;
double main_sl;
double main_tp;
double main_be_profit;
double main_be_offset;
static int      account_number;
static bool     is_ok;


int OnInit()
  {
   ArrayInitialize(spreadHistory,0.0);
   is_testing = IsTesting();
   symbol = Symbol();
   digits = MarketInfo(symbol,MODE_DIGITS);

   point = MarketInfo(symbol,MODE_POINT);      

   if(digits == 0)
     {
      my_point  = 1.0;
      my_digits = 0;
     }
   else
     {
      if(digits < 2)
        {
         my_point  = 0.1;
         my_digits = 1;
        }
      else
        {
         if(digits < 4)
           {
            my_point  = 0.01;
            my_digits = 2;
           }
         else
           {
            my_point  = 0.0001;
            my_digits = 4;
           }
        }
     }
   if(StringFind(symbol,"XAU") >= 0 || StringFind(symbol,"GOLD") >= 0)
     {
      my_point  = 0.1;
      my_digits = 1;
     }
   else
     {
      if(StringFind(symbol,"XAG") >= 0 || StringFind(symbol,"SILVER") >= 0)
        {
         my_point  = 0.01;
         my_digits = 2;
        }
     }
   pips_digits = digits - my_digits;
   double correction = MathPow(10,pips_digits);
   slippage = Slippage * correction;
   stoplevel = NormalizeDouble(MarketInfo(symbol,MODE_STOPLEVEL)*MarketInfo(symbol,MODE_POINT),digits);
   freezelevel  = MarketInfo(symbol, MODE_FREEZELEVEL);
      
   lots_digits = MathLog(MarketInfo(symbol,MODE_LOTSTEP)) / MathLog(0.1);
   minlots     = NormalizeDouble(MathMax(MinLots,MarketInfo(symbol,MODE_MINLOT)),lots_digits);
   maxlots     = NormalizeDouble(MathMin(MaxLots,MarketInfo(symbol,MODE_MAXLOT)),lots_digits);
   Lots = NormalizeDouble(Lots,lots_digits);
   if(Lots < minlots) Lots = minlots;
   else if(Lots > maxlots) Lots = maxlots;
   if(WriteDebugLog)
     {
      Print(StringConcatenate("Digits: ",DoubleToStr(digits,0),",  Point: ",DoubleToStr(point,digits)));
      Print(StringConcatenate("LotsDigits: ",DoubleToStr(lots_digits,0),",  MinLots: ",DoubleToStr(minlots,lots_digits),",  MaxLots: ",DoubleToStr(maxlots,lots_digits)));
     }
   risk = Risk / 100.0;
   main_sl                 = NormalizeDouble(my_point * StopLoss,               digits);
   main_tp                 = NormalizeDouble(my_point * TakeProfit,             digits);
   main_be_profit          = NormalizeDouble(my_point * MoveToBE,               digits);
   main_be_offset          = NormalizeDouble(my_point * MoveToBE_Offset,        digits);
   maxSpreadWithCommission = NormalizeDouble(my_point * MaxSpreadWithCommission,digits+1);
   trailingLimit           = NormalizeDouble(my_point * TrailingLimit,          digits);
   trailingDistance        = NormalizeDouble(my_point * TrailingDistance,       digits);
   rangeFilter             = NormalizeDouble(my_point * RangeFilter,            digits);
   commissionPoints        = NormalizeDouble(my_point * DefaultCommisionPoints, digits+1);
   gotCommissionPointsFromTrade = false;
  
   if(BarAndMA_Mode < 0 || BarAndMA_Mode > 3) BarAndMA_Mode = 0;
   account_number = Account_Number;
   objname_hline = StringConcatenate("last_history_check_",symbol,strtf(Period()),"_",DoubleToStr(MagicNumber,0));
// -------------------------------------------
  // TICK WARE RSI
   pTime = Time[0];
   pSecs = TimeCurrent();      

      maxsize = MaxBars;

      ArraySetAsSeries(Ticks, false);  
      ArrayResize(Ticks, maxsize+1);
      ArraySetAsSeries(Ticks,true);  
  
      ArraySetAsSeries(Bulls, false);  
      ArrayResize(Bulls, maxsize+1);
      ArraySetAsSeries(Bulls,true);  

        ArraySetAsSeries(Bears, false);  
      ArrayResize(Bears, maxsize+1);
      ArraySetAsSeries(Bears,true);  

      ArraySetAsSeries(AvgBulls, false);  
      ArrayResize(AvgBulls, maxsize+1);
      ArraySetAsSeries(AvgBulls,true);

      ArraySetAsSeries(AvgBears, false);  
      ArrayResize(AvgBears, maxsize+1);
      ArraySetAsSeries(AvgBears,true);

        
    //---- get commission ----------------------------------------------------------------------+
   if(!gotCommissionPointsFromTrade)
     {
      for(int i=OrdersHistoryTotal()-1; i>=0; i--)
        {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
         if(OrderProfit() == 0.0) continue;
         if(OrderSymbol() != symbol) continue;
         double order_open_price  = NormalizeDouble(OrderOpenPrice(), digits);
         double order_close_price = NormalizeDouble(OrderClosePrice(),digits);
         if(order_open_price == order_close_price) continue;
         double pip_rate = MathAbs(OrderProfit() / (order_close_price - order_open_price));
         commissionPoints = (0.0 - OrderCommission()) / pip_rate;
         if(WriteDebugLog) Print(StringConcatenate("CommissionPoints: ",DoubleToStr(commissionPoints,digits)));
         gotCommissionPointsFromTrade = true;
         break;
        }
     }
   return(INIT_SUCCEEDED);
  }
////////////////////////
bool InRange()
{
       bool Result=false;
       if((EntryHourFrom<=EntryHourTo && Hour()>=EntryHourFrom && Hour()<=EntryHourTo) ||
          (EntryHourFrom>EntryHourTo && (Hour()>=EntryHourFrom || Hour()<=EntryHourTo)))
          Result=true;
       return(Result);
}
/////////////
bool IsSafetyForTrade()
{
         bool Result=false;
        // if (DayOfWeek() == 0) return(Result);
       if(DayOfWeek()!=5 || FridayEndHour<0 || DayOfWeek()!= 0 ||
         (DayOfWeek()==5 && EntryHourFrom<=EntryHourTo && Hour()<FridayEndHour) ||
         (DayOfWeek()==5 && EntryHourFrom>EntryHourTo && FridayEndHour>=EntryHourFrom && Hour()<FridayEndHour) ||
         (DayOfWeek()==5 && EntryHourFrom>EntryHourTo && FridayEndHour<EntryHourFrom && Hour()<FridayEndHour) ||
         (DayOfWeek()==5 && EntryHourFrom>EntryHourTo && FridayEndHour<EntryHourFrom && Hour()>=FridayEndHour && Hour()>=EntryHourFrom))
         Result=true;
       return(Result);
}
////////////////////////
bool iVAR()
{
       bool Result=false;
       double iVAR_1=iCustom(symbol,TimeFrameiVAR,"iVAR_nmc",periods,0,1);
       double iVAR_2=iCustom(symbol,TimeFrameiVAR,"iVAR_nmc",periods,0,2);
             if(iVAR_2>a1 && iVAR_1>a2 && iVAR_2<a3  && iVAR_1<a4)
          Result=true;
       return(Result);
}
      
bool isNewBar()
{
   bool res=false;
   if (Time[0]!=pTime)
   {
   res=true;
   pTime=Time[0];
   }  

   return(res);
}

void OnDeinit(const int reason)
  {
   if(ShowComment) Comment("");
   return;
  }

void OnTick()
  {
   int acc_num = AccountNumber();
   int total_orders, i, signal_delete;
   int order_type;
   double order_open_price,order_close_price;
   // is_ok is nothing
   is_ok = account_number == 0 || acc_num == 0 || acc_num == account_number;

   //STEP 1
   // There is no time to calculate commission here
   // but Account equity protection is a good looking up
   if (EquityProtection && AccountEquity() <= AccountBalance()*AccountEquityPercentProtection/100)
{
message = message + "\nClosing all orders and stop trading because account money protection activated.";
Print("Closing all orders and stop trading because account money protection activated. Balance: ",AccountBalance()," Equity: ", AccountEquity());
    Comment("Closing orders because account equity protection was triggered. Balance: ",AccountBalance()," Equity: ", AccountEquity());
//  ContinueOpening=False;
return ;
    }  
  // STEP 2  
  // Before doing anything else to this :
   // Close all pending trades if outside trading hours
  
   if(WriteDebugLog)
     {
      Print(" STEP 2" );
      }
    
    total_orders = OrdersTotal()-1;
  
    if ( !InRange() || IsSafetyForTrade() )
    {  
     for (int cnt = total_orders;cnt>0;cnt--)
  {
     if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
     {
      order_type = OrderType();
   if ((OrderSymbol()==symbol && OrderMagicNumber() == MagicNumber) )
   {
if (order_type==OP_SELLLIMIT || order_type==OP_BUYLIMIT || order_type==OP_BUYSTOP || order_type==OP_SELLSTOP)
{
  signal_delete = OrderDelete(OrderTicket());
}
  }
}
  }
}  
// STEP 3
// MOVING NEW BID INSIDE MATRIX
  
   // Voir comment mettre la courbe des ticks dans une matrice raffinee
   // Ici c est la base de la logique.
   // faut il lisser la courbe avant de faire un iMAOnArray dessus ?
   // je ferais une version avec fourier ou bien IHP21
   // sinon, un slope direction line .. a voir
   if(WriteDebugLog)
     {
      Print(" STEP 3" );
      }
      
   // TICK RSI

   tickCounter++;
  
   bool tcond = false;  
   if(NumTicks > 0 && NumSecs == 0)
         tcond = tickCounter > 0 && tickCounter % NumTicks == 0;
   if(NumTicks == 0 && NumSecs > 0)
         tcond = TimeCurrent() >= pSecs + NumSecs;
  
   if(tcond)
   {
      barCounter ++;
      double oldbid = NormalizeDouble(MarketInfo(symbol,MODE_BID),digits);
            
      if(!isNewBar())
         {
         ShiftArray(0);
      
         Ticks[0] = oldbid;
         tickCounter = 0;
         }
        
      RefreshRates();
  
      if (NormalizeDouble(MarketInfo(symbol,MODE_BID),digits) != oldbid )
      {
         tickCounter ++;
         Ticks[barCounter] = NormalizeDouble(MarketInfo(symbol,MODE_BID),digits);
      }  

       Hi     = TickHighest(Ticks,TicksPeriod);  
       Lo     = TickLowest(Ticks,TicksPeriod);
        
       if(NumSecs > 0) pSecs = TimeCurrent();
  
   }
  
   if(barCounter>=1)
   {
      oldbid = NormalizeDouble(MarketInfo(symbol,MODE_BID),digits);
      if(isNewBar())
      {
           ShiftArray(1);
           Ticks[0] = oldbid;
           barCounter = 0;   // for simplification        
      }
          
      RefreshRates();
      if (NormalizeDouble(MarketInfo(symbol,MODE_BID),digits) != oldbid )
      {
         barCounter ++;
         Ticks[barCounter] = NormalizeDouble(MarketInfo(symbol,MODE_BID),digits);      
      }
                      
        Hi     = TickHighest(Ticks,TicksPeriod);  
        Lo     = TickLowest(Ticks,TicksPeriod);
  
   }
  
   if(barCounter >= MaxBars)
   {
      barCounter = 0;
   }
  
   Bulls[0] = MathAbs(Ticks[0]-Ticks[1])+(Ticks[0]-Ticks[1]);
   Bears[0] = MathAbs(Ticks[0]-Ticks[1])-(Ticks[0]-Ticks[1]);  
  
   int len = Length;
   if(MA_Mode == 2) len = 2*Length - 1;
  
   if(barCounter > len)
   {
      if(MA_Mode == 0)
      {
      AvgBulls[0] = TickSMA(Bulls, len);          
      AvgBears[0] = TickSMA(Bears, len);
      }  
      else
      if(MA_Mode == 1 || MA_Mode == 2)
      {
         if(barCounter == len+1)
         {
         AvgBulls[0] = TickSMA(Bulls, len);          
         AvgBears[0] = TickSMA(Bears, len);  
         }
         else
         if(barCounter > len+1)
         {
         AvgBulls[0] = TickEMA(Bulls, AvgBulls, len);
         AvgBears[0] = TickEMA(Bears, AvgBears, len);
         }
      }
      else
      if(MA_Mode == 3)
      {
      AvgBulls[0] = TickLWMA(Bulls, len);          
      AvgBears[0] = TickLWMA(Bears, len);
      }  
  
   if (AvgBulls[0] != 0)
         tRSI = 100.0/(1+AvgBears[0]/AvgBulls[0]);
   else
         tRSI = 0.00000001;        
   }

  
// STEP 4  
   //---- calculate average spread ------------------------------------------------------------+
   if(WriteDebugLog)
     {
      Print(" STEP 4" );
      }
   double spread = NormalizeDouble(Ask - Bid,digits);
   ArrayCopy(spreadHistory,spreadHistory,0,1,29);
   spreadHistory[29] = spread;
   if(spreadHistoryCount < 30) spreadHistoryCount++;
   double spreadHistorySum = 0.0;
   for(i=29; i>=30-spreadHistoryCount; i--) spreadHistorySum += spreadHistory[i];
   double spreadAverage = spreadHistorySum / spreadHistoryCount;
   //double askWithCommission = NormalizeDouble(Ask + commissionPoints,digits);
   //double bidWithCommission = NormalizeDouble(Bid - commissionPoints,digits);
   double spreadAverageWithCommission = NormalizeDouble(spreadAverage + commissionPoints,digits+1);
  
   //  STEP 5
   //---- detect trading signal ---------------------------------------------------------------+
   /////////////////////////////////////////////
   if(WriteDebugLog)
     {
      Print(" STEP 5" );
      }
   double stddev_ema0 =  iStdDev(symbol, 0, 20, 0, MODE_EMA, PRICE_CLOSE, 1);    
   double xhigh = iHigh(symbol, 0, 0);
   double xlow = iLow(symbol, 0, 0);
   double xopen = iOpen(symbol, 0, 0);
   //double maLow =  iMA(NULL, 0, MAPeriod, MAShift, MAMethod, PRICE_LOW, 0);
   //double maHigh =  iMA(NULL, 0, MAPeriod, MAShift, MAMethod, PRICE_HIGH, 0);
   //-----------------------
   // ORIG
   //-----------------------  
   double ma    = NormalizeDouble(iMA(symbol,0,MAPeriod,MAShift,MAMethod,PRICE_CLOSE,0),digits);
   double close = NormalizeDouble(MarketInfo(symbol,MODE_BID),digits);
   double open  = NormalizeDouble(iOpen(symbol,0,0),digits);
   double range = NormalizeDouble(MathAbs(open - close),digits);
  
   // STEP 6
   //--------- direction -------------------------------------
    if(WriteDebugLog)
     {
      Print(" STEP 6" );
      }  
   int bar_direction = 0;
   if(close > open) bar_direction++;
   else if(close < open) bar_direction--;
   bar_direction /= is_ok;
  
  
   if(UseFilterKeltnerChannel)
     {
      double kc_upper = NormalizeDouble(iCustom(NULL,0,IndicatorFileName_KC,KC_Period,0,0),digits);
      double kc_lower = NormalizeDouble(iCustom(NULL,0,IndicatorFileName_KC,KC_Period,2,0),digits);
     }
   if(BarAndMA_Mode == 0)
     {
      bool barandma_allow_buy  = true;
      bool barandma_allow_sell = true;
     }
   else
     {
      switch(BarAndMA_Mode)
        {
         case 1:
            barandma_allow_buy  = close > ma;
            barandma_allow_sell = close < ma;
            break;
         case 2:
            barandma_allow_buy  = open > ma && close > ma;
            barandma_allow_sell = open < ma && close < ma;
            break;
         case 3:
            barandma_allow_buy  = NormalizeDouble(iLow (NULL,0,0),digits) > ma;
            barandma_allow_sell = NormalizeDouble(iHigh(NULL,0,0),digits) < ma;
            break;
        }
     }
    if (UseRSI)
    {
      if (Bid < ma && open>Bid && tRSI < 50 )
      {
         RSIdirection = -1; // SELL
      }
      else
      if (Bid > ma && open<Bid  && tRSI > 50 )
      {
         RSIdirection = +1; // BUY
      }
    }
    
    // STEP 7
    ///////////   DIRECTION CALCULATING  
    // THE MOST IMPORTANT
    if(WriteDebugLog)
     {
      Print(" STEP 7 RSIdirection=",RSIdirection );
      }      
   int direction = 0;
   if(range > rangeFilter)
     {
      if(close < ma && bar_direction < 0)
        {
         if(   (!UseFilterKeltnerChannel || close < kc_lower)
            && (!UseRSI || RSIdirection < 0))  
              
                     direction++; // SELL
        }
      else
        {
         if(close > ma && bar_direction > 0)
           {
            if(   (!UseFilterKeltnerChannel || close > kc_upper)
               && (!UseRSI || RSIdirection > 0)) direction--; // BUY
           }
        }
     }
   direction /= is_ok;
  
   // STEP 8
   //---- place pending order immediately after closing previous order ------------------------+
    if(WriteDebugLog)
     {
      Print(" STEP 8 direction=",direction );
      }  
        
   int total_history_orders = OrdersHistoryTotal()-1;
   for( i = total_history_orders; i>=0; i--)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
      if(OrderMagicNumber() != MagicNumber
         || OrderSymbol() != symbol
         || OrderType() > OP_SELL )
               continue;

      datetime last_history_check = GetHLineValue(objname_hline);
      if(OrderCloseTime() < last_history_check) break;    
      if(OrderCloseTime() > last_history_check)
        {
         if(direction != 0)
           {
            if(direction < 0)
              {
               if(barandma_allow_buy)
                 {
                  order_open_price = NormalizeDouble(MarketInfo(symbol,MODE_ASK) + trailingLimit,digits);
                  double order_lots = GetLots();
                  int ticket = OrderSendEx(symbol,OP_BUYSTOP,order_lots,order_open_price,slippage,0.0,0.0,TradeComment,MagicNumber,0,ColorBuy);
                  if(ticket < 0) Print(StringConcatenate("BUYSTOP Send Error:  LT = ",DoubleToStr(order_lots,lots_digits),"  OP = ",DoubleToStr(order_open_price,digits),"  Bid = ",DoubleToStr(Bid,digits),"  Ask = ",DoubleToStr(Ask,digits)));
                 }
              }
            else
              {
               if(barandma_allow_sell)
                 {
                  order_open_price = NormalizeDouble(MarketInfo(symbol,MODE_BID) - trailingLimit,digits);
                  order_lots = GetLots();
                  ticket = OrderSendEx(symbol,OP_SELLSTOP,order_lots,order_open_price,slippage,0.0,0.0,TradeComment,MagicNumber,0,ColorSell);
                  if(ticket < 0) Print(StringConcatenate("SELLSTOP Send Error:  LT = ",DoubleToStr(order_lots,lots_digits),"  OP = ",DoubleToStr(order_open_price,digits),"  Bid = ",DoubleToStr(Bid,digits),"  Ask = ",DoubleToStr(Ask,digits)));
                 }
              }
           }
         DrawLine(objname_hline,TimeCurrent());
         break;
        }
     }
   // STEP 9    
   //---- watch orders ------------------------------------------------------------------------+
    if(WriteDebugLog)
     {
      Print(" STEP 9 direction=",direction );
      }    
   int num_orders = 0;
   //double stoplevel = NormalizeDouble(MarketInfo(symbol,MODE_STOPLEVEL)*point,digits);
   total_orders = OrdersTotal()-1;
   for(i= total_orders ; i>=0; i--)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderMagicNumber() != MagicNumber
         ||OrderSymbol() != symbol
         || OrderSymbol() != symbol)
                   continue;

      order_type = OrderType();
      if(order_type == OP_BUYLIMIT || order_type == OP_SELLLIMIT)
               continue;
      num_orders++;
      order_open_price  = NormalizeDouble(OrderOpenPrice(), digits);
      order_close_price = NormalizeDouble(OrderClosePrice(),digits);
      double order_stop_loss   = NormalizeDouble(OrderStopLoss(),  digits);
      double order_take_profit = NormalizeDouble(OrderTakeProfit(),digits);
      switch(order_type)
        {
         case OP_BUY:
            if(StopLoss > 0.0 || TakeProfit > 0.0)
              {
               bool to_modify_sl = false;
               if(StopLoss > 0.0 && order_stop_loss == 0.0)
                 {
                  double new_stop_loss = NormalizeDouble(order_open_price - main_sl,digits);
                  if(NormalizeDouble(order_close_price - new_stop_loss,digits) >= stoplevel) to_modify_sl = true;
                  else new_stop_loss = order_stop_loss;
                 }
               else new_stop_loss = order_stop_loss;
               bool to_modify_tp = false;
               if(TakeProfit > 0.0 && order_take_profit == 0.0)
                 {
                  double new_take_profit = NormalizeDouble(order_open_price + main_tp,digits);
                  if(NormalizeDouble(new_take_profit - order_close_price,digits) >= stoplevel) to_modify_tp = true;
                  else new_take_profit = order_take_profit;
                 }
               else new_take_profit = order_take_profit;
               if(to_modify_sl || to_modify_tp)
                 {
                  bool no_error = OrderModifyEx(OrderTicket(),order_open_price,new_stop_loss,new_take_profit,0,ColorBuy);
                  if(!no_error) Print(StringConcatenate("BUY Modify (SL/TP) Error:  OP = ",DoubleToStr(order_open_price,digits),"  SL = ",DoubleToStr(new_stop_loss,digits),"  TP = ",DoubleToStr(new_take_profit,digits),"  Bid = ",DoubleToStr(Bid,digits),"  Ask = ",DoubleToStr(Ask,digits)));
                  break;
                 }
              }
            if(MoveToBE > 0.0)
              {
               double new_stop_loss_be = NormalizeDouble(order_open_price + main_be_offset,digits);
               if(order_stop_loss == 0.0 || new_stop_loss_be > order_stop_loss)
                 {
                  double order_profit = NormalizeDouble(order_close_price - order_open_price,digits);
                  if(order_profit >= main_be_profit)
                    {
                     if(order_profit >= stoplevel)
                       {
                        no_error = OrderModifyEx(OrderTicket(),order_open_price,new_stop_loss_be,order_take_profit,0,ColorBuy);
                        if(!no_error) Print(StringConcatenate("BUY Modify (BE) Error:  OP = ",DoubleToStr(order_open_price,digits),"  SL = ",DoubleToStr(new_stop_loss_be,digits),"  Bid = ",DoubleToStr(Bid,digits),"  Ask = ",DoubleToStr(Ask,digits)));
                        break;
                       }
                    }
                 }
              }
            if(TrailingDistance > 0)
              {
               new_stop_loss = NormalizeDouble(order_close_price - trailingDistance,digits);
               if(order_stop_loss == 0.0 || new_stop_loss > order_stop_loss)
                 {
                  no_error = OrderModifyEx(OrderTicket(),order_open_price,new_stop_loss,order_take_profit,0,ColorBuy);
                  if(!no_error) Print(StringConcatenate("BUY Modify (TS) Error:  OP = ",DoubleToStr(order_open_price,digits),"  SL = ",DoubleToStr(new_stop_loss,digits),"  Bid = ",DoubleToStr(Bid,digits),"  Ask = ",DoubleToStr(Ask,digits)));
                  break;
                 }
              }
            break;
         case OP_SELL:
            if(StopLoss > 0.0 || TakeProfit > 0.0)
              {
               to_modify_sl = false;
               if(StopLoss > 0.0 && order_stop_loss == 0.0)
                 {
                  new_stop_loss = NormalizeDouble(order_open_price + main_sl,digits);
                  if(NormalizeDouble(new_stop_loss - order_close_price,digits) >= stoplevel) to_modify_sl = true;
                  else new_stop_loss = order_stop_loss;
                 }
               else new_stop_loss = order_stop_loss;
               to_modify_tp = false;
               if(TakeProfit > 0.0 && order_take_profit == 0.0)
                 {
                  new_take_profit = NormalizeDouble(order_open_price - main_tp,digits);
                  if(NormalizeDouble(order_close_price - new_take_profit,digits) >= stoplevel) to_modify_tp = true;
                  else new_take_profit = order_take_profit;
                 }
               else new_take_profit = order_take_profit;
               if(to_modify_sl || to_modify_tp)
                 {
                  no_error = OrderModifyEx(OrderTicket(),order_open_price,new_stop_loss,new_take_profit,0,ColorSell);
                  if(!no_error) Print(StringConcatenate("SELL Modify (SL/TP) Error:  OP = ",DoubleToStr(order_open_price,digits),"  SL = ",DoubleToStr(new_stop_loss,digits),"  TP = ",DoubleToStr(new_take_profit,digits),"  Bid = ",DoubleToStr(Bid,digits),"  Ask = ",DoubleToStr(Ask,digits)));
                  break;
                 }
              }
            if(MoveToBE > 0.0)
              {
               new_stop_loss_be = NormalizeDouble(order_open_price - main_be_offset,digits);
               if(order_stop_loss == 0.0 || new_stop_loss_be < order_stop_loss)
                 {
                  order_profit = NormalizeDouble(order_open_price - order_close_price,digits);
                  if(order_profit >= main_be_profit)
                    {
                     if(order_profit >= stoplevel)
                       {
                        no_error = OrderModifyEx(OrderTicket(),order_open_price,new_stop_loss_be,order_take_profit,0,ColorSell);
                        if(!no_error) Print(StringConcatenate("SELL Modify (BE) Error:  OP = ",DoubleToStr(order_open_price,digits),"  SL = ",DoubleToStr(new_stop_loss_be,digits),"  Bid = ",DoubleToStr(Bid,digits),"  Ask = ",DoubleToStr(Ask,digits)));
                        break;
                       }
                    }
                 }
              }
            if(TrailingDistance > 0)
              {
               new_stop_loss = NormalizeDouble(order_close_price + trailingDistance,digits);
               if(order_stop_loss == 0.0 || new_stop_loss < order_stop_loss)
                 {
                  no_error = OrderModifyEx(OrderTicket(),order_open_price,new_stop_loss,order_take_profit,0,ColorSell);
                  if(!no_error) Print(StringConcatenate("SELL Modify (TS) Error:  OP = ",DoubleToStr(order_open_price,digits),"  SL = ",DoubleToStr(new_stop_loss,digits),"  Bid = ",DoubleToStr(Bid,digits),"  Ask = ",DoubleToStr(Ask,digits)));
                  break;
                 }
              }
            break;
         case OP_BUYSTOP:
            if(!barandma_allow_buy)
              {
               Print("BarAndMA_Mode: to delete order");
               OrderDeleteEx(OrderTicket(),ColorBuy);
               break;
              }
            double current_price = NormalizeDouble(MarketInfo(symbol,MODE_ASK),digits);
            double new_open_price = NormalizeDouble(current_price + trailingLimit,digits);
            if(new_open_price < order_open_price)
              {
               no_error = OrderModifyEx(OrderTicket(),new_open_price,order_stop_loss,order_take_profit,0,ColorBuy);
               if(!no_error) Print(StringConcatenate("BUYSTOP Modify Error:  OP = ",DoubleToStr(new_open_price,digits),"  SL = ",DoubleToStr(new_stop_loss,digits),"  Bid = ",DoubleToStr(Bid,digits),"  Ask = ",DoubleToStr(Ask,digits)));
              }
            break;
         case OP_SELLSTOP:
            if(!barandma_allow_sell)
              {
               Print("BarAndMA_Mode: to delete order");
               OrderDeleteEx(OrderTicket(),ColorSell);
               break;
              }
            current_price = NormalizeDouble(MarketInfo(symbol,MODE_BID),digits);
            new_open_price = NormalizeDouble(current_price - trailingLimit,digits);
            if(new_open_price > order_open_price)
              {
               no_error = OrderModifyEx(OrderTicket(),new_open_price,order_stop_loss,order_take_profit,0,ColorSell);
               if(!no_error) Print(StringConcatenate("SELLSTOP Modify Error:  OP = ",DoubleToStr(new_open_price,digits),"  SL = ",DoubleToStr(new_stop_loss,digits),"  Bid = ",DoubleToStr(Bid,digits),"  Ask = ",DoubleToStr(Ask,digits)));
              }
            break;
        }
     }
   //---- open position -----------------------------------------------------------------------+
   if(num_orders == 0 && direction != 0 && spreadAverageWithCommission <= maxSpreadWithCommission)
     {
      if(direction < 0)
        {
         order_open_price = MarketInfo(symbol,MODE_ASK); // NormalizeDouble(MarketInfo(symbol,MODE_ASK) + trailingLimit,digits);
         order_lots = GetLots();
         ticket = OrderSendEx(symbol,OP_BUY,order_lots,order_open_price,slippage,0.0,0.0,TradeComment,MagicNumber,0,ColorBuy);
         if(ticket < 0) Print(StringConcatenate("BUY Send Error:  LT = ",DoubleToStr(order_lots,lots_digits),"  OP = ",DoubleToStr(order_open_price,digits),"  SL = ",DoubleToStr(order_stop_loss,digits),"  Bid = ",DoubleToStr(Bid,digits),"  Ask = ",DoubleToStr(Ask,digits)));
        }
      else
        {
         order_open_price = MarketInfo(symbol,MODE_BID); // NormalizeDouble(MarketInfo(symbol,MODE_BID) - trailingLimit,digits);
         order_lots = GetLots();
         ticket = OrderSendEx(symbol,OP_SELL,order_lots,order_open_price,slippage,0.0,0.0,TradeComment,MagicNumber,0,ColorSell);
         if(ticket < 0) Print(StringConcatenate("SELL Send Error:  LT = ",DoubleToStr(order_lots,lots_digits),"  OP = ",DoubleToStr(order_open_price,digits),"  SL = ",DoubleToStr(order_stop_loss,digits),"  Bid = ",DoubleToStr(Bid,digits),"  Ask = ",DoubleToStr(Ask,digits)));
        }
     }
   //---- show comment ------------------------------------------------------------------------+
   if(ShowComment || WriteDebugLog)
     {
      if(!UseFilterKeltnerChannel) string comm_kc = "";
      else comm_kc = StringConcatenate("Keltner:  upper = ",DoubleToStr(kc_upper,digits),",  lower = ",DoubleToStr(kc_lower,digits),"\n");
      
      message = StringConcatenate("Copyrighted by www.sbginter.com & www.eaihub.com\n",
                                         "Contact us : info@sbginter.com / info@eaihub.com\n",
                                         "Licence type : Opensource\n",
                                         "Account Name : ",AccountName(),"\n",
                                         "Account Number : ",DoubleToStr(AccountNumber(),0),"\n",
                                         "AvgSpread : ",DoubleToStr(spreadAverage,digits),"\n",
                                         "Balance : ",DoubleToStr(AccountBalance(),2)," $\n",
                                         "Equity : ",DoubleToStr(AccountEquity(),2)," $\n",
                                         "Commission rate : ",DoubleToStr(commissionPoints,digits+1),"\n",
                                         "Real avg. spread : ",DoubleToStr(spreadAverageWithCommission,digits+1),"\n",
                                         "MA = ",DoubleToStr(ma,digits),"\n",
                                         "Range = ",DoubleToStr(range/my_point,pips_digits)," pips\n",
                                         comm_kc
                                        );
      if(spreadAverageWithCommission > maxSpreadWithCommission)
        {
         message = StringConcatenate(message,"\n",
                                     "Robot is OFF :: Real avg. spread is too high for this scalping strategy ( ",DoubleToStr(spreadAverageWithCommission,digits+1)," > ",DoubleToStr(maxSpreadWithCommission,digits+1)," )"
                                    );
        }
      if(ShowComment) Comment(message);
      if(WriteDebugLog) if(num_orders != 0 || direction != 0) PrintLineLine(message);
     }
    
   return;
  }


//---- PrintLineLine --------------------------------------------------------------------------+

void PrintLineLine(string text)
  {
   int start_pos;
   int position = -1;
   while(position < StringLen(text))
     {
      start_pos = position + 1;
      position = StringFind(text,"\n",start_pos);
      if(position == -1)
        {
         Print(StringSubstr(text,start_pos));
         return;
        }
      Print(StringSubstr(text,start_pos,position-start_pos));
     }
  }


//---- DrawLine -------------------------------------------------------------------------------+

void DrawLine(string sName, double dPrice, color cLineClr = CLR_NONE)
   {
    if(ObjectFind(sName) == -1) ObjectCreate(sName,OBJ_HLINE,0,0,0);
    ObjectSet(sName,OBJPROP_PRICE1,dPrice);
    ObjectSet(sName,OBJPROP_COLOR, cLineClr);
   }


//---- GetHLineValue --------------------------------------------------------------------------+

double GetHLineValue(string name)
  {
   if(ObjectFind(name) == -1) return(-1);
   else return(ObjectGet(name,OBJPROP_PRICE1));
  }

//---- strtf ----------------------------------------------------------------------------------+

string strtf(int tf)
  {
   switch(tf)
     {
      case PERIOD_M1:  return("M1");
      case PERIOD_M5:  return("M5");
      case PERIOD_M15: return("M15");
      case PERIOD_M30: return("M30");
      case PERIOD_H1:  return("H1");
      case PERIOD_H4:  return("H4");
      case PERIOD_D1:  return("D1");
      case PERIOD_W1:  return("W1");
      case PERIOD_MN1: return("MN1");
      default:         return("Unknown timeframe");
     }
  }


//---- GetLots --------------------------------------------------------------------------------+

double GetLots()
  {
   if(!UseMM) double lots = Lots;
   else
     {
      double money = AccountBalance() * AccountLeverage() * risk;
      lots = NormalizeDouble(money / MarketInfo(symbol,MODE_LOTSIZE),lots_digits);
     }
   if(lots < minlots) lots = minlots;
   else if(lots > maxlots) lots = maxlots;
   return(lots);
  }

//---- ErrorDescription -----------------------------------------------------------------------+

string ErrorDescription(int error_code)
  {
   switch(error_code)
     {
      case 0:
      case 1:    string error_string="no error";                                          break;
      case 2:    error_string="common error";                                             break;
      case 3:    error_string="invalid trade parameters";                                 break;
      case 4:    error_string="trade server is busy";                                     break;
      case 5:    error_string="old version of the client terminal";                       break;
      case 6:    error_string="no connection with trade server";                          break;
      case 7:    error_string="not enough rights";                                        break;
      case 8:    error_string="too frequent requests";                                    break;
      case 9:    error_string="malfunctional trade operation (never returned error)";     break;
      case 64:   error_string="account disabled";                                         break;
      case 65:   error_string="invalid account";                                          break;
      case 128:  error_string="trade timeout";                                            break;
      case 129:  error_string="invalid price";                                            break;
      case 130:  error_string="invalid stops";                                            break;
      case 131:  error_string="invalid trade volume";                                     break;
      case 132:  error_string="market is closed";                                         break;
      case 133:  error_string="trade is disabled";                                        break;
      case 134:  error_string="not enough money";                                         break;
      case 135:  error_string="price changed";                                            break;
      case 136:  error_string="off quotes";                                               break;
      case 137:  error_string="broker is busy (never returned error)";                    break;
      case 138:  error_string="requote";                                                  break;
      case 139:  error_string="order is locked";                                          break;
      case 140:  error_string="long positions only allowed";                              break;
      case 141:  error_string="too many requests";                                        break;
      case 145:  error_string="modification denied because order too close to market";    break;
      case 146:  error_string="trade context is busy";                                    break;
      case 147:  error_string="expirations are denied by broker";                         break;
      case 148:  error_string="amount of open and pending orders has reached the limit";  break;
      case 149:  error_string="hedging is prohibited";                                    break;
      case 150:  error_string="prohibited by FIFO rules";                                 break;
      case 4000: error_string="no error (never generated code)";                          break;
      case 4001: error_string="wrong function pointer";                                   break;
      case 4002: error_string="array index is out of range";                              break;
      case 4003: error_string="no memory for function call stack";                        break;
      case 4004: error_string="recursive stack overflow";                                 break;
      case 4005: error_string="not enough stack for parameter";                           break;
      case 4006: error_string="no memory for parameter string";                           break;
      case 4007: error_string="no memory for temp string";                                break;
      case 4008: error_string="not initialized string";                                   break;
      case 4009: error_string="not initialized string in array";                          break;
      case 4010: error_string="no memory for array\' string";                             break;
      case 4011: error_string="too long string";                                          break;
      case 4012: error_string="remainder from zero divide";                               break;
      case 4013: error_string="zero divide";                                              break;
      case 4014: error_string="unknown command";                                          break;
      case 4015: error_string="wrong jump (never generated error)";                       break;
      case 4016: error_string="not initialized array";                                    break;
      case 4017: error_string="dll calls are not allowed";                                break;
      case 4018: error_string="cannot load library";                                      break;
      case 4019: error_string="cannot call function";                                     break;
      case 4020: error_string="expert function calls are not allowed";                    break;
      case 4021: error_string="not enough memory for temp string returned from function"; break;
      case 4022: error_string="system is busy (never generated error)";                   break;
      case 4050: error_string="invalid function parameters count";                        break;
      case 4051: error_string="invalid function parameter value";                         break;
      case 4052: error_string="string function internal error";                           break;
      case 4053: error_string="some array error";                                         break;
      case 4054: error_string="incorrect series array using";                             break;
      case 4055: error_string="custom indicator error";                                   break;
      case 4056: error_string="arrays are incompatible";                                  break;
      case 4057: error_string="global variables processing error";                        break;
      case 4058: error_string="global variable not found";                                break;
      case 4059: error_string="function is not allowed in testing mode";                  break;
      case 4060: error_string="function is not confirmed";                                break;
      case 4061: error_string="send mail error";                                          break;
      case 4062: error_string="string parameter expected";                                break;
      case 4063: error_string="integer parameter expected";                               break;
      case 4064: error_string="double parameter expected";                                break;
      case 4065: error_string="array as parameter expected";                              break;
      case 4066: error_string="requested history data in update state";                   break;
      case 4099: error_string="end of file";                                              break;
      case 4100: error_string="some file error";                                          break;
      case 4101: error_string="wrong file name";                                          break;
      case 4102: error_string="too many opened files";                                    break;
      case 4103: error_string="cannot open file";                                         break;
      case 4104: error_string="incompatible access to a file";                            break;
      case 4105: error_string="no order selected";                                        break;
      case 4106: error_string="unknown symbol";                                           break;
      case 4107: error_string="invalid price parameter for trade function";               break;
      case 4108: error_string="invalid ticket";                                           break;
      case 4109: error_string="trade is not allowed in the expert properties";            break;
      case 4110: error_string="longs are not allowed in the expert properties";           break;
      case 4111: error_string="shorts are not allowed in the expert properties";          break;
      case 4200: error_string="object is already exist";                                  break;
      case 4201: error_string="unknown object property";                                  break;
      case 4202: error_string="object is not exist";                                      break;
      case 4203: error_string="unknown object type";                                      break;
      case 4204: error_string="no object name";                                           break;
      case 4205: error_string="object coordinates error";                                 break;
      case 4206: error_string="no specified subwindow";                                   break;
      default:   error_string="unknown error";
     }
   return(error_string);
  }

//---------------------------------------------------------------------------------------------+
//---------------------------------------------------------------------------------------------+
string OrderTypeToStr(int order_type)
  {
   switch(order_type)
     {
      case OP_BUY: string result = "Buy";       break;
      case OP_SELL:       result = "Sell";      break;
      case OP_BUYLIMIT:   result = "BuyLimit";  break;
      case OP_SELLLIMIT:  result = "SellLimit"; break;
      case OP_BUYSTOP:    result = "BuyStop";   break;
      case OP_SELLSTOP:   result = "SellStop";  break;
      default:            result = "Unknown";   break;
     }
   return(result);
  }

//---------------------------------------------------------------------------------------------+
//---- OrderSendEx ----------------------------------------------------------------------------+
//---------------------------------------------------------------------------------------------+
int OrderSendEx(string order_symbol, int order_type, double order_lots, double order_open_price, int order_slippage, double order_stop_loss, double order_take_profit, string order_comment = "", int order_magic_number = 0, datetime order_expiration = 0, color order_color = CLR_NONE, string parent_fun_name = "")
  {
#define number_attempts_send        3
#define number_attempts_send_select 3
   if(StringLen(parent_fun_name) > 0) parent_fun_name = StringConcatenate(parent_fun_name," -> ");
   int err_129  = 0;
   int err_130  = 0;
   int err_137  = 0;
   int err_138  = 0;
   int err_4107 = 0;
   if(order_symbol == "" || order_symbol == "0") order_symbol = symbol;
   int order_digits  = MarketInfo(order_symbol,MODE_DIGITS);
   order_open_price  = NormalizeDouble(order_open_price,order_digits);
   order_stop_loss   = NormalizeDouble(order_stop_loss,order_digits);
   order_take_profit = NormalizeDouble(order_take_profit,order_digits);
   while(true)
     {
      if(!is_testing)
        {
         if(!IsExpertEnabled())
           {
            int ticket = -1;
            break;
           }
        }
      RefreshRates();
      double ask = NormalizeDouble(MarketInfo(order_symbol,MODE_ASK),order_digits);
      double bid = NormalizeDouble(MarketInfo(order_symbol,MODE_BID),order_digits);
      //double stoplevel = NormalizeDouble(MarketInfo(order_symbol,MODE_STOPLEVEL)*MarketInfo(order_symbol,MODE_POINT),order_digits);
      if(order_type > OP_SELL)
        {
         if(order_open_price <= 0.0)
           {
            ticket = -1;
            break;
           }
         if((order_type % 2) == OP_BUY) double current_price = ask;
         else current_price = bid;
         switch(order_type)
           {
            case OP_BUYLIMIT:
            case OP_SELLSTOP:
               double distance = NormalizeDouble(current_price - order_open_price,order_digits);
               break;
            case OP_BUYSTOP:
            case OP_SELLLIMIT:
               distance = NormalizeDouble(order_open_price - current_price,order_digits);
               break;
           }
         if(distance < stoplevel)
           {
            ticket = -1;
            break;
           }
         if(order_slippage < 0) order_slippage = 0;
        }
      else
        {
         if(order_type == OP_BUY)
           {
            if(order_open_price <= 0.0) order_open_price = ask;
           }
         else
           {
            if(order_open_price <= 0.0) order_open_price = bid;
           }
         if(order_slippage < 0) order_slippage = slippage;
        }
      if(order_stop_loss != 0)
        {
         if((order_type % 2) == OP_BUY) distance = NormalizeDouble(order_open_price - order_stop_loss,order_digits);
         else distance = NormalizeDouble(order_stop_loss - order_open_price,order_digits);
         if(distance < stoplevel)
           {
            ticket = -1;
            break;
           }
        }
      if(order_take_profit != 0)
        {
         if((order_type % 2) == OP_BUY) distance = NormalizeDouble(order_take_profit - order_open_price,order_digits);
         else distance = NormalizeDouble(order_open_price - order_take_profit,order_digits);
         if(distance < stoplevel)
           {
            ticket = -1;
            break;
           }
        }
      if(!is_testing) while(IsTradeContextBusy()) Sleep(1000);
      GetLastError();
      ticket = OrderSend(order_symbol,order_type,order_lots,order_open_price,order_slippage,order_stop_loss,order_take_profit,order_comment,order_magic_number,order_expiration,order_color);
      if(ticket < 0)
        {
         int err = GetLastError();
         Print(StringConcatenate(parent_fun_name,"OrderSendEx: OrderSend(",OrderTypeToStr(order_type),") ",ErrorDescription(err)));
         bool cont = false;
         switch(err)
           {
            case    0:
               Sleep(10000);
               break;
            case    6:
               //Sleep(10000);
               //if(IsConnected()) cont = true;
               break;
            case  128:
               Sleep(70000);
               break;
            case  129:
               Sleep(6000);
               err_129++;
               if(err_129 <= number_attempts_send) cont = true;
               break;
            case  130:
               Sleep(6000);
               err_130++;
               if(err_130 <= number_attempts_send) cont = true;
               break;
            case  134:
               Sleep(6000);
               break;
            case  135:
               cont = true;
               break;
            case  136:
               Sleep(6000);
               cont = true;
               break;
            case  137:
               Sleep(20000);
               err_137++;
               if(err_137 <= number_attempts_send) cont = true;
               break;
            case  138:
               err_138++;
               if(err_138 <= number_attempts_send) cont = true;
               break;
            case  140:
               if((order_type % 2) == OP_BUY)  cont = true;
               break;
            case  142:
               Sleep(70000);
               break;
            case  143:
               Sleep(70000);
               break;
            case  146:
               while(IsTradeContextBusy()) Sleep(1000);
               cont = true;
               break;
            case  147:
               order_expiration = 0;
               cont = true;
               break;
            case 4000:
               Sleep(10000);
               break;
            case 4107:
               err_4107++;
               if(err_4107 <= number_attempts_send) cont = true;
               break;
            case 4110:
               if((order_type % 2) == OP_SELL)  cont = true;
               break;
            case 4111:
               if((order_type % 2) == OP_BUY)  cont = true;
               break;
           }
         if(!cont) break;
        }
      else break;
     }
   return(ticket);
  }
//---------------------------------------------------------------------------------------------+
//---- OrderModifyEx --------------------------------------------------------------------------+
//---------------------------------------------------------------------------------------------+
bool OrderModifyEx(int order_ticket, double new_open_price, double new_stop_loss, double new_take_profit, datetime new_expiration = -1, color order_color = CLR_NONE, string parent_fun_name = "")
  {
#define number_attempts_modify        3
#define number_attempts_modify_select 3
#define number_attempts_modify_wait   30
   if(StringLen(parent_fun_name) > 0) parent_fun_name = StringConcatenate(parent_fun_name," -> ");
   int err_129 = 0;
   int err_130 = 0;
   int err_137 = 0;
   int err_138 = 0;
   int err_145 = 0;
   while(true)
     {
      if(!is_testing)
        {
         if(!IsExpertEnabled())
           {
            bool error = false;
            break;
           }
        }
      RefreshRates();
      int counter_attempts_select = 0;
      while(counter_attempts_select < number_attempts_modify_select)
        {
         if(OrderSelect(order_ticket,SELECT_BY_TICKET)) break;
         Print(StringConcatenate(parent_fun_name,"OrderModifyEx: OrderSelect() error = ",ErrorDescription(GetLastError())));
         Sleep(1000);
         counter_attempts_select++;
        }
      if(counter_attempts_select >= number_attempts_modify_select)
        {
         error = false;
         break;
        }
      if(OrderCloseTime() != 0)
        {
         error = true;
         break;
        }
      string order_symbol = OrderSymbol();
      int order_type = OrderType();
      int order_digits = MarketInfo(order_symbol,MODE_DIGITS);
      new_open_price  = NormalizeDouble(new_open_price, order_digits);
      new_stop_loss   = NormalizeDouble(new_stop_loss,  order_digits);
      new_take_profit = NormalizeDouble(new_take_profit,order_digits);
      double order_open_price  = NormalizeDouble(OrderOpenPrice(), order_digits);
      double order_close_price = NormalizeDouble(OrderClosePrice(),order_digits);
      double order_stop_loss   = NormalizeDouble(OrderStopLoss(),  order_digits);
      double order_take_profit = NormalizeDouble(OrderTakeProfit(),order_digits);
      datetime order_expiration = OrderExpiration();
      //double stoplevel = NormalizeDouble(MarketInfo(order_symbol,MODE_STOPLEVEL)*MarketInfo(order_symbol,MODE_POINT),order_digits);
      bool to_modify = false;
      if(order_type > OP_SELL)
        {
         if(new_open_price < 0 || new_open_price == order_open_price)
           {
            double modify_open_price = order_open_price;
            if(NormalizeDouble(MathAbs(modify_open_price - order_close_price),order_digits) < stoplevel)
              {
               error = false;
               break;
              }
           }
         else
           {
            modify_open_price = new_open_price;
            to_modify = true;
            bool to_modify2 = true;
            switch(order_type)
              {
               case OP_BUYLIMIT:
               case OP_SELLSTOP:
                  if(NormalizeDouble(order_close_price - modify_open_price,order_digits) < stoplevel) to_modify2 = false;
                  break;
               case OP_BUYSTOP:
               case OP_SELLLIMIT:
                  if(NormalizeDouble(modify_open_price - order_close_price,order_digits) < stoplevel) to_modify2 = false;
                  break;
              }
            if(!to_modify2)
              {
               error = false;
               break;
              }
           }
         if(new_expiration < 0 || new_expiration == order_expiration) double modify_expiration = order_expiration;
         else
           {
            modify_expiration = new_expiration;
            to_modify = true;
           }
         double second_price = modify_open_price;
        }
      else
        {
         modify_open_price = order_open_price;
         modify_expiration = order_expiration;
         second_price = order_close_price;
        }
      if(new_stop_loss < 0 || new_stop_loss == order_stop_loss) double modify_stop_loss = order_stop_loss;
      else
        {
         modify_stop_loss = new_stop_loss;
         to_modify = true;
        }
      if(new_take_profit < 0 || new_take_profit == order_take_profit) double modify_take_profit = order_take_profit;
      else
        {
         modify_take_profit = new_take_profit;
         to_modify = true;
        }
      if(!to_modify)
        {
         error = true;
         break;
        }
      if((order_type % 2) == OP_BUY)
        {
         if(modify_stop_loss != 0.0 && NormalizeDouble(second_price - modify_stop_loss,order_digits) < stoplevel)
           {
            error = false;
            break;
           }
         if(modify_take_profit != 0.0 && NormalizeDouble(modify_take_profit - second_price,order_digits) < stoplevel)
           {
            error = false;
            break;
           }
        }
      else
        {
         if(modify_stop_loss != 0.0 && NormalizeDouble(modify_stop_loss - second_price,order_digits) < stoplevel)
           {
            error = false;
            break;
           }
         if(modify_take_profit != 0.0 && NormalizeDouble(second_price - modify_take_profit,order_digits) < stoplevel)
           {
            error = false;
            break;
           }
        }
      if(!is_testing)
        {
         for(int i=0; i<number_attempts_modify_wait; i++)
           {
            if(!IsTradeContextBusy()) break;
            Sleep(1000);
           }
         if(i >= number_attempts_modify_wait) continue;
        }
      GetLastError();
      error = OrderModify(order_ticket,modify_open_price,modify_stop_loss,modify_take_profit,modify_expiration,order_color);
      if(!error)
        {
         int err = GetLastError();
         Print(StringConcatenate(parent_fun_name,"OrderModifyEx(",OrderTypeToStr(order_type),",",DoubleToStr(order_ticket,0),") error = ",ErrorDescription(err)));
         bool cont = false;
         switch(err)
           {
            case    0:
               Sleep(10000);
               cont = true;
               break;
            case    6:
               Sleep(10000);
               if(IsConnected()) cont = true;
               break;
            case  128:
               Sleep(70000);
               cont = true;
               break;
            case  129:
               Sleep(6000);
               err_129++;
               if(err_129 <= number_attempts_modify) cont = true;
               break;
            case  130:
               Sleep(6000);
               err_130++;
               if(err_130 <= number_attempts_modify) cont = true;
               break;
            case  134:
               Sleep(6000);
               cont = true;
               break;
            case  135:
               cont = true;
               break;
            case  136:
               Sleep(6000);
               cont = true;
               break;
            case  137:
               Sleep(20000);
               err_137++;
               if(err_137 <= number_attempts_modify) cont = true;
               break;
            case  138:
               err_138++;
               if(err_138 <= number_attempts_modify) cont = true;
               break;
            case  142:
               Sleep(70000);
               cont = true;
               break;
            case  143:
               Sleep(70000);
               cont = true;
               break;
            case  145:
               //Sleep(20000);
               //err_145++;
               //if(err_145 <= number_attempts_modify) cont = true;
               break;
            case  146:
               while(IsTradeContextBusy()) Sleep(1000);
               cont = true;
               break;
            case  147:
               new_expiration = 0;
               cont = true;
               break;
            case 4000:
               Sleep(10000);
               cont = true;
               break;
           }
         if(!cont) break;
        }
      else break;
     }
   return(error);
  }

//---------------------------------------------------------------------------------------------+
//---- OrderDeleteEx --------------------------------------------------------------------------+
//---------------------------------------------------------------------------------------------+
bool OrderDeleteEx(int order_ticket, color order_color = CLR_NONE, string parent_fun_name = "")
  {
#define number_attempts_delete        3
#define number_attempts_delete_select 3
   if(StringLen(parent_fun_name) > 0) parent_fun_name = StringConcatenate(parent_fun_name," -> ");
   int err_129 = 0;
   int err_130 = 0;
   int err_137 = 0;
   int err_138 = 0;
   while(true)
     {
      if(!is_testing)
        {
         if(!IsExpertEnabled())
           {
            bool error = false;
            break;
           }
        }
      RefreshRates();
      int counter_attempts_select = 0;
      while(counter_attempts_select < number_attempts_delete_select)
        {
         if(OrderSelect(order_ticket,SELECT_BY_TICKET)) break;
         Print(StringConcatenate(parent_fun_name,"OrderDeleteEx: OrderSelect() error = ",ErrorDescription(GetLastError())));
         Sleep(1000);
         counter_attempts_select++;
        }
      if(counter_attempts_select >= number_attempts_delete_select)
        {
         error = false;
         break;
        }
      if(OrderCloseTime() != 0)
        {
         error = true;
         break;
        }
      if(!is_testing) while(IsTradeContextBusy()) Sleep(1000);
      int order_type = OrderType();
      GetLastError();
      if(order_type <= OP_SELL) error = OrderClose(order_ticket,OrderLots(),OrderClosePrice(),slippage,order_color);
      else error = OrderDelete(order_ticket,order_color);
      if(!error)
        {
         int err = GetLastError();
         Print(StringConcatenate(parent_fun_name,"OrderDeleteEx(",OrderTypeToStr(order_type),",",DoubleToStr(order_ticket,0),") error = ",ErrorDescription(err)));
         bool cont = false;
         switch(err)
           {
            case    0:
               Sleep(10000);
               cont = true;
               break;
            case    6:
               Sleep(10000);
               if(IsConnected()) cont = true;
               break;
            case  128:
               Sleep(70000);
               cont = true;
               break;
            case  129:
               Sleep(6000);
               err_129++;
               if(err_129 <= number_attempts_delete) cont = true;
               break;
            case  130:
               Sleep(6000);
               err_130++;
               if(err_130 <= number_attempts_delete) cont = true;
               break;
            case  134:
               Sleep(6000);
               cont = true;
               break;
            case  135:
               cont = true;
               break;
            case  136:
               Sleep(6000);
               cont = true;
               break;
            case  137:
               Sleep(20000);
               err_137++;
               if(err_137 <= number_attempts_delete) cont = true;
               break;
            case  138:
               err_138++;
               if(err_138 <= number_attempts_delete) cont = true;
               break;
            case  142:
               Sleep(70000);
               cont = true;
               break;
            case  143:
               Sleep(70000);
               cont = true;
               break;
            case  145:
               //Sleep(20000);
               //cont = true;
               break;
            case  146:
               while(IsTradeContextBusy()) Sleep(1000);
               cont = true;
               break;
            case 4000:
               Sleep(10000);
               cont = true;
               break;
           }
         if(!cont) break;
        }
      else break;
     }
   return(error);
  }

//---------------------------------------------------------------------------------------------+
//---- OrderCloseEx ---------------------------------------------------------------------------+
//---------------------------------------------------------------------------------------------+
bool OrderCloseEx(int order_ticket, double order_lots, double order_close_price, int order_slippage, color order_color = CLR_NONE, string parent_fun_name = "")
  {
#define number_attempts_close           3
#define number_attempts_close_select    3
#define number_attempts_close_wait      30
   if(StringLen(parent_fun_name) > 0) parent_fun_name = StringConcatenate(parent_fun_name," -> ");
   int err_129 = 0;
   int err_130 = 0;
   int err_137 = 0;
   int err_138 = 0;
   while(true)
     {
      if(!is_testing)
        {
         if(!IsExpertEnabled())
           {
            bool error = false;
            break;
           }
        }
      RefreshRates();
      int counter_attempts_select = 0;
      while(counter_attempts_select < number_attempts_close_select)
        {
         if(OrderSelect(order_ticket,SELECT_BY_TICKET))
           {
            int order_digits = MarketInfo(OrderSymbol(),MODE_DIGITS);
            break;
           }
         Print(StringConcatenate(parent_fun_name,"OrderCloseEx: OrderSelect() error = ",ErrorDescription(GetLastError())));
         Sleep(1000);
         counter_attempts_select++;
        }
      if(counter_attempts_select >= number_attempts_close_select)
        {
         error = false;
         break;
        }
      if(OrderCloseTime() != 0)
        {
         error = true;
         break;
        }
      int order_type = OrderType();
      if(!is_testing)
        {
         for(int i=0; i<number_attempts_close_wait; i++)
           {
            if(!IsTradeContextBusy()) break;
            Sleep(1000);
           }
         if(i >= number_attempts_close_wait) continue;
        }
      RefreshRates();
      GetLastError();
      order_close_price = NormalizeDouble(OrderClosePrice(),order_digits);
      error = OrderClose(order_ticket,order_lots,order_close_price,order_slippage,order_color);
      if(!error)
        {
         int err = GetLastError();
         Print(StringConcatenate(parent_fun_name,"OrderCloseEx(",OrderTypeToStr(order_type),",",DoubleToStr(order_ticket,0),") error = ",ErrorDescription(err)));
         bool cont = false;
         switch(err)
           {
            case    0:
               Sleep(10000);
               if(OrderSelect(order_ticket,SELECT_BY_TICKET)) if(OrderCloseTime() == 0) cont = true;
               break;
            case    6:
               Sleep(10000);
               if(IsConnected()) cont = true;
               break;
            case  128:
               Sleep(70000);
               if(OrderSelect(order_ticket,SELECT_BY_TICKET)) if(OrderCloseTime() == 0) cont = true;
               break;
            case  129:
               Sleep(6000);
               err_129++;
               if(err_129 <= number_attempts_close) cont = true;
               break;
            case  130:
               Sleep(6000);
               err_130++;
               if(err_130 <= number_attempts_close) cont = true;
               break;
            case  135:
               cont = true;
               break;
            case  136:
               Sleep(6000);
               cont = true;
               break;
            case  137:
               Sleep(20000);
               err_137++;
               if(err_137 <= number_attempts_close) cont = true;
               break;
            case  138:
               err_138++;
               if(err_138 <= number_attempts_close) cont = true;
               break;
            case  142:
               Sleep(70000);
               if(OrderSelect(order_ticket,SELECT_BY_TICKET)) if(OrderCloseTime() == 0) cont = true;
               break;
            case  143:
               Sleep(70000);
               if(OrderSelect(order_ticket,SELECT_BY_TICKET)) if(OrderCloseTime() == 0) cont = true;
               break;
            case  145:
               //Sleep(20000);
               //cont = true;
               break;
            case  146:
               while(IsTradeContextBusy()) Sleep(1000);
               cont = true;
               break;
            case 4000:
               Sleep(10000);
               if(OrderSelect(order_ticket,SELECT_BY_TICKET)) if(OrderCloseTime() == 0) cont = true;
               break;
           }
         if(!cont) break;
        }
      else break;
     }
   return(error);
  }


////////////////////////////////////////////////:::::
//+------------------------------------------------------------------+
/// TICK RSI
void ShiftArray(int mode)
{
   if(mode==0)
   {
      for(int cnt=barCounter; cnt >= 0; cnt--)
      {
      Ticks[cnt] = Ticks[cnt-1];
      Bulls[cnt] = Bulls[cnt-1];
      Bears[cnt] = Bears[cnt-1];
      AvgBulls[cnt] = AvgBulls[cnt-1];
      AvgBears[cnt] = AvgBears[cnt-1];

      }
   }
   else
   {
      for(cnt=1; cnt <= barCounter; cnt++)
      {
      Ticks[cnt-1] = Ticks[cnt];
      Bulls[cnt-1] = Bulls[cnt];
      Bears[cnt-1] = Bears[cnt];
      AvgBulls[cnt-1] = AvgBulls[cnt];
      AvgBears[cnt-1] = AvgBears[cnt];
          
      Ticks[cnt] = 0.0;
      Bulls[cnt] = 0.0;
      Bears[cnt] = 0.0;
      AvgBulls[cnt] = 0.0;
      AvgBears[cnt] = 0.0;

      }
   }
}

//+------------------------------------------------------------------+
double TickLowest(double& array[],int per)
{
   double lowest = 1000000;
   for(int i = 0;i < per;i++) lowest = MathMin(lowest,array[i]);
   return(lowest);
}                

double TickHighest(double& array[],int per)
{
   double highest = 0;
   for(int i = 0;i < per;i++) highest = MathMax(highest,array[i]);
   return(highest);
}                


double TickSMA(double &array[],int per)
{
   double Sum = 0;
   for(int i = 0;i < per;i++)
   {
      Sum += array[i];
   }
   return(Sum/per);
}                

double TickEMA(double& array1[],double& array2[],int per)
{
   return(array2[1] + 2.0/(1+per)*(array1[0] - array2[1]));
}

double TickLWMA(double& array[],int per)
{
   double Sum = 0;
   double Weight = 0;
  
      for(int i = 0;i < per;i++)
      {
      Weight+= (per - i);
      Sum += array[i]*(per - i);
      }
   if(Weight>0) double lwma = Sum/Weight;
   else lwma = 0;
   return(lwma);
}