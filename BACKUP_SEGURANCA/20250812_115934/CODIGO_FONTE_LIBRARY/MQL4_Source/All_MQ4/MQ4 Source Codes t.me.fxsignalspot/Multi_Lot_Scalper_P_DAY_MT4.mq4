//+------------------------------------------------------------------+
//|                                      Multi_Lot_Scapler_P_DAY.mq4 |
//|                                   Owner:  Alejandro Galindo      |
//|                                                                  |
//|                                  Conversion to MT4 by Jacob Yego |
//|                                             |
//|                                     |
//+------------------------------------------------------------------+

#property copyright " Copyright © 2005  Alejandro Galindo - FAB4X"
#property link      " Copyright © 2005 Alejandro Galindo - FAB4X INTL"
#include <stdlib.mqh>
//+------------------------------------------------------------------+
//| Common External variables                                        |
//+------------------------------------------------------------------+
extern double Lots = 0.10;
extern double StopLoss = 0.00;
extern double TakeProfit = 10.00;
extern double TrailingStop = 5.00;

//+------------------------------------------------------------------+
//| External variables                                               |
//+------------------------------------------------------------------+
extern double MaxTrades = 5;
extern double Pips = 2;
extern double SecureProfit = 10;
extern double AccountProtection = 1;
extern double OrderstoProtect = 3;
extern double ReverseCondition = 0;
extern double EURUSDPipValue = 10;
extern double GBPUSDPipValue = 10;
extern double USDCHFPipValue = 7.94;
extern double USDJPYPipValue = 9.03;
extern double mm = 0;
extern double risk = 12;
extern double AccountisNormal = 0;
extern double TimeZoneofData = 0;


bool SetObjectText(string name, string text, string font, int size, color Acolor)
{
  return(ObjectSetText(name, text, size, font, Acolor));
}

bool MoveObject(string name, int type, datetime Atime, double Aprice, datetime Atime2 = 0, double Aprice2 = 0, color Acolor = CLR_NONE, int Aweight = 0, int Astyle = 0)
{
    if (ObjectFind(name) != -1)
    {
      int OType = ObjectType(name);

      if ((OType == OBJ_VLINE) ||
         (OType == OBJ_HLINE) ||
         (OType == OBJ_TRENDBYANGLE) ||
         (OType == OBJ_TEXT) ||
         (OType == OBJ_ARROW) ||
         (OType == OBJ_LABEL))
      {
        return(ObjectMove(name, 0, Atime, Aprice));
      }

      if ((OType == OBJ_GANNLINE) ||
         (OType == OBJ_GANNFAN) ||
         (OType == OBJ_GANNGRID) ||
         (OType == OBJ_FIBO) ||
         (OType == OBJ_FIBOTIMES) ||
         (OType == OBJ_FIBOFAN) ||
         (OType == OBJ_FIBOARC) ||
         (OType == OBJ_RECTANGLE) ||
         (OType == OBJ_ELLIPSE) ||
         (OType == OBJ_CYCLES) ||
         (OType == OBJ_TREND) ||
         (OType == OBJ_STDDEVCHANNEL) ||
         (OType == OBJ_REGRESSION))
      {
        return(ObjectMove(name, 0, Atime, Aprice) && ObjectMove(name, 1, Atime2, Aprice2));
      }


    }
    else
    {
      return(ObjectCreate(name, type, 0, Atime, Aprice, Atime2, Aprice2, 0, 0) && ObjectSet(name, OBJPROP_COLOR, Acolor));
    }
}



//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+

int init()
{
   return(0);
}
int start()
{
//+------------------------------------------------------------------+
//| Local variables                                                  |
//+------------------------------------------------------------------+
double OpenOrders = 0;
int cnt = 0;
double slippage = 5;
double sl = 0;
double tp = 0;
double BuyPrice = 0;
double SellPrice = 0;
double lotsi = 0;
double mylotsi = 0;
double mode = 0;
bool ContinueOpening = True;
double LastPrice = 0;
double PreviousOpenOrders = 0;
double Profit = 0;
double LastTicket = 0;
double LastType = 0;
double LastClosePrice = 0;
double LastLots = 0;
double Pivot = 0;
double PipValue = 0;
bool Reversed = False;
string text = "";
string text2 = "";
double myl = 0;
double myh = 0;
double myC = 0;
double myO = 0;
double mypivot = 0;
double Today = 0;
double RefDate = 0;
double LastBarOfDay = 0;
double FirstBarOfDay = 0;
double Loop = 0;
double myyh = 0;
double myyl = 0;
double myyc = 0;
double p = 0;
double flp = 0;
double feh = 0;
double fel = 0;
double ph = 0;
double pl = 0;
double gap = 0;

if( AccountisNormal ==  1 ) 
   {
   if( mm != 0 ) lotsi = MathCeil(AccountBalance() * risk / 10000) ; else lotsi = Lots;
   }
       else 
   {
   if( mm != 0 ) lotsi = MathCeil(AccountBalance() * risk / 10000) / 10 ; else lotsi = Lots;
   }

if( lotsi > 100 ) lotsi = 100;

OpenOrders = 0;
for(cnt =1;cnt <=OrdersTotal();cnt ++) {
   if( OrderSymbol() ==  Symbol() ) OpenOrders++;
   }
myh = High[0];
myl = Low[0];
myC = Close[0];
myO = Open[0];
myyh = High[1];
myyl = Low[1];
myyc = Close[1];
p  = (myyh + myyl + myyc + myO) / 4;
ph = (myyh + myh + myyc + myO) / 4;
pl = (myyl + myl + myyc + myO) / 4;
flp = (myh + myl + myC) / 3;
gap = MathAbs(p - flp) * 10000;

MoveObject("P",OBJ_HLINE,Time[0],p,Time[0],p,Gold,1,STYLE_SOLID);
SetObjectText("P_txt","Pivot Zone","Arial",7,White);
MoveObject("P_txt",OBJ_TEXT,Time[0],p,Time[0],p,White);

if( Ask > p && Ask > flp ) 
   {
   MoveObject("FLP",OBJ_HLINE,Time[0],flp,Time[0],flp,LimeGreen,1,STYLE_SOLID);
   SetObjectText("FLP_txt","Floating Trend Direction - LONG","Arial",7,White);
   MoveObject("FLP_txt",OBJ_TEXT,Time[0],flp,Time[0],flp,White);
   Comment("Account: ",AccountNumber()," - ",AccountName(),"'#10'LastPrice=",LastPrice," Previous open orders=",PreviousOpenOrders,"'#10'Continue opening=",ContinueOpening," OrderType=",OrderType(),"'#10'",text2," Balance: ",DoubleToStr(AccountBalance(),2),"'#10'Lots=",lotsi,"'#10'",text,"Trend Bias -- LONG");
   }

if( Bid < p && Bid < flp ) 
   {
   MoveObject("FLP",OBJ_HLINE,Time[0],flp,Time[0],flp,Red,1,STYLE_SOLID);
   SetObjectText("FLP_txt","Floating Trend Direction - SHORT","Arial",7,White);
   MoveObject("FLP_txt",OBJ_TEXT,Time[0],flp,Time[0],flp,White);
   Comment("Account: ",AccountNumber()," - ",AccountName(),"'#10'LastPrice=",LastPrice," Previous open orders=",PreviousOpenOrders,"'#10'Continue opening=",ContinueOpening," OrderType=",OrderType(),"'#10'",text2," Balance: ",DoubleToStr(AccountBalance(),2),"'#10'Lots=",lotsi,"'#10'",text,"Trend Bias -- SHORT");
   }


  
   
   if (Symbol()== "EURUSD") PipValue = EURUSDPipValue;
   if (Symbol()== "GBPUSD") PipValue = GBPUSDPipValue;
   if (Symbol()== "USDJPY") PipValue = USDJPYPipValue;
   if (Symbol()== "USDCHF") PipValue = USDCHFPipValue; 
    
      
if( PreviousOpenOrders > OpenOrders ) 
   {
   for(cnt =OrdersTotal();cnt >=1;cnt --) {
      mode = OrderType();
      if( OrderSymbol() ==  Symbol() ) 
         {
         if( mode ==  OP_BUY )  OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,Blue);
         if( mode ==  OP_SELL ) OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,Red);
         return(0);
         }
      }
   }
int ordertypeb=0,ordertypes=0;
PreviousOpenOrders = OpenOrders;
if( OpenOrders >= MaxTrades ) ContinueOpening = False ; else ContinueOpening = True;

if( LastPrice ==  0 ) 
   {
   for(cnt=0;cnt<OrdersTotal();cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if( OrderSymbol()==Symbol() )
         {
         LastPrice = OrderOpenPrice();
         if(OrderType()==OP_BUY)  ordertypeb=1;
         if(OrderType()==OP_BUY)  ordertypes=1;
         }
      }
   }

if( OpenOrders < 1 ) ordertypeb=1;
if( OpenOrders < 1 && Bid < p && Bid < flp && gap >= 7 ) 
   {
   LastPrice = 0;
   ordertypeb=1;
   }
if( OpenOrders < 1 && Ask > p && Ask > flp && gap >= 7 ) 
   {
   LastPrice = 0;
   ordertypes=1;
   }

for(cnt =OrdersTotal();cnt >=1;cnt --) {
   if( OrderSymbol() ==  Symbol() && Reversed ==  False ) 
      {
      if( OrderType() ==  OP_SELL ) 
         {
         if( TrailingStop > 0 ) 
            {
            if( OrderOpenPrice() - Ask >= TrailingStop * Point + Pips * Point ) 
               {
               if( OrderStopLoss() > Ask + Point * TrailingStop || OrderStopLoss() ==  0 ) 
                  {
                  OrderModify(OrderTicket(),OrderOpenPrice(),Ask + Point * TrailingStop,OrderClosePrice() - TakeProfit * Point - TrailingStop * Point,0,Purple);
                  return(0);
                  }
               }
            }
         }
      if( OrderType() ==  OP_BUY ) 
         {
         if( TrailingStop > 0 ) 
            {
            if( Bid - OrderOpenPrice() >= TrailingStop * Point + Pips * Point ) 
               {
               if( OrderStopLoss() < Bid - Point * TrailingStop ) 
                  {
                  OrderModify(OrderTicket(),OrderOpenPrice(),Bid - Point * TrailingStop,OrderClosePrice() + TakeProfit * Point + TrailingStop * Point,0,Yellow);
                  return(0);
                  }
               }
            }
         }
      }
   }

Profit = 0;
LastTicket = 0;
LastType = 0;
LastClosePrice = 0;
LastLots = 0;

for(cnt =1;cnt <=OrdersTotal();cnt ++) 
{
OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
   if( OrderSymbol() ==  Symbol() ) 
      {
      LastTicket = OrderTicket();
      if( OrderType() ==  OP_BUY ) LastType = 0;
      if( OrderType() ==  OP_SELL ) LastType = 1;
      LastClosePrice = OrderClosePrice();
      LastLots = OrderLots();
      if( LastType ==  0 ) 
         {
         if( OrderClosePrice() < OrderOpenPrice() ) 
            {
            Profit = Profit - (OrderOpenPrice() - OrderClosePrice()) * OrderLots() / Point;
            }
         if( OrderClosePrice() > OrderOpenPrice() ) 
            {
            Profit = Profit + (OrderClosePrice() - OrderOpenPrice()) * OrderLots() / Point;
            }
         }
      if( LastType ==  1 ) 
         {
         if( OrderClosePrice() > OrderOpenPrice() ) 
            {
            Profit = Profit - (OrderClosePrice() - OrderOpenPrice()) * OrderLots() / Point;
            }
         if( OrderClosePrice() < OrderOpenPrice() ) 
            {
            Profit = Profit + (OrderOpenPrice() - OrderClosePrice()) * OrderLots() / Point;
            }
         }
      }
   }

Profit = Profit * PipValue;
text2 = "Profit: $" + DoubleToStr(Profit,2) + " +/- ";
if( OpenOrders >= MaxTrades - OrderstoProtect && AccountProtection ==  1 ) 
   {
   if( ordertypeb==1 && Bid ==  tp ) 
      {
      OrderClose(LastTicket,LastLots,LastClosePrice,slippage,Yellow);
      ContinueOpening = False;
      return(0);
      }
   if( ordertypes==1 && Ask ==  tp ) 
      {
      OrderClose(LastTicket,LastLots,LastClosePrice,slippage,Yellow);
      ContinueOpening = False;
      return(0);
      }
   }

if( ordertypes==1 && ContinueOpening ) 
   {
   if( Bid - LastPrice >= Pips * Point || OpenOrders < 1 ) 
      {
      SellPrice = Bid;
      LastPrice = 0;
      if( TakeProfit ==  0 ) tp = 0 ; else tp = SellPrice - TakeProfit * Point;
      if( StopLoss ==  0 ) sl = 0 ; else sl = SellPrice + StopLoss * Point;
      if( OpenOrders != 0 ) 
         {
         mylotsi = lotsi;
         for(cnt =1;cnt <=OpenOrders;cnt ++) {
            if( MaxTrades > 12 ) mylotsi = NormalizeDouble(mylotsi * 1.5,1) ; else mylotsi = NormalizeDouble(mylotsi * 2,1);
            }
         }
             else 
         {
         mylotsi = lotsi;
         }
      if( mylotsi > 100 ) mylotsi = 100;
      OrderSend(Symbol(),OP_SELL,mylotsi,SellPrice,slippage,sl,tp,"",16384,0,Red);
      return(0);
      }
   }

if( ordertypeb==1 && ContinueOpening ) 
   {
   if( LastPrice - Ask >= Pips * Point || OpenOrders < 1 ) 
      {
      BuyPrice = Ask;
      LastPrice = 0;
      if( TakeProfit ==  0 ) tp = 0 ; else tp = BuyPrice + TakeProfit * Point;
      if( StopLoss ==  0 ) sl = 0 ; else sl = BuyPrice - StopLoss * Point;
      if( OpenOrders != 0 ) 
         {
         mylotsi = lotsi;
         for(cnt =1;cnt <=OpenOrders;cnt ++) {
            if( MaxTrades > 12 ) mylotsi = NormalizeDouble(mylotsi * 1.5,1) ; else mylotsi = NormalizeDouble(mylotsi * 2,1);
            }
         }
             else 
         {
         mylotsi = lotsi;
         }
      if( mylotsi > 100 ) mylotsi = 100;
      OrderSend(Symbol(),OP_BUY,mylotsi,BuyPrice,slippage,sl,tp,"",16384,0,Blue);
      return(0);
      }
   }

  return(0);
}