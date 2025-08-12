//+------------------------------------------------------------------+
//|                                                      Ademola.mq4 |
//|                                        Copyright © 2008, LEGRUPO |
//|                                           http://www.legrupo.com |
//|                                                     Version: 1.0 |
//| History:                                                         |
//| 1.0 => Release version to the public                             |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, LEGRUPO"
#property link      "http://www.legrupo.com"
//+------------------------------------------------------------------+
//| EX4 imports                                                      |
//+------------------------------------------------------------------+
#include <stderror.mqh>
#include <stdlib.mqh>

//---- input parameters
extern int ExpertID = 108888;
extern double    TakeProfit=40;
extern bool useStopLoss = true;
extern double    StopLoss=20;
extern double    Lots=0.01;
extern int Slippage = 3;

extern bool   useTimeFilter        = true;
extern int    startTradeTime       = 1;

extern bool UseMoneyManagement = true;
extern bool AccountIsMicro = true;
extern int Risk = 10; // risk in percentage % (10% of risk in this case)

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   int MagicNumber = MakeMagicNumber();
   if(UseMoneyManagement==true) {
      Lots = DefineLotSize(); //Adjust the lot size     total
   }
   int order_type = -1;
   double tp, sl, price = 0.0;
   if (TimeHour(TimeCurrent()) == startTradeTime) {
      // new day
      datetime time = StrToTime(+Year()+"."+Month()+"."+Day()+" 00:00");
      for(int i=1; i<=Bars; i++) {
         if (Time[i] == time) {
            double day_O = Open[i];
            double day_H = High[i];
            double day_L = Low[i];
            double day_C = Close[i];
            break;
         }
      }
      ObjectDelete("Day open");
      ObjectDelete("X");
      ObjectDelete("X1");
      ObjectDelete("X2");
      ObjectDelete("X3");
      ObjectDelete("X4");
      if(!ObjectCreate("Day open", OBJ_VLINE, 0, time, Ask)) {
         Alert("Error: Day open #",ErrorDescription(GetLastError()));
      } else {
         ObjectSet("Day open", OBJPROP_STYLE, STYLE_DASH);
         ObjectSet("Day open", OBJPROP_COLOR, Red);
         
         // X LINE
         double x_line=NormalizeDouble((day_H+day_L)/2, Digits);
         if(!ObjectCreate("X", OBJ_HLINE, 0, time, x_line)) {
            Alert("Error: LINE X #",ErrorDescription(GetLastError()));
         } else {
            ObjectSet("X", OBJPROP_STYLE, STYLE_SOLID);
            ObjectSet("X", OBJPROP_COLOR, Green);
         }
         
         // X1 LINE
         double x1_line=NormalizeDouble(((day_H+day_L)/2)+40*Point, Digits);
         if(!ObjectCreate("X1", OBJ_HLINE, 0, time, x1_line)) {
            Alert("Error: LINE X1 #",ErrorDescription(GetLastError()));
         } else {
            ObjectSet("X1", OBJPROP_STYLE, STYLE_SOLID);
            ObjectSet("X1", OBJPROP_COLOR, Purple);
         }
         
         // X2 LINE
         double x2_line=NormalizeDouble(((day_H+day_L)/2)+80*Point, Digits);
         if(!ObjectCreate("X2", OBJ_HLINE, 0, time, x2_line)) {
            Alert("Error: LINE X2 #",ErrorDescription(GetLastError()));
         } else {
            ObjectSet("X2", OBJPROP_STYLE, STYLE_SOLID);
            ObjectSet("X2", OBJPROP_COLOR, Purple);
         }
         
         // X3 LINE
         double x3_line=NormalizeDouble(((day_H+day_L)/2)-40*Point, Digits);
         if(!ObjectCreate("X3", OBJ_HLINE, 0, time, x3_line)) {
            Alert("Error: LINE X3 #",ErrorDescription(GetLastError()));
         } else {
            ObjectSet("X3", OBJPROP_STYLE, STYLE_SOLID);
            ObjectSet("X3", OBJPROP_COLOR, Red);
         }
         
         // X4 LINE
         double x4_line=NormalizeDouble(((day_H+day_L)/2)-80*Point, Digits);
         if(!ObjectCreate("X4", OBJ_HLINE, 0, time, x4_line)) {
            Alert("Error: LINE X4 #",ErrorDescription(GetLastError()));
         } else {
            ObjectSet("X4", OBJPROP_STYLE, STYLE_SOLID);
            ObjectSet("X4", OBJPROP_COLOR, Red);
         }
      }
      
      if (CountLongs(MagicNumber) == 0 || CountShorts(MagicNumber) == 0) {
         price = x1_line;
         tp = x2_line;
         if (useStopLoss) {
            sl = x4_line;
         } else {
            sl = 0;
         }
      
         int ticket_buy = OrderSend(Symbol(),OP_BUYSTOP,Lots,price,Slippage,sl,tp,"Ademola",MagicNumber,0,CLR_NONE);
         if(ticket_buy>0)
         {
            if(OrderSelect(ticket_buy,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
         } else {
            Alert("Ademola Error opening order : ",ErrorDescription(GetLastError()));
            return(0);
         } // fim ticket_buy
      
      
         price = x3_line;
         tp = x4_line;
         if (useStopLoss) {
            sl = x2_line;
         } else {
            sl = 0;
         }
         int ticket_sell = OrderSend(Symbol(),OP_SELLSTOP,Lots,price,Slippage,sl,tp,"Ademola",MagicNumber,0,CLR_NONE);
         if(ticket_sell>0)
         {
            if(OrderSelect(ticket_sell,SELECT_BY_TICKET,MODE_TRADES)) Print("SELL order opened : ",OrderOpenPrice());
         } else {
            Alert("Ademola Error opening order : ",ErrorDescription(GetLastError()));
            return(0);
         } // fim ticket_sell
      }
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+


int MakeMagicNumber()
{
   int SymbolCode  = 0;
   int PeriodCode  = 0;
   int MagicNumber = 0; 
   
   //---- Symbol Code
        if( Symbol() == "AUDCAD" || Symbol() == "AUDCADm" ) { SymbolCode = 1000; }
   else if( Symbol() == "AUDJPY" || Symbol() == "AUDJPYm" ) { SymbolCode = 2000; }
   else if( Symbol() == "AUDNZD" || Symbol() == "AUDNZDm" ) { SymbolCode = 3000; }
   else if( Symbol() == "AUDUSD" || Symbol() == "AUDUSDm" ) { SymbolCode = 4000; }
   else if( Symbol() == "CHFJPY" || Symbol() == "CHFJPYm" ) { SymbolCode = 5000; }
   else if( Symbol() == "EURAUD" || Symbol() == "EURAUDm" ) { SymbolCode = 6000; }
   else if( Symbol() == "EURCAD" || Symbol() == "EURCADm" ) { SymbolCode = 7000; }
   else if( Symbol() == "EURCHF" || Symbol() == "EURCHFm" ) { SymbolCode = 8000; }
   else if( Symbol() == "EURGBP" || Symbol() == "EURGBPm" ) { SymbolCode = 9000; }
   else if( Symbol() == "EURJPY" || Symbol() == "EURJPYm" ) { SymbolCode = 1000; }
   else if( Symbol() == "EURUSD" || Symbol() == "EURUSDm" ) { SymbolCode = 1100; }
   else if( Symbol() == "GBPCHF" || Symbol() == "GBPCHFm" ) { SymbolCode = 1200; }
   else if( Symbol() == "GBPJPY" || Symbol() == "GBPJPYm" ) { SymbolCode = 1300; }
   else if( Symbol() == "GBPUSD" || Symbol() == "GBPUSDm" ) { SymbolCode = 1400; }
   else if( Symbol() == "NZDJPY" || Symbol() == "NZDJPYm" ) { SymbolCode = 1500; }
   else if( Symbol() == "NZDUSD" || Symbol() == "NZDUSDm" ) { SymbolCode = 1600; }
   else if( Symbol() == "USDCAD" || Symbol() == "USDCADm" ) { SymbolCode = 1700; }
   else if( Symbol() == "USDCHF" || Symbol() == "USDCHFm" ) { SymbolCode = 1800; }
   else if( Symbol() == "USDJPY" || Symbol() == "USDJPYm" ) { SymbolCode = 1900; }
                     
   //---- Calculate MagicNumber
   MagicNumber = ExpertID+SymbolCode;
   return(MagicNumber);
}

double DefineLotSize() {
   double lotMM = MathCeil(AccountFreeMargin() *  Risk / 1000) / 100;
   if(AccountIsMicro==false) { //normal account
      if (lotMM < 0.1) lotMM = Lots;
      if ((lotMM > 0.5) && (lotMM < 1)) lotMM=0.5;
      if (lotMM > 1.0) lotMM = MathCeil(lotMM);
      if  (lotMM > 100) lotMM = 100;
   } else { //micro account
      if (lotMM < 0.01) lotMM = Lots;
      if (lotMM > 1.0) lotMM = MathCeil(lotMM);
      if  (lotMM > 100) lotMM = 100;
   }
   return (lotMM);
}
//+------------------------------------------------------------------+
//| Calculate concurrent Long position                               |
//+------------------------------------------------------------------+
int CountLongs(int MagicNumber)
{
 int count=0;
 int trade;
 int trades=OrdersTotal();
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if( OrderSymbol()!=Symbol() || OrderMagicNumber() != MagicNumber )
   continue;
   
  if(OrderType()==OP_BUY || OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP)
   count++;
 }//for
 return(count);
}
//+------------------------------------------------------------------+
//| Calculate concurrent short position                              |
//+------------------------------------------------------------------+
int CountShorts(int MagicNumber)
{
 int count=0;
 int trade;
 int trades=OrdersTotal();
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol() || OrderMagicNumber() != MagicNumber )
   continue;
   
  if(OrderType()==OP_SELL || OrderType()==OP_SELLLIMIT || OrderType()==OP_SELLSTOP)
  count++;
 }//for
 return(count);
}
//+------------------------------------------------------------------+
//| Close Long Position                                              |
//+------------------------------------------------------------------+
void CloseLongs(int MagicNumber)
{
 int i = OrdersTotal();
 
 while( CountLongs(MagicNumber) != 0 && i >= 0 )
 {  
   OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
   
   if( OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )
   {
     i--;
     continue;
   }
   else if(OrderType()==OP_BUY || OrderType()== OP_BUYLIMIT || OrderType()==OP_BUYSTOP)
   {
     OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,CLR_NONE);
     OrderDelete(OrderTicket());
     i--;
   }
 }
}
//+------------------------------------------------------------------+
//| Close Short Position                                             |
//+------------------------------------------------------------------+
void CloseShorts(int MagicNumber)
{
 int i = OrdersTotal();
 
 while( CountShorts(MagicNumber) != 0 && i >= 0 )
 {  
   OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
   
   if( OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
   {
     i--;
     continue;
   }
   else if(OrderType()== OP_SELL || OrderType()==OP_SELLLIMIT || OrderType()==OP_SELLSTOP)
  {
   OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,CLR_NONE);
   OrderDelete(OrderTicket());
  }
 }
}