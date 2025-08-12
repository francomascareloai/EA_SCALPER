//+------------------------------------+
//| TRUE_SCALPER                       |
//+------------------------------------+
//
// This is the one used successfully by Jean-François 
//
// Designed for M5 but I attached it to M15 and it worked fine.
//	long if EMA3>EMA7:::EMA3<EMA7<0 
// Code Adapted from  Scalper EAs to use EMA and RSI and multiple 
//currencies


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
extern double  Lots              =0.1;
extern double  SergeyForceProfit =3;
extern int     TakeProfit        =44;
extern int     StopLoss          =90;
extern int     RSIPos            =50;
extern int     RSINeg            =50;
extern int     Slippage          =2;
extern int     abandon           =101;


// Bar handling
datetime bartime=0;
int      bartick=0;



//+------------------------------------+
//| EA load code                       |
//+------------------------------------+

int init()
  {
   // set up the symbol optimizations
   // changed the follwoing line as per Ron's Email
 //  if (Symbol()=="GBPUSD")  {TakeProfit=44; StopLoss=90; abandon=101;}
    if (Symbol()=="AUDUSD")  {TakeProfit= 60; StopLoss= 23;   abandon=103;}
    if (Symbol()=="EURAUD")  {TakeProfit= 95; StopLoss=141; abandon=33;}
    if (Symbol()=="EURCHF")  {TakeProfit= 81; StopLoss= 77; abandon=97;}
    if (Symbol()=="EURGBP")  {TakeProfit= 11; StopLoss= 77; abandon=108;}
    if (Symbol()=="EURJPY")  {TakeProfit= 38; StopLoss= 75; abandon=183;}
    if (Symbol()=="EURUSD")  {TakeProfit=196; StopLoss= 22; abandon=103;}
    if (Symbol()=="GBPCHF")  {TakeProfit= 79; StopLoss= 98; abandon=113;}
    if (Symbol()=="GBPJPY")  {TakeProfit= 13; StopLoss= 98; abandon=117;}
    if (Symbol()=="GBPUSD")  {TakeProfit= 55; StopLoss=100; abandon=69;}
    if (Symbol()=="USDCAD")  {TakeProfit= 66; StopLoss= 76; abandon=106;}
    if (Symbol()=="USDCHF")  {TakeProfit=117; StopLoss= 78; abandon=111;}
    if (Symbol()=="USDJPY")  {TakeProfit= 53; StopLoss= 74; abandon=110;}


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
   if(AccountFreeMargin()<(200*Lots))        {Print("-----NO MONEY"); 
return(0);}
   if(iBars(Symbol(),PERIOD_H1)<100)                               {Print("-----NO BARS "); 
return(0);}
   if(bartime!=Time[0])                       {bartime=Time[0]; 
bartick++;       }

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
		   NRTRStopLoss();
		   SL=NRTRStopLoss();//Ask-(StopLoss*p);
		   TP=Ask+(TakeProfit*p);
         OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,SL,TP,"BUY"+CurTime(),0,0,White);
         bartick=0;
        }
        
      //ENTRY Bid (sell, short)
      if(bullMA3<(bearMA7-p) && RSIPOS)
        {
         NRTRStopLoss();
		   SL=NRTRStopLoss();//Bid+(StopLoss*p);
		   TP=Bid-(TakeProfit*p);
         OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,SL,TP,"SELL"+CurTime(),0,0,Red);
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
         NRTRStopLoss();
         SL=NRTRStopLoss();//Bid+(StopLoss*p);
         TP=Bid-(TakeProfit*p);
         OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,SL,TP,"SELL"+CurTime(),0,0,Red);
         // bump bartick to prevent multiple buys
         bartick++;
        } // if BUY

      if(OrderType()==OP_SELL)
        {
         // close losing SELL order to avoid more loss
         OrderClose(OrderTicket(),Lots,Ask,Slippage,Red);
         // setup and trade new order 
         NRTRStopLoss();
         SL=NRTRStopLoss();//Ask-(StopLoss*p);
         TP=Ask+(TakeProfit*p);
         OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,SL,TP,"BUY"+CurTime(),0,0,White);
         // bump bartick to prevent multiple buys
         bartick++;
        } //if SELL

     } //if OrdersPerSymbol
     for(cnt=0;cnt<OrdersTotal();cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if( OrderSymbol()==Symbol() )
         {
         if(OrderType()==OP_BUY)
            {
            if (OrderMagicNumber()==0)
               {
               if(  Bid-OrderOpenPrice() > SergeyForceProfit*Point  )
                  {
                  OrderClose(OrderTicket(),Lots,Bid,0,White);
                  return(0);
                  } // if profit made
                 } // if magic
                } // if Buy
 
         if(OrderType()==OP_SELL)
            {           
            if (OrderMagicNumber()==0)
               {
               if(  OrderOpenPrice()-Ask > (SergeyForceProfit*Point)   )
                  {
                  OrderClose(OrderTicket(),Lots,Ask,0,Red);
                  return(0);
                  } // if profit made
                 } // if magic
               } //if Sell
              } // if Symbol
             } // for



   return(0);
  } // start()

//Functions

double NRTRStopLoss()   {
   /*extern*/ int AveragePeriod=10;
   /*extern*/ int CountBars=300;
   double value1[],value2[];
  {
   if (CountBars>iBars(Symbol(),PERIOD_H1)) CountBars=iBars(Symbol(),PERIOD_H1);
   SetIndexDrawBegin(0,iBars(Symbol(),PERIOD_H1)-CountBars+1);
   SetIndexDrawBegin(1,iBars(Symbol(),PERIOD_H1)-CountBars+1);
   int i,counted_bars=IndicatorCounted();
   double value;
   double trend=0,dK,AvgRange,price;
//----
   if(iBars(Symbol(),PERIOD_H1)<=AveragePeriod) return(0);
//---- initial zero
   if(counted_bars<1)
   {
      for(i=1;i<=AveragePeriod;i++) value1[iBars(Symbol(),PERIOD_H1)-i]=0.0;
      for(i=1;i<=AveragePeriod;i++) value2[iBars(Symbol(),PERIOD_H1)-i]=0.0;
   }


AvgRange=0;
for (i=1 ; i<=AveragePeriod ; i++) AvgRange+= MathAbs(iHigh(Symbol(),PERIOD_H1,i)-iLow(Symbol(),PERIOD_H1,i));
if (Symbol() == "USDJPY" || Symbol() == "GBPJPY" || Symbol() == "EURJPY")
{dK = (AvgRange/AveragePeriod)/100;}
else {dK = AvgRange/AveragePeriod;}

if (iClose(Symbol(),PERIOD_H1,CountBars-1) > iOpen(Symbol(),PERIOD_H1,CountBars-1))
   {
   value1[CountBars - 1] = iClose(Symbol(),PERIOD_H1,CountBars-1) * (1 - dK);
   trend = 1; value2[CountBars - 1] = 0.0;
   }
if (iClose(Symbol(),PERIOD_H1,CountBars-1) < iOpen(Symbol(),PERIOD_H1,CountBars-1))  {
   value2[CountBars - 1] = iClose(Symbol(),PERIOD_H1,CountBars-1) * (1 + dK);
   trend = -1; value1[CountBars - 1] = 0.0;
   }
//----
   i=CountBars-1;
   while(i>=0)
     {
value1[i]=0; value2[i]=0;
if (trend >= 0)
       {
       if (iClose(Symbol(),PERIOD_H1,i) > price) price = iClose(Symbol(),PERIOD_H1,i);
       value = price * (1 - dK);
       if (iClose(Symbol(),PERIOD_H1,i) < value)
          {
          price = iClose(Symbol(),PERIOD_H1,i);
          value = price * (1 + dK);
          trend = -1;
          }
       } 
    else
       { 
    if (trend <= 0)
       {
       if (iClose(Symbol(),PERIOD_H1,i) < price) price = iClose(Symbol(),PERIOD_H1,i);
       value = price * (1 + dK);
       if (iClose(Symbol(),PERIOD_H1,i) > value) 
          {
          price = iClose(Symbol(),PERIOD_H1,i);
          value = price * (1 - dK);
          trend = 1;
          }
       }
       }
if (trend ==  1)  {value1[i]=value; value2[i]=0.0;}
if (trend == -1)  {value2[i]=value; value1[i]=0.0;}
ObjectCreate("NRTR SL",2,0,CurTime(),value,CurTime(),value,0,0);
      i--;
     }
   return(value);
  }
  }//end NRTRStopLoss() 