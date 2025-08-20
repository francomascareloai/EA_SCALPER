//+------------------------------------------------------------------+
//|                                                     day open.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
extern double LOT=0.01;
extern int Profit=10;
int bars;
bool trade;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
trade=false;
bars=iBars(Symbol(),PERIOD_D1);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
if (bars!=iBars(Symbol(),PERIOD_D1)){bars=iBars(Symbol(),PERIOD_D1);trade=true;}

if (trade){
            OrderSend(Symbol(),OP_BUY,LOT,Ask,2,0,0,NULL,0123456,0,clrRed);
            OrderSend(Symbol(),OP_SELL,LOT,Bid,2,0,0,NULL,0123456,0,clrRed);
            trade=false;
          }
   
  int tot=OrdersTotal();
  
  for(int i=0; i<=tot;i++)
  {OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
   if (OrderSymbol()==Symbol() &&OrderMagicNumber()==0123456)
      {
       if(OrderType()==OP_BUY){if (Bid>= OrderOpenPrice()+Profit*Point)OrderClose(OrderTicket(),LOT,Bid,2,clrAqua);}
      
       if(OrderType()==OP_SELL){if (Ask<= OrderOpenPrice()-Profit*Point)OrderClose(OrderTicket(),LOT,Ask,2,clrAqua);}
      }
  
  }
  
  }
//+------------------------------------------------------------------+
