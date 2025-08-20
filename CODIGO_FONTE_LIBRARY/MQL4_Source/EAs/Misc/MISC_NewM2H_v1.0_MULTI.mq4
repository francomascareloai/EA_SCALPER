//+------------------------------------------------------------------+
//|                                                       NewM2H.mq4 |
//+------------------------------------------------------------------+

#property copyright "Maloma"
#include <stdlib.mqh>

extern double Lot      = 0.1; // Начальный размер лота.
extern int    Grid     = 30; // Начальный размер сетки.
extern int    LockStep = 5;
       int    Step, State;
       double Spread;
       int    magic    = 9034309;
       int    i,j;
       double CurrentPrice, TargetUp, TargetDown;
       double LotSeq[8]={1,1,2,4,8,16,32,64,128}; 
       int    LastLock=0;

int Init()

{
  Step=0;
  Spread=MarketInfo(Symbol(),MODE_SPREAD);
  RefreshRates();
  CurrentPrice=Bid;
  OpenOrder(OP_BUY,Ask,Lot,Ask-400*Point,Bid+Grid*Point);
  OpenOrder(OP_SELL,Bid,Lot,Bid+400*Point,Ask-Grid*Point);
  CalcTarget();
  return(0);
}

int OpenOrder(int Cmd, double Price, double Lots, double SL, double TP)

{
  int err;
  int ticket=-1;
  while (ticket < 0) 
    {
     RefreshRates();
     ticket=OrderSend(Symbol(), Cmd, Lots, Price, 3, SL, TP, "", magic, 0, CLR_NONE);
     err=GetLastError();
     if ((err == 130) || (err == 4107)) {return(0);}
     if (ticket == -1) 
        {
         Comment("Error=", err, "   ", ErrorDescription(err));
         Sleep(6000);
        }
     else {Comment("                                             ");}
    }
  Sleep(1000);
  return(ticket);
}

int CalcTarget()

{  
  TargetUp=CurrentPrice+Grid*Point+Spread;
  TargetDown=CurrentPrice-Grid*Point;
  return(0);
}

int DoDown()

{
  j=OrdersTotal();
  for (i=0;i<j;i++)
    {
     RefreshRates();
     OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
     if ((OrderType()==OP_SELL)&&(OrderTicket()>LastLock)) {OrderClose(OrderTicket(),OrderLots(),Ask,3,CLR_NONE);}
    }
  if (State==1)
    {
     Step=1;
     RefreshRates();
     CurrentPrice=Bid;
     CalcTarget();
     OpenOrder(OP_BUY,Ask,LotSeq[1],Bid-400*Point,Bid+Grid*Point);
     OpenOrder(OP_SELL,Bid,LotSeq[1],Ask+400*Point,Ask-Grid*Point);
    }
  if (State==-1)
    {
     if (Step==LockStep)
       {
        Step=0;
        RefreshRates();
        CurrentPrice=Bid;
        CalcTarget();
        LastLock=OpenOrder(OP_SELL,Bid,LotSeq[LockStep+1],Bid+400*Point,Ask-Grid*Point);
        OpenOrder(OP_BUY,Ask,LotSeq[0],Bid-400*Point,Bid+Grid*Point);
        OpenOrder(OP_SELL,Bid,LotSeq[0],Ask+400*Point,Ask-Grid*Point);
       }
     if (Step<LockStep)
       {
        Step++;
        RefreshRates();
        CurrentPrice=Bid;
        CalcTarget();
        OpenOrder(OP_BUY,Ask,LotSeq[Step],Bid-400*Point,Bid+Grid*Point);
        OpenOrder(OP_SELL,Bid,LotSeq[1],Ask+400*Point,Ask-Grid*Point);
       }
    }
  State=-1;
  return(0);
}

int DoUp()

{
  j=OrdersTotal();
  for (i=0;i<j;i++)
    {
     RefreshRates();
     OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
     if ((OrderType()==OP_BUY)&&(OrderTicket()>LastLock)) {OrderClose(OrderTicket(),OrderLots(),Bid,3,CLR_NONE);}
    }
  if (State==-1)
    {
     Step=1;
     RefreshRates();
     CurrentPrice=Bid;
     CalcTarget();
     OpenOrder(OP_BUY,Ask,LotSeq[1],Bid-400*Point,Bid+Grid*Point);
     OpenOrder(OP_SELL,Bid,LotSeq[1],Ask+400*Point,Ask-Grid*Point);
    }
  if (State==1)
    {
     if (Step==LockStep)
       {
        Step=0;
        RefreshRates();
        CurrentPrice=Bid;
        CalcTarget();
        LastLock=OpenOrder(OP_BUY,Ask,LotSeq[LockStep+1],Bid-400*Point,Bid-Grid*Point);
        OpenOrder(OP_BUY,Ask,LotSeq[0],Bid-400*Point,Bid+Grid*Point);
        OpenOrder(OP_SELL,Bid,LotSeq[0],Ask+400*Point,Ask-Grid*Point);
       }
     if (Step<LockStep)
       {
        Step++;
        RefreshRates();
        CurrentPrice=Bid;
        CalcTarget();
        OpenOrder(OP_BUY,Ask,LotSeq[1],Ask-400*Point,Bid+Grid*Point);
        OpenOrder(OP_SELL,Bid,LotSeq[Step],Bid+400*Point,Ask-Grid*Point);
       }
    }
  State=1;
  return(0);
}

int start()

{
  if (OrdersTotal()<1) {Init();}
  if (Bid<=TargetDown)  {DoDown();}
  if (Ask>=TargetUp)  {DoUp();}
  return(0);
}
























/*
//+------------------------------------------------------------------+
//|                                                       NewM2H.mq4 |
//+------------------------------------------------------------------+

#property copyright "Maloma"
#include <stdlib.mqh>


extern double Lot     = 1; // Начальный размер лота.
extern int    Grid    = 30; // Начальный размер сетки.

   double Spred;
   double SellWorkPrice;
   double BuyWorkPrice;
   double BuyStopPrice;
   double BuyStopProfit;
   double SellLimitPrice;
   double SellLimitProfit;
   double BuyLimitPrice;
   double BuyLimitProfit;
   double SellStopPrice;
   double SellStopProfit;
   int    StateOld, StateCur;
   int    Magic=120976;
   double CurrentPrice, OldPrice;
   int    Step;
   int    LastBuy, LastSell, ProfitOrder;
   double LotSeq[6] = {2,2,4.5,11.5,28.5,71}; // For 30
//   int    LotSeq[9] = {1,1,3,8,20,51,131,335,855}; // For 28
//   int    LotSeq[9] = {1,1,3,7,16,40,95,228,547}; // For 35
//   int    LotSeq[9] = {1,1,2,6,13,31,72,168,392}; // For 40
   int    BuyStopCnt, BuyLimitCnt, SellStopCnt, SellLimitCnt;
   bool   TradeDone;
      
//+------------------------------------------------------------------+
//+ Инициализация начальных значений и установка стартовых ордеров.  +
//+------------------------------------------------------------------+
int Init() { 

    Step = 1;
    StateCur = 0;
    StateOld=StateCur;
    Spred = MarketInfo(Symbol(),MODE_SPREAD)*Point;
    RefreshRates();
    CurrentPrice = Bid;
    OpenOrder (Symbol(), OP_SELL, Lot, NormalizeDouble(Bid,4), 3, Bid+400*Point, Ask-Grid*Point, "", Magic, 0, Red);
    OpenOrder (Symbol(), OP_BUY, Lot, NormalizeDouble(Ask,4), 3, Ask-400*Point, Bid+Grid*Point, "", Magic, 0, Green);
    CalcAllPrice (CurrentPrice);
    SearchLastSellBuy();
    TradeDone=false;
}

//+------------------------------------------------------------------+
//+ Функция открытия ордера. Пытается до тех пор, пока не выставит.  +
//+ Ордер не выставится только по несоответствующим рынку параметрам.+
//+------------------------------------------------------------------+  
int OpenOrder(string Sym, int Cmd, double Vol, double Prc, int Slp, double Stl, double Tpt, string Com, int Mag, datetime Exp, color Clr) {
  int err;
  
  int ticket=-1;
  while (ticket < 0) 
    {
     RefreshRates();
     ticket=OrderSend(Sym, Cmd, Vol, Prc, Slp, Stl, Tpt, Com, Mag, Exp, Clr);
     err=GetLastError();
     if ((err == 130) || (err == 4107))
        {
//         CurrentPrice = Bid;
//         CalcAllPrice (CurrentPrice);
         return(0);
        }
     if (ticket == -1) 
        {
         Comment("Error=", err, "   ", ErrorDescription(err));
         Sleep(6000);
        }
     else
        {
         Comment("                                             ");
        }
    }
  Sleep(1000);
  return (ticket);
}
  
//+------------------------------------------------------------------------------+
//+ Функция рассчитывает Размер лота в зависимости от шага и внешних переменных. +
//+------------------------------------------------------------------------------+  
double LotSize(int tStep) {

  double rez = Lot*LotSeq[tStep];

  return(rez);
}

//+------------------------------------------------------------------+
//+ Функция рассчитывает цены открытия и ТП для отложенных ордеров.  +
//+------------------------------------------------------------------+  


//+---------------------------------------------------------------------+
//+ Функция выставляет отложенные ордера по цене Lx, если Lx не равен 0 +
//+---------------------------------------------------------------------+  
int SetOrders (double L1, double L2, double L3, double L4){

  if (L1 != 0) {OpenOrder (Symbol(), OP_BUYSTOP, L1, BuyStopPrice, 3, BuyStopPrice-400*Point, BuyStopProfit, "", Magic, 0, Green);}
  if (L3 != 0) {OpenOrder (Symbol(), OP_BUYLIMIT, L3, BuyLimitPrice, 3, BuyLimitPrice-400*Point, BuyLimitProfit, "", Magic, 0, Green);}
  if (L2 != 0) {OpenOrder (Symbol(), OP_SELLLIMIT, L2, SellLimitPrice, 3, SellLimitPrice+400*Point, SellLimitProfit, "", Magic, 0, Red);}
  if (L4 != 0) {OpenOrder (Symbol(), OP_SELLSTOP, L4, SellStopPrice, 3, SellStopPrice+400*Point, SellStopProfit, "", Magic, 0, Red);}
  return(0);
}

//+------------------------------------------------------------------+
//+ Функция ищет тикеты последних открытых ордеров BUY и SELL.       +
//+------------------------------------------------------------------+  
int SearchLastSellBuy(){
  
  LastBuy=0;
  LastSell=0;
  for (int cnt=OrdersTotal()-1;cnt>=0;cnt--)
      {
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
       if ((OrderSymbol() == Symbol()) && (OrderType() == OP_BUY))
          {
           if (OrderTicket()>LastBuy) {LastBuy=OrderTicket();}
          }
       if ((OrderSymbol() == Symbol()) && (OrderType() == OP_SELL))
          {
           if (OrderTicket()>LastSell) {LastSell=OrderTicket();}
          }   
      }
  return(0);
}

//+---------------------------------------------------------------------------+
//+ Функция возврвщает тикет ордера, который достиг ТП. Если нет такого, то 0.+
//+---------------------------------------------------------------------------+  
int TakeProfit(){

   ProfitOrder=0;
   for (int cnt=HistoryTotal()-1;cnt>=0;cnt--)
       {
        OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY);
        if ((OrderTicket() == LastSell) || (OrderTicket() == LastBuy))
           if (OrderClosePrice() == OrderTakeProfit()) {ProfitOrder = OrderTicket();}
       }
   return(ProfitOrder);
}

//+------------------------------------------------------------------------------------+
//+ Двигаем Профиты так, чтобы при откате все в убыточной руке закрылись автоматически +
//+------------------------------------------------------------------------------------+
int MoveTP(bool Last){

  int cnt, err, ticket;
  bool res;
  
  if (StateCur==1)
     {
      for (cnt=OrdersTotal()-1;cnt>=0;cnt--)
          {
           RefreshRates();
           OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
           if (OrderSymbol() == Symbol())
              {
               if (OrderType() == OP_SELL)
                  {
                   if (Last) 
                      {
                       res = false;
                       while (!res) 
                          {
                           Print("- 1 -");
                           res = OrderModify(OrderTicket(), OrderOpenPrice(), BuyStopPrice, BuyLimitPrice, 0, CLR_NONE);
                           Sleep(1000);
                          }
                      }
                   else 
                      {
                       if (OrderTicket() != LastSell)
                          {
                           res = false;
                           while (!res) 
                              {
                               Print("- 2 -");
                               res = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), BuyLimitPrice, 0, CLR_NONE);
                               Sleep(1000);
                              }
                          }
                      }   
                  }
              }
          }
      return(0);
     }
  if (StateCur==-1)
     {
      for (cnt=OrdersTotal()-1;cnt>=0;cnt--)
          {
           RefreshRates();
           OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
           if (OrderSymbol() == Symbol())
              {
               if (OrderType() == OP_BUY)
                  {
                   if (Last)
                      {
                       res = false;
                       while (!res) 
                          {
                           Print("- 3 -");
                           res = OrderModify(OrderTicket(), OrderOpenPrice(), SellStopPrice, SellLimitPrice, 0, CLR_NONE);
                           Sleep(1000);
                          }
                      }
                   else 
                      {
                       if (OrderTicket() != LastBuy)
                          {
                           res = false;
                           while (!res) 
                              {
                               Print("- 4 -", "  OrdersTotal=", OrdersTotal(), "  Cnt=", cnt, "  LastBuy=", LastBuy, "  OrderTicket=", OrderTicket(), "  error=", GetLastError(), "  SellLimitPrice=", SellLimitPrice, "  TP=", OrderTakeProfit());
                               res = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), SellLimitPrice, 0, CLR_NONE);
                               Sleep(1000);
                              }
                          }
                      }
                  }
              }
          }
      return(0);
     }
}
           
int CheckTrade()
{
  if (Bid==SellStopPrice)
    {
     OpenOrder (Symbol(), OP_BUY, LotSize(Step), BuyLimitPrice, 3, BuyLimitPrice-400*Point, BuyLimitProfit, "", Magic, 0, Green);
     OpenOrder (Symbol(), OP_SELL, LotSize(1), SellStopPrice, 3, SellStopPrice+400*Point, SellStopProfit, "", Magic, 0, Red);
     TradeDone=true;
    }
  if (Ask==BuyStopPrice)  
    {
     OpenOrder (Symbol(), OP_BUY, LotSize(1), BuyStopPrice, 3, BuyStopPrice-400*Point, BuyStopProfit, "", Magic, 0, Green);
     OpenOrder (Symbol(), OP_SELL, LotSize(Step), SellLimitPrice, 3, SellLimitPrice+400*Point, SellLimitProfit, "", Magic, 0, Red);
     TradeDone=true;
    }
}


//+---------------------------+
//+ Собственно тело программы +
//+---------------------------+
int start(){
int tp;  

  if (OrdersTotal()<1) {Init();}
  CheckTrade();
  tp = TakeProfit();
  if (tp == 0) {return(0);}
  if (TradeDone){
  TradeDone=false;
  SearchLastSellBuy();
  OrderSelect(tp, SELECT_BY_TICKET);
  StateOld = StateCur;
  OldPrice = CurrentPrice;
  CurrentPrice = OrderTakeProfit();
//  Print ("0=", OldPrice, "  ", CurrentPrice);
  if (CurrentPrice < OldPrice) {StateCur = -1;}
  if (CurrentPrice > OldPrice) {StateCur = 1;}
  if (StateCur == 1) {if (((CurrentPrice+Grid*Point)-Ask) < 10*Point) {CurrentPrice = Bid; Print( ((CurrentPrice+Grid*Point)-Ask) );}}
  if (StateCur == -1) {if ((Bid -(CurrentPrice-Grid*Point)) < 10*Point) {CurrentPrice = Ask; Print( (Bid -(CurrentPrice-Grid*Point)) );}}
  if (StateCur == StateOld) {Step++;}
     else {Step=2;}
//  Print ("1=", OldPrice, "  ", CurrentPrice);
  if (StateCur == 1) {CalcAllPrice(CurrentPrice);}
  if (StateCur == -1) {CalcAllPrice(CurrentPrice-Spred);}
//  Print("MoveTP");
  if (Step < 6)
     {
      MoveTP(false);
      if (StateCur == 1) {SetOrders (LotSize(1), LotSize(Step), LotSize(1), LotSize(1));}
      if (StateCur == -1) {SetOrders (LotSize(1), LotSize(1), LotSize(Step), LotSize(1));}
     }
  else
     {
      MoveTP(true);
      {SetOrders (LotSize(1), LotSize(1), LotSize(1), LotSize(1));}
      Step=0;
     }}
  return (0);
}*/


