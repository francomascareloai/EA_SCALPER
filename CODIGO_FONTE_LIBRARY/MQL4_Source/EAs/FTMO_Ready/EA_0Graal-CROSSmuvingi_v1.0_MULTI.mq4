//+------------------------------------------------------------------+
//|                                            Graal-FxProg_team.mq4 |
//|                                                             Rosh |
//|               http://www.investo.ru/forum/viewtopic.php?t=124777 |
//+------------------------------------------------------------------+
#property copyright "Rosh"
#property link      "http://www.investo.ru/forum/viewtopic.php?t=124777"

//---- input parameters
extern int       FastPeriod=13;
extern int       SlowPeriod=34;
extern int       MomPeriod=14;
extern double    MomFilter=0.1;
extern double    PercentCapital=10.0;
extern double    Lots=0.1;
extern int       Slippage=3;
extern int       StopLoss=20;
extern int       TakeProfit=200;
extern int       ExpertMagicNumber=2002;
int myBars;
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
  int cnt;
  double curFastMA=iMA(NULL,0,FastPeriod,0,MODE_EMA,PRICE_CLOSE,1);
  double curSlowMA=iMA(NULL,0,SlowPeriod,0,MODE_EMA,PRICE_OPEN,1);
  double prevFastMA=iMA(NULL,0,FastPeriod,0,MODE_EMA,PRICE_CLOSE,2);
  double prevSlowMA=iMA(NULL,0,SlowPeriod,0,MODE_EMA,PRICE_OPEN,2);
  double curMom=iMomentum(NULL,0,MomPeriod,PRICE_CLOSE,1)-100.0;
  double prevMom=iMomentum(NULL,0,MomPeriod,PRICE_CLOSE,2)-100.0;
//----
   if (Bars!=myBars)
      {
      myBars=Bars;
      if (curFastMA>curSlowMA && prevFastMA<prevSlowMA && curMom>MomFilter && curMom>prevMom)
         {
         if (OrdersTotal()>0)
            {
            for (cnt=OrdersTotal()-1;cnt>=0;cnt--)
               {
               OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
               if (OrderType()==OP_SELL) {OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,White);Sleep(30000);}
               }
            }
         OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,0,Ask+TakeProfit*Point,"buy",ExpertMagicNumber,0,Blue);
         }
      if (curFastMA<curSlowMA && prevFastMA>prevSlowMA && curMom<-MomFilter && curMom<prevMom)
         {
         if (OrdersTotal()>0)
            {
            for (cnt=OrdersTotal()-1;cnt>=0;cnt--)
               {
               OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
               if (OrderType()==OP_BUY) {OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,White);Sleep(30000);}
               }
            }
         OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,0,Bid-TakeProfit*Point,"sell",ExpertMagicNumber,0,Red);
         }
      }
//----
   return(0);
  }
//+------------------------------------------------------------------+