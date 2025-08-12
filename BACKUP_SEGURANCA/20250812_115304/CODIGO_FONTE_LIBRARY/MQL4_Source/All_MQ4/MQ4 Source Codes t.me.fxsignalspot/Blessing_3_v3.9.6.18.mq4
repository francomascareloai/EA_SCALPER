//+---------------------------------------------------------------------+
//|                                                Blessing 3 v3.9.6.18 |
//|                                                       July 20, 2020 |
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

//+-----------------------------------------------------------------------------
// Versions .10 thru .18 ...
//
//	.10 Clean up for new versions of MT4 and potentially MT5,
//		passes #property strict added EnableOncePerBar to allow use of
//		Open Prices Only model of MT4 Strategy Tester to vastly speed up
//		optimization.  Filters out ticks!
//		Also a few bug fixes and cosmetic changes.
//	.11	Repaired external parameters from .10 so they match the Blessing manual
//	.12	Added UseMinMarginPercent control to keep margin from dropping too low.
//	.13 Holiday bug fix.
//	.14 Enhanced PortionPC behavior, settings over 100 force effective balance
//		to that amount.  Assuming real balance is greater.
//	.15 Fixed divide by zero error
//	.16 Fixed Draw Down display
//	.17
//	.18 Added MA_TF, to replace hardwired Current setting for more control
//+-----------------------------------------------------------------------------

#property version   "396.18"
#property strict

#include <stdlib.mqh>
#include <stderror.mqh>
#include <WinUser32.mqh>

#define A 1                     //All (Basket + Hedge)
#define B 2                     //Basket
#define H 3                     //Hedge
#define T 4                     //Ticket
#define P 5                     //Pending

enum portChgs {
    no_change = 0,              // No changes
    increase = 1,               // Increase only
    any = -1,                   // Increase / decrease
};

enum mktCond {
    uptrend = 0,                // Long only
    downtrend = 1,              // Short only
    range = 2,                  // Long & short
    automatic = 3               // Automatic
};

enum entType {
    disable = 0,                // Disabled
    enable = 1,                 // Enabled
    reverse = 2                 // Reverse
};

enum tFrame {
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

input string Version_3_9_6_18 = "EA Settings:";
input string TradeComment = "b3_v396.18";
input string Notes = "";
input int EANumber = 1;         // EA Magic Number
input bool EmergencyCloseAll = false;   // *** CLOSE ALL NOW ***
// input bool	kludge_fix = true;

input string s1 = "";           //.
input bool ShutDown = false;    // *** NO NEW TRADES ***
input string s2 = "";           //.

input string LabelAcc = "";     // ==   ACCOUNT SETTINGS   ==
input double StopTradePercent = 10;;    // Percentage of balance lost before trading stops

input bool NanoAccount = false;;        // Small Lot Account (0.01)
input string s3 = "... PortionPC > 100 forces effective balance to that amount (e.g. 1000)"; //.
input double PortionPC = 100;;  // Percentage of account you want to trade on this pair
input portChgs PortionChange = increase;;       // Permitted Portion change with open basket
// If basket open: 0=no Portion change;1=allow portion to increase; -1=allow increase and decrease
input double MaxDDPercent = 50;;        // Percent of portion for max drawdown level.
input double MaxSpread = 5;;    // Maximum allowed spread while placing trades
input bool UseHolidayShutdown = true;;  // Enable holiday shut-downs
input string Holidays = "18/12-01/01";; // Comma-separated holiday list (format: [day]/[mth]-[day]/[mth])
input bool PlaySounds = false;; // Audible alerts
input string AlertSound = "Alert.wav";; // Alert sound

input string eopb = "";         // -- Opt. with 'Open prices only' --
// input string   eopb0                   = "Filters out ticks"; //. 
input bool EnableOncePerBar = true;
input bool UseMinMarginPercent = false;
input double MinMarginPercent = 1500;
input string eopb1 = "";        //. 

input bool B3Traditional = true;;       // Stop/Limits for entry if true, Buys/Sells if false
input mktCond ForceMarketCond = 3;;     // Market condition
// 0=uptrend 1=downtrend 2=range 3=automatic
input bool UseAnyEntry = false;;        // true = ANY entry can be used to open orders, false = ALL entries used to open orders

// input entType  MAEntry            = 1; // MA Entry
// input entType  CCIEntry           = 0; // CCI Entry
// input entType  BollingerEntry     = 0; // Bollinger Entry
// input entType  StochEntry         = 0; // Stochastic Entry
// input entType  MACDEntry          = 0; // MACD Entry
// 0=disable 1=enable 2=reverse

input string LabelLS = "";      // -----------   LOT SIZE   -----------
input bool UseMM = true;        // UseMM   (Money Management)
input double LAF = 0.5;;        // Adjusts MM base lot for large accounts
input double Lot = 0.01;;       // Starting lots if Money Management is off
input double Multiplier = 1.4;; // Multiplier on each level

input string LabelGS = "";      // ------     GRID SETTINGS    ------
input bool AutoCal = false;;    // Auto calculation of TakeProfit and Grid size;
input tFrame ATRTF = 0;;        // TimeFrame for ATR calculation
input int ATRPeriods = 21;;     // Number of periods for the ATR calculation
input double GAF = 1.0;;        // Widens/Squishes Grid in increments/decrements of .1
input int EntryDelay = 2400;;   // Time Grid in seconds, avoid opening lots of levels in fast market
input double EntryOffset = 5;;  // In pips, used in conjunction with logic to offset first trade entry
input bool UseSmartGrid = true;;        // True = use RSI/MA calculation for next grid order

input string LabelTS = "";      // =====    TRADING    =====
input int MaxTrades = 15;;      // Maximum number of trades to place (stops placing orders when reaches MaxTrades)
input int BreakEvenTrade = 12;; // Close All level, when reaches this level, doesn't wait for TP to be hit
input double BEPlusPips = 2;;   // Pips added to Break Even Point before BE closure
input bool UseCloseOldest = false;;     // True = will close the oldest open trade after CloseTradesLevel is reached
input int CloseTradesLevel = 5;;        // will start closing oldest open trade at this level
input bool ForceCloseOldest = true;;    // Will close the oldest trade whether it has potential profit or not
input int MaxCloseTrades = 4;;  // Maximum number of oldest trades to close
input double CloseTPPips = 10;; // After Oldest Trades have closed, Forces Take Profit to BE +/- xx Pips
input double ForceTPPips = 0;;  // Force Take Profit to BE +/- xx Pips
input double MinTPPips = 0;;    // Ensure Take Profit is at least BE +/- xx Pips


input string LabelES = "";      // -----------     EXITS    -----------
input bool MaximizeProfit = false;;     // Turns on TP move and Profit Trailing Stop Feature
input double ProfitSet = 70;;   // Profit trailing stop: Lock in profit at set percent of Total Profit Potential
input double MoveTP = 30;;      // Moves TP this amount in pips
input int TotalMoves = 2;;      // Number of times you want TP to move before stopping movement
input bool UseStopLoss = false;;        // Use Stop Loss and/or Trailing Stop Loss
input double SLPips = 30;;      // Pips for fixed StopLoss from BE, 0=off
input double TSLPips = 10;;     // Pips for trailing stop loss from BE + TSLPips: +ve = fixed trail; -ve = reducing trail; 0=off
input double TSLPipsMin = 3;;   // Minimum trailing stop pips if using reducing TS
input bool UsePowerOutSL = false;;      // Transmits a SL in case of internet loss
input double POSLPips = 600;;   // Power Out Stop Loss in pips
input bool UseFIFO = false;;    // Close trades in FIFO order

input string LabelEE = "";      // ---------   EARLY EXITS   ---------
input bool UseEarlyExit = false;;       // Reduces ProfitTarget by a percentage over time and number of levels open
input double EEStartHours = 3;; // Number of Hours to wait before EE over time starts
input bool EEFirstTrade = true;;        // true = StartHours from FIRST trade: false = StartHours from LAST trade
input double EEHoursPC = 0.5;;  // Percentage reduction per hour (0 = OFF)
input int EEStartLevel = 5;;    // Number of Open Trades before EE over levels starts
input double EELevelPC = 10;;   // Percentage reduction at each level (0 = OFF)
input bool EEAllowLoss = false;;        // true = Will allow the basket to close at a loss : false = Minimum profit is Break Even

input string LabelAdv = "";     //.
input string LabelGrid = "";    // ---------    GRID SIZE   ---------
input string SetCountArray = "4,4";;    // Specifies number of open trades in each block (separated by a comma)
input string GridSetArray = "25,50,100";;       // Specifies number of pips away to issue limit order (separated by a comma)
input string TP_SetArray = "50,100,200";;       // Take profit for each block (separated by a comma)

input string LabelEST0 = "";    // .
input string LabelEST = "";     // ==  ENTRY PARAMETERS  ==
input string LabelMA = "";      // -------------     MA     -------------   
input entType MAEntry = 1;;     // MA Entry
input tFrame MA_TF = 0;;        // Time frame for MA calculation, r.f. ********
input int MAPeriod = 100;;      // Period of MA (H4 = 100, H1 = 400)
input double MADistance = 10;;  // Distance from MA to be treated as Ranging Market

input string LabelCCI = "";     // -------------     CCI     -------------
input entType CCIEntry = 0;;    // CCI Entry
input int CCIPeriod = 14;;      // Period for CCI calculation

input string LabelBBS = "";     // -----   BOLLINGER BANDS   -----
input entType BollingerEntry = 0;;      // Bollinger Entry
input int BollPeriod = 10;;     // Period for Bollinger
input double BollDistance = 10;;        // Up/Down spread
input double BollDeviation = 2.0;;      // Standard deviation multiplier for channel

input string LabelSto = "";     // ---------   STOCHASTIC   --------
input entType StochEntry = 0;;  // Stochastic Entry
input int BuySellStochZone = 20;;       // Determines Overbought and Oversold Zones
input int KPeriod = 10;;        // Stochastic KPeriod
input int DPeriod = 2;;         // Stochastic DPeriod
input int Slowing = 2;;         // Stochastic Slowing

input string LabelMACD = "";    //  ------------    MACD    ------------
input entType MACDEntry = 0;;   // MACD Entry
input tFrame MACD_TF = 0;;      // Time frame for MACD calculation
// 0:Chart, 1:M1, 2:M5, 3:M15, 4:M30, 5:H1, 6:H4, 7:D1, 8:W1, 9:MN1
input int FastPeriod = 12;;     // MACD EMA Fast Period
input int SlowPeriod = 26;;     // MACD EMA Slow Period
input int SignalPeriod = 9;;    // MACD EMA Signal Period
input ENUM_APPLIED_PRICE MACDPrice = 0;;        // MACD Applied Price
// 0=close, 1=open, 2=high, 3=low, 4=HL/2, 5=HLC/3 6=HLCC/4

input string LabelSG = "";      // ---------   SMART GRID   ---------
input tFrame RSI_TF = 3;;       // Timeframe for RSI calculation (should be lower than chart TF)
input int RSI_Period = 14;;     // Period for RSI calculation
input ENUM_APPLIED_PRICE RSI_Price = 0;;        // RSI Applied Price
input int RSI_MA_Period = 10;;  // Period for MA of RSI calculation
input ENUM_MA_METHOD RSI_MA_Method = 0;;        // RSI MA Method


// ***********************************************************
input string LabelHS0 = "";     //.
input string LabelHS = "";      // ------   HEDGE SETTINGS   -----
// input string   LabelHS1        = "";  //.
input string HedgeSymbol = "";; // Enter the Symbol of the same/correlated pair EXACTLY as used by your broker.
input int CorrPeriod = 30;;     // Number of days for checking Hedge Correlation
input bool UseHedge = false;;   // Turns DD hedge on/off
input string DDorLevel = "DD";; // DD = start hedge at set DD;Level = Start at set level
input double HedgeStart = 20;;  // DD Percent or Level at which Hedge starts
input double hLotMult = 0.8;;   // Hedge Lots = Open Lots * hLotMult
input double hMaxLossPips = 30;;        // DD Hedge maximum pip loss - also hedge trailing stop
input bool hFixedSL = false;;   // true = fixed SL at hMaxLossPips
input double hTakeProfit = 30;; // Hedge Take Profit
input double hReEntryPC = 5;;   // Increase to HedgeStart to stop early re-entry of the hedge
input bool StopTrailAtBE = true;;       // True = Trailing Stop will stop at BE;False = Hedge will continue into profit
input bool ReduceTrailStop = true;;     // False = Trailing Stop is Fixed;True = Trailing Stop will reduce after BE is reached
// ***********************************************************

input string LabelOS0 = "";     //.
input string LabelOS = "";      // ------------   OTHER   -----------
input bool RecoupClosedLoss = true;;    // true = Recoup any Hedge/CloseOldest losses: false = Use original profit target.
input int Level = 7;;           // Largest Assumed Basket size.  Lower number = higher start lots
int slip = 99;;
input bool SaveStats = false;;  // true = will save equity statistics
input int StatsPeriod = 3600;;  // seconds between stats entries - off by default
input bool StatsInitialise = true;;     // true for backtest - false for forward/live to ACCUMULATE equity traces

input string LabelUE = "";      // ------------   EMAIL   ------------
input bool UseEmail = false;;
input string LabelEDD = "At what DD% would you like Email warnings (Max: 49, Disable: 0)?";     //.
input double EmailDD1 = 20;;
input double EmailDD2 = 30;;
input double EmailDD3 = 40;;

input string LabelEH = "Hours before DD timer resets";  //.
input double EmailHours = 24;;  // Minimum number of hours between emails

input string LabelDisplay = ""; // ------------   DISPLAY   -----------
// input string   LabelDisplay       = "Used to Adjust Overlay"; //.
input bool displayOverlay = true;;      // Enable display
input bool displayLogo = true;; // Display copyright and icon
input bool displayCCI = true;;  // Enable CCI display
input bool displayLines = true;;        // Show BE, TP and TS lines
input int displayXcord = 100;;  // Left / right offset
input int displayYcord = 30;;   // Up / down offset
input int displayCCIxCord = 10;;        // Moves CCI display left and right
input string displayFont = "Arial Bold";        //Display font
input int displayFontSize = 9;; // Changes size of display characters
input int displaySpacing = 14;; // Changes space between lines
// input double   displayRatio       = 1;; // Ratio to increase label width spacing
input double displayRatio = 1.3;;       // Ratio to increase label width spacing
input color displayColor = DeepSkyBlue;;        // default color of display characters
input color displayColorProfit = Green;;        // default color of profit display characters
input color displayColorLoss = Red;;    // default color of loss display characters
// input color displayColorFGnd = White;;  // default color of ForeGround Text display characters
input color displayColorFGnd = Black;;  // default color of ForeGround Text display characters
input bool Debug = false;;

input string LabelGridOpt = ""; // ----   GRID OPTIMIZATION   ----
input string LabelOpt = "These values can only be used while optimizing";       //.
input bool UseGridOpt = false;; // Set True in order to optimize the grid settings.
// These values will replace the normal SetCountArray,
// GridSetArray and TP_SetArray during optimization.
// The default values are the same as the normal array defaults
// REMEMBER:
// There must be one more value for GridArray and TPArray
// than there is for SetArray
input int SetArray1 = 4;
input int SetArray2 = 4;
input int SetArray3 = 0;
input int SetArray4 = 0;
input int GridArray1 = 25;
input int GridArray2 = 50;
input int GridArray3 = 100;
input int GridArray4 = 0;
input int GridArray5 = 0;
input int TPArray1 = 50;
input int TPArray2 = 100;
input int TPArray3 = 200;
input int TPArray4 = 0;
input int TPArray5 = 0;

//+-----------------------------------------------------------------+
//| Internal Parameters Set                                         |
//+-----------------------------------------------------------------+
int ca;
int Magic, hMagic;
int CbT, CpT, ChT;              // Count basket Total,Count pending Total,Count hedge Total
double Pip, hPip;
int POSLCount;
double SLbL;                    // Stop Loss basket Last
int Moves;
double MaxDD;
double SLb;                     // Stop Loss
int AccountType;
double StopTradeBalance;
double InitialAB;               // Initial Account Balance
bool Testing, Visual;
bool AllowTrading;
bool EmergencyWarning;
double MaxDDPer;
int Error;
int Set1Level, Set2Level, Set3Level, Set4Level;
int EmailCount;
string sTF;
datetime EmailSent;
int GridArray[, 2];
double Lots[], MinLotSize, LotStep;
int LotDecimal, LotMult, MinMult;
bool PendLot;
string CS, UAE;
int HolShutDown;
// datetime HolArray[, 4];
int HolArray[, 4];
datetime HolFirst, HolLast, NextStats, OTbF;
double RSI[];
int Digit[, 2], TF[10] = { 0, 1, 5, 15, 30, 60, 240, 1440, 10080, 43200 };

double Email[3];
double PbC, PhC, hDDStart, PbMax, PbMin, PhMax, PhMin, LastClosedPL, ClosedPips, SLh, hLvlStart, StatLowEquity, StatHighEquity;
datetime EETime;
int hActive, EECount, TbF, CbC, CaL, FileHandle;
bool TradesOpen, FileClosed, HedgeTypeDD, hThisChart, hPosCorr, dLabels, FirstRun;
string FileName, ID, StatFile;
double TPb, StopLevel, TargetPips, LbF, bTS, PortionBalance;
bool checkResult;


//+-----------------------------------------------------------------+
//| Input Parameters Requiring Modifications To Entered Values      |
//+-----------------------------------------------------------------+
int EANumber_;
double EntryOffset_;
double MoveTP_;
double MADistance_;
double BollDistance_;
double POSLPips_;
double hMaxLossPips_;
double hTakeProfit_;
double CloseTPPips_;
double ForceTPPips_;
double MinTPPips_;
double BEPlusPips_;
double SLPips_;
double TSLPips_;
double TSLPipsMin_;
string HedgeSymbol_;
bool UseHedge_;
double HedgeStart_;
double StopTradePercent_;
double ProfitSet_;
double EEHoursPC_;
double EELevelPC_;
double hReEntryPC_;
double PortionPC_;
double Lot_;
bool Debug_;
mktCond ForceMarketCond_;
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



//+-----------------------------------------------------------------+
//| expert initialization function                                  |
//+-----------------------------------------------------------------+
int init() {
    EANumber_ = EANumber;
    EntryOffset_ = EntryOffset;
    MoveTP_ = MoveTP;
    MADistance_ = MADistance;
    BollDistance_ = BollDistance;
    POSLPips_ = POSLPips;
    hMaxLossPips_ = hMaxLossPips;
    hTakeProfit_ = hTakeProfit;
    CloseTPPips_ = CloseTPPips;
    ForceTPPips_ = ForceTPPips;
    MinTPPips_ = MinTPPips;
    BEPlusPips_ = BEPlusPips;
    SLPips_ = SLPips;
    TSLPips_ = TSLPips;
    TSLPipsMin_ = TSLPipsMin;
    HedgeSymbol_ = HedgeSymbol;
    UseHedge_ = UseHedge;
    HedgeStart_ = HedgeStart;
    StopTradePercent_ = StopTradePercent;
    ProfitSet_ = ProfitSet;
    EEHoursPC_ = EEHoursPC;
    EELevelPC_ = EELevelPC;
    hReEntryPC_ = hReEntryPC;
    PortionPC_ = PortionPC;
	if (PortionPC > 100) PortionPC_ = 100; // r.f.
    Lot_ = Lot;
    Debug_ = Debug;
    ForceMarketCond_ = ForceMarketCond;
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

    ChartSetInteger(0, CHART_SHOW_GRID, false);
    CS = "Waiting for next tick .";     // To display comments while testing, simply use CS = .... and
    Comment(CS);                // it will be displayed by the line at the end of the start() block.
    CS = "";
    Testing = IsTesting();
    Visual = IsVisualMode();
    FirstRun = true;
    AllowTrading = true;

    if (EANumber_ < 1)
        EANumber_ = 1;

    if (Testing)
        EANumber_ = 0;

    Magic = GenerateMagicNumber();
    hMagic = JenkinsHash((string) Magic);
    FileName = "B3_" + (string) Magic + ".dat";

    if (Debug_) {
        Print("Magic Number: ", DTS(Magic, 0));
        Print("Hedge Number: ", DTS(hMagic, 0));
        Print("FileName: ", FileName);
    }

    Pip = Point;

    if (Digits % 2 == 1)
        Pip *= 10;

    if (NanoAccount)
        AccountType = 10;
    else
        AccountType = 1;

    MoveTP_ = ND(MoveTP_ * Pip, Digits);
    EntryOffset_ = ND(EntryOffset_ * Pip, Digits);
    MADistance_ = ND(MADistance_ * Pip, Digits);
    BollDistance_ = ND(BollDistance_ * Pip, Digits);
    POSLPips_ = ND(POSLPips_ * Pip, Digits);
    hMaxLossPips_ = ND(hMaxLossPips_ * Pip, Digits);
    hTakeProfit_ = ND(hTakeProfit_ * Pip, Digits);
    CloseTPPips_ = ND(CloseTPPips_ * Pip, Digits);
    ForceTPPips_ = ND(ForceTPPips_ * Pip, Digits);
    MinTPPips_ = ND(MinTPPips_ * Pip, Digits);
    BEPlusPips_ = ND(BEPlusPips_ * Pip, Digits);
    SLPips_ = ND(SLPips_ * Pip, Digits);
    TSLPips_ = ND(TSLPips * Pip, Digits);
    TSLPipsMin_ = ND(TSLPipsMin_ * Pip, Digits);

    if (UseHedge_) {
        if (HedgeSymbol_ == "")
            HedgeSymbol_ = Symbol();

        if (HedgeSymbol_ == Symbol())
            hThisChart = true;
        else
            hThisChart = false;

        hPip = MarketInfo(HedgeSymbol_, MODE_POINT);
        int hDigits = (int) MarketInfo(HedgeSymbol_, MODE_DIGITS);

        if (hDigits % 2 == 1)
            hPip *= 10;

        if (CheckCorr() > 0.9 || hThisChart)
            hPosCorr = true;
        else if (CheckCorr() < -0.9)
            hPosCorr = false;
        else {
            AllowTrading = false;
            UseHedge_ = false;
            Print("The specified Hedge symbol (", HedgeSymbol_, ") is not closely correlated with ", Symbol());
        }

        if (StringSubstr(DDorLevel, 0, 1) == "D" || StringSubstr(DDorLevel, 0, 1) == "d")
            HedgeTypeDD = true;
        else if (StringSubstr(DDorLevel, 0, 1) == "L" || StringSubstr(DDorLevel, 0, 1) == "l")
            HedgeTypeDD = false;
        else
            UseHedge_ = false;

        if (HedgeTypeDD) {
            HedgeStart_ /= 100;
            hDDStart = HedgeStart_;
        }
    }

    StopTradePercent_ /= 100;
    ProfitSet_ /= 100;
    EEHoursPC_ /= 100;
    EELevelPC_ /= 100;
    hReEntryPC_ /= 100;
    PortionPC_ /= 100;

    InitialAB = AccountBalance();
	// PortionPC now does double duty.  If > 100 serves as forced balance
	//  assuming the real balance is greater than PortionPC
	if (PortionPC > 100 && InitialAB > PortionPC) {
		InitialAB = PortionPC;
	}
	Print("*** Account balance: " +  DTS(InitialAB, 0));
    StopTradeBalance = InitialAB * (1 - StopTradePercent_);

    if (Testing)
        ID = "B3Test.";
    else
        ID = DTS(Magic, 0) + ".";

    HideTestIndicators(true);

    MinLotSize = MarketInfo(Symbol(), MODE_MINLOT);

    if (MinLotSize > Lot_) {
        Print("Lot is less than minimum lot size permitted for this account");
        AllowTrading = false;
    }

    LotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
    double MinLot = MathMin(MinLotSize, LotStep);
    LotMult = (int) ND(MathMax(Lot_, MinLotSize) / MinLot, 0);
    MinMult = LotMult;
    Lot_ = MinLot;

    if (MinLot < 0.01)
        LotDecimal = 3;
    else if (MinLot < 0.1)
        LotDecimal = 2;
    else if (MinLot < 1)
        LotDecimal = 1;
    else
        LotDecimal = 0;

    FileHandle = FileOpen(FileName, FILE_BIN | FILE_READ);

    if (FileHandle != -1) {
        TbF = FileReadInteger(FileHandle, LONG_VALUE);
        FileClose(FileHandle);
        Error = GetLastError();

        if (OrderSelect(TbF, SELECT_BY_TICKET)) {
            OTbF = OrderOpenTime();
            LbF = OrderLots();
            LotMult = (int) MathMax(1, LbF / MinLot);
            PbC = FindClosedPL(B);
            PhC = FindClosedPL(H);
            TradesOpen = true;

            if (Debug_)
                Print(FileName, " File Read: ", TbF, " Lots: ", DTS(LbF, LotDecimal));
        } else {
            FileDelete(FileName);
            TbF = 0;
            OTbF = 0;
            LbF = 0;
            Error = GetLastError();

            if (Error == ERR_NO_ERROR) {
                if (Debug_)
                    Print(FileName, " File Deleted");
            } else
                Print("Error ", Error, " (", ErrorDescription(Error), ") deleting file ", FileName);
        }
    }

    GlobalVariableSet(ID + "LotMult", LotMult);

    if (Debug_)
        Print("MinLotSize: ", DTS(MinLotSize, 2), " LotStep: ", DTS(LotStep, 2), " MinLot: ", DTS(MinLot, 2), " StartLot: ", DTS(Lot_, 2), " LotMult: ", DTS(LotMult, 0), " Lot Decimal: ", DTS(LotDecimal, 0));

    EmergencyWarning = EmergencyCloseAll_;

    if (IsOptimization())
        Debug_ = false;

    if (UseAnyEntry)
        UAE = "||";
    else
        UAE = "&&";

    if (ForceMarketCond_ < 0 || ForceMarketCond_ > 3)
        ForceMarketCond_ = 3;

    if (MAEntry_ < 0 || MAEntry_ > 2)
        MAEntry_ = 0;

    if (CCIEntry_ < 0 || CCIEntry_ > 2)
        CCIEntry_ = 0;

    if (BollingerEntry_ < 0 || BollingerEntry_ > 2)
        BollingerEntry_ = 0;

    if (StochEntry_ < 0 || StochEntry_ > 2)
        StochEntry_ = 0;

    if (MACDEntry_ < 0 || MACDEntry_ > 2)
        MACDEntry_ = 0;

    if (MaxCloseTrades_ == 0)
        MaxCloseTrades_ = MaxTrades;

    ArrayResize(Digit, 6);

    for (int Index = 0; Index < ArrayRange(Digit, 0); Index++) {
        if (Index > 0)
            Digit[Index, 0] = (int) MathPow(10, Index);

        Digit[Index, 1] = Index;

        if (Debug_)
            Print("Digit: ", Index, " [", Digit[Index, 0], ", ", Digit[Index, 1], "]");
    }

    LabelCreate();
    dLabels = false;

    //+-----------------------------------------------------------------+
    //| Set Lot Array                                                   |
    //+-----------------------------------------------------------------+
    ArrayResize(Lots, MaxTrades);

    for (int Index = 0; Index < MaxTrades; Index++) {
        if (Index == 0 || Multiplier_ < 1)
            Lots[Index] = Lot_;
        else
            Lots[Index] = ND(MathMax(Lots[Index - 1] * Multiplier_, Lots[Index - 1] + LotStep), LotDecimal);

        if (Debug_)
            Print("Lot Size for level ", DTS(Index + 1, 0), " : ", DTS(Lots[Index] * MathMax(LotMult, 1), LotDecimal));
    }

    if (Multiplier_ < 1)
        Multiplier_ = 1;

    //+-----------------------------------------------------------------+
    //| Set Grid and TP array                                           |
    //+-----------------------------------------------------------------+
    int GridSet = 0, GridTemp, GridTP, GridIndex = 0, GridLevel = 0, GridError = 0;

    if (!AutoCal) {
        ArrayResize(GridArray, MaxTrades);

        if (IsOptimization() && UseGridOpt) {
            if (SetArray1 > 0) {
                SetCountArray_ = DTS(SetArray1, 0);
                GridSetArray_ = DTS(GridArray1, 0);
                TP_SetArray_ = DTS(TPArray1, 0);
            }

            if (SetArray2 > 0 || (SetArray1 > 0 && GridArray2 > 0)) {
                if (SetArray2 > 0)
                    SetCountArray_ = SetCountArray_ + "," + DTS(SetArray2, 0);

                GridSetArray_ = GridSetArray_ + "," + DTS(GridArray2, 0);
                TP_SetArray_ = TP_SetArray_ + "," + DTS(TPArray2, 0);
            }

            if (SetArray3 > 0 || (SetArray2 > 0 && GridArray3 > 0)) {
                if (SetArray3 > 0)
                    SetCountArray_ = SetCountArray_ + "," + DTS(SetArray3, 0);

                GridSetArray_ = GridSetArray_ + "," + DTS(GridArray3, 0);
                TP_SetArray_ = TP_SetArray_ + "," + DTS(TPArray3, 0);
            }

            if (SetArray4 > 0 || (SetArray3 > 0 && GridArray4 > 0)) {
                if (SetArray4 > 0)
                    SetCountArray_ = SetCountArray_ + "," + DTS(SetArray4, 0);

                GridSetArray_ = GridSetArray_ + "," + DTS(GridArray4, 0);
                TP_SetArray_ = TP_SetArray_ + "," + DTS(TPArray4, 0);
            }

            if (SetArray4 > 0 && GridArray5 > 0) {
                GridSetArray_ = GridSetArray_ + "," + DTS(GridArray5, 0);
                TP_SetArray_ = TP_SetArray_ + "," + DTS(TPArray5, 0);
            }
        }

        while (GridIndex < MaxTrades) {
            if (StringFind(SetCountArray_, ",") == -1 && GridIndex == 0) {
                GridError = 1;
                break;
            } else
                GridSet = StrToInteger(StringSubstr(SetCountArray_, 0, StringFind(SetCountArray_, ",")));

            if (GridSet > 0) {
                SetCountArray_ = StringSubstr(SetCountArray_, StringFind(SetCountArray_, ",") + 1);
                GridTemp = StrToInteger(StringSubstr(GridSetArray_, 0, StringFind(GridSetArray_, ",")));
                GridSetArray_ = StringSubstr(GridSetArray_, StringFind(GridSetArray_, ",") + 1);
                GridTP = StrToInteger(StringSubstr(TP_SetArray_, 0, StringFind(TP_SetArray_, ",")));
                TP_SetArray_ = StringSubstr(TP_SetArray_, StringFind(TP_SetArray_, ",") + 1);
            } else
                GridSet = MaxTrades;

            if (GridTemp == 0 || GridTP == 0) {
                GridError = 2;
                break;
            }

            for (GridLevel = GridIndex; GridLevel <= MathMin(GridIndex + GridSet - 1, MaxTrades - 1); GridLevel++) {
                GridArray[GridLevel, 0] = GridTemp;
                GridArray[GridLevel, 1] = GridTP;

                if (Debug_)
                    Print("GridArray ", (GridLevel + 1), ": [", GridArray[GridLevel, 0], ", ", GridArray[GridLevel, 1], "]");
            }

            GridIndex = GridLevel;
        }

        if (GridError > 0 || GridArray[0, 0] == 0 || GridArray[0, 1] == 0) {
            if (GridError == 1)
                Print("Grid Array Error. Each value should be separated by a comma.");
            else
                Print("Grid Array Error. Check that there is one more 'Grid' and 'TP' entry than there are 'Set' numbers - separated by commas.");

            AllowTrading = false;
        }
    } else {
        while (GridIndex < 4) {
            GridSet = StrToInteger(StringSubstr(SetCountArray_, 0, StringFind(SetCountArray_, ",")));
            SetCountArray_ = StringSubstr(SetCountArray_, StringFind(SetCountArray_, DTS(GridSet, 0)) + 2);

            if (GridIndex == 0 && GridSet < 1) {
                GridError = 1;
                break;
            }

            if (GridSet > 0)
                GridLevel += GridSet;
            else if (GridLevel < MaxTrades)
                GridLevel = MaxTrades;
            else
                GridLevel = MaxTrades + 1;

            if (GridIndex == 0)
                Set1Level = GridLevel;
            else if (GridIndex == 1 && GridLevel <= MaxTrades)
                Set2Level = GridLevel;
            else if (GridIndex == 2 && GridLevel <= MaxTrades)
                Set3Level = GridLevel;
            else if (GridIndex == 3 && GridLevel <= MaxTrades)
                Set4Level = GridLevel;

            GridIndex++;
        }

        if (GridError == 1 || Set1Level == 0) {
            Print("Error setting up Grid Levels. Check that the SetCountArray contains valid numbers separated by commas.");
            AllowTrading = false;
        }
    }

    //+-----------------------------------------------------------------+
    //| Set holidays array                                              |
    //+-----------------------------------------------------------------+
    if (UseHolidayShutdown) {
        int HolTemp = 0, NumHols, NumBS = 0, HolCounter = 0;
        string HolTempStr;

		// holidays are separated by commas
		// 18/12-01/01
        if (StringFind(Holidays, ",", 0) == -1) { // no comma if just one holiday
            NumHols = 1;
        } else {
            NumHols = 1;
            while (HolTemp != -1) {
                HolTemp = StringFind(Holidays, ",", HolTemp + 1);
                if (HolTemp != -1) NumHols++;
            }
        }
        HolTemp = 0;
        while (HolTemp != -1) {
            HolTemp = StringFind(Holidays, "/", HolTemp + 1);
            if (HolTemp != -1) NumBS++;
        }

        if (NumBS != NumHols * 2) {
            Print("Holidays Error, number of back-slashes (", NumBS, ") should be equal to 2* number of Holidays (",
				NumHols, ", and separators should be commas.");
            AllowTrading = false;
        } else {
            HolTemp = 0;
            ArrayResize(HolArray, NumHols);
            while (HolTemp != -1) {
                if (HolTemp == 0)
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

        for (HolTemp = 0; HolTemp < HolCounter; HolTemp++) {
            datetime Start1, Start2;
			int Temp0, Temp1, Temp2, Temp3;
            for (int Item1 = HolTemp + 1; Item1 < HolCounter; Item1++) {
                Start1 = (datetime) HolArray[HolTemp, 0] * 100 + HolArray[HolTemp, 1];
                Start2 = (datetime) HolArray[Item1, 0] * 100 + HolArray[Item1, 1];
                if (Start1 > Start2) {
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

        if (Debug_) {
            for (HolTemp = 0; HolTemp < HolCounter; HolTemp++)
                Print("Holidays - From: ", HolArray[HolTemp, 1], "/", HolArray[HolTemp, 0], " - ",
					HolArray[HolTemp, 3], "/", HolArray[HolTemp, 2]);
        }
    }
    //+-----------------------------------------------------------------+
    //| Set email parameters                                            |
    //+-----------------------------------------------------------------+
    if (UseEmail) {
        if (Period() == 43200)
            sTF = "MN1";
        else if (Period() == 10800)
            sTF = "W1";
        else if (Period() == 1440)
            sTF = "D1";
        else if (Period() == 240)
            sTF = "H4";
        else if (Period() == 60)
            sTF = "H1";
        else if (Period() == 30)
            sTF = "M30";
        else if (Period() == 15)
            sTF = "M15";
        else if (Period() == 5)
            sTF = "M5";
        else if (Period() == 1)
            sTF = "M1";

        Email[0] = MathMax(MathMin(EmailDD1, MaxDDPercent - 1), 0) / 100;
        Email[1] = MathMax(MathMin(EmailDD2, MaxDDPercent - 1), 0) / 100;
        Email[2] = MathMax(MathMin(EmailDD3, MaxDDPercent - 1), 0) / 100;
        ArraySort(Email, WHOLE_ARRAY, 0, MODE_ASCEND);

        for (int z = 0; z <= 2; z++) {
            for (int Index = 0; Index <= 2; Index++) {
                if (Email[Index] == 0) {
                    Email[Index] = Email[Index + 1];
                    Email[Index + 1] = 0;
                }
            }

            if (Debug_)
                Print("Email [", (z + 1), "] : ", Email[z]);
        }
    }
    //+-----------------------------------------------------------------+
    //| Set SmartGrid parameters                                        |
    //+-----------------------------------------------------------------+
    if (UseSmartGrid) {
        ArrayResize(RSI, RSI_Period + RSI_MA_Period);
        ArraySetAsSeries(RSI, true);
    }
    //+---------------------------------------------------------------+
    //| Initialize Statistics                                         |
    //+---------------------------------------------------------------+
    if (SaveStats) {
        StatFile = "B3" + Symbol() + "_" + (string) Period() + "_" + (string) EANumber_ + ".csv";
        NextStats = TimeCurrent();
		// new PortionPC behavior ... r.f.
		double temp_account_balance = AccountBalance();
		if (PortionPC > 100 && temp_account_balance > PortionPC) {
			Stats(StatsInitialise, false, PortionPC, 0);
		} else {
			Stats(StatsInitialise, false, temp_account_balance * PortionPC_, 0);
		}
    }

    return (0);
}

//+-----------------------------------------------------------------+
//| expert deinitialization function                                |
//+-----------------------------------------------------------------+
int deinit() {
    switch (UninitializeReason()) {
    case REASON_REMOVE:
    case REASON_CHARTCLOSE:
    case REASON_CHARTCHANGE:
        if (CpT > 0) {
            while (CpT > 0)
                CpT -= ExitTrades(P, displayColorLoss, "Blessing Removed");
        }

        GlobalVariablesDeleteAll(ID);
    case REASON_RECOMPILE:
    case REASON_PARAMETERS:
    case REASON_ACCOUNT:
        if (!Testing)
            LabelDelete();

        Comment("");
    }

    return (0);
}


datetime OncePerBarTime = 0;

//+-----------------------------------------------------------------+
//| Once Per Bar function    returns true once per bar              |
//+-----------------------------------------------------------------+
bool OncePerBar() {
    if (!EnableOncePerBar || FirstRun)
        return (true);          // always return true if disabled

    if (OncePerBarTime != Time[0]) {
        OncePerBarTime = Time[0];
        return (true);          // true, our first time this bar
    }

    return (false);
}

double LbT = 0;                 // total lots out

double previous_stop_trade_amount;
double stop_trade_amount;


//+-----------------------------------------------------------------+
//| expert start function                                           |
//+-----------------------------------------------------------------+
int start() {
    int CbB = 0;                // Count buy
    int CbS = 0;                // Count sell
    int CpBL = 0;               // Count buy limit
    int CpSL = 0;               // Count sell limit
    int CpBS = 0;               // Count buy stop
    int CpSS = 0;               // Count sell stop
    double LbB = 0;             // Count buy lots
    double LbS = 0;             // Count sell lots
// double   LbT          =0;     // total lots out
    double OPpBL = 0;           // Buy limit open price
    double OPpSL = 0;           // Sell limit open price
    double SLbB = 0;            // stop losses are set to zero if POSL off
    double SLbS = 0;            // stop losses are set to zero if POSL off
    double BCb = 0, BCh = 0, BCa;       // Broker costs (swap + commission)
    double ProfitPot = 0;       // The Potential Profit of a basket of Trades
    double PipValue, PipVal2, ASK, BID;
    double OrderLot;
    double OPbL = 0, OPhO = 0;  // last open price
    datetime OTbL = 0;          // last open time
    datetime OTbO = 0, OThO = 0;
    double g2, tp2, Entry, RSI_MA = 0, LhB = 0, LhS = 0, LhT, OPbO = 0;
    int Ticket = 0, ChB = 0, ChS = 0, IndEntry = 0, TbO = 0, ThO = 0;
    double Pb = 0, Ph = 0, PaC = 0, PbPips = 0, PbTarget = 0, DrawDownPC = 0, BEb = 0, BEh = 0, BEa = 0;
    bool BuyMe = false, SellMe = false, Success, SetPOSL;
    string IndicatorUsed;
    double EEpc = 0, OPbN = 0, nLots = 0;
    double bSL = 0, TPa = 0, TPbMP = 0;
    int Trend = 0;
    string ATrend;
    double cci_01 = 0, cci_02 = 0, cci_03 = 0, cci_04 = 0;
    double cci_11 = 0, cci_12 = 0, cci_13 = 0, cci_14 = 0;


    //+-----------------------------------------------------------------+
    //| Count Open Orders, Lots and Totals                              |
    //+-----------------------------------------------------------------+
    PipVal2 = MarketInfo(Symbol(), MODE_TICKVALUE) / MarketInfo(Symbol(), MODE_TICKSIZE);
    PipValue = PipVal2 * Pip;
    StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
    ASK = ND(MarketInfo(Symbol(), MODE_ASK), (int) MarketInfo(Symbol(), MODE_DIGITS));
    BID = ND(MarketInfo(Symbol(), MODE_BID), (int) MarketInfo(Symbol(), MODE_DIGITS));

    if (ASK == 0 || BID == 0)
        return (0);

    for (int Order = 0; Order < OrdersTotal(); Order++) {
        if (!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
            continue;

        int Type = OrderType();

        if (OrderMagicNumber() == hMagic) {
            Ph += OrderProfit();
            BCh += OrderSwap() + OrderCommission();
            BEh += OrderLots() * OrderOpenPrice();

            if (OrderOpenTime() < OThO || OThO == 0) {
                OThO = OrderOpenTime();
                ThO = OrderTicket();
                OPhO = OrderOpenPrice();
            }

            if (Type == OP_BUY) {
                ChB++;
                LhB += OrderLots();
            } else if (Type == OP_SELL) {
                ChS++;
                LhS += OrderLots();
            }

            continue;
        }

        if (OrderMagicNumber() != Magic || OrderSymbol() != Symbol())
            continue;

        if (OrderTakeProfit() > 0)
            ModifyOrder(OrderOpenPrice(), OrderStopLoss());

        if (Type <= OP_SELL) {
            Pb += OrderProfit();
            BCb += OrderSwap() + OrderCommission();
            BEb += OrderLots() * OrderOpenPrice();

            if (OrderOpenTime() >= OTbL) {
                OTbL = OrderOpenTime();
                OPbL = OrderOpenPrice();
            }

            if (OrderOpenTime() < OTbF || TbF == 0) {
                OTbF = OrderOpenTime();
                TbF = OrderTicket();
                LbF = OrderLots();
            }

            if (OrderOpenTime() < OTbO || OTbO == 0) {
                OTbO = OrderOpenTime();
                TbO = OrderTicket();
                OPbO = OrderOpenPrice();
            }

            if (UsePowerOutSL && ((POSLPips_ > 0 && OrderStopLoss() == 0) || (POSLPips_ == 0 && OrderStopLoss() > 0)))
                SetPOSL = true;

            if (Type == OP_BUY) {
                CbB++;
                LbB += OrderLots();
                continue;
            } else {
                CbS++;
                LbS += OrderLots();
                continue;
            }
        } else {
            if (Type == OP_BUYLIMIT) {
                CpBL++;
                OPpBL = OrderOpenPrice();
                continue;
            } else if (Type == OP_SELLLIMIT) {
                CpSL++;
                OPpSL = OrderOpenPrice();
                continue;
            } else if (Type == OP_BUYSTOP)
                CpBS++;
            else
                CpSS++;
        }
    }

    CbT = CbB + CbS;
    LbT = LbB + LbS;
    Pb = ND(Pb + BCb, 2);
    ChT = ChB + ChS;
    LhT = LhB + LhS;
    Ph = ND(Ph + BCh, 2);
    CpT = CpBL + CpSL + CpBS + CpSS;
    BCa = BCb + BCh;

    //+-----------------------------------------------------------------+
    //| Calculate Min/Max Profit and Break Even Points                  |
    //+-----------------------------------------------------------------+
    if (LbT > 0) {
        BEb = ND(BEb / LbT, Digits);

        if (BCa < 0) {	// broker costs
			if (LbB - LbS != 0) // r.f., fix divide by zero on following line
				BEb -= ND(BCa / PipVal2 / (LbB - LbS), Digits);
		}

        if (Pb > PbMax || PbMax == 0)
            PbMax = Pb;

        if (Pb < PbMin || PbMin == 0)
            PbMin = Pb;

        if (!TradesOpen) {
            FileHandle = FileOpen(FileName, FILE_BIN | FILE_WRITE);

            if (FileHandle > -1) {
                FileWriteInteger(FileHandle, TbF);
                FileClose(FileHandle);
                TradesOpen = true;

                if (Debug_)
                    Print(FileName, " File Written: ", TbF);
            }
        }
    } else if (TradesOpen) {
        TPb = 0;
        PbMax = 0;
        PbMin = 0;
        OTbF = 0;
        TbF = 0;
        LbF = 0;
        PbC = 0;
        PhC = 0;
        PaC = 0;
        ClosedPips = 0;
        CbC = 0;
        CaL = 0;
        bTS = 0;

        if (HedgeTypeDD)
            hDDStart = HedgeStart_;
        else
            hLvlStart = HedgeStart_;

        EmailCount = 0;
        EmailSent = 0;
        FileHandle = FileOpen(FileName, FILE_BIN | FILE_READ);

        if (FileHandle > -1) {
            FileClose(FileHandle);
            Error = GetLastError();
            FileDelete(FileName);
            Error = GetLastError();

            if (Error == ERR_NO_ERROR) {
                if (Debug_)
                    Print(FileName + " File Deleted");

                TradesOpen = false;
            } else
                Print("Error ", Error, " {", ErrorDescription(Error), ") deleting file ", FileName);
        } else
            TradesOpen = false;
    }

    if (LhT > 0) {
        BEh = ND(BEh / LhT, Digits);

        if (Ph > PhMax || PhMax == 0)
            PhMax = Ph;

        if (Ph < PhMin || PhMin == 0)
            PhMin = Ph;
    } else {
        PhMax = 0;
        PhMin = 0;
        SLh = 0;
    }

    //+-----------------------------------------------------------------+
    //| Check if trading is allowed                                     |
    //+-----------------------------------------------------------------+
    if (CbT == 0 && ChT == 0 && ShutDown_) {
        if (CpT > 0) {
            ExitTrades(P, displayColorLoss, "Blessing is shutting down");

            return (0);
        }

        if (AllowTrading) {
            Print("Blessing has shut down. Set ShutDown = 'false' to resume trading");

            if (PlaySounds)
                PlaySound(AlertSound);

            AllowTrading = false;
        }

        if (UseEmail && EmailCount < 4 && !Testing) {
            SendMail("Blessing EA", "Blessing has shut down on " + Symbol() + " " + sTF + ". To resume trading, change ShutDown to false.");
            Error = GetLastError();

            if (Error > 0)
                Print("Error ", Error, " (", ErrorDescription(Error), ") sending email");
            else
                EmailCount = 4;
        }
    }

    static bool LDelete;

    if (!AllowTrading) {
        if (!LDelete) {
            LDelete = true;
            LabelDelete();

            if (ObjectFind("B3LStop") == -1) {
                CreateLabel("B3LStop", "Trading has stopped on this pair.", 10, 0, 0, 3, displayColorLoss);
                CreateLabel("B3LLogo", "I", 27, 3, 10, 10, Red, "Wingdings");   // I = open hand (stop)
            }

            string Tab = "Tester Journal";

            if (!Testing)
                Tab = "Terminal Experts";

            if (ObjectFind("B3LExpt") == -1)
                CreateLabel("B3LExpt", "Check the " + Tab + " tab for the reason.", 10, 0, 0, 6, displayColorLoss);

            if (ObjectFind("B3LResm") == -1)
                CreateLabel("B3LResm", "Reset Blessing to resume trading.", 10, 0, 0, 9, displayColorLoss);
        }

        return (0);
    } else {
        LDelete = false;
        ObjDel("B3LStop");
        ObjDel("B3LExpt");
        ObjDel("B3LResm");
    }

    //+-----------------------------------------------------------------+
    //| Calculate Drawdown and Equity Protection                        |
    //+-----------------------------------------------------------------+
	double temp_account_balance = AccountBalance();
	double NewPortionBalance;
	if (PortionPC > 100 && temp_account_balance > PortionPC) {
		NewPortionBalance = ND(PortionPC, 2);
	} else {
		NewPortionBalance = ND(temp_account_balance * PortionPC_, 2);
	}

    if (CbT == 0 || PortionChange < 0 || (PortionChange > 0 && NewPortionBalance > PortionBalance))
        PortionBalance = NewPortionBalance;

	if (Pb + Ph < 0)	// *******************************
		DrawDownPC = -(Pb + Ph) / PortionBalance;   // opb
	if (!FirstRun && DrawDownPC >= MaxDDPercent / 100) {
		ExitTrades(A, displayColorLoss, "Equity StopLoss Reached");

		if (PlaySounds)
			PlaySound(AlertSound);

		return (0);
	}				// ***********************************
	if (-(Pb + Ph) > MaxDD)
		MaxDD = -(Pb + Ph);

	MaxDDPer = MathMax(MaxDDPer, DrawDownPC * 100);
	// ***********************************************************
	// ***********************************************************

	if (SaveStats)
		Stats(false, TimeCurrent() < NextStats, PortionBalance, Pb + Ph);

	//+-----------------------------------------------------------------+
	//| Calculate  Stop Trade Percent                                   |
	//+-----------------------------------------------------------------+
	double StepAB = InitialAB * (1 + StopTradePercent_);
	double StepSTB;
	double temp_ab = AccountBalance();
	if (PortionPC > 100 && temp_ab > PortionPC) {
		StepSTB = PortionPC * (1 - StopTradePercent_);
	} else {
		StepSTB = temp_ab * (1 - StopTradePercent_);
	}
	double NextISTB = StepAB * (1 - StopTradePercent_);

	if (StepSTB > NextISTB) {
		InitialAB = StepAB;
		StopTradeBalance = StepSTB;
	}
	// Stop Trade Amount:
	double InitialAccountMultiPortion = StopTradeBalance * PortionPC_;
	stop_trade_amount = InitialAccountMultiPortion;

	if (PortionBalance < InitialAccountMultiPortion) {
		if (CbT == 0) {
			AllowTrading = false;

			if (PlaySounds)
				PlaySound(AlertSound);

			Print("Portion Balance dropped below stop-trading percentage");
			MessageBox("Reset required - account balance dropped below stop-trading percentage on " + DTS(AccountNumber(), 0) + " " + Symbol() + " " + (string) Period(), "Blessing 3: Warning", 48);

			return (0);
		} else if (!ShutDown_ && !RecoupClosedLoss) {
			ShutDown_ = true;

			if (PlaySounds)
				PlaySound(AlertSound);

			Print("Portion Balance dropped below stop-trading percentage");

			return (0);
		}
	}

	// **********************************************************************
	// **********************************************************************

	//+-----------------------------------------------------------------+
	//| Calculation of Trend Direction                                  |
	//+-----------------------------------------------------------------+
	// double ima_0 = iMA(Symbol(), 0, MAPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);
	double ima_0 = iMA(Symbol(), MA_TF, MAPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);

	if (ForceMarketCond_ == 3) {
		if (BID > ima_0 + MADistance_)
			Trend = 0;
		else if (ASK < ima_0 - MADistance_)
			Trend = 1;
		else
			Trend = 2;
	} else {
		Trend = ForceMarketCond_;

		if (Trend != 0 && BID > ima_0 + MADistance_)
			ATrend = "U";

		if (Trend != 1 && ASK < ima_0 - MADistance_)
			ATrend = "D";

		if (Trend != 2 && (BID < ima_0 + MADistance_ && ASK > ima_0 - MADistance_))
			ATrend = "R";
	}

    if (OncePerBar()) {	// **************************************************

        //+-----------------------------------------------------------------+
        //| Hedge/Basket/ClosedTrades Profit Management                     |
        //+-----------------------------------------------------------------+
        double Pa = Pb;
        PaC = PbC + PhC;

        if (hActive == 1 && ChT == 0) {
            PhC = FindClosedPL(H);
            hActive = 0;

            return (0);
        } else if (hActive == 0 && ChT > 0)
            hActive = 1;

        if (LbT > 0) {
            if (PbC > 0 || (PbC < 0 && RecoupClosedLoss)) {
                Pa += PbC;
                BEb -= ND(PbC / PipVal2 / (LbB - LbS), Digits);
            }

            if (PhC > 0 || (PhC < 0 && RecoupClosedLoss)) {
                Pa += PhC;
                BEb -= ND(PhC / PipVal2 / (LbB - LbS), Digits);
            }

            if (Ph > 0 || (Ph < 0 && RecoupClosedLoss))
                Pa += Ph;
        }
        //+-----------------------------------------------------------------+
        //| Close oldest open trade after CloseTradesLevel reached          |
        //+-----------------------------------------------------------------+
        if (UseCloseOldest && CbT >= CloseTradesLevel && CbC < MaxCloseTrades_) {
            if (!FirstRun && TPb > 0 && (ForceCloseOldest || (CbB > 0 && OPbO > TPb) || (CbS > 0 && OPbO < TPb))) {
                int Index = ExitTrades(T, DarkViolet, "Close Oldest Trade", TbO);

                if (Index == 1) {
                    if (OrderSelect(TbO, SELECT_BY_TICKET)) {   // yoh check return
                        PbC += OrderProfit() + OrderSwap() + OrderCommission();
                        ca = 0;
                        CbC++;
                    } else
                        Print("OrderSelect error ", GetLastError());    // yoh

                    return (0);
                }
            }
        }
        //+-----------------------------------------------------------------+
        //| ATR for Auto Grid Calculation and Grid Set Block                |
        //+-----------------------------------------------------------------+
        double GridTP;

        if (AutoCal) {
            double GridATR = iATR(NULL, TF[ATRTF], ATRPeriods, 0) / Pip;

            if ((CbT + CbC > Set4Level) && Set4Level > 0) {
                g2 = GridATR * 12;      //GS*2*2*2*1.5
                tp2 = GridATR * 18;     //GS*2*2*2*1.5*1.5
            } else if ((CbT + CbC > Set3Level) && Set3Level > 0) {
                g2 = GridATR * 8;       //GS*2*2*2
                tp2 = GridATR * 12;     //GS*2*2*2*1.5
            } else if ((CbT + CbC > Set2Level) && Set2Level > 0) {
                g2 = GridATR * 4;       //GS*2*2
                tp2 = GridATR * 8;      //GS*2*2*2
            } else if ((CbT + CbC > Set1Level) && Set1Level > 0) {
                g2 = GridATR * 2;       //GS*2
                tp2 = GridATR * 4;      //GS*2*2
            } else {
                g2 = GridATR;
                tp2 = GridATR * 2;
            }

            GridTP = GridATR * 2;
        } else {
            int Index = (int) MathMax(MathMin(CbT + CbC, MaxTrades) - 1, 0);
            g2 = GridArray[Index, 0];
            tp2 = GridArray[Index, 1];
            GridTP = GridArray[0, 1];
        }

        g2 = ND(MathMax(g2 * GAF * Pip, Pip), Digits);
        tp2 = ND(tp2 * GAF * Pip, Digits);
        GridTP = ND(GridTP * GAF * Pip, Digits);

        //+-----------------------------------------------------------------+
        //| Money Management and Lot size coding                            |
        //+-----------------------------------------------------------------+
        if (UseMM) {
            if (CbT > 0)        // Count basket Total
            {
                if (GlobalVariableCheck(ID + "LotMult"))
                    LotMult = (int) GlobalVariableGet(ID + "LotMult");

                if (LbF != LotSize(Lots[0] * LotMult)) {
                    LotMult = (int) (LbF / Lots[0]);
                    GlobalVariableSet(ID + "LotMult", LotMult);
                    Print("LotMult reset to " + DTS(LotMult, 0));
                }
            } else if (CbT == 0) {
                double Contracts, Factor, Lotsize;
                Contracts = PortionBalance / 10000;     // MarketInfo(Symbol(), MODE_LOTSIZE); ??

                if (Multiplier_ <= 1)
                    Factor = Level;
                else
                    Factor = (MathPow(Multiplier_, Level) - Multiplier_) / (Multiplier_ - 1);

                Lotsize = LAF * AccountType * Contracts / (1 + Factor);
                LotMult = (int) MathMax(MathFloor(Lotsize / Lot_), MinMult);
                GlobalVariableSet(ID + "LotMult", LotMult);
            }
        } else if (CbT == 0)
            LotMult = MinMult;

        //+-----------------------------------------------------------------+
        //| Calculate Take Profit                                           |
        //+-----------------------------------------------------------------+
        static double BCaL, BEbL;
        nLots = LbB - LbS;

        if (CbT > 0 && (TPb == 0 || CbT + ChT != CaL || BEbL != BEb || BCa != BCaL || FirstRun)) {
            string sCalcTP = "Set New TP:  BE: " + DTS(BEb, Digits);
            double NewTP = 0, BasePips;
            CaL = CbT + ChT;
            BCaL = BCa;
            BEbL = BEb;
            if (nLots == 0) {
                nLots = 1;
            }                   // divide by zero error fix ... r.f.
            BasePips = ND(Lot_ * LotMult * GridTP * (CbT + CbC) / nLots, Digits);

            if (CbB > 0) {
                if (ForceTPPips_ > 0) {
                    NewTP = BEb + ForceTPPips_;
                    sCalcTP = sCalcTP + " +Force TP (" + DTS(ForceTPPips_, Digits) + ") ";
                } else if (CbC > 0 && CloseTPPips_ > 0) {
                    NewTP = BEb + CloseTPPips_;
                    sCalcTP = sCalcTP + " +Close TP (" + DTS(CloseTPPips_, Digits) + ") ";
                } else if (BEb + BasePips > OPbL + tp2) {
                    NewTP = BEb + BasePips;
                    sCalcTP = sCalcTP + " +Base TP: (" + DTS(BasePips, Digits) + ") ";
                } else {
                    NewTP = OPbL + tp2;
                    sCalcTP = sCalcTP + " +Grid TP: (" + DTS(tp2, Digits) + ") ";
                }

                if (MinTPPips_ > 0) {
                    NewTP = MathMax(NewTP, BEb + MinTPPips_);
                    sCalcTP = sCalcTP + " >Minimum TP: ";
                }

                NewTP += MoveTP_ * Moves;

                if (BreakEvenTrade > 0 && CbT + CbC >= BreakEvenTrade) {
                    NewTP = BEb + BEPlusPips_;
                    sCalcTP = sCalcTP + " >BreakEven: (" + DTS(BEPlusPips_, Digits) + ") ";
                }

                sCalcTP = (sCalcTP + "Buy: TakeProfit: ");
            } else if (CbS > 0) {
                if (ForceTPPips_ > 0) {
                    NewTP = BEb - ForceTPPips_;
                    sCalcTP = sCalcTP + " -Force TP (" + DTS(ForceTPPips_, Digits) + ") ";
                } else if (CbC > 0 && CloseTPPips_ > 0) {
                    NewTP = BEb - CloseTPPips_;
                    sCalcTP = sCalcTP + " -Close TP (" + DTS(CloseTPPips_, Digits) + ") ";
                } else if (BEb + BasePips < OPbL - tp2) {
                    NewTP = BEb + BasePips;
                    sCalcTP = sCalcTP + " -Base TP: (" + DTS(BasePips, Digits) + ") ";
                } else {
                    NewTP = OPbL - tp2;
                    sCalcTP = sCalcTP + " -Grid TP: (" + DTS(tp2, Digits) + ") ";
                }

                if (MinTPPips_ > 0) {
                    NewTP = MathMin(NewTP, BEb - MinTPPips_);
                    sCalcTP = sCalcTP + " >Minimum TP: ";
                }

                NewTP -= MoveTP_ * Moves;

                if (BreakEvenTrade > 0 && CbT + CbC >= BreakEvenTrade) {
                    NewTP = BEb - BEPlusPips_;
                    sCalcTP = sCalcTP + " >BreakEven: (" + DTS(BEPlusPips_, Digits) + ") ";
                }

                sCalcTP = (sCalcTP + "Sell: TakeProfit: ");
            }

            if (TPb != NewTP) {
                TPb = NewTP;

                if (nLots > 0)
                    TargetPips = ND(TPb - BEb, Digits);
                else
                    TargetPips = ND(BEb - TPb, Digits);

                Print(sCalcTP + DTS(NewTP, Digits));

                return (0);
            }
        }

        PbTarget = TargetPips / Pip;
        ProfitPot = ND(TargetPips * PipVal2 * MathAbs(nLots), 2);

        if (CbB > 0)
            PbPips = ND((BID - BEb) / Pip, 1);

        if (CbS > 0)
            PbPips = ND((BEb - ASK) / Pip, 1);

        //+-----------------------------------------------------------------+
        //| Adjust BEb/TakeProfit if Hedge is active                        |
        //+-----------------------------------------------------------------+
        double hAsk = MarketInfo(HedgeSymbol_, MODE_ASK);
        double hBid = MarketInfo(HedgeSymbol_, MODE_BID);
        double hSpread = hAsk - hBid;

        if (hThisChart)
            nLots += LhB - LhS;

        double PhPips;

        if (hActive == 1) {
            if (nLots == 0) {
                BEa = 0;
                TPa = 0;
            } else if (hThisChart) {
                if (nLots > 0) {
                    if (CbB > 0)
                        BEa = ND((BEb * LbT - (BEh - hSpread) * LhT) / (LbT - LhT), Digits);
                    else
                        BEa = ND(((BEb - (ASK - BID)) * LbT - BEh * LhT) / (LbT - LhT), Digits);

                    TPa = ND(BEa + TargetPips, Digits);
                } else {
                    if (CbS > 0)
                        BEa = ND((BEb * LbT - (BEh + hSpread) * LhT) / (LbT - LhT), Digits);
                    else
                        BEa = ND(((BEb + ASK - BID) * LbT - BEh * LhT) / (LbT - LhT), Digits);

                    TPa = ND(BEa - TargetPips, Digits);
                }
            }

            if (ChB > 0)
                PhPips = ND((hBid - BEh) / hPip, 1);

            if (ChS > 0)
                PhPips = ND((BEh - hAsk) / hPip, 1);
        } else {
            BEa = BEb;
            TPa = TPb;
        }

        //+-----------------------------------------------------------------+
        //| Calculate Early Exit Percentage                                 |
        //+-----------------------------------------------------------------+
        double EEStartTime = 0, TPaF;

        if (UseEarlyExit && CbT > 0) {
            datetime EEopt;

            if (EEFirstTrade)
                EEopt = OTbF;
            else
                EEopt = OTbL;

            if (DayOfWeek() < TimeDayOfWeek(EEopt))
                EEStartTime = 2 * 24 * 3600;

            EEStartTime += EEopt + EEStartHours * 3600;

            if (EEHoursPC_ > 0 && TimeCurrent() >= EEStartTime)
                EEpc = EEHoursPC_ * (TimeCurrent() - EEStartTime) / 3600;

            if (EELevelPC_ > 0 && (CbT + CbC) >= EEStartLevel)
                EEpc += EELevelPC_ * (CbT + CbC - EEStartLevel + 1);

            EEpc = 1 - EEpc;

            if (!EEAllowLoss && EEpc < 0)
                EEpc = 0;

            PbTarget *= EEpc;
            TPaF = ND((TPa - BEa) * EEpc + BEa, Digits);

            if (displayOverlay && displayLines && (hActive != 1 || (hActive == 1 && hThisChart)) && (!Testing || (Testing && Visual)) &&
                EEpc < 1 && (CbT + CbC + ChT > EECount || EETime != Time[0]) && ((EEHoursPC_ > 0 && EEopt + EEStartHours * 3600 < Time[0]) || (EELevelPC_ > 0 && CbT + CbC >= EEStartLevel))) {
                EETime = Time[0];
                EECount = CbT + CbC + ChT;

                if (ObjectFind("B3LEELn") < 0) {
                    ObjectCreate("B3LEELn", OBJ_TREND, 0, 0, 0);
                    ObjectSet("B3LEELn", OBJPROP_COLOR, Yellow);
                    ObjectSet("B3LEELn", OBJPROP_WIDTH, 1);
                    ObjectSet("B3LEELn", OBJPROP_STYLE, 0);
                    ObjectSet("B3LEELn", OBJPROP_RAY, false);
                    ObjectSet("B3LEELn", OBJPROP_BACK, false);
                }

                if (EEHoursPC_ > 0)
                    ObjectMove("B3LEELn", 0, (datetime) (MathFloor(EEopt / 3600 + EEStartHours) * 3600), TPa);
                else
                    ObjectMove("B3LEELn", 0, (datetime) (MathFloor(EEopt / 3600) * 3600), TPaF);

                ObjectMove("B3LEELn", 1, Time[1], TPaF);

                if (ObjectFind("B3VEELn") < 0) {
                    ObjectCreate("B3VEELn", OBJ_TEXT, 0, 0, 0);
                    ObjectSet("B3VEELn", OBJPROP_COLOR, Yellow);
                    ObjectSet("B3VEELn", OBJPROP_WIDTH, 1);
                    ObjectSet("B3VEELn", OBJPROP_STYLE, 0);
                    ObjectSet("B3VEELn", OBJPROP_BACK, false);
                }

                ObjSetTxt("B3VEELn", "              " + DTS(TPaF, Digits), -1, Yellow);
                ObjectSet("B3VEELn", OBJPROP_PRICE1, TPaF + 2 * Pip);
                ObjectSet("B3VEELn", OBJPROP_TIME1, Time[1]);
            } else if ((!displayLines || EEpc == 1 || (!EEAllowLoss && EEpc == 0) || (EEHoursPC_ > 0 && EEopt + EEStartHours * 3600 >= Time[0]))) {
                ObjDel("B3LEELn");
                ObjDel("B3VEELn");
            }
        } else {
            TPaF = TPa;
            EETime = 0;
            EECount = 0;
            ObjDel("B3LEELn");
            ObjDel("B3VEELn");
        }

        //+-----------------------------------------------------------------+
        //| Maximize Profit with Moving TP and setting Trailing Profit Stop |
        //+-----------------------------------------------------------------+
        if (MaximizeProfit) {
            if (CbT == 0) {
                SLbL = 0;
                Moves = 0;
                SLb = 0;
            }

            if (!FirstRun && CbT > 0) {
                if (Pb + Ph < 0 && SLb > 0)
                    SLb = 0;

                if (SLb > 0 && ((nLots > 0 && BID < SLb) || (nLots < 0 && ASK > SLb))) {
                    ExitTrades(A, displayColorProfit, "Profit Trailing Stop Reached (" + DTS(ProfitSet_ * 100, 2) + "%)");

                    return (0);
                }

                if (PbTarget > 0) {
                    TPbMP = ND(BEa + (TPa - BEa) * ProfitSet_, Digits);

                    if ((nLots > 0 && BID > TPbMP) || (nLots < 0 && ASK < TPbMP))
                        SLb = TPbMP;
                }

                if (SLb > 0 && SLb != SLbL && MoveTP_ > 0 && TotalMoves > Moves) {
                    TPb = 0;
                    Moves++;

                    if (Debug_)
                        Print("MoveTP");

                    SLbL = SLb;

                    if (PlaySounds)
                        PlaySound(AlertSound);

                    return (0);
                }
            }
        }

        if (!FirstRun && TPaF > 0) {
            if ((nLots > 0 && BID >= TPaF) || (nLots < 0 && ASK <= TPaF)) {
                ExitTrades(A, displayColorProfit, "Profit Target Reached @ " + DTS(TPaF, Digits));

                return (0);
            }
        }

        if (!FirstRun && UseStopLoss) {
            if (SLPips_ > 0) {
                if (nLots > 0) {
                    bSL = BEa - SLPips_;

                    if (BID <= bSL) {
                        ExitTrades(A, displayColorProfit, "Stop Loss Reached");

                        return (0);
                    }
                } else if (nLots < 0) {
                    bSL = BEa + SLPips_;

                    if (ASK >= bSL) {
                        ExitTrades(A, displayColorProfit, "Stop Loss Reached");

                        return (0);
                    }
                }
            }

            if (TSLPips_ != 0) {
                if (nLots > 0) {
                    if (TSLPips_ > 0 && BID > BEa + TSLPips_)
                        bTS = MathMax(bTS, BID - TSLPips_);

                    if (TSLPips_ < 0 && BID > BEa - TSLPips_)
                        bTS = MathMax(bTS, BID - MathMax(TSLPipsMin_, -TSLPips_ * (1 - (BID - BEa + TSLPips_) / (-TSLPips_ * 2))));

                    if (bTS > 0 && BID <= bTS) {
                        ExitTrades(A, displayColorProfit, "Trailing Stop Reached");

                        return (0);
                    }
                } else if (nLots < 0) {
                    if (TSLPips_ > 0 && ASK < BEa - TSLPips_) {
                        if (bTS > 0)
                            bTS = MathMin(bTS, ASK + TSLPips_);
                        else
                            bTS = ASK + TSLPips_;
                    }

                    if (TSLPips_ < 0 && ASK < BEa + TSLPips_)
                        bTS = MathMin(bTS, ASK + MathMax(TSLPipsMin_, -TSLPips_ * (1 - (BEa - ASK + TSLPips_) / (-TSLPips_ * 2))));

                    if (bTS > 0 && ASK >= bTS) {
                        ExitTrades(A, displayColorProfit, "Trailing Stop Reached");

                        return (0);
                    }
                }
            }
        }
        //+-----------------------------------------------------------------+
        //| Check for and Delete hanging pending orders                     |
        //+-----------------------------------------------------------------+
        if (CbT == 0 && !PendLot) {
            PendLot = true;

            for (int Order = OrdersTotal() - 1; Order >= 0; Order--) {
                if (!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
                    continue;

                if (OrderMagicNumber() != Magic || OrderType() <= OP_SELL)
                    continue;

                if (ND(OrderLots(), LotDecimal) > ND(Lots[0] * LotMult, LotDecimal)) {
                    PendLot = false;

                    while (IsTradeContextBusy())
                        Sleep(100);

                    if (IsStopped())
                        return (-1);

                    Success = OrderDelete(OrderTicket());

                    if (Success) {
                        PendLot = true;

                        if (Debug_)
                            Print("Delete pending > Lot");
                    }
                }
            }

            return (0);
        } else if ((CbT > 0 || (CbT == 0 && CpT > 0 && !B3Traditional)) && PendLot) {
            PendLot = false;

            for (int Order = OrdersTotal() - 1; Order >= 0; Order--) {
                if (!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
                    continue;

                if (OrderMagicNumber() != Magic || OrderType() <= OP_SELL)
                    continue;

                if (ND(OrderLots(), LotDecimal) == ND(Lots[0] * LotMult, LotDecimal)) {
                    PendLot = true;

                    while (IsTradeContextBusy())
                        Sleep(100);

                    if (IsStopped())
                        return (-1);

                    Success = OrderDelete(OrderTicket());

                    if (Success) {
                        PendLot = false;

                        if (Debug_)
                            Print("Delete pending = Lot");
                    }
                }
            }

            return (0);
        }
        //+-----------------------------------------------------------------+
        //| Check ca, Breakeven Trades and Emergency Close All              |
        //+-----------------------------------------------------------------+
        switch (ca) {
        case B:
            if (CbT == 0 && CpT == 0)
                ca = 0;

            break;
        case H:
            if (ChT == 0)
                ca = 0;

            break;
        case A:
            if (CbT == 0 && CpT == 0 && ChT == 0)
                ca = 0;

            break;
        case P:
            if (CpT == 0)
                ca = 0;

            break;
        case T:
            break;
        default:
            break;
        }

        if (ca > 0) {
            ExitTrades(ca, displayColorLoss, "Close All (" + DTS(ca, 0) + ")");

            return (0);
        } else if (CbT == 0 && ChT > 0) {
            ExitTrades(H, displayColorLoss, "Basket Closed");

            return (0);
        } else if (EmergencyCloseAll_) {
            ExitTrades(A, displayColorLoss, "Emergency Close-All-Trades");
            EmergencyCloseAll_ = false;

            return (0);
        }
        //+-----------------------------------------------------------------+
        //| Check Holiday Shutdown                                          |
        //+-----------------------------------------------------------------+
        if (UseHolidayShutdown) {
            if (HolShutDown > 0 && TimeCurrent() >= HolLast && HolLast > 0) {
                Print("Trading has resumed after the ", TimeToStr(HolFirst, TIME_DATE), " - ", TimeToStr(HolLast, TIME_DATE), " holidays.");
                HolShutDown = 0;
                LabelDelete();
                LabelCreate();

                if (PlaySounds)
                    PlaySound(AlertSound);
            }

            if (HolShutDown == 3) {
                if (ObjectFind("B3LStop") == -1)
                    CreateLabel("B3LStop", "Trading has been paused on this pair for the holidays.", 10, 0, 0, 3, displayColorLoss);

                if (ObjectFind("B3LResm") == -1)
                    CreateLabel("B3LResm", "Trading will resume trading after " + TimeToStr(HolLast, TIME_DATE) + ".", 10, 0, 0, 9, displayColorLoss);

                return (0);
            } else if ((HolShutDown == 0 && TimeCurrent() >= HolLast) || HolFirst == 0) {
                for (int Index = 0; Index < ArraySize(HolArray); Index++) {
                    // HolFirst = StrToTime((string) Year() + "." + (string) HolArray[Index, 0] + "." + (string) HolArray[Index, 1]);
					string tts = (string) Year() + "." + (string) HolArray[Index, 0] + "." + (string) HolArray[Index, 1];
					Print("tts: " + tts + "  *******************************************************");
                    HolFirst = StrToTime(tts);

                    HolLast = StrToTime((string) Year() + "." + (string) HolArray[Index, 2] + "." + (string) HolArray[Index, 3] + " 23:59:59");

                    if (TimeCurrent() < HolFirst) {
                        if (HolFirst > HolLast)
                            HolLast = StrToTime(DTS(Year() + 1, 0) + "." + (string) HolArray[Index, 2] + "." + (string) HolArray[Index, 3] + " 23:59:59");

                        break;
                    }

                    if (TimeCurrent() < HolLast) {
                        if (HolFirst > HolLast)
                            HolFirst = StrToTime(DTS(Year() - 1, 0) + "." + (string) HolArray[Index, 0] + "." + (string) HolArray[Index, 1]);

                        break;
                    }

                    if (TimeCurrent() > HolFirst && HolFirst > HolLast) {
                        HolLast = StrToTime(DTS(Year() + 1, 0) + "." + (string) HolArray[Index, 2] + "." + (string) HolArray[Index, 3] + " 23:59:59");

                        if (TimeCurrent() < HolLast)
                            break;
                    }
                }

                if (TimeCurrent() >= HolFirst && TimeCurrent() <= HolLast) {
                    // Comment(""); // xxx
                    HolShutDown = 1;
                }
            } else if (HolShutDown == 0 && TimeCurrent() >= HolFirst && TimeCurrent() < HolLast)
                HolShutDown = 1;

            if (HolShutDown == 1 && CbT == 0) {
                Print("Trading has been paused for holidays (", TimeToStr(HolFirst, TIME_DATE), " - ", TimeToStr(HolLast, TIME_DATE), ")");

                if (CpT > 0) {
                    int Index = ExitTrades(P, displayColorLoss, "Holiday Shutdown");

                    if (Index == CpT)
                        ca = 0;
                }

                HolShutDown = 2;
                ObjDel("B3LClos");
            } else if (HolShutDown == 1) {
                if (ObjectFind("B3LClos") == -1)
                    CreateLabel("B3LClos", "", 5, 0, 0, 23, displayColorLoss);

                ObjSetTxt("B3LClos", "Trading will pause for holidays when this basket closes", 5);
            }

            if (HolShutDown == 2) {
                LabelDelete();

                if (PlaySounds)
                    PlaySound(AlertSound);

                HolShutDown = 3;
            }

            if (HolShutDown == 3) {
                if (ObjectFind("B3LStop") == -1)
                    CreateLabel("B3LStop", "Trading has been paused on this pair due to holidays.", 10, 0, 0, 3, displayColorLoss);

                if (ObjectFind("B3LResm") == -1)
                    CreateLabel("B3LResm", "Trading will resume after " + TimeToStr(HolLast, TIME_DATE) + ".", 10, 0, 0, 9, displayColorLoss);

                // Comment(""); // xxx

                return (0);
            }
        }
        //+-----------------------------------------------------------------+
        //| Power Out Stop Loss Protection                                  |
        //+-----------------------------------------------------------------+
        if (SetPOSL) {
            if (UsePowerOutSL && POSLPips_ > 0) {
                double POSL = MathMin(PortionBalance * (MaxDDPercent + 1) / 100 / PipVal2 / LbT, POSLPips_);
                SLbB = ND(BEb - POSL, Digits);
                SLbS = ND(BEb + POSL, Digits);
            } else {
                SLbB = 0;
                SLbS = 0;
            }

            for (int Order = 0; Order < OrdersTotal(); Order++) {
                if (!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
                    continue;

                if (OrderMagicNumber() != Magic || OrderSymbol() != Symbol() || OrderType() > OP_SELL)
                    continue;

                if (OrderType() == OP_BUY && OrderStopLoss() != SLbB) {
                    Success = ModifyOrder(OrderOpenPrice(), SLbB, Purple);

                    if (Debug_ && Success)
                        Print("Order ", OrderTicket(), ": Sync POSL Buy");
                } else if (OrderType() == OP_SELL && OrderStopLoss() != SLbS) {
                    Success = ModifyOrder(OrderOpenPrice(), SLbS, Purple);

                    if (Debug_ && Success)
                        Print("Order ", OrderTicket(), ": Sync POSL Sell");
                }
            }
        }
        //+-----------------------------------------------------------------+  << This must be the first Entry check.
        //| Moving Average Indicator for Order Entry                        |  << Add your own Indicator Entry checks
        //+-----------------------------------------------------------------+  << after the Moving Average Entry.
        if (MAEntry_ > 0 && CbT == 0 && CpT < 2) {
            if (BID > ima_0 + MADistance_ && (!B3Traditional || (B3Traditional && Trend != 2))) {
                if (MAEntry_ == 1) {
                    if (ForceMarketCond_ != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
                        BuyMe = true;
                    else
                        BuyMe = false;

                    if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                        SellMe = false;
                } else if (MAEntry_ == 2) {
                    if (ForceMarketCond_ != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
                        SellMe = true;
                    else
                        SellMe = false;

                    if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                        BuyMe = false;
                }
            } else if (ASK < ima_0 - MADistance_ && (!B3Traditional || (B3Traditional && Trend != 2))) {
                if (MAEntry_ == 1) {
                    if (ForceMarketCond_ != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
                        SellMe = true;
                    else
                        SellMe = false;

                    if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                        BuyMe = false;
                } else if (MAEntry_ == 2) {
                    if (ForceMarketCond_ != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
                        BuyMe = true;
                    else
                        BuyMe = false;

                    if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                        SellMe = false;
                }
            } else if (B3Traditional && Trend == 2) {
                if (ForceMarketCond_ != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
                    BuyMe = true;

                if (ForceMarketCond_ != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
                    SellMe = true;
            } else {
                BuyMe = false;
                SellMe = false;
            }

            if (IndEntry > 0)
                IndicatorUsed = IndicatorUsed + UAE;

            IndEntry++;
            IndicatorUsed = IndicatorUsed + " MA ";
        }
        //+----------------------------------------------------------------+
        //| CCI of 5M, 15M, 30M, 1H for Market Condition and Order Entry      |
        //+----------------------------------------------------------------+
        if (CCIEntry_ > 0) {
            cci_01 = iCCI(Symbol(), PERIOD_M5, CCIPeriod, PRICE_CLOSE, 0);
            cci_02 = iCCI(Symbol(), PERIOD_M15, CCIPeriod, PRICE_CLOSE, 0);
            cci_03 = iCCI(Symbol(), PERIOD_M30, CCIPeriod, PRICE_CLOSE, 0);
            cci_04 = iCCI(Symbol(), PERIOD_H1, CCIPeriod, PRICE_CLOSE, 0);
            cci_11 = iCCI(Symbol(), PERIOD_M5, CCIPeriod, PRICE_CLOSE, 1);
            cci_12 = iCCI(Symbol(), PERIOD_M15, CCIPeriod, PRICE_CLOSE, 1);
            cci_13 = iCCI(Symbol(), PERIOD_M30, CCIPeriod, PRICE_CLOSE, 1);
            cci_14 = iCCI(Symbol(), PERIOD_H1, CCIPeriod, PRICE_CLOSE, 1);
        }

        if (CCIEntry_ > 0 && CbT == 0 && CpT < 2) {
            if (cci_11 > 0 && cci_12 > 0 && cci_13 > 0 && cci_14 > 0 && cci_01 > 0 && cci_02 > 0 && cci_03 > 0 && cci_04 > 0) {
                if (ForceMarketCond_ == 3)
                    Trend = 0;

                if (CCIEntry_ == 1) {
                    if (ForceMarketCond_ != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
                        BuyMe = true;
                    else
                        BuyMe = false;

                    if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                        SellMe = false;
                } else if (CCIEntry_ == 2) {
                    if (ForceMarketCond_ != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
                        SellMe = true;
                    else
                        SellMe = false;

                    if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                        BuyMe = false;
                }
            } else if (cci_11 < 0 && cci_12 < 0 && cci_13 < 0 && cci_14 < 0 && cci_01 < 0 && cci_02 < 0 && cci_03 < 0 && cci_04 < 0) {
                if (ForceMarketCond_ == 3)
                    Trend = 1;

                if (CCIEntry_ == 1) {
                    if (ForceMarketCond_ != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
                        SellMe = true;
                    else
                        SellMe = false;

                    if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                        BuyMe = false;
                } else if (CCIEntry_ == 2) {
                    if (ForceMarketCond_ != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
                        BuyMe = true;
                    else
                        BuyMe = false;

                    if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                        SellMe = false;
                }
            } else if (!UseAnyEntry && IndEntry > 0) {
                BuyMe = false;
                SellMe = false;
            }

            if (IndEntry > 0)
                IndicatorUsed = IndicatorUsed + UAE;

            IndEntry++;
            IndicatorUsed = IndicatorUsed + " CCI ";
        }
        //+----------------------------------------------------------------+
        //| Bollinger Band Indicator for Order Entry                       |
        //+----------------------------------------------------------------+
        if (BollingerEntry_ > 0 && CbT == 0 && CpT < 2) {
            double ma = iMA(Symbol(), 0, BollPeriod, 0, MODE_SMA, PRICE_OPEN, 0);
            double stddev = iStdDev(Symbol(), 0, BollPeriod, 0, MODE_SMA, PRICE_OPEN, 0);
            double bup = ma + (BollDeviation * stddev);
            double bdn = ma - (BollDeviation * stddev);
            double bux = bup + BollDistance_;
            double bdx = bdn - BollDistance_;

            if (ASK < bdx) {
                if (BollingerEntry_ == 1) {
                    if (ForceMarketCond_ != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
                        BuyMe = true;
                    else
                        BuyMe = false;

                    if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                        SellMe = false;
                } else if (BollingerEntry_ == 2) {
                    if (ForceMarketCond_ != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
                        SellMe = true;
                    else
                        SellMe = false;

                    if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                        BuyMe = false;
                }
            } else if (BID > bux) {
                if (BollingerEntry_ == 1) {
                    if (ForceMarketCond_ != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
                        SellMe = true;
                    else
                        SellMe = false;

                    if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                        BuyMe = false;
                } else if (BollingerEntry_ == 2) {
                    if (ForceMarketCond_ != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
                        BuyMe = true;
                    else
                        BuyMe = false;

                    if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                        SellMe = false;
                }
            } else if (!UseAnyEntry && IndEntry > 0) {
                BuyMe = false;
                SellMe = false;
            }

            if (IndEntry > 0)
                IndicatorUsed = IndicatorUsed + UAE;

            IndEntry++;
            IndicatorUsed = IndicatorUsed + " BBands ";
        }
        //+----------------------------------------------------------------+
        //| Stochastic Indicator for Order Entry                           |
        //+----------------------------------------------------------------+
        if (StochEntry_ > 0 && CbT == 0 && CpT < 2) {
            int zoneBUY = BuySellStochZone;
            int zoneSELL = 100 - BuySellStochZone;
            double stoc_0 = iStochastic(NULL, 0, KPeriod, DPeriod, Slowing, MODE_LWMA, 1, 0, 1);
            double stoc_1 = iStochastic(NULL, 0, KPeriod, DPeriod, Slowing, MODE_LWMA, 1, 1, 1);

            if (stoc_0 < zoneBUY && stoc_1 < zoneBUY) {
                if (StochEntry_ == 1) {
                    if (ForceMarketCond_ != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
                        BuyMe = true;
                    else
                        BuyMe = false;

                    if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                        SellMe = false;
                } else if (StochEntry_ == 2) {
                    if (ForceMarketCond_ != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
                        SellMe = true;
                    else
                        SellMe = false;

                    if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                        BuyMe = false;
                }
            } else if (stoc_0 > zoneSELL && stoc_1 > zoneSELL) {
                if (StochEntry_ == 1) {
                    if (ForceMarketCond_ != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
                        SellMe = true;
                    else
                        SellMe = false;

                    if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                        BuyMe = false;
                } else if (StochEntry_ == 2) {
                    if (ForceMarketCond_ != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
                        BuyMe = true;
                    else
                        BuyMe = false;

                    if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                        SellMe = false;
                }
            } else if (!UseAnyEntry && IndEntry > 0) {
                BuyMe = false;
                SellMe = false;
            }

            if (IndEntry > 0)
                IndicatorUsed = IndicatorUsed + UAE;

            IndEntry++;
            IndicatorUsed = IndicatorUsed + " Stoch ";
        }
        //+----------------------------------------------------------------+
        //| MACD Indicator for Order Entry                                 |
        //+----------------------------------------------------------------+
        if (MACDEntry_ > 0 && CbT == 0 && CpT < 2) {
            double MACDm = iMACD(NULL, TF[MACD_TF], FastPeriod, SlowPeriod, SignalPeriod, MACDPrice, 0, 0);
            double MACDs = iMACD(NULL, TF[MACD_TF], FastPeriod, SlowPeriod, SignalPeriod, MACDPrice, 1, 0);

            if (MACDm > MACDs) {
                if (MACDEntry_ == 1) {
                    if (ForceMarketCond_ != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
                        BuyMe = true;
                    else
                        BuyMe = false;

                    if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                        SellMe = false;
                } else if (MACDEntry_ == 2) {
                    if (ForceMarketCond_ != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
                        SellMe = true;
                    else
                        SellMe = false;

                    if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                        BuyMe = false;
                }
            } else if (MACDm < MACDs) {
                if (MACDEntry_ == 1) {
                    if (ForceMarketCond_ != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
                        SellMe = true;
                    else
                        SellMe = false;

                    if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                        BuyMe = false;
                } else if (MACDEntry_ == 2) {
                    if (ForceMarketCond_ != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
                        BuyMe = true;
                    else
                        BuyMe = false;

                    if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                        SellMe = false;
                }
            } else if (!UseAnyEntry && IndEntry > 0) {
                BuyMe = false;
                SellMe = false;
            }

            if (IndEntry > 0)
                IndicatorUsed = IndicatorUsed + UAE;

            IndEntry++;
            IndicatorUsed = IndicatorUsed + " MACD ";
        }
        //+-----------------------------------------------------------------+  << This must be the last Entry check before
        //| UseAnyEntry Check && Force Market Condition Buy/Sell Entry      |  << the Trade Selection Logic. Add checks for
        //+-----------------------------------------------------------------+  << additional indicators before this block.
        if ((!UseAnyEntry && IndEntry > 1 && BuyMe && SellMe) || FirstRun) {
            BuyMe = false;
            SellMe = false;
        }

        if (ForceMarketCond_ < 2 && IndEntry == 0 && CbT == 0 && !FirstRun) {
            if (ForceMarketCond_ == 0)
                BuyMe = true;
            else if (ForceMarketCond_ == 1)
                SellMe = true;

            IndicatorUsed = " FMC ";
        }
        //+-----------------------------------------------------------------+
        //| Trade Selection Logic                                           |
        //+-----------------------------------------------------------------+
        OrderLot = LotSize(Lots[StrToInteger(DTS(MathMin(CbT + CbC, MaxTrades - 1), 0))] * LotMult);

        if (CbT == 0 && CpT < 2 && !FirstRun) {
            if (B3Traditional) {
                if (BuyMe) {
                    if (CpBS == 0 && CpSL == 0 && ((Trend != 2 || MAEntry_ == 0) || (Trend == 2 && MAEntry_ == 1))) {
                        Entry = g2 - MathMod(ASK, g2) + EntryOffset_;

                        if (Entry > StopLevel) {
                            Ticket = SendOrder(Symbol(), OP_BUYSTOP, OrderLot, Entry, 0, Magic, CLR_NONE);

                            if (Ticket > 0) {
                                if (Debug_)
                                    Print("Indicator Entry - (", IndicatorUsed, ") BuyStop MC = ", Trend);

                                CpBS++;
                            }
                        }
                    }

                    if (CpBL == 0 && CpSS == 0 && ((Trend != 2 || MAEntry_ == 0) || (Trend == 2 && MAEntry_ == 2))) {
                        Entry = MathMod(ASK, g2) + EntryOffset_;

                        if (Entry > StopLevel) {
                            Ticket = SendOrder(Symbol(), OP_BUYLIMIT, OrderLot, -Entry, 0, Magic, CLR_NONE);

                            if (Ticket > 0) {
                                if (Debug_)
                                    Print("Indicator Entry - (", IndicatorUsed, ") BuyLimit MC = ", Trend);

                                CpBL++;
                            }
                        }
                    }
                }

                if (SellMe) {
                    if (CpSL == 0 && CpBS == 0 && ((Trend != 2 || MAEntry_ == 0) || (Trend == 2 && MAEntry_ == 2))) {
                        Entry = g2 - MathMod(BID, g2) + EntryOffset_;

                        if (Entry > StopLevel) {
                            Ticket = SendOrder(Symbol(), OP_SELLLIMIT, OrderLot, Entry, 0, Magic, CLR_NONE);

                            if (Ticket > 0 && Debug_)
                                Print("Indicator Entry - (", IndicatorUsed, ") SellLimit MC = ", Trend);
                        }
                    }

                    if (CpSS == 0 && CpBL == 0 && ((Trend != 2 || MAEntry_ == 0) || (Trend == 2 && MAEntry_ == 1))) {
                        Entry = MathMod(BID, g2) + EntryOffset_;

                        if (Entry > StopLevel) {
                            Ticket = SendOrder(Symbol(), OP_SELLSTOP, OrderLot, -Entry, 0, Magic, CLR_NONE);

                            if (Ticket > 0 && Debug_)
                                Print("Indicator Entry - (", IndicatorUsed, ") SellStop MC = ", Trend);
                        }
                    }
                }
            } else {
                if (BuyMe) {
                    Ticket = SendOrder(Symbol(), OP_BUY, OrderLot, 0, slip, Magic, Blue);

                    if (Ticket > 0 && Debug_)
                        Print("Indicator Entry - (", IndicatorUsed, ") Buy");
                } else if (SellMe) {
                    Ticket = SendOrder(Symbol(), OP_SELL, OrderLot, 0, slip, Magic, displayColorLoss);

                    if (Ticket > 0 && Debug_)
                        Print("Indicator Entry - (", IndicatorUsed, ") Sell");
                }
            }

            if (Ticket > 0)
                return (0);
        } else if (TimeCurrent() - EntryDelay > OTbL && CbT + CbC < MaxTrades && !FirstRun) {
            if (UseSmartGrid) {
                if (RSI[1] != iRSI(NULL, TF[RSI_TF], RSI_Period, RSI_Price, 1)) {
                    for (int Index = 0; Index < RSI_Period + RSI_MA_Period; Index++)
                        RSI[Index] = iRSI(NULL, TF[RSI_TF], RSI_Period, RSI_Price, Index);
                } else
                    RSI[0] = iRSI(NULL, TF[RSI_TF], RSI_Period, RSI_Price, 0);

                RSI_MA = iMAOnArray(RSI, 0, RSI_MA_Period, 0, RSI_MA_Method, 0);
            }

            if (CbB > 0) {
                if (OPbL > ASK)
                    Entry = OPbL - (MathRound((OPbL - ASK) / g2) + 1) * g2;
                else
                    Entry = OPbL - g2;

                if (UseSmartGrid) {
                    if (ASK < OPbL - g2) {
                        if (RSI[0] > RSI_MA) {
                            Ticket = SendOrder(Symbol(), OP_BUY, OrderLot, 0, slip, Magic, Blue);

                            if (Ticket > 0 && Debug_)
                                Print("SmartGrid Buy RSI: ", RSI[0], " > MA: ", RSI_MA);
                        }

                        OPbN = 0;
                    } else
                        OPbN = OPbL - g2;
                } else if (CpBL == 0) {
                    if (ASK - Entry <= StopLevel)
                        Entry = OPbL - (MathFloor((OPbL - ASK + StopLevel) / g2) + 1) * g2;

                    Ticket = SendOrder(Symbol(), OP_BUYLIMIT, OrderLot, Entry - ASK, 0, Magic, SkyBlue);

                    if (Ticket > 0 && Debug_)
                        Print("BuyLimit grid");
                } else if (CpBL == 1 && Entry - OPpBL > g2 / 2 && ASK - Entry > StopLevel) {
                    for (int Order = OrdersTotal() - 1; Order >= 0; Order--) {
                        if (!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
                            continue;

                        if (OrderMagicNumber() != Magic || OrderSymbol() != Symbol() || OrderType() != OP_BUYLIMIT)
                            continue;

                        Success = ModifyOrder(Entry, 0, SkyBlue);

                        if (Success && Debug_)
                            Print("Mod BuyLimit Entry");
                    }
                }
            } else if (CbS > 0) {
                if (BID > OPbL)
                    Entry = OPbL + (MathRound((-OPbL + BID) / g2) + 1) * g2;
                else
                    Entry = OPbL + g2;

                if (UseSmartGrid) {
                    if (BID > OPbL + g2) {
                        if (RSI[0] < RSI_MA) {
                            Ticket = SendOrder(Symbol(), OP_SELL, OrderLot, 0, slip, Magic, displayColorLoss);

                            if (Ticket > 0 && Debug_)
                                Print("SmartGrid Sell RSI: ", RSI[0], " < MA: ", RSI_MA);
                        }

                        OPbN = 0;
                    } else
                        OPbN = OPbL + g2;
                } else if (CpSL == 0) {
                    if (Entry - BID <= StopLevel)
                        Entry = OPbL + (MathFloor((-OPbL + BID + StopLevel) / g2) + 1) * g2;

                    Ticket = SendOrder(Symbol(), OP_SELLLIMIT, OrderLot, Entry - BID, 0, Magic, Coral);

                    if (Ticket > 0 && Debug_)
                        Print("SellLimit grid");
                } else if (CpSL == 1 && OPpSL - Entry > g2 / 2 && Entry - BID > StopLevel) {
                    for (int Order = OrdersTotal() - 1; Order >= 0; Order--) {
                        if (!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
                            continue;

                        if (OrderMagicNumber() != Magic || OrderSymbol() != Symbol() || OrderType() != OP_SELLLIMIT)
                            continue;

                        Success = ModifyOrder(Entry, 0, Coral);

                        if (Success && Debug_)
                            Print("Mod SellLimit Entry");
                    }
                }
            }

            if (Ticket > 0)
                return (0);
        }
        //+-----------------------------------------------------------------+
        //| Hedge Trades Set-Up and Monitoring                              |
        //+-----------------------------------------------------------------+
        if ((UseHedge_ && CbT > 0) || ChT > 0) {
            int hLevel = CbT + CbC;

            if (HedgeTypeDD) {
                if (hDDStart == 0 && ChT > 0)
                    hDDStart = MathMax(HedgeStart_, DrawDownPC + hReEntryPC_);

                if (hDDStart > HedgeStart_ && hDDStart > DrawDownPC + hReEntryPC_)
                    hDDStart = DrawDownPC + hReEntryPC_;

                if (hActive == 2) {
                    hActive = 0;
                    hDDStart = MathMax(HedgeStart_, DrawDownPC + hReEntryPC_);
                }
            }

            if (hActive == 0) {
                if (!hThisChart && ((hPosCorr && CheckCorr() < 0.9) || (!hPosCorr && CheckCorr() > -0.9))) {
                    if (ObjectFind("B3LhCor") == -1)
                        CreateLabel("B3LhCor", "Correlation with the hedge pair has dropped below 90%.", 0, 0, 190, 10, displayColorLoss);
                } else
                    ObjDel("B3LhCor");

                if (hLvlStart > hLevel + 1 || (!HedgeTypeDD && hLvlStart == 0))
                    hLvlStart = MathMax(HedgeStart_, hLevel + 1);

                if ((HedgeTypeDD && DrawDownPC > hDDStart) || (!HedgeTypeDD && hLevel >= hLvlStart)) {
                    OrderLot = LotSize(LbT * hLotMult);

                    if ((CbB > 0 && !hPosCorr) || (CbS > 0 && hPosCorr)) {
                        Ticket = SendOrder(HedgeSymbol_, OP_BUY, OrderLot, 0, slip, hMagic, MidnightBlue);

                        if (Ticket > 0) {
                            if (hMaxLossPips_ > 0)
                                SLh = hAsk - hMaxLossPips_;

                            if (Debug_)
                                Print("Hedge Buy: Stoploss @ ", DTS(SLh, Digits));
                        }
                    }

                    if ((CbB > 0 && hPosCorr) || (CbS > 0 && !hPosCorr)) {
                        Ticket = SendOrder(HedgeSymbol_, OP_SELL, OrderLot, 0, slip, hMagic, Maroon);

                        if (Ticket > 0) {
                            if (hMaxLossPips_ > 0)
                                SLh = hBid + hMaxLossPips_;

                            if (Debug_)
                                Print("Hedge Sell: Stoploss @ ", DTS(SLh, Digits));
                        }
                    }

                    if (Ticket > 0) {
                        hActive = 1;

                        if (HedgeTypeDD)
                            hDDStart += hReEntryPC_;

                        hLvlStart = hLevel + 1;

                        return (0);
                    }
                }
            } else if (hActive == 1) {
                if (HedgeTypeDD && hDDStart > HedgeStart_ && hDDStart < DrawDownPC + hReEntryPC_)
                    hDDStart = DrawDownPC + hReEntryPC_;

                if (hLvlStart == 0) {
                    if (HedgeTypeDD)
                        hLvlStart = hLevel + 1;
                    else
                        hLvlStart = MathMax(HedgeStart_, hLevel + 1);
                }

                if (hLevel >= hLvlStart) {
                    OrderLot = LotSize(Lots[CbT + CbC - 1] * LotMult * hLotMult);

                    if (OrderLot > 0 && ((CbB > 0 && !hPosCorr) || (CbS > 0 && hPosCorr))) {
                        Ticket = SendOrder(HedgeSymbol_, OP_BUY, OrderLot, 0, slip, hMagic, MidnightBlue);

                        if (Ticket > 0 && Debug_)
                            Print("Hedge Buy");
                    }

                    if (OrderLot > 0 && ((CbB > 0 && hPosCorr) || (CbS > 0 && !hPosCorr))) {
                        Ticket = SendOrder(HedgeSymbol_, OP_SELL, OrderLot, 0, slip, hMagic, Maroon);

                        if (Ticket > 0 && Debug_)
                            Print("Hedge Sell");
                    }

                    if (Ticket > 0) {
                        hLvlStart = hLevel + 1;

                        return (0);
                    }
                }

                int Index = 0;

                if (!FirstRun && hMaxLossPips_ > 0) {
                    if (ChB > 0) {
                        if (hFixedSL) {
                            if (SLh == 0)
                                SLh = hBid - hMaxLossPips_;
                        } else {
                            if (SLh == 0 || (SLh < BEh && SLh < hBid - hMaxLossPips_))
                                SLh = hBid - hMaxLossPips_;
                            else if (StopTrailAtBE && hBid - hMaxLossPips_ >= BEh)
                                SLh = BEh;
                            else if (SLh >= BEh && !StopTrailAtBE) {
                                if (!ReduceTrailStop)
                                    SLh = MathMax(SLh, hBid - hMaxLossPips_);
                                else
                                    SLh = MathMax(SLh, hBid - MathMax(StopLevel, hMaxLossPips_ * (1 - (hBid - hMaxLossPips_ - BEh) / (hMaxLossPips_ * 2))));
                            }
                        }

                        if (hBid <= SLh)
                            Index = ExitTrades(H, DarkViolet, "Hedge StopLoss");
                    } else if (ChS > 0) {
                        if (hFixedSL) {
                            if (SLh == 0)
                                SLh = hAsk + hMaxLossPips_;
                        } else {
                            if (SLh == 0 || (SLh > BEh && SLh > hAsk + hMaxLossPips_))
                                SLh = hAsk + hMaxLossPips_;
                            else if (StopTrailAtBE && hAsk + hMaxLossPips_ <= BEh)
                                SLh = BEh;
                            else if (SLh <= BEh && !StopTrailAtBE) {
                                if (!ReduceTrailStop)
                                    SLh = MathMin(SLh, hAsk + hMaxLossPips_);
                                else
                                    SLh = MathMin(SLh, hAsk + MathMax(StopLevel, hMaxLossPips_ * (1 - (BEh - hAsk - hMaxLossPips_) / (hMaxLossPips_ * 2))));
                            }
                        }

                        if (hAsk >= SLh)
                            Index = ExitTrades(H, DarkViolet, "Hedge StopLoss");
                    }
                }

                if (Index == 0 && hTakeProfit_ > 0) {
                    if (ChB > 0 && hBid > OPhO + hTakeProfit_)
                        Index = ExitTrades(T, DarkViolet, "Hedge TakeProfit reached", ThO);

                    if (ChS > 0 && hAsk < OPhO - hTakeProfit_)
                        Index = ExitTrades(T, DarkViolet, "Hedge TakeProfit reached", ThO);
                }

                if (Index > 0) {
                    PhC = FindClosedPL(H);

                    if (Index == ChT) {
                        if (HedgeTypeDD)
                            hActive = 2;
                        else
                            hActive = 0;
                    }
                    return (0);
                }
            }
        }
        //+-----------------------------------------------------------------+
        //| Check DD% and send Email                                        |
        //+-----------------------------------------------------------------+
        if ((UseEmail || PlaySounds) && !Testing) {
            if (EmailCount < 2 && Email[EmailCount] > 0 && DrawDownPC > Email[EmailCount]) {
                GetLastError();

                if (UseEmail) {
                    SendMail("Drawdown warning", "Drawdown has exceeded " + DTS(Email[EmailCount] * 100, 2) + "% on " + Symbol() + " " + sTF);
                    Error = GetLastError();

                    if (Error > 0)
                        Print("Email DD: ", DTS(DrawDownPC * 100, 2), " Error: ", Error, " (", ErrorDescription(Error), ")");
                    else if (Debug_)
                        Print("DrawDown Email sent for ", Symbol(), " ", sTF, "  DD: ", DTS(DrawDownPC * 100, 2));
                    EmailSent = TimeCurrent();
                    EmailCount++;
                }

                if (PlaySounds)
                    PlaySound(AlertSound);
            } else if (EmailCount > 0 && EmailCount < 3 && DrawDownPC < Email[EmailCount] &&
						TimeCurrent() > EmailSent + EmailHours * 3600)
                EmailCount--;
        }
    }	// opb *********************
    //+-----------------------------------------------------------------+
    //| Display Overlay Code                                            |
    //+-----------------------------------------------------------------+
    string dMess = "";

    if ((Testing && Visual) || !Testing) {
        if (displayOverlay) {
            color Colour;
            int dDigits;

            ObjSetTxt("B3VTime", TimeToStr(TimeCurrent(), TIME_DATE | TIME_SECONDS));
            // This fixes a problem with OncePerBar & display of Stop Trade Amount always
            // showing zero, but is a hack ... Blessing needs to be re-engineered.
            // display of Stop Trade Amount:
            // double stop_trade_amount = -(Pb + Ph) / PortionBalance;   // opb
            // DrawLabel("B3VSTAm", InitialAccountMultiPortion, 167, 2, displayColorLoss);
            // static double previous_stop_trade_amount;

            if (stop_trade_amount != 0) {
                previous_stop_trade_amount = stop_trade_amount;
                DrawLabel("B3VSTAm", stop_trade_amount, 167, 2, displayColorLoss);
            } else
                DrawLabel("B3VSTAm", previous_stop_trade_amount, 167, 2, displayColorLoss);
            // DrawLabel("B3VSTAm", stop_trade_amount, 167, 2, displayColorLoss);
            // End of fix

            if (UseHolidayShutdown) {
                ObjSetTxt("B3VHolF", TimeToStr(HolFirst, TIME_DATE));
                ObjSetTxt("B3VHolT", TimeToStr(HolLast, TIME_DATE));
            }

            DrawLabel("B3VPBal", PortionBalance, 167);

            if (DrawDownPC > 0.4)
                Colour = displayColorLoss;
            else if (DrawDownPC > 0.3)
                Colour = Orange;
            else if (DrawDownPC > 0.2)
                Colour = Yellow;
            else if (DrawDownPC > 0.1)
                Colour = displayColorProfit;
            else
                Colour = displayColor;

            DrawLabel("B3VDrDn", DrawDownPC * 100, 315, 2, Colour);

            if (UseHedge_ && HedgeTypeDD)
                ObjSetTxt("B3VhDDm", DTS(hDDStart * 100, 2));
            else if (UseHedge_ && !HedgeTypeDD) {
                DrawLabel("B3VhLvl", CbT + CbC, 318, 0);
                ObjSetTxt("B3VhLvT", DTS(hLvlStart, 0));
            }

            ObjSetTxt("B3VSLot", DTS(Lot_ * LotMult, 2));

            if (ProfitPot >= 0)
                DrawLabel("B3VPPot", ProfitPot, 190);
            else {
                ObjSetTxt("B3VPPot", DTS(ProfitPot, 2), 0, displayColorLoss);
                dDigits = Digit[ArrayBsearch(Digit, (int) -ProfitPot, WHOLE_ARRAY, 0, MODE_ASCEND), 1];
                ObjSet("B3VPPot", 186 - dDigits * 7);
            }

            if (UseEarlyExit && EEpc < 1) {
                if (ObjectFind("B3SEEPr") == -1)
                    CreateLabel("B3SEEPr", "/", 0, 0, 220, 12);

                if (ObjectFind("B3VEEPr") == -1)
                    CreateLabel("B3VEEPr", "", 0, 0, 229, 12);

                ObjSetTxt("B3VEEPr", DTS(PbTarget * PipValue * MathAbs(LbB - LbS), 2));
            } else {
                ObjDel("B3SEEPr");
                ObjDel("B3VEEPr");
            }

            if (SLb > 0)
                DrawLabel("B3VPrSL", SLb, 190, Digits);
            else if (bSL > 0)
                DrawLabel("B3VPrSL", bSL, 190, Digits);
            else if (bTS > 0)
                DrawLabel("B3VPrSL", bTS, 190, Digits);
            else
                DrawLabel("B3VPrSL", 0, 190, 2);

            if (Pb >= 0) {
                DrawLabel("B3VPnPL", Pb, 190, 2, displayColorProfit);
                ObjSetTxt("B3VPPip", DTS(PbPips, 1), 0, displayColorProfit);
                ObjSet("B3VPPip", 229);
            } else {
                ObjSetTxt("B3VPnPL", DTS(Pb, 2), 0, displayColorLoss);
                dDigits = Digit[ArrayBsearch(Digit, (int) -Pb, WHOLE_ARRAY, 0, MODE_ASCEND), 1];
                ObjSet("B3VPnPL", 186 - dDigits * 7);
                ObjSetTxt("B3VPPip", DTS(PbPips, 1), 0, displayColorLoss);
                ObjSet("B3VPPip", 225);
            }

            if (PbMax >= 0)
                DrawLabel("B3VPLMx", PbMax, 190, 2, displayColorProfit);
            else {
                ObjSetTxt("B3VPLMx", DTS(PbMax, 2), 0, displayColorLoss);
                dDigits = Digit[ArrayBsearch(Digit, (int) -PbMax, WHOLE_ARRAY, 0, MODE_ASCEND), 1];
                ObjSet("B3VPLMx", 186 - dDigits * 7);
            }

            if (PbMin < 0)
                ObjSet("B3VPLMn", 225);
            else
                ObjSet("B3VPLMn", 229);

            ObjSetTxt("B3VPLMn", DTS(PbMin, 2), 0, displayColorLoss);

            if (CbT + CbC < BreakEvenTrade && CbT + CbC < MaxTrades)
                Colour = displayColor;
            else if (CbT + CbC < MaxTrades)
                Colour = Orange;
            else
                Colour = displayColorLoss;

            if (CbB > 0) {
                ObjSetTxt("B3LType", "Buy:");
                DrawLabel("B3VOpen", CbB, 207, 0, Colour);
            } else if (CbS > 0) {
                ObjSetTxt("B3LType", "Sell:");
                DrawLabel("B3VOpen", CbS, 207, 0, Colour);
            } else {
                ObjSetTxt("B3LType", "");
                ObjSetTxt("B3VOpen", DTS(0, 0), 0, Colour);
                ObjSet("B3VOpen", 207);
            }

            ObjSetTxt("B3VLots", DTS(LbT, 2));
            ObjSetTxt("B3VMove", DTS(Moves, 0));
            DrawLabel("B3VMxDD", MaxDD, 107);
            DrawLabel("B3VDDPC", MaxDDPer, 229);

            if (Trend == 0) {
                ObjSetTxt("B3LTrnd", "Trend is UP", 10, displayColorProfit);

                if (ObjectFind("B3ATrnd") == -1)
                    CreateLabel("B3ATrnd", "", 0, 0, 160, 20, displayColorProfit, "Wingdings");

                ObjectSetText("B3ATrnd", "é", displayFontSize + 9, "Wingdings", displayColorProfit);
                ObjSet("B3ATrnd", 160);
                ObjectSet("B3ATrnd", OBJPROP_YDISTANCE, displayYcord + displaySpacing * 20);

                if (StringLen(ATrend) > 0) {
                    if (ObjectFind("B3AATrn") == -1)
                        CreateLabel("B3AATrn", "", 0, 0, 200, 20, displayColorProfit, "Wingdings");

                    if (ATrend == "D") {
                        ObjectSetText("B3AATrn", "ê", displayFontSize + 9, "Wingdings", displayColorLoss);
                        ObjectSet("B3AATrn", OBJPROP_YDISTANCE, displayYcord + displaySpacing * 20 + 5);
                    } else if (ATrend == "R") {
                        ObjSetTxt("B3AATrn", "R", 10, Orange);
                        ObjectSet("B3AATrn", OBJPROP_YDISTANCE, displayYcord + displaySpacing * 20);
                    }
                } else
                    ObjDel("B3AATrn");
            } else if (Trend == 1) {
                ObjSetTxt("B3LTrnd", "Trend is DOWN", 10, displayColorLoss);

                if (ObjectFind("B3ATrnd") == -1)
                    CreateLabel("B3ATrnd", "", 0, 0, 210, 20, displayColorLoss, "WingDings");

                ObjectSetText("B3ATrnd", "ê", displayFontSize + 9, "Wingdings", displayColorLoss);
                ObjSet("B3ATrnd", 210);
                ObjectSet("B3ATrnd", OBJPROP_YDISTANCE, displayYcord + displaySpacing * 20 + 5);

                if (StringLen(ATrend) > 0) {
                    if (ObjectFind("B3AATrn") == -1)
                        CreateLabel("B3AATrn", "", 0, 0, 250, 20, displayColorProfit, "Wingdings");

                    if (ATrend == "U") {
                        ObjectSetText("B3AATrn", "é", displayFontSize + 9, "Wingdings", displayColorProfit);
                        ObjectSet("B3AATrn", OBJPROP_YDISTANCE, displayYcord + displaySpacing * 20);
                    } else if (ATrend == "R") {
                        ObjSetTxt("B3AATrn", "R", 10, Orange);
                        ObjectSet("B3AATrn", OBJPROP_YDISTANCE, displayYcord + displaySpacing * 20);
                    }
                } else
                    ObjDel("B3AATrn");
            } else if (Trend == 2) {
                ObjSetTxt("B3LTrnd", "Trend is Ranging", 10, Orange);
                ObjDel("B3ATrnd");

                if (StringLen(ATrend) > 0) {
                    if (ObjectFind("B3AATrn") == -1)
                        CreateLabel("B3AATrn", "", 0, 0, 220, 20, displayColorProfit, "Wingdings");

                    if (ATrend == "U") {
                        ObjectSetText("B3AATrn", "é", displayFontSize + 9, "Wingdings", displayColorProfit);
                        ObjectSet("B3AATrn", OBJPROP_YDISTANCE, displayYcord + displaySpacing * 20);
                    } else if (ATrend == "D") {
                        ObjectSetText("B3AATrn", "ê", displayFontSize + 8, "Wingdings", displayColorLoss);
                        ObjectSet("B3AATrn", OBJPROP_YDISTANCE, displayYcord + displaySpacing * 20 + 5);
                    }
                } else
                    ObjDel("B3AATrn");
            }

            if (PaC != 0) {
                if (ObjectFind("B3LClPL") == -1)
                    CreateLabel("B3LClPL", "Closed P/L", 0, 0, 312, 11);

                if (ObjectFind("B3VClPL") == -1)
                    CreateLabel("B3VClPL", "", 0, 0, 327, 12);

                if (PaC >= 0)
                    DrawLabel("B3VClPL", PaC, 327, 2, displayColorProfit);
                else {
                    ObjSetTxt("B3VClPL", DTS(PaC, 2), 0, displayColorLoss);
                    dDigits = Digit[ArrayBsearch(Digit, (int) -PaC, WHOLE_ARRAY, 0, MODE_ASCEND), 1];
                    ObjSet("B3VClPL", 323 - dDigits * 7);
                }
            } else {
                ObjDel("B3LClPL");
                ObjDel("B3VClPL");
            }

            if (hActive == 1) {
                if (ObjectFind("B3LHdge") == -1)
                    CreateLabel("B3LHdge", "Hedge", 0, 0, 323, 13);

                if (ObjectFind("B3VhPro") == -1)
                    CreateLabel("B3VhPro", "", 0, 0, 312, 14);

                if (Ph >= 0)
                    DrawLabel("B3VhPro", Ph, 312, 2, displayColorProfit);
                else {
                    ObjSetTxt("B3VhPro", DTS(Ph, 2), 0, displayColorLoss);
                    dDigits = Digit[ArrayBsearch(Digit, (int) -Ph, WHOLE_ARRAY, 0, MODE_ASCEND), 1];
                    ObjSet("B3VhPro", 308 - dDigits * 7);
                }

                if (ObjectFind("B3VhPMx") == -1)
                    CreateLabel("B3VhPMx", "", 0, 0, 312, 15);

                if (PhMax >= 0)
                    DrawLabel("B3VhPMx", PhMax, 312, 2, displayColorProfit);
                else {
                    ObjSetTxt("B3VhPMx", DTS(PhMax, 2), 0, displayColorLoss);
                    dDigits = Digit[ArrayBsearch(Digit, (int) -PhMax, WHOLE_ARRAY, 0, MODE_ASCEND), 1];
                    ObjSet("B3VhPMx", 308 - dDigits * 7);
                }

                if (ObjectFind("B3ShPro") == -1)
                    CreateLabel("B3ShPro", "/", 0, 0, 342, 15);

                if (ObjectFind("B3VhPMn") == -1)
                    CreateLabel("B3VhPMn", "", 0, 0, 351, 15, displayColorLoss);

                if (PhMin < 0)
                    ObjSet("B3VhPMn", 347);
                else
                    ObjSet("B3VhPMn", 351);

                ObjSetTxt("B3VhPMn", DTS(PhMin, 2), 0, displayColorLoss);

                if (ObjectFind("B3LhTyp") == -1)
                    CreateLabel("B3LhTyp", "", 0, 0, 292, 16);

                if (ObjectFind("B3VhOpn") == -1)
                    CreateLabel("B3VhOpn", "", 0, 0, 329, 16);

                if (ChB > 0) {
                    ObjSetTxt("B3LhTyp", "Buy:");
                    DrawLabel("B3VhOpn", ChB, 329, 0);
                } else if (ChS > 0) {
                    ObjSetTxt("B3LhTyp", "Sell:");
                    DrawLabel("B3VhOpn", ChS, 329, 0);
                } else {
                    ObjSetTxt("B3LhTyp", "");
                    ObjSetTxt("B3VhOpn", DTS(0, 0));
                    ObjSet("B3VhOpn", 329);
                }

                if (ObjectFind("B3ShOpn") == -1)
                    CreateLabel("B3ShOpn", "/", 0, 0, 342, 16);

                if (ObjectFind("B3VhLot") == -1)
                    CreateLabel("B3VhLot", "", 0, 0, 351, 16);

                ObjSetTxt("B3VhLot", DTS(LhT, 2));
            } else {
                ObjDel("B3LHdge");
                ObjDel("B3VhPro");
                ObjDel("B3VhPMx");
                ObjDel("B3ShPro");
                ObjDel("B3VhPMn");
                ObjDel("B3LhTyp");
                ObjDel("B3VhOpn");
                ObjDel("B3ShOpn");
                ObjDel("B3VhLot");
            }
        }

        if (displayLines) {
            if (BEb > 0) {
                if (ObjectFind("B3LBELn") == -1)
                    CreateLine("B3LBELn", DodgerBlue, 1, 0);

                ObjectMove("B3LBELn", 0, Time[1], BEb);
            } else
                ObjDel("B3LBELn");

            if (TPa > 0) {
                if (ObjectFind("B3LTPLn") == -1)
                    CreateLine("B3LTPLn", Gold, 1, 0);

                ObjectMove("B3LTPLn", 0, Time[1], TPa);
            } else if (TPb > 0 && nLots != 0) {
                if (ObjectFind("B3LTPLn") == -1)
                    CreateLine("B3LTPLn", Gold, 1, 0);

                ObjectMove("B3LTPLn", 0, Time[1], TPb);
            } else
                ObjDel("B3LTPLn");

            if (OPbN > 0) {
                if (ObjectFind("B3LOPLn") == -1)
                    CreateLine("B3LOPLn", Red, 1, 4);

                ObjectMove("B3LOPLn", 0, Time[1], OPbN);
            } else
                ObjDel("B3LOPLn");

            if (bSL > 0) {
                if (ObjectFind("B3LSLbT") == -1)
                    CreateLine("B3LSLbT", Red, 1, 3);

                ObjectMove("B3LSLbT", 0, Time[1], bSL);
            } else
                ObjDel("B3LSLbT");

            if (bTS > 0) {
                if (ObjectFind("B3LTSbT") == -1)
                    CreateLine("B3LTSbT", Gold, 1, 3);

                ObjectMove("B3LTSbT", 0, Time[1], bTS);
            } else
                ObjDel("B3LTSbT");

            if (hActive == 1 && BEa > 0) {
                if (ObjectFind("B3LNBEL") == -1)
                    CreateLine("B3LNBEL", Crimson, 1, 0);

                ObjectMove("B3LNBEL", 0, Time[1], BEa);
            } else
                ObjDel("B3LNBEL");

            if (TPbMP > 0) {
                if (ObjectFind("B3LMPLn") == -1)
                    CreateLine("B3LMPLn", Gold, 1, 4);

                ObjectMove("B3LMPLn", 0, Time[1], TPbMP);
            } else
                ObjDel("B3LMPLn");

            if (SLb > 0) {
                if (ObjectFind("B3LTSLn") == -1)
                    CreateLine("B3LTSLn", Gold, 1, 2);

                ObjectMove("B3LTSLn", 0, Time[1], SLb);
            } else
                ObjDel("B3LTSLn");

            if (hThisChart && BEh > 0) {
                if (ObjectFind("B3LhBEL") == -1)
                    CreateLine("B3LhBEL", SlateBlue, 1, 0);

                ObjectMove("B3LhBEL", 0, Time[1], BEh);
            } else
                ObjDel("B3LhBEL");

            if (hThisChart && SLh > 0) {
                if (ObjectFind("B3LhSLL") == -1)
                    CreateLine("B3LhSLL", SlateBlue, 1, 3);

                ObjectMove("B3LhSLL", 0, Time[1], SLh);
            } else
                ObjDel("B3LhSLL");
        } else {
            ObjDel("B3LBELn");
            ObjDel("B3LTPLn");
            ObjDel("B3LOPLn");
            ObjDel("B3LSLbT");
            ObjDel("B3LTSbT");
            ObjDel("B3LNBEL");
            ObjDel("B3LMPLn");
            ObjDel("B3LTSLn");
            ObjDel("B3LhBEL");
            ObjDel("B3LhSLL");
        }

        if (CCIEntry_ && displayCCI) {
            if (cci_01 > 0 && cci_11 > 0)
                ObjectSetText("B3VCm05", "Ù", displayFontSize + 6, "Wingdings", displayColorProfit);
            else if (cci_01 < 0 && cci_11 < 0)
                ObjectSetText("B3VCm05", "Ú", displayFontSize + 6, "Wingdings", displayColorLoss);
            else
                ObjectSetText("B3VCm05", "Ø", displayFontSize + 6, "Wingdings", Orange);

            if (cci_02 > 0 && cci_12 > 0)
                ObjectSetText("B3VCm15", "Ù", displayFontSize + 6, "Wingdings", displayColorProfit);
            else if (cci_02 < 0 && cci_12 < 0)
                ObjectSetText("B3VCm15", "Ú", displayFontSize + 6, "Wingdings", displayColorLoss);
            else
                ObjectSetText("B3VCm15", "Ø", displayFontSize + 6, "Wingdings", Orange);

            if (cci_03 > 0 && cci_13 > 0)
                ObjectSetText("B3VCm30", "Ù", displayFontSize + 6, "Wingdings", displayColorProfit);
            else if (cci_03 < 0 && cci_13 < 0)
                ObjectSetText("B3VCm30", "Ú", displayFontSize + 6, "Wingdings", displayColorLoss);
            else
                ObjectSetText("B3VCm30", "Ø", displayFontSize + 6, "Wingdings", Orange);

            if (cci_04 > 0 && cci_14 > 0)
                ObjectSetText("B3VCm60", "Ù", displayFontSize + 6, "Wingdings", displayColorProfit);
            else if (cci_04 < 0 && cci_14 < 0)
                ObjectSetText("B3VCm60", "Ú", displayFontSize + 6, "Wingdings", displayColorLoss);
            else
                ObjectSetText("B3VCm60", "Ø", displayFontSize + 6, "Wingdings", Orange);
        }

        if (Debug_) {
            string dSpace;

            for (int Index = 0; Index <= 175; Index++)
                dSpace = dSpace + " ";

            dMess = "\n\n" + dSpace + "Ticket   Magic     Type Lots OpenPrice  Costs  Profit  Potential";

            for (int Order = 0; Order < OrdersTotal(); Order++) {
                if (!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
                    continue;

                if (OrderMagicNumber() != Magic && OrderMagicNumber() != hMagic)
                    continue;

                dMess = (dMess + "\n" + dSpace + " " + (string) OrderTicket() + "  " + DTS(OrderMagicNumber(), 0) + "   " + (string) OrderType());
                dMess = (dMess + "   " + DTS(OrderLots(), LotDecimal) + "  " + DTS(OrderOpenPrice(), Digits));
                dMess = (dMess + "     " + DTS(OrderSwap() + OrderCommission(), 2));
                dMess = (dMess + "    " + DTS(OrderProfit() + OrderSwap() + OrderCommission(), 2));

                if (OrderMagicNumber() != Magic)
                    continue;
                else if (OrderType() == OP_BUY)
                    dMess = (dMess + "      " + DTS(OrderLots() * (TPb - OrderOpenPrice()) * PipVal2 + OrderSwap() + OrderCommission(), 2));
                else if (OrderType() == OP_SELL)
                    dMess = (dMess + "      " + DTS(OrderLots() * (OrderOpenPrice() - TPb) * PipVal2 + OrderSwap() + OrderCommission(), 2));
            }

            if (!dLabels) {
                dLabels = true;
                CreateLabel("B3LPipV", "Pip Value", 0, 2, 0, 0);
                CreateLabel("B3VPipV", "", 0, 2, 100, 0);
                CreateLabel("B3LDigi", "Digits Value", 0, 2, 0, 1);
                CreateLabel("B3VDigi", "", 0, 2, 100, 1);
                ObjSetTxt("B3VDigi", DTS(Digits, 0));
                CreateLabel("B3LPoin", "Point Value", 0, 2, 0, 2);
                CreateLabel("B3VPoin", "", 0, 2, 100, 2);
                ObjSetTxt("B3VPoin", DTS(Point, Digits));
                CreateLabel("B3LSprd", "Spread Value", 0, 2, 0, 3);
                CreateLabel("B3VSprd", "", 0, 2, 100, 3);
                CreateLabel("B3LBid", "Bid Value", 0, 2, 0, 4);
                CreateLabel("B3VBid", "", 0, 2, 100, 4);
                CreateLabel("B3LAsk", "Ask Value", 0, 2, 0, 5);
                CreateLabel("B3VAsk", "", 0, 2, 100, 5);
                CreateLabel("B3LLotP", "Lot Step", 0, 2, 200, 0);
                CreateLabel("B3VLotP", "", 0, 2, 300, 0);
                ObjSetTxt("B3VLotP", DTS(MarketInfo(Symbol(), MODE_LOTSTEP), LotDecimal));
                CreateLabel("B3LLotX", "Lot Max", 0, 2, 200, 1);
                CreateLabel("B3VLotX", "", 0, 2, 300, 1);
                ObjSetTxt("B3VLotX", DTS(MarketInfo(Symbol(), MODE_MAXLOT), 0));
                CreateLabel("B3LLotN", "Lot Min", 0, 2, 200, 2);
                CreateLabel("B3VLotN", "", 0, 2, 300, 2);
                ObjSetTxt("B3VLotN", DTS(MarketInfo(Symbol(), MODE_MINLOT), LotDecimal));
                CreateLabel("B3LLotD", "Lot Decimal", 0, 2, 200, 3);
                CreateLabel("B3VLotD", "", 0, 2, 300, 3);
                ObjSetTxt("B3VLotD", DTS(LotDecimal, 0));
                CreateLabel("B3LAccT", "Account Type", 0, 2, 200, 4);
                CreateLabel("B3VAccT", "", 0, 2, 300, 4);
                ObjSetTxt("B3VAccT", DTS(AccountType, 0));
                CreateLabel("B3LPnts", "Pip", 0, 2, 200, 5);
                CreateLabel("B3VPnts", "", 0, 2, 300, 5);
                ObjSetTxt("B3VPnts", DTS(Pip, Digits));
                CreateLabel("B3LTicV", "Tick Value", 0, 2, 400, 0);
                CreateLabel("B3VTicV", "", 0, 2, 500, 0);
                CreateLabel("B3LTicS", "Tick Size", 0, 2, 400, 1);
                CreateLabel("B3VTicS", "", 0, 2, 500, 1);
                ObjSetTxt("B3VTicS", DTS(MarketInfo(Symbol(), MODE_TICKSIZE), Digits));
                CreateLabel("B3LLev", "Leverage", 0, 2, 400, 2);
                CreateLabel("B3VLev", "", 0, 2, 500, 2);
                ObjSetTxt("B3VLev", DTS(AccountLeverage(), 0) + ":1");
                CreateLabel("B3LSGTF", "SmartGrid", 0, 2, 400, 3);

                if (UseSmartGrid)
                    CreateLabel("B3VSGTF", "True", 0, 2, 500, 3);
                else
                    CreateLabel("B3VSGTF", "False", 0, 2, 500, 3);

                CreateLabel("B3LCOTF", "Close Oldest", 0, 2, 400, 4);

                if (UseCloseOldest)
                    CreateLabel("B3VCOTF", "True", 0, 2, 500, 4);
                else
                    CreateLabel("B3VCOTF", "False", 0, 2, 500, 4);

                CreateLabel("B3LUHTF", "Hedge", 0, 2, 400, 5);

                if (UseHedge_ && HedgeTypeDD)
                    CreateLabel("B3VUHTF", "DrawDown", 0, 2, 500, 5);
                else if (UseHedge_ && !HedgeTypeDD)
                    CreateLabel("B3VUHTF", "Level", 0, 2, 500, 5);
                else
                    CreateLabel("B3VUHTF", "False", 0, 2, 500, 5);
            }

            ObjSetTxt("B3VPipV", DTS(PipValue, 2));
            ObjSetTxt("B3VSprd", DTS(ASK - BID, Digits));
            ObjSetTxt("B3VBid", DTS(BID, Digits));
            ObjSetTxt("B3VAsk", DTS(ASK, Digits));
            ObjSetTxt("B3VTicV", DTS(MarketInfo(Symbol(), MODE_TICKVALUE), Digits));
        }

        if (EmergencyWarning) {
            if (ObjectFind("B3LClos") == -1)
                CreateLabel("B3LClos", "", 5, 0, 0, 23, displayColorLoss);

            ObjSetTxt("B3LClos", "WARNING: EmergencyCloseAll is TRUE", 5, displayColorLoss);
        } else if (ShutDown_) {
            if (ObjectFind("B3LClos") == -1)
                CreateLabel("B3LClos", "", 5, 0, 0, 23, displayColorLoss);

            ObjSetTxt("B3LClos", "Trading will stop when this basket closes.", 5, displayColorLoss);
        } else if (HolShutDown != 1)
            ObjDel("B3LClos");
    }

    WindowRedraw();
    FirstRun = false;
    Comment(CS, dMess);

    return (0);
}


//+-----------------------------------------------------------------+
//| Check Lot Size Function                                         |
//+-----------------------------------------------------------------+
double LotSize(double NewLot) {
    NewLot = ND(NewLot, LotDecimal);
    NewLot = MathMin(NewLot, MarketInfo(Symbol(), MODE_MAXLOT));
    NewLot = MathMax(NewLot, MinLotSize);

    return (NewLot);
}


double margin_maxlots() {
    return (AccountFreeMargin() / MarketInfo(Symbol(), MODE_MARGINREQUIRED));
}


double portion_maxlots() {
    return (PortionBalance / MarketInfo(Symbol(), MODE_MARGINREQUIRED));
}


//+-----------------------------------------------------------------+
//| Open Order Function                                             |
//+-----------------------------------------------------------------+
int SendOrder(string OSymbol, int OCmd, double OLot, double OPrice, int OSlip, int OMagic, color OColor = CLR_NONE) {
    if (FirstRun)
        return (-1);

    int Ticket = 0;
    int Tries = 0;
    int OType = (int) MathMod(OCmd, 2);
    double OrderPrice;

	// check margin against MinMarginPercent
	if (UseMinMarginPercent && AccountMargin() > 0) {
        // double ml = ND(AccountEquity() / AccountMargin() * 100, 2);
        double ml = ND(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL), 2);
		Print("Account Margin Level: " + DTS(ml,2));
        if (ml < MinMarginPercent) {
            Print("Margin percent " + (string) ml + "% too low to open new trade");
            return -1;
        }
    }

	// Sanity check lots vs. portion and margin ... r.f.
    if (OLot > (portion_maxlots() - LbT)) {     // Request lots vs Portion - Current lots out
        Print("Insufficient Portion free ", OSymbol, "  Type: ", OType, " Lots: ", DTS(OLot, 2),
              "  Free margin: ", DTS(AccountFreeMargin(), 2), "  Margin Maxlots: ", DTS(margin_maxlots(), 2), "  Portion Maxlots: ", DTS(portion_maxlots(), 2), "  Current Lots: ", DTS(LbT, 2));
        return (-1);

        // OLot = portion_maxlots() - LbT - MinLotSize;
        // Print("Reducing order to: ", DTS(OLot, 2));
    }

    if (AccountFreeMarginCheck(OSymbol, OType, OLot) <= 0 || GetLastError() == ERR_NOT_ENOUGH_MONEY) {
        Print("Not enough margin ", OSymbol, "  Type: ", OType, " Lots: ", DTS(OLot, 2),
              "  Free margin: ", DTS(AccountFreeMargin(), 2), "  Margin Maxlots: ", DTS(margin_maxlots(), 2), "  Portion Maxlots: ", DTS(portion_maxlots(), 2), "  Current Lots: ", DTS(LbT, 2));

        return (-1);
    }

    if (MaxSpread > 0 && MarketInfo(OSymbol, MODE_SPREAD) * Point / Pip > MaxSpread)
        return (-1);

    while (Tries < 5) {
        Tries++;

        while (IsTradeContextBusy())
            Sleep(100);

        if (IsStopped())
            return (-1);
        else if (OType == 0)
            OrderPrice = ND(MarketInfo(OSymbol, MODE_ASK) + OPrice, (int) MarketInfo(OSymbol, MODE_DIGITS));
        else
            OrderPrice = ND(MarketInfo(OSymbol, MODE_BID) + OPrice, (int) MarketInfo(OSymbol, MODE_DIGITS));

        Ticket = OrderSend(OSymbol, OCmd, OLot, OrderPrice, OSlip, 0, 0, TradeComment, OMagic, 0, OColor);

        if (Ticket < 0) {
            Error = GetLastError();

            if (Error != 0)
                Print("Error ", Error, "(", ErrorDescription(Error), ") opening order - ",
                      "  Symbol: ", OSymbol, "  TradeOP: ", OCmd, "  OType: ", OType,
                      "  Ask: ", DTS(MarketInfo(OSymbol, MODE_ASK), Digits),
                      "  Bid: ", DTS(MarketInfo(OSymbol, MODE_BID), Digits), "  OPrice: ", DTS(OPrice, Digits), "  Price: ", DTS(OrderPrice, Digits), "  Lots: ", DTS(OLot, 2));

            switch (Error) {
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
            case 149:          //ERR_TRADE_HEDGE_PROHIBITED:
                if (Debug_)
                    Print("Hedge trades are not supported on this pair");

                UseHedge_ = false;
                Tries = 5;
                break;
            default:
                Tries = 5;
            }
        } else {
            if (PlaySounds)
                PlaySound(AlertSound);

            break;
        }
    }

    return (Ticket);
}


//+-----------------------------------------------------------------+
//| Modify Order Function                                           |
//+-----------------------------------------------------------------+
bool ModifyOrder(double OrderOP, double OrderSL, color Color = CLR_NONE) {
    bool Success = false;
    int Tries = 0;

    while (Tries < 5 && !Success) {
        Tries++;

        while (IsTradeContextBusy())
            Sleep(100);

        if (IsStopped())
            return (false);     //(-1)

        Success = OrderModify(OrderTicket(), OrderOP, OrderSL, 0, 0, Color);

        if (!Success) {
            Error = GetLastError();

            if (Error > 1) {
                Print("Error ", Error, " (", ErrorDescription(Error), ") modifying order ", OrderTicket(), "  Ask: ", Ask,
                      "  Bid: ", Bid, "  OrderPrice: ", OrderOP, "  StopLevel: ", StopLevel, "  SL: ", OrderSL, "  OSL: ", OrderStopLoss());

                switch (Error) {
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
            } else
                Success = true;
        } else
            break;
    }

    return (Success);
}


//+-------------------------------------------------------------------------+
//| Exit Trade Function - Type: All Basket Hedge Ticket Pending             |
//+-------------------------------------------------------------------------+
int ExitTrades(int Type, color Color, string Reason, int OTicket = 0) {
    static int OTicketNo;
    bool Success;
    int Tries = 0, Closed = 0, CloseCount = 0;
    int CloseTrades[, 2];
    double OPrice;
    string s;
    ca = Type;

    if (Type == T) {
        if (OTicket == 0)
            OTicket = OTicketNo;
        else
            OTicketNo = OTicket;
    }

    for (int Order = OrdersTotal() - 1; Order >= 0; Order--) {
        if (!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
            continue;

        if (Type == B && OrderMagicNumber() != Magic)
            continue;
        else if (Type == H && OrderMagicNumber() != hMagic)
            continue;
        else if (Type == A && OrderMagicNumber() != Magic && OrderMagicNumber() != hMagic)
            continue;
        else if (Type == T && OrderTicket() != OTicket)
            continue;
        else if (Type == P && (OrderMagicNumber() != Magic || OrderType() <= OP_SELL))
            continue;

        ArrayResize(CloseTrades, CloseCount + 1);
        CloseTrades[CloseCount, 0] = (int) OrderOpenTime();
        CloseTrades[CloseCount, 1] = OrderTicket();
        CloseCount++;
    }

    if (CloseCount > 0) {
        if (!UseFIFO)
            ArraySort(CloseTrades, WHOLE_ARRAY, 0, MODE_DESCEND);
        else if (CloseCount != ArraySort(CloseTrades))
            Print("Error sorting CloseTrades Array");

        for (int Order = 0; Order < CloseCount; Order++) {
            if (!OrderSelect(CloseTrades[Order, 1], SELECT_BY_TICKET))
                continue;

            while (IsTradeContextBusy())
                Sleep(100);

            if (IsStopped())
                return (-1);
            else if (OrderType() > OP_SELL)
                Success = OrderDelete(OrderTicket(), Color);
            else {
                if (OrderType() == OP_BUY)
                    OPrice = ND(MarketInfo(OrderSymbol(), MODE_BID), (int) MarketInfo(OrderSymbol(), MODE_DIGITS));
                else
                    OPrice = ND(MarketInfo(OrderSymbol(), MODE_ASK), (int) MarketInfo(OrderSymbol(), MODE_DIGITS));

                Success = OrderClose(OrderTicket(), OrderLots(), OPrice, slip, Color);
            }

            if (Success)
                Closed++;
            else {
                Error = GetLastError();
                Print("Error ", Error, " (", ErrorDescription(Error), ") closing order ", OrderTicket());

                switch (Error) {
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
                    ca = 0;
                    break;
                }
            }
        }

        if (Closed == CloseCount || Closed == 0)
            ca = 0;
    } else
        ca = 0;

    if (Closed > 0) {
        if (Closed != 1)
            s = "s";

        Print("Closed ", Closed, " position", s, " because ", Reason);

        if (PlaySounds)
            PlaySound(AlertSound);
    }

    return (Closed);
}


//+-----------------------------------------------------------------+
//| Find Hedge Profit                                               |
//+-----------------------------------------------------------------+
double FindClosedPL(int Type) {
    double ClosedProfit = 0;

    if (Type == B && UseCloseOldest)
        CbC = 0;

    if (OTbF > 0) {
        for (int Order = OrdersHistoryTotal() - 1; Order >= 0; Order--) {
            if (!OrderSelect(Order, SELECT_BY_POS, MODE_HISTORY))
                continue;

            if (OrderOpenTime() < OTbF)
                continue;

            if (Type == B && OrderMagicNumber() == Magic && OrderType() <= OP_SELL) {
                ClosedProfit += OrderProfit() + OrderSwap() + OrderCommission();

                if (UseCloseOldest)
                    CbC++;
            }

            if (Type == H && OrderMagicNumber() == hMagic)
                ClosedProfit += OrderProfit() + OrderSwap() + OrderCommission();
        }
    }

    return (ClosedProfit);
}


//+-----------------------------------------------------------------+
//| Check Correlation                                               |
//+-----------------------------------------------------------------+
double CheckCorr() {
    double BaseDiff, HedgeDiff, BasePow = 0, HedgePow = 0, Mult = 0;

    for (int Index = CorrPeriod - 1; Index >= 0; Index--) {
        BaseDiff = iClose(Symbol(), 1440, Index) - iMA(Symbol(), 1440, CorrPeriod, 0, MODE_SMA, PRICE_CLOSE, Index);
        HedgeDiff = iClose(HedgeSymbol_, 1440, Index) - iMA(HedgeSymbol_, 1440, CorrPeriod, 0, MODE_SMA, PRICE_CLOSE, Index);
        Mult += BaseDiff * HedgeDiff;
        BasePow += MathPow(BaseDiff, 2);
        HedgePow += MathPow(HedgeDiff, 2);
    }

    if (BasePow * HedgePow > 0)
        return (Mult / MathSqrt(BasePow * HedgePow));

    return (0);
}


//+------------------------------------------------------------------+
//|  Save Equity / Balance Statistics                                |
//+------------------------------------------------------------------+
void Stats(bool NewFile, bool IsTick, double Balance, double DrawDown) {
    double Equity = Balance + DrawDown;
    datetime TimeNow = TimeCurrent();

    if (IsTick) {
        if (Equity < StatLowEquity)
            StatLowEquity = Equity;

        if (Equity > StatHighEquity)
            StatHighEquity = Equity;
    } else {
        while (TimeNow >= NextStats)
            NextStats += StatsPeriod;

        int StatHandle;

        if (NewFile) {
            StatHandle = FileOpen(StatFile, FILE_WRITE | FILE_CSV, ',');
            Print("Stats " + StatFile + " " + (string) StatHandle);
            FileWrite(StatHandle, "Date", "Time", "Balance", "Equity Low", "Equity High", TradeComment);
        } else {
            StatHandle = FileOpen(StatFile, FILE_READ | FILE_WRITE | FILE_CSV, ',');
            FileSeek(StatHandle, 0, SEEK_END);
        }

        if (StatLowEquity == 0) {
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
int GenerateMagicNumber() {
    if (EANumber_ > 99)
        return (EANumber_);

    return (JenkinsHash((string) EANumber_ + "_" + Symbol() + "__" + (string) Period()));
}


int JenkinsHash(string Input) {
    int MagicNo = 0;

    for (int Index = 0; Index < StringLen(Input); Index++) {
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
double ND(double Value, int Precision) {
    return (NormalizeDouble(Value, Precision));
}


//+-----------------------------------------------------------------+
//| Double To String                                                |
//+-----------------------------------------------------------------+
string DTS(double Value, int Precision) {
    return (DoubleToStr(Value, Precision));
}


//+-----------------------------------------------------------------+
//| Integer To String                                                |
//+-----------------------------------------------------------------+
string ITS(int Value) {
    return (IntegerToString(Value));
}


//+-----------------------------------------------------------------+
//| Create Label Function (OBJ_LABEL ONLY)                          |
//+-----------------------------------------------------------------+
void CreateLabel(string Name, string Text, int FontSize, int Corner, int XOffset, double YLine, color Colour = CLR_NONE, string Font = "") {
    double XDistance = 0, YDistance = 0;

    if (Font == "")
        Font = displayFont;

    FontSize += displayFontSize;
    YDistance = displayYcord + displaySpacing * YLine;

    if (Corner == 0)
        XDistance = displayXcord + (XOffset * displayFontSize / 9 * displayRatio);
    else if (Corner == 1)
        XDistance = displayCCIxCord + XOffset * displayRatio;
    else if (Corner == 2)
        XDistance = displayXcord + (XOffset * displayFontSize / 9 * displayRatio);
    else if (Corner == 3) {
        XDistance = XOffset * displayRatio;
        YDistance = YLine;
    } else if (Corner == 5) {
        XDistance = XOffset * displayRatio;
        YDistance = 14 * YLine;
        Corner = 1;
    }

    if (Colour == CLR_NONE)
        Colour = displayColor;

    ObjectCreate(Name, OBJ_LABEL, 0, 0, 0);
    ObjectSetText(Name, Text, FontSize, Font, Colour);
    ObjectSet(Name, OBJPROP_CORNER, Corner);
    ObjectSet(Name, OBJPROP_XDISTANCE, XDistance);
    ObjectSet(Name, OBJPROP_YDISTANCE, YDistance);
}


//+-----------------------------------------------------------------+
//| Create Line Function (OBJ_HLINE ONLY)                           |
//+-----------------------------------------------------------------+
void CreateLine(string Name, color Colour, int Width, int Style) {
    ObjectCreate(Name, OBJ_HLINE, 0, 0, 0);
    ObjectSet(Name, OBJPROP_COLOR, Colour);
    ObjectSet(Name, OBJPROP_WIDTH, Width);
    ObjectSet(Name, OBJPROP_STYLE, Style);
}


//+------------------------------------------------------------------+
//| Draw Label Function (OBJ_LABEL ONLY)                             |
//+------------------------------------------------------------------+
void DrawLabel(string Name, double Value, int XOffset, int Decimal = 2, color Colour = CLR_NONE) {
    int dDigits = Digit[ArrayBsearch(Digit, (int) Value, WHOLE_ARRAY, 0, MODE_ASCEND), 1];
    ObjectSet(Name, OBJPROP_XDISTANCE, displayXcord + (XOffset - 7 * dDigits) * displayFontSize / 9 * displayRatio);
    ObjSetTxt(Name, DTS(Value, Decimal), 0, Colour);
}


//+-----------------------------------------------------------------+
//| Object Set Function                                             |
//+-----------------------------------------------------------------+
void ObjSet(string Name, int XCoord) {
    ObjectSet(Name, OBJPROP_XDISTANCE, displayXcord + XCoord * displayFontSize / 9 * displayRatio);
}


//+-----------------------------------------------------------------+
//| Object Set Text Function                                        |
//+-----------------------------------------------------------------+
void ObjSetTxt(string Name, string Text, int FontSize = 0, color Colour = CLR_NONE, string Font = "") {
    FontSize += displayFontSize;

    if (Font == "")
        Font = displayFont;

    if (Colour == CLR_NONE)
        Colour = displayColor;

    ObjectSetText(Name, Text, FontSize, Font, Colour);
}


//+------------------------------------------------------------------+
//| Delete Overlay Label Function                                    |
//+------------------------------------------------------------------+
void LabelDelete() {
    for (int Object = ObjectsTotal(); Object >= 0; Object--) {
        if (StringSubstr(ObjectName(Object), 0, 2) == "B3")
            ObjectDelete(ObjectName(Object));
    }
}


//+------------------------------------------------------------------+
//| Delete Object Function                                           |
//+------------------------------------------------------------------+
void ObjDel(string Name) {
    if (ObjectFind(Name) != -1)
        ObjectDelete(Name);
}


//+-----------------------------------------------------------------+
//| Create Object List Function                                     |
//+-----------------------------------------------------------------+
void LabelCreate() {
    if (displayOverlay && ((Testing && Visual) || !Testing)) {
        int dDigits;
        string ObjText;
        color ObjClr;

        // CreateLabel("B3LMNum", "Magic: ", 8 - displayFontSize, 5, 59, 1, displayColorFGnd, "Tahoma");
        CreateLabel("B3VMNum", DTS(Magic, 0), 8 - displayFontSize, 5, 5, 1, displayColorFGnd, "Tahoma");
        // CreateLabel("B3LComm", "Trade Comment: " + TradeComment, 8 - displayFontSize, 5, 5, 1.8, displayColorFGnd, "Tahoma");
        CreateLabel("B3LComm", TradeComment, 8 - displayFontSize, 5, 5, 1.8, displayColorFGnd, "Tahoma");

        if (displayLogo) {
            // changed from red airplane to green thumbs up, signify all is good
            // CreateLabel("B3LLogo", "Q", 27, 3, 10, 10, Crimson, "Wingdings");      // Airplane
            // CreateLabel("B3LLogo", "F", 27, 3, 10, 10, Green, "Wingdings");    // F = right pointing finger
            CreateLabel("B3LLogo", "C", 27, 3, 10, 10, Green, "Wingdings");     // C = thumbs up
            CreateLabel("B3LCopy", "This software is free and public domain", 10 - displayFontSize, 3, 5, 3, Silver, "Arial");
        }

        CreateLabel("B3LTime", "Server:", 0, 0, 0, 0);
        CreateLabel("B3VTime", "", 0, 0, 60, 0);
        CreateLabel("B3Line1", "=========================", 0, 0, 0, 1);
        CreateLabel("B3LEPPC", "Equity Protection % Set:", 0, 0, 0, 2);
        dDigits = Digit[ArrayBsearch(Digit, (int) MaxDDPercent, WHOLE_ARRAY, 0, MODE_ASCEND), 1];
        CreateLabel("B3VEPPC", DTS(MaxDDPercent, 2), 0, 0, 167 - 7 * dDigits, 2);
        CreateLabel("B3PEPPC", "%", 0, 0, 193, 2);
        CreateLabel("B3LSTPC", "Stop Trade % Set:", 0, 0, 0, 3);
        dDigits = Digit[ArrayBsearch(Digit, (int) (StopTradePercent_ * 100), WHOLE_ARRAY, 0, MODE_ASCEND), 1];
        CreateLabel("B3VSTPC", DTS(StopTradePercent_ * 100, 2), 0, 0, 167 - 7 * dDigits, 3);
        CreateLabel("B3PSTPC", "%", 0, 0, 193, 3);
        CreateLabel("B3LSTAm", "Stop Trade Amount:", 0, 0, 0, 4);
        CreateLabel("B3VSTAm", "", 0, 0, 167, 4, displayColorLoss);
        CreateLabel("B3LAPPC", "Account Portion:", 0, 0, 0, 5);
		if (PortionPC > 100) {	// r.f.
			dDigits = Digit[ArrayBsearch(Digit, (int) (PortionPC), WHOLE_ARRAY, 0, MODE_ASCEND), 1];
			CreateLabel("B3VAPPC", DTS(PortionPC, 2), 0, 0, 167 - 7 * dDigits, 5);
			CreateLabel("B3PAPPC", " ", 0, 0, 193, 5);
		} else {
			dDigits = Digit[ArrayBsearch(Digit, (int) (PortionPC_ * 100), WHOLE_ARRAY, 0, MODE_ASCEND), 1];
			CreateLabel("B3VAPPC", DTS(PortionPC_ * 100, 2), 0, 0, 167 - 7 * dDigits, 5);
			CreateLabel("B3PAPPC", "%", 0, 0, 193, 5);
		}
        CreateLabel("B3LPBal", "Portion Balance:", 0, 0, 0, 6);
        CreateLabel("B3VPBal", "", 0, 0, 167, 6);
		if (PortionPC > 100) {	// r.f.
			CreateLabel("B3LAPCR", "Portion Risk:", 0, 0, 228, 6);
		} else {
			CreateLabel("B3LAPCR", "Account Risk:", 0, 0, 228, 6);
		}
		CreateLabel("B3VAPCR", DTS(MaxDDPercent * PortionPC_, 2), 0, 0, 347, 6);
        CreateLabel("B3PAPCR", "%", 0, 0, 380, 6);

        if (UseMM) {
            ObjText = "Money Management is ON";
            ObjClr = displayColorProfit;
        } else {
            ObjText = "Money Management is OFF";
            ObjClr = displayColorLoss;
        }

        CreateLabel("B3LMMOO", ObjText, 0, 0, 0, 7, ObjClr);

        if (UsePowerOutSL) {
            ObjText = "Power-Off StopLoss is ON";
            ObjClr = displayColorProfit;
        } else {
            ObjText = "Power-Off StopLoss is OFF";
            ObjClr = displayColorLoss;
        }

        CreateLabel("B3LPOSL", ObjText, 0, 0, 0, 8, ObjClr);
        CreateLabel("B3LDrDn", "Draw Down %:", 0, 0, 228, 8);
        CreateLabel("B3VDrDn", "", 0, 0, 315, 8);

        if (UseHedge_) {
            if (HedgeTypeDD) {
                CreateLabel("B3LhDDn", "Hedge", 0, 0, 190, 8);
                CreateLabel("B3ShDDn", "/", 0, 0, 342, 8);
                CreateLabel("B3VhDDm", "", 0, 0, 347, 8);
            } else {
                CreateLabel("B3LhLvl", "Hedge Level:", 0, 0, 228, 9);
                CreateLabel("B3VhLvl", "", 0, 0, 318, 9);
                CreateLabel("B3ShLvl", "/", 0, 0, 328, 9);
                CreateLabel("B3VhLvT", "", 0, 0, 333, 9);
            }
        }

        CreateLabel("B3Line2", "======================", 0, 0, 0, 9);
        CreateLabel("B3LSLot", "Starting Lot Size:", 0, 0, 0, 10);
        CreateLabel("B3VSLot", "", 0, 0, 130, 10);

        if (MaximizeProfit) {
            ObjText = "Profit Maximizer is ON";
            ObjClr = displayColorProfit;
        } else {
            ObjText = "Profit Maximizer is OFF";
            ObjClr = displayColorLoss;
        }

        CreateLabel("B3LPrMx", ObjText, 0, 0, 0, 11, ObjClr);
        CreateLabel("B3LBask", "Basket", 0, 0, 200, 11);
        CreateLabel("B3LPPot", "Profit Potential:", 0, 0, 30, 12);
        CreateLabel("B3VPPot", "", 0, 0, 190, 12);
        CreateLabel("B3LPrSL", "Profit Trailing Stop:", 0, 0, 30, 13);
        CreateLabel("B3VPrSL", "", 0, 0, 190, 13);
        CreateLabel("B3LPnPL", "Portion P/L / Pips:", 0, 0, 30, 14);
        CreateLabel("B3VPnPL", "", 0, 0, 190, 14);
        CreateLabel("B3SPnPL", "/", 0, 0, 220, 14);
        CreateLabel("B3VPPip", "", 0, 0, 229, 14);
        CreateLabel("B3LPLMM", "Profit/Loss Max/Min:", 0, 0, 30, 15);
        CreateLabel("B3VPLMx", "", 0, 0, 190, 15);
        CreateLabel("B3SPLMM", "/", 0, 0, 220, 15);
        CreateLabel("B3VPLMn", "", 0, 0, 225, 15);
        CreateLabel("B3LOpen", "Open Trades / Lots:", 0, 0, 30, 16);
        CreateLabel("B3LType", "", 0, 0, 170, 16);
        CreateLabel("B3VOpen", "", 0, 0, 207, 16);
        CreateLabel("B3SOpen", "/", 0, 0, 220, 16);
        CreateLabel("B3VLots", "", 0, 0, 229, 16);
        CreateLabel("B3LMvTP", "Move TP by:", 0, 0, 0, 17);
        CreateLabel("B3VMvTP", DTS(MoveTP_ / Pip, 0), 0, 0, 100, 17);
        CreateLabel("B3LMves", "# Moves:", 0, 0, 150, 17);
        CreateLabel("B3VMove", "", 0, 0, 229, 17);
        CreateLabel("B3SMves", "/", 0, 0, 242, 17);
        CreateLabel("B3VMves", DTS(TotalMoves, 0), 0, 0, 249, 17);
        CreateLabel("B3LMxDD", "Max DD:", 0, 0, 0, 18);
        CreateLabel("B3VMxDD", "", 0, 0, 107, 18);
        CreateLabel("B3LDDPC", "Max DD %:", 0, 0, 150, 18);
        CreateLabel("B3VDDPC", "", 0, 0, 229, 18);
        CreateLabel("B3PDDPC", "%", 0, 0, 257, 18);

        if (ForceMarketCond_ < 3)
            CreateLabel("B3LFMCn", "Market trend is forced", 0, 0, 0, 19);

        CreateLabel("B3LTrnd", "", 0, 0, 0, 20);

        if (CCIEntry_ > 0 && displayCCI) {
            CreateLabel("B3LCCIi", "CCI", 2, 1, 12, 1);
            CreateLabel("B3LCm05", "m5", 2, 1, 25, 2.2);
            CreateLabel("B3VCm05", "Ø", 6, 1, 0, 2, Orange, "Wingdings");
            CreateLabel("B3LCm15", "m15", 2, 1, 25, 3.4);
            CreateLabel("B3VCm15", "Ø", 6, 1, 0, 3.2, Orange, "Wingdings");
            CreateLabel("B3LCm30", "m30", 2, 1, 25, 4.6);
            CreateLabel("B3VCm30", "Ø", 6, 1, 0, 4.4, Orange, "Wingdings");
            CreateLabel("B3LCm60", "h1", 2, 1, 25, 5.8);
            CreateLabel("B3VCm60", "Ø", 6, 1, 0, 5.6, Orange, "Wingdings");
        }

        if (UseHolidayShutdown) {
            CreateLabel("B3LHols", "Next Holiday Period", 0, 0, 240, 2);
            CreateLabel("B3LHolD", "From: (yyyy.mm.dd) To:", 0, 0, 232, 3);
            CreateLabel("B3VHolF", "", 0, 0, 232, 4);
            CreateLabel("B3VHolT", "", 0, 0, 300, 4);
        }
    }
}
