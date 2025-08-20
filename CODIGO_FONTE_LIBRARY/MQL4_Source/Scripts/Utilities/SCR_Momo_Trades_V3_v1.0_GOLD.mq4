//+------------------------------------------------------------------+
//|                                                  Momo_Trades.mq4 |
//|                      Copyright © 2008, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "#xrustsolution#"
#property link      "#xrust.ucoz.net#"
//-------------------------------------------------------------------+
// добавлена функция безубытка                                       +
// добавлен расчет ТП отширины канала
//---- input parameters----------------------------------------------+
extern double    Lots=0.1;
extern double    Risk=0.1;
extern int       Sl=100;
extern int       Tp=0;
extern int       bu=0;//кол-во пунктов трала: Если "0",то в безубыток
extern int       magic=78977;
extern int       PriseShift=10;
extern bool      AutoLot=false;
extern bool      CloseEndDay=true;
extern bool      BU=false;
//---- Ma parameters-------------------------------------------------+
extern int       MaPeriod=22;
extern int       MaShift=1;
//---- MaCd parameters-----------------------------------------------+ 
extern int       Fast=12;      
extern int       Slow=26;
extern int       Signal=9;
extern int       MacdShift=1;
//------Variables----------------------------------------------------+
static int prevtime = 0 ;
double MacdMain[11];
//int
bool UseSound=false;
//------------------
bool first=true;
double MinLot, MaxLot, MarginMinLot;//,Risk=0.1; 
int    MinLotDgts;
//+------------------------------------------------------------------+
void FirstCalc()
{
// 
// Предстартовый расчет. Выполняется один раз - при запуске
// (и каждый раз после сбоя связи).
//
      first=false;
//+--- Минимальный и максимальный размеры лотов
   MinLot=MarketInfo(Symbol(),MODE_MINLOT);
   if(MinLot<0.1) MinLotDgts=2; // размерность минлота   
   else
   {
      if(MinLot<1.0) MinLotDgts=1;
      else MinLotDgts=0;
   }
   MaxLot=MarketInfo(Symbol(),MODE_MAXLOT);   
//----
   return;
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
   //if(!IsTesting())return(0);



   
   ArrayInitialize(MacdMain,0.0); 
// Ждем, когда сформируется новый бар
   if (Time[0] == prevtime) return(0);
      prevtime = Time[0]; 
      MACD();  
      if(first==true) FirstCalc();
//----------------------BU--------------------------------------------+   
   if(OrdersTotal()>0&&BU){
    for(int n=0;n<OrdersTotal();n++){
     if(OrderSelect(n,SELECT_BY_POS,MODE_TRADES)){Bu(OrderTicket());}}}
//-------------------------------------------------------------------+
   if(OrdersTotal()<1){
   if(MacdBuy()&&EmaBuy()){open(false,Sl,Tp,Lots);}
   
   if(MacdSell()&&EmaSell()){open(true,Sl,Tp,Lots);}
   }
//-------------------------------------------------------------------+
   if(DayOfWeek()!=5){int end=23;}else{end=21;}
   if(CloseEndDay&&OrdersTotal()>0&&Hour()==end){
    for(int m=0;m<OrdersTotal();n++){
     if(OrderSelect(m,SELECT_BY_POS,MODE_TRADES)){del(OrderTicket());}}} 


   if(OrdersTotal()>0){Comment(TimeOpenLastPos());}
//----
   return(0);
  }
//+------------------------------------------------------------------+
double CalcLotsAuto()
{
   // нужен залог на минлот
   double MarginMinLot=MarketInfo(Symbol(),MODE_MARGINREQUIRED)*MinLot;
   // имеем свободных средств
   double FreeMargin=AccountFreeMargin();
   // если их не имеем :(
   if(MarginMinLot>FreeMargin) return(-1.0);
   // а если имеем, то сколько лотов можем себе позволить на позу
   int n=1;
   int m=NormalizeDouble(MaxLot/MinLot,0);
   double level=MarginMinLot*2;
   while(level<=FreeMargin && n<=m)
   {
      n++;
      level=level+MarginMinLot*n*Risk; // Менее агрессивно, для минифорекса
      //level=level+MarginMinLot*MathSqrt(n*Risk); // Более агрессивно
   }
   n--;
   double lots=NormalizeDouble((MinLot*n),MinLotDgts);
   return(lots);
}  
//+------------------------------------------------------------------+
void MACD(){
for(int i=0;i<10;i++){
MacdMain[i]=iMACD(Symbol(),0,Fast,Slow,Signal,0,MODE_MAIN,MacdShift+i);}}
//+------------------------------------------------------------------+
bool MacdBuy(){
bool _MacdBuy=false;
   if(
     (MacdMain[3]>MacdMain[4]&&
      MacdMain[4]>MacdMain[5]&&
      MacdMain[5]==0&&
      MacdMain[5]>MacdMain[6]&&
      MacdMain[6]>MacdMain[7])||
     (MacdMain[3]>MacdMain[4]&&
      MacdMain[4]>MacdMain[5]&&
      MacdMain[5]>=0&&
      MacdMain[6]<=0&& 
      MacdMain[6]>MacdMain[7]&&
      MacdMain[7]>MacdMain[8])){_MacdBuy=true;}
return(_MacdBuy);}      
//+------------------------------------------------------------------+
bool MacdSell(){
bool _MacdSell=false;
   if(
     (MacdMain[3]<MacdMain[4]&&
      MacdMain[4]<MacdMain[5]&&
      MacdMain[5]==0&&
      MacdMain[5]<MacdMain[6]&&
      MacdMain[6]<MacdMain[7])||
     (MacdMain[3]<MacdMain[4]&&
      MacdMain[4]<MacdMain[5]&&
      MacdMain[5]<=0&&
      MacdMain[6]>=0&& 
      MacdMain[6]<MacdMain[7]&&
      MacdMain[7]<MacdMain[8])){_MacdSell=true;}
return(_MacdSell);}  
//+------------------------------------------------------------------+  
bool EmaBuy(){bool _Emabuy=false;
 if(Close[MaShift]
    -iMA(Symbol(),0,MaPeriod,0,1,0,MaShift)>PriseShift*Point)
      {_Emabuy=true;}
return(_Emabuy);}
//+------------------------------------------------------------------+  
bool EmaSell(){bool _EmaSell=false;
 if(iMA(Symbol(),0,MaPeriod,0,1,0,MaShift)
         -Close[MaShift]>PriseShift*Point){_EmaSell=true;}
return(_EmaSell);}  
//--------Функция открытия ордеров-------------------------------------+
int open(bool tip,int Sl,int Tp,double lots)
{//tip = false => OP_BUYSTOP ; tip = true => OP_SELLSTOP;
   GetLastError();
   int err;
   if(AutoLot){lots=CalcLotsAuto();}
   double lastprise,prise,sl,tp; // самая свежая цена
   int ticket;
   int slip =(MarketInfo(Symbol(),MODE_SPREAD))*Point;//макс отклонение = спреду
   
//------   
   while (!IsTradeAllowed()){ Sleep(5000);}// если рынок занят то подождем 5 сек
   if (tip == false)
    {
     prise = NormalizeDouble(MarketInfo(Symbol(),MODE_ASK),Digits);
     if(Sl!=0){sl = NormalizeDouble((MarketInfo(Symbol(),MODE_BID)-(Sl*Point)),Digits);}else{sl=0;}
     if(Tp!=0){tp = NormalizeDouble((MarketInfo(Symbol(),MODE_ASK)+(Tp*Point)),Digits);}else{tp=0;}
     for(int i=0;i<5;i++) 
      {
       RefreshRates();// обновим цену
        ticket = OrderSend(Symbol(), OP_BUY,lots ,prise, slip,sl,tp,NULL,magic,0, Blue);
         if (ticket < 0)
          {
           if(UseSound){PlaySound("timeout.wav");}
            Print("Цена слишком близко!",prise,"  ",sl,"  ",tp,"  Не могу поставить ордер BUY!");
             }
              else
               {
                break;
                 }
                  }
                   }
  if(tip==true)
   {
    prise = NormalizeDouble(MarketInfo(Symbol(),MODE_BID),Digits);
    if(Sl!=0){sl = NormalizeDouble((MarketInfo(Symbol(),MODE_ASK)+(Sl*Point)),Digits);}else{sl=0;}
    if(Tp!=0){tp = NormalizeDouble((MarketInfo(Symbol(),MODE_BID)-(Tp*Point)),Digits);}else{tp=0;}    
    for( i=0;i<5;i++) 
     {
      RefreshRates();// обновим цену
       ticket = OrderSend(Symbol(), OP_SELL, lots ,prise, slip,sl,tp,NULL,magic,0, Red);
        if (ticket < 0)
         {
          if(UseSound){PlaySound("timeout.wav");}
           Print("Цена слишком близко!",prise,"  ",sl,"  ",tp,"  Не могу поставить ордер SELL!");
            }
             else
              {
               break;
                }
                 }
                  }

return(ticket); 
 } 
//-------------------------------------------------------------------+
int del(int ticket)
   {
    int err;
        GetLastError();//обнуляем ошику
        OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
        string symbol = OrderSymbol();
        
        if(OrderType()==OP_BUY)
         {
          RefreshRates();
           double prise = MarketInfo(symbol,MODE_BID);
            OrderClose(ticket,OrderLots(),prise,3,Green);
             err = GetLastError();
             }
        if(OrderType()==OP_SELL)
         {
          RefreshRates();
           prise = MarketInfo(symbol,MODE_ASK);
            OrderClose(ticket,OrderLots(),prise,3,Green);
             err = GetLastError();
             }
        if (err == 0&&UseSound){PlaySound("expert.wav");} if (err != 0) {PlaySound("timeout.wav");Print(err);} 
        while (!IsTradeAllowed()){ Sleep(5000);}// если рынок занят то подождем 5 сек 
    return(err);     
    }            
//-------------------------------------------------------------------+
// функция переводит СЛ в бу или на нужный уровень                   +
//+------------------------------------------------------------------+
 int Bu(int ti=0)
 {
  int err;double sl;
  if(ti==0){return(-1);}
  if(OrderSelect(ti,SELECT_BY_TICKET,MODE_TRADES)&&(OrderCloseTime()==0)){
    if(bu==0){sl=OrderOpenPrice();}else{
      if(OrderType()==OP_BUY) {sl=NormalizeDouble((OrderOpenPrice()+bu*Point),Digits);}
       if(OrderType()==OP_SELL){sl=NormalizeDouble((OrderOpenPrice()-bu*Point),Digits);}} 
    if(OrderType()==OP_BUY){
     if(sl<MarketInfo(OrderSymbol(),MODE_BID)-(MarketInfo(OrderSymbol(),MODE_STOPLEVEL)*Point)&&sl!=OrderStopLoss()){ 
      err = OrderModify(ti,OrderOpenPrice(),sl,OrderTakeProfit(),0,White);}} 
    if(OrderType()==OP_SELL){
     if(sl>MarketInfo(OrderSymbol(),MODE_ASK)+(MarketInfo(OrderSymbol(),MODE_STOPLEVEL)*Point)&&sl!=OrderStopLoss()){ 
      err = OrderModify(ti,OrderOpenPrice(),sl,OrderTakeProfit(),0,White);}}}      
 return(err);
 }
//+----------------------------------------------------------------------------+
//|  Автор    : Ким Игорь В. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  Версия   : 19.02.2008                                                     |
//|  Описание : Возвращает время открытия последней открытой позиций.          |
//+----------------------------------------------------------------------------+
//|  Параметры:                                                                |
//|    sy - наименование инструмента   (""   - любой символ,                   |
//|                                     NULL - текущий символ)                 |
//|    op - операция                   (-1   - любая позиция)                  |
//|    mn - MagicNumber                (-1   - любой магик)                    |
//+----------------------------------------------------------------------------+
datetime TimeOpenLastPos(string sy="", int op=-1, int mn=-1) {
  datetime t;
  int      i, k=OrdersTotal();

  if (sy=="0") sy=Symbol();
  for (i=0; i<k; i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if (OrderSymbol()==sy || sy=="") {
        if (OrderType()==OP_BUY || OrderType()==OP_SELL) {
          if (op<0 || OrderType()==op) {
            if (mn<0 || OrderMagicNumber()==mn) {
              if (t<OrderOpenTime()) t=OrderOpenTime();
            }
          }
        }
      }
    }
  }
//--------------------вычисляем разность времени-------------------------------
  int TimeShift = (TimeCurrent()-t)/60;
  
  
  
  return(TimeShift);
}     
  





        