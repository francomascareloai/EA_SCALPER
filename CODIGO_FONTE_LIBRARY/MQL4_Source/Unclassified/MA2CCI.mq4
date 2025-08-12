//+------------------------------------------------------------------+
//|                                                       MA2CCI.mq4 |
//|                                  Copyright © 2005, George-on-Don |
//|                                       http://www.forex.aaanet.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, George-on-Don"
#property link      "http://www.forex.aaanet.ru"

#include <stdlib.mqh>
#include <stderror.mqh>

#define MAGICMA  20050610

//---- input parameters
extern int       FMa=4;       // Fast MA
extern int       SMa=8;       // Slow MA
extern int       PCCi=4;      // CCI Period
extern int       pATR=4;      // ATR Period for S/L
extern double    Lots=0.1;    // Lot
extern bool      SndMl=true;  // E-mail Sending Parameter
extern double    DcF = 3;     // Optimization Factor 
extern double    MaxR = 0.02; // Maximum Risk

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)
  {
   int buys=0,sells=0;
//----
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) 
         break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
        {
         if(OrderType()==OP_BUY)  
            buys++;
         if(OrderType()==OP_SELL) 
           sells++;
        }
     }
//---- return orders volume
     if(buys>0) 
        return(buys);
     else
        return(-sells);
  }
  
void CheckForOpen()
  {
   double mas;
   double maf;
   double mas_p;
   double maf_p;
   double Atr;
   double icc;
   double icc_p;
   int    res;
   string sHeaderLetter;
   string sBodyLetter;
//---- trading will be started with first tick of new bar only
   if(Volume[0]>1) return;
//---- define Moving Average 
   mas=iMA(NULL,0,SMa,0,MODE_SMA,PRICE_CLOSE,1);    // Slow MA shifted on 1 Period
   maf=iMA(NULL,0,FMa,0,MODE_SMA,PRICE_CLOSE,1);    // Fast MA shifted on 1 Period
   mas_p=iMA(NULL,0,SMa,0,MODE_SMA,PRICE_CLOSE,2);  // Slow MA shifted on 2 Period 
   maf_p=iMA(NULL,0,FMa,0,MODE_SMA,PRICE_CLOSE,2);  // Fast MA shifted on 2 Period
   Atr = iATR(NULL,0,pATR,0);
   icc = iCCI(NULL,0,PCCi,PRICE_CLOSE,1);           // CCI shifted on 1 Period
   icc_p = iCCI(NULL,0,PCCi,PRICE_CLOSE,2);         // CCI shifted on 2 Period
 //---- check for open sell order
   if ( (maf<mas && maf_p>=mas_p)&&(icc<0 && icc_p >=0 )) 
     {
      res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,Ask+Atr,0,"",MAGICMA,0,Red);
      if (SndMl == True && res != -1) 
        {
         sHeaderLetter = "Operation SELL by " + Symbol()+"";
         sBodyLetter = "Order Sell by "+ Symbol() + " at " + DoubleToStr(Bid,4)+ ", and set stop/loss at " + DoubleToStr(Ask+Atr,4)+"";
         sndMessage(sHeaderLetter, sBodyLetter);
        }
      return;
     }
//---- check for open buy order
   if ((maf>mas && maf_p<=mas_p)&& (icc > 0 && icc_p <=0 ))  
     {
      res=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,Bid-Atr,0,"",MAGICMA,0,Blue);
      if ( SndMl == True && res != -1)
        { 
         sHeaderLetter = "Operation BUY at " + Symbol()+"";
         sBodyLetter = "Order Buy at "+ Symbol() + " for " + DoubleToStr(Ask,4)+ ", and set stop/loss at " + DoubleToStr(Bid-Atr,4)+"";
         sndMessage(sHeaderLetter, sBodyLetter);
        }
      return;
     }
  }  

void CheckForClose()
  {
   double mas;
   double maf;
   double mas_p;
   double maf_p;
   string sHeaderLetter;
   string sBodyLetter;
   bool CloseOrd;
//---- 
   if(Volume[0]>1) return;
//----  
   mas=iMA(NULL,0,SMa,0,MODE_SMA,PRICE_CLOSE,1);    // Slow MA shifted on 1 Period
   maf=iMA(NULL,0,FMa,0,MODE_SMA,PRICE_CLOSE,1);    // Fast MA shifted on 1 Period
   mas_p=iMA(NULL,0,SMa,0,MODE_SMA,PRICE_CLOSE,2);  // Slow MA shifted on 2 Period
   maf_p=iMA(NULL,0,FMa,0,MODE_SMA,PRICE_CLOSE,2);  // Fast MA shifted on 2 Period
//----
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //----  
      if(OrderType()==OP_BUY)
        {
         if(maf<mas && maf_p>=mas_p) CloseOrd=OrderClose(OrderTicket(),OrderLots(),Bid,3,Lime);
         if ( SndMl == True && CloseOrd == True)
           {
            sHeaderLetter = "Operation CLOSE BUY at" + Symbol()+"";
            sBodyLetter = "Close order Buy at "+ Symbol() + " for " + DoubleToStr(Bid,4)+ ", and finish this Trade";
            sndMessage(sHeaderLetter, sBodyLetter);
           }
         break;
        }
      if(OrderType()==OP_SELL)
        {
         if(maf>mas && maf_p<=mas_p) OrderClose(OrderTicket(),OrderLots(),Ask,3,Lime);
         if ( SndMl == True && CloseOrd == True) 
           {
            sHeaderLetter = "Operation CLOSE SELL at" + Symbol()+"";
            sBodyLetter = "Close order Sell at "+ Symbol() + " for " + DoubleToStr(Ask,4)+ ", and finish this Trade";
            sndMessage(sHeaderLetter, sBodyLetter);
           }
         break;
        }
     }
  }  

//+------------------------------------------------------------------+
//| Optimized Lot Value Calculation                                  |
//+------------------------------------------------------------------+
double LotsOptimized()
  {
   double lot=Lots;
   int    orders=HistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break
//---- select lot size
   lot=NormalizeDouble(AccountFreeMargin()*MaxR/1000.0,1);
//---- calcuulate number of losses orders without a break
   if(DcF>0)
     {
      for(int i=orders-1;i>=0;i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) { Print("Ошибка в истории!"); break; }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL) continue;
         //----
         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++;
        }
      if(losses>1) lot=NormalizeDouble(lot-lot*losses/DcF,1);
     }
//---- return lot size
   if(lot<0.1) lot=0.1;
   return(lot);
  }

//-------------------------------------------------------------------+
// Send e-mail message function                                      |
//-------------------------------------------------------------------+
void sndMessage(string HeaderLetter, string BodyLetter)
  {
   int RetVal;
   SendMail( HeaderLetter, BodyLetter );
   RetVal = GetLastError();
   if (RetVal!= ERR_NO_MQLERROR) Print ("Ошибка, сообщение не отправлено: ", ErrorDescription(RetVal));
  }
//+------------------------------------------------------------------+
//| Expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//---- 
   if(Bars<25 || IsTradeAllowed()==false) return;
//---- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();
   else                                    CheckForClose();
//----
   return(0);
  }
//+------------------------------------------------------------------+