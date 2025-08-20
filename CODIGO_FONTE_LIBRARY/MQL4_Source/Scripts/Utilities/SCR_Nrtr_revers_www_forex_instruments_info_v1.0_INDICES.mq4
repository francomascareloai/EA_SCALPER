//+------------------------------------------------------------------+
//|                                                  NRTR_Revers.mq4 |
//|                                 idea of Konkop, conversed by Rosh|
//|                           http://forexsystems.ru/phpBB/index.php |
//+------------------------------------------------------------------+
#property copyright "idea of Konkop, conversed by Rosh"
#property link      "http://forexsystems.ru/phpBB/index.php"
//----
#include <stdlib.mqh>
//----
extern double TakeProfit=4000;
extern double Lots=0.1;
extern double TrailingStop=0;
extern double StopLoss=4000;
extern double Slippage=6;
extern int ExpertMagicNumber=1007;
//---- input parameters
extern int       per=3;// период АТР
extern int       reverse=100;// пункты
extern double    k=3.0; // коэфиициент от волатильности
string trend="up";
double line=0.0;
int b=0,cnt=0;
double dif=10.0,breaklevel=10;
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
   int total,ticket;
//---- 
   if (Bars>b)
     {
      b=Bars;
      //Print("Bars=",Bars);
      Print("trend=",trend);
      //Print("per/2.0=",per/2.0);
      //Print("per/2.0=",MathRound(per/2.0));
      //Print("dif=",dif);
      //k=per;
      dif=MathRound(k*((iATR(NULL,0,per,1)/Point))/10);
      breaklevel=dif;
//----
      if (trend=="up")
        {
         line=Low[Lowest(NULL,0,MODE_LOW,per-1,2)]-dif*Point;
         //Print("line=",line,"   breaklevel=",breaklevel,"   line-Close[1]=",line-Close[1],"    Low[Lowest(NULL,0,MODE_LOW,per,1)]-line=",Low[Lowest(NULL,0,MODE_LOW,per,1)]-line);
         //if (((line-Close[1])>breaklevel*Point)||((Low[Lowest(NULL,0,MODE_LOW,per,MathRound(per/2))]-line)>=reverse*Point))
         if(((line-Close[1])>breaklevel*Point)  ||  ((Low[Lowest(NULL,0,MODE_LOW,MathRound(per/2.0),per-MathRound(per/2.0)+1)]-line)>=reverse*Point)  )
           {
            Print("меняем тренд");
            trend="down";
            total=OrdersTotal();
            for(cnt=0;cnt<total;cnt++)
              {
               OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
               if (OrderType()==OP_BUY)
                 {
                  OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Orange);
                  //return(0);
                 }
              }// for
            if (OrdersTotal()<1)
              {
               ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,Bid+StopLoss*Point,Bid-TakeProfit*Point,"sell",ExpertMagicNumber,0,Red);
               if(ticket<0)
                 {
                  Print("OrderSend failed with error #",GetLastError());
                  return(0);
                 }
               return(0);
              }
           }// if (((line-Close[1])>breaklevel*Po....  
         return(0);
        }//if (trend=="up")
      if (trend=="down")
        {
         line=High[Highest(NULL,0,MODE_HIGH,per-1,2)]+dif*Point;
         //if (((Close[1]-line)>breaklevel*Point)||((line-High[Highest(NULL,0,MODE_HIGH,per,MathRound(per/2))])>=reverse*Point))
         if (((Close[1]-line)>breaklevel*Point)||((line-High[Highest(NULL,0,MODE_HIGH,MathRound(per/2.0),per-MathRound(per/2.0)+1)])>=reverse*Point))
           {
            Print("меняем тренд");
            trend="up";
            total=OrdersTotal();
            for(cnt=0;cnt<total;cnt++)
              {
               OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
               if (OrderType()==OP_SELL)
                 {
                  OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,White);
                 }
              }// for
            if (OrdersTotal()<1)
              {
               ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,Ask-StopLoss*Point,Ask+TakeProfit*Point,"buy",ExpertMagicNumber,0,Blue);
               return(0);
               if(ticket<0)
                 {
                  Print("OrderSend failed with error #",GetLastError());
                  return(0);
                 }
               return(0);
              }
           }// if (((Close[1]-line)>breakle.....
         return(0);
        }//if (trend=="down")
     }//if (Bars>b)
//----
   return(0);
  }
//+------------------------------------------------------------------+