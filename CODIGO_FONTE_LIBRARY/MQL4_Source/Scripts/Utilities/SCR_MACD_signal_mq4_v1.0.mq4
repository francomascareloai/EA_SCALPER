//+------------------------------------------------------------------+
//|                                                  MACD_signal.mq4 |
//|                                                           tom112 |
//|                                            tom112@mail.wplus.net |
//+------------------------------------------------------------------+
#property copyright "tom112"
#property link "tom112@mail.wplus.net"
//---- input parameters
extern double TakeProfit = 10;
extern double Lots = 10;
extern double TrailingStop = 25;
extern int Pfast = 9;
extern int Pslow = 15;
extern int Psignal = 8;
extern double LEVEL = 0.004;
double Points;
//+------------------------------------------------------------------+
//| expert initialization function |
//+------------------------------------------------------------------+
int init()
  {
   Points = MarketInfo(Symbol(), MODE_POINT);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function |
//+------------------------------------------------------------------+
int start()
  {
   double MacdCurrent = 0, MacdPrevious = 0, SignalCurrent = 0;
   double SignalPrevious = 0, MaCurrent = 0, MaPrevious = 0;
   int cnt = 0, total;
   int i1, pp, shift;
   double Tv[2][500] ;
   double Range, rr, Delta, Delta1, val3;
// первичные проверки данных
// важно удостовериться что эксперт работает на нормальном графике и
// пользователь правильно выставил внешние переменные (Lots, StopLoss,
// TakeProfit, TrailingStop)
// в нашем случае проверяем только TakeProfit
   if(Bars < 100)
     {
       Print("bars less than 100");
       return(0); // на графике менее 100 баров
     }
   if(TakeProfit < 10)
     {
       Print("TakeProfit less than 10");
       return(0); // проверяем TakeProfit
     }
   Range = iATR(NULL, 0, 200, 1);
   rr = Range*LEVEL;
   Delta = iMACD(NULL, 0, Pfast, Pslow, Psignal, PRICE_CLOSE, MODE_MAIN, 0)-
           iMACD(NULL, 0, Pfast, Pslow, Psignal, PRICE_CLOSE, MODE_SIGNAL, 0);
   Delta1 = iMACD(NULL, 0, Pfast, Pslow, Psignal, PRICE_CLOSE, MODE_MAIN, 1)-
            iMACD(NULL, 0, Pfast, Pslow, Psignal, PRICE_CLOSE, MODE_SIGNAL, 1);
// теперь надо определиться - в каком состоянии торговый терминал?
// проверим, есть ли ранее открытые позиции или ордеры?
   if(OrdersTotal() < 1) 
     {
       // нет ни одного открытого ордера
       // на всякий случай проверим, если у нас свободные деньги на счету?
       // значение 1000 взято для примера, обычно можно открыть 1 лот
       if(AccountFreeMargin() < (1000*Lots))
         {
           Print("We have no money");
           return(0); // денег нет - выходим
         }
       // проверим, не слишком ли часто пытаемся открыться?
       // если последний раз торговали менее чем 5 минут(5*60=300 сек)
       // назад, то выходим
       // If((CurTime-LastTradeTime)<300) return(0);
       // проверяем на возможность встать в длинную позицию (BUY)
       if(Delta > rr && Delta1 < rr )
         {
           OrderSend(Symbol(), OP_BUY, Lots, Ask, 3, 0, Ask + TakeProfit*Points, 
                     "macd signal", 16384, 0, Red); // исполняем
           if(GetLastError() == 0)
               Print("Order opened : ", OrderOpenPrice());
           return(0); // выходим, так как все равно после совершения торговой операции
           // наступил 10-ти секундный таймаут на совершение торговых операций
         }
       // проверяем на возможность встать в короткую позицию (SELL)
       if(Delta < -rr && Delta1 > -rr )
         {
           OrderSend(Symbol(), OP_SELL, Lots, Bid, 3, 0, Bid - TakeProfit*Points, 
                     "macd sample", 16384, 0, Red); // исполняем
           if(GetLastError() == 0)
               Print("Order opened : ", OrderOpenPrice());
           return(0); // выходим
         }
       // здесь мы завершили проверку на возможность открытия новых позиций.
       // новые позиции открыты не были и просто выходим по Exit, так как
       // все равно анализировать нечего
       return(0);
     }
   // переходим к важной части эксперта - контролю открытых позиций
   // 'важно правильно войти в рынок, но выйти - еще важнее...'
   total = OrdersTotal();
   for(cnt = 0; cnt < total; cnt++)
     {
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
       if(OrderType() <= OP_SELL && // это открытая позиция? OP_BUY или OP_SELL 
          OrderSymbol()==Symbol())  // инструмент совпадает?
         {
           if(OrderType() == OP_BUY) // открыта длинная позиция
             {
               // проверим, может уже пора закрываться?
               if(Delta < 0)
                 {
                   // закрываем позицию
                   OrderClose(OrderTicket(), OrderLots(), Bid, 3, Violet); 
                   return(0); // выходим
                 }
               // проверим - может можно/нужно уже трейлинг стоп ставить?
               if(TrailingStop > 0) // пользователь выставил в настройках трейлингстоп
                 { // значит мы идем его проверять
                   if(Bid - OrderOpenPrice() > Points*TrailingStop)
                     {
                       if(OrderStopLoss() < Bid - Points*TrailingStop)
                         {
                           OrderModify(OrderTicket(), OrderOpenPrice(), 
                                       Bid - Points*TrailingStop, 
                                       OrderTakeProfit(), 0, Red);
                           return(0);
                         }
                     }
                 }
             }
           else // иначе это короткая позиция
             {
               // проверим, может уже пора закрываться?
               if(Delta > 0)
                 {
                   // закрываем позицию
                   OrderClose(OrderTicket(), OrderLots(), Ask, 3, Violet); 
                   return(0); // выходим
                 }
               // проверим - может можно/нужно уже трейлинг стоп ставить?
               if(TrailingStop > 0) // пользователь выставил в настройках трейлингстоп
                 { // значит мы идем его проверять
                   if((OrderOpenPrice() - Ask) > (Points*TrailingStop))
                     {
                       if(OrderStopLoss() == 0.0 || OrderStopLoss() > 
                          (Ask + Points*TrailingStop))
                         {
                           OrderModify(OrderTicket(), OrderOpenPrice(), 
                                       Ask + Points*TrailingStop, 
                                       OrderTakeProfit(), 0, Red);
                           return(0);
                         }
                     }
                 }
             }
         }
     }
   return(0);
  }
// the end.
//+------------------------------------------------------------------+

