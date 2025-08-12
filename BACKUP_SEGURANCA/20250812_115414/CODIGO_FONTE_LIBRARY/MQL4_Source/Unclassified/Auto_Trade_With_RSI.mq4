//+------------------------------------------------------------------+
//|                                          Auto Trade With RSI.mq4 |
//|                                  Copyright 2015, Khurram Mustafa |
//|                             https://www.mql5.com/en/users/kc1981 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Khurram Mustafa"
#property link      "https://www.mql5.com/en/users/kc1981"
#property version   "1.00"
#property strict

input string Program="Auto Trade With RSI";
input bool   OpenBUY=True;
input bool   OpenSELL=True;
input int    RSIperiod=14;
input double ManualLots=0.2;
input bool   AutoLot=True;
input double Risk=5;
input double StopLoss=0;
input double TakeProfit=100;
input bool   CloseBySignal=False;
input double TrailingStop=0;
input int    Slippage=10;
input int    MagicNumber=786;
//---
int OrderBuy,OrderSell;
int ticket;
int LotDigits;
double Trail,iTrailingStop;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   double stoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   OrderBuy=0;
   OrderSell=0;
   for(int cnt=0; cnt<OrdersTotal(); cnt++)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderComment()==Program)
           {
            if(OrderType()==OP_BUY) OrderBuy++;
            if(OrderType()==OP_SELL) OrderSell++;
            if(TrailingStop>0)
              {
               iTrailingStop=TrailingStop;
               if(TrailingStop<stoplevel) iTrailingStop=stoplevel;
               Trail=iTrailingStop*Point;
               double tsbuy=NormalizeDouble(Bid-Trail,Digits);
               double tssell=NormalizeDouble(Ask+Trail,Digits);
               if(OrderType()==OP_BUY && Bid-OrderOpenPrice()>Trail && Bid-OrderStopLoss()>Trail)
                 {
                  ticket=OrderModify(OrderTicket(),OrderOpenPrice(),tsbuy,OrderTakeProfit(),0,Blue);
                 }
               if(OrderType()==OP_SELL && OrderOpenPrice()-Ask>Trail && (OrderStopLoss()-Ask>Trail || OrderStopLoss()==0))
                 {
                  ticket=OrderModify(OrderTicket(),OrderOpenPrice(),tssell,OrderTakeProfit(),0,Blue);
                 }
              }
           }
     }
   double rsi0=iRSI(Symbol(),0,RSIperiod,PRICE_CLOSE,0);
   double rsi1=iRSI(Symbol(),0,RSIperiod,PRICE_CLOSE,1);
   double rsi2=iRSI(Symbol(),0,RSIperiod,PRICE_CLOSE,2);
   double rsi3=iRSI(Symbol(),0,RSIperiod,PRICE_CLOSE,3);
   double rsi4=iRSI(Symbol(),0,RSIperiod,PRICE_CLOSE,4);
   double rsi5=iRSI(Symbol(),0,RSIperiod,PRICE_CLOSE,5);
   double rsi6=iRSI(Symbol(),0,RSIperiod,PRICE_CLOSE,6);
   double rsi7=iRSI(Symbol(),0,RSIperiod,PRICE_CLOSE,7);
   double rsi8=iRSI(Symbol(),0,RSIperiod,PRICE_CLOSE,8);
   double rsi9=iRSI(Symbol(),0,RSIperiod,PRICE_CLOSE,9);
   double rsi10=iRSI(Symbol(),0,RSIperiod,PRICE_CLOSE,10);
   double rsi11=iRSI(Symbol(),0,RSIperiod,PRICE_CLOSE,11);
   double rsi12=iRSI(Symbol(),0,RSIperiod,PRICE_CLOSE,12);
   double rsi13=iRSI(Symbol(),0,RSIperiod,PRICE_CLOSE,13);
   double rsi14=iRSI(Symbol(),0,RSIperiod,PRICE_CLOSE,14);
   double rsi15=iRSI(Symbol(),0,RSIperiod,PRICE_CLOSE,15);
   double rsi16=iRSI(Symbol(),0,RSIperiod,PRICE_CLOSE,16);
   double rsi17=iRSI(Symbol(),0,RSIperiod,PRICE_CLOSE,17);
   double rsi18=iRSI(Symbol(),0,RSIperiod,PRICE_CLOSE,18);
   double rsi19=iRSI(Symbol(),0,RSIperiod,PRICE_CLOSE,19);
   double rsi20=iRSI(Symbol(),0,RSIperiod,PRICE_CLOSE,20);
   double Tot_RSI=(rsi0+rsi1+rsi2+rsi3+rsi4+rsi5+rsi6
                   +rsi7+rsi8+rsi9+rsi10+rsi11+rsi12
                   +rsi13+rsi14+rsi15+rsi16+rsi17+rsi18+rsi19+rsi20)
   /21;
   if(OpenSELL)
     {
      if(OrderSell<1 && OrderBuy==0 && Tot_RSI<45)
        {
         OPSELL();
        }
     }
   if(OpenBUY)
     {
      if(OrderBuy<1 && OrderSell==0 && Tot_RSI>55)
        {
         OPBUY();
        }
     }
//--- Close By Signal
   if(CloseBySignal)
     {
      if(OrderSell>0 && Tot_RSI>52)
        {
            CloseSell();   
        }
      if(OrderBuy>0 && Tot_RSI<47)
        {
            CloseBuy();   
        }
     }
//---
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OPBUY()
  {
   double StopLossLevel;
   double TakeProfitLevel;
   if(StopLoss>0) StopLossLevel=Bid-StopLoss*Point; else StopLossLevel=0.0;
   if(TakeProfit>0) TakeProfitLevel=Ask+TakeProfit*Point; else TakeProfitLevel=0.0;

   ticket=OrderSend(Symbol(),OP_BUY,LOT(),Ask,Slippage,StopLossLevel,TakeProfitLevel,Program,MagicNumber,0,DodgerBlue);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OPSELL()
  {
   double StopLossLevel;
   double TakeProfitLevel;
   if(StopLoss>0) StopLossLevel=Ask+StopLoss*Point; else StopLossLevel=0.0;
   if(TakeProfit>0) TakeProfitLevel=Bid-TakeProfit*Point; else TakeProfitLevel=0.0;
//---
   ticket=OrderSend(Symbol(),OP_SELL,LOT(),Bid,Slippage,StopLossLevel,TakeProfitLevel,Program,MagicNumber,0,DeepPink);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseSell()
  {
   int  total=OrdersTotal();
   for(int y=OrdersTotal()-1; y>=0; y--)
     {
      if(OrderSelect(y,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderType()==OP_SELL && OrderMagicNumber()==MagicNumber)
           {
            ticket=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),5,Black);
           }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseBuy()
  {
   int  total=OrdersTotal();
   for(int y=OrdersTotal()-1; y>=0; y--)
     {
      if(OrderSelect(y,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber()==MagicNumber)
           {
            ticket=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),5,Black);
           }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LOT()
  {
   double lotsi;
   double ilot_max =MarketInfo(Symbol(),MODE_MAXLOT);
   double ilot_min =MarketInfo(Symbol(),MODE_MINLOT);
   double tick=MarketInfo(Symbol(),MODE_TICKVALUE);
//---
   double  myAccount=AccountBalance();
//---
   if(ilot_min==0.01) LotDigits=2;
   if(ilot_min==0.1) LotDigits=1;
   if(ilot_min==1) LotDigits=0;
//---
   if(AutoLot)
     {
      lotsi=NormalizeDouble((myAccount*Risk)/20000,LotDigits);
        } else { lotsi=ManualLots;
     }
//---
   if(lotsi>=ilot_max) { lotsi=ilot_max; }
//---
   return(lotsi);
  }
//+------------------------------------------------------------------+
