//+------------------------------------------------------------------+
//|                                        TrueScalperProfitLock.mq4 |
//|         Copyright © 2005, International Federation of Red Cross. |
//|                                             http://www.ifrc.org/ |
//|                                         Please donate some pips  |
//+------------------------------------------------------------------+
//+-----------------------------------------------------------------------------------------+
//|  Modifications                                                                          |
//|  -------------                                                                          |
//|  1)  Jacob Yego and Ron Thompson: Original version                                      |
//|                                                                                         |
//|  2)  Reworked by Roger. This MT4 version is now identical to                            |
//|                    Roger's earlier MT3 version TrueScalperProfitLock.mql.               |
//|                    Both these versions now include optional RSI validation, optional    |
//|                    Abandon method, MoneyManagement and ProfitLock system.               |
//|                                                                                         |
//| Original Theory of operation (See TrueScalperProfitLock.mql MT3 version for more UPDATED|
//| and DETAILED descriptions)                                                              |
//+-----------------------------------------------------------------------------------------+
#property copyright "Copyright © 2005, International Federation of Red Cross."
#property link      "http://www.ifrc.org/"
// generic user input
extern double Lots=1.0;
extern int    TakeProfit=44;
extern int    StopLoss=90;
extern bool   RSIMethodA=false;
extern bool   RSIMethodB=true;
extern int    RSIValue=50;
extern bool   AbandonMethodA=true;
extern bool   AbandonMethodB=false;
extern int    Abandon=101;
extern bool   MoneyManagement=true;
extern int    Risk=2;
extern int    Slippage=3;
extern bool   UseProfitLock=true;
extern int    BreakEvenTrigger=25;
extern int    BreakEven=3;
extern bool   LiveTrading=false;
extern bool   AccountIsMini=false;
extern int    maxTradesPerPair=1;
extern int    MagicNumber=5432;
//----
double lotMM;
bool BuySignal=false;
bool SetBuy=false;
bool SellSignal=false;
bool SetSell=false;
// Bar handling
datetime bartime=0;
int      bartick=0;
int      TradeBars=0;
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
   if (UseProfitLock) ProfitLockStop();
   if (AbandonMethodA || AbandonMethodB)
     {
      RunAbandonCheck();
      RunAbandonMethods();
     }
   if (!SetLotsMM()) return(0);
   RunOrderTriggerCalculations();
   RunPairSpesificSettings();
   RunNewOrderManagement();
//----
   return(0);
  }
//  SetLotsMM - By Robert Cochran http://autoforex.biz
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SetLotsMM()
  {
   double MarginCutoff;
//----
   if(!AccountIsMini) MarginCutoff=1000;
   if(AccountIsMini) MarginCutoff=100;
   if(AccountFreeMargin() < MarginCutoff) return(false);
   if(MoneyManagement)
     {
      lotMM=MathCeil(AccountBalance() * Risk/10000)/10;
//----
      if(lotMM < 0.1) lotMM=Lots;
      if(lotMM > 1.0) lotMM=MathCeil(lotMM);
      // Enforce lot size boundaries
      if(LiveTrading)
        {
         if(AccountIsMini)               lotMM=lotMM * 10;
         if(!AccountIsMini && lotMM < 1.0) lotMM=1.0;
        }
      if(lotMM > 100) lotMM=100;
     }
   else
     {
      lotMM=Lots; // Change MoneyManagement to 0 if you want the Lots parameter to be in effect
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|  RunOrderTriggerCalculations                                     |
//+------------------------------------------------------------------+
bool RunOrderTriggerCalculations()
  {
   bool    RSIPOS=false;
   bool    RSINEG=false;
   // 3-period moving average on Bar[1]
   double bullMA3=iMA(Symbol(),0,3,0,MODE_EMA,PRICE_CLOSE,1);
   // 7-period moving average on Bar[1]
   double bearMA7=iMA(Symbol(),0,7,0,MODE_EMA,PRICE_CLOSE,1);
   // 2-period moving average on Bar[2]
   double RSI=iRSI(Symbol(),0,2,PRICE_CLOSE,2);
   double RSI2=iRSI(Symbol(),0,2,PRICE_CLOSE,1);
   // Determine what polarity RSI is in
   if (RSIMethodA)
     {
      if(RSI>RSIValue && RSI2<RSIValue)
        {
         RSIPOS=true;
         RSINEG=false;
        }
      else RSIPOS=false;
      if(RSI<RSIValue && RSI2>RSIValue)
        {
         RSIPOS=false;
         RSINEG=true;
        }
      else RSINEG=false;
     }
   if (RSIMethodB)
     {
      if(RSI>RSIValue)
        {
         RSIPOS=true;
         RSINEG=false;
        }
      if(RSI<RSIValue)
        {
         RSIPOS=false;
         RSINEG=true;
        }
     }
   if ((bullMA3 > (bearMA7+Point)) && RSINEG)
     {
      BuySignal=true;
     }
   else BuySignal=false;
   if ((bullMA3 < (bearMA7-Point)) && RSIPOS)
     {
      SellSignal=true;
     }
   else SellSignal=false;
   return(true);
  }
// OpenOrdersBySymbolAndComment
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OpenOrdersForThisEA()
  {
   int ofts=0;
   for(int x=0;x<OrdersTotal();x++)
     {
      OrderSelect(x, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
        {
         ofts++;
        }
     }
   return(ofts);
  }
// PROFIT LOCK - By Robert Cochran - http://autoforex.biz
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ProfitLockStop()
  {
   if(OpenOrdersForThisEA() > 0 )
     {
        for( int i=0; i < OrdersTotal(); i++){
         OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         //--- LONG TRADES
         if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderMagicNumber()== MagicNumber)
           {
            if (Bid>=OrderOpenPrice() + BreakEvenTrigger*Point &&
                OrderOpenPrice() > OrderStopLoss())
              {
               OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + BreakEven * Point, OrderTakeProfit(), Green);
              }
           }
         //--- SHORT TRADES
         if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
           {
            if (Ask <=OrderOpenPrice() - BreakEvenTrigger*Point &&
                OrderOpenPrice() < OrderStopLoss())
              {
               OrderModify(OrderTicket(), OrderOpenPrice(),OrderOpenPrice() - BreakEven * Point, OrderTakeProfit(), Blue);
              }
           }
        }
     }
  }
// ABANDON CHECK
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RunAbandonCheck()
  {
   if(OpenOrdersForThisEA() > 0 )
     {
      if (TradeBars==0 && bartick==0)
        {
         for(int i=0; i < OrdersTotal(); i++)
           {
            if (OrderSymbol()==Symbol())
              {
               TradeBars=MathFloor(CurTime() - OrderOpenTime())/60/Period();
               bartime=Time[0];
               bartick=TradeBars;
              }
           }
        }
      if(bartime!=Time[0])
        {
         bartime=Time[0];
         bartick++;
        }
     }
   return(true);
  }
// RunAbandonMethods
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RunAbandonMethods()
  {
   if(OpenOrdersForThisEA() > 0 )
     {
      for(int i=0; i < OrdersTotal(); i++)
        {
         OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         if (AbandonMethodA && bartick==Abandon)//Force "HEDGE" after abandon
           {
            // LONG TRADES
            if (OrderType()==OP_BUY && OrderSymbol()==Symbol() &&
            OrderMagicNumber()==MagicNumber)
              {
               OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Blue);
               SetSell=true;
               continue;
              }
            // SHORT TRADES
            if (OrderType()==OP_SELL && OrderSymbol()==Symbol() &&
            OrderMagicNumber()==MagicNumber)
              {
               OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Blue);
               SetBuy=true;
               continue;
              }
           }
         if (AbandonMethodB && bartick==Abandon)//Indicators decide direction after abandon
           {
            // LONG TRADES
            if (OrderType()==OP_BUY && OrderSymbol()==Symbol() &&
            OrderMagicNumber()==MagicNumber)
              {
               OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,White);
               continue;
              }
            // SHORT TRADES
            if (OrderType()==OP_SELL && OrderSymbol()==Symbol() &&
            OrderMagicNumber()==MagicNumber)
              {
               OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,White);
               continue;
              }
           }
        }
     }
   return(true);
  }
// RunPairSpesificSettings
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RunPairSpesificSettings()
  {
   // set up the symbol optimizations
   if (Symbol()=="GBPUSD")
     {
      TakeProfit=55; StopLoss=100; Abandon=69;
     }
   return(true);
  }
// RunNewOrderManagement
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RunNewOrderManagement()
  {
   double  TP,SL;
//----
   if(OpenOrdersForThisEA() < maxTradesPerPair )
     {
      //ENTRY Ask(buy, long) 
      if (BuySignal || SetBuy)
        {
         SL=Ask - StopLoss*Point;
         TP=Ask + TakeProfit*Point;
         OrderSend(Symbol(),OP_BUY,lotMM,Ask,Slippage,SL,TP,"TS-ProfitLock - "+Symbol()+" - Long",MagicNumber,0,White);
         bartick=0;
         if (SetBuy) SetBuy=false;
         return(true);
        }
      //ENTRY Bid (sell, short)
      if (SellSignal || SetSell)
        {
         SL=Bid + StopLoss*Point;
         TP=Bid - TakeProfit*Point;
         OrderSend(Symbol(),OP_SELL,lotMM,Bid,Slippage,SL,TP,"TS-ProfitLock - "+Symbol()+" - Short",MagicNumber,0,Red);
         bartick=0;
         if (SetSell) SetSell=false;
         return(true);
        }
     }
   return(true);
  }
//+------------------------------------------------------------------+