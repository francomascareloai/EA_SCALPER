//+------------------------------------+
//| TRUE_SCALPER                       |
//+------------------------------------+
//
// This is the one used successfully by Jean-François 
//
// Designed for M5 but I attached it to M15 and it worked fine.
//	long if EMA3>EMA7:::EMA3<EMA7<0 
// Code Adapted from  Scalper EAs to use EMA and RSI and multiple currencies

// v7 - reverted all changes back to original intent


// variables declared here are GLOBAL in scope

#property copyright "Jacob Yego"
#property link      "http://www.PointForex.com/"
// MT4 conversion by Ron Thompson

// generic user input
extern double Lots=0.1;
extern int    TakeProfit=30;
extern int    StopLoss=175;
extern int    RSIPos=50;
extern int    RSINeg=50;
extern int    Slippage=2;
extern int    ProfitMade=5;

//+------------------------------------+
//| Custom init (usually empty on EAs) |
//|------------------------------------|
// Called ONCE when EA is added to chart
int init()
  {
   return(0);
  }


//+------------------------------------+
//| Custom deinit(usually empty on EAs)|
//+------------------------------------+
// Called ONCE when EA is removed from chart
int deinit()
  {
   return(0);
  }


//+------------------------------------+
//| EA main code                       |
//+------------------------------------+
// Called EACH TICK and possibly every Minute
// in the case that there have been no ticks

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

   // Error checking
   if(AccountFreeMargin()<(1000*Lots))        {Print("-----NO MONEY"); return(0);}
   if(Bars<100)                               {Print("-----NO BARS "); return(0);}

   
   // 3-period moving average on Bar[1]
   bullMA3=iMA(Symbol(),0,3,0,MODE_EMA,PRICE_CLOSE,1);
   // 7-period moving average on Bar[1]
   bearMA7=iMA(Symbol(),0,7,0,MODE_EMA,PRICE_CLOSE,1);
   
   // 2-period moving average(???) on Bar[2]
   RSI=iRSI(Symbol(),0,2,PRICE_CLOSE,2);
   // Determine what polarity RSI is in
   if(RSI>RSIPos) {RSIPOS=true;  RSINEG=false;}
   if(RSI<RSINeg) {RSIPOS=false; RSINEG=true;}


   OrdersPerSymbol=0;
   for(cnt=OrdersTotal();cnt>=0;cnt--)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if( OrderSymbol()==Symbol() )
        {
         OrdersPerSymbol++;
        }
     }

   // place new orders based on direction
   // only of no orders open
   if(OrdersPerSymbol<1)
     {
      if(bullMA3>bearMA7+(p*2) && RSINEG)
		  {
		   //Ask(buy, long) hedged with a SELLSTOP
         OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,Ask-(StopLoss*p),Ask+(TakeProfit*p),"BUY  "+CurTime(),0,0,White);
         return(0);
        }
        
      if(bullMA3<bearMA7-(p*2) && RSIPOS)
        {
         //Bid (sell, short)
         OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,Bid+(StopLoss*p),Bid-(TakeProfit*p),"SELL "+CurTime(),0,0,Red);
         return(0);
        }
     } //if
	
   // CLOSE order if profit target made
   for(cnt=OrdersTotal();cnt>=0;cnt--)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if( OrderSymbol()==Symbol() )
        {
         if(OrderType()==OP_BUY)
           {
            // did we make our desired BUY profit?
            if(  Bid-OrderOpenPrice() > ProfitMade*p  )
              {
               OrderClose(OrderTicket(),Lots,Bid,0,White);
              }
           } // if BUY


         if(OrderType()==OP_SELL)
           {
            // did we make our desired SELL profit?
            if(  OrderOpenPrice()-Ask > (ProfitMade*p)   )
              {
               OrderClose(OrderTicket(),Lots,Ask,0,Red);
              }
           } //if SELL
           
        } // if(OrderSymbol)
        
     } // for






   return(0);
  } // start()





