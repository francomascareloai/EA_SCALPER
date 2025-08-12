//+-----------------------------------------+
//|GH.mq4   WPR for Multi Pair              |
//|Copyright © 2005, Gary Hensley           |
//+-----------------------------------------+
//
//		Modifications                                                         
//		-------------                                                       
//		DATE       	MOD #    	DESCRIPTION                		        
//		---------- 	-------- 	---------------------------------------------------------------
//		01 Jul 2005 1   		   GaryH: Converted Original M3 version of MultiPairWPR script.

#property copyright "WPR for Multi Pair, Copyright © 2005, Gary Hensley"
//#property link      "http://www.metaquotes.net/"

#define MAGICMA  20050610

//---- input parameters
extern int       UsePct=0;
extern int       MaxLots=100;

//---- global variables
int bsi=0;
int dir=0;
int vTrig=0;
int openorders=0;
string pair;
double vSL=0,vTP=0;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   pair = Symbol();
   return(0);
  } 

//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Calculate open positions                                         |
//+------------------------------------------------------------------+
int GetCurrentOrders()
  {
  //---- calc open OrderSelect
   openorders=0;
   dir=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      //if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
      if(OrderSymbol()==Symbol())
      {
        openorders+=1;
        if(OrderType()==OP_BUY) dir=1;
        if(OrderType()==OP_SELL) dir=-1;
      }  
   }
}

//+------------------------------------------------------------------+
//| Calculate Lot Sizes                                              |
//+------------------------------------------------------------------+
int LotCalc(double Risk)
  {
   int vLots=0;
   if (UsePct >0 && Risk>0) vLots=MathFloor(AccountBalance()*(UsePct/100)/((Risk/MarketInfo (Symbol(), MODE_POINT))*10));
   if (UsePct >0 && Risk==0)  vLots = MathFloor(AccountBalance()*(UsePct/100)/1000);
   if (vLots>MaxLots) vLots=MaxLots;
   if (vLots<1) vLots=1;
   return(vLots);
}

//+------------------------------------------------------------------+
//| Close Open Position                                              |
//+------------------------------------------------------------------+
int CloseTrade()
  { 
  for(int i=0;i<OrdersTotal();i++)
    {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      //if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      if(OrderSymbol()==Symbol())
      {
        if(OrderType()==OP_BUY) OrderClose(OrderTicket(),OrderLots(),Bid,3,White);
        if(OrderType()==OP_SELL) OrderClose(OrderTicket(),OrderLots(),Ask,3,White);
      }  
  }
}

//+------------------------------------------------------------------+
//| Open Trade Position                                              |
//+------------------------------------------------------------------+
int OpenTrade()
  {
   int vLots=LotCalc(0);
   if (bsi>0) OrderSend(Symbol(),OP_BUY,vLots,Ask,3,0,0,0,0,Blue);
   if (bsi<0) OrderSend(Symbol(),OP_SELL,vLots,Bid,3,0,0,0,0,Red);
}

//+------------------------------------------------------------------+
//| Buy/Sell Indicator                                               |
//+------------------------------------------------------------------+
int CalcBSI()
  {
  //---- calc current indicators
  int GU_Trig=1,EU_Trig=1,UC_Trig=1,UJ_Trig=1;
  if (iWPR("GBPUSD",0,14,0)<-50) GU_Trig=-1;
  if (iWPR("EURUSD",0,14,0)<-50) EU_Trig=-1;
  if (iWPR("USDCHF",0,14,0)<-50) UC_Trig=-1;
  if (iWPR("USDJPY",0,14,0)<-50) UJ_Trig=-1;
  vTrig=GU_Trig+EU_Trig-UC_Trig-UJ_Trig;

  bsi=0;
  if (vTrig>2) bsi=1;
  if (vTrig<-2) bsi=-1;
  if (pair>"USD") bsi=bsi*(-1);

}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
  GetCurrentOrders();
  CalcBSI();
  Comment("Dir: ",dir,"\nBSI: ",bsi,"\nTrig: ",vTrig,);
   
  //---- exit trades
  if (openorders!=0) {
     if ((bsi>0) && (dir<0)) CloseTrade();
     if ((bsi<0) && (dir>0)) CloseTrade();
  }   
  //---- open trades
  else {
   if (bsi!=0) OpenTrade();
  }   
}