//+------------------------------------------------------------------+
//|                                Basket trading profit protect.mq4 |
//|                                  Copyright © 2008, Steve Hopwood |
//|                                     www.hopwood3.freeserve.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Steve Hopwood"
#property link      "www.hopwood3.freeserve.co.uk"
#include <WinUser32.mqh>
#include <stdlib.mqh>
#define  NL    "\n"

extern int     StartLockPips=200;
extern int     MagicNumber=71946723;
extern bool    CloseAtPipsProfitReached=false;
extern int     ScalpProfitPips=30;
extern bool    AllowTradeClosure=true;

bool           CloseAll=false;
int            LockedPips=0;
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
  
int CalculatePipsProfit()
   {
      int Profit=0;
      for (int cc=0; cc<OrdersTotal()-1; cc++)
      {
         OrderSelect(cc,SELECT_BY_POS);
         if (OrderMagicNumber()==MagicNumber)
         {
            if (OrderType()==OP_BUY) double ThisTradeProfit = MarketInfo(OrderSymbol(),MODE_BID)-OrderOpenPrice();
            if (OrderType()==OP_SELL) ThisTradeProfit = OrderOpenPrice()-MarketInfo(OrderSymbol(), MODE_ASK);
            if (MarketInfo(OrderSymbol(),MODE_DIGITS)==4) int multiplier=10000;
            if (MarketInfo(OrderSymbol(),MODE_DIGITS)==2) multiplier=100;
            ThisTradeProfit = ThisTradeProfit * multiplier;
            int iThisTradeProfit=ThisTradeProfit;
            Profit=Profit+iThisTradeProfit;
        }//if (OrderMagicNumber()==MagicNumber)
      }//for (int cc=0; cc<OrdersTotal(); cc++)
      
      return(Profit);
   }// end int CalculatePipsProfit()
  
void CloseAllBasketTrades()
   {   
      CloseAll=false;         
      Comment("Pips protect point reached. Closing all trades monitored by this ea");
      if (!AllowTradeClosure) return;
           
         
      for (int cc=0; cc<OrdersTotal(); cc++)
      {
         OrderSelect(cc,SELECT_BY_POS);
         if (OrderMagicNumber()==MagicNumber)
         {
            if (OrderType()==OP_BUY)
            {
               int ticket=OrderClose(OrderTicket(),OrderLots(), MarketInfo(OrderSymbol(), MODE_BID),5,CLR_NONE);
               if (ticket<0) CloseAll=true;
               else cc--;
            }//if (OrderType()==OP_BUY)   
            
            if (OrderType()==OP_SELL)
            {
               ticket=OrderClose(OrderTicket(),OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK),5,CLR_NONE);
               if (ticket<0) CloseAll=true;
               else cc--;
            }//if (OrderType()==OP_SELL)   
            
         }//if (OrderMagicNumber()==MagicNumber)
      }//for (int cc=0; cc<OrdersTotal(); cc++)
      
   
   }// end void CloseAllBasketTrades()
       
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   if (OrdersTotal()==0) 
   {
      Comment("No trades to monitor");
      LockedPips=0;
      return;
   }   
   
   if (CloseAll) CloseAllBasketTrades();
   
   int PipsProfit=CalculatePipsProfit();
   if (PipsProfit >= StartLockPips) 
   {
      if (LockedPips==0) LockedPips=StartLockPips-50;
      if (PipsProfit - LockedPips >=150) LockedPips = LockedPips + 100;
   }//if (PipsProfit >= StartLockPips) 
   
   if (LockedPips > 0 && PipsProfit <= LockedPips && PipsProfit>0)
   {
      CloseAll=true;
      CloseAllBasketTrades();
   }
 
   if (CloseAtPipsProfitReached)
   {
      if (PipsProfit >= ScalpProfitPips)
      {
         CloseAll=true;
         CloseAllBasketTrades();
      }
   }
 
   string ScreenMessage;
   ScreenMessage = StringConcatenate(ScreenMessage, "Magic number: ",MagicNumber,NL);
   ScreenMessage = StringConcatenate(ScreenMessage, "Pips profit = ",PipsProfit, NL);
   if (LockedPips>0) ScreenMessage = StringConcatenate(ScreenMessage, "Locked in pips = ", LockedPips,NL);
   else ScreenMessage = StringConcatenate(ScreenMessage, "No pips locked yet",NL);
   if (CloseAtPipsProfitReached) ScreenMessage = StringConcatenate(ScreenMessage, "Closing position at ", ScalpProfitPips, " pips",NL);
   Comment(ScreenMessage);
   
//----
   return(0);
  }
//+------------------------------------------------------------------+