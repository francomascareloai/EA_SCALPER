//+------------------------------------------------------------------+
//|                                                     MyFriend.mq4 |
//|                                                 Disruption Trade |
//|                                                       2006.09.25 |
//|                                 Copyright © 2006, Nick A. Zhilin |
//|                                              rebus@dialup.etr.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Nick A. Zhilin"
#property link      "rebus@dialup.etr.ru"
 
extern string ParamExp="--- Параметры эксперта ---";
extern double Risk=0.33;
extern int TP=70;
extern int SLPlus=13;
extern string ParamClose=" --- Использование дополнительного предохранителя ---";
extern bool UseClose=true;
extern string ParamTrail=" --- Параметры Trailing Stop ---";
extern int ChPeriod=16;
extern bool UseTrailingStop=true;
extern int StartProfit=5;
extern int TSLPlus=1;
                  
int start()
  {
//----
   double Lots, TakeProfit, StopLoss;
   double I1Current, I1Previous, I2Current, I2Previous;
   double I3Current, I3Previous, I4Current, I4Previous;
   double Pivot, R1, R2, R3, S1, S2, S3;
   double MP;
   int cnt, ticket, total;
   int signal1, signal2;
   static int se;

//-------------------------------------------
// обязательные проверки
//-------------------------------------------
// проверка на достаточное количество баров
//-------------------------------------------
   if(Bars<100 && se==0)
     {
      Print("Баров должно быть не менее 100");
      se++;  
     }

// проверка инструмента и тайм фрейма
   if(Symbol()!="EURUSD" && se==0)
     {
      Print("Программа может работать только на паре EUR/USD");
      se++;  
     }
   if(Period()!=PERIOD_M30 && se==0)
     {
      Print("Программа оптимизирована под тайм фрейм М30");
      se++;  
     }
// выход, если обнаружены ошибки запуска
   if(se>0) return(0);
   
//-------------------------------------------
// расчет локальных переменных
//-------------------------------------------
// значения индикаторов
    
   I1Current=iCustom(NULL,0,"DC",ChPeriod,1,0,0,ChPeriod,0,0);
   I1Previous=iCustom(NULL,0,"DC",ChPeriod,1,0,0,ChPeriod,0,1);
   I2Current=iCustom(NULL,0,"DC",ChPeriod,1,0,0,ChPeriod,1,0);
   I2Previous=iCustom(NULL,0,"DC",ChPeriod,1,0,0,ChPeriod,1,1);

// расчет и отображение опорного центра и уровней

   Pivot=(iHigh(NULL,PERIOD_D1,1)+iLow(NULL,PERIOD_D1,1)+iClose(NULL,PERIOD_D1,1))/3;
   S1=2*Pivot-iHigh(NULL,PERIOD_D1,1);
   R1=2*Pivot-iLow(NULL,PERIOD_D1,1);
   S2=Pivot-R1+S1;
   R2=Pivot+R1-S1;
   S3=iLow(NULL,PERIOD_D1,1)-2*(iHigh(NULL,PERIOD_D1,1)-Pivot);
   R3=iHigh(NULL,PERIOD_D1,1)+2*(Pivot-iLow(NULL,PERIOD_D1,1));

   ShowPivot(Pivot,R1,R2,R3,S1,S2,S3);

// оценка локального тренда
   MP=((Close[0]+Close[1]+Close[2])/3
       - (Close[0]+Close[1]+Close[2]
          +Close[3]+Close[4]+Close[5]
          +Close[6]+Close[7]+Close[8])/9)*1000;
   
// определение условий открытия позиций
// по пересечению опорной точки

   if(Open[1]<Pivot                    // открытие предыдущего бара ниже опорной точки
      && Close[1]>Pivot                // закрытие предыдущего бара выше опорной точки - подтверждение пробоя
      && (Close[1]-Open[1])>12*Point   // амплитуда движения цены достаточно большая
      && Ask>Close[1]                  // цена растет
      && MP>0                          // локальный тренд +
      && Ask<High[0]                   // покупка не на максимуме цены
     )
      signal1=1;
      
   if(Open[1]>Pivot                    // открытие предыдущего бара ниже опорной точки
      && Close[1]<Pivot                // закрытие предыдущего бара выше опорной точки - подтверждение пробоя
      && (Open[1]-Close[1])>12*Point   // амплитуда движения цены достаточно большая
      && Bid<Close[1]                  // цена падает
      && MP<0                          // локальный тренд -
      && Bid>Low[0]                    // продажа не на минимуме цены
     )
      signal1=-1;

// по расширению канала Дончиана больше первого диапазона опорного центра

   if(I2Current-I1Current>R1-S1        // текущий канал Дончиана шире канала опорного центра
      && I2Previous-I1Previous<R1-S1   // предыдущий был уже
      && I2Current>I2Previous          // верхняя граница канала Дончиана пошла вверх
      && I1Current>=I1Previous         // нижняя - не пошла вниз
      && MP>0                          // локальный тренд +
      && Ask<High[0]-7*Point           // покупка не на максимуме цены    
     )
      signal1=1;
       
   if(I2Current-I1Current>R1-S1        // текущий канал Дончиана шире канала опорного центра
      && I2Previous-I1Previous<R1-S1   // предыдущий был уже
      && I1Current<I1Previous          // нижняя граница канала Дончиана пошла вниз
      && I2Current>=I2Previous         // верхняя - не пошла вверх
      && MP>0                          // локальный тренд +
      && Bid>Low[0]+7*Point            // продажа не на минимуме цены
     )
      signal1=-1;

// по другим условиям
// для флета - использовать signal2


//------------------------------------------ 
// открытых ордеров всего
//------------------------------------------ 
   total=OrdersTotal();
   if(total<1) 
     {
      // нет открытых ордеров
      if(AccountFreeMargin()<(1000*Lots))
        {
         Print("Недостаточно денег на счету. Свободной маржи = ", AccountFreeMargin());
         return(0);  
        }  
         bool BUYStart=false;
         bool SELLStart=false;
         if(!BUYStart && !SELLStart)
            {
             if(signal1==1
               || signal2==1)               
               {
                BUYStart=true;
                SELLStart=false;
               }
             if(signal1==-1
               || signal2==-1)
               { 
                SELLStart=true;
                BUYStart=false;
               }
            }
         if(BUYStart)
           // открываем длинную позицию (BUY)
            OpenBuy(signal2,I1Current);
         if(SELLStart)
           // открываем короткую позицию (SELL)
            OpenSell(signal2,I2Current);
       return(0);
      }
      // -------------------------------------------------
      // модифицируем, что можем
      //--------------------------------------------------
      for(cnt=0;cnt<total;cnt++)
        {
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

         if(OrderType()<=OP_SELL &&   
            // прроверка на наличие открытых позиций 
            OrderSymbol()==Symbol())  
            // проверка инструмента
           {
            if(OrderType()==OP_BUY)   
              // длинная позиция открыта
              // второй предохранитель - если за три бара цена не пошла в нужную сторону
              {

               if(
                  UseClose
                  && ((CurTime()-OrderOpenTime())>=3*Period()*60
                  && (CurTime()-OrderOpenTime())<4*Period()*60
                  && Close[1]<OrderOpenPrice()-3*Point)
                 )
                 {
                  OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet);
                  return(0); 
                 }

               // изменение SL при безубыточности
               if(UseTrailingStop
                  && (Bid-OrderOpenPrice())>StartProfit*Point
                  && I1Current>I1Previous)                            
                  // цена ордера в области безубыточности
                  // стоп устанавливаем по нижней границе быстрого канала
                 {
                  StopLoss=I1Current-TSLPlus*Point;
                  if(OrderStopLoss()<StopLoss)
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),StopLoss,0,0,Aqua);
                     return(0);
                    }
                 }

               return(0);
              }

            if(OrderType()==OP_SELL)   
              // короткая позиция открыта
              // второй предохранитель - если за три бара цена не пошла в нужную сторону
              {

               if(
                  UseClose
                  && ((CurTime()-OrderOpenTime())>=3*Period()*60
                  && (CurTime()-OrderOpenTime())<4*Period()*60
                  && Close[1]>OrderOpenPrice()+3*Point)
                 )
                 {
                  OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet);
                  return(0); 
                 }

               // изменение SL при безубыточности
               if(UseTrailingStop
                  && (OrderOpenPrice()-Ask)>StartProfit*Point
                  && I2Current<I2Previous)                            
                  // цена ордера в области безубыточности
                  // стоп устанавливаем по верхней границе быстрого канала
                 {
                  StopLoss=I2Current+TSLPlus*Point;
                  if(OrderStopLoss()>StopLoss)
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),StopLoss,0,0,Red);
                     return(0);
                    }
                 }

            return(0);
           }
        }      
       
     }
   return(0);
  }
//====================================================================
// функции
//====================================================================
// отображение опорного центра и линий поддержки/сопротивления
//--------------------------------------------------------------------
void ShowPivot(double Pivot,double R1,double R2,double R3,double S1,double S2,double S3)
{
   ObjectDelete("P_Line");
   ObjectDelete("S3_Line");
   ObjectDelete("R3_Line");
   ObjectDelete("S2_Line");
   ObjectDelete("R2_Line");
   ObjectDelete("S1_Line");
   ObjectDelete("R1_Line");

   ObjectCreate("P_Line",OBJ_HLINE,0,CurTime(),Pivot);
   ObjectSet("P_Line",OBJPROP_COLOR,DeepPink);
   ObjectSet("P_Line",OBJPROP_STYLE,STYLE_SOLID);

   ObjectCreate("S3_Line",OBJ_HLINE,0,CurTime(),S3);
   ObjectSet("S3_Line",OBJPROP_COLOR,Red);
   ObjectSet("S3_Line",OBJPROP_STYLE,STYLE_SOLID);

   ObjectCreate("R3_Line",OBJ_HLINE,0,CurTime(),R3);
   ObjectSet("R3_Line",OBJPROP_COLOR,Red);
   ObjectSet("R3_Line",OBJPROP_STYLE,STYLE_SOLID);

   ObjectCreate("S2_Line",OBJ_HLINE,0,CurTime(),S2);
   ObjectSet("S2_Line",OBJPROP_COLOR,Orange);
   ObjectSet("S2_Line",OBJPROP_STYLE,STYLE_SOLID);

   ObjectCreate("R2_Line",OBJ_HLINE,0,CurTime(),R2);
   ObjectSet("R2_Line",OBJPROP_COLOR,Orange);
   ObjectSet("R2_Line",OBJPROP_STYLE,STYLE_SOLID);

   ObjectCreate("S1_Line",OBJ_HLINE,0,CurTime(),S1);
   ObjectSet("S1_Line",OBJPROP_COLOR,Yellow);
   ObjectSet("S1_Line",OBJPROP_STYLE,STYLE_SOLID);

   ObjectCreate("R1_Line",OBJ_HLINE,0,CurTime(),R1);
   ObjectSet("R1_Line",OBJPROP_COLOR,Yellow);
   ObjectSet("R1_Line",OBJPROP_STYLE,STYLE_SOLID);

   ObjectsRedraw();

   if(ObjectFind("R3 label")!=0)
      {
       ObjectCreate("R3 label",OBJ_TEXT,0,Time[0],R3);
       ObjectSetText("R3 label"," R3 ",6,"Arial",Red);
      }
   else ObjectMove("R3 label",0,Time[0],R3);
   
   if(ObjectFind("S3 label")!=0)
      {
       ObjectCreate("S3 label",OBJ_TEXT,0,Time[0],S3);
       ObjectSetText("S3 label"," S3 ",6,"Arial",Red);
      }
   else ObjectMove("S3 label",0,Time[0],S3);
 
   if(ObjectFind("R2 label")!=0)
      {
       ObjectCreate("R2 label",OBJ_TEXT,0,Time[0],R2);
       ObjectSetText("R2 label"," R2 ",6,"Arial",Orange);
      }
   else ObjectMove("R2 label",0,Time[0],R2);
 
   if(ObjectFind("S2 label")!=0)
      {
       ObjectCreate("S2 label",OBJ_TEXT,0,Time[0],S2);
       ObjectSetText("S2 label"," S2 ",6,"Arial",Orange);
      }
   else ObjectMove("S2 label",0,Time[0],S2);

   if(ObjectFind("R1 label")!=0)
      {
       ObjectCreate("R1 label",OBJ_TEXT,0,Time[0],R1);
       ObjectSetText("R1 label"," R1 ",6,"Arial",Yellow);
      }
   else ObjectMove("R1 label",0,Time[0],R1);

   if(ObjectFind("S1 label")!=0)
      {
       ObjectCreate("S1 label",OBJ_TEXT,0,Time[0],S1);
       ObjectSetText("S1 label"," S1 ", 6,"Arial",Yellow);
      }
   else ObjectMove("S1 label",0,Time[0],S1);

   if(ObjectFind("P label")!=0)
      {
       ObjectCreate("P label",OBJ_TEXT,0,Time[0],Pivot);
       ObjectSetText("P label"," P ",6,"Arial",DeepPink);
      }
   else ObjectMove("P label",0,Time[0],Pivot);
}

// открыть длинную позицию
void OpenBuy(int s,double I1)
  {
   double Lots, TakeProfit, StopLoss;
   int ticket;

   if(s==1) 
      {
       TakeProfit=Ask+12*Point;
       StopLoss=I1-5*Point;
      }
   else 
      {
       TakeProfit=Ask+TP*Point;
       StopLoss=Low[1]-SLPlus*Point;
      }

   ticket=OrderSend(Symbol(),OP_BUY,PosSize(),Ask,3,StopLoss,TakeProfit,"MyFriend",9552,0,Aqua);
   if(ticket>0)
      {
       if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
          { 
           Print("BUY ордер открыт: ",OrderOpenPrice());
          }
      }
   else Print("Ошибка открытия ордера BUY: ",GetLastError()); 
  }

// открыть короткую позицию
void OpenSell(int s,double I2)
  {
   double Lots, TakeProfit, StopLoss;
   int ticket;

   if(s==-1) 
      {
       TakeProfit=Bid-12*Point;
       StopLoss=I2+5*Point;
      }
   else 
      {
       TakeProfit=Bid-TP*Point;
       StopLoss=High[1]+SLPlus*Point;
      }

   ticket=OrderSend(Symbol(),OP_SELL,PosSize(),Bid,3,StopLoss,TakeProfit,"MyFriend",9552,0,Red);
   if(ticket>0)
      {
       if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
         { 
          Print("SELL ордер открыт: ",OrderOpenPrice());
         }
      }
   else Print("Ошибка открытия ордера SELL: ",GetLastError()); 
  }

// расчет размера открываемой позиции
double PosSize()
  {
   double L;
   
   L=0.1;
   L=NormalizeDouble(AccountFreeMargin()*Risk/1000.0,1);
   if(L>5)
      { 
       if(IsTesting()) L=5;
       else L=MarketInfo("EURUSD",MODE_MAXLOT);
      }
   if(L<0.1) L=0.1;
   return(L);
}  




//+------------------------------------------------------------------+

