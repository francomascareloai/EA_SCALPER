//+-------------------------------------------------------------------------+
//| RPM5_MT4_[ea].mq4                                                       |
//| Copyright © 2005,yahoo.com/group/MetaTrader_Experts_and_Indicators/                                                       |
//| http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/|
//+-------------------------------------------------------------------------+


#property copyright "Copyright © 2005,yahoo.com/group/MetaTrader_Experts_and_Indicators/"
#property link      "http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/"

#define   MAGIC     20050817
extern int    HourSetOrder = 9;    // start time
extern int BullBearPeriod=5;
extern double lots         = 1.0;           // 
extern double TrailingStop = 15;            // trail stop in points
extern double takeProfit   = 150;            // recomended  no more than 150
extern double stopLoss     = 25;             // do not use s/l
extern double slippage     = 3;
extern bool pivots = true;
double dHigh, dLow;     // day extrema 
int    WidthChannel;    // width of channel
double day_high=0;
double day_low=0;
double yesterday_high=0;
double yesterday_open=0;
double yesterday_low=0;
double yesterday_close=0;
double today_open=0;
double today_high=0;
double today_low=0;
double rates_d1[2][6];
double P=0;
double fib_projection1=0.214;
double fib_projection2=0.382;
double fib_projection3=0.618;
double fib_projection4=0.768;
extern string nameEA       = "DayTrading";  // EA identifier. Allows for several co-existing EA with different values

double bull,bear;
double PrevBBE,CurrentBBE;
double realTP, realSL,b,s,sl,tp;
bool isBuying = false, isSelling = false, isClosing = false;
int cnt, ticket;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init() {
//---- exit if period is greater than daily charts
if(Period() > 1440)
{//1
Print("Error - Chart period is greater than 1 day.");
return(-1); // then exit
}//1
   //---- Get new daily prices
ArrayCopyRates(rates_d1, Symbol(), PERIOD_D1);

yesterday_close = rates_d1[1][4];
yesterday_open = rates_d1[1][1];
today_open = rates_d1[0][1];
yesterday_high = rates_d1[1][3];
yesterday_low = rates_d1[1][2];
day_high = rates_d1[0][3];
day_low = rates_d1[0][2];

P = (yesterday_high + yesterday_low + yesterday_close) / 3;

  // return(0);
  // }
   
   ObjectCreate("Fractal Fibo Retracement",OBJ_FIBO,0,P,fib_projection1,fib_projection2,fib_projection3,fib_projection4 );
   
  if(ObjectFind("P line") != 0)
      {
      ObjectCreate("P line", OBJ_HLINE, 0, Time[40], P);
      ObjectSet("P line", OBJPROP_STYLE, STYLE_DASH);
      ObjectSet("P line", OBJPROP_COLOR, Magenta);
      }
      else
      {
      ObjectMove("P line", 0, Time[40], P);
     }//2
     if (!IsTesting()) {
    ObjectCreate("HDayBorder", OBJ_TREND, 0, 0,0, 0,0);
    ObjectCreate("LDayBorder", OBJ_TREND, 0, 0,0, 0,0);
    }
     return(0);
}
//+------------------------------------------------------------------+
//|  the determination of the day extreem                               |
//+------------------------------------------------------------------+
int DefineDayExtremums() {
  int CurrentDay=Day(), sb=0;

  dHigh=0; dLow=500;
  while (TimeDay(Time[sb])==CurrentDay && sb<1500) {
    if (TimeHour(Time[sb])<=HourSetOrder) {
      dHigh = MathMax(dHigh, High[sb]);
      dLow  = MathMin(dLow, Low[sb]);
    }
    sb++;
  }
  WidthChannel = (dHigh - dLow) / Point;
  Comment("Width of channel: " + WidthChannel);
}
    //+------------------------------------------------------------------+
//|  mapping the day channel                                                                         |
//+------------------------------------------------------------------+
int DrawDayChannel() {
  if (!IsTesting()) {
    ObjectSet("HDayBorder", OBJPROP_TIME1, StrToTime(TimeToStr(Time[0], TIME_DATE)+" 00:00"));
    ObjectSet("HDayBorder", OBJPROP_TIME2, Time[0]);
    ObjectSet("HDayBorder", OBJPROP_PRICE1, dHigh);
    ObjectSet("HDayBorder", OBJPROP_PRICE2, dHigh);
    ObjectSet("HDayBorder", OBJPROP_COLOR, Blue);
    ObjectSet("HDayBorder", OBJPROP_STYLE, STYLE_DASH);

    ObjectSet("LDayBorder", OBJPROP_TIME1, StrToTime(TimeToStr(Time[0], TIME_DATE)+" 00:00"));
    ObjectSet("LDayBorder", OBJPROP_TIME2, Time[0]);
    ObjectSet("LDayBorder", OBJPROP_PRICE1, dLow);
    ObjectSet("LDayBorder", OBJPROP_PRICE2, dLow);
    ObjectSet("LDayBorder", OBJPROP_COLOR, Red);
    ObjectSet("LDayBorder", OBJPROP_STYLE, STYLE_DASH);
  }
}
  

//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit() {
ObjectDelete("Fractal Fibo Retracement");
ObjectDelete("P Line");
if (!IsTesting()) {
    ObjectDelete("HDayBorder");
    ObjectDelete("LDayBorder");
  }
   return(0);
}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start() {
DefineDayExtremums();
  DrawDayChannel();
   // Check for invalid bars and takeprofit
   if(Bars < 200) {
      Print("Not enough bars for this strategy - ", nameEA);
      return(-1);
   }
   calculateIndicators();                      // Calculate indicators' value   
  
   // Control open trades
   int totalOrders = OrdersTotal();
   int numPos = 0;
   for(cnt=0; cnt<totalOrders; cnt++) {        // scan all orders and positions...
      OrderSelect(cnt, SELECT_BY_POS);         // the next line will check for ONLY market trades, not entry orders
      if(OrderSymbol() == Symbol() && OrderType() <= OP_SELL ) {   // only look for this symbol, and only orders from this EA      
         numPos++;
         if(OrderType() == OP_BUY) {           // Check for close signal for bought trade
               
            if(TrailingStop > 0) {             // Check trailing stop
               if(Bid-OrderOpenPrice() > TrailingStop*Point)
                {
                  if(OrderStopLoss() < (Bid - TrailingStop*Point))
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-TrailingStop*Point,OrderTakeProfit(),0,Blue);
               }
            }
         } else {                              // Check sold trade for close signal
            
            if(TrailingStop > 0) {             // Control trailing stop
               if(OrderOpenPrice() - Ask > TrailingStop*Point)
                {
                  if(OrderStopLoss() == 0 || OrderStopLoss() > Ask + TrailingStop*Point)
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask+TrailingStop*Point,OrderTakeProfit(),0,Red);
               }           
            } 
         }
      }
   }
   
   
   // If there is no open trade for this pair and this EA
   if(numPos < 1) {   
      if(AccountFreeMargin() < 1000*lots) {
         Print("Not enough money to trade ", lots, " lots. Strategy:", nameEA);
         return(0);
      }
      if(isBuying && !isSelling && !isClosing) {  // Check for BUY entry signal
         sl = Ask - stopLoss * Point;
         tp = Bid + takeProfit * Point;
         
        // ticket = OrderSend(OP_BUY,lots,Ask,slippage,realSL,realTP,nameEA,16384,0,Red);  // Buy
         //OrderSend(OP_BUY,lots,Ask,slippage,realSL,realTP,0,0,Red);
         OrderSend(Symbol(),OP_BUY,lots,Ask,slippage,sl,tp,nameEA+CurTime(),0,0,Green);
         Comment(sl);
         if(ticket < 0)
            Print("OrderSend (",nameEA,") failed with error #", GetLastError());
        
      }
      if(isSelling && !isBuying && !isClosing) {  // Check for SELL entry signal
          sl = Bid + stopLoss * Point;
          tp = Ask - takeProfit * Point;
        // ticket = OrderSend(NULL,OP_SELL,lots,Bid,slippage,realSL,realTP,nameEA,16384,0,Red); // Sell
         OrderSend(Symbol(),OP_SELL,lots,Bid,slippage,sl,tp,nameEA+CurTime(),0,0,Red);
         if(ticket < 0)
            Print("OrderSend (",nameEA,") failed with error #", GetLastError());
        
      }
   }
   return(0);
}

void calculateIndicators() {    // Calculate indicators' value   
 

   bull = iBullsPower(NULL,0,BullBearPeriod,PRICE_CLOSE,1);
   bear = iBearsPower(NULL,0,BullBearPeriod,PRICE_CLOSE,1);
//Comment("bull+bear= ",bull + bear);
  CurrentBBE             = iCustom(NULL, 0, "BullsBearsEyes",13,0,0.5,300,0,0);
  PrevBBE                = iCustom(NULL, 0, "BullsBearsEyes",13,0,0.5,300,0,1);
   
  
   b = ((1 * Point) + (iATR(NULL,0,5,1) * 1.5));
   s = ((1 * Point) + (iATR(NULL,0,5,1) * 1.5));
   // Check for BUY, SELL, and CLOSE signal   
   //isBuying  = (bull+bear>0);
   //isSelling = (bull+bear<0);
   isBuying  = (CurrentBBE>0.50);
   isSelling = (CurrentBBE<0.50);

   isClosing = false;

 for (int i = 0; i < OrdersTotal(); i++) 
 {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);

      if (OrderType() == OP_BUY)
       {
     TrailingStop=b;
        
      if (Bid - OrderOpenPrice() > TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT))
        {
           if (OrderStopLoss() < Bid - TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT))
               {
               OrderModify(OrderTicket(), OrderOpenPrice(), Bid - TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT), OrderTakeProfit(), Red);
            }
         }
      } else if (OrderType() == OP_SELL) 
      {
      TrailingStop=s;
         if (OrderOpenPrice() - Ask > TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT))
          {
            if ((OrderStopLoss() > Ask + TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT)) || 
                  (OrderStopLoss() == 0)) {
               OrderModify(OrderTicket(), OrderOpenPrice(),
                  Ask + TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT), OrderTakeProfit(), Red);
            }
         }
     }
 } 
    
return(0);
   
}

//+------------------------------------------------------------------+