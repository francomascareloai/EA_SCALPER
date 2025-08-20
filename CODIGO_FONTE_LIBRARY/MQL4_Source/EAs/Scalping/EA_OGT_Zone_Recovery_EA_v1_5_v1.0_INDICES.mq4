//+------------------------------------------------------------------+
//|                                                    Zone Hedge EA |
//|                                                       A. Sweeney |
//+------------------------------------------------------------------+

#property copyright     "Click here for the latest version"
#property description   "Coded by: A Sweeney"
#property link "https://oneglancetrader.com/download"
#property strict

// inputs, RSI OB/OS levels, RSI period, RSI timeframes
// if ob/os = false and ob/os[+1] = true take the trade


//+------------------------------------------------------------------+
//| Includes and object initialization                               |
//+------------------------------------------------------------------+

enum EA_Setting {Manual, RSI_MTF};
// enum Trade_Volume {Fixed_Lot, Fixed_P

enum CLOSE_PENDING_TYPE
{
   CLOSE_BUY_LIMIT,
   CLOSE_SELL_LIMIT,
   CLOSE_BUY_STOP,
   CLOSE_SELL_STOP,
   CLOSE_ALL_PENDING
};


//+------------------------------------------------------------------+
//| Input variables                                                  |
//+------------------------------------------------------------------+

sinput string RecoverySettings; // ** ZONE RECOVERY SETTINGS **
extern int RecoveryZoneSize = 200; // Recovery Zone Size (points)
extern int TakeProfit = 200; // Take Profit (points)
input int MaxTrades = 0; // Max Trades (0 for unlimited)
input bool SetMaxLoss = false; // Max Loss after Max Trades reached?
input double MaxLoss = 0; // Max Loss after Max Trades (0 for unlimted) in deposit currency.
input bool UseRecoveryTakeProfit = true; // Use a Recovery Take Profit
input int RecoveryTakeProfit = 50; // Recovery Take Profit (points).
extern double PendingPrice = 0; // Price for pending orders

sinput string ATRHeader; // ** ATR Dynamic Zone Sizing **
input bool UseATR = false; // Use ATR?
input int ATRPeriod = 14; // ATR Period
input double ATRZoneFraction = 0.2; // Fraction of ATR to use as Recovery Zone
input double ATRTPFraction = 0.3; // Fraction or ATR to use for TP sizes
input double ATRRecoveryZone = 0.15; // Fraction of ATR to use for recovery TP.

sinput string MoneyManagement;  	// ** MONEY MANAGEMENT SETTINGS **
input double RiskPercent = 0; // Account % Initial Lot Size  (set to 0 if not used) 
input double InitialLotSize = 0.1; // Initial Lot Size (if % not used)
input double LotMultiplier = 2; // Multiplier for Lots
input double LotAdditions = 0;
sinput string CustomLotSizing; // ** CUSTOM LOT SIZES **
input double CustomLotSize1 = 0;
input double CustomLotSize2 = 0;
input double CustomLotSize3 = 0;
input double CustomLotSize4 = 0;
input double CustomLotSize5 = 0;
input double CustomLotSize6 = 0;
input double CustomLotSize7 = 0;
input double CustomLotSize8 = 0;
input double CustomLotSize9 = 0;
input double CustomLotSize10 = 0;


sinput string TimerSettings;			// **  TIMER SETTINGS **
input bool UseTimer = false; // Use a Trade Timer?
input int StartHour = 0; // Start Hour
input int StartMinute = 0; // Start Minute
input int EndHour = 0; // End Hour
input int EndMinute = 0; // End Minute
input bool UseLocalTime = false; // Use local time?

sinput string TradeSettings;    	// ** EA SETTINGS **
input EA_Setting EA_Mode= Manual;
input int RSIPeriod = 14; // RSI Period
input double OverboughtLevel = 70; //Over-bought level
input double OversoldLevel = 30; // Over-sold level
input bool UseM1Timeframe = false; // Use M1 Timeframe?
input bool UseM5Timeframe = false; // Use M5 Timeframe?
input bool UseM15Timeframe = true; // Use M15 Timeframe?
input bool UseM30Timeframe = true; // Use M30 Timeframe?
input bool UseH1Timeframe = false; // Use H1 Timeframe?
input bool UseH4Timeframe = false; // Use H4 Timeframe?
input bool UseDailyTimeframe = false; // Use Daily Timeframe?
input bool UseWeeklyTimeframe = false; // Use Weekly Timeframe?
input bool UseMonthlyTimeframe = false; // Use Monthly Timeframe?

sinput string Visuals; // ** VISUALS **
input color profitLineColor = clrLightSeaGreen;
input int Panel_X = 40; // Panel X coordinate.
input int Panel_Y = 40; // Panel Y coordinate.
input color Panel_Color = clrBlack; // Panel background colour.
input color Panel_Lable_Color = clrWhite; // Panel lable text color.

sinput string BacktestingSettings; // ** OTHER SETTINGS **
input int MagicNumber = 141020; // Magic Number
input int Slippage = 100; // Slippage Max (Points).
input bool TradeOnBarOpen = true; // Trade on New Bar?
input int speed = 500; // Back tester speed
input double TestCommission = 7; // Back tester simulated commission


//+------------------------------------------------------------------+
//| Global variable and indicators                                   |
//+------------------------------------------------------------------+

#define EA_NAME "OGT Zone Recovery v1.5"
#define SELL_BUTTON "Sell Button"
#define BUY_BUTTON "Buy Button"
#define PENDING_EDIT "Pending Edit"
#define CLOSE_ALL_BUTTON "Close All Button"
#define TP_EDIT "TP Edit"
#define ZONE_EDIT "Zone Edit"
string gTradingPanelObjects[100];
#define PROFIT_LINE "Profit Line"

datetime gLastTime;
int gInitialTicket;
double gBuyOpenPrice;
double gSellOpenPrice;
double gBuyTakeProfit;
double gSellTakeProfit;
double gLotSize;
double gInitialLotSize;
double gInitialProfitTarget;
bool gRecoveryInitiated;
int gBuyStopTicket = 0;
int gSellStopTicket = 0;
int gBuyTicket = 0;
int gSellTicket = 0;
double gCustomLotSizes[10]; 

double UsePip;
double UseSlippage;
double gCurrentDirection;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()
{
   gRecoveryInitiated = false;
   gCurrentDirection = 0;
   // Set magic number
   UsePip = PipPoint(Symbol());
   UseSlippage = GetSlippage(Symbol(), Slippage);
   gLastTime = 0;
   gCustomLotSizes[0] = CustomLotSize1;
   gCustomLotSizes[1] = CustomLotSize2;
   gCustomLotSizes[2] = CustomLotSize3;
   gCustomLotSizes[3] = CustomLotSize4;
   gCustomLotSizes[4] = CustomLotSize5;
   gCustomLotSizes[5] = CustomLotSize6;
   gCustomLotSizes[6] = CustomLotSize7;
   gCustomLotSizes[7] = CustomLotSize8;
   gCustomLotSizes[8] = CustomLotSize9;
   gCustomLotSizes[9] = CustomLotSize10;
 
   CreateTradingPanel();
   Print("INIT SUCCESFUL, Recovery Initiated: ", gRecoveryInitiated, " Current Dirn: ", gCurrentDirection, " Magic No: ", MagicNumber, " Slippage: ", Slippage);
   
   if(OrdersTotal() > 0) FindOpenOrders();
       
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert Shutdown function                                             |
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
{
   switch(reason)
   {
      case 0:
      {
         DeleteTradePanel();
         Print("EA De-Initialised, removed by EA");
         break;
      }
      case 1:
      {
         DeleteTradePanel();
         Print("EA De-Initialised, removed by user");
         break;
      }
      case 2:
      {
         DeleteTradePanel();
         Print("EA De-Initialised, EA recompiled");
         break;
      }
      case 3:
      {
         DeleteTradePanel();
         Print("EA De-Initialised, Symbol changed");
         break;
      }   
      case 4:
      {
         DeleteTradePanel();
         Print("EA De-Initialised, chart closed by user.");
         break;
      }
      case 5:
      {
         Print("EA De-Initialised, input parameters changed.");
         break;
      }
      case 6:
      {
         Print("EA De-Initialised, account changed");
         break;
      }
      case 7:
      {
         DeleteTradePanel();
         Print("EA De-Initialised, A new template has been applied.");
         break;
      }
      case 8:
      {
         DeleteTradePanel();
         Print("EA De-Initialised, EA failed to initialize.");
         break;
      }
      case 9:
      {
         DeleteTradePanel();
         Print("EA De-Initialised, Terminal closed by user.");
         break;
      }  
   }
}



//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void OnTick()
{
   if(IsVisualMode() == true)
   {
      int Waitloop = 0;
      while(Waitloop < speed)
      {
         Waitloop++;
      }
   }
   // Check timer
   bool tradeEnabled = true;
   if(UseTimer == true)
   {
      tradeEnabled = CheckDailyTimer();
   }
   
   // Check for bar open
   bool newBar = true;
   int barShift = 0;
   
   // check if a new bar has been opened
   if(TradeOnBarOpen == true)
   {
      newBar = false;
      datetime time[];
      bool firstRun = false;
      
      CopyTime(_Symbol,PERIOD_CURRENT,0,2,time);
      
      if(gLastTime == 0) firstRun = true;
	
	   if(time[0] > gLastTime)
	   {
		   if(firstRun == false) newBar = true;
		   gLastTime = time[0];
	   }
      barShift = 1;
   }
   
   // Money management
   
   // set lot size to initial lot size for doubling later
   gInitialLotSize = CheckVolume(_Symbol, InitialLotSize); // check the input value for lot initial lot size and set to initial
   
   if(RiskPercent != 0)
   {
      int StopLoss = TakeProfit;
      if(UseATR == true)
      {
         double atr = iATR(_Symbol, PERIOD_D1, ATRPeriod, 1);
         StopLoss = round((atr*ATRTPFraction)/_Point); // set the stop loss a fraction of atr in points
      }
      gInitialLotSize = GetTradeSize(_Symbol,InitialLotSize,RiskPercent,StopLoss);
   }

   // Check entries on new bar
   if(newBar == true && tradeEnabled == true) // check for new bar and whether timer allows to open
   {
      
      switch(EA_Mode)
      {
         case RSI_MTF:
         {
            int direction = Is_RSI_OBOS_on_MTF(barShift + 1);
            int nowFalse = Is_RSI_OBOS_on_MTF(barShift);
            if(direction == 1 && nowFalse == 0)
            {
               Print("Buy signal generated.");
               if(gCurrentDirection == 0)
               {
                  TakeTrade(direction);
                  Print("Buy signal generated.");
               } else {
                  Print("Buy signal not used as EA in trade on ", _Symbol);
               }
            }
            else if(direction == -1 && nowFalse == 0)
            {
               if(gCurrentDirection == 0) 
               {
                  TakeTrade(direction);
                  Print("Sell signal generated.");
               } else {
                  Print("Sell signal not used as EA in trade on ", _Symbol);
               }
            }
         }              
      }
   }   
   
   

   if(gCurrentDirection != 0)
   {
      // on every tick work out the average price
      // count the number of buy and sell orders
      int positions = 0;
      double averagePrice = 0;
      double currentProfit = 0;
      double positionSize = 0;
      double netLotSize = 0;
      double totalCommision = 0;
      double totalSpreadCosts = 0;
      double point_value = _Point*MarketInfo(_Symbol, MODE_TICKVALUE)/MarketInfo(_Symbol, MODE_TICKSIZE);
   
      for(int counter = 0; counter <= OrdersTotal() - 1; counter++)
      {
         if(OrderSelect(counter, SELECT_BY_POS))
         {
            if(OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol())
            {
               positions += 1;
               currentProfit += OrderProfit();
               
               if(OrderType() == OP_BUY)
               {
                  positionSize += (OrderOpenPrice()*OrderLots());
                  netLotSize += OrderLots();
                  totalSpreadCosts += (OrderLots()*MarketInfo(_Symbol, MODE_SPREAD)*point_value);
                  totalCommision += OrderCommission();
               }
               else if(OrderType() == OP_SELL)
               {
                  positionSize -= (OrderOpenPrice()*OrderLots());
                  netLotSize -= OrderLots();
                  totalSpreadCosts += (OrderLots()*MarketInfo(_Symbol, MODE_SPREAD)*point_value);
                  totalCommision += OrderCommission();
               }
            }
         }
      }

      // if the current profits are greater than the desired recovery profit and costs close the trades
      double volume;
      if(CustomLotSize1 != 0) volume = CustomLotSize1;
      else volume = gInitialLotSize;
      double profitTarget = RecoveryTakeProfit*point_value*volume;
      if(UseATR == true) 
      {
         double atr = iATR(_Symbol, PERIOD_D1, ATRPeriod, 1);
         profitTarget = (ATRRecoveryZone*atr*point_value*volume)/_Point;
      }
      
      // simulate commission for backtesting
      double tradeCosts = 0;
      if(IsTesting())
      {
         tradeCosts = totalSpreadCosts+(MathAbs(netLotSize)*TestCommission);
      } else {
         tradeCosts = totalSpreadCosts+totalCommision; // spread and commision
      }
     
      double tp = RecoveryTakeProfit;
      if(UseRecoveryTakeProfit == false || gRecoveryInitiated == false)
      {
         profitTarget = TakeProfit*point_value*volume; // initial profit is equal to planned rz over tp, in $$
      }
      
      if(currentProfit >= (profitTarget +tradeCosts))
      {
         CloseOrdersAndReset();
         Print("Orders closed, profit target of: ", DoubleToStr(profitTarget, 2), "$ exceeded at: ", DoubleToStr(currentProfit, 2), "$, Costs(", DoubleToStr(tradeCosts, 2), "$)");        
      }
      if(netLotSize != 0)
      {
         averagePrice = NormalizeDouble(positionSize/netLotSize, _Digits);
         Comment(StringConcatenate("Average Price: ", DoubleToStr(averagePrice, _Digits), ", Profit Target: $", DoubleToStr(profitTarget, 2), " + Trade Costs: $", DoubleToStr(tradeCosts, 2), ", Running Profit:  $", DoubleToStr(currentProfit, 2)));
      }
      
      if(positions >= MaxTrades && MaxTrades != 0 && currentProfit < -MaxLoss && SetMaxLoss == true)
      {
         CloseOrdersAndReset();
         Print("Orders closed, max trades reached and max loss of: -$", MaxLoss, " by $", currentProfit);
      }   
   
      // set the take profit line price
      if(gCurrentDirection == 1 && netLotSize != 0)
      {
         tp = (profitTarget + tradeCosts - currentProfit)*_Point/(point_value*netLotSize);
         double   profitPrice = NormalizeDouble(Bid + tp, _Digits);
         if(!ObjectSetDouble(0, PROFIT_LINE, OBJPROP_PRICE, profitPrice)) Print("Could not set line");
      } else if(gCurrentDirection == -1 && netLotSize != 0) {
         tp = (profitTarget + tradeCosts - currentProfit)*_Point/(point_value*netLotSize);   
         double   profitPrice = NormalizeDouble(Ask + tp, _Digits);
         if(!ObjectSetDouble(0, PROFIT_LINE, OBJPROP_PRICE, profitPrice)) Print("Could not set line");   
      } 
      

   
   // check if the current direction is buy and the bid price (sell stop has opened) is below the recovery line
      if(gCurrentDirection == 1)
      {
         double price = MarketInfo(Symbol(), MODE_ASK);
         if(OrderSelect(gSellStopTicket, SELECT_BY_TICKET))
         {
            if(OrderType() == OP_SELL) // if the sell stop has opened
            {
               Print("Recovery Sell Stop has been opened, initiating recovery...");
               gSellTicket = gSellStopTicket; // make the stop a sell ticket
               gSellStopTicket = 0; // reset the sell stop ticket
               
               // increase the lot size 
               gLotSize = GetTradeVolume(positions+1);

               if(MaxTrades == 0 || positions < MaxTrades) // check we've not exceeded the max trades
               {
                 // open a buy stop order at double the running lot size
                 gBuyStopTicket = OpenPendingOrder(Symbol(), OP_BUYSTOP, gLotSize, gBuyOpenPrice, 0, 0, StringConcatenate("Recovery Buy Stop opened."), 0, clrTurquoise); // create an opposite buy stop
                 gRecoveryInitiated = true; // signal that we are in recovery mode
               }
               // change the current direction to sell
               gCurrentDirection = -1;            
            }
         } else {
            string message = "Warning - EA could not find the recovery Sell Stop";
            Alert(message);
            Print(message);
         }
      }
   // check if the current direction is sell and the ask price (sell stop has opened) is below the recovery line
      if(gCurrentDirection == -1)
      {
         double price = MarketInfo(Symbol(), MODE_BID);   
         if(OrderSelect(gBuyStopTicket, SELECT_BY_TICKET))
         {
            if(OrderType() == OP_BUY) // if the buy stop has opened
            {
               Print("Recovery Buy Stop has been opene, initiating recovery...");
               gBuyTicket = gBuyStopTicket; // set the buy ticket to the stop
               gBuyStopTicket = 0; // reset the buy ticket
               
               // increase the lot size
               gLotSize = GetTradeVolume(positions+1);               
               
               if(MaxTrades == 0 || positions < MaxTrades) // check we've not exceeded the max trades
               {
                  // open a sell stop order at double the running lot size
                  gSellStopTicket = OpenPendingOrder(Symbol(), OP_SELLSTOP, gLotSize, gSellOpenPrice, 0, 0, StringConcatenate("Recovery Sell Stop opened."), 0, clrPink); // create an opposite sell stop
                  gRecoveryInitiated = true; // signal we're in recovery mode
               }
               // change the current direction to sell
               gCurrentDirection = 1;
            }
         } else {
            string message = "Warning - EA could not find the recovery Buy Stop";
            Alert(message);
            Print(message);
         }
      }
   } else {
      Comment("No OGT Zone Recovery Trades Active");
   }
}

// Initial trade taking algorithm

void TakeTrade(int direction)
{

    double tp = 0;
    double rz = 0;
    // if the user has selected to use the ATR to size zones
    if(UseATR == true)
    {
      double atr = iATR(_Symbol, PERIOD_D1, ATRPeriod, 1);
      tp = atr*ATRTPFraction;
      rz = atr*ATRZoneFraction;
      //TakeProfit = tp;
      //RecoveryZoneSize = rz;
    } else if(UseATR == false)
    {
      tp = TakeProfit*_Point; // tp as price units
      rz = RecoveryZoneSize*_Point; // rz as price
    }
    if(CustomLotSize1 != 0) gLotSize = CustomLotSize1;
    else gLotSize = gInitialLotSize;

    double price = 0;
    
   if(direction == 1)
   {
   
       gBuyTicket = OpenMarketOrder(Symbol(), OP_BUY, gLotSize, "Initial Buy Order", clrGreen);
       if(OrderSelect(gBuyTicket, SELECT_BY_TICKET))
       {                 
          gBuyOpenPrice = OrderOpenPrice();       
          gSellOpenPrice = NormalizeDouble((gBuyOpenPrice - rz), _Digits);
          gBuyTakeProfit = NormalizeDouble((gBuyOpenPrice + tp), _Digits);
          gSellTakeProfit = NormalizeDouble((gBuyOpenPrice - (tp + rz)), _Digits);
          
          // ModifyStopsByPrice(gBuyTicket, gSellTakeProfit, gBuyTakeProfit);  
      
          //open a recovery stop order in the opposite direction
          gLotSize = GetTradeVolume(2);
          gSellStopTicket = OpenPendingOrder(Symbol(), OP_SELLSTOP, gLotSize, gSellOpenPrice, 0, 0, "Initial Recovery Sell Stop)", 0, clrPink);
          gCurrentDirection = direction;
          price = gBuyOpenPrice;
       }
   }
   // Sell Trade
   else if(direction == -1)
   {
       gSellTicket = OpenMarketOrder(Symbol(), OP_SELL, gLotSize, "Initial Sell Order", clrRed);
       if(OrderSelect(gSellTicket, SELECT_BY_TICKET))
       {
          gSellOpenPrice = OrderOpenPrice(); 
          gBuyOpenPrice = NormalizeDouble((gSellOpenPrice + rz), _Digits);
          gSellTakeProfit = NormalizeDouble((gSellOpenPrice - tp), _Digits);
          gBuyTakeProfit = NormalizeDouble((gSellOpenPrice + (tp + rz)), _Digits);
          
          // ModifyStopsByPrice(gSellTicket, gBuyTakeProfit, gSellTakeProfit);       
          
          //open a recovery stop order in the opposite direction
          gLotSize = GetTradeVolume(2);
          gBuyStopTicket = OpenPendingOrder(Symbol(), OP_BUYSTOP, gLotSize, gBuyOpenPrice, 0, 0, "Initial Recovery Buy Stop)", 0, clrTurquoise);
          gCurrentDirection = direction;
          price = gSellOpenPrice;
       }
   }
   CreateProfitLine(direction, price, tp); 
}

void PlaceTrade(int pType)
{
    double tp = 0;
    double rz = 0;
    // if the user has selected to use the ATR to size zones
    if(UseATR == true)
    {
      double atr = iATR(_Symbol, PERIOD_D1, ATRPeriod, 1);
      tp = atr*ATRTPFraction;
      rz = atr*ATRZoneFraction;
      //TakeProfit = tp;
      //RecoveryZoneSize = rz;
    } else if(UseATR == false)
    {
      tp = TakeProfit*_Point;  // tp as price
      rz = RecoveryZoneSize*_Point; // rz  as price
    }
    if(CustomLotSize1 != 0) gLotSize = CustomLotSize1;
    else gLotSize = gInitialLotSize;
    
    if(pType == OP_BUYLIMIT)
    {
      gBuyStopTicket = OpenPendingOrder(_Symbol, OP_BUYLIMIT, gLotSize, PendingPrice, 0, 0, "Buy Limit Order", 0, 0);
      gBuyOpenPrice = PendingPrice;       
      gSellOpenPrice = NormalizeDouble((gBuyOpenPrice - rz), _Digits);
      gCurrentDirection = -1;
    
    } else if(pType == OP_BUYSTOP)
    {
      gBuyStopTicket = OpenPendingOrder(_Symbol, OP_BUYSTOP, gLotSize, PendingPrice, 0, 0, "Buy Stop Order", 0, 0);
      gBuyOpenPrice = PendingPrice;       
      gSellOpenPrice = NormalizeDouble((gBuyOpenPrice - rz), _Digits);
      gCurrentDirection = -1;
    
    } else if(pType == OP_SELLLIMIT)
    {
      gSellOpenPrice = PendingPrice; 
      gBuyOpenPrice = NormalizeDouble((gSellOpenPrice + rz), _Digits);
      gSellStopTicket = OpenPendingOrder(_Symbol, OP_SELLLIMIT, gLotSize, PendingPrice, 0, 0,  "Sell Limit Order", 0, 0);
      gCurrentDirection = 1;
    } else if(pType == OP_SELLSTOP)
    {
      gSellOpenPrice = PendingPrice; 
      gBuyOpenPrice = NormalizeDouble((gSellOpenPrice + rz), _Digits);
      gSellStopTicket = OpenPendingOrder(_Symbol, OP_SELLSTOP, gLotSize, PendingPrice, 0, 0,  "Sell Stop Order", 0, 0);
      gCurrentDirection = 1;
    }
    CreateProfitLine(gCurrentDirection, PendingPrice, 0);
}

// RSI Entry Function

int Is_RSI_OBOS_on_MTF(int shift)
{
   int direction = 0;
   
   // check if the MTF is showing oversold, buy signal
   double rsi = iRSI(_Symbol, PERIOD_M1, RSIPeriod, PRICE_CLOSE, shift);
   if((UseM1Timeframe == false) || (rsi < OversoldLevel))
   {
      rsi = iRSI(_Symbol, PERIOD_M5, RSIPeriod, PRICE_CLOSE, shift);
      if(UseM5Timeframe == false || (rsi < OversoldLevel))
      {
         rsi = iRSI(_Symbol, PERIOD_M15, RSIPeriod, PRICE_CLOSE, shift);
         if((UseM15Timeframe == false) || (rsi < OversoldLevel))
         {
            rsi = iRSI(_Symbol, PERIOD_M30, RSIPeriod, PRICE_CLOSE, shift);
            if((UseM30Timeframe == false) || (rsi < OversoldLevel))
            {
               rsi = iRSI(_Symbol, PERIOD_H1, RSIPeriod, PRICE_CLOSE, shift);
               if((UseH1Timeframe == false) || (rsi < OversoldLevel))
               {
                  rsi = iRSI(_Symbol, PERIOD_H4, RSIPeriod, PRICE_CLOSE, shift);
                  if((UseH4Timeframe == false) || (rsi < OversoldLevel))
                  {
                     rsi = iRSI(_Symbol, PERIOD_D1, RSIPeriod, PRICE_CLOSE, shift);
                     if((UseDailyTimeframe == false) || (rsi < OversoldLevel))
                     {
                        rsi = iRSI(_Symbol, PERIOD_W1, RSIPeriod, PRICE_CLOSE, shift);
                        if((UseWeeklyTimeframe == false) || (rsi < OversoldLevel))
                        {
                           rsi = iRSI(_Symbol, PERIOD_MN1, RSIPeriod, PRICE_CLOSE, shift);
                           if((UseMonthlyTimeframe == false) || (rsi < OversoldLevel))
                           {
                              direction = 1;
                              return direction;
                           }
                        }
                     }                     
                  }
               }
            }
         }
      }
   }
   
   // check if the MTF is showing overbought, sell signal   
   rsi = iRSI(_Symbol, PERIOD_M1, RSIPeriod, PRICE_CLOSE, shift);
   if((UseM1Timeframe == false) || (rsi > OverboughtLevel))
   {
      rsi = iRSI(_Symbol, PERIOD_M5, RSIPeriod, PRICE_CLOSE, shift);
      if(UseM5Timeframe == false || (rsi > OverboughtLevel))
      {
         rsi = iRSI(_Symbol, PERIOD_M15, RSIPeriod, PRICE_CLOSE, shift);
         if((UseM15Timeframe == false) || (rsi > OverboughtLevel))
         {
            rsi = iRSI(_Symbol, PERIOD_M30, RSIPeriod, PRICE_CLOSE, shift);
            if((UseM30Timeframe == false) || (rsi > OverboughtLevel))
            {
               rsi = iRSI(_Symbol, PERIOD_H1, RSIPeriod, PRICE_CLOSE, shift);
               if((UseH1Timeframe == false) || (rsi > OverboughtLevel))
               {
                  rsi = iRSI(_Symbol, PERIOD_H4, RSIPeriod, PRICE_CLOSE, shift);
                  if((UseH4Timeframe == false) || (rsi > OverboughtLevel))
                  {
                     rsi = iRSI(_Symbol, PERIOD_D1, RSIPeriod, PRICE_CLOSE, shift);
                     if((UseDailyTimeframe == false) || (rsi > OverboughtLevel))
                     {
                        rsi = iRSI(_Symbol, PERIOD_W1, RSIPeriod, PRICE_CLOSE, shift);
                        if((UseWeeklyTimeframe == false) || (rsi > OverboughtLevel))
                        {
                           rsi = iRSI(_Symbol, PERIOD_MN1, RSIPeriod, PRICE_CLOSE, shift);
                           if((UseMonthlyTimeframe == false) || (rsi > OverboughtLevel))
                           {
                              direction = -1;
                              return direction;
                           }
                        }
                     }                     
                  }
               }
            }
         }
      } 
   }
   return direction;      
}

void CloseOrdersAndReset()
{
   CloseAllMarketOrders();
   DeletePendingOrders(CLOSE_ALL_PENDING);
   gLotSize = gInitialLotSize;
   gCurrentDirection = 0;
   gBuyStopTicket = 0;
   gSellStopTicket = 0;
   gBuyTicket = 0;
   gSellTicket = 0;
   gRecoveryInitiated = false;
   DeleteProfitLine();
}

void CreateProfitLine(double pDirection, double pPrice, double pPoints)
{
   double price = 0;
   if(pDirection == 1)
   {
      price = NormalizeDouble(pPrice + pPoints, _Digits);
   } else if(pDirection == -1) {
      price = NormalizeDouble(pPrice - pPoints, _Digits);
   }
   ObjectCreate(0, PROFIT_LINE, OBJ_HLINE, 0,0,price);
   ObjectSetInteger(0, PROFIT_LINE, OBJPROP_COLOR, profitLineColor);
   ObjectSetInteger(0, PROFIT_LINE, OBJPROP_STYLE, STYLE_DASH);
}

void DeleteProfitLine()
{
   ObjectDelete(0, PROFIT_LINE);
}

void CreateTradingPanel()
{
   // create the button to start the trade off

   long buttonWidth = 50;
   long buttonHeight = 25;
   long panelX = Panel_X;
   long panelY = Panel_Y;
   long boxMargin = 10;
   long lableX = panelX+boxMargin+5;
   long lableY = panelY+boxMargin+10;
   long lableHeight = 40;
   long buttonX = panelX+boxMargin+20;
   long buttonY = panelY+lableHeight+boxMargin;
   long panelWidth = boxMargin+buttonWidth+boxMargin+buttonWidth+boxMargin +40;
   long panelHeight = boxMargin+lableHeight+boxMargin+buttonHeight+boxMargin+buttonHeight+boxMargin+buttonHeight+boxMargin+buttonHeight+boxMargin+buttonHeight+boxMargin;
   double pending = NormalizeDouble(PendingPrice, _Digits);
   

   string buttonBox = "ButtonBox";   
   ObjectCreate(0, buttonBox, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0,buttonBox,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0, buttonBox, OBJPROP_XSIZE, panelWidth);
   ObjectSetInteger(0, buttonBox, OBJPROP_YSIZE, panelHeight);
   ObjectSetInteger(0, buttonBox, OBJPROP_XDISTANCE, panelX);
   ObjectSetInteger(0, buttonBox, OBJPROP_YDISTANCE, panelY);
   ObjectSetInteger(0, buttonBox, OBJPROP_BGCOLOR, Panel_Color);
   ObjectSetInteger(0,buttonBox,OBJPROP_BORDER_TYPE,BORDER_RAISED);
   ObjectSetInteger(0,buttonBox,OBJPROP_COLOR,clrGray);
   ObjectSetInteger(0,buttonBox,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,buttonBox,OBJPROP_HIDDEN,false);
   ObjectSetInteger(0,buttonBox,OBJPROP_ZORDER,0);
   gTradingPanelObjects[0] = buttonBox;
   
   string panelLabel = "Trading Panel Label";
   ObjectCreate(0, panelLabel, OBJ_LABEL, 0,0,0);
   ObjectSetString(0, panelLabel, OBJPROP_TEXT, EA_NAME);
   ObjectSetInteger(0, panelLabel, OBJPROP_XDISTANCE, lableX);
   ObjectSetInteger(0, panelLabel, OBJPROP_YDISTANCE, lableY);
   ObjectSetInteger(0, panelLabel, OBJPROP_COLOR, Panel_Lable_Color);
   ObjectSetInteger(0, panelLabel, OBJPROP_FONTSIZE, 9);
   gTradingPanelObjects[1] = panelLabel;
   
   string sellButtonName = SELL_BUTTON;  
   ObjectCreate(0, sellButtonName, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, sellButtonName, OBJPROP_XSIZE, buttonWidth);
   ObjectSetInteger(0, sellButtonName, OBJPROP_YSIZE, buttonHeight);
   ObjectSetInteger(0, sellButtonName, OBJPROP_XDISTANCE, buttonX);
   ObjectSetInteger(0, sellButtonName, OBJPROP_YDISTANCE, buttonY);
   ObjectSetInteger(0, sellButtonName, OBJPROP_COLOR, Panel_Lable_Color);
   ObjectSetInteger(0, sellButtonName, OBJPROP_BGCOLOR, clrRed);
   ObjectSetString(0, sellButtonName, OBJPROP_TEXT, "Sell");
   gTradingPanelObjects[2] = SELL_BUTTON;
     
   string buyButtonName = BUY_BUTTON;
   ObjectCreate(0, buyButtonName, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, buyButtonName, OBJPROP_XSIZE, buttonWidth);
   ObjectSetInteger(0, buyButtonName, OBJPROP_YSIZE, buttonHeight);
   ObjectSetInteger(0, buyButtonName, OBJPROP_XDISTANCE, (buttonX+buttonWidth+boxMargin));
   ObjectSetInteger(0, buyButtonName, OBJPROP_YDISTANCE, buttonY);
   ObjectSetInteger(0, buyButtonName, OBJPROP_COLOR, Panel_Lable_Color);
   ObjectSetInteger(0, buyButtonName, OBJPROP_BGCOLOR, clrGreen);
   ObjectSetString(0, buyButtonName, OBJPROP_TEXT, "Buy");
   gTradingPanelObjects[3] = BUY_BUTTON; 
   
   ObjectCreate(0, CLOSE_ALL_BUTTON, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, CLOSE_ALL_BUTTON, OBJPROP_XSIZE, buttonWidth+boxMargin+buttonWidth);
   ObjectSetInteger(0, CLOSE_ALL_BUTTON, OBJPROP_YSIZE, buttonHeight);
   ObjectSetInteger(0, CLOSE_ALL_BUTTON, OBJPROP_XDISTANCE, (buttonX));
   ObjectSetInteger(0, CLOSE_ALL_BUTTON, OBJPROP_YDISTANCE, buttonY+buttonHeight+boxMargin);
   ObjectSetInteger(0, CLOSE_ALL_BUTTON, OBJPROP_COLOR, Panel_Lable_Color);
   ObjectSetInteger(0, CLOSE_ALL_BUTTON, OBJPROP_BGCOLOR, clrGray);
   ObjectSetString(0, CLOSE_ALL_BUTTON, OBJPROP_TEXT, "Close All Orders");
   gTradingPanelObjects[4] = CLOSE_ALL_BUTTON;
   
   string TPLabel = "TP Label";
   ObjectCreate(0, TPLabel, OBJ_LABEL, 0, 0, 0);
   ObjectSetString(0, TPLabel, OBJPROP_TEXT, "TP: ");
   ObjectSetInteger(0, TPLabel, OBJPROP_XDISTANCE, buttonX);
   ObjectSetInteger(0, TPLabel, OBJPROP_YDISTANCE, 5+buttonY+buttonHeight+boxMargin+buttonHeight+boxMargin);
   ObjectSetInteger(0, TPLabel, OBJPROP_COLOR, Panel_Lable_Color);
   gTradingPanelObjects[5] = TPLabel;
   
   string zoneLable = "Zone Lable";
   ObjectCreate(0, zoneLable, OBJ_LABEL, 0, 0, 0);
   ObjectSetString(0, zoneLable, OBJPROP_TEXT, "Zone: ");
   ObjectSetInteger(0, zoneLable, OBJPROP_XDISTANCE, buttonX);
   ObjectSetInteger(0, zoneLable, OBJPROP_YDISTANCE, 5+ buttonY+buttonHeight+boxMargin+buttonHeight+boxMargin+buttonHeight+boxMargin);
   ObjectSetInteger(0, zoneLable, OBJPROP_COLOR, Panel_Lable_Color);
   gTradingPanelObjects[6] = zoneLable;
   
   ObjectCreate(0, TP_EDIT, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, TP_EDIT, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, TP_EDIT, OBJPROP_XDISTANCE, buttonX+buttonWidth+boxMargin);
   ObjectSetInteger(0, TP_EDIT, OBJPROP_YDISTANCE, buttonY+buttonHeight+boxMargin+buttonHeight+boxMargin);
   ObjectSetInteger(0, TP_EDIT, OBJPROP_XSIZE, buttonWidth);
   ObjectSetInteger(0, TP_EDIT, OBJPROP_YSIZE, buttonHeight);   
   ObjectSetInteger(0, TP_EDIT, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, TP_EDIT, OBJPROP_BGCOLOR, clrWhite);
   ObjectSetString(0, TP_EDIT, OBJPROP_TEXT, IntegerToString(TakeProfit));
   ObjectSetInteger(0,TP_EDIT,OBJPROP_ALIGN,ALIGN_CENTER);
   gTradingPanelObjects[7] = TP_EDIT;
   
   ObjectCreate(0, ZONE_EDIT, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, ZONE_EDIT, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, ZONE_EDIT, OBJPROP_XDISTANCE, buttonX+buttonWidth+boxMargin);
   ObjectSetInteger(0, ZONE_EDIT, OBJPROP_YDISTANCE, buttonY+buttonHeight+boxMargin+buttonHeight+boxMargin+buttonHeight+boxMargin);   
   ObjectSetInteger(0, ZONE_EDIT, OBJPROP_XSIZE, buttonWidth);
   ObjectSetInteger(0, ZONE_EDIT, OBJPROP_YSIZE, buttonHeight);
   ObjectSetInteger(0, ZONE_EDIT, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, ZONE_EDIT, OBJPROP_BGCOLOR, clrWhite);
   ObjectSetString(0, ZONE_EDIT, OBJPROP_TEXT, IntegerToString(RecoveryZoneSize));
   ObjectSetInteger(0,ZONE_EDIT,OBJPROP_ALIGN,ALIGN_CENTER);
   gTradingPanelObjects[8] = ZONE_EDIT;
   
   ObjectCreate(0, PENDING_EDIT, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, PENDING_EDIT, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, PENDING_EDIT, OBJPROP_XDISTANCE, buttonX+buttonWidth+boxMargin);
   ObjectSetInteger(0, PENDING_EDIT, OBJPROP_YDISTANCE, buttonY+buttonHeight+boxMargin+buttonHeight+boxMargin+buttonHeight+boxMargin+buttonHeight+boxMargin);   
   ObjectSetInteger(0, PENDING_EDIT, OBJPROP_XSIZE, buttonWidth);
   ObjectSetInteger(0, PENDING_EDIT, OBJPROP_YSIZE, buttonHeight);
   ObjectSetInteger(0, PENDING_EDIT, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, PENDING_EDIT, OBJPROP_BGCOLOR, clrWhite);
   ObjectSetString(0, PENDING_EDIT, OBJPROP_TEXT, IntegerToString(pending));
   ObjectSetInteger(0,PENDING_EDIT,OBJPROP_ALIGN,ALIGN_CENTER);
   gTradingPanelObjects[9] = PENDING_EDIT;
      
   string pendingLabel = "Pending Label";
   ObjectCreate(0, pendingLabel, OBJ_LABEL, 0, 0, 0);
   ObjectSetString(0, pendingLabel, OBJPROP_TEXT, "Price: ");
   ObjectSetInteger(0, pendingLabel, OBJPROP_XDISTANCE, buttonX);
   ObjectSetInteger(0, pendingLabel, OBJPROP_YDISTANCE, 5+ buttonY+buttonHeight+boxMargin+buttonHeight+boxMargin+buttonHeight+boxMargin+buttonHeight+boxMargin);
   ObjectSetInteger(0, pendingLabel, OBJPROP_COLOR, Panel_Lable_Color);
   gTradingPanelObjects[10] = pendingLabel;  
   
}

// Panel action buttons
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
   if(sparam == SELL_BUTTON && gCurrentDirection == 0)
   {
      if(gCurrentDirection == 0 && PendingPrice == 0) TakeTrade((int)-1);
      else if(PendingPrice > Bid) PlaceTrade(OP_SELLLIMIT);
      else if(PendingPrice < Bid) PlaceTrade(OP_SELLSTOP);
   }
   else if(sparam == BUY_BUTTON && gCurrentDirection == 0)
   {
      if(gCurrentDirection == 0 && PendingPrice == 0) TakeTrade((int)1);
      else if(PendingPrice > Ask) PlaceTrade(OP_BUYSTOP);
      else if(PendingPrice < Ask) PlaceTrade(OP_BUYLIMIT);
   }
   else if(sparam == CLOSE_ALL_BUTTON)
   {
      CloseOrdersAndReset();
      Print("Close all pressed.");
   }
   
   else if(id == CHARTEVENT_OBJECT_ENDEDIT && sparam == TP_EDIT)
   {
      string takeProfitString = ObjectGetString(0, TP_EDIT, OBJPROP_TEXT);
      TakeProfit = StringToPips(takeProfitString);
   }
   else if(id == CHARTEVENT_OBJECT_ENDEDIT && sparam == ZONE_EDIT)
   {
      string zoneString = ObjectGetString(0, ZONE_EDIT, OBJPROP_TEXT);
      RecoveryZoneSize = StringToPips(zoneString);
   }
   else if(id == CHARTEVENT_OBJECT_ENDEDIT && sparam == PENDING_EDIT)
   {
      string pendingString = ObjectGetString(0, PENDING_EDIT, OBJPROP_TEXT);
      PendingPrice = NormalizeDouble(StringToDouble(pendingString), _Digits);
   }
   
}


void DeleteTradePanel()
{
   for(int count = 0; count <= ArraySize(gTradingPanelObjects)-1; count++)
   {
      if(ArraySize(gTradingPanelObjects) > 0)
      {
         string objectName = gTradingPanelObjects[count];
         ObjectDelete(0, objectName);
      }
   }
}

// USEFUL FUNCTIONS

// Pip Point Function
double PipPoint(string Currency)
   {
      double CalcPoint = 0; 
      double CalcDigits = MarketInfo(Currency,MODE_DIGITS);
      if(CalcDigits == 2 || CalcDigits == 3) CalcPoint = 0.01;
      else if(CalcDigits == 4 || CalcDigits == 5) CalcPoint = 0.0001;
      else if(CalcDigits == 0) CalcPoint = 0;
      else if(CalcDigits == 1) CalcPoint = 0.1;
      return(CalcPoint);
   }
   
double GetSlippage(string Currency, int SlippagePips) 
   { 
      double CalcSlippage = SlippagePips;
      int CalcDigits = (int)MarketInfo(Currency,MODE_DIGITS); 
      if(CalcDigits == 0 || CalcDigits == 1 || CalcDigits == 2 || CalcDigits == 4) CalcSlippage = SlippagePips; 
      else if(CalcDigits == 3 || CalcDigits == 5) CalcSlippage = SlippagePips; 
      return(CalcSlippage); 
   }
   
int GetPoints(int Pips)
   {
      int CalcPoint = Pips; 
      double CalcDigits = MarketInfo(Symbol(),MODE_DIGITS);
      if(CalcDigits == 0 || CalcDigits == 1 || CalcDigits == 2 || CalcDigits == 4) CalcPoint = Pips;
      return(CalcPoint);
   }
   
int StringToPips(string text)
{
   int pips = StringToInteger(text);
   if(pips <= 0)
   {
      Alert("Invalid pips from string: ", pips);
   }
   return pips;
}



void CloseAllMarketOrders()
{
   int retryCount = 0;
   
   for(int Counter = 0; Counter <= OrdersTotal()-1; Counter++)
   {
      if(OrderSelect(Counter,SELECT_BY_POS))
      {
         if(OrderMagicNumber() == MagicNumber && OrderSymbol() == _Symbol && (OrderType() == OP_BUY || OrderType() == OP_SELL))
         {
            // Close Order
            int CloseTicket = OrderTicket();
            double CloseLots = OrderLots();
            while(IsTradeContextBusy()) Sleep(10);
            
            RefreshRates();            
            double ClosePrice = MarketInfo(_Symbol,MODE_BID);
            if(OrderType() == OP_SELL) ClosePrice = MarketInfo(_Symbol, MODE_ASK);

            bool Closed = OrderClose(CloseTicket,CloseLots,ClosePrice,Slippage,Red);
            // Error Handling
            if(Closed == false)
            {
               int ErrorCode = GetLastError();
               string ErrAlert = StringConcatenate("Close All Market Orders - Error ",ErrorCode,".");
               Alert(ErrAlert);
               Print(ErrAlert);
            } else Counter--;
         }
      }  
    }
}

double GetTradeVolume(int pTradeNo)
{
   double lots = 0;
   double volume = 0;
   if(CustomLotSize1 == 0)
   {
      lots = (gLotSize*LotMultiplier)+LotAdditions; //increase the lot size
   } else if(CustomLotSize1 != 0){
      if(pTradeNo > 10) {
         Alert("No of trades exceeds custom lot size inputs (10)");
         return -1;
      } else {
         lots = gCustomLotSizes[pTradeNo-1];
      }
   }
   volume = CheckVolume(_Symbol, lots);
   return volume;
}

// Verify and adjust trade volume
double CheckVolume(string pSymbol,double pVolume)
{
	double minVolume = SymbolInfoDouble(pSymbol,SYMBOL_VOLUME_MIN);
	double maxVolume = SymbolInfoDouble(pSymbol,SYMBOL_VOLUME_MAX);
	double stepVolume = SymbolInfoDouble(pSymbol,SYMBOL_VOLUME_STEP);
	
	double tradeSize;
	if(pVolume < minVolume) 
	{
	   Alert("Sent volume is smaller than the minimum volume for this symbol: ", _Symbol, ", min: ", minVolume, ", sent: ", pVolume);
	   tradeSize = minVolume;
	}
	else if(pVolume > maxVolume)
	{
	   Alert("Sent volume is larger than the maximum volume for this symbol: ", _Symbol, ", max: ", maxVolume, ", sent: ", pVolume);	   
	   tradeSize = maxVolume;
	}   
	else tradeSize = MathRound(pVolume / stepVolume) * stepVolume;
	
	if(stepVolume >= 0.1) tradeSize = NormalizeDouble(tradeSize,1);
	else tradeSize = NormalizeDouble(tradeSize,2);
	
	return(tradeSize);
}

bool DeletePendingOrders(CLOSE_PENDING_TYPE pDeleteType)
{
   bool error = false;
   bool deleteOrder = false;
   
   // Loop through open order pool from oldest to newest
   for(int order = 0; order <= OrdersTotal() - 1; order++)
   {
      // Select order
      bool result = OrderSelect(order,SELECT_BY_POS);
      
      int orderType = OrderType();
      int orderMagicNumber = OrderMagicNumber();
      int orderTicket = OrderTicket();
      double orderVolume = OrderLots();
      
      // Determine if order type matches pCloseType
      if( (pDeleteType == CLOSE_ALL_PENDING && orderType != OP_BUY && orderType != OP_SELL)
         || (pDeleteType == CLOSE_BUY_LIMIT && orderType == OP_BUYLIMIT) 
         || (pDeleteType == CLOSE_SELL_LIMIT && orderType == OP_SELLLIMIT) 
         || (pDeleteType == CLOSE_BUY_STOP && orderType == OP_BUYSTOP)
         || (pDeleteType == CLOSE_SELL_STOP && orderType == OP_SELLSTOP) )
      {
         deleteOrder = true;
      }
      else deleteOrder = false;
      
      // Close order if pCloseType and magic number match currently selected order
      if(deleteOrder == true && orderMagicNumber == MagicNumber)
      {
         result = OrderDelete(orderTicket);
         
         if(result == false)
         {
            Print("Delete multiple orders, failed to delete order: ", orderTicket);
            error = true;
         }
         else order--;
      }
   }
   
   return(error);
}

int OpenPendingOrder(string pSymbol,int pType,double pVolume,double pPrice,double pStop,double pProfit,string pComment,datetime pExpiration,color pArrow)
{
   int retryCount = 0;
	int ticket = 0;
	int errorCode = 0;
	int max_attempts = 5;

	string orderType;
	string errDesc;
	
	// Order retry loop
	while(retryCount <= max_attempts)
	{
		while(IsTradeContextBusy()) Sleep(10);
		ticket = OrderSend(pSymbol, pType, pVolume, pPrice, Slippage, pStop, pProfit, pComment, MagicNumber, pExpiration, pArrow);
		
		// Error handling
   	if(ticket == -1)
   	{
   		errorCode = GetLastError();
   		bool checkError = RetryOnError(errorCode);
      	
      	// Unrecoverable error
      	if(checkError == false)  
   		{
     			Alert("Open ",orderType," order: Error ",errorCode,".");
     			Print("Symbol: ",pSymbol,", Volume: ",pVolume,", Price: ",pPrice,", SL: ",pStop,", TP: ",pProfit,", Expiration: ",pExpiration);
   			break;
   		}
   		
   		// Retry on error
   		else
   		{
   			Print("Server error detected, retrying...");
   			Sleep(3000);
   			retryCount++;
   		}
   	}
   	
   	// Order successful
   	else
   	{
   	   Comment(orderType," order #",ticket," opened on ",_Symbol);
   	   Print(orderType," order #",ticket," opened on ",_Symbol);
   	   break;
   	} 
   }
   
   // Failed after retry
	if(retryCount > max_attempts)
	{
		Alert("Open ",orderType," order: Max retries exceeded. Error ",errorCode," - ",errDesc);
		Print("Symbol: ",pSymbol,", Volume: ",pVolume,", Price: ",pPrice,", SL: ",pStop,", TP: ",pProfit,", Expiration: ",pExpiration);
	}

	return(ticket);
}

bool RetryOnError(int pErrorCode)
{
	// Retry on these error codes
	switch(pErrorCode)
	{
		case ERR_BROKER_BUSY:
		case ERR_COMMON_ERROR:
		case ERR_NO_ERROR:
		case ERR_NO_CONNECTION:
		case ERR_NO_RESULT:
		case ERR_SERVER_BUSY:
		case ERR_NOT_ENOUGH_RIGHTS:
      case ERR_MALFUNCTIONAL_TRADE:
      case ERR_TRADE_CONTEXT_BUSY:
      case ERR_TRADE_TIMEOUT:
      case ERR_REQUOTE:
      case ERR_TOO_MANY_REQUESTS:
      case ERR_OFF_QUOTES:
      case ERR_PRICE_CHANGED:
      case ERR_TOO_FREQUENT_REQUESTS:
		
		return(true);
	}
	
	return(false);
}

int OpenMarketOrder(string pSymbol, int pType, double pVolume, string pComment, color pArrow)
{
	int retryCount = 0;
	int ticket = 0;
	int errorCode = 0;
	int max_attempts = 5;
	int wait_time = 3000;
	
	double orderPrice = 0;
	
	string orderType;
	string errDesc;
	
	// Order retry loop
	while(retryCount <= max_attempts) 
	{
		while(IsTradeContextBusy()) Sleep(10);
		
		// Get current bid/ask price
		if(pType == OP_BUY) orderPrice = MarketInfo(pSymbol,MODE_ASK);
		else if(pType == OP_SELL) orderPrice = MarketInfo(pSymbol,MODE_BID);

		// Place market order
		ticket = OrderSend(pSymbol,pType,pVolume,orderPrice,Slippage,0,0,pComment,MagicNumber,0,pArrow);
	   
		// Error handling
		if(ticket == -1)
		{
			errorCode = GetLastError();
			bool checkError = RetryOnError(errorCode);
			
			// Unrecoverable error
			if(checkError == false)
			{
				Alert("Open ",orderType," order: Error ",errorCode,".");
				Print("Symbol: ",pSymbol,", Volume: ",pVolume,", Price: ",orderPrice);
				break;
			}
			
			// Retry on error
			else
			{
				Print("Server error detected, retrying...");
				Sleep(wait_time);
				retryCount++;
			}
		}
		
		// Order successful
		else
		{
		   Comment(orderType," order #",ticket," opened on ",pSymbol);
		   Print(orderType," order #",ticket," opened on ",pSymbol);
		   break;
		} 
   }
   
   // Failed after retry
	if(retryCount > max_attempts)
	{
		Alert("Open ",orderType," order: Max retries exceeded. Error ",errorCode," - ",errDesc);
		Print("Symbol: ",pSymbol,", Volume: ",pVolume,", Price: ",orderPrice);
	}
   
   return(ticket);
} 

// Return trade size based on risk per trade of stop loss in points
double GetTradeSize(string pSymbol, double pFixedVol, double pPercent, int pStopPoints)
{
	double tradeSize;
	
	if(pPercent > 0 && pStopPoints > 0)
	{
		if(pPercent > 10) pPercent = 10;
		
		double margin = AccountInfoDouble(ACCOUNT_BALANCE) * (pPercent / 100);
		double tickSize = SymbolInfoDouble(pSymbol,SYMBOL_TRADE_TICK_VALUE);
		
		tradeSize = (margin / pStopPoints) / tickSize;
		tradeSize = CheckVolume(pSymbol,tradeSize);
		
		return(tradeSize);
	}
	else
	{
		tradeSize = pFixedVol;
		tradeSize = CheckVolume(pSymbol,tradeSize);
		
		return(tradeSize);
	}
}

// Create datetime value
datetime CreateDateTime(int pHour = 0, int pMinute = 0) 
{
	MqlDateTime timeStruct;
	TimeToStruct(TimeCurrent(),timeStruct);
	
	timeStruct.hour = pHour;
	timeStruct.min = pMinute;
	
	datetime useTime = StructToTime(timeStruct);
	
	return(useTime);
}

// Check timer
bool CheckDailyTimer()
{
   datetime TimeStart = CreateDateTime(StartHour, StartMinute);
   datetime TimeEnd = CreateDateTime(EndHour, EndMinute);
   
   datetime currentTime;
	if(UseLocalTime == true) currentTime = TimeLocal();
	else currentTime = TimeCurrent();
   
   // check if the timer goes over midnight
	if(TimeEnd <= TimeStart)	
	{
		TimeStart -= 86400;
		
		if(currentTime > TimeEnd)
		{
			TimeStart += 86400;
			TimeEnd += 86400;
		}
	} 
	
	bool timerOn = false;
	if(currentTime >= TimeStart && currentTime < TimeEnd) 
	{
		timerOn = true;
	}
	
	return(timerOn);
}


void FindOpenOrders()
{
   double largest_lots = 0;
   int ticket = -1;
   int open_orders = 0;
   int stopTicket = 0;
   for(int Counter = 0; Counter <= OrdersTotal()-1; Counter++)
   {
      if(OrderSelect(Counter,SELECT_BY_POS))
      {
         if(OrderMagicNumber() == MagicNumber && OrderSymbol() == _Symbol && (OrderType() == OP_BUY || OrderType() == OP_SELL))
         {
            open_orders++;
            if(OrderLots() > largest_lots)
            { 
               ticket = OrderTicket();
               largest_lots = OrderLots();
            }
         }
         if(OrderMagicNumber() == MagicNumber && OrderSymbol() == _Symbol && OrderType() == OP_BUYSTOP)
         {
            gBuyStopTicket = OrderTicket();
            stopTicket = gBuyStopTicket;
         } else if(OrderMagicNumber() == MagicNumber && OrderSymbol() == _Symbol && OrderType() == OP_SELLSTOP)
         {
            gSellStopTicket = OrderTicket();
            stopTicket = gSellStopTicket;
         }
      }
   }
   
   if(ticket > 0)
   {
      if(OrderSelect(ticket, SELECT_BY_TICKET))
      {
         int type = OrderType();
         if(type == OP_BUY)
         {
            gCurrentDirection = 1;
            gBuyTicket = ticket;
         } else if(type == OP_SELL)
         {
            gCurrentDirection = -1;
            gSellTicket = ticket;
         }   
         if(open_orders > 1) gRecoveryInitiated = true;
      }
      Print("Check for orders complete, resuming recovery direction of trade: ", ticket, " with recovery stop: ", stopTicket, " in place. ", open_orders, " orders already opened.");
   } else {
      Print("Check for orders complete, none currently open.");
   }     
}         

