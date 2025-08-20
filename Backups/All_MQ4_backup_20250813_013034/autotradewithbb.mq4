//+------------------------------------------------------------------+
//|                                                        Forex.mq4 |
//|                                  Copyright 2016, Khurram Mustafa |
//|                             https://www.mql5.com/en/users/kc1981 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Khurram Mustafa"
#property link      "https://www.mql5.com/en/users/kc1981"
#property version   "1.00"
#property strict

input string Program="FOREX";
input bool   OpenBUY=True;
input bool   OpenSELL=True;
input int GMTTrade_Start=12;
input int GMTTrade_Stop=19;
input int BB_Period=50;
input int RSI_Period=6;
input int CCI_Period=6;
input int Stoch_KPeriod=14;
input int Stoch_DPeriod=3;
input int Stoch_Slowing=3;
input double ManualLots=0.2;
input bool   AutoLot=True;
input double Risk=5;
input double StopLoss=1000;
input double TakeProfit=0;
input double TrailingStop=20;
input int    Slippage=5;
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
//----
//----
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
   double BB504L=iBands(Symbol(),0,BB_Period,4.0,0,PRICE_CLOSE,MODE_HIGH,1);
   double BB504H=iBands(Symbol(),0,BB_Period,4.0,0,PRICE_CLOSE,MODE_LOW,1);
   double RSILast=iRSI(Symbol(),0,RSI_Period,PRICE_CLOSE,1);
   double StoLast=iStochastic(Symbol(),0,Stoch_KPeriod,Stoch_DPeriod,Stoch_Slowing,MODE_SMA,STO_CLOSECLOSE,MODE_CLOSE,1);
   double CCILast=iCCI(Symbol(),0,CCI_Period,PRICE_CLOSE,1);
   double Barlast=iClose(Symbol(),0,1);

   if(OpenSELL)
     {
      if((Hour()>GMTTrade_Start) && (Hour()<GMTTrade_Stop))
        {
         if(OrderSell<1)
           {
            if(Barlast>BB504H && RSILast>75 && StoLast>85)
              {
               OPSELL();
              }
           }
        }
     }
   if(OpenBUY)
     {
      if((Hour()>GMTTrade_Start) && (Hour()<GMTTrade_Stop))
        {
         if(OrderBuy<1)
           {
            if(Barlast<BB504L && RSILast<25 && StoLast<155)
              {
               OPBUY();
              }
           }
        }
     }
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
