//+------------------------------------------------------------------+
//|                                           Serg153 Martingail.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                         http://pilot911.narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://pilot911.narod.ru"

//---- input parameters
//extern double    StartFromPartOfLot=0.1;
//extern int       StopLoss=25;
//extern int       TakeProfit=25;




//+----------------------------------------------------------------------------------------------------------+
//| Описание стратегии:
//| 
//| Стратегия работает на основе увеличения поз после лоссовых сделок
//| Причем лоссовые сделки не закрываются. Просто засекаем уровень,
//| например, 20 пипсов в качестве виртуального стоплосса - по 
//| достижении которого открываемся увеличенной позой в ту же сторону
//| (селл или бай имею в виду), в которую был открыт предыдущий  
//| лоссовый ордер.
//| 
//| Система отличается от обычного мартингейла тем, что в самом начале
//| на первом шаге открываемся в обе стороны одинаковыми позами.
//| После этого, как описал выше - удваиваем новые позы (см шаги ниже - можно и не удваивать... думайте
//| свою прибыльную последовательность).
//|
//| Возможные варианты поз относительно позы на первом шаге (можно дописать знающим людям):
//|
//| По минусовой руке:
//| 1-1-2-4-8-входим в лок
//| или
//| 1-1-2-3-7-входим в лок
//| или
//| ...ваш вариант  
//|
//| По плюсовой руке: 
//| 1- и все.. на первом шаге открыта только минимальная поза 
//|
//| Все сделки закрываются после отката на любом шаге на 20 пипсов минусовой руки 
//| Если дошли до 5го шага без отката и далее идет движение против нас без отката - локируем минусовую руку
//| и далее разруливаем лок (ждем день или неделю...) - но в результате лока средства высвобождаются, 
//| хотя у разных дилинговых центров свои условия по локированию.. могут под маржу и продолжать держать 
//| средства.
//|
//| Я оперирую шагом в 20 пипсов - но можно использовать другой.
//| Все рассчитывается, как описано на форуме альпари в теме Мартингейл
//|
//| http://forum.alpari-idc.ru/viewtopic.php?t=43148
//|
//+----------------------------------------------------------------------------------------------------------+



   int               cnt, total,                      // счетчики, временные переменные
                     ticket1=0,                         // тикет первого открытого на первом шаге ордера
                     ticket2=0,                         // тикет второго ордера, открытого в противоположную сторону относитель ticket1 на первом шаге
                     ticket3=0,
                     ticket4=0,
                     ticket5=0,
                     ticket6=0,
                     ticket7=0,
                     ticket8=0,                                                            
                     tiketPlus=0;                       // переменная хранит значение тикета профитного ордера, устанавливается после получения одним из ордеров ticket1 или ticket2 виртуального лосса (сделка не закрывается) 
   int               OpenSell0_Byu1;                  // флаг, определяющий, в какую сторону открывать ордера против тренда (по которым на предыдущих шагах получали виртульаный лосс)
   
            
            // Steps in pips
extern   int         Step1Pips=20,
                     Step2Pips=20,
                     Step3Pips=20,
                     Step4Pips=20,
                     Step5Pips=20;
            // Steps in lots
extern   double         Step1Lots=1,
                     Step2Lots=1,
                     Step3Lots=2,
                     Step4Lots=4,
                     Step5Lots=8;
            
   int               StepMartingail=0;








//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
   total = 0;
   for (cnt=0;cnt<73;cnt++)
   {          

      if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderType()<=OP_SELL && OrderSymbol()==Symbol()) total++;
      }
   }

   Comment("Текущий шаг: ", StepMartingail, "\nticket1: ", ticket1, "\nticket2: ", ticket2, "\nticket3: ", ticket3, "\nticket4: ", ticket4, "\nticket5: ", ticket5, "\nticket6: ", ticket6, "\nticket7: ", ticket7);
 
   //+--
   //| самое начало - обнуляем все переменные и открываемся в обе стороны
   //+--
   if (StepMartingail==0 || StepMartingail==1000000)
   {
   
      //--
      // Флаг, показывающий, в какую сторону открываться - устанавливается сразу после того, как дошли
      // до первой ступени и получили первый виртуальный лосс (сделка не закрывается)
      // ставим 0 или 1: если лоссовая сделка была SELL - ставим 0, иначе - 1
      //--
      tiketPlus   = 0;     // нет пока плюсового ордера
      ticket1     = 0;
      ticket2     = 0;
      ticket3     = 0;
      ticket4     = 0;
      ticket5     = 0;
      ticket6     = 0;
      ticket7     = 0;
      ticket8     = 0;                                                            
      tiketPlus   = 0; 

      StepMartingail = 1;
      
   }   
   else if (StepMartingail == 1)
   {
      //--
      // На первом шаге открываемся в обе стороны
      //--
   
      if (ticket1 <= 0)
      {
         ticket1  =  OrderSend(Symbol(),   OP_BUY,  Step1Lots,  Ask,  3, Ask - 2000*Point,  Ask+2000*Point, "macd sample", 16384,   0, Green);
      }
      else if (ticket2 <= 0)
      {
         ticket2  =  OrderSend(Symbol(),   OP_SELL, Step1Lots,  Bid,  3, Bid + 2000*Point,  Bid-2000*Point, "macd sample", 16384,   0, Green);
      }
   }   
   else if (StepMartingail == 2 && ticket3<=0)
   {
      if (OpenSell0_Byu1 == 1)
      {
         ticket3  =  OrderSend(Symbol(),   OP_BUY,  Step2Lots,  Ask,  3, Ask - 2000*Point,  Ask+2000*Point, "macd sample", 16384,   0, Green);
      }
      else if (OpenSell0_Byu1 == 0)
      {
         ticket3  =  OrderSend(Symbol(),   OP_SELL, Step2Lots,  Bid,  3, Bid + 2000*Point,  Bid-2000*Point, "macd sample", 16384,   0, Green);
      }
   }   
   else if (StepMartingail == 3 && ticket4<=0)
   {
      if (OpenSell0_Byu1 == 1)
      {
         ticket4  =  OrderSend(Symbol(),   OP_BUY,  Step3Lots,  Ask,  3, Ask - 2000*Point,  Ask+2000*Point, "macd sample", 16384,   0, Green);
      }
      else if (OpenSell0_Byu1 == 0)
      {
         ticket4  =  OrderSend(Symbol(),   OP_SELL, Step3Lots,  Bid,  3, Bid + 2000*Point,  Bid-2000*Point, "macd sample", 16384,   0, Green);
      }
   }   
   else if (StepMartingail == 4 && ticket5<=0)
   {
      if (OpenSell0_Byu1 == 1)
      {
         ticket5  =  OrderSend(Symbol(),   OP_BUY,  Step4Lots,  Ask,  3, Ask - 2000*Point,  Ask+2000*Point, "macd sample", 16384,   0, Green);
      }
      else if (OpenSell0_Byu1 == 0)
      {
         ticket5  =  OrderSend(Symbol(),   OP_SELL, Step4Lots,  Bid,  3, Bid + 2000*Point,  Bid-2000*Point, "macd sample", 16384,   0, Green);
      }
   }
   else if (StepMartingail == 5 && ticket6<=0)
   {
      if (OpenSell0_Byu1 == 1)
      {
         ticket6  =  OrderSend(Symbol(),   OP_BUY,  Step5Lots,  Ask,  3, Ask - 2000*Point,  Ask+2000*Point, "macd sample", 16384,   0, Green);
      }
      else if (OpenSell0_Byu1 == 0)
      {
         ticket6  =  OrderSend(Symbol(),   OP_SELL, Step5Lots,  Bid,  3, Bid + 2000*Point,  Bid-2000*Point, "macd sample", 16384,   0, Green);
      }
   }      
   else if (StepMartingail == 999) // go to LOCK!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
   {
      if (OpenSell0_Byu1 == 0)
      {
         ticket7  =  OrderSend(Symbol(),   OP_BUY,  (Step2Lots+Step3Lots+Step4Lots+Step5Lots),  Ask,  3, Ask - 2000*Point,  Ask+2000*Point, "macd sample", 16384,   0, Green);
      }
      else if (OpenSell0_Byu1 == 1)
      {
         ticket7  =  OrderSend(Symbol(),   OP_SELL, (Step2Lots+Step3Lots+Step4Lots+Step5Lots),  Bid,  3, Bid + 2000*Point,  Bid-2000*Point, "macd sample", 16384,   0, Green);
      }
      
      StepMartingail = 1000000;
   }
         

      
      
      
      if (StepMartingail == 1 && ticket1>0 && ticket2>0)
      {
         if(OrderSelect(ticket1, SELECT_BY_TICKET, MODE_TRADES))
         {
        
             if (OrderOpenPrice() - Bid > Step1Pips*Point)
             {
                 StepMartingail = 2;
                 OpenSell0_Byu1 = 1;
                 tiketPlus = ticket2;                 
             }
         }  
         else if (OrderSelect(ticket2, SELECT_BY_TICKET, MODE_TRADES))
         {
             if (Ask - OrderOpenPrice() > Step1Pips*Point)
             {
                 StepMartingail = 2;
                 OpenSell0_Byu1 = 0;                 
                 tiketPlus = ticket1;
             }
         }
      }
      else if (StepMartingail == 2 && ticket3>0)
      {
   
         if(OrderSelect(ticket3, SELECT_BY_TICKET, MODE_TRADES) && OpenSell0_Byu1 == 1)
         {
      
             if (OrderOpenPrice() - Bid > Step2Pips*Point)
             {
                 StepMartingail = 3;
             }
             else if (Bid  -  OrderOpenPrice() > Step2Pips*Point)
             {
                 StepMartingail = 2000000;
             }
         }  
         else if (OrderSelect(ticket3, SELECT_BY_TICKET, MODE_TRADES)  && OpenSell0_Byu1 == 0)
         {
         
             if (Ask - OrderOpenPrice() > Step2Pips*Point)
             {
                 StepMartingail = 3;
             }
             else if (OrderOpenPrice() - Ask > Step2Pips*Point)
             {
                 StepMartingail = 2000000;
             }
         } 
      }  
      else if (StepMartingail == 3 && ticket4>0)
      {
         if(OrderSelect(ticket4, SELECT_BY_TICKET, MODE_TRADES) && OpenSell0_Byu1 == 1)
         {
             if (OrderOpenPrice() - Bid > Step3Pips*Point)
             {
                 StepMartingail = 4;
             }
             else if (Bid  -  OrderOpenPrice() > Step3Pips*Point)
             {
                 StepMartingail = 2000000;
             }
         }  
         else if (OrderSelect(ticket4, SELECT_BY_TICKET, MODE_TRADES) && OpenSell0_Byu1 == 0)
         {
             if (Ask - OrderOpenPrice() > Step3Pips*Point)
             {
                 StepMartingail = 4;
             }
             else if (OrderOpenPrice() - Ask > Step3Pips*Point)
             {
                 StepMartingail = 2000000;
             }
         } 
      }        
      else if (StepMartingail == 4 && ticket5>0)
      {
         if(OrderSelect(ticket5, SELECT_BY_TICKET, MODE_TRADES) && OpenSell0_Byu1 == 1)
         {
             if (OrderOpenPrice() - Bid > Step4Pips*Point)
             {
                 StepMartingail = 5;
             }
             else if (Bid  -  OrderOpenPrice() > Step4Pips*Point)
             {
                 StepMartingail = 2000000;
             }
         }  
         else if (OrderSelect(ticket5, SELECT_BY_TICKET, MODE_TRADES) && OpenSell0_Byu1 == 0)
         {
             if (Ask - OrderOpenPrice() > Step4Pips*Point)
             {
                 StepMartingail = 5;
             }
             else if (OrderOpenPrice() - Ask > Step4Pips*Point)
             {
                 StepMartingail = 2000000;
             }
         }
      }            
      else if (StepMartingail == 5 && ticket6>0)
      {
         if(OrderSelect(ticket6, SELECT_BY_TICKET, MODE_TRADES) && OpenSell0_Byu1 == 1)
         {
             if (OrderOpenPrice() - Bid > Step5Pips*Point)
             {
                 StepMartingail = 999;// LOCKS
             }
             else if (Bid  -  OrderOpenPrice() > Step5Pips*Point)
             {
                 StepMartingail = 2000000;
             }
         }  
         else if (OrderSelect(ticket6, SELECT_BY_TICKET, MODE_TRADES) && OpenSell0_Byu1 == 0)
         {
             if (Ask - OrderOpenPrice() > Step5Pips*Point)
             {
                 StepMartingail = 999;// LOCKS
             }
             else if (OrderOpenPrice() - Ask > Step5Pips*Point)
             {
                 StepMartingail = 2000000;
             }
         }
      }
      else if (StepMartingail == 2000000)
      {
         if (ticket1 > 0 || ticket2 > 0 || ticket3 > 0 || ticket4 > 0 || ticket5 > 0 || ticket6 > 0 || ticket7 > 0 || ticket8 > 0 )
         {
              if (OrderSelect(ticket1, SELECT_BY_TICKET, MODE_TRADES) && ticket1 > 0) 
              {
                  OrderClose(ticket1,OrderLots(),Bid,3,Violet); // close position
                  ticket1 = -1;
              }
              else if (OrderSelect(ticket2, SELECT_BY_TICKET, MODE_TRADES) && ticket2 > 0) 
              {
                  OrderClose(ticket2,OrderLots(),Ask,3,Violet); // close position
                  ticket2 = -1;                  
              }
              else if (OrderSelect(ticket3, SELECT_BY_TICKET, MODE_TRADES) && ticket3 > 0) 
              {
                  if (OpenSell0_Byu1   == 1)  OrderClose(ticket3,OrderLots(),Bid,3,Violet); // close position
                  if (OpenSell0_Byu1   == 0)  OrderClose(ticket3,OrderLots(),Ask,3,Violet); // close position                  
                  ticket3 = -1;                  
              }    
              else if (OrderSelect(ticket4, SELECT_BY_TICKET, MODE_TRADES) && ticket4 > 0) 
              {
                  if (OpenSell0_Byu1   == 1)  OrderClose(ticket4,OrderLots(),Bid,3,Violet); // close position
                  if (OpenSell0_Byu1   == 0)  OrderClose(ticket4,OrderLots(),Ask,3,Violet); // close position
                  ticket4 = -1;                                    
              } 
              else if (OrderSelect(ticket5, SELECT_BY_TICKET, MODE_TRADES) && ticket5 > 0) 
              {
                  if (OpenSell0_Byu1   == 1)  OrderClose(ticket5,OrderLots(),Bid,3,Violet); // close position
                  if (OpenSell0_Byu1   == 0)  OrderClose(ticket5,OrderLots(),Ask,3,Violet); // close position                  
                  ticket5 = -1;                  
              } 
              else if (OrderSelect(ticket6, SELECT_BY_TICKET, MODE_TRADES) && ticket6 > 0) 
              {
                  if (OpenSell0_Byu1   == 1)  OrderClose(ticket6,OrderLots(),Bid,3,Violet); // close position
                  if (OpenSell0_Byu1   == 0)  OrderClose(ticket6,OrderLots(),Ask,3,Violet); // close position                  
                  ticket6 = -1;                  
              } 
              else if (OrderSelect(ticket7, SELECT_BY_TICKET, MODE_TRADES) && ticket7 > 0) 
              {
                  if (OpenSell0_Byu1   == 1)  OrderClose(ticket7,OrderLots(),Bid,3,Violet); // close position
                  if (OpenSell0_Byu1   == 0)  OrderClose(ticket7,OrderLots(),Ask,3,Violet); // close position                  
                  ticket7 = -1;                  
              } 
                                           
         }
         else StepMartingail = 0;
      }



//OPEN BUY (вверх) происходит по цене ASK, а CLOSE - по цене BID; OPEN SELL (вниз) - по цене BID, а CLOSE - по цене ASK. 

//----
   return(0);
  }
//+------------------------------------------------------------------+