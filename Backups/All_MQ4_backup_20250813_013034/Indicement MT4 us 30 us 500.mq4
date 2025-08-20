#property strict

extern bool ShowInfoPanel = TRUE;
extern double InfoPanelSizeAdjust = 1.0;
extern bool UpdateInfoTesting = FALSE;
extern string spreadfilter = "------------------------------ Settings ------------------------------";
extern bool Enable_BuyTrades = TRUE;
extern bool Enable_SellTrades = TRUE;
extern int FridayStopHour = 25;
extern bool setSL_TP_After_Entry = FALSE;
extern bool Virtual_expiration = FALSE;
extern int FakeOutFilter = 0;
extern int ST1_MagicNumber = 4000;
extern string ST1_Comment = "Indicement";
extern bool RemoveCommentSuffix = FALSE;
extern string US500_Settings = "------------------------------ US500 settings ------------------------------";
extern bool RunUS500 = TRUE;
extern string US500_Symbol = "US500";
extern bool US500_STRAT1 = TRUE;
extern bool US500_STRAT2 = TRUE;
extern bool US500_STRAT3 = TRUE;
extern bool US500_STRAT4 = TRUE;
extern double US500_UnitValue = 0.0;
extern double US500_MaxSpread = 0.0;
extern double US500_Randomization = 0.0;
extern string US30_Settings = "------------------------------ US30 settings ------------------------------";
extern bool RunUS30 = TRUE;
extern string US30_Symbol = "US30";
extern bool US30_STRAT1 = TRUE;
extern bool US30_STRAT2 = TRUE;
extern bool US30_STRAT3 = TRUE;
extern double US30_UnitValue = 0.0;
extern double US30_MaxSpread = 0.0;
extern double US30_Randomization = 0.0;
extern string NAS100_Settings = "------------------------------ NAS100 settings ------------------------------";
extern bool RunNAS100 = TRUE;
extern string NAS100_Symbol = "USTEC";
extern bool NAS100_STRAT1 = TRUE;
extern bool NAS100_STRAT2 = TRUE;
extern bool NAS100_STRAT3 = TRUE;
extern bool NAS100_STRAT4 = TRUE;
extern double NAS100_UnitValue = 0.0;
extern double NAS100_MaxSpread = 0.0;
extern double NAS100_Randomization = 0.0;
extern string propfirmsettings = "----------------------- Propfirm unique trades settings -----------------------";
extern double AdjustEntry = 0.0;
extern double AdjustSL = 0.0;
extern double AdjustTP = 0.0;
extern double AdjustTrailSL = 0.0;
extern double AdjustTrailTP = 0.0;
extern double AdjustBreakEven = 0.0;
extern string LotSizeSettings = "----------------------- LotSize Settings -----------------------";
extern double ForceBalanceToUse = 0.0;
extern int Risk = 1;
extern double MaxRisk_Strategy = 3.0;
extern int LotPerBalance_step = 500;
extern double StartLots = 0.01;
extern double PropFirmMaxDailyDD = 0.0;
extern bool UseEquity = FALSE;
extern bool OnlyUp = FALSE;
extern bool CheckMargin = TRUE;
extern bool AdjustLotsizeToVariableValues = TRUE;
extern string NFP_FILTER = "----------------------- NFP Filter -----------------------";
extern bool EnableNFP_Filter = TRUE;
extern bool AutoGMT = TRUE;
extern int Broker_GMT_OFFSET_Winter = 2;
extern int Broker_GMT_OFFSET_Summer = 3;
extern bool NFP_CloseOpenTrades = TRUE;
extern bool NFP_ClosePendingOrders = TRUE;
extern int NFP_MinutesBefore = 50;
extern int NFP_MinutesAfter = 30;
extern string IR_FILTER = "----------------------- Interest Rate Filter -----------------------";
extern bool EnableIR_Filter = TRUE;
extern bool IR_CloseOpenTrades = TRUE;
extern bool IR_ClosePendingOrders = TRUE;
extern int IR_MinutesBefore = 60;
extern int IR_MinutesAfter = 120;
extern string CPI_FILTER = "----------------------- CPI Filter -----------------------";
extern bool EnableCPI_Filter = FALSE;
extern bool CPI_CloseOpenTrades = TRUE;
extern bool CPI_ClosePendingOrders = TRUE;
extern int CPI_MinutesBefore = 60;
extern int CPI_MinutesAfter = 120;
extern string DisableTrades = "------------------------- Trading hours -------------------------";
extern bool UseTradingTimeZones = FALSE;
extern int Time_Source = 2;
extern string StartTime_string = "00:00";
extern string StopTime_string = "24:00";

  int    MagicNumber = 123456;  // Magic number to use for the EA
  bool   EcnBroker   = false;   // Is your broker ECN/STP type of broker?
  double LotSize     = 0.1;     // Lot size to use for trading
  int    Slippage    = 3;       // Slipage to use when opening new orders
  double StopLoss    = 100;     // Initial stop loss (in pips)
  double TakeProfit  = 100;     // Initial take profit (in pips)

  string dummy1      = "";      // .
  string dummy2      = "";      // Settings for indicators
  int    BarToUse    = 1;       // Bar to test (0, for still opened, 1 for first closed, and so on)
  int                Ma1Period   = 12;          // Fast ma period
  ENUM_APPLIED_PRICE Ma1Price    = PRICE_CLOSE; // Fast ma price
  ENUM_MA_METHOD     Ma1Method   = MODE_SMA;    // Fast ma method
  int                Ma2Period   = 26;          // Slow ma period
  ENUM_APPLIED_PRICE Ma2Price    = PRICE_CLOSE; // Slow ma price
  ENUM_MA_METHOD     Ma2Method   = MODE_SMA;    // Slow ma method 

  string dummy3      = "";      // . 
  string dummy4      = "";      // General settings
  bool   DisplayInfo = true;    // Dislay info

bool dummyResult;
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()   { 

return(0); }
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
      double diffc = iMA(NULL,0,Ma1Period,0,Ma1Method,Ma1Price,BarToUse)  -iMA(NULL,0,Ma2Period,0,Ma2Method,Ma2Price,BarToUse);
      double diffp = iMA(NULL,0,Ma1Period,0,Ma1Method,Ma1Price,BarToUse+1)-iMA(NULL,0,Ma2Period,0,Ma2Method,Ma2Price,BarToUse+1);
      if ((diffc*diffp)<0)
         if (diffc>0)
               doWhat = _doBuy;
         else  doWhat = _doSell;
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