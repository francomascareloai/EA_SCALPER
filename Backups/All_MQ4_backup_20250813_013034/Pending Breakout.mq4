//+------------------------------------------------------------------+
//|                                             Pending Breakout.mq4 |
//|                                                  Andrew R. Young |
//|                                 http://www.expertadvisorbook.com |
//+------------------------------------------------------------------+

#property copyright     "Andrew R. Young"
#property link          "http://www.expertadvisorbook.com"
#property description   "Pending order breakout system with trade timer and break even stop"
#property strict


//+------------------------------------------------------------------+
//| Includes and object initialization                               |
//+------------------------------------------------------------------+

#include <Mql4Book\Trade.mqh>
CTrade Trade;
CCount Count;

#include <Mql4Book\Timer.mqh>
CTimer Timer;

#include <Mql4Book\TrailingStop.mqh>
#include <Mql4Book\MoneyManagement.mqh>


//+------------------------------------------------------------------+
//| Input variables                                                  |
//+------------------------------------------------------------------+

sinput string MM; 	// Money Management
input bool UseMoneyManagement = true;
input double RiskPercent = 2;
input double FixedLotSize = 0.1;

sinput string TS; 	// Trade Settings
input int MagicNumber = 101;
input int HighLowBars = 8;
input int TakeProfit = 0;

sinput string BE;    // Break Even Stop
input bool UseBreakEvenStop = false;
input int MinimumProfit = 0;
input int LockProfit = 0;

sinput string TI; 	// Timer
input int StartHour = 0;
input int StartMinute = 0;
input int EndHour = 0;
input int EndMinute = 0;
input bool UseLocalTime = false;


//+------------------------------------------------------------------+
//| Global variable and indicators                                   |
//+------------------------------------------------------------------+

int gBuyTicket, gSellTicket;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()
{
   // Set magic number
   Trade.SetMagicNumber(MagicNumber);
   
   return(INIT_SUCCEEDED);
}


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void OnTick()
{
   // Check timer
   bool tradeEnabled = Timer.DailyTimer(StartHour,StartMinute,EndHour,EndMinute,UseLocalTime);
   
   // Close all orders
   if(tradeEnabled == false)
   {
      Trade.CloseAllMarketOrders();
      Trade.DeleteAllPendingOrders();
      
      gBuyTicket = 0;
      gSellTicket = 0;
   }
   
   // Open orders
   else
   {
      // Calculate highest high & lowest low
      int hShift = iHighest(_Symbol,_Period,MODE_HIGH,HighLowBars);
      int lShift = iLowest(_Symbol,_Period,MODE_LOW,HighLowBars);
      
      double hHigh = High[hShift];
      double lLow = Low[lShift];
      
      double difference = (hHigh - lLow) / _Point;
      
      // Money management
      double lotSize = FixedLotSize;
      if(UseMoneyManagement == true)
      {
         lotSize = MoneyManagement(_Symbol,FixedLotSize,RiskPercent,(int)difference); 
      }
      
      // Open buy stop order
      if( Count.Buy() == 0 && Count.BuyStop() == 0 && gBuyTicket == 0 )
      {
         double orderPrice = hHigh;
			orderPrice = AdjustAboveStopLevel(_Symbol,orderPrice);
			
			double buyStop = lLow;
			double buyProfit = BuyTakeProfit(_Symbol,TakeProfit,orderPrice);
			
			gBuyTicket = Trade.OpenBuyStopOrder(_Symbol,lotSize,orderPrice,buyStop,buyProfit);
      }
      
      // Open sell stop order
      if( Count.Sell() == 0 && Count.SellStop() == 0 && gSellTicket == 0)
      {
         double orderPrice = lLow;
			orderPrice = AdjustBelowStopLevel(_Symbol,orderPrice);
			
			double sellStop = hHigh;
			double sellProfit = SellTakeProfit(_Symbol,TakeProfit,orderPrice);
			
			gSellTicket = Trade.OpenSellStopOrder(_Symbol,lotSize,orderPrice,sellStop,sellProfit);
      }
      
      // Break even stop
      if(UseBreakEvenStop == true)
      {
         BreakEvenStopAll(MinimumProfit,LockProfit);   
      }
   }
}      
