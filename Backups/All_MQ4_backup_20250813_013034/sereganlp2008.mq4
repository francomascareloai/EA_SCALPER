//+------------------------------------------------------------------+
//|                                                sereganlp2008.mq4 |
//|                               Copyright © 2008, Sergey Stepanoff |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Sergey Stepanoff"
#property link      "sereganlp.livejournal.com"

// Параметры Ишимоку
int Tenkan=12;
int Kijun=24;
int Senkou=120;

// Параметры первого стохастика
int s11=3;
int s12=3;
int s13=5;
// Параметры второго стохастика
int s21=5;
int s22=5;
int s23=10;
// Параметры третьего стохастика
int s31=5;
int s32=5;
int s33=7;
// Параметры четвертого стохастика
int s41=3;
int s42=3;
int s43=7;

int MyTP=40;
int MySL=30;

int StopBezub=31;

datetime LostTime;

int ticket=0;
int ticket2=0;
int ticket3=0;
double lot=0.1;
double lot2=0;
double lot3=0;

bool CloseTP=false;
double VirtualTP;
int OgrTP=30;
double risk=4000;
double MaxBalance;

// Для Fibo-Pivot
double P = 0, S = 0, R = 0, SP1 = 0, R1 = 0, SP2 = 0, R2 = 0, SP3 = 0, R3 = 0, SP4 = 0, R4 = 0;

// Управление размером лотов
int Capital()
  {
   if (AccountBalance() > MaxBalance) MaxBalance = AccountBalance();
   lot=NormalizeDouble(MaxBalance / risk, 1);
   if (AccountBalance()<lot*1500) lot=NormalizeDouble(AccountFreeMargin()/1500,1);
   if (lot<=5)
     {
      lot2=0;
      lot3=0;
     }
   if ((lot>5) && (lot<=10))
     {
      lot2=lot-5;
      lot=5;
      lot3=0;
     } else
   if ((lot>10) && (lot<=15))
     {
      lot3=lot-10;
      lot=5;
      lot2=5;
     } else
   if (lot>15)
     {
      lot=5;
      lot2=5;
      lot3=5;
     }
   if (AccountBalance()<7000)
     {
      lot2=0;
      lot3=0;
      lot=NormalizeDouble(AccountBalance() / risk, 1);
     }
  }

// Проверка на наличие открытых ордеров
int init()
  {
   Capital();
   if (OrdersTotal()>0)
     {
      OrderSelect(1,SELECT_BY_POS,MODE_TRADES);
      ticket=OrderTicket();
      if ((OrderType()==OP_BUY) && (OrderProfit()>=0)) VirtualTP=MyTPUp(Symbol());
      if ((OrderType()==OP_BUY) && (OrderProfit()<0)) VirtualTP=OrderOpenPrice()+50*Point;
      if ((OrderType()==OP_SELL) && (OrderProfit()>=0)) VirtualTP=MyTPDown(Symbol());
      if ((OrderType()==OP_SELL) && (OrderProfit()<0)) VirtualTP=OrderOpenPrice()-50*Point;
     }
   if (OrdersTotal()>1)
     {
      OrderSelect(2,SELECT_BY_POS,MODE_TRADES);
      ticket2=OrderTicket();
     }
   if (OrdersTotal()==3)
     {
      OrderSelect(3,SELECT_BY_POS,MODE_TRADES);
      ticket3=OrderTicket();
     }
   return(0);
  }
int deinit()
  {
   return(0);
  }

// Вычисление уровней FIBO и PIVOT
void FiboPivot(string symbol)
  {
    //------ Pivot Points ------
    R = iHigh(symbol,PERIOD_D1,1) - iLow(symbol,PERIOD_D1,1);
    P = (iHigh(symbol,PERIOD_D1,1) + iLow(symbol,PERIOD_D1,1) + iClose(symbol,PERIOD_D1,1))/3; //Pivot
    R1 = P + (R * 0.38);
    R2 = P + (R * 0.62);
    R3 = P + (R * 0.99);
    R4 = 2*P+iHigh(symbol,PERIOD_D1,1)-2*iLow(symbol,PERIOD_D1,1);
    SP1 = P - (R * 0.38);
    SP2 = P - (R * 0.62);
    SP3 = P - (R * 0.99);
    SP4 = 2*P-(2*iHigh(symbol,PERIOD_D1,1)-iLow(symbol,PERIOD_D1,1));
  }

// Вычисление тейков по уровням FIBO и Pivot
double MyTPUp(string symbol)
  {
   FiboPivot(symbol);
   double TP;
   TP=Ask+MyTP*Point;
   if (R4>Ask+MyTP*Point) TP=R4;
   if (R3>Ask+MyTP*Point) TP=R3;
   if (R2>Ask+MyTP*Point) TP=R2;
   if (R1>Ask+MyTP*Point) TP=R1;
   if (P>Ask+MyTP*Point) TP=P;
   if (SP1>Ask+MyTP*Point) TP=SP1;
   if (SP2>Ask+MyTP*Point) TP=SP2;
   if (SP3>Ask+MyTP*Point) TP=SP3;
   if (SP4>Ask+MyTP*Point) TP=SP4;
   return(TP);
  }

double MyTPDown(string symbol)
  {
   FiboPivot(symbol);
   double TP;
   TP=Bid-MyTP*Point;
   if (SP4<Bid-MyTP*Point) TP=SP4+Ask-Bid;
   if (SP3<Bid-MyTP*Point) TP=SP3+Ask-Bid;
   if (SP2<Bid-MyTP*Point) TP=SP2+Ask-Bid;
   if (SP1<Bid-MyTP*Point) TP=SP1+Ask-Bid;
   if (P<Bid-MyTP*Point) TP=P+Ask-Bid;
   if (R1<Bid-MyTP*Point) TP=R1+Ask-Bid;
   if (R2<Bid-MyTP*Point) TP=R2+Ask-Bid;
   if (R3<Bid-MyTP*Point) TP=R3+Ask-Bid;
   if (R4<Bid-MyTP*Point) TP=R4+Ask-Bid;
   return(TP);
  }

// Вычисление стопов по уровням FIBO и Pivot
double MySLDown(string symbol)
  {
   FiboPivot(symbol);
   double SL;
   SL=Ask+MySL*Point;
   if (R4>Ask+MySL*Point) SL=R4+Ask-Bid;
   if (R3>Ask+MySL*Point) SL=R3+Ask-Bid;
   if (R2>Ask+MySL*Point) SL=R2+Ask-Bid;
   if (R1>Ask+MySL*Point) SL=R1+Ask-Bid;
   if (P>Ask+MySL*Point) SL=P+Ask-Bid;
   if (SP1>Ask+MySL*Point) SL=SP1+Ask-Bid;
   if (SP2>Ask+MySL*Point) SL=SP2+Ask-Bid;
   if (SP3>Ask+MySL*Point) SL=SP3+Ask-Bid;
   if (SP4>Ask+MySL*Point) SL=SP4+Ask-Bid;
   return(SL);
  }

double MySLUp(string symbol)
  {
   FiboPivot(symbol);
   double SL;
   SL=Bid-MySL*Point;
   if (SP4<Bid-MySL*Point) SL=SP4;
   if (SP3<Bid-MySL*Point) SL=SP3;
   if (SP2<Bid-MySL*Point) SL=SP2;
   if (SP1<Bid-MySL*Point) SL=SP1;
   if (P<Bid-MySL*Point) SL=P;
   if (R1<Bid-MySL*Point) SL=R1;
   if (R2<Bid-MySL*Point) SL=R2;
   if (R3<Bid-MySL*Point) SL=R3;
   if (R4<Bid-MySL*Point) SL=R4;
   return(SL);
  }

// Сигналы Ишимоку на открытие вверх  
bool SignalIchimokuUp(string symbol)
  {
   bool signal=false;

// проверка пересечения TS и KS
   if ((iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_TENKANSEN,0)>iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_KIJUNSEN,0)) &&
       (iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_TENKANSEN,1)<=iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_KIJUNSEN,1)))
           signal=true;   else

// проверка выхода из "облака"
   if ((iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_SENKOUSPANA,0)>iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_SENKOUSPANB,0)) &&
       (iHigh(symbol,0,0)>iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_SENKOUSPANA,0)) &&
       (iHigh(symbol,0,1)<iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_SENKOUSPANA,1)) &&
       (Bid<iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_SENKOUSPANA,0)+OgrTP*Point))
           signal=true;   else
   if ((iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_SENKOUSPANA,0)<iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_SENKOUSPANB,0)) &&
       (iHigh(symbol,0,0)>iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_SENKOUSPANB,0)) &&
       (iHigh(symbol,0,1)<iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_SENKOUSPANB,1)) &&
       (Bid<iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_SENKOUSPANB,0)+OgrTP*Point))
           signal=true;

   return(signal);
  }

// Сигналы Ишимоку на открытие вниз
bool SignalIchimokuDown(string symbol)
  {
   bool signal=false;

// проверка пересечения TS и KS
   if ((iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_TENKANSEN,0)<iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_KIJUNSEN,0)) &&
       (iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_TENKANSEN,1)>=iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_KIJUNSEN,1)))
          signal=true;   else

// проверка выхода из облака
   if ((iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_SENKOUSPANA,0)<iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_SENKOUSPANB,0)) &&
       (iLow(symbol,0,0)<iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_SENKOUSPANA,0)) &&
       (iLow(symbol,0,1)>iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_SENKOUSPANA,1))  &&
       (Bid>iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_SENKOUSPANA,0)-OgrTP*Point))
          signal=true;   else
   if ((iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_SENKOUSPANA,0)>iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_SENKOUSPANB,0)) &&
       (iLow(symbol,0,0)<iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_SENKOUSPANB,0)) &&
       (iLow(symbol,0,1)>iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_SENKOUSPANB,1)) &&
       (Bid>iIchimoku(symbol,0,Tenkan,Kijun,Senkou,MODE_SENKOUSPANB,0)-OgrTP*Point))
          signal=true;

   return(signal);
  }

// Подтверждение стохастика на открытие вверх
bool SignalStochUp(string symbol, int s1, int s2, int s3, int period)
  {
   if (iStochastic(symbol,period,s3,s2,s1,MODE_SMA,0,0,0)>iStochastic(symbol,period,s3,s2,s1,MODE_SMA,0,1,0))
      return(true); else return(false);
  }

// Подтверждение стохастика на открытие вниз
bool SignalStochDown(string symbol, int s1, int s2, int s3, int period)
  {
   if (iStochastic(symbol,period,s3,s2,s1,MODE_SMA,0,0,0)<iStochastic(symbol,period,s3,s2,s1,MODE_SMA,0,1,0))
      return(true); else return(false);
  }

// Перенос стопа в безубыточность
void TestBezub()
  {
   OrderSelect(ticket,SELECT_BY_TICKET);
   if ((OrderType()==OP_BUY) && (OrderStopLoss() < OrderOpenPrice()) && (Bid-OrderOpenPrice() > StopBezub*Point))
     {
      while (IsTradeContextBusy()) {}
      OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice()+Ask-Bid+Point,OrderTakeProfit(),0);
      if (OrdersTotal()>1)
       {
        while (IsTradeContextBusy()) {}
        OrderModify(ticket2,OrderOpenPrice(),OrderOpenPrice()+Ask-Bid+Point,OrderTakeProfit(),0);
       }
      if (OrdersTotal()==3)
       {
        while (IsTradeContextBusy()) {}
        OrderModify(ticket3,OrderOpenPrice(),OrderOpenPrice()+Ask-Bid+Point,OrderTakeProfit(),0);
       }
     }
   if ((OrderType()==OP_SELL) && (OrderStopLoss() > OrderOpenPrice()) && (OrderOpenPrice()-Ask > StopBezub*Point))
     {
      while (IsTradeContextBusy()) {}
      OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice()-Ask+Bid-Point,OrderTakeProfit(),0);
      if (OrdersTotal()>1)
       {
        while (IsTradeContextBusy()) {}
        OrderModify(ticket2,OrderOpenPrice(),OrderOpenPrice()-Ask+Bid-Point,OrderTakeProfit(),0);
       }
      if (OrdersTotal()==3)
       {
        while (IsTradeContextBusy()) {}
        OrderModify(ticket3,OrderOpenPrice(),OrderOpenPrice()-Ask+Bid-Point,OrderTakeProfit(),0);
       }
     }
   return(0);
  }

// Закрытие длинных позиций
void CloseUp()
  {
   if (OrdersTotal()==3)
    {
     while (IsTradeContextBusy()) {}
     OrderClose(ticket3,lot3,Bid,15);
    }
   if (OrdersTotal()==2)
    {
     while (IsTradeContextBusy()) {}
     OrderClose(ticket2,lot2,Bid,15);
    }
   if (OrdersTotal()==1)
    {
     while (IsTradeContextBusy()) {}
     OrderClose(ticket,lot,Bid,15);
    }
   LostTime=iTime(NULL,0,0);
   CloseTP=false;
   VirtualTP=0;
   Capital();
  }

// Закрытие коротких позиций
void CloseDown()
  {
   if (OrdersTotal()==3)
    {
     while (IsTradeContextBusy()) {}
     OrderClose(ticket3,lot3,Ask,15);
    }
   if (OrdersTotal()==2)
    {
     while (IsTradeContextBusy()) {}
     OrderClose(ticket2,lot2,Ask,15);
    }
   if (OrdersTotal()==1)
    {
     while (IsTradeContextBusy()) {}
     OrderClose(ticket,lot,Ask,15);
    }
   LostTime=iTime(NULL,0,0);
   CloseTP=false;
   VirtualTP=0;
   Capital();
  }  

// Открытие длинных позиций
void OpenUp()
  {
   Capital();
   while (IsTradeContextBusy()) {}
   ticket=OrderSend(Symbol(),OP_BUY,lot,Ask,5,MySLUp(Symbol()),Bid+300*Point);
   if (lot2>0)
    {
     while (IsTradeContextBusy()) {}
     ticket2=OrderSend(Symbol(),OP_BUY,lot2,Ask,5,MySLUp(Symbol()),Bid+300*Point);
    }
   if (lot3>0)
    {
     while (IsTradeContextBusy()) {}
     ticket3=OrderSend(Symbol(),OP_BUY,lot3,Ask,5,MySLUp(Symbol()),Bid+300*Point);
    }
   VirtualTP=MyTPUp(Symbol());
   LostTime=iTime(NULL,0,0);  
  }

// ОТкрытие коротких позиций
void OpenDown()
  {
   Capital();
   while (IsTradeContextBusy()) {}
   ticket=OrderSend(Symbol(),OP_SELL,lot,Bid,5,MySLDown(Symbol()),Ask-300*Point);
   if (lot2>0)
    {
     while (IsTradeContextBusy()) {}
     ticket2=OrderSend(Symbol(),OP_SELL,lot2,Bid,5,MySLDown(Symbol()),Ask-300*Point);
    }
   if (lot3>0)
    {
     while (IsTradeContextBusy()) {}
     ticket3=OrderSend(Symbol(),OP_SELL,lot3,Bid,5,MySLDown(Symbol()),Ask-300*Point);
    }
   VirtualTP=MyTPDown(Symbol());
   LostTime=iTime(NULL,0,0);
  }

// Проверка на закрытие
int TestClose()
  {
   OrderSelect(ticket,SELECT_BY_TICKET);
// Проверяем, как будем закрываться - по TP или по MAшке
   if ((OrderType()==OP_BUY) && (Bid<OrderOpenPrice()-OgrTP*Point)) CloseTP=true;
   if ((OrderType()==OP_SELL) && (Bid>OrderOpenPrice()+OgrTP*Point)) CloseTP=true;

// Проверка на закрытие по TP   
   if ((OrderType()==OP_BUY) && (Bid>VirtualTP) && CloseTP)
       CloseUp();
          else
   if ((OrderType()==OP_SELL) && (Ask<VirtualTP) && CloseTP)
       CloseDown();
          else

// Если прибыль положительная и цена коснулась MAшки - закрываемся
   if ((OrderType()==OP_BUY) && (OrderProfit()>0) && (Bid<iMA(Symbol(),0,21,0,MODE_SMA,PRICE_MEDIAN,0)) &&
      (Low[1]>iMA(Symbol(),0,21,0,MODE_SMA,PRICE_MEDIAN,1)))
        CloseUp();
           else
   if ((OrderType()==OP_SELL) && (OrderProfit()>0) && (Bid>iMA(Symbol(),0,21,0,MODE_SMA,PRICE_MEDIAN,0)) &&
      (High[1]<iMA(Symbol(),0,21,0,MODE_SMA,PRICE_MEDIAN,1)))
        CloseDown();
           else
// Закрываем сделку, как только она вышла в прибыльность, если была очень большая просадка
    if ((OrderType()==OP_BUY) && (iLowest(NULL,0,MODE_LOW,iBarShift(NULL,0,OrderOpenTime(),0))<Bid-250)
       && (OrderProfit()>0))
        CloseUp();
        else
    if ((OrderType()==OP_SELL) && (iHighest(NULL,0,MODE_LOW,iBarShift(NULL,0,OrderOpenTime(),0))>Bid+250)
       && (OrderProfit()>0))
        CloseDown();
        
        else
// Переворот      
    if ((OrderType()==OP_BUY) && SignalDown())
       {
        CloseUp();
        OpenDown();
       }
        else
    if ((OrderType()==OP_SELL) && SignalUp())
       {
        CloseDown();
        OpenUp();
       }

   }

// Сигнал на открытие длинных позиций
bool SignalUp()
  {
   if (SignalIchimokuUp(Symbol()) && SignalStochUp(Symbol(),s11,s12,s13,0) && SignalStochUp(Symbol(),s21,s22,s23,0) &&
       SignalStochUp(Symbol(),s31,s32,s33,0) && SignalStochUp(Symbol(),s41,s42,s43,0))
         return(true); else return(false);
  }

// Сигнал на открытие коротких позиций
bool SignalDown()
  {
   if (SignalIchimokuDown(Symbol()) && SignalStochDown(Symbol(),s11,s12,s13,0) && SignalStochDown(Symbol(),s21,s22,s23,0) &&
       SignalStochDown(Symbol(),s31,s32,s33,0) && SignalStochDown(Symbol(),s41,s42,s43,0))
         return(true); else return(false);
  }

int start()
  {
   if (OrdersTotal()==0)
     {
      if (SignalUp()) OpenUp();
          else
      if (SignalDown()) OpenDown();
     }
          else
     {
      TestBezub();
      // Запуск проверки на закрытие, кроме свечки, на которой открылись
      if (LostTime<iTime(NULL,0,0)) TestClose(); 
     }
   return(0);
  }

