//+------------------------------------------------------------------+
//|                                      Alligator_Signal_Expert.mq4 |
//|                                                              AVM |
//+------------------------------------------------------------------+
#property copyright "AVM"
#property link      ""
extern string rem1="Параметры мувингов";
extern int P_MA_1=13;
extern int P_MA_2=8;
extern int P_MA_3=5;
extern string rem2="Расхождение мувингов";
extern int Delta=3;
extern string rem3="Торговые параметры";
extern double Lot=1;
extern string rem34="Для пятизнака умножаем на 10";
extern int StopLoss=50;
extern int TakeProfit=50;
extern string rem33="Уровень безубытка в пп";
extern int Level_NoLoss=30;
extern string rem4="Сдвиг 0-текущий бар, 1-закрытый предыдущий";
extern int Shift_Indik=1;
extern int Shift_open=0;
extern string rem5="Магик ордера";
extern int Magik=112233;
bool   Label_B=true,                    // Метка открытия ордера Buy
       Label_S=true;                    // Метка открытия ордера Sell
bool   Label_Modify=true;
int Lot_Close[];


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
   bool
   Ans,
   Cls_B=false,                     // Критерий для закрытия  Buy
   Cls_S=false,                     // Критерий для закрытия  Sell
   Opn_B=false,                     // Критерий для открытия  Buy
   Opn_S=false;                     // Критерий для открытия  Sell
   int Total=0;                                    // Количество ордеров 
   int Ticket[5];
   double SL = StopLoss;
   double TP = TakeProfit;
   for(int i=1; i<=OrdersTotal(); i++)          // Цикл перебора ордер
     {
      if (OrderSelect(i-1,SELECT_BY_POS,MODE_TRADES)==true) // Если есть следующий
        {                                       // Анализ ордеров:
          if (OrderSymbol()!=Symbol())continue;      // Не наш фин. инструм
          if (OrderMagicNumber()!=Magik)continue;  
           ArrayResize(Ticket,Total+1);
           ArrayResize(Lot_Close,Total+1);
          Ticket[Total]=OrderTicket();
          Lot_Close[Total]=OrderLots();
          Total++;                               // Счётчик отложенных ордеров
//         if (Total>2)                           // Не более двух орд
//           {
//            return;                             // Выход из start()
//           }
        }
     }
     int    Error=GetLastError();
   double MA_1=iMA(NULL,0,P_MA_1,0,MODE_SMMA,PRICE_MEDIAN,Shift_Indik);
   double MA_2=iMA(NULL,0,P_MA_2,0,MODE_SMMA,PRICE_MEDIAN,Shift_Indik);
   double MA_3=iMA(NULL,0,P_MA_3,0,MODE_SMMA,PRICE_MEDIAN,Shift_Indik);  
 //  ---------------------------------------------------------------------------Торговые критерии
   if (MA_3 > MA_2+Delta*Point && MA_2 > MA_1+Delta*Point  )  
     {  
       Opn_B=true; 
       Cls_S=true; 
     }
   if (MA_1 > MA_2+Delta*Point && MA_2 > MA_3+Delta*Point  )  
    { 
      Opn_S=true; 
      Cls_B=true; 
    }
 //--------------------------------------------------------------------------- Если ордер в прибыли, переводим в безубыток
  for (i=0; i<Total; i++)
  {
   if (Label_Modify == true 
       && OrderSelect(Ticket[i],SELECT_BY_TICKET) == true 
       && OrderProfit() > 0 
       && MathAbs(iClose(NULL,0,0)-OrderOpenPrice()) > Level_NoLoss*Point  ) 
    {
    OrderModify(Ticket[i],OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0);
    Label_Modify=false;
    }
  }
//-------------------------------------------------- Если есть противоположный сигнал, закрываем все.

  for (i=0; i < Total; i++)
  {
    if (Cls_B==true)
       if ( OrderSelect(Ticket[i],SELECT_BY_TICKET) == true && OrderType()==0 )
          { OrderClose(Ticket[i],Lot,Bid,2); }
    if (Cls_S==true)
      if ( OrderSelect(Ticket[i],SELECT_BY_TICKET) == true && OrderType()==1)
         {  OrderClose(Ticket[i],Lot,Ask,2); }
 }

 //------------------------------------- Открытие позиций
if ( Total==0 && Opn_B==true && Label_B==true  && iClose(NULL,0,Shift_open) < MA_2 )
  {
   if (StopLoss !=0)    SL = Bid-StopLoss*Point;
   if (TakeProfit !=0)  TP = Bid+TakeProfit*Point;
   Ticket[1]=OrderSend(Symbol(),OP_BUY,Lot,Ask,2,SL,TP,"Нижгий MA",Magik);
   Label_Modify = true;
  } 
if ( Total==1 && Opn_B==true && Label_B==true && iClose(NULL,0,Shift_open) < MA_1 )
  { 
   if (StopLoss !=0)    SL = Bid-StopLoss*Point;
   if (TakeProfit !=0)  TP = Bid+TakeProfit*Point;
   Ticket[2]=OrderSend(Symbol(),OP_BUY,Lot,Ask,2,SL,TP,"Средний MA",Magik);
   Label_B=false;
   Label_S=true;
   Label_Modify = true;
  }

if ( Total==0 && Opn_S==true && Label_S==true  && iClose(NULL,0,Shift_open) > MA_2 )
  {
    if (StopLoss !=0)    SL = Ask+StopLoss*Point;
    if (TakeProfit !=0)  TP = Ask-TakeProfit*Point;
    Ticket[1]=OrderSend(Symbol(),OP_SELL,Lot,Bid,2,SL,TP,"Нижгий MA",Magik);
    Label_Modify = true;
  }
if ( Total==1 && Opn_S==true && Label_S==true &&  iClose(NULL,0,Shift_open) > MA_1 )
  {
    if (StopLoss !=0)    SL = Ask+StopLoss*Point;   else SL=0;
    if (TakeProfit !=0)  TP = Ask-TakeProfit*Point; else TP=0;
   Ticket[2]=OrderSend(Symbol(),OP_SELL,Lot,Bid,2,SL,TP,"Средний MA",Magik);
   Label_S=false;
   Label_B=true;
   Label_Modify = true;
  }
//----


 Fun_Error(Error);
return(0);
}
//+------------------------------------------------------------------+

int Fun_Error(int Error)                        // Ф-ия обработ ошибок
  {
   switch(Error)
     {                                          // Преодолимые ошибки   
      case  0:    return(0);         
    //  case  4105: return(0);  
      case  4: Alert("Торговый сервер занят. Пробуем ещё раз..");
         Sleep(3000);                           // Простое решение
         return(1);                             // Выход из функции
      case 135:Alert("Цена изменилась. Пробуем ещё раз..");
         RefreshRates();                        // Обновим данные
         return(1);                             // Выход из функции
      case 136:Alert("Нет цен. Ждём новый тик..");
         while(RefreshRates()==false)           // До нового тика
            Sleep(1);                           // Задержка в цикле
         return(1);                             // Выход из функции
      case 137:Alert("Брокер занят. Пробуем ещё раз..");
         Sleep(3000);                           // Простое решение
         return(1);                             // Выход из функции
      case 146:Alert("Подсистема торговли занята. Пробуем ещё..");
         Sleep(500);                            // Простое решение
         return(1);                             // Выход из функции
         // Критические ошибки
      case  2: Alert("Общая ошибка.");
         return(0);                             // Выход из функции
      case 133:Alert("Торговля запрещена.");
         return(0);                             // Выход из функции
      case 134:Alert("Недостаточно денег для совершения операции.");
         return(0);                             // Выход из функции
      default: Alert("Возникла ошибка ",Error); // Другие варианты   
         return(0);                             // Выход из функции
     }
  }
//-------------------------------------------------------------- 11 --


