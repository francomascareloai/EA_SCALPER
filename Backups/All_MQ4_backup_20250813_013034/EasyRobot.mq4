//+------------------------------------------------------------------+
//|                                                    EasyRobot.mq4 |
//|                             Copyright 2020, DKP Sweden,CS Robots |
//|                             https://www.mql5.com/en/users/kenpar |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, DKP Sweden,CS Robots"
#property link      "https://www.mql5.com/en/users/kenpar"
#property version   "1.03"
#property strict
//////////////////////////////////////////////////////////////////////
//Fully operational ea for real/demo accounts or educational purpose
//It was never said anywere it's a holy grail....
//Optimize adviser settings # 5,6,8,9 with use of 'range/step' guide
//////////////////////////////////////////////////////////////////////
//Version updates
//v1.01:Period checking - This robot is designed to trade H1 charts and a period checking 
//function now alerts user if traded chart period is wrong!
//v1.02:Re coded trailing stop - Added a tiny chart comment - EA journal events printing switch
//v1.03:Order string comments added
//////////////////////////////////////////////////////////////////////
extern int          MagicNumber   = 1234567;//1.   Magic number
extern bool         AutoLot       = true;//2.   Auto lots
extern double       FixedLot      = 0.1;//3.   Fixed lots size
extern int          Risk          = 2;//4.   Risk % (if #2=true)
extern double       TakeFactor    = 4.2;//5.   TP factor multiplier ( range 1.0-5.0/step 0.1 )
extern double       StopFactor    = 4.9;//6.   SL factor multiplier ( range 1.0-5.0/step 0.1 )
extern bool         UseTstop      = true;//7.   Trailing stop
extern double       Tstart        = 48.;//8.   Trailing start pips ( range 10.0-50.0/step 1.0 )
extern double       Tstep         = 36.;//9.   Trailing step pips ( range 10.0-50.0/step 1.0 )
extern string       oscb          = "ER_BUY";//10. Order string comment long
extern string       oscs          = "ER_SELL";//11. Order string comment short
//---
bool journal=false,dash=false;
//---
double _takefactor,
       _stopfactor,
       _point,
       NewPoint,
       _lots,
       _otf,
       _osf,
       _tp,
       _sl;
//---
int ticket=0,_digits;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   _digits = (int)MarketInfo(Symbol(),MODE_DIGITS);
   _point = MarketInfo(Symbol(),MODE_POINT);
//---
   if(_digits==5||_digits==3)
      NewPoint=_point*10;
   else
      NewPoint=_point;
//---
   if(!period())
      return(INIT_FAILED);
//---
   if(!IsTesting()||IsVisualMode())
     {
      journal=true;
      dash=true;
     }
//---
   Comment("\n| No ticks received yet...");
//---

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Comment("");
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(Tstep>Tstart)
      return;
//---
   if(dash)
      _comment();
//---
   if(UseTstop&&GetPosition()!=0)
      Trail();
//---
   if(GetPosition()==0)
      BarSignal();
//---
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BarSignal()
  {
//---
   if(iOpen(Symbol(),PERIOD_CURRENT,0) < iClose(Symbol(),PERIOD_CURRENT,0))
      SendBuy(Ask,FetchLots(),TakeFactor,StopFactor);
//---
   if(iOpen(Symbol(),PERIOD_CURRENT,0) > iClose(Symbol(),PERIOD_CURRENT,0))
      SendSell(Bid,FetchLots(),TakeFactor,StopFactor);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendBuy(double bprice,double vol,double _tf,double _sf)
  {
//---
   _otf = (ATR() * (Zd(_tf,NewPoint)));
   _osf = (ATR() * (Zd(_sf,NewPoint)));
//---
   _tp = bprice + _otf * NewPoint;
   _sl = bprice - _osf * NewPoint;
//---
   if(CheckMoneyForTrade(Symbol(),OP_BUY,vol))
      ticket = OrderSend(Symbol(),OP_BUY,vol,bprice,3,_sl,_tp,oscb,MagicNumber,0,Green);
   if(ticket<1)
     {
      Print("Order send BUY failed - errcode ",GetLastError());
      return;
     }
   else
   if(journal)
      Print("Order send BUY executed successfully, ticket # ",ticket);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendSell(double sprice,double vol,double _tf,double _sf)
  {
//---
   _otf = (ATR() * (Zd(_tf,NewPoint)));
   _osf = (ATR() * (Zd(_sf,NewPoint)));
//---
   _tp = sprice - _otf * NewPoint;
   _sl = sprice + _osf * NewPoint;
//---
   if(CheckMoneyForTrade(Symbol(),OP_SELL,vol))
      ticket = OrderSend(Symbol(),OP_SELL,vol,sprice,3,_sl,_tp,oscs,MagicNumber,0,Red);
   if(ticket<1)
     {
      Print("Order send SELL failed - errcode ",GetLastError());
      return;
     }
   else
   if(journal)
      Print("Order send SELL executed successfully, ticket # ",ticket);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trail()
  {
//---
   double stops=MarketInfo(Symbol(),MODE_STOPLEVEL);
//---
   for(int u=0; u<OrdersTotal(); u++)
     {
      if(!OrderSelect(u,SELECT_BY_POS,MODE_TRADES))
         break;
      if(OrderSymbol()!=Symbol() && OrderMagicNumber()!=MagicNumber)
         continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
        {
         if(OrderType()==OP_BUY && Bid-Tstart*NewPoint>OrderOpenPrice())
           {
            double nsb=NormalizeDouble(Bid-Tstep*NewPoint,Digits);
            if(nsb>OrderStopLoss() || OrderStopLoss()==0)
              {
               if(nsb<Bid-stops*NewPoint)
                 {
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),nsb,OrderTakeProfit(),0,Blue))
                     Print("Trailing stop modify error BUY order on Symbol : "+Symbol()+" : ",GetLastError());
                  else
                     if(journal)
                        Print("Trailing stop modifying BUY order on Symbol : "+Symbol()+" ok!");
                 }
              }
           }
         if(OrderType()==OP_SELL && Ask+Tstart*NewPoint<OrderOpenPrice())
           {
            double nss=NormalizeDouble(Ask+Tstep*NewPoint,Digits);
            if(nss<OrderStopLoss() || OrderStopLoss()==0)
              {
               if(Ask+stops*NewPoint<nss)
                 {
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),nss,OrderTakeProfit(),0,Blue))
                     Print("Trailing stop modify error SELL order on Symbol : "+Symbol()+" : ",GetLastError());
                  else
                     if(journal)
                        Print("Trailing stop modifying SELL order on Symbol : "+Symbol()+" ok!");
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ATR()
  {
   return(iATR(Symbol(), PERIOD_CURRENT, 14, 1));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FetchLots()
  {
   if(AutoLot)
     {
      _lots = MathMin(MathMax((MathRound((AccountFreeMargin()*Risk/1000/100)
                                         /MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP)),
                              MarketInfo(Symbol(),MODE_MINLOT)),MarketInfo(Symbol(),MODE_MAXLOT));
     }
   else
     {
      _lots = MathMin(MathMax((MathRound(FixedLot/MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP)),
                              MarketInfo(Symbol(),MODE_MINLOT)),MarketInfo(Symbol(),MODE_MAXLOT));
     }
   return(_lots);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetPosition()
  {
   int posval=0;
   for(int e = OrdersTotal() - 1; e >= 0; e--)
     {
      if(!OrderSelect(e, SELECT_BY_POS))
         break;
      if(OrderSymbol()!=Symbol() && OrderMagicNumber()!=MagicNumber)
         continue;
      if(OrderCloseTime() == 0 && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
        {
         if(OrderType() == OP_BUY)
            posval = 1;
         if(OrderType() == OP_SELL)
            posval = -1;
        }
     }
   return(posval);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _comment()
  {
   Comment("\n| Easy Robot working...\n| Weekday ",DayOfWeek());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Zd(double n, double d)
  {
   if(d == 0)
      return(0);
   else
      return(n/d);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool period()
  {
   if(!IsTesting()&&Period()!=PERIOD_H1)
     {
      MessageBox("Wrong period - Use H1");
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb,int type,double lots)
  {
   double free_margin=AccountFreeMarginCheck(symb,type,lots);
   if(free_margin<0)
     {
      string oper=(type==OP_BUY)? "Buy":"Sell";
      Print("Not enough money for ",oper," ",lots," ",symb," Error code=",GetLastError());
      return(false);
     }
//--- checking successful
   return(true);
  }
//+------------------------------------------------------------------+
