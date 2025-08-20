//+-----------------------+
//| MA/MACD/CCI Expert    |
//+-----------------------+

 extern double Lots = 1;
 extern double TakeProfit = 120;
 extern double StopLoss = 200;
 

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|

int init()
  {
   return(0);
  }


//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int start()
  {

   bool     rising=false;
   bool    falling=false;

   double slA=0, slB=0;
   double tpA=0, tpB=0;

   double p=Point();
   
   double MACDM, MACDS;
   double MAH,   MAL;
   double CCIP1;

   int      cnt=0;


   // Error checking
   if(AccountFreeMargin()<(1000*Lots))        {Print("-----NO MONEY"); return(0);}
   if(Bars<100)                               {Print("-----NO BARS "); return(0);}

   // only one order per symbol
   // don't do anything till TP or SL takes the order out
   for(cnt=0;cnt<OrdersTotal();cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()==Symbol())
        {
         return(0);
        }
     }

   // calculate TP and SL for (B)id and (A)sk
   tpA=Ask+(p*TakeProfit);
   slA=Ask-(p*StopLoss);
   tpB=Bid-(p*TakeProfit);
   slB=Bid+(p*StopLoss);
   // but set to zero if user doesn't want any
   if (TakeProfit<=0) {tpA=0; tpB=0;}           
   if (StopLoss<=0)   {slA=0; slB=0;}           
   
   MAL=iMA(NULL,0,34,0,MODE_EMA,PRICE_LOW, 1);
   MAH=iMA(NULL,0,34,0,MODE_EMA,PRICE_HIGH,1);
   
   MACDM=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,  1);
   MACDS=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);

   CCIP1=iCCI(NULL,0,20,PRICE_CLOSE,1);

   // is it rising or falling
   if (High[1]>MAH && Low[1]>MAH && MACDS>0 && CCIP1>100)  { rising=true;}
   if (High[1]<MAL && Low[1]<MAL && MACDS<0 && CCIP1<-100) { falling=true;}
   
   // Open new order based on direction of cross
   if (rising)  OrderSend(Symbol(),OP_BUY,Lots,Ask,3,slA,tpA,"ZZZSMCR02",11123,0,White);
   if (falling) OrderSend(Symbol(),OP_SELL,Lots,Bid,3,slB,tpB,"ZZZSMCR02",11321,0,Red);
   
   return(0);
  }

