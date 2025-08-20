//+------------------------------------------------------------------+
//|                                                         Gold.mq4 |
//|                                              Copyright 2016, AM2 |
//|                                      http://www.forexsystems.biz |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, AM2"
#property link      "http://www.forexsystems.biz"
#property version   "1.00"
#property strict

//--- Inputs
extern double Lots         = 0.1;   // лот
extern double KLot         = 2;     // умножение лота
extern double MaxLot       = 5;     // максимальный лот
extern double Depo         = 20000; // увеличенное депо
extern double Sup          = 1000;  // поддержка низы
extern double Res          = 1500;  // сопротивление верхи
extern int    StopLoss     = 5000;  // лось
extern int    TakeProfit   = 5000;  // язь
extern int    Slip         = 30;    // реквот
extern int    Count        = 100;   // максимальное количество поз
extern int    Magic        = 12;    // магик

datetime t=0;
double Price=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
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
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void PutOrder(int type,double price)
  {
   int r=0;
   color clr=Green;
   double sl=0,tp=0;

   if(type==1 || type==3 || type==5)
     {
      clr=Red;
      if(StopLoss>0)   sl=NormalizeDouble(price+StopLoss*Point,Digits);
      if(TakeProfit>0) tp=NormalizeDouble(price-TakeProfit*Point,Digits);
     }

   if(type==0 || type==2 || type==4)
     {
      clr=Blue;
      if(StopLoss>0)   sl=NormalizeDouble(price-StopLoss*Point,Digits);
      if(TakeProfit>0) tp=NormalizeDouble(price+TakeProfit*Point,Digits);
     }

   r=OrderSend(NULL,type,Lots,NormalizeDouble(price,Digits),Slip,sl,tp,"",Magic,0,clr);
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTrades()
  {
   int count=0;
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
           {
            if(OrderType()<2) count++;
           }
        }
     }
   return(count);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Last()
  {
   int result=0;
   if(OrderSelect(OrdersHistoryTotal()-1,SELECT_BY_POS,MODE_HISTORY))
     {
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
        {
         if(OrderProfit()>0)
           {
            result=1;//tp  
           }
        }
     }
   return(result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAll()
  {
   bool cl;
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
           {
            if(OrderType()==OP_BUY) cl=OrderClose(OrderTicket(),OrderLots(),Bid,Slip,Blue);
            if(OrderType()==OP_SELL) cl=OrderClose(OrderTicket(),OrderLots(),Ask,Slip,Red);
           }
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//| OnTick function                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(AccountEquity()>Depo)
     {
      CloseAll();
      return;
     }
     
   if(CountTrades()<Count)
     {
      if(Bid>Sup && Bid<Res)
        {
         if(CountTrades()<1)
           {
            PutOrder(1,Bid);
            PutOrder(0,Ask);
            Price=Bid;
           }

         if(Last()==1 && (Bid>Price+TakeProfit*Point || Bid<Price-TakeProfit*Point))
           {
            PutOrder(1,Bid);
            PutOrder(0,Ask);
            Price=Bid;
           }
        }
     }

   Comment("\n Equity: ",DoubleToStr(AccountEquity(),Digits));
  }
//+------------------------------------------------------------------+
