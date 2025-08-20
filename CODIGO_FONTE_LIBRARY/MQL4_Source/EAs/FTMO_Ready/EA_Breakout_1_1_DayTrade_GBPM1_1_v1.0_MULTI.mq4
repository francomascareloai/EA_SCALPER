//+------------------------------------------------------------------+
//|                                                      version.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+

#property copyright "http://www.strategybuilderfx.com/showpost.php?p=166491&postcount=5807"

//---- input parameters
extern double    LotsIfNoMM=1;
extern bool      UseMM=false;
extern double    MMRiskFactor=0.2;
extern double    MMBalanceExcludeAmt=0;
extern double    MMBalanceShareDivisor=1;
extern int       TradeOpenTime=9;
extern int       LookBackHrs=1;
extern int       PipsAddedToRange=5;
extern int       StopLossMax=50;
extern int       BreakEvenPlus5At=30;
extern int       TakeProfit=999;
extern int       blTakeProfitOverrideMatchSL=0;
int       blExitAtDailyBarRangeIfInProfit=0; //Left experimental code in, but results no good and needs to be made to work on both closed bars and every tick
int       DailyBarRange=120;
extern int       blCloseAtEOD=1;
extern int       EOD=17;
extern int       blOneTradeOnly=0;
extern int       ClosedBarLowTrailAfterBE=0;
extern int       Multiplier15mATR3TrailAfterBE=0;
extern int       MultiplierH1ATR4TrailAfterBE=0;
extern int       RangeMax=0;
extern int       blIfRangeMaxStillOpenFarTrade=1;
extern int       OrderHoursExpiry=0;
extern int       blCancelPendingAtStartTime=1;
extern bool      AdjustDSTwhenBacktesting?=false;
extern bool      Skip1stFriOfMonthIfBacktesting?=false;
int       blTakePartialProfitAtBEtime=0;  //The code is not reliable for anything but backtest
extern int       MagicNum=253661;
extern string    TradeComment="BO_DayTrade";


//--- MM calculation
double CalculateMMLot()
  {
   double lot_min =MarketInfo(Symbol(),MODE_MINLOT);
   double lot_max =MarketInfo(Symbol(),MODE_MAXLOT);
   double lot_step=MarketInfo(Symbol(),MODE_LOTSTEP);
   double lot;
//--- check data
   if(lot_min<0 || lot_max<=0.0 || lot_step<=0.0) 
     {
      Print("CalculateMMLot: invalid MarketInfo() results [",lot_min,",",lot_max,",",lot_step,"]");
      return(0);
     }
   if(AccountLeverage()<=0)
     {
      Print("CalculateMMLot: invalid AccountLeverage() [",AccountLeverage(),"]");
      return(0);
     }
//--- basic formula
   lot=NormalizeDouble((AccountBalance()-MMBalanceExcludeAmt)/MMBalanceShareDivisor*MMRiskFactor/AccountLeverage()/10.0,2);
//--- additional calculation
//   ...
//--- check min, max and step
   lot=NormalizeDouble(lot/lot_step,0)*lot_step;
   if(lot<lot_min) lot=lot_min;
   if(lot>lot_max) lot=lot_max;
//---
   return(lot);
  }



//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+

int start()
  {
   //---- 
   int i,Ticket,LastOrderTime,StartTime,EODTime,CloseUnhitOrdersTime,Bought=0,Sold=0,PeriodToReference=0,ErrTemp=0;
   int PendingTicket,OpenTicket,Last15mATRTrailBarTime,LastH1ATRTrailBarTime;

   double Lots,EntryLong,EntryShort,SLLong,SLShort,TPLong,TPShort,CurrBarTime,LookbackBars,ATRtrail;
   
   if ( ! IsTesting() ) Comment(" Time ", StringSubstr(TimeToStr(CurTime()),StringLen(TimeToStr(CurTime()))-1-5),"    Tick no. ", iVolume(NULL,0,0));
   
   
   if (UseMM) Lots=CalculateMMLot(); else Lots=LotsIfNoMM;

   
   /*
   if (IsTesting()) PeriodToReference=0; 
      else PeriodToReference=PERIOD_M1;
   */  
   PeriodToReference=0; //I.e. whatever timeframe the chart/backtest is in
      
   CurrBarTime=iTime(NULL,PeriodToReference,0);

   //Count time
   //if(TimeHour(CurrBarTime)>=TradeOpenTime-1)
   if(IsTesting() && AdjustDSTwhenBacktesting? && TimeMonth(CurrBarTime)>=4 && TimeMonth(CurrBarTime)<=10)
      {
      StartTime= StrToTime(TradeOpenTime-1+":00");
      CloseUnhitOrdersTime= StrToTime(TradeOpenTime+OrderHoursExpiry-1+":00");
      if(DayOfWeek()==5)   EODTime  = MathMin(StrToTime("22:00"),StrToTime(EOD-1+":00"));
         else              EODTime  = StrToTime(EOD-1+":00");
      }
      else
      {
      StartTime= StrToTime(TradeOpenTime+":00");
      CloseUnhitOrdersTime= StrToTime(TradeOpenTime+OrderHoursExpiry+":00");
      if(DayOfWeek()==5)   EODTime  = MathMin(StrToTime("22:00"),StrToTime(EOD+":00"));
         else              EODTime  = StrToTime(EOD+":00");
      }

   
   
   
   if(blCancelPendingAtStartTime == 1 && CurTime()> StartTime-15*60 && CurrBarTime<StartTime)
      {
      for (i=0;i<OrdersTotal();i++)
         {
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderMagicNumber()==MagicNum && OrderSymbol()==Symbol() && (OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP)) OrderDelete(OrderTicket());
         }
      }


   
   
   //Set orders
   //The first criteria tests for a bug where StrToTime returns the previous date until 3:00 AM.
   if(TimeDay(StrToTime(TimeHour(CurrBarTime)+":00")) == TimeDay(CurrBarTime) && CurrBarTime>= StartTime && StrToTime(TimeHour(CurrBarTime)+":00")<StartTime+60*60)
      {
      //Determine range

      LookbackBars=0;
      
      for (i=0;i<Bars;i++)
         {
         if (iTime(NULL,PeriodToReference,i) < StrToTime(TimeHour(CurrBarTime)+":00")-(LookBackHrs*60*60)) 
            {
            LookbackBars=i+1;
            break;
            }
         }
      
      if (LookbackBars==0) return(0); //exit if not enough bars on current timeframe

      EntryLong   =iHigh(NULL,PeriodToReference,Highest(NULL,PeriodToReference,MODE_HIGH,LookbackBars,1))+(PipsAddedToRange+MarketInfo(Symbol(),MODE_SPREAD))*Point;
      EntryShort  =iLow (NULL,PeriodToReference,Lowest (NULL,PeriodToReference,MODE_LOW, LookbackBars,1))-PipsAddedToRange*Point;
      
      SLLong      =MathMax(EntryLong-StopLossMax*Point,EntryShort);
      SLShort     =MathMin(EntryShort+StopLossMax*Point,EntryLong);

      if (blTakeProfitOverrideMatchSL==0)
         {
         TPLong      =EntryLong+TakeProfit*Point;
         TPShort     =EntryShort-TakeProfit*Point;
         }
       else
         {
         TPLong      =EntryLong+(EntryLong-SLLong);
         TPShort     =EntryShort-(SLShort-EntryShort);
         }
         
         
      //Check Orders
      for (i=0;i<OrdersTotal();i++)
         {
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderMagicNumber()==MagicNum && OrderSymbol()==Symbol() && (OrderType()==OP_BUYSTOP || OrderType()==OP_BUY)) 
            {
            Bought++;
            //Fix stop if too wide due to slippage
            if (OrderStopLoss()<OrderOpenPrice()-(StopLossMax+2)*Point) OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-StopLossMax*Point,OrderTakeProfit(),OrderExpiration(),Green);
            }
         if(OrderMagicNumber()==MagicNum && OrderSymbol()==Symbol() && (OrderType()==OP_SELLSTOP || OrderType()==OP_SELL)) 
            {
            Sold++;
            //Fix stop if too wide due to slippage
            if (OrderStopLoss()>OrderOpenPrice()+(StopLossMax+2)*Point) OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+StopLossMax*Point,OrderTakeProfit(),OrderExpiration(),Green);
            }
         }
      
      if (RangeMax != 0 && EntryLong-EntryShort>=RangeMax*Point) //So we can filter out large ranges
         { 
         if (blIfRangeMaxStillOpenFarTrade==1) 
            {
            //Ensures that only the trigger furthest from the current price will be set. If price moves back to the other side of the range within the hour, the second trade will also be set.
            if (iClose(NULL,PeriodToReference,1)-EntryShort < EntryLong-iClose(NULL,PeriodToReference,1)) 
               {
               Sold=1;
               //Print("HERE");
               }
              else
               {
               Bought=1;
               }
            }
           else
            {
            // Ensures that no trades will be opened
            Bought=1;
            Sold=1;
            }
         }
      
      if (! (IsTesting() && Skip1stFriOfMonthIfBacktesting? &&  DayOfWeek()==5 && Day()<8)) 
         {
         if(Bought==0 && EntryLong>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point) //no buy order and price not right at the top of the range
            {
            Ticket=OrderSend(Symbol(),OP_BUYSTOP,Lots,EntryLong,3,SLLong,TPLong,TradeComment,MagicNum,0,Green);
            }
         if(Sold==0 && EntryShort<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point) //no sell order and price not right at the bottom of the range
            { 
            Ticket=OrderSend(Symbol(),OP_SELLSTOP,Lots,EntryShort,3,SLShort,TPShort,TradeComment,MagicNum,0,Green);
            }
         }
      }
   
   //Manage opened orders

   if (blOneTradeOnly==1  && CurrBarTime>=StartTime+60*60) //Delete the second pending trade if the other has been hit and new orders are no longer being placed
      {
      OpenTicket=0;
      PendingTicket=0;
      for (i=0;i<OrdersTotal();i++)
         {
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderMagicNumber()==MagicNum && OrderSymbol()==Symbol() && (OrderType()==OP_BUY || OrderType()==OP_SELL)) {OpenTicket=OrderTicket();}
         if(OrderMagicNumber()==MagicNum && OrderSymbol()==Symbol() && (OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP)) {PendingTicket=OrderTicket();}
         }
      if (OpenTicket != 0 && PendingTicket != 0) //This assumes that there will only be two trades set at any given time
         {
         OrderDelete(PendingTicket);
         }   
      }


   for (i=0;i<OrdersTotal();i++)
      {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderHoursExpiry>0 && CurrBarTime>=CloseUnhitOrdersTime)
         {
         if(OrderMagicNumber()==MagicNum && OrderSymbol()==Symbol() && OrderType()==OP_BUYSTOP)  OrderDelete(OrderTicket());
         if(OrderMagicNumber()==MagicNum && OrderSymbol()==Symbol() && OrderType()==OP_SELLSTOP) OrderDelete(OrderTicket());
         }   
      
      if(blCloseAtEOD==1 && CurrBarTime>=EODTime)
         {
         if(OrderMagicNumber()==MagicNum && OrderSymbol()==Symbol() && OrderType()==OP_BUY)      OrderClose(OrderTicket(),OrderLots(),Bid,3,Red);
         if(OrderMagicNumber()==MagicNum && OrderSymbol()==Symbol() && OrderType()==OP_SELL)     OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
         if(OrderMagicNumber()==MagicNum && OrderSymbol()==Symbol() && OrderType()==OP_BUYSTOP)  OrderDelete(OrderTicket());
         if(OrderMagicNumber()==MagicNum && OrderSymbol()==Symbol() && OrderType()==OP_SELLSTOP) OrderDelete(OrderTicket());
         }   
        else 
         {

         //move at BE if profit>BE
         if(BreakEvenPlus5At>0 && OrderMagicNumber()==MagicNum && OrderSymbol()==Symbol() && OrderType()==OP_BUY)
            {
            if(OrderStopLoss()<OrderOpenPrice() && iHigh(NULL,PeriodToReference,1)-OrderOpenPrice() >= BreakEvenPlus5At*Point)
               {
               OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+5*Point,OrderTakeProfit(),0,Green);
               if (blTakePartialProfitAtBEtime==1) OrderClose(OrderTicket(),OrderLots()/2,Bid,3,Green); 
               }   
            }   
         if(BreakEvenPlus5At>0 && OrderMagicNumber()==MagicNum && OrderSymbol()==Symbol() && OrderType()==OP_SELL)
            {
            if(OrderStopLoss()>OrderOpenPrice() && OrderOpenPrice()-(iLow(NULL,PeriodToReference,1)+MarketInfo(Symbol(),MODE_SPREAD)*Point) >= BreakEvenPlus5At*Point)
               {
               OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-5*Point,OrderTakeProfit(),0,Green);
               if (blTakePartialProfitAtBEtime==1) OrderClose(OrderTicket(),OrderLots()/2,Ask,3,Green); 
               }
            }
         
         //If blExitAtDailyBarRangeIfInProfit turned on, exit at daily range if in profit
         if (blExitAtDailyBarRangeIfInProfit==1)
            {
            if(OrderMagicNumber()==MagicNum && OrderSymbol()==Symbol() && OrderType()==OP_BUY)
               {
               if(OrderProfit()>0 && iHigh(Symbol(),PERIOD_D1,0)-iLow(Symbol(),PERIOD_D1,0)>DailyBarRange*Point)
                  {
                  OrderClose(OrderTicket(),OrderLots(),Bid,3,Red);
                  }   
               }   
            if(OrderMagicNumber()==MagicNum && OrderSymbol()==Symbol() && OrderType()==OP_SELL)
               {
               if(OrderProfit()>0 && iHigh(Symbol(),PERIOD_D1,0)-iLow(Symbol(),PERIOD_D1,0)>DailyBarRange*Point)
                  {
                  OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
                  }
               }
            }

         
         }
      }
   
   if (ClosedBarLowTrailAfterBE>0) 
      {  
      for (i=0;i<OrdersTotal();i++)
         {
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderMagicNumber()==MagicNum && OrderSymbol()==Symbol() && OrderType()==OP_BUY)
            {
            if(OrderStopLoss()>=OrderOpenPrice() && iLow(NULL,PeriodToReference,1)-OrderStopLoss() > ClosedBarLowTrailAfterBE*Point)
               {
               OrderModify(OrderTicket(),OrderOpenPrice(),iLow(NULL,PeriodToReference,1)-ClosedBarLowTrailAfterBE*Point,OrderTakeProfit(),0,Green);
               }   
            }   
         if(OrderMagicNumber()==MagicNum && OrderSymbol()==Symbol() && OrderType()==OP_SELL)
            {
            if(OrderStopLoss()<=OrderOpenPrice() && OrderStopLoss()-((iHigh(NULL,PeriodToReference,1)+MarketInfo(Symbol(),MODE_SPREAD)*Point)) > ClosedBarLowTrailAfterBE*Point)
               {
               OrderModify(OrderTicket(),OrderOpenPrice(),((iHigh(NULL,PeriodToReference,1)+MarketInfo(Symbol(),MODE_SPREAD)*Point))+ClosedBarLowTrailAfterBE*Point,OrderTakeProfit(),0,Green);
               }
            }
         }
      }
   
   if (Multiplier15mATR3TrailAfterBE>0 && iTime(Symbol(),PERIOD_M15,0)> Last15mATRTrailBarTime) 
      {
      Last15mATRTrailBarTime=iTime(Symbol(),PERIOD_M15,0);
      for (i=0;i<OrdersTotal();i++)
         {
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderMagicNumber()==MagicNum && OrderSymbol()==Symbol() && OrderType()==OP_BUY)
            {
            
            if (Digits==4) 
               {
               ATRtrail=iATR(Symbol(),PERIOD_M15,3,1)*Multiplier15mATR3TrailAfterBE;
               }
             else
               {
               ATRtrail=NormalizeDouble(iATR(Symbol(),PERIOD_M15,3,1),Digits)*Multiplier15mATR3TrailAfterBE;
               }
            
            if(OrderStopLoss()>=OrderOpenPrice() && iOpen(NULL,PeriodToReference,1)-OrderStopLoss() > ATRtrail)
               {
               OrderModify(OrderTicket(),OrderOpenPrice(),iOpen(NULL,PeriodToReference,1)-ATRtrail,OrderTakeProfit(),0,Green);
               }   
            }   
         if(OrderMagicNumber()==MagicNum && OrderSymbol()==Symbol() && OrderType()==OP_SELL)
            {
            
            if (Digits==4) 
               {
               ATRtrail=iATR(Symbol(),PERIOD_M15,3,1)*Multiplier15mATR3TrailAfterBE;
               }
             else
               {
               ATRtrail=NormalizeDouble(iATR(Symbol(),PERIOD_M15,3,1),Digits)*Multiplier15mATR3TrailAfterBE;
               }
            
            if(OrderStopLoss()<=OrderOpenPrice() && OrderStopLoss()-((iOpen(NULL,PeriodToReference,1)+MarketInfo(Symbol(),MODE_SPREAD)*Point)) > ATRtrail)
               {
               OrderModify(OrderTicket(),OrderOpenPrice(),((iOpen(NULL,PeriodToReference,1)+MarketInfo(Symbol(),MODE_SPREAD)*Point))+ATRtrail,OrderTakeProfit(),0,Green);
               }
            }
         }
      }
   
   if (MultiplierH1ATR4TrailAfterBE>0 && iTime(Symbol(),PERIOD_H1,0)> LastH1ATRTrailBarTime) 
      {
      LastH1ATRTrailBarTime=iTime(Symbol(),PERIOD_H1,0);
      for (i=0;i<OrdersTotal();i++)
         {
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderMagicNumber()==MagicNum && OrderSymbol()==Symbol() && OrderType()==OP_BUY)
            {
            
            if (Digits==4) 
               {
               ATRtrail=iATR(Symbol(),PERIOD_H1,4,1)*MultiplierH1ATR4TrailAfterBE;
               }
             else
               {
               ATRtrail=NormalizeDouble(iATR(Symbol(),PERIOD_H1,4,1),Digits)*MultiplierH1ATR4TrailAfterBE;
               }
            
            if(OrderStopLoss()>=OrderOpenPrice() && iOpen(NULL,PeriodToReference,1)-OrderStopLoss() > ATRtrail)
               {
               OrderModify(OrderTicket(),OrderOpenPrice(),iOpen(NULL,PeriodToReference,1)-ATRtrail,OrderTakeProfit(),0,Green);
               }   
            }   
         if(OrderMagicNumber()==MagicNum && OrderSymbol()==Symbol() && OrderType()==OP_SELL)
            {
            
            if (Digits==4) 
               {
               ATRtrail=iATR(Symbol(),PERIOD_H1,4,1)*MultiplierH1ATR4TrailAfterBE;
               }
             else
               {
               ATRtrail=NormalizeDouble(iATR(Symbol(),PERIOD_H1,4,1),Digits)*MultiplierH1ATR4TrailAfterBE;
               }
            
            if(OrderStopLoss()<=OrderOpenPrice() && OrderStopLoss()-((iOpen(NULL,PeriodToReference,1)+MarketInfo(Symbol(),MODE_SPREAD)*Point)) > ATRtrail)
               {
               OrderModify(OrderTicket(),OrderOpenPrice(),((iOpen(NULL,PeriodToReference,1)+MarketInfo(Symbol(),MODE_SPREAD)*Point))+ATRtrail,OrderTakeProfit(),0,Green);
               }
            }
         }
      }
   
   return(0);
  }
//+------------------------------------------------------------------+