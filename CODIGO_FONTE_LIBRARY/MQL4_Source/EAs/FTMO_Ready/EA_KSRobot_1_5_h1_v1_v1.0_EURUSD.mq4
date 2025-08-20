//+------------------------------------------------------------------+
//|                 Kijun Sen Robot                                  |
//|                 Copyright ® 2005 Noam Koren (noamko@shani.net).  |
//|                 http://www.metaquotes.ru                         |
//+------------------------------------------------------------------+
//+-------------------------------------------------------------------------------------------------------------+
//| Based on Akash discussion at Moneytech ("Great technique for beginners")                                    |
//|                                                                                                             |
//| Disclaimer :   Distributed for forward testing purposes.                                                    |
//|                This expert was never tested on a live account - use at your own risk!                       |
//|                In other words - DO NOT USE ON A LIVE ACCOUNT !                                              |
//|                                                                                                             |
//| Attach to 30 Minute chart                                                                                   |
//|                                                                                                             |
//|  $Log: KSRobot.mq4,v $                                                                                      |
//|  Revision 1.5  2005/10/18 11:10:09  noam                                                                    |
//|  1) Added alerts                                                                                            |
//|                                                                                                             |
//|  2) Modified S/L rules to reduce average S/L size - if a bar closes with MA in the wrong direction          |
//|     exit if B/E was not hit yet.                                                                            |
//|                                                                                                             |
//|  3) Modified Entry rule - Wait for BID to cross KS for Long and ASK to cross down for Short.                |
//|     This helps to filter out faulty signals.                                                                |
//|                                                                                                             |
//|  4) Modified Entry rule - only enter if KS is Horizontal OR in the same direction of entry.                 |
//|                                                                                                             |
//| Revision 1.4  2005/10/08 18:19:58  noam                                                                     |
//|  1) Added slope: allows filtering out trades if the slope of KS line is too vertical (too = defined by user)|
//|  2) Added optimized values per currency. This can be overrider by setting UseOptimizedValues to false.      |
//|  3) Added a comment to provide some information to the user while the expert is attached.                   |
//|                                                                                                             |
//| Experimental                                                                                                |
//|   E1) Added two experimental stop loss tactics (not used unless by default):                                |
//|   	a) PSAR                                                                                                |
//|   	b) Exit if not at BE after X bars                                                                      |
//|                                                                                                             |
//|   Revision 1.3  2005/09/21 01:00:47  noam                                                                   |
//|   Use limit order / market order depending on current price                                                 |
//|   Do not clear cross value until order is sent                                                              |
//|   Added some printouts                                                                                      |
//|                                                                                                             |
//|   Revision 1.2  2005/09/20 17:11:12  noam                                                                   |
//|   Added disclaimer                                                                                          |
//|   Added price normalization                                                                                 |
//|   Adjusted time limits to fit MT4 time                                                                      |
//|                                                                                                             |
//|   Revision 1.1  2005/09/19 20:34:57  noam                                                                   |
//|   Initial Kijun Sen Robot version                                                                           |
//|   Backtested on 30M GBP/USD                                                                                 |
//|                                                                                                             | 
//| 1) Find a way to improve profit taking - TS is good but misses much of trendy moves. Maybe                  |
//|    switch to EMA signal once X pips are secure?                                                             |
//|                                                                                                             |
//| 2) Find out why entering only once per bar hits performance.                                                |
//|                                                                                                             |
//| 3) Add 2% money management rule.                                                                            |
//+-------------------------------------------------------------------------------------------------------------+
#property copyright "Noam Koren"
/* expert specific parameters */
#define EXPERT_COLOR    Yellow
#define EXPERT_STRING   "Kijun Sen Robot"
#define EXPERT_MAGIC    13
#define UP       1
#define DOWN    -1
#define NEUTRAL  0
/*  
    Optimized results 
    GBP/USD:
    4.38	1000.00	8.38%	StopLoss=50 	BreakEven=9 TrailingStop=10 	MAfilter=6 	TakeProfit=120
    EUR/USD:
    2.68	1520.00	12.24%	StopLoss=60 	BreakEven=9 TrailingStop=6 	   MAfilter=6 	TakeProfit=120      
*/
int      MaxOpenPositions=1;
/* Default parameters. */
int      TakeProfit     =120;  /* default 120 */
extern int      StopLoss       =50;   /* 50  very imporant to allow for a substaintial movement in the other direction */
extern int      BreakEven      =9;    /* default = 9 */
extern int      TrailingStop   =10;   /* default 10 */
extern int      MAfilter       =6;    /* MA must be at least 6 pips away from KS in order to be valid */
extern bool     UseOptimizedValues=true;
/* MM */
extern double   Lots   =1;
//----
int TenkanSen          =6;
int KijunSen           =12;
int Senkou             =24;
/* globals */
double lastbid         =0.0;
double lastask         =0.0;
double longcross       =0.0;
double shortcross      =0.0;
double longentry       =0.0;
double shortentry      =0.0;
int daystart           =7; /* 5AM GMT */
int dayend             =19;/* 5PM GMT */
int MAdir              =NEUTRAL;
int precision          =4;
int lastbar            =0;
bool newbar            =false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  int init()  
  {
     if (UseOptimizedValues==true)
     {
        /* set parameters based on pair */
      if (Symbol()=="GBPUSD")  {StopLoss=50; BreakEven=9; TrailingStop=10; MAfilter=6;}
      if (Symbol()=="EURUSD")  {StopLoss=60; BreakEven=9; TrailingStop=6;  MAfilter=6;}
     }
   precision=SymbolPrecision();
   lastbar=Time[0];
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
{
   return(0);  
}
/* expert specific utility functions */
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  int SymbolPrecision() 
  {
   return(MarketInfo(Symbol(), MODE_DIGITS));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OpenPosition()
  {
   double KS      =iIchimoku(NULL, 0, TenkanSen, KijunSen, Senkou, MODE_KIJUNSEN, 0);
   double KS1     =iIchimoku(NULL, 0, TenkanSen, KijunSen, Senkou, MODE_KIJUNSEN, 1);
   double KS2     =iIchimoku(NULL, 0, TenkanSen, KijunSen, Senkou, MODE_KIJUNSEN, 2);
   double Ema20   =iMA(NULL,0,20,0,MODE_LWMA,PRICE_CLOSE,0);
   double PEma20  =iMA(NULL,0,20,0,MODE_LWMA,PRICE_CLOSE,1);
   double PSAR    =iSAR(NULL, 0, 0.02, 0.2, 0); /* fast parabolic for tight exits */
//----
   if (lastbid==0.0) lastbid=Bid;
   if (lastask==0.0) lastask=Ask;
    /* Make sure the time is right */
   if(Hour() < daystart || Hour() > dayend-1)return(0);
    /* KS cross */
     if(Open[0] < KS && lastbid < KS && Bid > KS && longcross==0 && KS>=KS2) 
     {
        /* the cross is only interesting if the KS line is above the MA  */
        if(Ema20 < KS - MAfilter * Point)
        {
         longcross=KS;
         shortcross=0;
        }
     }
     if(Open[0] > KS && lastask > KS && Ask < KS && shortcross==0 && KS<=KS2) 
     {
        /* the cross is only interesting if the KS line is under the MA  */
        if(Ema20 > KS + MAfilter * Point)
        {
         shortcross=KS;
         longcross=0;
        }
     }
    /* check MA direction */
     if(PEma20 < Ema20 )
     {
      MAdir=UP;
     }
     if(PEma20 > Ema20 )
     {
      MAdir=DOWN;
     }
    /* once the MA is pointing in the right direction set the the entry price to be the current KS */
     if (MAdir==UP && longcross!=0 && longentry==0)
     {
      longentry=NormalizeDouble( KS, precision );
      return(1);
     }
    /* once the MA is pointing in the right direction set the the entry price to be the current KS */
     if (MAdir==DOWN && shortcross!=0 && shortentry==0)
     {
      shortentry=NormalizeDouble( KS, precision );
      return(-1);
     }
   lastbid=Bid;
   lastask=Ask;
   //----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ClosePosition()
  {
   double PEma20  =iMA(NULL,0,20,0,MODE_LWMA,PRICE_CLOSE,1);
   double PPEma20 =iMA(NULL,0,20,0,MODE_LWMA,PRICE_CLOSE,2);
//----
     if(OrderType()==OP_BUY )
     {
        if (newbar && PEma20 < PPEma20 && OrderStopLoss() < OrderOpenPrice() )
        {
         return(1);
        }
     }
     if(OrderType()==OP_SELL )
     {
        if (newbar && PEma20 > PPEma20 && OrderStopLoss() > OrderOpenPrice() )
        {
         return(-1);
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int cnt, experttickets, ticket, total, i, pos, action=0, method;
   double hardstop;
   datetime ticketexpiration=0;
    /* make sure that the char is valid */
     if (Bars<100)
     {
      Print("Invalid chart: less than 100 bars!");
      return(-1);
     }
     if(( Hour() < daystart || Hour() > dayend-1))
     {
      Comment("\nTrading halted. (will start again at ", daystart, " AM )\n");
      }
       else 
      {
      Comment("\nExpert is active. (will halt at ", dayend, " PM )\n");
      Comment("\nTS = ", TrailingStop, " BE = ", BreakEven, " SL = ", StopLoss, " MAfilter  = ", MAfilter,"\n");
     }
   total=OrdersTotal();
     if (Time[0]==lastbar) 
     {
      newbar=false;
      }
       else 
      {
      lastbar=Time[0];
      newbar=true;
     }
    /* Only allow one open position at a time (per expert)- so if there is an open position - do not open another one. */
     for(cnt=0,experttickets=0;cnt<total;cnt++) 
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
        if(OrderSymbol()==Symbol() && OrderMagicNumber()==EXPERT_MAGIC) 
        {
         experttickets=experttickets+1;
        }
     }
     if(experttickets<MaxOpenPositions) 
     {
        /* Set the number of lots - or exit if there is not enough margin */
      Lots=Lots;
        ticketexpiration=CurTime() + PERIOD_M30 * 60; /* orders are valid for half an hour */
        /* OpenPosition() has state so calling it again will mess up the results - this is why I call it
         * once and remember the return value before acting 
         */
      action=OpenPosition();
        /* check for long position (BUY) possibility */
        if(action==1)
        {
         if (Ask > longentry + 4 * Point)    method=OP_BUYLIMIT;
         if (Ask==longentry)   method=OP_BUY;
           if (Ask < longentry) 
           {
            longentry=Ask;
            method=OP_BUY;
           }
         hardstop=NormalizeDouble( (longentry-StopLoss*Point), precision) ;
         Alert("KSRobot ", Symbol(), " Go Long @ ", longentry, "!");
         ticket=OrderSend(Symbol(),method,Lots,longentry,4,hardstop,Ask+TakeProfit*Point,EXPERT_STRING,EXPERT_MAGIC,ticketexpiration,White);
           if(ticket>0) 
           {
              if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) 
              {
               Print("BUY LIMIT  order sent : ",OrderOpenPrice(), "Ask = ", Ask, "\n" );
              }
            longcross=0;
            }
             else 
            {
            Print("Error opening BUY LIMIT order : ",GetLastError(), " SL = ", hardstop, " Ask = ", Ask, " Entry = ", longentry, " TP =",Ask+TakeProfit*Point, " Method = ", method,  "\n");
           }
         longentry=0;
//----
         return(0);
        }
        /* check for short position (SELL) possibility */
        if(action==-1 )
        {
         hardstop=NormalizeDouble( (shortentry+StopLoss*Point), precision) ;
         Alert("KSRobot ", Symbol(), " KS Go Short @ ", shortentry, "!");
//----
         if (Bid < shortentry - 4 * Point)   method=OP_SELLLIMIT;
         if (Bid==shortentry)  method=OP_SELL;
           if (Bid > shortentry) 
           {
            shortentry=Bid;
            method=OP_SELL;
           }
         ticket=OrderSend(Symbol(),method,Lots,shortentry,4,hardstop,Bid-TakeProfit*Point,EXPERT_STRING,EXPERT_MAGIC,ticketexpiration,Red);
           if(ticket>0) 
           {
              if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) 
              {
               Print("SELL LIMIT order sent : ",OrderOpenPrice(), "Bid = ", Bid, "\n");
              }
            shortcross=0;
            }
             else 
            {
            Print("Error opening SELL LIMIT order : ",GetLastError(), " SL = ", hardstop, " Bid = ", Bid, " Entry = ", shortentry, " TP =",Bid-TakeProfit*Point, "method = ", method, "\n" );
           }
         shortentry=0;
//----
         return(0);
        }
        /* do nothing */
      return(0);
     }
    /* if there are open positions - check if they need to be closed */
     for(cnt=0;cnt<total;cnt++) 
     {
      lastbid=Bid;
      lastask=Ask;
//----
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
        /* Check if there are positions that were opened by this expert for this symbol */
        if(OrderType()<=OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==EXPERT_MAGIC)
        {
            /* handle long position */
           if(OrderType()==OP_BUY) 
           {
                /* close if condition met */
              if(ClosePosition()==1)
              {
               OrderClose(OrderTicket(),OrderLots(),Bid,3,EXPERT_COLOR);
               return(0);
              }
                /* set BreakEven if set */
              if (BreakEven>0)
              {
                 if(Bid-OrderOpenPrice()>Point*BreakEven) 
                 {
                    if(OrderStopLoss()<OrderOpenPrice()) 
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+Point*1,OrderTakeProfit(),0,Gray);
                    }
                 }
              }
                /* update trailing stop */
              if(TrailingStop>0) 
              {
                 if(Bid-OrderOpenPrice()>Point*(TrailingStop)) 
                 {
                    if(OrderStopLoss()<Bid-Point*TrailingStop) 
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Gray);
                     return(0);
                    }
                 }
              }
            }
             else 
            {
            /* handle short position */
            /* close if condition met */
              if (ClosePosition()==-1) 
              {
               OrderClose( OrderTicket(),OrderLots(),Ask,3,EXPERT_COLOR );
               return(0);
              }
                /* set BreakEven if set */
              if (BreakEven>0)
              {
                 if(OrderOpenPrice()-Ask>Point*BreakEven) 
                 {
                    if(OrderStopLoss()>OrderOpenPrice()) 
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-Point*1,OrderTakeProfit(),0,Gray);
                    }
                 }
              }
                /* update trailing stop */
              if(TrailingStop>0) 
              {
                 if(OrderOpenPrice()-Ask>Point*(TrailingStop)) 
                 {
                    if(OrderStopLoss()>Ask+Point*TrailingStop) 
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Gray);
                     return(0);
                    }
                 }
              }
           }
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+