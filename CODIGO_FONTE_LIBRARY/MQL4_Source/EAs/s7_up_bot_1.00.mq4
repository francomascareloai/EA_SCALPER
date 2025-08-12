//+------------------------------------------------------------------+
//|                                                     UP_bot_1.mq4 |
//|                                         Copyright © 2014, sova75 |
//+------------------------------------------------------------------+
#property copyright   "sova75"
#property link        "html://www.mql4.com"
#property version     "1.00"
#property description "торговля от уровней - вход на втором баре"
//--- объявление констант
#define BUY 0                    // создадим предопределенню переменную со значением 0
#define SEL 1                    // создадим предопределенню переменную со значением 1
//--- input parameters
extern string  separator1        ="------ start trade settings ------";
extern int     TakeProfit        =30;        // уровень TakeProfit
extern int     StopLoss          =0;         // уровень StopLoss (if 0 then auto)
extern double  HLdivergence      =0.1;       // миним. отклонение двух соседних баров для входа 
extern double  SpanPrice         =6;         // отступ от стартового уровня для открытия ордера
extern double  Lots              =0.01;      // размер ставки
extern int     MaxTrades         =1;         // макс. кол-во одновременно открытых ордеров
extern int     Slippage          =5;         // проскальзывание
extern int     MagicNumber       =140804;    // номер советника
extern string  separator2        ="------ output settings ------";
extern bool    TrailingStop      =false;     // трал стопов открытых ордеров
extern int     TrailStopLoss     =20;        // уровень трала StopLoss
extern bool    ZeroTrailingStop  =false;     // трал стопов до уровня БУ
extern double  StepTrailing      =0.5;       // шаг трала стопов
extern bool    OutputAtLower     =false;     // выход при снижении ниже предыдущего бара
extern bool    OutputAtRevers    =false;     // выход при перевороте тренда
extern double  SpanToRevers      =3;         // отступ от реверсивного уровня для закрытия ордера
//--- глобальные переменные
int expertBars;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
void OnInit() {
//--- проверяем разрядность
   if(Digits==3 || Digits==5) {
      TakeProfit    *=10;
      StopLoss      *=10;
      Slippage      *=10;
      SpanPrice     *=10;
      HLdivergence  *=10;
      TrailStopLoss *=10;
      StepTrailing  *=10;}
//--- переводим значение переменной HLdivergence в ценовую форму
//   if(Digits==2 || Digits==3) {HLdivergence/=1000; SpanPrice/=1000;}
//   else {HLdivergence/=100000; SpanPrice/=100000;}
//--- проверяем разрешенные уровни TakeProfit, StopLoss
   if (TakeProfit<MarketInfo(_Symbol,MODE_STOPLEVEL) && TakeProfit!=0) {
      Comment("TakeProfit value too small, must be >= "+DoubleToStr(MarketInfo(_Symbol,MODE_STOPLEVEL),0));}
   if (StopLoss<MarketInfo(_Symbol,MODE_STOPLEVEL) && StopLoss!=0) {
      Comment("StopLoss value too small, must be >= "+DoubleToStr(MarketInfo(_Symbol,MODE_STOPLEVEL),0));}
//---
   return;}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   return;}
//+------------------------------------------------------------------+
//| expert ontick function                                           |
//+------------------------------------------------------------------+
void OnTick() {
//--- если ордеров нет, проверяем условия для входа
   if(CountOrders()<MaxTrades)
      if(NextTrade())
         if(StartTrade(BUY)) OpenOrders(BUY);
   if(CountOrders()<MaxTrades)
      if(NextTrade())
         if(StartTrade(SEL)) OpenOrders(SEL);
//--- если ордера есть - проверяем условия выхода
   if(CountOrders()!=0) {
//--- тралим стопы рыночных ордеров
      if(TrailingStop) Trailing();
//--- тралим стопы рыночных ордеров до уровня БУ
      if(ZeroTrailingStop) ZeroTrailing();
//--- выходим при снижении ниже предыдущего бара
      if(OutputAtLower) OutputAL();
//--- выходим при снижении iHigh бара
      if(OutputAtRevers) OutputAR();}
   return;}
//+------------------------------------------------------------------+
//| определяем количество открытых ордеров по магику                 |
//+------------------------------------------------------------------+
int CountOrders() {int count=0;
   for(int i=OrdersTotal()-1; i>=0; i--) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()==MagicNumber) {
            if(OrderType()==OP_BUY || OrderType()==OP_SELL) count++;}}
   return(count);}
//+------------------------------------------------------------------+
//| проверяем бар последнего открытого ордера                        |
//+------------------------------------------------------------------+
bool NextTrade() {int count=0;
   if(OrdersTotal()==0) return true;
   for(int i=OrdersTotal()-1; i >= 0; i--) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
         if(OrderMagicNumber()==MagicNumber) {
            if(OrderType()==OP_BUY || OrderType()==OP_SELL) {
               if(OrderOpenTime()<Time[0])
                  return true;}}}}
   return false;}
//+------------------------------------------------------------------+
//| проверяем условия для входа                                      |
//+------------------------------------------------------------------+
bool StartTrade(int typ) {
//--- проверяем возможность покупки
   if(typ==BUY) {
      if(MathAbs(Low[0]-Low[1])<Point*HLdivergence)
         if(Bid-Low[0]>Point*SpanPrice && Bid-Low[0]<Point*SpanPrice*1.5) return true;}
//--- проверяем возможность продажи
   if(typ==SEL) {
      if(MathAbs(High[0]-High[1])<Point*HLdivergence)
         if(High[0]-Bid>Point*SpanPrice && High[0]-Bid<Point*SpanPrice*1.5) return true;}
   return false;}
//+------------------------------------------------------------------+
//| открываем ордера по текущей цене                                 |
//+------------------------------------------------------------------+
bool OpenOrders(int typ) {
   double price=0,SL=0,TP=0,spread=0;           // обнулим переменные для цены 
   int p=0,ticket=-1;                           // и счетчик попыток открытия ордеров
   if(typ==BUY) {                               // если мы хотим открыть ордер на покупку
      price=NormalizeDouble(Ask,Digits);        // запросим цену для его открытия и сразу же ее нормализуем под 4 или 5 знаков автоматически
      if (StopLoss>0) SL=NormalizeDouble(Bid-Point*StopLoss,Digits); 
      else SL=NormalizeDouble(Low[0]-Point*HLdivergence,Digits);
      TP=NormalizeDouble(Ask+Point*TakeProfit,Digits);}
   if(typ==SEL) {                               // если мы хотим открыть ордер на покупку
      price=NormalizeDouble(Bid,Digits);        // запросим цену для его открытия и сразу же ее нормализуем под 4 или 5 знаков автоматически
      spread=MarketInfo(_Symbol,MODE_SPREAD);
      if (StopLoss>0) SL=NormalizeDouble(Ask+Point*StopLoss,Digits);
      else SL=NormalizeDouble(High[0]+Point*HLdivergence+Point*spread,Digits);
      TP=NormalizeDouble(Bid-Point*TakeProfit,Digits);}
   if(IsTradeAllowed())                         // проверим, свободен ли поток котировок и можем ли мы открыть ордер     
      while(p<5) {                              // запустим цикл попыток открытия ордера на 5 попыток
         ticket=OrderSend(Symbol(),typ,Lots,price,Slippage,SL,TP,WindowExpertName()+"  "+(string)MagicNumber,MagicNumber,0,clrBlack); 
         if(ticket>=0)                          // если наш ордер одобрили, запомним его тикет в переменную ticket
            return true;                        // выйдем из функции с успехом
         else {                                 // если сервер не принял наш ордер
            p++;                                // увеличим счетчик на 1
            Print("OrderSend завершилась с ошибкой #",GetLastError()); // выведем в журнал имя функции и номер ошибки 
            Sleep(500); RefreshRates();}}       // подождем полсекунды и обновим данные
   return false;}                               // в случае если за 5 попыток ордер не открылся, выйдем из функции с неудачей
//+------------------------------------------------------------------+
//| тралим стопы рыночных ордеров                                    |
//+------------------------------------------------------------------+
void Trailing() {
   for(int i=0; i<OrdersTotal(); i++) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
         if(OrderType()<=OP_SELL && OrderMagicNumber()==MagicNumber) {
            if(OrderType()==OP_BUY) {
               if(OrderStopLoss()<Bid-Point*TrailStopLoss) {
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailStopLoss,OrderTakeProfit(),0,clrBlue))
                     Print("Ошибка модификации Trailing. Код ошибки=",GetLastError());}}
            else {
               if(OrderStopLoss()>Ask+Point*TrailStopLoss) {
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailStopLoss,OrderTakeProfit(),0,clrRed))
                     Print("Ошибка модификации Trailing. Код ошибки=",GetLastError());}}}
      else Print("OrderSelect() вернул ошибку - ",GetLastError());}}
   return;}
//+------------------------------------------------------------------+
//| переводим в ордера БУ по достижении                              |
//+------------------------------------------------------------------+
void ZeroTrailing() {double SL;
   for(int i=0; i<OrdersTotal(); i++) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
         if(OrderType()<=OP_SELL && OrderMagicNumber()==MagicNumber) {
            if(OrderType()==OP_BUY) {
               if(OrderStopLoss()<OrderOpenPrice()) {
                  if (StopLoss>0) SL=NormalizeDouble(Bid-Point*StopLoss,Digits);
                  else SL=NormalizeDouble(Bid-Point*(SpanPrice+HLdivergence),Digits);
                  if(OrderStopLoss()<SL && SL-OrderStopLoss()>Point*StepTrailing) {
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),SL,OrderTakeProfit(),0,clrBlue))
                        Print("Ошибка модификации ZeroTrailing. Код ошибки=",GetLastError());}}}
            else {
               if(OrderStopLoss()>OrderOpenPrice()) {
                  if (StopLoss>0) SL=NormalizeDouble(Ask+Point*StopLoss,Digits);
                  else SL=NormalizeDouble(Ask+Point*(SpanPrice+HLdivergence),Digits);
                  if(OrderStopLoss()>SL && OrderStopLoss()-SL>Point*StepTrailing) {
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),SL,OrderTakeProfit(),0,clrRed))
                        Print("Ошибка модификации ZeroTrailing. Код ошибки=",GetLastError());}}}}
      else Print("OrderSelect() вернул ошибку - ",GetLastError());}}
   return;}
//+------------------------------------------------------------------+
//| выходим при снижении ниже предыдущего бара                       |
//+------------------------------------------------------------------+
void OutputAL() {
   for(int i=0; i<OrdersTotal(); i++) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
         if(OrderType()<=OP_SELL && OrderMagicNumber()==MagicNumber) {
            if(OrderType()==OP_BUY) {
               if(Bid<iLow(NULL,0,1)) {
                  if(!OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,clrBlue))
                     Print("Ошибка модификации OutputAtLower. Код ошибки=",GetLastError());}}
            else {
               if(Bid>iHigh(NULL,0,1)) {
                  if(!OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,clrRed))
                     Print("Ошибка модификации OutputAtLower. Код ошибки=",GetLastError());}}}
      else Print("OrderSelect() вернул ошибку - ",GetLastError());}}
   return;}
//+------------------------------------------------------------------+
//| выходим при перевороте тренда                                    |
//+------------------------------------------------------------------+
void OutputAR() {
   for(int i=0; i<OrdersTotal(); i++) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
         if(OrderType()<=OP_SELL && OrderMagicNumber() == MagicNumber) {
            if(OrderType()==OP_BUY) {
               if(MathAbs(High[0]-High[1])<Point*HLdivergence) {
                  if(High[0]-Bid>Point*SpanToRevers && High[0]-Bid<Point*SpanToRevers*1.5) {
                     if(!OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,clrBlue))
                        Print("Ошибка модификации OutputAtRevers. Код ошибки=",GetLastError());}}}
            else {
               if(MathAbs(Low[0]-Low[1])<Point*HLdivergence) {
                  if(Bid-Low[0]>Point*SpanToRevers && Bid-Low[0]<Point*SpanToRevers*1.5) {
                     if(!OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,clrRed))
                        Print("Ошибка модификации OutputAtRevers. Код ошибки=",GetLastError());}}}}
      else Print("OrderSelect() вернул ошибку - ",GetLastError());}}
   return;}
//+------------------------------------------------------------------+