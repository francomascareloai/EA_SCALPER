//+------------------------------------------------------------------+
//|                                                        NinaEA.mq4 |
//|                                                         emsjoflo |
//|                                  automaticforex.invisionzone.com |
//+------------------------------------------------------------------+
#property copyright "emsjoflo"
#property link      "automaticforex.invisionzone.com"

//---- input parameters
extern int       PeriodWATR=10;
extern double    Kwatr=1;
extern int       highlow=0;
extern int       cbars = 1000;
extern int       from  = 0;
extern int       maP  = 50;
extern double    lots=0.1;
extern int       SMAspread=0;
extern int       StopLoss=0;
extern int       Slippage=4;
double   nina, ninapast, SL=0;
int      i, buys, sells;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   
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
//----
//get moving average info
nina = iCustom(NULL,0,"NINA",PeriodWATR,Kwatr,highlow,0,1)-iCustom(NULL,0,"NINA",PeriodWATR,Kwatr,highlow,1,1);
ninapast = iCustom(NULL,0,"NINA",PeriodWATR,Kwatr,highlow,0,2)-iCustom(NULL,0,"NINA",PeriodWATR,Kwatr,highlow,1,2);

//check for open orders first 
if (OrdersTotal()>0)
   {
   buys=0;
   sells=0;
   for (i=0;i<OrdersTotal();i++)
      {
      OrderSelect(i,SELECT_BY_POS);
      if (OrderSymbol()==Symbol())
         {
         if (OrderType()== OP_BUY)
            {
            if (nina <= 0) OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Orange);
            else buys++;
            }
         if (OrderType()== OP_SELL) 
            {
            if (nina >= 0) OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Yellow);
            else sells++;
            }
         }
      }
   }
if (nina >= 0 && ninapast < 0 && buys == 0)
   {
   Print("Buy condition");
   if (StopLoss >1) SL=Ask-StopLoss*Point;
   OrderSend(Symbol(),OP_BUY,lots,Ask,Slippage,0/*(Ask-StopLoss*Point)*/,0,"NinaEA",123,0,Green);
   }
if (nina <= 0 && ninapast > 0 && sells ==0)
   {
   Print ("Sell condition");
   if (StopLoss>1) SL=Bid+StopLoss*Point;
   OrderSend(Symbol(),OP_SELL,lots,Bid,Slippage,0/*(Bid+StopLoss*Point)*/,0,"NinaEA",123,0,Red);
   }   
   
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+