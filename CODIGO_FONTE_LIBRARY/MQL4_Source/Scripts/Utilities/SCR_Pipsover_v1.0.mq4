//+------------------------------------------------------------------+
//|                                                     Pipsover.mq4 |
//|                              Copyright © 2006, Yury V. Reshetov. |
//|                                       http://betaexpert.narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Yury V. Reshetov. ICQ: 282715499"
#property link      "http://betaexpert.narod.ru"

//---- input parameters
// Объемы
extern double lots = 0.1;
// убытки
extern double stoploss = 70;
// Прибыль
extern double takeprofit = 140;
// Предельный уровень значения индикатора Чайкина для открытия позиции
extern double openlevel = 55;
// Предельный уровень значения индикатора Чайкина для локирования позиции
extern double closelevel = 90;
// Время последнего бара
static int prevtime = 0;

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
   // Ждем, когда сформируется новый бар
   if (Time[0] == prevtime) return(0);
   prevtime = Time[0];
//---- 
   // 20 периодный мувинг
   double ma = iMA(NULL, 0, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
   // Предыдущее значение индикатора Чайкина
   double ch = iCustom(NULL, 0, "Chaikin", 0, 0, 1);
   
   // Нет открытых позиций
   if (OrdersTotal() < 1) {
      int res = 0;
      // Если значение индикатора Чайкина зашкалило и начался потенциальный разворот
      // Своего рода перепроданность
      // Покупаем
      if (Close[1] > Open[1] && Low[1] < ma && ch < -openlevel) {
         res=OrderSend(Symbol(), OP_BUY, lots ,Ask, 3, Ask - stoploss * Point, Bid + takeprofit * Point, "Pipsover", 888, 0, Blue);
         return(0);
      }
      // Если значение индикатора Чайкина зашкалило и начался потенциальный разворот
      // Своего рода перекупленность
      // Продаем
      if (Close[1] < Open[1] && High[1] > ma &&  ch > openlevel) {
         res=OrderSend(Symbol(), OP_SELL, lots ,Bid, 3, Bid + stoploss * Point, Ask - takeprofit * Point, "Pipsover", 888, 0, Red);
         return(0);
      }
   } else { // Есть открытые позиции. Может быть пора подстраховаться?
   
      // Если открыта всего одна позиция
      if (OrdersTotal() > 1) return(0);
   
      OrderSelect(0, SELECT_BY_POS, MODE_TRADES);
   
      // Похоже на откат, залокируем длинную позицию
      if (OrderType() == OP_BUY  && Close[1] < Open[1] && High[1] > ma &&  ch > closelevel) {
         res=OrderSend(Symbol(), OP_SELL, lots ,Bid, 3, Bid + stoploss * Point, Ask - takeprofit * Point, "Pipsover", 888, 0, Red);
         return(0);
      }
      
      // Похоже на откат, залокируем коротку позицию
      if (OrderType() == OP_SELL && Close[1] > Open[1] && Low[1] < ma && ch < -closelevel) {
         res=OrderSend(Symbol(), OP_BUY, lots ,Ask, 3, Ask - stoploss * Point, Bid + takeprofit * Point, "Pipsover", 888, 0, Blue);
         return(0);
      }
   }
   
//---- вот и сказке звиздец
   return(0);
  }
//+------------------------------------------------------------------+