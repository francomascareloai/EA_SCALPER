//+------------------------------------+
//| TRUE_SCALPER                       |
//+------------------------------------+

// Designed for 5 but I attached it to 15 and it worked fine.
//	long if EMA3>EMA7:::EMA3<EMA7<0 
// Code Adapted from  Scalper EAs to use EMA and RSI and multiple currencies


// variables declared here are GLOBAL in scope

#property copyright "Jacob Yego"
#property link      "http://www.PointForex.com/"

// generic user input
extern double Lots=1.0;
extern int    MyPeriod=14;
extern int    TakeProfit=100;
extern int    StopLoss=0;
extern int    TrailingStop=5;
extern int    Slippage=2;
extern int    BuyLevel=0;
extern int    SellLevel=0;

//Bar movement, must be 0 to cause 1st movement
datetime newbar=0;


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
   int      i=0;
   int      ProfitMade=2;
   int      OrdersPerSymbol=0;

   bool      found=false;
   bool     rising=false;
   bool    falling=false;
   bool      cross=false;

   double  bull=0;
   double  bear=0;
   
   double RSI=0;
   bool  RSIPOS=0;
   bool  RSINEG=0;
   double  lobar=0;
   double  highbar=0; 
   double sl=0,tp=0;

   // Error checking
   if(AccountFreeMargin()<(1000*Lots))        {Print("-----NO MONEY"); return(0);}
   if(Bars<100)                               {Print("-----NO BARS "); return(0);}
   if (TakeProfit<10)                         {Print("TakeProfit<10"); return(0);}

   if (newbar == Time[0])                     {                        return(0);}
   newbar=Time[0];
   
   bull=iMA(Symbol(),0,3,0,MODE_EMA,PRICE_CLOSE,1);
   bear=iMA(Symbol(),0,7,0,MODE_EMA,PRICE_CLOSE,1);
   
   RSI=iRSI(Symbol(),0,2,PRICE_CLOSE,2); //>50
   if(RSI>50) RSIPOS=true;  else RSIPOS=false;
   if(RSI<50) RSINEG=false; else RSIPOS=true;

   lobar=Low[Lowest(MODE_LOW,19,19)];
   highbar=High[Highest(MODE_HIGH,19,19)];
    
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
   if(OrdersPerSymbol<1)
     {
      if(bull>bear && RSINEG)
		  {
         sl=lobar-1*p;    //(ask-(StopLoss*point));
         tp=(Bid+(TakeProfit*p));
         OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,sl,tp,"ZJMQCIDFG",11123,0,White);
         return(0);
        }
        
      if(bull<bear && RSIPOS)
        {
         sl=highbar+1*p;   //(bid+(StopLoss*point));
         tp=(Ask-(TakeProfit*p));
         OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,sl,tp,"ZJMQCIDFG",11321,0,Red);
         return(0);
        }
     } //if
	
   // close if profit target made
   for(cnt=OrdersTotal();cnt>=0;cnt--)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if( OrderSymbol()==Symbol() )
        {
         if(OrderType()==OP_BUY)
           {
            if(  Bid-OrderOpenPrice() > (ProfitMade*p)  )
              {
               OrderClose(OrderTicket(),Lots,Bid,0,White);
               return(0);
              }
           }
         if(OrderType()==OP_SELL)
           {
            if(  OrderOpenPrice()-Ask > (ProfitMade*p)   )
              {
               OrderClose(OrderTicket(),Lots,Ask,0,Red);
               return(0);
              }
           }
        }
     }

   // See if the direction changed, and close if so
   for(cnt=OrdersTotal();cnt>=0;cnt--)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if( OrderSymbol()==Symbol() )
        {
         if(OrderType()==OP_BUY)
           {
            if(bull<bear)
              {
               OrderClose(OrderTicket(),Lots,Bid,0,White);
               return(0);
              }
           }
         if(OrderType()==OP_SELL)
           {
            if(bull>bear)
              {
               OrderClose(OrderTicket(),Lots,Ask,0,Red);
               return(0);
              }
           }
        }
     }


   return(0);
  }




