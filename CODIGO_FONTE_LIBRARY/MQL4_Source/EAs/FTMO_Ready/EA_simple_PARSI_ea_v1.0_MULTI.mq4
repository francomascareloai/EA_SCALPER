//------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"
#property strict
//------------------------------------------------------------------

extern int        MagicNumber                   = 123456;  // Magic number to use for the EA
extern bool       EcnBroker                     = false;   // Is your broker ECN/STP type of broker?
extern double     LotSize                       = 0.1;     // Lot size to use for trading
extern int        Slippage                      = 3;       // Slipage to use when opening new orders
extern double     StopLoss                      = 100;     // Initial stop loss (in pips)
extern double     TakeProfit                    = 100;     // Initial take profit (in pips)

extern string     dummy1                        = "";      // .
extern string     dummy2                        = "";      // Settings for indicators
extern int        BarToUse                      = 1;       // Bar to test (0, for still opened, 1 for first closed, and so on)
input double      inp_hot_money_sensitivity     = 0.7;   // fast sensitivity
input int         inp_hot_money_period          = 40;    // fast period
input double      inp_hot_money_base            = 30;    // fast level
input double      inp_banker_sensitivity        = 1.5;   // slow sensitivity
input int         inp_banker_period             = 50;    // slow period
input double      inp_banker_base               = 50;    // slow level

extern string     dummy3                        = "";      // . 
extern string     dummy4                        = "";      // General settings
extern bool       DisplayInfo                   = true;    // Dislay info

input uint        StartHour                     =  0; // Start hour
input uint        StartMinute                   =  0; // Start minute
input uint        StartSecond                   =  0; // Start second
input uint        EndHour                       = 24; // Ending hour
input uint        EndMinute                     =  0; // Ending minute
input uint        EndSecond                     =  0; // Ending second

bool dummyResult;
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()   { return(0); }
int deinit() { return(0); }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define _doNothing 0
#define _doBuy     1
#define _doSell    2
int start()
{
   int doWhat = _doNothing;
      double upArrc = iCustom(_Symbol,_Period,"PARSI 1.0",inp_hot_money_sensitivity,inp_hot_money_period,inp_hot_money_base,inp_banker_sensitivity,inp_banker_period,inp_banker_base,0,BarToUse);
      double dnArrc = iCustom(_Symbol,_Period,"PARSI 1.0",inp_hot_money_sensitivity,inp_hot_money_period,inp_hot_money_base,inp_banker_sensitivity,inp_banker_period,inp_banker_base,1,BarToUse);
      double upArrp = iCustom(_Symbol,_Period,"PARSI 1.0",inp_hot_money_sensitivity,inp_hot_money_period,inp_hot_money_base,inp_banker_sensitivity,inp_banker_period,inp_banker_base,0,BarToUse+1);
      double dnArrp = iCustom(_Symbol,_Period,"PARSI 1.0",inp_hot_money_sensitivity,inp_hot_money_period,inp_hot_money_base,inp_banker_sensitivity,inp_banker_period,inp_banker_base,1,BarToUse+1);
      if (upArrc!=EMPTY_VALUE && upArrp==EMPTY_VALUE) doWhat = _doBuy;
      if (dnArrc!=EMPTY_VALUE && dnArrp==EMPTY_VALUE) doWhat = _doSell;
      if (doWhat==_doNothing && !DisplayInfo) return(0);
         
   //
   //
   //
   //
   //
   
   int    openedBuys    = 0;
   int    openedSells   = 0;
   double currentProfit = 0;
   for (int i = OrdersTotal()-1; i>=0; i--)
   {
      if (!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if (OrderSymbol()      != Symbol())            continue;
      if (OrderMagicNumber() != MagicNumber)         continue;

      //
      //
      //
      //
      //
      
      if (DisplayInfo) currentProfit += OrderProfit()+OrderCommission()+OrderSwap();
         
         if (OrderType()==OP_BUY)
            if (doWhat==_doSell)
                  { RefreshRates(); if (!OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,CLR_NONE)) openedBuys++; }
            else  openedBuys++;
         if (OrderType()==OP_SELL)
            if (doWhat==_doBuy)
                  { RefreshRates(); if (!OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,CLR_NONE)) openedSells++; }
            else  openedSells++;            
   }
   if (!checkTimeLimits(StartHour,StartMinute,StartSecond,EndHour,EndMinute,EndSecond,TimeCurrent())) doWhat=_doNothing;
   if (DisplayInfo) Comment("Current profit : "+DoubleToStr(currentProfit,2)+" "+AccountCurrency()); if (doWhat==_doNothing) return(0);

   //
   //
   //
   //
   //

   if (doWhat==_doBuy && openedBuys==0)
      {
         RefreshRates();
         double stopLossBuy   = 0; if (StopLoss>0)   stopLossBuy   = Ask-StopLoss*Point*MathPow(10,Digits%2);
         double takeProfitBuy = 0; if (TakeProfit>0) takeProfitBuy = Ask+TakeProfit*Point*MathPow(10,Digits%2);
         if (EcnBroker)
         {
            int ticketb = OrderSend(Symbol(),OP_BUY,LotSize,Ask,Slippage,0,0,"",MagicNumber,0,CLR_NONE);
            if (ticketb>-1)
              dummyResult = OrderModify(ticketb,OrderOpenPrice(),stopLossBuy,takeProfitBuy,0,CLR_NONE);
         }
         else dummyResult = OrderSend(Symbol(),OP_BUY,LotSize,Ask,Slippage,stopLossBuy,takeProfitBuy,"",MagicNumber,0,CLR_NONE);
      }
   if (doWhat==_doSell && openedSells==0)
      {
         RefreshRates();
         double stopLossSell   = 0; if (StopLoss>0)   stopLossSell   = Bid+StopLoss*Point*MathPow(10,Digits%2);
         double takeProfitSell = 0; if (TakeProfit>0) takeProfitSell = Bid-TakeProfit*Point*MathPow(10,Digits%2);
         if (EcnBroker)
         {
            int tickets = OrderSend(Symbol(),OP_SELL,LotSize,Bid,Slippage,0,0,"",MagicNumber,0,CLR_NONE);
            if (tickets>-1)
              dummyResult = OrderModify(tickets,OrderOpenPrice(),stopLossSell,takeProfitSell,0,CLR_NONE);
         }
         else dummyResult = OrderSend(Symbol(),OP_SELL,LotSize,Bid,Slippage,stopLossSell,takeProfitSell,"",MagicNumber,0,CLR_NONE);
      }
   return(0);
}

//
//
//
//
//

bool checkTimeLimits(uint startHour, uint endHour, datetime timeToCheck) { return(checkTimeLimits(startHour,0,0,endHour,0,0,timeToCheck)); }
bool checkTimeLimits(uint startHour, uint startMinute, uint endHour, uint endMinute, datetime timeToCheck) { return(checkTimeLimits(startHour,startMinute,0,endHour,endMinute,0,timeToCheck)); }
bool checkTimeLimits(uint startHour, uint startMinute, uint startSecond, uint endHour, uint endMinute, uint endSecond, datetime timeToCheck)
{
   bool answer = false;
   MqlDateTime tempTime; TimeToStruct(timeToCheck,tempTime);
      datetime startTime,endTime,checkTime;
               startTime = _ctMinMax(startHour,0,24)    *3600+_ctMinMax(startMinute,0,60) *60+_ctMinMax(startSecond,0,60);
               endTime   = _ctMinMax(endHour,0,24)      *3600+_ctMinMax(endMinute,0,60)   *60+_ctMinMax(endSecond,0,60);
               checkTime = _ctMinMax(tempTime.hour,0,24)*3600+_ctMinMax(tempTime.min,0,60)*60+_ctMinMax(tempTime.sec,0,60);
               
   if (startTime>endTime)
          answer = (checkTime>=startTime || checkTime<=endTime);
   else   answer = (checkTime>=startTime && checkTime<=endTime);
   return(answer);
}
uint _ctMinMax(uint value, uint min, uint max) { return((uint)MathMax(MathMin(value,max),min)); }