//+------------------------------------+
//| TRUE_SCALPER                       |
//+------------------------------------+
//
// This is the one used successfully by Jean-François 
//
// Designed for M5 but I attached it to M15 and it worked fine.
//	long if EMA3>EMA7:::EMA3<EMA7<0 
// Code Adapted from  Scalper EAs to use EMA and RSI and multiple currencies


// v4 - Fixed a couple of ELSE statements that should NOT
//      have been there

// Spent a LOT of time debugging the backtester

// v11- added sell-&-hedge
//      added abandon-after-#-of-ticks
//      added init() section to load optimized symbol info


/*
Theory of operation

Based on MA3 of Bar[1],  MA7 of Bar[1]  and  RSI of Bar[2]

ENTRY LONG When:
MA3(Bar[1]) is greater than MA7(Bar[1]) by at least 1 pip
RSI(2-period Bar[2]) greater than 50

ENTRY SHORT When:
MA3(Bar[1]) is less than than MA7(Bar[1]) by at least 1 pip
RSI(2-period Bar[2]) less than 50

EXIT #1:
# of ticks to abandon trade is exceeded, 
trade is closed, and another is opened in the opposite direction

EXIT #2
TakeProfit (optimized) or Stoploss(optimized)

MONEY MANAGEMENT
-none-

RISK MANAGEMENT
TP/SL ~ .5  that is, SL is 2X TP mitigated by reversing hedge

TIME FRAME
15 MINUTES
also works well at 1 HOUR


*/


// variables declared here are GLOBAL in scope

#property copyright "Jacob Yego"
#property link      "http://www.PointForex.com/"
// MT4 conversion and some improvements by Ron Thompson

// generic user input
extern double Lots=0.1;
extern int    TakeProfit=44;
extern int    StopLoss=90;
extern int    RSIPos=50;
extern int    RSINeg=50;
extern int    Slippage=2;
extern int    abandon=101;


// Bar handling
datetime bartime=0;
int      bartick=0;



//+------------------------------------+
//| EA load code                       |
//+------------------------------------+

int init()
  {
   // set up the symbol optimizations
   if (Symbol()=="GBPUSD")  {TakeProfit=55; StopLoss=100; abandon=69;}
  }


//+------------------------------------+
//| EA unload code                     |
//+------------------------------------+

int deinit()
  {
  }



//+------------------------------------+
//| EA main code                       |
//+------------------------------------+

int start()
  {

   double p=Point();
   int      cnt=0;

   int      OrdersPerSymbol=0;

   double  bullMA3=0;
   double  bearMA7=0;
   double  RSI=0;
   bool    RSIPOS=0;
   bool    RSINEG=0;
   
   double TP;
   double SL;


   // Error checking & bar counting
   if(AccountFreeMargin()<(1000*Lots))        {Print("-----NO MONEY"); return(0);}
   if(Bars<100)                               {Print("-----NO BARS "); return(0);}
   if(bartime!=Time[0])                       {bartime=Time[0]; bartick++;       }

   // 3-period moving average on Bar[1]
   bullMA3=iMA(Symbol(),0,3,0,MODE_EMA,PRICE_CLOSE,1);
   // 7-period moving average on Bar[1]
   bearMA7=iMA(Symbol(),0,7,0,MODE_EMA,PRICE_CLOSE,1);
   
   // 2-period moving average on Bar[2]
   RSI=iRSI(Symbol(),0,2,PRICE_CLOSE,2);

   // Determine what polarity RSI is in
   if(RSI>RSIPos) {RSIPOS=true;  RSINEG=false;}
   if(RSI<RSINeg) {RSIPOS=false; RSINEG=true;}


   // count the open orders for this symbol 
   OrdersPerSymbol=0;
   for(cnt=OrdersTotal();cnt>=0;cnt--)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if( OrderSymbol()==Symbol() )
        {
         OrdersPerSymbol++;
        }
     }


   // place new order based on direction
   // only if no other orders are open on this Symbol 
   if(OrdersPerSymbol==0)
     {
      //ENTRY Ask(buy, long) 
      if(bullMA3>(bearMA7+p) && RSINEG)
		  {
		   SL=Ask-(StopLoss*p);
		   TP=Ask+(TakeProfit*p);
         OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,SL,TP,"BUY  "+CurTime(),0,0,White);
         bartick=0;
        }
        
      //ENTRY Bid (sell, short)
      if(bullMA3<(bearMA7-p) && RSIPOS)
        {
		   SL=Bid+(StopLoss*p);
		   TP=Bid-(TakeProfit*p);
         OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,SL,TP,"SELL "+CurTime(),0,0,Red);
         bartick=0;
        }
     } //if


   // have we run out of ticks for average time-to-profit?
   if(OrdersPerSymbol==1 && bartick==abandon)
     {

      if(OrderType()==OP_BUY)
        {
         // close losing BUY order to avoid more loss
         OrderClose(OrderTicket(),Lots,Bid,Slippage,White);
         // setup and trade new order 
         SL=Bid+(StopLoss*p);
         TP=Bid-(TakeProfit*p);
         OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,SL,TP,"SELL "+CurTime(),0,0,Red);
         // bump bartick to prevent multiple buys
         bartick++;
        } // if BUY

      if(OrderType()==OP_SELL)
        {
         // close losing SELL order to avoid more loss
         OrderClose(OrderTicket(),Lots,Ask,Slippage,Red);
         // setup and trade new order 
         SL=Ask-(StopLoss*p);
         TP=Ask+(TakeProfit*p);
         OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,SL,TP,"BUY  "+CurTime(),0,0,White);
         // bump bartick to prevent multiple buys
         bartick++;
        } //if SELL

     } //if OrdersPerSymbol

   return(0);
  } // start()




