//+------------------------------------------------------------------+
//|                                              SHE_Baluev_Real.mq4 |
//|                                         Copyright © 2006, Shurka |
//|                                                 shforex@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Shurka"
#property link      "shforex@narod.ru"
#define MAGIC 130106

//---- Вводимые (изменяемые) параметры
extern int     Per=50; //Период в пунктах, через который расставляются отложенные ордера
extern int     Profit=100; //Величина профита
extern int     Stop=100; //Величина стоплосса, она же трейлинг
extern int     StepTrail=10;
extern double  Lots=0.1;
extern string  Symb="*";
//---- Всякие вспомогательные переменные
int    i, BS[5], SS[5], bi, si, B;
double SL, TP, UR, PNT, ASK, BID;
string SMB;

//+------------------------------------------------------------------+
//| фуккция инициализации эксперта                                   |
//| выполняется один раз при подеключении советника к графику        |
//| или при смене пары или таймфрейма                                |
//+------------------------------------------------------------------+
int init()
{
   if(Symb=="*") SMB=Symbol(); else SMB=Symb;
   PNT=MarketInfo(SMB,MODE_POINT);
   return(0);
}
//+------------------------------------------------------------------+
//| фуккция деинициализации эксперта                                 |
//| тут ничего не делаем. выполняется при отключении советника       |
//+------------------------------------------------------------------+
int deinit() {   return(0); }
//+------------------------------------------------------------------+
//| собсна сам советник                                              |
//+------------------------------------------------------------------+
int start()
{
   if(!IsTradeAllowed())
   {
      Comment("Торговля по этому инструменту запрещена или торговый поток занят."); return(0);
   } else Comment("                                                                    ");
   bi=0; si=0; B=0; // инициализируем вспомогательные переменные
   SL=MarketInfo(SMB,MODE_ASK);
   ASK=MarketInfo(SMB,MODE_ASK);
   BID=MarketInfo(SMB,MODE_BID);
   for(i=0;i<OrdersTotal();i++) // проходим по всем существующим ордерам-----------------------------------
   {
      OrderSelect(i, SELECT_BY_POS); // закрепляем очередной ордер, типа с ним работать бум
      if(OrderSymbol()!=SMB || OrderMagicNumber()!=MAGIC) continue; // Если не наш - смотрим следующий
      
      if(OrderType()==OP_BUYSTOP) {BS[bi]=i;bi++;}   else // если он байстоп, то в BS запоминаем его номер
      if(OrderType()==OP_SELLSTOP) {SS[si]=i;si++;}  else // если он селлстоп, то в SS запоминаем его номер
      if(OrderType()==OP_BUY) // если он открытый в покупку, то...
      {
         B=1; // помечаем, что был ордер открытый в покупку.
         if(OrderStopLoss()<BID-(Stop+StepTrail)*PNT) // подтягиваем стоп если текущий отстал
            OrderModify(OrderTicket(),OrderOpenPrice(),BID-Stop*PNT,OrderTakeProfit(),0,CLR_NONE);
         if( SL>OrderStopLoss()) SL=OrderStopLoss(); // В SL запоминаем уровень стоплосса,
         //  чтобы потом подтянуть разворотный селлстоп ордер
      } else // иначе, если это открытый ордер в продажу то всё как и с покупкой но наоборот
      if(OrderType()==OP_SELL)
      {
         B=-1; // помечаем, что был ордер открытый в продажу.
         if(OrderStopLoss()>ASK+(Stop+StepTrail)*PNT)
            OrderModify(OrderTicket(),OrderOpenPrice(),ASK+Stop*PNT,OrderTakeProfit(),0,CLR_NONE);
         if( SL<OrderStopLoss()) SL=OrderStopLoss();
      }
   } // цикл закончен, мы просмотрели все ордера. Теперь...------------------------------------------------
   // нужно подтянуть отложенные ордера вслед за играющими
   if(B==1) // если среди них был хоть один открытый в покупку, а по логике игры, не может быть
            // одновременно открыты ордера и в покупку и в продажу, только в одну сторону.
            // Отложенные разворотные ордера могут сработать только после лося.
   {
      for(i=0;i<si;i++) // если был найден хоть один селлстоп
      {
         if(Profit==0) TP=0; else TP=SL-(Profit+i*Per)*PNT;
         OrderSelect(SS[i], SELECT_BY_POS); // цепляем его
         OrderModify(OrderTicket(),SL-i*Per*PNT,SL+(Stop-i*Per)*PNT,TP,0,CLR_NONE); // сдвигаем на уровень
         // наименьшего стоплосса для бай ордеров
      }
   } else // Иначе, если нет бай ордеров, но есть селл ордера, то тот же цирк вниз
   if(B==-1)
   {
      for(i=0;i<bi;i++)
      {
         if(Profit==0) TP=0; else TP=SL+(Profit+i*Per)*PNT;
         OrderSelect(BS[i], SELECT_BY_POS);
         OrderModify(OrderTicket(),SL+i*Per*PNT,SL+(i*Per-Stop)*PNT,TP,0,CLR_NONE);
      }
   }// Покончили с перемещением уровня открытия существующих отложенных ордеров на уровень стопов
   // открытых ордеров-------------------------------------------------------------------------------------
   // В переменную UR записываем уровень для ближайшего отложенного SellStop ордера.
   // Нужно, чтобы отложенные в покупку и продажу не пересекались стопами, поэтому если уровень стопа
   // больше чем 2 периода, то первые отложенные ордера должны быть не на расстоянии Per вверх и вниз
   // от текущей цены, а на расстоянии Stop друг от друга, т.е половины Stop от цены.
   if(Stop>2*Per) UR=BID-(Stop/2)*PNT;
   else UR=BID-Per*PNT;
   for(i=0;i<si;i++) // Пробегаем по всем существующим отложенным в продажу и сдвигаем UR вниз
                     // до самого нижнего.
   {
      OrderSelect(SS[i], SELECT_BY_POS); // цепляем его
      if(UR>OrderOpenPrice()) UR=OrderOpenPrice();
   }
   if(si>0) UR-=Per*PNT;
   for(i=si;i<5;i++)// Теперь нужно добавить недостающих отложенных до 10 (5 и 5)
   {
      if(Profit==0) TP=0; else TP=UR-(Profit+(i-si)*Per)*PNT;
      OrderSend(SMB,OP_SELLSTOP,Lots,UR-(i-si)*Per*PNT,3,UR+(Stop-(i-si)*Per)*PNT,TP,NULL,MAGIC,0,CLR_NONE);
   }
   // То же самое делаем и с отложенными в покупку.
   if(Stop>2*Per) UR=ASK+(Stop/2)*PNT;
   else UR=ASK+Per*PNT;
   for(i=0;i<bi;i++)
   {
      OrderSelect(BS[i], SELECT_BY_POS); // цепляем его
      if(UR<OrderOpenPrice()) UR=OrderOpenPrice();
   }
   if(bi>0) UR+=Per*PNT;
   for(i=bi;i<5;i++)
   {
      if(Profit==0) TP=0; else TP=UR+(Profit+(i-bi)*Per)*PNT;
      OrderSend(SMB,OP_BUYSTOP,Lots,UR+(i-bi)*Per*PNT,3,UR+((i-bi)*Per-Stop)*PNT,TP,NULL,MAGIC,0,CLR_NONE);
   }
   return(0);
}
//+------------------------------------------------------------------+
// Что не ясно, пишите, спрашивайте, не стесняйтесь.