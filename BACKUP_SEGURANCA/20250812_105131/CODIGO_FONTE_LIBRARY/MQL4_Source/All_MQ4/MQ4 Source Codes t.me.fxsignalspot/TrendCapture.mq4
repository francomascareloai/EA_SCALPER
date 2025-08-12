//+------------------------------------------------------------------+
//|                                                         Prev.mq4 |
//|                              Copyright © 2006, Yury V. Reshetov. |
//|                                       http://betaexpert.narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Yury V. Reshetov. ICQ: 282715499"
#property link      "http://betaexpert.narod.ru"

#include <stdlib.mqh>


//---- Входные параметры

// Мы согласны на такую прибыль и нам чужого не надо
extern double     TakeProfit=180.0;
// Если мы просчитались, то такой убыток нас вполне устроит
extern double     StopLoss=50.0;
// Оптимальная доля наших деньжат, которую мы можем продуть 
// без риска остаться без портков
extern double     MaximumRisk = 0.03;
// Здесь мы будем запоминать время последнего сформировавшегося бара
static int        prevtime = 0;

//+------------------------------------------------------------------+
//|              Поехали!                                            |
//+------------------------------------------------------------------+
int start() {
   // Для начала не мешает убедиться, что сформировался новый бар
   // Иначе брокер может открыть позицию и вне рынка,
   // тогда хрен докажешь, что от был неправ.
   // К тому же, индикаторы при внутрибаровой торговле могут 
   // менять показания как им удумается - семь пятниц на неделе.
   if (Time[0] == prevtime) return(0);
   // Запомним текущий бар
   prevtime = Time[0];
   // Сколько позиций у нас открыто?
   int total = OrdersTotal();
   // Номер тикета 
   int ticket = -1;
   for(int cnt = 0; cnt < total; cnt++) {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      // если это открытая позиция и инструмент совпадает
      if(OrderType() <= OP_SELL && OrderSymbol() == Symbol()) {
         ticket = OrderTicket();
      }
   }
   // Если есть уже открытая позиция, то новую открывать не стоит
   if (ticket < 0) {
      int cmd = OP_BUY;
      // Сколько у нас закрытых ордеров?
      int htotal = HistoryTotal();
      // Покопаемся в истории счета
      for(int i = 0; i < htotal; i++) {
         if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) == false) { 
            Print("Ошибка в истории счета! Обратись к брокеру! Может он украл наши денежки и подтер следы?"); 
            break; 
         }
         // Если ордер нашего символа и он до закрытия 
         // не был лимитным
         if ((OrderSymbol()!= Symbol()) || (OrderType() > OP_SELL)) 
            continue;
         // Если ордер был закрыт с прибылью, то бишь по TakeProfit
         if (OrderProfit() > 0) {
            // Значит следующая позиция будет в том же направлении
            cmd = OrderType();
         } else { // в противном случае, 
                  // рынок уже развернулся
                  // и нам туда же
            if (OrderType() == OP_SELL) {
               cmd = OP_BUY;
            } else {
               cmd = OP_SELL;
            }
         }
      }  
      // Что там шепчут индикаторы?
      double sar = iSAR(NULL, 0, 0.02, 0.2, 0);
      double adx = iADX(NULL, 0, 14, PRICE_CLOSE, MODE_MAIN, 0);
      if (cmd == OP_BUY) { // Если открываем длинную позицию
         // Ждем когда тренд немного приподымется
         // и на рынке все спокойно
         if ((sar < Close[0]) && (adx < 20)) { 
            // Покупаем
            ticket=OrderSend(Symbol(),OP_BUY, LotsOptimized(), Ask, 3, Bid - StopLoss * Point, Ask + TakeProfit * Point, "TrendCapture", 16384, 0, Blue);
            // Запишем в журнал, как отреагировал брокер
            if(ticket > 0) {
               if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) 
                  Print("Длинная позиция открыта по цене : ",OrderOpenPrice());
            } else 
               Print(ErrorDescription(GetLastError())); 
            return(0); 
         }
      } else { // Если открываем короткую позицию
         // Ждем когда тренд немного присядет 
         // и на рынке все спокойно
         if ((sar > Close[0]) && (adx < 20)) { 
            // Продаем
            ticket=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,Ask + StopLoss * Point,Bid-TakeProfit*Point,"TrendCapture",16384,0,Red);
            // Запишем в журнал, как отреагировал брокер
            if(ticket > 0) {
               if(OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) 
                  Print("Короткая позиция открыта по цене : ",OrderOpenPrice());
            } else 
               Print(ErrorDescription(GetLastError())); 
            return(0); 
         }
      } 
   }
   
      // Предохранитель
   double    Guard = 5.0;
   OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
   if(OrderType()==OP_BUY) {  // длинная открытая позиция
      // Если текущая цена позволяет выставить предохранитель             
      if(Bid-OrderOpenPrice()>Point*Guard) {
         // Если защита стоит в убытке
         if(OrderStopLoss() < OrderOpenPrice()) {
            // За что купил, за то и продаю
            OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, Blue);
            // Выходим
            return(0);
         }
      }
              
   }
   else // Если позиция короткая
   {
      // Если текущая цена позволяет выставить предохранитель             
      if((OrderOpenPrice() - Ask) > (Point*Guard)) {
         // Если защита стоит в убытке
         if(OrderStopLoss() > OrderOpenPrice()) {
            // За что купил, за то и продаю
            OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, Red);
            // Выходим
            return(0);
         }
      }
   }
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| Money Management                                                 |
//+------------------------------------------------------------------+
double LotsOptimized()
  {
   double lot = 0.1;
   int    losses = 0;                  // number of losses orders without a break
//---- select lot size
   lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000.0,1);
//---- return lot size
   if (lot > 100) lot = 100;
   if(lot < 0.1) lot = 0.1;
   return(lot);
}
//+----------------- Вот и сказке звиздец ----------------+

