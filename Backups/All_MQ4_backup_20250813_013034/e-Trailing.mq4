//+------------------------------------------------------------------+
//|                                                   e-Trailing.mq4 |
//|                                           Ким Игорь В. aka KimIV |
//|                                              http://www.kimiv.ru |
//|                                                                  |
//| 12.09.2005 Автоматический Trailing Stop всех открытых позиций    |
//|            Вешать только на один график                          |
//| 21.01.2006 Параметр AllPositions                                 |
//+------------------------------------------------------------------+
#property copyright "Ким Игорь В. aka KimIV"
#property link      "http://www.kimiv.ru"
//------- Внешние параметры ------------------------------------------
extern bool   AllPositions  =False;         // Управлять всеми позициями
extern bool   ProfitTrailing=True;          // Тралить только профит
extern int    TrailingStop  =15;            // Фиксированный размер трала
extern int    TrailingStep  =2;             // Шаг трала
extern bool   UseSound      =True;          // Использовать звуковой сигнал
extern string NameFileSound ="expert.wav";  // Наименование звукового файла
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
  void start() 
  {
     for(int i=0; i<OrdersTotal(); i++) 
     {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) 
        {
           if (AllPositions || OrderSymbol()==Symbol()) 
           {
            TrailingPositions();
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Сопровождение позиции простым тралом                             |
//+------------------------------------------------------------------+
  void TrailingPositions() 
  {
   double pBid, pAsk, pp;
//----
   pp=MarketInfo(OrderSymbol(), MODE_POINT);
     if (OrderType()==OP_BUY) 
     {
      pBid=MarketInfo(OrderSymbol(), MODE_BID);
        if (!ProfitTrailing || (pBid-OrderOpenPrice())>TrailingStop*pp) 
        {
           if (OrderStopLoss()<pBid-(TrailingStop+TrailingStep-1)*pp) 
           {
            ModifyStopLoss(pBid-TrailingStop*pp);
            return;
           }
        }
     }
     if (OrderType()==OP_SELL) 
     {
      pAsk=MarketInfo(OrderSymbol(), MODE_ASK);
        if (!ProfitTrailing || OrderOpenPrice()-pAsk>TrailingStop*pp) 
        {
           if (OrderStopLoss()>pAsk+(TrailingStop+TrailingStep-1)*pp || OrderStopLoss()==0) 
           {
            ModifyStopLoss(pAsk+TrailingStop*pp);
            return;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Перенос уровня StopLoss                                          |
//| Параметры:                                                       |
//|   ldStopLoss - уровень StopLoss                                  |
//+------------------------------------------------------------------+
  void ModifyStopLoss(double ldStopLoss) 
  {
   bool fm;
   fm=OrderModify(OrderTicket(),OrderOpenPrice(),ldStopLoss,OrderTakeProfit(),0,CLR_NONE);
   if (fm && UseSound) PlaySound(NameFileSound);
  }
//+------------------------------------------------------------------+