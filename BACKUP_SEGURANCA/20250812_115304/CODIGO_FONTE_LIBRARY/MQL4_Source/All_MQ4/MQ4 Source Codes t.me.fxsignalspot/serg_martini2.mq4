/*
Алгоритм открытия сделок по мартингейлу
***************************************
порядок нумерации ордеров магическими числами
101.102.103.104.105 - первоначальные оредра на бай
201.202.203.204.205 - первоначальные ордера на селл
*/

extern double StartLots = 0.1;
extern double Step = 20;
extern double StepFactor = 1;

extern double TimeOut = 5000;






//&& (OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLLIMIT)
//**********************************************************************
// функция изменяет текущий тэйкпрофит для всех открытых позиций на цену предпоследней сделки серии - для БАЕК // PRICE = цена нового тейкпрофита
//**********************************************************************
void setNewTakeProfitBuy(double NewTP) { 
   int TotalOrd, TekOrd, Tiket, Error;
   TotalOrd = OrdersTotal();
   for(TekOrd = 0; TekOrd < TotalOrd; TekOrd++) { OrderSelect(TekOrd, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber() >= 101 &&  OrderMagicNumber() <= 105) {
         if (NormalizeDouble(OrderTakeProfit(),Digits) != NormalizeDouble(NewTP, Digits) ) {
            Tiket = OrderModify(OrderTicket(), OrderOpenPrice(), 0, NewTP, 0, Green);
            Print ("Модификация TP для OP_BUY. TP_New = ", OrderTakeProfit(), "->", NewTP, "  lots= ", OrderLots(), " num= ", OrderTicket());
            Print ("Результат = ",Tiket);
            if (Tiket !=1 ) {Error = GetLastError(); Print ("Ошибка = ", Error); }                  
            Sleep(TimeOut);
         }
      }
   }  
}
//**********************************************************************
// функция изменяет текущий тэйкпрофит для всех открытых позиций на цену предпоследней сделки серии - для СЕЛОК // PRICE = цена нового тейкпрофита
//**********************************************************************
void setNewTakeProfitSel(double NewTP) { 
   int TotalOrd, TekOrd, Tiket, Error;
   TotalOrd = OrdersTotal();
   for(TekOrd = 0; TekOrd < TotalOrd; TekOrd++) { OrderSelect(TekOrd, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol()==Symbol() && OrderType()==OP_SELL  && OrderMagicNumber() >= 201 &&  OrderMagicNumber() <= 205) {
         if ( NormalizeDouble(OrderTakeProfit(),Digits) != NormalizeDouble(NewTP, Digits) ) {
            Tiket = OrderModify(OrderTicket(), OrderOpenPrice(), 0, NewTP, 0, Yellow);
            Print ("Модификация TP для OP_SELL. TP_New = ", OrderTakeProfit(), "->", NewTP, "  lots= ", OrderLots(), " num= ", OrderTicket() );
            Print ("Результат = ",Tiket);
            if (Tiket !=1 ) {Error = GetLastError(); Print ("Ошибка = ", Error); }                  
            Sleep(TimeOut);
         } 
      }
   }   
}
//********************************************************************
//
//Функции для модификации отложенных ордеров лонгов
//
//********************************************************************
// вычисление цены открытия ордера, который еще не активирован (нужен для установки 
// отложенного ордера нового уровня ветки или для модификации цены установленного  отложенного ордера)      
//********************************************************************
double getNextOrderPriceByNum(int n1, double p1){
   switch (n1) {
      case 101: return (p1-Step*Point); //для лонгов цена следующего ордера ниже на шаг с учетом фактора
      case 102: return (p1-Step*MathPow(StepFactor,1)*Point);
      case 103: return (p1-Step*MathPow(StepFactor,2)*Point);
      case 104: return (p1-Step*MathPow(StepFactor,3)*Point);   
      case 201: return (p1+Step*Point); //для шортов цена следующего ордера выше на шаг с учетом фактора  
      case 202: return (p1+Step*MathPow(StepFactor,1)*Point);
      case 203: return (p1+Step*MathPow(StepFactor,2)*Point);
      case 204: return (p1+Step*MathPow(StepFactor,3)*Point);   
   }
   return (0);        
}
//********************************************************************
//функция модификации отложенного ордера
//здесь получаем вычисленные цены открытия и тэйкпрофита для отложенных ордеров
//и если они отличаются от цен модифицируемого ордера, изменяем их
//********************************************************************
int modOrder(int num, double oprice, double prprice){
    int t, cnt1, tic, err;
    double p1, p2;
    t=OrdersTotal();
    for(cnt1=0;cnt1<t;cnt1++){
       OrderSelect(cnt1, SELECT_BY_POS, MODE_TRADES);
       if (OrderSymbol()==Symbol() && OrderMagicNumber()==num){ 
          if ((OrderOpenPrice()!=oprice || OrderTakeProfit()!=prprice) && oprice!=0 && prprice!=0) {     
             if (OrderType()==OP_BUYLIMIT){
                p1=oprice;
                p2=prprice;
               //NormalizeDouble(p2,Digits);
               if (NormalizeDouble(OrderOpenPrice(),Digits)!=NormalizeDouble(p1,Digits) || NormalizeDouble(OrderTakeProfit(),Digits)!=NormalizeDouble(p2,Digits) ) { 
                  //if (OrderOpenPrice()!=p1 || OrderTakeProfit()!=p2) {
                  tic=OrderModify(OrderTicket(),p1,0,p2,0,Red);
                  Print ("модиф BUYLIMIT ", OrderOpenPrice(), "->", p1, " t/p ", OrderTakeProfit(),"->", p2);
                  Print ("Результат = ",tic);
                  if (tic!=1) {err=GetLastError(); Print ("Ошибка = ",err);}                     
                Sleep(TimeOut);
                 }
              }
              if (OrderType()==OP_SELLLIMIT){
                  p1=oprice;
                  p2=prprice;
                 if (NormalizeDouble(OrderOpenPrice(),Digits)!=NormalizeDouble(p1,Digits) 
                     || NormalizeDouble(OrderTakeProfit(),Digits)!=NormalizeDouble(p2,Digits)) { 
                      tic=OrderModify(OrderTicket(),p1,0,p2,0,Green);
                      Print ("модиф SELLLIMIT ", OrderOpenPrice(), "->", p1, " t/p ", OrderTakeProfit(),"->", p2);
                      Print ("Результат = ",tic);
                      if (tic!=1) {err=GetLastError();
                      Print ("Ошибка = ",err);}                       
                      Sleep(TimeOut);
                  }                       
              }              
            }
          }
      }  
      return (1);      
     }    


//********************************************************************
//
// НЕОБХОДИМЫЕ ФУНКЦИИ
//
//********************************************************************
//
// БЛОК ПРОВЕРОК и ОПРЕДЕЛЕНИЙ ПАРАМЕТРОВ
//
//********************************************************************
// эта функция проверяет наличие ордера с данным магическим номером
// MODE - тип действий : 1=просто проверить маг номер 2=проверить маг номер для BUYSTOP,SELLSTOP
// NUM - проверяемый магический номер ордера
//********************************************************************
bool isMagNum(int mode, int num) { 
   int TotalOrd, TekOrd;     
   TotalOrd = OrdersTotal();
   for(TekOrd = 0; TekOrd < TotalOrd; TekOrd++) { OrderSelect(TekOrd, SELECT_BY_POS, MODE_TRADES);
      if (mode == 1) {
         if (OrderMagicNumber()==num && OrderSymbol()==Symbol()) return (True); // возвращаемое значение
      }
      if (mode == 2) {
         if (OrderMagicNumber()==num && OrderSymbol()==Symbol() && (OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP) ) return (True); // возвращаемое значение
      }
   }  
return (False); }
//********************************************************************
//функция, проверяющая активирован ли данный ордер в открытую позицию   
//********************************************************************
bool isOrderActive(int num) {       
   int TotalOrd, TekOrd;     
   TotalOrd = OrdersTotal();
   for(TekOrd = 0; TekOrd < TotalOrd; TekOrd++) { OrderSelect(TekOrd, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol()==Symbol() && OrderMagicNumber()== num && (OrderType()==OP_BUY || OrderType()==OP_SELL)) { return (True); } // возвращаемое значение
   }  
   return (False);   
} 
//********************************************************************
//здесь определяем максимальный магический номер открытого ордера для лонгов
//********************************************************************
int getMaxLongNum(){
   int topL = 0, TotalOrd, TekOrd;
   TotalOrd = OrdersTotal();
   for(TekOrd = 0; TekOrd < TotalOrd; TekOrd++) { OrderSelect(TekOrd, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber()>topL) topL = OrderMagicNumber(); 
   }  
   return (topL); // максимальный магический номер лонгов    
}
//********************************************************************
//здесь определяем максимальный магический номер открытого ордера для шортов
//********************************************************************
int getMaxShortNum(){
   int topL = 0, TotalOrd, TekOrd;
   TotalOrd = OrdersTotal();
   for(TekOrd = 0; TekOrd < TotalOrd; TekOrd++) { OrderSelect(TekOrd, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol()==Symbol() && OrderType()==OP_SELL && OrderMagicNumber()>topL ) topL = OrderMagicNumber();
   }  
   return (topL); // максимальный магический номер шортов
}
//********************************************************************
//определение масимального (текущего) уровня для активных длинных или коротких позиций 
//********************************************************************
int getTopLevel (int mode) {       
   int TotalOrd, TekOrd, MaxLevel, cLev=0;
   TotalOrd = OrdersTotal();
   if (mode == 1) { //проверка уровня для лонгов
      for(TekOrd = 0; TekOrd < TotalOrd; TekOrd++) { OrderSelect(TekOrd, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol()==Symbol() && OrderType()==OP_BUY ) { //только активированные позиции
            switch (OrderMagicNumber()) {
               case 105: cLev=5; break; 
               case 104: cLev=4; break;
               case 103: cLev=3; break;
               case 102: cLev=2; break;
               case 101: cLev=1; break;
            } 
            if (cLev > MaxLevel) MaxLevel = cLev;   
         }  
      }    return (MaxLevel);   
   }  
//********************************************************************
   if (mode == 2) { //проверка уровня для шортов
      for(TekOrd = 0; TekOrd < TotalOrd; TekOrd++) { OrderSelect(TekOrd, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol()==Symbol() && OrderType()==OP_SELL ) { //только активированные позиции
            switch (OrderMagicNumber()) {
               case 205: cLev=5; break; 
               case 204: cLev=4; break;
               case 203: cLev=3; break;
               case 202: cLev=2; break;
               case 201: cLev=1; break;             
            } 
            if (cLev > MaxLevel) MaxLevel = cLev;   
         }  
      }  return (MaxLevel); 
   }
}
//*******************************************************
// получение цены открытия ордера по его магическому номеру === функция для получения цены открытия ордера по его номеру
//*******************************************************
double getOrderPriceByNum (int num) {       
   int t, cnt1;     
   t=OrdersTotal();
   for(cnt1=0;cnt1<t;cnt1++){
      OrderSelect(cnt1, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol()==Symbol() && OrderMagicNumber()== num) { return (OrderOpenPrice()); }
   }  
   return (0);   
}
///************************************************************************
//определение следующего магического номера по данному     
//********************************************************************
int getNextOrderNum(int n1){
   switch (n1) {
      case 101: return (102); 
      case 102: return (103); 
      case 103: return (104); 
      case 104: return (105); 
      case 201: return (202); 
      case 202: return (203); 
      case 203: return (204); 
      case 204: return (205); 
    }
    return (0);       
}
//******************************************************
//определение сколько лотов открывать по заданному номеру уровня
//******************************************************
double getLotByLevel(int Level) {       
   double Lot1;
   Lot1 = StartLots;//значение по умолчанию
   switch( Level ) {
      case 3: Lot1 = StartLots*2; break;
      case 4: Lot1 = StartLots*4; break;
      case 5: Lot1 = StartLots*8; break;
   }
   return (Lot1);
}
//********************************************************************
//
// БЛОК ВЫСТАВЛЕНИЙ ОРДЕРОВ
//
//********************************************************************   
// выставление ПЕРВЫХ ордеров серии BUY & SELL
//********************************************************************
   //                валюта  тип сдлк  лот сдлк        цена слип  SL TP              комментарий                 маг ном
void Create_Prima_Buy() { 
   int Tiket, Error;
   Tiket = OrderSend(Symbol(), OP_BUY, StartLots, Ask,  3,  0, Ask+Step*Point,"101 Первая Позиция Лонгов", 101,0, Red);
   Print("Открытие Первой Позиции Серии Лонгов 101 Для -> ",Symbol(),"  Ask = ", Ask,"  T/P = ",Ask+Step*Point,"  Тiкet = ",Tiket);
   if ( Tiket == -1 ) {Error = GetLastError(); Print ("Ошибка Открытия Первой Позиции Лонгов 101 = ",Error); } 
   Sleep(TimeOut);
}
//********************************************************************
void Create_Prima_Sell() { 
   int Tiket, Error;
   Tiket = OrderSend(Symbol(), OP_SELL, StartLots, Bid,3,0,Bid-Step*Point,"201 первая позиция шортов", 201, 0, Green);
   Print("Открытие Первой Позиции Серии Шортов 201 Для -> ",Symbol(),"  Bid = ", Bid, " Т/Р = ", Bid-Step*Point, "  Тiket = ",Tiket);
   if (Tiket == -1) {Error = GetLastError(); Print ("Ошибка Открытия Первой Позиции Серии Шортов 201 = ", Error); } 
   Sleep(TimeOut);
}   
//********************************************************************
// выставление ПЕРВЫХ ордеров серии BUY_STOP & SELL_STOP
//********************************************************************
void Create_Modify_Prima_BuyStop() { 
   int TotalOrd, TekOrd;     
   int Tiket, Error;
   int MaxMagNumBuy;       // здесь определяем максимальный магический номер открытого ордера для лонгов
   double OrderPriceBuy ;  // цена открытия ордера по его магическому номеру
   double PriceBuyStop; // цена открытия отложенного ордера STOP
// вычисление цены открытия нового отложенного ордера №1 потом может быть модифицирован функцией модификации               
   MaxMagNumBuy  = getMaxLongNum();                    // здесь определяем максимальный магический номер открытого ордера для лонгов
   OrderPriceBuy = getOrderPriceByNum( MaxMagNumBuy ); // получение цены открытия ордера по его магическому номеру
   PriceBuyStop  = OrderPriceBuy + Step*Point + (Point * MarketInfo(Symbol(),MODE_SPREAD) ); // цена открытия отложенного ордера STOP
// проверяем есть ли отложенный ордер 
   if (isMagNum(2,101) == False) { //--- если нет то создаем ордер
      Tiket = OrderSend(Symbol(), OP_BUYSTOP, StartLots, PriceBuyStop,  3,  0, PriceBuyStop + Step*Point,"BUY_STOP_№101", 101,0, Red);
      Print("Открытие BUY_STOP_№101 Для -> ",Symbol(),"  Ask = ", PriceBuyStop,"  T/P = ",PriceBuyStop+Step*Point,"  Тiкet = ",Tiket);
      if ( Tiket == -1 ) {Error = GetLastError(); Print ("Ошибка Открытия BUY_STOP_№101 = ",Error); } 
      Sleep(TimeOut); }
   else { //--- иначе проверяем его и если надо модифицируем его
      TotalOrd = OrdersTotal();
      for(TekOrd = 0; TekOrd < TotalOrd; TekOrd++) { OrderSelect(TekOrd, SELECT_BY_POS, MODE_TRADES);
         if (OrderMagicNumber()==101 && OrderSymbol()==Symbol() && OrderType()==OP_BUYSTOP ) { // нашли отложенный ордер BUY_STOP
            if (NormalizeDouble(OrderOpenPrice(),Digits)!=NormalizeDouble(PriceBuyStop,Digits) || NormalizeDouble(OrderTakeProfit(),Digits)!=NormalizeDouble((PriceBuyStop + Step*Point),Digits) ) { 
               Tiket = OrderModify(OrderTicket(),PriceBuyStop,0,(PriceBuyStop + Step*Point),0,Red);
               Print ("Модификация BUY_STOP_№101 ", OrderOpenPrice(), "->", PriceBuyStop, " t/p = ", OrderTakeProfit(),"  -> ", (PriceBuyStop + Step*Point));
               if ( Tiket == 0 ) {Error = GetLastError(); Print ("Ошибка Модификации BUY_STOP_№101 = ",Error); } 
               Sleep(TimeOut); break;
            }
         }
      }  
   }
}
//********************************************************************
//********************************************************************
void Create_Modify_Prima_SellStop() { 
   int TotalOrd, TekOrd;     
   int Tiket, Error;
   int MaxMagNumSell;       // здесь определяем максимальный магический номер открытого ордера для лонгов
   double OrderPriceSell ;  // цена открытия ордера по его магическому номеру
   double PriceSellStop; // цена открытия отложенного ордера STOP
// вычисление цены открытия нового отложенного ордера для шортов №1 потом может быть модифицирован функцией модификации
   MaxMagNumSell  = getMaxShortNum();                     // здесь определяем максимальный магический номер открытого ордера для шортов
   OrderPriceSell = getOrderPriceByNum( MaxMagNumSell ); // получение цены открытия ордера по его магическому номеру
   PriceSellStop  = OrderPriceSell - Step*Point - (Point * MarketInfo(Symbol(),MODE_SPREAD) ); // цена открытия отложенного ордера STOP
// проверяем есть ли отложенный ордер 
   if (isMagNum(2,201) == False) { //--- если нет то создаем ордер
      Tiket = OrderSend(Symbol(), OP_SELLSTOP, StartLots, PriceSellStop, 3, 0, PriceSellStop - Step*Point,"SELL_STOP_№201", 201, 0, Green);
      Print("Открытие SELL_STOP_№201 Для -> ",Symbol(),"  Bid = ", Bid, " Т/Р = ", Bid-Step*Point, "  Тiket = ",Tiket);
      if (Tiket == -1) {Error = GetLastError(); Print ("Ошибка Открытия SELL_STOP_№201 = ", Error); } 
      Sleep(TimeOut); }
   else {
      TotalOrd = OrdersTotal();
      for(TekOrd = 0; TekOrd < TotalOrd; TekOrd++) { OrderSelect(TekOrd, SELECT_BY_POS, MODE_TRADES);
         if (OrderMagicNumber()==201 && OrderSymbol()==Symbol() && OrderType()==OP_SELLSTOP ) { // нашли отложенный ордер BUY_STOP
            if (NormalizeDouble(OrderOpenPrice(),Digits)!=NormalizeDouble(PriceSellStop,Digits) || NormalizeDouble(OrderTakeProfit(),Digits)!=NormalizeDouble(PriceSellStop - Step*Point,Digits)) { 
               Tiket = OrderModify(OrderTicket(),PriceSellStop,0,(PriceSellStop - Step*Point),0,Green);
               Print ("Модификация SELL_STOP_№201 ", OrderOpenPrice(), "->", PriceSellStop, " t/p = ", OrderTakeProfit(),"  -> ", PriceSellStop - Step*Point);
               if ( Tiket == 0 ) {Error = GetLastError(); Print ("Ошибка Модификации SELL_STOP_№201 = ",Error); } 
               Sleep(TimeOut); break;
            }                       
         }
      }
   }
}   
//********************************************************************
//
// БЛОК УДАЛЕНИЯ ОРДЕРОВ
//
//********************************************************************   
//функция удаления ордера по магическому номеру 
//********************************************************************   
bool deleteOrderNum(int num) { // NUM - магический номер ордера для удаления
   int TotalOrd, TekOrd, Tiket, Error;     
   TotalOrd = OrdersTotal();
   for(TekOrd = 0; TekOrd < TotalOrd; TekOrd++) { OrderSelect(TekOrd, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol()==Symbol() && OrderMagicNumber()== num ) {
         Print ("Удаление ордера № = ", num, "   Tiket = ", OrderTicket() );
         Tiket = OrderDelete(OrderTicket()); 
         if (Tiket == 0) {Error = GetLastError(); Print ("Ошибка удаления = ",Error);} 
         Sleep(1000); return (True);
      }   
   }  
   return (False);   
}     
//********************************************************************   
// удалим все ненужные отложенные ордера (большие чем МакОткОрдер + 1) для БАЕК
//********************************************************************   
void Delete_BuyLimit_Old(){
   int NomMaxBuy;
// удаление лишних лонгов, если нет ордера первой ступени
   if (isOrderActive(101) == False) { 
      if (isMagNum(1,102) == True) deleteOrderNum(102); 
      if (isMagNum(1,103) == True) deleteOrderNum(103); 
      if (isMagNum(1,104) == True) deleteOrderNum(104); 
      if (isMagNum(1,105) == True) deleteOrderNum(105); 
      return;
   }
//********************************************************************
// Здесь удалим лишние отложенные ордера для лонгов
// для этого нам достаточно знать номер максимальной открытой позы , 
// пропустить следующий по уровню лимитный ордер и удалить все остальные
//********************************************************************
   NomMaxBuy = getMaxLongNum();                //нужно выяснить, какая активная позиция (открытая) максимальна
   if (NomMaxBuy  == 101 ) { 
      if (isMagNum(1,103) == True) deleteOrderNum(103); 
      if (isMagNum(1,104) == True) deleteOrderNum(104); 
      if (isMagNum(1,105) == True) deleteOrderNum(105); 
      return;
   }
   if (NomMaxBuy  == 102 ) { 
      if (isMagNum(1,104) == True) deleteOrderNum(104); 
      if (isMagNum(1,105) == True) deleteOrderNum(105); 
      return;
   }
   if (NomMaxBuy  == 103 ) { 
      if (isMagNum(1,105) == True) deleteOrderNum(105); 
      return;
   }
}
//********************************************************************   
// удалим все ненужные отложенные ордера (большие чем МакОткОрдер + 1) для СЕЛОК
//********************************************************************   
void Delete_SellLimit_Old(){
   int NomMaxSell;
// удаление лишних шортов, если нет ордера первой ступени
   if (isOrderActive(201) == False) { 
      if (isMagNum(1,202) == True) deleteOrderNum(202); 
      if (isMagNum(1,203) == True) deleteOrderNum(203); 
      if (isMagNum(1,204) == True) deleteOrderNum(204); 
      if (isMagNum(1,205) == True) deleteOrderNum(205); 
      return;
   }
   NomMaxSell = getMaxShortNum(); // нужно выяснить, какая активная позиция (открытая) максимальна
   if (NomMaxSell  == 201 ) { 
      if (isMagNum(1,203) == True) deleteOrderNum(203); 
      if (isMagNum(1,204) == True) deleteOrderNum(204); 
      if (isMagNum(1,205) == True) deleteOrderNum(205); 
      return;
   }
   if (NomMaxSell  == 202 ) { 
      if (isMagNum(1,204) == True) deleteOrderNum(204); 
      if (isMagNum(1,205) == True) deleteOrderNum(205); 
      return;
   }
   if (NomMaxSell  == 203 ) { 
      if (isMagNum(1,205) == True) deleteOrderNum(205); 
      return;
   }
}
//********************************************************************
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//********************************************************************
int start() {
//********************************************************************
//
// НЕОБХОДИМЫЕ ПЕРЕМЕННЫЕ
//
//********************************************************************
   double sig=0, curPrice, topLot, devPrice, newPrice, newPriceSel, newPriceBuy;
   double lastOpenPrice, curProfitPriceBuy, curProfitPriceSell, nullPrice, nullPrice2;
   int cnt, ticket, total, pr,  openPos, topLev, direct, topLevBuy, topLevSell; 
   int n1, n2, err;
   double p1, p2, prof, tpBuy, tpSell;
//********************************************************************
// Различные начальные проверки на минимальные значения суммы на счете
// проверка достаточного количества маржи на счете
//********************************************************************
if(AccountFreeMargin()<(500)) { Print("Мало Денег На Счете. Free Margin = ", AccountFreeMargin()); return(0); }
//********************************************************************
// проверка уровня текущих средств на счете        
//********************************************************************
if(AccountEquity()<(600)) { Print("Эквити Упала Слишком Низко = ", AccountEquity()); return(0); }
//********************************************************************
//
// ПРОВЕРКА ЕСТЬ ЛИ ОРДЕР 1 СТУПЕНИ ДЛЯ БАЕК И СЕЛОК
//
//********************************************************************
if (isMagNum(1,101) == False) Create_Prima_Buy();  // проверка есть ли ордер 1 ступени для баек, если его нет то создаём БАЙКУ1
if (isMagNum(1,201) == False) Create_Prima_Sell(); // проверка есть ли ордер 1 ступени для селок, если его нет то создаём СЕЛКУ1
//********************************************************************
//
// ПРОВЕРКА ЕСТЬ ЛИ BUY_STOP_№1 & SELL_STOP_№1
//
//********************************************************************
Create_Modify_Prima_BuyStop();  // проверка есть ли ордер BuyStop1 ступени для баек, если его нет то создаём БАЙКУ1 илиначе проверяем цены и ТП и если надо изменяем ордер
Create_Modify_Prima_SellStop(); // проверка есть ли ордер SellStop1 ступени для селок, если его нет то создаём СЕЛКУ1 иначе проверяем цены и ТП и если надо изменяем ордер
//********************************************************************
//
// УДАЛИМ ВСЕ НЕНУЖНЫЕ ОРДЕРА ДЛЯ БАЕК И СЕЛОК
//
//********************************************************************
Delete_BuyLimit_Old();  // удалим все ненужные отложенные ордера (большие чем МакОткОрдер + 1) для БАЕК
Delete_SellLimit_Old(); // удалим все ненужные отложенные ордера (большие чем МакОткОрдер + 1) для СЕЛОК
//********************************************************************
//
// ПРОВЕРКА ЕСТЬ ЛИ BUY_LIMIT & SELL_LIMIT
//
//********************************************************************
//********************************************************************
// вычисляем новую цену для следующего отложенного ордера
//********************************************************************
newPriceBuy = 0; newPriceSel = 0;
//********************************************************************
// вычисление цены открытия нового отложенного ордера
// потом может быть модифицирован функцией модификации               
//********************************************************************
topLevBuy  = getTopLevel(1); // макс открытый уровень для лонгов
if (topLevBuy>0) {
   n1 = getMaxLongNum();                       // здесь определяем максимальный магический номер открытого ордера для лонгов
   p1 = getOrderPriceByNum(n1);                // получение цены открытия ордера по его магическому номеру
   newPriceBuy=getNextOrderPriceByNum(n1, p1); // вычисление цены открытия ордера, который еще не активирован (нужен для установки 
   tpBuy = p1;                                 // запомнить значение для установки тэйкпрофита отложенного ордера и = цена открытия предыдущего ордера
}
//********************************************************************
// вычисление цены открытия нового отложенного ордера для шортов
// потом может быть модифицирован функцией модификации
//********************************************************************
topLevSell = getTopLevel(2); // макс открытый уровень для шортов
if (topLevSell>0) {
   n1 = getMaxShortNum();                         // здесь определяем максимальный магический номер открытого ордера для шортов
   p1 = getOrderPriceByNum(n1);                   // получение цены открытия ордера по его магическому номеру
   newPriceSel = getNextOrderPriceByNum(n1, p1);  // вычисление цены открытия ордера, который еще не активирован (нужен для установки 
   tpSell = p1;                                    // запомнить значение для установки тэйкпрофита отложенного ордера и = цена открытия предыдущего ордера
}
//********************************************************************
// тут обязательно проверить, допустима ли такая цена по рынку?
// если цена рынка ниже для байлимит ордера, то нужно взять цену на несколько пипсов ниже (на спрэд) текущей
//********************************************************************
if (newPriceBuy > Bid) newPriceBuy = Bid - Step*Point;  //это для селллимит ордеров
if (newPriceSel < Ask) newPriceSel = Ask + Step*Point;  //это для селллимит ордеров
//********************************************************************
// установка ордеров ступеней начиная со 2
//********************************************************************
if (topLevBuy==1 && isMagNum(1,102)==False) {
   ticket=OrderSend(Symbol(),OP_BUYLIMIT,getLotByLevel(2),newPriceBuy,3,0,tpBuy,"вторая - отложенный лонг 102",102,0,Green);
   Print("Открытие второй отложенной позиции лонгов 102 ",Symbol()," ask= ", Ask," t/p=",Ask+Step*Point," ticket=",ticket);
   if (ticket == -1 ) {err=GetLastError(); Print ("Ошибка открытия отложенки 102 = ",err); } 
   Sleep(TimeOut);
}
if (topLevSell==1 && isMagNum(1,202)==False) {
   ticket=OrderSend(Symbol(),OP_SELLLIMIT,getLotByLevel(2),newPriceSel,3,0,tpSell,"вторая - отложенный шорт 202",202,0,Red);
   Print("Открытие второй отложенной позиции шортов 202 ",Symbol()," Bid= ", Bid," t/p=",Bid-Step*Point," ticket=",ticket);               
   if (ticket == -1) {err=GetLastError(); Print ("Ошибка открытия отложенки 202 = ",err); } 
   Sleep(TimeOut);
}
//********************************************************************
// установка ордеров ступеней начиная с 3
//********************************************************************
if (topLevBuy==2 && isMagNum(1,103)==False && isOrderActive(102)==True) {
   ticket=OrderSend(Symbol(),OP_BUYLIMIT,getLotByLevel(3),newPriceBuy,3,0,tpBuy,"третья - отложенный лонг 103",103,0,Green);
   Print("Открытие третьей отложенной позиции лонгов 103 ",Symbol()," ask= ", Ask," t/p=",Ask+Step*Point," ticket=",ticket);
   if (ticket == -1) {err=GetLastError(); Print ("Ошибка открытия отложенки 103 = ",err); } 
   Sleep(TimeOut);
}
if (topLevSell==2 && isMagNum(1,203)==False && isOrderActive(202)==True) {
   ticket=OrderSend(Symbol(),OP_SELLLIMIT,getLotByLevel(3),newPriceSel,3,0,tpSell,"третья - отложенный шорт 203",203,0,Red);
   Print("Открытие третьей отложенной позиции шортов 203 ",Symbol()," Bid= ", Bid," t/p=",Bid-Step*Point," ticket=",ticket);               
   if (ticket == -1) {err=GetLastError(); Print ("Ошибка открытия отложенки 203 = ",err); } 
   Sleep(TimeOut);
}
//********************************************************************
// установка ордеров ступеней начиная с 4
//********************************************************************
if (topLevBuy==3 && isMagNum(1,104)==False && isOrderActive(103)==True) {
   ticket=OrderSend(Symbol(),OP_BUYLIMIT,getLotByLevel(4),newPriceBuy,3,0,tpBuy,"четвертая - отложенный лонг 104",104,0,Green);
   Print("Открытие четвёртой отложенной пощзиции лонгов 104 ",Symbol()," ask= ", Ask," t/p=",Ask+Step*Point," ticket=",ticket);
   if (ticket == -1) {err=GetLastError(); Print ("Ошибка открытия отложенки 104 = ",err); } 
   Sleep(TimeOut);
}
if (topLevSell==3 && isMagNum(1,204)==False && isOrderActive(203)==True) {
   ticket=OrderSend(Symbol(),OP_SELLLIMIT,getLotByLevel(4),newPriceSel,3,0,tpSell,"четвертая - отложенный шорт 204",204,0,Red);
   Print("Открытие четвёртой отложенной позиции шортов 204 ",Symbol()," Bid= ", Bid," t/p=",Bid-Step*Point," ticket=",ticket);               
   if (ticket == -1) {err=GetLastError(); Print ("Ошибка открытия отложенки 204 = ",err); } 
   Sleep(TimeOut);
}
//********************************************************************
// установка ордеров ступеней начиная с 5
//********************************************************************
if (topLevBuy==4 && isMagNum(1,105)==False && isOrderActive(104)==True) {
   ticket=OrderSend(Symbol(),OP_BUYLIMIT,getLotByLevel(5),newPriceBuy,3,0,tpBuy,"пятая - отложенный лонг 105",105,0,Green);
   Print("Открытие пятой отложенной позиции лонгов 105 ",Symbol()," ask= ", Ask," t/p=",Ask+Step*Point," ticket=",ticket);
   if (ticket == -1) {err=GetLastError(); Print ("Ошибка открытия отложенки 105 = ",err); } 
   Sleep(TimeOut);
}
if (topLevSell==4 && isMagNum(1,205)==False && isOrderActive(204)==True) {
   ticket=OrderSend(Symbol(),OP_SELLLIMIT,getLotByLevel(5),newPriceSel,3,0,tpSell,"пятая - отложенный шорт 205",205,0,Red);
   Print("Открытие пятой отложенный позиции шортов 205 ",Symbol()," Bid= ", Bid," t/p=",Bid-Step*Point," ticket=",ticket);               
   if (ticket == -1) {err=GetLastError(); Print ("Ошибка открытия отложенки 205 = ",err); } 
   Sleep(TimeOut);
}
//********************************************************************
//
// ПРОВЕРКА ПРАВИЛЬНОСТИ ТП АКТИВНЫХ ОРДЕРОВ ДЛЯ BUY & SELL
//
//********************************************************************
// теперь можно определить цену, на которой нужно закрыть
// все сделки на первом же откате и которая является чуть лучшей
// ценой открытия предпоследнего плеча
//********************************************************************
curProfitPriceBuy  = getOrderPriceByNum(101) + Step*Point;
curProfitPriceSell = getOrderPriceByNum(201) - Step*Point;
//********************************************************************
// вычисление новых цен профитов открытых ордеров для лонгов
//********************************************************************
if (isOrderActive(105)==True) curProfitPriceBuy=getOrderPriceByNum(104);
if (isOrderActive(105)==False && isOrderActive(104)==True) curProfitPriceBuy=getOrderPriceByNum(103);
if (isOrderActive(105)==False && isOrderActive(104)==False && isOrderActive(103)==True) curProfitPriceBuy=getOrderPriceByNum(102);
if (isOrderActive(105)==False && isOrderActive(104)==False && isOrderActive(103)==False && isOrderActive(102)==True){ if (isOrderActive(101)==True) curProfitPriceBuy=getOrderPriceByNum(101); }
//********************************************************************
// вычисление цен профитов открытых ордеров для шортов
//********************************************************************
if (isOrderActive(205)==True) curProfitPriceSell=getOrderPriceByNum(204);
if (isOrderActive(205)==False && isOrderActive(204)==True) curProfitPriceSell=getOrderPriceByNum(203);
if (isOrderActive(205)==False && isOrderActive(204)==False && isOrderActive(203)==True) curProfitPriceSell=getOrderPriceByNum(202);
if (isOrderActive(205)==False && isOrderActive(205)==False && isOrderActive(203)==False && isOrderActive(202)==True){ if (isOrderActive(201)==True) curProfitPriceSell=getOrderPriceByNum(201); }
//********************************************************************
// передвигание на цену предпоследней ступени 
//********************************************************************
setNewTakeProfitBuy(curProfitPriceBuy);  // переустановка профитов для лонгов 
setNewTakeProfitSel(curProfitPriceSell); // переустановка профитов для шортов
//********************************************************************
// Это блок проверки правильности цен отложенных ордеров и их коррекция,
//     если это необходимо
// Сначала проверяем ветку для лонгов
//     p1 - это будет цена профита для следующей позиции
//********************************************************************
n1=getMaxLongNum();                //нужно выяснить, какая активная позиция (открытая) максимальна
p1=getOrderPriceByNum(n1);         // теперь получить цену открытия этой позиции
p2=getNextOrderPriceByNum(n1, p1); // теперь надо расчитать цену открытия отложенного ордера, поскольку правила могут быть разными             
n2=getNextOrderNum(n1);            // узнать, какой будет следующий номер ордера
if (isMagNum(1,n2)==True && p2<(Bid-(Ask-Bid)-3*Point)) { modOrder(n2, p2, p1); } //наконец модифицируем ордер => идем на функцию модификации цен отложенных ордеров 
//********************************************************************
// все то же самое делаем для шортов
//********************************************************************
n1=getMaxShortNum();               // нужно выяснить, какая активная позиция (открытая) максимальна
p1=getOrderPriceByNum(n1);         // теперь получить цену открытия этой позиции
p2=getNextOrderPriceByNum(n1, p1); // теперь надо расчитать цену открытия отложенного ордера, поскольку правила могут быть разными
n2=getNextOrderNum(n1);            //узнать, какой будет следующий номер ордера
if (isMagNum(1,n2)==True && p2>(Ask+(Ask-Bid)+3*Point)) { modOrder(n2, p2, p1); } 
//********************************************************************
//
// В С Ё
//
//********************************************************************
return(0);
}     
//********************************************************************
//
// THE  END
//
//********************************************************************

