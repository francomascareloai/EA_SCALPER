//+------------------------------------------------------------------+
//|                                                  FreeScalper.mq4 |
//|                                              Copyright 2016, AM2 |
//|                                      http://www.forexsystems.biz |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, AM2"
#property link      "http://www.forexsystems.biz"
#property version   "1.00"
#property strict

//--- Inputs
extern double Lots       = 0.1;      // лот
extern double KLot       = 1;        // умножение лота
extern double MaxLot     = 5;        // максимальный лот
extern int StopLoss      = 2000;     // лось
extern int TakeProfit    = 3000;     // язь
extern int BULevel       = 0;        // уровень БУ
extern int BUPoint       = 30;       // пункты БУ
extern int TrailingStop  = 0;        // трал
extern int StartHour     = 0;        // час начала торговли
extern int StartMin      = 30;       // минута начала торговли
extern int EndHour       = 23;       // час окончания торговли
extern int EndMin        = 30;       // минута окончания торговли
extern int Slip          = 30;       // реквот
extern int Shift         = 1;        // на каком баре сигнал индикатора
extern int CloseOn       = 1;        // 1-закрытие в конце работы
extern int Magic         = 123;      // магик
extern string IndName    = "freescalperindicator";
extern int IndPeriod     = 14;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Comment("");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
  }
//+----------------------------------------------------------------------------+
//|  Автор    : Ким Игорь В. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  Версия   : 30.04.2009                                                     |
//|  Описание : Возвращает флаг разрешения торговли по времени.                |
//+----------------------------------------------------------------------------+
//|  Параметры:                                                                |
//|    hb - часы времени начала торговли                                       |
//|    mb - минуты времени начала торговли                                     |
//|    he - часы времени окончания торговли                                    |
//|    me - минуты времени окончания торговли                                  |
//+----------------------------------------------------------------------------+
bool isTradeTimeInt(int hb=0,int mb=0,int he=0,int me=0)
  {
   datetime db, de;           // Время начала и окончания работы
   int      hc;               // Часы текущего времени торгового сервера

   db=StrToTime(TimeToStr(TimeCurrent(), TIME_DATE)+" "+(string)hb+":"+(string)mb);
   de=StrToTime(TimeToStr(TimeCurrent(), TIME_DATE)+" "+(string)he+":"+(string)me);
   hc=TimeHour(TimeCurrent());

   if(db>=de)
     {
      if(hc>=he) de+=24*60*60; else db-=24*60*60;
     }

   if(TimeCurrent()>=db && TimeCurrent()<=de) return(True);
   else return(False);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PutOrder(int type,double price)
  {
   int r=0;
   color clr=Green;
   double sl=0,tp=0;

   if(type==1 || type==3 || type==5)
     {
      clr=Red;
      if(StopLoss>0) sl=NormalizeDouble(price+StopLoss*Point,Digits);
      if(TakeProfit>0) tp=NormalizeDouble(price-TakeProfit*Point,Digits);
     }

   if(type==0 || type==2 || type==4)
     {
      clr=Blue;
      if(StopLoss>0) sl=NormalizeDouble(price-StopLoss*Point,Digits);
      if(TakeProfit>0) tp=NormalizeDouble(price+TakeProfit*Point,Digits);
     }

   r=OrderSend(NULL,type,Lot(),NormalizeDouble(price,Digits),Slip,sl,tp,"",Magic,0,clr);
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
void OpenPos()
  {
   double green = iCustom(NULL,0,IndName,IndPeriod,0,Shift);
   double red = iCustom(NULL,0,IndName,IndPeriod,1,Shift);

   if(green>0)
     {
      PutOrder(0,Ask);
     }

   if(red>0)
     {
      PutOrder(1,Bid);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePos()
  {
   double green = iCustom(NULL,0,IndName,IndPeriod,0,Shift);
   double red = iCustom(NULL,0,IndName,IndPeriod,1,Shift);
//---
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
           {
            if(OrderType()==OP_BUY)
              {
               if(red>0)
                 {
                  if(!OrderClose(OrderTicket(),OrderLots(),Bid,Slip,White))
                     Print("OrderClose error ",GetLastError());
                 }
              }
            if(OrderType()==OP_SELL)
              {
               if(green>0)
                 {
                  if(!OrderClose(OrderTicket(),OrderLots(),Ask,Slip,White))
                     Print("OrderClose error ",GetLastError());
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Lot()
  {
   double lot=Lots;

   if(OrderSelect(OrdersHistoryTotal()-1,SELECT_BY_POS,MODE_HISTORY))
     {
      if(OrderProfit()<0)
        {
         lot=OrderLots()*KLot;
        }
     }
   if(lot>MaxLot)lot=Lots;
   return(lot);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trailing()
  {
   bool mod;
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() || OrderMagicNumber()==Magic)
           {
            if(OrderType()==OP_BUY)
              {
               if(Bid-OrderOpenPrice()>TrailingStop*Point)
                 {
                  if(OrderStopLoss()<Bid-TrailingStop*Point)
                    {
                     mod=OrderModify(OrderTicket(),OrderOpenPrice(),Bid-TrailingStop*Point,OrderTakeProfit(),0,Yellow);
                     return;
                    }
                 }
              }

            if(OrderType()==OP_SELL)
              {
               if((OrderOpenPrice()-Ask)>TrailingStop*Point)
                 {
                  if((OrderStopLoss()>(Ask+TrailingStop*Point)) || (OrderStopLoss()==0))
                    {
                     mod=OrderModify(OrderTicket(),OrderOpenPrice(),Ask+TrailingStop*Point,OrderTakeProfit(),0,Yellow);
                     return;
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BU()
  {
   bool m;
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() || OrderMagicNumber()==Magic)
           {
            if(OrderType()==OP_BUY)
              {
               if(OrderOpenPrice()<=(Bid-(BULevel+BUPoint)*Point) && OrderOpenPrice()>OrderStopLoss())
                 {
                  m=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+BUPoint*Point,OrderTakeProfit(),0,Yellow);
                  return;
                 }
              }

            if(OrderType()==OP_SELL)
              {
               if(OrderOpenPrice()>=(Ask+(BULevel+BUPoint)*Point) && (OrderOpenPrice()<OrderStopLoss()||OrderStopLoss()==0))
                 {
                  m=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-BUPoint*Point,OrderTakeProfit(),0,Yellow);
                  return;
                 }
              }
           }
        }
     }
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
            if(OrderType()==OP_BUY)
              {
               RefreshRates();
               cl=OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),Slip,White);
              }
            if(OrderType()==OP_SELL)
              {
               RefreshRates();
               cl=OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),Slip,White);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double green = iCustom(NULL,0,IndName,IndPeriod,0,Shift);
   double red = iCustom(NULL,0,IndName,IndPeriod,1,Shift);

   if(CountTrades()<1 && isTradeTimeInt(StartHour,StartMin,EndHour,EndMin))
     {
      OpenPos();
     }
   else ClosePos();

   if(!isTradeTimeInt(StartHour,StartMin,EndHour,EndMin) &&  CloseOn>0) CloseAll();

   if(BULevel>0) BU();
   if(TrailingStop>0) Trailing();

   Comment("\n green: ",green,
           "\n red: ",red);
  }
//+------------------------------------------------------------------+
