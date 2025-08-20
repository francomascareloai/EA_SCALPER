//+------------------------------------------------------------------+
//|                                             ZigAndZag_trader.mq4 |
//|                      Copyright © 2008, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

//---- input parameters
extern double    Lots=0.1;//торгуемый лот
extern int       ZZbar=3;//баров назад с которого берем сигнал к торговле
extern int       Closebar=3;//баров назад с которого берем сигнал к закрытию 
extern int       Maxord=1;//количество торгуемых ордеров(пока оставить 1)воможно будет мультиордерная система
extern int       Sl=0;//стоплос подбирается при оптимизации
extern int       Tp=0;//тейк подбирается при оптимизации
extern int       magic=78977;//магик
//-----------------------
static int prevtime = 0 ;
bool buy,sell,close,UseSound=false;
//+------------------------------------------------------------------+

int start()
  {
// Ждем, когда сформируется новый бар
   if (Time[0] == prevtime) return(0);
      prevtime = Time[0];  
buy=false;sell=false;     
//-----------
 if(iCustom(NULL,0,"ZigAndZag",4,Closebar)!=0){close=true;}
 if(iCustom(NULL,0,"ZigAndZag",5,ZZbar)!=0){buy=true;}
 if(iCustom(NULL,0,"ZigAndZag",6,ZZbar)!=0){sell=true;}
 //Comment(close+"\n"+buy+"\n"+sell+"\n"+OrdersTotal());
//------------
 if(buy&&OrdersTotal()<Maxord){open(false,Sl,Tp,Lots);buy=false; } 
 if(sell&&OrdersTotal()<Maxord){open(true,Sl,Tp,Lots);sell=false; }
//------------------------------- 
 if(close&&OrdersTotal()>0){
  for(int i=0;i<OrdersTotal();i++){
   if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
    del(OrderTicket()); 
     close=false; 
     }}} 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//--------Функция открытия ордеров-------------------------------------+
int open(bool tip,int Sl,int Tp,double lots)
{//tip = false => OP_BUYSTOP ; tip = true => OP_SELLSTOP;
   GetLastError();
   int err;
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