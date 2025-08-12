//+------------------------------------------------------------------+
//|                                               TrailingStairs.mq4 |
//|                                                              I_D |
//|                                            http://www.mymmk.com/ |
//+------------------------------------------------------------------+
#property copyright "I_D"
#property link      "http://www.mymmk.com/ Софт для управления капиталом"

extern   int      iTicket;             // уникальный номер (тикет) открытой позиции
extern   int      iTrl_dist_1 = 30;    // исходное расстояние трейлинга (пунктов) (не меньше MarketInfo(Symbol(),MODE_STOPLEVEL), больше trl_dist_2 и trl_dist_3);
extern   int      iLevel_1 = 50;       // уровень профита (пунктов), при достижении которого дистанция трейлинга будет сокращена с trl_dist_1 до trl_dist_2 (меньше level_2; больше trl_dist_1);
extern   int      iTrl_dist_2 = 20;    // расстояние трейлинга (пунктов) после достижения курсом уровня профита в level_1 пунктов (не меньше MarketInfo(Symbol(),MODE_STOPLEVEL));
extern   int      iLevel_2 = 70;       // уровень профита (пунктов), при достижении которого дистанция трейлинга будет сокращена с trl_dist_2 до trl_dist_3 пунктов (больше trl_dist_1 и больше level_1);
extern   int      iTrl_dist_3 = 10;    // расстояние трейлинга (пунктов) после достижения курсом уровня профита в level_2 пунктов (не меньше MarketInfo(Symbol(),MODE_STOPLEVEL)).

//+------------------------------------------------------------------+
//| ТРЕЙЛИНГ СТАНДАРТНЫЙ-ЗАТЯГИВАЮЩИЙСЯ ("УДАВКА")                   |
//| Эксперту передаётся тикет позиции, исходный трейлинг (пунктов) и |
//| 2 "уровня" (значения профита, пунктов), при которых трейлинг     |
//| сокращаем, и соответствующие значения трейлинга (пунктов)        |
//| Пример: исходный трейлинг 30 п., при +50 - 20 п., +80 и больше - |
//| на расстоянии в 10 пунктов.                                      |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {    
   return(0);
  }
  
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
  
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
   TrailingUdavka(iTicket,iTrl_dist_1,iLevel_1,iTrl_dist_2,iLevel_2,iTrl_dist_3);
   return(0);
  }
//+------------------------------------------------------------------+

void TrailingUdavka(int ticket,int trl_dist_1,int level_1,int trl_dist_2,int level_2,int trl_dist_3)
   {  
   
   double newstop = 0; // новый стоплосс
   double trldist; // расстояние трейлинга (в зависимости от "пройденного" может = trl_dist_1, trl_dist_2 или trl_dist_3)

   // проверяем переданные значения
   if ((trl_dist_1<MarketInfo(Symbol(),MODE_STOPLEVEL)) || (trl_dist_2<MarketInfo(Symbol(),MODE_STOPLEVEL)) || (trl_dist_3<MarketInfo(Symbol(),MODE_STOPLEVEL)) || 
   (level_1<=trl_dist_1) || (level_2<=trl_dist_1) || (level_2<=level_1) || (ticket==0) || (!OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)))
      {
      Print("Трейлинг функцией TrailingUdavka() невозможен из-за некорректности значений переданных ей аргументов.");
      return(0);
      } 
   
   // если длинная позиция (OP_BUY)
   if (OrderType()==OP_BUY)
      {
      // если профит <=trl_dist_1, то trldist=trl_dist_1, если профит>trl_dist_1 && профит<=level_1*Point ...
      if ((Bid-OrderOpenPrice())<=level_1*Point) trldist = trl_dist_1;
      if (((Bid-OrderOpenPrice())>level_1*Point) && ((Bid-OrderOpenPrice())<=level_2*Point)) trldist = trl_dist_2;
      if ((Bid-OrderOpenPrice())>level_2*Point) trldist = trl_dist_3; 
            
      // если стоплосс = 0 или меньше курса открытия, то если тек.цена (Bid) больше/равна дистанции курс_открытия+расст.трейлинга
      if ((OrderStopLoss()==0) || (OrderStopLoss()<OrderOpenPrice()))
         {
         if (Bid>(OrderOpenPrice() + trldist*Point))
         newstop = Bid -  trldist*Point;
         }

      // иначе: если текущая цена (Bid) больше/равна дистанции текущий_стоплосс+расстояние трейлинга, 
      else
         {
         if (Bid>(OrderStopLoss() + trldist*Point))
         newstop = Bid -  trldist*Point;
         }
      
      // модифицируем стоплосс
      if ((newstop>OrderStopLoss()) && (newstop<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
         {
         if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
         Print("Не удалось модифицировать стоплосс ордера №",OrderTicket(),". Ошибка: ",GetLastError());
         }
      }
      
   // если короткая позиция (OP_SELL)
   if (OrderType()==OP_SELL)
      { 
      // если профит <=trl_dist_1, то trldist=trl_dist_1, если профит>trl_dist_1 && профит<=level_1*Point ...
      if ((OrderOpenPrice()-(Ask + MarketInfo(Symbol(),MODE_SPREAD)*Point))<=level_1*Point) trldist = trl_dist_1;
      if (((OrderOpenPrice()-(Ask + MarketInfo(Symbol(),MODE_SPREAD)*Point))>level_1*Point) && ((OrderOpenPrice()-(Ask + MarketInfo(Symbol(),MODE_SPREAD)*Point))<=level_2*Point)) trldist = trl_dist_2;
      if ((OrderOpenPrice()-(Ask + MarketInfo(Symbol(),MODE_SPREAD)*Point))>level_2*Point) trldist = trl_dist_3; 
            
      // если стоплосс = 0 или меньше курса открытия, то если тек.цена (Ask) больше/равна дистанции курс_открытия+расст.трейлинга
      if ((OrderStopLoss()==0) || (OrderStopLoss()>OrderOpenPrice()))
         {
         if (Ask<(OrderOpenPrice() - (trldist + MarketInfo(Symbol(),MODE_SPREAD))*Point))
         newstop = Ask + trldist*Point;
         }

      // иначе: если текущая цена (Bid) больше/равна дистанции текущий_стоплосс+расстояние трейлинга, 
      else
         {
         if (Ask<(OrderStopLoss() - (trldist + MarketInfo(Symbol(),MODE_SPREAD))*Point))
         newstop = Ask +  trldist*Point;
         }
            
       // модифицируем стоплосс
      if (newstop>0)
         {
         if (((OrderStopLoss()==0) || (OrderStopLoss()>OrderOpenPrice())) && (newstop>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
            Print("Не удалось модифицировать стоплосс ордера №",OrderTicket(),". Ошибка: ",GetLastError());
            }
         else
            {
            if ((newstop<OrderStopLoss()) && (newstop>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))  
               {
               if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
               Print("Не удалось модифицировать стоплосс ордера №",OrderTicket(),". Ошибка: ",GetLastError());
               }
            }
         }
      }      
   }
//+------------------------------------------------------------------+