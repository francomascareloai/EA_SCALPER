//+---------------------------------------------------------------------+
//|                                      BlessingLite 3 v3.9.6.34 gamma |
//|                                                    January 23, 2020 |
//|                                                                     |
//|     In no event will authors be liable for any damages whatsoever.  |
//|                         Use at your own risk.                       |
//|                                                                     |
//|  This EA is dedicated to Mike McKeough, a member of the Blessing    |
//|  Development Group, who passed away on Saturday, 31st July 2010.    |
//|  His contributions to the development of this EA have helped make   |
//|  it what it is today, and we will miss his enthusiasm, dedication   |
//|  and desire to make this the best EA possible.                      |
//|  Rest In Peace.                                                     |
//+---------------------------------------------------------------------+
// This work has been entered into the public domain by its authors ...
// Copyrights have been rescinded.
// this Lite version is based on the version v3.9.6.13 beta from www.forexfactory.com
// it is the approach of a strict complex version to enable multipair trading
// hedge function disabled and code cleared from it

#property version   "396.34"
#property strict

#include <stdlib.mqh>
#include <stderror.mqh>
#include <WinUser32.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>

#define A 1                     //All (Basket of all pairs)
#define B 2                     //Basket
#define T 4                     //Ticket
#define P 5                     //Pending

enum portChgs
  {
   no_change = 0,              // No changes
   increase = 1,               // Increase only
   any = -1,                   // Increase / decrease
  };

enum entType
  {
   disable = 0,                // Disabled
   enable = 1,                 // Enabled
   reverse = 2                 // Reverse
  };

enum tFrame
  {
   current = 0,                // Current
   m1 = 1,                     // M1
   m5 = 2,                     // M5
   m15 = 3,                    // M15
   m30 = 4,                    // M30
   h1 = 5,                     // H1
   h4 = 6,                     // H4
   d1 = 7,                     // Daily
   w1 = 8,                     // Weekly
   mn1 = 9                     // Monthly
  };


//+-----------------------------------------------------------------+
//| External Parameters Set                                         |
//+-----------------------------------------------------------------+

input string Version_3_9_6_34_gamma = "EA Settings:";
input string TradeComment = "BlessingLite 3.9.6.34 gamma";
input string Notes = "";
input int EANumber = 1681348112;         // EA Magic Number
input bool   UseDefaultPairs = true; // Use the default 28 pairs
input string OwnPairs = ""; // Comma separated own pair list

input bool Debug = false;

input bool EmergencyCloseAll = false;   // *** CLOSE ALL NOW ***

input string s1 = "";           //.
input bool ShutDown = false;    // *** NO NEW TRADES ***
input string s2 = "";           //.

input string LabelAcc = "";     // ==   ACCOUNT SETTINGS   ==
input double StopTradePercent = 10;    // Percentage of balance lost before trading stops

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input bool NanoAccount = false;        // Small Lot Account (0.01)
input double PortionPC = 100;  // Percentage of account you want to trade (on this pair) -->divided by Numer of Pairs?
input portChgs PortionChange = increase;       // Permitted Portion change with open basket
// If basket open: 0=no Portion change;1=allow portion to increase; -1=allow increase and decrease
input double MaxDDPercent = 90;        // Percent of portion for max drawdown level.
input double MaxSpread = 10;    // Maximum allowed spread while placing trades
input bool UseHolidayShutdown = false;  // Enable holiday shut-downs
input string Holidays = "18/12-01/01"; // Comma-separated holiday list (format: [day]/[mth]-[day]/[mth])
input bool PlaySounds = false; // Audible alerts
input string AlertSound = "Alert.wav"; // Alert sound

input string eopb = "";         // -- Opt. with 'Open prices only' --
// input string   eopb0                   = "Filters out ticks"; //. 
input bool EnableOncePerBar = true;
input bool UseMinMarginPercent = false;
input double MinMarginPercent = 1500;
input string eopb1 = "";        //. 

input bool B3Traditional = true;       // Stop/Limits for entry if true, Buys/Sells if false


input bool UseAnyEntry = false;        // true = ANY entry can be used to open orders, false = ALL entries used to open orders
// input entType  MAEntry            = 1; // MA Entry
// input entType  CCIEntry           = 0; // CCI Entry
// input entType  BollingerEntry     = 0; // Bollinger Entry
// input entType  StochEntry         = 0; // Stochastic Entry
// input entType  MACDEntry          = 0; // MACD Entry
// 0=disable 1=enable 2=reverse

input string LabelLS = "";      // -----------   LOT SIZE   -----------
input bool UseMM = false;        // UseMM   (Money Management)
input double LAF = 0.5;        // Adjusts MM base lot for large accounts
input double Lot = 0.01;       // Starting lots if Money Management is off
input double Multiplier = 3.0; // Multiplier on each level

input string LabelGS = "";      // ------     GRID SETTINGS    ------
input bool AutoCal = false;    // Auto calculation of TakeProfit and Grid size;
input tFrame ATRTF = 0;        // TimeFrame for ATR calculation
input int ATRPeriods = 5;     // Number of periods for the ATR calculation
input double GAF = 1.1;        // Widens/Squishes Grid in increments/decrements of .1
input int EntryDelay = 1200;   // Time Grid in seconds, avoid opening lots of levels in fast market
input double EntryOffset = 0;  // In pips, used in conjunction with logic to offset first trade entry
input bool UseSmartGrid = false;        // True = use RSI/MA calculation for next grid order

input string LabelTS = "";      // =====    TRADING    =====
input int MaxTrades = 15;      // Maximum number of trades to place (stops placing orders when reaches MaxTrades)
input int BreakEvenTrade = 5; // Close All level, when reaches this level, doesn't wait for TP to be hit
input double BEPlusPips = -5;   // Pips added to Break Even Point before BE closure
input bool UseCloseOldest = false;     // True = will close the oldest open trade after CloseTradesLevel is reached
input int CloseTradesLevel = 5;        // will start closing oldest open trade at this level
input bool ForceCloseOldest = true;    // Will close the oldest trade whether it has potential profit or not
input int MaxCloseTrades = 4;  // Maximum number of oldest trades to close
input double CloseTPPips = 10; // After Oldest Trades have closed, Forces Take Profit to BE +/- xx Pips
input double ForceTPPips = 0;  // Force Take Profit to BE +/- xx Pips
input double MinTPPips = 0;    // Ensure Take Profit is at least BE +/- xx Pips


input string LabelES = "";      // -----------     EXITS    -----------
input bool MaximizeProfit = true;     // Turns on TP move and Profit Trailing Stop Feature
input double ProfitSet = 50;   // Profit trailing stop: Lock in profit at set percent of Total Profit Potential
input double MoveTP = 2;      // Moves TP this amount in pips
input int TotalMoves = 2;      // Number of times you want TP to move before stopping movement
input bool UseStopLoss = false;        // Use Stop Loss and/or Trailing Stop Loss
input double SLPips = 30;      // Pips for fixed StopLoss from BE, 0=off
input double TSLPips = 10;     // Pips for trailing stop loss from BE + TSLPips: +ve = fixed trail; -ve = reducing trail; 0=off
input double TSLPipsMin = 3;   // Minimum trailing stop pips if using reducing TS
input bool UsePowerOutSL = false;      // Transmits a SL in case of internet loss
input double POSLPips = 600;   // Power Out Stop Loss in pips
input bool UseFIFO = false;    // Close trades in FIFO order

input string LabelEE = "";      // ---------   EARLY EXITS   ---------
input bool UseEarlyExit = false;       // Reduces ProfitTarget by a percentage over time and number of levels open
input double EEStartHours = 3; // Number of Hours to wait before EE over time starts
input bool EEFirstTrade = true;        // true = StartHours from FIRST trade: false = StartHours from LAST trade
input double EEHoursPC = 0.5;  // Percentage reduction per hour (0 = OFF)
input int EEStartLevel = 5;    // Number of Open Trades before EE over levels starts
input double EELevelPC = 10;   // Percentage reduction at each level (0 = OFF)
input bool EEAllowLoss = false;        // true = Will allow the basket to close at a loss : false = Minimum profit is Break Even

input string LabelAdv = "";     //.
input string LabelGrid = "";    // ---------    GRID SIZE   ---------
input string SetCountArray = "3,2,2,2";    // Specifies number of open trades in each block (separated by a comma)
input string GridSetArray = "55,100,115,160";       // Specifies number of pips away to issue limit order (separated by a comma)
input string TP_SetArray = "10,15,15,15";       // Take profit for each block (separated by a comma)

// input entType 0=disable 1=enable 2=reverse
input string LabelEST0 = "";    // .
input string LabelEST = "";     // ==  ENTRY PARAMETERS  ==
input string LabelMA = "";      // -------------     MA     -------------
input entType MAEntry = 0;     // MA Entry
input int MAPeriod = 100;      // Period of MA (H4 = 100, H1 = 400)
input double MADistance = 10;  // Distance from MA to be treated as Ranging Market

input string LabelCCI = "";     // -------------     CCI     -------------
input entType CCIEntry = 0;    // CCI Entry
input int CCIPeriod = 14;      // Period for CCI calculation

input string LabelBBS = "";     // -----   BOLLINGER BANDS   -----
input entType BollingerEntry = 1;      // Bollinger Entry
input int BollPeriod = 20;     // Period for Bollinger
input double BollDistance = -1;        // Up/Down spread
input double BollDeviation = 3.0;      // Standard deviation multiplier for channel

input string LabelSto = "";     // ---------   STOCHASTIC   --------
input entType StochEntry = 0;  // Stochastic Entry
input int BuySellStochZone = 20;       // Determines Overbought and Oversold Zones
input int KPeriod = 10;        // Stochastic KPeriod
input int DPeriod = 2;         // Stochastic DPeriod
input int Slowing = 2;         // Stochastic Slowing

input string LabelMACD = "";    //  ------------    MACD    ------------
input entType MACDEntry = 0;   // MACD Entry
input tFrame MACD_TF = 0;      // Time frame for MACD calculation
// 0:Chart, 1:M1, 2:M5, 3:M15, 4:M30, 5:H1, 6:H4, 7:D1, 8:W1, 9:MN1
input int FastPeriod = 12;     // MACD EMA Fast Period
input int SlowPeriod = 26;     // MACD EMA Slow Period
input int SignalPeriod = 9;    // MACD EMA Signal Period
input ENUM_APPLIED_PRICE MACDPrice = PRICE_CLOSE;        // MACD Applied Price
// 0=close, 1=open, 2=high, 3=low, 4=HL/2, 5=HLC/3 6=HLCC/4

input string LabelSG = "";      // ---------   SMART GRID   ---------
input tFrame RSI_TF = 3;       // Timeframe for RSI calculation (should be lower than chart TF)
input int RSI_Period = 14;     // Period for RSI calculation
input ENUM_APPLIED_PRICE RSI_Price = PRICE_CLOSE;        // RSI Applied Price
// 0=close, 1=open, 2=high, 3=low, 4=HL/2, 5=HLC/3 6=HLCC/4
input int RSI_MA_Period = 10;  // Period for MA of RSI calculation
input ENUM_MA_METHOD RSI_MA_Method = MODE_SMA;        // RSI MA Method
//0=Simple averaging, 1=Exponential averaging, 2=Smoothed averaging 3=Linear-weighted averaging

input string LabelOS0 = "";     //.
input string LabelOS = "";      // ------------   OTHER   -----------
input bool RecoupClosedLoss = true;    // true = Recoup any CloseOldest losses: false = Use original profit target.
input int Level = 7;           // Largest Assumed Basket size.  Lower number = higher start lots
int slip = 99;
input bool SaveStats = false;  // true = will save equity statistics
input int StatsPeriod = 3600;  // seconds between stats entries - off by default
input bool StatsInitialise = true;     // true for backtest - false for forward/live to ACCUMULATE equity traces

input string LabelUE = "";      // ------------   EMAIL   ------------
input bool UseEmail = false;
input string LabelEDD = "At what DD% would you like Email warnings (Max: 49, Disable: 0)?";     //.
input double EmailDD1 = 20;
input double EmailDD2 = 30;
input double EmailDD3 = 40;

input string LabelEH = "Hours before DD timer resets";  //.
input double EmailHours = 24;  // Minimum number of hours between emails

string LabelDisplay = ""; // ------------   DISPLAY   -----------
// input string   LabelDisplay       = "Used to Adjust Overlay"; //.
bool displayOverlay = true;      // Enable display
bool displayLogo = true; // Display copyright and icon
string displayFont = "Courier Bold";        //Display font
int displayFontSize = 9; // Changes size of display characters
int displaySpacing = 14; // Changes space between lines
// color displayColor = DeepSkyBlue;        // default color of display characters
color displayColorProfit = Green;        // default color of profit display characters
color displayColorLoss = Red;    // default color of loss display characters
color displayColorFGnd = White;  // default color of ForeGround Text display characters

string DefaultPairs[] = {"AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY","CHFJPY","EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD","EURUSD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD","NZDCAD","NZDCHF","NZDJPY","NZDUSD","USDCAD","USDCHF","USDJPY"};
string TradePairs[];

//+-----------------------------------------------------------------+
//| Internal Parameters Set                                         |
//+-----------------------------------------------------------------+
// int POSLCount; //not used!!
int Magic;
int AccountType;

double StopTradeBalance;
bool Testing, Visual;
bool AllowTrading;
bool EmergencyWarning;
int Error;

int ca; //close all type

int Set1Level, Set2Level, Set3Level, Set4Level;
int EmailCount;
string sTF;
datetime EmailSent;

int GridArray[, 2];

string CS, UAE;
int HolShutDown;
// datetime HolArray[, 4];
int HolArray[, 4];
datetime HolFirst, HolLast, NextStats;
int Digit[, 2], TF[10] = { 0, 1, 5, 15, 30, 60, 240, 1440, 10080, 43200 };
double InitialAB;               // Initial Account Balance --> global variable?
double Email[3];
double  StatLowEquity, StatHighEquity;
datetime EETime;
int  EECount, FileHandle;
bool FileClosed, FirstRun, dLabels;
string FileName, ID, StatFile;

bool checkResult;

string suffix="";
string prefix="";

// This is the struct that is used by any of the pairs-to-trade
struct pairinf
  {
   int               CbB;                // Count buy
   int               CbS;                // Count sell
   int               CpBL;               // Count buy limit
   int               CpSL;               // Count sell limit
   int               CpBS;               // Count buy stop
   int               CpSS;               // Count sell stop
   double            LbB;             // Count buy lots
   double            LbS;             // Count sell lots
   // double   LbT          =0;     // total lots out
   double            OPpBL;           // Buy limit open price
   double            OPpSL;           // Sell limit open price
   double            SLbB;            // stop losses are set to zero if POSL off
   double            SLbS;            // stop losses are set to zero if POSL off
   double            BCb, BCa;       // Broker costs (swap + commission)
   double            ProfitPot;       // The Potential Profit of a basket of Trades
   double            PipValue, PipVal2, ASK, BID;
   double            OrderLot;
   double            OPbL;  // last open price
   datetime          OTbL;          // last open time
   datetime          OTbO;
   double            g2, tp2, Entry, RSI_MA, OPbO;
   int               Ticket, IndEntry, TbO;
   double            Pb, PaC, PbPips, PbTarget, DrawDownPC, BEb, BEa;
   bool              TradesOpen, BuyMe, SellMe, Success, SetPOSL;
   string            IndicatorUsed;
   double            EEpc, OPbN, nLots;
   double            bSL, TPa, TPbMP;
   int               Trend;
   string            ATrend;
   double            cci_01, cci_02, cci_03, cci_04;
   double            cci_11, cci_12, cci_13, cci_14;
   double            StopLevel;
   datetime          OTbF;
   int               CaL, CbC, TbF;
   double            bTS, TPb, LbF, PbC, ClosedPips;
   int               CbT, CpT;              // Count basket Total,Count pending Total
   double            PbMax, PbMin, PortionBalance, MaxDD, MaxDDPer;
   int               LotDecimal, MinMult, LotMult;
   double            Lots[];
   double            RSI[];
   double            TargetPips;
   double            SLbL;                    // Stop Loss basket Last
   double            SLb;                     // Stop Loss
   int               Moves;
   bool              PendLot;
   datetime          OncePerBarTime;
   double            Pip;
   double            MoveTP_;
   double            EntryOffset_;
   double            MADistance_;
   double            BollDistance_;
   double            POSLPips_;
   double            CloseTPPips_;
   double            ForceTPPips_;
   double            MinTPPips_;
   double            BEPlusPips_;
   double            SLPips_;
   double            TSLPips_;
   double            TSLPipsMin_;
   double            Lot_;
   double            MinLotSize, LotStep;
   double            GridTP;
   
   double            BCaL, BEbL;
  };
pairinf pairinfo[];


//+-----------------------------------------------------------------+
//| Input Parameters Requiring Modifications To Entered Values      |
//+-----------------------------------------------------------------+
// --> still open to see whether some of them have to be moved into the pairs struct

int EANumber_;
double StopTradePercent_;
double ProfitSet_;
double EEHoursPC_;
double EELevelPC_;
double PortionPC_;
bool Debug_; //okay

//which Entry Indicators to be used:
entType MAEntry_;
entType CCIEntry_;
entType BollingerEntry_;
entType StochEntry_;
entType MACDEntry_;

int MaxCloseTrades_;
double Multiplier_;
string SetCountArray_;
string GridSetArray_;
string TP_SetArray_;
bool EmergencyCloseAll_;
bool ShutDown_;

double LbT = 0;                 // total lots out
double previous_stop_trade_amount;
double stop_trade_amount;


//+-----------------------------------------------------------------+
//| expert initialization function                                  |
//+-----------------------------------------------------------------+
int OnInit()
  {
   EANumber_ = EANumber;
   StopTradePercent_ = StopTradePercent;
   ProfitSet_ = ProfitSet;
   EEHoursPC_ = EEHoursPC;
   EELevelPC_ = EELevelPC;
   PortionPC_ = PortionPC;
   Debug_ = Debug;
   MAEntry_ = MAEntry;
   CCIEntry_ = CCIEntry;
   BollingerEntry_ = BollingerEntry;
   StochEntry_ = StochEntry;
   MACDEntry_ = MACDEntry;
   MaxCloseTrades_ = MaxCloseTrades;
   Multiplier_ = Multiplier;
   SetCountArray_ = SetCountArray;
   GridSetArray_ = GridSetArray;
   TP_SetArray_ = TP_SetArray;
   EmergencyCloseAll_ = EmergencyCloseAll;
   ShutDown_ = ShutDown;
   
   getPrefixSuffix(prefix,suffix);
   if(UseDefaultPairs == true)
      ArrayCopy(TradePairs,DefaultPairs);
   else
      StringSplit(OwnPairs,',',TradePairs);

   if(ArraySize(TradePairs) <= 0)
     {
      Print("No pairs to trade");
      return(INIT_FAILED);
     }

   ArrayResize(pairinfo,ArraySize(TradePairs));

   ChartSetInteger(0, CHART_SHOW_GRID, false);
   CS = "Waiting for next tick .";     // To display comments while testing, simply use CS = .... and
   Comment(CS);                // it will be displayed by the line at the end of the start() block.
   CS = "";
   Testing = IsTesting();
   Visual = IsVisualMode();
   AllowTrading = true;
   FirstRun = true;
   if(EANumber_ < 1)
      EANumber_ = 1;

   if(Testing)
      EANumber_ = 0;

   Magic = 1681348112;
   FileName = "B3_" + (string) Magic + ".dat";

   if(Debug_)
     {
      Print("Magic Number: ", DTS(Magic, 0));
      Print("FileName: ", FileName);
      for (int Index=0;Index<ArraySize(TradePairs);Index++){
      Print("Pip: ",DoubleToStr(MarketInfo(TradePairs[Index]+suffix,MODE_POINT),8));
      Print("Digits: ",DTS(MarketInfo(TradePairs[Index]+suffix,MODE_DIGITS),8));
      }
     }

   if(NanoAccount)
      AccountType = 10;
   else
      AccountType = 1;
 
int temp;
      
   for (int Index=0;Index<ArraySize(TradePairs);Index++){
      pairinfo[Index].Pip = MarketInfo(TradePairs[Index]+suffix,MODE_POINT);
      temp = (int) MarketInfo(TradePairs[Index]+suffix,MODE_DIGITS);
      if(temp % 2 == 1)pairinfo[Index].Pip *= 10;
      pairinfo[Index].MoveTP_ = ND(MoveTP * pairinfo[Index].Pip, temp);
      pairinfo[Index].EntryOffset_ = ND(EntryOffset * pairinfo[Index].Pip, temp);
      pairinfo[Index].MADistance_ = ND(MADistance * pairinfo[Index].Pip, temp);
      pairinfo[Index].BollDistance_ = ND(BollDistance * pairinfo[Index].Pip, temp);
      pairinfo[Index].POSLPips_ = ND(POSLPips * pairinfo[Index].Pip, temp);
      pairinfo[Index].CloseTPPips_ = ND(CloseTPPips * pairinfo[Index].Pip, temp);
      pairinfo[Index].ForceTPPips_ = ND(ForceTPPips * pairinfo[Index].Pip, temp);
      pairinfo[Index].MinTPPips_ = ND(MinTPPips * pairinfo[Index].Pip, temp);
      pairinfo[Index].BEPlusPips_ = ND(BEPlusPips * pairinfo[Index].Pip, temp);
      pairinfo[Index].SLPips_ = ND(SLPips * pairinfo[Index].Pip, temp);
      pairinfo[Index].TSLPips_ = ND(TSLPips * pairinfo[Index].Pip, temp);
      pairinfo[Index].TSLPipsMin_ = ND(TSLPipsMin * pairinfo[Index].Pip, temp);
      pairinfo[Index].BCaL = 0;
      pairinfo[Index].BEbL = 0;
   }

   StopTradePercent_ /= 100;
   ProfitSet_ /= 100;
   EEHoursPC_ /= 100;
   EELevelPC_ /= 100;
   PortionPC_ /= 100;

   InitialAB = AccountBalance();
   StopTradeBalance = InitialAB * (1 - StopTradePercent_);

   if(Testing)
      ID = "B3Test.";
   else
      ID = DTS(Magic, 0) + ".";

   HideTestIndicators(true);

   double MinLot=0;   
   for (int Index=0;Index<ArraySize(TradePairs);Index++){
      pairinfo[Index].Lot_ = Lot;
      pairinfo[Index].MinLotSize = MarketInfo(TradePairs[Index]+suffix, MODE_MINLOT);
      if(pairinfo[Index].MinLotSize > pairinfo[Index].Lot_)
        {   
         Print("Lot is less than minimum lot size permitted for this account");
         AllowTrading = false;
        }
         pairinfo[Index].LotStep = MarketInfo(TradePairs[Index]+suffix, MODE_LOTSTEP);
         MinLot = MathMin(pairinfo[Index].MinLotSize, pairinfo[Index].LotStep);  
         if (MinLot ==0)
         {   
         Print("No MarketInfo for"+TradePairs[Index]+suffix);
         AllowTrading = false;
         }
         else pairinfo[Index].LotMult = (int) ND(MathMax(pairinfo[Index].Lot_, pairinfo[Index].MinLotSize) / MinLot, 0);
         pairinfo[Index].MinMult = pairinfo[Index].LotMult;
         pairinfo[Index].Lot_ = MinLot;

         pairinfo[Index].OncePerBarTime = 0;

      if(MinLot < 0.01)
         pairinfo[Index].LotDecimal = 3;
      else
         if(MinLot < 0.1)
            pairinfo[Index].LotDecimal = 2;
         else
            if(MinLot < 1)
               pairinfo[Index].LotDecimal = 1;
           else
               pairinfo[Index].LotDecimal = 0;}

//what is happening here? Do we need this part?
   FileHandle = FileOpen(FileName, FILE_BIN | FILE_READ);

   if(FileHandle != -1)
     {
      pairinfo[0].TbF = FileReadInteger(FileHandle, LONG_VALUE);
      FileClose(FileHandle);
      Error = GetLastError();

      if(OrderSelect(pairinfo[0].TbF, SELECT_BY_TICKET))
        {
        for (int Index=0;Index<ArraySize(TradePairs);Index++){
         pairinfo[Index].OTbF = OrderOpenTime();
         pairinfo[Index].LbF = OrderLots();
         MinLot = MathMin(pairinfo[Index].MinLotSize, pairinfo[Index].LotStep);  
         if (MinLot ==0)
         {   
         Print("No MarketInfo for"+TradePairs[Index]+suffix);
         AllowTrading = false;
         }
         else pairinfo[Index].LotMult = (int) MathMax(1, pairinfo[Index].LbF / MinLot);
         pairinfo[Index].PbC = FindClosedPL(B, pairinfo[Index].OTbF,pairinfo[Index].CbC);
         pairinfo[Index].TradesOpen = true;
         if(Debug_)
            Print(FileName, " File Read: ", pairinfo[0].TbF, " Lots: ", DTS(pairinfo[Index].LbF, pairinfo[Index].LotDecimal));}
        }
      else
        {
         FileDelete(FileName);
         for (int Index=0;Index<ArraySize(TradePairs);Index++){
         pairinfo[Index].TbF = 0;
         pairinfo[Index].OTbF = 0;
         pairinfo[Index].LbF = 0;
         GlobalVariableSet(ID + "LotMult", pairinfo[Index].LotMult);
         }
         Error = GetLastError();

         if(Error == ERR_NO_ERROR)
           {
            if(Debug_)
               Print(FileName, " File Deleted");
           }
         else
            Print("Error ", Error, " (", ErrorDescription(Error), ") deleting file ", FileName);
        }
     }


   EmergencyWarning = EmergencyCloseAll_;

   if(IsOptimization())
      Debug_ = false;

   if(UseAnyEntry)
      UAE = "||";
   else
      UAE = "&&";

   if(MAEntry_ < 0 || MAEntry_ > 2)
      MAEntry_ = 0;

   if(CCIEntry_ < 0 || CCIEntry_ > 2)
      CCIEntry_ = 0;

   if(BollingerEntry_ < 0 || BollingerEntry_ > 2)
      BollingerEntry_ = 0;

   if(StochEntry_ < 0 || StochEntry_ > 2)
      StochEntry_ = 0;

   if(MACDEntry_ < 0 || MACDEntry_ > 2)
      MACDEntry_ = 0;

   if(MaxCloseTrades_ == 0)
      MaxCloseTrades_ = MaxTrades;

   ArrayResize(Digit, 6);
   for(int Index = 0; Index < ArrayRange(Digit, 0); Index++)
     {
      if(Index > 0)
         Digit[Index, 0] = (int) MathPow(10, Index);

      Digit[Index, 1] = Index;

      if(Debug_)
         Print("Digit: ", Index, " [", Digit[Index, 0], ", ", Digit[Index, 1], "]");
     }

   dLabels = false;

//+-----------------------------------------------------------------+
//| Set Lot and RSI Array for each pair                             |
//+-----------------------------------------------------------------+


   for (int Index2=0; Index2 <ArraySize(TradePairs); Index2++){
      ArrayResize(pairinfo[Index2].Lots, MaxTrades);
      ArrayResize(pairinfo[Index2].RSI, (RSI_Period+RSI_MA_Period));
     for (int Index = 0; Index < MaxTrades; Index++) {
        if (Index == 0 || Multiplier_ < 1)
            pairinfo[Index2].Lots[Index] = pairinfo[Index2].Lot_;
        else
            pairinfo[Index2].Lots[Index] = ND(MathMax(pairinfo[Index2].Lots[Index - 1] * Multiplier_, pairinfo[Index2].Lots[Index - 1] + pairinfo[Index2].LotStep), pairinfo[Index2].LotDecimal);

        if (Debug_)
            Print("Lot Size for level ", DTS(Index + 1, 0), " : ", DTS(pairinfo[Index2].Lots[Index] * MathMax(pairinfo[Index2].LotMult, 1), pairinfo[Index2].LotDecimal));
    }
}

   if(Multiplier_ < 1)
      Multiplier_ = 1;

//+-----------------------------------------------------------------+
//| Set Grid and TP array --> needs to be modified for multipairs?? |
//+-----------------------------------------------------------------+
   int GridSet = 0, GridTemp, GridTP, GridIndex = 0, GridLevel = 0, GridError = 0;

   if(!AutoCal)
     {
      ArrayResize(GridArray, MaxTrades);
      while(GridIndex < MaxTrades)
        {
         if(StringFind(SetCountArray_, ",") == -1 && GridIndex == 0)
           {
            GridError = 1;
            break;
           }
         else
            GridSet = StrToInteger(StringSubstr(SetCountArray_, 0, StringFind(SetCountArray_, ",")));

         if(GridSet > 0)
           {
            SetCountArray_ = StringSubstr(SetCountArray_, StringFind(SetCountArray_, ",") + 1);
            GridTemp = StrToInteger(StringSubstr(GridSetArray_, 0, StringFind(GridSetArray_, ",")));
            GridSetArray_ = StringSubstr(GridSetArray_, StringFind(GridSetArray_, ",") + 1);
            GridTP = StrToInteger(StringSubstr(TP_SetArray_, 0, StringFind(TP_SetArray_, ",")));
            TP_SetArray_ = StringSubstr(TP_SetArray_, StringFind(TP_SetArray_, ",") + 1);
           }
         else
            GridSet = MaxTrades;

         if(GridTemp == 0 || GridTP == 0)
           {
            GridError = 2;
            break;
           }

         for(GridLevel = GridIndex; GridLevel <= MathMin(GridIndex + GridSet - 1, MaxTrades - 1); GridLevel++)
           {
            GridArray[GridLevel, 0] = GridTemp;
            GridArray[GridLevel, 1] = GridTP;

            if(Debug_)
               Print("GridArray ", (GridLevel + 1), ": [", GridArray[GridLevel, 0], ", ", GridArray[GridLevel, 1], "]");
           }

         GridIndex = GridLevel;
        }

      if(GridError > 0 || GridArray[0, 0] == 0 || GridArray[0, 1] == 0)
        {
         if(GridError == 1)
            Print("Grid Array Error. Each value should be separated by a comma.");
         else
            Print("Grid Array Error. Check that there is one more 'Grid' and 'TP' entry than there are 'Set' numbers - separated by commas.");

         AllowTrading = false;
        }
     }
   else //if Autocal
     {
      while(GridIndex < 4)
        {
         GridSet = StrToInteger(StringSubstr(SetCountArray_, 0, StringFind(SetCountArray_, ",")));
         SetCountArray_ = StringSubstr(SetCountArray_, StringFind(SetCountArray_, DTS(GridSet, 0)) + 2);

         if(GridIndex == 0 && GridSet < 1)
           {
            GridError = 1;
            break;
           }

         if(GridSet > 0)
            GridLevel += GridSet;
         else
            if(GridLevel < MaxTrades)
               GridLevel = MaxTrades;
            else
               GridLevel = MaxTrades + 1;

         if(GridIndex == 0)
            Set1Level = GridLevel;
         else
            if(GridIndex == 1 && GridLevel <= MaxTrades)
               Set2Level = GridLevel;
            else
               if(GridIndex == 2 && GridLevel <= MaxTrades)
                  Set3Level = GridLevel;
               else
                  if(GridIndex == 3 && GridLevel <= MaxTrades)
                     Set4Level = GridLevel;

         GridIndex++;
        }

      if(GridError == 1 || Set1Level == 0)
        {
         Print("Error setting up Grid Levels. Check that the SetCountArray contains valid numbers separated by commas.");
         AllowTrading = false;
        }
     }

// here we should copy the above grid into the pairinfo[].grid

//+-----------------------------------------------------------------+
//| Set holidays array                                              |
//+-----------------------------------------------------------------+
   if(UseHolidayShutdown)
     {
      int HolTemp = 0, NumHols, NumBS = 0, HolCounter = 0;
      string HolTempStr;

      // holidays are separated by commas
      // 18/12-01/01
      if(StringFind(Holidays, ",", 0) == -1)    // no comma if just one holiday
        {
         NumHols = 1;
        }
      else
        {
         NumHols = 1;
         while(HolTemp != -1)
           {
            HolTemp = StringFind(Holidays, ",", HolTemp + 1);
            if(HolTemp != -1)
               NumHols++;
           }
        }
      HolTemp = 0;
      while(HolTemp != -1)
        {
         HolTemp = StringFind(Holidays, "/", HolTemp + 1);
         if(HolTemp != -1)
            NumBS++;
        }

      if(NumBS != NumHols * 2)
        {
         Print("Holidays Error, number of back-slashes (", NumBS, ") should be equal to 2* number of Holidays (",
               NumHols, ", and separators should be commas.");
         AllowTrading = false;
        }
      else
        {
         HolTemp = 0;
         ArrayResize(HolArray, NumHols);
         while(HolTemp != -1)
           {
            if(HolTemp == 0)
               HolTempStr = StringTrimLeft(StringTrimRight(StringSubstr(Holidays, 0, StringFind(Holidays, ",", HolTemp))));
            else
               HolTempStr = StringTrimLeft(StringTrimRight(StringSubstr(Holidays, HolTemp + 1,
                                           StringFind(Holidays, ",", HolTemp + 1) - StringFind(Holidays, ",", HolTemp) - 1)));

            HolTemp = StringFind(Holidays, ",", HolTemp + 1);
            HolArray[HolCounter, 0] = StrToInteger(StringSubstr(StringSubstr(HolTempStr, 0, StringFind(HolTempStr, "-", 0)),
                                                   StringFind(StringSubstr(HolTempStr, 0, StringFind(HolTempStr, "-", 0)), "/") + 1));
            HolArray[HolCounter, 1] = StrToInteger(StringSubstr(StringSubstr(HolTempStr, 0, StringFind(HolTempStr, "-", 0)), 0,
                                                   StringFind(StringSubstr(HolTempStr, 0, StringFind(HolTempStr, "-", 0)), "/")));
            HolArray[HolCounter, 2] = StrToInteger(StringSubstr(StringSubstr(HolTempStr, StringFind(HolTempStr, "-", 0) + 1),
                                                   StringFind(StringSubstr(HolTempStr, StringFind(HolTempStr, "-", 0) + 1), "/") + 1));
            HolArray[HolCounter, 3] = StrToInteger(StringSubstr(StringSubstr(HolTempStr, StringFind(HolTempStr, "-", 0) + 1), 0,
                                                   StringFind(StringSubstr(HolTempStr, StringFind(HolTempStr, "-", 0) + 1), "/")));
            HolCounter++;
           }
        }

      for(HolTemp = 0; HolTemp < HolCounter; HolTemp++)
        {
         datetime Start1, Start2;
         int Temp0, Temp1, Temp2, Temp3;
         for(int Item1 = HolTemp + 1; Item1 < HolCounter; Item1++)
           {
            Start1 = (datetime) HolArray[HolTemp, 0] * 100 + HolArray[HolTemp, 1];
            Start2 = (datetime) HolArray[Item1, 0] * 100 + HolArray[Item1, 1];
            if(Start1 > Start2)
              {
               Temp0 = HolArray[Item1, 0];
               Temp1 = HolArray[Item1, 1];
               Temp2 = HolArray[Item1, 2];
               Temp3 = HolArray[Item1, 3];
               HolArray[Item1, 0] = HolArray[HolTemp, 0];
               HolArray[Item1, 1] = HolArray[HolTemp, 1];
               HolArray[Item1, 2] = HolArray[HolTemp, 2];
               HolArray[Item1, 3] = HolArray[HolTemp, 3];
               HolArray[HolTemp, 0] = Temp0;
               HolArray[HolTemp, 1] = Temp1;
               HolArray[HolTemp, 2] = Temp2;
               HolArray[HolTemp, 3] = Temp3;
              }
           }
        }

      if(Debug_)
        {
         for(HolTemp = 0; HolTemp < HolCounter; HolTemp++)
            Print("Holidays - From: ", HolArray[HolTemp, 1], "/", HolArray[HolTemp, 0], " - ",
                  HolArray[HolTemp, 3], "/", HolArray[HolTemp, 2]);
        }
     }
//+-----------------------------------------------------------------+
//| Set email parameters                                            |
//+-----------------------------------------------------------------+
   if(UseEmail)
     {
      if(Period() == 43200)
         sTF = "MN1";
      else
         if(Period() == 10800)
            sTF = "W1";
         else
            if(Period() == 1440)
               sTF = "D1";
            else
               if(Period() == 240)
                  sTF = "H4";
               else
                  if(Period() == 60)
                     sTF = "H1";
                  else
                     if(Period() == 30)
                        sTF = "M30";
                     else
                        if(Period() == 15)
                           sTF = "M15";
                        else
                           if(Period() == 5)
                              sTF = "M5";
                           else
                              if(Period() == 1)
                                 sTF = "M1";

      Email[0] = MathMax(MathMin(EmailDD1, MaxDDPercent - 1), 0) / 100;
      Email[1] = MathMax(MathMin(EmailDD2, MaxDDPercent - 1), 0) / 100;
      Email[2] = MathMax(MathMin(EmailDD3, MaxDDPercent - 1), 0) / 100;
      ArraySort(Email, WHOLE_ARRAY, 0, MODE_ASCEND);

      for(int z = 0; z <= 2; z++)
        {
         for(int Index = 0; Index <= 2; Index++)
           {
            if(Email[Index] == 0)
              {
               Email[Index] = Email[Index + 1];
               Email[Index + 1] = 0;
              }
           }

         if(Debug_)
            Print("Email [", (z + 1), "] : ", Email[z]);
        }
     }
//+-----------------------------------------------------------------+
//| Set SmartGrid parameters                                        |
//+-----------------------------------------------------------------+
   if(UseSmartGrid)
     {
     for (int Index=0;Index<ArraySize(TradePairs);Index++){
      ArrayResize(pairinfo[Index].RSI, RSI_Period + RSI_MA_Period);
      ArraySetAsSeries(pairinfo[Index].RSI, true);
      }
     }
//+---------------------------------------------------------------+
//| Initialize Statistics                                         |
//+---------------------------------------------------------------+
   if(SaveStats)
     {
      StatFile = "B3" + Symbol() + "_" + (string) Period() + "_" + (string) EANumber_ + ".csv";
      NextStats = TimeCurrent();
      Stats(StatsInitialise, false, AccountBalance() * PortionPC_, 0);
     }

   return (0);
  }

//+-----------------------------------------------------------------+
//| expert deinitialization function                                |
//+-----------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   switch(reason)
     {
      case REASON_REMOVE:
      case REASON_CHARTCLOSE:
      case REASON_CHARTCHANGE:
//close all pending orders
      for (int Index=0;Index<ArraySize(TradePairs);Index++){
         if(pairinfo[Index].CpT > 0)
           {
            while(pairinfo[Index].CpT > 0)
               pairinfo[Index].CpT -= ExitTrades(P, displayColorLoss, "Blessing Removed",0,ca,TradePairs[Index]+suffix);
           }
      }
         GlobalVariablesDeleteAll(ID);
      case REASON_RECOMPILE:
      case REASON_PARAMETERS:
      case REASON_ACCOUNT:;

         Comment("Reason:"+IntegerToString(reason));

     }

   return;
  }


//+-----------------------------------------------------------------+
//| expert start function                                           |
//+-----------------------------------------------------------------+
void OnTick()
{
int retValue = DoStart();
}

int DoStart()

{	if (Debug_) printf("!!!!!!!!!!!!!!!!!!!start!!!!!!!!!!!!");



      //+-----------------------------------------------------------------+
      //| Check Holiday Shutdown                                          |
      //+-----------------------------------------------------------------+
      
      if(UseHolidayShutdown)
        {
         if(HolShutDown > 0 && TimeCurrent() >= HolLast && HolLast > 0)
           {
            Print("Trading has resumed after the ", TimeToStr(HolFirst, TIME_DATE), " - ", TimeToStr(HolLast, TIME_DATE), " holidays.");
            HolShutDown = 0;

            if(PlaySounds)
               PlaySound(AlertSound);
           }

         if(HolShutDown == 3)
           {

            return (0);
           }
         else
            if((HolShutDown == 0 && TimeCurrent() >= HolLast) || HolFirst == 0)
              {
               for(int Index = 0; Index < ArraySize(HolArray); Index++)
                 {
                  // HolFirst = StrToTime((string) Year() + "." + (string) HolArray[Index, 0] + "." + (string) HolArray[Index, 1]);
                  string tts = (string) Year() + "." + (string) HolArray[Index, 0] + "." + (string) HolArray[Index, 1];
                  Print("tts: " + tts + "  *******************************************************");
                  HolFirst = StrToTime(tts);

                  HolLast = StrToTime((string) Year() + "." + (string) HolArray[Index, 2] + "." + (string) HolArray[Index, 3] + " 23:59:59");

                  if(TimeCurrent() < HolFirst)
                    {
                     if(HolFirst > HolLast)
                        HolLast = StrToTime(DTS(Year() + 1, 0) + "." + (string) HolArray[Index, 2] + "." + (string) HolArray[Index, 3] + " 23:59:59");

                     break;
                    }

                  if(TimeCurrent() < HolLast)
                    {
                     if(HolFirst > HolLast)
                        HolFirst = StrToTime(DTS(Year() - 1, 0) + "." + (string) HolArray[Index, 0] + "." + (string) HolArray[Index, 1]);

                     break;
                    }

                  if(TimeCurrent() > HolFirst && HolFirst > HolLast)
                    {
                     HolLast = StrToTime(DTS(Year() + 1, 0) + "." + (string) HolArray[Index, 2] + "." + (string) HolArray[Index, 3] + " 23:59:59");

                     if(TimeCurrent() < HolLast)
                        break;
                    }
                 }

               if(TimeCurrent() >= HolFirst && TimeCurrent() <= HolLast)
                 {
                  // Comment(""); // xxx
                  HolShutDown = 1;
                 }
              }
            else
               if(HolShutDown == 0 && TimeCurrent() >= HolFirst && TimeCurrent() < HolLast)
                  HolShutDown = 1;
         }
//start of the big loop for each pair-to-trade

   for(int i=0;i<ArraySize(TradePairs);i++){

if (Debug_)   printf("TradePair:"+IntegerToString(i)+TradePairs[i]+suffix);
if (Debug_)   Print("MinLotSize: ", DTS(pairinfo[i].MinLotSize, 2), " LotStep: ", DTS(pairinfo[i].LotStep, 2), " MinLot: ", DTS(MathMin(pairinfo[i].MinLotSize, pairinfo[i].LotStep), 2), " StartLot: ", DTS(pairinfo[i].Lot_, 2), " LotMult: ", DTS(pairinfo[i].LotMult, 0), " Lot Decimal: ", DTS(pairinfo[i].LotDecimal, 0));

   pairinfo[i].CbB          =0;     // Count buy
 	pairinfo[i].CbS          =0;     // Count sell
 	pairinfo[i].CpBL         =0;     // Count buy limit
  	pairinfo[i].CpSL         =0;     // Count sell limit
	pairinfo[i].CpBS         =0;     // Count buy stop
	pairinfo[i].CpSS         =0;     // Count sell stop
	pairinfo[i].LbB          =0;     // Count buy lots
	pairinfo[i].LbS          =0;     // Count sell lots
	pairinfo[i].OPpBL        =0;     // Buy limit open price
	pairinfo[i].OPpSL        =0;     // Sell limit open price
	pairinfo[i].SLbB         =0;     // stop losses are set to zero if POSL off
	pairinfo[i].SLbS         =0;     // stop losses are set to zero if POSL off
	pairinfo[i].ProfitPot    =0;     // The Potential Profit of a basket of Trades
 	pairinfo[i].BCb          =0;
	pairinfo[i].BCa          =0;       // Broker costs (swap + commission)
	pairinfo[i].OPbL = 0;
	pairinfo[i].OTbL = 0;          // last open time
	pairinfo[i].OTbO = 0;
	pairinfo[i].RSI_MA = 0;
	pairinfo[i].OPbO = 0;
	pairinfo[i].Ticket = 0;
	pairinfo[i].IndEntry = 0;
	pairinfo[i].TbO = 0;
	pairinfo[i].Pb = 0;
	pairinfo[i].PaC = 0;
	pairinfo[i].PbPips = 0;	
	pairinfo[i].PbTarget = 0;
	pairinfo[i].DrawDownPC = 0;
	pairinfo[i].BEb = 0;
	pairinfo[i].BEa = 0;
	pairinfo[i].BuyMe = false; 
	pairinfo[i].SellMe = false;
	pairinfo[i].EEpc = 0;
	pairinfo[i].OPbN = 0;
	pairinfo[i].nLots = 0;
	pairinfo[i].bSL = 0;
	pairinfo[i].TPa = 0;
	pairinfo[i].TPbMP = 0;
	pairinfo[i].Trend = 0;
	pairinfo[i].cci_01 = 0;
	pairinfo[i].cci_02 = 0;
	pairinfo[i].cci_03 = 0;
	pairinfo[i].cci_04 = 0;
	pairinfo[i].cci_11 = 0;
	pairinfo[i].cci_12 = 0;
	pairinfo[i].cci_13 = 0;
	pairinfo[i].cci_14 = 0;


//+-----------------------------------------------------------------+
//| Count Open Orders, Lots and Totals -->does it work in multipair?|
//+-----------------------------------------------------------------+
   if (MarketInfo(TradePairs[i]+suffix, MODE_TICKSIZE) !=0) pairinfo[i].PipVal2 = MarketInfo(TradePairs[i]+suffix, MODE_TICKVALUE) / MarketInfo(TradePairs[i]+suffix, MODE_TICKSIZE);
   else printf("No MarketInfo for "+TradePairs[i]+suffix+DoubleToStr(MarketInfo(TradePairs[i]+suffix,MODE_TICKSIZE)));
   pairinfo[i].PipValue = pairinfo[i].PipVal2 * pairinfo[i].Pip;
   pairinfo[i].StopLevel = MarketInfo(TradePairs[i]+suffix, MODE_STOPLEVEL) * Point;
   pairinfo[i].ASK = ND(MarketInfo(TradePairs[i]+suffix, MODE_ASK), (int) MarketInfo(TradePairs[i]+suffix, MODE_DIGITS));
   pairinfo[i].BID = ND(MarketInfo(TradePairs[i]+suffix, MODE_BID), (int) MarketInfo(TradePairs[i]+suffix, MODE_DIGITS));

   if(pairinfo[i].ASK == 0 || pairinfo[i].BID == 0)
      return (0);

   for(int Order = 0; Order < OrdersTotal(); Order++)
     {
      if(!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
         continue;

      int Type = OrderType();

      if(OrderMagicNumber() != Magic || OrderSymbol() != TradePairs[i]+suffix)
         continue;

      if(OrderTakeProfit() > 0)
         ModifyOrder(OrderOpenPrice(), OrderStopLoss(),0,i);

      if(Type <= OP_SELL)
        {
         pairinfo[i].Pb += OrderProfit();
         pairinfo[i].BCb += OrderSwap() + OrderCommission();
         pairinfo[i].BEb += OrderLots() * OrderOpenPrice();

         if(OrderOpenTime() >= pairinfo[i].OTbL)
           {
            pairinfo[i].OTbL = OrderOpenTime();
            pairinfo[i].OPbL = OrderOpenPrice();
           }

         if(OrderOpenTime() < pairinfo[i].OTbF || pairinfo[i].TbF == 0)
           {
            pairinfo[i].OTbF = OrderOpenTime();
            pairinfo[i].TbF = OrderTicket();
            pairinfo[i].LbF = OrderLots();
           }

         if(OrderOpenTime() < pairinfo[i].OTbO || pairinfo[i].OTbO == 0)
           {
            pairinfo[i].OTbO = OrderOpenTime();
            pairinfo[i].TbO = OrderTicket();
            pairinfo[i].OPbO = OrderOpenPrice();
           }

         if(UsePowerOutSL && ((pairinfo[i].POSLPips_ > 0 && OrderStopLoss() == 0) || (pairinfo[i].POSLPips_ == 0 && OrderStopLoss() > 0)))
            pairinfo[i].SetPOSL = true;

         if(Type == OP_BUY)
           {
            pairinfo[i].CbB++;
            pairinfo[i].LbB += OrderLots();
            continue;
           }
         else
           {
            pairinfo[i].CbS++;
            pairinfo[i].LbS += OrderLots();
            continue;
           }
        }
      else
        {
         if(Type == OP_BUYLIMIT)
           {
            pairinfo[i].CpBL++;
            pairinfo[i].OPpBL = OrderOpenPrice();
            continue;
           }
         else
            if(Type == OP_SELLLIMIT)
              {
               pairinfo[i].CpSL++;
               pairinfo[i].OPpSL = OrderOpenPrice();
               continue;
              }
            else
               if(Type == OP_BUYSTOP)
                  pairinfo[i].CpBS++;
               else
                  pairinfo[i].CpSS++;
        }
     }

   pairinfo[i].CbT = pairinfo[i].CbB + pairinfo[i].CbS;
   LbT = pairinfo[i].LbB + pairinfo[i].LbS;
   pairinfo[i].Pb = ND(pairinfo[i].Pb + pairinfo[i].BCb, 2);
   pairinfo[i].CpT = pairinfo[i].CpBL + pairinfo[i].CpSL + pairinfo[i].CpBS + pairinfo[i].CpSS;
   pairinfo[i].BCa = pairinfo[i].BCb;


//+-----------------------------------------------------------------+
//| Calculate Min/Max Profit and Break Even Points                  |
//+-----------------------------------------------------------------+
   if(LbT > 0)
     {
      pairinfo[i].BEb = ND(pairinfo[i].BEb / LbT, Digits);

      if(pairinfo[i].BCa < 0)
         pairinfo[i].BEb -= ND(pairinfo[i].BCa / pairinfo[i].PipVal2 / (pairinfo[i].LbB - pairinfo[i].LbS), Digits);

      if(pairinfo[i].Pb > pairinfo[i].PbMax || pairinfo[i].PbMax == 0)
         pairinfo[i].PbMax = pairinfo[i].Pb;

      if(pairinfo[i].Pb < pairinfo[i].PbMin || pairinfo[i].PbMin == 0)
         pairinfo[i].PbMin = pairinfo[i].Pb;

      if(!pairinfo[i].TradesOpen)
        {
         FileHandle = FileOpen(FileName, FILE_BIN | FILE_WRITE);

         if(FileHandle > -1)
           {
            FileWriteInteger(FileHandle, pairinfo[i].TbF);
            FileClose(FileHandle);
            pairinfo[i].TradesOpen = true;

            if(Debug_)
               Print(FileName, " File Written: ", pairinfo[i].TbF);
           }
        }
     }
   else
      if(pairinfo[i].TradesOpen)
        {
         pairinfo[i].TPb = 0;
         pairinfo[i].PbMax = 0;
         pairinfo[i].PbMin = 0;
         pairinfo[i].OTbF = 0; //wirklich Index???? oder alle Index?
         pairinfo[i].TbF = 0;
         pairinfo[i].LbF = 0;
         pairinfo[i].PbC = 0;
         pairinfo[i].PaC = 0;
         pairinfo[i].ClosedPips = 0;
         pairinfo[i].CbC = 0;
         pairinfo[i].CaL = 0;
         pairinfo[i].bTS = 0;
         

         EmailCount = 0;
         EmailSent = 0;
         FileHandle = FileOpen(FileName, FILE_BIN | FILE_READ);

         if(FileHandle > -1)
           {
            FileClose(FileHandle);
            Error = GetLastError();
            FileDelete(FileName);
            Error = GetLastError();

            if(Error == ERR_NO_ERROR)
              {
               if(Debug_)
                  Print(FileName + " File Deleted");

               pairinfo[i].TradesOpen = false;
              }
            else
               Print("Error ", Error, " {", ErrorDescription(Error), ") deleting file ", FileName);
           }
         else
            pairinfo[i].TradesOpen = false;
        }

//+-----------------------------------------------------------------+
//| Check if trading is allowed                                     |
//+-----------------------------------------------------------------+
   if(pairinfo[i].CbT == 0 && ShutDown_)
     {
      if(pairinfo[i].CpT > 0)
        {
         ExitTrades(P, displayColorLoss, "Blessing is shutting down",0,ca,"");
         return (0);
        }

      if(AllowTrading)
        {
         Print("Blessing has shut down. Set ShutDown = 'false' to resume trading");

         if(PlaySounds)
            PlaySound(AlertSound);

         AllowTrading = false;
        }

      if(UseEmail && EmailCount < 4 && !Testing)
        {
         SendMail("Blessing EA", "Blessing has shut down on " + TradePairs[i]+suffix + " " + sTF + ". To resume trading, change ShutDown to false.");
         Error = GetLastError();

         if(Error > 0)
            Print("Error ", Error, " (", ErrorDescription(Error), ") sending email");
         else
            EmailCount = 4;
        }
     }

//+-----------------------------------------------------------------+
//| Calculate Drawdown and Equity Protection                        |
//+-----------------------------------------------------------------+
   double NewPortionBalance = ND(AccountBalance() * PortionPC_, 2);

   if(pairinfo[i].CbT == 0 || PortionChange < 0 || (PortionChange > 0 && NewPortionBalance > pairinfo[i].PortionBalance))
      pairinfo[i].PortionBalance = NewPortionBalance;

   if(OncePerBar(pairinfo[i].OncePerBarTime)&& (pairinfo[i].PortionBalance !=0))
     {
      if(pairinfo[i].Pb < 0)
         pairinfo[i].DrawDownPC = -(pairinfo[i].Pb) / pairinfo[i].PortionBalance;   // opb
      if(!FirstRun && pairinfo[i].DrawDownPC >= MaxDDPercent / 100)
        {
         ExitTrades(A, displayColorLoss, "Equity StopLoss Reached",0,ca,"");
         if(PlaySounds)
            PlaySound(AlertSound);
         return (0);
        }

      if(-(pairinfo[i].Pb) > pairinfo[i].MaxDD)
         pairinfo[i].MaxDD = -(pairinfo[i].Pb);

      pairinfo[i].MaxDDPer = MathMax(pairinfo[i].MaxDDPer, pairinfo[i].DrawDownPC * 100);

      if(SaveStats)
         Stats(false, TimeCurrent() < NextStats, pairinfo[i].PortionBalance, pairinfo[i].Pb);

      //+-----------------------------------------------------------------+
      //| Calculate  Stop Trade Percent                                   |
      //+-----------------------------------------------------------------+
      double StepAB = InitialAB * (1 + StopTradePercent_);
      double StepSTB = AccountBalance() * (1 - StopTradePercent_);
      double NextISTB = StepAB * (1 - StopTradePercent_);

      if(StepSTB > NextISTB)
        {
         InitialAB = StepAB;
         StopTradeBalance = StepSTB;
        }
      // Stop Trade Amount:
      double InitialAccountMultiPortion = StopTradeBalance * PortionPC_;
      stop_trade_amount = InitialAccountMultiPortion;

      if(pairinfo[i].PortionBalance < InitialAccountMultiPortion)
        {
         if(pairinfo[i].CbT == 0)
           {
            AllowTrading = false;

            if(PlaySounds)
               PlaySound(AlertSound);

            Print("Portion Balance dropped below stop-trading percentage");
            MessageBox("Reset required - account balance dropped below stop-trading percentage on " + DTS(AccountNumber(), 0) + " " + TradePairs[i]+suffix + " " + (string) Period(), "Blessing 3: Warning", 48);
            return (0);
           }
         else
            if(!ShutDown_ && !RecoupClosedLoss)
              {
               ShutDown_ = true;

               if(PlaySounds)
                  PlaySound(AlertSound);

               Print("Portion Balance dropped below stop-trading percentage");

               return (0);
              }
        }
      //+-----------------------------------------------------------------+
      //| Calculation of Trend Direction                                  |
      //+-----------------------------------------------------------------+
      double ima_0 = iMA(TradePairs[i]+suffix, 0, MAPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);

         if(pairinfo[i].BID > ima_0 + pairinfo[i].MADistance_)
            pairinfo[i].Trend = 0;
         else
            if(pairinfo[i].ASK < ima_0 - pairinfo[i].MADistance_)
               pairinfo[i].Trend = 1;
            else
               pairinfo[i].Trend = 2;
        
      //+-----------------------------------------------------------------+
      //| Basket/ClosedTrades Profit Management                     |
      //+-----------------------------------------------------------------+
      double Pa = pairinfo[i].Pb;
      pairinfo[i].PaC = pairinfo[i].PbC;

      if(LbT > 0)
        {
         if(pairinfo[i].PbC > 0 || (pairinfo[i].PbC < 0 && RecoupClosedLoss))
           {
            Pa += pairinfo[i].PbC;
            pairinfo[i].BEb -= ND(pairinfo[i].PbC / pairinfo[i].PipVal2 / (pairinfo[i].LbB - pairinfo[i].LbS), Digits);
           }         
        }
        
      //+-----------------------------------------------------------------+
      //| Close oldest open trade after CloseTradesLevel reached          |
      //+-----------------------------------------------------------------+
      if(UseCloseOldest && pairinfo[i].CbT >= CloseTradesLevel && pairinfo[i].CbC < MaxCloseTrades_)
        {
         if(!FirstRun && pairinfo[i].TPb > 0 && (ForceCloseOldest || (pairinfo[i].CbB > 0 && pairinfo[i].OPbO > pairinfo[i].TPb) || (pairinfo[i].CbS > 0 && pairinfo[i].OPbO < pairinfo[i].TPb)))
           {
            int Index = ExitTrades(T, DarkViolet, "Close Oldest Trade", pairinfo[i].TbO, ca,TradePairs[i]);

            if(Index == 1)
              {
               if(OrderSelect(pairinfo[i].TbO, SELECT_BY_TICKET))      // yoh check return
                 {
                  pairinfo[i].PbC += OrderProfit() + OrderSwap() + OrderCommission();
                  ca = 0;
                  pairinfo[i].CbC++;
                 }
               else
                  Print("OrderSelect error ", GetLastError());    // yoh

               return (0);
              }
           }
        }

      //+-----------------------------------------------------------------+
      //| ATR for Auto Grid Calculation and Grid Set Block                |
      //+-----------------------------------------------------------------+
//      double GridTP;

      if(AutoCal)
        {
         double GridATR = iATR(TradePairs[i]+suffix, TF[ATRTF], ATRPeriods, 0) / pairinfo[i].Pip;

         if((pairinfo[i].CbT + pairinfo[i].CbC > Set4Level) && Set4Level > 0)
           {
            pairinfo[i].g2 = GridATR * 12;      //GS*2*2*2*1.5
            pairinfo[i].tp2 = GridATR * 18;     //GS*2*2*2*1.5*1.5
           }
         else
            if((pairinfo[i].CbT + pairinfo[i].CbC > Set3Level) && Set3Level > 0)
              {
               pairinfo[i].g2 = GridATR * 8;       //GS*2*2*2
               pairinfo[i].tp2 = GridATR * 12;     //GS*2*2*2*1.5
              }
            else
               if((pairinfo[i].CbT + pairinfo[i].CbC > Set2Level) && Set2Level > 0)
                 {
                  pairinfo[i].g2 = GridATR * 4;       //GS*2*2
                  pairinfo[i].tp2 = GridATR * 8;      //GS*2*2*2
                 }
               else
                  if((pairinfo[i].CbT + pairinfo[i].CbC > Set1Level) && Set1Level > 0)
                    {
                     pairinfo[i].g2 = GridATR * 2;       //GS*2
                     pairinfo[i].tp2 = GridATR * 4;      //GS*2*2
                    }
                  else
                    {
                     pairinfo[i].g2 = GridATR;
                     pairinfo[i].tp2 = GridATR * 2;
                    }

         pairinfo[i].GridTP = GridATR * 2;
        }
      else
        {
         int Index = (int) MathMax(MathMin(pairinfo[i].CbT + pairinfo[i].CbC, MaxTrades) - 1, 0);
         pairinfo[i].g2 = GridArray[Index, 0];
         pairinfo[i].tp2 = GridArray[Index, 1];
         pairinfo[i].GridTP = GridArray[0, 1];
        }

      pairinfo[i].g2 = ND(MathMax(pairinfo[i].g2 * GAF * pairinfo[i].Pip, pairinfo[i].Pip), Digits);
      pairinfo[i].tp2 = ND(pairinfo[i].tp2 * GAF * pairinfo[i].Pip, Digits);
      pairinfo[i].GridTP = ND(pairinfo[i].GridTP * GAF * pairinfo[i].Pip, Digits);

      //+-----------------------------------------------------------------+
      //| Money Management and Lot size coding                            |
      //+-----------------------------------------------------------------+
      if(UseMM)
        {
         if(pairinfo[i].CbT > 0)         // Count basket
           {
            if(GlobalVariableCheck(ID + "LotMult"))
               pairinfo[i].LotMult = (int) GlobalVariableGet(ID + "LotMult");

            if(pairinfo[i].LbF != LotSize(pairinfo[i].Lots[0] * pairinfo[i].LotMult,i,pairinfo[i].LotDecimal,pairinfo[i].MinLotSize))
              {
               pairinfo[i].LotMult = (int)(pairinfo[i].LbF / pairinfo[i].Lots[0]);
               GlobalVariableSet(ID + "LotMult", pairinfo[i].LotMult);
               Print("LotMult reset to " + DTS(pairinfo[i].LotMult, 0));
              }
           }
         else
            if(pairinfo[i].CbT == 0)
              {
               double Contracts, Factor, Lotsize;
               Contracts = pairinfo[i].PortionBalance / 10000;     // MarketInfo(TradePairs[i]+suffix, MODE_LOTSIZE); ??

               if(Multiplier_ <= 1)
                  Factor = Level;
               else
                  Factor = (MathPow(Multiplier_, Level) - Multiplier_) / (Multiplier_ - 1);

               Lotsize = LAF * AccountType * Contracts / (1 + Factor);
               pairinfo[i].LotMult = (int) MathMax(MathFloor(Lotsize / pairinfo[i].Lot_), pairinfo[i].MinMult);
               GlobalVariableSet(ID + "LotMult", pairinfo[i].LotMult);
              }
        }
      else
         if(pairinfo[i].CbT == 0)
            pairinfo[i].LotMult = pairinfo[i].MinMult;

      //+-----------------------------------------------------------------+
      //| Calculate Take Profit                                           |
      //+-----------------------------------------------------------------+
//      static double BCaL, BEbL;
      pairinfo[i].nLots = pairinfo[i].LbB - pairinfo[i].LbS;

      if(pairinfo[i].CbT > 0 && (pairinfo[i].TPb == 0 || pairinfo[i].CbT != pairinfo[i].CaL || pairinfo[i].BEbL != pairinfo[i].BEb || pairinfo[i].BCa != pairinfo[i].BCaL || FirstRun))
        {
         string sCalcTP = TradePairs[i]+"Set New TP:  BE: " + DTS(pairinfo[i].BEb, Digits);
         double NewTP = 0, BasePips=0; //set BasePips to Zero, don't know if this will have an impact
         pairinfo[i].CaL = pairinfo[i].CbT;
         pairinfo[i].BCaL = pairinfo[i].BCa;
         pairinfo[i].BEbL = pairinfo[i].BEb;
         if(pairinfo[i].nLots == 0)
           {
            pairinfo[i].nLots = 1;
           }                   // divide by zero error fix ... r.f.
         BasePips = ND(pairinfo[i].Lot_ * pairinfo[i].LotMult * pairinfo[i].GridTP * (pairinfo[i].CbT + pairinfo[i].CbC) / pairinfo[i].nLots, Digits);

         if(pairinfo[i].CbB > 0)
           {
            if(pairinfo[i].ForceTPPips_ > 0)
              {
               NewTP = pairinfo[i].BEb + pairinfo[i].ForceTPPips_;
               sCalcTP = sCalcTP + " +Force TP (" + DTS(pairinfo[i].ForceTPPips_, Digits) + ") ";
              }
            else
               if(pairinfo[i].CbC > 0 && pairinfo[i].CloseTPPips_ > 0)
                 {
                  NewTP = pairinfo[i].BEb + pairinfo[i].CloseTPPips_;
                  sCalcTP = sCalcTP + " +Close TP (" + DTS(pairinfo[i].CloseTPPips_, Digits) + ") ";
                 }
               else
                  if(pairinfo[i].BEb + BasePips > pairinfo[i].OPbL + pairinfo[i].tp2)
                    {
                     NewTP = pairinfo[i].BEb + BasePips;
                     sCalcTP = sCalcTP + " +Base TP: (" + DTS(BasePips, Digits) + ") ";
                    }
                  else
                    {
                     NewTP = pairinfo[i].OPbL + pairinfo[i].tp2;
                     sCalcTP = sCalcTP + " +Grid TP: (" + DTS(pairinfo[i].tp2, Digits) + ") ";
                    }

            if(pairinfo[i].MinTPPips_ > 0)
              {
               NewTP = MathMax(NewTP, pairinfo[i].BEb + pairinfo[i].MinTPPips_);
               sCalcTP = sCalcTP + " >Minimum TP: ";
              }

            NewTP += pairinfo[i].MoveTP_ * pairinfo[i].Moves;

            if(BreakEvenTrade > 0 && pairinfo[i].CbT + pairinfo[i].CbC >= BreakEvenTrade)
              {
               NewTP = pairinfo[i].BEb + pairinfo[i].BEPlusPips_;
               sCalcTP = sCalcTP + " >BreakEven: (" + DTS(pairinfo[i].BEPlusPips_, Digits) + ") ";
              }

            sCalcTP = (sCalcTP + "Buy: TakeProfit: ");
           }
         else
            if(pairinfo[i].CbS > 0)
              {
               if(pairinfo[i].ForceTPPips_ > 0)
                 {
                  NewTP = pairinfo[i].BEb - pairinfo[i].ForceTPPips_;
                  sCalcTP = sCalcTP + " -Force TP (" + DTS(pairinfo[i].ForceTPPips_, Digits) + ") ";
                 }
               else
                  if(pairinfo[i].CbC > 0 && pairinfo[i].CloseTPPips_ > 0)
                    {
                     NewTP = pairinfo[i].BEb - pairinfo[i].CloseTPPips_;
                     sCalcTP = sCalcTP + " -Close TP (" + DTS(pairinfo[i].CloseTPPips_, Digits) + ") ";
                    }
                  else
                     if(pairinfo[i].BEb + BasePips < pairinfo[i].OPbL - pairinfo[i].tp2)
                       {
                        NewTP = pairinfo[i].BEb + BasePips;
                        sCalcTP = sCalcTP + " -Base TP: (" + DTS(BasePips, Digits) + ") ";
                       }
                     else
                       {
                        NewTP = pairinfo[i].OPbL - pairinfo[i].tp2;
                        sCalcTP = sCalcTP + " -Grid TP: (" + DTS(pairinfo[i].tp2, Digits) + ") ";
                       }

               if(pairinfo[i].MinTPPips_ > 0)
                 {
                  NewTP = MathMin(NewTP, pairinfo[i].BEb - pairinfo[i].MinTPPips_);
                  sCalcTP = sCalcTP + " >Minimum TP: ";
                 }

               NewTP -= pairinfo[i].MoveTP_ * pairinfo[i].Moves;

               if(BreakEvenTrade > 0 && pairinfo[i].CbT + pairinfo[i].CbC >= BreakEvenTrade)
                 {
                  NewTP = pairinfo[i].BEb - pairinfo[i].BEPlusPips_;
                  sCalcTP = sCalcTP + " >BreakEven: (" + DTS(pairinfo[i].BEPlusPips_, Digits) + ") ";
                 }

               sCalcTP = (sCalcTP + "Sell: TakeProfit: ");
              }

         if(pairinfo[i].TPb != NewTP)
           {
            pairinfo[i].TPb = NewTP;

            if(pairinfo[i].nLots > 0)
               pairinfo[i].TargetPips = ND(pairinfo[i].TPb - pairinfo[i].BEb, Digits);
            else
               pairinfo[i].TargetPips = ND(pairinfo[i].BEb - pairinfo[i].TPb, Digits);

            Print(sCalcTP + DTS(NewTP, Digits));

            return (0);
           }
        }

      pairinfo[i].PbTarget = pairinfo[i].TargetPips / pairinfo[i].Pip;
      pairinfo[i].ProfitPot = ND(pairinfo[i].TargetPips * pairinfo[i].PipVal2 * MathAbs(pairinfo[i].nLots), 2);

      if(pairinfo[i].CbB > 0)
         pairinfo[i].PbPips = ND((pairinfo[i].BID - pairinfo[i].BEb) / pairinfo[i].Pip, 1);

      if(pairinfo[i].CbS > 0)
         pairinfo[i].PbPips = ND((pairinfo[i].BEb - pairinfo[i].ASK) / pairinfo[i].Pip, 1);

      //+-----------------------------------------------------------------+
      //| Adjust BEb/TakeProfit                                           |
      //+-----------------------------------------------------------------+

         pairinfo[i].BEa = pairinfo[i].BEb;
         pairinfo[i].TPa = pairinfo[i].TPb;
        
      //+-----------------------------------------------------------------+
      //| Calculate Early Exit Percentage                                 |
      //+-----------------------------------------------------------------+
      double EEStartTime = 0, TPaF;

      if(UseEarlyExit && pairinfo[i].CbT > 0)
        {
         datetime EEopt;

         if(EEFirstTrade)
            EEopt = pairinfo[i].OTbF;
         else
            EEopt = pairinfo[i].OTbL;

         if(DayOfWeek() < TimeDayOfWeek(EEopt))
            EEStartTime = 2 * 24 * 3600;

         EEStartTime += EEopt + EEStartHours * 3600;

         if(EEHoursPC_ > 0 && TimeCurrent() >= EEStartTime)
            pairinfo[i].EEpc = EEHoursPC_ * (TimeCurrent() - EEStartTime) / 3600;

         if(EELevelPC_ > 0 && (pairinfo[i].CbT + pairinfo[i].CbC) >= EEStartLevel)
            pairinfo[i].EEpc += EELevelPC_ * (pairinfo[i].CbT + pairinfo[i].CbC - EEStartLevel + 1);

         pairinfo[i].EEpc = 1 - pairinfo[i].EEpc;

         if(!EEAllowLoss && pairinfo[i].EEpc < 0)
            pairinfo[i].EEpc = 0;

         pairinfo[i].PbTarget *= pairinfo[i].EEpc;
         TPaF = ND((pairinfo[i].TPa - pairinfo[i].BEa) * pairinfo[i].EEpc + pairinfo[i].BEa, Digits);
        }
      else
        {
         TPaF = pairinfo[i].TPa;
         EETime = 0;
         EECount = 0;
        }

      //+-----------------------------------------------------------------+
      //| Maximize Profit with Moving TP and setting Trailing Profit Stop |
      //+-----------------------------------------------------------------+
      if(MaximizeProfit)
        {
         if(pairinfo[i].CbT == 0)
           {
            pairinfo[i].SLbL = 0;
            pairinfo[i].Moves = 0;
            pairinfo[i].SLb = 0;
           }

         if(!FirstRun && pairinfo[i].CbT > 0)
           {
            if(pairinfo[i].Pb < 0 && pairinfo[i].SLb > 0)
               pairinfo[i].SLb = 0;

            if(pairinfo[i].SLb > 0 && ((pairinfo[i].nLots > 0 && pairinfo[i].BID < pairinfo[i].SLb) || (pairinfo[i].nLots < 0 && pairinfo[i].ASK > pairinfo[i].SLb)))
              {
               ExitTrades(B, displayColorProfit, "Profit Trailing Stop Reached (" + DTS(ProfitSet_ * 100, 2) + "%)",0,ca,TradePairs[i]+suffix);

               return (0);
              }

            if(pairinfo[i].PbTarget > 0)
              {
               pairinfo[i].TPbMP = ND(pairinfo[i].BEa + (pairinfo[i].TPa - pairinfo[i].BEa) * ProfitSet_, Digits);

               if((pairinfo[i].nLots > 0 && pairinfo[i].BID > pairinfo[i].TPbMP) || (pairinfo[i].nLots < 0 && pairinfo[i].ASK < pairinfo[i].TPbMP))
                  pairinfo[i].SLb = pairinfo[i].TPbMP;
              }

            if(pairinfo[i].SLb > 0 && pairinfo[i].SLb != pairinfo[i].SLbL && pairinfo[i].MoveTP_ > 0 && TotalMoves > pairinfo[i].Moves)
              {
               pairinfo[i].TPb = 0;
               pairinfo[i].Moves++;

               if(Debug_)
                  Print("MoveTP");

               pairinfo[i].SLbL = pairinfo[i].SLb;

               if(PlaySounds)
                  PlaySound(AlertSound);

               return (0);
              }
           }
        }

      if(!FirstRun && TPaF > 0)
        {
         if((pairinfo[i].nLots > 0 && pairinfo[i].BID >= TPaF) || (pairinfo[i].nLots < 0 && pairinfo[i].ASK <= TPaF))
           {
            ExitTrades(B, displayColorProfit, "Profit Target Reached @ " + DTS(TPaF, Digits),0,ca,TradePairs[i]+suffix);

            return (0);
           }
        }

      if(!FirstRun && UseStopLoss)
        {
         if(pairinfo[i].SLPips_ > 0)
           {
            if(pairinfo[i].nLots > 0)
              {
               pairinfo[i].bSL = pairinfo[i].BEa - pairinfo[i].SLPips_;

               if(pairinfo[i].BID <= pairinfo[i].bSL)
                 {
                  ExitTrades(B, displayColorProfit, "Stop Loss Reached",0,ca,TradePairs[i]+suffix);

                  return (0);
                 }
              }
            else
               if(pairinfo[i].nLots < 0)
                 {
                  pairinfo[i]. bSL = pairinfo[i].BEa + pairinfo[i].SLPips_;

                  if(pairinfo[i].ASK >= pairinfo[i].bSL)
                    {
                     ExitTrades(B, displayColorProfit, "Stop Loss Reached",0,ca,TradePairs[i]+suffix);

                     return (0);
                    }
                 }
           }

         if(pairinfo[i].TSLPips_ != 0)
           {
            if(pairinfo[i].nLots > 0)
              {
               if(pairinfo[i].TSLPips_ > 0 && pairinfo[i].BID > pairinfo[i].BEa + pairinfo[i].TSLPips_)
                  pairinfo[i].bTS = MathMax(pairinfo[i].bTS, pairinfo[i].BID - pairinfo[i].TSLPips_);

               if(pairinfo[i].TSLPips_ < 0 && pairinfo[i].BID > pairinfo[i].BEa - pairinfo[i].TSLPips_)
                  pairinfo[i].bTS = MathMax(pairinfo[i].bTS, pairinfo[i].BID - MathMax(pairinfo[i].TSLPipsMin_, -pairinfo[i].TSLPips_ * (1 - (pairinfo[i].BID - pairinfo[i].BEa + pairinfo[i].TSLPips_) / (-pairinfo[i].TSLPips_ * 2))));

               if(pairinfo[i].bTS > 0 && pairinfo[i].BID <= pairinfo[i].bTS)
                 {
                  ExitTrades(B, displayColorProfit, "Trailing Stop Reached",0,ca,TradePairs[i]+suffix);

                  return (0);
                 }
              }
            else
               if(pairinfo[i].nLots < 0)
                 {
                  if(pairinfo[i].TSLPips_ > 0 && pairinfo[i].ASK < pairinfo[i].BEa - pairinfo[i].TSLPips_)
                    {
                     if(pairinfo[i].bTS > 0)
                        pairinfo[i].bTS = MathMin(pairinfo[i].bTS, pairinfo[i].ASK + pairinfo[i].TSLPips_);
                     else
                        pairinfo[i].bTS = pairinfo[i].ASK + pairinfo[i].TSLPips_;
                    }

                  if(pairinfo[i].TSLPips_ < 0 && pairinfo[i].ASK < pairinfo[i].BEa + pairinfo[i].TSLPips_)
                     pairinfo[i].bTS = MathMin(pairinfo[i].bTS, pairinfo[i].ASK + MathMax(pairinfo[i].TSLPipsMin_, -pairinfo[i].TSLPips_ * (1 - (pairinfo[i].BEa - pairinfo[i].ASK + pairinfo[i].TSLPips_) / (-pairinfo[i].TSLPips_ * 2))));

                  if(pairinfo[i].bTS > 0 && pairinfo[i].ASK >= pairinfo[i].bTS)
                    {
                     ExitTrades(B, displayColorProfit, "Trailing Stop Reached",0,ca,TradePairs[i]+suffix);

                     return (0);
                    }
                 }
           }
        }

      //+-----------------------------------------------------------------+
      //| Check for and Delete hanging pending orders                     |
      //+-----------------------------------------------------------------+
      if(pairinfo[i].CbT == 0 && !pairinfo[i].PendLot)
        {
         pairinfo[i].PendLot = true;

         for(int Order = OrdersTotal() - 1; Order >= 0; Order--)
           {
            if(!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
               continue;

            if(OrderMagicNumber() != Magic || OrderType() <= OP_SELL)
               continue;

            if(OrderMagicNumber() != Magic || OrderSymbol() != TradePairs[i]+suffix)
               continue;

            if(ND(OrderLots(), pairinfo[i].LotDecimal) > ND(pairinfo[i].Lots[0] * pairinfo[i].LotMult, pairinfo[i].LotDecimal))
              {
               pairinfo[i].PendLot = false;

               while(IsTradeContextBusy())
                  Sleep(100);

               if(IsStopped())
                  return (-1);

               pairinfo[i].Success = OrderDelete(OrderTicket());

               if(pairinfo[i].Success)
                 {
                  pairinfo[i].PendLot = true;

                  if(Debug_)
                     Print("Delete pending > Lot");
                 }
              }
           }

         return (0);
        }
      else
         if((pairinfo[i].CbT > 0 || (pairinfo[i].CbT == 0 && pairinfo[i].CpT > 0 && !B3Traditional)) && pairinfo[i].PendLot)
           {
            pairinfo[i].PendLot = false;

            for(int Order = OrdersTotal() - 1; Order >= 0; Order--)
              {
               if(!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
                  continue;

               if(OrderMagicNumber() != Magic || OrderType() <= OP_SELL)
                  continue;

               if(OrderMagicNumber() != Magic || OrderSymbol() != TradePairs[i]+suffix)
                  continue;

               if(ND(OrderLots(), pairinfo[i].LotDecimal) == ND(pairinfo[i].Lots[0] * pairinfo[i].LotMult, pairinfo[i].LotDecimal))
                 {
                  pairinfo[i].PendLot = true;

                  while(IsTradeContextBusy())
                     Sleep(100);

                  if(IsStopped())
                     return (-1);

                  pairinfo[i].Success = OrderDelete(OrderTicket());

                  if(pairinfo[i].Success)
                    {
                     pairinfo[i].PendLot = false;

                     if(Debug_)
                        Print("Delete pending = Lot");
                    }
                 }
              }

            return (0);
           }

      //+-----------------------------------------------------------------+
      //| Check ca, Breakeven Trades and Emergency Close All              |
      //+-----------------------------------------------------------------+
      switch(ca)
        {
         case B:
            if(pairinfo[i].CbT == 0 && pairinfo[i].CpT == 0)
               ca = 0;

            break;
         case A:
            if(pairinfo[i].CbT == 0 && pairinfo[i].CpT == 0)
               ca = 0;

            break;
         case P:
            if(pairinfo[i].CpT == 0)
               ca = 0;

            break;
         case T:
            break;
         default:
            break;
        }

      if(ca > 0)
        {
         ExitTrades(ca, displayColorLoss, "Close All (" + DTS(ca, 0) + ")",0,ca,TradePairs[i]+suffix);

         return (0);
        }
         else
            if(EmergencyCloseAll_)
              {
               ExitTrades(A, displayColorLoss, "Emergency Close-All-Trades",0,ca,"");
               EmergencyCloseAll_ = false;

               return (0);
              }
//This one has to be moved to the beginning, somehow out of the for-to-loop

      //+-----------------------------------------------------------------+
      //| Check Holiday Shutdown                                          |
      //+-----------------------------------------------------------------+
      if(UseHolidayShutdown)
        {
         if(HolShutDown == 1 && pairinfo[i].CbT == 0)
           {
            Print("Trading has been paused for holidays (", TimeToStr(HolFirst, TIME_DATE), " - ", TimeToStr(HolLast, TIME_DATE), ")");

            if(pairinfo[i].CpT > 0)
              {
               int Index = ExitTrades(P, displayColorLoss, "Holiday Shutdown",0,ca,"");
               if(Index == pairinfo[i].CpT)
                  ca = 0;
              }

            HolShutDown = 2;
           }
         else
            if(HolShutDown == 1) {}

         if(HolShutDown == 2)
           {
            if(PlaySounds)
               PlaySound(AlertSound);

            HolShutDown = 3;
           }

         if(HolShutDown == 3)
           {
            return (0);
           }
        }

      //+-----------------------------------------------------------------+
      //| Power Out Stop Loss Protection                                  |
      //+-----------------------------------------------------------------+
      if(pairinfo[i].SetPOSL)
        {
         if(UsePowerOutSL && pairinfo[i].POSLPips_ > 0)
           {
            double POSL = MathMin(pairinfo[i].PortionBalance * (MaxDDPercent + 1) / 100 / pairinfo[i].PipVal2 / LbT, pairinfo[i].POSLPips_);
            pairinfo[i].SLbB = ND(pairinfo[i].BEb - POSL, Digits);
            pairinfo[i].SLbS = ND(pairinfo[i].BEb + POSL, Digits);
           }
         else
           {
            pairinfo[i].SLbB = 0;
            pairinfo[i].SLbS = 0;
           }

         for(int Order = 0; Order < OrdersTotal(); Order++)
           {
            if(!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
               continue;

            if(OrderMagicNumber() != Magic || OrderSymbol() != TradePairs[i]+suffix || OrderType() > OP_SELL)
               continue;

            if(OrderType() == OP_BUY && OrderStopLoss() != pairinfo[i].SLbB)
              {
               pairinfo[i].Success = ModifyOrder(OrderOpenPrice(), pairinfo[i].SLbB, Purple,i);

               if(Debug_ && pairinfo[i].Success)
                  Print("Order ", OrderTicket(), ": Sync POSL Buy");
              }
            else
               if(OrderType() == OP_SELL && OrderStopLoss() != pairinfo[i].SLbS)
                 {
                  pairinfo[i].Success = ModifyOrder(OrderOpenPrice(), pairinfo[i].SLbS, Purple,i);

                  if(Debug_ && pairinfo[i].Success)
                     Print("Order ", OrderTicket(), ": Sync POSL Sell");
                 }
           }
        }

      //+-----------------------------------------------------------------+  << This must be the first Entry check.
      //| Moving Average Indicator for Order Entry                        |  << Add your own Indicator Entry checks
      //+-----------------------------------------------------------------+  << after the Moving Average Entry.
      if(MAEntry_ > 0 && pairinfo[i].CbT == 0 && pairinfo[i].CpT < 2)
        {
 
         if(pairinfo[i].BID > ima_0 + pairinfo[i].MADistance_ && (!B3Traditional || (B3Traditional && pairinfo[i].Trend != 2)))
           {
            if(MAEntry_ == 1)
              {
               if(UseAnyEntry || pairinfo[i].IndEntry == 0 || (!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].BuyMe))
                  pairinfo[i].BuyMe = true;
               else
                  pairinfo[i].BuyMe = false;  
               if(!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].SellMe && (!B3Traditional || (B3Traditional && pairinfo[i].Trend != 2)))
                  pairinfo[i].SellMe = false;
              }
            else
               if(MAEntry_ == 2)
                 {
                  if(UseAnyEntry || pairinfo[i].IndEntry == 0 || (!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].SellMe))
                     pairinfo[i].SellMe = true;
                  else
                     pairinfo[i].SellMe = false;

                  if(!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].BuyMe && (!B3Traditional || (B3Traditional && pairinfo[i].Trend != 2)))
                     pairinfo[i].BuyMe = false;
                 }
           }
         else
            if(pairinfo[i].ASK < ima_0 - pairinfo[i].MADistance_ && (!B3Traditional || (B3Traditional && pairinfo[i].Trend != 2)))
              {
               if(MAEntry_ == 1)
                 {
                  if(UseAnyEntry || pairinfo[i].IndEntry == 0 || (!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].SellMe))
                     pairinfo[i].SellMe = true;
                  else
                     pairinfo[i].SellMe = false;

                  if(!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].BuyMe && (!B3Traditional || (B3Traditional && pairinfo[i].Trend != 2)))
                     pairinfo[i].BuyMe = false;
                 }
               else
                  if(MAEntry_ == 2)
                    {
                     if(UseAnyEntry || pairinfo[i].IndEntry == 0 || (!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].BuyMe))
                        pairinfo[i].BuyMe = true;
                     else
                        pairinfo[i].BuyMe = false;

                     if(!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].SellMe && (!B3Traditional || (B3Traditional && pairinfo[i].Trend != 2)))
                        pairinfo[i].SellMe = false;
                    }
              }
            else
               if(B3Traditional && pairinfo[i].Trend == 2)
                 {
                  if(UseAnyEntry || pairinfo[i].IndEntry == 0 || (!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].BuyMe))
                     pairinfo[i].BuyMe = true;

                  if(UseAnyEntry || pairinfo[i].IndEntry == 0 || (!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].SellMe))
                     pairinfo[i].SellMe = true;
                 }
               else
                 {
                  pairinfo[i].BuyMe = false;
                  pairinfo[i].SellMe = false;
                 }

         if(pairinfo[i].IndEntry > 0)
            pairinfo[i].IndicatorUsed = pairinfo[i].IndicatorUsed + UAE;

         pairinfo[i].IndEntry++;
         pairinfo[i].IndicatorUsed = pairinfo[i].IndicatorUsed + " MA ";
        }

      //+----------------------------------------------------------------+
      //| CCI of 5M, 15M, 30M, 1H for Market Condition and Order Entry      |
      //+----------------------------------------------------------------+
      if(CCIEntry_ > 0)
        {
         pairinfo[i].cci_01 = iCCI(TradePairs[i]+suffix, PERIOD_M5, CCIPeriod, PRICE_CLOSE, 0);
         pairinfo[i].cci_02 = iCCI(TradePairs[i]+suffix, PERIOD_M15, CCIPeriod, PRICE_CLOSE, 0);
         pairinfo[i].cci_03 = iCCI(TradePairs[i]+suffix, PERIOD_M30, CCIPeriod, PRICE_CLOSE, 0);
         pairinfo[i].cci_04 = iCCI(TradePairs[i]+suffix, PERIOD_H1, CCIPeriod, PRICE_CLOSE, 0);
         pairinfo[i].cci_11 = iCCI(TradePairs[i]+suffix, PERIOD_M5, CCIPeriod, PRICE_CLOSE, 1);
         pairinfo[i].cci_12 = iCCI(TradePairs[i]+suffix, PERIOD_M15, CCIPeriod, PRICE_CLOSE, 1);
         pairinfo[i].cci_13 = iCCI(TradePairs[i]+suffix, PERIOD_M30, CCIPeriod, PRICE_CLOSE, 1);
         pairinfo[i].cci_14 = iCCI(TradePairs[i]+suffix, PERIOD_H1, CCIPeriod, PRICE_CLOSE, 1);
        }

      if(CCIEntry_ > 0 && pairinfo[i].CbT == 0 && pairinfo[i].CpT < 2)
        {
         if(pairinfo[i].cci_11 > 0 && pairinfo[i].cci_12 > 0 && pairinfo[i].cci_13 > 0 && pairinfo[i].cci_14 > 0 && pairinfo[i].cci_01 > 0 && pairinfo[i].cci_02 > 0 && pairinfo[i].cci_03 > 0 && pairinfo[i].cci_04 > 0)
           {
            pairinfo[i].Trend = 0;

            if(CCIEntry_ == 1)
              {
               if(UseAnyEntry || pairinfo[i].IndEntry == 0 || (!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].BuyMe))
                  pairinfo[i].BuyMe = true;
               else
                  pairinfo[i].BuyMe = false;

               if(!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].SellMe && (!B3Traditional || (B3Traditional && pairinfo[i].Trend != 2)))
                  pairinfo[i].SellMe = false;
              }
            else
               if(CCIEntry_ == 2)
                 {
                  if(UseAnyEntry || pairinfo[i].IndEntry == 0 || (!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].SellMe))
                     pairinfo[i].SellMe = true;
                  else
                     pairinfo[i].SellMe = false;

                  if(!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].BuyMe && (!B3Traditional || (B3Traditional && pairinfo[i].Trend != 2)))
                     pairinfo[i].BuyMe = false;
                 }
           }
         else
            if(pairinfo[i].cci_11 < 0 && pairinfo[i].cci_12 < 0 && pairinfo[i].cci_13 < 0 && pairinfo[i].cci_14 < 0 && pairinfo[i].cci_01 < 0 && pairinfo[i].cci_02 < 0 && pairinfo[i].cci_03 < 0 && pairinfo[i].cci_04 < 0)
              {
               pairinfo[i].Trend = 1;

               if(CCIEntry_ == 1)
                 {
                  if(UseAnyEntry || pairinfo[i].IndEntry == 0 || (!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].SellMe))
                     pairinfo[i].SellMe = true;
                  else
                     pairinfo[i].SellMe = false;

                  if(!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].BuyMe && (!B3Traditional || (B3Traditional && pairinfo[i].Trend != 2)))
                     pairinfo[i].BuyMe = false;
                 }
               else
                  if(CCIEntry_ == 2)
                    {
                     if(UseAnyEntry || pairinfo[i].IndEntry == 0 || (!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].BuyMe))
                        pairinfo[i].BuyMe = true;
                     else
                        pairinfo[i].BuyMe = false;

                     if(!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].SellMe && (!B3Traditional || (B3Traditional && pairinfo[i].Trend != 2)))
                        pairinfo[i].SellMe = false;
                    }
              }
            else
               if(!UseAnyEntry && pairinfo[i].IndEntry > 0)
                 {
                  pairinfo[i].BuyMe = false;
                  pairinfo[i].SellMe = false;
                 }

         if(pairinfo[i].IndEntry > 0)
            pairinfo[i].IndicatorUsed = pairinfo[i].IndicatorUsed + UAE;

         pairinfo[i].IndEntry++;
         pairinfo[i].IndicatorUsed = pairinfo[i].IndicatorUsed + " CCI ";
        }
if (Debug_) printf("BuyMe"+TradePairs[i]+suffix+IntegerToString(pairinfo[i].BuyMe));
if (Debug_) printf("SellMe"+TradePairs[i]+suffix+IntegerToString(pairinfo[i].SellMe));

      //+----------------------------------------------------------------+
      //| Bollinger Band Indicator for Order Entry                       |
      //+----------------------------------------------------------------+
      if(BollingerEntry_ > 0 && pairinfo[i].CbT == 0 && pairinfo[i].CpT < 2)
        {
         double ma = iMA(TradePairs[i]+suffix, 0, BollPeriod, 0, MODE_SMA, PRICE_OPEN, 0);
         double stddev = iStdDev(TradePairs[i]+suffix, 0, BollPeriod, 0, MODE_SMA, PRICE_OPEN, 0);
         double bup = ma + (BollDeviation * stddev);
         double bdn = ma - (BollDeviation * stddev);
         double bux = bup + pairinfo[i].BollDistance_;
         double bdx = bdn - pairinfo[i].BollDistance_;

         if(pairinfo[i].ASK < bdx)
           {
            if(BollingerEntry_ == 1)
              {
               if(UseAnyEntry || pairinfo[i].IndEntry == 0 || (!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].BuyMe))
                  pairinfo[i].BuyMe = true;
               else
                  pairinfo[i].BuyMe = false;

               if(!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].SellMe && (!B3Traditional || (B3Traditional && pairinfo[i].Trend != 2)))
                  pairinfo[i].SellMe = false;
              }
            else
               if(BollingerEntry_ == 2)
                 {
                  if(UseAnyEntry || pairinfo[i].IndEntry == 0 || (!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].SellMe))
                     pairinfo[i].SellMe = true;
                  else
                     pairinfo[i].SellMe = false;

                  if(!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].BuyMe && (!B3Traditional || (B3Traditional && pairinfo[i].Trend != 2)))
                     pairinfo[i].BuyMe = false;
                 }
           }
         else
            if(pairinfo[i].BID > bux)
              {
               if(BollingerEntry_ == 1)
                 {
                  if(UseAnyEntry || pairinfo[i].IndEntry == 0 || (!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].SellMe))
                     pairinfo[i].SellMe = true;
                  else
                     pairinfo[i].SellMe = false;

                  if(!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].BuyMe && (!B3Traditional || (B3Traditional && pairinfo[i].Trend != 2)))
                     pairinfo[i].BuyMe = false;
                 }
               else
                  if(BollingerEntry_ == 2)
                    {
                     if(UseAnyEntry || pairinfo[i].IndEntry == 0 || (!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].BuyMe))
                        pairinfo[i].BuyMe = true;
                     else
                        pairinfo[i].BuyMe = false;

                     if(!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].SellMe && (!B3Traditional || (B3Traditional && pairinfo[i].Trend != 2)))
                        pairinfo[i].SellMe = false;
                    }
              }
            else
               if(!UseAnyEntry && pairinfo[i].IndEntry > 0)
                 {
                  pairinfo[i].BuyMe = false;
                  pairinfo[i].SellMe = false;
                 }

         if(pairinfo[i].IndEntry > 0)
            pairinfo[i].IndicatorUsed = pairinfo[i].IndicatorUsed + UAE;

         pairinfo[i].IndEntry++;
         pairinfo[i].IndicatorUsed = pairinfo[i].IndicatorUsed + " BBands ";
        }
      //+----------------------------------------------------------------+
      //| Stochastic Indicator for Order Entry                           |
      //+----------------------------------------------------------------+
      if(StochEntry_ > 0 && pairinfo[i].CbT == 0 && pairinfo[i].CpT < 2)
        {
         int zoneBUY = BuySellStochZone;
         int zoneSELL = 100 - BuySellStochZone;
         double stoc_0 = iStochastic(TradePairs[i]+suffix, 0, KPeriod, DPeriod, Slowing, MODE_LWMA, 1, 0, 1);
         double stoc_1 = iStochastic(TradePairs[i]+suffix, 0, KPeriod, DPeriod, Slowing, MODE_LWMA, 1, 1, 1);

         if(stoc_0 < zoneBUY && stoc_1 < zoneBUY)
           {
            if(StochEntry_ == 1)
              {
               if(UseAnyEntry || pairinfo[i].IndEntry == 0 || (!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].BuyMe))
                  pairinfo[i].BuyMe = true;
               else
                  pairinfo[i].BuyMe = false;

               if(!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].SellMe && (!B3Traditional || (B3Traditional && pairinfo[i].Trend != 2)))
                  pairinfo[i].SellMe = false;
              }
            else
               if(StochEntry_ == 2)
                 {
                  if(UseAnyEntry || pairinfo[i].IndEntry == 0 || (!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].SellMe))
                     pairinfo[i].SellMe = true;
                  else
                     pairinfo[i].SellMe = false;

                  if(!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].BuyMe && (!B3Traditional || (B3Traditional && pairinfo[i].Trend != 2)))
                     pairinfo[i].BuyMe = false;
                 }
           }
         else
            if(stoc_0 > zoneSELL && stoc_1 > zoneSELL)
              {
               if(StochEntry_ == 1)
                 {
                  if(UseAnyEntry || pairinfo[i].IndEntry == 0 || (!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].SellMe))
                     pairinfo[i].SellMe = true;
                  else
                     pairinfo[i].SellMe = false;

                  if(!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].BuyMe && (!B3Traditional || (B3Traditional && pairinfo[i].Trend != 2)))
                     pairinfo[i].BuyMe = false;
                 }
               else
                  if(StochEntry_ == 2)
                    {
                     if(UseAnyEntry || pairinfo[i].IndEntry == 0 || (!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].BuyMe))
                        pairinfo[i].BuyMe = true;
                     else
                        pairinfo[i].BuyMe = false;

                     if(!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].SellMe && (!B3Traditional || (B3Traditional && pairinfo[i].Trend != 2)))
                        pairinfo[i].SellMe = false;
                    }
              }
            else
               if(!UseAnyEntry && pairinfo[i].IndEntry > 0)
                 {
                  pairinfo[i].BuyMe = false;
                  pairinfo[i].SellMe = false;
                 }

         if(pairinfo[i].IndEntry > 0)
            pairinfo[i].IndicatorUsed = pairinfo[i].IndicatorUsed + UAE;

         pairinfo[i].IndEntry++;
         pairinfo[i].IndicatorUsed = pairinfo[i].IndicatorUsed + " Stoch ";
        }
      //+----------------------------------------------------------------+
      //| MACD Indicator for Order Entry                                 |
      //+----------------------------------------------------------------+
      if(MACDEntry_ > 0 && pairinfo[i].CbT == 0 && pairinfo[i].CpT < 2)
        {
         double MACDm = iMACD(TradePairs[i]+suffix, TF[MACD_TF], FastPeriod, SlowPeriod, SignalPeriod, MACDPrice, 0, 0);
         double MACDs = iMACD(TradePairs[i]+suffix, TF[MACD_TF], FastPeriod, SlowPeriod, SignalPeriod, MACDPrice, 1, 0);

         if(MACDm > MACDs)
           {
            if(MACDEntry_ == 1)
              {
               if(UseAnyEntry || pairinfo[i].IndEntry == 0 || (!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].BuyMe))
                  pairinfo[i].BuyMe = true;
               else
                  pairinfo[i].BuyMe = false;

               if(!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].SellMe && (!B3Traditional || (B3Traditional && pairinfo[i].Trend != 2)))
                  pairinfo[i].SellMe = false;
              }
            else
               if(MACDEntry_ == 2)
                 {
                  if(UseAnyEntry || pairinfo[i].IndEntry == 0 || (!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].SellMe))
                     pairinfo[i].SellMe = true;
                  else
                     pairinfo[i].SellMe = false;

                  if(!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].BuyMe && (!B3Traditional || (B3Traditional && pairinfo[i].Trend != 2)))
                     pairinfo[i].BuyMe = false;
                 }
           }
         else
            if(MACDm < MACDs)
              {
               if(MACDEntry_ == 1)
                 {
                  if(UseAnyEntry || pairinfo[i].IndEntry == 0 || (!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].SellMe))
                     pairinfo[i].SellMe = true;
                  else
                     pairinfo[i].SellMe = false;

                  if(!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].BuyMe && (!B3Traditional || (B3Traditional && pairinfo[i].Trend != 2)))
                     pairinfo[i].BuyMe = false;
                 }
               else
                  if(MACDEntry_ == 2)
                    {
                     if(UseAnyEntry || pairinfo[i].IndEntry == 0 || (!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].BuyMe))
                        pairinfo[i].BuyMe = true;
                     else
                        pairinfo[i].BuyMe = false;

                     if(!UseAnyEntry && pairinfo[i].IndEntry > 0 && pairinfo[i].SellMe && (!B3Traditional || (B3Traditional && pairinfo[i].Trend != 2)))
                        pairinfo[i].SellMe = false;
                    }
              }
            else
               if(!UseAnyEntry && pairinfo[i].IndEntry > 0)
                 {
                  pairinfo[i].BuyMe = false;
                  pairinfo[i].SellMe = false;
                 }

         if(pairinfo[i].IndEntry > 0)
            pairinfo[i].IndicatorUsed = pairinfo[i].IndicatorUsed + UAE;

         pairinfo[i].IndEntry++;
         pairinfo[i].IndicatorUsed = pairinfo[i].IndicatorUsed + " MACD ";
        }
      //+-----------------------------------------------------------------+  << This must be the last Entry check before
      //| UseAnyEntry Check                                               |  << the Trade Selection Logic. Add checks for
      //+-----------------------------------------------------------------+  << additional indicators before this block.
      if((!UseAnyEntry && pairinfo[i].IndEntry > 1 && pairinfo[i].BuyMe && pairinfo[i].SellMe) || FirstRun)
        {
         pairinfo[i].BuyMe = false;
         pairinfo[i].SellMe = false;
        }
            
      //+-----------------------------------------------------------------+
      //| Trade Selection Logic                                           |
      //+-----------------------------------------------------------------+
      pairinfo[i].OrderLot = LotSize(pairinfo[i].Lots[StrToInteger(DTS(MathMin(pairinfo[i].CbT + pairinfo[i].CbC, MaxTrades - 1), 0))] * pairinfo[i].LotMult,i,pairinfo[i].LotDecimal,pairinfo[i].MinLotSize);

if (Debug_) printf("In Trade Selection:"+DoubleToStr(pairinfo[i].OrderLot));
 
      if(pairinfo[i].CbT == 0 && pairinfo[i].CpT < 2 && !FirstRun)
        {
         if(B3Traditional)
           {
            if(pairinfo[i].BuyMe)
              {
               if(pairinfo[i].CpBS == 0 && pairinfo[i].CpSL == 0 && ((pairinfo[i].Trend != 2 || MAEntry_ == 0) || (pairinfo[i].Trend == 2 && MAEntry_ == 1)))
                 {
                  pairinfo[i].Entry = pairinfo[i].g2 - MathMod(pairinfo[i].ASK, pairinfo[i].g2) + pairinfo[i].EntryOffset_;

                  if(pairinfo[i].Entry > pairinfo[i].StopLevel)
                    {
                     pairinfo[i].Ticket = SendOrder(TradePairs[i]+suffix, OP_BUYSTOP, pairinfo[i].OrderLot, pairinfo[i].Entry, 0, Magic, CLR_NONE,i,pairinfo[i].Pip);

                     if(pairinfo[i].Ticket > 0)
                       {
                        if(Debug_)
                           Print("Indicator Entry - (", pairinfo[i].IndicatorUsed, ") BuyStop MC = ", pairinfo[i].Trend);

                        pairinfo[i].CpBS++;
                       }
                    }
                 }

               if(pairinfo[i].CpBL == 0 && pairinfo[i].CpSS == 0 && ((pairinfo[i].Trend != 2 || MAEntry_ == 0) || (pairinfo[i].Trend == 2 && MAEntry_ == 2)))
                 {
                  pairinfo[i].Entry = MathMod(pairinfo[i].ASK, pairinfo[i].g2) + pairinfo[i].EntryOffset_;

                  if(pairinfo[i].Entry > pairinfo[i].StopLevel)
                    {
                     pairinfo[i].Ticket = SendOrder(TradePairs[i]+suffix, OP_BUYLIMIT, pairinfo[i].OrderLot, -pairinfo[i].Entry, 0, Magic, CLR_NONE,i,pairinfo[i].Pip);

                     if(pairinfo[i].Ticket > 0)
                       {
                        if(Debug_)
                           Print("Indicator Entry - (", pairinfo[i].IndicatorUsed, ") BuyLimit MC = ", pairinfo[i].Trend);

                        pairinfo[i].CpBL++;
                       }
                    }
                 }
              }

            if(pairinfo[i].SellMe)
              {
               if(pairinfo[i].CpSL == 0 && pairinfo[i].CpBS == 0 && ((pairinfo[i].Trend != 2 || MAEntry_ == 0) || (pairinfo[i].Trend == 2 && MAEntry_ == 2)))
                 {
                  pairinfo[i].Entry = pairinfo[i].g2 - MathMod(pairinfo[i].BID, pairinfo[i].g2) + pairinfo[i].EntryOffset_;

                  if(pairinfo[i].Entry > pairinfo[i].StopLevel)
                    {
                     pairinfo[i].Ticket = SendOrder(TradePairs[i]+suffix, OP_SELLLIMIT, pairinfo[i].OrderLot, pairinfo[i].Entry, 0, Magic, CLR_NONE,i,pairinfo[i].Pip);

                     if(pairinfo[i].Ticket > 0 && Debug_)
                        Print("Indicator Entry - (", pairinfo[i].IndicatorUsed, ") SellLimit MC = ", pairinfo[i].Trend);
                    }
                 }

               if(pairinfo[i].CpSS == 0 && pairinfo[i].CpBL == 0 && ((pairinfo[i].Trend != 2 || MAEntry_ == 0) || (pairinfo[i].Trend == 2 && MAEntry_ == 1)))
                 {
                  pairinfo[i].Entry = MathMod(pairinfo[i].BID, pairinfo[i].g2) + pairinfo[i].EntryOffset_;

                  if(pairinfo[i].Entry > pairinfo[i].StopLevel)
                    {
                     pairinfo[i].Ticket = SendOrder(TradePairs[i]+suffix, OP_SELLSTOP, pairinfo[i].OrderLot, -pairinfo[i].Entry, 0, Magic, CLR_NONE,i,pairinfo[i].Pip);

                     if(pairinfo[i].Ticket > 0 && Debug_)
                        Print("Indicator Entry - (", pairinfo[i].IndicatorUsed, ") SellStop MC = ", pairinfo[i].Trend);
                    }
                 }
              }
           }
         else
           {
            if(pairinfo[i].BuyMe)
              {
               pairinfo[i].Ticket = SendOrder(TradePairs[i]+suffix, OP_BUY, pairinfo[i].OrderLot, 0, slip, Magic, Blue,i,pairinfo[i].Pip);

               if(pairinfo[i].Ticket > 0 && Debug_)
                  Print("Indicator Entry - (", pairinfo[i].IndicatorUsed, ") Buy");
              }
            else
               if(pairinfo[i].SellMe)
                 {
                  pairinfo[i].Ticket = SendOrder(TradePairs[i]+suffix, OP_SELL, pairinfo[i].OrderLot, 0, slip, Magic, displayColorLoss,i,pairinfo[i].Pip);

                  if(pairinfo[i].Ticket > 0 && Debug_)
                     Print("Indicator Entry - (", pairinfo[i].IndicatorUsed, ") Sell");
                 }
           }

         if(pairinfo[i].Ticket > 0)
            return (0);
        }
      else
         if(TimeCurrent() - EntryDelay > pairinfo[i].OTbL && pairinfo[i].CbT + pairinfo[i].CbC < MaxTrades && !FirstRun)
           {
            if(UseSmartGrid)
              {
               if(pairinfo[i].RSI[1] != iRSI(TradePairs[i]+suffix, TF[RSI_TF], RSI_Period, RSI_Price, 1))
                 {
                  for(int Index = 0; Index < RSI_Period + RSI_MA_Period; Index++)
                     pairinfo[i].RSI[Index] = iRSI(TradePairs[i]+suffix, TF[RSI_TF], RSI_Period, RSI_Price, Index);
                 }
               else
                  pairinfo[i].RSI[0] = iRSI(TradePairs[i]+suffix, TF[RSI_TF], RSI_Period, RSI_Price, 0);

               pairinfo[i].RSI_MA = iMAOnArray(pairinfo[i].RSI, 0, RSI_MA_Period, 0, RSI_MA_Method, 0);
              }

            if(pairinfo[i].CbB > 0)
              {
               if(pairinfo[i].OPbL > pairinfo[i].ASK)
                  pairinfo[i].Entry = pairinfo[i].OPbL - (MathRound((pairinfo[i].OPbL - pairinfo[i].ASK) / pairinfo[i].g2) + 1) * pairinfo[i].g2;
               else
                  pairinfo[i].Entry = pairinfo[i].OPbL - pairinfo[i].g2;

               if(UseSmartGrid)
                 {
                  if(pairinfo[i].ASK < pairinfo[i].OPbL - pairinfo[i].g2)
                    {
                     if(pairinfo[i].RSI[0] > pairinfo[i].RSI_MA)
                       {
                        pairinfo[i].Ticket = SendOrder(TradePairs[i]+suffix, OP_BUY, pairinfo[i].OrderLot, 0, slip, Magic, Blue,i,pairinfo[i].Pip);

                        if(pairinfo[i].Ticket > 0 && Debug_)
                           Print("SmartGrid Buy RSI: ", pairinfo[i].RSI[0], " > MA: ", pairinfo[i].RSI_MA);
                       }

                     pairinfo[i].OPbN = 0;
                    }
                  else
                     pairinfo[i].OPbN = pairinfo[i].OPbL - pairinfo[i].g2;
                 }
               else
                  if(pairinfo[i].CpBL == 0)
                    {
                     if(pairinfo[i].ASK - pairinfo[i].Entry <= pairinfo[i].StopLevel)
                        pairinfo[i].Entry = pairinfo[i].OPbL - (MathFloor((pairinfo[i].OPbL - pairinfo[i].ASK + pairinfo[i].StopLevel) / pairinfo[i].g2) + 1) * pairinfo[i].g2;

                     pairinfo[i].Ticket = SendOrder(TradePairs[i]+suffix, OP_BUYLIMIT, pairinfo[i].OrderLot, pairinfo[i].Entry - pairinfo[i].ASK, 0, Magic, SkyBlue,i,pairinfo[i].Pip);

                     if(pairinfo[i].Ticket > 0 && Debug_)
                        Print("BuyLimit grid");
                    }
                  else
                     if(pairinfo[i].CpBL == 1 && pairinfo[i].Entry - pairinfo[i].OPpBL > pairinfo[i].g2 / 2 && pairinfo[i].ASK - pairinfo[i].Entry > pairinfo[i].StopLevel)
                       {
                        for(int Order = OrdersTotal() - 1; Order >= 0; Order--)
                          {
                           if(!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
                              continue;

                           if(OrderMagicNumber() != Magic || OrderSymbol() != TradePairs[i]+suffix || OrderType() != OP_BUYLIMIT)
                              continue;

                           pairinfo[i].Success = ModifyOrder(pairinfo[i].Entry, 0, SkyBlue,i);

                           if(pairinfo[i].Success && Debug_)
                              Print("Mod BuyLimit Entry");
                          }
                       }
              }
            else
               if(pairinfo[i].CbS > 0)
                 {
                  if(pairinfo[i].BID > pairinfo[i].OPbL)
                     pairinfo[i].Entry = pairinfo[i].OPbL + (MathRound((-pairinfo[i].OPbL + pairinfo[i].BID) / pairinfo[i].g2) + 1) * pairinfo[i].g2;
                  else
                     pairinfo[i].Entry = pairinfo[i].OPbL + pairinfo[i].g2;

                  if(UseSmartGrid)
                    {
                     if(pairinfo[i].BID > pairinfo[i].OPbL + pairinfo[i].g2)
                       {
                        if(pairinfo[i].RSI[0] < pairinfo[i].RSI_MA)
                          {
                           pairinfo[i].Ticket = SendOrder(TradePairs[i]+suffix, OP_SELL, pairinfo[i].OrderLot, 0, slip, Magic, displayColorLoss,i,pairinfo[i].Pip);

                           if(pairinfo[i].Ticket > 0 && Debug_)
                              Print("SmartGrid Sell RSI: ", pairinfo[i].RSI[0], " < MA: ", pairinfo[i].RSI_MA);
                          }

                        pairinfo[i].OPbN = 0;
                       }
                     else
                        pairinfo[i].OPbN = pairinfo[i].OPbL + pairinfo[i].g2;
                    }
                  else
                     if(pairinfo[i].CpSL == 0)
                       {
                        if(pairinfo[i].Entry - pairinfo[i].BID <= pairinfo[i].StopLevel)
                           pairinfo[i].Entry = pairinfo[i].OPbL + (MathFloor((-pairinfo[i].OPbL + pairinfo[i].BID + pairinfo[i].StopLevel) / pairinfo[i].g2) + 1) * pairinfo[i].g2;

                        pairinfo[i].Ticket = SendOrder(TradePairs[i]+suffix, OP_SELLLIMIT, pairinfo[i].OrderLot, pairinfo[i].Entry - pairinfo[i].BID, 0, Magic, Coral,i,pairinfo[i].Pip);

                        if(pairinfo[i].Ticket > 0 && Debug_)
                           Print("SellLimit grid");
                       }
                     else
                        if(pairinfo[i].CpSL == 1 && pairinfo[i].OPpSL - pairinfo[i].Entry > pairinfo[i].g2 / 2 && pairinfo[i].Entry - pairinfo[i].BID > pairinfo[i].StopLevel)
                          {
                           for(int Order = OrdersTotal() - 1; Order >= 0; Order--)
                             {
                              if(!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
                                 continue;

                              if(OrderMagicNumber() != Magic || OrderSymbol() != TradePairs[i]+suffix || OrderType() != OP_SELLLIMIT)
                                 continue;

                              pairinfo[i].Success = ModifyOrder(pairinfo[i].Entry, 0, Coral);

                              if(pairinfo[i].Success && Debug_)
                                 Print("Mod SellLimit Entry");
                             }
                          }
                 }

            if(pairinfo[i].Ticket > 0)
               return (0);
           }
      //+-----------------------------------------------------------------+
      //| Check DD% and send Email                                        |
      //+-----------------------------------------------------------------+
      if((UseEmail || PlaySounds) && !Testing)
        {
         if(EmailCount < 2 && Email[EmailCount] > 0 && pairinfo[i].DrawDownPC > Email[EmailCount])
           {
            GetLastError();

            if(UseEmail)
              {
               SendMail("Drawdown warning", "Drawdown has exceeded " + DTS(Email[EmailCount] * 100, 2) + "% on " + TradePairs[i]+suffix + " " + sTF);
               Error = GetLastError();

               if(Error > 0)
                  Print("Email DD: ", DTS(pairinfo[i].DrawDownPC * 100, 2), " Error: ", Error, " (", ErrorDescription(Error), ")");
               else
                  if(Debug_)
                     Print("DrawDown Email sent for ", TradePairs[i]+suffix, " ", sTF, "  DD: ", DTS(pairinfo[i].DrawDownPC * 100, 2));
               EmailSent = TimeCurrent();
               EmailCount++;
              }

            if(PlaySounds)
               PlaySound(AlertSound);
           }
         else
            if(EmailCount > 0 && EmailCount < 3 && pairinfo[i].DrawDownPC < Email[EmailCount] && TimeCurrent() > EmailSent + EmailHours * 3600)
               EmailCount--;
        }
     }
//+-----------------------------------------------------------------+
//| Display Overlay Code                                            |
//+-----------------------------------------------------------------+
   string dMess = "";

   if((Testing && Visual) || !Testing)
     {
      if(Debug_ || !Debug_)
        {
         string dSpace;

         for(int Index = 0; Index <= 175; Index++)
            dSpace = dSpace + " ";

         dMess = "\n\n"+ dSpace + "Ticket   Magic     Type Lots OpenPrice  Costs  Profit  Potential";

         for(int Order = 0; Order < OrdersTotal(); Order++)
           {
            if(!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
               continue;

            if(OrderMagicNumber() != Magic)
               continue;

            dMess = (dMess + "\n" + dSpace + " " + (string) OrderTicket() + "  " + DTS(OrderMagicNumber(), 0) + "   " + (string) OrderType());
            dMess = (dMess + "   " + DTS(OrderLots(), pairinfo[i].LotDecimal) + "  " + DTS(OrderOpenPrice(), Digits));
            dMess = (dMess + "     " + DTS(OrderSwap() + OrderCommission(), 2));
            dMess = (dMess + "    " + DTS(OrderProfit() + OrderSwap() + OrderCommission(), 2));

            if(OrderMagicNumber() != Magic)
               continue;
            else
               if(OrderType() == OP_BUY)
                  dMess = (dMess + "      " + DTS(OrderLots() * (pairinfo[i].TPb - OrderOpenPrice()) * pairinfo[i].PipVal2 + OrderSwap() + OrderCommission(), 2));
               else
                  if(OrderType() == OP_SELL)
                     dMess = (dMess + "      " + DTS(OrderLots() * (OrderOpenPrice() - pairinfo[i].TPb) * pairinfo[i].PipVal2 + OrderSwap() + OrderCommission(), 2));
           }

         if(!dLabels)
           {
            dLabels = true;
           }
        }
     }

//   WindowRedraw();
   FirstRun = false;
   Comment(CS, dMess);
   }
   return (0);
}


//+-----------------------------------------------------------------+
//| Check Lot Size Function                                         |
//+-----------------------------------------------------------------+
double LotSize(double NewLot, int count, int localLotDecimal, double localMinLotSize)
  {
   NewLot = ND(NewLot, localLotDecimal);
   NewLot = MathMin(NewLot, MarketInfo(TradePairs[count]+suffix, MODE_MAXLOT));
   localMinLotSize = MarketInfo(TradePairs[count]+suffix, MODE_MINLOT);
   NewLot = MathMax(NewLot, localMinLotSize);

   return (NewLot);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double margin_maxlots(string pairs)
  {
   return (AccountFreeMargin() / MarketInfo(pairs, MODE_MARGINREQUIRED));
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double portion_maxlots(double PortionBalance, string pairs)
  {
   return (PortionBalance / MarketInfo(pairs, MODE_MARGINREQUIRED));
  }


//+-----------------------------------------------------------------+
//| Open Order Function                                             |
//+-----------------------------------------------------------------+
int SendOrder(string OSymbol, int OCmd, double OLot, double OPrice, int OSlip, int OMagic, color OColor = CLR_NONE, int count=0, double localPip=0)
  {
   if(FirstRun)
      return (-1);

   int Ticket = 0;
   int Tries = 0;
   int OType = (int) MathMod(OCmd, 2);
   double OrderPrice;

// check margin against MinMarginPercent
   if(UseMinMarginPercent && AccountMargin() > 0)
     {
      // double ml = ND(AccountEquity() / AccountMargin() * 100, 2);
      double ml = ND(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL), 2);
      Print("Account Margin Level: " + DTS(ml,2));
      if(ml < MinMarginPercent)
        {
         Print("Margin percent " + (string) ml + "% too low to open new trade");
         return -1;
        }
     }

// Sanity check lots vs. portion and margin ... r.f.
   if(OLot > (portion_maxlots(pairinfo[count].PortionBalance, OSymbol) - LbT))        // Request lots vs Portion - Current lots out
     {
      Print("Insufficient Portion free ", OSymbol, "  Type: ", OType, " Lots: ", DTS(OLot, 2),
            "  Free margin: ", DTS(AccountFreeMargin(), 2), "  Margin Maxlots: ", DTS(margin_maxlots(OSymbol), 2), "  Portion Maxlots: ", DTS(pairinfo[count].PortionBalance, 2), "  Current Lots: ", DTS(LbT, 2));
      return (-1);

      // OLot = portion_maxlots(pairinfo[count].PortionBalance, OSymbol) - LbT - MinLotSize;
      // Print("Reducing order to: ", DTS(OLot, 2));
     }

   if(AccountFreeMarginCheck(OSymbol, OType, OLot) <= 0 || GetLastError() == ERR_NOT_ENOUGH_MONEY)
     {
      Print("Not enough margin ", OSymbol, "  Type: ", OType, " Lots: ", DTS(OLot, 2),
            "  Free margin: ", DTS(AccountFreeMargin(), 2), "  Margin Maxlots: ", DTS(margin_maxlots(OSymbol), 2), "  Portion Maxlots: ", DTS(portion_maxlots(pairinfo[count].PortionBalance, OSymbol), 2), "  Current Lots: ", DTS(LbT, 2));

      return (-1);
     }

   if(MaxSpread > 0 && MarketInfo(OSymbol, MODE_SPREAD) * Point / localPip > MaxSpread)
      return (-1);

   while(Tries < 5)
     {
      Tries++;

      while(IsTradeContextBusy())
         Sleep(100);

      if(IsStopped())
         return (-1);
      else
         if(OType == 0)
            OrderPrice = ND(MarketInfo(OSymbol, MODE_ASK) + OPrice, (int) MarketInfo(OSymbol, MODE_DIGITS));
         else
            OrderPrice = ND(MarketInfo(OSymbol, MODE_BID) + OPrice, (int) MarketInfo(OSymbol, MODE_DIGITS));

if (Debug_) printf("im Order, OLot="+DoubleToStr(OLot,8));

      Ticket = OrderSend(OSymbol, OCmd, OLot, OrderPrice, OSlip, 0, 0, TradeComment, OMagic, 0, OColor);

      if(Ticket < 0)
        {
         Error = GetLastError();

         if(Error != 0)
            Print("Error ", Error, "(", ErrorDescription(Error), ") opening order - ",
                  "  Symbol: ", OSymbol, "  TradeOP: ", OCmd, "  OType: ", OType,
                  "  Ask: ", DTS(MarketInfo(OSymbol, MODE_ASK), Digits),
                  "  Bid: ", DTS(MarketInfo(OSymbol, MODE_BID), Digits), "  OPrice: ", DTS(OPrice, Digits), "  Price: ", DTS(OrderPrice, Digits), "  Lots: ", DTS(OLot, 2));

         switch(Error)
           {
            case ERR_TRADE_DISABLED:
               AllowTrading = false;
               Print("Broker has disallowed EAs on this account");
               Tries = 5;
               break;
            case ERR_OFF_QUOTES:
            case ERR_INVALID_PRICE:
               Sleep(5000);
            case ERR_PRICE_CHANGED:
            case ERR_REQUOTE:
               RefreshRates();
            case ERR_SERVER_BUSY:
            case ERR_NO_CONNECTION:
            case ERR_BROKER_BUSY:
            case ERR_TRADE_CONTEXT_BUSY:
               Tries++;
               break;
               Tries = 5;
               break;
            default:
               Tries = 5;
           }
        }
      else
        {
         if(PlaySounds)
            PlaySound(AlertSound);

         break;
        }
     }

   return (Ticket);
  }


//+-----------------------------------------------------------------+
//| Modify Order Function                                           |
//+-----------------------------------------------------------------+
bool ModifyOrder(double OrderOP, double OrderSL, color Color = CLR_NONE, int count=0)
  {
   bool Success = false;
   int Tries = 0;

   while(Tries < 5 && !Success)
     {
      Tries++;

      while(IsTradeContextBusy())
         Sleep(100);

      if(IsStopped())
         return (false);     //(-1)

      Success = OrderModify(OrderTicket(), OrderOP, OrderSL, 0, 0, Color);

      if(!Success)
        {
         Error = GetLastError();

         if(Error > 1)
           {
            Print("Error ", Error, " (", ErrorDescription(Error), ") modifying order ", OrderTicket(), "  Ask: ", Ask,
                  "  Bid: ", Bid, "  OrderPrice: ", OrderOP, "  StopLevel: ", pairinfo[count].StopLevel, "  SL: ", OrderSL, "  OSL: ", OrderStopLoss());

            switch(Error)
              {
               case ERR_TRADE_MODIFY_DENIED:
                  Sleep(10000);
               case ERR_OFF_QUOTES:
               case ERR_INVALID_PRICE:
                  Sleep(5000);
               case ERR_PRICE_CHANGED:
               case ERR_REQUOTE:
                  RefreshRates();
               case ERR_SERVER_BUSY:
               case ERR_NO_CONNECTION:
               case ERR_BROKER_BUSY:
               case ERR_TRADE_CONTEXT_BUSY:
               case ERR_TRADE_TIMEOUT:
                  Tries++;
                  break;
               default:
                  Tries = 5;
                  break;
              }
           }
         else
            Success = true;
        }
      else
         break;
     }

   return (Success);
  }


//+-------------------------------------------------------------------------+
//| Exit Trade Function - Type: All Basket Ticket Pending             |
//+-------------------------------------------------------------------------+
int ExitTrades(int Type, color Color, string Reason, int OTicket, int &localca, string localTradePairs="")
  {

   if(Debug_)Comment("Reason; "+Reason);
   if(Debug_)Print("Reason; "+Reason);
   static int OTicketNo; //why static?
   bool Success;
   int Tries = 0, Closed = 0, CloseCount = 0;
   int CloseTrades[, 2];
   double OPrice;
   string s;
   localca=0;
   localca = Type;

   if(Type == T)
     {
      if(OTicket == 0)
         OTicket = OTicketNo;
      else
         OTicketNo = OTicket;
     }


//Here the orders to be closed are selected and written into array CloseTrades
   for(int Order = OrdersTotal() - 1; Order >= 0; Order--)
     {
      if(!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
         continue;
         
//    if(OrderMagicNumber() != Magic || OrderSymbol() != localTradePairs) { 
//      Print("nothing found");
//      continue;
//      }    
//    else Print("Magic number for the Trade", OrderMagicNumber(),OrderSymbol());

   if(Debug_)Comment("OrderSymbol; "+OrderSymbol());
   if(Debug_)Print("OrderSymbol; "+OrderSymbol());
   if(Debug_)Comment("OrderMagicNumber(); "+IntegerToString(OrderMagicNumber()));
   if(Debug_)Print("OrderMagicNumber() "+IntegerToString(OrderMagicNumber()));

      if (Type == B) 
         {
         if (OrderMagicNumber() != Magic) continue;
         if (localTradePairs != OrderSymbol()) continue;
         }
         else
            if(Type == A)
               {
               if (OrderMagicNumber() != Magic) continue;
               if (localTradePairs != "") continue;
               }
             else
               if(Type == T && OrderTicket() != OTicket) continue;
                  else
                     if(Type == P)
                        {
                        if (OrderMagicNumber() != Magic) continue;
//nächste Abfrage auf Logik überprüfen, scheint nicht zu stimmen, ist ja schon spät                        
                        if (localTradePairs != OrderSymbol() && localTradePairs != "") continue;
                        }
           




      ArrayResize(CloseTrades, CloseCount + 1);
      CloseTrades[CloseCount, 0] = (int) OrderOpenTime();
      CloseTrades[CloseCount, 1] = OrderTicket();
      CloseCount++;
     }

//Here the selected Orders are finally closed/deleted, using array CloseTrades
   if(CloseCount > 0)
     {
      if(!UseFIFO)
         ArraySort(CloseTrades, WHOLE_ARRAY, 0, MODE_DESCEND);
      else
         if(CloseCount != ArraySort(CloseTrades))
            Print("Error sorting CloseTrades Array");

      for(int Order = 0; Order < CloseCount; Order++)
        {
         if(!OrderSelect(CloseTrades[Order, 1], SELECT_BY_TICKET))
            continue;

         while(IsTradeContextBusy())
            Sleep(100);

         if(IsStopped())
            return (-1);
         else
            if(OrderType() > OP_SELL)
               Success = OrderDelete(OrderTicket(), Color);
            else
              {
               if(OrderType() == OP_BUY)
                  OPrice = ND(MarketInfo(localTradePairs, MODE_BID), (int) MarketInfo(OrderSymbol(), MODE_DIGITS));
               else
                  OPrice = ND(MarketInfo(localTradePairs, MODE_ASK), (int) MarketInfo(OrderSymbol(), MODE_DIGITS));

               Success = OrderClose(OrderTicket(), OrderLots(), OPrice, slip, Color);
              }

         if(Success)
            Closed++;
         else
           {
            Error = GetLastError();
            Print("Error ", Error, " (", ErrorDescription(Error), ") closing order ", OrderTicket());

            switch(Error)
              {
               case ERR_NO_ERROR:
               case ERR_NO_RESULT:
                  Success = true;
                  break;
               case ERR_OFF_QUOTES:
               case ERR_INVALID_PRICE:
                  Sleep(5000);
               case ERR_PRICE_CHANGED:
               case ERR_REQUOTE:
                  RefreshRates();
               case ERR_SERVER_BUSY:
               case ERR_NO_CONNECTION:
               case ERR_BROKER_BUSY:
               case ERR_TRADE_CONTEXT_BUSY:
                  Print("Attempt ", (Tries + 1), " of 5: Order ", OrderTicket(), " failed to close. Error:", ErrorDescription(Error));
                  Tries++;
                  break;
               case ERR_TRADE_TIMEOUT:
               default:
                  Print("Attempt ", (Tries + 1), " of 5: Order ", OrderTicket(), " failed to close. Fatal Error:", ErrorDescription(Error));
                  Tries = 5;
                  localca = 0;
                  break;
              }
           }
        }

      if(Closed == CloseCount || Closed == 0)
         localca = 0;
     }
   else
      localca = 0;

   if(Closed > 0)
     {
      if(Closed != 1)
         s = "s";

      Print("Closed ", Closed, " position", s, " because ", Reason);

      if(PlaySounds)
         PlaySound(AlertSound);
     }

   return (Closed);
  }


//+-----------------------------------------------------------------+
//| Find Hedge Profit                                               |
//+-----------------------------------------------------------------+
double FindClosedPL(int Type, datetime localOTbF, int localCbC)
  {
   double ClosedProfit = 0;

   if(Type == B && UseCloseOldest)
      localCbC = 0;

   if(localOTbF > 0)
     {
      for(int Order = OrdersHistoryTotal() - 1; Order >= 0; Order--)
        {
         if(!OrderSelect(Order, SELECT_BY_POS, MODE_HISTORY))
            continue;

         if(OrderOpenTime() < localOTbF)
            continue;

         if(Type == B && OrderMagicNumber() == Magic && OrderType() <= OP_SELL)
           {
            ClosedProfit += OrderProfit() + OrderSwap() + OrderCommission();

            if(UseCloseOldest)
               localCbC++;
           }
        }
     }

   return (ClosedProfit);
  }

//+------------------------------------------------------------------+
//|  Save Equity / Balance Statistics                                |
//+------------------------------------------------------------------+
void Stats(bool NewFile, bool IsTick, double Balance, double DrawDown)
  {
   double Equity = Balance + DrawDown;
   datetime TimeNow = TimeCurrent();

   if(IsTick)
     {
      if(Equity < StatLowEquity)
         StatLowEquity = Equity;

      if(Equity > StatHighEquity)
         StatHighEquity = Equity;
     }
   else
     {
      while(TimeNow >= NextStats)
         NextStats += StatsPeriod;

      int StatHandle;

      if(NewFile)
        {
         StatHandle = FileOpen(StatFile, FILE_WRITE | FILE_CSV, ',');
         Print("Stats " + StatFile + " " + (string) StatHandle);
         FileWrite(StatHandle, "Date", "Time", "Balance", "Equity Low", "Equity High", TradeComment);
        }
      else
        {
         StatHandle = FileOpen(StatFile, FILE_READ | FILE_WRITE | FILE_CSV, ',');
         FileSeek(StatHandle, 0, SEEK_END);
        }

      if(StatLowEquity == 0)
        {
         StatLowEquity = Equity;
         StatHighEquity = Equity;
        }

      FileWrite(StatHandle, TimeToStr(TimeNow, TIME_DATE), TimeToStr(TimeNow, TIME_SECONDS), DTS(Balance, 0), DTS(StatLowEquity, 0), DTS(StatHighEquity, 0));
      FileClose(StatHandle);

      StatLowEquity = Equity;
      StatHighEquity = Equity;
     }
  }


//+-----------------------------------------------------------------+
//| Magic Number Generator                                          |
//+-----------------------------------------------------------------+
int GenerateMagicNumber()
  {
   if(EANumber_ > 99)
      return (EANumber_);

   return (JenkinsHash((string) EANumber_ + "_" + Symbol() + "__" + (string) Period()));
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int JenkinsHash(string Input)
  {
   int MagicNo = 0;

   for(int Index = 0; Index < StringLen(Input); Index++)
     {
      MagicNo += StringGetChar(Input, Index);
      MagicNo += (MagicNo << 10);
      MagicNo ^= (MagicNo >> 6);
     }

   MagicNo += (MagicNo << 3);
   MagicNo ^= (MagicNo >> 11);
   MagicNo += (MagicNo << 15);

   return (MathAbs(MagicNo));
  }


//+-----------------------------------------------------------------+
//| Normalize Double                                                |
//+-----------------------------------------------------------------+
double ND(double Value, int Precision)
  {
   return (NormalizeDouble(Value, Precision));
  }


//+-----------------------------------------------------------------+
//| Double To String                                                |
//+-----------------------------------------------------------------+
string DTS(double Value, int Precision)
  {
   return (DoubleToStr(Value, Precision));
  }


//+-----------------------------------------------------------------+
//| Integer To String                                                |
//+-----------------------------------------------------------------+
string ITS(int Value)
  {
   return (IntegerToString(Value));
  }
  
//+-----------------------------------------------------------------+
//| Once Per Bar function    returns true once per bar              |
//+-----------------------------------------------------------------+
bool OncePerBar(datetime localOncePerBarTime)
  {
   if(!EnableOncePerBar || FirstRun)
      return (true);          // always return true if disabled

   if(localOncePerBarTime != Time[0])
     {
      localOncePerBarTime = Time[0];
      return (true);          // true, our first time this bar
     }
   return (true);
  }

//+-----------------------------------------------------------------+
//| getPrefixSuffix function for brokers that use suffix (i.e. USDi)|
//+-----------------------------------------------------------------+
#define sectorSize  1936
#define HFILE_ERROR -1
void getPrefixSuffix(string& oprefix, string& osuffix)
{ 
   int fileHandle = FileOpenHistory("symbols.raw",FILE_BIN|FILE_READ|FILE_SHARE_READ|FILE_WRITE|FILE_SHARE_WRITE);
   if (fileHandle == HFILE_ERROR) {
      Print("Open symbols.raw failed");
      return;
   }

   oprefix="";
   osuffix="";
   for(int i=0;; i++)
   {
      FileSeek(fileHandle, sectorSize*i, SEEK_SET);
         if (FileIsEnding(fileHandle)) { 
            break; 
         }
string symbolName = FileReadString(fileHandle,12);
      symbolName = StringSubstr(symbolName, 0);
                   
            int pos = StringFind(symbolName,"EURUSD",0);
             if (pos > -1)
             {
                if (pos>0)
                  oprefix = StringSubstr(symbolName,0,pos);
                if ((pos+6)<StringLen(symbolName)) {
                  osuffix = StringSubstr(symbolName,(pos+6),0);
                  Print("Dashboard detected suffix: "+suffix);
                }
                break;
             }     
   } 

   if (fileHandle>-1)
      FileClose(fileHandle);
}